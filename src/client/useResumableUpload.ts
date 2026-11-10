import { useState, useRef, useCallback } from 'react';
import { ResumableS3Uploader, UploadProgress } from './ResumableS3Uploader';

export function useResumableUpload(apiBaseUrl: string, authToken: string, tenantId: string) {
  const [progress, setProgress] = useState<UploadProgress | null>(null);
  const [status, setStatus] = useState<'idle' | 'uploading' | 'paused' | 'completed' | 'error'>('idle');
  const [error, setError] = useState<string | null>(null);
  const uploaderRef = useRef<ResumableS3Uploader | null>(null);

  const startUpload = useCallback((file: File) => {
    setStatus('uploading');
    setError(null);

    const uploader = new ResumableS3Uploader(file, {
      apiBaseUrl,
      authToken,
      tenantId,
      onProgress: (p) => setProgress(p),
      onSuccess: () => setStatus('completed'),
      onError: (err) => {
        setStatus('error');
        setError(err.message);
      }
    });

    uploaderRef.current = uploader;
    uploader.start();
  }, [apiBaseUrl, authToken, tenantId]);

  const pauseUpload = useCallback(() => {
    if (uploaderRef.current) {
      uploaderRef.current.pause();
      setStatus('paused');
    }
  }, []);

  const resumeUpload = useCallback(() => {
    if (uploaderRef.current) {
      setStatus('uploading');
      uploaderRef.current.start();
    }
  }, []);

  const abortUpload = useCallback(() => {
    if (uploaderRef.current) {
      uploaderRef.current.abort();
      setStatus('idle');
      setProgress(null);
    }
  }, []);

  return {
    startUpload,
    pauseUpload,
    resumeUpload,
    abortUpload,
    progress,
    status,
    error
  };
}
