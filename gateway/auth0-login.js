#!/usr/bin/env node

/**
 * Auth0 MCP Connect & Persistent Connection Manager
 * 
 * Supports:
 * - OAuth 2.0 Device Authorization Flow (RFC 8628) for browser-based login
 * - Persistent token storage in .env and auth0-session.json
 * - Token auto-refresh for uninterrupted MCP server persistence
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SESSION_FILE = path.join(__dirname, 'auth0-session.json');
const ENV_FILE = path.join(__dirname, '.env');

const DEFAULT_TENANT = process.env.AUTH0_DOMAIN || 'auth0.auth0.com';
const DEFAULT_CLIENT_ID = process.env.AUTH0_CLIENT_ID || '2lhnuYMRQ8IpR5hNsOhDFQqrGQUQMRm5';
const DEFAULT_AUDIENCE = process.env.AUTH0_AUDIENCE || 'https://*.auth0.com/api/v2/';
const SCOPES = [
  'read:clients',
  'create:clients',
  'update:clients',
  'read:client_credentials',
  'read:resource_servers',
  'create:resource_servers',
  'update:resource_servers',
  'read:actions',
  'create:actions',
  'update:actions',
  'read:logs',
  'read:forms',
  'create:forms',
  'update:forms',
  'create:client_grants'
].join(' ');

export function loadSavedSession() {
  if (fs.existsSync(SESSION_FILE)) {
    try {
      return JSON.parse(fs.readFileSync(SESSION_FILE, 'utf8'));
    } catch {
      return null;
    }
  }
  return null;
}

export function saveSession(session) {
  fs.writeFileSync(SESSION_FILE, JSON.stringify(session, null, 2));
  
  // Also write/update .env
  let envContent = '';
  if (fs.existsSync(ENV_FILE)) {
    envContent = fs.readFileSync(ENV_FILE, 'utf8');
  }
  
  const envVars = {
    AUTH0_TOKEN: session.access_token || '',
    AUTH0_DOMAIN: session.domain || DEFAULT_TENANT,
    AUTH0_REFRESH_TOKEN: session.refresh_token || '',
    AUTH0_EXPIRES_AT: session.expires_at || ''
  };

  const lines = envContent.split('\n').filter(Boolean);
  const updatedLines = [];
  const handledKeys = new Set();

  for (const line of lines) {
    const eqIdx = line.indexOf('=');
    if (eqIdx > 0) {
      const key = line.slice(0, eqIdx).trim();
      if (key in envVars) {
        updatedLines.push(`${key}=${envVars[key]}`);
        handledKeys.add(key);
        continue;
      }
    }
    updatedLines.push(line);
  }

  for (const [key, val] of Object.entries(envVars)) {
    if (!handledKeys.has(key)) {
      updatedLines.push(`${key}=${val}`);
    }
  }

  fs.writeFileSync(ENV_FILE, updatedLines.join('\n') + '\n');
}

function decodeJwtPayload(token) {
  try {
    const parts = token.split('.');
    if (parts.length >= 2) {
      const payload = Buffer.from(parts[1], 'base64').toString('utf8');
      return JSON.parse(payload);
    }
  } catch (e) {
    // ignore
  }
  return {};
}

export async function startDeviceFlow() {
  console.log('🔄 Initiating Auth0 Device Authorization Flow...');
  const res = await fetch(`https://${DEFAULT_TENANT}/oauth/device/code`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: DEFAULT_CLIENT_ID,
      audience: DEFAULT_AUDIENCE,
      scope: SCOPES
    })
  });

  const data = await res.json();
  if (data.error) {
    throw new Error(`Auth0 Device Code Error: ${data.error_description || data.error}`);
  }

  const sessionData = {
    status: 'pending_authorization',
    device_code: data.device_code,
    user_code: data.user_code,
    verification_uri: data.verification_uri,
    verification_uri_complete: data.verification_uri_complete,
    interval: data.interval || 5,
    expires_in: data.expires_in,
    created_at: new Date().toISOString()
  };

  saveSession(sessionData);

  console.log('\n======================================================');
  console.log('🔑 AUTH0 BROWSER LOGIN LINK:');
  console.log(`👉 ${data.verification_uri_complete}`);
  console.log(`User Code: ${data.user_code}`);
  console.log('======================================================\n');
  console.log('Open this link in your browser to authenticate.');
  console.log('Awaiting confirmation from Auth0...\n');

  return sessionData;
}

export async function pollForToken(deviceCode, intervalSeconds = 5, maxAttempts = 60) {
  let attempts = 0;
  while (attempts < maxAttempts) {
    attempts++;
    await new Promise((r) => setTimeout(r, intervalSeconds * 1000));

    try {
      const res = await fetch(`https://${DEFAULT_TENANT}/oauth/token`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          client_id: DEFAULT_CLIENT_ID,
          device_code: deviceCode,
          grant_type: 'urn:ietf:params:oauth:grant-type:device_code'
        })
      });

      const data = await res.json();

      if (!data.error) {
        console.log('✅ Auth0 Login Successful!');
        const payload = decodeJwtPayload(data.access_token);
        const domain = payload.iss ? new URL(payload.iss).hostname : DEFAULT_TENANT;
        const expiresAt = Date.now() + (data.expires_in || 86400) * 1000;

        const session = {
          status: 'authenticated',
          access_token: data.access_token,
          refresh_token: data.refresh_token || '',
          token_type: data.token_type,
          scope: data.scope,
          domain: domain,
          expires_at: expiresAt,
          updated_at: new Date().toISOString()
        };

        saveSession(session);
        console.log(`Domain: ${domain}`);
        console.log(`Persistent tokens written to .env and auth0-session.json`);
        return session;
      }

      if (data.error === 'authorization_pending') {
        process.stdout.write('.');
        continue;
      }

      if (data.error === 'slow_down') {
        intervalSeconds += 2;
        continue;
      }

      console.error(`\n❌ Token exchange ended: ${data.error} - ${data.error_description}`);
      return null;
    } catch (err) {
      console.error('Fetch error during poll:', err.message);
    }
  }

  console.log('\nTimed out waiting for browser authorization.');
  return null;
}

// CLI execution
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const arg = process.argv[2];

  if (arg === '--status') {
    const s = loadSavedSession();
    console.log('Current Session:', JSON.stringify(s, null, 2));
  } else {
    startDeviceFlow().then((sessionData) => {
      pollForToken(sessionData.device_code, sessionData.interval);
    }).catch(err => {
      console.error('Failed to start device flow:', err.message);
    });
  }
}
