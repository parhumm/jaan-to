---
title: "detect-design"
sidebar_position: 2
doc_type: skill
tags: [detect, design, tokens, components, accessibility, drift]
related: [detect-dev, detect-writing, detect-pack]
updated_date: 2026-02-08
---

# /jaan-to:detect-design

> Detect real design system in code with drift findings and evidence blocks.

---

## What It Does

Scans the repository for design system signals: brand definitions, design tokens (JSON, CSS variables, Tailwind config), component libraries, UI patterns, accessibility implementation, and governance processes. Identifies drift between token definitions and actual usage with paired evidence.

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
| `$JAAN_OUTPUTS_DIR/detect/design/brand.md` | Brand signals (colors, typography, logos, font loading) |
| `$JAAN_OUTPUTS_DIR/detect/design/tokens.md` | Design token inventory with drift findings |
| `$JAAN_OUTPUTS_DIR/detect/design/components.md` | Component inventory (primitives, layout, navigation, feedback, data display, form) |
| `$JAAN_OUTPUTS_DIR/detect/design/patterns.md` | UI patterns, spacing scales, dark mode, theme switching |
| `$JAAN_OUTPUTS_DIR/detect/design/accessibility.md` | A11y implementation findings (ARIA, semantic HTML, a11y tests) |
| `$JAAN_OUTPUTS_DIR/detect/design/governance.md` | Design system governance (CODEOWNERS, versioning, visual regression testing) |

---

## What It Scans

| Category | Patterns |
|----------|---------|
| Tokens | `**/tokens/**/*.{json,js,ts}`, `tailwind.config.*`, `**/theme.{js,ts,json}`, `**/*.tokens.json` |
| CSS variables | `**/*.{css,scss,less}` with `--` prefix |
| Components | `**/components/**/*.{tsx,jsx,vue,svelte}` |
| Storybook | `.storybook/**`, `**/*.stories.{tsx,jsx,ts,js,mdx}` |
| Brand assets | `**/assets/brand/**`, font configs, logo assets |
| Governance | `CODEOWNERS`, changelogs, Chromatic/Percy/Backstop configs |

---

## Key Points

- Evidence IDs use namespace `E-DSN-NNN` (prevents collisions in detect-pack aggregation)
- **Drift detection** requires paired evidence per finding: token definition (E-DSN-001a) + conflicting usage (E-DSN-001b)
- Token categories: colors, typography, spacing, shadows, border radius, breakpoints, animation
- Component classification: primitives, layout, navigation, feedback, data display, form
- Accessibility findings scoped to repo evidence only — use "Unknown" for runtime behavior
- Governance signals: CODEOWNERS, design system changelogs, Storybook deployment, visual regression testing
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
