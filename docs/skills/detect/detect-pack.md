---
title: "pack-detect"
sidebar_position: 6
doc_type: skill
tags: [detect, knowledge, consolidation, risk, unknowns, evidence]
related: [detect-dev, detect-design, detect-writing, detect-product, detect-ux]
updated_date: 2026-02-08
---

# /jaan-to:pack-detect

> Consolidate all detect outputs into unified index with risk heatmap and unknowns backlog.

---

## What It Does

Reads all detect skill outputs (`docs/current/{dev,design,writing,product,ux}/`) and consolidates them into a unified knowledge index. Does NOT scan the repository directly — only reads and aggregates outputs from the 5 detect skills. Enforces universal frontmatter, aggregates findings into severity buckets, builds a domain x severity risk heatmap, validates all evidence IDs, and produces a prioritized Unknowns backlog.

---

## Usage

```
/jaan-to:pack-detect
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/README.md` | Knowledge index: metadata, domain summaries, overall score, links to all detect outputs |
| `docs/current/risk-heatmap.md` | Risk heatmap table (domain x severity), top risks per domain |
| `docs/current/unknowns-backlog.md` | Prioritized unknowns with "how to confirm" steps and scope boundaries |
| `docs/current/source-map.md` | Evidence index: all E-IDs mapped to file locations |

---

## Orchestration (Step 0)

Before consolidation, checks which detect skills have run:

- **No outputs found**: Lists all 5 detect skills and suggests running them first
- **Partial outputs**: Reports which domains are present/missing, asks user to continue (results marked as partial)
- **All outputs found**: Proceeds directly to consolidation

---

## Key Points

- Enforces universal frontmatter: `target.commit` (must match git HEAD), `tool.rules_version`, `confidence_scheme`, `findings_summary`, `overall_score`, `lifecycle_phase` (CycloneDX)
- **Overall score formula**: `10 - (critical×2.0 + high×1.0 + medium×0.4 + low×0.1) / max(total_findings, 1)`, clamped 0–10
- **Risk heatmap**: domain × severity markdown table with per-domain scores; missing domains shown as "not analyzed"
- **Evidence ID validation**: all IDs must follow namespace convention (E-DEV, E-DSN, E-WRT, E-PRD, E-UX), no duplicates, all resolve to file locations
- **Partial run handling**: coverage % reported ("3/5 domains analyzed"), overall score labeled with "(partial)" suffix
- Unknowns backlog collects all findings with confidence ≤ Tentative + "how to confirm" steps
- Frontmatter validation failures become findings (severity: Medium, confidence: Confirmed)

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
