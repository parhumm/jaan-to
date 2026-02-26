---
title: "Frontend UI Workflow Reference"
sidebar_position: 21
---

# Frontend UI Workflow Reference

> Shared reference for frontend UI skills. Loaded on demand via inline `> **Reference**:` pointers in SKILL.md.

---

## CSF3 Story Format Spec

Standard Component Story Format v3 pattern. Used by `frontend-story-generate`, `frontend-scaffold`, and `frontend-design`.

### Base Template

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { {ComponentName} } from './{ComponentName}';

const meta: Meta<typeof {ComponentName}> = {
  component: {ComponentName},
  tags: ['autodocs'],
  argTypes: {
    // Map props to controls
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    // Default prop values
  },
};
```

### Rules

- Use declarative `args` objects, not render functions
- Export `meta` as default (CSF3 requirement)
- Type stories with `StoryObj<typeof meta>` (not `StoryObj<typeof Component>`)
- Use `includeStories` / `excludeStories` to filter data exports from story list
- Add `tags: ['autodocs']` for automatic documentation
- One story per meaningful state (Default, Loading, Error, Empty, each variant)

### CVA Variant Detection

When a component uses `class-variance-authority` (CVA), generate one story per variant combination.

**Detection patterns** (grep in component source):

| Pattern | Indicates |
|---------|-----------|
| `cva(` | CVA base call |
| `variants:` | Variant definitions |
| `defaultVariants:` | Default variant values |
| `compoundVariants:` | Compound variant rules |

**Story generation for CVA**:
1. Extract variant keys from `variants:` block
2. Generate `Default` story with `defaultVariants` values
3. Generate one story per variant value (e.g., `Destructive`, `Outline`, `Ghost`)
4. Generate compound variant stories if `compoundVariants` exist

### argTypes Controls

Map TypeScript prop types to Storybook controls:

| Prop Type | Control |
|-----------|---------|
| `string` | `{ control: 'text' }` |
| `boolean` | `{ control: 'boolean' }` |
| `number` | `{ control: 'number' }` |
| `enum / union` | `{ control: 'select', options: [...] }` |
| `ReactNode` | `{ control: 'text' }` |
| `() => void` | `{ action: 'clicked' }` |

---

## Component State Coverage Matrix

Every generated story set must cover these states. Mark N/A if the component does not support a state.

| State | Required | Description |
|-------|----------|-------------|
| Default | Yes | Component with default props |
| Loading | If async | Skeleton or spinner state |
| Error | If fallible | Error message or boundary |
| Empty | If data-driven | No-data / zero state |
| Disabled | If interactive | Disabled form elements |
| Each variant | If CVA/variants | One story per variant value |
| Edge: long text | If text content | Overflow / truncation behavior |
| Edge: RTL | If i18n | Right-to-left layout |

---

## MCP Graceful Degradation Patterns

All frontend UI skills must work without MCP servers. MCP enhances, never gates.

### Pattern: Try MCP, Fallback to Source

```
IF MCP tool available:
  → Use MCP tool for richer context
ELSE:
  → Read source files directly (Glob + Grep + Read)
  → Log: "MCP server not available — using source file analysis"
```

### Storybook MCP

| MCP Tool | Purpose | Fallback |
|----------|---------|----------|
| `mcp__storybook-mcp__get-ui-building-instructions` | CSF conventions for project | Read `.storybook/main.ts` + existing `*.stories.tsx` |
| `mcp__storybook-mcp__list-all-components` | Component inventory | `Glob: src/**/*.tsx` minus stories/tests |
| `mcp__storybook-mcp__get-component-documentation` | Component docs | Read component source + JSDoc |
| `mcp__storybook-mcp__get-story-urls` | Story URLs for verification | Construct from `localhost:6006/?path=/story/{id}` |

### shadcn MCP

| MCP Tool | Purpose | Fallback |
|----------|---------|----------|
| `mcp__shadcn__*` (registry tools) | Real prop types from registry | Read component source files in `components/ui/` |

shadcn MCP command: `npx shadcn@latest mcp`

### Playwright MCP

| MCP Tool | Purpose | Fallback |
|----------|---------|----------|
| `mcp__playwright__browser_snapshot` | Accessibility tree (primary, fast, deterministic) | Static code analysis only (`static-mode`) |
| `mcp__playwright__browser_take_screenshot` | Visual capture (secondary) | No visual capture in `static-mode` |
| `mcp__playwright__browser_navigate` | Navigate to story URL | N/A in `static-mode` |
| `mcp__playwright__browser_tabs` | Manage browser tabs | N/A in `static-mode` |

Playwright MCP command: `npx @playwright/mcp@latest`
Config file: `npx @playwright/mcp@latest --config path/to/config.json`

---

## Visual Scoring Rubric

Two output modes based on Playwright MCP availability.

### visual-mode (Playwright available)

Score 0-10 based on accessibility tree + visual capture.

| Score | Meaning | Criteria |
|-------|---------|----------|
| 9-10 | Excellent | All states render correctly, responsive, accessible, no visual regressions |
| 7-8 | Good | Minor issues (spacing, alignment) that do not affect usability |
| 5-6 | Acceptable | Functional but noticeable visual issues |
| 3-4 | Poor | Significant visual problems affecting usability |
| 1-2 | Broken | Component fails to render or is unusable |
| 0 | Critical | Component crashes or blocks interaction |

### static-mode (No Playwright)

- Visual score: **N/A**
- Report header: "Static analysis only — visual verification requires Playwright MCP."
- Blocks visual pass/fail conclusions
- Can still assess: code structure, prop types, accessibility attributes, CSS classes

---

## Playwright Network Policy

Default: localhost-only. New network capabilities require explicit user consent.

### Recommended Playwright MCP Config

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

### URL Validation Rules

| URL Pattern | Action |
|-------------|--------|
| `localhost:*` | Allow (default) |
| `127.0.0.1:*` | Allow (default) |
| Any external domain | Require explicit per-URL user confirmation |

Skills must validate URLs before passing to `browser_navigate`.

---

## dev-output-integrate Readme Format

Every integratable skill must emit `{id}-{slug}-readme.md` for `dev-output-integrate` compatibility.

### Required Format

```markdown
# {Skill Name} Output

## Integration Map

| Source | Destination |
|--------|-------------|
| `{id}-{slug}-stories.tsx` | `src/components/{component}/{Component}.stories.tsx` |
| `{id}-{slug}-patch-{name}.tsx` | `src/components/{component}/{Component}.tsx` |

## Notes

- {Any special integration instructions}
```

`dev-output-integrate` parses Source/Destination tables and `cp` commands to map output files to project locations.

---

## Storybook Detection

Pattern for detecting Storybook in a project (used by multiple skills).

| Check | Method | Indicates |
|-------|--------|-----------|
| `.storybook/` directory | `Glob: .storybook/main.*` | Storybook installed |
| `storybook` in devDependencies | `Grep: "storybook" package.json` | Storybook as dependency |
| `*.stories.tsx` files | `Glob: src/**/*.stories.tsx` | Existing stories |
| `@storybook/addon-mcp` | `Grep: "addon-mcp" .storybook/main.*` | MCP addon configured |
| `experimentalRSC: true` | `Grep: "experimentalRSC" .storybook/main.*` | RSC support enabled |
| `components.json` | `Glob: components.json` | shadcn/ui configured |

---

## Related

- [Storybook MCP Connector](../mcp/storybook.md)
- [shadcn MCP Connector](../mcp/shadcn.md)
- [Playwright MCP Connector](../mcp/playwright.md)
- [Security Policy — Network](../config/security.md)
- [Design System Context Seed](../../scripts/seeds/design.md)
