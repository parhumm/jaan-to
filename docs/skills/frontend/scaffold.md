---
title: "frontend-scaffold"
sidebar_position: 7
doc_type: skill
created_date: 2026-02-09
updated_date: 2026-02-09
tags: [dev, frontend, scaffold, react, nextjs, tailwind, typescript, api-hooks]
related: [frontend-design, frontend-task-breakdown, backend-api-contract]
---

# /frontend-scaffold

> Convert designs to React/Next.js components with TailwindCSS, TypeScript, and typed API client hooks.

---

## Overview

Generates production-ready frontend scaffolds from upstream artifacts (design outputs, task breakdowns, API contracts). Produces React/Next.js components with Server Component defaults, TailwindCSS v4 styling, TanStack Query hooks, and TypeScript interfaces derived from OpenAPI schemas.

---

## Usage

```
/frontend-scaffold
/frontend-scaffold frontend-design frontend-task-breakdown backend-api-contract
```

| Argument | Required | Description |
|----------|----------|-------------|
| frontend-design | No | Path to HTML preview or component description |
| frontend-task-breakdown | No | Path to FE task breakdown markdown |
| backend-api-contract | No | Path to OpenAPI YAML |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/frontend/scaffold/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Architecture doc + component map |
| `{id}-{slug}-components.tsx` | React components |
| `{id}-{slug}-hooks.ts` | Typed API client hooks |
| `{id}-{slug}-types.ts` | TypeScript interfaces from API schemas |
| `{id}-{slug}-pages.tsx` | Page layouts / routes |
| `{id}-{slug}-config.ts` | Package.json + tsconfig + tailwind config |
| `{id}-{slug}-readme.md` | Setup + run instructions |

When `backend-api-contract` is provided, additional API integration files are generated:

| File | Content |
|------|---------|
| `{id}-{slug}-orval-config.ts` | Orval configuration for API client generation |
| `{id}-{slug}-msw-handlers.ts` | MSW request handlers for all spec endpoints |
| `{id}-{slug}-msw-browser.ts` | MSW browser setup (setupWorker) |
| `{id}-{slug}-msw-server.ts` | MSW Node.js server setup (setupServer) |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| State management | Not in tech.md | TanStack Query only / + Zustand / + nuqs |
| Routing | Not in tech.md | App Router / Pages Router / custom |
| Testing | Not in tech.md | Vitest + Testing Library / Playwright / both |
| Responsive strategy | Not in tech.md | Mobile-first / desktop-first / adaptive |

---

## Framework Detection

Reads `$JAAN_CONTEXT_DIR/tech.md` to auto-detect:
- Frontend framework (default: React v19 + Next.js v15)
- Styling approach (default: TailwindCSS v4)
- State management and testing tools

---

## Key Patterns

- **React 19**: Server Components by default, `'use client'` only where needed
- **TailwindCSS v4**: CSS-first config with `@import "tailwindcss"` + `@theme {}`
- **API Integration**: Orval v7 or openapi-typescript for type generation
- **State**: TanStack Query v5 for server state, Zustand for client state, nuqs for URL state
- **Components**: Atomic Design levels, 4 states per data component (loading/error/empty/success)
- **Accessibility**: ARIA, semantic HTML, keyboard nav, WCAG AA contrast

---

## Workflow Chain

```
/frontend-design → /frontend-task-breakdown → /frontend-scaffold → /qa-test-cases
```

---

## Example

**Input:**
```
/frontend-scaffold path/to/design.html path/to/tasks.md path/to/api.yaml
```

**Output:**
```
jaan-to/outputs/frontend/scaffold/01-user-dashboard/
├── 01-user-dashboard.md
├── 01-user-dashboard-components.tsx
├── 01-user-dashboard-hooks.ts
├── 01-user-dashboard-types.ts
├── 01-user-dashboard-pages.tsx
├── 01-user-dashboard-config.ts
└── 01-user-dashboard-readme.md
```

---

## Tips

- Run `/frontend-task-breakdown` first to plan the component inventory
- Provide an API contract for automatic TypeScript type and hook generation
- Set up `$JAAN_CONTEXT_DIR/tech.md` to skip framework questions
- Copy scaffold files to your project directory and run `npm install`

---

## Related Skills

- [/frontend-design](design.md) - Create component designs
- [/frontend-task-breakdown](task-breakdown.md) - Plan component inventory
- [/backend-api-contract](../backend/api-contract.md) - Generate OpenAPI contracts

---

## Technical Details

- **Logical Name**: frontend-scaffold
- **Command**: `/frontend-scaffold`
- **Role**: dev (frontend)
- **Output**: `$JAAN_OUTPUTS_DIR/frontend/scaffold/{id}-{slug}/`
