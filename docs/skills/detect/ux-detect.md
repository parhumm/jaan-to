---
title: "ux-detect"
sidebar_position: 5
doc_type: skill
tags: [detect, ux, journeys, heuristics, accessibility, pain-points]
related: [ux-heuristic-review, ux-journey-map, knowledge-pack]
---

# /jaan-to:ux-detect

> Repo-driven UX audit with journey mapping and heuristic-based findings.

---

## What It Does

Performs a UX audit by mapping journeys from actual routes, screens, and state components. Identifies pain points, heuristic issues, and accessibility gaps — all aligned to the same evidence/confidence system as other detect audits.

---

## Usage

```
/jaan-to:ux-detect
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/ux/personas.md` | Inferred personas from UI signals |
| `docs/current/ux/jtbd.md` | Jobs-to-be-done from feature surfaces |
| `docs/current/ux/flows.md` | User flows from routes/navigation |
| `docs/current/ux/pain-points.md` | Identified UX pain points |
| `docs/current/ux/heuristics.md` | Heuristic evaluation findings |
| `docs/current/ux/accessibility.md` | A11y findings within repo scope |
| `docs/current/ux/gaps.md` | Missing UX coverage areas |

---

## Key Points

- Map journeys from actual routes/screens and state components; missing proof MUST become Unknown
- Heuristic findings must be triaged (no raw dumps), each with severity + confidence + evidence blocks
- Accessibility findings must stay within repo evidence scope; otherwise Uncertain/Unknown
- Consistent doc structure: Exec Summary → Scope/Methodology → Findings → Recommendations → Appendices

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
