import { Router } from 'express';
import { checkJwt, resolveTenantContext, requireRole } from './auth';
import { UploadService } from './upload-service';
import { McpOrchestrator } from './mcp-orchestrator';

const router = Router();

// In-Memory store for demonstration / testing (Replaced with PostgreSQL in production)
const uploadSessions = new Map<string, any>();

// 1. Health Endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Authenticated Pipeline
router.use(checkJwt, resolveTenantContext);

// 2. Connector Catalog
router.get('/connectors/catalog', async (req, res) => {
  res.json({
    tenant: req.user!.tenant_id,
    userRole: req.user!.role,
    count: 40,
    catalog: [
      { id: 'github', name: 'GitHub', category: 'Development', mcp: true },
      { id: 'duckdb', name: 'DuckDB', category: 'Database', mcp: true },
      { id: 'postgres', name: 'PostgreSQL', category: 'Database', mcp: true },
      { id: 's3', name: 'AWS S3', category: 'Storage', mcp: true }
    ]
  });
});

// 3. Test Connector Connection via MCP
router.post('/connectors/:id/test', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  try {
    const result = await McpOrchestrator.executeTool(
      'uvx',
      ['--with', 'mcp<1.2.0', 'mcp-server-sqlite', '--db-path', '/tmp/test.db'],
      'list_tables',
      {}
    );
    res.json({ status: 'connected', result });
  } catch (err: any) {
    res.status(500).json({ status: 'failed', error: err.message });
  }
});

// 4. Init Upload Session
router.post('/uploads/init', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const { filename, sizeBytes } = req.body;
  const session = await UploadService.initUpload(req.user!.tenant_id, filename, sizeBytes);
  uploadSessions.set(session.sessionId, { ...session, parts: [] });
  res.json(session);
});

// 5. Get Presigned Part URL
router.get('/uploads/:sessionId/part-url', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  const partNumber = parseInt(req.query.partNumber as string, 10);
  const presignedUrl = await UploadService.getPartPresignedUrl(session.objectKey, session.uploadId, partNumber);
  res.json({ presignedUrl, partNumber });
});

// 6. Report Part Complete
router.post('/uploads/:sessionId/part-complete', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  const { partNumber, etag } = req.body;
  session.parts.push({ partNumber, etag });
  res.json({ status: 'recorded', partNumber });
});

// 7. Complete Upload
router.post('/uploads/:sessionId/complete', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (!session) return res.status(404).json({ error: 'Upload session not found' });

  await UploadService.completeUpload(session.objectKey, session.uploadId, req.body.parts);
  uploadSessions.delete(req.params.sessionId);
  res.json({ status: 'completed', objectKey: session.objectKey });
});

// 8. Abort Upload
router.post('/uploads/:sessionId/abort', requireRole(['owner', 'admin', 'editor']), async (req, res) => {
  const session = uploadSessions.get(req.params.sessionId);
  if (session) {
    await UploadService.abortUpload(session.objectKey, session.uploadId);
    uploadSessions.delete(req.params.sessionId);
  }
  res.json({ status: 'aborted' });
});

export default router;
