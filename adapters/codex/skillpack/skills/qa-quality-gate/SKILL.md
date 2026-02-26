---
name: qa-quality-gate
description: Compute composite quality score from test, security, and audit outputs. Use when deciding review depth.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/qa/quality-gate/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: "[upstream-output-paths...] (1-4 paths from qa-test-run, detect-dev, sec-audit-remediate, backend-pr-review)"
license: PROPRIETARY
disable-model-invocation: true
---

# qa-quality-gate

> Aggregate upstream quality signals into a composite score with routing recommendation.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to-qa-quality-gate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-qa-quality-gate.template.md` - Output template
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Upstream Outputs**: $ARGUMENTS

Accepts 1-4 paths to upstream skill outputs:
- **qa-test-run output** -- Test results with pass/fail counts and coverage
- **detect-dev output** -- Engineering audit with confidence scores
- **sec-audit-remediate output** -- Security findings and remediation status
- **backend-pr-review output** -- PR review verdict and concerns
- **qa-test-mutate output** (optional) -- Mutation testing score and survivors

At least 1 path is required. Missing signals are treated as `null` (not measured).

---

## Pre-Execution Protocol
**MANDATORY** -- Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `qa-quality-gate`
Execute: Step 0 (Init Guard) -> A (Load Lessons) -> B (Resolve Template) -> C (Offer Template Seeding)

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_qa-quality-gate`

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

megathink

Use reasoning for:
- Parsing upstream output files to extract quality signals
- Normalizing heterogeneous scores to 0-1 scale
- Computing weighted composite with null signal handling

## Step 1: Read Upstream Outputs

For each provided path:

1. **qa-test-run**: Extract test pass rate (passed/total), line coverage %, branch coverage %
2. **detect-dev**: Extract overall confidence score, finding severity counts
3. **sec-audit-remediate**: Extract security scan results (critical/high/medium/low counts, remediation %)
4. **backend-pr-review**: Extract verdict (approve/request-changes), concern count
5. **qa-test-mutate**: Extract mutation score % (may be `null` if tool unavailable)

Present signal inventory:
```
QUALITY SIGNALS
-------------------------------------------------------------
Signal                    Source              Value    Status
----------------------    ----------------    -----    ------
Static analysis           detect-dev          {val}    {available/null}
Test pass rate + coverage qa-test-run         {val}    {available/null}
Mutation score            qa-test-mutate      {val}    {available/null}
Security scan             sec-audit-remediate {val}    {available/null}
Code complexity           detect-dev          {val}    {available/null}
Diff size/scope           backend-pr-review   {val}    {available/null}

Available signals: {count}/6
```

## Step 2: Normalize Signals

Convert each signal to 0-1 scale:

| Signal | Raw Value | Normalization |
|--------|-----------|---------------|
| Static analysis | pass/fail + finding count | 1.0 (pass, 0 findings) to 0.0 (fail, many criticals) |
| Test pass rate + coverage | pass rate %, coverage % | (pass_rate * 0.6 + coverage * 0.4) / 100 |
| Mutation score | percentage or null | score / 100, or null |
| Security scan | severity counts | 1.0 (no findings) to 0.0 (critical findings) |
| Code complexity | cyclomatic/cognitive | 1.0 (low) to 0.0 (very high) |
| Diff size/scope | lines changed, files | 1.0 (small) to 0.5 (large) |

## Step 3: Compute Composite Score

### Default Weights (configurable in `jaan-to/config/settings.yaml`):

```yaml
qa_quality_gate:
  weights:
    static_analysis: 0.20
    test_pass_coverage: 0.25
    mutation_score: 0.15
    security_scan: 0.20
    code_complexity: 0.10
    diff_size: 0.10
```

### Null Signal Handling

When a signal is `null` (not measured), redistribute its weight proportionally across remaining non-null signals.

Example: if mutation score is `null` (weight 0.15):
- Remaining signals total weight: 0.85
- Each remaining signal scaled by `1 / 0.85`
- Weights sum to 1.0

Formula: `adjusted_weight[i] = original_weight[i] / sum_of_non_null_weights`

Report: "Score based on {N}/6 available signals."

### Composite Calculation

```
composite = sum(normalized_signal[i] * adjusted_weight[i]) for all non-null signals
```

## Step 4: Determine Routing Recommendation

| Score | Recommendation | Action |
|-------|---------------|--------|
| > 0.85 | "Recommend auto-approve -- all quality signals strong" | Lightweight review sufficient |
| 0.6-0.85 | "Recommend lightweight review -- AI-annotated concerns attached" | Focus on flagged areas |
| < 0.6 | "Recommend full human review -- significant quality signals flagged" | Comprehensive review needed |

---

# HARD STOP -- Quality Gate Results

Present composite score and recommendation:

```
QUALITY GATE RESULTS
-------------------------------------------------------------
Composite Score:  {score} (based on {N}/6 signals)

Signal Breakdown:
  Static Analysis (0.20):       {normalized} -> weighted {contribution}
  Test Pass + Coverage (0.25):  {normalized} -> weighted {contribution}
  Mutation Score (0.15):        {normalized or "null (excluded)"} -> weighted {contribution}
  Security Scan (0.20):         {normalized} -> weighted {contribution}
  Code Complexity (0.10):       {normalized} -> weighted {contribution}
  Diff Size (0.10):             {normalized} -> weighted {contribution}

Recommendation: {routing recommendation text}

Null Signals: {list of null signals with reason}
```

Use AskUserQuestion:
- Question: "Accept quality gate recommendation?"
- Header: "Quality Gate"
- Options:
  - "Accept" -- Proceed with recommendation
  - "Override" -- Override recommendation (explain why)
  - "Investigate" -- Drill into specific signals

**This gate does NOT auto-approve. Human decision is final.**

---

# PHASE 2: Output (Write Phase)

## Step 5: Generate Output

### 5.1 Generate Output Metadata

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/qa/quality-gate"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

### 5.2 Generate Executive Summary

Template:
```
Quality gate for {project/feature}: composite score {score} based on {N}/6 signals.
{recommendation}. Key concerns: {top 2-3 lowest signals}.
{null_signals_note if any}.
```

### 5.3 Write Output

Path: `$JAAN_OUTPUTS_DIR/qa/quality-gate/${NEXT_ID}-${slug}/`

Main file: `{id}-{slug}.md`

Sections:
- Title, Executive Summary
- Composite Score with breakdown table
- Signal Details (per signal: source, raw value, normalized, weighted)
- Null Signal Analysis
- Routing Recommendation with rationale
- Human Decision Record (accept/override + reason)
- Metadata (upstream paths, timestamp, weight config)

### 5.4 Update Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Project/Feature} Quality Gate" \
  "{Executive Summary}"
```

## Step 6: Capture Feedback

Use AskUserQuestion:
- Question: "How did the quality gate turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" -- Done
  - "Needs fixes" -- Adjust weights or signals
  - "Learn from this" -- Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add qa-quality-gate "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human decision
- Aggregates upstream outputs (does NOT scan repo directly)
- Configurable weights via settings.yaml
- Human-in-the-loop: recommendation only, never auto-approve

## Definition of Done

- [ ] At least 1 upstream output read and parsed
- [ ] Signals normalized to 0-1 scale
- [ ] Null signals handled with proportional weight redistribution
- [ ] Composite score computed
- [ ] Routing recommendation determined
- [ ] Human decision recorded (accept/override)
- [ ] Executive Summary generated
- [ ] Sequential ID generated
- [ ] Output written to `$JAAN_OUTPUTS_DIR/qa/quality-gate/{id}-{slug}/`
- [ ] Index updated
- [ ] User approved
