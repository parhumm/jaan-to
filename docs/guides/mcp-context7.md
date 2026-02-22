---
title: "MCP & Context7 Integration"
sidebar_position: 2
doc_type: guide
created_date: 2026-02-22
updated_date: 2026-02-22
tags: [mcp, context7, configuration, library-docs, setup]
related: [customization]
---

# MCP & Context7 Integration

> On-demand library documentation for your development workflow.

---

## What is MCP?

MCP (Model Context Protocol) is a standard for connecting AI assistants to external data sources. jaan-to uses MCP connectors to provide real system context to skills — skills stay generic while MCP provides per-product data from actual tools.

Context7 is the first MCP connector shipped with jaan-to (Phase 7).

---

## What is Context7?

Context7 provides up-to-date library documentation via MCP. Instead of relying on training data (which may be outdated), skills can fetch current API references, code examples, and architecture guides directly from library documentation sources.

**Two MCP tools are available:**

| Tool | Purpose |
|------|---------|
| `resolve-library-id` | Convert a library name (e.g., "fastapi") to a Context7-compatible ID (e.g., "/tiangolo/fastapi") |
| `get-library-docs` | Fetch documentation for a resolved library ID with mode selection |

---

## Setup

Context7 MCP is pre-configured in jaan-to v7.4.0+. The configuration lives in `.mcp.json` at the plugin root:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

No additional setup is required. The server is installed and run automatically via `npx` when a skill needs it.

**Verify it works:** Run `/jaan-to:dev-docs-fetch react` — if Context7 resolves the library and returns documentation, the MCP connection is active.

---

## Using /jaan-to:dev-docs-fetch

The `dev-docs-fetch` skill is the primary way to interact with Context7.

### Basic Usage

```bash
# Fetch docs for specific libraries
/jaan-to:dev-docs-fetch fastapi openai react

# Auto-detect from your tech stack
/jaan-to:dev-docs-fetch

# The skill reads $JAAN_CONTEXT_DIR/tech.md to find your libraries
```

### What Happens

1. **Parse input** — Reads library names from arguments, or auto-detects from `tech.md`
2. **Check cache** — Looks for existing docs in `$JAAN_OUTPUTS_DIR/dev/docs/context7/`
3. **Report status** — Shows FRESH (skip), STALE (re-fetch), or MISSING (fetch) per library
4. **HARD STOP** — Asks for confirmation before fetching
5. **Fetch** — Resolves library IDs and fetches documentation via Context7 MCP
6. **Store** — Saves with YAML frontmatter for metadata tracking

### Fetch Modes

| Mode | Flag | Content |
|------|------|---------|
| `code` (default) | No flag needed | API references + code examples |
| `info` | Specify in prompt | Architecture, concepts, design patterns |

You can also request a specific topic (e.g., "middleware", "streaming") to get more focused documentation.

---

## Cache Management

### Location

Cached documentation is stored at:

```
$JAAN_OUTPUTS_DIR/dev/docs/context7/
├── fastapi.md
├── react.md
├── sqlalchemy.md
└── ...
```

### TTL

Cache entries have a **7-day TTL**. After 7 days, entries are marked STALE and will be re-fetched on the next run.

### Manual Refresh

To force a refresh of all cached docs, delete the cache directory and re-run:

```bash
rm -rf jaan-to/outputs/dev/docs/context7/
/jaan-to:dev-docs-fetch
```

### File Format

Each cached file includes YAML frontmatter:

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

{Documentation content}
```

---

## Integration with Other Skills

`dev-docs-fetch` is designed to work as a **context enrichment step** in other skills' workflows:

- **Standalone**: Run directly when you need library documentation
- **Phase 1 prep**: Other dev/backend/frontend skills can call it during their analysis phase
- **team-ship integration**: Backend and Frontend teammates run `dev-docs-fetch` as their first skill to cache library context before scaffolding

### Skills That Benefit

| Skill | How It Benefits |
|-------|----------------|
| `backend-scaffold` | Generates more accurate code with current API references |
| `frontend-scaffold` | Uses current component patterns and hooks |
| `backend-task-breakdown` | Plans tasks with awareness of library capabilities |
| `frontend-task-breakdown` | Breaks down work knowing available framework features |
| `dev-project-assemble` | Configures projects with current best practices |

---

## Troubleshooting

### MCP Server Not Starting

If you see errors about the Context7 MCP server:

1. Ensure `npx` is available in your PATH
2. Check network connectivity — the server is downloaded on first use
3. Try manually: `npx -y @upstash/context7-mcp@latest`

### Library Not Found

Context7 may not recognize all library names:

- Try the full package name (e.g., `@tanstack/react-query` instead of `react-query`)
- The skill offers retry with alternative names when a library is not found
- You can skip unavailable libraries and continue with the rest

### Network Errors

The skill retries up to 3 times with backoff on network failures. If all retries fail:

- Stale cache is offered as a fallback (if available)
- You can skip the failing library and continue

---

## Future MCP Connectors

Context7 is the first of 24 planned MCP connectors. See the [MCP Connectors roadmap](../roadmap/tasks/mcp-connectors.md) for the full list including GA4, GitLab, Jira, Figma, and more.

---

[Back to Guides](../guides/)
