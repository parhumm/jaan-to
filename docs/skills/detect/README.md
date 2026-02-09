---
title: "Detect & Knowledge"
sidebar_position: 7
slug: /skills/detect
updated_date: 2026-02-08
---

# Detect Skills

> Evidence-based repo audits with confidence-scored findings.

---

## Pipeline

Run individual detect skills for specific domains, or run all 5 then consolidate:

```
/jaan-to:detect-dev        → $JAAN_OUTPUTS_DIR/detect/dev/
/jaan-to:detect-design     → $JAAN_OUTPUTS_DIR/detect/design/
/jaan-to:detect-writing    → $JAAN_OUTPUTS_DIR/detect/writing/
/jaan-to:detect-product    → $JAAN_OUTPUTS_DIR/detect/product/
/jaan-to:detect-ux         → $JAAN_OUTPUTS_DIR/detect/ux/
                                    ↓
/jaan-to:pack-detect       → $JAAN_OUTPUTS_DIR/detect/{README,risk-heatmap,unknowns-backlog,source-map}.md
```

---

## Available Skills

| Skill | Description | Output Files |
|-------|-------------|-------------|
| [/jaan-to:detect-dev](detect-dev.md) | Engineering audit with OpenSSF-style scoring | 9 files |
| [/jaan-to:detect-design](detect-design.md) | Design system detection with drift findings | 6 files |
| [/jaan-to:detect-writing](detect-writing.md) | Writing system extraction with NNg tone scoring | 6 files |
| [/jaan-to:detect-product](detect-product.md) | Product reality extraction with 3-layer evidence | 7 files |
| [/jaan-to:detect-ux](detect-ux.md) | UX audit with Nielsen heuristics and journey mapping | 7 files |
| [/jaan-to:pack-detect](detect-pack.md) | Consolidate all detect outputs into scored index | 4 files |

---

## Shared Standards

All detect skills share:

- **Evidence format**: SARIF-compatible blocks with id, type, confidence, location (uri, startLine, snippet), method
- **Evidence ID namespaces**: `E-DEV-NNN`, `E-DSN-NNN`, `E-WRT-NNN`, `E-PRD-NNN`, `E-UX-NNN` (prevents collisions in pack-detect)
- **4-level confidence**: Confirmed (0.95–1.00) / Firm (0.80–0.94) / Tentative (0.50–0.79) / Uncertain (0.20–0.49)
- **Universal frontmatter**: title, id, version, status, target.commit, tool metadata, confidence_scheme, findings_summary, overall_score (0–10), lifecycle_phase
- **Document structure** (Diataxis): Executive Summary → Scope/Methodology → Findings → Recommendations → Appendices
- **Output path**: `$JAAN_OUTPUTS_DIR/detect/{domain}/` — flat files, overwritten each run (no IDs)

---

## Reference

- [Repo-analysis output & content detection standards](../../../jaan-to/outputs/research/61-detect-pack.md)

---

[Back to Skills](../README.md)
