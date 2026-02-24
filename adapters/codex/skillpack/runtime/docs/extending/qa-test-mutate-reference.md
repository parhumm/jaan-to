# qa-test-mutate Reference

> Extracted reference material for the `qa-test-mutate` skill. Contains multi-stack configs, scoring rubrics, and CI patterns.

---

## Multi-Stack Framework Table

| Stack | Framework | Key CI Feature | Config File | Install |
|-------|-----------|----------------|-------------|---------|
| JS/TS | StrykerJS | `--incremental`, `coverageAnalysis: "perTest"` | `stryker.config.mjs` | `npx --no-install stryker --version` |
| PHP | Infection | MSI/MCC/CCMSI metrics, PHPUnit/Pest compatible | `infection.json5` | `vendor/bin/infection --version` |
| Go | go-mutesting | AST-based mutation, Avito fork recommended | CLI flags | `go-mutesting --version` |
| Python | mutmut | `mutmut results` CLI output, `mutate_only_covered_lines` | `setup.cfg` or CLI | `mutmut --version` |

**Known `tool` field values** (non-normative, parsers MUST NOT validate against this list):
`"stryker"`, `"infection"`, `"go-mutesting"`, `"mutmut"`

New mutation tools may be added without schema changes. The `tool` field is free-form `string` type.

---

## Mutation Run Commands

### JS/TS (StrykerJS)

```bash
# Check availability (never bare npx)
npx --no-install stryker --version

# Full run
npx stryker run

# Incremental (PR scope -- changed files only)
npx stryker run --incremental

# With specific config
npx stryker run --configFile stryker.config.mjs
```

**Config template** (`stryker.config.mjs`):
```javascript
/** @type {import('@stryker-mutator/api/core').PartialStrykerOptions} */
export default {
  mutate: ['src/**/*.ts', '!src/**/*.test.ts', '!src/**/*.spec.ts'],
  testRunner: 'vitest',
  reporters: ['html', 'json', 'progress'],
  coverageAnalysis: 'perTest',
  incremental: true,
  thresholds: {
    high: 80,
    low: 60,
    break: 60,
  },
};
```

**Score source**: `reports/mutation/mutation.json` -> `mutationScore` field

### PHP (Infection)

```bash
# Check availability
vendor/bin/infection --version

# Full run
vendor/bin/infection --min-msi=60 --min-covered-msi=80 --threads=4

# With specific config
vendor/bin/infection --configuration=infection.json5

# Show log
vendor/bin/infection --logger-json=infection-log.json
```

**Config template** (`infection.json5`):
```json5
{
  "$schema": "vendor/infection/infection/resources/schema.json",
  "source": {
    "directories": ["src"],
    "excludes": ["Tests", "Migrations"]
  },
  "phpUnit": {
    "configDir": "."
  },
  "mutators": {
    "@default": true
  },
  "minMsi": 60,
  "minCoveredMsi": 80
}
```

**Score source**: `infection-log.json` -> `stats.msi` field (Mutation Score Indicator)

### Go (go-mutesting)

```bash
# Check availability
go-mutesting --version

# Full run (Avito fork recommended)
go-mutesting ./...

# Specific packages
go-mutesting ./pkg/auth/... ./pkg/payment/...
```

**Score source**: parse stdout `killed/total` ratio (no native JSON output).
Example output: `The mutation score is 0.7250 (145 killed out of 200 total)`

**NEVER conflate with `go test -cover` output** -- that measures code coverage, not mutation score.

### Python (mutmut)

```bash
# Check availability
mutmut --version

# Full run
mutmut run

# Run only covered lines (faster)
mutmut run --paths-to-mutate=src/

# Get results (parse this, NOT .mutmut-cache SQLite)
mutmut results
```

**Score source**: `mutmut results` CLI output -> parse survived/killed/total counts.
Example output:
```
To apply a mutant on disk:
  mutmut apply <id>

Survived: 42
Killed: 158
Total: 200
```

**NEVER parse `.mutmut-cache`** -- this is an unstable internal SQLite database format.

---

## Scoring Rubric and Thresholds

### Default Thresholds (configurable in `jaan-to/config/settings.yaml`)

```yaml
qa_mutation:
  thresholds:
    break_ci: 60        # Minimum score to pass CI
    target_new_code: 80  # Target for new/changed code
    critical_paths: 90   # Target for payments, auth, security
  feedback_loop:
    max_iterations: 3
    min_delta: 5         # Stop if improvement < 5 points
```

### Score Interpretation

| Score Range | Quality Level | Recommendation |
|------------|---------------|----------------|
| 90-100% | Excellent | Test suite is highly effective |
| 80-89% | Good | Meets target for new code |
| 60-79% | Adequate | Passes CI, but improvement recommended |
| 40-59% | Poor | Below CI threshold, needs immediate attention |
| 0-39% | Critical | Test suite provides minimal value |
| null | Unknown | Mutation tool not available for this stack |

### Null Score Handling

- `mutation_score: null` means "not measured" (tool unavailable)
- `mutation_score: 0` means "measured zero" (all mutants survived)
- Downstream consumers (qa-quality-gate, qa-test-run) must handle `null` by excluding from weighting
- JSON parsers: treat `null` as absent signal, `0` as measured zero signal

---

## CI Integration Patterns

### Incremental (PRs -- changed files only)

Run mutation testing only on files changed in the PR for fast feedback:

```yaml
# GitHub Actions example
- name: Mutation Testing (Incremental)
  if: github.event_name == 'pull_request'
  run: npx stryker run --incremental --mutate "$(git diff --name-only origin/main...HEAD | grep -E '\.(ts|js)$' | tr '\n' ',')"
```

### Full (Nightly)

Run full mutation testing suite on schedule:

```yaml
# GitHub Actions example
on:
  schedule:
    - cron: '0 2 * * *'  # Nightly at 2 AM UTC

- name: Mutation Testing (Full)
  run: npx stryker run
```

### Multi-Stack CI Matrix

```yaml
strategy:
  matrix:
    include:
      - stack: node
        cmd: npx stryker run
        score_file: reports/mutation/mutation.json
      - stack: php
        cmd: vendor/bin/infection --logger-json=infection-log.json
        score_file: infection-log.json
      - stack: go
        cmd: go-mutesting ./...
        score_file: stdout
      - stack: python
        cmd: mutmut run && mutmut results
        score_file: stdout
```

---

## Survivors JSON Schema (Handoff Contract v1.0)

```json
{
  "schema_version": "1.0",
  "tool": "stryker",
  "run_timestamp": "2024-01-15T14:30:00Z",
  "mutation_score": 72.5,
  "total_mutants": 200,
  "killed": 145,
  "survived": 55,
  "survivors": [
    {
      "id": "mutant-001",
      "file": "src/services/auth.ts",
      "line": 42,
      "original": "return balance > 0;",
      "mutated": "return balance >= 0;",
      "mutator": "ConditionalBoundary",
      "status": "Survived"
    }
  ]
}
```

### Field Requirements

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `schema_version` | string | Yes | Always `"1.0"` |
| `tool` | string | Yes | Free-form, not enum |
| `run_timestamp` | string (ISO-8601) | Yes | UTC timestamp |
| `mutation_score` | number or null | Yes | Percentage (0-100) or null if unavailable |
| `total_mutants` | integer | Yes | Total mutants generated |
| `killed` | integer | Yes | Mutants killed by tests |
| `survived` | integer | Yes | Mutants that survived |
| `survivors[]` | array | Yes | May be empty |
| `survivors[].id` | string | Yes | Unique within this run |
| `survivors[].file` | string | Yes | Relative path to source |
| `survivors[].line` | integer | Yes | Line number in source |
| `survivors[].original` | string | Yes | Original code snippet |
| `survivors[].mutated` | string | Yes | Mutated code snippet |
| `survivors[].mutator` | string | Yes | Mutator type name |
| `survivors[].status` | string | Yes | Always `"Survived"` |
