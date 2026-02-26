---
title: "frontend-story-generate"
sidebar_position: 5
doc_type: skill
created_date: 2026-02-26
updated_date: 2026-02-26
tags: [dev, frontend, storybook, stories, csf3, testing, components]
related: [frontend-design, frontend-scaffold, frontend-visual-verify]
---

# /frontend-story-generate

> Generate CSF3 Storybook stories for components with variant coverage and state matrices.

---

## Overview

Creates Component Story Format 3 (CSF3) Storybook stories for React components. Automatically detects CVA variants, props, and states to generate comprehensive story coverage. Works with or without MCP servers via graceful degradation.

---

## Usage

```
/frontend-story-generate "src/components/Button.tsx"
/frontend-story-generate "jaan-to/outputs/frontend/scaffold/01-dashboard/"
/frontend-story-generate
```

| Argument | Required | Description |
|----------|----------|-------------|
| component-path | No | Path to component file, frontend-design output, or frontend-scaffold output |

When run without arguments, scans the project for components missing stories.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/frontend/story/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Documentation with coverage matrix and props API |
| `{id}-{slug}-stories.tsx` | CSF3 Storybook stories |
| `{id}-{slug}-readme.md` | Integration instructions for dev-output-integrate |

---

## Key Features

- **CVA variant detection** — Automatically finds `cva()`, `variants:`, `defaultVariants:` to generate per-variant stories
- **State coverage matrix** — Generates stories for Default, Loading, Error, Empty, Disabled, and edge case states
- **MCP graceful degradation** — Uses Storybook MCP and shadcn MCP when available; falls back to source reading
- **Scan mode** — When run without arguments, finds components missing `.stories.tsx` siblings
- **CSF3 format** — `Meta<typeof Component>` + `StoryObj<typeof meta>` pattern with declarative args

---

## MCP Integration (Optional)

| MCP Server | Tools Used | Fallback |
|------------|-----------|----------|
| Storybook MCP | `get-ui-building-instructions`, `list-all-components` | Read `.storybook/` config directly |
| shadcn MCP | Registry queries for prop types | Read component source for TypeScript interfaces |

---

## Workflow Chain

```
/frontend-design → /frontend-story-generate → /frontend-visual-verify
/frontend-scaffold → /frontend-story-generate → /frontend-visual-verify
```

- **frontend-design** or **frontend-scaffold** creates components
- **frontend-story-generate** creates stories for those components
- **frontend-visual-verify** visually verifies the rendered stories

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `/frontend-design` | Upstream — generates components that need stories |
| `/frontend-scaffold` | Upstream — scaffold output includes components |
| `/frontend-visual-verify` | Downstream — verifies rendered stories visually |
| `/dev-output-integrate` | Downstream — integrates story files into project |

---

[Back to Frontend Skills](README.md) | [Back to All Skills](../README.md)
