---
title: "dev-verify Reference"
sidebar_position: 20
---

# dev-verify Reference

> Multi-stack reference for `/dev-verify`. Loaded on demand via inline `> **Reference**:` pointers in SKILL.md.

---

## Build Pipeline Sequences

Per-stack build order with conditional ORM steps. Use these when executing the Bootstrap Validation Sequence (Step 6-10).

### Node.js / TypeScript

```
1. {pkg_mgr} install                    — pnpm install / npm install / yarn install
2. npx prisma generate                  — If prisma/schema.prisma exists
   OR npx drizzle-kit generate          — If drizzle.config.ts exists
3. npx tsc --noEmit                     — Type check (non-emit)
4. {pkg_mgr} run build                  — turbo run build (monorepo) / pnpm run build
```

**Monorepo variants:**
- `turbo.json` present → `turbo run build` respects pipeline topology
- `pnpm-workspace.yaml` without turbo → `pnpm -r run build` for recursive build
- Per-app type checks: `turbo run typecheck` or `pnpm --filter {app} run typecheck`

**Package manager detection** (from lockfile):
| Lockfile | Package Manager |
|---|---|
| `pnpm-lock.yaml` | `pnpm` |
| `package-lock.json` | `npm` |
| `yarn.lock` | `yarn` |

### PHP

```
1. composer install                     — Install dependencies
2. php artisan migrate --pretend        — If Laravel detected (dry-run migration check)
3. vendor/bin/phpstan analyse           — Static analysis (level from phpstan.neon)
4. composer run build                   — If build script exists in composer.json
```

**Laravel-specific:**
- Check `artisan` file exists before running artisan commands
- `php artisan config:cache` may be needed before phpstan
- For Octane: verify swoole/roadrunner extension is loaded

### Go

```
1. go mod download                      — Download dependencies
2. go generate ./...                    — If //go:generate directives exist
3. go vet ./...                         — Static analysis
4. go build ./cmd/...                   — Build all commands (or ./... for libraries)
```

**Go-specific:**
- `go vet` catches issues `go build` misses (unused variables, printf format strings)
- For sqlc: check `sqlc.yaml` exists, run `sqlc generate` before `go vet`
- For wire: check `wire.go` files, run `wire ./...` before build

---

## Error Pattern Matching

Per-stack error patterns mapped to the generic categories defined in SKILL.md Step 8.

### Node.js / TypeScript

| TS Error Code | Generic Category | Example |
|---|---|---|
| TS2307 | `missing-dependency` | Cannot find module '{package}' |
| TS2304 | `missing-dependency` | Cannot find name '{identifier}' (often missing @types/) |
| TS2305 | `export-import-mismatch` | Module has no exported member '{name}' |
| TS2614 | `export-import-mismatch` | Module has no default export |
| TS2339 | `type-mismatch` | Property '{name}' does not exist on type '{type}' |
| TS2322 | `type-mismatch` | Type '{a}' is not assignable to type '{b}' |
| TS18046 | `type-mismatch` | '{name}' is of type 'unknown' |

**Detection patterns:**
```
/error TS(\d+):/ → extract error code
/Cannot find module '([^']+)'/ → extract package name for missing-dependency
/has no exported member '([^']+)'/ → extract member name for export-import-mismatch
```

### PHP (PHPStan)

| PHPStan Pattern | Generic Category |
|---|---|
| `Class .* not found` | `missing-dependency` |
| `Call to undefined method` | `export-import-mismatch` |
| `Parameter .* expects .*, .* given` | `type-mismatch` |
| `Access to undefined property` | `type-mismatch` |

**Detection patterns:**
```
/Class ([A-Z][a-zA-Z\\]+) not found/ → extract class, check if package missing
/Call to undefined method ([A-Z][a-zA-Z\\]+)::(\w+)/ → extract class and method
```

### Go

| Go Error Pattern | Generic Category |
|---|---|
| `could not import` | `missing-dependency` |
| `undefined:` | `export-import-mismatch` |
| `cannot use .* as type` | `type-mismatch` |
| `imported and not used` | `config-mismatch` |
| `import cycle not allowed` | `schema-drift` |

**Detection patterns:**
```
/could not import ([a-z][a-z0-9./]+)/ → extract module path
/undefined: ([a-zA-Z]+)/ → extract identifier
/cannot use .* \(.*\) as type (.*)/ → extract expected type
```

---

## Auto-Fix Command Sequences

Per-stack fix commands for auto-fixable error categories. **Safety rule**: only apply fixes from this table. Report everything else.

### Node.js / TypeScript

| Category | Fix Command | Notes |
|---|---|---|
| `missing-dependency` | `{pkg_mgr} add {package}` | Extract package from TS2307 error message |
| `missing-dependency` (@types) | `{pkg_mgr} add -D @types/{package}` | If TS2304 and package exists in node_modules |
| `export-import-mismatch` | Edit: rename import to match actual export | Read target file exports first |
| `config-mismatch` | Edit: update tsconfig.json paths/aliases | Match existing path alias patterns |

### PHP

| Category | Fix Command | Notes |
|---|---|---|
| `missing-dependency` | `composer require {package}` | Extract from "Class not found" |
| `export-import-mismatch` | Edit: fix `use` statement namespace | Resolve from autoload map |
| `config-mismatch` | Edit: update config file | Match existing config patterns |

### Go

| Category | Fix Command | Notes |
|---|---|---|
| `missing-dependency` | `go get {module}` | Extract from "could not import" |
| `export-import-mismatch` | Edit: fix import path or identifier | Check exported names in target package |
| `config-mismatch` | Edit: remove unused import | Only for "imported and not used" |

### Auto-Fix Safety Matrix

| Category | Auto-Fix Safe? | Condition |
|---|---|---|
| `missing-dependency` | Yes | Package name matches `^[@a-z][a-z0-9./_-]*$` |
| `export-import-mismatch` | Yes | Single rename, target export verified to exist |
| `type-mismatch` | Conditional | Only simple casts (e.g., `as string`). If complex generics or union types → report only |
| `schema-drift` | Never | Always report. Suggest `/backend-data-model` re-run |
| `config-mismatch` | Yes | Config key exists in target file |

---

## Config-Implied Dependency Validation

Detection table for framework config signals that imply build dependencies. Pattern from `dev-project-assemble` Step 10.3.

### Node.js

| Config File | Signal | Required Dependency | Check In |
|---|---|---|---|
| `next.config.ts` | `reactCompiler: true` | `babel-plugin-react-compiler` | `package.json` devDependencies |
| `next.config.ts` | `@next/mdx` import | `@next/mdx`, `@mdx-js/react` | `package.json` dependencies |
| `next.config.ts` | `withPWA` wrapper | `next-pwa` | `package.json` dependencies |
| `tailwind.config.ts` | `@tailwindcss/typography` plugin | `@tailwindcss/typography` | `package.json` devDependencies |
| `vite.config.ts` | `@vitejs/plugin-react` import | `@vitejs/plugin-react` | `package.json` devDependencies |

### PHP

| Config File | Signal | Required Dependency | Check In |
|---|---|---|---|
| `composer.json` | `laravel/octane` in require | `swoole` ext OR `spiral/roadrunner` | `php -m` or `composer.json` |
| `composer.json` | `laravel/horizon` in require | Redis extension | `php -m` |

### Go

| Config File | Signal | Required Dependency | Check In |
|---|---|---|---|
| `sqlc.yaml` | exists | `sqlc` binary | `which sqlc` |
| `wire.go` | `//go:build wireinject` | `wire` binary | `which wire` |

**Validation algorithm:**
1. Read framework config files for signals
2. For each signal found, check if required dependency is present
3. If missing → classify as `missing-dependency` with config context

---

## Smoke Test Patterns

### Health Endpoint Conventions

| Framework | Health Path | Expected Response |
|---|---|---|
| Fastify | `/health` | `{ status: "ok" }` or `200 OK` |
| Express | `/health` | `200 OK` with JSON body |
| Next.js | `/api/health` | `200 OK` with JSON body |
| Laravel | `/api/health` | `200 OK` with JSON body |
| Symfony | `/health` | `200 OK` |
| Go (any) | `/health` | `200 OK` with JSON body |

### Production Detection Rules

**Never run write operations if any of these are detected:**
- `DATABASE_URL` contains `amazonaws.com`, `azure.com`, `cloud.google.com`
- `NODE_ENV=production` in loaded environment
- `.env.production` is the active env file
- Connection string contains hostnames that are not `localhost`, `127.0.0.1`, or `host.docker.internal`

### Write Endpoint Safety Protocol

1. Require explicit user approval via AskUserQuestion before each write endpoint test
2. Use unique identifiers in test data (prefix with `_jaan_test_`)
3. Record created resource IDs for cleanup
4. After testing: DELETE all created resources
5. Verify cleanup succeeded

---

## Integration Manifest Validation

How to use `.last-integration-manifest` from `dev-output-integrate` Step 13.

### Reading the Manifest

The manifest file is at `$JAAN_OUTPUTS_DIR/.last-integration-manifest`. Format: one relative path per line (relative to project root).

```
src/routes/auth/login.ts
src/routes/auth/register.ts
src/services/auth.service.ts
prisma/schema.prisma
```

### Scope Narrowing

When the manifest exists:
1. Read all paths from manifest
2. Scope build validation to these files (check that they compile)
3. Present: "Last integration included {N} files; validating all {N}..."

### Drift Detection

Compare manifest against current project state:
- Files in manifest but missing from project → flag as "integration gap"
- Files in project modified after manifest timestamp → note as "post-integration changes"

---

## Frontend Health Detection

Frontend frameworks that serve HTML rather than JSON health endpoints.

| Framework | Default Port | Check URL | Expected |
|---|---|---|---|
| Next.js | 3000 | `GET /` | HTTP 200, HTML content |
| Vite (React/Vue) | 5173 | `GET /` | HTTP 200, HTML content |
| Laravel Blade/Inertia | 8000 (shared) | `GET /` | HTTP 200, HTML content |
| Go templates | 8080 (shared) | `GET /` | HTTP 200, HTML content |

**Shared-port services**: Laravel Blade/Inertia and Go templates serve both API and frontend on the same port. Check both `/api/health` (JSON) and `/` (HTML) on the same port.

---

## Framework-Agnostic Routing Detection

How to discover available routes for contract validation and smoke tests.

### File-Based Routing
- **Next.js** `app/` directory: Each `page.tsx` → route path. Also check `route.ts` for API routes.
- **Nuxt** `pages/` directory: Same convention as Next.js.

### Config-Based Routing
- **Laravel** `routes/api.php`: Parse `Route::get()`, `Route::post()`, etc.
- **Go** `http.ServeMux` or chi router: Parse `r.Get()`, `r.Post()`, `mux.HandleFunc()` patterns.
- **Fastify**: Parse route registration in plugin files.

### Hybrid Routing
- **Laravel + Inertia**: Backend routes at `/api/*` (from `routes/api.php`), frontend routes at `/*` (from `routes/web.php`).
- **Go + templates**: API routes and template routes on same server.

### Route Discovery Priority
1. OpenAPI spec (most authoritative)
2. Framework route config files
3. File-based routing conventions
4. Fallback: `/health` and `/` only
