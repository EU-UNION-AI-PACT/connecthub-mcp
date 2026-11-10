#!/usr/bin/env node

/**
 * Lists all available MCP Tools across all connected servers:
 * - Auth0 MCP Server (23 IAM, Actions, Logs, Security tools)
 * - DuckDB MCP Server (Analytical SQL & Big Data processing)
 * - SQLite MCP Server (Relational database management)
 * - Storage / Filesystem MCP Server (File system & large storage management)
 */

import { spawn } from 'child_process';
import readline from 'readline';

async function queryMcpTools(command, args, env = process.env) {
  return new Promise((resolve) => {
    const proc = spawn(command, args, {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, ...env }
    });

    let tools = [];
    const rl = readline.createInterface({ input: proc.stdout });

    const initReq = {
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2024-11-05',
        capabilities: {},
        clientInfo: { name: 'mcp-tool-inspector', version: '1.0.0' }
      }
    };

    proc.stdin.write(JSON.stringify(initReq) + '\n');

    rl.on('line', (line) => {
      try {
        const msg = JSON.parse(line);
        if (msg.id === 1) {
          // Send notifications/initialized (required by python fastmcp/mcp servers)
          proc.stdin.write(JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized', params: {} }) + '\n');
          // Send tools/list request
          const listReq = {
            jsonrpc: '2.0',
            id: 2,
            method: 'tools/list',
            params: {}
          };
          proc.stdin.write(JSON.stringify(listReq) + '\n');
        } else if (msg.id === 2) {
          tools = msg.result?.tools || [];
          proc.kill();
          resolve(tools);
        }
      } catch (e) {
        // ignore non-json log lines
      }
    });

    proc.stderr.on('data', () => {});
    proc.on('close', () => resolve(tools));
    proc.on('error', () => resolve(tools));

    setTimeout(() => {
      proc.kill();
      resolve(tools);
    }, 6000);
  });
}

async function main() {
  console.log('🔍 Inspecting and aggregating tools from all MCP servers...\n');

  console.log('1️⃣ Inspecting SQLite MCP Server...');
  const sqliteTools = await queryMcpTools('uvx', ['--with', 'mcp<1.2.0', 'mcp-server-sqlite', '--db-path', '/home/antigravity/mcp-gateway/data/relational.db']);
  console.log(`   Found ${sqliteTools.length} SQLite database tools.`);

  console.log('2️⃣ Inspecting DuckDB MCP Server...');
  const duckdbTools = await queryMcpTools('uvx', ['--with', 'mcp<1.2.0', 'mcp-server-duckdb', '--db-path', '/home/antigravity/mcp-gateway/data/analytics.duckdb']);
  console.log(`   Found ${duckdbTools.length} DuckDB Big Data tools.`);

  console.log('3️⃣ Inspecting Filesystem Storage MCP Server...');
  const storageTools = await queryMcpTools('npx', ['-y', '@modelcontextprotocol/server-filesystem', '/home/antigravity/mcp-gateway/data/storage']);
  console.log(`   Found ${storageTools.length} Storage tools.`);

  console.log('4️⃣ Inspecting Auth0 MCP Server...');
  const auth0Module = await import('/home/antigravity/.npm/_npx/c3417775d2c45756/node_modules/@auth0/auth0-mcp-server/dist/tools/index.js');
  const auth0Tools = auth0Module.TOOLS.map(t => ({
    name: t.name,
    description: t.description || 'Auth0 identity & security management tool'
  }));
  console.log(`   Found ${auth0Tools.length} Auth0 tools.`);

  const allTools = [
    ...auth0Tools.map(t => ({ ...t, category: 'Auth0 Identity & Security' })),
    ...duckdbTools.map(t => ({ ...t, category: 'DuckDB Big Data Analytics' })),
    ...sqliteTools.map(t => ({ ...t, category: 'SQLite Relational Database' })),
    ...storageTools.map(t => ({ ...t, category: 'Storage & Datasets' }))
  ];

  console.log('\n======================================================');
  console.log(`🎉 TOTAL MCP TOOLS CONFIGURED: ${allTools.length} TOOLS (Requirement: 33+)`);
  console.log('======================================================\n');

  allTools.forEach((t, i) => {
    console.log(`${(i + 1).toString().padStart(2, ' ')}. [${t.category}] ${t.name}: ${t.description.slice(0, 65)}...`);
  });

  return allTools;
}

main().catch(console.error);
