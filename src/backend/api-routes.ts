import { Router } from 'express';
import { checkJwt, resolveTenantContext, requireRole } from './auth';
import { UploadService } from './upload-service';
import { DynamicConnectorRouter } from './dynamic-connector-router';
import { jobQueue } from '../worker/queue';
import '../worker/job-processor';
import { DatabaseSync } from 'node:sqlite';
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
  try {
    const db = new DatabaseSync(DB_PATH);
    const stmt = db.prepare(`
      SELECT i.id, i.display_name, i.status, i.version_tag, i.endpoint_url, i.auth_method, i.last_tested_at,
             c.category, c.integration_type, c.has_official_mcp
      FROM connector_installations i
      JOIN connector_catalog c ON i.connector_id = c.id
      WHERE i.tenant_id = ?
    `);
    const rows = stmt.all(req.user!.tenant_id);
    db.close();
    res.json({ tenant: req.user!.tenant_id, count: rows.length, installations: rows });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Data Versions Audit & Git-like Snapshots
router.get('/data-versions', async (req, res) => {
  try {
    const db = new DatabaseSync(DB_PATH);
    const stmt = db.prepare(`
      SELECT v.id, v.version_tag, v.commit_hash, v.records_count, v.size_bytes, v.storage_location, v.created_at,
             i.display_name AS connector_name
      FROM data_versions v
      JOIN connector_installations i ON v.installation_id = i.id
      WHERE v.tenant_id = ?
      ORDER BY v.created_at DESC LIMIT 100
    `);
    const rows = stmt.all(req.user!.tenant_id);
    db.close();
    res.json({ tenant: req.user!.tenant_id, count: rows.length, versions: rows });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
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

// 8. Get Upload Session Status
router.get('/uploads/:sessionId/status', requireRole(['owner', 'admin', 'editor', 'viewer']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });
  res.json({
    sessionId: session.sessionId,
    status: session.status || 'uploading',
    objectKey: session.objectKey,
    totalParts: session.totalParts,
    completedParts: session.parts,
    completedPartsCount: session.parts.length
  });
});

// 9. Abort Upload Session
router.post('/uploads/:sessionId/abort', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  try {
    await UploadService.abortUpload(session.objectKey, session.uploadId);
  } catch (err: any) {
    console.warn('S3 AbortMultipartUpload warning:', err.message);
  }

  uploadSessions.delete(req.params.sessionId);
  res.json({ status: 'aborted', sessionId: req.params.sessionId });
});

// 10. Complete Upload & Enqueue Processing Job
router.post('/uploads/:sessionId/complete', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  await UploadService.completeUpload(session.objectKey, session.uploadId, req.body.parts);
  uploadSessions.delete(req.params.sessionId);

  await jobQueue.add({
    tenantId: req.user!.tenant_id,
    connectorKey: 's3_storage',
    jobType: 'upload_process',
    inputMetadata: { objectKey: session.objectKey, sizeBytes: req.body.sizeBytes }
  });

  res.json({ status: 'completed', objectKey: session.objectKey });
});

// 11. Dispatch Background Job (sync, connection_test, export)
router.post('/jobs/dispatch', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const { connectorKey, jobType, inputMetadata, idempotencyKey } = req.body;
  if (!connectorKey || !jobType) {
    return res.status(400).json({ error: 'Missing connectorKey or jobType' });
  }

  const job = await jobQueue.add({
    tenantId: req.user!.tenant_id,
    connectorKey,
    jobType,
    inputMetadata: inputMetadata || {},
    idempotencyKey
  });

  res.json({ status: 'queued', job });
});

// 12. List Jobs for Tenant
router.get('/jobs', async (req, res) => {
  const jobs = jobQueue.list(req.user!.tenant_id);
  res.json({ tenant: req.user!.tenant_id, count: jobs.length, jobs });
});

// 13. Get Job by ID
router.get('/jobs/:id', async (req, res) => {
  const job = jobQueue.get(req.params.id);
  if (!job || job.tenantId !== req.user!.tenant_id) {
    return res.status(404).json({ error: 'Job not found' });
  }
  res.json(job);
});

// 14. Real Metrics Summary (Direct from DB & Queue, no hardcoded stats)
router.get('/metrics/summary', async (req, res) => {
  try {
    const db = new DatabaseSync(DB_PATH);
    const totalInst: any = db.prepare('SELECT COUNT(*) as count FROM connector_installations WHERE tenant_id = ?').get(req.user!.tenant_id);
    const verifiedInst: any = db.prepare("SELECT COUNT(*) as count FROM connector_installations WHERE tenant_id = ? AND status IN ('verified', 'active')").get(req.user!.tenant_id);
    const cataloguedInst: any = db.prepare("SELECT COUNT(*) as count FROM connector_installations WHERE tenant_id = ? AND status = 'catalogued'").get(req.user!.tenant_id);
    const totalVersions: any = db.prepare('SELECT COUNT(*) as count FROM data_versions WHERE tenant_id = ?').get(req.user!.tenant_id);
    db.close();

    const jobs = jobQueue.list(req.user!.tenant_id);
    const succeededJobs = jobs.filter(j => j.status === 'succeeded').length;
    const successRate = jobs.length > 0 ? ((succeededJobs / jobs.length) * 100).toFixed(1) : '100.0';

    res.json({
      tenantId: req.user!.tenant_id,
      connectors: {
        total: totalInst?.count || 0,
        verified: verifiedInst?.count || 0,
        catalogued: cataloguedInst?.count || 0
      },
      dataVersions: totalVersions?.count || 0,
      jobs: {
        total: jobs.length,
        succeeded: succeededJobs,
        successRate: `${successRate}%`
      }
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
