---
title: "MCP Context7 Integration"
sidebar_position: 8
---

# MCP Context7 Integration

> On-demand library documentation via Context7 MCP

---

## Goal

Integrate Context7 MCP to fetch, cache, and manage library documentation for development tasks.

---

## Skill: `/dev-docs-fetch`

- **Name**: `dev-docs-fetch` (role=dev, domain=docs, action=fetch)
- **Directory**: `skills/dev-docs-fetch/`
- **MCP Required**: Context7 (`mcp__context7__resolve-library-id`, `mcp__context7__get-library-docs`)
- **Input**: `[library-names...]` or auto-detect from `$JAAN_CONTEXT_DIR/tech.md`
- **Output**: Cached docs in `$JAAN_OUTPUTS_DIR/dev/docs/context7/`

---

## Capabilities

| Feature | Description |
|---------|-------------|
| Resolve library IDs | `mcp__context7__resolve-library-id` |
| Fetch documentation | `mcp__context7__get-library-docs` (mode: code/info) |
| Smart caching | 7-day TTL, Bash-based freshness check |
| Auto-detection | Read `$JAAN_CONTEXT_DIR/tech.md` for stack-aware library resolution |
| Fallback handling | Use stale cache on API errors, retry with backoff |
| Topic extraction | Extract specific topic from task description (e.g., "middleware", "streaming") |

---

## Subtasks

- [x] Add Context7 MCP server to Claude settings (`.mcp.json`)
- [x] Create `/dev-docs-fetch` skill (`skills/dev-docs-fetch/SKILL.md`)
  - YAML frontmatter with `allowed-tools`: Bash, Context7 MCP tools, Write, Read
  - `argument-hint: [library-names...]`
  - Pre-execution protocol integration
  - Two-phase workflow with HARD STOP
- [x] Implement tech-agnostic library detection
  - Read `$JAAN_CONTEXT_DIR/tech.md` for current stack (no hardcoded library tiers)
  - Parse arguments when provided directly
  - Auto-detect from conversation context as fallback
- [x] Implement cache freshness check (Bash-based)
  - Cache directory: `$JAAN_OUTPUTS_DIR/dev/docs/context7/`
  - 7-day TTL using file modification time
  - Cross-platform (macOS `stat -f %m` / Linux `stat -c %Y`)
- [x] Add graceful error handling
  - Library not found → suggest alternatives, offer retry/skip
  - API failure → fallback to stale cache
  - Network timeout → retry up to 3 times with backoff
  - Invalid response → skip and continue
- [x] YAML frontmatter for cached files
  - Fields: title, library_id, type, created, updated, context7_mode, topic, tags, source, cache_ttl
  - Preserve `created` date on re-fetch
- [x] Learning integration (`$JAAN_LEARN_DIR/dev-docs-fetch.learn.md`)

---

## Skill Workflow

```
Phase 0: Parse arguments + auto-detect from tech.md
Phase 1: Cache freshness check (fresh/stale/missing)
   ↓
HARD STOP — Confirm libraries to fetch
   ↓
Phase 2: Resolve library IDs via Context7 MCP
Phase 3: Fetch documentation (code/info mode)
Phase 4: Store with YAML frontmatter + summary report
```

---

## v3.0.0 Adaptation Notes

| Aspect | Design Decision |
|--------|----------------|
| **Tech-agnostic** | No hardcoded library tiers — read `$JAAN_CONTEXT_DIR/tech.md` for stack detection instead |
| **Env vars** | All paths use `$JAAN_*` variables (`$JAAN_OUTPUTS_DIR`, `$JAAN_CONTEXT_DIR`, `$JAAN_LEARN_DIR`) |
| **Cache path** | `$JAAN_OUTPUTS_DIR/dev/docs/context7/` (follows output structure convention) |
| **Learning** | `$JAAN_LEARN_DIR/dev-docs-fetch.learn.md` with merge strategy |
| **Multi-runtime** | Skill definition is runtime-agnostic (canonical in `skills/`) |

---

## File Structure

```
$JAAN_OUTPUTS_DIR/dev/docs/context7/
├── fastapi.md
├── react.md
├── sqlalchemy.md
└── ...
```

Each file includes YAML frontmatter:
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

## Integration Points

- **Standalone:** `/dev-docs-fetch fastapi openai`
- **Auto-integrated:** Can be called from other dev skills in Phase 1
- **Silent mode:** Cache hits don't produce output

---

## Token Budget

Target: <10,000 tokens per execution

- Check cache with Bash (no file reads for fresh cache)
- Fetch only stale/missing libraries
- Max 3-5 libraries per run
- Concise reporting (no verbose logs)

---

## References

- [Context7 MCP documentation](https://context7.com)
- Reference implementation: `Jaan.Coach/.claude/commands/fetch-tech-docs.md`
- [Skill creation spec](../../extending/create-skill.md)
- [Naming conventions](../../extending/naming-conventions.md)
