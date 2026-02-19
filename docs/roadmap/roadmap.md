---
title: "jaan.to Roadmap"
sidebar_position: 1
---

# jaan.to Roadmap

> See [vision.md](vision.md) for philosophy and concepts

---

## Overview

| Phase | Focus | Status |
|-------|-------|--------|
| 1-3 | Foundation, migration, customization | Done (see [CHANGELOG.md](/changelog)) |
| 4 | Development workflow | Planned |
| 5 | Detect & Knowledge Pack (6 skills) | **Done** |
| 6 | Role skills (142 across 11 roles) | In Progress |
| 7 | MCP connectors | Planned |
| 8 | Testing and polish | Planned |
| 9 | Distribution | Partial |

---

## Version History

For complete release history, see [CHANGELOG.md](/changelog).

**Latest:** v7.1.0 (43 skills) — Asset embedding for document-generating skills

---

## Unreleased

- [ ] `jaan-init` Co-Authored-By attribution for git commits and PRs ([#109](https://github.com/parhumm/jaan-to/issues/109))

---

## Phase 4: Development Workflow

> Details: [tasks/development-workflow.md](tasks/development-workflow.md) | [tasks/lsp-support.md](tasks/lsp-support.md)

- [ ] Project constitution document (`context/constitution.md`) — 9 immutable development principles
- [ ] Complexity tracking in outputs — `[NEEDS CLARIFICATION]`, `[COMPLEXITY]`, `[EXCEPTION]`, `[TRADEOFF]` markers
- [ ] LSP support — Bundle TypeScript + Python language server configs, make skills LSP-aware

---

## Phase 5: Detect & Knowledge Pack (6 skills) — DONE

> Details: [tasks/role-skills/detect.md](tasks/role-skills/detect.md) | Completed in v3.23.0–v6.1.0 — see [CHANGELOG.md](/changelog)

6 detect skills shipped: detect-dev, detect-design, detect-writing, detect-product, detect-ux, detect-pack. Pipeline produces `$JAAN_OUTPUTS_DIR/detect/` knowledge with SARIF-like evidence and confidence scoring.

---

## Phase 6: Role Skills (142 across 11 roles)

> Details: [tasks/role-skills.md](tasks/role-skills.md)

142 skills cataloged across 11 roles. Quick-win skills (no MCP required) are built first, followed by advanced skills that depend on MCP connectors.

All new skills must follow v3.0.0 patterns: `$JAAN_*` environment variables, template variables, tech stack integration, and pass `/jaan-to:skill-update` validation.

| Role | Total | Quick Wins | Advanced | File |
|------|-------|------------|----------|------|
| PM | 24 | 18 | 6 | [pm.md](tasks/role-skills/pm.md) |
| DEV | 19 | 15 | 4 | [dev.md](tasks/role-skills/dev.md) |
| QA | 12 | 8 | 4 | [qa.md](tasks/role-skills/qa.md) |
| DATA | 14 | 8 | 6 | [data.md](tasks/role-skills/data.md) |
| GROWTH | 15 | 9 | 6 | [growth.md](tasks/role-skills/growth.md) |
| UX | 21 | 16 | 5 | [ux.md](tasks/role-skills/ux.md) |
| SEC | 4 | 4 | 0 | [sec.md](tasks/role-skills/sec.md) |
| DELIVERY | 8 | 8 | 0 | [delivery.md](tasks/role-skills/delivery.md) |
| SRE | 9 | 5 | 4 | [sre.md](tasks/role-skills/sre.md) |
| SUPPORT | 8 | 8 | 0 | [support.md](tasks/role-skills/support.md) |
| RELEASE | 8 | 8 | 0 | [release.md](tasks/role-skills/release.md) |

**Priority** (by research rank): qa-test-cases (#1), data-sql-query (#2), ux-research-synthesize (#8), qa-bug-report (#10), growth-meta-write (#12). Full priority list in [tasks/role-skills.md](tasks/role-skills.md#priority-order-by-research-rank).

**Completed work**: 43 skills shipped across v4.0.0–v6.4.0 — see [CHANGELOG.md](/changelog) for details.

---

## Phase 7: MCP Connectors (24 documented)

> Details: [tasks/mcp-connectors.md](tasks/mcp-connectors.md)

MCP connectors provide real system context to skills. Skills stay generic; MCP provides per-product data from actual tools.

- **Core MCPs (11)**: GA4, GitLab, Jira, Figma, GSC, Clarity, Sentry, BigQuery, Playwright, OpenAPI, dbt Cloud
- **Extended MCPs (13)**: Notion, Slack, GitHub, Linear, Mixpanel, Confluence, Snowflake, PostgreSQL, Ahrefs, Semrush, LambdaTest, Google Drive, Memory
- **Infrastructure**: Deferred loading for token savings, Context7 integration, model routing per skill type

---

## Phase 8: Testing and Polish

- [ ] E2E test framework in `tests/` with mocked MCP responses
- [ ] JSON export alongside markdown for all skill outputs
- [ ] External notifications (Slack integration)
- [ ] Fix `learn-report` skill hook script for macOS compatibility (Bash 3.2 — needs 4+ for `declare -A`)

---

## Phase 9: Distribution

> Details: [tasks/distribution.md](tasks/distribution.md)

- [ ] Multi-agent compatibility research (Cursor, Copilot, Windsurf, Gemini)
- [ ] CLI installer (`jaan-to-cli`) for one-command setup
- [ ] Public documentation site and branding guidelines

---

## Quick Reference

### Commands

| Command | Description |
|---------|-------------|
| `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| `/jaan-to:pm-research-about` | Deep research or add file/URL to index |
| `/jaan-to:pm-story-write` | Generate user stories with Given/When/Then AC |
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code |
| `/jaan-to:detect-dev` | Engineering audit with scored findings |
| `/jaan-to:detect-design` | Design system detection with drift findings |
| `/jaan-to:detect-writing` | Writing system extraction with tone scoring |
| `/jaan-to:detect-product` | Product reality extraction with evidence |
| `/jaan-to:detect-ux` | UX audit with journey/pain-point findings |
| `/jaan-to:detect-pack` | Consolidate detect outputs into knowledge index |
| `/jaan-to:frontend-task-breakdown` | Frontend task breakdown with component hierarchy |
| `/jaan-to:backend-task-breakdown` | Backend task breakdown from PRDs |
| `/jaan-to:frontend-design` | Frontend component design |
| `/jaan-to:backend-data-model` | Generate data model docs with constraints, indexes, and migrations |
| `/jaan-to:backend-api-contract` | Generate OpenAPI 3.1 contracts from API entities |
| `/jaan-to:backend-pr-review` | Review backend PRs for security, performance, and code quality |
| `/jaan-to:backend-scaffold` | Generate production-ready backend code from specs |
| `/jaan-to:frontend-scaffold` | Convert designs to React/Next.js scaffold code |
| `/jaan-to:ux-heatmap-analyze` | Analyze heatmap CSV + screenshots |
| `/jaan-to:ux-microcopy-write` | Multi-language UX microcopy |
| `/jaan-to:ux-research-synthesize` | Synthesize UX research findings |
| `/jaan-to:ux-flowchart-generate` | Generate Mermaid flowcharts from PRD/docs/codebase |
| `/jaan-to:qa-test-cases` | Generate test cases from PRDs |
| `/jaan-to:wp-pr-review` | Review WordPress plugin PRs for security and standards |
| `/jaan-to:dev-project-assemble` | Wire scaffold outputs into runnable project structure |
| `/jaan-to:backend-service-implement` | Generate service implementations from scaffold stubs |
| `/jaan-to:qa-test-generate` | Generate runnable Vitest/Playwright tests from BDD cases |
| `/jaan-to:sec-audit-remediate` | Generate security fixes from detect-dev findings |
| `/jaan-to:dev-output-integrate` | Copy generated outputs into project with config merging |
| `/jaan-to:devops-infra-scaffold` | Generate CI/CD, Dockerfiles, deployment configs |
| `/jaan-to:devops-deploy-activate` | Activate deployment pipeline with secrets and platform provisioning |
| `/jaan-to:qa-test-run` | Execute tests, diagnose failures, auto-fix, generate coverage reports |
| `/jaan-to:dev-verify` | Validate build pipeline and running services with health checks |
| `/jaan-to:release-iterate-changelog` | Generate changelog with user impact and support guidance |
| `/jaan-to:jaan-init` | Initialize jaan-to for a project |
| `/jaan-to:jaan-issue-report` | Report issues to jaan-to GitHub repo |
| `/jaan-to:skill-create` | Create new skill with wizard |
| `/jaan-to:skill-update` | Update existing skill |
| `/jaan-to:docs-create` | Create documentation with templates |
| `/jaan-to:docs-update` | Audit and update stale documentation |
| `/jaan-to:learn-add` | Add lesson to skill's LEARN.md |
| `/jaan-to:roadmap-add` | Add task to roadmap |
| `/jaan-to:roadmap-update` | Maintain and sync roadmap |
| `/jaan-to:learn-report` | View learning system dashboard |

### Key Paths

| Path | Purpose |
|------|---------|
| `skills/` | Skill definitions (plugin-relative) |
| `jaan-to/config/settings.yaml` | Project configuration (v3.0.0+) |
| `jaan-to/context/` | Context templates (project-relative) |
| `jaan-to/templates/` | Output templates (project-relative) |
| `jaan-to/outputs/` | Generated outputs (project-relative) |
| `jaan-to/learn/` | Learning files (project-relative) |
| `.claude-plugin/plugin.json` | Plugin manifest |
| `docs/roadmap/tasks/` | Task details |

### Skill Naming

| Pattern | Example |
|---------|---------|
| Role-based: `{role}-{domain}-{action}` | `/jaan-to:pm-prd-write` |
| Internal: `{domain}-{action}` | `/jaan-to:skill-create` |
| Directory: `skills/{skill-name}/` | `skills/jaan-to:pm-prd-write/` |
