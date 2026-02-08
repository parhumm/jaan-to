---
name: detect-design
description: Design system detection with drift findings and evidence blocks.
allowed-tools: Read, Glob, Grep, Write(docs/current/design/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [repo]
---

# detect-design

> Detect real design system in code with drift findings and evidence blocks.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:detect-design.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (if exists, for framework-aware scanning)
- `$JAAN_TEMPLATES_DIR/jaan-to:detect-design.template.md` - Output template

**Output path exception**: This skill writes to `docs/current/design/` in the target project, NOT to `$JAAN_OUTPUTS_DIR`. Detect outputs are living project documentation (overwritten each run), not versioned artifacts.

## Input

**Repository**: $ARGUMENTS

If a repository path is provided, scan that repo. Otherwise, scan the current working directory.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:detect-design.learn.md`

If the file exists, apply its lessons throughout this execution.

If the file does not exist, continue without it.

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_detect-design` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, evidence blocks.

---

## Standards Reference

### Evidence Format (SARIF-compatible)

Every finding MUST include structured evidence blocks:

```yaml
evidence:
  id: E-DSN-001
  type: code-location
  confidence: 0.95
  location:
    uri: "src/tokens/colors.json"
    startLine: 15
    endLine: 20
    snippet: |
      "primary": "#3B82F6"
  method: pattern-match
```

Evidence IDs use namespace `E-DSN-NNN` to prevent collisions in pack-detect.

### Drift Detection — Paired Evidence

"Drift" findings REQUIRE two evidence items showing the conflict:

```yaml
evidence:
  - id: E-DSN-001a
    type: token-definition
    confidence: 0.95
    location:
      uri: "src/tokens/colors.json"
      startLine: 15
    snippet: |
      "primary": "#3B82F6"
  - id: E-DSN-001b
    type: conflicting-usage
    confidence: 0.90
    location:
      uri: "src/components/Button.tsx"
      startLine: 42
    snippet: |
      color: "#2563EB"  // hardcoded, differs from token
```

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
  name: "detect-design"
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

### Document Structure (Diataxis)

1. Executive Summary
2. Scope and Methodology
3. Findings (ID/severity/confidence/evidence)
4. Recommendations
5. Appendices

---

# PHASE 1: Detection (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Identifying design token hierarchies and naming conventions
- Detecting drift between definitions and usage
- Mapping component library patterns
- Accessibility scope assessment

## Step 1: Scan Design Tokens

### Token Definition Files
- Glob: `**/tokens/**/*.{json,js,ts}` — design token packages
- Glob: `**/*.tokens.json` — token files by convention
- Glob: `tailwind.config.*` — Tailwind theme tokens
- Glob: `**/theme.{js,ts,json}`, `**/theme/**` — theme definitions

### CSS Variables
- Grep in `**/*.{css,scss,less}` for `--` prefixed custom properties
- Extract variable names, values, and categorize (color, spacing, typography, etc.)
- Detect naming conventions (BEM, kebab-case, camelCase)

### Token Categories
Map discovered tokens to categories:
- **Colors**: brand, semantic (success/warning/error/info), neutral/gray scales
- **Typography**: font families, sizes, weights, line heights
- **Spacing**: margins, paddings, gaps (detect scale: 4px/8px base)
- **Shadows**: elevation levels
- **Border radius**: shape tokens
- **Breakpoints**: responsive breakpoints
- **Animation**: timing, easing, duration tokens

## Step 2: Scan Component Library

### Component Files
- Glob: `**/components/**/*.{tsx,jsx,vue,svelte}` — component source
- Glob: `**/*.stories.{tsx,jsx,ts,js,mdx}` — Storybook stories
- Glob: `.storybook/**` — Storybook configuration

### Component Inventory
For each component directory, extract:
- Component name and file path
- Props interface (TypeScript types or PropTypes)
- Variant patterns (size, color, state)
- Composition patterns (compound components, slots)

### Component Categories
Classify components:
- **Primitives**: Button, Input, Text, Icon, Image
- **Layout**: Container, Grid, Stack, Flex, Spacer
- **Navigation**: Nav, Menu, Breadcrumb, Tabs, Pagination
- **Feedback**: Alert, Toast, Modal, Dialog, Progress
- **Data display**: Table, Card, List, Badge, Avatar
- **Form**: Select, Checkbox, Radio, Switch, DatePicker

## Step 3: Scan Brand Assets

- Glob: `**/assets/brand/**` — brand directory
- Glob: `**/assets/logo*`, `**/assets/icons/**` — logo and icon assets
- Glob: `**/fonts/**`, `**/*.woff2`, `**/*.ttf` — font files
- Detect font loading strategy (preload, font-display)
- Check for favicon and app icons

## Step 4: Scan UI Patterns

- Grep for layout patterns: grid systems, responsive utilities
- Detect spacing scale usage consistency
- Scan for color usage patterns outside token definitions
- Check for hardcoded values vs token references (drift signals)
- Detect dark mode / theme switching patterns (`prefers-color-scheme`, theme context)

## Step 5: Scan Accessibility Signals

**Scope**: Repo-level only. Cannot make claims about runtime behavior.

- Grep for ARIA attributes: `aria-label`, `aria-describedby`, `aria-live`, `role=`
- Check for semantic HTML usage: `<main>`, `<nav>`, `<article>`, `<section>`, `<header>`, `<footer>`
- Glob: `**/*.test.{ts,tsx,js,jsx}` and grep for a11y test patterns: `axe`, `jest-axe`, `@testing-library`, `getByRole`
- Check for skip links, focus management patterns
- Detect `alt` attribute usage on images

**Important**: Mark findings as "Unknown" when repo evidence is insufficient for runtime behavior claims.

## Step 6: Scan Governance Signals

- Glob: `CODEOWNERS` — check for design system file ownership
- Look for design system changelogs or versioning
- Detect Storybook configuration and deployment
- Check for visual regression testing (chromatic, percy, backstop)
- Look for design system documentation conventions
- Check for token versioning or release process

## Step 7: Detect Drift

For every token/variable definition found in Step 1, scan component files for:
- Hardcoded values that should reference tokens
- Inconsistent token usage (same semantic meaning, different tokens)
- Orphaned tokens (defined but never used)
- Undocumented overrides

Each drift finding MUST have paired evidence (definition + conflicting usage).

---

# HARD STOP — Detection Summary & User Approval

## Step 8: Present Detection Summary

```
DESIGN SYSTEM DETECTION COMPLETE
---------------------------------

TOKEN INVENTORY
  Colors:      {n} tokens found    [Confidence: {level}]
  Typography:  {n} tokens found    [Confidence: {level}]
  Spacing:     {n} tokens found    [Confidence: {level}]
  Other:       {n} tokens found    [Confidence: {level}]

COMPONENTS: {n} components detected across {n} categories
DRIFT FINDINGS: {n} drift issues found
ACCESSIBILITY: {n} a11y findings

SEVERITY SUMMARY
  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}  |  Info: {n}

OVERALL SCORE: {score}/10

OUTPUT FILES (6):
  docs/current/design/brand.md          - Brand signals
  docs/current/design/tokens.md         - Design token inventory
  docs/current/design/components.md     - Component inventory
  docs/current/design/patterns.md       - UI patterns and conventions
  docs/current/design/accessibility.md  - A11y findings
  docs/current/design/governance.md     - Governance signals
```

> "Proceed with writing 6 output files to docs/current/design/? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Write Output Files

## Step 9: Write to docs/current/design/

Create directory `docs/current/design/` if it does not exist.

Write 6 output files using the template:

| File | Content |
|------|---------|
| `docs/current/design/brand.md` | Brand signals (colors, typography, logos) |
| `docs/current/design/tokens.md` | Design token definitions and usage with drift findings |
| `docs/current/design/components.md` | Component inventory and patterns |
| `docs/current/design/patterns.md` | UI patterns and conventions |
| `docs/current/design/accessibility.md` | A11y implementation findings (scoped to repo evidence) |
| `docs/current/design/governance.md` | Design system governance signals |

Each file MUST include:
1. Universal YAML frontmatter
2. Executive Summary
3. Scope and Methodology
4. Findings with evidence blocks (using E-DSN-NNN IDs)
5. Recommendations

---

## Step 10: Capture Feedback

> "Any feedback on the design system detection? [y/n]"

If yes:
- Run `/jaan-to:learn-add detect-design "{feedback}"`

---

## Definition of Done

- [ ] All 6 output files written to `docs/current/design/`
- [ ] Universal YAML frontmatter in every file
- [ ] Every finding has evidence block with E-DSN-NNN ID
- [ ] Drift findings have paired evidence (definition + conflicting usage)
- [ ] Accessibility findings scoped to repo evidence (no runtime claims)
- [ ] Confidence scores assigned to all findings
- [ ] Overall score calculated
- [ ] User approved output
