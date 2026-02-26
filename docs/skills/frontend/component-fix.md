---
title: "frontend-component-fix"
sidebar_position: 7
doc_type: skill
created_date: 2026-02-26
updated_date: 2026-02-26
tags: [dev, frontend, bugfix, components, patches, accessibility]
related: [frontend-visual-verify, frontend-design, dev-output-integrate]
---

# /frontend-component-fix

> Diagnose and fix UI bugs by generating patch artifacts routed through dev-output-integrate.

---

## Overview

Diagnoses UI bugs and generates patch files as output artifacts. Never edits project source directly — patches are applied through `/dev-output-integrate` which has proper edit permissions and conflict detection. Offers a guided single-run mode that chains fix, integrate, and verify in one approval.

---

## Usage

```
/frontend-component-fix "Button hover state not showing on mobile"
/frontend-component-fix "Card layout breaks at 768px" --component src/components/Card.tsx
/frontend-component-fix "Color contrast fails WCAG" --screenshot /tmp/screenshot.png
```

| Argument | Required | Description |
|----------|----------|-------------|
| bug-description | Yes | Description of the UI bug |
| --component | No | Path to the component with the bug |
| --screenshot | No | Path to a screenshot showing the issue |

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/frontend/component-fix/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Fix report with diagnosis, before/after diff, rationale |
| `{id}-{slug}-patch-{component}.tsx` | Patched component files |
| `{id}-{slug}-readme.md` | Integration instructions for dev-output-integrate |

---

## Safety Model

This skill is **output-only** — it generates patches under `$JAAN_OUTPUTS_DIR` and never writes to `src/`, `lib/`, or `app/` directories.

Patches are applied through `/dev-output-integrate` which:
- Has proper `Edit(src/**)` permissions
- Performs conflict detection
- Shows before/after diffs for review

---

## Guided Single-Run Mode

After generating patches, the skill offers a streamlined next-actions flow:

| Option | What Happens |
|--------|-------------|
| **Integrate + Verify** | Runs `/dev-output-integrate` with prefilled paths, then `/frontend-visual-verify` |
| **Integrate only** | Runs `/dev-output-integrate` with prefilled paths |
| **Save patches only** | Done — user integrates manually later |

This collapses the 3-skill chain into a single approval.

---

## Key Features

- **Root cause analysis** — Reads full component tree, not just the reported component
- **Minimal patches** — Changes only what's needed to fix the bug; no refactoring
- **Before/after diff** — Every fix includes a clear diff showing what changed and why
- **MCP integration** — Optionally uses Playwright for before screenshots and Storybook for component docs
- **Preserves API** — Never changes props interface in a fix
- **Contract alignment** — When fixing data shape issues, checks against the API contract to determine if the component or the spec needs updating

---

## Workflow Chain

```
(bug report) → /frontend-component-fix → /dev-output-integrate → /frontend-visual-verify
```

- **frontend-component-fix** generates safe patch artifacts
- **dev-output-integrate** applies patches to source with conflict detection
- **frontend-visual-verify** confirms the fix renders correctly

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `/frontend-visual-verify` | Upstream (finds bugs) and downstream (confirms fix) |
| `/dev-output-integrate` | Downstream — applies generated patches to source |
| `/frontend-design` | Complementary — designs components; this skill fixes them |
| `/frontend-story-generate` | Complementary — updated stories may be needed after fix |

---

[Back to Frontend Skills](README.md) | [Back to All Skills](../README.md)
