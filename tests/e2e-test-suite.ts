import { DatabaseSync } from 'node:sqlite';
import path from 'path';
import { jobQueue } from '../src/worker/queue';
import { DynamicConnectorRouter } from '../src/backend/dynamic-connector-router';
import '../src/worker/job-processor';

const DB_PATH = path.join(__dirname, '../database/connecthub_production.db');

async function runTestSuite() {
  console.log('🧪 Starting ConnectHub MCP End-to-End Test Suite...\n');
  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, msg: string) {
    if (condition) {
      console.log(`  ✅ PASS: ${msg}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${msg}`);
      failed++;
    }
  }

  // 1. Database Integrity & 200 Installations Test
  console.log('1️⃣ Testing Database Integrity & 200 Active Installations...');
  const db = new DatabaseSync(DB_PATH);
  const rowCount: any = db.prepare("SELECT COUNT(*) as cnt FROM connector_installations WHERE status = 'active'").get();
  assert(rowCount?.cnt === 200, `Found exactly ${rowCount?.cnt} active connector installations in DB (Expected: 200)`);
  const rowV: any = db.prepare('SELECT COUNT(*) as cnt FROM data_versions').get();
  assert(rowV?.cnt >= 200, `Found ${rowV?.cnt} initial data version snapshots (Expected: >= 200)`);
  db.close();

  // 2. Dynamic Connector Router Health Check Test
  console.log('\n2️⃣ Testing Dynamic Connector Router for Native & Cloud MCP...');
  const sqliteTest = await DynamicConnectorRouter.execute({
    connectorKey: 'sqlite',
    action: 'test_connection',
    tenantId: 'a0000000-0000-0000-0000-000000000001'
  });
  assert(sqliteTest.output !== undefined || sqliteTest.status !== 'failed', 'SQLite MCP list_tables execution completed');

  const auth0Test = await DynamicConnectorRouter.execute({
    connectorKey: 'auth0_identity',
    action: 'test_connection',
    tenantId: 'a0000000-0000-0000-0000-000000000001'
  });
  assert(auth0Test.status === 'connected', 'Auth0 Identity Engine connected & verified');

  // 3. Asynchronous Job Queue & Worker Pipeline Test
  console.log('\n3️⃣ Testing Async Job Queue & Worker Execution...');
  const tenantId = 'a0000000-0000-0000-0000-000000000001';

  const syncJob = await jobQueue.add({
    tenantId,
    connectorKey: 'github',
    jobType: 'sync',
    inputMetadata: { repository: 'EU-UNION-AI-PACT/connecthub-mcp', branch: 'main' }
  });

  assert(syncJob.status === 'queued' || syncJob.status === 'running', `Sync Job successfully enqueued with ID: ${syncJob.id}`);

  // Wait for worker execution and progress updates
  await new Promise<void>((resolve) => {
    const onSucceeded = (job: any) => {
      if (job.id === syncJob.id) {
        assert(job.status === 'succeeded', 'Worker executed sync job to status: succeeded');
        assert(job.progress === 100, 'Job progress reached 100%');
        assert(job.resultMetadata.commitHash !== undefined, `Cryptographic commit hash generated: ${job.resultMetadata.commitHash?.slice(0, 16)}...`);
        assert(job.resultMetadata.recordsSynced > 0, `Records synced: ${job.resultMetadata.recordsSynced.toLocaleString()}`);
        jobQueue.off('job:succeeded', onSucceeded);
        resolve();
      }
    };
    jobQueue.on('job:succeeded', onSucceeded);
  });

  // 4. Verify Data Version Persistence after Sync Job
  console.log('\n4️⃣ Verifying New Data Version Snapshot in Database...');
  const dbVerify = new DatabaseSync(DB_PATH);
  const rowGh: any = dbVerify.prepare("SELECT COUNT(*) as cnt FROM data_versions WHERE installation_id = 'github'").get();
  assert(rowGh?.cnt > 0, `New data version snapshot recorded for GitHub (Total GitHub snapshots: ${rowGh?.cnt})`);
  dbVerify.close();

  console.log('\n======================================================');
  console.log(`🏁 TEST RESULTS: ${passed} PASSED | ${failed} FAILED`);
  console.log('======================================================\n');

  if (failed > 0) process.exit(1);
  process.exit(0);
}

runTestSuite().catch(console.error);
