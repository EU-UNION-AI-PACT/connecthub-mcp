import Uppy from '@uppy/core';
import AwsS3Multipart from '@uppy/aws-s3-multipart';

export function configureConnectHubUppy(
  uppy: Uppy,
  apiBaseUrl: string,
  authToken: string,
  tenantId: string
) {
  uppy.use(AwsS3Multipart, {
    limit: 4,
    retryDelays: [0, 1000, 3000, 5000],

    async createMultipartUpload(file: any) {
      const res = await fetch(`${apiBaseUrl}/uploads/init`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${authToken}`,
          'X-Tenant-ID': tenantId,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          filename: file.name,
          sizeBytes: file.size,
          contentType: file.type
        })
      });
      const data = await res.json();
      return {
        uploadId: data.uploadId,
        key: data.objectKey
      };
    },

    async signPart(file: any, partData: any) {
      const { uploadId, key, partNumber } = partData;
      const res = await fetch(
        `${apiBaseUrl}/uploads/sign-part?key=${encodeURIComponent(key)}&uploadId=${uploadId}&partNumber=${partNumber}`,
        {
          headers: {
            Authorization: `Bearer ${authToken}`,
            'X-Tenant-ID': tenantId
          }
        }
      );
      const data = await res.json();
      return { url: data.presignedUrl };
    },

    async completeMultipartUpload(file: any, { uploadId, key, parts }: any) {
      const res = await fetch(`${apiBaseUrl}/uploads/complete`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${authToken}`,
          'X-Tenant-ID': tenantId,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ uploadId, objectKey: key, parts })
      });
      const data = await res.json();
      return { location: data.location };
    },

    async abortMultipartUpload(file: any, { uploadId, key }: any) {
      await fetch(`${apiBaseUrl}/uploads/abort`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${authToken}`,
          'X-Tenant-ID': tenantId,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ uploadId, objectKey: key })
      });
    }
  });
}
