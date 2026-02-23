---
title: "detect-dev"
sidebar_position: 1
doc_type: skill
tags: [detect, dev, engineering, audit, security, cicd]
related: [detect-design, detect-writing, detect-product, detect-ux, detect-pack]
updated_date: 2026-02-23
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
/jaan-to:detect-dev [repo] [--full] [--incremental]
```

| Argument | Required | Description |
|----------|----------|-------------|
| repo | No | Target repository (defaults to current) |
| `--full` | No | Run full analysis (9 detection steps, 9 output files). Default is light mode. |
| `--incremental` | No | Scope scan to files changed since last audit. Combines with `--full`. |

**Light mode** (default): Scans config/manifest files and Docker/database layers, produces 1 summary file with tech stack, database/container table, top-5 findings, and overall score (score notes limited scope).

**Full mode** (`--full`): Runs all detection steps including CI/CD, git analysis, infrastructure, and project structure. Produces 9 detailed output files.

**Incremental mode** (`--incremental`): Reads `.audit-state.yaml` from the previous run, then uses `git diff` to scope the scan to only changed files. Falls back to a full scan if no prior audit state exists, the commit is unreachable (e.g., after rebase), or the stored commit hash is invalid. Exits early with "Audit is up to date" if no files have changed. Combines with `--full` for scoped full-depth analysis.

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

## Incremental Mode

When `--incremental` is used, detect-dev reads `$JAAN_OUTPUTS_DIR/detect/dev/.audit-state.yaml` (written at the end of every audit run) and scopes the scan to files changed since the last audit commit.

| Flags | Behavior |
|-------|----------|
| *(none)* | Light mode, full scan |
| `--full` | Full mode, full scan |
| `--incremental` | Light mode, scoped to changed files |
| `--incremental --full` | Full mode, scoped to changed files |

**Graceful fallback**: If no state file exists, the commit is unreachable, or the hash is invalid, detect-dev warns and falls back to a full scan. If no files have changed, it exits with "Audit is up to date."

**Post-integration workflow**: After running `/jaan-to:dev-output-integrate`, run `/jaan-to:detect-dev --incremental` to re-audit only the integrated files.

---

## Integration-Aware Evidence

When integration logs exist (from `/jaan-to:dev-output-integrate`), detect-dev tags evidence blocks with an `origin` field:

- `origin: integrated` — file was copied into the project by dev-output-integrate
- `origin: hand-written` — file was not part of any integration

This helps prioritize findings: issues in integrated (generated) code may indicate upstream generation problems, while issues in hand-written code are direct developer concerns. The `origin` field is optional and omitted when no integration logs are available.

---

## Enhanced Detection Capabilities

### DORA Metrics

Full-mode analysis includes DORA (DevOps Research and Assessment) metrics derived from git history and CI/CD pipeline data:

- **Deployment Frequency** — estimated from release tags and merge-to-main cadence
- **Lead Time for Changes** — average time from first commit to production deploy
- **Change Failure Rate** — ratio of hotfix/revert commits to total deploys
- **Mean Time to Recovery** — average time between failure introduction and fix

DORA metrics appear in the `cicd.md` output file with confidence levels based on available data.

### ISO 25010 Mapping

Findings are mapped to ISO/IEC 25010 quality characteristics (Functional Suitability, Performance Efficiency, Compatibility, Usability, Reliability, Security, Maintainability, Portability). Each finding's frontmatter includes an `iso_25010` field with the applicable characteristic, enabling standards-based reporting.

### Mutation Testing Detection

Scans for mutation testing configuration files (StrykerJS `stryker.config.*`, Infection `infection.json5`, go-mutesting configs) and mutation score thresholds. Reports presence/absence as a finding in `testing.md` with severity based on test suite maturity.

---

## Key Points

- 4-level confidence: Confirmed (0.95-1.00) / Firm (0.80-0.94) / Tentative (0.50-0.79) / Uncertain (0.20-0.49)
- Diataxis-style sections: Executive Summary → Scope/Methodology → Findings → Recommendations → Appendices
- Frontmatter includes `target.platform`, `findings_summary` buckets + `overall_score` (0-10, OpenSSF-style) + `lifecycle_phase` (CycloneDX)
- CI/CD security checks: secrets boundaries, runner trust (`self-hosted`), permissions (`write-all`), action pinning (SHA vs `@main`), SLSA provenance
- Overall score formula: `10 - (critical*2.0 + high*1.0 + medium*0.4 + low*0.1) / max(total_findings, 1)`
- Uses git tools for history analysis (`git log`, `git remote`, `git show`, `git diff`)

---

[Back to Detect Skills](docs/skills/detect/README.md) | [Back to All Skills](../README.md)
