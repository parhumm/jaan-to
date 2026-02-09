---
title: "detect-design"
sidebar_position: 2
doc_type: skill
tags: [detect, design, tokens, components, accessibility, drift]
related: [detect-dev, detect-writing, detect-pack]
updated_date: 2026-02-09
---

# /jaan-to:detect-design

> Detect real design system in code with drift findings and evidence blocks.

---

## What It Does

Scans the repository for design system signals: design tokens, component libraries, brand assets, UI patterns, accessibility, and governance. Supports **light mode** (default, 1 summary file) and **full mode** (`--full`, 6 detailed files with drift analysis).

---

## Usage

```
/jaan-to:detect-design [repo] [--full]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full analysis (6 detection steps, 6 output files). Default is light mode. |

**Light mode** (default): Scans design tokens and component library, produces 1 summary file with token inventory, component inventory, and token coverage gaps.

**Full mode** (`--full`): Runs all steps including brand assets, UI patterns, accessibility, governance, and drift detection. Produces 6 detailed output files.

---

## Output

### Light Mode (default) — 1 file
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/design/summary{suffix}.md` | Token inventory, component inventory, coverage gaps, top-5 findings |

### Full Mode (`--full`) — 6 files
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/design/brand.md` | Brand signals (colors, typography, logos, font loading) |
| `$JAAN_OUTPUTS_DIR/detect/design/tokens.md` | Design token inventory with drift findings |
| `$JAAN_OUTPUTS_DIR/detect/design/components.md` | Component inventory (primitives, layout, navigation, feedback, data display, form) |
| `$JAAN_OUTPUTS_DIR/detect/design/patterns.md` | UI patterns, spacing scales, dark mode, theme switching |
| `$JAAN_OUTPUTS_DIR/detect/design/accessibility.md` | A11y implementation findings (ARIA, semantic HTML, a11y tests) |
| `$JAAN_OUTPUTS_DIR/detect/design/governance.md` | Design system governance (CODEOWNERS, versioning, visual regression testing) |

### Multi-Platform Monorepo
Files use platform suffix: `brand-{platform}.md`, `summary-{platform}.md`, etc.

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

## Multi-Platform Support

- **Platform detection with UI presence check**: Auto-detects platforms and checks for UI components (`.jsx`, `.tsx`, `.vue`, `.svelte`)
- **Evidence ID format**:
  - Single-platform: `E-DSN-NNN` (e.g., `E-DSN-001`)
  - Multi-platform: `E-DSN-{PLATFORM}-NNN` (e.g., `E-DSN-WEB-001`, `E-DSN-MOBILE-023`)
- **"Detect and Report N/A" pattern**: For non-UI platforms (backend, CLI), produces minimal output with informational finding ("No UI Components Detected")
- **Skip criteria**: Platforms without UI files automatically get N/A treatment with perfect score (10.0)

---

## Key Points

- **Drift detection** requires paired evidence per finding: token definition (E-DSN-001a) + conflicting usage (E-DSN-001b)
- Token categories: colors, typography, spacing, shadows, border radius, breakpoints, animation
- Component classification: primitives, layout, navigation, feedback, data display, form
- Accessibility findings scoped to repo evidence only — use "Unknown" for runtime behavior
- Governance signals: CODEOWNERS, design system changelogs, Storybook deployment, visual regression testing
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain

---

[Back to Detect Skills](docs/skills/detect/README.md) | [Back to All Skills](../README.md)
