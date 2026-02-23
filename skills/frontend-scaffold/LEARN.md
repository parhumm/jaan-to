# Lessons: frontend-scaffold

> Last updated: 2026-02-09

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-frontend-scaffold.learn.md`

Seeded from research: $JAAN_OUTPUTS_DIR/research/63-dev-scaffolds.md

---

## Better Questions

Questions to ask during information gathering:

- Ask about feature-scoped vs atomic component organization — some teams prefer co-located feature folders
- Ask about SSR vs client-only rendering requirements — determines Server Component boundaries
- Ask about Orval vs openapi-typescript preference — Orval generates hooks automatically, openapi-typescript gives more control
- Ask about Server Actions vs client API calls for mutations — affects form and data flow architecture
- Ask about responsive breakpoint strategy — mobile-first vs desktop-first vs adaptive affects all components

## Edge Cases

Special cases to check and handle:

- Component count conflicts between frontend-design and frontend-task-breakdown — reconcile or ask
- API contract newer than design artifacts — may have endpoints not reflected in UI
- `useFormStatus` must be in a child component of `<form>` — placing it in the form component itself won't work
- Next.js 15 `fetch()` defaults to `no-store` (was `force-cache` in v14) — explicit caching needed
- TailwindCSS v4 bang syntax changed: `!bg-red-500` → `bg-red-500!` (suffix notation)
- ESLint 9 flat config (`eslint.config.mjs`) replaces `.eslintrc.json` — no backwards compatibility
- `use(promise)` must not create promises during render — causes infinite loops
- React Compiler handles memoization — manual `useMemo`/`useCallback`/`React.memo` causes conflicts
- Framework config can imply build dependencies not listed in package.json — verify config signals match dependency manifest

## Workflow

Process improvements:

- Read tech.md FIRST — framework determines all component patterns, imports, and config
- Follow input order: frontend-task-breakdown → frontend-design → backend-api-contract
- Generate TypeScript types before components — components depend on type definitions
- Default to Server Components for data fetching — only add `'use client'` when interactivity needed
- Check design.md and brand.md for existing tokens before generating custom values

## Common Mistakes

Things to avoid:

- `useEffect` for data fetching — use `async/await` in Server Components or `use(promise)` with Suspense
- `forwardRef` — in React 19, `ref` is a regular prop
- Manual memoization (`useMemo`/`useCallback`/`React.memo`) — React Compiler handles this
- `tailwind.config.js` — TailwindCSS v4 uses CSS-first config with `@theme { }`
- `@tailwind` directives — use `@import "tailwindcss"` in v4
- `'use client'` on every component — Server Components are the default in React 19
- `unstable_cache` — deprecated in Next.js 15, use `'use cache'` directive with `cacheTag()`/`cacheLife()`
- `next lint` — removed in Next.js 16, use ESLint CLI with `eslint.config.mjs` flat config
- `<Context.Provider>` — deprecated in React 19, use `<Context>` directly
- `defaultProps` — use ES6 default parameters instead
- `@layer utilities` — use `@utility` in TailwindCSS v4
- v3 dynamic class construction (`bg-[--my-var]`) — use `bg-(--my-var)` in v4
