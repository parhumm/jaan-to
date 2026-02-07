---
title: /dev-stack-detect
doc_type: skill
created_date: 2026-02-03
updated_date: 2026-02-03
tags: [dev, stack, detection, context, auto-detect]
related: [customization]
---

# /dev-stack-detect

> Auto-detect project tech stack and populate jaan.to context files.

---

## Overview

Scans your project's codebase to detect languages, frameworks, databases, infrastructure, CI/CD pipelines, and integrations. Populates `tech.md`, `integrations.md`, `boundaries.md`, and `config.md` with detected values.

---

## Usage

```
/dev-stack-detect
/dev-stack-detect backend
/dev-stack-detect infrastructure
```

| Argument | Required | Description |
|----------|----------|-------------|
| focus-area | No | Limit scan to: backend, frontend, infrastructure, or all (default) |

---

## What It Detects

| Category | Sources Scanned | Examples |
|----------|----------------|---------|
| Languages | package.json, pyproject.toml, go.mod, Cargo.toml, etc. | Node.js 20, Python 3.12, Go 1.22 |
| Frameworks | Dependency lists in manifests | React 18, FastAPI, Django, Next.js 14 |
| Databases | docker-compose.yml service images | PostgreSQL 15, Redis 7, MongoDB |
| CI/CD | Workflow files | GitHub Actions, GitLab CI |
| Testing | Test config files + dependencies | Jest, pytest, Playwright |
| Infrastructure | IaC files, deployment configs | Docker, Kubernetes, Terraform |
| Source Control | git remote URL | GitHub, GitLab, Bitbucket |
| Monorepo | Workspace config files | pnpm, Nx, Turborepo |

---

## Output

Updates four context files (with user approval):

| File | Sections Updated |
|------|-----------------|
| `$JAAN_CONTEXT_DIR/tech.md` | Current Stack, Frameworks, Testing |
| `$JAAN_CONTEXT_DIR/integrations.md` | Source Control, CI/CD |
| `$JAAN_CONTEXT_DIR/boundaries.md` | Allowed/Denied write paths |
| `$JAAN_CONTEXT_DIR/config.md` | Enabled roles |

Also saves a detection report to `$JAAN_OUTPUTS_DIR/dev/stack-detect/`.

---

## Merge Modes

Selected via interactive prompt (AskUserQuestion):

| Mode | Behavior |
|------|----------|
| **Auto-fill** (default) | Fill empty/placeholder sections, skip customized ones |
| **Interactive** | Fill empty, ask per customized section with diff |
| **Overwrite** | Replace all sections (shows full diff, requires confirmation) |
| **Cancel** | Save report only, don't modify files |

---

## Confidence Scoring

Every detection includes a confidence score:

| Range | Meaning | Example |
|-------|---------|---------|
| 95-100% | Explicit in manifest file | `"react": "^18.2.0"` in package.json |
| 90-95% | Docker image with version tag | `postgres:15` in docker-compose |
| 80-90% | Workflow/config file exists | `.github/workflows/` directory |
| 60-80% | Directory structure inference | `k8s/` directory exists |

Only detections above 60% confidence are reported.

---

## Bootstrap Integration

When jaan.to is installed on a new project, the bootstrap script detects placeholder context files and outputs `suggest_stack_detect: true`. This prompts running the skill automatically.

---

## Sections Not Auto-Detected

These require manual input:

- Technical Constraints (compliance, performance requirements)
- Common Patterns (auth, error handling conventions)
- Versioning & Deprecation policies
- Tech Debt items
- Issue Tracking tools (Jira, Linear)
- Communication channels
- Analytics/Design tools
- Team structure

---

[Back to Dev Skills](README.md) | [Back to All Skills](../README.md)
