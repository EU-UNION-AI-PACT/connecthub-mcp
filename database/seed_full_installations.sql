-- ConnectHub MCP - Full 200 Connectors Implementation & Data Versioning Migration
BEGIN;

-- 1. Ensure Tenant & Admin User
INSERT INTO tenants (id, name, slug, status, storage_quota_bytes)
VALUES ('a0000000-0000-0000-0000-000000000001', 'Acme Corporation', 'acme', 'active', 10995116277760)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO users (id, auth0_subject, email, display_name, status)
VALUES ('u0000000-0000-0000-0000-000000000001', 'auth0|673000000000000000000001', 'admin@acme.com', 'Acme Admin', 'active')
ON CONFLICT (auth0_subject) DO NOTHING;

INSERT INTO tenant_memberships (tenant_id, user_id, role)
VALUES ('a0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000001', 'owner')
ON CONFLICT (tenant_id, user_id) DO NOTHING;

-- 2. Seed 200 Active Connector Installations, Secret Refs & Version Snapshots

-- Connector #1: OpenAI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000001', 'openai', 'OpenAI', 'AI & Machine Learning', 'mcp', '["API Key, OAuth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'OpenAI', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000001', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:openai')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000001', 'v1.1.7', '6e7d8e8caf40a26fa2ce712ed0d2f391b4513aac1a5b8d748bb3753667277ed7', 2770, 1418240, 's3://connecthub-tenant-acme/openai/snapshots/6e7d8e8caf40.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #2: Anthropic Claude
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000002', 'anthropic', 'Anthropic Claude', 'AI & Machine Learning', 'mcp', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 'Anthropic Claude', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000002', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:anthropic')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000002', 'v1.2.14', 'cf4021a589825be2856bc083e5aa0f1562e418663328624aa4f68fff470154a8', 4190, 2145280, 's3://connecthub-tenant-acme/anthropic/snapshots/cf4021a58982.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #3: Hugging Face
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000003', 'huggingface', 'Hugging Face', 'AI & Machine Learning', 'mcp', '["Access Token (User/Write)"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000003', 'Hugging Face', 'catalogued', 'Access Token (User/Write)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000003', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:huggingface')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000003', 'v1.3.1', '4f1b566b79c420b67e7245168b64f11887e3b81b9d0aaf6a64646cb55d974615', 5610, 2872320, 's3://connecthub-tenant-acme/huggingface/snapshots/4f1b566b79c4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #4: Cohere
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000004', 'cohere', 'Cohere', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000004', 'Cohere', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000004', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cohere')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000004', 'v1.4.8', '150aed0300f54df57f332e455a3f2de23b7129cded27d8890b3c28bff75ed06c', 7030, 3599360, 's3://connecthub-tenant-acme/cohere/snapshots/150aed0300f5.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #5: Mistral AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000005', 'mistral', 'Mistral AI', 'AI & Machine Learning', 'mcp', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000005', 'Mistral AI', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000005', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mistral')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000005', 'v1.0.15', 'd36efd88836d4b526add9d898b4c61598df051e525fc235adef999cb93812b58', 8450, 4326400, 's3://connecthub-tenant-acme/mistral/snapshots/d36efd88836d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #6: Perplexity AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000006', 'perplexity', 'Perplexity AI', 'AI & Machine Learning', 'mcp', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000006', 'Perplexity AI', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000006', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:perplexity')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000006', 'v1.1.2', '15e0108bde0fe9f6f5ab9388e5577708f8e33ca1d04986b13951464c42b1eed3', 9870, 5053440, 's3://connecthub-tenant-acme/perplexity/snapshots/15e0108bde0f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #7: Replicate
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000007', 'replicate', 'Replicate', 'AI & Machine Learning', 'api', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000007', 'Replicate', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000007', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:replicate')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000007', 'v1.2.9', 'ec492c58058ad41a2635b2c220c0d8793233d7adfa479fc19e90e6a280bec490', 11290, 5780480, 's3://connecthub-tenant-acme/replicate/snapshots/ec492c58058a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #8: Together AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000008', 'together_ai', 'Together AI', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000008', 'Together AI', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000008', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:together_ai')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000008', 'v1.3.16', '25a0276fd04887232a1e9760486b87a69270e88aaf0d6abab680ea7902a15ebf', 12710, 6507520, 's3://connecthub-tenant-acme/together_ai/snapshots/25a0276fd048.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #9: Groq LPU
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000009', 'groq', 'Groq LPU', 'AI & Machine Learning', 'mcp', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000009', 'Groq LPU', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000009', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:groq')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000009', 'v1.4.3', 'b28424e445dfce59f7f315861f25286c41b6b7de9c8e964c8e411a9d6d8913e1', 14130, 7234560, 's3://connecthub-tenant-acme/groq/snapshots/b28424e445df.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #10: DeepSeek
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000010', 'deepseek', 'DeepSeek', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000010', 'DeepSeek', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000010', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:deepseek')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000010', 'v1.0.10', '99157c0cec9ee42a01a40c70675255245551db3ec81f6d0624925bdaebb14ddd', 15550, 7961600, 's3://connecthub-tenant-acme/deepseek/snapshots/99157c0cec9e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #11: Ollama (Local/Self-hosted)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000011', 'ollama', 'Ollama (Local/Self-hosted)', 'AI & Machine Learning', 'mcp', '["Endpoint URL, Basic Auth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000011', 'Ollama (Local/Self-hosted)', 'catalogued', 'Endpoint URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000011', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:ollama')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000011', 'v1.1.17', 'a7efb9ceaeaf03402e1905a1971b0a5dd3941a138e53f1c4cf99e72d3886fbc5', 16970, 8688640, 's3://connecthub-tenant-acme/ollama/snapshots/a7efb9ceaeaf.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #12: vLLM Engine
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000012', 'vllm', 'vLLM Engine', 'AI & Machine Learning', 'api', '["Endpoint URL, Bearer Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000012', 'vLLM Engine', 'catalogued', 'Endpoint URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000012', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:vllm')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000012', 'v1.2.4', 'cdcff88dfba2a6870baf27e3474fe360e2961991a6c0c2f07cc6af40ec636c58', 18390, 9415680, 's3://connecthub-tenant-acme/vllm/snapshots/cdcff88dfba2.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #13: LangSmith (LangChain)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000013', 'langsmith', 'LangSmith (LangChain)', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000013', 'LangSmith (LangChain)', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000013', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:langsmith')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000013', 'v1.3.11', '097a2ea3721eac4821ac16064819930c426884e69b79e535dbf310400af6737b', 19810, 10142720, 's3://connecthub-tenant-acme/langsmith/snapshots/097a2ea3721e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #14: LlamaCloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000014', 'llamaindex', 'LlamaCloud', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000014', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000014', 'LlamaCloud', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000014', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000014', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:llamaindex')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000014', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000014', 'v1.4.18', 'c07d9f9ff8fa2b9daa1346a4fb532d39173f09875cb0ff2311c60f3ba9bbe983', 21230, 10869760, 's3://connecthub-tenant-acme/llamaindex/snapshots/c07d9f9ff8fa.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #15: Weights & Biases
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000015', 'wandb', 'Weights & Biases', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000015', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000015', 'Weights & Biases', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000015', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000015', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:wandb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000015', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000015', 'v1.0.5', '4d4ace5cda1c3e4858112f96c8ab550a28c73191c6aa101c808b9f47a131a3d2', 22650, 11596800, 's3://connecthub-tenant-acme/wandb/snapshots/4d4ace5cda1c.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #16: ElevenLabs Voice AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000016', 'elevenlabs', 'ElevenLabs Voice AI', 'AI & Machine Learning', 'mcp', '["xi-api-key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000016', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000016', 'ElevenLabs Voice AI', 'catalogued', 'xi-api-key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000016', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000016', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:elevenlabs')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000016', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000016', 'v1.1.12', '733a509def9dd78c3bf7e392f03eef7629bd62b146e0055f876b9f22fcde95f3', 24070, 12323840, 's3://connecthub-tenant-acme/elevenlabs/snapshots/733a509def9d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #17: Runway Gen AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000017', 'runway', 'Runway Gen AI', 'AI & Machine Learning', 'api', '["Secret Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000017', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000017', 'Runway Gen AI', 'catalogued', 'Secret Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000017', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000017', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:runway')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000017', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000017', 'v1.2.19', 'b15d7406ad90f80174e6563502ef4f67da5f70edf4078706f3b4247876ad2a3c', 25490, 13050880, 's3://connecthub-tenant-acme/runway/snapshots/b15d7406ad90.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #18: Stability AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000018', 'stability_ai', 'Stability AI', 'AI & Machine Learning', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000018', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000018', 'Stability AI', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000018', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000018', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:stability_ai')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000018', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000018', 'v1.3.6', '558387f3bc4d43a42c183154e77b2e28cc3947385677429c79609b1e85f64e3f', 26910, 13777920, 's3://connecthub-tenant-acme/stability_ai/snapshots/558387f3bc4d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #19: Pinecone Vector DB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000019', 'pinecone', 'Pinecone Vector DB', 'Vector Database', 'mcp', '["API Key, Environment"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000019', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000019', 'Pinecone Vector DB', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000019', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000019', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:pinecone')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000019', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000019', 'v1.4.13', '09bb86dc30b11e74c3e1ff50ad3b7784e3088ec416a9704f78751fcad7402727', 28330, 14504960, 's3://connecthub-tenant-acme/pinecone/snapshots/09bb86dc30b1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #20: Qdrant Vector Search
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000020', 'qdrant', 'Qdrant Vector Search', 'Vector Database', 'mcp', '["API Key, Cluster URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000020', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000020', 'Qdrant Vector Search', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000020', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000020', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:qdrant')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000020', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000020', 'v1.0.0', 'cac1f091d7588e9bda8565b28447f8d6c6e8bd21f46307fb8e0373afebabbe29', 29750, 15232000, 's3://connecthub-tenant-acme/qdrant/snapshots/cac1f091d758.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #21: Weaviate Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000021', 'weaviate', 'Weaviate Cloud', 'Vector Database', 'mcp', '["API Key, Cluster URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000021', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000021', 'Weaviate Cloud', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000021', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000021', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:weaviate')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000021', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000021', 'v1.1.7', '3d9a042ef0579b4bbd11bc6ac4464f1c6c756871bce644cf25f6885ac77a5053', 31170, 15959040, 's3://connecthub-tenant-acme/weaviate/snapshots/3d9a042ef057.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #22: ChromaDB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000022', 'chroma', 'ChromaDB', 'Vector Database', 'mcp', '["Endpoint URL, Auth Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000022', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000022', 'ChromaDB', 'catalogued', 'Endpoint URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000022', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000022', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:chroma')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000022', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000022', 'v1.2.14', 'bd19ddeeb6d4efbde04b56d9a624da5615eefb6a4b30d1b16801ffa4b695ccd9', 32590, 16686080, 's3://connecthub-tenant-acme/chroma/snapshots/bd19ddeeb6d4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #23: Milvus / Zilliz
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000023', 'milvus', 'Milvus / Zilliz', 'Vector Database', 'mcp', '["API Key, Cluster URI"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000023', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000023', 'Milvus / Zilliz', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000023', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000023', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:milvus')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000023', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000023', 'v1.3.1', 'c7f2c0e198d268eaba1b4777fd7455c9afd3f629d9886ac74a3ba3a618324c66', 34010, 17413120, 's3://connecthub-tenant-acme/milvus/snapshots/c7f2c0e198d2.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #24: Meilisearch
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000024', 'meilisearch', 'Meilisearch', 'Search & Discovery', 'mcp', '["Master API Key, URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000024', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000024', 'Meilisearch', 'catalogued', 'Master API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000024', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000024', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:meilisearch')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000024', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000024', 'v1.4.8', 'cd40e2df4a3fdae9ae012f12ff310e1500682ee2628d2b42b8722af50f31271b', 35430, 18140160, 's3://connecthub-tenant-acme/meilisearch/snapshots/cd40e2df4a3f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #25: Algolia Search
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000025', 'algolia', 'Algolia Search', 'Search & Discovery', 'api', '["Application ID, Admin API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000025', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000025', 'Algolia Search', 'catalogued', 'Application ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000025', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000025', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:algolia')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000025', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000025', 'v1.0.15', 'e70ab3073651f05a4cadd3cf0bd7baaf84e78a9489d1b795f1782716600858b4', 36850, 18867200, 's3://connecthub-tenant-acme/algolia/snapshots/e70ab3073651.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #26: Typesense Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000026', 'typesense', 'Typesense Cloud', 'Search & Discovery', 'api', '["API Key, Node URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000026', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000026', 'Typesense Cloud', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000026', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000026', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:typesense')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000026', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000026', 'v1.1.2', '87a97cd1f95c03e313b34d35b9e15b549c4701275b3c624177879ea6ec70d59e', 38270, 19594240, 's3://connecthub-tenant-acme/typesense/snapshots/87a97cd1f95c.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #27: Vespa AI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000027', 'vespa', 'Vespa AI', 'Search & Discovery', 'api', '["Certificate, Key, Endpoint"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000027', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000027', 'Vespa AI', 'catalogued', 'Certificate', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000027', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000027', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:vespa')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000027', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000027', 'v1.2.9', '858ca64a16a3958bf23bdb1453d5e852541cf6572b0eb7dc20a6b5587d2b8f18', 39690, 20321280, 's3://connecthub-tenant-acme/vespa/snapshots/858ca64a16a3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #28: Marqo Vector Search
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000028', 'marqo', 'Marqo Vector Search', 'Vector Database', 'api', '["API Key, Endpoint"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000028', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000028', 'Marqo Vector Search', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000028', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000028', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:marqo')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000028', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000028', 'v1.3.16', 'd69252c76c232238a0b03d6f55ff01294832f7286afb121a3ce733b07f13c3b8', 41110, 21048320, 's3://connecthub-tenant-acme/marqo/snapshots/d69252c76c23.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #29: PostgreSQL
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000029', 'postgresql', 'PostgreSQL', 'Relational Database', 'database', '["User/Password, TLS, IAM Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000029', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000029', 'PostgreSQL', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000029', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000029', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:postgresql')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000029', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000029', 'v1.4.3', '506790d88a505ce29ea20a965e91c195bb7d3345355db419bd41d551665cf150', 42530, 21775360, 's3://connecthub-tenant-acme/postgresql/snapshots/506790d88a50.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #30: MySQL
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000030', 'mysql', 'MySQL', 'Relational Database', 'database', '["User/Password, SSL CA"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000030', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000030', 'MySQL', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000030', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000030', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mysql')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000030', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000030', 'v1.0.10', '1baec6db557f58340fa673304e3b7044b9f24aac2b27b9b952a76422b9fc0a51', 43950, 22502400, 's3://connecthub-tenant-acme/mysql/snapshots/1baec6db557f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #31: SQLite
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000031', 'sqlite', 'SQLite', 'Relational Database', 'mcp', '["Database File Path, Encryption Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000031', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000031', 'SQLite', 'catalogued', 'Database File Path', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000031', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000031', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sqlite')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000031', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000031', 'v1.1.17', 'd02acd244c4d77f4730e32c78d1d31160e161b7a983ca3b39858924c0c24c939', 45370, 23229440, 's3://connecthub-tenant-acme/sqlite/snapshots/d02acd244c4d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #32: MariaDB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000032', 'mariadb', 'MariaDB', 'Relational Database', 'database', '["User/Password, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000032', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000032', 'MariaDB', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000032', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000032', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mariadb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000032', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000032', 'v1.2.4', 'be7b86fcadc3ddd4ccda9896131f8ec16595c9455da45ca037f421aa49f127cc', 46790, 23956480, 's3://connecthub-tenant-acme/mariadb/snapshots/be7b86fcadc3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #33: Microsoft SQL Server
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000033', 'sqlserver', 'Microsoft SQL Server', 'Relational Database', 'database', '["SQL Auth, Windows/Azure AD"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000033', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000033', 'Microsoft SQL Server', 'catalogued', 'SQL Auth', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000033', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000033', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sqlserver')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000033', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000033', 'v1.3.11', 'fb114e1f9dfcae6ad7a6b36d61c0c90e711e14ceee03d1e06895155db28767be', 48210, 24683520, 's3://connecthub-tenant-acme/sqlserver/snapshots/fb114e1f9dfc.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #34: Oracle Database
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000034', 'oracle_db', 'Oracle Database', 'Relational Database', 'database', '["TNS, User/Password, Wallet"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000034', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000034', 'Oracle Database', 'catalogued', 'TNS', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000034', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000034', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:oracle_db')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000034', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000034', 'v1.4.18', '704477b3f35a2ce22cf289f4489c5b30a004dc312e8ddc7b83a03b0197e46937', 49630, 25410560, 's3://connecthub-tenant-acme/oracle_db/snapshots/704477b3f35a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #35: CockroachDB Dedicated
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000035', 'cockroachdb', 'CockroachDB Dedicated', 'Relational Database', 'database', '["User/Password, SSL Root Cert"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000035', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000035', 'CockroachDB Dedicated', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000035', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000035', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cockroachdb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000035', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000035', 'v1.0.5', 'ac687135a8d0bda33d778d503cc8768999cecb19f0d4cd067973430907a51bce', 51050, 26137600, 's3://connecthub-tenant-acme/cockroachdb/snapshots/ac687135a8d0.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #36: TiDB Serverless
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000036', 'tidb', 'TiDB Serverless', 'Relational Database', 'database', '["User/Password, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000036', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000036', 'TiDB Serverless', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000036', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000036', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:tidb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000036', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000036', 'v1.1.12', 'b04e42541d257b50984376339ddcd7ac95d9833f0414ff06910d7722fefab84c', 52470, 26864640, 's3://connecthub-tenant-acme/tidb/snapshots/b04e42541d25.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #37: Neon Serverless Postgres
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000037', 'neon', 'Neon Serverless Postgres', 'Relational Database', 'mcp', '["API Key, Connection String"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000037', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000037', 'Neon Serverless Postgres', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000037', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000037', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:neon')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000037', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000037', 'v1.2.19', '47c3174e18e02272fba78ddccb0a039a110ece98aa668186d610758a742dc49c', 53890, 27591680, 's3://connecthub-tenant-acme/neon/snapshots/47c3174e18e0.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #38: Supabase (DB & Auth)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000038', 'supabase', 'Supabase (DB & Auth)', 'Relational Database', 'mcp', '["Service Role Key, Database URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000038', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000038', 'Supabase (DB & Auth)', 'catalogued', 'Service Role Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000038', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000038', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:supabase')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000038', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000038', 'v1.3.6', 'c8bc3f49e3ed1113e258bff7a4b9d6c3696034dac51fad4c5fd59d4de673dc86', 55310, 28318720, 's3://connecthub-tenant-acme/supabase/snapshots/c8bc3f49e3ed.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #39: PlanetScale MySQL
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000039', 'planetscale', 'PlanetScale MySQL', 'Relational Database', 'database', '["Service Token, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000039', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000039', 'PlanetScale MySQL', 'catalogued', 'Service Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000039', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000039', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:planetscale')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000039', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000039', 'v1.4.13', '02d82b1cc5e39491fb6553edc34a8e2e5d96c41af7058232ca38c97ae1873fea', 56730, 29045760, 's3://connecthub-tenant-acme/planetscale/snapshots/02d82b1cc5e3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #40: TimescaleDB (Time Series)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000040', 'timescaledb', 'TimescaleDB (Time Series)', 'Relational Database', 'database', '["User/Password, SSL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000040', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000040', 'TimescaleDB (Time Series)', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000040', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000040', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:timescaledb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000040', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000040', 'v1.0.0', 'ae686628751ff604c00563b50ad9d60dcdd1dfa259c7cf4b44afb02e8e121204', 58150, 29772800, 's3://connecthub-tenant-acme/timescaledb/snapshots/ae686628751f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #41: YugabyteDB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000041', 'yugabytedb', 'YugabyteDB', 'Relational Database', 'database', '["User/Password, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000041', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000041', 'YugabyteDB', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000041', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000041', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:yugabytedb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000041', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000041', 'v1.1.7', '136ca1a27c61c8ec44bbfc0172f263f54e1c302314823b51b9b64dc4d8c432be', 59570, 30499840, 's3://connecthub-tenant-acme/yugabytedb/snapshots/136ca1a27c61.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #42: QuestDB Time-Series
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000042', 'questdb', 'QuestDB Time-Series', 'Relational Database', 'database', '["HTTP Influx / PostgreSQL Wire"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000042', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000042', 'QuestDB Time-Series', 'catalogued', 'HTTP Influx / PostgreSQL Wire', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000042', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000042', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:questdb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000042', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000042', 'v1.2.14', 'bb2b76bdeba475e2e0a743b1825eaedb573cb6123cc8a51562e6dda1e0624604', 60990, 31226880, 's3://connecthub-tenant-acme/questdb/snapshots/bb2b76bdeba4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #43: ClickHouse Cloud / Local
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000043', 'clickhouse_local', 'ClickHouse Cloud / Local', 'Relational Database', 'mcp', '["Native / HTTP, User, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000043', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000043', 'ClickHouse Cloud / Local', 'catalogued', 'Native / HTTP', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000043', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000043', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:clickhouse_local')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000043', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000043', 'v1.3.1', '970f95cec197ededeec488051adafccb9a6fc75642f891b75ed61bc78752d9ee', 62410, 31953920, 's3://connecthub-tenant-acme/clickhouse_local/snapshots/970f95cec197.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #44: DuckDB (Big Data Engine)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000044', 'duckdb', 'DuckDB (Big Data Engine)', 'Big Data & Analytics', 'mcp', '["Embedded, Parquet, S3 Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000044', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000044', 'DuckDB (Big Data Engine)', 'catalogued', 'Embedded', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000044', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000044', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:duckdb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000044', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000044', 'v1.4.8', 'c837036544d9a73c622bb2794badd98123b7b4dbb27d4810b6eef3eb05f5580a', 63830, 32680960, 's3://connecthub-tenant-acme/duckdb/snapshots/c837036544d9.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #45: Snowflake Warehouse
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000045', 'snowflake', 'Snowflake Warehouse', 'Big Data & Analytics', 'mcp', '["OAuth, Key-Pair (RSA), Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000045', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000045', 'Snowflake Warehouse', 'catalogued', 'OAuth', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000045', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000045', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:snowflake')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000045', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000045', 'v1.0.15', '82a118092e8472de71876ba1a5d246dbf48b1d10b93e28f3a23b12a2a3eb416b', 65250, 33408000, 's3://connecthub-tenant-acme/snowflake/snapshots/82a118092e84.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #46: Google BigQuery
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000046', 'bigquery', 'Google BigQuery', 'Big Data & Analytics', 'mcp', '["Google OAuth 2.0, Service Account"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000046', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000046', 'Google BigQuery', 'catalogued', 'Google OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000046', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000046', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:bigquery')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000046', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000046', 'v1.1.2', 'abd7f0b91048a3d22c55a249a264433c7fc6aa575a3af38dd3bf108a4a75e7bc', 66670, 34135040, 's3://connecthub-tenant-acme/bigquery/snapshots/abd7f0b91048.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #47: Amazon Redshift
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000047', 'redshift', 'Amazon Redshift', 'Big Data & Analytics', 'database', '["IAM Temp Token, Username/Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000047', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000047', 'Amazon Redshift', 'catalogued', 'IAM Temp Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000047', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000047', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:redshift')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000047', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000047', 'v1.2.9', 'c5d5b48a0c28093232b02769d051d04956a389e4ab8d66c7956e8edb1dfdd052', 68090, 34862080, 's3://connecthub-tenant-acme/redshift/snapshots/c5d5b48a0c28.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #48: Databricks Lakehouse
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000048', 'databricks', 'Databricks Lakehouse', 'Big Data & Analytics', 'mcp', '["OAuth 2.0, Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000048', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000048', 'Databricks Lakehouse', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000048', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000048', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:databricks')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000048', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000048', 'v1.3.16', '31ae8673613e314aad07c5cc93e458107b9dac05a34a3f2d6164c79621226eb1', 69510, 35589120, 's3://connecthub-tenant-acme/databricks/snapshots/31ae8673613e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #49: ClickHouse Analytical
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000049', 'clickhouse_cloud', 'ClickHouse Analytical', 'Big Data & Analytics', 'mcp', '["User, Password, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000049', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000049', 'ClickHouse Analytical', 'catalogued', 'User', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000049', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000049', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:clickhouse_cloud')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000049', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000049', 'v1.4.3', '1bcf2365bed315f8a732eb42a8cba20fd3b4a48c24fd4acaaf5e7445b7d7795c', 70930, 36316160, 's3://connecthub-tenant-acme/clickhouse_cloud/snapshots/1bcf2365bed3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #50: Apache Spark / Livy
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000050', 'apache_spark', 'Apache Spark / Livy', 'Big Data & Analytics', 'api', '["Master URL, Kerberos / Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000050', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000050', 'Apache Spark / Livy', 'catalogued', 'Master URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000050', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000050', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:apache_spark')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000050', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000050', 'v1.0.10', 'cd598e8dcb4ea7a2d62879efb427c2cfa905a1ba82425a1dcd7b17a11e643a00', 72350, 37043200, 's3://connecthub-tenant-acme/apache_spark/snapshots/cd598e8dcb4e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #51: Trino / Presto Distributed
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000051', 'trino', 'Trino / Presto Distributed', 'Big Data & Analytics', 'database', '["User, Password / Kerberos, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000051', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000051', 'Trino / Presto Distributed', 'catalogued', 'User', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000051', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000051', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:trino')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000051', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000051', 'v1.1.17', '3142e45cb4ced17c57bf2ec500d375067385fd6b09d4cf9e2a17ec2df48f9245', 73770, 37770240, 's3://connecthub-tenant-acme/trino/snapshots/3142e45cb4ce.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #52: Apache Druid Real-Time
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000052', 'apache_druid', 'Apache Druid Real-Time', 'Big Data & Analytics', 'api', '["Router URL, Basic Auth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000052', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000052', 'Apache Druid Real-Time', 'catalogued', 'Router URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000052', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000052', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:apache_druid')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000052', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000052', 'v1.2.4', '24bdbedf7744077c9a596feb892447c15d8c77bb0cb44c46ea6b4872ef81c496', 75190, 38497280, 's3://connecthub-tenant-acme/apache_druid/snapshots/24bdbedf7744.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #53: StarRocks OLAP
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000053', 'starrocks', 'StarRocks OLAP', 'Big Data & Analytics', 'database', '["FE Host, User, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000053', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000053', 'StarRocks OLAP', 'catalogued', 'FE Host', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000053', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000053', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:starrocks')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000053', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000053', 'v1.3.11', '65e3de750c03031fb6113e7e427320080c31acb4a914fc2b173dd365eec8cc59', 76610, 39224320, 's3://connecthub-tenant-acme/starrocks/snapshots/65e3de750c03.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #54: dbt Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000054', 'dbt_cloud', 'dbt Cloud', 'Big Data & Analytics', 'api', '["Service Token, Account ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000054', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000054', 'dbt Cloud', 'catalogued', 'Service Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000054', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000054', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:dbt_cloud')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000054', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000054', 'v1.4.18', '2d6920bdbe310c0dad9b5b22ac949615fcc8c9af4d6b9035de80514571cd289f', 78030, 39951360, 's3://connecthub-tenant-acme/dbt_cloud/snapshots/2d6920bdbe31.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #55: Cube Semantic Layer
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000055', 'cubejs', 'Cube Semantic Layer', 'Big Data & Analytics', 'api', '["API Secret, Cube URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000055', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000055', 'Cube Semantic Layer', 'catalogued', 'API Secret', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000055', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000055', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cubejs')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000055', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000055', 'v1.0.5', 'aa288fa036438f4e20e464e1ac23e6aa6047b05b9b1d51267136f74904c49d09', 79450, 40678400, 's3://connecthub-tenant-acme/cubejs/snapshots/aa288fa03643.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #56: MotherDuck (Cloud DuckDB)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000056', 'motherduck', 'MotherDuck (Cloud DuckDB)', 'Big Data & Analytics', 'mcp', '["Service Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000056', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000056', 'MotherDuck (Cloud DuckDB)', 'catalogued', 'Service Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000056', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000056', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:motherduck')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000056', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000056', 'v1.1.12', 'c1aa8839e6711d593baada2749cc0f4951da1567a0953d317d4ad5f4409de172', 80870, 41405440, 's3://connecthub-tenant-acme/motherduck/snapshots/c1aa8839e671.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #57: Firebolt Cloud Data Warehouse
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000057', 'firebolt', 'Firebolt Cloud Data Warehouse', 'Big Data & Analytics', 'database', '["Service Account ID, Secret"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000057', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000057', 'Firebolt Cloud Data Warehouse', 'catalogued', 'Service Account ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000057', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000057', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:firebolt')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000057', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000057', 'v1.2.19', 'ca963e41632ac3ba08355c9a9c5f450dd1fe138b8fe56fd5a58f095ef797eaea', 82290, 42132480, 's3://connecthub-tenant-acme/firebolt/snapshots/ca963e41632a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #58: SingleStoreDB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000058', 'singlestore', 'SingleStoreDB', 'Big Data & Analytics', 'database', '["User/Password, SSL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000058', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000058', 'SingleStoreDB', 'catalogued', 'User/Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000058', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000058', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:singlestore')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000058', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000058', 'v1.3.6', 'eb6d3b0502894978215b8140c61d9f3a8118b76af36b5dc3ac5b3d880cd7787c', 83710, 42859520, 's3://connecthub-tenant-acme/singlestore/snapshots/eb6d3b050289.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #59: Redis / Valkey Cache
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000059', 'redis', 'Redis / Valkey Cache', 'NoSQL & Cache', 'mcp', '["Password, ACL, TLS CA"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000059', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000059', 'Redis / Valkey Cache', 'catalogued', 'Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000059', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000059', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:redis')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000059', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000059', 'v1.4.13', '202cf770804d1c8463abaa9ef1865d2be637c69fc64e62edf906c21ec6bfec0e', 85130, 43586560, 's3://connecthub-tenant-acme/redis/snapshots/202cf770804d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #60: MongoDB Atlas / Enterprise
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000060', 'mongodb', 'MongoDB Atlas / Enterprise', 'NoSQL & Cache', 'database', '["SCRAM-SHA-256, X.509, API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000060', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000060', 'MongoDB Atlas / Enterprise', 'catalogued', 'SCRAM-SHA-256', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000060', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000060', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mongodb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000060', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000060', 'v1.0.0', 'aa646d97bc21e36215339dc5f7c527ea0185493d9cb3cfdd959cbfc77a9ffe02', 86550, 44313600, 's3://connecthub-tenant-acme/mongodb/snapshots/aa646d97bc21.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #61: Apache Cassandra / Astra DB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000061', 'cassandra', 'Apache Cassandra / Astra DB', 'NoSQL & Cache', 'database', '["Secure Connect Bundle, Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000061', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000061', 'Apache Cassandra / Astra DB', 'catalogued', 'Secure Connect Bundle', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000061', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000061', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cassandra')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000061', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000061', 'v1.1.7', '0ab26c3e4466ade7e9856f209e7f811d480358ff4bfbe031150a86099e0b003e', 87970, 45040640, 's3://connecthub-tenant-acme/cassandra/snapshots/0ab26c3e4466.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #62: Couchbase Capella
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000062', 'couchbase', 'Couchbase Capella', 'NoSQL & Cache', 'database', '["Cluster URL, User, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000062', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000062', 'Couchbase Capella', 'catalogued', 'Cluster URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000062', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000062', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:couchbase')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000062', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000062', 'v1.2.14', 'd2356641161a577566ef44a8c474d04ebf907eb98c35bdc04c799b596ec74785', 89390, 45767680, 's3://connecthub-tenant-acme/couchbase/snapshots/d2356641161a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #63: ScyllaDB NoSQL
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000063', 'scylladb', 'ScyllaDB NoSQL', 'NoSQL & Cache', 'database', '["Contact Points, User, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000063', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000063', 'ScyllaDB NoSQL', 'catalogued', 'Contact Points', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000063', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000063', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:scylladb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000063', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000063', 'v1.3.1', '7f5a756b820d47d653ebbb7c7d72c9289e58aa7deb6021352acf4e0178af40e4', 90810, 46494720, 's3://connecthub-tenant-acme/scylladb/snapshots/7f5a756b820d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #64: Amazon DynamoDB
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000064', 'dynamodb', 'Amazon DynamoDB', 'NoSQL & Cache', 'storage', '["IAM Role, STS, Access Keys"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000064', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000064', 'Amazon DynamoDB', 'catalogued', 'IAM Role', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000064', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000064', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:dynamodb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000064', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000064', 'v1.4.8', '8a9b82c8a01f9d7f7e63044d722e49bbe84f1e9b4255da893e1a6dd7ee6947e2', 92230, 47221760, 's3://connecthub-tenant-acme/dynamodb/snapshots/8a9b82c8a01f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #65: Google Cloud Firestore
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000065', 'firestore', 'Google Cloud Firestore', 'NoSQL & Cache', 'database', '["Google Service Account, OAuth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000065', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000065', 'Google Cloud Firestore', 'catalogued', 'Google Service Account', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000065', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000065', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:firestore')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000065', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000065', 'v1.0.15', '97f93a9ce718c104d2ed0b96caa0a961c2d9e5f67323a062c7454b90148e60eb', 93650, 47948800, 's3://connecthub-tenant-acme/firestore/snapshots/97f93a9ce718.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #66: Firebase Realtime Database
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000066', 'firebase_rtdb', 'Firebase Realtime Database', 'NoSQL & Cache', 'database', '["Firebase Secret / Admin SDK"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000066', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000066', 'Firebase Realtime Database', 'catalogued', 'Firebase Secret / Admin SDK', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000066', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000066', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:firebase_rtdb')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000066', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000066', 'v1.1.2', '418a26b1eb3d5c69f4b42d66b708ab92365f8103e1a4602abf663f65ef636e33', 95070, 48675840, 's3://connecthub-tenant-acme/firebase_rtdb/snapshots/418a26b1eb3d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #67: Upstash Serverless Redis
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000067', 'upstash', 'Upstash Serverless Redis', 'NoSQL & Cache', 'mcp', '["REST URL, REST Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000067', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000067', 'Upstash Serverless Redis', 'catalogued', 'REST URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000067', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000067', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:upstash')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000067', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000067', 'v1.2.9', '35e6178015d9a9d920691b0f6f6ce458e0208483afb975dadca0f43d9e3efecf', 96490, 49402880, 's3://connecthub-tenant-acme/upstash/snapshots/35e6178015d9.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #68: DragonflyDB Cache
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000068', 'dragonfly', 'DragonflyDB Cache', 'NoSQL & Cache', 'database', '["Redis Wire Protocol, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000068', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000068', 'DragonflyDB Cache', 'catalogued', 'Redis Wire Protocol', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000068', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000068', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:dragonfly')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000068', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000068', 'v1.3.16', '8ae3d191d4d19e3f3ba501165948b80c31e7244a907a94a99c573670827fa1fe', 97910, 50129920, 's3://connecthub-tenant-acme/dragonfly/snapshots/8ae3d191d4d1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #69: Neo4j Graph Database
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000069', 'neo4j', 'Neo4j Graph Database', 'NoSQL & Cache', 'mcp', '["Bolt Protocol, User, Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000069', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000069', 'Neo4j Graph Database', 'catalogued', 'Bolt Protocol', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000069', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000069', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:neo4j')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000069', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000069', 'v1.4.3', '9392a27ba97a266a1ec10ac29ad0a693bfc16427b2a5d89ec746f2208a66b4bb', 99330, 50856960, 's3://connecthub-tenant-acme/neo4j/snapshots/9392a27ba97a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #70: Memcached
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000070', 'memcached', 'Memcached', 'NoSQL & Cache', 'database', '["Host, Port, SASL Credentials"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000070', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000070', 'Memcached', 'catalogued', 'Host', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000070', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000070', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:memcached')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000070', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000070', 'v1.0.10', 'af798798a8133cda5a9fa330317015d34a3c8f8dce313b102b4060209b309084', 100750, 51584000, 's3://connecthub-tenant-acme/memcached/snapshots/af798798a813.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #71: AWS S3 Object Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000071', 'aws_s3', 'AWS S3 Object Storage', 'Cloud Storage', 'storage', '["IAM Role, STS, Access Keys"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000071', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000071', 'AWS S3 Object Storage', 'catalogued', 'IAM Role', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000071', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000071', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:aws_s3')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000071', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000071', 'v1.1.17', '51efecf42314d927a703e902eda40cdacbea5f178bbfbd87418154f2c0b868cc', 102170, 52311040, 's3://connecthub-tenant-acme/aws_s3/snapshots/51efecf42314.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #72: Google Cloud Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000072', 'gcs', 'Google Cloud Storage', 'Cloud Storage', 'storage', '["Workload Identity, Service Account"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000072', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000072', 'Google Cloud Storage', 'catalogued', 'Workload Identity', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000072', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000072', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:gcs')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000072', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000072', 'v1.2.4', '7f4864795d2ca14e23ad72010f995c4d7b13f6ad6fb8362c638325b2458084c1', 103590, 53038080, 's3://connecthub-tenant-acme/gcs/snapshots/7f4864795d2c.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #73: Azure Blob Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000073', 'azure_blob', 'Azure Blob Storage', 'Cloud Storage', 'storage', '["Entra ID, SAS Token, Shared Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000073', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000073', 'Azure Blob Storage', 'catalogued', 'Entra ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000073', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000073', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:azure_blob')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000073', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000073', 'v1.3.11', '986efb22f7725ac30af7f1bec2d9cc0d5fd71ac8e5b03cbd9220885c71011e42', 105010, 53765120, 's3://connecthub-tenant-acme/azure_blob/snapshots/986efb22f772.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #74: MinIO Object Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000074', 'minio', 'MinIO Object Storage', 'Cloud Storage', 'storage', '["Access Key + Secret Key, Endpoint"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000074', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000074', 'MinIO Object Storage', 'catalogued', 'Access Key + Secret Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000074', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000074', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:minio')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000074', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000074', 'v1.4.18', 'd1593a9cd26e5fa692b4a5c6ab57a867fb871c4d208f7814a46af5297778b1ca', 106430, 54492160, 's3://connecthub-tenant-acme/minio/snapshots/d1593a9cd26e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #75: Cloudflare R2 Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000075', 'cloudflare_r2', 'Cloudflare R2 Storage', 'Cloud Storage', 'storage', '["S3 Compatible Credentials, Account ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000075', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000075', 'Cloudflare R2 Storage', 'catalogued', 'S3 Compatible Credentials', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000075', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000075', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cloudflare_r2')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000075', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000075', 'v1.0.5', '668da0af14f97cdd2c8afd90c874beafea7bbef809bdc9f5d51f90435ff5671d', 107850, 55219200, 's3://connecthub-tenant-acme/cloudflare_r2/snapshots/668da0af14f9.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #76: Wasabi Hot Cloud Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000076', 'wasabi', 'Wasabi Hot Cloud Storage', 'Cloud Storage', 'storage', '["Access Key, Secret Key, Region"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000076', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000076', 'Wasabi Hot Cloud Storage', 'catalogued', 'Access Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000076', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000076', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:wasabi')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000076', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000076', 'v1.1.12', 'f7a04509efdfa98ad7029daa3c1624555a821a75cd140dca8cde222534028b05', 109270, 55946240, 's3://connecthub-tenant-acme/wasabi/snapshots/f7a04509efdf.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #77: Backblaze B2
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000077', 'backblaze_b2', 'Backblaze B2', 'Cloud Storage', 'storage', '["Application Key ID, Application Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000077', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000077', 'Backblaze B2', 'catalogued', 'Application Key ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000077', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000077', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:backblaze_b2')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000077', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000077', 'v1.2.19', '4bade3c41045eae4a193d1c6b3e5cbbb9039c2ef1f49584d2565e417e1cbbe6b', 110690, 56673280, 's3://connecthub-tenant-acme/backblaze_b2/snapshots/4bade3c41045.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #78: Google Drive
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000078', 'google_drive', 'Google Drive', 'File Storage', 'mcp', '["Google OAuth 2.0, Service Account"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000078', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000078', 'Google Drive', 'catalogued', 'Google OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000078', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000078', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:google_drive')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000078', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000078', 'v1.3.6', 'f692716cec3dafe4d5f5ca4786bd83fff47ff06ede069d6496bf8ceedb9c42d0', 112110, 57400320, 's3://connecthub-tenant-acme/google_drive/snapshots/f692716cec3d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #79: Microsoft OneDrive
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000079', 'onedrive', 'Microsoft OneDrive', 'File Storage', 'api', '["Microsoft Entra ID OAuth 2.0"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000079', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000079', 'Microsoft OneDrive', 'catalogued', 'Microsoft Entra ID OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000079', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000079', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:onedrive')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000079', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000079', 'v1.4.13', 'abd9c01136778aadfc02fb0bac3a23fcb381b2f84b1df87294aabb36c7328aca', 113530, 58127360, 's3://connecthub-tenant-acme/onedrive/snapshots/abd9c0113677.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #80: Microsoft SharePoint Online
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000080', 'sharepoint', 'Microsoft SharePoint Online', 'File Storage', 'api', '["Microsoft Entra ID OAuth 2.0"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000080', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000080', 'Microsoft SharePoint Online', 'catalogued', 'Microsoft Entra ID OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000080', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000080', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sharepoint')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000080', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000080', 'v1.0.0', '1a67490ef8a00d223bbeae025e51f52879816e893c9d5a1212b0a5c2768511e9', 114950, 58854400, 's3://connecthub-tenant-acme/sharepoint/snapshots/1a67490ef8a0.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #81: Dropbox
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000081', 'dropbox', 'Dropbox', 'File Storage', 'api', '["OAuth 2.0 PKCE"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000081', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000081', 'Dropbox', 'catalogued', 'OAuth 2.0 PKCE', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000081', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000081', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:dropbox')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000081', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000081', 'v1.1.7', '95e1020d59f18fa0611d4f82e818da645346eb6df26d423549312e56aaf5a3d2', 116370, 59581440, 's3://connecthub-tenant-acme/dropbox/snapshots/95e1020d59f1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #82: Box Enterprise Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000082', 'box', 'Box Enterprise Storage', 'File Storage', 'api', '["OAuth 2.0, JWT Keypair"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000082', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000082', 'Box Enterprise Storage', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000082', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000082', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:box')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000082', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000082', 'v1.2.14', 'cf11bc83c7f64cb06fe161dbfe66c4a52db8bf6046858a08a2ba450396b4abfa', 117790, 60308480, 's3://connecthub-tenant-acme/box/snapshots/cf11bc83c7f6.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #83: SFTP / SSH File Transfer
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000083', 'sftp', 'SFTP / SSH File Transfer', 'File Storage', 'file_transfer', '["SSH Private Key, Passphrase"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000083', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000083', 'SFTP / SSH File Transfer', 'catalogued', 'SSH Private Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000083', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000083', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sftp')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000083', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000083', 'v1.3.1', '4723c6b9d18e7de14de4d245d7f404c9e847cb444b967029d9bd095057ada5ca', 119210, 61035520, 's3://connecthub-tenant-acme/sftp/snapshots/4723c6b9d18e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #84: IPFS / Pinata Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000084', 'ipfs', 'IPFS / Pinata Storage', 'File Storage', 'api', '["Pinata JWT, Gateway URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000084', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000084', 'IPFS / Pinata Storage', 'catalogued', 'Pinata JWT', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000084', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000084', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:ipfs')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000084', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000084', 'v1.4.8', 'eb8c0e43f5d0a5b272ddf74a37d8985415d2a90ccc9be19558dc8f47f7a3df2b', 120630, 61762560, 's3://connecthub-tenant-acme/ipfs/snapshots/eb8c0e43f5d0.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #85: Nextcloud Storage
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000085', 'nextcloud', 'Nextcloud Storage', 'File Storage', 'api', '["App Password, WebDAV URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000085', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000085', 'Nextcloud Storage', 'catalogued', 'App Password', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000085', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000085', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:nextcloud')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000085', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000085', 'v1.0.15', '588a7520f540a0ee143ee348788ca81f574d180ffcb35e8871f5522df9d2ef5e', 122050, 62489600, 's3://connecthub-tenant-acme/nextcloud/snapshots/588a7520f540.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #86: AWS Cloud Management
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000086', 'aws_ec2_iam', 'AWS Cloud Management', 'Cloud Infrastructure', 'api', '["IAM Role, AssumeRole STS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000086', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000086', 'AWS Cloud Management', 'catalogued', 'IAM Role', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000086', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000086', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:aws_ec2_iam')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000086', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000086', 'v1.1.2', '530e602417480c72862ac756d5482d8cdfea8dc954aa0536947d8389f38cd273', 123470, 63216640, 's3://connecthub-tenant-acme/aws_ec2_iam/snapshots/530e60241748.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #87: Microsoft Azure Resource Manager
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000087', 'azure_rm', 'Microsoft Azure Resource Manager', 'Cloud Infrastructure', 'api', '["Entra ID Service Principal"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000087', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000087', 'Microsoft Azure Resource Manager', 'catalogued', 'Entra ID Service Principal', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000087', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000087', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:azure_rm')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000087', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000087', 'v1.2.9', 'ed34faffba2baebfe5be70823664d6a88163597857b4814eff6357ce49c52350', 124890, 63943680, 's3://connecthub-tenant-acme/azure_rm/snapshots/ed34faffba2b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #88: Google Cloud Platform (GCP)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000088', 'gcp_compute', 'Google Cloud Platform (GCP)', 'Cloud Infrastructure', 'api', '["Service Account JSON, Workload Identity"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000088', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000088', 'Google Cloud Platform (GCP)', 'catalogued', 'Service Account JSON', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000088', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000088', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:gcp_compute')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000088', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000088', 'v1.3.16', 'ea30f0a46c3193b13833333b72f998382cd1572583e67e811d6f03c81abeee41', 126310, 64670720, 's3://connecthub-tenant-acme/gcp_compute/snapshots/ea30f0a46c31.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #89: Cloudflare DNS & Edge
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000089', 'cloudflare', 'Cloudflare DNS & Edge', 'Cloud Infrastructure', 'mcp', '["API Token (Scoped)"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000089', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000089', 'Cloudflare DNS & Edge', 'catalogued', 'API Token (Scoped)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000089', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000089', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cloudflare')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000089', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000089', 'v1.4.3', '07d3382107d4c540035e8f3469c4a3223f10554ab1a8955906e1eb3fafb45377', 127730, 65397760, 's3://connecthub-tenant-acme/cloudflare/snapshots/07d3382107d4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #90: DigitalOcean Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000090', 'digitalocean', 'DigitalOcean Cloud', 'Cloud Infrastructure', 'api', '["Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000090', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000090', 'DigitalOcean Cloud', 'catalogued', 'Personal Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000090', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000090', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:digitalocean')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000090', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000090', 'v1.0.10', '2aa82a64428b609057e62c8a8bd3bd95c533a956fac620e4e998bfec4aed6a06', 129150, 66124800, 's3://connecthub-tenant-acme/digitalocean/snapshots/2aa82a64428b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #91: Hetzner Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000091', 'hetzner', 'Hetzner Cloud', 'Cloud Infrastructure', 'api', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000091', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000091', 'Hetzner Cloud', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000091', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000091', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:hetzner')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000091', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000091', 'v1.1.17', 'c3d9f38b05c8af6eef614c4c8397fb451299fd22bae5bf3272dddc0984108a8f', 130570, 66851840, 's3://connecthub-tenant-acme/hetzner/snapshots/c3d9f38b05c8.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #92: Linode / Akamai Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000092', 'linode', 'Linode / Akamai Cloud', 'Cloud Infrastructure', 'api', '["Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000092', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000092', 'Linode / Akamai Cloud', 'catalogued', 'Personal Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000092', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000092', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:linode')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000092', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000092', 'v1.2.4', '850ed772058e69acc2bc4de1369145268c96dac59194fb865f793aef71184177', 131990, 67578880, 's3://connecthub-tenant-acme/linode/snapshots/850ed772058e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #93: Vercel Deployment Platform
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000093', 'vercel', 'Vercel Deployment Platform', 'Cloud Infrastructure', 'mcp', '["Personal / Team Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000093', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000093', 'Vercel Deployment Platform', 'catalogued', 'Personal / Team Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000093', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000093', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:vercel')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000093', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000093', 'v1.3.11', 'eb63ff9229cbb6987a34b8f9f40dccd799b0db4c28de7267facd5da960b12716', 133410, 68305920, 's3://connecthub-tenant-acme/vercel/snapshots/eb63ff9229cb.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #94: Netlify Edge
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000094', 'netlify', 'Netlify Edge', 'Cloud Infrastructure', 'api', '["Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000094', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000094', 'Netlify Edge', 'catalogued', 'Personal Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000094', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000094', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:netlify')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000094', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000094', 'v1.4.18', 'f2b9d8cc00d4cac9eef114473d7a24581715d3bb84036ce9768d45510576c94f', 134830, 69032960, 's3://connecthub-tenant-acme/netlify/snapshots/f2b9d8cc00d4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #95: Render Cloud Platform
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000095', 'render', 'Render Cloud Platform', 'Cloud Infrastructure', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000095', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000095', 'Render Cloud Platform', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000095', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000095', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:render')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000095', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000095', 'v1.0.5', '7799b3f6970458e9b150a6e8b54e6412158338bd16593c6d409d3c72688f7ce8', 136250, 69760000, 's3://connecthub-tenant-acme/render/snapshots/7799b3f69704.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #96: Railway Infrastructure
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000096', 'railway', 'Railway Infrastructure', 'Cloud Infrastructure', 'api', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000096', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000096', 'Railway Infrastructure', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000096', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000096', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:railway')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000096', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000096', 'v1.1.12', 'c026e0dfb48a5e38f03c4e2d00a5845c767e6990b6aff305daa3862a12d6d083', 137670, 70487040, 's3://connecthub-tenant-acme/railway/snapshots/c026e0dfb48a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #97: Fly.io App Platform
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000097', 'fly_io', 'Fly.io App Platform', 'Cloud Infrastructure', 'api', '["Auth Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000097', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000097', 'Fly.io App Platform', 'catalogued', 'Auth Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000097', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000097', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:fly_io')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000097', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000097', 'v1.2.19', '68eebe5683424e63312091e34f8a81ba7d2a50f22789b5f5d4641b8ed108e702', 139090, 71214080, 's3://connecthub-tenant-acme/fly_io/snapshots/68eebe568342.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #98: OVHcloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000098', 'ovhcloud', 'OVHcloud', 'Cloud Infrastructure', 'api', '["Application Key, Secret, Consumer Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000098', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000098', 'OVHcloud', 'catalogued', 'Application Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000098', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000098', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:ovhcloud')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000098', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000098', 'v1.3.6', 'f17b7e918f6633384a2afe4a689e6af1ba4d4ed1e3b450243d0a1eaa128057dd', 140510, 71941120, 's3://connecthub-tenant-acme/ovhcloud/snapshots/f17b7e918f66.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #99: Scaleway Elements
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000099', 'scaleaway', 'Scaleway Elements', 'Cloud Infrastructure', 'api', '["Secret Key, Organization ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000099', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000099', 'Scaleway Elements', 'catalogued', 'Secret Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000099', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000099', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:scaleaway')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000099', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000099', 'v1.4.13', '9e12689800e7123f90f90ef0343fd97943e8f68b96f81a8755f2bd2f0a568ab9', 141930, 72668160, 's3://connecthub-tenant-acme/scaleaway/snapshots/9e12689800e7.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #100: Equinix Metal Bare Metal
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000100', 'equinix_metal', 'Equinix Metal Bare Metal', 'Cloud Infrastructure', 'api', '["User API Token, Project ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000100', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000100', 'Equinix Metal Bare Metal', 'catalogued', 'User API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000100', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000100', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:equinix_metal')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000100', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000100', 'v1.0.0', 'b5e65954d76f1d2faab2805edd19ead17c9c6aa17767c332cd1d928813577bed', 143350, 73395200, 's3://connecthub-tenant-acme/equinix_metal/snapshots/b5e65954d76f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #101: GitHub
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000101', 'github', 'GitHub', 'DevOps & Code', 'mcp', '["OAuth 2.0, GitHub App, Fine-grained PAT"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000101', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000101', 'GitHub', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000101', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000101', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:github')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000101', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000101', 'v1.1.7', 'f72395da7fcef0ffe1c029782798301908ce5f4cb1bed44a4a2d998eb7f38ca3', 144770, 74122240, 's3://connecthub-tenant-acme/github/snapshots/f72395da7fce.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #102: GitLab
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000102', 'gitlab', 'GitLab', 'DevOps & Code', 'mcp', '["OAuth 2.0, Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000102', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000102', 'GitLab', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000102', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000102', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:gitlab')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000102', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000102', 'v1.2.14', '2c32488ec731c16883c391ad8925b0c3ef5ff9db7e49b3a14246584e4ed4891e', 146190, 74849280, 's3://connecthub-tenant-acme/gitlab/snapshots/2c32488ec731.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #103: Bitbucket Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000103', 'bitbucket', 'Bitbucket Cloud', 'DevOps & Code', 'api', '["OAuth 2.0, App Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000103', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000103', 'Bitbucket Cloud', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000103', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000103', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:bitbucket')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000103', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000103', 'v1.3.1', 'ca21c604813b40e80ea58a7383407994360bc1c80210152ecf1990d350528161', 147610, 75576320, 's3://connecthub-tenant-acme/bitbucket/snapshots/ca21c604813b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #104: Azure DevOps Repos & Pipelines
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000104', 'azure_devops', 'Azure DevOps Repos & Pipelines', 'DevOps & Code', 'api', '["Microsoft Entra ID, PAT"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000104', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000104', 'Azure DevOps Repos & Pipelines', 'catalogued', 'Microsoft Entra ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000104', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000104', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:azure_devops')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000104', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000104', 'v1.4.8', '06a8a3d5c8a265d559d5ed88c8b3830bd4bf1ff8f0c2755c52023e17c7b50554', 149030, 76303360, 's3://connecthub-tenant-acme/azure_devops/snapshots/06a8a3d5c8a2.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #105: Gitea / Forgejo
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000105', 'gitea', 'Gitea / Forgejo', 'DevOps & Code', 'mcp', '["Access Token, Basic Auth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000105', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000105', 'Gitea / Forgejo', 'catalogued', 'Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000105', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000105', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:gitea')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000105', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000105', 'v1.0.15', '02e9f9438ba8c6c450504458c77614703f22aedd7ae342571f502edaaab2db6b', 150450, 77030400, 's3://connecthub-tenant-acme/gitea/snapshots/02e9f9438ba8.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #106: Docker Hub Registry
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000106', 'docker_hub', 'Docker Hub Registry', 'DevOps & Code', 'mcp', '["Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000106', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000106', 'Docker Hub Registry', 'catalogued', 'Personal Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000106', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000106', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:docker_hub')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000106', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000106', 'v1.1.2', '4c810d23ac3da15619a55c819af28b0324ad12d7d4b5d67cfecea48db452640a', 151870, 77757440, 's3://connecthub-tenant-acme/docker_hub/snapshots/4c810d23ac3d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #107: Kubernetes Cluster
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000107', 'kubernetes', 'Kubernetes Cluster', 'DevOps & Code', 'mcp', '["Kubeconfig, ServiceAccount Bearer Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000107', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000107', 'Kubernetes Cluster', 'catalogued', 'Kubeconfig', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000107', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000107', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:kubernetes')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000107', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000107', 'v1.2.9', 'c2709678aff93202ee80f1219fae449fedb60cafe04a3d10171eb646ad50b967', 153290, 78484480, 's3://connecthub-tenant-acme/kubernetes/snapshots/c2709678aff9.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #108: ArgoCD GitOps
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000108', 'argocd', 'ArgoCD GitOps', 'DevOps & Code', 'api', '["Auth Token, Server URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000108', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000108', 'ArgoCD GitOps', 'catalogued', 'Auth Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000108', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000108', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:argocd')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000108', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000108', 'v1.3.16', 'ea54d1b702f1b40247e5eb34e8ad28aa57b77f2d9720e542bef57ace669f9811', 154710, 79211520, 's3://connecthub-tenant-acme/argocd/snapshots/ea54d1b702f1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #109: Terraform Cloud / HCP
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000109', 'terraform_cloud', 'Terraform Cloud / HCP', 'DevOps & Code', 'api', '["User / Team API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000109', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000109', 'Terraform Cloud / HCP', 'catalogued', 'User / Team API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000109', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000109', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:terraform_cloud')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000109', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000109', 'v1.4.3', '3cfb566caabce4f343c0522841f12fe02dc128b9b8c158eabedc9dff45e42cdf', 156130, 79938560, 's3://connecthub-tenant-acme/terraform_cloud/snapshots/3cfb566caabc.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #110: Pulumi Service
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000110', 'pulumi', 'Pulumi Service', 'DevOps & Code', 'api', '["Pulumi Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000110', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000110', 'Pulumi Service', 'catalogued', 'Pulumi Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000110', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000110', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:pulumi')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000110', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000110', 'v1.0.10', 'cb87fbe0246e48cae8b1bead1d1b8a12d18813f60920715411275d65dff4a643', 157550, 80665600, 's3://connecthub-tenant-acme/pulumi/snapshots/cb87fbe0246e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #111: Jenkins Automation
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000111', 'jenkins', 'Jenkins Automation', 'DevOps & Code', 'api', '["API Token, Username"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000111', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000111', 'Jenkins Automation', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000111', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000111', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:jenkins')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000111', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000111', 'v1.1.17', '40e727d27434c27c365f2cd2d6386b061fcb211789cda3fc694475b0b1f848aa', 158970, 81392640, 's3://connecthub-tenant-acme/jenkins/snapshots/40e727d27434.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #112: CircleCI
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000112', 'circleci', 'CircleCI', 'DevOps & Code', 'api', '["Personal API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000112', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000112', 'CircleCI', 'catalogued', 'Personal API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000112', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000112', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:circleci')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000112', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000112', 'v1.2.4', '762c526299f6f05f74b613f5281ea279c9c4290b3fb08bc810dfa5402f2bf98d', 160390, 82119680, 's3://connecthub-tenant-acme/circleci/snapshots/762c526299f6.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #113: JFrog Artifactory
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000113', 'artifactory', 'JFrog Artifactory', 'DevOps & Code', 'api', '["Access Token, Artifactory URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000113', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000113', 'JFrog Artifactory', 'catalogued', 'Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000113', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000113', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:artifactory')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000113', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000113', 'v1.3.11', 'a1aaed7e9c941828b43f538240e155870c50e60d3a5fcbb86fc24ee0baaffd9f', 161810, 82846720, 's3://connecthub-tenant-acme/artifactory/snapshots/a1aaed7e9c94.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #114: Snyk Security & Vulnerability
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000114', 'snyk', 'Snyk Security & Vulnerability', 'DevOps & Code', 'mcp', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000114', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000114', 'Snyk Security & Vulnerability', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000114', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000114', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:snyk')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000114', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000114', 'v1.4.18', 'e2fc1e980e53a29ecf1e8786fce757b792f74f85a256e5422b36b4e2a0a411b6', 163230, 83573760, 's3://connecthub-tenant-acme/snyk/snapshots/e2fc1e980e53.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #115: SonarQube / SonarCloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000115', 'sonarqube', 'SonarQube / SonarCloud', 'DevOps & Code', 'api', '["User Token, Server URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000115', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000115', 'SonarQube / SonarCloud', 'catalogued', 'User Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000115', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000115', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sonarqube')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000115', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000115', 'v1.0.5', '955134981a59909a55f24a474bccac53ad70533b24e409ec339fdbef54fa9f37', 164650, 84300800, 's3://connecthub-tenant-acme/sonarqube/snapshots/955134981a59.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #116: Datadog Observability
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000116', 'datadog', 'Datadog Observability', 'Observability & Monitoring', 'mcp', '["API Key, Application Key, Site"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000116', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000116', 'Datadog Observability', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000116', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000116', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:datadog')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000116', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000116', 'v1.1.12', '7639d0020c214f8b5ba63bd51bde0f10c4501a79ba57fac27be27d7048bc1a1d', 166070, 85027840, 's3://connecthub-tenant-acme/datadog/snapshots/7639d0020c21.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #117: New Relic APM
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000117', 'newrelic', 'New Relic APM', 'Observability & Monitoring', 'api', '["User API Key, Account ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000117', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000117', 'New Relic APM', 'catalogued', 'User API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000117', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000117', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:newrelic')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000117', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000117', 'v1.2.19', 'ca823585fdb5bf92ea9c85818c02d98c863eab3b6cc0112d11174080394ad496', 167490, 85754880, 's3://connecthub-tenant-acme/newrelic/snapshots/ca823585fdb5.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #118: Grafana Cloud / OSS
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000118', 'grafana', 'Grafana Cloud / OSS', 'Observability & Monitoring', 'mcp', '["Service Account Token, Host URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000118', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000118', 'Grafana Cloud / OSS', 'catalogued', 'Service Account Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000118', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000118', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:grafana')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000118', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000118', 'v1.3.6', 'c34eb697cc94af7f6f1641d91c181cacd3dc1f9d21570e065996a5710c38da43', 168910, 86481920, 's3://connecthub-tenant-acme/grafana/snapshots/c34eb697cc94.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #119: Prometheus Metrics
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000119', 'prometheus', 'Prometheus Metrics', 'Observability & Monitoring', 'api', '["Server URL, Basic Auth, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000119', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000119', 'Prometheus Metrics', 'catalogued', 'Server URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000119', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000119', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:prometheus')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000119', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000119', 'v1.4.13', '56766be0796a7c87d3bf45c4189d5d82bc5ecc91cefda1c9a41ab86f97e75c7a', 170330, 87208960, 's3://connecthub-tenant-acme/prometheus/snapshots/56766be0796a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #120: Sentry Error Tracking
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000120', 'sentry', 'Sentry Error Tracking', 'Observability & Monitoring', 'mcp', '["User Auth Token, Organization"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000120', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000120', 'Sentry Error Tracking', 'catalogued', 'User Auth Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000120', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000120', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sentry')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000120', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000120', 'v1.0.0', '2907009368679c86511e7b7ce2531dbea0a87d7100ee8e0632e465c4b2f44f12', 171750, 87936000, 's3://connecthub-tenant-acme/sentry/snapshots/290700936867.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #121: Splunk Enterprise / Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000121', 'splunk', 'Splunk Enterprise / Cloud', 'Observability & Monitoring', 'api', '["HEC Token, Management Port, TLS"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000121', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000121', 'Splunk Enterprise / Cloud', 'catalogued', 'HEC Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000121', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000121', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:splunk')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000121', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000121', 'v1.1.7', 'c23572c297729c6cbe47599dc6f6a36d61a7cc4e4106dd32838ea86d3f4761e0', 173170, 88663040, 's3://connecthub-tenant-acme/splunk/snapshots/c23572c29772.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #122: Dynatrace Intelligence
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000122', 'dynatrace', 'Dynatrace Intelligence', 'Observability & Monitoring', 'api', '["Environment Token, Tenant URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000122', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000122', 'Dynatrace Intelligence', 'catalogued', 'Environment Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000122', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000122', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:dynatrace')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000122', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000122', 'v1.2.14', 'ec9da76db365e9ebeada17feb7870f9e8cfd1c30637a0b87c11d2a2227f52c0b', 174590, 89390080, 's3://connecthub-tenant-acme/dynatrace/snapshots/ec9da76db365.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #123: Elasticsearch / Kibana
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000123', 'elasticsearch_apm', 'Elasticsearch / Kibana', 'Observability & Monitoring', 'mcp', '["API Key, Elastic Cloud ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000123', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000123', 'Elasticsearch / Kibana', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000123', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000123', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:elasticsearch_apm')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000123', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000123', 'v1.3.1', '51daf9699cd416f1d27757f59c6f7a93f71f64bc42f769634bbf9872deb4e89c', 176010, 90117120, 's3://connecthub-tenant-acme/elasticsearch_apm/snapshots/51daf9699cd4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #124: Better Stack (Logtail/Uptime)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000124', 'betterstack', 'Better Stack (Logtail/Uptime)', 'Observability & Monitoring', 'api', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000124', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000124', 'Better Stack (Logtail/Uptime)', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000124', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000124', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:betterstack')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000124', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000124', 'v1.4.8', '77b8a2c93c9ddf66fd9b3ae1f9ee940779009fa498cac9f00fe1fb026a6407ba', 177430, 90844160, 's3://connecthub-tenant-acme/betterstack/snapshots/77b8a2c93c9d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #125: PostHog Analytics
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000125', 'posthog', 'PostHog Analytics', 'Observability & Monitoring', 'mcp', '["Personal API Key, Project API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000125', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000125', 'PostHog Analytics', 'catalogued', 'Personal API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000125', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000125', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:posthog')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000125', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000125', 'v1.0.15', 'd6dac553f306936c9e4f35e76b03012942cf98a45dfea319130c1ed6a22b1730', 178850, 91571200, 's3://connecthub-tenant-acme/posthog/snapshots/d6dac553f306.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #126: Mixpanel Product Analytics
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000126', 'mixpanel', 'Mixpanel Product Analytics', 'Observability & Monitoring', 'api', '["Service Account Secret, Project ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000126', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000126', 'Mixpanel Product Analytics', 'catalogued', 'Service Account Secret', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000126', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000126', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mixpanel')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000126', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000126', 'v1.1.2', '597394f0b9fb56bc0c1afa56ae2aaec97f92750491d2d76c549b88e87613f416', 180270, 92298240, 's3://connecthub-tenant-acme/mixpanel/snapshots/597394f0b9fb.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #127: Amplitude Analytics
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000127', 'amplitude', 'Amplitude Analytics', 'Observability & Monitoring', 'api', '["API Key, Secret Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000127', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000127', 'Amplitude Analytics', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000127', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000127', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:amplitude')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000127', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000127', 'v1.2.9', '3b1b6305dbe944a0d9d48f1ae7539de68a92d4af5b45d290b551c8b444d2cc3e', 181690, 93025280, 's3://connecthub-tenant-acme/amplitude/snapshots/3b1b6305dbe9.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #128: Twilio Segment CDP
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000128', 'segment', 'Twilio Segment CDP', 'Observability & Monitoring', 'api', '["Write Key, Public API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000128', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000128', 'Twilio Segment CDP', 'catalogued', 'Write Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000128', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000128', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:segment')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000128', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000128', 'v1.3.16', '3e259ad3b433d64fa703b11e01bbe9c790e8bf2f02c7145fcd17fcd9a2b8f751', 183110, 93752320, 's3://connecthub-tenant-acme/segment/snapshots/3e259ad3b433.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #129: Slack Workspace
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000129', 'slack', 'Slack Workspace', 'Communication', 'mcp', '["OAuth 2.0, Bot Token, User Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000129', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000129', 'Slack Workspace', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000129', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000129', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:slack')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000129', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000129', 'v1.4.3', '0774e455157a49b780ac86fa8c34762d6c363b2b4c73c8087d56d84d1957cba8', 184530, 94479360, 's3://connecthub-tenant-acme/slack/snapshots/0774e455157a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #130: Microsoft Teams
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000130', 'microsoft_teams', 'Microsoft Teams', 'Communication', 'api', '["Microsoft Entra ID OAuth 2.0"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000130', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000130', 'Microsoft Teams', 'catalogued', 'Microsoft Entra ID OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000130', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000130', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:microsoft_teams')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000130', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000130', 'v1.0.10', 'c76bfaafb311003fa5e23e60e6cc36d4e0125e9b5b71b05682b546505e0aaf76', 185950, 95206400, 's3://connecthub-tenant-acme/microsoft_teams/snapshots/c76bfaafb311.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #131: Discord Community
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000131', 'discord', 'Discord Community', 'Communication', 'api', '["Bot Token, Client ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000131', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000131', 'Discord Community', 'catalogued', 'Bot Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000131', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000131', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:discord')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000131', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000131', 'v1.1.17', 'ee21f5381fb857e09b68ba9aac34d189bc04776cd47045c2e731302fc84b6eb7', 187370, 95933440, 's3://connecthub-tenant-acme/discord/snapshots/ee21f5381fb8.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #132: Telegram Bot
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000132', 'telegram', 'Telegram Bot', 'Communication', 'mcp', '["Bot Father API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000132', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000132', 'Telegram Bot', 'catalogued', 'Bot Father API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000132', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000132', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:telegram')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000132', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000132', 'v1.2.4', '517512ce0a79ddbaefbe91022eb7c11e44f6f508283df36b71eb86f42857a725', 188790, 96660480, 's3://connecthub-tenant-acme/telegram/snapshots/517512ce0a79.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #133: WhatsApp Business (Meta)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000133', 'whatsapp_business', 'WhatsApp Business (Meta)', 'Communication', 'api', '["System User Access Token, Phone ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000133', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000133', 'WhatsApp Business (Meta)', 'catalogued', 'System User Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000133', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000133', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:whatsapp_business')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000133', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000133', 'v1.3.11', '5e979990bbaf7e75e4149964f7b9d2d9098db80dc637e5b6911e4823eea8a7bb', 190210, 97387520, 's3://connecthub-tenant-acme/whatsapp_business/snapshots/5e979990bbaf.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #134: Zoom Video Communications
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000134', 'zoom', 'Zoom Video Communications', 'Communication', 'api', '["Server-to-Server OAuth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000134', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000134', 'Zoom Video Communications', 'catalogued', 'Server-to-Server OAuth', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000134', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000134', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:zoom')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000134', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000134', 'v1.4.18', '7d62e2753f1c5d7f5e771acde36e045538fbfbb32a6436f0eace52963db6c2c8', 191630, 98114560, 's3://connecthub-tenant-acme/zoom/snapshots/7d62e2753f1c.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #135: Google Meet
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000135', 'google_meet', 'Google Meet', 'Communication', 'api', '["Google OAuth 2.0, Workspace Admin"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000135', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000135', 'Google Meet', 'catalogued', 'Google OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000135', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000135', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:google_meet')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000135', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000135', 'v1.0.5', 'faea60bb5791f38bd69e091097826949bfe28e417b6380002df4d480a6728c1a', 193050, 98841600, 's3://connecthub-tenant-acme/google_meet/snapshots/faea60bb5791.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #136: Cisco Webex
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000136', 'cisco_webex', 'Cisco Webex', 'Communication', 'api', '["OAuth 2.0, Bot Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000136', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000136', 'Cisco Webex', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000136', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000136', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:cisco_webex')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000136', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000136', 'v1.1.12', 'e8b6d879f9e4b432a6167a3bf121a4dc6c31f257dc8b39b4340e225ad2095460', 194470, 99568640, 's3://connecthub-tenant-acme/cisco_webex/snapshots/e8b6d879f9e4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #137: Mattermost Collaboration
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000137', 'mattermost', 'Mattermost Collaboration', 'Communication', 'api', '["Personal Access Token, Bot Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000137', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000137', 'Mattermost Collaboration', 'catalogued', 'Personal Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000137', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000137', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mattermost')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000137', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000137', 'v1.2.19', '956426c44bc42bd673defb00b51ce9cbee06f2c7ed47d938ec87790b8914f2f1', 195890, 100295680, 's3://connecthub-tenant-acme/mattermost/snapshots/956426c44bc4.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #138: Matrix / Element Synapse
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000138', 'matrix', 'Matrix / Element Synapse', 'Communication', 'api', '["Access Token, Homeserver URL"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000138', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000138', 'Matrix / Element Synapse', 'catalogued', 'Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000138', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000138', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:matrix')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000138', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000138', 'v1.3.6', 'ac8e6cef5f9f36a61f407a348b5515f6bf1570d5699c6fa276ccba510f27eedb', 197310, 101022720, 's3://connecthub-tenant-acme/matrix/snapshots/ac8e6cef5f9f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #139: Twilio Voice & SMS
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000139', 'twilio_sms', 'Twilio Voice & SMS', 'Communication', 'api', '["Account SID, Auth Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000139', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000139', 'Twilio Voice & SMS', 'catalogued', 'Account SID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000139', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000139', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:twilio_sms')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000139', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000139', 'v1.4.13', '1b585b0cbbe3ab58505d49e3b43da0af9115495a96e0dadb2abc04dbd0084365', 198730, 101749760, 's3://connecthub-tenant-acme/twilio_sms/snapshots/1b585b0cbbe3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #140: Twilio SendGrid Email
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000140', 'sendgrid', 'Twilio SendGrid Email', 'Communication', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000140', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000140', 'Twilio SendGrid Email', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000140', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000140', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:sendgrid')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000140', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000140', 'v1.0.0', 'ced744e61101f9481be661299140b447410a4ef047c3cf080521db629262786e', 200150, 102476800, 's3://connecthub-tenant-acme/sendgrid/snapshots/ced744e61101.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #141: Resend Modern Email
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000141', 'resend', 'Resend Modern Email', 'Communication', 'mcp', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000141', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000141', 'Resend Modern Email', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000141', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000141', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:resend')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000141', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000141', 'v1.1.7', '1740825ab9291c27a0280e6460210bdd28eb88ed4bf4854fccb69c46c7a505cf', 201570, 103203840, 's3://connecthub-tenant-acme/resend/snapshots/1740825ab929.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #142: Postmark Transactional Email
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000142', 'postmark', 'Postmark Transactional Email', 'Communication', 'api', '["Server API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000142', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000142', 'Postmark Transactional Email', 'catalogued', 'Server API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000142', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000142', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:postmark')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000142', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000142', 'v1.2.14', '4a9f4ec65932eed9a16a815d0c76402fc0c6e61b41102f8a13040bc51403f234', 202990, 103930880, 's3://connecthub-tenant-acme/postmark/snapshots/4a9f4ec65932.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #143: Generic SMTP / IMAP Email
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000143', 'smtp_imap', 'Generic SMTP / IMAP Email', 'Communication', 'api', '["Host, Port, User, TLS/SSL Password"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000143', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000143', 'Generic SMTP / IMAP Email', 'catalogued', 'Host', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000143', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000143', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:smtp_imap')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000143', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000143', 'v1.3.1', '0ffec0e9a0b6c25fd99f9047e11e287c5a3cda2c1d8ee1b64696513e954f795a', 204410, 104657920, 's3://connecthub-tenant-acme/smtp_imap/snapshots/0ffec0e9a0b6.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #144: Jira Software & Product
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000144', 'jira', 'Jira Software & Product', 'Project Management', 'mcp', '["OAuth 2.0 (3LO), API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000144', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000144', 'Jira Software & Product', 'catalogued', 'OAuth 2.0 (3LO)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000144', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000144', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:jira')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000144', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000144', 'v1.4.8', '9434037682421dbc5554fdfb99bfdec882351dee8820846c711219d72e3346e7', 205830, 105384960, 's3://connecthub-tenant-acme/jira/snapshots/943403768242.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #145: Confluence Wiki
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000145', 'confluence', 'Confluence Wiki', 'Project Management', 'mcp', '["OAuth 2.0 (3LO), API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000145', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000145', 'Confluence Wiki', 'catalogued', 'OAuth 2.0 (3LO)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000145', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000145', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:confluence')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000145', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000145', 'v1.0.15', 'e679156d6f11656cb2f73bfb76adb90814f34c710bd686543d3c37f90d985a9a', 207250, 106112000, 's3://connecthub-tenant-acme/confluence/snapshots/e679156d6f11.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #146: Linear Issue Tracker
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000146', 'linear', 'Linear Issue Tracker', 'Project Management', 'mcp', '["OAuth 2.0, Personal API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000146', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000146', 'Linear Issue Tracker', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000146', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000146', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:linear')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000146', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000146', 'v1.1.2', 'afde714c09b5e5c8a66acc33f3a097c58d2ca9da1045df1d9affea9b56aee651', 208670, 106839040, 's3://connecthub-tenant-acme/linear/snapshots/afde714c09b5.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #147: Asana Work Management
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000147', 'asana', 'Asana Work Management', 'Project Management', 'api', '["OAuth 2.0, Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000147', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000147', 'Asana Work Management', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000147', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000147', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:asana')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000147', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000147', 'v1.2.9', '17752d02b13b1b646ae0c8d0808cd70769ab708fd7380196ea9f1db7d862b326', 210090, 107566080, 's3://connecthub-tenant-acme/asana/snapshots/17752d02b13b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #148: Monday.com Work OS
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000148', 'monday', 'Monday.com Work OS', 'Project Management', 'api', '["API v2 Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000148', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000148', 'Monday.com Work OS', 'catalogued', 'API v2 Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000148', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000148', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:monday')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000148', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000148', 'v1.3.16', '42ab6b866bc55d14ffb8cafc2c0e4d0f48671826d34d4c04f4e0c34d73e78040', 211510, 108293120, 's3://connecthub-tenant-acme/monday/snapshots/42ab6b866bc5.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #149: Trello Boards
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000149', 'trello', 'Trello Boards', 'Project Management', 'api', '["API Key, OAuth Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000149', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000149', 'Trello Boards', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000149', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000149', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:trello')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000149', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000149', 'v1.4.3', '62c822ea6e42a9af8db261825d3faa1a0c8f206f1ae52a27d18bf8ba3f3ca434', 212930, 109020160, 's3://connecthub-tenant-acme/trello/snapshots/62c822ea6e42.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #150: Notion Workspace
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000150', 'notion', 'Notion Workspace', 'Project Management', 'mcp', '["OAuth 2.0, Internal Integration Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000150', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000150', 'Notion Workspace', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000150', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000150', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:notion')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000150', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000150', 'v1.0.10', 'f1858d1890bca384c81b89a545abb61ee1a299fb47add911d821eceb58d96bb1', 214350, 109747200, 's3://connecthub-tenant-acme/notion/snapshots/f1858d1890bc.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #151: ClickUp All-in-One
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000151', 'clickup', 'ClickUp All-in-One', 'Project Management', 'api', '["OAuth 2.0, Personal API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000151', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000151', 'ClickUp All-in-One', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000151', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000151', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:clickup')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000151', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000151', 'v1.1.17', 'd0cf6648853acad250a339ed2079d50740a4f868423a19ecbcff5ace3657bd9d', 215770, 110474240, 's3://connecthub-tenant-acme/clickup/snapshots/d0cf6648853a.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #152: Basecamp 4
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000152', 'basecamp', 'Basecamp 4', 'Project Management', 'api', '["OAuth 2.0, Account ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000152', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000152', 'Basecamp 4', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000152', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000152', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:basecamp')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000152', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000152', 'v1.2.4', '81fb68ff01e3a1c384ce5cd12aa5c2c2af6b9fa2764a334b5b958685f83da476', 217190, 111201280, 's3://connecthub-tenant-acme/basecamp/snapshots/81fb68ff01e3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #153: Wrike Collaborative Work
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000153', 'wrike', 'Wrike Collaborative Work', 'Project Management', 'api', '["Permanent Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000153', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000153', 'Wrike Collaborative Work', 'catalogued', 'Permanent Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000153', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000153', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:wrike')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000153', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000153', 'v1.3.11', 'e7dfd7d23a5fad4a04712f8a5e2f19605d1779a38518bd66efee3e7d3c610d69', 218610, 111928320, 's3://connecthub-tenant-acme/wrike/snapshots/e7dfd7d23a5f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #154: Shortcut (Clubhouse)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000154', 'shortcut', 'Shortcut (Clubhouse)', 'Project Management', 'api', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000154', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000154', 'Shortcut (Clubhouse)', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000154', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000154', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:shortcut')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000154', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000154', 'v1.4.18', '935e9345a553688d3c21bda247112dba0aaa142b8bb9c2fa47c31742034b4915', 220030, 112655360, 's3://connecthub-tenant-acme/shortcut/snapshots/935e9345a553.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #155: Coda Interactive Docs
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000155', 'coda', 'Coda Interactive Docs', 'Project Management', 'api', '["API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000155', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000155', 'Coda Interactive Docs', 'catalogued', 'API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000155', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000155', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:coda')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000155', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000155', 'v1.0.5', 'abfd098532429c9122afe25b989529fc890f489d0a49935888b000a44fbc9c8c', 221450, 113382400, 's3://connecthub-tenant-acme/coda/snapshots/abfd09853242.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #156: Miro Visual Collaboration
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000156', 'miro', 'Miro Visual Collaboration', 'Project Management', 'api', '["OAuth 2.0 Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000156', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000156', 'Miro Visual Collaboration', 'catalogued', 'OAuth 2.0 Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000156', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000156', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:miro')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000156', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000156', 'v1.1.12', '2592e14a6b3f0b9942cf9234ceba94fec87a7f125069cb398cf706f6048171e4', 222870, 114109440, 's3://connecthub-tenant-acme/miro/snapshots/2592e14a6b3f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #157: Figma Design & Tokens
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000157', 'figma', 'Figma Design & Tokens', 'Project Management', 'mcp', '["Personal Access Token, OAuth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000157', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000157', 'Figma Design & Tokens', 'catalogued', 'Personal Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000157', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000157', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:figma')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000157', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000157', 'v1.2.19', '09e1e80afc8d56d289237a7edef158bbe5861b15896dc327cc882284cba624e1', 224290, 114836480, 's3://connecthub-tenant-acme/figma/snapshots/09e1e80afc8d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #158: Obsidian Local Vault
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000158', 'obsidian', 'Obsidian Local Vault', 'Project Management', 'mcp', '["Local Vault REST API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000158', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000158', 'Obsidian Local Vault', 'catalogued', 'Local Vault REST API Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000158', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000158', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:obsidian')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000158', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000158', 'v1.3.6', '90846d0728d89227c377156e5befe48ad48c5c4945af2fd0c283dd788ee87fc6', 225710, 115563520, 's3://connecthub-tenant-acme/obsidian/snapshots/90846d0728d8.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #159: Salesforce CRM & Cloud
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000159', 'salesforce', 'Salesforce CRM & Cloud', 'CRM & Sales', 'api', '["OAuth 2.0 Connected App, JWT Flow"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000159', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000159', 'Salesforce CRM & Cloud', 'catalogued', 'OAuth 2.0 Connected App', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000159', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000159', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:salesforce')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000159', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000159', 'v1.4.13', '5aacf7447912ff73d411381b23bab383f908b5cbda81cd22d53c6cdfe3c8a8d8', 227130, 116290560, 's3://connecthub-tenant-acme/salesforce/snapshots/5aacf7447912.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #160: HubSpot Growth Platform
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000160', 'hubspot', 'HubSpot Growth Platform', 'CRM & Sales', 'mcp', '["OAuth 2.0, Private App Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000160', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000160', 'HubSpot Growth Platform', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000160', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000160', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:hubspot')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000160', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000160', 'v1.0.0', '9fdc0c7c5a7b8b15a056e206ede0b58a4ed736135ba1ee881c219ea91a9a34d5', 228550, 117017600, 's3://connecthub-tenant-acme/hubspot/snapshots/9fdc0c7c5a7b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #161: Pipedrive CRM
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000161', 'pipedrive', 'Pipedrive CRM', 'CRM & Sales', 'api', '["OAuth 2.0, API Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000161', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000161', 'Pipedrive CRM', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000161', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000161', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:pipedrive')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000161', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000161', 'v1.1.7', '5bf8d6a50037acc750280d60894e8d7c9458426d3fd1ca280c8b4c1a751a4870', 229970, 117744640, 's3://connecthub-tenant-acme/pipedrive/snapshots/5bf8d6a50037.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #162: Zoho CRM
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000162', 'zoho_crm', 'Zoho CRM', 'CRM & Sales', 'api', '["OAuth 2.0 Server-Based"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000162', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000162', 'Zoho CRM', 'catalogued', 'OAuth 2.0 Server-Based', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000162', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000162', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:zoho_crm')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000162', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000162', 'v1.2.14', '4799dba59e1dd6de178e9cf1867b7e191f054beb70b3c5e903d2054303de1ed7', 231390, 118471680, 's3://connecthub-tenant-acme/zoho_crm/snapshots/4799dba59e1d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #163: Close CRM
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000163', 'close_crm', 'Close CRM', 'CRM & Sales', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000163', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000163', 'Close CRM', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000163', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000163', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:close_crm')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000163', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000163', 'v1.3.1', '25a6c1f71e9f56ddb584f60ac241a8e07a2ca9f5b16b48bfd661470baeaaa8e1', 232810, 119198720, 's3://connecthub-tenant-acme/close_crm/snapshots/25a6c1f71e9f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #164: Mailchimp Marketing
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000164', 'mailchimp', 'Mailchimp Marketing', 'CRM & Sales', 'api', '["API Key, Server Prefix"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000164', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000164', 'Mailchimp Marketing', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000164', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000164', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:mailchimp')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000164', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000164', 'v1.4.8', 'd5d46771d796eea72067060346cd54ea5ccd71093e68cb6426befd5275031df3', 234230, 119925760, 's3://connecthub-tenant-acme/mailchimp/snapshots/d5d46771d796.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #165: Klaviyo Ecommerce Marketing
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000165', 'klaviyo', 'Klaviyo Ecommerce Marketing', 'CRM & Sales', 'api', '["Private API Key (pk_...)"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000165', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000165', 'Klaviyo Ecommerce Marketing', 'catalogued', 'Private API Key (pk_...)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000165', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000165', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:klaviyo')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000165', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000165', 'v1.0.15', 'eeaeeb0b7486a093bfedc92a67252197d51b4f1d952ad9de463c35fc65c25948', 235650, 120652800, 's3://connecthub-tenant-acme/klaviyo/snapshots/eeaeeb0b7486.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #166: ActiveCampaign
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000166', 'activecampaign', 'ActiveCampaign', 'CRM & Sales', 'api', '["API URL, API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000166', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000166', 'ActiveCampaign', 'catalogued', 'API URL', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000166', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000166', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:activecampaign')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000166', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000166', 'v1.1.2', '29699d1d5a6334fd6615254974df0101bea52605b91154960e9bba180a2d3cbe', 237070, 121379840, 's3://connecthub-tenant-acme/activecampaign/snapshots/29699d1d5a63.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #167: Customer.io Journeys
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000167', 'customer_io', 'Customer.io Journeys', 'CRM & Sales', 'api', '["Site ID, API Key, App API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000167', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000167', 'Customer.io Journeys', 'catalogued', 'Site ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000167', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000167', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:customer_io')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000167', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000167', 'v1.2.9', '66e42857287d02060343d2df740287ab8d4b1ca8b82a2575236a523916c1f0fc', 238490, 122106880, 's3://connecthub-tenant-acme/customer_io/snapshots/66e42857287d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #168: Intercom Engage & CRM
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000168', 'intercom_crm', 'Intercom Engage & CRM', 'CRM & Sales', 'mcp', '["OAuth 2.0, Extended Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000168', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000168', 'Intercom Engage & CRM', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000168', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000168', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:intercom_crm')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000168', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000168', 'v1.3.16', 'b978d1ef405bc998566f1df3d48e21f529f929551978a1df857924f98a4ae6c2', 239910, 122833920, 's3://connecthub-tenant-acme/intercom_crm/snapshots/b978d1ef405b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #169: Braze Customer Engagement
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000169', 'braze', 'Braze Customer Engagement', 'CRM & Sales', 'api', '["Rest API Key, REST Endpoint"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000169', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000169', 'Braze Customer Engagement', 'catalogued', 'Rest API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000169', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000169', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:braze')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000169', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000169', 'v1.4.3', 'ddf4e91b2df2a4e56a3797bcabfca446f3283a432049d6b622b05348c69ba6b7', 241330, 123560960, 's3://connecthub-tenant-acme/braze/snapshots/ddf4e91b2df2.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #170: Apollo.io B2B Lead Intel
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000170', 'apollo_io', 'Apollo.io B2B Lead Intel', 'CRM & Sales', 'api', '["Master API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000170', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000170', 'Apollo.io B2B Lead Intel', 'catalogued', 'Master API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000170', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000170', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:apollo_io')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000170', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000170', 'v1.0.10', 'a68ff7368ec1dd68bcc3ba0f338d1df74cd859b33f17fae40013f7def1c382d5', 242750, 124288000, 's3://connecthub-tenant-acme/apollo_io/snapshots/a68ff7368ec1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #171: ZoomInfo Enterprise
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000171', 'zoominfo', 'ZoomInfo Enterprise', 'CRM & Sales', 'api', '["Client ID, Private Key PKI"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000171', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000171', 'ZoomInfo Enterprise', 'catalogued', 'Client ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000171', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000171', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:zoominfo')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000171', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000171', 'v1.1.17', '89f481bad2b9750959abdf5788936049fd5165f61a6ff95ca0097b5005bb3aec', 244170, 125015040, 's3://connecthub-tenant-acme/zoominfo/snapshots/89f481bad2b9.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #172: Lemlist Cold Outreach
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000172', 'lemlist', 'Lemlist Cold Outreach', 'CRM & Sales', 'api', '["API Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000172', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000172', 'Lemlist Cold Outreach', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000172', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000172', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:lemlist')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000172', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000172', 'v1.2.4', '91b60995a7ca50f1d4317c41cff5cf5a45ecbec4d4e2ce7b0efb5c6b40d37868', 245590, 125742080, 's3://connecthub-tenant-acme/lemlist/snapshots/91b60995a7ca.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #173: Zendesk Support
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000173', 'zendesk_support', 'Zendesk Support', 'Customer Support', 'mcp', '["OAuth 2.0, API Token + Email"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000173', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000173', 'Zendesk Support', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000173', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000173', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:zendesk_support')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000173', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000173', 'v1.3.11', 'c3ff1eb01694569d2e42c1c06459d110aee86e570080164055068c4b7e8bc461', 247010, 126469120, 's3://connecthub-tenant-acme/zendesk_support/snapshots/c3ff1eb01694.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #174: Freshdesk Omnichannel
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000174', 'freshdesk', 'Freshdesk Omnichannel', 'Customer Support', 'api', '["API Key, Domain"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000174', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000174', 'Freshdesk Omnichannel', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000174', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000174', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:freshdesk')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000174', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000174', 'v1.4.18', '0c8f109a2edefd3be525acd35dd40e59d0ebbb244237fb0d9c7c1c1b09aa8af2', 248430, 127196160, 's3://connecthub-tenant-acme/freshdesk/snapshots/0c8f109a2ede.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #175: Help Scout Helpdesk
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000175', 'helpscout', 'Help Scout Helpdesk', 'Customer Support', 'api', '["OAuth 2.0 App Credentials"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000175', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000175', 'Help Scout Helpdesk', 'catalogued', 'OAuth 2.0 App Credentials', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000175', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000175', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:helpscout')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000175', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000175', 'v1.0.5', 'a35134c60295a53ce999efacc8b1596afc2942101f7f1459843ac94281f0bb9a', 249850, 127923200, 's3://connecthub-tenant-acme/helpscout/snapshots/a35134c60295.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #176: Front Shared Inbox
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000176', 'front_app', 'Front Shared Inbox', 'Customer Support', 'api', '["API Token (JWT)"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000176', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000176', 'Front Shared Inbox', 'catalogued', 'API Token (JWT)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000176', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000176', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:front_app')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000176', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000176', 'v1.1.12', 'b1e393d1b79d9678cb066c2ae5f42f5d7869695e6d93304cb609ae9600ca6d34', 1270, 650240, 's3://connecthub-tenant-acme/front_app/snapshots/b1e393d1b79d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #177: Gorgias Ecommerce Support
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000177', 'gorgias', 'Gorgias Ecommerce Support', 'Customer Support', 'api', '["Base API Key, Username"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000177', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000177', 'Gorgias Ecommerce Support', 'catalogued', 'Base API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000177', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000177', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:gorgias')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000177', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000177', 'v1.2.19', '467bcfde320def12193537787c3d8daae14a1cd4d095d03543ad47251b6f05a5', 2690, 1377280, 's3://connecthub-tenant-acme/gorgias/snapshots/467bcfde320d.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #178: Kustomer Platform
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000178', 'kustomer', 'Kustomer Platform', 'Customer Support', 'api', '["API Key with Roles"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000178', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000178', 'Kustomer Platform', 'catalogued', 'API Key with Roles', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000178', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000178', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:kustomer')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000178', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000178', 'v1.3.6', '451d8c8694ce1cd49be5314425d3839b8539a8008b37a0a014bd9d40d90b08fc', 4110, 2104320, 's3://connecthub-tenant-acme/kustomer/snapshots/451d8c8694ce.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #179: ServiceNow Enterprise ITSM
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000179', 'servicenow', 'ServiceNow Enterprise ITSM', 'Customer Support', 'api', '["OAuth 2.0, Basic Auth"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000179', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000179', 'ServiceNow Enterprise ITSM', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000179', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000179', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:servicenow')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000179', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000179', 'v1.4.13', 'b286c1e5d69f502ab46172a2b83c0b586e28514bc72df518a068e86594479e95', 5530, 2831360, 's3://connecthub-tenant-acme/servicenow/snapshots/b286c1e5d69f.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #180: PagerDuty Incident Response
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000180', 'pagerduty', 'PagerDuty Incident Response', 'Customer Support', 'mcp', '["REST API Key, Events API v2 Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000180', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000180', 'PagerDuty Incident Response', 'catalogued', 'REST API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000180', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000180', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:pagerduty')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000180', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000180', 'v1.0.0', 'f3749f674e842d791b548fa189ada84ef353bd1e243bdfed7bc23710909f30a6', 6950, 3558400, 's3://connecthub-tenant-acme/pagerduty/snapshots/f3749f674e84.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #181: Opsgenie Alerting
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000181', 'opsgenie', 'Opsgenie Alerting', 'Customer Support', 'api', '["GenieKey (API Key)"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000181', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000181', 'Opsgenie Alerting', 'catalogued', 'GenieKey (API Key)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000181', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000181', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:opsgenie')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000181', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000181', 'v1.1.7', '52bc9794c3f00218522288fc2c8ac2c614b3b64de194457457a2c12f9157d9f6', 8370, 4285440, 's3://connecthub-tenant-acme/opsgenie/snapshots/52bc9794c3f0.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #182: Stripe Payments & Billing
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000182', 'stripe', 'Stripe Payments & Billing', 'E-Commerce & Fintech', 'mcp', '["Restricted API Key (rk_...), Webhook Secret"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000182', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000182', 'Stripe Payments & Billing', 'catalogued', 'Restricted API Key (rk_...)', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000182', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000182', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:stripe')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000182', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000182', 'v1.2.14', '0978ec7c82ab37cd5cc504f3e32f8f1009a809ec7018fe8d953a090aa9676e90', 9790, 5012480, 's3://connecthub-tenant-acme/stripe/snapshots/0978ec7c82ab.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #183: PayPal Developer
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000183', 'paypal', 'PayPal Developer', 'E-Commerce & Fintech', 'api', '["Client ID, Secret Key, Environment"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000183', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000183', 'PayPal Developer', 'catalogued', 'Client ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000183', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000183', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:paypal')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000183', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000183', 'v1.3.1', '94c0f013ec0e9e6ed2b93821a8d203a48d4d280c6cdf78f911360c4a3e0e3b70', 11210, 5739520, 's3://connecthub-tenant-acme/paypal/snapshots/94c0f013ec0e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #184: Shopify Plus / Store
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000184', 'shopify', 'Shopify Plus / Store', 'E-Commerce & Fintech', 'mcp', '["Admin API Access Token, Store Domain"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000184', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000184', 'Shopify Plus / Store', 'catalogued', 'Admin API Access Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000184', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000184', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:shopify')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000184', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000184', 'v1.4.8', '20723fd2d33e9db75dccedf8369b74264a28c70516607ebd7e2c8a16d1c25f83', 12630, 6466560, 's3://connecthub-tenant-acme/shopify/snapshots/20723fd2d33e.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #185: WooCommerce WordPress
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000185', 'woocommerce', 'WooCommerce WordPress', 'E-Commerce & Fintech', 'api', '["Consumer Key, Consumer Secret"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000185', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000185', 'WooCommerce WordPress', 'catalogued', 'Consumer Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000185', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000185', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:woocommerce')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000185', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000185', 'v1.0.15', '86e00a600e0350d0eb64dfe8f6833a4b72e768c57d7b69a73d7e73fa18b4efb3', 14050, 7193600, 's3://connecthub-tenant-acme/woocommerce/snapshots/86e00a600e03.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #186: BigCommerce
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000186', 'bigcommerce', 'BigCommerce', 'E-Commerce & Fintech', 'api', '["Store Hash, Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000186', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000186', 'BigCommerce', 'catalogued', 'Store Hash', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000186', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000186', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:bigcommerce')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000186', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000186', 'v1.1.2', '1863618c369b56e1c766ce28ed3710ed98c65b22b68f4d95b32885f95e99ef10', 15470, 7920640, 's3://connecthub-tenant-acme/bigcommerce/snapshots/1863618c369b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #187: Square POS & Ecommerce
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000187', 'square', 'Square POS & Ecommerce', 'E-Commerce & Fintech', 'api', '["OAuth 2.0, Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000187', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000187', 'Square POS & Ecommerce', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000187', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000187', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:square')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000187', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000187', 'v1.2.9', '11a18a772af67529acd4b2423958e431a7b64965f214e82937856f693f9d22d7', 16890, 8647680, 's3://connecthub-tenant-acme/square/snapshots/11a18a772af6.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #188: Paddle Billing
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000188', 'paddle', 'Paddle Billing', 'E-Commerce & Fintech', 'api', '["API Key, Vendor ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000188', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000188', 'Paddle Billing', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000188', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000188', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:paddle')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000188', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000188', 'v1.3.16', '6430d58128cf3dbf39d92d1b29c6b4573c1020a27fb72d9588e5bda150f68eab', 18310, 9374720, 's3://connecthub-tenant-acme/paddle/snapshots/6430d58128cf.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #189: Adyen Global Payments
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000189', 'adyen', 'Adyen Global Payments', 'E-Commerce & Fintech', 'api', '["API Key, Merchant Account"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000189', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000189', 'Adyen Global Payments', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000189', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000189', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:adyen')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000189', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000189', 'v1.4.3', 'caad0c359835fbdd095d90368644959c668e125075e84dc00e038558641e0b49', 19730, 10101760, 's3://connecthub-tenant-acme/adyen/snapshots/caad0c359835.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #190: Lemon Squeezy Merchant
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000190', 'lemon_squeezy', 'Lemon Squeezy Merchant', 'E-Commerce & Fintech', 'api', '["API Key, Store ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000190', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000190', 'Lemon Squeezy Merchant', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000190', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000190', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:lemon_squeezy')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000190', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000190', 'v1.0.10', 'b54069dea4f142f2c8251690033185dd4fa8761b584d73be589938b6c5b42ae4', 21150, 10828800, 's3://connecthub-tenant-acme/lemon_squeezy/snapshots/b54069dea4f1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #191: Chargebee Subscription
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000191', 'chargebee', 'Chargebee Subscription', 'E-Commerce & Fintech', 'api', '["API Key, Site Name"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000191', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000191', 'Chargebee Subscription', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000191', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000191', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:chargebee')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000191', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000191', 'v1.1.17', '6086ca552297316f3a336b01e08a08ded8b1837e5a60430eda3c5b62ec16b53f', 22570, 11555840, 's3://connecthub-tenant-acme/chargebee/snapshots/6086ca552297.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #192: Plaid Financial Data
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000192', 'plaid', 'Plaid Financial Data', 'E-Commerce & Fintech', 'api', '["Client ID, Secret, Environment"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000192', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000192', 'Plaid Financial Data', 'catalogued', 'Client ID', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000192', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000192', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:plaid')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000192', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000192', 'v1.2.4', 'e0539020af404ceb4fd6d6e2b09d94ea67435cfce97ec6f2e63ecbd22470a649', 23990, 12282880, 's3://connecthub-tenant-acme/plaid/snapshots/e0539020af40.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #193: QuickBooks Online (Intuit)
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000193', 'quickbooks', 'QuickBooks Online (Intuit)', 'Finance & HR', 'api', '["OAuth 2.0 Refresh Token, Realm ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000193', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000193', 'QuickBooks Online (Intuit)', 'catalogued', 'OAuth 2.0 Refresh Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000193', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000193', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:quickbooks')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000193', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000193', 'v1.3.11', 'ec17061431e3b29912ec4288750cf0d88325461250d6ee3096da3f69318fa5ba', 25410, 13009920, 's3://connecthub-tenant-acme/quickbooks/snapshots/ec17061431e3.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #194: Xero Accounting
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000194', 'xero', 'Xero Accounting', 'Finance & HR', 'api', '["OAuth 2.0 PKCE, Tenant ID"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000194', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000194', 'Xero Accounting', 'catalogued', 'OAuth 2.0 PKCE', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000194', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000194', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:xero')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000194', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000194', 'v1.4.18', 'e7287bc7782459936a13cfecef0aa9ef658fbd033be3c211c520d5d0f621b3b6', 26830, 13736960, 's3://connecthub-tenant-acme/xero/snapshots/e7287bc77824.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #195: Google Sheets
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000195', 'google_sheets', 'Google Sheets', 'Spreadsheet & Docs', 'mcp', '["Google OAuth 2.0, Service Account"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000195', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000195', 'Google Sheets', 'catalogued', 'Google OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000195', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000195', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:google_sheets')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000195', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000195', 'v1.0.5', '8d7fc75637931d17196761178fc88eec83045285d18cc4238a98cfb34018df30', 28250, 14464000, 's3://connecthub-tenant-acme/google_sheets/snapshots/8d7fc7563793.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #196: Airtable Connected Apps
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000196', 'airtable', 'Airtable Connected Apps', 'Spreadsheet & Docs', 'mcp', '["OAuth 2.0, Personal Access Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000196', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000196', 'Airtable Connected Apps', 'catalogued', 'OAuth 2.0', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000196', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000196', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:airtable')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000196', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000196', 'v1.1.12', '2ecb7080241414b897a015c5bbe9ad8d70a73f27afe87eb12e8e2eb3b26ee130', 29670, 15191040, 's3://connecthub-tenant-acme/airtable/snapshots/2ecb70802414.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #197: DocuSign eSignature
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000197', 'docusign', 'DocuSign eSignature', 'Finance & HR', 'api', '["JWT Grant RSA Keypair, Integration Key"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000197', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000197', 'DocuSign eSignature', 'catalogued', 'JWT Grant RSA Keypair', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000197', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000197', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:docusign')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000197', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000197', 'v1.2.19', '5930d76281f12693e6ce6ebcdacd0f2f1c2534d8228ad7aca1f575769614204c', 31090, 15918080, 's3://connecthub-tenant-acme/docusign/snapshots/5930d76281f1.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #198: BambooHR Human Resources
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000198', 'bamboohr', 'BambooHR Human Resources', 'Finance & HR', 'api', '["API Key, Subdomain"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000198', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000198', 'BambooHR Human Resources', 'catalogued', 'API Key', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000198', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000198', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:bamboohr')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000198', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000198', 'v1.3.6', '81a910c26e1b73436dfc4691c386ee59df4c043d9e4f21e5ca4f60a120ebb2cb', 32510, 16645120, 's3://connecthub-tenant-acme/bamboohr/snapshots/81a910c26e1b.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #199: Gusto Payroll & HR
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000199', 'gusto', 'Gusto Payroll & HR', 'Finance & HR', 'api', '["OAuth 2.0 Refresh Token"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000199', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000199', 'Gusto Payroll & HR', 'catalogued', 'OAuth 2.0 Refresh Token', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000199', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000199', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:gusto')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000199', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000199', 'v1.4.13', '6a353677f4207139f43cf482b306a1de6356fbdaa588f5add1b36baf936f352b', 33930, 17372160, 's3://connecthub-tenant-acme/gusto/snapshots/6a353677f420.parquet')
ON CONFLICT (id) DO NOTHING;


-- Connector #200: Auth0 Identity & Security
INSERT INTO connector_catalog (id, key, display_name, category, integration_type, auth_methods, is_enabled)
VALUES ('c0000000-0000-0000-0000-000000000200', 'auth0_identity', 'Auth0 Identity & Security', 'Security & Identity', 'mcp', '["OAuth 2.0 Device Flow, Client Credentials"]'::jsonb, true)
ON CONFLICT (key) DO UPDATE SET display_name = EXCLUDED.display_name;

INSERT INTO connector_installations (id, tenant_id, connector_id, display_name, status, auth_method, last_tested_at)
VALUES ('i0000000-0000-0000-0000-000000000200', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000200', 'Auth0 Identity & Security', 'catalogued', 'OAuth 2.0 Device Flow', now())
ON CONFLICT (tenant_id, id) DO UPDATE SET status = 'catalogued';

INSERT INTO connector_secret_refs (id, tenant_id, installation_id, secret_provider, secret_ref)
VALUES ('s0000000-0000-0000-0000-000000000200', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000200', 'aws_secrets_manager', 'arn:aws:secretsmanager:eu-central-1:tenant-acme:secret:auth0_identity')
ON CONFLICT (installation_id, secret_ref) DO NOTHING;

INSERT INTO data_versions (id, tenant_id, installation_id, version_tag, commit_hash, records_count, size_bytes, storage_location)
VALUES ('v0000000-0000-0000-0000-000000000200', 'a0000000-0000-0000-0000-000000000001', 'i0000000-0000-0000-0000-000000000200', 'v1.0.0', '9992a609d59776960e0a8fa37d6b308c90e6963bb412e4b62fd1a1584ad11b88', 35350, 18099200, 's3://connecthub-tenant-acme/auth0_identity/snapshots/9992a609d597.parquet')
ON CONFLICT (id) DO NOTHING;

COMMIT;
-- Mark confirmed operational connectors as verified
UPDATE connector_installations 
SET status = 'verified' 
WHERE display_name IN ('GitHub', 'SQLite', 'DuckDB', 'Auth0', 'AWS S3', 'PostgreSQL');
COMMIT;
