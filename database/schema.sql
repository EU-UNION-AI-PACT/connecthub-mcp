-- ConnectHub MCP – PostgreSQL Production MVP Schema with Native RLS
-- Security Rules:
-- 1. Zugangsdaten gehören in einen Secret Manager, nicht in diese Datenbank.
-- 2. Dateien gehören in Object Storage (S3 / MinIO), nicht in BYTEA Spalten.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- RLS Tenant Context Helper Function
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS UUID AS $$
  SELECT NULLIF(current_setting('app.current_tenant_id', true), '')::UUID;
$$ LANGUAGE sql STABLE;

CREATE TABLE tenants (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                TEXT NOT NULL,
    slug                TEXT NOT NULL UNIQUE,
    status              TEXT NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'suspended', 'deleted')),
    storage_quota_bytes BIGINT NOT NULL DEFAULT 1099511627776, -- 1 TB Standard
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth0_subject       TEXT NOT NULL UNIQUE,
    email               TEXT,
    display_name        TEXT,
    status              TEXT NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'disabled', 'deleted')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tenant_memberships (
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role                TEXT NOT NULL
                        CHECK (role IN ('owner', 'admin', 'editor', 'viewer')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (tenant_id, user_id)
);

-- Globaler Connector-Katalog (Nicht mandantenisoliert)
CREATE TABLE connector_catalog (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key                 TEXT NOT NULL UNIQUE,
    display_name        TEXT NOT NULL,
    category            TEXT NOT NULL,
    description         TEXT,
    integration_type    TEXT NOT NULL
                        CHECK (integration_type IN ('mcp', 'api', 'database', 'storage', 'file_transfer')),
    auth_methods        JSONB NOT NULL DEFAULT '[]'::jsonb,
    config_schema       JSONB NOT NULL DEFAULT '{}'::jsonb,
    documentation_url   TEXT,
    is_enabled          BOOLEAN NOT NULL DEFAULT true,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Mandantenspezifische Connector Installationen
CREATE TABLE connector_installations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    connector_id        UUID NOT NULL REFERENCES connector_catalog(id),
    display_name        TEXT NOT NULL,
    status              TEXT NOT NULL DEFAULT 'catalogued'
                        CHECK (status IN ('catalogued', 'configured', 'authenticated', 'verified', 'active', 'disabled', 'failed', 'deleted')),
    endpoint_url        TEXT,
    auth_method         TEXT,
    configuration       JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_by          UUID REFERENCES users(id) ON DELETE SET NULL,
    last_tested_at      TIMESTAMPTZ,
    last_error          TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, id)
);

-- Secret References (KMS / Vault Referenzen)
CREATE TABLE connector_secret_refs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    installation_id     UUID NOT NULL,
    secret_provider     TEXT NOT NULL
                        CHECK (secret_provider IN ('aws_secrets_manager', 'azure_key_vault', 'gcp_secret_manager', 'vault', 'other')),
    secret_ref          TEXT NOT NULL,
    secret_version      TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (installation_id, secret_ref),
    FOREIGN KEY (tenant_id, installation_id)
        REFERENCES connector_installations (tenant_id, id)
        ON DELETE CASCADE
);

CREATE TABLE jobs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    installation_id     UUID,
    requested_by        UUID REFERENCES users(id) ON DELETE SET NULL,
    job_type            TEXT NOT NULL
                        CHECK (job_type IN ('connection_test', 'sync', 'upload_process', 'export', 'delete')),
    status              TEXT NOT NULL DEFAULT 'queued'
                        CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
    idempotency_key     TEXT,
    progress            SMALLINT NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    records_processed   BIGINT NOT NULL DEFAULT 0,
    error_code          TEXT,
    error_message       TEXT,
    input_metadata      JSONB NOT NULL DEFAULT '{}'::jsonb,
    result_metadata     JSONB NOT NULL DEFAULT '{}'::jsonb,
    started_at          TIMESTAMPTZ,
    finished_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (tenant_id, installation_id)
        REFERENCES connector_installations (tenant_id, id)
        ON DELETE SET NULL,
    UNIQUE (tenant_id, idempotency_key)
);

CREATE TABLE upload_sessions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    created_by          UUID REFERENCES users(id) ON DELETE SET NULL,
    object_key          TEXT NOT NULL,
    original_filename   TEXT NOT NULL,
    content_type        TEXT,
    expected_size_bytes BIGINT NOT NULL CHECK (expected_size_bytes >= 0),
    checksum_sha256     TEXT,
    status              TEXT NOT NULL DEFAULT 'initiated'
                        CHECK (status IN ('initiated', 'uploading', 'completed', 'aborted', 'expired', 'failed')),
    multipart_upload_id TEXT,
    expires_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, object_key)
);

CREATE TABLE stored_objects (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    upload_session_id   UUID REFERENCES upload_sessions(id) ON DELETE SET NULL,
    installation_id     UUID,
    job_id              UUID REFERENCES jobs(id) ON DELETE SET NULL,
    storage_provider    TEXT NOT NULL
                        CHECK (storage_provider IN ('s3', 'azure_blob', 'gcs', 'minio', 'other')),
    bucket_name         TEXT NOT NULL,
    object_key          TEXT NOT NULL,
    original_filename   TEXT NOT NULL,
    content_type        TEXT,
    size_bytes          BIGINT NOT NULL CHECK (size_bytes >= 0),
    checksum_sha256     TEXT,
    status              TEXT NOT NULL DEFAULT 'available'
                        CHECK (status IN ('pending', 'available', 'processing', 'archived', 'deleted', 'failed')),
    retention_until     TIMESTAMPTZ,
    created_by          UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (tenant_id, installation_id)
        REFERENCES connector_installations (tenant_id, id)
        ON DELETE SET NULL,
    UNIQUE (storage_provider, bucket_name, object_key)
);

CREATE TABLE audit_events (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id           UUID REFERENCES tenants(id) ON DELETE SET NULL,
    actor_user_id       UUID REFERENCES users(id) ON DELETE SET NULL,
    action              TEXT NOT NULL,
    resource_type       TEXT NOT NULL,
    resource_id         TEXT,
    outcome             TEXT NOT NULL DEFAULT 'success'
                        CHECK (outcome IN ('success', 'failure')),
    request_id          TEXT,
    ip_address          INET,
    user_agent          TEXT,
    details             JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

ALTER TABLE connector_installations ENABLE ROW LEVEL SECURITY;
ALTER TABLE connector_secret_refs ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE upload_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE stored_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_connector_installations ON connector_installations
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY rls_connector_secret_refs ON connector_secret_refs
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY rls_jobs ON jobs
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY rls_upload_sessions ON upload_sessions
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY rls_stored_objects ON stored_objects
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY rls_audit_events ON audit_events
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());


-- ==========================================
-- DATA VERSIONING & CONFIG AUDIT
-- ==========================================

CREATE TABLE data_versions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    installation_id     UUID NOT NULL,
    version_tag         TEXT NOT NULL,
    commit_hash         TEXT NOT NULL,
    records_count       BIGINT NOT NULL DEFAULT 0,
    size_bytes          BIGINT NOT NULL DEFAULT 0,
    storage_location    TEXT NOT NULL,
    parent_version_id   UUID REFERENCES data_versions(id),
    metadata            JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (tenant_id, installation_id)
        REFERENCES connector_installations (tenant_id, id)
        ON DELETE CASCADE
);

CREATE INDEX data_versions_tenant_installation_idx
    ON data_versions (tenant_id, installation_id, created_at DESC);

CREATE TABLE connector_config_versions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    installation_id     UUID NOT NULL,
    version_number      INTEGER NOT NULL,
    configuration_hash  TEXT NOT NULL,
    configuration       JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_by          UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (tenant_id, installation_id)
        REFERENCES connector_installations (tenant_id, id)
        ON DELETE CASCADE
);

ALTER TABLE data_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE connector_config_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_data_versions ON data_versions
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY rls_connector_config_versions ON connector_config_versions
  FOR ALL USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
