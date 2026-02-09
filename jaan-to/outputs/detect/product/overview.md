# Product Overview — claude-code

---
title: "Product Overview — claude-code"
id: "AUDIT-2026-016"
version: "1.0.0"
status: draft
date: 2026-02-09
target:
  name: "claude-code"
  platform: "all"
  commit: "cccb7879092e0338fdd063523d8f81d2955f4bfe"
  branch: "refactor/skill-naming-cleanup"
tool:
  name: "detect-product"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 3
overall_score: 10.0
lifecycle_phase: post-build
---

## Executive Summary

**jaan.to** (claude-code) is an **open-source CLI plugin for Claude Code** with 26 AI-powered skills for product management, development, UX, QA, and data workflows.

**Product Type**: Developer tool (CLI plugin)
**Distribution**: Open source (MIT License)
**Monetization**: None (free)
**Target Users**: PM, Dev (Frontend/Backend), UX, QA, Data roles

**Core Features**:
- 26 structured skills across 6 domains
- Two-phase workflow (analyze → approve → generate)
- Continuous learning system (LEARN.md)
- Evidence-based repo audits (detect suite)
- Template-driven output generation

**Assessment**: **Excellent** — Well-defined product with clear value proposition and comprehensive feature set for workflow automation.

---

## Scope and Methodology

**Analysis Methods**:
- Skill inventory (SKILL.md files)
- README and documentation analysis
- Plugin manifest inspection (plugin.json)
- License verification

**Product Context**:
- **Product Name**: jaan.to (Persian: "give soul")
- **Version**: 3.24.0
- **Repository**: github.com/parhumm/jaan-to
- **Installation**: Via Claude Code plugin marketplace

---

## Findings

### F-PRD-001: CLI Plugin for Claude Code

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-PRD-001
  type: code-location
  confidence: 1.00
  location:
    uri: ".claude-plugin/plugin.json"
    startLine: 1
    endLine: 9
    snippet: |
      {
        "name": "jaan-to",
        "version": "3.24.0",
        "description": "Give soul to your workflow. 27 AI-powered skills...",
        "author": {
          "name": "Parhum Khoshbakht",
          "email": "parhum.kh@gmail.com"
        }
      }
  method: manifest-analysis
```

**Description**: The product is a **Claude Code plugin** distributed via the official plugin marketplace. Users install via:
```bash
/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to
```

**Impact**: **Positive** — Integrates directly into Claude Code's workflow, no separate installation required.

---

### F-PRD-002: 26 Skills Across 6 Domains

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-PRD-002
  type: metric
  confidence: 1.00
  location:
    uri: "skills/"
    analysis: |
      Skill count: 26 directories with SKILL.md files

      Domains:
      - PM: 3 skills (pm-prd-write, pm-story-write, pm-research-about)
      - Dev Frontend: 2 skills (frontend-design, frontend-task-breakdown)
      - Dev Backend: 3 skills (backend-api-contract, backend-data-model, backend-task-breakdown)
      - Detect Suite: 6 skills (detect-dev, detect-design, detect-product, detect-ux, detect-writing, detect-pack)
      - UX: 3 skills (ux-heatmap-analyze, ux-microcopy-write, ux-research-synthesize)
      - QA: 1 skill (qa-test-cases)
      - Data: 1 skill (data-gtm-datalayer)
      - Core: 7 skills (docs-create, docs-update, learn-add, roadmap-add, roadmap-update, skill-create, skill-update)
  method: static-analysis
```

**Description**: The product offers **26 skills** (commands) covering:
- Product management (PRDs, user stories, research)
- Development (frontend/backend task breakdowns, API contracts, data models)
- Evidence-based audits (detect suite for dev, design, product, UX, writing)
- UX research and microcopy
- QA test case generation
- Data analytics tracking (GTM)
- Documentation and learning management

**Impact**: **Positive** — Comprehensive coverage of software development workflows.

---

### F-PRD-003: Open Source Distribution (MIT License)

**Severity**: Informational
**Confidence**: Confirmed (1.00)

```yaml
evidence:
  id: E-PRD-003
  type: code-location
  confidence: 1.00
  location:
    uri: "README.md"
    startLine: 6
    snippet: |
      [![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  method: pattern-match
```

**Description**: The product is **open source** under MIT License:
- Free to use, modify, and distribute
- Source code publicly available on GitHub
- No commercial restrictions

**Impact**: **Positive** — Removes adoption barriers, encourages community contributions.

---

## Recommendations

None. Product definition is clear and well-executed.

---

## Appendices

### A. Product Summary

| Attribute | Value |
|-----------|-------|
| **Name** | jaan.to |
| **Type** | Claude Code CLI Plugin |
| **Version** | 3.24.0 |
| **Skills** | 26 |
| **License** | MIT (Open Source) |
| **Distribution** | Claude plugin marketplace + GitHub |
| **Monetization** | None (free) |
| **Target Users** | PM, Dev, UX, QA, Data teams |

### B. Skill Domains

| Domain | Skill Count | Examples |
|--------|-------------|----------|
| PM | 3 | PRD generation, user stories, research |
| Dev (Frontend) | 2 | UI design, task breakdown |
| Dev (Backend) | 3 | API contracts, data models, tasks |
| Detect Suite | 6 | Repo audits (dev, design, product, UX, writing) |
| UX | 3 | Heatmap analysis, microcopy, research synthesis |
| QA | 1 | BDD/Gherkin test cases |
| Data | 1 | GTM tracking code generation |
| Core | 7 | Docs, learning, roadmap, skill management |

---

*Generated by jaan.to detect-product | 2026-02-09*
