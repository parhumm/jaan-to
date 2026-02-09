---
name: pack-detect
description: Consolidate all detect outputs into unified index with risk heatmap and unknowns backlog.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [repo]
---

# pack-detect

> Consolidate all detect outputs into a scored index with risk heatmap and unknowns backlog.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:pack-detect.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:pack-detect.template.md` - Output template

**Output path**: `$JAAN_OUTPUTS_DIR/detect/` — flat files, overwritten each run (no IDs).

**Important**: This skill does NOT scan the repository directly. It reads and consolidates outputs from the 5 detect skills.

## Input

**Repository**: $ARGUMENTS

If a repository path is provided, read detect outputs from that repo. Otherwise, use the current working directory.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:pack-detect.learn.md`

If the file exists, apply its lessons throughout this execution.

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_pack-detect` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, evidence blocks.

---

# PHASE 1: Consolidation (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Cross-domain pattern recognition
- Risk correlation across domains
- Evidence ID validation and deduplication
- Overall score calculation

## Step 0: Check Detect Outputs

Glob `$JAAN_OUTPUTS_DIR/detect/{dev,design,writing,product,ux}/` to see which detect skills have run.

**If NO detect outputs exist**:

Display:
> "No detect outputs found. To generate a full knowledge pack, run the detect skills first:
>
> 1. `/jaan-to:detect-dev` — Engineering audit
> 2. `/jaan-to:detect-design` — Design system detection
> 3. `/jaan-to:detect-writing` — Writing system extraction
> 4. `/jaan-to:detect-product` — Product reality extraction
> 5. `/jaan-to:detect-ux` — UX audit
>
> Then run `/jaan-to:pack-detect` to consolidate.
>
> Or run individual skills for specific domains."

**Stop execution.**

**If SOME but not all detect outputs exist**:

Display:
> "Found outputs for: {list of domains with outputs}.
> Missing: {list of domains without outputs}.
>
> Continue with available outputs? (Results will be marked as partial) [y/n]"

If user declines, stop execution.

## Step 1: Read All Detect Outputs

For each domain that has outputs, read all files:

| Domain | Directory | Expected Files |
|--------|-----------|---------------|
| dev | `$JAAN_OUTPUTS_DIR/detect/dev/` | stack, architecture, standards, testing, cicd, deployment, security, observability, risks |
| design | `$JAAN_OUTPUTS_DIR/detect/design/` | brand, tokens, components, patterns, accessibility, governance |
| writing | `$JAAN_OUTPUTS_DIR/detect/writing/` | writing-system, glossary, ui-copy, error-messages, localization, samples |
| product | `$JAAN_OUTPUTS_DIR/detect/product/` | overview, features, value-prop, monetization, entitlements, metrics, constraints |
| ux | `$JAAN_OUTPUTS_DIR/detect/ux/` | personas, jtbd, flows, pain-points, heuristics, accessibility, gaps |

## Step 2: Validate Universal Frontmatter

For each output file, validate required frontmatter fields:

- `target.commit` — MUST match current git HEAD (flag stale if mismatched)
- `tool.rules_version` — record for version compatibility
- `confidence_scheme` — MUST be "four-level"
- `findings_summary` — MUST have severity buckets (critical/high/medium/low/informational)
- `overall_score` — MUST be 0-10 numeric
- `lifecycle_phase` — MUST use CycloneDX vocabulary

**Validation failures** become findings in the consolidated output (severity: Medium, confidence: Confirmed).

## Step 3: Aggregate Findings

### Severity Buckets

Collect all findings_summary from each output file and aggregate into repo-wide totals:

```
Total Critical:      sum of all critical findings
Total High:          sum of all high findings
Total Medium:        sum of all medium findings
Total Low:           sum of all low findings
Total Informational: sum of all informational findings
```

### Overall Score Formula

```
overall_score = 10 - (critical * 2.0 + high * 1.0 + medium * 0.4 + low * 0.1) / max(total_findings, 1)
```

Clamp result to 0-10 range.

If partial run (not all 5 domains), append "(partial)" to the score label.

### Confidence Distribution

Count findings by confidence level across all domains:
- Confirmed: {n}
- Firm: {n}
- Tentative: {n}
- Uncertain: {n}

## Step 4: Build Risk Heatmap

Create a domain x severity markdown table:

```markdown
| Domain | Critical | High | Medium | Low | Info | Score |
|--------|----------|------|--------|-----|------|-------|
| Dev    | {n}      | {n}  | {n}    | {n} | {n}  | {s}   |
| Design | {n}      | {n}  | {n}    | {n} | {n}  | {s}   |
| Writing| {n}      | {n}  | {n}    | {n} | {n}  | {s}   |
| Product| {n}      | {n}  | {n}    | {n} | {n}  | {s}   |
| UX     | {n}      | {n}  | {n}    | {n} | {n}  | {s}   |
| **Total** | **{n}** | **{n}** | **{n}** | **{n}** | **{n}** | **{s}** |
```

For missing domains, show "not analyzed" in all cells.

## Step 5: Build Evidence Index (Source Map)

Collect ALL evidence IDs from all detect outputs and build a resolution index:

```markdown
| Evidence ID | Domain | File | Location | Type | Confidence |
|-------------|--------|------|----------|------|------------|
| E-DEV-001   | dev    | src/auth/login.py | L42-58 | code-location | Confirmed |
| E-DSN-001a  | design | src/tokens/colors.json | L15 | token-definition | Firm |
| ...         | ...    | ...  | ...      | ...  | ...        |
```

Validate:
- No duplicate evidence IDs (flag if found)
- All IDs follow namespace convention (E-DEV-NNN, E-DSN-NNN, E-WRT-NNN, E-PRD-NNN, E-UX-NNN)
- All IDs resolve to actual file locations

## Step 6: Build Unknowns Backlog

Collect all findings with confidence <= Tentative (0.79 or below) and all "absence" evidence items.

For each unknown:
- Finding ID and title
- Current confidence level
- Domain
- "How to confirm" steps (what investigation would resolve the uncertainty)
- Explicit scope boundary (what this finding can and cannot claim)

---

# HARD STOP — Consolidation Summary & User Approval

## Step 7: Present Consolidation Summary

```
KNOWLEDGE PACK CONSOLIDATION
------------------------------

DOMAINS ANALYZED: {n}/5 {list}
{if partial: "WARNING: Partial analysis — missing: {list}"}

REPO-WIDE FINDINGS
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {score}/10 {(partial) if applicable}

CONFIDENCE DISTRIBUTION
  Confirmed: {n}  |  Firm: {n}  |  Tentative: {n}  |  Uncertain: {n}

EVIDENCE INDEX: {n} evidence IDs indexed
UNKNOWNS BACKLOG: {n} items requiring investigation

VALIDATION ISSUES: {n} frontmatter validation failures

OUTPUT FILES (4):
  $JAAN_OUTPUTS_DIR/detect/README.md              - Knowledge index with overall score
  $JAAN_OUTPUTS_DIR/detect/risk-heatmap.md        - Domain x severity risk heatmap
  $JAAN_OUTPUTS_DIR/detect/unknowns-backlog.md    - Prioritized unknowns with confirmation steps
  $JAAN_OUTPUTS_DIR/detect/source-map.md          - Evidence ID resolution index
```

> "Proceed with writing 4 consolidation files to $JAAN_OUTPUTS_DIR/detect/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 8: Write to $JAAN_OUTPUTS_DIR/detect/

Write 4 output files:

| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/README.md` | Knowledge index: metadata, domain summaries, overall score, links to all detect outputs |
| `$JAAN_OUTPUTS_DIR/detect/risk-heatmap.md` | Risk heatmap table (domain x severity), top risks per domain |
| `$JAAN_OUTPUTS_DIR/detect/unknowns-backlog.md` | Prioritized unknowns with "how to confirm" steps and scope boundaries |
| `$JAAN_OUTPUTS_DIR/detect/source-map.md` | Evidence index: all E-IDs mapped to file locations |

### README.md Structure

```markdown
# Knowledge Index: {repo-name}

> Generated by jaan.to pack-detect | {date}

## Overview

- **Domains analyzed**: {n}/5
- **Overall score**: {score}/10
- **Total findings**: {n}
- **Evidence items**: {n}

## Domain Summaries

### Dev — {score}/10
{executive summary from dev outputs}

### Design — {score}/10
{executive summary from design outputs}

### Writing — {score}/10
{executive summary from writing outputs}

### Product — {score}/10
{executive summary from product outputs}

### UX — {score}/10
{executive summary from ux outputs}

## Quick Links
- [Risk Heatmap](risk-heatmap.md)
- [Unknowns Backlog](unknowns-backlog.md)
- [Source Map](source-map.md)
- [Dev Audit](dev/)
- [Design Audit](design/)
- [Writing Audit](writing/)
- [Product Audit](product/)
- [UX Audit](ux/)
```

Each file MUST include universal YAML frontmatter.

---

## Step 9: Capture Feedback

> "Any feedback on the knowledge pack? [y/n]"

If yes:
- Run `/jaan-to:learn-add pack-detect "{feedback}"`

---

## Definition of Done

- [ ] All 4 output files written to `$JAAN_OUTPUTS_DIR/detect/`
- [ ] Universal YAML frontmatter in every file
- [ ] Risk heatmap shows domain x severity table
- [ ] Evidence index resolves all E-IDs to file locations
- [ ] No duplicate evidence IDs
- [ ] Unknowns backlog has "how to confirm" steps
- [ ] Overall score calculated with formula
- [ ] Partial runs clearly labeled with coverage %
- [ ] Frontmatter validation issues flagged
- [ ] User approved output
