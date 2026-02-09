---
title: "frontend-scaffold"
sidebar_position: 7
doc_type: skill
created_date: 2026-02-09
updated_date: 2026-02-09
tags: [dev, frontend, scaffold, react, nextjs, tailwind, typescript, api-hooks]
related: [frontend-design, frontend-task-breakdown, backend-api-contract]
---

# /jaan-to:frontend-scaffold

> Convert designs to React/Next.js components with TailwindCSS, TypeScript, and typed API client hooks.

---

## Overview

Generates production-ready frontend scaffolds from upstream artifacts (design outputs, task breakdowns, API contracts). Produces React/Next.js components with Server Component defaults, TailwindCSS v4 styling, TanStack Query hooks, and TypeScript interfaces derived from OpenAPI schemas.

---

## Usage

```
/jaan-to:frontend-scaffold
/jaan-to:frontend-scaffold frontend-design frontend-task-breakdown backend-api-contract
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
| `{id}-frontend-scaffold-{slug}.md` | Architecture doc + component map |
| `{id}-frontend-scaffold-components-{slug}.tsx` | React components |
| `{id}-frontend-scaffold-hooks-{slug}.ts` | Typed API client hooks |
| `{id}-frontend-scaffold-types-{slug}.ts` | TypeScript interfaces from API schemas |
| `{id}-frontend-scaffold-pages-{slug}.tsx` | Page layouts / routes |
| `{id}-frontend-scaffold-config-{slug}.ts` | Package.json + tsconfig + tailwind config |
| `{id}-frontend-scaffold-readme-{slug}.md` | Setup + run instructions |

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
/jaan-to:frontend-design → /jaan-to:frontend-task-breakdown → /jaan-to:frontend-scaffold → /jaan-to:qa-test-cases
```

---

## Example

**Input:**
```
/jaan-to:frontend-scaffold path/to/design.html path/to/tasks.md path/to/api.yaml
```

**Output:**
```
jaan-to/outputs/frontend/scaffold/01-user-dashboard/
├── 01-frontend-scaffold-user-dashboard.md
├── 01-frontend-scaffold-components-user-dashboard.tsx
├── 01-frontend-scaffold-hooks-user-dashboard.ts
├── 01-frontend-scaffold-types-user-dashboard.ts
├── 01-frontend-scaffold-pages-user-dashboard.tsx
├── 01-frontend-scaffold-config-user-dashboard.ts
└── 01-frontend-scaffold-readme-user-dashboard.md
```

---

## Tips

- Run `/jaan-to:frontend-task-breakdown` first to plan the component inventory
- Provide an API contract for automatic TypeScript type and hook generation
- Set up `$JAAN_CONTEXT_DIR/tech.md` to skip framework questions
- Copy scaffold files to your project directory and run `npm install`

---

## Related Skills

- [/jaan-to:frontend-design](design.md) - Create component designs
- [/jaan-to:frontend-task-breakdown](task-breakdown.md) - Plan component inventory
- [/jaan-to:backend-api-contract](../backend/api-contract.md) - Generate OpenAPI contracts

---

## Technical Details

- **Logical Name**: frontend-scaffold
- **Command**: `/jaan-to:frontend-scaffold`
- **Role**: dev (frontend)
- **Output**: `$JAAN_OUTPUTS_DIR/frontend/scaffold/{id}-{slug}/`
