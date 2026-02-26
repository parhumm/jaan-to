---
name: qa-contract-validate
description: Validate API contracts with Spectral, oasdiff, and Schemathesis pipeline. Use when verifying API spec compliance.
allowed-tools: Read, Glob, Grep, Bash(npx @stoplight/spectral-cli:*), Bash(oasdiff:*), Bash(npx @stoplight/prism-cli:*), Bash(schemathesis:*), Write($JAAN_OUTPUTS_DIR/qa/contract-validate/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[openapi-spec-path] [--baseline baseline-spec] [--url api-url]"
license: PROPRIETARY
context: fork
disable-model-invocation: true
---

# qa-contract-validate

> Validate API contracts through a multi-tool pipeline -- lint, diff, mock, and fuzz.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context
- `$JAAN_LEARN_DIR/jaan-to-qa-contract-validate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-qa-contract-validate.template.md` - Output template
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Contract Source**: $ARGUMENTS

Input modes:
1. **OpenAPI spec path** -- Path to OpenAPI/Swagger YAML or JSON file
2. **--baseline {path}** -- Optional baseline spec for breaking change detection (oasdiff)
3. **--url {api-url}** -- Optional running API URL for Prism/Schemathesis validation
4. **Interactive** -- Empty arguments triggers wizard

**Scope**: OpenAPI/Swagger specs only (v1). GraphQL schema validation and gRPC proto linting are out of scope.

---

## Pre-Execution Protocol
**MANDATORY** -- Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `qa-contract-validate`
Execute: Step 0 (Init Guard) -> A (Load Lessons) -> B (Resolve Template) -> C (Offer Template Seeding)

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_qa-contract-validate`

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Validating OpenAPI spec structure
- Planning tool pipeline based on available tools and inputs
- Analyzing spec for common issues before tool execution

## Step 1: Validate Input Spec

1. Read the OpenAPI spec file
2. Verify it is valid YAML/JSON
3. Check for `openapi:` or `swagger:` version field
4. Extract: title, version, endpoint count, schema count

## Step 2: Preflight Tool Availability

Check each tool using only commands permitted by `allowed-tools`. Use `npx --no-install` for npm tools to prevent silent auto-installation. Never use bare `npx` or `which`.

| Tool | Check Command | Type |
|------|--------------|------|
| Spectral | `npx --no-install @stoplight/spectral-cli --version` | npm |
| oasdiff | `oasdiff --version` | Go binary (NOT npm) |
| Prism | `npx --no-install @stoplight/prism-cli --version` | npm |
| Schemathesis | `schemathesis --version` | Python pip |

Report availability:
```
TOOL AVAILABILITY
-------------------------------------------------------------
Spectral:     {available/unavailable}
oasdiff:      {available/unavailable} (requires --baseline)
Prism:        {available/unavailable} (requires --url)
Schemathesis: {available/unavailable} (requires --url)

Pipeline: {count}/4 tools available
```

**Hard rule**: If 0 out of 4 tools are available, report status as **INCONCLUSIVE** (not PASS). Output must state: "No validation tools installed -- contract compliance unknown. Install at least one tool to validate."

## Step 3: Plan Validation Pipeline

Based on available tools and provided inputs:

| Tool | Condition | Stage |
|------|-----------|-------|
| Spectral | Always (if available) | Lint spec |
| oasdiff | If `--baseline` provided AND tool available | Breaking changes |
| Prism | If `--url` provided AND tool available | Conformance check |
| Schemathesis | If `--url` provided AND tool available | Fuzz testing |

---

# HARD STOP -- Human Review Check

```
CONTRACT VALIDATION PLAN
-------------------------------------------------------------
Spec:        {spec_path} ({endpoint_count} endpoints, {schema_count} schemas)
Baseline:    {baseline_path or "none"}
API URL:     {url or "none"}

Pipeline Stages:
  1. Spectral Lint:      {will run / skipped (unavailable)}
  2. oasdiff Diff:       {will run / skipped (no baseline or unavailable)}
  3. Prism Conformance:  {will run / skipped (no URL or unavailable)}
  4. Schemathesis Fuzz:  {will run / skipped (no URL or unavailable)}

Output Folder: $JAAN_OUTPUTS_DIR/qa/contract-validate/{id}-{slug}/
```

Use AskUserQuestion:
- Question: "Proceed with contract validation?"
- Header: "Validate"
- Options:
  - "Yes" -- Run validation pipeline
  - "No" -- Cancel
  - "Edit" -- Provide missing inputs (baseline, URL)

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Execution (Write Phase)

## Step 4: Run Spectral Lint (if available)

```bash
npx @stoplight/spectral-cli lint {spec_path} --format json --ruleset .spectral.yaml
```

If `.spectral.yaml` not found, use built-in rulesets. Parse JSON output:
- Count errors, warnings, info by severity
- Extract top findings with rule ID, path, message

## Step 5: Run oasdiff Breaking Changes (if available + baseline)

```bash
oasdiff breaking --fail-on ERR {baseline_path} {spec_path} --format json
```

oasdiff is a Go binary, NOT npm. Install: `go install github.com/tufin/oasdiff@latest` or `brew install oasdiff`.
CI: use `oasdiff/oasdiff-action@{pinned-sha}` GitHub Action (pin to immutable commit SHA, never `@latest`).

Parse output: list breaking changes with severity and path.

## Step 6: Run Prism Conformance (if available + URL)

```bash
npx @stoplight/prism-cli proxy {spec_path} --host 0.0.0.0 --port 4010
```

Or validate against running API in proxy mode. Parse conformance violations.

## Step 7: Run Schemathesis Fuzz (if available + URL)

```bash
schemathesis run --url {api_url} {spec_path} --stateful=links --format json
```

schemathesis is a Python pip package, NOT npm. Parse: test count, failure count, defect details.

## Step 8: Aggregate Results

Combine all tool outputs into aggregate status:

| Stage | Status | Findings |
|-------|--------|----------|
| Spectral | PASS/WARN/FAIL | {error_count} errors, {warn_count} warnings |
| oasdiff | PASS/FAIL/SKIPPED | {breaking_count} breaking changes |
| Prism | PASS/FAIL/SKIPPED | {violation_count} conformance violations |
| Schemathesis | PASS/FAIL/SKIPPED | {defect_count} defects found |

**Aggregate**: PASS (all ran pass), WARN (warnings only), FAIL (any errors/breaking/defects), INCONCLUSIVE (0 tools ran).

## Step 9: Preview & Approval

### 9.1 Generate Output Metadata

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/qa/contract-validate"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

### 9.2 Generate Executive Summary

Template:
```
API contract validation for {spec_title} v{spec_version} ({endpoint_count} endpoints).
Pipeline: {tools_ran}/{tools_total} tools executed. Aggregate status: {PASS/WARN/FAIL/INCONCLUSIVE}.
Spectral: {status}. oasdiff: {status}. Prism: {status}. Schemathesis: {status}.
```

### 9.3 Write Output

Path: `$JAAN_OUTPUTS_DIR/qa/contract-validate/${NEXT_ID}-${slug}/`

Files:
- `{id}-{slug}.md` -- Main validation report
- `spectral-results.json` -- Raw Spectral output (if ran)
- `oasdiff-results.json` -- Raw oasdiff output (if ran)
- `schemathesis-results.json` -- Raw Schemathesis output (if ran)

### 9.4 Update Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Spec Title} Contract Validation" \
  "{Executive Summary}"
```

## Step 10: Capture Feedback

Use AskUserQuestion:
- Question: "How did contract validation turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- What should I improve?
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add qa-contract-validate "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-tool pipeline with graceful degradation
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] OpenAPI spec validated as parseable
- [ ] Tool availability checked (no auto-install)
- [ ] Available tools executed in pipeline order
- [ ] Results aggregated with per-tool status
- [ ] 0 tools available = INCONCLUSIVE (not PASS)
- [ ] Executive Summary generated
- [ ] Sequential ID generated
- [ ] Output files written
- [ ] Index updated
- [ ] User approved
