---
title: "shadcn MCP"
sidebar_position: 4
---

# shadcn MCP

> Browse and install UI components from registries via natural language.

---

## What It Does

The shadcn MCP server connects AI assistants to component registries. Skills use it to get real prop types, variant definitions, and install components directly.

---

## Setup

### MCP Server Config

**Claude Code** (`.mcp.json`):
```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

**Codex** (`~/.codex/config.toml`):
```toml
[mcp_servers.shadcn]
command = "npx"
args = ["shadcn@latest", "mcp"]
```

---

## How It Works

1. Connects to configured registries (shadcn/ui default, custom registries)
2. AI describes what's needed in plain English
3. MCP translates to registry commands
4. Components are fetched and installed in the project

---

## Project Configuration

shadcn/ui projects use `components.json`:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "radix-nova",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "css": "src/styles/globals.css",
    "baseColor": "neutral",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui"
  },
  "iconLibrary": "lucide"
}
```

### Custom Registries

```json
{
  "registries": {
    "@acme": "https://acme.com/r/{name}.json"
  }
}
```

---

## Skills That Use It

| Skill | Purpose |
|-------|---------|
| `frontend-story-generate` | Real prop types from registry for accurate stories |
| `frontend-component-fix` | Component documentation for diagnosis |

---

## Without MCP

Skills degrade gracefully. Without shadcn MCP:
- Read component source files in `components/ui/`
- Parse `components.json` for configuration
- Extract prop types from TypeScript interfaces

---

[Back to MCP Connectors](README.md)
