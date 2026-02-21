# dev-project-assemble — Reference Material

> Extracted reference tables, code templates, and patterns for the `dev-project-assemble` skill.
> This file is loaded by `dev-project-assemble` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Directory Layout Templates

**Monorepo (Turborepo):**
```
{project}/
  apps/
    web/          # Next.js frontend
    api/          # Fastify backend
  packages/
    ui/           # Shared components (optional)
    types/        # Shared TypeScript types
    validators/   # Shared Zod schemas
  tooling/
    typescript/   # Shared tsconfig presets
    eslint/       # Shared ESLint configs
    tailwind/     # Shared Tailwind config
  turbo.json
  pnpm-workspace.yaml
  package.json
  .env.example
  .gitignore
```

**Separate Projects:**
```
{project}/
  backend/        # Fastify backend
    src/
    prisma/
    package.json
    tsconfig.json
  frontend/       # Next.js frontend
    src/
    package.json
    tsconfig.json
    next.config.ts
  .env.example
  .gitignore
```

## File Splitting Maps

**Backend (from `{id}-{slug}-routes.ts`):**
- Split per resource: `src/routes/{resource}/index.ts`
- Extract schemas: `src/routes/{resource}/{resource}.schema.ts`
- Extract services: `src/routes/{resource}/{resource}.service.ts`

**Backend (from `{id}-{slug}-middleware.ts`):**
- Auth plugin: `src/plugins/auth.ts`
- Error handler: `src/plugins/error-handler.ts`
- CORS config: `src/plugins/cors.ts`

**Backend (from `{id}-{slug}-prisma.prisma`):**
- Prisma schema: `prisma/schema.prisma`
- Seed file: `prisma/seed.ts`

**Backend entry points (GENERATED):**
- `src/app.ts` -- Fastify app builder with plugin registration
- `src/server.ts` -- Server startup with graceful shutdown
- `src/env.ts` -- Environment variable validation with Zod

**Frontend (from `{id}-{slug}-components.tsx`):**
- Split per component: `src/components/{level}/{ComponentName}.tsx`
- Atomic design levels: atoms, molecules, organisms

**Frontend (from `{id}-{slug}-hooks.ts`):**
- API hooks: `src/lib/api/hooks.ts`
- Query client: `src/lib/api/query-client.ts`

**Frontend (from `{id}-{slug}-types.ts`):**
- Shared types: `src/types/api.ts` (or `packages/types/` in monorepo)

**Frontend (from `{id}-{slug}-pages.tsx`):**
- Split per page: `src/app/{route}/page.tsx`
- Layout files: `src/app/{route}/layout.tsx`

**Frontend entry points (GENERATED):**
- `src/app/layout.tsx` -- Root layout (Server Component)
- `src/app/providers.tsx` -- Client-side provider composition
- `src/app/page.tsx` -- Home page
- `src/app/global.css` -- Global styles with Tailwind imports
- `src/env.ts` -- Environment variable validation

**Config files (GENERATED):**
- `package.json` -- Dependencies, scripts
- `tsconfig.json` -- TypeScript config (extends shared base in monorepo)
- `next.config.ts` -- Next.js configuration
- `tailwind.config.ts` -- Tailwind config (or CSS-first `@theme` in v4)
- `.env.example` -- All required environment variables documented
- `.gitignore` -- Standard ignores

## Build Plugin Detection

Framework configuration files can imply build-time dependencies that must be present in the dependency manifest. If a config signal is detected, the corresponding dependency **must** be added.

**Principle**: If framework config implies a build-time dependency, the dependency manifest must include it.

### Detection Table

| Stack | Config Signal | Required Dependency | Manifest |
|-------|--------------|-------------------|----------|
| Node.js / Next.js | `reactCompiler: true` in `next.config.ts` | `babel-plugin-react-compiler` | `devDependencies` in `package.json` |
| Node.js / Next.js | `@next/mdx` in `next.config.ts` | `@next/mdx`, `@mdx-js/react` | `dependencies` in `package.json` |
| PHP / Laravel | `octane` in `config/octane.php` | `laravel/octane`, `swoole` or `roadrunner` | `require` in `composer.json` |
| PHP / Laravel | `horizon` in `config/horizon.php` | `laravel/horizon` | `require` in `composer.json` |
| Go | `sqlc.yaml` or `sqlc.json` present | `sqlc` CLI | `tools.go` or Makefile |
| Go | `go:generate` directives | Referenced generator tool | `tools.go` or Makefile |

### Example: Next.js React Compiler

```typescript
// next.config.ts
const nextConfig: NextConfig = {
  reactCompiler: true,  // ← config signal
  // ...
};
```

When `reactCompiler: true` is detected:
- Add `babel-plugin-react-compiler` to `devDependencies`
- Without it, build fails: `Module not found: Can't resolve 'babel-plugin-react-compiler'`

---

## Backend Entry Point Templates

### 7.1: App Builder (`src/app.ts`)
```typescript
// Generate based on detected plugins and routes
import Fastify from "fastify";
// ... plugin imports based on scaffold analysis
// ... route imports or @fastify/autoload config

export async function buildApp() {
  const app = Fastify({ logger: true });
  // Register plugins in correct order
  // Register routes
  return app;
}
```

### 7.2: Server Startup (`src/server.ts`)
```typescript
// Separate from app.ts for testability
import { buildApp } from "./app.js";
import { env } from "./env.js";
// Graceful shutdown handler
```

### 7.3: Environment Validation (`src/env.ts`)
```typescript
// Zod-based env validation from scaffold config
import { z } from "zod";
const envSchema = z.object({ /* from scaffold */ });
export const env = envSchema.parse(process.env);
```

## Frontend Entry Point Templates

### 9.1: Root Layout (`src/app/layout.tsx`)
Server Component that wraps children in Providers:
```tsx
// Generated from detected providers
import { Providers } from "./providers";
import "./global.css";

export default function RootLayout({ children }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

### 9.2: Provider Composition (`src/app/providers.tsx`)
Client component with providers in correct nesting order:
```tsx
"use client";
// Generated based on Step 5 provider analysis
// Auth -> Theme -> Data -> State ordering
```

### 9.3: Home Page (`src/app/page.tsx`)
Basic page connecting to scaffold components.

### 9.4: Global Styles (`src/app/global.css`)
TailwindCSS v4 imports:
```css
@import "tailwindcss";
@theme { /* custom design tokens */ }
```

### 9.5: Environment Validation (`src/env.ts`)
```typescript
// @t3-oss/env-nextjs or custom Zod validation
// Server + client variable separation
```

## Config File Content Patterns

### 10.4: `.env.example`
Document ALL required environment variables:
```env
# Backend
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
PORT=3001
JWT_SECRET=change-me-to-a-secure-random-string
NODE_ENV=development

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Optional
REDIS_URL=redis://localhost:6379
LOG_LEVEL=info
```

### 10.5: `.gitignore`
Standard ignores for Node.js + Next.js + Prisma:
```
node_modules/
.next/
dist/
.turbo/
.env
.env.local
.env.*.local
*.tsbuildinfo
```

### 10.6: Monorepo-Specific (if applicable)
- `pnpm-workspace.yaml` -- Workspace package paths
- `turbo.json` -- Pipeline configuration with dependency graph
- `tooling/` -- Shared configs (TypeScript, ESLint, Tailwind)

## Multi-Stack Assembly Rules

### Node.js/TypeScript + Next.js (Primary Stack)

**Monorepo (Turborepo + pnpm):**
- `pnpm-workspace.yaml`: `packages: ["apps/*", "packages/*", "tooling/*"]`
- Internal packages use `"main": "./src/index.ts"` for dev-time source imports
- Workspace protocol: `"@{scope}/{pkg}": "workspace:*"`
- Root scripts delegate to Turborepo: `"dev": "turbo dev"`, `"build": "turbo build"`
- `turbo.json` pipeline: build depends on `^build`, dev is persistent + uncached
- Shared tsconfig in `tooling/typescript/` with base, nextjs, and library presets

**Backend Entry Point (Fastify):**
- `app.ts` (configuration) separate from `server.ts` (runtime) for testability
- Plugin registration order: infrastructure -> auth -> database -> routes
- `@fastify/autoload` for file-based route loading with `ignorePattern` for non-route files
- Graceful shutdown with `signal.NotifyContext` or process signal handlers

**Frontend Entry Point (Next.js App Router):**
- `layout.tsx` is Server Component -- delegates to `providers.tsx` (Client Component)
- Provider nesting: Session -> Theme -> QueryClient -> State
- `providers.tsx` marked with `"use client"`
- `global.css` with TailwindCSS v4 `@import "tailwindcss"` + `@theme {}`

**Environment Variables:**
- Backend: Zod schema validation at startup, crash on invalid
- Frontend: `@t3-oss/env-nextjs` with server/client separation
- Shared `.env.example` documenting all variables with descriptions
- Layered strategy: `.env` < `.env.local` < `.env.{environment}` < `.env.{environment}.local`

### PHP/Laravel (Secondary Stack)

**Directory Layout:**
- Laravel backend in `backend/` with standard Artisan structure
- Next.js frontend in `frontend/` consuming Laravel API
- Shared `.env.example` for both

**Entry Points:**
- Laravel: `public/index.php` (standard), `routes/api.php` for API
- API Resources for response shaping (never expose raw Eloquent models)

### Go (Tertiary Stack)

**Directory Layout:**
- Go backend in `backend/` with `internal/` feature-based packages
- Next.js frontend in `frontend/`

**Entry Points:**
- `cmd/api/main.go` -- Wire dependencies, start server
- `internal/{feature}/handler.go`, `service.go`, `repository.go`
- Manual DI in `main.go` (no framework)
