---
title: "Storybook MCP"
sidebar_position: 3
---

# Storybook MCP

> Component documentation and story URLs via MCP.

---

## What It Does

The Storybook MCP addon exposes component documentation, story URLs, and build instructions to AI assistants. Skills use it to generate accurate stories and verify components.

---

## Setup

### Install Addon

```bash
npx storybook@latest add @anthropic-ai/storybook-mcp
```

### Configure in `.storybook/main.ts`

```typescript
const config: StorybookConfig = {
  stories: ['../src/**/*.stories.@(js|jsx|mjs|ts|tsx)'],
  addons: [
    '@storybook/addon-docs',
    '@anthropic-ai/storybook-mcp',
  ],
};
```

### MCP Server Config

**Claude Code** (`.mcp.json`):
```json
{
  "mcpServers": {
    "storybook-mcp": {
      "command": "npx",
      "args": ["@anthropic-ai/storybook-mcp"]
    }
  }
}
```

**Codex** (`~/.codex/config.toml`):
```toml
[mcp_servers.storybook-mcp]
command = "npx"
args = ["@anthropic-ai/storybook-mcp"]
```

---

## Tools Available

| Tool ID | Purpose |
|---------|---------|
| `get-ui-building-instructions` | CSF conventions for the project |
| `list-all-components` | Component inventory with metadata |
| `get-component-documentation` | Props, variants, usage docs for a component |
| `get-story-urls` | Story URLs for visual verification |

---

## Skills That Use It

| Skill | Tools Used |
|-------|-----------|
| `frontend-story-generate` | `get-ui-building-instructions`, `list-all-components`, `get-component-documentation` |
| `frontend-visual-verify` | `get-story-urls` |
| `frontend-component-fix` | `get-component-documentation`, `get-story-urls` |
| `frontend-design` | `get-ui-building-instructions` |

---

## Storybook Conventions

### CSF3 Format

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { MyComponent } from './MyComponent';

const meta: Meta<typeof MyComponent> = {
  component: MyComponent,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: { /* default props */ },
};
```

### RSC Support

Enable experimental React Server Components:

```javascript
export default {
  features: {
    experimentalRSC: true,
  },
};
```

---

## Without MCP

Skills degrade gracefully. Without Storybook MCP:
- Read `.storybook/main.ts` for configuration
- Read existing `*.stories.tsx` files for conventions
- Construct story URLs from naming patterns

---

[Back to MCP Connectors](README.md)
