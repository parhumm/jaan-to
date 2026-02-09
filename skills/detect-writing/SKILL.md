---
name: detect-writing
description: Writing system extraction with NNg tone dimensions, UI copy classification, and i18n maturity scoring.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [repo]
---

# detect-writing

> Detect the current writing system using multi-signal extraction and output a canonical writing-system spec.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:detect-writing.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (for framework-aware i18n scanning)
- `$JAAN_TEMPLATES_DIR/jaan-to:detect-writing.template.md` - Output template

**Output path**: `$JAAN_OUTPUTS_DIR/detect/writing/` — flat files, overwritten each run (no IDs).

## Input

**Repository**: $ARGUMENTS

If a repository path is provided, scan that repo. Otherwise, scan the current working directory.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:detect-writing.learn.md`

If the file exists, apply its lessons throughout this execution.

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_detect-writing` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, evidence blocks.

> **Language exception**: This skill's output describes the *project's* writing system. The language setting affects conversation and report prose, NOT the analysis of the project's content language or i18n configuration.

---

## Standards Reference

### Evidence Format (SARIF-compatible)

```yaml
evidence:
  id: E-WRT-001                # Single-platform format
  id: E-WRT-WEB-001            # Multi-platform format (platform prefix)
  type: code-location
  confidence: 0.85
  location:
    uri: "src/locales/en/common.json"
    startLine: 42
    snippet: |
      "deleteConfirm": "Are you sure you want to delete this?"
  method: pattern-match
```

**Evidence ID Format**:

```python
# Generation logic:
if current_platform == 'all' or current_platform is None:  # Single-platform
  evidence_id = f"E-WRT-{sequence:03d}"                     # E-WRT-001
else:  # Multi-platform
  platform_upper = current_platform.upper()
  evidence_id = f"E-WRT-{platform_upper}-{sequence:03d}"    # E-WRT-WEB-001, E-WRT-BACKEND-023
```

Evidence IDs use namespace `E-WRT-*` to prevent collisions in detect-pack aggregation. Platform prefix prevents ID collisions across platforms in multi-platform analysis.

### Confidence Levels (4-level)

| Level | Label | Range | Criteria |
|-------|-------|-------|----------|
| 4 | **Confirmed** | 0.95-1.00 | Multiple independent methods agree |
| 3 | **Firm** | 0.80-0.94 | Single high-precision method with clear evidence |
| 2 | **Tentative** | 0.50-0.79 | Pattern match without full analysis |
| 1 | **Uncertain** | 0.20-0.49 | Absence-of-evidence reasoning |

### Frontmatter Schema (Universal)

```yaml
---
title: "{document title}"
id: "{AUDIT-YYYY-NNN}"
version: "1.0.0"
status: draft
date: {YYYY-MM-DD}
target:
  name: "{repo-name}"
  platform: "{platform_name}"  # NEW: 'all' for single-platform, 'web'/'backend'/etc for multi-platform
  commit: "{git HEAD hash}"
  branch: "{current branch}"
tool:
  name: "detect-writing"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 0
overall_score: 0.0
lifecycle_phase: post-build
---
```

---

# PHASE 1: Detection (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- NNg tone dimension scoring across string corpus
- UI copy classification and quality assessment
- i18n maturity level determination
- Terminology consistency analysis

## Step 0: Detect Platforms

**Purpose**: Auto-detect platform structure and determine analysis scope (full vs partial).

Use **Glob** and **Bash** to identify platform folders:

### Platform Patterns

(Same as detect-dev - see detect-dev Step 0 for full patterns table)

### Detection Process

1. **Check for monorepo markers**: `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`
2. **List top-level directories**: `ls -d */ | grep -Ev "node_modules|\.git|dist|build|\.next"`
3. **Match against platform patterns**: Apply disambiguation rules
4. **Handle detection results**:
   - No platforms → Single-platform: `platforms = [{ name: 'all', path: '.' }]`
   - Platforms detected → Multi-platform: Ask user to select all or specific platforms

### Writing System Applicability

For each platform, determine analysis scope:

| Platform Type | Analysis Scope | Rationale |
|---------------|---------------|-----------|
| web, mobile, androidtv, ios, android, desktop | **Full** | UI copy, error messages, tone, localization |
| backend, api, services | **Partial** | Error messages only (API errors, logs, validation messages) |
| cli, cmd | **Partial** | Error messages + CLI help text only |

**Partial analysis** includes:
- Error message detection and scoring (Step 4)
- Glossary extraction from error messages (Step 5 - partial)
- Localization detection for error messages (Step 6 - partial)
- **Skips**: UI copy classification (Step 2), full tone analysis (Step 3 reduced to error messages only)

### UI Presence Check

```bash
# Check for UI component files
ui_files=$(find {platform.path} -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) 2>/dev/null | head -n 1)

if [ -z "$ui_files" ]; then
  # No UI files - partial analysis mode
  analysis_mode = "partial"  # Error messages only
else
  analysis_mode = "full"     # Full writing system analysis
fi
```

### Analysis Loop

For each platform in platforms:
1. Set `current_platform = platform.name`
2. Set `base_path = platform.path`
3. **Determine analysis mode** based on platform type and UI presence
4. If `analysis_mode == "partial"`:
   - Run Step 1 (String Inventory) - focus on error strings only
   - Skip Step 2 (UI Copy Classification)
   - Run Step 3 (Tone Analysis) - reduced to error messages corpus only
   - Run Step 4 (Error Message Scoring)
   - Run Step 5 (Glossary) - error terminology only
   - Run Step 6 (Localization) - error message i18n only
   - Skip Step 7 (Governance) unless content linting detected
   - Output files: writing-system.md (partial), error-messages.md, glossary.md (reduced), localization.md (reduced)
   - Mark ui-copy.md and samples.md as "Not Applicable"
5. If `analysis_mode == "full"`:
   - Run all steps (Steps 1-7)
   - Output all 6 files
6. Use platform-specific output paths in Step 9

**Partial Analysis Output Notes**:
- `writing-system.md`: Tone dimensions based on error messages only, with note about scope limitation
- `ui-copy.md`: Minimal "Not Applicable" file with informational finding
- `samples.md`: Minimal "Not Applicable" file or error message samples only

**Note**: If single-platform mode (`platform.name == 'all'`), output paths have NO suffix. If multi-platform mode, output paths include `-{platform}` suffix.

## Step 1: String Inventory

Extract all user-facing strings from:

### i18n / Locale Files
Use framework-specific glob patterns:

| Framework | Glob Patterns |
|-----------|--------------|
| React i18next | `**/locales/**/*.json`, `**/i18n/**/*.json`, `**/public/locales/**/*.json` |
| Vue i18n | `**/locales/*.json`, `**/i18n/**/*.json`, `**/lang/**/*.{json,yml}` |
| Angular | `**/src/locale/messages.*.xlf` |
| Next.js | `**/public/locales/**/*.json`, `**/messages/*.json` |
| Flutter/Dart | `**/lib/l10n/*.arb`, `**/l10n/app_*.arb` |
| Android | `**/res/values/strings.xml`, `**/res/values-*/strings.xml` |
| iOS/macOS | `**/*.lproj/Localizable.strings` |
| Rails | `**/config/locales/**/*.yml` |
| Django | `**/locale/*/LC_MESSAGES/django.po` |
| Java | `**/resources/messages*.properties` |
| .NET | `**/Resources/*.resx` |
| PHP/Laravel | `**/resources/lang/**/*.php`, `**/lang/**/*.php` |
| GNU gettext | `**/po/*.po`, `**/po/*.pot` |

### Component Inline Text
- Grep for text in component props: `label`, `title`, `message`, `description`, `placeholder`, `helperText`, `errorMessage`
- Grep for JSX/TSX inline text between tags

## Step 2: UI Copy Classification

Classify discovered strings into 8 categories using component-name glob patterns:

### Category Detection Patterns

| Category | Component Patterns | Props to Extract |
|----------|-------------------|-----------------|
| **Buttons/CTAs** | `*Button*`, `*Btn*`, `*CTA*`, `*Submit*`, `*Action*` | `children`, `label`, `text` |
| **Error messages** | `*Error*`, `*ValidationError*`, `*ErrorBoundary*`, `*ErrorState*` | `message`, `errorMessage`, `description` |
| **Empty states** | `*EmptyState*`, `*NoData*`, `*NoResults*`, `*ZeroState*`, `*BlankState*` | `title`, `description`, `message` |
| **Confirmation dialogs** | `*Dialog*`, `*Modal*`, `*Confirm*`, `*AlertDialog*` | `title`, `message`, `confirmText`, `cancelText` |
| **Notifications/toasts** | `*Toast*`, `*Notification*`, `*Snackbar*`, `*Banner*`, `*Flash*` | `message`, `title`, `description` |
| **Onboarding** | `*Onboarding*`, `*Tour*`, `*Walkthrough*`, `*Welcome*`, `*Wizard*`, `*Stepper*` | `title`, `description`, `step` |
| **Form labels/helper** | `*FormField*`, `*Label*`, `*HelperText*`, `*HintText*`, `*TextField*` | `label`, `helperText`, `placeholder` |
| **Loading states** | `*Loading*`, `*Spinner*`, `*Skeleton*`, `*Progress*`, `*Shimmer*` | `loadingText`, `message`, `label` |

Also inspect variant/severity props (`variant="error"`, `severity="warning"`, `isLoading`, `isEmpty`, `isDestructive`) to classify ambiguous components.

## Step 3: NNg Tone Dimension Scoring

For each extracted string corpus, compute tone dimensions:

### 4 Primary Dimensions (NNg)

| Dimension | Scale | Detection Signals |
|-----------|-------|------------------|
| **Formality** | 1(formal)-5(casual) | Contraction ratio, avg sentence length, passive voice %, Flesch-Kincaid grade, Latin-derived word ratio |
| **Humor** | 1(serious)-5(funny) | Exclamation frequency, emoji presence, metaphor/wordplay, dry/factual ratio |
| **Respectfulness** | 1(irreverent)-5(respectful) | Politeness markers ("please"/"thank you"), hedging frequency, commands vs requests |
| **Enthusiasm** | 1(matter-of-fact)-5(enthusiastic) | Exclamation marks, superlatives ("amazing"/"great"), intensifiers ("very"/"extremely") |

### 5 Extended Dimensions

| Dimension | Scale | Detection Signals |
|-----------|-------|------------------|
| **Technical complexity** | 1(simple)-5(complex) | Flesch-Kincaid score, jargon density, acronym frequency |
| **Verbosity** | 1(terse)-5(verbose) | Words per string, chars per string, information density |
| **Directness** | 1(indirect)-5(direct) | Imperative verb ratio, hedging words, sentence-initial verbs |
| **Empathy** | 1(detached)-5(empathetic) | Second-person pronoun density, emotional vocabulary, apology patterns |
| **Confidence** | 1(uncertain)-5(assertive) | Modal verb distribution ("should" vs "will"), definitive statements |

### Consistency Score

Calculate standard deviation per dimension across all strings. Flag strings deviating >1.5 standard deviations from mean on any dimension as outliers.

## Step 4: Error Message Quality Scoring

Apply 5-dimension weighted rubric to each error message found:

| Dimension | Weight | Scoring Criteria |
|-----------|--------|-----------------|
| **Clarity** | 25% | Flesch-Kincaid grade, jargon presence, visible error codes |
| **Specificity** | 20% | Problem field identification, exact issue description |
| **Actionability** | 25% | Fix-it actions, format examples, corrective guidance |
| **Tone** | 15% | Blame language, positive/empathetic phrasing |
| **Accessibility** | 15% | ARIA association, multiple indicators, screen reader support |

### Automated Heuristic Flags

Flag messages that match:
- Flesch-Kincaid > 8 (too complex for error messages)
- Sentences > 25 words
- Messages > 40 words
- Passive voice > 10%
- Blame language: "you failed", "your error", "invalid input"
- Visible error codes: `ERR_*`, `0x[0-9A-F]+`, `HTTP \d{3}`
- Missing action verbs (no guidance on how to fix)

## Step 5: i18n Maturity Assessment

### Framework Detection

Use the glob patterns from Step 1 to identify which i18n framework is in use.

### ICU MessageFormat Detection

Grep for ICU patterns indicating plural/gender-aware i18n:
- Plural: `\{\s*\w+\s*,\s*plural\s*,\s*(?:zero|one|two|few|many|other|=\d+)\s*\{`
- Select: `\{\s*\w+\s*,\s*select\s*,\s*\w+\s*\{`
- Format: `\{\s*\w+\s*,\s*(?:number|date|time)\s*(?:,\s*(?:short|medium|long|full))?\s*\}`

### RTL Support Detection

- Grep: `dir="rtl"` or `dir="auto"` in HTML templates
- Grep: CSS logical properties (`margin-inline-start`, `padding-inline-end`, `inset-inline-start`)
- Grep: `[dir="rtl"]` CSS selectors
- Check for RTL locale codes in supported locales (ar, he, fa, ur, ps)

### Hardcoded String Detection

- Grep in JSX/TSX for inline text: `>[^{<]*[A-Za-z]{3,}[^}<]*<`
- Exclude: UPPER_CASE constants, import paths, CSS class names, test IDs, `console.log` arguments

### String Interpolation Quality

- Named parameters (`{userName}`) = high maturity
- Positional with index (`%1$s`) = medium maturity
- Unnamed positional (`%s`, `%d`) = low maturity

### Centralization Scoring

**Positive signals** (+1 each): single `locales/` directory at root, consistent naming, single import source, i18n config file, namespaced dot-notation keys, CODEOWNERS entry for locale files.

**Negative signals** (-1 each): inline strings in components, multiple unrelated i18n directories, mixed hardcoded/translated in same component, no key naming convention, no i18n config.

Scores <= -2 cap maturity at Level 1 regardless of other signals.

### i18n Maturity Scale (0-5)

| Level | Name | Key Indicators |
|-------|------|---------------|
| **0** | None | No locale files, no i18n library, all strings hardcoded |
| **1** | Basic | i18n library installed but <30% externalized; single locale |
| **2** | Partial | 1-2 locales; 30-70% externalized; simple interpolation |
| **3** | Functional | 3+ locales; >70% externalized; pluralization; locale-aware formatting |
| **4** | Mature | 5+ locales; >95% externalized; ICU plural+select; RTL support; CLDR; governance |
| **5** | Excellence | 10+ locales; 100% externalized with lint; full ICU; bidi CSS; automated pipeline |

## Step 6: Terminology Extraction

Build a glossary using ISO-704-inspired methodology:

### Term Discovery
- Apply TF-IDF across string corpus (treat each file/module as a document)
- High TF-IDF terms in specific modules = domain-specific candidates
- For multi-word terms, use C-value method to penalize nested terms that mostly appear as parts of longer terms

### Inconsistency Detection
- **Semantic**: Same concept, different terms (e.g., "Delete" vs "Remove" vs "Erase")
- **Syntactic**: Near-identical strings with minor wording differences
- **Frequency-based**: Most frequent variant = "preferred"; alternatives = "admitted" or "deprecated"

### Glossary Entry Format

```yaml
terms:
  - preferred: "workspace"
    admitted: ["project", "space"]
    deprecated: ["folder"]
    definition: "A container for organizing related files and settings"
    occurrences: 47
    files: ["src/components/Workspace.tsx", "locales/en/common.json"]
    status: preferred    # preferred | admitted | deprecated | forbidden
```

## Step 7: Content Governance Detection

- Glob: `CODEOWNERS` — check for locale file ownership
- Check dependencies for content linting: `alex`, `write-good`, `vale`, `cspell`, `textlint`
- Check for i18n-related keywords in PR templates
- Check CI for missing translation checks

---

# HARD STOP — Detection Summary & User Approval

## Step 8: Present Detection Summary

```
WRITING SYSTEM DETECTION COMPLETE
-----------------------------------

PLATFORM: {platform_name or 'all'}
ANALYSIS MODE: {Full/Partial (error messages only)}

STRING CORPUS: {n} strings analyzed across {n} files
LOCALES DETECTED: {list}

TONE DIMENSIONS (NNg) {scope note if partial: "based on error messages only"}
  Formality:      {score}/5    Consistency: {stddev}
  Humor:          {score}/5    Consistency: {stddev}
  Respectfulness: {score}/5    Consistency: {stddev}
  Enthusiasm:     {score}/5    Consistency: {stddev}

UI COPY COVERAGE {show "N/A" if partial analysis}
  Buttons:      {n} strings    Error messages: {n} strings
  Empty states: {n} strings    Dialogs:        {n} strings
  Toasts:       {n} strings    Onboarding:     {n} strings
  Form labels:  {n} strings    Loading:        {n} strings

i18n MATURITY: Level {0-5} ({name})
ERROR MESSAGE SCORE: {avg_score}/10

SEVERITY SUMMARY
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {score}/10

OUTPUT FILES (6):
  $JAAN_OUTPUTS_DIR/detect/writing/writing-system{-platform}.md  - Voice + tone + consistency
  $JAAN_OUTPUTS_DIR/detect/writing/glossary{-platform}.md        - Terminology glossary
  $JAAN_OUTPUTS_DIR/detect/writing/ui-copy{-platform}.md         - UI copy classification {or "N/A" if partial}
  $JAAN_OUTPUTS_DIR/detect/writing/error-messages{-platform}.md  - Error message audit
  $JAAN_OUTPUTS_DIR/detect/writing/localization{-platform}.md    - i18n maturity assessment
  $JAAN_OUTPUTS_DIR/detect/writing/samples{-platform}.md         - Representative samples {or "N/A" if partial}

Note: {-platform} suffix only if multi-platform mode (e.g., -web, -backend). Single-platform mode has no suffix.
      Partial analysis mode (backend/cli) produces minimal "Not Applicable" files for ui-copy.md and samples.md.
```

> "Proceed with writing 6 output files to $JAAN_OUTPUTS_DIR/detect/writing/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 9: Write to $JAAN_OUTPUTS_DIR/detect/writing/

Create directory `$JAAN_OUTPUTS_DIR/detect/writing/` if it does not exist.

**Platform-specific output path logic**:

```python
# Determine filename suffix
if current_platform == 'all' or current_platform is None:  # Single-platform
  suffix = ""                                               # No suffix
else:  # Multi-platform
  suffix = f"-{current_platform}"                          # e.g., "-web", "-backend"

# Example output paths:
# Single-platform: $JAAN_OUTPUTS_DIR/detect/writing/writing-system.md
# Multi-platform:  $JAAN_OUTPUTS_DIR/detect/writing/writing-system-web.md
#                  $JAAN_OUTPUTS_DIR/detect/writing/writing-system-backend.md
```

Write 6 output files:

| File | Content | Partial Analysis Handling |
|------|---------|---------------------------|
| `$JAAN_OUTPUTS_DIR/detect/writing/writing-system{suffix}.md` | Voice definition, tone spectrum (NNg dimensions), consistency score | If partial: Note scope limitation ("based on error messages only") |
| `$JAAN_OUTPUTS_DIR/detect/writing/glossary{suffix}.md` | Terminology glossary with ISO-704 statuses | If partial: Error terminology only |
| `$JAAN_OUTPUTS_DIR/detect/writing/ui-copy{suffix}.md` | UI copy classification across 8 categories | If partial: **Minimal "Not Applicable" file** |
| `$JAAN_OUTPUTS_DIR/detect/writing/error-messages{suffix}.md` | Error message quality audit with rubric scoring | Always included (core finding) |
| `$JAAN_OUTPUTS_DIR/detect/writing/localization{suffix}.md` | i18n maturity assessment (0-5) with evidence | If partial: Error message i18n only |
| `$JAAN_OUTPUTS_DIR/detect/writing/samples{suffix}.md` | Representative string samples per category | If partial: **Minimal "Not Applicable" or error samples only** |

**Note**: `{suffix}` is empty for single-platform mode, or `-{platform}` for multi-platform mode.

**Partial Analysis "Not Applicable" Files**:

For platforms with `analysis_mode == "partial"` (backend/cli), create minimal files for `ui-copy.md` and `samples.md`:

```yaml
---
findings_summary:
  informational: 1
overall_score: 10.0  # Nothing to assess
---

## Executive Summary

Platform '{platform}' does not contain UI components. Full writing system analysis is not applicable. This audit focuses on error messages only.

## Findings

### E-WRT-{PLATFORM}-001: UI Copy Analysis Not Applicable

**Severity**: Informational
**Confidence**: Confirmed (1.0)

**Description**: Platform type '{platform}' (backend/CLI) does not have UI copy. Writing system analysis is limited to error messages, validation strings, and API responses.
```

Each file MUST include:
1. Universal YAML frontmatter with `platform` field and findings_summary/overall_score
2. Executive Summary (with scope note if partial analysis)
3. Scope and Methodology (clearly state "Partial Analysis" if applicable)
4. Findings with evidence blocks (using E-WRT-{PLATFORM}-NNN or E-WRT-NNN IDs)
5. Recommendations

---

## Step 10: Capture Feedback

> "Any feedback on the writing system detection? [y/n]"

If yes:
- Run `/jaan-to:learn-add detect-writing "{feedback}"`

---

## Definition of Done

- [ ] All 6 output files written to `$JAAN_OUTPUTS_DIR/detect/writing/`
- [ ] Universal YAML frontmatter with `platform` field in every file
- [ ] Every finding has evidence block with correct ID format (E-WRT-NNN for single-platform, E-WRT-{PLATFORM}-NNN for multi-platform)
- [ ] NNg tone dimensions scored with consistency analysis (note scope if partial)
- [ ] UI copy classified into 8 categories (or "Not Applicable" if partial analysis)
- [ ] Error messages scored with weighted rubric (always included)
- [ ] i18n maturity rated 0-5 with evidence (scoped to error messages if partial)
- [ ] Glossary uses ISO-704 statuses (error terminology if partial)
- [ ] Output filenames match platform suffix convention (no suffix for single-platform, -{platform} suffix for multi-platform)
- [ ] If partial analysis mode (backend/cli), minimal "Not Applicable" files created for ui-copy.md and samples.md
- [ ] User approved output
- [ ] Confidence scores assigned to all findings
- [ ] User approved output
