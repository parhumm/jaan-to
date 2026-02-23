---
title: "devops-infra-scaffold"
sidebar_position: 2
doc_type: skill
created_date: 2026-02-11
updated_date: 2026-02-23
tags: [devops, infra, scaffold, cicd, docker, deployment, github-actions, gitlab-ci]
related: [backend-scaffold, frontend-scaffold, detect-dev, sec-audit-remediate]
---

# /jaan-to:devops-infra-scaffold

> Generate CI/CD workflows, Dockerfiles, and deployment configs from tech.md — you can't ship what you can't deploy.

---

## Overview

Generates production-ready infrastructure files from tech stack context: CI/CD pipelines (GitHub Actions / GitLab CI), multi-stage Dockerfiles, docker-compose for local development, environment configuration, and deployment platform configs. Supports Node.js/TypeScript, PHP, and Go stacks.

---

## Usage

```
/jaan-to:devops-infra-scaffold
/jaan-to:devops-infra-scaffold [tech.md]
```

| Argument | Required | Description |
|----------|----------|-------------|
| tech.md | No | Path to tech stack definition |
| backend-scaffold | No | Path to backend scaffold output |
| frontend-scaffold | No | Path to frontend scaffold output |
| detect-dev | No | Path to detect-dev output for security scanning |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Infrastructure guide with architecture decisions |
| `.github/workflows/ci.yml` or `.gitlab-ci.yml` | CI/CD pipeline |
| `ci/health-check.yml` | Health monitoring workflow (15-min cron, GitHub Actions only) |
| `ci/secret-rotation-reminder.yml` | Quarterly secret rotation reminder (GitHub Actions only) |
| `ci/quality-pipeline.yml` | Quality pipeline with Spectral lint, oasdiff breaking changes, mutation testing, and Schemathesis fuzz stages |
| `Dockerfile` + `Dockerfile.frontend` | Multi-stage Docker builds |
| `docker-compose.yml` | Local development stack |
| `.env.example` | Environment variable template |
| `config/next.config.standalone.ts` | Next.js standalone config (if Next.js detected) |
| `deploy/` | Platform-specific deployment configs |
| `{id}-{slug}-readme.md` | Setup + deployment instructions |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| CI/CD platform | Not in tech.md | GitHub Actions / GitLab CI |
| Deployment target | Not in tech.md | Vercel / Railway / Fly.io / AWS ECS |
| Docker strategy | Always | Single / multi-service / monorepo |
| Environment tiers | Always | dev / staging / production |

---

## Multi-Stack Support

| Stack | CI/CD | Docker | Deployment |
|-------|-------|--------|------------|
| Node.js / TypeScript | GitHub Actions / GitLab CI | Multi-stage Alpine | Vercel / Railway / Fly.io |
| PHP | GitLab CI | php-fpm + nginx | AWS ECS / Railway |
| Go | GitHub Actions / GitLab CI | Scratch / distroless | Fly.io / AWS ECS |

---

## Workflow Chain

```
/jaan-to:dev-project-assemble + /jaan-to:sec-audit-remediate --> /jaan-to:devops-infra-scaffold
```

---

## Example

**Input:**
```
/jaan-to:devops-infra-scaffold
```

**Output:**
```
jaan-to/outputs/devops/infra-scaffold/01-my-app-infra/
├── 01-my-app-infra.md
├── .github/workflows/ci.yml
├── Dockerfile
├── Dockerfile.frontend
├── docker-compose.yml
├── .env.example
├── deploy/
│   └── fly.toml
└── 01-my-app-infra-readme.md
```

---

## CI Quality Pipeline Stages

When an OpenAPI contract is detected (from `backend-api-contract` output or project files), the generated CI pipeline includes four additional quality stages:

| Stage | Tool | Purpose |
|-------|------|---------|
| Spectral Lint | Spectral | Validates OpenAPI spec against style rules and best practices |
| Breaking Changes | oasdiff | Detects breaking API changes between branches |
| Mutation Testing | StrykerJS / Infection / go-mutesting | Verifies test suite effectiveness via code mutation |
| Fuzz Testing | Schemathesis | Property-based fuzz testing of API endpoints against the contract |

These stages run in parallel after the standard build/test stages. Each stage is opt-in via `ci_quality_stages` in `jaan-to/config/settings.yaml`.

---

## Tips

- Set up `$JAAN_CONTEXT_DIR/tech.md` for automatic stack detection
- Run after `/jaan-to:dev-project-assemble` to match the project structure
- Include `/jaan-to:detect-dev` output for security scanning in CI
- Review generated secrets and environment variables before deploying
- Configure endpoint repository variables (`API_URL`, `WEB_URL`) after copying health-check workflow
- Review secret rotation checklist against actual project secrets
- Verify Next.js `output: 'standalone'` matches Dockerfile expectations

---

## Related Skills

- [/jaan-to:dev-project-assemble](../dev/project-assemble.md) - Assemble project from scaffolds
- [/jaan-to:backend-scaffold](../backend/scaffold.md) - Generate backend code
- [/jaan-to:sec-audit-remediate](../sec/audit-remediate.md) - Generate security fixes

---

## Technical Details

- **Logical Name**: devops-infra-scaffold
- **Command**: `/jaan-to:devops-infra-scaffold`
- **Role**: devops
- **Output**: `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{id}-{slug}/`
