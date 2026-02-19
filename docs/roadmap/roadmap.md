---
title: "jaan.to Roadmap"
sidebar_position: 1
---

# jaan.to Roadmap

> See [vision.md](vision.md) for philosophy and concepts

---

## Overview

| Phase | Focus                                            | Status                                |
| ----- | ------------------------------------------------ | ------------------------------------- |
| 1     | Plugin architecture (10 skills)                  | **Done**                              |
| 2     | Migration & standards                            | **Done**                              |
| 3     | Customization & config system                    | **Done**                              |
| 4     | Detect & Knowledge Pack (6 skills)               | **Done**                              |
| 5     | Idea to Product pipeline (43 skills)             | **Done**                              |
| 6     | Priority skills & infrastructure                 | Planned                               |
| 7     | MCP connectors (24 documented)                   | Planned                               |
| 8     | Extended role skills (remaining from 142 catalog) | Planned                               |
| 9     | Testing and polish                               | Planned                               |
| 10    | Distribution                                     | Partial                               |

---

## Version History

For complete release history, see [CHANGELOG.md](/changelog).

**Latest:** v7.1.1 (44 skills)

---

## Unreleased

- [x] Security audit remediation — 13 findings fixed, `set -euo pipefail` enforced, skill permissions narrowed
- [x] Automated security enforcement — `scripts/validate-security.sh`, CI gate, `/jaan-release` + `/jaan-issue-review` integration
- [x] `jaan-init` Co-Authored-By attribution for git commits and PRs ([#109](https://github.com/parhumm/jaan-to/issues/109))
- [x] `pm-prd-write` output readability, document flow, RTL support ([#141](https://github.com/parhumm/jaan-to/issues/141))
- [x] Agent Skills open standard compatibility — All 44 skills compliant with agentskills.io spec (license, compatibility, trigger phrases, marketplace discovery, naming spec, E2E tests, CI enforcement)

---

## Shipped Skills (44)

> Added across v1.0.0–v7.1.0. See [CHANGELOG.md](/changelog) for per-version details.

| Role | # | Skills |
|------|---|--------|
| Backend | 6 | api-contract, data-model, pr-review, scaffold, service-implement, task-breakdown |
| Frontend | 3 | design, scaffold, task-breakdown |
| PM | 3 | prd-write, research-about, story-write |
| UX | 4 | flowchart-generate, heatmap-analyze, microcopy-write, research-synthesize |
| QA | 3 | test-cases, test-generate, test-run |
| Detect | 6 | dev, design, pack, product, ux, writing |
| Dev | 3 | output-integrate, project-assemble, verify |
| DevOps | 2 | deploy-activate, infra-scaffold |
| Data | 1 | gtm-datalayer |
| Security | 1 | audit-remediate |
| Release | 1 | iterate-changelog |
| WordPress | 1 | pr-review |
| Core | 10 | jaan-init, jaan-issue-report, skill-create, skill-update, docs-create, docs-update, learn-add, roadmap-add, roadmap-update, team-ship |

---

## Phase 1: Plugin Architecture — Done

> v1.0.0 — see [CHANGELOG.md](/changelog)

Skills/agents/hooks architecture, 10 initial skills (PM, Data, Core), learning system, context templates, two-phase workflow with human approval, bootstrap setup.

---

## Phase 2: Migration & Standards — Done

> v2.0.0–v2.2.0 — see [CHANGELOG.md](/changelog)

Directory rename `.jaan-to/` → `jaan-to/`, research skills merge, pm-story-write with INVEST validation and Given/When/Then acceptance criteria.

---

## Phase 3: Customization & Config — Done

> v3.0.0–v3.22.0 — see [CHANGELOG.md](/changelog)

Multi-layer YAML config, `$JAAN_*` path variables, template variables, language preference system, ID-based output structure, marketplace distribution, Docusaurus documentation site.

---

## Phase 4: Detect & Knowledge Pack — Done

> v3.23.0–v4.1.0 — see [CHANGELOG.md](/changelog)

6 detect skills (dev, design, writing, product, ux, pack) with SARIF-like evidence, 4-level confidence scoring, multi-platform monorepo support, light/full detection modes.

---

## Phase 5: Idea to Product Pipeline — Done

> v3.3.0–v7.1.0 — see [CHANGELOG.md](/changelog)

The [Idea to Product Guide](https://github.com/parhumm/jaanify/blob/main/docs/idea-to-product.md) walks through the full pipeline — research, PRD, design, code generation, testing, and deployment — with minimum human intervention. Each skill's output feeds the next.

Complete spec-to-ship workflow across 13 roles: Research → Specification → Design → Planning → Scaffolding → Quality → Infrastructure → Integration → Release. Token optimization (v7.0.0) reduced skill sizes 25-60%. Asset embedding (v7.1.0) for document-generating skills.


---

## Phase 6: Priority Skills & Infrastructure

### New Skills
- [ ] `skill-create /ux-flowchart-png` — Convert `/ux-flowchart-generate` Mermaid outputs to PNG (Python script) and auto-embed in documents ([#124](https://github.com/parhumm/jaan-to/issues/124)) → [details](tasks/ux-flowchart-png.md)
- [ ] `skill-create /frontend-pr-review` — Frontend-focused PR review for React/Next.js (performance, accessibility, hooks, bundle impact) ([#125](https://github.com/parhumm/jaan-to/issues/125)) → [details](tasks/frontend-pr-review.md)
- [ ] `skill-create /detect-security` — Dedicated security/vulnerability detection; extract security scope from `detect-dev`, `detect-pack`, and other `detect-*` skills ([#126](https://github.com/parhumm/jaan-to/issues/126)) → [details](tasks/detect-security.md)
- [ ] `skill-create /pm-jira-export` — Convert markdown outputs to Jira-ready copy-paste format + Jira MCP support ([#127](https://github.com/parhumm/jaan-to/issues/127)) → [details](tasks/pm-jira-export.md)
- [ ] `skill-create /pm-okr-controller` — Objective and OKR tracking for PM role ([#128](https://github.com/parhumm/jaan-to/issues/128)) → [details](tasks/pm-okr-controller.md)

### Skill Updates
- [ ] `skill-update /frontend-design` — Review and update UX/frontend skills for current best practices ([#129](https://github.com/parhumm/jaan-to/issues/129)) → [details](tasks/frontend-design-update.md)
- [ ] `skill-update /frontend-task-breakdown` — Shadcn MCP integration + React component-aware breakdowns ([#130](https://github.com/parhumm/jaan-to/issues/130)) → [details](tasks/frontend-task-breakdown-update.md)

### Architecture
- [ ] Security output proxy — Separate security docs/outputs into `jaan-to-sec-output/` gitsubmodule (mirrors `jaan-to/outputs/` structure, tech-lead-only access) ([#131](https://github.com/parhumm/jaan-to/issues/131)) → [details](tasks/security-output-proxy.md)
- [ ] GitLab support — First-class GitLab MCP + `glab` CLI + GitLab App across all relevant skills ([#132](https://github.com/parhumm/jaan-to/issues/132)) → [details](tasks/gitlab-support.md)

### WP Consolidation
- [ ] Consolidate WP skills: 25 → max 7 — Full WP plugin lifecycle (Plan → Build → Secure → Test → Release → Support → Maintain) ([#133](https://github.com/parhumm/jaan-to/issues/133)) → [details](tasks/roles-wp-skills.md)

### PM & Batch Skills
- [ ] PM role gap completion — Ship remaining PM skills from 21-skill catalog + batch workflow ([#134](https://github.com/parhumm/jaan-to/issues/134)) → [details](tasks/pm-role-gap.md)
- [ ] Batch/combination skills per role — Role-level pipeline skills (WP, PM, Dev, UX, QA) for shipping ideas with minimum human actions ([#135](https://github.com/parhumm/jaan-to/issues/135)) → [details](tasks/batch-skills.md)

### Agent Teams Integration
- [x] `team-ship` orchestration skill — Role-based agent teams to ship ideas from concept to production → [research](../research/77-agent-teams-integration.md)
  - [x] `skills/team-ship/roles.md` — Role definitions with model selection and dependency graph
  - [x] `skills/team-ship/SKILL.md` — Orchestration logic (≤500 lines, fork-isolated)
  - [x] `docs/extending/team-ship-reference.md` — Spawn prompts, dependency algo, checkpoint schema
  - [x] Agent team hooks: TaskCompleted quality gate, TeammateIdle redirect, roles-sync drift detection
  - [x] `skill-create` Step 14.5 + `skill-update` Step 11.5 — Auto-sync roles.md
  - [x] Configuration: `agent_teams_*` settings in defaults.yaml

### Distribution
- [ ] Jaanify → starter template — Convert `parhumm/jaanify` into smart starter template for one-command idea-to-ship ([#136](https://github.com/parhumm/jaan-to/issues/136)) → [details](tasks/jaanify-template.md)
- [ ] Branding + website with skill demos — Landing page, skill output demos, flow-of-use walkthroughs (priority: next week) ([#137](https://github.com/parhumm/jaan-to/issues/137)) → [details](tasks/branding-website.md)

### Development Workflow

> Details: [tasks/development-workflow.md](tasks/development-workflow.md) | [tasks/lsp-support.md](tasks/lsp-support.md)

- [ ] Project constitution document (`context/constitution.md`) — 9 immutable development principles ([#138](https://github.com/parhumm/jaan-to/issues/138)) → [details](tasks/development-workflow.md)
- [ ] Complexity tracking in outputs — `[NEEDS CLARIFICATION]`, `[COMPLEXITY]`, `[EXCEPTION]`, `[TRADEOFF]` markers ([#139](https://github.com/parhumm/jaan-to/issues/139)) → [details](tasks/development-workflow.md)
- [ ] LSP support — Bundle TypeScript + Python language server configs, make skills LSP-aware ([#140](https://github.com/parhumm/jaan-to/issues/140)) → [details](tasks/lsp-support.md)

---

## Phase 7: MCP Connectors

> Details: [tasks/mcp-connectors.md](tasks/mcp-connectors.md)

MCP connectors provide real system context to skills. Skills stay generic; MCP provides per-product data from actual tools.

- **Core MCPs (11)**: GA4, GitLab, Jira, Figma, GSC, Clarity, Sentry, BigQuery, Playwright, OpenAPI, dbt Cloud
- **Extended MCPs (13)**: Notion, Slack, GitHub, Linear, Mixpanel, Confluence, Snowflake, PostgreSQL, Ahrefs, Semrush, LambdaTest, Google Drive, Memory
- **Infrastructure**: Deferred loading for token savings, Context7 integration, model routing per skill type

---

## Phase 8: Extended Role Skills

> Full catalog: [tasks/role-skills.md](tasks/role-skills.md)

Remaining skills from the original 142-skill catalog require MCP connectors or additional research. All new skills must follow v3.0.0 patterns: `$JAAN_*` environment variables, template variables, tech stack integration, and pass `/jaan-to:skill-update` validation.

---

## Phase 9: Testing and Polish

- [ ] E2E test framework in `tests/` with mocked MCP responses
- [ ] JSON export alongside markdown for all skill outputs
- [ ] External notifications (Slack integration)
- [ ] Fix `learn-report` skill hook script for macOS compatibility (Bash 3.2 — needs 4+ for `declare -A`)

---

## Phase 10: Distribution

> Details: [tasks/distribution.md](tasks/distribution.md)

- [x] Agent Skills open standard compatibility (agentskills.io) — marketplace.json discovery, all 44 skills compliant
- [ ] Multi-agent compatibility research (Cursor, Copilot, Windsurf, Gemini)
- [ ] CLI installer (`jaan-to-cli`) for one-command setup
- [ ] Public documentation site and branding guidelines

---

## Reference

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
| Directory: `skills/{skill-name}/` | `skills/pm-prd-write/` |
