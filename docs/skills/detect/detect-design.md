---
title: "detect-design"
sidebar_position: 2
doc_type: skill
tags: [detect, design, tokens, components, accessibility, drift]
related: [pack-detect]
---

# /jaan-to:detect-design

> Detect real design system in code with drift findings and evidence blocks.

---

## What It Does

Scans the repository for design system signals: brand definitions, design tokens, component libraries, UI patterns, accessibility implementation, and governance processes. Identifies drift between token definitions and actual usage.

---

## Usage

```
/jaan-to:detect-design
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/design/brand.md` | Brand signals (colors, typography, logos) |
| `docs/current/design/tokens.md` | Design token definitions and usage |
| `docs/current/design/components.md` | Component inventory and patterns |
| `docs/current/design/patterns.md` | UI patterns and conventions |
| `docs/current/design/accessibility.md` | A11y implementation findings |
| `docs/current/design/governance.md` | Design system governance signals |

---

## Key Points

- Tokens/components evidence must include exact file locations
- "Drift" findings require two evidences: token definition + conflicting usage
- Each finding includes Severity, Confidence (4-level), Evidence blocks
- Accessibility findings must be scoped — use "Unknown" when repo evidence is insufficient
- Governance detection: owners/process/versioning signals (Storybook, docs conventions, token maintenance)

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
