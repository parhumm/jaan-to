---
title: "Spec-to-Ship Skills Plan"
sidebar_position: 6
---

# Plan: Spec-to-Ship Skills — Closing 5 Launch Gaps

## Context

The jaan-to plugin excels at specification generation but produces 0% production code, 0% tests, and 0% infrastructure. Projects using the full skill pipeline (api-contract → data-model → task-breakdown → scaffold) end up with world-class specs and empty TODO stubs. The entire path from scaffold to ship is missing. This plan adds 4 new skills + 1 scaffold improvement to close the gap.

---

## Skill Inventory

| # | Gap | Action | Skill Name | Type |
|---|-----|--------|-----------|------|
| 1 | L-02 | New skill | `dev-project-assemble` | Wires scaffolds into runnable project |
| 2 | L-01 | New skill | `backend-service-implement` | Fills TODO stubs with business logic |
| 3 | L-03 | New skill | `qa-test-generate` | Produces runnable test files from BDD specs |
| 4 | L-04 | Scaffold fix + new skill | `backend-scaffold` improvement + `sec-audit-remediate` | Secure defaults + finding remediation |
| 5 | L-05 | New skill | `devops-infra-scaffold` | CI/CD, Docker, deployment configs |

---

## 1. `/dev-project-assemble` (L-02 — P0)

> Wire scaffold outputs into a runnable project with proper directory tree, configs, and entry points.

**Why first:** Nothing downstream works until scaffolds become a bootable project.

**Decision:** Writes directly to the project directory (not jaan-to/outputs/). The HARD STOP gate is critical — user reviews the full file tree before any writes happen.

### Spec

- **Name:** `dev-project-assemble`
- **Description:** Wire scaffold outputs into runnable project structure with configs and entry points.
- **argument-hint:** `[backend-scaffold, frontend-scaffold] [target-dir]`
- **allowed-tools:** `Read, Glob, Grep, Write(src/**), Write(prisma/**), Write(package.json), Write(tsconfig.json), Write(next.config.*), Write(tailwind.config.*), Write(.env.example), Write(.gitignore), Write($JAAN_OUTPUTS_DIR/dev/project-assemble/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)`
- **Output:** Direct project writes + assembly log at `$JAAN_OUTPUTS_DIR/dev/project-assemble/{id}-{slug}/{id}-{slug}.md`

### Input Artifacts
- `backend-scaffold` output (routes, services, schemas, middleware, prisma, config files)
- `frontend-scaffold` output (components, hooks, types, pages, config files)
- `frontend-design` output (HTML previews — optional)
- `$JAAN_CONTEXT_DIR/tech.md` (tech stack detection)

### Output — Direct Project Writes
Writes files directly to the project directory tree. Example for a monorepo:

```
project-root/
├── apps/
│   ├── backend/
│   │   ├── src/
│   │   │   ├── app.ts                    # Entry point + plugin registration
│   │   │   ├── routes/                   # Individual route files (split from bundled)
│   │   │   ├── services/                 # Individual service files (split from bundled)
│   │   │   ├── schemas/                  # Individual Zod schema files
│   │   │   ├── middleware/               # Auth, error handler, rate limiter
│   │   │   └── lib/                      # ORM client singleton, utils
│   │   ├── prisma/schema.prisma
│   │   ├── package.json                  # With dev/build/start/test/lint scripts
│   │   ├── tsconfig.json
│   │   └── .env.example
│   └── frontend/
│       ├── src/
│       │   ├── app/                      # App Router (layout.tsx, page.tsx)
│       │   ├── components/               # Split by atomic level
│       │   ├── hooks/                    # Individual hook files
│       │   ├── types/                    # Individual type files
│       │   ├── stores/                   # State store files
│       │   └── lib/                      # API client, utils
│       ├── package.json
│       ├── tsconfig.json
│       └── next.config.js
├── packages/shared/                       # Shared types (if monorepo)
├── package.json                           # Root workspace config
└── .gitignore
```

Also writes an assembly log to `$JAAN_OUTPUTS_DIR/dev/project-assemble/{id}-{slug}/{id}-{slug}.md`.

### Phase 1 Workflow
1. Read all scaffold outputs (backend + frontend) — parse bundled files
2. Detect tech stack from `tech.md`
3. Ask: monorepo (Turborepo/pnpm workspaces) vs. separate repos?
4. Ask: target directory path? (default: project root)
5. Check for existing files — warn if any would be overwritten
6. Map bundled file sections → individual files
7. Plan entry points, provider wiring, config files
8. **Generate full directory tree preview — list every file that will be created**

### Phase 2 Workflow
1. Split bundled scaffold files into individual files
2. Generate entry points (app.ts for backend, layout.tsx/page.tsx for frontend)
3. Generate provider wiring (state stores, auth context, theme provider)
4. Generate config files (package.json, tsconfig.json, framework configs)
5. Generate .env.example with all required environment variables
6. Write all files to project directory (with user approval per group)
7. Write assembly log to `$JAAN_OUTPUTS_DIR/dev/project-assemble/`

### DAG Position
```
backend-scaffold ──┐
frontend-scaffold ─┼──→ dev-project-assemble ──→ backend-service-implement
frontend-design ───┘                          ──→ qa-test-generate
                                              ──→ devops-infra-scaffold
```

### Create via
`/skill-create dev-project-assemble` — run as dedicated agent

---

## 2. `/backend-service-implement` (L-01 — P0)

> Generate actual business logic from TODO stubs using specs as the source of truth.

**Why:** Projects end up with perfectly specified endpoints where every service returns `// TODO: implement`. The specs are all there — the bridge from spec to code is missing.

### Spec

- **Name:** `backend-service-implement`
- **Description:** Generate service implementations with business logic from specs and scaffold stubs.
- **argument-hint:** `[backend-scaffold, backend-api-contract, backend-data-model, backend-task-breakdown]`
- **allowed-tools:** `Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/backend/service-implement/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)`
- **Output:** `$JAAN_OUTPUTS_DIR/backend/service-implement/{id}-{slug}/`

### Input Artifacts
- `backend-scaffold` output (route handlers with TODO stubs, service stubs, ORM schema)
- `backend-api-contract` output (OpenAPI 3.1 — endpoint specs, request/response schemas, error codes)
- `backend-data-model` output (table definitions, relationships, constraints, indexes)
- `backend-task-breakdown` output (vertical slices with implementation notes)
- `$JAAN_CONTEXT_DIR/tech.md` (framework + ORM detection)

### Output Artifacts
```
{id}-{slug}/
├── {id}-{slug}.md                    # Implementation guide + decisions log
├── {id}-{slug}-services/             # Service files by domain
│   ├── auth.service.ts               # JWT lifecycle, session management
│   ├── {resource}.service.ts         # Per-resource service with full CRUD
│   └── ...
├── {id}-{slug}-helpers/              # Shared utilities
│   ├── pagination.ts                 # Cursor/offset pagination from API contract
│   ├── error-factory.ts              # RFC 9457 error construction
│   └── ...
└── {id}-{slug}-readme.md             # Integration instructions
```

### Phase 1 Workflow
1. Parse scaffold stubs — identify all `// TODO: implement` locations
2. For each stub, cross-reference against:
   - API contract (what this endpoint should do)
   - Data model (what tables/relations are involved)
   - Task breakdown (implementation notes, reliability patterns, error taxonomy)
3. Ask: Which vertical slice to implement first? (or all at once?)
4. Ask: External service dependencies — generate real or mock implementations?
5. Map each TODO to a concrete implementation plan
6. Generate implementation preview per service

### Phase 2 Workflow
1. Generate service implementations with:
   - Full ORM query logic (findMany, create, update, delete with relations)
   - Input validation beyond schema (business rules, uniqueness checks)
   - Error handling following RFC 9457 patterns from the API contract
   - Pagination (cursor or offset based on API contract)
   - Proper TypeScript types inferred from ORM schema
2. Generate auth service with proper JWT lifecycle (jose library)
3. Generate shared helpers (pagination, error factory, etc.)
4. Quality check: every TODO stub has a corresponding implementation

### Multi-Stack Support
- **Node.js/TypeScript + Fastify + Prisma** (primary)
- **PHP/Laravel + Eloquent** (secondary)
- **Go + stdlib/Chi** (tertiary)

### DAG Position
```
backend-scaffold ──────┐
backend-api-contract ──┼──→ backend-service-implement ──→ qa-test-generate
backend-data-model ────┤                               ──→ sec-audit-remediate
backend-task-breakdown ┘
```

### Create via
`/skill-create backend-service-implement` — run as dedicated agent

---

## 3. `/qa-test-generate` (L-03 — P0)

> Produce runnable Vitest unit tests and Playwright E2E specs from BDD test cases and scaffold code.

**Why:** BDD scenarios exist as markdown documentation. Zero `*.test.ts` files. `pnpm test` crashes. The spec-to-test bridge is missing.

### Spec

- **Name:** `qa-test-generate`
- **Description:** Generate runnable Vitest and Playwright test files from BDD test cases and scaffold code.
- **argument-hint:** `[qa-test-cases, backend-scaffold | frontend-scaffold]`
- **allowed-tools:** `Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/qa/test-generate/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)`
- **Output:** `$JAAN_OUTPUTS_DIR/qa/test-generate/{id}-{slug}/`

### Input Artifacts
- `qa-test-cases` output (BDD/Gherkin scenarios with @tags, concrete test data)
- `backend-scaffold` OR `frontend-scaffold` output (testable code structure)
- `backend-service-implement` output (optional — filled services for deeper tests)
- `backend-api-contract` output (request/response examples for API test assertions)
- `$JAAN_CONTEXT_DIR/tech.md` (test framework detection)

### Output Artifacts
```
{id}-{slug}/
├── {id}-{slug}.md                     # Test strategy + coverage map
├── config/
│   ├── vitest.config.ts               # Vitest configuration
│   ├── playwright.config.ts           # Playwright configuration
│   └── setup/
│       ├── test-setup.ts              # Global test setup
│       ├── msw-handlers.ts            # MSW mock handlers from API contract
│       └── test-utils.ts              # Render helpers, custom matchers
├── unit/
│   ├── services/
│   │   └── {resource}.service.test.ts # Unit tests per service
│   └── hooks/
│       └── use-{resource}.test.ts     # Hook tests with MSW
├── integration/
│   └── api/
│       └── {resource}.api.test.ts     # API integration tests
├── e2e/
│   └── {flow}.spec.ts                # Playwright E2E per user flow
└── fixtures/
    ├── {resource}.fixture.ts          # Test data factories
    └── db-seed.ts                     # Database seed for integration tests
```

### Phase 1 Workflow
1. Parse qa-test-cases output — extract all BDD scenarios with @tags
2. Map scenarios to testable code units:
   - `@smoke` + `@positive` → unit tests for happy path
   - `@negative` + `@boundary` → unit tests for edge cases
   - `@e2e` → Playwright specs
3. Parse scaffold code — identify testable functions, components, hooks
4. Parse API contract — extract request/response examples for mock handlers
5. Ask: Test framework preference (Vitest recommended for unit, Playwright for E2E)?
6. Ask: Mock strategy (MSW for API mocking recommended)?
7. Generate test inventory: X unit tests, Y integration tests, Z E2E specs

### Phase 2 Workflow
1. Generate config files (vitest.config.ts, playwright.config.ts)
2. Generate test setup (MSW handlers from API contract, render helpers, custom matchers)
3. Generate test data factories from API contract examples
4. Convert BDD Given/When/Then to test assertions:
   - `Given` → test setup / beforeEach
   - `When` → action execution
   - `Then` → assertions (expect/toEqual/toBeVisible)
5. Generate unit tests per service/hook/component
6. Generate Playwright E2E specs per user flow
7. Quality check: every @smoke scenario has a test, coverage target met

### DAG Position
```
qa-test-cases ──────────┐
backend-scaffold ───────┼──→ qa-test-generate
frontend-scaffold ──────┤
backend-api-contract ───┘
```

### Create via
`/skill-create qa-test-generate` — run as dedicated agent

---

## 4. Security Hardening (L-04 — P1)

Two-part approach: fix the root cause (scaffold defaults) + remediate existing findings.

### 4a. `backend-scaffold` Improvement

**What changes in `skills/backend-scaffold/SKILL.md`:**
- Auth middleware: Replace `decodeJwt` (base64-only) with proper JWT verification using `jose` library
- Session handling: httpOnly cookies instead of localStorage, add CSRF protection
- Rate limiting: Include `@fastify/rate-limit` in generated middleware
- Dependencies: Add `jose`, `@fastify/rate-limit`, `@fastify/csrf-protection` to generated package.json
- Add a "Security Defaults" section to the generated scaffold README

**Files to modify:**
- `skills/backend-scaffold/SKILL.md` — update Phase 2 generation rules for auth middleware, add security section

### 4b. `/sec-audit-remediate` (New Skill)

> Generate targeted security fixes from detect-dev SARIF findings with regression tests.

### Spec

- **Name:** `sec-audit-remediate`
- **Description:** Generate security fixes from detect-dev findings with regression tests.
- **argument-hint:** `[detect-dev-output] [backend-scaffold | frontend-scaffold]`
- **allowed-tools:** `Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/sec/remediate/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)`
- **Output:** `$JAAN_OUTPUTS_DIR/sec/remediate/{id}-{slug}/`

### Input Artifacts
- `detect-dev` output (SARIF findings with severity, confidence, locations)
- `backend-scaffold` output (vulnerable code to fix)
- `$JAAN_CONTEXT_DIR/tech.md`

### Output Artifacts
```
{id}-{slug}/
├── {id}-{slug}.md                     # Remediation report (findings → fixes mapping)
├── fixes/
│   ├── {finding-id}-auth-middleware.ts # Fixed auth with proper JWT verification
│   ├── {finding-id}-rate-limiter.ts   # Rate limit middleware
│   ├── {finding-id}-csrf.ts           # CSRF protection setup
│   └── ...                            # One fix file per finding
├── tests/
│   ├── auth-security.test.ts          # Regression tests for auth fixes
│   ├── rate-limit.test.ts             # Rate limit verification
│   └── ...                            # One test file per critical/high finding
└── {id}-{slug}-readme.md              # Integration instructions
```

### Phase 1 Workflow
1. Parse detect-dev SARIF output — extract findings sorted by severity (Critical → High → Medium → Low)
2. For each finding, identify:
   - Vulnerable code location (file + line from SARIF)
   - Root cause category (auth, injection, XSS, config, etc.)
   - Fix complexity (simple replacement vs. architectural change)
3. Cross-reference with scaffold code to understand current implementation
4. Ask: Which findings to remediate? (default: all Critical + High)
5. Generate remediation plan per finding

### Phase 2 Workflow
1. Generate fix files per finding (replacement code)
2. Generate regression tests per critical/high finding
3. Generate integration instructions (which scaffold files to replace)
4. Quality check: every Critical finding has a fix + test

### DAG Position
```
detect-dev ─────────┐
backend-scaffold ───┼──→ sec-audit-remediate ──→ devops-infra-scaffold (security in CI)
frontend-scaffold ──┘
```

### Create via
`/skill-create sec-audit-remediate` — run as dedicated agent

---

## 5. `/devops-infra-scaffold` (L-05 — P1)

> Generate CI/CD workflows, Dockerfiles, and deployment configs from tech.md.

**Why:** You can't ship what you can't deploy. Every scaffold project ends with zero infrastructure.

### Spec

- **Name:** `devops-infra-scaffold`
- **Description:** Generate CI/CD workflows, Dockerfiles, and deployment configs from tech stack.
- **argument-hint:** `[tech.md | (interactive)]`
- **allowed-tools:** `Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/devops/infra-scaffold/**), Task, WebSearch, AskUserQuestion, Edit(jaan-to/config/settings.yaml)`
- **Output:** `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{id}-{slug}/`

### Input Artifacts
- `$JAAN_CONTEXT_DIR/tech.md` (databases, services, frameworks, versions)
- `backend-scaffold` output (entry points, dependencies)
- `frontend-scaffold` output (build config, framework)
- `detect-dev` output (optional — existing CI/CD findings)

### Output Artifacts
```
{id}-{slug}/
├── {id}-{slug}.md                     # Infrastructure guide
├── ci/
│   ├── ci.yml                         # GitHub Actions workflow (lint → type-check → test → build → deploy)
│   └── cd.yml                         # Deployment workflow (staging → production)
├── docker/
│   ├── Dockerfile.backend             # Multi-stage build for backend
│   ├── Dockerfile.frontend            # Multi-stage build for frontend
│   └── docker-compose.yml             # Full stack: app + database + cache + search
├── config/
│   ├── .env.example                   # All required environment variables
│   ├── .env.test                      # Test environment defaults
│   └── .env.production.example        # Production-specific vars
├── deploy/
│   ├── {platform}.yml                 # Platform-specific config (Vercel/Railway/AWS)
│   └── migration.sh                   # Database migration script for CI
└── {id}-{slug}-readme.md              # Setup + deployment instructions
```

### Phase 1 Workflow
1. Read tech.md — detect all services (database, cache, search, etc.)
2. Parse scaffold outputs — detect entry points, build commands, dependencies
3. Ask: CI/CD platform (GitHub Actions recommended, GitLab CI, CircleCI)?
4. Ask: Deployment target (Vercel for frontend, Railway for backend recommended)?
5. Ask: Container registry (GitHub Container Registry recommended)?
6. Ask: Environment strategy (staging + production recommended)?
7. Plan CI stages and Docker services

### Phase 2 Workflow
1. Generate CI workflow:
   - Lint, type-check, test, build, deploy stages
   - Cache: node_modules, build artifacts, ORM engine
   - Matrix: runtime version from tech.md
   - Secrets: referenced by name, never hardcoded
2. Generate Dockerfiles (multi-stage: deps → build → runtime)
3. Generate docker-compose.yml (all services from tech.md)
4. Generate .env files (with comments explaining each variable)
5. Generate deployment configs for target platform
6. Generate migration script for CI

### Multi-Stack Support
- **Node.js/Next.js + Fastify** → GitHub Actions + Docker + Vercel/Railway
- **PHP/Laravel** → GitHub Actions + Docker + Forge/Vapor
- **Go** → GitHub Actions + Docker + Fly.io/Railway

### DAG Position
```
tech.md ────────────┐
backend-scaffold ───┼──→ devops-infra-scaffold
frontend-scaffold ──┤
detect-dev ─────────┘ (optional, for security gates in CI)
```

### Create via
`/skill-create devops-infra-scaffold` — run as dedicated agent

---

## Updated DAG (Complete Pipeline)

```
Spec Phase (existing):
  api-contract + data-model + task-breakdown + user stories
         ↓
Scaffold Phase (existing):
  backend-scaffold (improved: secure auth defaults) + frontend-scaffold
         ↓
Assembly Phase (NEW):
  dev-project-assemble → runnable project
         ↓
Implementation Phase (NEW):
  backend-service-implement → filled business logic
         ↓ (parallel)
Quality Phase (NEW):
  qa-test-generate → runnable tests     |  sec-audit-remediate → security fixes
         ↓
Ship Phase (NEW):
  devops-infra-scaffold → CI/CD + Docker + deploy
```

---

## Pre-Creation Research (Step 0)

Run `/pm-research-about` for each skill to gather development workflow standards, methods, and best practices. All 6 research tasks run as **parallel dedicated agents** (Auto mode, Deep/100 unique sources each).

| # | Skill | Research Topic | Output File |
|---|-------|---------------|-------------|
| R1 | `dev-project-assemble` | Scaffold-to-project assembly automation: monorepo patterns (Turborepo, pnpm workspaces), entry point generation, provider wiring, config generation, bundled file splitting, .env management, bootstrapping workflows (Node.js/TypeScript + Fastify + Next.js) | [`69-dev-scaffold-project-assembly-automation.md`](../../research/69-dev-scaffold-project-assembly-automation.md) |
| R2 | `backend-service-implement` | Spec-to-code service implementation: ORM query generation (Prisma, Eloquent, GORM), business logic derivation from API specs, RFC 9457 error handling, validation beyond schema, pagination (cursor/offset), JWT lifecycle (jose), transactions, idempotency, service layer architecture | [`70-dev-backend-service-implementation-generation.md`](../../research/70-dev-backend-service-implementation-generation.md) |
| R3 | `qa-test-generate` | BDD/Gherkin to runnable test code: Given/When/Then to Vitest/Playwright conversion, test data factories (Fishery, zod-mock), MSW mock handlers from OpenAPI, tag-based routing (@smoke→unit, @e2e→Playwright), coverage strategies, CI-friendly execution | [`71-qa-bdd-gherkin-test-code-generation.md`](../../research/71-qa-bdd-gherkin-test-code-generation.md) |
| R4 | `backend-scaffold` (security) | Secure backend defaults: JWT verification (jose vs base64), httpOnly cookies, CSRF (@fastify/csrf-protection), rate limiting (@fastify/rate-limit), CSP headers, CORS, input sanitization, OWASP Top 10 mitigation in scaffolds | [`72-dev-secure-backend-scaffold-hardening.md`](../../research/72-dev-secure-backend-scaffold-hardening.md) |
| R5 | `sec-audit-remediate` | SARIF remediation automation: SARIF 2.1.0 parsing, finding-to-fix mapping, CWE-to-remediation mapping, automated fixes by category (auth, injection, XSS, SSRF, crypto, config), regression test generation, CI security gates (CodeQL, Semgrep, Snyk) | [`73-dev-sarif-security-remediation-automation.md`](../../research/73-dev-sarif-security-remediation-automation.md) |
| R6 | `devops-infra-scaffold` | CI/CD scaffold generation: GitHub Actions workflows (matrix, caching, reusable), multi-stage Docker builds, docker-compose, .env management, deployment configs (Vercel, Railway, Fly.io, AWS ECS), database migrations in CI, security scanning (Trivy, Snyk) | [`74-dev-cicd-infra-scaffold-generation.md`](../../research/74-dev-cicd-infra-scaffold-generation.md) |

**Cross-references with existing research:**
- R1 builds on `63-dev-scaffolds.md` (individual scaffold patterns → assembly layer)
- R2 builds on `59-backend-api-contract.md` + `60-backend-data-model.md` + `52-backend-task-breakdown.md`
- R3 builds on `50-qa-test-cases.md` (BDD generation methodology → code generation)
- R4 fills the security gap in `63-dev-scaffolds.md`
- R5 builds on `53-dev-pr-review.md` + `61-detect-pack.md` (SARIF output → remediation)
- R6 is net new (no existing infrastructure research)

---

## Execution Plan

### Phase A: Research (all 6 in parallel) ✅
Run `/pm-research-about` for each skill — 6 parallel agents, Auto mode, Deep (100 unique sources each). Complete — outputs at `docs/research/69-74`.

### Phase B: Skill Creation
Each new skill is created by invoking `/skill-create` as a **separate dedicated agent**. Each agent receives its corresponding research output as context. The scaffold improvement (4a) is a direct edit to the existing SKILL.md.

`/skill-create` produces: `SKILL.md` + `LEARN.md` (research-seeded) + `template.md` (if applicable). Skills that write code (`dev-project-assemble`, `backend-service-implement`) do NOT need `template.md`.

| Step | Action | Method | Parallelizable |
|------|--------|--------|----------------|
| 1 | `dev-project-assemble` | `/skill-create dev-project-assemble` (agent) + R1 research | — |
| 2 | `backend-scaffold` improvement | Direct edit to `skills/backend-scaffold/SKILL.md` using R4 research | With step 1 |
| 3 | `backend-service-implement` | `/skill-create backend-service-implement` (agent) + R2 research | With steps 1+2 |
| 4 | `qa-test-generate` | `/skill-create qa-test-generate` (agent) + R3 research | With step 3 |
| 5 | `sec-audit-remediate` | `/skill-create sec-audit-remediate` (agent) + R5 research | With steps 3+4 |
| 6 | `devops-infra-scaffold` | `/skill-create devops-infra-scaffold` (agent) + R6 research | After steps 1-5 |

**Parallel batches:**
- **Batch 0:** R1 + R2 + R3 + R4 + R5 + R6 (all research in parallel)
- **Batch 1:** Steps 1 + 2 + 3 (assemble + scaffold fix + service implement)
- **Batch 2:** Steps 4 + 5 (test generate + security remediate)
- **Batch 3:** Step 6 (infra scaffold)

### Phase C: Post-Creation (per skill, after each batch)

After each skill is created via `/skill-create`, run these steps:

| # | Step | Command/Action |
|---|------|---------------|
| 1 | Compliance check | `/skill-update {skill-name}` — v3.0.0 frontmatter + structure compliance |
| 2 | Issue capture | If any issues found during creation or compliance check, fix them, then run `/learn-add` to record the lesson |
| 3 | Config catalog | Edit `scripts/seeds/config.md` — add skill entry to catalog table |
| 4 | Documentation | `/docs-create {skill-name}` — generate skill docs page |
| 5 | Roadmap update | `/pm-roadmap-add` to add skill to roadmap (or `/pm-roadmap-update` to sync existing entries) |
| 6 | Changelog | `/release-iterate-changelog` — add entries for new skills |
| 7 | Commit + PR | Commit all files, create PR to `dev` |

**Continuous learning rule:** At any point during Phase B or C, if an issue is discovered and fixed (frontmatter error, missing section, wrong path, etc.), immediately run `/learn-add` to capture the lesson before moving on.

### Batch Execution: Step-by-Step Pipeline

Run all 6 skills sequentially. Each skill completes its full lifecycle (Phase B create + Phase C post-creation) before the next one starts. This ensures lessons learned from earlier skills feed into later ones.

**Execution order:**

```
┌─────────────────────────────────────────────────────────────┐
│  SKILL 1: dev-project-assemble                              │
│  B1. /skill-create dev-project-assemble (agent)     │
│  C1. skill-update → learn-add → config → docs-create        │
│      → pm-roadmap-add → release-iterate-changelog → commit      │
├─────────────────────────────────────────────────────────────┤
│  SKILL 2: backend-scaffold improvement                      │
│  B2. Direct edit to skills/backend-scaffold/SKILL.md        │
│  C2. skill-update → learn-add → docs-create                 │
│      → pm-roadmap-update → release-iterate-changelog → commit   │
├─────────────────────────────────────────────────────────────┤
│  SKILL 3: backend-service-implement                         │
│  B3. /skill-create backend-service-implement (agent)│
│  C3. skill-update → learn-add → config → docs-create        │
│      → pm-roadmap-add → release-iterate-changelog → commit      │
├─────────────────────────────────────────────────────────────┤
│  SKILL 4: qa-test-generate                                  │
│  B4. /skill-create qa-test-generate (agent)         │
│  C4. skill-update → learn-add → config → docs-create        │
│      → pm-roadmap-add → release-iterate-changelog → commit      │
├─────────────────────────────────────────────────────────────┤
│  SKILL 5: sec-audit-remediate                               │
│  B5. /skill-create sec-audit-remediate (agent)      │
│  C5. skill-update → learn-add → config → docs-create        │
│      → pm-roadmap-add → release-iterate-changelog → commit      │
├─────────────────────────────────────────────────────────────┤
│  SKILL 6: devops-infra-scaffold                             │
│  B6. /skill-create devops-infra-scaffold (agent)    │
│  C6. skill-update → learn-add → config → docs-create        │
│      → pm-roadmap-add → release-iterate-changelog → commit      │
└─────────────────────────────────────────────────────────────┘
```

**Per-skill lifecycle (B + C combined):**

```
For each skill in [1..6]:
  1. Create skill          → /skill-create {name} (or direct edit for #2)
  2. Compliance check      → /skill-update {name}
  3. Fix issues + learn    → fix → /learn-add (if issues found)
  4. Config catalog        → Edit scripts/seeds/config.md (new skills only)
  5. Documentation         → /docs-create {name}
  6. Roadmap               → /pm-roadmap-add (or /pm-roadmap-update)
  7. Changelog             → /release-iterate-changelog
  8. Commit                → git add + commit to dev branch
  → NEXT SKILL
```

**Gate rule:** Do NOT start skill N+1 until skill N's commit (step 8) succeeds. This guarantees each skill builds on a clean, committed state.

---

## Verification

### Structural (per skill — after Phase C step 1)

1. Frontmatter: `name` matches directory, `description` < 120 chars, no `: ` escaping issues, no `model:` field
2. Required sections: Context Files, Input, Pre-Execution, HARD STOP, Definition of Done
3. All paths use `$JAAN_*` env vars (no hardcoded project paths)
4. No hardcoded credentials, IPs, or tokens
5. `/learn-add` referenced (not deprecated `/update-lessons-learned`)
6. LEARN.md exists with seeded lessons (Better Questions, Edge Cases, Workflow, Common Mistakes)
7. `scripts/seeds/config.md` has catalog entry for the skill

### Functional (per skill — on a project with upstream pipeline complete)

1. **dev-project-assemble**: Run on scaffold outputs → verify `npm run dev` boots both backend and frontend
2. **backend-service-implement**: Run on stubs → verify all TODO comments replaced with real ORM queries and business logic
3. **qa-test-generate**: Run on BDD specs → verify `pnpm test` runs and passes
4. **backend-scaffold improvement**: Run on a new project → verify auth uses proper JWT verification, not base64
5. **sec-audit-remediate**: Run on detect-dev output → verify Critical findings have fixes + regression tests
6. **devops-infra-scaffold**: Run on tech.md → verify `docker-compose up` starts all services, CI workflow is valid YAML

---

## Roadmap Integration

Done via `/pm-roadmap-add` or `/pm-roadmap-update` in Phase C step 5. Expected changes:

- Add `dev-project-assemble` to `docs/roadmap/tasks/role-skills/dev.md` in the DEV skills chain
- Add `backend-service-implement` to `docs/roadmap/tasks/role-skills/backend.md` after `backend-scaffold`
- Add `qa-test-generate` to `docs/roadmap/tasks/role-skills/qa.md` after `qa-test-cases`
- Add `sec-audit-remediate` to `docs/roadmap/tasks/role-skills/sec.md` after `sec-threat-model-lite`
- Create `docs/roadmap/tasks/role-skills/devops.md` for `devops-infra-scaffold`
- Update `docs/roadmap/roadmap.md` Phase 6 progress

---

## Critical Files

| File | Purpose |
|------|---------|
| `skills/backend-scaffold/SKILL.md` | Modify for L-04a security defaults |
| `skills/qa-test-cases/SKILL.md` | Reference for qa-test-generate input format |
| `skills/detect-dev/SKILL.md` | Reference for sec-audit-remediate SARIF input |
| `skills/frontend-scaffold/SKILL.md` | Reference for dev-project-assemble bundled output parsing |
| `docs/extending/create-skill.md` | Skill creation spec (used by /skill-create) |
| `scripts/seeds/config.md` | Skill catalog — add entry per new skill (Phase C step 2) |
| `scripts/lib/id-generator.sh` | ID generation for output folders |
| `scripts/lib/index-updater.sh` | Index updates for output folders |
