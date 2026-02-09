---
title: "Detect & Knowledge"
sidebar_position: 7
slug: /skills/detect
updated_date: 2026-02-09
---

# Detect Skills

> Evidence-based repo audits with confidence-scored findings.

---

## Pipeline

All detect skills support `--light` (default) and `--full` modes. Light mode produces 1 summary file per domain; full mode produces detailed multi-file output.

### Light Mode (default)
```
/jaan-to:detect-dev        → $JAAN_OUTPUTS_DIR/detect/dev/summary.md        (1 file)
/jaan-to:detect-design     → $JAAN_OUTPUTS_DIR/detect/design/summary.md     (1 file)
/jaan-to:detect-writing    → $JAAN_OUTPUTS_DIR/detect/writing/summary.md    (1 file)
/jaan-to:detect-product    → $JAAN_OUTPUTS_DIR/detect/product/summary.md    (1 file)
/jaan-to:detect-ux         → $JAAN_OUTPUTS_DIR/detect/ux/summary.md         (1 file)
                                    ↓
/jaan-to:detect-pack       → $JAAN_OUTPUTS_DIR/detect/summary.md            (1 file)
```

### Full Mode (`--full`)
```
/jaan-to:detect-dev --full        → $JAAN_OUTPUTS_DIR/detect/dev/*.md        (9 files)
/jaan-to:detect-design --full     → $JAAN_OUTPUTS_DIR/detect/design/*.md     (6 files)
/jaan-to:detect-writing --full    → $JAAN_OUTPUTS_DIR/detect/writing/*.md    (6 files)
/jaan-to:detect-product --full    → $JAAN_OUTPUTS_DIR/detect/product/*.md    (7 files)
/jaan-to:detect-ux --full         → $JAAN_OUTPUTS_DIR/detect/ux/*.md         (7 files)
                                           ↓
/jaan-to:detect-pack --full       → $JAAN_OUTPUTS_DIR/detect/pack/*.md       (4+ files)
```

detect-pack handles mixed inputs: domains can be light or full independently.

---

## Available Skills

| Skill | Description | Light | Full |
|-------|-------------|-------|------|
| [/jaan-to:detect-dev](detect-dev.md) | Engineering audit with OpenSSF-style scoring | 1 file | 9 files |
| [/jaan-to:detect-design](detect-design.md) | Design system detection with drift findings | 1 file | 6 files |
| [/jaan-to:detect-writing](detect-writing.md) | Writing system extraction with NNg tone scoring | 1 file | 6 files |
| [/jaan-to:detect-product](detect-product.md) | Product reality extraction with 3-layer evidence | 1 file | 7 files |
| [/jaan-to:detect-ux](detect-ux.md) | UX audit with Nielsen heuristics and journey mapping | 1 file | 7 files |
| [/jaan-to:detect-pack](detect-pack.md) | Consolidate all detect outputs into scored index | 1 file | 4+ files |

---

## Multi-Platform Support

All detect skills automatically detect and analyze multi-platform monorepos:

- **Platform auto-detection**: Scans folder structure (web/, backend/, mobile/, etc.) using configurable patterns
- **Platform-scoped filenames**: `stack-web.md`, `stack-backend.md` instead of nested folders
- **Evidence ID prefixing**: `E-DEV-WEB-001` for multi-platform, `E-DEV-001` for single-platform
- **Cross-platform linking**: Use `related_evidence` field to link findings across platforms
- **"Detect and Report N/A" pattern**: All domains always produce output (even if N/A for that platform)
- **Merged pack**: detect-pack consolidates all platforms into cross-platform risk heatmap

See individual skill documentation for platform-specific behavior.

---

## Shared Standards

All detect skills share:

- **Evidence format**: SARIF-compatible blocks with id, type, confidence, location (uri, startLine, snippet), method
- **Evidence ID namespaces**:
  - Single-platform: `E-DEV-NNN`, `E-DSN-NNN`, `E-WRT-NNN`, `E-PRD-NNN`, `E-UX-NNN`
  - Multi-platform: `E-DEV-{PLATFORM}-NNN` (e.g., `E-DEV-WEB-001`, `E-DSN-BACKEND-023`)
- **4-level confidence**: Confirmed (0.95–1.00) / Firm (0.80–0.94) / Tentative (0.50–0.79) / Uncertain (0.20–0.49)
- **Universal frontmatter**: title, id, version, status, target.commit, target.platform, tool metadata, confidence_scheme, findings_summary, overall_score (0–10), lifecycle_phase
- **Document structure** (Diataxis): Executive Summary → Scope/Methodology → Findings → Recommendations → Appendices
- **Output path**: `$JAAN_OUTPUTS_DIR/detect/{domain}/` — flat files with platform suffixes, overwritten each run (no IDs)

---

## Reference

- [Repo-analysis output & content detection standards](../../../jaan-to/outputs/research/61-detect-pack.md)

---

[Back to Skills](../README.md)
