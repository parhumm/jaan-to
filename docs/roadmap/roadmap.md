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
| 5 | Role skills (137 across 11 roles) | In Progress |
| 6 | MCP connectors | Planned |
| 7 | Testing and polish | Planned |
| 8 | Distribution | Partial |

---

## Version History

For complete release history, see [CHANGELOG.md](/changelog).

**Latest:** v3.21.0 — Jaanify showcase examples

### v3.21.0 — Jaanify showcase examples
- Examples replaced with Jaanify showcase README (`0bf37a1`)
- Plugin and marketplace version sync fix (`807cad5`)

### v3.20.0 — Language preference system
- Language preference for plugin conversation and output (`34df511`)
- Documentation: customization guide and seed files updated (`5fe2a18`)

---

## Unreleased

---

## Phase 4: Development Workflow

> Details: [tasks/development-workflow.md](tasks/development-workflow.md) | [tasks/lsp-support.md](tasks/lsp-support.md)

- [ ] Project constitution document (`context/constitution.md`) — 9 immutable development principles
- [ ] Complexity tracking in outputs — `[NEEDS CLARIFICATION]`, `[COMPLEXITY]`, `[EXCEPTION]`, `[TRADEOFF]` markers
- [ ] LSP support — Bundle TypeScript + Python language server configs, make skills LSP-aware

---

## Phase 5: Role Skills (141 across 11 roles)

> Details: [tasks/role-skills.md](tasks/role-skills.md)

141 skills cataloged across 11 roles. Quick-win skills (no MCP required) are built first, followed by advanced skills that depend on MCP connectors.

All new skills must follow v3.0.0 patterns: `$JAAN_*` environment variables, template variables, tech stack integration, and pass `/jaan-to:skill-update` validation.

| Role | Total | Quick Wins | Advanced | File |
|------|-------|------------|----------|------|
| PM | 24 | 18 | 6 | [pm.md](tasks/role-skills/pm.md) |
| DEV | 19 | 15 | 4 | [dev.md](tasks/role-skills/dev.md) |
| QA | 12 | 8 | 4 | [qa.md](tasks/role-skills/qa.md) |
| DATA | 14 | 8 | 6 | [data.md](tasks/role-skills/data.md) |
| GROWTH | 15 | 9 | 6 | [growth.md](tasks/role-skills/growth.md) |
| UX | 20 | 15 | 5 | [ux.md](tasks/role-skills/ux.md) |
| SEC | 4 | 4 | 0 | [sec.md](tasks/role-skills/sec.md) |
| DELIVERY | 8 | 8 | 0 | [delivery.md](tasks/role-skills/delivery.md) |
| SRE | 9 | 5 | 4 | [sre.md](tasks/role-skills/sre.md) |
| SUPPORT | 8 | 8 | 0 | [support.md](tasks/role-skills/support.md) |
| RELEASE | 8 | 8 | 0 | [release.md](tasks/role-skills/release.md) |

**Priority** (by research rank): qa-test-cases (#1), data-sql-query (#2), ux-research-synthesize (#8), qa-bug-report (#10), growth-meta-write (#12). Full priority list in [tasks/role-skills.md](tasks/role-skills.md#priority-order-by-research-rank).

---

## Phase 6: MCP Connectors (24 documented)

> Details: [tasks/mcp-connectors.md](tasks/mcp-connectors.md)

MCP connectors provide real system context to skills. Skills stay generic; MCP provides per-product data from actual tools.

- **Core MCPs (11)**: GA4, GitLab, Jira, Figma, GSC, Clarity, Sentry, BigQuery, Playwright, OpenAPI, dbt Cloud
- **Extended MCPs (13)**: Notion, Slack, GitHub, Linear, Mixpanel, Confluence, Snowflake, PostgreSQL, Ahrefs, Semrush, LambdaTest, Google Drive, Memory
- **Infrastructure**: Deferred loading for token savings, Context7 integration, model routing per skill type

---

## Phase 7: Testing and Polish

- [ ] E2E test framework in `tests/` with mocked MCP responses
- [ ] JSON export alongside markdown for all skill outputs
- [ ] External notifications (Slack integration)
- [ ] Fix `learn-report` skill hook script for macOS compatibility (Bash 3.2 — needs 4+ for `declare -A`)

---

## Phase 8: Distribution

> Details: [tasks/distribution.md](tasks/distribution.md)

- [x] Plugin marketplace installation (`/plugin marketplace add parhumm/jaan-to`)
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
| `/jaan-to:dev-stack-detect` | Detect project tech stack |
| `/jaan-to:dev-fe-task-breakdown` | Frontend task breakdown with component hierarchy |
| `/jaan-to:dev-be-task-breakdown` | Backend task breakdown from PRDs |
| `/jaan-to:dev-fe-design` | Frontend component design |
| `/jaan-to:dev-be-data-model` | Generate data model docs with constraints, indexes, and migrations |
| `/jaan-to:dev-api-contract` | Generate OpenAPI 3.1 contracts from API entities |
| `/jaan-to:ux-heatmap-analyze` | Analyze heatmap CSV + screenshots |
| `/jaan-to:ux-microcopy-write` | Multi-language UX microcopy |
| `/jaan-to:ux-research-synthesize` | Synthesize UX research findings |
| `/jaan-to:qa-test-cases` | Generate test cases from PRDs |
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
