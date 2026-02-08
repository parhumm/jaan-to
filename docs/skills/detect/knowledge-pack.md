---
title: "knowledge-pack"
sidebar_position: 6
doc_type: skill
tags: [detect, knowledge, consolidation, risk, unknowns, evidence]
related: [dev-detect, design-detect, writing-detect, product-detect, ux-detect]
---

# /jaan-to:knowledge-pack

> Consolidate all detect outputs into a scored index with risk heatmap and unknowns backlog.

---

## What It Does

Reads all detect skill outputs (`docs/current/{dev,design,writing,product,ux}/`) and consolidates them into a unified knowledge index. Enforces universal frontmatter, aggregates findings into severity buckets, builds a risk heatmap, and produces a prioritized Unknowns backlog.

---

## Usage

```
/jaan-to:knowledge-pack
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/README.md` | Knowledge index with metadata and overall score |
| `docs/current/risk-heatmap.md` | Severity buckets + risk heatmap (markdown) |
| `docs/current/unknowns-backlog.md` | Prioritized unknowns with "how to confirm" steps |
| `docs/current/source-map.md` | Evidence index: IDs → file locations |

---

## Key Points

- Enforces universal frontmatter: target commit, tool version, rules_version, confidence_scheme, findings_summary, overall_score, lifecycle_phase
- Aggregates findings into repo-wide scoreboard (severity buckets + overall score)
- Evidence Index: all evidence IDs must resolve back to file locations
- "Absence" evidence allowed but must be low confidence
- Unknowns backlog includes "how to confirm" steps and explicit scope boundaries

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
