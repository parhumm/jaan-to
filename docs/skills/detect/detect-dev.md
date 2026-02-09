---
title: "detect-dev"
sidebar_position: 1
doc_type: skill
tags: [detect, dev, engineering, audit, security, cicd]
related: [detect-design, detect-writing, detect-product, detect-ux, detect-pack]
updated_date: 2026-02-09
---

# /jaan-to:detect-dev

> Repo engineering audit with machine-parseable findings and OpenSSF-style scoring.

---

## What It Does

Performs an engineering audit of the repository with evidence-backed findings and OpenSSF-style scoring. Supports **light mode** (default, 1 summary file) and **full mode** (`--full`, 9 detailed files).

Scans manifest files (package.json, pyproject.toml, go.mod, Cargo.toml, etc.), Docker/compose configurations, CI/CD pipelines, git metadata, infrastructure-as-code, and project structure across 11+ language ecosystems.

---

## Usage

```
/jaan-to:detect-dev [repo] [--full]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full analysis (9 detection steps, 9 output files). Default is light mode. |

**Light mode** (default): Scans config/manifest files and Docker/database layers, produces 1 summary file with tech stack, database/container table, top-5 findings, and overall score (score notes limited scope).

**Full mode** (`--full`): Runs all detection steps including CI/CD, git analysis, infrastructure, and project structure. Produces 9 detailed output files.

---

## Output

### Light Mode (default) — 1 file
| File | Content |
|------|---------|
| `$JAAN_OUTPUTS_DIR/detect/dev/summary{suffix}.md` | Tech stack table, db/container table, top-5 findings, overall score |

### Full Mode (`--full`) — 9 files
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

### Multi-Platform Monorepo
Files use platform suffix: `stack-{platform}.md`, `summary-{platform}.md`, etc.

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

## Multi-Platform Support

- **Platform auto-detection**: Detects web/, backend/, mobile/, etc. from folder structure
- **Evidence ID format**:
  - Single-platform: `E-DEV-NNN` (e.g., `E-DEV-001`)
  - Multi-platform: `E-DEV-{PLATFORM}-NNN` (e.g., `E-DEV-WEB-001`, `E-DEV-BACKEND-023`)
- **Output paths**: Platform-scoped filenames (`stack-web.md`) instead of nested folders
- **Fully applicable**: detect-dev analyzes all platforms (no skip logic)
- **Cross-platform linking**: Use `related_evidence` field for findings appearing in multiple platforms

---

## Key Points

- 4-level confidence: Confirmed (0.95-1.00) / Firm (0.80-0.94) / Tentative (0.50-0.79) / Uncertain (0.20-0.49)
- Diataxis-style sections: Executive Summary → Scope/Methodology → Findings → Recommendations → Appendices
- Frontmatter includes `target.platform`, `findings_summary` buckets + `overall_score` (0-10, OpenSSF-style) + `lifecycle_phase` (CycloneDX)
- CI/CD security checks: secrets boundaries, runner trust (`self-hosted`), permissions (`write-all`), action pinning (SHA vs `@main`), SLSA provenance
- Overall score formula: `10 - (critical*2.0 + high*1.0 + medium*0.4 + low*0.1) / max(total_findings, 1)`
- Uses git tools for history analysis (`git log`, `git remote`, `git show`)

---

[Back to Detect Skills](README.md) | [Back to All Skills](../README.md)
