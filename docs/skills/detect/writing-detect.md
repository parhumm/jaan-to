---
title: "writing-detect"
sidebar_position: 3
doc_type: skill
tags: [detect, writing, tone, glossary, i18n, microcopy]
related: [ux-microcopy-write, knowledge-pack]
---

# /jaan-to:writing-detect

> Detect the current writing system with multi-signal extraction and tone scoring.

---

## What It Does

Extracts the writing system from the repository using glob discovery, string classification, and heuristic/NLP scoring. Produces a canonical writing-system spec covering voice, tone, glossary, UI copy patterns, and i18n maturity.

---

## Usage

```
/jaan-to:writing-detect
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/writing/writing-system.md` | Primary writing system spec (voice, tone, glossary, patterns) |
| `docs/current/writing/glossary.md` | Term inventory with ISO-704-ish statuses |
| `docs/current/writing/ui-copy.md` | UI string classification across 8 categories |
| `docs/current/writing/error-messages.md` | Error message quality scoring |
| `docs/current/writing/localization.md` | i18n maturity assessment (0–5) |
| `docs/current/writing/samples.md` | Representative copy samples |

Primary output is `writing-system.md`; others are optional splits.

---

## Key Points

- Canonical structure: Voice definition → Tone spectrum → Glossary → UI copy patterns → Plain language → i18n maturity → Recommendations
- NNg tone dimensions: Formality / Humor / Respectfulness / Enthusiasm + consistency score
- UI copy classified into 8 categories: Buttons, Errors, Empty states, Confirm dialogs, Toasts, Onboarding, Labels/helper, Loading
- Error messages scored with weighted rubric: Clarity / Specificity / Actionability / Tone / A11y
- i18n maturity rated 0–5 using glob patterns + ICU/RTL/hardcoded-string signals + governance signals
- Glossary uses ISO-704-ish statuses: preferred / admitted / deprecated / forbidden

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
