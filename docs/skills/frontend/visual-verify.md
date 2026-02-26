---
title: "frontend-visual-verify"
sidebar_position: 6
doc_type: skill
created_date: 2026-02-26
updated_date: 2026-02-26
tags: [dev, frontend, visual, verification, playwright, storybook, accessibility]
related: [frontend-story-generate, frontend-component-fix, frontend-design]
---

# /frontend-visual-verify

> Visual verification of UI components via Storybook snapshots and Playwright MCP.

---

## Overview

Verifies that components render correctly by analyzing accessibility trees and capturing screenshots. Operates in two modes depending on Playwright MCP availability: full visual verification or code-review-only analysis.

---

## Usage

```
/frontend-visual-verify "http://localhost:6006/?path=/story/button--default"
/frontend-visual-verify "src/components/Button.tsx"
/frontend-visual-verify "jaan-to/outputs/frontend/design/01-hero/"
```

| Argument | Required | Description |
|----------|----------|-------------|
| target | No | Storybook URL (localhost), component path, or frontend-design output |

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/frontend/visual-verify/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Verification report with scoring and findings |
| `{id}-{slug}-screenshots/` | Captured screenshots (visual-mode only) |
| `{id}-{slug}-readme.md` | Summary with pass/fail status |

---

## Output Modes

| Mode | Condition | Visual Score | Can Conclude Pass/Fail? |
|------|-----------|-------------|------------------------|
| **visual-mode** | Playwright MCP available | 0-10 scale | Yes |
| **static-mode** | No Playwright MCP | N/A | No — code analysis only |

In static-mode, the report header states: "Static analysis only — visual verification requires Playwright MCP."

---

## Key Features

- **Accessibility tree analysis** — Uses `browser_snapshot` (structured, deterministic) as the primary verification tool
- **Screenshot capture** — `browser_take_screenshot` for visual evidence (secondary to accessibility tree)
- **Localhost-only default** — Only navigates to `localhost:*` and `127.0.0.1:*`; external URLs require per-URL user confirmation
- **Visual scoring rubric** — 6 categories: layout, typography, color, spacing, responsiveness, accessibility
- **Honest static-mode** — Never claims visual pass/fail without Playwright
- **API dependency note** — Flags components with API dependencies that may need MSW handlers for proper Storybook rendering

---

## Network Security

Default: **localhost-only**. The skill will not navigate to external domains without explicit user confirmation.

Playwright MCP config recommendation:
```json
{
  "network": {
    "allowedOrigins": ["http://localhost:*", "http://127.0.0.1:*"]
  }
}
```

---

## Workflow Chain

```
/frontend-story-generate → /frontend-visual-verify → /frontend-component-fix (if issues found)
```

- **frontend-story-generate** creates stories to verify
- **frontend-visual-verify** checks rendering
- **frontend-component-fix** fixes any issues found

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `/frontend-story-generate` | Upstream — generates stories to verify |
| `/frontend-component-fix` | Downstream — fixes issues found during verification |
| `/frontend-design` | Upstream — produces components to verify |
| `/dev-verify` | Complementary — verifies build pipeline; this skill verifies visual output |

---

[Back to Frontend Skills](README.md) | [Back to All Skills](../README.md)
