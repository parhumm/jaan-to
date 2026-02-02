# Connect Claude Code to Tools via MCP

> Official guide for connecting Claude Code to external tools and data sources through the Model Context Protocol.
> Source: https://code.claude.com/docs/en/mcp.md
> Added: 2026-01-29

---

## Overview

MCP (Model Context Protocol) is an open source standard for AI-tool integrations. MCP servers give Claude Code access to tools, databases, and APIs.

### What You Can Do
- Implement features from issue trackers (JIRA, GitHub)
- Analyze monitoring data (Sentry, Statsig)
- Query databases (PostgreSQL, etc.)
- Integrate designs (Figma)
- Automate workflows (Gmail, Slack)

---

## Installing MCP Servers

### Option 1: HTTP (Recommended for Remote)
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### Option 2: SSE (Deprecated)
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

### Option 3: Stdio (Local)
```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

> All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the name from the command.

### Managing Servers
```bash
claude mcp list          # List all
claude mcp get github    # Details
claude mcp remove github # Remove
/mcp                     # Status (within Claude Code)
```

---

## Installation Scopes

| Scope | Storage | Who Sees It | Use Case |
|-------|---------|-------------|----------|
| **Local** (default) | `~/.claude.json` | You, this project | Personal dev servers, sensitive credentials |
| **Project** | `.mcp.json` in repo root | All collaborators | Team-shared tools (check into VCS) |
| **User** | `~/.claude.json` | You, all projects | Personal utilities across projects |

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

Precedence: local > project > user.

---

## Authentication

OAuth 2.0 supported for remote servers:
1. Add the server
2. Run `/mcp` within Claude Code
3. Follow browser login steps

---

## Environment Variable Expansion in .mcp.json

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

Supported: `${VAR}` and `${VAR:-default}` in command, args, env, url, headers.

---

## MCP Resources

Reference resources with `@` mentions:
```
> Can you analyze @github:issue://123 and suggest a fix?
> Compare @postgres:schema://users with @docs:file://database/user-model
```

---

## Tool Search

Automatically enabled when MCP tool descriptions exceed 10% of context window. Tools load on-demand instead of all upfront.

```bash
ENABLE_TOOL_SEARCH=auto:5 claude   # Custom 5% threshold
ENABLE_TOOL_SEARCH=false claude    # Disable
```

Requires Sonnet 4+ or Opus 4+.

---

## Plugin MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. Start automatically when plugin enabled.

---

## Managed MCP Configuration

### Option 1: Exclusive Control (`managed-mcp.json`)
System-wide file that takes exclusive control:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux: `/etc/claude-code/managed-mcp.json`

### Option 2: Policy-Based (`allowedMcpServers` / `deniedMcpServers`)
Allow users to add servers within policy constraints. Restrict by:
- **Server name**: `{ "serverName": "github" }`
- **Command**: `{ "serverCommand": ["npx", "-y", "approved-package"] }`
- **URL pattern**: `{ "serverUrl": "https://mcp.company.com/*" }`

Denylist always takes absolute precedence.

---

## Claude Code as MCP Server

```bash
claude mcp serve
```

Use in Claude Desktop config:
```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"]
    }
  }
}
```

---

## Output Limits

- Warning threshold: 10,000 tokens
- Default max: 25,000 tokens
- Override: `MAX_MCP_OUTPUT_TOKENS=50000`
