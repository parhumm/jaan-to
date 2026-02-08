---
title: "detect-product"
sidebar_position: 4
doc_type: skill
tags: [detect, product, features, monetization, instrumentation]
related: [pm-prd-write, pack-detect]
---

# /jaan-to:detect-product

> Evidence-based product reality extraction with scored risks.

---

## What It Does

Extracts the "product reality" from the repository: features, value proposition signals, monetization/entitlements, instrumentation coverage, and constraints. Every claim requires evidence linking to surface, copy, and code path.

---

## Usage

```
/jaan-to:detect-product
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/product/overview.md` | Product overview and identity signals |
| `docs/current/product/features.md` | Feature inventory with evidence |
| `docs/current/product/value-prop.md` | Value proposition signals |
| `docs/current/product/monetization.md` | Pricing copy vs enforcement evidence |
| `docs/current/product/entitlements.md` | Access gates and tier evidence |
| `docs/current/product/metrics.md` | Instrumentation and analytics reality |
| `docs/current/product/constraints.md` | Technical and business constraints |

---

## Key Points

- "Feature exists" requires evidence linking to surface + copy + code path; otherwise Inferred/Unknown
- Monetization: distinguish "pricing copy" vs "enforcement" — gates must be proven by code locations
- Absence of evidence becomes an "absence" evidence item
- Instrumentation: report taxonomy/consistency signals; heuristic conclusions labeled Tentative
- Same standardized frontmatter + Findings block format as all detect audits

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
