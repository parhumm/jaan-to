---
title: "dev-docs-fetch"
sidebar_position: 6
doc_type: skill
created_date: 2026-02-22
updated_date: 2026-02-22
tags: [dev, docs, context7, mcp, cache, library-docs, tech-agnostic]
related: [dev-verify, backend-scaffold, frontend-scaffold, dev-project-assemble]
---

# /jaan-to:dev-docs-fetch

> Fetch and cache library documentation via Context7 MCP with auto-detect and smart caching.

---

## Overview

Fetches real, up-to-date library documentation from Context7 MCP and caches it locally with a 7-day TTL. Tech-agnostic: reads `$JAAN_CONTEXT_DIR/tech.md` for stack detection or accepts explicit library names as arguments. Callable standalone or from other skills' Phase 1 for context enrichment.

This is the first MCP-powered skill in jaan-to (Phase 7).

---

## Prerequisites

- Context7 MCP server configured in `.mcp.json` (included with jaan-to v7.4.0+)
- Project initialized with `/jaan-to:jaan-init`
- `npx` available in PATH (for MCP server installation)

---

## Usage

```
/jaan-to:dev-docs-fetch fastapi openai react
/jaan-to:dev-docs-fetch
```

| Input | Behavior |
|-------|----------|
| Library names as arguments | Fetch docs for specified libraries |
| No arguments (with `tech.md`) | Auto-detect libraries from `$JAAN_CONTEXT_DIR/tech.md` |
| No arguments (without `tech.md`) | Ask user which libraries to fetch |

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/dev/docs/context7/`:

| File | Content |
|------|---------|
| `{library-name}.md` | Cached library documentation with YAML frontmatter |

Each file includes metadata:

```yaml
---
title: FastAPI Documentation
library_id: /tiangolo/fastapi
type: context7-reference
created: 2026-02-22
updated: 2026-02-22
context7_mode: code
topic: null
tags: [context7, fastapi, technical-reference]
source: Context7 MCP
cache_ttl: 7 days
---
```

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Which libraries to fetch | No arguments and no tech.md | Need user input for library list |
| Specific topics within libraries | Optional | More focused documentation (e.g., "middleware") |
| Code or info mode | Optional | API references vs architecture concepts |
| Confirm fetch plan | HARD STOP after cache check | User approves which libraries to fetch/skip |
| Use stale cache on API failure | When API fails and stale cache exists | Fallback to outdated docs vs no docs |

---

## Two-Phase Workflow

### Phase 1 — Analysis (Read-Only)

1. Parses arguments or auto-detects from `$JAAN_CONTEXT_DIR/tech.md` (`#current-stack`, `#frameworks`)
2. Checks cache freshness for each library using Bash-based `stat`/`find` (cross-platform macOS/Linux)
3. Reports cache status per library: FRESH (skip), STALE (re-fetch), MISSING (fetch)
4. Presents fetch plan at **HARD STOP** for approval

### Phase 2 — Fetch & Store

1. Resolves library IDs via `mcp__context7__resolve-library-id`
2. Fetches documentation via `mcp__context7__get-library-docs` (code/info mode, optional topic)
3. Stores each library doc with YAML frontmatter at `$JAAN_OUTPUTS_DIR/dev/docs/context7/{library-name}.md`
4. Preserves `created` date on re-fetch (only updates `updated`)
5. Reports summary: fetched count, skipped (fresh), errors

---

## Error Handling

| Error | Behavior |
|-------|----------|
| Library not found | Offer alternative names, retry or skip |
| API failure | Fallback to stale cache with user consent |
| Network timeout | Retry up to 3 times with backoff |
| Invalid response | Skip and continue with remaining libraries |

---

## Workflow Chain

```
$JAAN_CONTEXT_DIR/tech.md (auto-detect)
  |
  v
/jaan-to:dev-docs-fetch  (fetch + cache)
  |
  v
/jaan-to:backend-scaffold, /jaan-to:frontend-scaffold, etc.
```

---

## Example

**Input:**
```
/jaan-to:dev-docs-fetch fastapi sqlalchemy
```

**Output:**
```
Cache Status:
  fastapi     — MISSING → will fetch
  sqlalchemy  — FRESH (2 days old) → skip

Fetching 1 library...

  fastapi: Resolved → /tiangolo/fastapi
  fastapi: Fetched (code mode, 4,200 tokens)

Summary: 1 fetched, 1 skipped (fresh), 0 errors
Cache: jaan-to/outputs/dev/docs/context7/
```

---

## Tips

- Keep requests to 3-5 libraries per run (token budget: <10,000 tokens)
- Use specific topics for more relevant docs (e.g., "fastapi middleware" instead of all of FastAPI)
- Run before scaffold skills to enrich their context
- Fresh cache is free — the skill skips cached libraries without any MCP calls
- Cached docs are regular markdown files — read them anytime with any tool

---

## Related Skills

- [/jaan-to:dev-verify](verify.md) - Validate build pipeline and services
- [/jaan-to:dev-project-assemble](project-assemble.md) - Wire scaffolds into runnable project
- [/jaan-to:backend-scaffold](../backend/scaffold.md) - Generate backend code
- [/jaan-to:frontend-scaffold](../frontend/scaffold.md) - Generate frontend components

---

## Technical Details

- **Logical Name**: dev-docs-fetch
- **Command**: `/jaan-to:dev-docs-fetch`
- **Role**: dev
- **Output**: `$JAAN_OUTPUTS_DIR/dev/docs/context7/`
- **MCP Required**: Context7 (`resolve-library-id`, `get-library-docs`)
- **Token Budget**: <10,000 tokens per execution
