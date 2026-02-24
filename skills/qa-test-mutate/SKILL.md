---
name: qa-test-mutate
description: Run mutation testing to validate test suite quality with multi-stack support. Use when verifying test effectiveness.
allowed-tools: Read, Glob, Grep, Bash(npx stryker:*), Bash(vendor/bin/infection:*), Bash(go-mutesting:*), Bash(mutmut:*), Bash(npx vitest:*), Bash(npm test:*), Write($JAAN_OUTPUTS_DIR/qa/test-mutate/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[test-suite-path | qa-test-generate-output | (interactive)]"
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
context: fork
disable-model-invocation: true
---

# qa-test-mutate

> Mutation testing is the only reliable quality metric for AI-generated test suites.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL -- determines mutation framework)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_LEARN_DIR/jaan-to-qa-test-mutate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-qa-test-mutate.template.md` - Output template
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- Research: `${CLAUDE_PLUGIN_ROOT}/docs/research/76-tdd-bdd-ai-orchestration.md` (Section 5)

## Input

**Test Suite Source**: $ARGUMENTS

Input modes:
1. **qa-test-generate output** -- Path to generated test suite (from `/jaan-to:qa-test-generate`)
2. **Test suite path** -- Path to project's existing test directory
3. **Interactive** -- Empty arguments triggers wizard

IMPORTANT: The input above is your starting point. Determine mode and proceed accordingly.

---

## Pre-Execution Protocol
**MANDATORY** -- Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `qa-test-mutate`
Execute: Step 0 (Init Guard) -> A (Load Lessons) -> B (Resolve Template) -> C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` -- Know the tech stack for mutation framework selection

If files do not exist, continue without them.

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_qa-test-mutate`

> **Language exception**: Generated code output (config files, JSON reports) is NOT affected by this setting and remains in English/code.

### Codex Runtime Note
> Iterative feedback loop (Steps 5-8 of Phase 2) requires Claude Code `Task` tool for sub-agent delegation. In Codex runtime, run single mutation pass only -- skip iterative feedback loop.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Detecting tech stack to select correct mutation framework
- Analyzing test suite structure and test runner configuration
- Planning mutation testing scope (which files to mutate, which tests to run)
- Evaluating existing mutation configs (stryker.config.*, infection.json5, etc.)

## Step 1: Detect Tech Stack and Mutation Framework

Read `$JAAN_CONTEXT_DIR/tech.md` for stack detection. Select mutation framework:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-mutate-reference.md` section "Multi-Stack Framework Table" for the supported stacks table (JS/TS, PHP, Go, Python), framework names, key CI features, and config files.

**Unsupported stack fallback**: If `tech.md` reports a stack not in the supported table (e.g., Java, Ruby, C#, Rust):
- Report `mutation_score: null` in output, DO NOT fail
- Add "Unsupported Stack" section: "Mutation testing not yet supported for {stack}. Supported: JS/TS, PHP, Go, Python."
- Skip entire mutation feedback loop (proceed to output with null score)

If tech.md unavailable, use AskUserQuestion:
- "Which tech stack is this project using?" -- Options: "Node.js/TypeScript", "PHP", "Go", "Python"

## Step 2: Validate Test Suite

1. Locate test files from input path or discovery:
   - Glob for test file patterns (`**/*.test.ts`, `**/*.spec.ts`, `**/*_test.go`, `**/test_*.py`, `**/Test*.php`)
2. Count test files and verify test runner is configured
3. Check if mutation framework is available using only permitted commands:
   - JS/TS: `npx --no-install stryker --version` (never bare `npx`)
   - PHP: `vendor/bin/infection --version`
   - Go: `go-mutesting --version`
   - Python: `mutmut --version`
4. If framework not installed, report as unavailable -- DO NOT install

Present discovery summary:
```
MUTATION TESTING ANALYSIS
-------------------------------------------------------------
Tech Stack:          {detected stack}
Mutation Framework:  {framework name} ({available/unavailable})
Test Runner:         {runner name}
Test Files:          {count} files
Test Commands:       {detected test command}

Mutation Scope:
  Source Files:      {count} files to mutate
  Test Files:        {count} test files
  Estimated Time:    {rough estimate based on file count}
```

## Step 3: Plan Mutation Run

Based on stack and framework availability:

1. **Framework available**: Plan full mutation run with configured options
2. **Framework unavailable**: Report status, suggest installation, output with `mutation_score: null`

Configure mutation run parameters:
- **Scope**: Changed files only (incremental) OR full project
- **Thresholds** (from `jaan-to/config/settings.yaml` or defaults):
  - Break CI: 60% mutation score
  - Target (new code): 80%
  - Critical paths (payments, auth): 90%

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-mutate-reference.md` section "Scoring Rubric and Thresholds" for configurable threshold table and CI integration patterns.

---

# HARD STOP -- Human Review Check

Show complete plan before executing:

```
MUTATION TESTING PLAN
-------------------------------------------------------------
Framework:       {mutation framework}
Available:       {yes/no}
Scope:           {incremental/full}
Source Files:    {count} to mutate
Test Files:      {count} test files
Test Command:    {command}
Thresholds:      Break={break}%, Target={target}%, Critical={critical}%
Feedback Loop:   {enabled/disabled (Codex: disabled)}
Max Iterations:  {2-3}

Output Folder:   $JAAN_OUTPUTS_DIR/qa/test-mutate/{id}-{slug}/
```

Use AskUserQuestion:
- Question: "Proceed with mutation testing?"
- Header: "Run Mutations"
- Options:
  - "Yes" -- Run mutation testing
  - "No" -- Cancel
  - "Edit" -- Adjust scope or thresholds

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Execution (Write Phase)

## Step 4: Execute Mutation Run

### Step 4.0: Guard -- Unsupported Stack Check

If mutation framework is unavailable for the detected stack:
- Skip entire mutation feedback loop
- Emit: "Unsupported stack -- mutation feedback loop skipped"
- Write output with `mutation_score: null`, empty `survivors: []`
- Jump to Step 9 (Preview & Approval)

### Step 4.1: Run Mutation Framework

Execute the appropriate mutation command:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/qa-test-mutate-reference.md` section "Mutation Run Commands" for per-stack execution commands and configuration.

### Step 4.2: Parse Results

Extract mutation score from **mutation tool output only** (never conflate with code coverage):

- **StrykerJS**: `reports/mutation/mutation.json` -> `mutationScore` field
- **Infection**: `infection-log.json` -> `stats.msi` field (Mutation Score Indicator)
- **go-mutesting**: parse stdout `killed/total` ratio (no native JSON output)
- **mutmut**: `mutmut results` CLI output -> parse survived/killed/total counts (NOT `.mutmut-cache` SQLite, which is unstable internal format)

### Step 4.3: Write Survivors JSON

Write surviving mutants to handoff contract file:

Path: `{output-folder}/{id}-{slug}-survivors.json`

```json
{
  "schema_version": "1.0",
  "tool": "{framework-name}",
  "run_timestamp": "{ISO-8601}",
  "mutation_score": {score or null},
  "total_mutants": {count},
  "killed": {count},
  "survived": {count},
  "survivors": [
    {
      "id": "mutant-{nnn}",
      "file": "{relative/path/to/source.ext}",
      "line": {line_number},
      "original": "{original code snippet}",
      "mutated": "{mutated code snippet}",
      "mutator": "{MutatorName}",
      "status": "Survived"
    }
  ]
}
```

**Contract rules**:
- `tool` field: free-form string (not enum). Known values: `"stryker"`, `"infection"`, `"go-mutesting"`, `"mutmut"`.
- Fields `file`, `line`, `original`, `mutated` are REQUIRED per survivor.
- If mutation tool unavailable: `mutation_score: null` (JSON null, not 0).

## Step 5: Feedback Loop Guard

If survivors artifact is empty OR mutation run failed:
- Stop loop. Emit result with score from Step 4.2, no feedback iteration.
- Jump to Step 9.

## Step 6: Mutation-Guided Feedback Loop (Claude Code Only)

> **Codex runtime**: Skip this entire section. Single mutation pass only.

For each iteration (max 2-3, stop if delta < 5 points):

### 6.1: Feed Survivors to Test Generator

Use Task tool to spawn sub-agent:
- Invoke `/jaan-to:qa-test-generate --from-mutants {survivors-json-path}`
- Sub-agent reads survivors JSON and generates targeted tests
- Each survivor gets a test that exercises the `original` line and asserts behavior the `mutated` version would break

### 6.2: Re-Run Mutations

Execute mutation framework again with new tests added.

### 6.3: Compare Results

Calculate improvement delta:
- `delta = new_score - previous_score`
- If delta < 5 points: stop iteration (diminishing returns)
- If iterations >= 3: stop (max iterations reached)
- Otherwise: loop back to 6.1

Track iteration history:
```
Iteration  Score   Delta   Survivors  New Tests
---------  ------  ------  ---------  ---------
1          72.5%   --      55         --
2          81.3%   +8.8    38         17
3          84.1%   +2.8    32         6 (stopped: delta < 5)
```

## Step 7: Evaluate Against Thresholds

Compare final mutation score against configured thresholds:

| Threshold | Value | Result |
|-----------|-------|--------|
| Break CI | {break}% | {PASS/FAIL} |
| Target (new code) | {target}% | {PASS/FAIL} |
| Critical paths | {critical}% | {PASS/WARN if applicable} |

## Step 8: Quality Check

Before preview, validate:
- [ ] Mutation score is from mutation tool output (not code coverage)
- [ ] Survivors JSON matches schema contract (schema_version, required fields)
- [ ] All survivor entries have `file`, `line`, `original`, `mutated` fields
- [ ] Score type is correct: number (measured) or null (not measured)
- [ ] Threshold comparison uses correct values from settings.yaml or defaults

## Step 9: Preview & Approval

### 9.1 Generate Output Metadata

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/qa/test-mutate"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

Generate slug from feature/project name, lowercase-kebab-case, max 50 chars.

### 9.2 Generate Executive Summary

Template:
```
Mutation testing report for {project/feature} using {framework}. Mutation score: {score}%
({killed}/{total} mutants killed, {survived} survivors). {iterations} feedback iterations
performed. Threshold evaluation: Break CI {PASS/FAIL}, Target {PASS/FAIL}.
Top survivor locations: {top 3 file paths}.
```

### 9.3 Show Preview

```
MUTATION TESTING RESULTS
-------------------------------------------------------------
ID:              {NEXT_ID}
Folder:          $JAAN_OUTPUTS_DIR/qa/test-mutate/{NEXT_ID}-{slug}/

Framework:       {framework}
Mutation Score:  {score}% ({killed}/{total})
Survivors:       {count}
Iterations:      {count}

Threshold Results:
  Break CI (60%):       {PASS/FAIL}
  Target (80%):         {PASS/FAIL}
  Critical (90%):       {PASS/WARN/N/A}

Top 5 Survivor Locations:
  1. {file}:{line} - {mutator}
  2. {file}:{line} - {mutator}
  ...

Files:
  {id}-{slug}.md                    (Mutation report)
  {id}-{slug}-survivors.json        (Survivors handoff contract)
```

Use AskUserQuestion:
- Question: "Write mutation testing results?"
- Header: "Write Results"
- Options:
  - "Yes" -- Write output files
  - "No" -- Cancel

## Step 10: Write Output Files

If approved:

### 10.1 Create Folder

```bash
OUTPUT_FOLDER="$JAAN_OUTPUTS_DIR/qa/test-mutate/${NEXT_ID}-${slug}"
mkdir -p "$OUTPUT_FOLDER"
```

### 10.2 Write Main Report

Path: `$OUTPUT_FOLDER/${NEXT_ID}-${slug}.md`

Sections:
- Title, Executive Summary
- Metadata (framework, score, thresholds, iterations)
- Mutation Score Summary (with iteration history table if applicable)
- Threshold Evaluation
- Top Survivors (table with file, line, mutator, original, mutated)
- Feedback Loop History (if iterations > 1)
- Recommendations (based on score and survivor analysis)

### 10.3 Write Survivors JSON

Path: `$OUTPUT_FOLDER/${NEXT_ID}-${slug}-survivors.json`

Per contract defined in Step 4.3.

### 10.4 Update Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Feature/Project} Mutation Report" \
  "{Executive Summary}"
```

### 10.5 Confirm Completion

```
MUTATION TESTING COMPLETE
-------------------------------------------------------------
ID:          {NEXT_ID}
Folder:      $JAAN_OUTPUTS_DIR/qa/test-mutate/{NEXT_ID}-{slug}/
Index:       Updated $JAAN_OUTPUTS_DIR/qa/test-mutate/README.md

Score:       {score}%
Survivors:   {count}
Iterations:  {count}

Next Steps:
- Review survivors and strengthen tests manually
- Run /jaan-to:qa-test-generate --from-mutants {survivors-json-path} for targeted tests
- Integrate mutation CI stage via /jaan-to:devops-infra-scaffold
```

## Step 11: Capture Feedback

Use AskUserQuestion:
- Question: "How did mutation testing turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- What should I improve?
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add qa-test-mutate "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection with unsupported-stack fallback
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path
- Artifact handoff contract (survivors JSON) for downstream skills

## Definition of Done

- [ ] Tech stack detected and mutation framework selected
- [ ] Framework availability checked (without auto-install)
- [ ] Mutation run executed (or null score for unsupported stack)
- [ ] Mutation score from tool output only (never code coverage)
- [ ] Survivors JSON written per handoff contract schema
- [ ] Feedback loop executed (Claude Code) or skipped (Codex/unsupported)
- [ ] Thresholds evaluated against configured values
- [ ] Executive Summary generated
- [ ] Sequential ID generated
- [ ] Folder created: `{id}-{slug}/`
- [ ] Main report written: `{id}-{slug}.md`
- [ ] Survivors JSON written: `{id}-{slug}-survivors.json`
- [ ] Index updated
- [ ] User approved
