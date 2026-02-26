---
name: qa-tdd-orchestrate
description: Orchestrate RED/GREEN/REFACTOR TDD cycle with context-isolated agents. Use when implementing features test-first.
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion, Write($JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/**), Edit(jaan-to/config/settings.yaml)
argument-hint: "[feature-description | acceptance-criteria | qa-test-cases-output]"
license: PROPRIETARY
context: fork
disable-model-invocation: true
codex-support: false
---

# qa-tdd-orchestrate

> Context isolation between AI agents is the single most important architectural decision for TDD.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL -- determines test framework and runner)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_LEARN_DIR/jaan-to-qa-tdd-orchestrate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-qa-tdd-orchestrate.template.md` - Output template
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- Research: `${CLAUDE_PLUGIN_ROOT}/docs/research/76-tdd-bdd-ai-orchestration.md` (Sections 1, 3)

## Input

**Feature Source**: $ARGUMENTS

Input modes:
1. **Feature description** -- Plain text describing the feature to implement
2. **Acceptance criteria** -- Formal AC to drive outer BDD loop
3. **qa-test-cases output** -- Path to BDD test cases (from `/jaan-to:qa-test-cases`) for outer loop
4. **Interactive** -- Empty arguments triggers wizard

IMPORTANT: The input above is your starting point. Determine mode and proceed accordingly.

### Claude Code Only

This skill requires the `Task` tool for spawning context-isolated sub-agents. Context isolation (the core research premise) requires `Task`-based sub-agents; single-context sequential mode fundamentally breaks this guarantee. This skill is NOT available in Codex runtime.

---

## Pre-Execution Protocol
**MANDATORY** -- Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `qa-tdd-orchestrate`
Execute: Step 0 (Init Guard) -> A (Load Lessons) -> B (Resolve Template) -> C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` -- Know the tech stack for test framework detection

If files do not exist, continue without them.

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_qa-tdd-orchestrate`

> **Language exception**: Generated code output is NOT affected by this setting.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Decomposing feature into TDD-able components
- Mapping acceptance criteria to outer BDD loop
- Planning RED/GREEN/REFACTOR cycle sequence
- Designing context isolation boundaries

## Step 1: Parse Feature Input

Based on input mode:

**Feature description**: Decompose into testable components (functions, modules, endpoints).
**Acceptance criteria / qa-test-cases output**: Use as outer BDD acceptance test. Each AC becomes an outer loop iteration target.

Present decomposition:
```
TDD DECOMPOSITION
-------------------------------------------------------------
Feature:           {feature name}
Outer Loop:        {count} acceptance criteria
Inner Components:  {count} TDD-able units

Components:
  1. {component_name} -- {brief description}
  2. {component_name} -- {brief description}
  ...

Test Framework:    {detected from tech.md}
Test Command:      {detected test command}
```

## Step 2: Detect Test Framework

Read `$JAAN_CONTEXT_DIR/tech.md` for test framework detection:
- Extract test runner and assertion library
- Extract project structure patterns (src/, lib/, test/, etc.)
- Determine test file naming convention

If tech.md unavailable, use AskUserQuestion:
- "Which test framework does this project use?" -- Options: "Vitest", "Jest", "pytest", "PHPUnit/Pest", "Go testing"

## Step 3: Plan TDD Cycle

For each component, plan the RED/GREEN/REFACTOR sequence:

```
TDD CYCLE PLAN
-------------------------------------------------------------
Outer Loop: BDD Acceptance Test
  "{acceptance criterion text}"

Inner Cycles:
  Cycle 1: {component_1}
    RED:      Write failing test for {specific behavior}
    GREEN:    Minimal implementation to pass
    REFACTOR: Clean up, extract patterns

  Cycle 2: {component_2}
    RED:      Write failing test for {specific behavior}
    GREEN:    Minimal implementation to pass
    REFACTOR: Clean up, apply DRY

  ...

Iteration Limits:
  Max RED-GREEN cycles per component: {5-10}
  Same-test failure escalation: 3 attempts
  Max total cycles: {configurable, default 10}
```

---

# HARD STOP -- Human Review Check

Show complete plan before executing:

```
TDD ORCHESTRATION PLAN
-------------------------------------------------------------
Feature:         {feature name}
Components:      {count}
Outer Loop:      {count} acceptance criteria
Inner Cycles:    {estimated count} RED-GREEN-REFACTOR cycles
Test Framework:  {framework}
Test Command:    {command}

Context Isolation:
  Level 1: Artifact-only handoffs (no reasoning text)
  Level 2: Prompt exclusion lists (per agent)
  Level 3: Handoff manifest verification

Output Folder:   $JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/{id}-{slug}/
```

Use AskUserQuestion:
- Question: "Proceed with TDD orchestration?"
- Header: "Start TDD"
- Options:
  - "Yes" -- Begin RED/GREEN/REFACTOR cycles
  - "No" -- Cancel
  - "Edit" -- Adjust components or cycle limits

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Execution (Write Phase)

## Context Isolation Architecture

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-tdd-orchestrate-reference.md` section "Agent Prompt Templates" for RED/GREEN/REFACTOR agent prompts with explicit exclusion rules.

Isolation is enforced at three levels:

**Level 1 -- Artifact-only handoffs**: No reasoning text transfer between agents. Only file paths and test runner stdout/stderr cross boundaries.

**Level 2 -- Prompt exclusion lists**: Each agent's Task prompt explicitly excludes information from other phases.

**Level 3 -- Handoff manifest verification**: Each phase gate writes `handoff-{phase}.json` listing only artifact paths being passed. Next agent's prompt is built ONLY from allowlisted paths.

## Step 4: Execute Double-Loop TDD

### 4.1 Outer Loop (BDD Acceptance)

For each acceptance criterion:

1. If qa-test-cases output provided, extract the corresponding BDD scenario
2. Create or identify the acceptance test file
3. Run acceptance test -- confirm it FAILS (expected: feature not yet implemented)
4. Begin inner TDD cycles (Step 4.2)
5. After all inner cycles complete, re-run acceptance test
6. If acceptance test PASSES: feature complete for this AC (outer GREEN)
7. If acceptance test still FAILS: diagnose and iterate

### 4.2 Inner Loop (RED/GREEN/REFACTOR)

For each component within current AC:

#### RED Phase

Spawn isolated sub-agent via Task tool:

```
Task prompt for RED agent:
- ONLY includes: requirements text, test framework docs, existing test patterns
- EXCLUDED: implementation plans, existing source code (src/**), scaffold output
- Goal: Write a failing test for {component} that tests {specific behavior}
- Output: test file path
```

**Phase gate**: Run test command. Verify test FAILS (non-zero exit code).
- If test passes: RED phase invalid (test is not testing new behavior). Abort and ask RED agent to write a more specific test.
- Write `handoff-red.json`:
  ```json
  {
    "phase": "red",
    "test_file": "{path to test file}",
    "runner_output": "{stdout/stderr from failed test run}",
    "exit_code": 1
  }
  ```

#### GREEN Phase

Spawn isolated sub-agent via Task tool:

```
Task prompt for GREEN agent:
- ONLY includes: failing test file content, test runner output (from handoff-red.json)
- EXCLUDED: RED agent's reasoning, requirements text, implementation plans
- Goal: Write MINIMAL code to make the failing test pass
- Output: implementation file path(s)
```

**Allowlist verification**: Assert GREEN agent's prompt contains ONLY content from files listed in `handoff-red.json`. Any non-manifest content = isolation violation, abort cycle.

**Phase gate**: Run test command. Verify test PASSES (zero exit code).
- If test fails: GREEN implementation insufficient. Allow up to 3 retries.
- After 3 failures on same test: escalate to human via AskUserQuestion.
- Write `handoff-green.json`:
  ```json
  {
    "phase": "green",
    "implementation_files": ["{path1}", "{path2}"],
    "test_file": "{path to test file}",
    "runner_output": "{stdout/stderr from passing test run}",
    "exit_code": 0
  }
  ```

#### REFACTOR Phase

Spawn isolated sub-agent via Task tool:

```
Task prompt for REFACTOR agent:
- INCLUDES: all code files + passing test suite output
- EXCLUDED: RED and GREEN agent prompts/reasoning
- Goal: Improve code quality without changing behavior. All tests must still pass.
- Output: modified file path(s)
```

**Phase gate**: Run ALL tests. Verify ALL still PASS (zero exit code).
- If any test fails: revert refactoring, keep GREEN implementation.

### 4.3 Iteration Tracking

Track progress per component:
```
Component: {name}
  Cycle 1: RED(pass) -> GREEN(pass) -> REFACTOR(pass)
  Cycle 2: RED(pass) -> GREEN(fail x2, pass) -> REFACTOR(pass)
  ...
  Same-test failures: {count}/3
  Total cycles: {count}/{max}
```

If same test fails 3 times with same error pattern: escalate via AskUserQuestion with error details.

## Step 5: Quality Check

Before preview, validate:
- [ ] All acceptance tests pass (outer loop complete)
- [ ] All unit tests pass (inner loops complete)
- [ ] Context isolation maintained (no reasoning text in handoff manifests)
- [ ] Handoff manifests written for each phase gate
- [ ] Iteration counts within configured limits

## Step 6: Preview & Approval

### 6.1 Generate Output Metadata

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/qa/tdd-orchestrate"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

Generate slug from feature name, lowercase-kebab-case, max 50 chars.

### 6.2 Generate Executive Summary

Template:
```
TDD orchestration for {feature_name} completed with {component_count} components
across {cycle_count} RED-GREEN-REFACTOR cycles. {ac_count} acceptance criteria
satisfied. Context isolation enforced via artifact-only handoffs with manifest
verification. Final test suite: {test_count} tests, all passing.
```

### 6.3 Show Preview

```
TDD ORCHESTRATION RESULTS
-------------------------------------------------------------
ID:              {NEXT_ID}
Folder:          $JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/{NEXT_ID}-{slug}/

Feature:         {feature name}
Components:      {count}
Total Cycles:    {count}
Tests Written:   {count}
Tests Passing:   {count}/{count}

Acceptance Criteria:
  AC1: {text} -- PASS
  AC2: {text} -- PASS
  ...

Files:
  {id}-{slug}.md                      (Orchestration report)
  handoff-red.json                     (RED phase manifest)
  handoff-green.json                   (GREEN phase manifest)
  orchestration-log.json               (Full cycle history)
```

Use AskUserQuestion:
- Question: "Write TDD orchestration results?"
- Header: "Write Results"
- Options:
  - "Yes" -- Write output files
  - "No" -- Cancel

## Step 7: Write Output Files

If approved:

### 7.1 Create Folder

```bash
OUTPUT_FOLDER="$JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/${NEXT_ID}-${slug}"
mkdir -p "$OUTPUT_FOLDER"
```

### 7.2 Write Main Report

Path: `$OUTPUT_FOLDER/${NEXT_ID}-${slug}.md`

Sections:
- Title, Executive Summary
- Feature Decomposition
- TDD Cycle Summary (per component: RED/GREEN/REFACTOR results)
- Acceptance Criteria Results
- Context Isolation Verification
- Iteration History
- Recommendations

### 7.3 Write Orchestration Log

Path: `$OUTPUT_FOLDER/orchestration-log.json`

Contains full cycle-by-cycle history with timestamps, agent outputs, and phase gate results.

### 7.4 Update Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Feature Name} TDD Report" \
  "{Executive Summary}"
```

### 7.5 Confirm Completion

```
TDD ORCHESTRATION COMPLETE
-------------------------------------------------------------
ID:          {NEXT_ID}
Folder:      $JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/{NEXT_ID}-{slug}/
Index:       Updated $JAAN_OUTPUTS_DIR/qa/tdd-orchestrate/README.md

Components:  {count}
Cycles:      {count}
Tests:       {count} (all passing)

Next Steps:
- Review generated tests and implementation
- Run /jaan-to:qa-test-mutate to validate test effectiveness
- Run /jaan-to:dev-verify to verify build pipeline
```

## Step 8: Capture Feedback

Use AskUserQuestion:
- Question: "How did TDD orchestration turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- What should I improve?
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add qa-tdd-orchestrate "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path
- Context isolation via Task-based sub-agents (Claude Code only)

## Definition of Done

- [ ] Feature decomposed into TDD-able components
- [ ] Test framework detected
- [ ] RED/GREEN/REFACTOR cycles executed per component
- [ ] Context isolation enforced (artifact-only handoffs, manifest verification)
- [ ] All acceptance tests pass (outer loop)
- [ ] All unit tests pass (inner loop)
- [ ] Iteration limits respected
- [ ] Same-test failures escalated (if any)
- [ ] Executive Summary generated
- [ ] Sequential ID generated
- [ ] Folder created: `{id}-{slug}/`
- [ ] Main report written: `{id}-{slug}.md`
- [ ] Orchestration log written
- [ ] Index updated
- [ ] User approved
