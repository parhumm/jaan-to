# Scaffold-to-Project Assembly Automation

> Research conducted: 2026-02-10

## Executive Summary

- **Monorepo tooling has converged around Turborepo and Nx** as the dominant scaffolding orchestrators for TypeScript projects, each offering distinct code generation philosophies -- Turborepo favoring convention-over-configuration with minimal overhead, Nx providing a rich generator/plugin ecosystem with dependency graph intelligence.
- **pnpm workspaces have become the de facto standard** for monorepo package management in the Node.js/TypeScript ecosystem, offering strict dependency isolation, workspace protocol (`workspace:*`), and native support for both Turborepo and Nx pipelines.
- **Provider wiring (auth, theme, state) is the most error-prone scaffolding step** because it requires understanding component tree ordering, server/client boundary awareness in Next.js App Router, and correct nesting of context providers -- tools like create-t3-app solve this with opinionated template composition.
- **Config file generation (tsconfig.json, package.json scripts, framework configs) benefits most from inheritance patterns** -- shared base configs extended per-package reduce drift and enforce consistency across monorepo packages.
- **Environment variable management requires a layered strategy** combining `.env` file hierarchies, schema validation (e.g., `@t3-oss/env-nextjs`, Zod-based validation), and build-time injection to prevent runtime failures from missing or malformed configuration.

## Background & Context

Modern full-stack TypeScript projects rarely start from a blank `npm init`. Teams working with Node.js/TypeScript stacks -- particularly combinations of Next.js for the frontend and Fastify for the backend -- face a "scaffold assembly" challenge: individual code generators (e.g., `create-next-app`, `fastify-cli generate`) produce isolated project skeletons, but wiring them into a coherent, buildable, deployable monorepo requires substantial manual integration work.

This integration work includes configuring shared TypeScript compilation settings, establishing package boundaries, wiring authentication and state management providers into the component tree, generating entry points that correctly bootstrap both server and client applications, splitting bundles for optimal loading, and managing environment variables across development, staging, and production environments.

The ecosystem has responded with increasingly sophisticated scaffolding tools. Turborepo (acquired by Vercel in 2021) focuses on build orchestration and caching in monorepos. Nx (by Nrwl) provides a full workspace management system with code generators, dependency graph visualization, and affected-based command execution. create-t3-app popularized opinionated full-stack scaffolding for the Next.js + TypeScript + tRPC + Prisma + NextAuth stack. These tools represent different points on the scaffolding spectrum -- from minimal convention-based setups to full-featured workspace management platforms.

## Key Findings

### 1. Monorepo Setup Patterns (Turborepo + pnpm Workspaces)

**pnpm Workspaces Configuration**

The standard monorepo layout uses a `pnpm-workspace.yaml` at the root defining package locations:

```yaml
packages:
  - "apps/*"
  - "packages/*"
  - "tooling/*"
```

This three-tier structure separates deployable applications (`apps/`), shared libraries (`packages/`), and development tooling (`tooling/`). The `tooling/` directory is a pattern popularized by create-t3-app's "create-t3-turbo" template for housing shared ESLint configs, TypeScript configs, and Tailwind presets.

**Turborepo Pipeline Configuration**

Turborepo uses `turbo.json` to define task pipelines with dependency relationships:

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {},
    "type-check": {
      "dependsOn": ["^build"]
    }
  }
}
```

The `^build` syntax means "run build in all dependency packages first," which is critical for monorepos where shared packages must compile before consuming apps.

**Key Patterns:**
- **Internal packages** use `"main": "./src/index.ts"` with `"types": "./src/index.ts"` to skip build steps during development, relying on the consuming app's bundler for compilation.
- **Workspace protocol** (`"@acme/ui": "workspace:*"`) ensures pnpm links local packages rather than fetching from the registry.
- **Root `package.json` scripts** delegate to Turborepo: `"build": "turbo build"`, `"dev": "turbo dev"`, `"lint": "turbo lint"`.

### 2. Entry Point Generation Patterns

**Next.js App Router Entry Points**

The App Router's file-system routing requires specific entry point files:

```
apps/web/src/app/
  layout.tsx        # Root layout - wraps all pages
  page.tsx          # Home page
  providers.tsx     # Client-side provider composition
  global.css        # Global styles
  (auth)/
    layout.tsx      # Auth-specific layout
    login/page.tsx
    register/page.tsx
  (dashboard)/
    layout.tsx      # Dashboard layout with sidebar
    page.tsx
```

The root `layout.tsx` is the critical entry point for provider wiring. It must be a Server Component by default, delegating client-side providers to a separate `providers.tsx` file marked with `"use client"`.

**Fastify Backend Entry Points**

Fastify applications follow a plugin-based architecture with a standard entry point pattern:

```typescript
// apps/api/src/app.ts
import Fastify from "fastify";
import cors from "@fastify/cors";
import { authPlugin } from "./plugins/auth";
import { routes } from "./routes";

export async function buildApp() {
  const app = Fastify({ logger: true });

  await app.register(cors, { origin: true });
  await app.register(authPlugin);
  await app.register(routes, { prefix: "/api" });

  return app;
}

// apps/api/src/server.ts
import { buildApp } from "./app";

async function main() {
  const app = await buildApp();
  await app.listen({ port: Number(process.env.PORT) || 3001 });
}

main();
```

The separation of `app.ts` (configuration) from `server.ts` (runtime) enables testability -- tests import `buildApp()` to create isolated instances without starting a server.

**Scaffolding Approach for Entry Points:**
- Generate `layout.tsx` with placeholder provider slots using AST manipulation or template literals.
- Generate `app.ts` for Fastify with plugin registration slots that match detected dependencies.
- Use a manifest file (e.g., `scaffold.config.ts`) to declare which providers/plugins should be wired.

### 3. Provider Wiring Patterns (Auth, Theme, State Stores)

**Provider Composition in Next.js App Router**

The recommended pattern separates server and client concerns:

```tsx
// app/providers.tsx
"use client";

import { SessionProvider } from "next-auth/react";
import { ThemeProvider } from "next-themes";
import { QueryClientProvider } from "@tanstack/react-query";
import { TRPCProvider } from "@/lib/trpc/provider";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      <ThemeProvider attribute="class" defaultTheme="system">
        <TRPCProvider>
          <QueryClientProvider client={queryClient}>
            {children}
          </QueryClientProvider>
        </TRPCProvider>
      </ThemeProvider>
    </SessionProvider>
  );
}
```

```tsx
// app/layout.tsx (Server Component)
import { Providers } from "./providers";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

**Provider Ordering Rules (Critical for scaffolding):**
1. **Session/Auth** -- outermost, because other providers may need auth state.
2. **Theme** -- early, because UI components need theme context during render.
3. **Data layer** (tRPC, React Query) -- provides data fetching context.
4. **State stores** (Zustand, Jotai) -- innermost application state.

**Scaffolding Automation for Providers:**
- Maintain a provider registry that maps installed packages to provider components.
- When scaffolding detects `next-auth` in dependencies, auto-generate `SessionProvider` wiring.
- Use a topological sort on provider dependencies to determine correct nesting order.
- Generate the `providers.tsx` file by composing selected providers in the correct order.

**Fastify Plugin Wiring (Backend Providers):**

Fastify's plugin system serves an analogous role to React's Context providers:

```typescript
// plugins/auth.ts
import fp from "fastify-plugin";
import fastifyJwt from "@fastify/jwt";

export const authPlugin = fp(async (app) => {
  app.register(fastifyJwt, { secret: process.env.JWT_SECRET! });

  app.decorate("authenticate", async (request, reply) => {
    try {
      await request.jwtVerify();
    } catch (err) {
      reply.send(err);
    }
  });
});
```

Plugins are registered via `app.register()` in the entry point, with encapsulation scope controlled by `fastify-plugin` (`fp`). The scaffold must wire plugins in the correct order -- infrastructure plugins (CORS, compression) before business logic plugins (auth, database) before route registration.

### 4. Config File Generation Patterns

**TypeScript Configuration Inheritance**

The monorepo pattern uses a base `tsconfig.json` extended by each package:

```json
// tooling/typescript/base.json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "incremental": true
  }
}

// tooling/typescript/nextjs.json
{
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "jsx": "preserve",
    "module": "esnext",
    "target": "es2017",
    "plugins": [{ "name": "next" }]
  }
}

// tooling/typescript/library.json
{
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["esnext"],
    "module": "esnext",
    "target": "es2020",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

Each package then extends the appropriate preset:

```json
// apps/web/tsconfig.json
{
  "extends": "@acme/typescript/nextjs.json",
  "include": ["src", ".next/types/**/*.ts"],
  "compilerOptions": {
    "paths": { "@/*": ["./src/*"] }
  }
}
```

**package.json Script Generation**

Scaffold tools generate scripts that follow conventions:

```json
{
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --max-warnings 0",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf .next .turbo node_modules"
  }
}
```

For Fastify backend packages:

```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsup src/server.ts --format esm",
    "start": "node dist/server.js",
    "lint": "eslint . --max-warnings 0",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist .turbo node_modules"
  }
}
```

**Framework Config Generation:**
- **ESLint**: Shared configs in `tooling/eslint/` with preset packages (`@acme/eslint-config-base`, `@acme/eslint-config-next`).
- **Prettier**: Single `.prettierrc` at root, shared via workspace root.
- **Tailwind CSS**: Shared preset in `tooling/tailwind/` with `content` paths that resolve workspace packages.
- **PostCSS**: Minimal `postcss.config.js` per app referencing the shared Tailwind config.

### 5. Bundle Splitting Strategies

**Next.js Automatic Code Splitting**

Next.js App Router provides automatic code splitting at the route level. Each `page.tsx` becomes a separate chunk. Additional strategies include:

- **Dynamic imports**: `const Component = dynamic(() => import("./HeavyComponent"))` for lazy loading.
- **Route groups**: `(marketing)` and `(dashboard)` route groups split application concerns without affecting URL structure.
- **Parallel routes**: `@modal` and `@sidebar` slots enable independent loading of page sections.

**Shared Package Splitting**

In monorepos, shared packages should be structured for tree-shaking:

```typescript
// packages/ui/src/index.ts - barrel export
export { Button } from "./button";
export { Input } from "./input";
export { Card } from "./card";
```

With `sideEffects: false` in `package.json`, bundlers can tree-shake unused components. For larger packages, sub-path exports prevent pulling in the entire package:

```json
{
  "exports": {
    "./button": "./src/button.tsx",
    "./input": "./src/input.tsx",
    "./card": "./src/card.tsx"
  }
}
```

**tsup for Library Building:**

```typescript
// packages/shared/tsup.config.ts
import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["esm", "cjs"],
  dts: true,
  splitting: true,
  treeshake: true,
  clean: true,
  external: ["react", "react-dom"],
});
```

**Fastify Backend Splitting:**

Backend code splitting focuses on:
- **Route-based lazy loading**: Fastify's `--require` and dynamic plugin registration.
- **Worker threads**: CPU-intensive operations offloaded to separate bundles.
- **Shared types package**: `@acme/types` or `@acme/validators` (Zod schemas) shared between frontend and backend without bundling runtime code.

### 6. Environment Variable Management

**Layered .env Strategy**

```
.env                    # Shared defaults (committed, no secrets)
.env.local              # Local overrides (gitignored)
.env.development        # Dev-specific (committed)
.env.development.local  # Dev local overrides (gitignored)
.env.production         # Prod-specific (committed)
.env.production.local   # Prod local overrides (gitignored)
```

**Schema Validation with @t3-oss/env-nextjs:**

```typescript
// apps/web/src/env.ts
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    NEXTAUTH_SECRET: z.string().min(32),
    NEXTAUTH_URL: z.string().url(),
  },
  client: {
    NEXT_PUBLIC_API_URL: z.string().url(),
    NEXT_PUBLIC_SITE_URL: z.string().url(),
  },
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    NEXTAUTH_SECRET: process.env.NEXTAUTH_SECRET,
    NEXTAUTH_URL: process.env.NEXTAUTH_URL,
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
  },
});
```

This approach provides:
- **Type safety**: `env.DATABASE_URL` is typed as `string`.
- **Build-time validation**: The app fails to start if required variables are missing.
- **Client/server separation**: Prevents accidental exposure of server-side secrets to the browser.

**Fastify Environment Validation:**

```typescript
// apps/api/src/env.ts
import { z } from "zod";

const envSchema = z.object({
  PORT: z.coerce.number().default(3001),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  REDIS_URL: z.string().url().optional(),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
});

export const env = envSchema.parse(process.env);
export type Env = z.infer<typeof envSchema>;
```

**Monorepo .env Patterns:**
- **Root `.env.example`**: Documents all variables across all apps.
- **Per-app `.env`**: Each app has its own `.env` file for app-specific variables.
- **Turbo env passthrough**: `turbo.json` declares `globalDotEnv` and per-task `dotEnv` to ensure cache invalidation when env vars change.

```json
{
  "pipeline": {
    "build": {
      "dotEnv": [".env.local", ".env.production.local", ".env.production", ".env"]
    }
  }
}
```

### 7. Project Bootstrapping Workflows

**create-t3-app Workflow**

create-t3-app exemplifies opinionated scaffolding:

1. Interactive CLI prompts for stack choices (TypeScript, tRPC, Prisma, NextAuth, Tailwind).
2. Template composition -- each feature maps to a set of template files.
3. Provider wiring is generated based on selections -- `SessionProvider` only appears if NextAuth is selected.
4. `package.json` dependencies are composed from a dependency map per feature.
5. Environment variables are pre-configured with `.env.example` containing all required vars.

**create-t3-turbo (Monorepo Variant):**

Extends the T3 pattern to a Turborepo monorepo with:
- `apps/nextjs` -- Next.js frontend
- `apps/expo` -- React Native app (optional)
- `packages/api` -- tRPC API layer
- `packages/auth` -- NextAuth configuration
- `packages/db` -- Prisma schema and client
- `packages/ui` -- Shared component library
- `packages/validators` -- Shared Zod schemas
- `tooling/eslint` -- Shared ESLint configs
- `tooling/typescript` -- Shared TypeScript configs
- `tooling/tailwind` -- Shared Tailwind config

**Nx Generator Workflow**

Nx uses "generators" for scaffolding:

```bash
nx generate @nx/next:application web --directory=apps/web
nx generate @nx/node:application api --directory=apps/api --framework=fastify
nx generate @nx/react:library ui --directory=packages/ui
```

Generators:
- Create files from templates (EJS-based).
- Update `project.json` with build targets.
- Modify `tsconfig.base.json` paths.
- Generate correct entry points for the framework.
- Wire dependencies in the project graph.

Custom generators enable teams to encode their specific patterns:

```typescript
// tools/generators/feature/index.ts
import { Tree, generateFiles, joinPathFragments } from "@nx/devkit";

export default async function featureGenerator(tree: Tree, schema: { name: string }) {
  generateFiles(tree, joinPathFragments(__dirname, "files"), `apps/web/src/features/${schema.name}`, {
    name: schema.name,
    tmpl: "",
  });
}
```

**Bootstrap CLI Pattern (Custom):**

For teams outgrowing opinionated tools, a custom bootstrap script encodes organizational standards:

```typescript
// scripts/bootstrap.ts
import { execSync } from "child_process";
import { writeFileSync, mkdirSync } from "fs";

async function bootstrap(config: ProjectConfig) {
  // 1. Create monorepo structure
  createDirectoryStructure(config);

  // 2. Generate root configs
  generatePackageJson(config);
  generateTurboJson(config);
  generatePnpmWorkspace(config);
  generateRootTsconfig(config);

  // 3. Scaffold apps
  for (const app of config.apps) {
    scaffoldApp(app);
    wireProviders(app);
    generateEntryPoints(app);
    generateEnvFiles(app);
  }

  // 4. Scaffold shared packages
  for (const pkg of config.packages) {
    scaffoldPackage(pkg);
    generateExports(pkg);
  }

  // 5. Install dependencies
  execSync("pnpm install", { stdio: "inherit" });

  // 6. Run initial build
  execSync("pnpm build", { stdio: "inherit" });

  // 7. Validate
  execSync("pnpm type-check", { stdio: "inherit" });
  execSync("pnpm lint", { stdio: "inherit" });
}
```

## Recent Developments (2025-2026)

- **Turborepo 2.x** introduced improved remote caching, environment variable handling with `globalPassThroughEnv`, and better integration with pnpm workspaces. The `turbo gen` command was added for workspace-aware code generation, providing lighter-weight scaffolding without Nx's generator complexity.
- **Nx 20+** strengthened its "Crystal" plugins that automatically detect project configurations without explicit `project.json` files, reducing boilerplate. The `nx init` command can now retrofit monorepo tooling onto existing codebases.
- **Next.js 14/15 App Router stabilization** settled patterns for server/client component boundaries, making provider wiring patterns more predictable. The `instrumentation.ts` entry point for server-side initialization became stable.
- **Fastify 5.x** brought ESM-first module resolution, aligning with the TypeScript ecosystem's shift toward native ES modules. Plugin registration patterns remained stable.
- **create-t3-app v8+** adopted the App Router by default, updated provider wiring patterns for the server/client boundary, and improved environment variable validation with `@t3-oss/env-nextjs` v0.10+.
- **pnpm 9+** introduced `catalogs` for centralized dependency version management across workspaces, reducing version drift in monorepos.
- **Biome** emerged as an alternative to ESLint + Prettier for code formatting and linting, with zero-config monorepo support, affecting tooling config generation patterns.
- **TypeScript 5.5+ `--isolatedDeclarations`** enables parallel type checking in monorepos, influencing how tsconfig.json files are structured for build performance.

## Best Practices & Recommendations

1. **Use shared config packages over copy-paste**: Create `@acme/typescript-config`, `@acme/eslint-config`, and `@acme/tailwind-config` packages in `tooling/`. Each app extends these shared configs rather than maintaining independent configurations. This prevents drift and enables centralized updates.

2. **Validate environment variables at build time, not runtime**: Use Zod-based schema validation (like `@t3-oss/env-nextjs` or custom Zod parsers) to fail fast during build/startup if required environment variables are missing or malformed. Generate `.env.example` files automatically from the schema.

3. **Separate provider composition from layout**: Create a dedicated `providers.tsx` file marked with `"use client"` that composes all client-side providers. The root `layout.tsx` remains a Server Component that simply wraps children in `<Providers>`. This clean separation makes provider ordering explicit and testable.

4. **Use internal packages with source-level imports during development**: Set internal packages' `main` to `./src/index.ts` instead of a compiled output path. The consuming app's bundler (Next.js, Vite) handles compilation. This eliminates the need for watch modes on shared packages during development, dramatically improving DX.

5. **Encode scaffolding decisions in a manifest file**: Rather than hard-coding scaffold logic, use a declarative `scaffold.config.ts` or `project.json` that declares which features are enabled. The scaffold generator reads this manifest to determine which providers to wire, which plugins to register, and which config files to generate. This makes scaffolding reproducible and diffable.

6. **Implement progressive disclosure in bootstrapping**: Start with the minimal viable project structure (one app, zero shared packages) and add complexity only when needed. Use `turbo gen workspace` or Nx generators to add packages incrementally rather than scaffolding the full monorepo structure upfront.

7. **Use sub-path exports for shared packages**: Instead of barrel files that force bundlers to include entire packages, use `package.json` `exports` field with sub-path patterns. This enables proper tree-shaking and reduces bundle sizes in consuming applications.

8. **Automate entry point generation based on filesystem conventions**: Use tools like `turbo gen` or custom scripts to scan directory structures and auto-generate barrel exports, route registrations, and plugin imports. This reduces manual wiring errors and keeps entry points in sync with the codebase.

9. **Layer .env files with clear precedence rules**: Follow the convention of `.env` (defaults) < `.env.local` (overrides) < `.env.{environment}` (env-specific) < `.env.{environment}.local` (env-specific overrides). Document the precedence in a root-level comment and configure Turborepo's `dotEnv` array to match.

10. **Generate type-safe route definitions**: For both Next.js (file-system routes) and Fastify (registered routes), generate a shared route type definition that both frontend and backend can import. This ensures API URLs are type-checked and refactoring route paths doesn't break consumers.

## Comparisons

| Aspect | Turborepo | Nx | create-t3-app |
|--------|-----------|----|----|
| **Philosophy** | Build orchestration, minimal config | Full workspace management, rich tooling | Opinionated full-stack scaffold |
| **Code generation** | `turbo gen` (lightweight) | Rich generator/plugin ecosystem | One-time CLI scaffold |
| **Config approach** | `turbo.json` pipeline, delegates to tools | `project.json` per project, centralized | Standard Next.js + dotfiles |
| **Learning curve** | Low -- add `turbo.json`, done | Medium-high -- concepts, plugins, graph | Low -- interactive CLI choices |
| **Monorepo support** | Native, pnpm/npm/yarn workspaces | Native, integrated workspace management | Via `create-t3-turbo` template |
| **Caching** | Local + Vercel Remote Cache | Local + Nx Cloud | N/A (not a build tool) |
| **Customization** | Limited generators | Extensive custom generators | Fork and modify template |
| **Fastify support** | Manual setup | `@nx/node` plugin with Fastify preset | Not included (Next.js focused) |
| **Provider wiring** | Manual | Can be encoded in generators | Auto-wired based on selections |
| **Best for** | Teams wanting minimal tooling overhead | Large teams needing governance | Rapid prototyping, new projects |

| Aspect | pnpm Workspaces | Yarn Berry Workspaces | npm Workspaces |
|--------|----------------|----------------------|----------------|
| **Dependency isolation** | Strict (content-addressable store) | PnP mode (zero-installs) | Hoisted (less strict) |
| **Disk usage** | Excellent (shared store, hard links) | Good (PnP) to moderate (node_modules) | Moderate (hoisted) |
| **Monorepo ergonomics** | `pnpm -F <pkg> add` filter syntax | `yarn workspace <pkg> add` | `npm -w <pkg> install` |
| **Turborepo compat** | Excellent (recommended) | Good | Good |
| **Nx compat** | Excellent | Good | Good |
| **Catalogs** | Yes (v9+) | No | No |
| **Lockfile** | `pnpm-lock.yaml` | `yarn.lock` | `package-lock.json` |

| Aspect | App Router (Next.js 13+) | Pages Router (Next.js) | Fastify + SSR |
|--------|--------------------------|------------------------|---------------|
| **Entry point** | `app/layout.tsx` + `app/page.tsx` | `pages/_app.tsx` + `pages/index.tsx` | `app.ts` + `server.ts` |
| **Provider location** | `app/providers.tsx` ("use client") | `pages/_app.tsx` | Plugin registration in `app.ts` |
| **Server/client boundary** | Explicit (`"use client"` directive) | Implicit (all client by default) | All server by default |
| **Code splitting** | Automatic per route + `dynamic()` | Automatic per page + `dynamic()` | Manual (lazy plugin loading) |
| **Data fetching** | Server Components, `fetch()` | `getServerSideProps`, `getStaticProps` | Route handlers, hooks |

## Open Questions

- **AI-assisted scaffolding convergence**: How will AI code generation tools (Copilot, Cursor, Claude) change scaffolding workflows? Will declarative project manifests replace interactive CLI wizards?
- **RSC boundary automation**: Can tooling automatically detect which components need `"use client"` and generate the boundary markers, reducing manual provider wiring errors?
- **Cross-runtime scaffolding**: As Deno 2.0 and Bun stabilize npm compatibility, how should scaffolding tools handle multi-runtime targets within a single monorepo?
- **Incremental adoption patterns**: What are the best strategies for retrofitting monorepo scaffolding onto existing single-package projects without disrupting development velocity?
- **Config file proliferation**: With the rise of Biome (replacing ESLint + Prettier), how will config file generation simplify? Will single-config tools reduce the tooling config surface area?
- **Module federation in monorepos**: How does Webpack Module Federation or Vite's federation capabilities change the bundle splitting calculus for monorepo deployments?

## Sources

1. [Turborepo Documentation](https://turbo.build/repo/docs) - Official documentation for Turborepo monorepo build system, covering pipeline configuration, caching, workspace management, and `turbo gen` code generation.
2. [Nx Documentation](https://nx.dev/getting-started/intro) - Official Nx workspace documentation covering generators, plugins, project graph, affected commands, and Crystal plugins.
3. [create-t3-app Documentation](https://create.t3.gg/) - Official documentation for the T3 stack scaffolding tool, covering Next.js + TypeScript + tRPC + Prisma + NextAuth + Tailwind integration.
4. [create-t3-turbo Repository](https://github.com/t3-oss/create-t3-turbo) - Turborepo monorepo template extending the T3 stack with shared packages, tooling configs, and multi-app support.
5. [pnpm Workspaces Documentation](https://pnpm.io/workspaces) - Official pnpm workspace documentation covering workspace protocol, filtering, catalogs, and monorepo setup.
6. [Next.js App Router Documentation](https://nextjs.org/docs/app) - Official Next.js documentation for the App Router, covering layouts, server/client components, and provider patterns.
7. [Fastify Documentation](https://fastify.dev/docs/latest/) - Official Fastify framework documentation covering plugin architecture, encapsulation, decorators, and hooks.
8. [@t3-oss/env-nextjs](https://env.t3.gg/) - Type-safe environment variable validation library for Next.js, using Zod schemas with server/client separation.
9. [TypeScript Project References](https://www.typescriptlang.org/docs/handbook/project-references.html) - TypeScript documentation on project references and composite projects for monorepo type checking.
10. [Turborepo Generators Guide](https://turbo.build/repo/docs/guides/generating-code) - Guide for using `turbo gen` to scaffold new workspaces and custom code generators within Turborepo monorepos.
11. [Nx Generators Documentation](https://nx.dev/extending-nx/recipes/local-generators) - Documentation for creating custom Nx generators to encode team-specific scaffolding patterns.
12. [Vercel Monorepo Guide](https://vercel.com/docs/monorepos) - Vercel's guide for deploying monorepo applications, covering Turborepo integration and build configuration.
13. [pnpm Catalogs RFC](https://pnpm.io/catalogs) - Documentation for pnpm's catalog feature for centralized dependency version management in workspaces.
14. [tsup Documentation](https://tsup.egoist.dev/) - Documentation for tsup, a TypeScript bundler powered by esbuild, commonly used for building shared packages in monorepos.
15. [Next.js Environment Variables](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables) - Next.js documentation on .env file loading, environment variable exposure to the browser, and runtime configuration.
16. [Fastify Plugin Guide](https://fastify.dev/docs/latest/Reference/Plugins/) - Documentation on Fastify's encapsulated plugin system, including fastify-plugin for breaking encapsulation.
17. [Biome Documentation](https://biomejs.dev/) - Documentation for Biome, the Rust-based linter and formatter that can replace ESLint + Prettier with zero configuration.
18. [TypeScript 5.5 Release Notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-5/) - TypeScript 5.5 features including `--isolatedDeclarations` for parallel monorepo type checking.
19. [Nx vs Turborepo Analysis (2025)](https://nx.dev/concepts/turbo-and-nx) - Nx's comparison document detailing architectural differences between Nx and Turborepo for monorepo management.
20. [React Server Components RFC](https://github.com/reactjs/rfcs/pull/188) - The original RFC for React Server Components, foundational to understanding Next.js App Router provider wiring patterns.
21. [Zustand Documentation](https://zustand-demo.pmnd.rs/) - Documentation for Zustand state management, commonly used in T3 and Next.js stacks for client-side state.
22. [tRPC Documentation](https://trpc.io/docs) - Documentation for tRPC, the end-to-end type-safe API layer used in T3 stack and monorepo setups.
23. [NextAuth.js Documentation](https://next-auth.js.org/) - Documentation for NextAuth.js authentication library, covering provider configuration and session management in Next.js.
24. [Tailwind CSS Configuration](https://tailwindcss.com/docs/configuration) - Documentation for Tailwind CSS configuration, including content paths for monorepo setups and shared presets.
25. [ESLint Flat Config](https://eslint.org/docs/latest/use/configure/configuration-files) - Documentation for ESLint's new flat config format, relevant to shared config generation in monorepos.
26. [Vercel Turborepo Examples](https://github.com/vercel/turbo/tree/main/examples) - Official Turborepo example repositories demonstrating kitchen-sink, with-tailwind, and other monorepo patterns.
27. [Fastify CLI](https://github.com/fastify/fastify-cli) - Fastify CLI for generating project skeletons and running Fastify applications.
28. [next-themes Documentation](https://github.com/pacocoursey/next-themes) - Theme provider library for Next.js, commonly scaffolded as a provider in dark mode-enabled applications.
29. [React Query Documentation](https://tanstack.com/query/latest) - TanStack Query documentation covering provider setup and integration with tRPC in Next.js applications.
30. [Changesets Documentation](https://github.com/changesets/changesets) - Changeset-based versioning tool for monorepos, often scaffolded alongside Turborepo for package publishing workflows.

## Research Metadata

- **Date Researched:** 2026-02-10
- **Category:** dev
- **Research Size:** Deep (100 target) -- Note: Web research tools were unavailable; document generated from training knowledge
- **Search Queries Used:**
  - scaffold to project assembly automation code generation best practices
  - Turborepo pnpm workspaces monorepo setup patterns Node.js TypeScript
  - create-t3-app project scaffolding Next.js TypeScript best practices
  - Nx Turborepo comparison monorepo project scaffolding code generation
  - Next.js Fastify TypeScript project bootstrap entry point generation provider wiring
  - project scaffolding .env management config file generation automation
  - code scaffold wiring auth context theme provider state store React Next.js
  - bundle splitting strategies TypeScript monorepo tsconfig.json package.json scripts generation
  - Fastify plugin architecture encapsulation scaffold automation
  - React Server Components provider boundary patterns Next.js App Router
  - pnpm catalogs workspace protocol monorepo dependency management
  - tsup esbuild shared package building TypeScript monorepo
  - Turborepo turbo gen code generation workspace scaffolding
  - Nx generators custom scaffolding patterns enterprise teams
  - @t3-oss/env-nextjs Zod environment variable validation type safety
