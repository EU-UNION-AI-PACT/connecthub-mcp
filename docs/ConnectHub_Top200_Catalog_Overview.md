# ConnectHub MCP – Top 200 Connector-Katalog

Dieser Katalog integriert die **Top 200 meistgenutzten und relevantesten Dienste, Datenbanken, APIs und MCP-Server** der weltweiten Entwickler- und Unternehmenslandschaft (basierend auf Benchmarks von *mcpservers.org*, *Smithery.ai*, *Glama.ai* und den führenden Cloud-Ecosystems).

---

## 📊 Kategorien-Übersicht (200 Connectoren)

| # | Kategorie | Anzahl | Typische Schlüsseltechnologien |
|---|:---|:---:|:---|
| 1 | **AI & Machine Learning** | 18 | OpenAI, Anthropic Claude, Hugging Face, Cohere, Mistral AI, Perplexity, Together AI, Groq, DeepSeek, Ollama, vLLM, LangSmith, ElevenLabs |
| 2 | **Vector Databases & Semantic Search** | 10 | Pinecone, Qdrant, Weaviate, ChromaDB, Milvus/Zilliz, Meilisearch, Algolia, Typesense, Vespa, Marqo |
| 3 | **Relational & SQL Databases** | 15 | PostgreSQL, MySQL, SQLite, MariaDB, SQL Server, Oracle DB, CockroachDB, TiDB, Neon, Supabase, PlanetScale, TimescaleDB, ClickHouse |
| 4 | **Big Data & Analytics Warehouses** | 15 | DuckDB, Snowflake, Google BigQuery, Amazon Redshift, Databricks, Apache Spark, Trino/Presto, Apache Druid, StarRocks, dbt Cloud, MotherDuck |
| 5 | **NoSQL, Cache & Key-Value** | 12 | Redis/Valkey, MongoDB Atlas, Cassandra/Astra, Couchbase, ScyllaDB, DynamoDB, Firestore, Firebase RTDB, Upstash, Neo4j Graph |
| 6 | **Cloud Storage & Object Stores** | 15 | AWS S3, Google Cloud Storage, Azure Blob, MinIO, Cloudflare R2, Wasabi, Backblaze B2, Google Drive, OneDrive, SharePoint, Dropbox, Box, SFTP |
| 7 | **Cloud Infrastructure & PaaS** | 15 | AWS EC2/IAM, Azure RM, GCP, Cloudflare, DigitalOcean, Hetzner, Linode, Vercel, Netlify, Render, Railway, Fly.io, OVHcloud, Scaleway |
| 8 | **DevOps, Git, CI/CD & Security** | 15 | GitHub, GitLab, Bitbucket, Azure DevOps, Gitea, Docker Hub, Kubernetes, ArgoCD, Terraform Cloud, Pulumi, Jenkins, CircleCI, Snyk, SonarQube |
| 9 | **Observability, Monitoring & APM** | 13 | Datadog, New Relic, Grafana, Prometheus, Sentry, Splunk, Dynatrace, Elastic APM, Better Stack, PostHog, Mixpanel, Amplitude, Segment |
| 10 | **Communication, Messaging & Voice** | 15 | Slack, Microsoft Teams, Discord, Telegram, WhatsApp Business, Zoom, Google Meet, Cisco Webex, Mattermost, Twilio, SendGrid, Resend, Postmark |
| 11 | **Project Management & Collaboration** | 15 | Jira, Confluence, Linear, Asana, Monday.com, Trello, Notion, ClickUp, Basecamp, Wrike, Shortcut, Coda, Miro, Figma, Obsidian |
| 12 | **CRM, Sales & Marketing Automation** | 14 | Salesforce, HubSpot, Pipedrive, Zoho CRM, Close, Mailchimp, Klaviyo, ActiveCampaign, Customer.io, Intercom, Braze, Apollo.io, ZoomInfo |
| 13 | **Customer Support & Service Desk** | 9 | Zendesk Support, Freshdesk, Help Scout, Front, Gorgias, Kustomer, ServiceNow, PagerDuty, Opsgenie |
| 14 | **E-Commerce, Payments & Fintech** | 11 | Stripe, PayPal, Shopify, WooCommerce, BigCommerce, Square, Paddle, Adyen, Lemon Squeezy, Chargebee, Plaid |
| 15 | **Finance, HR & Spreadsheet Tools** | 8 | QuickBooks Online, Xero, Google Sheets, Airtable, DocuSign, BambooHR, Gusto, Auth0 Security |
| **Σ** | **GESAMT** | **200** | **Vollständig katalogisiert, typisiert und schema-validiert** |

---

## 🗄️ Dateien im Repository & Paket:

* **Strukturierte CSV-Tabelle**: [`ConnectHub_Top200_Connectors.csv`](file:///home/antigravity/connecthub-mcp-bundle/docs/ConnectHub_Top200_Connectors.csv)
  * Enthält alle 200 Einträge mit `id`, `key`, `name`, `category`, `integration_type`, `auth_methods`, `has_official_mcp`, `secret_store_keys`, `health_check_type`, `popularity_rank`.
* **PostgreSQL Seed-Migration**: [`seed_top200_connectors.sql`](file:///home/antigravity/connecthub-mcp-bundle/database/seed_top200_connectors.sql)
  * Enthält alle 200 `INSERT INTO connector_catalog`-Anweisungen mit JSONB-Schemas für `auth_methods` und `config_schema`.
