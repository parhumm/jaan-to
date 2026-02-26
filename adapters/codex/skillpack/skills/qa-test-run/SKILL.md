---
name: qa-test-run
description: Execute tests, diagnose failures, auto-fix simple issues, generate coverage reports. Use when running and debugging test suites.
allowed-tools: Read, Glob, Grep, Bash(npm test:*), Bash(npm run test:*), Bash(npm run lint:*), Bash(npx vitest:*), Bash(npx jest:*), Bash(npx playwright:*), Bash(npx tsc:*), Bash(npx prisma generate:*), Bash(pnpm test:*), Bash(pnpm run test:*), Bash(pnpm run lint:*), Bash(pnpm exec:*), Bash(yarn test:*), Bash(yarn run test:*), Bash(composer test:*), Bash(composer dump-autoload:*), Bash(go test:*), Bash(go generate:*), Bash(go mod tidy:*), Bash(go tool cover:*), Bash(php artisan test:*), Bash(php artisan migrate:*), Bash(vendor/bin/phpunit:*), Bash(vendor/bin/pest:*), Write($JAAN_OUTPUTS_DIR/qa/test-run/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [qa-test-generate-output | test-directory] [--unit | --integration | --e2e | --all]
license: PROPRIETARY
---

# qa-test-run

> Execute tests across stacks, diagnose failures, auto-fix simple issues, and generate coverage reports.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL -- determines test runners, package manager, framework)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to-qa-test-run.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to-qa-test-run.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Test Source**: $ARGUMENTS

Accepts 1-2 arguments:
- **qa-test-generate output** (preferred) -- Path to qa-test-generate output directory (from `/jaan-to:qa-test-generate`)
- **test directory** -- Path to existing test directory in the project
- **Tier filter** (optional) -- `--unit`, `--integration`, `--e2e`, `--mutation`, or `--all` (default: `--all`)
- **Empty** -- Interactive wizard prompting for test location and tier

IMPORTANT: The input above is your starting point. Determine mode and proceed accordingly.

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `qa-test-run`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_qa-test-run`

> **Language exception**: Test execution output (command output, error messages, stack traces) is NOT affected by this setting and remains in the project's language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing test file structure and framework detection
- Planning execution order across tiers
- Diagnosing failure patterns and categorizing root causes
- Determining auto-fix feasibility vs manual intervention

## Step 1: Validate & Parse Inputs

**If qa-test-generate output provided**:
1. Read the output directory structure
2. Identify config files (vitest.config.ts, playwright.config.ts, etc.)
3. Identify test files by tier (unit/, integration/, e2e/)
4. Extract test framework from config files

**If test directory provided**:
1. Scan directory for test files
2. Detect test framework from config files or file patterns
3. Classify tests into tiers by naming convention

**If no input**:
Use AskUserQuestion:
- "Where are your test files located?"
- "Which test tiers to run?" Options: "All", "Unit only", "Integration only", "E2E only"

## Step 2: Detect Tech Stack

Read `$JAAN_CONTEXT_DIR/tech.md` for framework detection.

| tech.md value | Test Runner | E2E Runner | Coverage Tool | Package Manager | Test Command Prefix |
|---------------|-------------|------------|---------------|-----------------|---------------------|
| Node.js / TypeScript | Vitest / Jest | Playwright / Cypress | @vitest/coverage-v8 / istanbul | pnpm / npm / yarn | `npx` / `pnpm exec` |
| PHP | PHPUnit / Pest | Laravel Dusk / Codeception | PHPUnit coverage (Xdebug/PCOV) | composer | `vendor/bin/` |
| Go | `go test` (stdlib) | Rod / Chromedp | `go test -cover` (built-in) | go mod | `go test` |

**Fallback**: If tech.md missing → detect from lockfiles (package-lock.json, composer.lock, go.sum) + config files (vitest.config.*, phpunit.xml, *_test.go) → AskUserQuestion if ambiguous.

## Step 3: Scan Test Files by Tier

Scan per detected stack:

**Node.js/TypeScript**:
- Unit: `*.test.{ts,tsx}`, `*.spec.{ts,tsx}` in `test/unit/` or `__tests__/`
- Integration: `*.integration.test.*`, `*.int.test.*` in `test/integration/`
- E2E: `*.spec.{ts,tsx}` in `test/e2e/`, `e2e/`, or `tests/`

**PHP**:
- Unit: `*Test.php` in `tests/Unit/`
- Integration: `*Test.php` in `tests/Feature/`
- E2E: `*Test.php` in `tests/Browser/`

**Go**:
- Unit: `*_test.go` in package directories (no build tags)
- Integration: `*_test.go` with `//go:build integration` tag
- E2E: `*_test.go` with `//go:build e2e` tag

Present file counts per tier.

## Step 4: Pre-Execution Health Checks

Run stack-aware health checks before execution:

| Check | Node.js | PHP | Go |
|-------|---------|-----|-----|
| Dependencies installed | `node_modules/` exists | `vendor/` exists | `go.sum` exists |
| ORM client generated | Prisma: `npx prisma generate` | Eloquent: migrations run | sqlc: `sqlc generate` |
| Test env file | `.env.test` or `.env.testing` | `.env.testing` | `_test` build tag |
| E2E server | webServer config in playwright | artisan serve | custom server |

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Health Check Matrix" for per-stack detailed checks and fix commands.

If any check fails → report issue and offer auto-fix (Step 6).

## Step 5: Build Execution Plan

Construct commands per tier based on detected stack and framework:

**Node.js/TypeScript**:
- Unit: `npx vitest run --workspace=unit --reporter=json`
- Integration: `npx vitest run --workspace=integration --reporter=json`
- E2E: `npx playwright test --reporter=json`

**PHP**:
- Unit: `vendor/bin/phpunit --testsuite=unit --log-junit=results.xml`
- Integration: `vendor/bin/phpunit --testsuite=feature --log-junit=results.xml`
- E2E: `vendor/bin/phpunit --testsuite=browser --log-junit=results.xml`

**Go**:
- Unit: `go test ./... -json -cover`
- Integration: `go test ./... -json -cover -tags=integration`
- E2E: `go test ./... -json -tags=e2e`

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Multi-Stack Test Commands" for full command tables with flags, environment variables, and framework-specific options.

Present execution plan with estimated test counts per tier.

---

# HARD STOP -- Human Review Check

Show complete analysis and execution plan:

```
TEST EXECUTION PLAN
-------------------------------------------------------------
Stack:              {detected_stack}
Test Runner:        {detected_runner}
Coverage Tool:      {detected_coverage}
Package Manager:    {detected_pm}

Health Checks:      {pass_count}/{total} passed
  {list_of_checks_with_status}

Tests Found:
  Unit:             {count} files ({scenario_count} tests)
  Integration:      {count} files ({scenario_count} tests)
  E2E:              {count} files ({scenario_count} tests)

Execution Order:    unit → integration → E2E
Tier Filter:        {all|unit|integration|e2e}

{health_check_issues_if_any}
```

Use AskUserQuestion:
- Question: "Proceed with test execution?"
- Header: "Run Tests"
- Options:
  - "Yes" -- Execute tests as planned
  - "No" -- Cancel
  - "Edit" -- Change tier filter or fix health issues first

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Execution (Write Phase)

## Step 6: Auto-Fix Simple Issues

Before running tests, attempt to fix common issues (stack-aware):

**Node.js**:
- Generate Prisma client: `npx prisma generate`
- Create `.env.test` from `.env.example`
- Fix import paths for moved test files

**PHP**:
- Run `composer dump-autoload`
- Create `.env.testing` from `.env.example`
- Run pending migrations: `php artisan migrate --env=testing`

**Go**:
- Run `go generate ./...`
- Verify test build tags are correct
- Run `go mod tidy`

For environment values (DB URLs, API keys), use AskUserQuestion to get actual values from the user -- never guess or use placeholders.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Auto-Fix Procedures" for per-stack step-by-step procedures.

## Step 7: Execute Tests Sequentially

Run tests in order: **unit → integration → E2E**

For each tier:
1. Run the test command with JSON/XML reporter for reliable parsing
2. Capture stdout, stderr, and exit code
3. Parse results into structured format
4. Record pass/fail/skip counts
5. If failures detected → proceed to Step 8 (diagnose) before next tier

**Important**: Use `--reporter=json` (Vitest), `--reporter=json` (Playwright), `--log-junit` (PHPUnit), or `-json` (Go) for machine-parseable output. Never rely on text output parsing.

## Step 8: Diagnose Failures

Categorize each failure into generic categories:

| Category | Auto-Fix | Examples |
|----------|----------|---------|
| Import/Module resolution | Yes | Missing modules, wrong paths, autoload issues |
| ORM/DB client generation | Yes | Prisma not generated, Eloquent not migrated, sqlc stale |
| Environment configuration | Yes (ask value) | Missing env vars, wrong DB URLs |
| Assertion failures | No (manual) | Business logic mismatches |
| Timeout/Async errors | Suggest fix | Slow operations, missing await, goroutine leaks |
| Database/State errors | Suggest fix | Missing migrations, seed data, connection refused |
| Mock/Fixture errors | Suggest fix | Stale snapshots, missing handlers, mock mismatches |

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Error Pattern Detection" for per-stack regex patterns to identify each category.

For auto-fixable categories: apply fix and mark for re-run.
For manual categories: collect diagnostic info for the report.

## Step 9: Re-Run Failed Tests

After auto-fixes, selectively re-run only failed tests:

**Node.js (Vitest)**: `npx vitest run --reporter=json {failed_test_files}`
**Node.js (Playwright)**: `npx playwright test --reporter=json {failed_spec_files}`
**PHP (PHPUnit)**: `vendor/bin/phpunit --filter="{FailedTestName}"`
**Go**: `go test -json -run "TestName" ./package/...`

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Selective Re-Run Commands" for per-framework re-run flags and options.

Track which tests were fixed by auto-fix vs still failing.

## Step 10: Parse Coverage

Parse coverage output per stack:

**Node.js**: Istanbul/v8 JSON from `coverage/coverage-summary.json`
**PHP**: PHPUnit Clover XML from `coverage.xml` or `build/logs/clover.xml`
**Go**: `go test -coverprofile=coverage.out` → parse with `go tool cover`

Extract:
- Line coverage percentage
- Branch coverage percentage (where available)
- Uncovered files and functions
- Coverage delta from previous run (if baseline exists)

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Coverage Parsing Rules" for per-stack parsing patterns and output formats.

## Step 10a: Parse Mutation Score (if --mutation or --all with mutation config detected)

If `--mutation` tier selected OR mutation tool config detected (stryker.config.*, infection.json5, etc.):

Parse mutation score from **mutation tool outputs only** (never conflate with code coverage):
- **StrykerJS**: `reports/mutation/mutation.json` -> `mutationScore`
- **Infection**: `infection-log.json` -> `stats.msi`
- **go-mutesting**: parse stdout `killed/total` ratio (NOT `go test -cover`)
- **mutmut**: `mutmut results` CLI output -> parse survived/killed/total counts (NOT `.mutmut-cache` SQLite)

If mutation tool not available for stack: report `mutation_score: null` (JSON null, NOT `"N/A"`) and exclude from quality-gate weighting. Parsers treat `null` as "not measured", `0` as "measured zero".

Add mutation results to output report:
- Mutation score percentage
- Surviving mutants count
- Top 5 survivor locations (file:line with mutator type)

### Iteration Tracking

Track RED-GREEN cycle count during test execution:
- Cap at configurable limit (default 10 cycles)
- If same test fails 3 times with same error pattern: escalate via AskUserQuestion with error context
- Include cycle count in final report

## Step 11: Generate Report

Compile results into structured report:

### 11.1 Generate Output Metadata

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/qa/test-run"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

Generate slug from test directory or project name (lowercase-kebab-case, max 50 chars).

### 11.2 Generate Executive Summary

```
Test execution for {project_name}: {total_tests} tests across {tier_count} tiers.
{pass_count} passed, {fail_count} failed, {skip_count} skipped.
{auto_fix_count} failures auto-fixed. Coverage: {line_pct}% line, {branch_pct}% branch.
```

### 11.3 Show Preview

```
OUTPUT PREVIEW
-------------------------------------------------------------
ID:     {NEXT_ID}
Folder: $JAAN_OUTPUTS_DIR/qa/test-run/{NEXT_ID}-{slug}/

Results:
  Unit:        {pass}/{total} passed ({coverage}% coverage)
  Integration: {pass}/{total} passed ({coverage}% coverage)
  E2E:         {pass}/{total} passed

Auto-Fixes Applied: {count}
Remaining Failures: {count}
```

Use AskUserQuestion:
- Question: "Write test execution report?"
- Header: "Write Report"
- Options:
  - "Yes" -- Write report to output
  - "No" -- Cancel
  - "Refine" -- Make adjustments first

## Step 12: Write Output Files

If approved:

### 12.1 Create Folder

```bash
OUTPUT_FOLDER="$JAAN_OUTPUTS_DIR/qa/test-run/${NEXT_ID}-${slug}"
mkdir -p "$OUTPUT_FOLDER"
```

### 12.2 Write Main Document

Path: `$OUTPUT_FOLDER/${NEXT_ID}-${slug}.md`

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to-qa-test-run.template.md`

Fill sections:
- Title, Executive Summary
- Test Execution Results (per tier with pass/fail/skip counts)
- Coverage Report (line, branch, uncovered functions)
- Failure Analysis (categorized with diagnostics)
- Auto-Fix Summary (what was fixed, how)
- Suggested Fixes (for manual failures)
- Coverage Gaps (uncovered areas)
- Next Steps
- Metadata

### 12.3 Update Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Project Name} Test Execution" \
  "{Executive Summary}"
```

### 12.4 Confirm Completion

```
TEST EXECUTION COMPLETE
-------------------------------------------------------------
ID:          {NEXT_ID}
Folder:      $JAAN_OUTPUTS_DIR/qa/test-run/{NEXT_ID}-{slug}/
Index:       Updated $JAAN_OUTPUTS_DIR/qa/test-run/README.md

Results:
  Total:       {total_tests} tests
  Passed:      {pass_count}
  Failed:      {fail_count}
  Skipped:     {skip_count}
  Auto-Fixed:  {auto_fix_count}

Coverage:
  Line:        {line_pct}%
  Branch:      {branch_pct}%
```

## Step 13: Suggest Next Actions

> **Test execution complete!**
>
> **Next Steps:**
> - Review failure diagnostics in the report
> - Fix remaining assertion failures manually
> - Re-run with `/jaan-to:qa-test-run {output-path} --all` after fixes
> - Use `/jaan-to:qa-test-generate` to generate tests for uncovered areas
> - See the report for detailed coverage gaps and suggested improvements

## Step 14: Capture Feedback

Use AskUserQuestion:
- Question: "How did the test execution turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- What should I improve?
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add qa-test-run "{feedback}"`

---

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-run-reference.md` section "Key Execution Rules" for test execution best practices, tier ordering rationale, and anti-patterns to avoid.

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] Tech stack detected from tech.md or fallback
- [ ] Test files scanned and classified by tier
- [ ] Health checks passed (or auto-fixed)
- [ ] Tests executed sequentially: unit → integration → E2E
- [ ] Failures diagnosed and categorized
- [ ] Auto-fixable issues fixed and re-run
- [ ] Coverage parsed per stack
- [ ] Sequential ID generated
- [ ] Report written to `$JAAN_OUTPUTS_DIR/qa/test-run/{id}-{slug}/`
- [ ] Index updated
- [ ] User approved final result
