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

### Single-Platform Project
```
/jaan-to:detect-dev        → $JAAN_OUTPUTS_DIR/detect/dev/*.md
/jaan-to:detect-design     → $JAAN_OUTPUTS_DIR/detect/design/*.md
/jaan-to:detect-writing    → $JAAN_OUTPUTS_DIR/detect/writing/*.md
/jaan-to:detect-product    → $JAAN_OUTPUTS_DIR/detect/product/*.md
/jaan-to:detect-ux         → $JAAN_OUTPUTS_DIR/detect/ux/*.md
                                    ↓
/jaan-to:detect-pack       → $JAAN_OUTPUTS_DIR/detect/pack/{README,risk-heatmap,unknowns-backlog,source-map}.md
```

### Multi-Platform Monorepo
```
Per platform (web, backend, mobile, etc.):
  /jaan-to:detect-dev      → $JAAN_OUTPUTS_DIR/detect/dev/stack-{platform}.md
  /jaan-to:detect-design   → $JAAN_OUTPUTS_DIR/detect/design/brand-{platform}.md
  ...                      → (platform-scoped filenames)
                                    ↓
/jaan-to:detect-pack       → Per-platform packs + merged pack combining all platforms
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
| [/jaan-to:detect-pack](detect-pack.md) | Consolidate all detect outputs into scored index | 4 files |

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
