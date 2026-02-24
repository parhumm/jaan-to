---
title: "qa-tdd-orchestrate"
sidebar_position: 6
doc_type: skill
created_date: 2026-02-23
updated_date: 2026-02-23
tags: [qa, tdd, bdd, red-green-refactor, context-isolation, agents, test-first]
related: [qa-test-cases, qa-test-generate, qa-test-mutate, qa-test-run]
---

# /jaan-to:qa-tdd-orchestrate

> Orchestrate RED/GREEN/REFACTOR TDD cycle with context-isolated agents for test-first development.

---

## Overview

Runs a full TDD cycle using three context-isolated AI agents (RED, GREEN, REFACTOR) that communicate only through artifacts -- never through shared reasoning. Supports a double-loop pattern: outer BDD acceptance tests from `/jaan-to:qa-test-cases`, inner unit TDD cycles per component. Context isolation is the core architectural principle, enforced at three levels.

**Claude Code only** -- requires `Task` tool for sub-agent spawning. Not available in Codex runtime.

---

## Usage

```
/jaan-to:qa-tdd-orchestrate "implement user login with rate limiting"
/jaan-to:qa-tdd-orchestrate path/to/qa-test-cases-output
```

| Argument | Required | Description |
|----------|----------|-------------|
| feature source | No | Feature description, acceptance criteria, or qa-test-cases output path |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | TDD orchestration report with cycle history and results |
| `orchestration-log.json` | Full cycle-by-cycle history with timestamps and phase gates |
| `handoff-red.json` | RED phase manifest (test file path, runner output) |
| `handoff-green.json` | GREEN phase manifest (implementation files, test results) |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Test framework | tech.md unavailable | Determines test runner and assertion library |
| Component decomposition | Always | Approve how feature is broken into TDD-able units |
| Cycle limits | Custom needed | Max RED-GREEN cycles per component |

---

## Context Isolation (Three Levels)

The core research premise: AI agents writing tests must not see implementation plans, and agents writing implementation must not see test reasoning.

| Level | Mechanism | What It Prevents |
|-------|-----------|-----------------|
| 1. Artifact-only handoffs | No reasoning text between agents | GREEN agent "cheating" by reading RED's intent |
| 2. Prompt exclusion lists | Each agent explicitly excludes other phases | Cross-contamination of concerns |
| 3. Handoff manifest verification | Phase gate JSON lists only allowed paths | Any non-manifest content = isolation violation |

---

## Double-Loop TDD

```
Outer Loop (BDD Acceptance)
  AC1 → Inner TDD Cycles → AC1 PASS
  AC2 → Inner TDD Cycles → AC2 PASS

Inner Loop (per component)
  RED → write failing test
  GREEN → minimal code to pass
  REFACTOR → improve without breaking tests
```

---

## Workflow Chain

```
/jaan-to:qa-test-cases --> /jaan-to:qa-tdd-orchestrate --> /jaan-to:qa-test-mutate
```

---

## Example

**Input:**
```
/jaan-to:qa-tdd-orchestrate "implement user login with rate limiting"
```

**Output:**
```
jaan-to/outputs/qa/tdd-orchestrate/01-user-login/
├── 01-user-login.md             (orchestration report)
├── orchestration-log.json        (full cycle history)
├── handoff-red.json              (RED phase manifest)
└── handoff-green.json            (GREEN phase manifest)
```

**Report summary:**
```
Components:   3 (authenticate, rate-limiter, session-manager)
Total Cycles: 8 RED-GREEN-REFACTOR
Tests Written: 24
Tests Passing: 24/24
Acceptance Criteria: 3/3 satisfied
```

---

## Tips

- Start with acceptance criteria from `/jaan-to:qa-test-cases` for the outer loop
- Review the component decomposition before approving -- smaller components = better TDD
- If a test fails 3 times with the same error, the skill escalates to you
- Follow up with `/jaan-to:qa-test-mutate` to validate test effectiveness

---

## Related Skills

- [/jaan-to:qa-test-cases](test-cases.md) - Generate BDD/Gherkin test cases for outer loop
- [/jaan-to:qa-test-mutate](test-mutate.md) - Validate test effectiveness after TDD
- [/jaan-to:qa-test-generate](test-generate.md) - Generate test files from BDD cases
- [/jaan-to:qa-test-run](test-run.md) - Execute and diagnose test failures

---

## Technical Details

- **Logical Name**: qa-tdd-orchestrate
- **Command**: `/jaan-to:qa-tdd-orchestrate`
- **Role**: qa
- **Output**: `$JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/{id}-{slug}/`
- **Runtime**: Claude Code only (codex-support: false)
- **Reference**: `docs/extending/qa-tdd-orchestrate-reference.md`
