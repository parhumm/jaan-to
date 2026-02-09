# Plan: Create backend-scaffold and frontend-scaffold Skills

> Saved from implementation plan | 2026-02-09

## Context

Two scaffold skills are documented in the roadmap (`docs/roadmap/tasks/role-skills/dev.md`) but not yet implemented. These are **code-generation skills** that produce production-ready backend/frontend starter code from upstream artifacts (API contracts, data models, task breakdowns, designs). They fill a gap in the dev workflow chain between planning/contract skills and integration/test skills.

**Multi-stack support**: Both skills must be tech.md-adaptive — generating code for whatever stack the project uses, not just one framework. Research covered: Node.js (Fastify), PHP (Laravel/Symfony), Go (Chi/stdlib), MySQL, WebSocket patterns.

**Research Reference**: [`63-dev-scaffolds.md`](https://github.com/parhumm/jaan-to/blob/main/jaan-to/outputs/research/63-dev-scaffolds.md) — Comprehensive blueprint for production-ready code scaffolds across all target stacks.

---

## Scope

Create **2 new skills** following v3.0.0 patterns from existing code-generation skills (`frontend-design`, `backend-api-contract`).

### Files to Create (6 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `skills/backend-scaffold/SKILL.md` | Backend scaffold skill definition |
| 2 | `skills/backend-scaffold/template.md` | Output template for scaffold documentation |
| 3 | `skills/backend-scaffold/LEARN.md` | Seed learning file |
| 4 | `skills/frontend-scaffold/SKILL.md` | Frontend scaffold skill definition |
| 5 | `skills/frontend-scaffold/template.md` | Output template for scaffold documentation |
| 6 | `skills/frontend-scaffold/LEARN.md` | Seed learning file |

### Files to Modify (1 file)

| # | File | Change |
|---|------|--------|
| 7 | `scripts/seeds/config.md` | Add both skills to Available Skills table |

---

## Critical Fixes from Verification

These issues were identified by deep verification against plugin standards:

| # | Issue | Resolution |
|---|-------|------------|
| 1 | `scaffold/` subfolder non-standard for index-updater.sh | Remove subfolder; write all files directly in `{id}-{slug}/` folder |
| 2 | Language Settings block missing from plan | Add full standard block to both SKILL.md Pre-Execution sections |
| 3 | Version lock-in in descriptions | Make adaptive: read tech.md, fall back to defaults |
| 4 | Input validation/parsing logic missing | Add Phase 1 Step 1 for validating upstream skill outputs |
| 5 | Definition of Done missing | Add explicit DoD checklists to both skills |
| 6 | LEARN.md seed needs research-informed content | Add seeded lessons per skill |
| 7 | Cross-skill input consumption not documented | Document expected formats from each upstream skill |

---

## Skill 1: backend-scaffold

### Frontmatter
```yaml
name: backend-scaffold
description: Generate production-ready backend code from specs: Fastify routes, Prisma schema, service layer, Zod validation.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/backend/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [backend-api-contract, backend-task-breakdown, backend-data-model]
```

### Context Files
```markdown
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL — determines framework, DB, patterns)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#patterns`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:backend-scaffold.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:backend-scaffold.learn.md` - Past lessons (loaded in Pre-Execution)
```

### Pre-Execution (standard v3.0.0 block)
1. Read `$JAAN_LEARN_DIR/jaan-to:backend-scaffold.learn.md` — apply lessons
2. Read `$JAAN_CONTEXT_DIR/tech.md` — know framework/DB for code generation
3. Language Settings — read `jaan-to/config/settings.yaml`, resolve language
4. Language exception note — generated code NOT affected by language setting

### Input Handling
Accepts 1-3 file paths or descriptions:
- **backend-api-contract** — Path to OpenAPI YAML (from `/jaan-to:backend-api-contract` output: `api.yaml`)
- **backend-task-breakdown** — Path to BE task breakdown markdown (from `/jaan-to:backend-task-breakdown` output)
- **backend-data-model** — Path to data model markdown (from `/jaan-to:backend-data-model` output)
- **Empty** — Interactive wizard prompting for each

### Phase 1 Steps
1. **Validate & Parse Inputs** — For each provided path:
   - backend-api-contract: Read api.yaml, extract paths, schemas, error responses, security schemes
   - backend-task-breakdown: Read markdown, extract task list, entity names, reliability patterns
   - backend-data-model: Read markdown, extract table definitions, constraints, indexes, relations
   - Report which inputs found vs missing; suggest fallback for missing (e.g., CRUD from backend-data-model if no API contract)
2. **Detect Tech Stack** — Read `$JAAN_CONTEXT_DIR/tech.md`:
   - Extract framework from `#current-stack` (default: Fastify v4+)
   - Extract DB from `#current-stack` (default: PostgreSQL)
   - Extract patterns from `#patterns` (auth, error handling, logging)
   - If tech.md missing: ask framework/DB via AskUserQuestion
3. **Clarify Architecture** — AskUserQuestion for items not in tech.md:
   - Project structure (monolith / modular monolith / microservice)
   - Auth middleware pattern (JWT / API key / session / none)
   - Error handling depth (basic / full RFC 9457 with error taxonomy)
   - Logging (structured JSON pino / winston / none)
4. **Plan Scaffold Structure** — Present directory tree, file list, resource count
5. **HARD STOP** — User approves before generation

### Phase 2 Output — Flat folder (no `scaffold/` subfolder)
All files in `$JAAN_OUTPUTS_DIR/dev/backend/{id}-{slug}/`:

```
{id}-{slug}/
├── {id}-backend-scaffold-{slug}.md                    # Main doc (setup guide + architecture)
├── {id}-backend-scaffold-routes-{slug}.ts              # Fastify route handlers (all resources)
├── {id}-backend-scaffold-services-{slug}.ts            # Service layer (business logic)
├── {id}-backend-scaffold-schemas-{slug}.ts             # Zod validation schemas
├── {id}-backend-scaffold-middleware-{slug}.ts           # Auth + error handling middleware
├── {id}-backend-scaffold-prisma-{slug}.prisma          # Prisma data model
├── {id}-backend-scaffold-config-{slug}.ts              # Package.json + tsconfig content
└── {id}-backend-scaffold-readme-{slug}.md              # Setup + run instructions
```

### Key Generation Rules (Research-Informed)
- **Routing**: Use `@fastify/autoload` for file-based route loading — register twice (plugins with `encapsulate: false`, routes encapsulated per resource)
- **Type Provider**: Use `fastify-type-provider-zod` with `validatorCompiler`/`serializerCompiler` for full type inference; must call `withTypeProvider<ZodTypeProvider>()` on each encapsulated context
- **Prisma Singleton**: Use `globalThis` pattern to prevent connection pool exhaustion during hot-reload
- **Zod Schemas**: Define schemas in `.schema.ts` files, export `z.infer<>` types; derive from OpenAPI contract component schemas
- **Error Handler**: Use Fastify's `setErrorHandler` (NOT Express-style middleware) — map `ZodError` to 400, `PrismaClientKnownRequestError` P2002 to 409 Conflict, P2025 to 404, all others to 500; always set `Content-Type: application/problem+json`
- **RFC 9457 Fields**: `type` (URI), `title`, `status`, `detail`, `instance`; extension `errors[]` for validation details
- **Service Layer**: Function-based services with Prisma client passed as parameter (enables testability without DI container); use Prisma `$transaction` for cross-service operations
- **Route Structure**: Collocated `index.ts` (routes) + `{resource}.schema.ts` (Zod) + `{resource}.service.ts` (logic) per resource
- **TypeScript**: Extend `fastify-tsconfig` with `target: "ES2023"`, `module: "NodeNext"`, `strict: true`
- **Env Vars**: Parameterize `DATABASE_URL`, `PORT`, `HOST`, `NODE_ENV`, `LOG_LEVEL`, `CORS_ORIGIN`
- **Scripts**: `dev` (tsx watch), `build` (tsc), `start`, `lint`, `test`, `db:generate`, `db:migrate:dev`, `db:migrate:deploy`, `db:push`, `db:seed`, `db:studio`, `postinstall` (prisma generate)

### Multi-Stack Support (Research-Informed)

The skill reads tech.md `#current-stack` to determine which stack to generate:

| tech.md value | Framework | ORM/DB | Validation | Output |
|---------------|-----------|--------|------------|--------|
| Node.js / TypeScript | Fastify v4+ | Prisma | Zod + type-provider | `.ts` files |
| PHP | Laravel 12 / Symfony 7 | Eloquent / Doctrine | Form Requests / Symfony Validator | `.php` files |
| Go | Chi / stdlib (Go 1.22+) | sqlc / GORM | go-playground/validator | `.go` files |

**PHP Stack (Laravel) — Key Patterns:**
- PSR-4 autoloading, single `public/index.php` entry point
- Route model binding + Form Requests for validation
- Eloquent Active Record with `utf8mb4`, BIGINT PKs, JSON columns
- API Resources for response shaping (never expose raw models)
- Sanctum for auth (SPA cookies + API tokens)
- Pest for testing, RFC 9457 via `crell/api-problem`
- Zero-downtime MySQL migrations: expand-contract pattern

**PHP Stack (Symfony) — Key Patterns:**
- API Platform for OpenAPI-first development
- Doctrine Data Mapper ORM, DTOs for request/response shaping
- Symfony Validator with constraint annotations
- JWT via `lexik/jwt-authentication-bundle`

**Go Stack — Key Patterns:**
- Feature-based `internal/` package organization
- Interface-driven design with constructor injection
- sqlc for type-safe SQL, golang-migrate for migrations
- go-playground/validator v10, RFC 9457 via custom `ProblemDetail` struct
- Table-driven tests + httptest, Docker multi-stage builds
- `oapi-codegen` for OpenAPI server interfaces, graceful shutdown with `signal.NotifyContext`

**WebSocket Support (Optional — all stacks):**
- **Go**: coder/websocket, Hub pattern
- **Node.js**: ws / Socket.IO
- **PHP**: Ratchet / Swoole
- Auth: ephemeral single-use token via query parameter
- SSE handles 80% of real-time use cases — suggest SSE first

### Anti-Patterns to NEVER Generate

**All Stacks:** Business logic in route handlers, hardcoded secrets, missing `.gitignore`, no error handling

**Node.js:** Direct Prisma calls in handlers, multiple PrismaClient instances, `any` types, Express-style error middleware, missing response serialization schemas

**PHP:** Fat controllers, N+1 queries, exposing raw Eloquent models, `env()` outside config files, `utf8` instead of `utf8mb4`

**Go:** Generic package names (`utils/`), global database connections, ignoring errors, unlimited connection pool, goroutine leaks

### Package Dependencies (Research-Validated)
**Production**: `fastify` ^4.28, `@fastify/autoload` ^6, `@fastify/cors` ^10, `@fastify/sensible` ^6, `@fastify/swagger` ^9, `@fastify/swagger-ui` ^5, `@prisma/client` ^6, `fastify-plugin` ^5, `fastify-type-provider-zod` ^4, `zod` ^3.24
**Dev**: `typescript` ^5.6, `@types/node` ^22, `fastify-tsconfig` ^2, `prisma` ^6, `tsx` ^4, `vitest` ^2, `eslint` ^9

### Definition of Done
- [ ] All API endpoints from contract have route handlers
- [ ] All entities from data model have Prisma models
- [ ] Zod schemas generated for all request bodies
- [ ] Error handler covers ZodError, Prisma errors, and generic errors
- [ ] Service layer stubs exist for all business logic
- [ ] Prisma singleton + `onClose` disconnect configured
- [ ] Setup README is complete and actionable
- [ ] Output follows v3.0.0 structure (ID, folder, index)
- [ ] Index updated with executive summary
- [ ] User approved final result

---

## Skill 2: frontend-scaffold

### Frontmatter
```yaml
name: frontend-scaffold
description: Convert designs to React/Next.js components with TailwindCSS, TypeScript, and typed API client hooks.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/frontend/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [frontend-design, frontend-task-breakdown, backend-api-contract]
```

### Context Files
```markdown
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL — determines framework, styling, versions)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_CONTEXT_DIR/design.md` - Design system guidelines (optional)
- `$JAAN_CONTEXT_DIR/brand.md` - Brand guidelines (optional)
- `$JAAN_TEMPLATES_DIR/jaan-to:frontend-scaffold.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:frontend-scaffold.learn.md` - Past lessons (loaded in Pre-Execution)
```

### Pre-Execution (standard v3.0.0 block)
1. Read `$JAAN_LEARN_DIR/jaan-to:frontend-scaffold.learn.md` — apply lessons
2. Read `$JAAN_CONTEXT_DIR/tech.md` — know framework/styling for code generation
3. Read `$JAAN_CONTEXT_DIR/design.md` — design system patterns (optional)
4. Language Settings — read `jaan-to/config/settings.yaml`, resolve language
5. Language exception note — generated code NOT affected by language setting

### Input Handling
Accepts 1-3 file paths or descriptions:
- **frontend-design** — Path to HTML preview or component description (from `/jaan-to:frontend-design` output)
- **frontend-task-breakdown** — Path to FE task breakdown (from `/jaan-to:frontend-task-breakdown` output)
- **backend-api-contract** — Path to OpenAPI YAML (from `/jaan-to:backend-api-contract` output)
- **Empty** — Interactive wizard
- Cross-role: optionally consumes `/jaan-to:ux-microcopy-write` output

### Phase 1 Steps
1. **Validate & Parse Inputs**
2. **Detect Tech Stack** (default: React v19 + Next.js v15 + TailwindCSS v4)
3. **Design System Check**
4. **Clarify Architecture** (state management, routing, testing, responsive)
5. **Plan Component Tree**
6. **HARD STOP** — User approves before generation

### Phase 2 Output — Flat folder
All files in `$JAAN_OUTPUTS_DIR/dev/frontend/{id}-{slug}/`:

```
{id}-{slug}/
├── {id}-frontend-scaffold-{slug}.md                     # Main doc (architecture + component map)
├── {id}-frontend-scaffold-components-{slug}.tsx          # React components
├── {id}-frontend-scaffold-hooks-{slug}.ts               # Typed API client hooks
├── {id}-frontend-scaffold-types-{slug}.ts               # TypeScript interfaces from API schemas
├── {id}-frontend-scaffold-pages-{slug}.tsx               # Page layouts / routes
├── {id}-frontend-scaffold-config-{slug}.ts              # Package.json + tsconfig + tailwind config
└── {id}-frontend-scaffold-readme-{slug}.md              # Setup + run instructions
```

### Key Generation Rules (Research-Informed)

**React 19 Patterns (CRITICAL — differs from React 18):**
- Server Components are default — only add `'use client'` when needed
- `async/await` in Server Components, NOT `useEffect` + `useState`
- `use(promise)` with Suspense, NOT `useEffect`
- `ref` is a regular prop, NOT `forwardRef`
- React Compiler handles memoization — no `useMemo`/`useCallback`/`React.memo`
- `useActionState` + `useFormStatus` (in child component) for forms
- Server Actions for mutations, ES6 default parameters (NOT `defaultProps`)

**TailwindCSS v4 Patterns:**
- CSS-first config: `@import "tailwindcss"` + `@theme { }` — NO `tailwind.config.js`
- Dark mode: `@custom-variant dark` + `next-themes`
- `cn()` helper (clsx + tailwind-merge), OKLCH colors

**Component Generation:**
- 4 states per data component: loading, error, empty, success
- Atomic Design: Atoms -> Molecules -> Organisms -> Templates
- Feature-based organization, `aria-*` on all interactive elements
- Minimum 44x44px touch targets (WCAG 2.2)

**API Integration:**
- Orval for TypeScript types from OpenAPI
- TanStack Query v5 for client-side fetching
- `HydrationBoundary` for RSC → client data handoff
- Separate generated API code into `src/lib/api/generated/`

**State Management:**
- Server/API data → TanStack Query v5
- Local state → `useState`/`useReducer`
- Global client state → Zustand (no Provider needed)
- URL state → `nuqs` or `useSearchParams`
- Form state → `useActionState` + `useFormStatus`
- Optimistic UI → `useOptimistic`

### Anti-Patterns to NEVER Generate
**React 19**: `useEffect` for data fetching, `forwardRef`, manual memoization, `defaultProps`, `PropTypes`
**Next.js 15**: `'use client'` everywhere, API routes for internal mutations, `unstable_cache`, `next lint`
**TailwindCSS v4**: `tailwind.config.js`, dynamic class construction, `@tailwind` directives
**Accessibility**: `<div onClick>`, missing `alt`, color-only indicators, missing form labels

### Package Dependencies (Research-Validated)
**Production**: `react` ^19, `react-dom` ^19, `next` ^15, `@tanstack/react-query` ^5.60, `zustand` ^5, `next-themes` ^0.4, `clsx` ^2.1, `tailwind-merge` ^2.6, `zod` ^3.23, `axios` ^1.7
**Dev**: `typescript` ^5.7, `@types/react` ^19, `@types/node` ^22, `@tailwindcss/postcss` ^4, `tailwindcss` ^4, `eslint` ^9, `prettier` ^3.4, `orval` ^8, `vitest` ^2, `@testing-library/react` ^16

### Definition of Done
- [ ] All components from frontend-task-breakdown inventory generated
- [ ] Server Components default; `'use client'` only where needed
- [ ] TypeScript interfaces from API contract schemas
- [ ] TanStack Query hooks for client-side data fetching
- [ ] Loading/error/empty/success states on all data components
- [ ] Accessibility: ARIA, semantic HTML, keyboard nav
- [ ] TailwindCSS v4 CSS-first config
- [ ] Responsive mobile-first breakpoints
- [ ] Setup README complete
- [ ] Output follows v3.0.0 structure
- [ ] User approved final result

---

## LEARN.md Seeds

### backend-scaffold
- **Better Questions**: idempotency keys, repository vs direct ORM, WebSocket vs SSE, relation strategies, zero-downtime migrations
- **Edge Cases**: endpoints without data model coverage, uncovered audit tables, middleware gaps, Prisma error codes, Zod type provider scoping, MySQL DDL limitations, Go connection pooling
- **Workflow**: tech.md first, backend-api-contract → backend-data-model → backend-task-breakdown order, SSE before WebSocket
- **Common Mistakes**: wrong framework code, Express-style errors in Fastify, multiple Prisma instances, raw Eloquent models, N+1 queries, env() outside config, global Go DB connections

### frontend-scaffold
- **Better Questions**: feature-scoped vs atomic, SSR vs client-only, Orval vs openapi-typescript, Server Actions vs client API calls
- **Edge Cases**: component count conflicts between inputs, API contract newer than design, useFormStatus child requirement, Next.js 15 no-cache default
- **Workflow**: frontend-task-breakdown → frontend-design → backend-api-contract order, types before components, Server Components for data fetching
- **Common Mistakes**: useEffect for fetching, forwardRef, manual memoization, tailwind.config.js, @tailwind directives, 'use client' everywhere, unstable_cache, next lint

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `backend-api-contract` | Upstream — provides OpenAPI YAML consumed by both scaffold skills |
| `backend-data-model` | Upstream — provides data model consumed by BE scaffold |
| `backend-task-breakdown` | Upstream — provides task list consumed by BE scaffold |
| `frontend-task-breakdown` | Upstream — provides component inventory consumed by FE scaffold |
| `frontend-design` | Upstream — provides HTML previews consumed by FE scaffold |
| `dev-integration-plan` | Downstream — suggested next step after scaffold |
| `dev-test-plan` | Downstream — suggested next step after scaffold |
