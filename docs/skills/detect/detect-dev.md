---
title: "detect-dev"
sidebar_position: 1
doc_type: skill
tags: [detect, dev, engineering, audit, security, cicd]
related: [detect-design, detect-writing, detect-product, detect-ux, detect-pack]
updated_date: 2026-02-08
---

# /jaan-to:detect-dev

> Repo engineering audit with machine-parseable findings and OpenSSF-style scoring.

---

## What It Does

Performs a comprehensive engineering audit of the repository, producing 9 structured markdown reports covering stack, architecture, standards, testing, CI/CD, deployment, security, observability, and risks. Every finding is evidence-backed with SARIF-like locations and confidence scoring.

Scans manifest files (package.json, pyproject.toml, go.mod, Cargo.toml, etc.), Docker/compose configurations, CI/CD pipelines, git metadata, infrastructure-as-code, and project structure across 11+ language ecosystems.

---

## Usage

```
/jaan-to:detect-dev
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |

---

## Output

| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/dev/stack.md` | Tech stack with version evidence |
| `$JAAN_OUTPUTS_DIR/detect/dev/architecture.md` | Architecture patterns and data flow |
| `$JAAN_OUTPUTS_DIR/detect/dev/standards.md` | Coding standards and conventions |
| `$JAAN_OUTPUTS_DIR/detect/dev/testing.md` | Test coverage and strategy |
| `$JAAN_OUTPUTS_DIR/detect/dev/cicd.md` | CI/CD pipelines and security |
| `$JAAN_OUTPUTS_DIR/detect/dev/deployment.md` | Deployment patterns |
| `$JAAN_OUTPUTS_DIR/detect/dev/security.md` | Security posture and findings (OWASP mapping) |
| `$JAAN_OUTPUTS_DIR/detect/dev/observability.md` | Logging, metrics, tracing |
| `$JAAN_OUTPUTS_DIR/detect/dev/risks.md` | Technical risks and debt |

Each file includes standardized YAML frontmatter + Findings blocks (ID/severity/confidence/evidence).

---

## What It Scans

| Layer | Confidence | Sources |
|-------|------------|---------|
| Config files | 95-100% | package.json, pyproject.toml, go.mod, Cargo.toml, Gemfile, composer.json, pom.xml, pubspec.yaml, mix.exs, Package.swift, *.csproj |
| Docker & databases | 90-95% | docker-compose.yml, Dockerfile |
| CI/CD & testing | 90-95% | GitHub Actions, GitLab CI, CircleCI, Jenkins, test configs, linters |
| Git & integrations | 95% | git remote, CODEOWNERS, PR templates, Renovate/Dependabot |
| Infrastructure | 60-80% | Terraform, serverless.yml, Vercel/Netlify/Fly configs, Kubernetes/Helm |
| Project structure | 60-80% | Directory layout, monorepo signals |

---

## Key Points

- Evidence IDs use namespace `E-DEV-NNN` (prevents collisions in detect-pack aggregation)
- 4-level confidence: Confirmed (0.95-1.00) / Firm (0.80-0.94) / Tentative (0.50-0.79) / Uncertain (0.20-0.49)
- Diataxis-style sections: Executive Summary → Scope/Methodology → Findings → Recommendations → Appendices
- Frontmatter includes `findings_summary` buckets + `overall_score` (0-10, OpenSSF-style) + `lifecycle_phase` (CycloneDX)
- CI/CD security checks: secrets boundaries, runner trust (`self-hosted`), permissions (`write-all`), action pinning (SHA vs `@main`), SLSA provenance
- Overall score formula: `10 - (critical*2.0 + high*1.0 + medium*0.4 + low*0.1) / max(total_findings, 1)`
- Uses git tools for history analysis (`git log`, `git remote`, `git show`)

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
