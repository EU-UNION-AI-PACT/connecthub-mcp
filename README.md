# ConnectHub MCP – Gesamtpaket

Mandantenfähige Plattform für Model Context Protocol (MCP) Integrationen, Auth0 Identity Management, relationale & analytische Datenbanken sowie unterbrechungsfreie S3/MinIO Resumable Uploads.

---

## 📁 Paketstruktur

```text
connecthub-mcp-bundle/
├── database/
│   └── schema.sql                  # PostgreSQL Schema mit nativer Row Level Security (RLS)
├── docs/
│   ├── ConnectHub_MCP_MVP_Blueprint.md      # Architektur- & Spezifikations-Blueprint
│   ├── ConnectHub_Top40_Connectors.csv      # CSV-Katalog aller 40 Connectoren
│   └── ConnectHub_Resumable_Upload_Client.md # Vollständige Resumable Upload Dokumentation
├── gateway/
│   ├── mcp_config.json             # Supergateway MCP Multi-Server Konfiguration
│   ├── auth0-login.js              # Auth0 Device Flow & Token Persistent Manager
│   ├── list-all-tools.js           # Tool Aggregator (46 MCP Tools)
│   └── start-gateway.sh            # Gateway Starter (Port 8000)
├── src/
│   ├── client/
│   │   ├── ResumableS3Uploader.ts  # Autonomer TypeScript Resumable S3 Uploader
│   │   ├── UppyS3MultipartAdapter.ts # Adapter für @uppy/aws-s3-multipart
│   │   └── useResumableUpload.ts   # React Hook für Resumable Uploads
│   └── backend/
│       ├── auth.ts                 # Auth0 JWT Middleware & Tenant RBAC
│       ├── mcp-orchestrator.ts     # MCP Protocol Stdio/SSE Runner
│       ├── upload-service.ts       # S3 Multipart & Presigned Part Manager
│       └── api-routes.ts           # REST API Controller
├── web/
│   ├── connecthub_portal.html      # Interaktives Frontend Portal mit Upload-Simulator
│   └── mcp_dashboard.html          # MCP Proxy & Auth0 Control Center
└── package.json
```

---

## 🚀 Schnelleinstieg

### 1. Gateway mit 46 MCP Tools starten
```bash
cd gateway
./start-gateway.sh
```
Der Proxy läuft standardmäßig auf `http://localhost:8000` und stellt folgende SSE-Endpunkte bereit:
* `/auth0/sse` – 23 Auth0 Identity & Security Tools
* `/duckdb/sse` – High-Performance SQL Engine für Terabyte-Daten
* `/sqlite/sse` – Relationale Tabellen & CRUD
* `/storage/sse` – Filesystem- & Dataset-Storage Tools

### 2. Tools inspizieren
```bash
node gateway/list-all-tools.js
```

### 3. Auth0 Browser-Login ausführen
```bash
node gateway/auth0-login.js
```
Der Link öffnet die Auth0-Aktivierung im Browser und persistiert die Tokens automatisch in `.env` und `auth0-session.json`.

---

## 🛡️ Sicherheitsmerkmale
* **PostgreSQL RLS**: Mandantenisolation wird direkt in der Datenbank via `current_tenant_id()` erzwungen.
* **Secret Manager**: Keine Klartext-Passwörter in der Datenbank — Speicherung von KMS-Referenzen.
* **Direct-to-S3 Uploads**: Der Browser lädt Chunks über kurzlebige Presigned URLs direkt in S3/MinIO, ohne das Backend zu belasten.
