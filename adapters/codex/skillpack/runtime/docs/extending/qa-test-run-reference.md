# qa-test-run — Reference Material

> Extracted reference tables, code templates, and patterns for the `qa-test-run` skill.
> This file is loaded by `qa-test-run` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Multi-Stack Test Commands

### Node.js / TypeScript

| Tier | Runner | Command | Reporter Flag | Coverage Flag |
|------|--------|---------|--------------|---------------|
| Unit | Vitest | `npx vitest run --workspace=unit` | `--reporter=json` | `--coverage` |
| Unit | Jest | `npx jest --testPathPattern=unit` | `--json --outputFile=results.json` | `--coverage --coverageReporters=json-summary` |
| Integration | Vitest | `npx vitest run --workspace=integration` | `--reporter=json` | `--coverage` |
| Integration | Jest | `npx jest --testPathPattern=integration` | `--json` | `--coverage` |
| E2E | Playwright | `npx playwright test` | `--reporter=json` | N/A |
| E2E | Cypress | `npx cypress run` | `--reporter=json` | N/A |

**Package manager detection**:
- `pnpm-lock.yaml` → use `pnpm exec` instead of `npx`
- `yarn.lock` → use `yarn` instead of `npx`
- `package-lock.json` → use `npx` (default)

**Environment variables**:
- `NODE_ENV=test`
- `DATABASE_URL` from `.env.test`
- `CI=true` for consistent snapshot behavior

### PHP

| Tier | Runner | Command | Reporter Flag | Coverage Flag |
|------|--------|---------|--------------|---------------|
| Unit | PHPUnit | `vendor/bin/phpunit --testsuite=unit` | `--log-junit=results.xml` | `--coverage-clover=coverage.xml` |
| Unit | Pest | `vendor/bin/pest --testsuite=unit` | `--log-junit=results.xml` | `--coverage-clover=coverage.xml` |
| Feature | PHPUnit | `vendor/bin/phpunit --testsuite=feature` | `--log-junit=results.xml` | `--coverage-clover=coverage.xml` |
| Browser | Laravel Dusk | `php artisan dusk` | `--log-junit=results.xml` | N/A |
| Browser | Codeception | `vendor/bin/codecept run acceptance` | `--xml=results.xml` | N/A |

**Coverage driver detection**:
- `php -m | grep xdebug` → Xdebug available
- `php -m | grep pcov` → PCOV available (faster, preferred)
- Set `XDEBUG_MODE=coverage` if using Xdebug

### Go

| Tier | Command | Reporter Flag | Coverage Flag |
|------|---------|--------------|---------------|
| Unit | `go test ./...` | `-json` | `-cover -coverprofile=coverage.out` |
| Integration | `go test ./... -tags=integration` | `-json` | `-cover -coverprofile=coverage.out` |
| E2E | `go test ./... -tags=e2e` | `-json` | N/A |

**Test timeout**: Default 10m for unit, 30m for integration. Set with `-timeout` flag.

---

## Parallel Execution Strategy

### When to Parallelize

- **Unit tests**: Almost always safe to parallelize (stateless by design)
- **Integration tests**: Safe if each test uses isolated DB transactions or test containers
- **E2E tests**: Playwright handles parallelism via separate browser workers with zero shared state

### Per-Stack Configuration

**Vitest** (fastest config for CI):
```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    pool: 'threads',
    poolOptions: { threads: { maxThreads: 8, minThreads: 4 } },
    isolate: false,        // Disable for stateless unit tests only
    fileParallelism: true,
    maxConcurrency: 10,    // For .concurrent tests
  },
})
```

**Playwright** (CI-optimized with sharding):
```typescript
// playwright.config.ts
export default defineConfig({
  fullyParallel: true,
  workers: process.env.CI ? 4 : undefined,
  maxFailures: process.env.CI ? 10 : undefined,
  retries: process.env.CI ? 2 : 0,
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
})
```
CI sharding: `npx playwright test --shard=${{ matrix.shardIndex }}/${{ matrix.shardTotal }}`

**PHPUnit + ParaTest**:
```bash
# Install: composer require --dev brianium/paratest
vendor/bin/paratest -p8 --runner WrapperRunner
# Laravel: php artisan test --parallel --processes=4
```

**Go**:
```go
func TestAPICreate(t *testing.T) {
    t.Parallel() // Mark I/O-bound tests as parallel-safe
}
```
```bash
go test ./... -parallel 128 -p 16 -count=1
```
Caution: Lightweight CPU-bound unit tests may be slower with `t.Parallel()` due to goroutine scheduling overhead.

**pytest-xdist**:
```bash
pip install pytest-xdist
pytest -n auto --dist loadscope  # Group by module (keeps fixtures together)
pytest -n 8 --dist load          # Max throughput
```

### Coverage Tool Performance Comparison

| Stack | Provider | Overhead vs Baseline | Branch Coverage | Recommendation |
|-------|----------|---------------------|-----------------|----------------|
| JS/TS | V8 (`@vitest/coverage-v8`) | ~10% | Block-level | **CI default** -- no instrumentation needed |
| JS/TS | Istanbul (`@vitest/coverage-istanbul`) | ~300% | Statement-level | Local only when V8 accuracy insufficient |
| PHP | PCOV | ~34% (18.9s vs 14.0s baseline) | Line only | **CI default** -- 2.8x faster than Xdebug |
| PHP | Xdebug 3 (line mode) | ~280% (53.5s) | Line + branch | Local debugging only |
| PHP | Xdebug 3 (path mode) | ~950% (146.8s) | Full path | Never in CI |
| Go | `go test -cover` (set mode) | <1% | N/A | **Always** -- compile-time rewriting |
| Go | `go test -cover` (atomic mode) | ~3-5% | N/A | Required for parallel tests |
| Python | coverage.py (line) | ~200-300% | Line | Default |
| Python | coverage.py (branch) | ~500% | Branch | Only when needed |

Benchmarks from Sebastian Bergmann (PHP, Dec 2025) and Vitest v3.2.0+ docs.

### E2E Authentication Caching (Playwright storageState)

Authenticate once in a setup project, reuse session across all tests:

```typescript
// auth.setup.ts
import { test as setup } from '@playwright/test';
setup('authenticate', async ({ request }) => {
  await request.post('/api/login', {
    form: { user: 'testuser', password: 'pass123' },
  });
  await request.storageState({ path: '.auth/user.json' });
});
```

```typescript
// playwright.config.ts projects
projects: [
  { name: 'setup', testMatch: /.*\.setup\.ts/ },
  {
    name: 'chromium',
    dependencies: ['setup'],
    use: { storageState: '.auth/user.json' },
  },
],
```

---

## Health Check Matrix

### Node.js

| Check | Detection | Auto-Fix Command | Skip If |
|-------|-----------|-----------------|---------|
| node_modules exists | `ls node_modules/` | `npm install` / `pnpm install` / `yarn` | Already exists |
| Prisma client generated | `ls node_modules/.prisma/client/` | `npx prisma generate` | No prisma schema |
| .env.test exists | `ls .env.test` | Copy `.env.example` → `.env.test` (ask user for values) | Already exists |
| Vitest config exists | `ls vitest.config.*` | Report missing (cannot auto-create) | Not using Vitest |
| Playwright installed | `npx playwright --version` | `npx playwright install` | Not using Playwright |
| E2E server config | Check `webServer` in playwright.config | Report if missing | Not running E2E |

### PHP

| Check | Detection | Auto-Fix Command | Skip If |
|-------|-----------|-----------------|---------|
| vendor exists | `ls vendor/` | `composer install` | Already exists |
| .env.testing exists | `ls .env.testing` | Copy `.env.example` → `.env.testing` | Already exists |
| Autoload fresh | `composer dump-autoload` timestamp | `composer dump-autoload` | Recent dump |
| DB migrations | `php artisan migrate:status --env=testing` | `php artisan migrate --env=testing` | No artisan |
| APP_KEY set | `grep APP_KEY .env.testing` | `php artisan key:generate --env=testing` | Key exists |

### Go

| Check | Detection | Auto-Fix Command | Skip If |
|-------|-----------|-----------------|---------|
| go.sum exists | `ls go.sum` | `go mod tidy` | Already exists |
| go generate fresh | Check generated file timestamps | `go generate ./...` | No generate directives |
| sqlc generated | `ls` sqlc output dirs | `sqlc generate` | No sqlc.yaml |
| Test build succeeds | `go test -run=^$ ./...` | Report errors | N/A |

---

## Error Pattern Detection

### Node.js / TypeScript

| Category | Regex Pattern | Example |
|----------|--------------|---------|
| Import/Module | `Cannot find module '([^']+)'` | Cannot find module '@/services/user' |
| Import/Module | `Module not found: Error: Can't resolve '([^']+)'` | Module not found: Error: Can't resolve 'msw' |
| ORM/DB client | `@prisma/client did not initialize` | Prisma client not generated |
| ORM/DB client | `PrismaClientInitializationError` | Database connection failed |
| Environment | `Environment variable ([A-Z_]+) is not set` | DATABASE_URL not set |
| Assertion | `expect\(received\)\.to(Equal|Be|Match)` | Assertion mismatch |
| Timeout/Async | `Exceeded timeout of (\d+) ?ms` | Test timed out |
| Timeout/Async | `act\(\) warning` | Missing act() wrapper |
| Database/State | `relation "([^"]+)" does not exist` | Table not created |
| Mock/Fixture | `No request handler found for` | MSW handler missing |
| Mock/Fixture | `Snapshot .+ mismatched` | Stale snapshot |

### PHP

| Category | Regex Pattern | Example |
|----------|--------------|---------|
| Import/Module | `Class '([^']+)' not found` | Class 'App\Services\User' not found |
| ORM/DB client | `SQLSTATE\[42S02\]` | Table doesn't exist |
| Environment | `Missing (?:required )?environment variable: ([A-Z_]+)` | Missing DB credentials |
| Assertion | `Failed asserting that` | Assertion mismatch |
| Timeout/Async | `Maximum execution time of (\d+) seconds exceeded` | Script timeout |
| Database/State | `SQLSTATE\[42S01\].*already exists` | Migration conflict |

### Go

| Category | Regex Pattern | Example |
|----------|--------------|---------|
| Import/Module | `cannot find package "([^"]+)"` | Missing dependency |
| ORM/DB client | `sql: database is closed` | Connection pool exhausted |
| Environment | `required key ([A-Z_]+) missing value` | Missing env var |
| Assertion | `expected .+ got .+` | Assertion mismatch (testify) |
| Timeout/Async | `panic: test timed out after` | Test timeout |
| Timeout/Async | `goroutine .+ \[chan send\]` | Goroutine leak |
| Database/State | `pq: relation "([^"]+)" does not exist` | Missing migration |

---

## Coverage Parsing Rules

### Node.js (Istanbul/v8 JSON)

File: `coverage/coverage-summary.json`

```json
{
  "total": {
    "lines": { "total": 1000, "covered": 800, "pct": 80 },
    "branches": { "total": 200, "covered": 140, "pct": 70 },
    "functions": { "total": 100, "covered": 85, "pct": 85 }
  },
  "path/to/file.ts": { ... }
}
```

Extract: `total.lines.pct`, `total.branches.pct`, per-file coverage for uncovered report.

### PHP (Clover XML)

File: `coverage.xml` or `build/logs/clover.xml`

```xml
<coverage generated="...">
  <project>
    <metrics statements="1000" coveredstatements="800"
             conditionals="200" coveredconditionals="140" />
  </project>
</coverage>
```

Calculate: `coveredstatements / statements * 100`, `coveredconditionals / conditionals * 100`.

### Go (coverprofile)

File: `coverage.out`

```
mode: atomic
package/file.go:10.2,12.5 1 1
package/file.go:14.2,16.5 1 0
```

Parse with: `go tool cover -func=coverage.out` for per-function coverage.
Total line: `total:    (statements)    80.0%`

---

## Auto-Fix Procedures

### Import/Module Resolution

**Node.js**:
1. Check if module is a project dependency: `grep {module} package.json`
2. If missing: report to user (don't auto-install packages)
3. If path alias issue: check `tsconfig.json` paths and fix import

**PHP**:
1. Run `composer dump-autoload`
2. Check PSR-4 mapping in `composer.json`
3. Verify namespace matches directory structure

**Go**:
1. Run `go mod tidy`
2. Check if import path matches module name in `go.mod`

### ORM/DB Client Generation

**Node.js (Prisma)**:
1. `npx prisma generate`
2. Verify `node_modules/.prisma/client/` populated
3. If schema changed: `npx prisma db push --accept-data-loss` (test DB only, ask first)

**PHP (Eloquent)**:
1. `php artisan migrate:fresh --env=testing --seed`
2. Verify tables created

**Go (sqlc)**:
1. `sqlc generate`
2. Verify generated files match schema

### Environment Configuration

1. Identify missing variable from error message
2. Check `.env.example` for default/placeholder
3. Use AskUserQuestion: "What value should {VAR_NAME} have in the test environment?"
4. Write to `.env.test` / `.env.testing`

---

## Selective Re-Run Commands

### Node.js

| Runner | Re-Run Failed Only | Re-Run Specific File | Re-Run Specific Test |
|--------|-------------------|---------------------|---------------------|
| Vitest | `npx vitest run {file1} {file2}` | `npx vitest run path/to/test.ts` | `npx vitest run -t "test name"` |
| Jest | `npx jest --onlyFailures` | `npx jest path/to/test.ts` | `npx jest -t "test name"` |
| Playwright | `npx playwright test {file1} {file2}` | `npx playwright test path/to/spec.ts` | `npx playwright test -g "test name"` |

### PHP

| Runner | Re-Run Failed Only | Re-Run Specific File | Re-Run Specific Test |
|--------|-------------------|---------------------|---------------------|
| PHPUnit | `vendor/bin/phpunit --filter="TestName"` | `vendor/bin/phpunit tests/Unit/UserTest.php` | `vendor/bin/phpunit --filter="testMethod"` |
| Pest | `vendor/bin/pest --filter="test name"` | `vendor/bin/pest tests/Unit/UserTest.php` | `vendor/bin/pest --filter="test name"` |

### Go

| Re-Run Failed Only | Re-Run Specific File | Re-Run Specific Test |
|-------------------|---------------------|---------------------|
| `go test -json -run "TestName" ./package/...` | `go test -json ./package/...` | `go test -json -run "^TestSpecific$" ./package/...` |

---

## Changed Code Only (Selective Execution)

Run only tests affected by recent code changes for faster feedback loops:

| Stack | Command | How It Works |
|-------|---------|-------------|
| JS/TS (Vitest) | `npx vitest --changed HEAD~1` | Uses git diff to find changed source files, runs related tests |
| JS/TS (Jest) | `npx jest --changedSince=main` | Runs tests related to files changed since branch point |
| JS/TS (Playwright) | `npx playwright test --grep @smoke` | Tag-based selection (no automatic changed-file detection) |
| PHP | `vendor/bin/phpunit --filter="TestClassName"` | Manual filter (no native git-diff integration) |
| Go | `go test $(go list ./... \| grep -f <(git diff --name-only main \| sed 's|/[^/]*$||' \| sort -u))` | Shell pipeline matching changed packages |
| Python | `pytest --lf` (last failed) or `pytest-testmon` | `testmon` tracks code-to-test mapping automatically |

**Monorepo tools** (Nx, Turborepo) provide affected-project detection automatically:
- Nx: `npx nx affected --target=test`
- Turborepo: `npx turbo run test --filter=...[HEAD~1]`

---

## Key Execution Rules

1. **Always use machine-parseable output** -- JSON for Node/Go, XML for PHP. Never parse text output.
2. **Execute tiers sequentially** -- unit first (fast feedback), then integration, then E2E.
3. **Stop tier on catastrophic failure** -- if >80% of tests in a tier fail, likely a setup issue. Diagnose before continuing.
4. **Never auto-fix assertion failures** -- these represent actual bugs. Only auto-fix infrastructure issues.
5. **Ask before modifying env files** -- environment values may contain secrets. Always use AskUserQuestion.
6. **Track auto-fix results separately** -- report which tests were fixed vs which still fail.
7. **Parse coverage before next tier** -- coverage output may be overwritten by subsequent tiers.
8. **Use test DB only** -- never run tests against production or staging databases.

---

## Contract Validation Tier

The `--contract` tier delegates API contract validation to `/jaan-to:qa-contract-validate` rather than executing contract tools directly.

### Rationale

- `qa-test-run` does not have Spectral/oasdiff/Prism/Schemathesis in its `allowed-tools`
- `qa-contract-validate` is the sole owner of contract validation logic
- Delegation prevents ownership duplication and tool drift

### Contract discovery

Search order:
1. `specs/openapi.yaml` or `specs/openapi.json` in project root
2. `$JAAN_OUTPUTS_DIR/backend/api-contract/**/openapi.yaml`

### Output report integration

| Contract Status | Report Entry |
|----------------|-------------|
| Contract found, delegation suggested | "DELEGATED to qa-contract-validate" |
| No contract found | "SKIPPED (no contract)" |
| Never | "PASS" (contract tier cannot pass within qa-test-run) |
