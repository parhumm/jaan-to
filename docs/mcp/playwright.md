---
title: "Playwright MCP"
sidebar_position: 5
---

# Playwright MCP

> Browser automation via accessibility snapshots and screenshots.

---

## What It Does

Playwright MCP provides browser automation using structured accessibility snapshots. It operates on page structure data (not screenshots), making it fast, lightweight, and deterministic. Skills use it for visual verification of UI components.

---

## Setup

### MCP Server Config

**Claude Code** (`.mcp.json`):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

**Codex** (`~/.codex/config.toml`):
```toml
[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@latest"]
```

### With Config File

```bash
npx @playwright/mcp@latest --config path/to/config.json
```

---

## Network Security

**Default: localhost-only.** The recommended config restricts navigation:

```json
{
  "browser": {
    "launchOptions": { "headless": true }
  },
  "network": {
    "allowedOrigins": ["http://localhost:*", "http://127.0.0.1:*"],
    "blockedOrigins": ["*"]
  }
}
```

External URLs require explicit per-URL user confirmation in `frontend-visual-verify`.

---

## Core Tools

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Navigate to URL |
| `browser_snapshot` | Get accessibility tree (primary tool, fast, deterministic) |
| `browser_take_screenshot` | Capture visual screenshot (secondary) |
| `browser_tabs` | Manage browser tabs |
| `browser_click` | Click element |
| `browser_type` | Type text |
| `browser_wait_for` | Wait for conditions |
| `browser_resize` | Resize window |

### Optional Capabilities

Enable with `--caps=pdf,vision,testing`:
- **PDF**: `browser_pdf_save`
- **Vision**: coordinate-based mouse interactions
- **Testing**: `browser_generate_locator`, `browser_verify_element_visible`, `browser_verify_text_visible`

---

## Skills That Use It

| Skill | Tools Used |
|-------|-----------|
| `frontend-visual-verify` | `browser_navigate`, `browser_snapshot`, `browser_take_screenshot`, `browser_tabs` |
| `frontend-component-fix` | `browser_navigate`, `browser_snapshot`, `browser_take_screenshot` |

---

## Without MCP

Skills degrade to `static-mode`:
- Code-level analysis only (no browser automation)
- Visual score = N/A
- Cannot make visual pass/fail conclusions
- Still checks: code structure, prop types, accessibility attributes, CSS classes

---

[Back to MCP Connectors](README.md)
