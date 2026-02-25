---
title: "qa-quality-gate"
sidebar_position: 8
doc_type: skill
created_date: 2026-02-23
updated_date: 2026-02-23
tags: [qa, quality-gate, composite-score, review-routing, upstream-aggregation]
related: [qa-test-run, qa-test-mutate, detect-dev, sec-audit-remediate, backend-pr-review]
---

# /qa-quality-gate

> Compute composite quality score from upstream skill outputs to guide review depth.

---

## Overview

Aggregates quality signals from upstream skills (test results, audit findings, security scans, PR reviews, mutation scores) into a single composite score with a routing recommendation. Does NOT scan the repo directly -- reads only from existing skill output files. Handles missing signals with proportional weight redistribution. The final decision is always human -- the gate recommends but never auto-approves.

---

## Usage

```
/qa-quality-gate path/to/qa-test-run-output path/to/detect-dev-output
/qa-quality-gate path/to/test-run path/to/detect-dev path/to/sec-audit path/to/qa-test-mutate
```

| Argument | Required | Description |
|----------|----------|-------------|
| upstream paths | Yes (1-4) | Paths to outputs from qa-test-run, detect-dev, sec-audit-remediate, backend-pr-review, qa-test-mutate |

At least 1 upstream output path is required.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/qa/quality-gate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Quality gate report with composite score, signal breakdown, and routing recommendation |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Upstream paths | Not provided | Need at least 1 skill output to score |
| Weight overrides | User requests | Adjust signal weights for project context |
| Accept/Override | Always | Final human decision on routing recommendation |

---

## Quality Signals (6 Total)

| Signal | Source Skill | Default Weight |
|--------|-------------|---------------|
| Static analysis | detect-dev | 0.20 |
| Test pass rate + coverage | qa-test-run | 0.25 |
| Mutation score | qa-test-mutate | 0.15 |
| Security scan | sec-audit-remediate | 0.20 |
| Code complexity | detect-dev | 0.10 |
| Diff size/scope | backend-pr-review | 0.10 |

Weights are configurable in `jaan-to/config/settings.yaml` under `qa_quality_gate.weights`.

---

## Null Signal Handling

When a signal is `null` (upstream output not provided), its weight is redistributed proportionally across remaining non-null signals so weights always sum to 1.0.

Example: If mutation score (0.15 weight) is null, remaining weights are scaled by `1 / 0.85`.

---

## Routing Recommendations

| Score Range | Recommendation |
|-------------|---------------|
| > 0.85 | Auto-approve -- all quality signals strong. Lightweight review sufficient. |
| 0.60 - 0.85 | Lightweight review -- AI-annotated concerns attached. Focus on flagged areas. |
| < 0.60 | Full human review -- significant quality signals flagged. Comprehensive review needed. |

---

## Example

**Input:**
```
/qa-quality-gate outputs/qa/test-run/01-auth/ outputs/detect/dev/01-audit/
```

**Output:**
```
jaan-to/outputs/qa/quality-gate/01-auth-gate/
└── 01-auth-gate.md
```

**Report summary:**
```
Composite Score: 0.78 (based on 4/6 signals)

Signal Breakdown:
  Static Analysis (0.20):      0.85 -> weighted 0.200
  Test Pass + Coverage (0.25): 0.92 -> weighted 0.271
  Mutation Score (0.15):       null (excluded)
  Security Scan (0.20):        0.70 -> weighted 0.165
  Code Complexity (0.10):      0.65 -> weighted 0.076
  Diff Size (0.10):            null (excluded)

Recommendation: Lightweight review
```

---

## Tips

- Provide more upstream outputs for a higher-confidence score
- Null signals are handled gracefully -- start with what you have
- Override the recommendation if project context warrants different review depth
- Configure weights in settings.yaml to match your team's quality priorities

---

## Related Skills

- [/qa-test-run](test-run.md) - Test execution results (primary input)
- [/qa-test-mutate](test-mutate.md) - Mutation score signal
- [/detect-dev](../detect/detect-dev.md) - Engineering audit signal
- [/sec-audit-remediate](../sec/audit-remediate.md) - Security scan signal

---

## Technical Details

- **Logical Name**: qa-quality-gate
- **Command**: `/qa-quality-gate`
- **Role**: qa
- **Output**: `$JAAN_OUTPUTS_DIR/qa/quality-gate/{id}-{slug}/`
- **Note**: Reads upstream outputs only -- does NOT scan the repository directly
