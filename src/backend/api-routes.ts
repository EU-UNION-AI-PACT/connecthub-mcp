import { Router } from 'express';
import { checkJwt, resolveTenantContext, requireRole } from './auth';
import { UploadService } from './upload-service';
import { DynamicConnectorRouter } from './dynamic-connector-router';
import sqlite3 from 'sqlite3';
import path from 'path';

const router = Router();
const DB_PATH = path.join(__dirname, '../../database/connecthub_production.db');

// In-Memory upload store
const uploadSessions = new Map<string, any>();

// 1. Health Endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Authenticated Pipeline
router.use(checkJwt, resolveTenantContext);

// 2. Connector Catalog & 200 Active Installations
router.get('/connectors/installed', async (req, res) => {
  const db = new sqlite3.Database(DB_PATH);
  db.all(
    `SELECT i.id, i.display_name, i.status, i.version_tag, i.endpoint_url, i.auth_method, i.last_tested_at,
            c.category, c.integration_type, c.has_official_mcp
     FROM connector_installations i
     JOIN connector_catalog c ON i.connector_id = c.id
     WHERE i.tenant_id = ?`,
    [req.user!.tenant_id],
    (err, rows) => {
      db.close();
      if (err) return res.status(500).json({ error: err.message });
      res.json({ tenant: req.user!.tenant_id, count: rows.length, installations: rows });
    }
  );
});

// 3. Data Versions Audit & Git-like Snapshots
router.get('/data-versions', async (req, res) => {
  const db = new sqlite3.Database(DB_PATH);
  db.all(
    `SELECT v.id, v.version_tag, v.commit_hash, v.records_count, v.size_bytes, v.storage_location, v.created_at,
            i.display_name AS connector_name
     FROM data_versions v
     JOIN connector_installations i ON v.installation_id = i.id
     WHERE v.tenant_id = ?
     ORDER BY v.created_at DESC LIMIT 100`,
    [req.user!.tenant_id],
    (err, rows) => {
      db.close();
      if (err) return res.status(500).json({ error: err.message });
      res.json({ tenant: req.user!.tenant_id, count: rows.length, versions: rows });
    }
  );
});

// 4. Test Any Connector via Dynamic Router
router.post('/connectors/:key/test', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  try {
    const result = await DynamicConnectorRouter.execute({
      connectorKey: req.params.key,
      action: 'test_connection',
      tenantId: req.user!.tenant_id
    });
    res.json({ status: 'connected', result });
  } catch (err: any) {
    res.status(500).json({ status: 'failed', error: err.message });
  }
});

// 5. Init Resumable S3 Upload
router.post('/uploads/init', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const { filename, sizeBytes } = req.body;
  const session = await UploadService.initUpload(req.user!.tenant_id, filename, sizeBytes);
  uploadSessions.set(session.sessionId, { ...session, parts: [] });
  res.json(session);
});

// 6. Get Presigned Part URL
router.get('/uploads/:sessionId/part-url', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  const partNumber = parseInt(req.query.partNumber as string, 10);
  const presignedUrl = await UploadService.getPartPresignedUrl(session.objectKey, session.uploadId, partNumber);
  res.json({ presignedUrl, partNumber });
});

// 7. Report Part Complete
router.post('/uploads/:sessionId/part-complete', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  const { partNumber, etag } = req.body;
  session.parts.push({ partNumber, etag });
  res.json({ status: 'recorded', partNumber });
});

// 8. Complete Upload
router.post('/uploads/:sessionId/complete', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  await UploadService.completeUpload(session.objectKey, session.uploadId, req.body.parts);
  uploadSessions.delete(req.params.sessionId);
  res.json({ status: 'completed', objectKey: session.objectKey });
});

export default router;
