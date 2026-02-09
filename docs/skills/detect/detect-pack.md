---
title: "detect-pack"
sidebar_position: 6
doc_type: skill
tags: [detect, knowledge, consolidation, risk, unknowns, evidence]
related: [detect-dev, detect-design, detect-writing, detect-product, detect-ux]
updated_date: 2026-02-09
---

# /jaan-to:detect-pack

> Consolidate all detect outputs into unified index with risk heatmap and unknowns backlog.

---

## What It Does

Reads all detect skill outputs and consolidates them into a unified knowledge index. Supports **light mode** (default, 1 summary file) and **full mode** (`--full`, 4+ detailed files with evidence index and unknowns backlog). Automatically detects whether each domain provided light-mode (summary) or full-mode (individual files) outputs.

---

## Usage

```
/jaan-to:detect-pack [repo] [--full]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full consolidation (4+ output files with evidence index and unknowns). Default is light mode. |

**Light mode** (default): Produces 1 summary file with risk heatmap, per-domain scores, and executive summaries.

**Full mode** (`--full`): Produces 4 files (single-platform) or 4 + per-platform packs (multi-platform), including evidence index, unknowns backlog, and cross-platform deduplication.

**Mixed input handling**: detect-pack automatically detects whether each domain produced light-mode (`summary.md`) or full-mode (individual files) outputs. Full-mode domains use per-file data; light-mode domains use summary frontmatter.

---

## Output

### Light Mode (default) — 1 file
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/summary.md` | Risk heatmap, per-domain scores, executive summaries, input mode table |

### Full Mode (`--full`) — 4 files (single-platform)
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/pack/README.md` | Knowledge index: metadata, domain summaries, overall score, links to all detect outputs |
| `$JAAN_OUTPUTS_DIR/detect/pack/risk-heatmap.md` | Risk heatmap table (domain x severity), top risks per domain |
| `$JAAN_OUTPUTS_DIR/detect/pack/unknowns-backlog.md` | Prioritized unknowns with "how to confirm" steps and scope boundaries |
| `$JAAN_OUTPUTS_DIR/detect/pack/source-map.md` | Evidence index: all E-IDs mapped to file locations |

### Full Mode — Multi-Platform Monorepo
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/pack/README-{platform}.md` | Per-platform knowledge index (e.g., `README-web.md`, `README-backend.md`) |
| `$JAAN_OUTPUTS_DIR/detect/pack/README.md` | **Merged pack**: Consolidates all platforms into cross-platform risk heatmap and unified backlog |
| `$JAAN_OUTPUTS_DIR/detect/pack/risk-heatmap.md` | **Cross-platform risk table** with platform x domain matrix |
| `$JAAN_OUTPUTS_DIR/detect/pack/unknowns-backlog.md` | All platforms combined, grouped by platform then domain |
| `$JAAN_OUTPUTS_DIR/detect/pack/source-map.md` | All evidence IDs from all platforms |

---

## Multi-Platform Support

- **Platform auto-discovery**: Detects platforms by scanning for filename suffixes in detect outputs (e.g., `stack-web.md`, `stack-backend.md`)
- **Per-platform packs**: Creates separate pack for each platform at `detect/pack/README-{platform}.md`
- **Merged pack algorithm**: For multi-platform projects, creates additional merged pack that:
  - Aggregates findings across all platforms
  - Deduplicates cross-platform findings via `related_evidence` chains
  - Builds cross-platform risk heatmap (platform x domain table)
  - Combines unknowns backlog from all platforms
- **Evidence ID parsing**: Handles both formats:
  - Single-platform: `E-DEV-001` → domain: DEV, platform: null, sequence: 001
  - Multi-platform: `E-DEV-WEB-001` → domain: DEV, platform: WEB, sequence: 001
- **Orchestration mode**: If no outputs exist, asks if multi-platform, then displays platform-by-platform workflow guide

---

## Orchestration (Step 0)

Before consolidation, checks which detect skills have run:

- **No outputs found**:
  - Asks: "Is this a multi-platform project? [y/n]"
  - If YES: Displays orchestration guide with platform-by-platform workflow
  - If NO: Lists all 5 detect skills and suggests running them first
- **Partial outputs**: Reports which domains are present/missing per platform, asks user to continue (results marked as partial)
- **All outputs found**: Proceeds directly to consolidation (per-platform + merged if multi-platform)

---

## Key Points

- Enforces universal frontmatter: `target.commit` (must match git HEAD), `target.platform`, `tool.rules_version`, `confidence_scheme`, `findings_summary`, `overall_score`, `lifecycle_phase` (CycloneDX)
- **Overall score formula**: `10 - (critical×2.0 + high×1.0 + medium×0.4 + low×0.1) / max(total_findings, 1)`, clamped 0–10
- **Risk heatmap**:
  - Single-platform: domain × severity markdown table with per-domain scores
  - Multi-platform: platform × domain table showing findings per platform + totals row
- **Evidence ID validation**: all IDs must follow namespace convention, no duplicates, all resolve to file locations
  - Regex: `^E-([A-Z]+)-(([A-Z]+)-)?(\d{3}[a-z]?)$` (matches both single and multi-platform formats)
- **Partial run handling**: coverage % reported ("3/5 domains analyzed"), overall score labeled with "(partial)" suffix
- Unknowns backlog collects all findings with confidence ≤ Tentative + "how to confirm" steps
- Frontmatter validation failures become findings (severity: Medium, confidence: Confirmed)

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
