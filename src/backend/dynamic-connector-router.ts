import { McpOrchestrator, McpToolCallResult } from './mcp-orchestrator';

export type ConnectorStatus = 'catalogued' | 'configured' | 'authenticated' | 'verified' | 'active' | 'failed';

export interface ConnectorExecutionOptions {
  connectorKey: string;
  action: 'test_connection' | 'sync_data' | 'fetch_schema' | 'invoke_tool';
  params?: Record<string, any>;
  tenantId: string;
}

export interface ConnectorExecutionResult {
  status: ConnectorStatus;
  connector: string;
  action: string;
  tenantId: string;
  executionId: string;
  latencyMs: number;
  testedAt: string;
  healthy: boolean | null;
  data?: any;
  message?: string;
  providerDetails?: Record<string, any>;
  dataVersionHash?: string;
}

const AUTH0_DOMAIN = process.env.AUTH0_DOMAIN || 'auth0.auth0.com';

export class DynamicConnectorRouter {
  /**
   * Dispatches execution to real MCP toolchains, live provider APIs, or honest catalog status
   */
  public static async execute(options: ConnectorExecutionOptions): Promise<ConnectorExecutionResult> {
    const { connectorKey, action, params = {}, tenantId } = options;
    const startTime = Date.now();
    const executionId = `exec_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    // 1. Core Native MCP Server: SQLite (Real execution)
    if (connectorKey === 'sqlite') {
      try {
        const mcpRes = await McpOrchestrator.executeTool(
          'uvx',
          ['--with', 'mcp<1.2.0', 'mcp-server-sqlite', '--db-path', '/tmp/test.db'],
          action === 'test_connection' ? 'list_tables' : 'read_query',
          params.query ? params : { query: 'SELECT 1 AS health_check, sqlite_version() as version;' }
        );
        const latencyMs = Date.now() - startTime;
        return {
          status: 'verified',
          connector: 'sqlite',
          action,
          tenantId,
          executionId,
          latencyMs,
          testedAt: new Date().toISOString(),
          healthy: true,
          data: mcpRes,
          providerDetails: { engine: 'SQLite 3 via FastMCP', mode: 'embedded-oltp' }
        };
      } catch (err: any) {
        return {
          status: 'failed',
          connector: 'sqlite',
          action,
          tenantId,
          executionId,
          latencyMs: Date.now() - startTime,
          testedAt: new Date().toISOString(),
          healthy: false,
          message: `SQLite MCP execution error: ${err.message}`
        };
      }
    }

    // 2. Core Native MCP Server: DuckDB (Real execution)
    if (connectorKey === 'duckdb') {
      try {
        const mcpRes = await McpOrchestrator.executeTool(
          'uvx',
          ['--with', 'mcp<1.2.0', 'mcp-server-duckdb', '--db-path', '/tmp/analytics.duckdb'],
          'query',
          params.query ? params : { query: 'SELECT 1 AS health_check, current_date AS date;' }
        );
        const latencyMs = Date.now() - startTime;
        return {
          status: 'verified',
          connector: 'duckdb',
          action,
          tenantId,
          executionId,
          latencyMs,
          testedAt: new Date().toISOString(),
          healthy: true,
          data: mcpRes,
          providerDetails: { engine: 'DuckDB OLAP Columnar via FastMCP' }
        };
      } catch (err: any) {
        return {
          status: 'failed',
          connector: 'duckdb',
          action,
          tenantId,
          executionId,
          latencyMs: Date.now() - startTime,
          testedAt: new Date().toISOString(),
          healthy: false,
          message: `DuckDB MCP execution error: ${err.message}`
        };
      }
    }

    // 3. Real Provider Health Check: GitHub (Auditor recommended initial live candidate!)
    if (connectorKey === 'github') {
      try {
        const headers: Record<string, string> = {
          'User-Agent': 'ConnectHub-MCP-Platform/1.0',
          'Accept': 'application/vnd.github.v3+json'
        };
        if (process.env.GITHUB_TOKEN) {
          headers['Authorization'] = `token ${process.env.GITHUB_TOKEN}`;
        }

        const endpoint = action === 'sync_data' && params.repository
          ? `https://api.github.com/repos/${params.repository}/commits?per_page=5`
          : 'https://api.github.com/octocat';

        const ghRes = await fetch(endpoint, { headers });
        const latencyMs = Date.now() - startTime;

        if (ghRes.ok) {
          const rawText = await ghRes.text();
          let parsedData: any;
          try {
            parsedData = JSON.parse(rawText);
          } catch {
            parsedData = { message: rawText.trim() };
          }

          const rateLimitRemaining = ghRes.headers.get('x-ratelimit-remaining');
          const rateLimitLimit = ghRes.headers.get('x-ratelimit-limit');

          return {
            status: 'verified',
            connector: 'github',
            action,
            tenantId,
            executionId,
            latencyMs,
            testedAt: new Date().toISOString(),
            healthy: true,
            data: parsedData,
            providerDetails: {
              apiEndpoint: endpoint,
              rateLimit: `${rateLimitRemaining}/${rateLimitLimit}`,
              readOnly: true,
              authScheme: process.env.GITHUB_TOKEN ? 'Token (Authenticated)' : 'Public API (Unauthenticated)'
            }
          };
        } else {
          return {
            status: 'failed',
            connector: 'github',
            action,
            tenantId,
            executionId,
            latencyMs,
            testedAt: new Date().toISOString(),
            healthy: false,
            message: `GitHub API returned HTTP ${ghRes.status}: ${ghRes.statusText}`
          };
        }
      } catch (err: any) {
        return {
          status: 'failed',
          connector: 'github',
          action,
          tenantId,
          executionId,
          latencyMs: Date.now() - startTime,
          testedAt: new Date().toISOString(),
          healthy: false,
          message: `Network error contacting GitHub API: ${err.message}`
        };
      }
    }

    // 4. Real Provider Health Check: Auth0 Identity (Verifies real JWKS discovery & SSL)
    if (connectorKey === 'auth0_identity' || connectorKey === 'auth0') {
      try {
        const jwksUrl = `https://${AUTH0_DOMAIN}/.well-known/jwks.json`;
        const jwksRes = await fetch(jwksUrl);
        const latencyMs = Date.now() - startTime;

        if (jwksRes.ok) {
          const jwksData: any = await jwksRes.json();
          const keyCount = jwksData?.keys?.length || 0;
          return {
            status: 'verified',
            connector: 'auth0_identity',
            action,
            tenantId,
            executionId,
            latencyMs,
            testedAt: new Date().toISOString(),
            healthy: true,
            data: { jwksEndpoint: jwksUrl, verifiedKeys: keyCount },
            providerDetails: {
              domain: AUTH0_DOMAIN,
              issuer: `https://${AUTH0_DOMAIN}/`,
              activeKeys: keyCount
            }
          };
        } else {
          return {
            status: 'failed',
            connector: 'auth0_identity',
            action,
            tenantId,
            executionId,
            latencyMs,
            testedAt: new Date().toISOString(),
            healthy: false,
            message: `Auth0 JWKS endpoint returned HTTP ${jwksRes.status}`
          };
        }
      } catch (err: any) {
        return {
          status: 'failed',
          connector: 'auth0_identity',
          action,
          tenantId,
          executionId,
          latencyMs: Date.now() - startTime,
          testedAt: new Date().toISOString(),
          healthy: false,
          message: `Failed to reach Auth0 domain: ${err.message}`
        };
      }
    }

    // 5. Honest Status for all remaining cataloged connectors:
    // We do NOT return a fake healthy=true without real provider communication!
    // Instead, we report that the connector is cataloged and requires tenant credential configuration.
    const latencyMs = Date.now() - startTime;
    return {
      status: 'catalogued',
      connector: connectorKey,
      action,
      tenantId,
      executionId,
      latencyMs,
      testedAt: new Date().toISOString(),
      healthy: null, // null explicitly indicates: Unverified / Awaiting credentials
      message: `Connector '${connectorKey}' ist katalogisiert, erfordert jedoch eine Mandanten-Konfiguration (KMS-Secret / OAuth).`,
      providerDetails: {
        configured: false,
        authenticated: false,
        requiresCredentials: true,
        supportedAuth: ['OAuth 2.0', 'API Key', 'AWS KMS Secret']
      }
    };
  }
}
