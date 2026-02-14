# Plan: Create backend-scaffold and frontend-scaffold Skills

> Saved from implementation plan | 2026-02-09
> Optimized against research `63-dev-scaffolds.md` | 2026-02-09

## Context

Two scaffold skills are documented in the roadmap (`docs/roadmap/tasks/role-skills/dev.md`) but not yet implemented. These are **code-generation skills** that produce production-ready backend/frontend starter code from upstream artifacts (API contracts, data models, task breakdowns, designs). They fill a gap in the dev workflow chain between planning/contract skills and integration/test skills.

**Multi-stack support**: Both skills must be tech.md-adaptive — generating code for whatever stack the project uses, not just one framework. Research covered: Node.js (Fastify v5), PHP (Laravel/Symfony), Go (Chi/stdlib), MySQL, WebSocket patterns.

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

These issues were identified by deep verification against plugin standards and research alignment:

| # | Issue | Resolution |
|---|-------|------------|
| 1 | `scaffold/` subfolder non-standard for index-updater.sh | Remove subfolder; write all files directly in `{id}-{slug}/` folder |
| 2 | Language Settings block missing from plan | Add full standard block to both SKILL.md Pre-Execution sections |
| 3 | Version lock-in in descriptions | Make adaptive: read tech.md, fall back to defaults |
| 4 | Input validation/parsing logic missing | Add Phase 1 Step 1 for validating upstream skill outputs |
| 5 | Definition of Done missing | Add explicit DoD checklists to both skills |
| 6 | LEARN.md seed needs research-informed content | Add seeded lessons per skill |
| 7 | Cross-skill input consumption not documented | Document expected formats from each upstream skill |
| 8 | Fastify v4 retired (June 2025); plan targeted dead version | Update all references to Fastify v5+ |
| 9 | `fastify-type-provider-zod` 2 major versions behind | Update ^4 → ^6.1; use v6 error helpers |
| 10 | Go stack has zero generation rules | Add full Go Generation Rules subsection |
| 11 | Symfony stack has zero generation rules | Add API Platform + Doctrine patterns |
| 12 | `Write()` path doesn't match output path | Fix both frontmatter to `Write($JAAN_OUTPUTS_DIR/dev/**)` |
| 13 | Phase 2 missing step-by-step structure | Add Steps 6-13 matching existing skill patterns |

---

## Skill 1: backend-scaffold

### Frontmatter
```yaml
name: backend-scaffold
description: Generate production-ready backend code from specs: routes, data model, service layer, validation.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/dev/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
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

### Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `backend-scaffold`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Know the tech stack for framework-specific code generation
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration

#### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_backend-scaffold` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

### Input Handling
Accepts 1-3 file paths or descriptions:
- **backend-api-contract** — Path to OpenAPI YAML (from `/jaan-to:backend-api-contract` output: `api.yaml`)
- **backend-task-breakdown** — Path to BE task breakdown markdown (from `/jaan-to:backend-task-breakdown` output)
- **backend-data-model** — Path to data model markdown (from `/jaan-to:backend-data-model` output)
- **Empty** — Interactive wizard prompting for each

### Phase 1 Steps

#### Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing upstream artifacts to derive code structure
- Mapping API contract schemas to framework-native patterns
- Planning multi-stack generation strategy
- Identifying edge cases in input parsing

#### Step 1: Validate & Parse Inputs
For each provided path:
- backend-api-contract: Read api.yaml, extract paths, schemas, error responses, security schemes
- backend-task-breakdown: Read markdown, extract task list, entity names, reliability patterns
- backend-data-model: Read markdown, extract table definitions, constraints, indexes, relations
- Report which inputs found vs missing; suggest fallback for missing (e.g., CRUD from backend-data-model if no API contract)

#### Step 2: Detect Tech Stack
Read `$JAAN_CONTEXT_DIR/tech.md`:
- Extract framework from `#current-stack` (default: Fastify v5+)
- Extract DB from `#current-stack` (default: PostgreSQL)
- Extract patterns from `#patterns` (auth, error handling, logging)
- If tech.md missing: ask framework/DB via AskUserQuestion

#### Step 3: Clarify Architecture
AskUserQuestion for items not in tech.md:
- Project structure (monolith / modular monolith / microservice)
- Auth middleware pattern (JWT / API key / session / none)
- Error handling depth (basic / full RFC 9457 with error taxonomy)
- Logging (structured JSON pino / winston / none)

#### Step 4: Plan Scaffold Structure
Present directory tree, file list, resource count

#### Step 5: HARD STOP
User approves before generation

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

### Phase 2 Steps

#### Step 6: Generate Content
Read `$JAAN_TEMPLATES_DIR/jaan-to:backend-scaffold.template.md` and populate all sections based on Phase 1 analysis.

#### Step 7: Quality Check
Validate generated output against checklist:
- [ ] All API endpoints from contract have route handlers
- [ ] All entities from data model have ORM models
- [ ] Validation schemas generated for all request bodies
- [ ] Error handler covers validation, ORM, and generic errors
- [ ] Service layer stubs exist for all business logic
- [ ] DB singleton + graceful disconnect configured
- [ ] No anti-patterns present in generated code

#### Step 8: Preview & Approval
Present generated output summary. Use AskUserQuestion:
- Question: "Write scaffold files to output?"
- Header: "Write Files"
- Options: "Yes" — Write the files / "No" — Cancel / "Refine" — Make adjustments first

#### Step 9: Generate ID and Folder Structure
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/dev/backend"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{project-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

#### Step 10: Write Output
1. Create output folder: `mkdir -p "$OUTPUT_FOLDER"`
2. Write all scaffold files to `$OUTPUT_FOLDER`
3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Project Title}" \
  "{Executive summary — 1-2 sentences}"
```

#### Step 11: Suggest Next Actions
> **Scaffold generated successfully!**
>
> **Next Steps:**
> - Copy scaffold files to your project directory
> - Run `npm install` (or equivalent) to install dependencies
> - Run `/jaan-to:dev-integration-plan` to plan integration with existing code
> - Run `/jaan-to:dev-test-plan` to generate test plan

#### Step 12: Capture Feedback
Use AskUserQuestion:
- Question: "How did the scaffold turn out?"
- Header: "Feedback"
- Options: "Perfect!" — Done / "Needs fixes" — What should I improve? / "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add backend-scaffold "{feedback}"`

### Key Generation Rules — Node.js/TypeScript (Research-Informed)
- **Routing**: Use `@fastify/autoload` v6 for file-based route loading — register twice (plugins with `encapsulate: false`, routes encapsulated per resource); add `ignorePattern: /.*\.(?:schema|service)\.ts/` to prevent non-plugin files from being auto-loaded as routes
- **Type Provider**: Use `fastify-type-provider-zod` v6.1+ with `validatorCompiler`/`serializerCompiler` set once at app level; must call `withTypeProvider<ZodTypeProvider>()` on each encapsulated context (type providers don't propagate across encapsulation boundaries)
- **Prisma Singleton**: Use `globalThis` pattern to prevent connection pool exhaustion during hot-reload; conditional assignment based on `NODE_ENV`
- **Zod Schemas**: Define schemas in `.schema.ts` files, export `z.infer<>` types; derive from OpenAPI contract component schemas
- **Error Handler**: Use Fastify's `setErrorHandler` (NOT Express-style middleware) — use `hasZodFastifySchemaValidationErrors(error)` for 400 (NOT `instanceof ZodError` which fails across module boundaries), use `isResponseSerializationError(error)` for 500 serialization errors; map `PrismaClientKnownRequestError` P2002 → 409 (unique constraint), P2003 → 409 (foreign key), P2025 → 404 (not found), all others → 500; always set `Content-Type: application/problem+json`
- **RFC 9457 Fields**: `type` (URI), `title`, `status`, `detail`, `instance`; extension `errors[]` for validation details
- **Service Layer**: Plain exported functions importing the Prisma singleton — module caching acts as built-in singleton, making DI containers (tsyringe, inversify) unnecessary; testable via `vi.mock()`; callable from CRON jobs or queue consumers outside HTTP context; use Prisma `$transaction` for cross-service operations
- **Route Structure**: Collocated `index.ts` (routes) + `{resource}.schema.ts` (Zod) + `{resource}.service.ts` (logic) per resource
- **TypeScript**: Extend `fastify-tsconfig` v2 with `target: "ES2023"`, `module: "NodeNext"`, `strict: true`
- **Import Extensions**: With `"type": "module"` and `moduleResolution: "NodeNext"`, all imports MUST include `.js` extensions — `NodeNext` mirrors Node.js runtime behavior; never use `moduleResolution: "bundler"` for backends (allows vague imports that fail at runtime)
- **Env Vars**: Parameterize `DATABASE_URL`, `PORT`, `HOST`, `NODE_ENV`, `LOG_LEVEL`, `CORS_ORIGIN`
- **Env Validation**: Validate environment variables with Zod at startup — crash immediately on missing/invalid variables; use Node.js 20.6+ `--env-file=.env` flag for loading
- **Scripts**: `dev` (tsx watch), `build` (tsc), `start`, `lint`, `test`, `db:generate`, `db:migrate:dev`, `db:migrate:deploy`, `db:push`, `db:seed`, `db:studio`, `postinstall` (prisma generate)

### Multi-Stack Support (Research-Informed)

The skill reads tech.md `#current-stack` to determine which stack to generate:

| tech.md value | Framework | ORM/DB | Validation | Output |
|---------------|-----------|--------|------------|--------|
| Node.js / TypeScript | Fastify v5+ | Prisma | Zod + type-provider v6.1 | `.ts` files |
| PHP | Laravel 12 / Symfony 7 | Eloquent / Doctrine | Form Requests / Symfony Validator | `.php` files |
| Go | Chi / stdlib (Go 1.22+) | sqlc / GORM | go-playground/validator | `.go` files |

**PHP Stack (Laravel) — Key Patterns:**
- PSR-4 autoloading, single `public/index.php` entry point
- Route model binding + Form Requests for validation (`$request->validated()`, never `$request->all()`)
- Eloquent Active Record with `utf8mb4`, BIGINT PKs, JSON columns
- **Strictness in `AppServiceProvider::boot()`**: `preventLazyLoading()` (catches N+1), `preventSilentlyDiscardingAttributes()` (catches mass assignment typos), `preventAccessingMissingAttributes()`; in production, lazy loading violations log instead of throwing
- API Resources for response shaping (never expose raw models); use `whenLoaded()`, `whenCounted()`, conditional `when()` helpers
- Sanctum for auth (SPA cookies + API tokens); cookie auth requires `SANCTUM_STATEFUL_DOMAINS` and `supports_credentials: true`
- Pest 3/4 for testing with architecture presets (`arch()->preset()->laravel()`) and mutation testing (`--mutate`)
- RFC 9457 via `crell/api-problem` v3.8.0 (PHP ^8.3)
- Zero-downtime MySQL migrations: expand-contract pattern (add nullable → backfill → deploy → drop old); use `daursu/laravel-zero-downtime-migration` for large tables

**PHP Stack (Symfony) — Key Patterns:**
- API Platform v4.x: `#[ApiResource]` annotations for automatic CRUD REST APIs with OpenAPI documentation
- Doctrine Data Mapper ORM: entities are POPOs, persistence via EntityManager (better separation than Active Record)
- DTOs with `#[MapRequestPayload]` and Symfony Validator constraint attributes (`#[Assert\NotBlank]`, `#[Assert\Positive]`)
- JWT via `lexik/jwt-authentication-bundle` v3.2.0 with RS256 signing + `gesdinet/jwt-refresh-token-bundle` for refresh tokens

**Go Stack — Generation Rules:**
- **Routing**: Go 1.22+ `net/http.ServeMux` with method+wildcard patterns (`GET /users/{id}`, `r.PathValue("id")`); use Chi v5.2.x only for middleware grouping/subrouters; avoid gorilla/mux (archived 2023), Gin/Fiber (diverge from `net/http` idioms)
- **Structure**: Feature-based `internal/` packages (`internal/user/handler.go`, `service.go`, `repository.go`); avoid layer-based `internal/handlers/` anti-pattern (excessive cross-package imports); shallow hierarchies (1-2 levels)
- **DI**: Constructor injection with small interfaces (1-3 methods) defined at consumer site; accept interfaces, return structs; wire manually in `main.go`; manual DI preferred over Wire/Dig except for very large projects
- **Database**: sqlc generates type-safe Go code from annotated SQL queries (`-- name: GetUser :one`); golang-migrate for sequential numbered up/down migration files
- **Validation**: go-playground/validator v10 (v10.27.0) with struct tags (`validate:"required,email"`); single instance (caches struct info); `WithRequiredStructEnabled()` for v11 compatibility; `RegisterTagNameFunc()` for JSON field names
- **OpenAPI**: oapi-codegen v2 generates Go types, server interfaces, and request validation middleware; developers implement `ServerInterface`; YAML config with Chi/stdlib backend support
- **Error Handling**: RFC 9457 via custom `ProblemDetail` struct; `Content-Type: application/problem+json`
- **Testing**: Table-driven tests with `httptest.NewRecorder()` + `httptest.NewRequest()`; `t.Run()` subtests; `t.Parallel()` for concurrent execution
- **Docker**: Multi-stage builds → 10-20MB images using `distroless/static-debian12`; `CGO_ENABLED=0` for static binaries; `-ldflags="-s -w"` to strip debug info
- **Graceful Shutdown**: `signal.NotifyContext` with 10-second timeout, closing HTTP server and database connections

**WebSocket Support (Optional — all stacks):**
- **Go**: coder/websocket, Hub pattern for connection management
- **Node.js**: ws / Socket.IO
- **PHP**: Ratchet / Swoole
- Auth: ephemeral single-use token via query parameter (`ws://host/ws?ticket=abc123`); 30-second TTL, consumed on first use to prevent log-exposure attacks
- SSE handles 95% of real-time use cases — suggest SSE first; SSE works over standard HTTP, supports auto-reconnection, multiplexed over HTTP/2

### Anti-Patterns to NEVER Generate

**All Stacks:** Business logic in route handlers, hardcoded secrets, missing `.gitignore`, no error handling

**Node.js:** Direct Prisma calls in handlers, multiple PrismaClient instances, `any` types, Express-style error middleware, missing response serialization schemas, `instanceof ZodError` (use v6 helpers), missing `.js` extensions in ESM imports, `moduleResolution: "bundler"` for backends

**PHP:** Fat controllers, N+1 queries, exposing raw Eloquent models, `env()` outside config files, `utf8` instead of `utf8mb4`, missing Eloquent strictness modes

**Go:** Generic package names (`utils/`), global database connections, ignoring errors, unlimited connection pool, goroutine leaks, layer-based `internal/handlers/` structure

### Package Dependencies (Research-Validated)

**Node.js/TypeScript:**
- **Production**: `fastify` ^5.7, `@fastify/autoload` ^6, `@fastify/cors` ^10, `@fastify/sensible` ^6, `@fastify/swagger` ^9, `@fastify/swagger-ui` ^5, `@prisma/client` ^6, `fastify-plugin` ^5, `fastify-type-provider-zod` ^6.1, `zod` ^3.24
- **Dev**: `typescript` ^5.6, `@types/node` ^22, `fastify-tsconfig` ^2, `prisma` ^6, `tsx` ^4, `vitest` ^2, `eslint` ^9

**Go:** `chi` v5.2.x (optional), `go-playground/validator` v10, `golang-migrate`, `sqlc`, `oapi-codegen` v2

**PHP (Laravel):** `laravel/sanctum`, `crell/api-problem` ^3.8, `pestphp/pest` ^3

**PHP (Symfony):** `api-platform/core` ^4, `lexik/jwt-authentication-bundle` ^3.2, `gesdinet/jwt-refresh-token-bundle`

### Definition of Done
- [ ] All API endpoints from contract have route handlers
- [ ] All entities from data model have ORM models (Prisma/Eloquent/Doctrine/sqlc)
- [ ] Validation schemas generated for all request bodies
- [ ] Error handler covers validation errors, ORM errors, and generic errors
- [ ] Service layer stubs exist for all business logic
- [ ] DB singleton + graceful disconnect configured
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
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/dev/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
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

### Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `frontend-scaffold`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Know the tech stack for framework-specific code generation
- `$JAAN_CONTEXT_DIR/design.md` — Know the design system patterns
- `$JAAN_CONTEXT_DIR/brand.md` — Know brand colors, fonts, tone

#### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_frontend-scaffold` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

### Input Handling
Accepts 1-3 file paths or descriptions:
- **frontend-design** — Path to HTML preview or component description (from `/jaan-to:frontend-design` output)
- **frontend-task-breakdown** — Path to FE task breakdown (from `/jaan-to:frontend-task-breakdown` output)
- **backend-api-contract** — Path to OpenAPI YAML (from `/jaan-to:backend-api-contract` output)
- **Empty** — Interactive wizard
- Cross-role: optionally consumes `/jaan-to:ux-microcopy-write` output

### Phase 1 Steps

#### Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing design artifacts to derive component architecture
- Mapping API contract schemas to TypeScript interfaces and hooks
- Planning Server Component vs Client Component boundaries
- Identifying accessibility requirements per component

#### Step 1: Validate & Parse Inputs

#### Step 2: Detect Tech Stack
Default: React v19 + Next.js v15 + TailwindCSS v4

#### Step 3: Design System Check

#### Step 4: Clarify Architecture
State management, routing, testing, responsive strategy

#### Step 5: Plan Component Tree

#### Step 6: HARD STOP
User approves before generation

### Phase 2 Output — Flat folder
All files in `$JAAN_OUTPUTS_DIR/frontend/scaffold/{id}-{slug}/`:

```
{id}-{slug}/
├── {id}-{slug}.md                                       # Main doc (architecture + component map)
├── {id}-{slug}-components.tsx                            # React components
├── {id}-{slug}-hooks.ts                                 # Typed API client hooks
├── {id}-{slug}-types.ts                                 # TypeScript interfaces from API schemas
├── {id}-{slug}-pages.tsx                                # Page layouts / routes
├── {id}-{slug}-config.ts                                # Package.json + tsconfig + tailwind config
└── {id}-{slug}-readme.md                                # Setup + run instructions
```

### Phase 2 Steps

#### Step 7: Generate Content
Read `$JAAN_TEMPLATES_DIR/jaan-to:frontend-scaffold.template.md` and populate all sections based on Phase 1 analysis.

#### Step 8: Quality Check
Validate generated output against checklist:
- [ ] All components from task breakdown inventory generated
- [ ] Server Components default; `'use client'` only where needed
- [ ] TypeScript interfaces match API contract schemas
- [ ] TanStack Query hooks for client-side data fetching
- [ ] Loading/error/empty/success states on all data components
- [ ] Accessibility: ARIA, semantic HTML, keyboard nav
- [ ] No anti-patterns present in generated code

#### Step 9: Preview & Approval
Present generated output summary. Use AskUserQuestion:
- Question: "Write scaffold files to output?"
- Header: "Write Files"
- Options: "Yes" — Write the files / "No" — Cancel / "Refine" — Make adjustments first

#### Step 10: Generate ID and Folder Structure
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/frontend/scaffold"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{project-name-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

#### Step 11: Write Output
1. Create output folder: `mkdir -p "$OUTPUT_FOLDER"`
2. Write all scaffold files to `$OUTPUT_FOLDER`
3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Project Title}" \
  "{Executive summary — 1-2 sentences}"
```

#### Step 12: Suggest Next Actions
> **Scaffold generated successfully!**
>
> **Next Steps:**
> - Copy scaffold files to your project directory
> - Run `npm install` to install dependencies
> - Run `/jaan-to:dev-integration-plan` to plan integration with existing code
> - Run `/jaan-to:dev-test-plan` to generate test plan
> - Run `/jaan-to:qa-test-cases` to generate test cases

#### Step 13: Capture Feedback
Use AskUserQuestion:
- Question: "How did the scaffold turn out?"
- Header: "Feedback"
- Options: "Perfect!" — Done / "Needs fixes" — What should I improve? / "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add frontend-scaffold "{feedback}"`

### Key Generation Rules (Research-Informed)

**React 19 Patterns (CRITICAL — differs from React 18):**
- Server Components are default — only add `'use client'` when needed
- `async/await` in Server Components, NOT `useEffect` + `useState`
- `use(promise)` with Suspense, NOT `useEffect`; never create promises during render (infinite loops)
- `ref` is a regular prop, NOT `forwardRef`
- React Compiler (stable v1.0, October 2025) handles memoization — no `useMemo`/`useCallback`/`React.memo`; enable in `next.config.ts` with `{ reactCompiler: true }`; up to 12% faster initial loads
- `useActionState` + `useFormStatus` (must be in **child component** of `<form>`) for forms
- Server Actions for mutations, ES6 default parameters (NOT `defaultProps`)
- `<Context.Provider>` deprecated — use `<Context>` directly
- `ref` callbacks support cleanup functions

**TailwindCSS v4 Patterns:**
- CSS-first config: `@import "tailwindcss"` + `@theme { }` — NO `tailwind.config.js`
- Dark mode: `@custom-variant dark (&:where(.dark, .dark *))` + `next-themes`
- `cn()` helper (clsx + tailwind-merge), OKLCH colors
- **v3→v4 breaking syntax**: `!bg-red-500` → `bg-red-500!` (suffix), `@layer utilities` → `@utility`, `bg-[--my-var]` → `bg-(--my-var)`; requires Safari 16.4+, Chrome 111+, Firefox 128+
- PostCSS uses `@tailwindcss/postcss` as single plugin — autoprefixer is built-in
- Content detection is automatic (no `content` array)

**Component Generation:**
- 4 states per data component: loading, error, empty, success
- Atomic Design: Atoms -> Molecules -> Organisms -> Templates
- Feature-based organization, `aria-*` on all interactive elements
- Minimum 24x24px touch targets (WCAG 2.2 AA); 44x44px recommended (AAA / mobile guideline)
- Use semantic HTML (`<button>`, `<nav>`, `<main>`) before ARIA; enforce with `eslint-plugin-jsx-a11y`

**API Integration:**
- **Orval** v7 for TypeScript types + TanStack Query hooks from OpenAPI (ready-to-use `useQuery`/`useMutation` with auto-generated keys)
- **Alternative**: `openapi-typescript` (~1.68M weekly downloads) generates only TypeScript types with zero runtime; companion `openapi-fetch` provides type-safe `createClient<paths>()` wrapper; requires manually writing TanStack Query hooks but offers more control
- TanStack Query v5 for client-side fetching; `HydrationBoundary` for RSC → client data handoff (prefetch with `queryClient.prefetchQuery()`, dehydrate cache, wrap in `<HydrationBoundary state={dehydrate(queryClient)}>`)
- Use `queryOptions()` factories for type-safe, reusable query definitions with hierarchical key factories
- Separate generated API code into `src/lib/api/generated/` — treated as dependency, never hand-edited
- Add `"generate:api": "orval --config ./orval.config.ts"` to package.json

**State Management:**
- Server/API data → TanStack Query v5
- Local state → `useState`/`useReducer`
- Global client state → Zustand v5 (no Provider needed, ~1KB gzip); use targeted selectors to minimize re-renders
- URL state → `nuqs` v2.5+ (used by Sentry, Supabase, Vercel); type-safe parsers, server-side via `createLoader()`
- Form state → `useActionState` + `useFormStatus`
- Optimistic UI → `useOptimistic` (React 19); instant UI feedback, auto-reconcile or rollback

**Next.js 15 Caching:**
- `fetch()` defaults to `no-store` (was `force-cache` in v14); opt into caching with `cache: 'force-cache'` or `next: { revalidate: 3600 }`
- `unstable_cache` deprecated — use `'use cache'` directive with `cacheTag()` and `cacheLife()`
- Server Actions for internal mutations; Route Handlers (`route.ts`) for external consumers
- ESLint 9 flat config (`eslint.config.mjs`) replaces `.eslintrc.json`

### Anti-Patterns to NEVER Generate
**React 19**: `useEffect` for data fetching, `forwardRef`, manual memoization (`useMemo`/`useCallback`/`React.memo`), `defaultProps`, `PropTypes`, `<Context.Provider>`
**Next.js 15**: `'use client'` everywhere, API routes for internal mutations, `unstable_cache` (deprecated — use `'use cache'` directive with `cacheTag()`/`cacheLife()`), `next lint` (removed in Next.js 16 — use ESLint CLI with `eslint.config.mjs` flat config)
**TailwindCSS v4**: `tailwind.config.js`, dynamic class construction, `@tailwind` directives, v3 bang syntax (`!bg-red-500`), `@layer utilities`
**Accessibility**: `<div onClick>`, missing `alt`, color-only indicators, missing form labels

### Package Dependencies (Research-Validated)
**Production**: `react` ^19, `react-dom` ^19, `next` ^15, `@tanstack/react-query` ^5.60, `zustand` ^5, `nuqs` ^2.5, `next-themes` ^0.4, `clsx` ^2.1, `tailwind-merge` ^2.6, `zod` ^3.23, `axios` ^1.7
**Dev**: `typescript` ^5.7, `@types/react` ^19, `@types/node` ^22, `@tailwindcss/postcss` ^4, `tailwindcss` ^4, `eslint` ^9, `prettier` ^3.4, `orval` ^7, `vitest` ^2, `@testing-library/react` ^16, `eslint-plugin-jsx-a11y`

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
- [ ] Index updated with executive summary
- [ ] User approved final result

---

## LEARN.md Seeds

### backend-scaffold
- **Better Questions**: idempotency keys, repository vs direct ORM, WebSocket vs SSE, relation strategies, zero-downtime migrations
- **Edge Cases**: endpoints without data model coverage, uncovered audit tables, middleware gaps, Prisma error codes (P2002/P2003/P2025), Zod type provider scoping across encapsulation boundaries, MySQL DDL limitations (no transactional DDL), Go connection pooling
- **Workflow**: tech.md first, backend-api-contract → backend-data-model → backend-task-breakdown order, SSE before WebSocket
- **Common Mistakes**: wrong framework code, Express-style errors in Fastify, multiple Prisma instances, raw Eloquent models, N+1 queries, env() outside config, global Go DB connections, missing `.js` extensions in ESM imports (causes `ERR_MODULE_NOT_FOUND`), using `instanceof ZodError` instead of `hasZodFastifySchemaValidationErrors` helper, missing Eloquent strictness modes, `moduleResolution: "bundler"` for backends

### frontend-scaffold
- **Better Questions**: feature-scoped vs atomic, SSR vs client-only, Orval vs openapi-typescript, Server Actions vs client API calls
- **Edge Cases**: component count conflicts between inputs, API contract newer than design, `useFormStatus` must be in child component of `<form>`, Next.js 15 no-cache default, TailwindCSS v4 suffix syntax (`bg-red-500!` not `!bg-red-500`), ESLint 9 flat config (`eslint.config.mjs` not `.eslintrc.json`)
- **Workflow**: frontend-task-breakdown → frontend-design → backend-api-contract order, types before components, Server Components for data fetching
- **Common Mistakes**: useEffect for fetching, forwardRef, manual memoization, tailwind.config.js, @tailwind directives, 'use client' everywhere, unstable_cache (use 'use cache'), next lint (use eslint CLI), `<Context.Provider>` (use `<Context>` directly)

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
