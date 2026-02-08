---
name: detect-writing
description: Writing system extraction with NNg tone dimensions, UI copy classification, and i18n maturity scoring.
allowed-tools: Read, Glob, Grep, Write(docs/current/writing/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [repo]
---

# detect-writing

> Detect the current writing system using multi-signal extraction and output a canonical writing-system spec.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:detect-writing.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (for framework-aware i18n scanning)
- `$JAAN_TEMPLATES_DIR/jaan-to:detect-writing.template.md` - Output template

**Output path exception**: This skill writes to `docs/current/writing/` in the target project, NOT to `$JAAN_OUTPUTS_DIR`. Detect outputs are living project documentation (overwritten each run), not versioned artifacts.

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
  id: E-WRT-001
  type: code-location
  confidence: 0.85
  location:
    uri: "src/locales/en/common.json"
    startLine: 42
    snippet: |
      "deleteConfirm": "Are you sure you want to delete this?"
  method: pattern-match
```

Evidence IDs use namespace `E-WRT-NNN` to prevent collisions in pack-detect.

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

STRING CORPUS: {n} strings analyzed across {n} files
LOCALES DETECTED: {list}

TONE DIMENSIONS (NNg)
  Formality:      {score}/5    Consistency: {stddev}
  Humor:          {score}/5    Consistency: {stddev}
  Respectfulness: {score}/5    Consistency: {stddev}
  Enthusiasm:     {score}/5    Consistency: {stddev}

UI COPY COVERAGE
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
  docs/current/writing/writing-system.md  - Voice + tone + consistency
  docs/current/writing/glossary.md        - Terminology glossary
  docs/current/writing/ui-copy.md         - UI copy classification
  docs/current/writing/error-messages.md  - Error message audit
  docs/current/writing/localization.md    - i18n maturity assessment
  docs/current/writing/samples.md         - Representative samples
```

> "Proceed with writing 6 output files to docs/current/writing/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 9: Write to docs/current/writing/

Create directory `docs/current/writing/` if it does not exist.

Write 6 output files:

| File | Content |
|------|---------|
| `docs/current/writing/writing-system.md` | Voice definition, tone spectrum (NNg dimensions), consistency score |
| `docs/current/writing/glossary.md` | Terminology glossary with ISO-704 statuses |
| `docs/current/writing/ui-copy.md` | UI copy classification across 8 categories |
| `docs/current/writing/error-messages.md` | Error message quality audit with rubric scoring |
| `docs/current/writing/localization.md` | i18n maturity assessment (0-5) with evidence |
| `docs/current/writing/samples.md` | Representative string samples per category |

Each file MUST include:
1. Universal YAML frontmatter
2. Executive Summary
3. Scope and Methodology
4. Findings with evidence blocks (using E-WRT-NNN IDs)
5. Recommendations

---

## Step 10: Capture Feedback

> "Any feedback on the writing system detection? [y/n]"

If yes:
- Run `/jaan-to:learn-add detect-writing "{feedback}"`

---

## Definition of Done

- [ ] All 6 output files written to `docs/current/writing/`
- [ ] Universal YAML frontmatter in every file
- [ ] Every finding has evidence block with E-WRT-NNN ID
- [ ] NNg tone dimensions scored with consistency analysis
- [ ] UI copy classified into 8 categories
- [ ] Error messages scored with weighted rubric
- [ ] i18n maturity rated 0-5 with evidence
- [ ] Glossary uses ISO-704 statuses
- [ ] Confidence scores assigned to all findings
- [ ] User approved output
