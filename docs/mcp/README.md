---
title: "MCP Connectors"
sidebar_position: 1
---

# MCP Connectors

> Real system context for AI-powered skills.

---

## What is MCP?

MCP (Model Context Protocol) is a standard for connecting AI assistants to external data sources. jaan-to uses MCP connectors to provide real system context to skills — skills stay generic while MCP provides per-product data from actual tools.

Skills request context, MCP provides real data. No hallucinating file structures.

---

## Available Connectors

| Connector | Status | Skills Enabled | Skill |
|-----------|--------|----------------|-------|
| [Context7](context7.md) | Available | 1 | `dev-docs-fetch` |

---

## Planned Connectors (Phase 7)

24 MCP connectors are planned across 4 tiers:

| Tier | Connectors | Skills Enabled |
|------|-----------|----------------|
| **Tier 1** — High Impact | GA4, GitLab | 20+ |
| **Tier 2** — Medium Impact | Jira, Figma, GSC, Clarity | 5-6 each |
| **Tier 3** — Targeted | Sentry, BigQuery, Playwright | 2-4 each |
| **Tier 4** — Single Skill | OpenAPI/Swagger, dbt Cloud | 1 each |

Extended connectors include Notion, Slack, GitHub, Linear, Mixpanel, Confluence, and more.

See the full [MCP Connectors roadmap](../roadmap/tasks/mcp-connectors.md) for details.

---

## Dual-Runtime Setup

MCP connectors work on both Claude Code and Codex runtimes.

### Claude Code

MCP servers are configured in `.mcp.json` at the plugin root. This file is included with jaan-to and loaded automatically — no manual setup required.

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

### Codex

MCP servers are configured in `~/.codex/config.toml`. The jaan-to installer adds a managed block automatically during `install-codex-skillpack.sh`:

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@latest"]
```

**Manual alternative:**

```bash
codex mcp add context7 -- npx -y @upstash/context7-mcp@latest
```

To skip MCP configuration during install, use `--no-mcp`.

---

## How Skills Use MCP

Skills declare MCP tool dependencies in their `allowed-tools` frontmatter:

```yaml
allowed-tools: mcp__context7__resolve-library-id, mcp__context7__get-library-docs
```

The naming convention is `mcp__<server>__<tool>`, where `<server>` matches the key in `.mcp.json` or `config.toml`.

---

## Adding New Connectors

When a new MCP connector is added to jaan-to:

1. Add server config to `.mcp.json` (Claude Code)
2. Add matching TOML block to `update_codex_mcp_config()` in `scripts/install-codex-skillpack.sh` (Codex)
3. Reference MCP tools in skill `allowed-tools` using `mcp__<server>__<tool>`
4. Add connector documentation page to `docs/mcp/`
5. CI validates parity: `scripts/validate-mcp-servers.sh` checks both runtimes match

---

[Back to Documentation](../README.md)
