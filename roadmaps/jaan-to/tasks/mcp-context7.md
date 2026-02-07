# MCP Context7 Integration

> On-demand library documentation via Context7 MCP

---

## Goal

Integrate Context7 MCP to fetch, cache, and manage library documentation for development tasks.

---

## Capabilities

| Feature | Description |
|---------|-------------|
| Resolve library IDs | `mcp__context7__resolve-library-id` |
| Fetch documentation | `mcp__context7__get-library-docs` |
| Smart caching | 7-day TTL in `docs/references/context7/` |
| Auto-detection | Extract libraries from task descriptions |
| Fallback handling | Use stale cache on API errors |

---

## Subtasks

- [ ] Add Context7 MCP server to Claude settings
- [ ] Create `/jaan-to:dev-fetch-tech-docs` skill
  - Parse library arguments
  - Auto-detect from task context
- [ ] Build library keyword mapping table
  - Tier 1: fastapi, openai, sqlalchemy, pydantic, postgresql
  - Tier 2: python-telegram-bot, python-jose, alembic, uvicorn
  - Tier 3: pytest, pytest-asyncio, pyyaml, sentry, httpx
- [ ] Implement cache freshness check (Bash-based)
- [ ] Add graceful error handling
  - Library not found → suggest alternatives
  - API failure → fallback to stale cache
  - Network timeout → retry with backoff

---

## File Structure

```
docs/references/context7/
├── fastapi.md
├── openai.md
├── sqlalchemy.md
└── ...
```

Each file includes YAML frontmatter:
```yaml
---
title: FastAPI Documentation
library_id: /tiangolo/fastapi
type: context7-reference
created: 2025-01-20
updated: 2025-01-25
context7_mode: code
cache_ttl: 7 days
---
```

---

## Integration Points

- **Standalone:** `/jaan-to:dev-fetch-tech-docs fastapi openai`
- **Auto-integrated:** Called from `/dev-app` Phase 1.1
- **Silent mode:** Cache hits don't produce output

---

## Token Budget

Target: <10,000 tokens per execution

- Check cache with Bash (no file reads for fresh cache)
- Fetch only stale/missing libraries
- Max 3-5 libraries per run

---

## References

- Context7 MCP documentation
- Existing skill: `/jaan-to:dev-fetch-tech-docs` (from Jaan.Coach)
