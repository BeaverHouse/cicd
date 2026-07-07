# OSS - Bifrost

Bifrost is the LLM gateway (routing, virtual keys, budgets, request logging).
It replaces LiteLLM; per-user governance is driven by llm-client via the
`x-bf-vk` header and the `/api/governance/*` admin API.

Operational notes:

- Inference calls require the `/v1` path — services use
  `LLM_GATEWAY_ENDPOINT=http://bifrost.bifrost.svc.cluster.local:8080/v1`.
- Config store and logs store both run on the existing Supabase Postgres
  (must be UTF8-encoded). No node-local state.
- `BIFROST_ENCRYPTION_KEY` is a new GitLab CI variable
  (`openssl rand -base64 32`); rotating it invalidates stored provider keys.
- Virtual keys / budgets are created lazily by llm-client, so no governance
  seeding is needed in values.
