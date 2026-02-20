---
name: dev-verify
description: Validate integrated build pipeline and running services with health checks and smoke tests. Use when verifying project builds.
allowed-tools: Read, Glob, Grep, Bash(pnpm:*), Bash(npm:*), Bash(yarn:*), Bash(composer:*), Bash(go:*), Bash(npx tsc:*), Bash(turbo:*), Bash(curl:*), Bash(docker compose:*), Bash(docker:*), Bash(lsof:*), Bash(nc:*), Bash(ss:*), Bash(ls:*), Bash(mkdir:*), Write($JAAN_OUTPUTS_DIR/dev/verify/**), Task, AskUserQuestion, Edit(src/**), Edit(apps/**), Edit(package.json), Edit(tsconfig.json), Edit(composer.json), Edit(jaan-to/config/settings.yaml)
argument-hint: [--build-only | --runtime-only] [--skip-smoke] [--skip-fix] [--port PORT]
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# dev-verify

> Validate integrated build pipeline and running services with health checks and smoke tests.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` — Tech stack (determines build commands, ports, health endpoints)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:dev-verify.template.md` — Report template
- `$JAAN_LEARN_DIR/jaan-to:dev-verify.learn.md` — Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` — Language resolution protocol

## Input

**Arguments**: $ARGUMENTS

- `--build-only` — Skip runtime verification (Phase 3). Only compile/type-check.
- `--runtime-only` — Skip build verification (Phase 2). Only health checks.
- `--skip-smoke` — Skip smoke tests in Phase 3.
- `--skip-fix` — Report build errors without auto-fixing.
- `--port PORT` — Override default port for a specific service.
- No flags — run full pipeline (build + runtime).

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `dev-verify`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Know the tech stack for build commands and health endpoints
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_dev-verify`

> **Language exception**: Generated code output, compiler error messages, and command output are NOT affected by this setting.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing tech stack to determine build commands and health check strategy
- Cross-referencing integration manifest with project files
- Planning verification order (build before runtime)
- Identifying config-implied dependencies from framework configs

## Step 1: Detect Tech Stack

Read `$JAAN_CONTEXT_DIR/tech.md` `#current-stack` section. If missing, invoke `context-scout` agent. Extract:
- Backend language/framework
- Frontend framework
- Package manager (from lockfile)
- ORM (if any)
- Database type
- Cache/queue services

**Build detection table:**

| tech.md value | Type Check | Dep Install | Build |
|---|---|---|---|
| Node.js / TypeScript | `npx tsc --noEmit` | `pnpm install` / `npm install` | `turbo run build` / `pnpm run build` |
| PHP | `vendor/bin/phpstan analyse` | `composer install` | `composer run build` |
| Go | `go vet ./...` + `go build ./...` | `go mod download` | `go build ./cmd/...` |

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Build Pipeline Sequences" for ORM generate commands, conditional steps, and monorepo variants.

**Health detection table:**

| tech.md Backend | Default Port | Health Endpoint | Protocol |
|---|---|---|---|
| Node.js / Fastify | 3000 | GET /health | HTTP JSON |
| Node.js / Express | 3000 | GET /health | HTTP JSON |
| Node.js / Next.js | 3000 | GET /api/health | HTTP JSON |
| PHP / Laravel | 8000 | GET /api/health | HTTP JSON |
| PHP / Symfony | 8000 | GET /health | HTTP JSON |
| Go / Chi | 8080 | GET /health | HTTP JSON |
| Go / stdlib | 8080 | GET /health | HTTP JSON |

| tech.md Database/Cache | Default Port | Health Command | Protocol |
|---|---|---|---|
| PostgreSQL | 5432 | pg_isready -U $user | TCP + CLI |
| MySQL | 3306 | mysqladmin ping -u $user | TCP + CLI |
| Redis | 6379 | redis-cli PING | TCP + CLI |
| MongoDB | 27017 | nc -z | TCP |

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Frontend Health Detection" and "Framework-Agnostic Routing Detection" for frontend frameworks and shared-port services.

## Step 2: Read Integration Manifest

Check for `$JAAN_OUTPUTS_DIR/.last-integration-manifest` (written by `dev-output-integrate` Step 13).

- If found: use as validation scope — these are the files last integrated into the project
- If not found: proceed without scope constraint (verify entire project)

Present scope summary:
> Integration manifest: {found/not found}. Validation scope: {N files from manifest / entire project}.

## Step 3: Discover Project State

**For build verification** (skip if `--runtime-only`):
1. Read `package.json` / `composer.json` / `go.mod` for dependency manifest
2. Detect monorepo structure (`turbo.json`, `pnpm-workspace.yaml`)
3. Check ORM config (`prisma/schema.prisma`, `drizzle.config.ts`)
4. Detect config-implied build dependencies (pattern from `dev-project-assemble`):
   - `next.config.ts` → `reactCompiler: true` → requires `babel-plugin-react-compiler`
   - `next.config.ts` → `@next/mdx` import → requires `@next/mdx` + `@mdx-js/react`
   - `composer.json` → `laravel/octane` → requires `swoole` or `roadrunner`
   - `go.mod` → `sqlc` generate config → requires `sqlc` binary
   - Flag missing config-implied deps as `missing-dependency` errors

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Config-Implied Dependency Validation" for full detection table.

**For runtime verification** (skip if `--build-only`):
1. Read `docker-compose.yml` / `compose.yml` for service definitions and port mappings
2. Read `.env`, `.env.local`, `.env.development` for port overrides (`PORT`, `API_PORT`, `DATABASE_URL`)
3. Detect listening ports: `lsof -i -P -n` (macOS/Darwin) or `ss -tlnp` (Linux)
4. Cross-reference discovered ports with detection table expected ports

## Step 4: Discover API Contract

Skip if `--build-only`.

- Glob for `openapi.yaml`, `openapi.json`, `swagger.yaml` in project root and `docs/`
- Check `$JAAN_OUTPUTS_DIR/backend/api-contract/*/` for jaan-to-generated specs
- Extract endpoint list for contract validation

## Step 5: Plan Verification Strategy

**Build plan** (if not `--runtime-only`):
- Which type checker to run
- Which dependencies to install
- Which build command to execute
- ORM generate step needed?

**Runtime plan** (if not `--build-only`):
- For each discovered service, map to check type from detection tables
- **HTTP services**: Port check → health endpoint → (optional) contract validation → (optional) smoke tests
- **Databases/caches**: Port check → CLI health command (via docker exec or direct)
- **Shared-port services** (Laravel Blade/Inertia, Go templates): Single port serves both routes

Present summary:
```
VERIFICATION PLAN
=================

Tech Stack:       {detected stack}
Manifest Scope:   {N files / entire project}
Build Plan:       {type check → build sequence}
Runtime Plan:     {N services to check}
Estimated Steps:  {count}
```

---

# HARD STOP — Review Verification Plan

Use AskUserQuestion:
- Question: "Proceed with verification? ({n} build steps, {m} services to check)"
- Header: "Verify"
- Options:
  - "Proceed" — Run full pipeline
  - "Build only" — Skip runtime verification
  - "Runtime only" — Skip build verification
  - "Report only" — Analyze without auto-fixing

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Build Verification

Skip entirely if `--runtime-only` or user chose "Runtime only".

**Bootstrap Validation Sequence** (follows `dev-output-integrate-reference.md` order):

```
1. {pkg_manager} install       — Install dependencies
2. ORM generate (if applicable) — prisma generate / drizzle-kit generate / go generate
3. npx tsc --noEmit / phpstan / go vet — Type/compile check
4. {pkg_manager} run build     — Full build
```

## Step 6: Install Dependencies

Run stack-appropriate install command from detection table. Report any install failures. Include config-implied dependencies detected in Step 3.

## Step 7: Run Type/Compile Check

Execute type checker from detection table. If ORM detected in Step 3, run ORM generate first (e.g., `npx prisma generate`). Collect all errors from stdout/stderr.

## Step 8: Categorize Build Errors

| Category | Auto-Fix? | Action |
|---|---|---|
| `missing-dependency` | Yes | Install package (includes config-implied deps) |
| `export-import-mismatch` | Yes | Fix export/import names |
| `type-mismatch` | Conditional | Fix if simple cast, else report |
| `schema-drift` | No | Report only, suggest upstream re-run |
| `config-mismatch` | Yes | Update config entry |

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Error Pattern Matching" for per-stack error patterns, detection regex, and auto-fix command sequences.

## Step 9: Apply Auto-Fixes

Skip if `--skip-fix` or user chose "Report only".

For each auto-fixable error:
1. Show proposed fix (diff or command)
2. Apply fix
3. Track changes for report

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Auto-Fix Command Sequences" for per-stack install/fix commands and safety matrix.

## Step 10: Re-Run Build

1. Re-run type/compile check — compare before vs after error counts
2. Run full build pipeline if type check passes

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Build Pipeline Sequences" for per-stack build order with conditional ORM steps.

Present build results:
```
BUILD RESULTS
=============
Type Check:    {errors_before} → {errors_after} errors
Auto-Fixed:    {count} issues
Remaining:     {count} errors
Full Build:    ✓ Pass / ✗ Failed at {stage}
```

If `--build-only`: skip to Step 15 (Quality Check).

---

# PHASE 3: Runtime Verification

Skip entirely if `--build-only` or user chose "Build only".

## Step 11: Run Health Checks

For each service in approved plan:

1. **Port check** (fast, fail-fast): `nc -z -w 2 localhost {port}`
2. **HTTP health check** (if port up): `curl -s -o /dev/null -w "%{http_code} %{time_total}" --max-time 5 http://localhost:{port}{path}`
3. **Database/cache check** (if applicable):
   - Docker: `docker compose exec -T {service} {health_command}`
   - Direct: CLI command or `nc -z` fallback

**Security**: `curl` restricted to `localhost`/`127.0.0.1` only. No external URLs.

**Runtime error categories:**

| Error Category | Meaning | HTTP Analogy |
|---|---|---|
| `service-unavailable` | Port not listening | 503 |
| `unhealthy-response` | Health endpoint returned non-2xx | 503 |
| `invalid-response-format` | Unexpected response body/content-type | 500 |
| `timeout` | No response within deadline | 504 |
| `configuration-mismatch` | Expected service not found or wrong port | 400 |
| `authentication-required` | Health endpoint behind auth | 401 |

## Step 12: Validate API Contract

Skip if no OpenAPI spec found in Step 4.

- GET endpoints: compare status code, Content-Type, response body structure against spec
- Structural validation only (field presence and types) — no full JSON Schema validator
- Flag mismatches as `contract-violation` with expected vs actual

## Step 13: Run Smoke Tests

Skip if `--skip-smoke`.

- GET endpoints: automatic read-only tests
- Write endpoints (POST/PUT/DELETE): require explicit user approval via AskUserQuestion
- Cleanup temporary resources after write tests
- Never run write operations against services with production indicators in connection strings

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/dev-verify-reference.md` section "Smoke Test Patterns" for per-framework endpoint conventions and production detection rules.

## Step 14: Cross-Validate Build + Runtime

Only if both phases ran:
- Build succeeded but service unhealthy? → Flag as deployment config issue
- Build has warnings but service healthy? → Note warnings in report, non-blocking
- Schema drift detected in build but API responses match? → Note potential stale migration
- Integration manifest present but files missing? → Flag as integration gap

Present runtime results:
```
RUNTIME RESULTS
===============
Services Checked:  {count}
Healthy:           {count}
Unhealthy:         {count}
Contract Checks:   {pass}/{total}
Smoke Tests:       {pass}/{total} (or skipped)
```

---

# Shared Closing Steps

## Step 15: Quality Check

**Build Verification:**
- [ ] Error counts accurate, auto-fixes logged with diffs
- [ ] Config-implied dependencies validated
- [ ] Build pipeline completed (or errors categorized)

**Runtime Verification:**
- [ ] All services checked, no false positives from IPv4/IPv6
- [ ] Contract validation ran if spec available
- [ ] Smoke tests ran if applicable and approved

**Cross-Validation:**
- [ ] Cross-validation findings noted (if both phases ran)
- [ ] Integration manifest cross-referenced (if available)

**Report Safety:**
- [ ] No credentials or secrets in report output

If any check fails, fix before proceeding.

## Step 16: Generate ID and Folder Structure

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/dev/verify"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{verification-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Preview:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/dev/verify/{NEXT_ID}-{slug}/`
> - Main file: `{NEXT_ID}-{slug}.md`

## Step 17: Write Verification Report

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:dev-verify.template.md`

Write `{NEXT_ID}-{slug}.md` with:
- Executive Summary (BLUF: build pass/fail, runtime pass/fail, errors found/fixed/remaining)
- Tech Stack Detected
- Integration Scope (from manifest, if available)
- Build Results (before/after error counts, fixes applied, remaining errors)
- Runtime Results (service inventory, health check pass/fail, response times)
- Contract Validation Results (if applicable)
- Smoke Test Results (if applicable)
- Cross-Validation Findings (if both phases ran)
- Recommendations
- Metadata (date, mode, output path, skill version)

Update index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Verification Title}" \
  "{Executive summary — 1-2 sentences}"
```

Confirm:
> Verification report written to: `$JAAN_OUTPUTS_DIR/dev/verify/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md`
> Index updated: `$JAAN_OUTPUTS_DIR/dev/verify/README.md`

## Step 18: Suggest Next Actions

Context-aware recommendations:
- All pass → suggest `/jaan-to:devops-deploy-activate`
- Build failures → actionable fix suggestions, suggest re-running upstream skills
- Runtime failures → actionable fix suggestions per error category
- Contract mismatches → suggest `/jaan-to:backend-api-contract`
- Schema drift → suggest `/jaan-to:backend-data-model`
- Missing tests → suggest `/jaan-to:qa-test-generate`

## Step 19: Capture Feedback

Use AskUserQuestion:
- Question: "How did the verification turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" — Done
  - "Needs fixes" — What should I adjust?
  - "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add dev-verify "{feedback}"`

---

## Scope Boundaries

- Does NOT start/stop services (user responsibility)
- Does NOT deploy (that is `/jaan-to:devops-deploy-activate`)
- Does NOT generate new code (that is scaffold/implement skills)
- Does NOT modify ORM schemas (reports drift, suggests upstream re-run)
- Does NOT auto-push to main (user controls deployment)
- Auto-fixes limited to: dependency installs, export/import name fixes, config entry updates
- `curl` restricted to `localhost`/`127.0.0.1` only
- Write endpoints in smoke tests require explicit user approval

---

## DAG Position

```
dev-output-integrate + dev-project-assemble + sec-audit-remediate
  |
  v
dev-verify
  |
  v
devops-deploy-activate
```

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] Build verification passes (type check + full build) OR errors are categorized and reported
- [ ] Runtime verification passes (all services healthy) OR failures have actionable details
- [ ] Report written to `$JAAN_OUTPUTS_DIR/dev/verify/{id}-{slug}/`
- [ ] Index updated
- [ ] Next actions suggested based on results
- [ ] User feedback captured
