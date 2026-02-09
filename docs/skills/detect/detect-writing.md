---
title: "detect-writing"
sidebar_position: 3
doc_type: skill
tags: [detect, writing, tone, glossary, i18n, microcopy]
related: [detect-dev, detect-design, detect-product, detect-ux, detect-pack]
updated_date: 2026-02-09
---

# /jaan-to:detect-writing

> Writing system extraction with NNg tone dimensions, UI copy classification, and i18n maturity scoring.

---

## What It Does

Extracts the writing system from the repository with string discovery, classification, and heuristic scoring. Supports **light mode** (default, 1 summary file) and **full mode** (`--full`, 6 detailed files with NNg tone scoring, glossary, and governance).

---

## Usage

```
/jaan-to:detect-writing [repo] [--full]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full analysis (6 detection steps, 6 output files). Default is light mode. |

**Light mode** (default): Scans string inventory and i18n maturity, produces 1 summary file. Backend/CLI platforms also include error message quality scores (partial-mode exception).

**Full mode** (`--full`): Runs all steps including NNg tone dimensions, UI copy classification, glossary, and governance. Produces 6 detailed output files.

---

## Output

### Light Mode (default) — 1 file
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/writing/summary{suffix}.md` | String corpus overview, i18n maturity, top-5 findings (+ error scores for backend/CLI) |

### Full Mode (`--full`) — 6 files
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/writing/writing-system.md` | Voice definition, tone spectrum (NNg dimensions), consistency score |
| `$JAAN_OUTPUTS_DIR/detect/writing/glossary.md` | Terminology glossary with ISO-704-ish statuses (preferred/admitted/deprecated/forbidden) |
| `$JAAN_OUTPUTS_DIR/detect/writing/ui-copy.md` | UI string classification across 8 categories with component-name patterns |
| `$JAAN_OUTPUTS_DIR/detect/writing/error-messages.md` | Error message quality audit with 5-dimension weighted rubric |
| `$JAAN_OUTPUTS_DIR/detect/writing/localization.md` | i18n maturity assessment (0–5) with evidence |
| `$JAAN_OUTPUTS_DIR/detect/writing/samples.md` | Representative copy samples per category |

### Multi-Platform Monorepo
Files use platform suffix: `writing-system-{platform}.md`, `summary-{platform}.md`, etc.

---

## What It Scans

| Category | Patterns |
|----------|---------|
| i18n locale files | React i18next, Vue i18n, Angular, Next.js, Flutter/Dart, Android, iOS/macOS, Rails, Django, Java, .NET, PHP/Laravel, GNU gettext (13 framework-specific glob sets) |
| Component inline text | JSX/TSX inline text, component props (`label`, `title`, `message`, `placeholder`, `helperText`, `errorMessage`) |
| UI copy components | `*Button*`, `*Error*`, `*EmptyState*`, `*Dialog*`, `*Toast*`, `*Onboarding*`, `*FormField*`, `*Loading*` + variants |
| ICU MessageFormat | Plural, select, and format patterns in locale files |
| RTL support | `dir="rtl"`, CSS logical properties, RTL locale codes (ar, he, fa, ur, ps) |
| Content governance | `CODEOWNERS`, content linting tools (`alex`, `write-good`, `vale`, `cspell`, `textlint`), CI translation checks |

---

## Multi-Platform Support

- **Platform auto-detection**: Detects web/, backend/, mobile/, etc. from folder structure
- **Evidence ID format**:
  - Single-platform: `E-WRT-NNN` (e.g., `E-WRT-001`)
  - Multi-platform: `E-WRT-{PLATFORM}-NNN` (e.g., `E-WRT-WEB-001`, `E-WRT-BACKEND-023`)
- **Partial analysis mode**: Backend/CLI platforms analyze error messages only (skips UI copy, onboarding, CTA)
- **Cross-platform consistency**: Tone dimension scoring compares across platforms for brand consistency

---

## Key Points

- **NNg tone dimensions**: 4 primary (Formality/Humor/Respectfulness/Enthusiasm 1–5) + 5 extended (Technical complexity/Verbosity/Directness/Empathy/Confidence)
- **Consistency score**: Standard deviation per dimension across all strings; flag >1.5σ outliers
- UI copy classified into 8 categories: Buttons, Errors, Empty states, Confirm dialogs, Toasts, Onboarding, Form labels/helper, Loading
- **Error message rubric**: Clarity (25%) / Specificity (20%) / Actionability (25%) / Tone (15%) / A11y (15%)
- **Automated heuristic flags**: Flesch-Kincaid >8, sentences >25 words, messages >40 words, passive >10%, blame language, visible error codes, missing action verbs
- **i18n maturity** rated 0–5: None → Basic → Partial → Functional → Mature → Excellence; centralization scoring (+1/−1 signals, cap at Level 1 if ≤−2)
- Glossary uses ISO-704-ish methodology with TF-IDF/C-value term extraction
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
