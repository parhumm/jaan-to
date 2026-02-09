---
name: detect-pack
description: Consolidate all detect outputs into unified index with risk heatmap and unknowns backlog.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: "[repo] [--full]"
---

# detect-pack

> Consolidate all detect outputs into a scored index with risk heatmap and unknowns backlog.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:detect-pack.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:detect-pack.template.md` - Output template

**Output path**: `$JAAN_OUTPUTS_DIR/detect/` — flat files, overwritten each run (no IDs).

**Important**: This skill does NOT scan the repository directly. It reads and consolidates outputs from the 5 detect skills.

## Input

**Arguments**: $ARGUMENTS — parsed in Step 0.0. Repository path and mode determined there.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:detect-pack.learn.md`

If the file exists, apply its lessons throughout this execution.

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_detect-pack` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, evidence blocks.

---

# PHASE 1: Consolidation (Read-Only)

## Step 0.0: Parse Arguments

**Arguments**: $ARGUMENTS

| Argument | Effect |
|----------|--------|
| (none) | **Light mode** (default): Heatmap + domain scores, single summary file |
| `[repo]` | Read detect outputs from specified repo (applies to both modes) |
| `--full` | **Full mode**: Full consolidation with evidence index and unknowns backlog (current behavior) |

**Mode determination:**
- If `$ARGUMENTS` contains `--full` as a standalone token → set `run_depth = "full"`
- Otherwise → set `run_depth = "light"`

Strip `--full` token from arguments. Set `repo_path` to remaining arguments (or current working directory if empty).

## Thinking Mode

**If `run_depth == "full"`:** ultrathink
**If `run_depth == "light"`:** megathink

Use extended reasoning for:
- Cross-domain pattern recognition
- Risk correlation across domains
- Evidence ID validation and deduplication
- Overall score calculation

## Step 0: Check Detect Outputs & Detect Platforms

### Check for Detect Outputs

Glob `$JAAN_OUTPUTS_DIR/detect/{dev,design,writing,product,ux}/` to see which detect skills have run.

**If NO detect outputs exist**:

Display:
> "No detect outputs found. Is this a multi-platform project? [y/n]"

If YES:
  Ask: "Enter platform names (comma-separated, e.g., web,backend,mobile): "
  Display orchestration guide:

  "To analyze all platforms, run detect skills for each:

  Platform: {platform1}
    1. /jaan-to:detect-dev
    2. /jaan-to:detect-design
    3. /jaan-to:detect-writing
    4. /jaan-to:detect-product
    5. /jaan-to:detect-ux

  Platform: {platform2}
    ... (repeat for each platform)

  After all platforms analyzed:
    /jaan-to:detect-pack"

  **Stop execution** (orchestration mode)

If NO (single-platform):
  Display standard workflow list:
  > "To generate a full knowledge pack, run the detect skills first:
  >
  > 1. `/jaan-to:detect-dev` — Engineering audit
  > 2. `/jaan-to:detect-design` — Design system detection
  > 3. `/jaan-to:detect-writing` — Writing system extraction
  > 4. `/jaan-to:detect-product` — Product reality extraction
  > 5. `/jaan-to:detect-ux` — UX audit
  >
  > Then run `/jaan-to:detect-pack` to consolidate."

  **Stop execution**

### Detect Platform Structure

**If outputs exist**, scan for platform suffixes to determine single vs multi-platform:

```python
# Detect platforms by scanning for filename suffixes
platforms = set()
for domain in ['dev', 'design', 'writing', 'product', 'ux']:
  files = Glob(f"$JAAN_OUTPUTS_DIR/detect/{domain}/*-*.md")  # Files with dash suffix
  for file in files:
    # Extract platform from filename: "stack-web.md" → "web"
    # Pattern: {aspect}-{platform}.md where platform is everything after last dash
    filename = os.path.basename(file)
    if filename.count('-') >= 1:  # Has platform suffix
      platform = filename.split('-')[-1].replace('.md', '')
      platforms.add(platform)

# Also check for files WITHOUT suffix (single-platform)
for domain in ['dev', 'design', 'writing', 'product', 'ux']:
  files_no_suffix = Glob(f"$JAAN_OUTPUTS_DIR/detect/{domain}/*.md")
  for file in files_no_suffix:
    filename = os.path.basename(file)
    # Check if filename has NO platform suffix (e.g., "stack.md" not "stack-web.md")
    if '-' not in filename.replace('.md', ''):  # No dash in base name
      platforms.add('all')  # Single-platform marker
      break

platforms = list(platforms)
```

**Handle detection results**:

- **No platforms detected** → Something is wrong, no valid outputs found
- **Only 'all' platform detected** → **Single-platform mode**: consolidate all files into single pack
- **Multiple platforms detected** (excluding 'all') → **Multi-platform mode**: create per-platform packs + merged pack
- **Mix of 'all' and platforms** → **Hybrid mode**: treat 'all' as legacy single-platform alongside new multi-platform outputs

**Display detection result**:
```
PLATFORM DETECTION
------------------
Mode: {Single-platform / Multi-platform / Hybrid}
Platforms detected: {list}
```

**If SOME but not all detect outputs exist**:

Display:
> "Found outputs for: {list of domains with outputs}.
> Missing: {list of domains without outputs}.
>
> Continue with available outputs? (Results will be marked as partial) [y/n]"

If user declines, stop execution.

## Step 1: Read All Detect Outputs

For each domain that has outputs, detect input mode and read accordingly:

### Input Mode Detection

For each domain directory (`detect/dev/`, `detect/design/`, etc.):

1. **Glob for individual aspect files** (e.g., `stack*.md`, `architecture*.md`, `tokens*.md`)
2. **If individual files found** → `input_mode = "full"` — read all individual files (current behavior)
3. **If only `summary{suffix}.md` found** → `input_mode = "light"` — read summary file, extract `findings_summary` and `overall_score` from frontmatter
4. **Track input mode per domain** for use in subsequent steps:

| Domain | Input Mode | Files Read |
|---------|-----------|------------|
| dev     | full / light | {count} files or summary.md |
| design  | full / light | {count} files or summary.md |
| writing | full / light | {count} files or summary.md |
| product | full / light | {count} files or summary.md |
| ux      | full / light | {count} files or summary.md |

### Full-Mode Input: Expected Files

| Domain | Directory | Expected Files |
|--------|-----------|---------------|
| dev | `$JAAN_OUTPUTS_DIR/detect/dev/` | stack, architecture, standards, testing, cicd, deployment, security, observability, risks |
| design | `$JAAN_OUTPUTS_DIR/detect/design/` | brand, tokens, components, patterns, accessibility, governance |
| writing | `$JAAN_OUTPUTS_DIR/detect/writing/` | writing-system, glossary, ui-copy, error-messages, localization, samples |
| product | `$JAAN_OUTPUTS_DIR/detect/product/` | overview, features, value-prop, monetization, entitlements, metrics, constraints |
| ux | `$JAAN_OUTPUTS_DIR/detect/ux/` | personas, jtbd, flows, pain-points, heuristics, accessibility, gaps |

### Light-Mode Input: Summary Files

For domains with `input_mode = "light"`, read `summary{suffix}.md` and extract:
- YAML frontmatter: `findings_summary`, `overall_score`, `platform`, `target`
- Executive summary text (for domain summary in consolidated output)

## Step 2: Validate Universal Frontmatter

For each output file, validate required frontmatter fields:

- `target.commit` — MUST match current git HEAD (flag stale if mismatched)
- `tool.rules_version` — record for version compatibility
- `confidence_scheme` — MUST be "four-level"
- `findings_summary` — MUST have severity buckets (critical/high/medium/low/informational)
- `overall_score` — MUST be 0-10 numeric
- `lifecycle_phase` — MUST use CycloneDX vocabulary

**Validation failures** become findings in the consolidated output (severity: Medium, confidence: Confirmed).

**Light-mode input handling**: For domains with `input_mode = "light"`, validate only the summary file frontmatter. Skip per-file validation (individual files don't exist).

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

**If `run_depth == "light"`:** Skip Steps 5, 6, and 6a. Proceed directly to Step 7 (Present Consolidation Summary).

**Note**: For domains with `input_mode = "light"`, Steps 2-4 use summary-level data (frontmatter scores and finding counts) instead of per-file data. Validation is limited to frontmatter presence check.

## Step 5: Build Evidence Index (Source Map)

Collect ALL evidence IDs from all detect outputs and build a resolution index:

```markdown
| Evidence ID | Platform | Domain | File | Location | Type | Confidence |
|-------------|----------|--------|------|----------|------|------------|
| E-DEV-001   | all      | dev    | src/auth/login.py | L42-58 | code-location | Confirmed |
| E-DEV-WEB-001 | web    | dev    | web/src/auth/login.py | L42-58 | code-location | Confirmed |
| E-DSN-MOBILE-001a | mobile | design | mobile/src/tokens/colors.json | L15 | token-definition | Firm |
| ...         | ...      | ...    | ...  | ...      | ...  | ...        |
```

**Evidence ID Parsing** — Handle both legacy and multi-platform formats:

```python
import re

# Regex pattern: E-{DOMAIN}-({PLATFORM}-)?{NUMBER}
evidence_id_pattern = r'^E-([A-Z]+)-(([A-Z]+)-)?(\d{3}[a-z]?)$'

# Examples:
#   E-DEV-001        → groups: ('DEV', None, None, '001')
#   E-DEV-WEB-001    → groups: ('DEV', 'WEB-', 'WEB', '001')
#   E-DSN-001a       → groups: ('DSN', None, None, '001a')  # Drift finding with suffix

# Parsing logic:
match = re.match(evidence_id_pattern, evidence_id)
if match:
  domain = match.group(1)          # DEV, DSN, WRT, PRD, UX
  platform = match.group(3) or 'all'  # WEB, BACKEND, MOBILE, or 'all' for legacy
  sequence = match.group(4)        # 001, 002, 001a, etc.
```

**Validate**:
- No duplicate evidence IDs (flag if found)
- All IDs follow namespace convention (E-{DOMAIN}-NNN or E-{DOMAIN}-{PLATFORM}-NNN)
- Domain codes valid: DEV, DSN, WRT, PRD, UX
- Platform names match detected platforms from Step 0
- All IDs resolve to actual file locations

**Cross-platform Evidence Linking** (if multi-platform):

For findings with `related_evidence` field, track bidirectional links:

```python
# Build evidence graph
evidence_links = {}
for evidence_id, evidence in all_evidence.items():
  if evidence.get('related_evidence'):
    for related_id in evidence['related_evidence']:
      if evidence_id not in evidence_links:
        evidence_links[evidence_id] = set()
      evidence_links[evidence_id].add(related_id)

# Identify cross-platform finding groups
cross_platform_groups = find_connected_components(evidence_links)
# Example: [{E-DEV-WEB-042, E-DEV-BACKEND-038}, ...] = same issue in web + backend
```

## Step 6: Build Unknowns Backlog

Collect all findings with confidence <= Tentative (0.79 or below) and all "absence" evidence items.

For each unknown:
- Finding ID and title
- Current confidence level
- Domain
- "How to confirm" steps (what investigation would resolve the uncertainty)
- Explicit scope boundary (what this finding can and cannot claim)

## Step 6a: Multi-Platform Consolidation (if applicable)

**Only run this step if Step 0 detected multiple platforms.**

If single-platform mode, skip to Step 7.

### 1. Aggregate Per-Platform Findings

For each detected platform:

```python
platform_findings = {}
for platform in platforms:
  findings_summary = {
    'critical': 0, 'high': 0, 'medium': 0, 'low': 0, 'informational': 0
  }

  # Read all domain outputs for this platform
  for domain in ['dev', 'design', 'writing', 'product', 'ux']:
    for aspect in DOMAIN_ASPECTS[domain]:  # e.g., dev → [stack, architecture, ...]
      # Try platform-specific file first
      file_path = f"$JAAN_OUTPUTS_DIR/detect/{domain}/{aspect}-{platform}.md"
      if file_exists(file_path):
        frontmatter = parse_frontmatter(file_path)
        # Aggregate severity counts
        for severity in ['critical', 'high', 'medium', 'low', 'informational']:
          findings_summary[severity] += frontmatter['findings_summary'][severity]

  # Calculate overall score for this platform
  total_findings = sum(findings_summary.values())
  overall_score = 10 - (
    findings_summary['critical'] * 2.0 +
    findings_summary['high'] * 1.0 +
    findings_summary['medium'] * 0.4 +
    findings_summary['low'] * 0.1
  ) / max(total_findings, 1)

  platform_findings[platform] = {
    'summary': findings_summary,
    'score': overall_score
  }
```

### 2. Build Cross-Platform Risk Heatmap

```python
heatmap_table = []
for platform, data in platform_findings.items():
  row = {
    'platform': platform,
    'dev': format_severity(get_domain_findings(platform, 'dev')),
    'design': format_severity(get_domain_findings(platform, 'design')),
    'writing': format_severity(get_domain_findings(platform, 'writing')),
    'product': format_severity(get_domain_findings(platform, 'product')),
    'ux': format_severity(get_domain_findings(platform, 'ux')),
    'score': data['score']
  }
  heatmap_table.append(row)

# Add totals row
totals = aggregate_all_platforms(platform_findings)
heatmap_table.append({'platform': 'TOTAL', ...totals})
```

**Example cross-platform heatmap:**

| Platform | Dev | Design | Writing | Product | UX | Score |
|----------|-----|--------|---------|---------|-----|-------|
| web      | C:2 H:5 M:8 | C:0 H:2 M:4 | C:0 H:1 M:3 | C:0 H:2 M:5 | C:1 H:3 M:6 | 7.2 |
| backend  | C:1 H:3 M:6 | - | C:0 H:0 M:2 | C:0 H:1 M:4 | - | 8.1 |
| mobile   | C:0 H:4 M:7 | C:0 H:3 M:5 | C:0 H:2 M:4 | C:0 H:2 M:6 | C:0 H:2 M:5 | 7.8 |
| **Total**| **3 12 21** | **5 9** | **3 7** | **4 15** | **1 5 11** | **7.7** |

### 3. Identify Cross-Platform Findings

```python
# Extract findings with related_evidence (cross-platform links)
cross_platform_findings = []
for platform in platforms:
  for domain in ['dev', 'design', 'writing', 'product', 'ux']:
    findings = extract_findings_with_related_evidence(platform, domain)
    for finding in findings:
      if finding.get('related_evidence'):  # Has cross-platform links
        cross_platform_findings.append(finding)
```

### 4. Deduplicate Shared Findings

```python
deduplicated = []
seen_groups = set()

for finding in cross_platform_findings:
  # Create canonical group ID from related_evidence chain
  group_id = frozenset([finding['id']] + finding['related_evidence'])

  if group_id not in seen_groups:
    seen_groups.add(group_id)

    # Collect all platforms affected
    affected_platforms = []
    for evidence_id in group_id:
      # Extract platform from evidence ID: E-DEV-WEB-001 → 'web'
      match = re.match(r'E-[A-Z]+-([A-Z]+)-\d+', evidence_id)
      if match:
        affected_platforms.append(match.group(1).lower())
      else:
        affected_platforms.append('all')  # Legacy format

    deduplicated.append({
      'title': finding['title'],
      'severity': max_severity([get_finding_by_id(eid)['severity'] for eid in group_id]),
      'platforms': list(set(affected_platforms)),
      'evidence_ids': list(group_id),
      'description': finding['description']
    })
```

**Store consolidated data** for use in Step 8 (Writing phase):
- `platform_findings`: per-platform aggregates
- `heatmap_table`: cross-platform risk table
- `deduplicated`: cross-platform findings with deduplication

---

# HARD STOP — Consolidation Summary & User Approval

## Step 7: Present Consolidation Summary

**If `run_depth == "light"`:**

```
KNOWLEDGE PACK CONSOLIDATION (Light Mode)
--------------------------------------------

MODE: {Single-Platform / Multi-Platform}
{if multi: "PLATFORMS DETECTED: {list} ({n} platforms)"}

DOMAINS ANALYZED: {n}/5 {list}
INPUT MODES: {domain: mode for each domain}
{if partial: "WARNING: Partial analysis — missing: {list}"}

REPO-WIDE FINDINGS
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {score}/10 {(partial) if applicable}

RISK HEATMAP:
  {inline domain x severity table}

OUTPUT FILE (1):
  $JAAN_OUTPUTS_DIR/detect/summary.md

Note: Run with --full for evidence index (source map), unknowns backlog,
cross-platform deduplication, and per-platform detail packs.
```

> "Proceed with writing summary to $JAAN_OUTPUTS_DIR/detect/? [y/n]"

**If `run_depth == "full"`:**

**Single-Platform Mode:**

```
KNOWLEDGE PACK CONSOLIDATION
------------------------------

MODE: Single-Platform
PLATFORM: all

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

**Multi-Platform Mode:**

```
KNOWLEDGE PACK CONSOLIDATION
------------------------------

MODE: Multi-Platform
PLATFORMS DETECTED: {list} ({n} platforms)

DOMAINS ANALYZED: {n}/5 {list}
{if partial: "WARNING: Partial analysis — missing: {list}"}

PER-PLATFORM SCORES
  web:     {score}/10  |  Findings: C:{n} H:{n} M:{n} L:{n} I:{n}
  backend: {score}/10  |  Findings: C:{n} H:{n} M:{n} L:{n} I:{n}
  mobile:  {score}/10  |  Findings: C:{n} H:{n} M:{n} L:{n} I:{n}

REPO-WIDE AGGREGATE (All Platforms)
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {weighted_avg_score}/10

CROSS-PLATFORM FINDINGS: {n} findings linked across multiple platforms

CONFIDENCE DISTRIBUTION
  Confirmed: {n}  |  Firm: {n}  |  Tentative: {n}  |  Uncertain: {n}

EVIDENCE INDEX: {n} evidence IDs indexed ({n} with platform prefixes)
UNKNOWNS BACKLOG: {n} items requiring investigation

VALIDATION ISSUES: {n} frontmatter validation failures

OUTPUT FILES (4 + {n} per-platform):
  $JAAN_OUTPUTS_DIR/detect/pack/README.md              - Merged pack (all platforms)
  $JAAN_OUTPUTS_DIR/detect/pack/risk-heatmap.md        - Cross-platform risk heatmap
  $JAAN_OUTPUTS_DIR/detect/pack/unknowns-backlog.md    - All platforms combined
  $JAAN_OUTPUTS_DIR/detect/pack/source-map.md          - All evidence IDs

  Per-platform packs:
  $JAAN_OUTPUTS_DIR/detect/pack/README-{platform}.md   - Per-platform index
  (one per detected platform)
```

> "Proceed with writing consolidation files to $JAAN_OUTPUTS_DIR/detect/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 8: Write Output Files

**Output directory logic:**

```python
# Determine output directory
if len(platforms) == 1 and 'all' in platforms:  # Single-platform
  output_dir = "$JAAN_OUTPUTS_DIR/detect/"
else:  # Multi-platform
  output_dir = "$JAAN_OUTPUTS_DIR/detect/pack/"

# Create directory if needed
os.makedirs(output_dir, exist_ok=True)
```

### Stale File Cleanup

- **If `run_depth == "full"`:** Delete any existing `summary.md` in `$JAAN_OUTPUTS_DIR/detect/` (stale light-mode output).
- **If `run_depth == "light"`:** Do NOT delete existing full-mode files.

### If `run_depth == "light"`: Write Single Summary File

Write one file: `$JAAN_OUTPUTS_DIR/detect/summary.md`

Contents:
1. Universal YAML frontmatter with `findings_summary` and `overall_score`
2. **Overview** — domains analyzed, input modes, overall score
3. **Risk Heatmap** — domain x severity table (from Step 4)
4. **Per-Domain Executive Summary** — 1-2 sentences per domain
5. If multi-platform: **Platform Scores Table** — scores per platform (no cross-platform dedup)
6. **Input Mode Table** — which domains provided full vs summary data
7. "Run with `--full` for evidence index (source map), unknowns backlog with confirmation steps, cross-platform finding deduplication, and per-platform detail packs."

### If `run_depth == "full"`: Write Full Output Files

### Single-Platform Mode

Write 4 output files to `$JAAN_OUTPUTS_DIR/detect/`:

| File | Content |
|------|---------|
| `README.md` | Knowledge index: metadata, domain summaries, overall score, links to all detect outputs |
| `risk-heatmap.md` | Risk heatmap table (domain x severity), top risks per domain |
| `unknowns-backlog.md` | Prioritized unknowns with "how to confirm" steps and scope boundaries |
| `source-map.md` | Evidence index: all E-IDs mapped to file locations |

### Multi-Platform Mode

Write to `$JAAN_OUTPUTS_DIR/detect/pack/`:

**Per-Platform Packs** (one per platform):

| File | Content |
|------|---------|
| `README-{platform}.md` | Platform-specific index with domain summaries for that platform only |

**Merged Pack** (all platforms combined):

| File | Content |
|------|---------|
| `README.md` | Merged knowledge index with platform summary table and overall aggregated score |
| `risk-heatmap.md` | Cross-platform risk heatmap (platform x domain table) + cross-platform findings section |
| `unknowns-backlog.md` | All Tentative/Uncertain findings across all platforms, grouped by platform then domain |
| `source-map.md` | All evidence IDs from all platforms with platform column |

### README.md Structure (Single-Platform)

```markdown
# Knowledge Index: {repo-name}

> Generated by jaan.to detect-pack | {date}

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

### README.md Structure (Multi-Platform Merged Pack)

```markdown
# Knowledge Index: {repo-name} (All Platforms)

> Generated by jaan.to detect-pack | {date}

## Overview

- **Mode**: Multi-Platform
- **Platforms analyzed**: {n} ({list})
- **Domains analyzed**: {n}/5
- **Overall score**: {weighted_avg_score}/10
- **Total findings**: {n} (across all platforms)
- **Evidence items**: {n}

## Platform Summary

| Platform | Score | Domains | Critical | High | Medium | Low | Info |
|----------|-------|---------|----------|------|--------|-----|------|
| web      | 7.2   | 5/5     | 2        | 12   | 25     | 8   | 3    |
| backend  | 8.1   | 3/5     | 1        | 5    | 15     | 3   | 2    |
| mobile   | 7.8   | 5/5     | 0        | 10   | 22     | 6   | 4    |
| **Total**| **7.7**| -      | **3**    | **27**| **62** | **17**| **9**|

## Cross-Platform Findings

{n} findings appear across multiple platforms:

1. **TypeScript Not Configured** (High) — Affects: web, backend
   - Evidence: E-DEV-WEB-042, E-DEV-BACKEND-038
   - Impact: Type safety missing in both frontend and backend

2. ... (list other cross-platform findings)

## Per-Platform Details

- [Web Platform Pack](README-web.md) — Score: 7.2/10
- [Backend Platform Pack](README-backend.md) — Score: 8.1/10
- [Mobile Platform Pack](README-mobile.md) — Score: 7.8/10

## Quick Links

- [Cross-Platform Risk Heatmap](risk-heatmap.md)
- [Unknowns Backlog (All Platforms)](unknowns-backlog.md)
- [Source Map (All Evidence IDs)](source-map.md)
```

Each file MUST include universal YAML frontmatter.

---

## Step 9: Capture Feedback

> "Any feedback on the knowledge pack? [y/n]"

If yes:
- Run `/jaan-to:learn-add detect-pack "{feedback}"`

---

## Definition of Done

**If `run_depth == "light"`:**

- [ ] Single `summary.md` written to `$JAAN_OUTPUTS_DIR/detect/`
- [ ] Universal YAML frontmatter with `findings_summary` and `overall_score`
- [ ] Risk heatmap table included (domain x severity)
- [ ] Per-domain executive summary (1-2 sentences each)
- [ ] Input mode table shows which domains provided full vs summary data
- [ ] Overall score calculated with formula
- [ ] Partial runs clearly labeled with coverage %
- [ ] "--full" upsell note included
- [ ] User approved output

**If `run_depth == "full"`:**

**Single-Platform Mode:**

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

**Multi-Platform Mode:**

- [ ] Output files written to `$JAAN_OUTPUTS_DIR/detect/pack/`
- [ ] Per-platform packs created (README-{platform}.md for each platform)
- [ ] Merged pack created (README.md with platform summary table)
- [ ] Cross-platform risk heatmap shows platform x domain table
- [ ] Cross-platform findings section in heatmap (deduplicated via related_evidence)
- [ ] Evidence index includes platform column and handles both ID formats
- [ ] Evidence ID regex correctly parses E-DEV-001 and E-DEV-WEB-001 formats
- [ ] No duplicate evidence IDs (checked with platform awareness)
- [ ] Cross-platform evidence links validated (all related_evidence IDs exist)
- [ ] Unknowns backlog groups findings by platform, then domain
- [ ] Per-platform scores calculated correctly
- [ ] Overall weighted average score calculated from platform scores
- [ ] Platform detection logic executed in Step 0
- [ ] User approved output
