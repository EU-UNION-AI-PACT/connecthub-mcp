#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# Source .env if exists
if [ -f "$DIR/.env" ]; then
  set -a
  source "$DIR/.env"
  set +a
fi

echo "🚀 Starting MCP Supergateway Proxy on port 8000..."
exec npx -y supergateway@4.2.1 \
  --config "$DIR/mcp_config.json" \
  --port 8000 \
  --logLevel info
