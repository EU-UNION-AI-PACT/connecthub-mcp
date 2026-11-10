import { S3Client, CreateMultipartUploadCommand, UploadPartCommand, CompleteMultipartUploadCommand, AbortMultipartUploadCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3 = new S3Client({
  region: process.env.AWS_REGION || 'eu-central-1',
  endpoint: process.env.S3_ENDPOINT, // Optional for MinIO / LocalStack
  forcePathStyle: Boolean(process.env.S3_ENDPOINT) // required for MinIO
});

const BUCKET_NAME = process.env.S3_BUCKET || 'connecthub-tenant-storage';
const DEFAULT_PART_SIZE = 25 * 1024 * 1024; // 25 MB Chunks

export class UploadService {
  public static async initUpload(tenantId: string, filename: string, sizeBytes: number) {
    const objectKey = `${tenantId}/uploads/${Date.now()}_${filename}`;

    const createRes = await s3.send(new CreateMultipartUploadCommand({
      Bucket: BUCKET_NAME,
      Key: objectKey,
      Metadata: { tenant_id: tenantId, original_filename: filename }
    }));

    const uploadId = createRes.UploadId!;
    const totalParts = Math.ceil(sizeBytes / DEFAULT_PART_SIZE);

    return {
      sessionId: `sess_${Date.now()}`,
      objectKey,
      uploadId,
      partSize: DEFAULT_PART_SIZE,
      totalParts
    };
  }

  public static async getPartPresignedUrl(objectKey: string, uploadId: string, partNumber: number): Promise<string> {
    return getSignedUrl(s3, new UploadPartCommand({
      Bucket: BUCKET_NAME,
      Key: objectKey,
      UploadId: uploadId,
      PartNumber: partNumber
    }), { expiresIn: 3600 });
  }

  public static async completeUpload(
    objectKey: string,
    uploadId: string,
    parts: { PartNumber: number; ETag: string }[]
  ) {
    return s3.send(new CompleteMultipartUploadCommand({
      Bucket: BUCKET_NAME,
      Key: objectKey,
      UploadId: uploadId,
      MultipartUpload: {
        Parts: parts.sort((a, b) => a.PartNumber - b.PartNumber)
      }
    }));
  }

  public static async abortUpload(objectKey: string, uploadId: string) {
    return s3.send(new AbortMultipartUploadCommand({
      Bucket: BUCKET_NAME,
      Key: objectKey,
      UploadId: uploadId
    }));
  }
}
