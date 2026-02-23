---
title: "qa-test-mutate"
sidebar_position: 5
doc_type: skill
created_date: 2026-02-23
updated_date: 2026-02-23
tags: [qa, mutation-testing, stryker, infection, go-mutesting, mutmut, test-quality]
related: [qa-test-generate, qa-test-run, qa-test-cases, devops-infra-scaffold]
---

# /jaan-to:qa-test-mutate

> Run mutation testing to validate test suite quality with multi-stack support and iterative feedback.

---

## Overview

Runs mutation testing against your test suite to measure test effectiveness. Supports StrykerJS (JS/TS), Infection (PHP), go-mutesting (Go), and mutmut (Python). Produces a survivors JSON artifact that feeds directly into `/jaan-to:qa-test-generate --from-mutants` for targeted test generation. In Claude Code, runs an iterative feedback loop that improves mutation score across 2-3 cycles.

---

## Usage

```
/jaan-to:qa-test-mutate
/jaan-to:qa-test-mutate path/to/test-generate-output
/jaan-to:qa-test-mutate tests/
```

| Argument | Required | Description |
|----------|----------|-------------|
| test source | No | Path to qa-test-generate output or test directory |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/qa/test-mutate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Mutation testing report with score, threshold evaluation, and survivor analysis |
| `{id}-{slug}-survivors.json` | Survivors JSON handoff contract (schema v1.0) for downstream skills |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Tech stack | tech.md unavailable | Determines mutation framework |
| Scope | Always | Incremental (changed files) or full project |
| Thresholds | Not in settings.yaml | Break CI %, target %, critical path % |

---

## Multi-Stack Support

| Stack | Mutation Framework | Config File |
|-------|--------------------|-------------|
| Node.js / TypeScript | StrykerJS | `stryker.config.mjs` |
| PHP | Infection | `infection.json5` |
| Go | go-mutesting | CLI flags |
| Python | mutmut | `setup.cfg` / `pyproject.toml` |

Stack is auto-detected from `tech.md` or project files. Unsupported stacks get `mutation_score: null` (not a failure).

---

## Scoring and Thresholds

Mutation score comes from the mutation tool output only (never code coverage).

| Threshold | Default | Purpose |
|-----------|---------|---------|
| Break CI | 60% | Minimum acceptable score |
| Target (new code) | 80% | Goal for new test suites |
| Critical paths | 90% | Payments, auth, data integrity |

---

## Survivors JSON Contract

The survivors JSON file follows schema v1.0 and feeds into `/jaan-to:qa-test-generate --from-mutants`:

```json
{
  "schema_version": "1.0",
  "tool": "stryker",
  "mutation_score": 72.5,
  "survivors": [
    {
      "id": "mutant-001",
      "file": "src/auth/login.ts",
      "line": 42,
      "original": "if (attempts >= 5)",
      "mutated": "if (attempts > 5)",
      "mutator": "ConditionalBoundary",
      "status": "Survived"
    }
  ]
}
```

---

## Feedback Loop (Claude Code Only)

In Claude Code, the skill runs an iterative feedback loop:

1. Run mutations, collect survivors
2. Feed survivors to `/jaan-to:qa-test-generate --from-mutants`
3. Re-run mutations with new tests
4. Stop when delta < 5 points or max 3 iterations reached

Codex runtime runs a single mutation pass only.

---

## Workflow Chain

```
/jaan-to:qa-test-generate --> /jaan-to:qa-test-mutate --> /jaan-to:qa-test-generate --from-mutants
```

---

## Example

**Input:**
```
/jaan-to:qa-test-mutate path/to/test-generate/01-user-auth/
```

**Output:**
```
jaan-to/outputs/qa/test-mutate/01-user-auth/
├── 01-user-auth.md              (mutation report)
└── 01-user-auth-survivors.json  (handoff contract)
```

**Report summary:**
```
Framework:       StrykerJS
Mutation Score:  84.1% (289/344 killed, 55 survivors)
Iterations:      3 (72.5% → 81.3% → 84.1%)
Break CI (60%):  PASS
Target (80%):    PASS
```

---

## Tips

- Run `/jaan-to:qa-test-generate` first to create test files
- Use the survivors JSON with `--from-mutants` for targeted test improvements
- Add mutation CI stage via `/jaan-to:devops-infra-scaffold`
- Mutation score is independent of code coverage -- both matter

---

## Related Skills

- [/jaan-to:qa-test-generate](test-generate.md) - Generate test files (accepts `--from-mutants`)
- [/jaan-to:qa-test-run](test-run.md) - Execute tests and generate coverage
- [/jaan-to:qa-test-cases](test-cases.md) - Generate BDD/Gherkin test cases
- [/jaan-to:devops-infra-scaffold](../devops/infra-scaffold.md) - Add mutation CI stage

---

## Technical Details

- **Logical Name**: qa-test-mutate
- **Command**: `/jaan-to:qa-test-mutate`
- **Role**: qa
- **Output**: `$JAAN_OUTPUTS_DIR/qa/test-mutate/{id}-{slug}/`
- **Runtime**: Claude Code (full feedback loop) / Codex (single pass, degraded)
- **Reference**: `docs/extending/qa-test-mutate-reference.md`
