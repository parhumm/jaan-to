# dev-output-integrate — Reference Material

> Extracted reference tables, code templates, and patterns for the `dev-output-integrate` skill.
> This file is loaded by `dev-output-integrate` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Config Merge Strategies

### package.json Deep Merge

When integrating outputs that include package.json additions, merge selectively:

**Strategy**: Deep merge by section, never overwrite existing values.

| Section | Merge Rule |
|---------|-----------|
| `dependencies` | Add new entries, keep existing versions (warn on conflict) |
| `devDependencies` | Add new entries, keep existing versions (warn on conflict) |
| `scripts` | Add new scripts, warn if script name exists with different command |
| `name`, `version` | Never overwrite |
| `engines` | Keep existing, warn if output requires different version |

**Conflict resolution**:
- If both files define the same dependency with different versions: show both versions, ask user which to keep
- If both files define the same script with different commands: show both, ask user

### tsconfig.json Extends Pattern

When integrating outputs that modify TypeScript configuration:

**Strategy**: Use `extends` pattern when possible, inline merge as fallback.

1. If output provides a base tsconfig: add as `extends` target
2. If output adds `compilerOptions`: merge individual options (warn on conflicts)
3. If output adds `include`/`exclude`: append paths, deduplicate

**Example extends approach**:
```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist"
  },
  "include": ["src/**/*.ts"]
}
```

---

## Entry Point Wiring Patterns

### Fastify Plugin Registration Order

When wiring backend entry points, plugins must be registered in dependency order:

```typescript
// app.ts — plugin registration order
import Fastify from 'fastify';

const app = Fastify({ logger: true });

// 1. Infrastructure (no dependencies)
await app.register(import('@fastify/compress'));
await app.register(import('@fastify/helmet'));

// 2. CORS (before auth, after helmet)
await app.register(import('@fastify/cors'), { origin: process.env.ALLOWED_ORIGINS?.split(',') });

// 3. Rate limiting (before auth)
await app.register(import('@fastify/rate-limit'), { max: 100, timeWindow: '1 minute' });

// 4. Session/Auth (after CORS, before routes)
await app.register(import('@fastify/jwt'), { secret: process.env.JWT_SECRET });

// 5. CSRF (after session)
await app.register(import('@fastify/csrf-protection'));

// 6. Sensible (error handling, last utility plugin)
await app.register(import('@fastify/sensible'));

// 7. Database (Prisma singleton)
await app.register(import('./plugins/prisma'));

// 8. Routes (last — depend on all plugins above)
await app.register(import('./routes/autoload'));
```

### Next.js Config Wiring

When integrating frontend config modifications:

```typescript
// next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // Existing config preserved
  reactStrictMode: true,

  // New: transpile monorepo packages (if applicable)
  transpilePackages: ['@repo/ui', '@repo/types'],

  // New: image domains (from output)
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '**.example.com' },
    ],
  },

  // New: API rewrites (from output)
  async rewrites() {
    return [
      { source: '/api/:path*', destination: `${process.env.BACKEND_URL}/api/:path*` },
    ];
  },
};

export default nextConfig;
```

### Provider Registration (React)

Frontend providers must be nested in dependency order:

```tsx
// providers.tsx — nesting order (outermost first)
export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>          {/* 1. Auth (outermost) */}
      <ThemeProvider>          {/* 2. Theme */}
        <QueryClientProvider>  {/* 3. Data layer */}
          {children}
        </QueryClientProvider>
      </ThemeProvider>
    </SessionProvider>
  );
}
```

---

## Route File Wiring

Route-level outputs (pages, views, layouts) must be placed in framework-specific route directories — not in generic component or library directories.

### Detection Heuristic

1. **Check README placement instructions** — look for paths containing `app/`, `pages/`, `resources/views/`, `resources/js/Pages/`, or `templates/`
2. **Check filename conventions** — files named `page.tsx`, `layout.tsx`, `loading.tsx`, or ending in `.blade.php`, `.html.tmpl` are route-level
3. **Check output folder structure** — files in folders named `pages/` or `routes/` in the output are route-level

### Per-Stack Routing Conventions

| Stack | Framework | Route Directory | Route File Pattern |
|-------|-----------|----------------|-------------------|
| Node.js / Next.js (App Router) | Next.js 13+ | `src/app/{route}/` | `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx` |
| Node.js / Next.js (Pages Router) | Next.js 12 | `src/pages/{route}.tsx` | Single file per route |
| PHP / Laravel (Inertia) | Laravel + Inertia | `resources/js/Pages/{Route}.vue` or `.tsx` | PascalCase component |
| PHP / Laravel (Blade) | Laravel | `resources/views/{route}.blade.php` | Dot-notation directories |
| Go | stdlib / Chi | `templates/{route}.html.tmpl` | Template files |

### Wiring Rules

**Next.js App Router:**
- Route groups: `(group)/` directories — parentheses are part of the path
- Dynamic segments: `[param]/` — brackets are part of the path
- Layout inheritance: `layout.tsx` applies to all children in the directory
- `page.tsx` is the route entry point — if output contains a component meant for a route, create or update the `page.tsx` to import and render it

**Laravel Inertia:**
- Pages are React/Vue components in `resources/js/Pages/`
- Route registration in `routes/web.php` — `Inertia::render('PageName')`
- Nested routes use folder structure: `Pages/Auth/Login.tsx`

**Laravel Blade:**
- Views in `resources/views/` with dot-notation: `auth.login` → `resources/views/auth/login.blade.php`
- Layouts use `@extends` or component-based `<x-layout>`

### Example Integration Mapping

```
Output file                          → Route destination (Next.js App Router)
{id}-{slug}-pages/landing.tsx        → src/app/(marketing)/page.tsx
{id}-{slug}-pages/dashboard.tsx      → src/app/dashboard/page.tsx
{id}-{slug}-pages/settings.tsx       → src/app/settings/page.tsx
{id}-{slug}-pages/auth/login.tsx     → src/app/auth/login/page.tsx
```

---

## Security Plugin Registration Order

When modifying entry points to wire security plugins, follow this exact order:

| Order | Plugin | Purpose | Must Be Before |
|-------|--------|---------|----------------|
| 1 | `@fastify/helmet` | Security headers | Everything |
| 2 | `@fastify/cors` | Cross-origin access | Auth, routes |
| 3 | `@fastify/rate-limit` | Request throttling | Auth, routes |
| 4 | `@fastify/session` or `@fastify/jwt` | Authentication | CSRF, routes |
| 5 | `@fastify/csrf-protection` | CSRF tokens | Routes |
| 6 | `@fastify/sensible` | Error helpers | Routes |

**Critical**: Registering auth before CORS will cause preflight failures. Registering CSRF before session will cause token generation failures.

---

## Package Manager Detection

Detect package manager from lockfile presence:

| Lockfile | Package Manager | Install Command | Add Command |
|----------|----------------|-----------------|-------------|
| `pnpm-lock.yaml` | pnpm | `pnpm install` | `pnpm add {pkg}` |
| `package-lock.json` | npm | `npm install` | `npm install {pkg}` |
| `yarn.lock` | yarn | `yarn install` | `yarn add {pkg}` |
| `bun.lockb` | bun | `bun install` | `bun add {pkg}` |
| None found | pnpm (default) | `pnpm install` | `pnpm add {pkg}` |

**Priority**: If multiple lockfiles exist, prefer in order: pnpm → npm → yarn → bun.

---

## Test Framework Detection

Detect test framework from project configuration:

| Indicator | Framework | Run Command |
|-----------|-----------|-------------|
| `vitest.config.ts` or `vitest.config.js` | Vitest | `pnpm vitest run` |
| `jest.config.ts` or `jest.config.js` | Jest | `pnpm jest` |
| `playwright.config.ts` | Playwright | `pnpm playwright test` |
| `cypress.config.ts` | Cypress | `pnpm cypress run` |
| `vitest` in package.json `devDependencies` | Vitest | `pnpm vitest run` |
| `jest` in package.json `devDependencies` | Jest | `pnpm jest` |

**Test file placement conventions**:
- Co-located: `src/**/__tests__/*.test.ts` (preferred by Vitest)
- Root-level: `tests/**/*.test.ts` (common for integration tests)
- E2E: `e2e/**/*.spec.ts` (Playwright convention)

---

## Bootstrap Validation Sequence

After integrating outputs, validate in this order:

| Step | Command | Purpose | Skip If |
|------|---------|---------|---------|
| 1 | `{pkg_manager} install` | Install dependencies | User declined |
| 2 | `npx prisma generate` | Generate Prisma client | No .prisma files integrated |
| 3 | `npx prisma db push` or `npx prisma migrate dev` | Apply schema to DB | No schema changes |
| 4 | `npx prisma db seed` | Seed database | No seed file |
| 5 | `npx tsc --noEmit` | TypeScript check | No .ts files |
| 6 | `{pkg_manager} run lint` | Lint check | No lint script |
| 7 | `{pkg_manager} run test` | Run tests | No test files integrated |
| 8 | `{pkg_manager} run build` | Build check | User prefers to skip |

**On failure**: Report error, suggest fix, continue to next step. Do not abort the entire validation.

---

## Environment Variable Management

### .env.example Generation

When outputs reference environment variables, ensure `.env.example` is updated:

**Security-relevant variables** (from sec-audit-remediate outputs):
```bash
JWT_SECRET=change-me-in-production
JWT_ISSUER=https://api.example.com
ALLOWED_ORIGINS=http://localhost:3000
SESSION_SECRET=change-me-in-production
CSRF_SECRET=change-me-in-production
```

**Database variables**:
```bash
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp
REDIS_URL=redis://localhost:6379
```

**Merge rule**: Append new variables to existing `.env.example`, preserve existing values, add comments for new sections.

### Zod/Envalid Validation Schema

If output includes environment validation (common in backend-scaffold outputs):

```typescript
// src/env.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(4000),
});

export const env = envSchema.parse(process.env);
```

Place at `src/env.ts` or `src/config/env.ts` depending on project convention.

## OpenAPI-Specific Integration

When `frontend-scaffold` output includes API tooling files (`*-orval-config.ts`, `*-msw-*`), additional integration steps apply.

### File placement

| Source File | Destination | Tool |
|------------|-------------|------|
| `{id}-{slug}-orval-config.ts` | `orval.config.ts` (project root) | `Write(orval.config.ts)` |
| `{id}-{slug}-msw-handlers.ts` | `src/mocks/handlers.ts` | `Write(src/**)` |
| `{id}-{slug}-msw-browser.ts` | `src/mocks/browser.ts` | `Write(src/**)` |
| `{id}-{slug}-msw-server.ts` | `src/mocks/server.ts` | `Write(src/**)` |

### Storybook MSW setup

1. Detect preview file: `.storybook/preview.{ts,tsx,js,mjs,cjs}`
2. If exists: `Edit(.storybook/**)` to add MSW initialization
3. If not: `Write(.storybook/preview.ts)` with full MSW setup

### MSW service worker

```bash
npx msw init public/ --save
```

This writes `mockServiceWorker.js` to `public/` — a static file that intercepts network requests in the browser.

### Package.json updates

- Add `"generate:api": "orval --config ./orval.config.ts"` to `scripts`
- Suggest adding `orval`, `msw`, `msw-storybook-addon` to devDependencies if not present
