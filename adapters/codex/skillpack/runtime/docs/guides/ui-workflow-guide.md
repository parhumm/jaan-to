---
title: "UI Development Workflow"
sidebar_position: 10
---

# UI Development Workflow

> Build, verify, and fix UI components with Storybook, shadcn/ui, and MCP.

---

## Overview

jaan-to provides a complete UI development workflow:

1. **Design** — Generate component code with `/jaan-to:frontend-design`
2. **Scaffold** — Create full project structure with `/jaan-to:frontend-scaffold`
3. **Story** — Generate Storybook stories with `/jaan-to:frontend-story-generate`
4. **Verify** — Visually verify with `/jaan-to:frontend-visual-verify`
5. **Fix** — Fix UI bugs with `/jaan-to:frontend-component-fix`

Each step works independently. Use what you need.

---

## Quick Start

### 1. Initialize Project Context

```
/jaan-to:jaan-init
```

If a frontend stack is detected, seed `jaan-to/context/design.md` with your design system details.

### 2. Design a Component

```
/jaan-to:frontend-design "Hero section for landing page with CTA"
```

Generates component code, HTML preview, and CSF3 stories (if Storybook detected).

### 3. Generate Stories

```
/jaan-to:frontend-story-generate src/components/Hero.tsx
```

Generates CSF3 stories covering Default, Loading, Error, Empty, and all CVA variants.

### 4. Verify Visually

```
/jaan-to:frontend-visual-verify http://localhost:6006/?path=/story/hero--default
```

With Playwright MCP: scores 0-10 based on accessibility tree + visual capture.
Without Playwright: code-level analysis only (score = N/A).

### 5. Fix Issues

```
/jaan-to:frontend-component-fix "Button hover doesn't work on mobile" --component src/components/ui/Button.tsx
```

Generates patch artifacts. Offers guided integration + verification in one step.

---

## MCP Setup (Optional)

MCP servers enhance skills with real system context. All skills work without them.

### Storybook MCP

Exposes component docs and story URLs to skills.

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

### shadcn MCP

Browses and installs components from registries.

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

### Playwright MCP

Visual verification via accessibility snapshots. Localhost-only by default.

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

---

## Skill Chain Examples

### New Component (from scratch)

```
/jaan-to:frontend-design "Pricing card with 3 tiers"
  → /jaan-to:frontend-story-generate (from design output)
  → /jaan-to:dev-output-integrate (copy to project)
  → /jaan-to:frontend-visual-verify (confirm rendering)
```

### Bug Fix (reported issue)

```
/jaan-to:frontend-component-fix "Cards overlap on tablet"
  → Select "Integrate + Verify" (guided single-run mode)
  → Done (patches applied and verified)
```

### Full Project Scaffold

```
/jaan-to:frontend-scaffold (from PRD + API contract)
  → /jaan-to:frontend-story-generate (scan for missing stories)
  → /jaan-to:dev-output-integrate
  → /jaan-to:frontend-visual-verify (verify each component)
```

### Team Delivery

```
/jaan-to:team-ship "Build a dashboard" --track full
  → Frontend teammate runs: scaffold → design → story-generate
  → Visual QA teammate runs: visual-verify (Phase 3)
  → Lead reviews: visual verification report in Phase 4
```

---

## Design System Context

Seed `jaan-to/context/design.md` to give skills awareness of your design system. Key sections:

- **Component Library** — Which library (shadcn, MUI, custom), source path, style system
- **Storybook** — Version, config path, story format, dev URL, addons
- **Component Conventions** — File structure, naming, variant system
- **MCP Servers** — Which MCP servers are configured
- **Visual Standards** — Breakpoints, accessibility targets, animation approach

---

## Related

- [Storybook MCP Connector](../mcp/storybook.md)
- [shadcn MCP Connector](../mcp/shadcn.md)
- [Playwright MCP Connector](../mcp/playwright.md)
- [Security — Network Policy](../config/security.md)
- [Frontend UI Workflow Reference](../extending/frontend-ui-workflow-reference.md)
