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

## Key Execution Rules

1. **Always use machine-parseable output** -- JSON for Node/Go, XML for PHP. Never parse text output.
2. **Execute tiers sequentially** -- unit first (fast feedback), then integration, then E2E.
3. **Stop tier on catastrophic failure** -- if >80% of tests in a tier fail, likely a setup issue. Diagnose before continuing.
4. **Never auto-fix assertion failures** -- these represent actual bugs. Only auto-fix infrastructure issues.
5. **Ask before modifying env files** -- environment values may contain secrets. Always use AskUserQuestion.
6. **Track auto-fix results separately** -- report which tests were fixed vs which still fail.
7. **Parse coverage before next tier** -- coverage output may be overwritten by subsequent tiers.
8. **Use test DB only** -- never run tests against production or staging databases.
