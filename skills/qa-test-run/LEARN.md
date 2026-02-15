# Lessons: qa-test-run

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:qa-test-run.learn.md`

## Better Questions

- Ask about test database availability before running integration tests -- missing DB causes all integration tests to fail with connection errors
- Confirm coverage thresholds if not configured in vitest.config or phpunit.xml -- teams have different standards
- Ask about E2E server startup method -- some projects need manual server start, others use webServer config in Playwright
- Ask if there are known flaky tests to exclude or retry -- avoids wasting time on known issues
- Check if the project uses a monorepo with multiple test configurations -- single-root assumptions break in workspaces

## Edge Cases

- Monorepo with multiple package.json / composer.json files -- each workspace may have its own test runner and config
- Different coverage output directories per framework -- Vitest defaults to `coverage/`, Jest to `coverage/`, PHPUnit varies
- MSW v1 (`rest.get`) vs v2 (`http.get`) syntax in Node.js projects -- auto-fix must detect the correct version
- Xdebug vs PCOV for PHP coverage -- PCOV is faster but may not be installed; Xdebug needs `XDEBUG_MODE=coverage`
- Go test cache invalidation -- `go test -count=1` forces re-run, otherwise cached results may be returned
- Playwright browser binaries not installed -- `npx playwright install` is needed after fresh npm install
- Test files that import from build output (dist/) instead of source -- build may be stale

## Workflow

- Run health checks before any test execution -- catching setup issues early prevents misleading failure cascades
- Execute tiers sequentially (unit → integration → E2E) -- fast feedback first, expensive tests last
- Parse coverage output after each tier before the next tier runs -- subsequent tiers may overwrite coverage files
- Use selective re-run after auto-fixes instead of full re-run -- saves time when only a few tests were affected
- Capture auto-fix results separately from test results -- users need to know what was fixed vs what genuinely failed

## Common Mistakes

- Don't assume npm -- always check lockfiles (pnpm-lock.yaml, yarn.lock, package-lock.json) for the correct package manager
- Don't auto-fix assertion failures -- these represent actual bugs, not infrastructure issues
- Don't skip remaining tiers when one tier fails -- later tiers may have independent useful results
- Don't parse text output from test runners -- always use JSON/XML reporters for reliable structured data
- Don't run tests against production or staging databases -- always verify the database URL points to a test instance
- Don't guess environment variable values -- always use AskUserQuestion to get actual values from the user
- Don't ignore `afterEach` cleanup failures -- leaked state causes cascading failures in subsequent tests
