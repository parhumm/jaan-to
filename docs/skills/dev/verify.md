---
title: "dev-verify"
sidebar_position: 5
doc_type: skill
created_date: 2026-02-14
updated_date: 2026-02-23
tags: [dev, verify, build, health-check, smoke-test, type-check, runtime, multi-stack]
related: [dev-output-integrate, dev-project-assemble, devops-deploy-activate, backend-scaffold, frontend-scaffold]
---

# /jaan-to:dev-verify

> Validate integrated build pipeline and running services with health checks and smoke tests.

---

## Overview

Answers the single question: **"Does my project work?"** Combines build verification (compile, type-check, auto-fix) and runtime verification (health checks, contract validation, smoke tests) into one command. Reads `tech.md` to detect your stack, then runs a three-phase pipeline: analysis, build verification, and runtime verification.

Supports Node.js/TypeScript, PHP, and Go out of the box. Handles monorepos (Turborepo, pnpm workspaces), ORM generate steps (Prisma, Drizzle), Docker Compose services, and database/cache health checks.

---

## Usage

```
/jaan-to:dev-verify
/jaan-to:dev-verify --build-only
/jaan-to:dev-verify --runtime-only
/jaan-to:dev-verify --skip-smoke --skip-fix
/jaan-to:dev-verify --port 4000
```

| Flag | Description |
|------|-------------|
| `--build-only` | Skip runtime verification. Only compile/type-check. |
| `--runtime-only` | Skip build verification. Only health checks. |
| `--skip-smoke` | Skip smoke tests in runtime phase. |
| `--skip-fix` | Report build errors without auto-fixing. |
| `--port PORT` | Override default port for a service. |

When run without flags, executes the full pipeline (build + runtime).

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/dev/verify/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Verification report with build results, health check results, and recommendations |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Verification strategy approval | After Phase 1 analysis | Confirm detected stack and planned checks |
| Build-only / Runtime-only | At HARD STOP | User may want to narrow scope |
| Write endpoint approval | Before smoke-testing POST/PUT/DELETE | Prevent unintended data changes |

---

## Three-Phase Workflow

### Phase 1 — Analysis (Read-Only)

1. Reads `tech.md` to detect backend, frontend, package manager, ORM, database, and cache
2. Reads integration manifest (if available from `dev-output-integrate`)
3. Discovers project state: dependency manifests, monorepo structure, ORM configs
4. Discovers API contracts (OpenAPI specs)
5. Presents verification plan at **HARD STOP** for approval

### Phase 2 — Build Verification

1. Installs dependencies
2. Runs ORM generate (Prisma, Drizzle, sqlc, wire) if applicable
3. Runs type/compile check (tsc, phpstan, go vet)
4. Categorizes errors into generic categories
5. Auto-fixes safe errors (missing deps, export mismatches, config gaps)
6. Re-runs build pipeline to verify fixes

**Build error categories:**

| Category | Auto-Fix? |
|----------|-----------|
| `missing-dependency` | Yes |
| `export-import-mismatch` | Yes |
| `type-mismatch` | Conditional (simple casts only) |
| `schema-drift` | No (report only) |
| `config-mismatch` | Yes |

### Phase 3 — Runtime Verification

1. Checks port availability for each service
2. Runs HTTP health checks against detected endpoints
3. Runs database/cache health commands (pg_isready, redis-cli PING, etc.)
4. Validates API responses against OpenAPI contract (if spec found). When Spectral and/or Prism are available locally, enhanced contract validation runs automatically: Spectral lints the spec for style conformance and Prism validates response payloads against schema definitions
5. Runs smoke tests on GET endpoints (write endpoints require approval)
6. Cross-validates build and runtime results

---

## Workflow Chain

```
/jaan-to:dev-output-integrate + /jaan-to:dev-project-assemble
  |
  v
/jaan-to:dev-verify  (build + runtime)
  |
  v
/jaan-to:devops-deploy-activate
```

---

## Example

**Input:**
```
/jaan-to:dev-verify
```

**Output:**
```
Mode:        Full (build + runtime)
Build:       PASS (3 errors found, 3 auto-fixed)
Runtime:     PASS (4/4 services healthy)
Contract:    PASS (12 endpoints validated)
Smoke Tests: PASS (8 GET endpoints tested)

Report: jaan-to/outputs/dev/verify/42-my-project-verify/42-my-project-verify.md
```

---

## Tips

- Run after `dev-output-integrate` or `dev-project-assemble` to verify everything works together
- Use `--build-only` for fast compile checks during development
- Use `--runtime-only` when services are already running and you just need health validation
- Use `--skip-fix` to get a report without any auto-modifications
- Keep services running before invoking — this skill does **not** start or stop services
- `curl` is restricted to localhost only — no external requests

---

## Related Skills

- [/jaan-to:dev-output-integrate](output-integrate.md) - Copy generated outputs into project
- [/jaan-to:dev-project-assemble](project-assemble.md) - Wire scaffolds into runnable project
- [/jaan-to:devops-deploy-activate](../devops/deploy-activate.md) - Activate deployment pipeline
- [/jaan-to:backend-scaffold](../backend/scaffold.md) - Generate backend code
- [/jaan-to:frontend-scaffold](../frontend/scaffold.md) - Generate frontend components

---

## Technical Details

- **Logical Name**: dev-verify
- **Command**: `/jaan-to:dev-verify`
- **Role**: dev
- **Output**: `$JAAN_OUTPUTS_DIR/dev/verify/{id}-{slug}/`
- **Multi-Stack**: Node.js/TypeScript, PHP, Go
- **Closes**: [#78](https://github.com/parhumm/jaan-to/issues/78), [#85](https://github.com/parhumm/jaan-to/issues/85)
