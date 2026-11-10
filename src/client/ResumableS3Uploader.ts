/**
 * ConnectHub MCP - Resumable S3 / MinIO Multipart Uploader
 * 
 * Features:
 * - Direct-to-Storage via Presigned URLs (zero backend proxy bottleneck)
 * - 4x Concurrency Worker Pool
 * - Resumable via LocalStorage / IndexedDB session cache
 * - Pause / Resume / Abort controls
 * - Exponential backoff retry on network drops
 */

export interface UploadOptions {
  apiBaseUrl: string;
  authToken: string;
  tenantId: string;
  partSize?: number; // Default: 25 MB
  concurrency?: number; // Default: 4
  maxRetries?: number; // Default: 5
  onProgress?: (progress: UploadProgress) => void;
  onError?: (error: Error) => void;
  onSuccess?: (result: UploadCompleteResult) => void;
}

export interface UploadProgress {
  bytesUploaded: number;
  totalBytes: number;
  percentage: number;
  activeParts: number[];
  completedParts: number;
  totalParts: number;
  speedBytesPerSec: number;
}

export interface UploadCompleteResult {
  sessionId: string;
  objectKey: string;
  checksum: string;
}

interface StoredSessionState {
  sessionId: string;
  uploadId: string;
  objectKey: string;
  fileSignature: string;
  partSize: number;
  totalParts: number;
  completedParts: { partNumber: number; etag: string }[];
}

export class ResumableS3Uploader {
  private file: File;
  private options: Required<UploadOptions>;
  private isPaused: boolean = false;
  private isAborted: boolean = false;
  private activeControllers: Map<number, AbortController> = new Map();
  private state!: StoredSessionState;
  private lastProgressTime: number = Date.now();
  private lastProgressBytes: number = 0;

  constructor(file: File, options: UploadOptions) {
    this.file = file;
    this.options = {
      partSize: 25 * 1024 * 1024,
      concurrency: 4,
      maxRetries: 5,
      onProgress: () => {},
      onError: () => {},
      onSuccess: () => {},
      ...options
    };
  }

  private get fileSignature(): string {
    return `${this.file.name}_${this.file.size}_${this.file.lastModified}`;
  }

  private get storageKey(): string {
    return `connecthub_upload_${this.options.tenantId}_${this.fileSignature}`;
  }

  public async start(): Promise<void> {
    this.isPaused = false;
    this.isAborted = false;

    try {
      await this.initOrResumeSession();

      const completedSet = new Set(this.state.completedParts.map((p) => p.partNumber));
      const pendingParts: number[] = [];

      for (let i = 1; i <= this.state.totalParts; i++) {
        if (!completedSet.has(i)) {
          pendingParts.push(i);
        }
      }

      if (pendingParts.length === 0) {
        await this.finalizeUpload();
        return;
      }

      await this.runWorkerPool(pendingParts);

      if (!this.isPaused && !this.isAborted) {
        await this.finalizeUpload();
      }
    } catch (err: any) {
      if (!this.isPaused && !this.isAborted) {
        this.options.onError(err);
      }
    }
  }

  public pause(): void {
    this.isPaused = true;
    for (const controller of this.activeControllers.values()) {
      controller.abort();
    }
    this.activeControllers.clear();
  }

  public async abort(): Promise<void> {
    this.isAborted = true;
    this.pause();

    try {
      if (this.state?.sessionId) {
        await fetch(`${this.options.apiBaseUrl}/uploads/${this.state.sessionId}/abort`, {
          method: 'POST',
          headers: this.authHeaders()
        });
      }
    } finally {
      localStorage.removeItem(this.storageKey);
    }
  }

  private async initOrResumeSession(): Promise<void> {
    const rawState = localStorage.getItem(this.storageKey);

    if (rawState) {
      try {
        const parsed: StoredSessionState = JSON.parse(rawState);
        const res = await fetch(`${this.options.apiBaseUrl}/uploads/${parsed.sessionId}/status`, {
          headers: this.authHeaders()
        });

        if (res.ok) {
          const remoteStatus = await res.json();
          if (remoteStatus.status === 'uploading' || remoteStatus.status === 'initiated') {
            this.state = {
              ...parsed,
              completedParts: remoteStatus.parts || parsed.completedParts
            };
            return;
          }
        }
      } catch (e) {
        // Fallback
      }
    }

    const totalParts = Math.ceil(this.file.size / this.options.partSize);
    const res = await fetch(`${this.options.apiBaseUrl}/uploads/init`, {
      method: 'POST',
      headers: { ...this.authHeaders(), 'Content-Type': 'application/json' },
      body: JSON.stringify({
        filename: this.file.name,
        sizeBytes: this.file.size,
        contentType: this.file.type || 'application/octet-stream',
        partSize: this.options.partSize,
        totalParts
      })
    });

    if (!res.ok) {
      throw new Error(`Init Upload failed with status ${res.status}`);
    }

    const data = await res.json();
    this.state = {
      sessionId: data.sessionId,
      uploadId: data.uploadId,
      objectKey: data.objectKey,
      fileSignature: this.fileSignature,
      partSize: this.options.partSize,
      totalParts,
      completedParts: []
    };

    this.saveState();
  }

  private async runWorkerPool(pendingParts: number[]): Promise<void> {
    const queue = [...pendingParts];
    const workers: Promise<void>[] = [];

    const worker = async (): Promise<void> => {
      while (queue.length > 0 && !this.isPaused && !this.isAborted) {
        const partNumber = queue.shift()!;
        await this.uploadPartWithRetry(partNumber);
      }
    };

    const workerCount = Math.min(this.options.concurrency, queue.length);
    for (let i = 0; i < workerCount; i++) {
      workers.push(worker());
    }

    await Promise.all(workers);
  }

  private async uploadPartWithRetry(partNumber: number): Promise<void> {
    let attempt = 0;

    while (attempt < this.options.maxRetries && !this.isPaused && !this.isAborted) {
      attempt++;
      try {
        const controller = new AbortController();
        this.activeControllers.set(partNumber, controller);

        const presignedUrl = await this.getPresignedPartUrl(partNumber);
        const start = (partNumber - 1) * this.state.partSize;
        const end = Math.min(start + this.state.partSize, this.file.size);
        const chunk = this.file.slice(start, end);

        const s3Res = await fetch(presignedUrl, {
          method: 'PUT',
          body: chunk,
          signal: controller.signal
        });

        if (!s3Res.ok) {
          throw new Error(`S3 Part Upload ${partNumber} failed: ${s3Res.status}`);
        }

        const rawEtag = s3Res.headers.get('ETag') || s3Res.headers.get('etag');
        if (!rawEtag) {
          throw new Error(`Missing ETag header on Part ${partNumber}`);
        }
        const etag = rawEtag.replace(/"/g, '');

        await this.reportPartComplete(partNumber, etag, end - start);

        this.state.completedParts.push({ partNumber, etag });
        this.saveState();
        this.activeControllers.delete(partNumber);

        this.notifyProgress();
        return;
      } catch (err: any) {
        this.activeControllers.delete(partNumber);
        if (this.isPaused || this.isAborted) return;

        if (attempt >= this.options.maxRetries) {
          throw new Error(`Part ${partNumber} failed after ${attempt} retries: ${err.message}`);
        }

        const backoffMs = Math.pow(2, attempt) * 250 + Math.random() * 100;
        await new Promise((r) => setTimeout(r, backoffMs));
      }
    }
  }

  private async getPresignedPartUrl(partNumber: number): Promise<string> {
    const res = await fetch(
      `${this.options.apiBaseUrl}/uploads/${this.state.sessionId}/part-url?partNumber=${partNumber}`,
      { headers: this.authHeaders() }
    );
    if (!res.ok) throw new Error(`Could not get Part URL for part ${partNumber}`);
    const data = await res.json();
    return data.presignedUrl;
  }

  private async reportPartComplete(partNumber: number, etag: string, sizeBytes: number): Promise<void> {
    await fetch(`${this.options.apiBaseUrl}/uploads/${this.state.sessionId}/part-complete`, {
      method: 'POST',
      headers: { ...this.authHeaders(), 'Content-Type': 'application/json' },
      body: JSON.stringify({ partNumber, etag, sizeBytes })
    });
  }

  private async finalizeUpload(): Promise<void> {
    const res = await fetch(`${this.options.apiBaseUrl}/uploads/${this.state.sessionId}/complete`, {
      method: 'POST',
      headers: { ...this.authHeaders(), 'Content-Type': 'application/json' },
      body: JSON.stringify({
        parts: this.state.completedParts
      })
    });

    if (!res.ok) {
      throw new Error(`Complete upload failed with status ${res.status}`);
    }

    const data = await res.json();
    localStorage.removeItem(this.storageKey);

    this.options.onSuccess({
      sessionId: this.state.sessionId,
      objectKey: this.state.objectKey,
      checksum: data.checksum
    });
  }

  private notifyProgress(): void {
    const completedCount = this.state.completedParts.length;
    let bytesUploaded = 0;

    for (const p of this.state.completedParts) {
      const start = (p.partNumber - 1) * this.state.partSize;
      const end = Math.min(start + this.state.partSize, this.file.size);
      bytesUploaded += end - start;
    }

    const now = Date.now();
    const timeDeltaSec = (now - this.lastProgressTime) / 1000;
    let speed = 0;
    if (timeDeltaSec > 0.5) {
      speed = (bytesUploaded - this.lastProgressBytes) / timeDeltaSec;
      this.lastProgressTime = now;
      this.lastProgressBytes = bytesUploaded;
    }

    this.options.onProgress({
      bytesUploaded,
      totalBytes: this.file.size,
      percentage: Math.round((bytesUploaded / this.file.size) * 100),
      activeParts: Array.from(this.activeControllers.keys()),
      completedParts: completedCount,
      totalParts: this.state.totalParts,
      speedBytesPerSec: speed
    });
  }

  private saveState(): void {
    localStorage.setItem(this.storageKey, JSON.stringify(this.state));
  }

  private authHeaders(): Record<string, string> {
    return {
      Authorization: `Bearer ${this.options.authToken}`,
      'X-Tenant-ID': this.options.tenantId
    };
  }
}
