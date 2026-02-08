---
title: "dev-detect"
sidebar_position: 1
doc_type: skill
tags: [detect, dev, engineering, audit, security, cicd]
related: [dev-stack-detect, knowledge-pack]
---

# /jaan-to:dev-detect

> Repo engineering audit with machine-parseable findings and OpenSSF-style scoring.

---

## What It Does

Performs a comprehensive engineering audit of the repository, producing structured markdown reports for stack, architecture, standards, testing, CI/CD, deployment, security, observability, and risks. Every finding is evidence-backed with SARIF-like locations and confidence scoring.

---

## Usage

```
/jaan-to:dev-detect
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `docs/current/dev/stack.md` | Tech stack with version evidence |
| `docs/current/dev/architecture.md` | Architecture patterns and data flow |
| `docs/current/dev/standards.md` | Coding standards and conventions |
| `docs/current/dev/testing.md` | Test coverage and strategy |
| `docs/current/dev/cicd.md` | CI/CD pipelines and security |
| `docs/current/dev/deployment.md` | Deployment patterns |
| `docs/current/dev/security.md` | Security posture and findings |
| `docs/current/dev/observability.md` | Logging, metrics, tracing |
| `docs/current/dev/risks.md` | Technical risks and debt |

Each file includes standardized YAML frontmatter + Findings blocks (ID/severity/confidence/evidence).

---

## Key Points

- Every claim MUST be evidence-backed with SARIF-like locations (uri, startLine/endLine, snippet) + evidence IDs (E001…)
- 4-level confidence: Confirmed / Firm / Tentative / Uncertain
- Diátaxis-style sections: Executive Summary → Scope/Methodology → Findings → Recommendations → Appendices
- Frontmatter includes findings_summary buckets + overall_score (0–10, OpenSSF-style) + lifecycle_phase (CycloneDX)
- CI/CD security: secrets boundaries, runner trust, permissions, supply-chain signals (SLSA-ish)

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
