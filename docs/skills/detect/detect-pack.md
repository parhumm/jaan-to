---
title: "detect-pack"
sidebar_position: 6
doc_type: skill
tags: [detect, knowledge, consolidation, risk, unknowns, evidence]
related: [detect-dev, detect-design, detect-writing, detect-product, detect-ux]
updated_date: 2026-02-23
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

## Seed Reconciliation (Step 8a)

After writing output files, detect-pack compares consolidated detection results against all project seed files and proposes updates:

- **Reads**: `$JAAN_CONTEXT_DIR/tech.md`, `team.md`, `integrations.md`, `boundaries.md`, `tone-of-voice.template.md`, `localization.template.md`
- **Classifies changes**: `[UPDATE]` (version drift), `[ADD]` (missing entry), `[STALE]` (not detected — user decides keep/remove)
- **Presents diff-style summary** per seed file with approval prompt: `[y/all/n/pick]`
- **Applies approved changes** preserving section anchors and user-added custom sections
- **Suggests `/learn-add`** for findings that don't map to any seed file
- **Writes report**: `$JAAN_OUTPUTS_DIR/detect/seed-reconciliation.md`

See [seed-reconciliation-reference.md](../../extending/seed-reconciliation-reference.md) for mapping rules and preservation conventions.

---

## ISO 25010 Compliance

detect-pack aggregates ISO/IEC 25010 quality characteristic mappings from all detect domains. The consolidated output includes:

- **ISO 25010 coverage matrix** — which characteristics are addressed by findings across domains
- **Characteristic-level scores** — aggregated score per ISO 25010 characteristic (Functional Suitability, Performance Efficiency, Compatibility, Usability, Reliability, Security, Maintainability, Portability)
- **Gap analysis** — identifies ISO 25010 characteristics with no coverage from any detect domain

### Quality Gate Readiness

The pack output includes a **Quality Gate Readiness** section that evaluates whether the project meets configurable thresholds for shipping:

| Gate | Default Threshold | Source |
|------|-------------------|--------|
| Overall score | >= 6.0 | All domains |
| Critical findings | 0 | All domains |
| High findings | <= 3 | All domains |
| ISO 25010 coverage | >= 6/8 characteristics | Mapped findings |
| Mutation score | >= 60% (if detected) | detect-dev testing.md |

Gate thresholds are configurable via `quality_gate` in `jaan-to/config/settings.yaml`. The readiness verdict is `PASS`, `WARN`, or `FAIL`.

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

[Back to Detect Skills](docs/skills/detect/README.md) | [Back to All Skills](../README.md)
