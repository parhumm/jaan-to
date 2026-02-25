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
| 6 | Role skills (53 shipped across 17 role prefixes) | In Progress |
| 7 | MCP connectors (1/24 shipped) | In Progress |
| 8 | Testing and polish | Planned |
| 9 | Distribution & CLI transformation (1/7 done) | Partial |

---

## Version History

For complete release history, see [CHANGELOG.md](/changelog).

**Latest:** v7.5.1 (53 skills) | **Next:** v7.6.0 (53+ skills)

---

## Unreleased

- [ ] Role Orchestrator Skills — 6 per-role orchestrator skills (`/pm`, `/ux`, `/dev`, `/qa`, `/devops`, `/sec`) using Claude Code Agent Teams. Each orchestrator coordinates all sub-skills within its role via dynamic discovery (`sub-skills.md`). Update `team-ship` to delegate to orchestrators as meta-orchestrator with backward-compatible fallback. → [details](tasks/role-orchestrators.md)
- [ ] Skill Lifecycle Automation — 5 workflow automation skills discovered via `pm-skill-discover` (est. ~333 min/week savings):
  - [ ] `dev-adapter-sync` (Must) — Mirror skill files from skills/ to adapters/codex/ automatically
  - [ ] `dev-skill-batch-update` (Must) — Apply uniform changes across all SKILL.md files at once
  - [ ] `dev-docs-sync` (Should) — Auto-sync CHANGELOG, roadmap, DEPENDENCIES, READMEs, marketplace.json
  - [ ] `qa-skill-validate` (Should) — Validate skills, diagnose failures, auto-fix
  - [ ] `devops-adapter-rebuild` (Could) — Rebuild codex adapter after changes

---

## v7.5.1 — 2026-02-25

- [x] Security hardening (6 rounds) — Closed multiple prompt injection bypass vectors in pre-tool security gate
- [x] Layered prompt injection defenses across all distributed skills
- [x] `pm-changelog-rewrite` skill — New changelog rewrite and maintenance workflows
- [x] Enhanced `pm-roadmap-update` and `release-iterate-changelog` with file discovery, auto-commit, issue refs
- [x] 53 skills total

---

## v7.5.0 — 2026-02-24

- [x] Windows NTFS compatibility fix (#157) — Replace `jaan-to:` colon prefix with `jaan-to-` dash prefix in all learn/template filenames, auto-migration in `bootstrap.sh` with three-branch collision handling
- [x] TDD/BDD/AI orchestration quality skills — 4 new skills + 15 enhanced, from research doc 76 (qa-test-mutate, qa-tdd-orchestrate, qa-contract-validate, qa-quality-gate + 11 enhanced skills)
- [x] `qa-issue-validate` skill — Validate GitHub/GitLab issues against codebase with RCA and threat scanning
- [x] `qa-issue-report` skill — Report issues to any GitHub/GitLab repository with smart context analysis
- [x] Convert internal roadmap skills to generic pm-* skills — `pm-roadmap-add` and `pm-roadmap-update` replace internal `roadmap-add`/`roadmap-update`
- [x] `pm-skill-discover` skill — Detect repeated workflow patterns and suggest skills to automate them
- [x] 53 skills total (was 45 in v7.1.0)

---

## v7.4.0 — 2026-02-22

- [x] Context7 MCP integration + `/dev-docs-fetch` skill — library docs fetch, smart caching, auto-detect from tech.md → [details](tasks/mcp-context7.md)
- [x] Dual-runtime MCP support — Codex config.toml auto-configuration, `validate-mcp-servers.sh` parity checks, CI dual-runtime MCP gate
- [x] MCP infrastructure hardening — config update safety, `.mcp.json` build distribution, stale count fixes

---

## v7.3.0 — 2026-02-21

- [x] Multi-runtime Codex support — dual-runtime governance, single-source build targets, codex runner, installer-first skillpack, CI dual-runtime enforcement
- [x] Codex runner fixes — zero-argument handling, `.agents/` native discovery path
- [x] Website hero install UX redesign — clipboard buttons, local logos, improved layout

---

## v7.2.0 — 2026-02-19

- [x] Security audit remediation — 13 findings fixed, `set -euo pipefail` enforced, skill permissions narrowed
- [x] Automated security enforcement — `scripts/validate-security.sh`, CI gate, `/jaan-release` + `/jaan-issue-review` integration
- [x] `jaan-init` Co-Authored-By attribution for git commits and PRs ([#109](https://github.com/parhumm/jaan-to/issues/109))
- [x] `pm-prd-write` output readability, document flow, RTL support ([#141](https://github.com/parhumm/jaan-to/issues/141))
- [x] Agent Skills open standard compatibility — All 44 skills compliant with agentskills.io spec (license, compatibility, trigger phrases, marketplace discovery, naming spec, E2E tests, CI enforcement)
- [x] `team-ship` agent teams orchestration skill — Role-based AI teammates for spec-to-ship pipeline
- [x] Compliance hardening — Skill Alignment sections (44 skills), Definition of Done (5 skills), hardcoded path sanitization

---

## Phase 4: Development Workflow

> Details: [tasks/development-workflow.md](tasks/development-workflow.md) | [tasks/lsp-support.md](tasks/lsp-support.md)

- [ ] Project constitution document (`context/constitution.md`) — 9 immutable development principles
- [ ] ~~Complexity tracking in outputs~~ — Deferred: overlaps with existing LEARN.md feedback system
- [ ] LSP support — Bundle TypeScript + Python language server configs, make skills LSP-aware

---

## Phase 5: Detect & Knowledge Pack (6 skills) — DONE

> Details: [tasks/role-skills/detect.md](tasks/role-skills/detect.md) | Completed in v3.23.0–v6.1.0 — see [CHANGELOG.md](/changelog)

6 detect skills shipped: detect-dev, detect-design, detect-writing, detect-product, detect-ux, detect-pack. Pipeline produces `$JAAN_OUTPUTS_DIR/detect/` knowledge with SARIF-like evidence and confidence scoring.

---

## Phase 6: Role Skills (142 across 17 role prefixes)

> Details: [tasks/role-skills.md](tasks/role-skills.md)

142 skills cataloged across 17 role prefixes. Quick-win skills (no MCP required) are built first, followed by advanced skills that depend on MCP connectors.

All new skills must follow v3.0.0 patterns: `$JAAN_*` environment variables, template variables, tech stack integration, and pass `/skill-update` validation.

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

**Completed work**: 53 skills shipped across v4.0.0–v7.5.0 — see [CHANGELOG.md](/changelog) for details.

---

## Phase 7: MCP Connectors (24 documented)

> Details: [tasks/mcp-connectors.md](tasks/mcp-connectors.md)

MCP connectors provide real system context to skills. Skills stay generic; MCP provides per-product data from actual tools.

- **Core MCPs (11)**: GA4, GitLab, Jira, Figma, GSC, Clarity, Sentry, BigQuery, Playwright, OpenAPI, dbt Cloud
- **Extended MCPs (13)**: Notion, Slack, GitHub, Linear, Mixpanel, Confluence, Snowflake, PostgreSQL, Ahrefs, Semrush, LambdaTest, Google Drive, Memory
- **Infrastructure**: Deferred loading for token savings, Context7 integration, model routing per skill type
- [x] Context7 MCP integration + `/dev-docs-fetch` skill — library docs fetch, smart caching, auto-detect from tech.md → [details](tasks/mcp-context7.md)

---

## Phase 8: Testing and Polish

- [ ] E2E test framework in `tests/` with mocked MCP responses
- [ ] JSON export alongside markdown for all skill outputs
- [ ] External notifications (Slack integration)
- [ ] **[BLOCKER]** Fix `learn-report` skill hook script for macOS compatibility (Bash 3.2 — needs 4+ for `declare -A`)

---

## Phase 9: Distribution & CLI Transformation

> Details: [tasks/distribution.md](tasks/distribution.md) | [tasks/cli-transformation.md](tasks/cli-transformation.md)

### Standalone CLI (`jaan-to` npm package)

Build jaan-to as an independent CLI app using the Claude Agent SDK (TypeScript). Dual distribution: plugin stays for Claude Code users, CLI reaches everyone else. Skills, templates, learning, and context files are shared between both runtimes.

- [ ] Phase A: MVP CLI — SKILL.md parser, config loader, env var resolver, `jaan-to init`, `jaan-to run <skill>` → [details](tasks/cli-transformation.md)
- [ ] Phase B: Feature parity — Learning merge, template variables, subagents, hooks, shell script ports
- [ ] Phase C: CLI-native features — CI/CD mode (`--ci`), batch mode, progress UI, session management
- [ ] Phase D: Multi-model — Provider abstraction layer, OpenAI/Gemini/Ollama support

### Cross-Agent Compatibility

- [x] Agent Skills open standard compatibility (agentskills.io) — marketplace.json discovery, all 44 skills compliant
- [ ] Multi-agent compatibility research (Cursor, Copilot, Windsurf, Gemini)

### Public Presence

- [ ] Public documentation site and branding guidelines
- [ ] npm package publication (`jaan-to`)

---

## Quick Reference

### Commands

| Command | Description |
|---------|-------------|
| `/pm-prd-write` | Generate PRD from initiative |
| `/pm-research-about` | Deep research or add file/URL to index |
| `/pm-story-write` | Generate user stories with Given/When/Then AC |
| `/data-gtm-datalayer` | Generate GTM tracking code |
| `/detect-dev` | Engineering audit with scored findings |
| `/detect-design` | Design system detection with drift findings |
| `/detect-writing` | Writing system extraction with tone scoring |
| `/detect-product` | Product reality extraction with evidence |
| `/detect-ux` | UX audit with journey/pain-point findings |
| `/detect-pack` | Consolidate detect outputs into knowledge index |
| `/frontend-task-breakdown` | Frontend task breakdown with component hierarchy |
| `/backend-task-breakdown` | Backend task breakdown from PRDs |
| `/frontend-design` | Frontend component design |
| `/backend-data-model` | Generate data model docs with constraints, indexes, and migrations |
| `/backend-api-contract` | Generate OpenAPI 3.1 contracts from API entities |
| `/backend-pr-review` | Review backend PRs for security, performance, and code quality |
| `/backend-scaffold` | Generate production-ready backend code from specs |
| `/frontend-scaffold` | Convert designs to React/Next.js scaffold code |
| `/ux-heatmap-analyze` | Analyze heatmap CSV + screenshots |
| `/ux-microcopy-write` | Multi-language UX microcopy |
| `/ux-research-synthesize` | Synthesize UX research findings |
| `/ux-flowchart-generate` | Generate Mermaid flowcharts from PRD/docs/codebase |
| `/qa-test-cases` | Generate test cases from PRDs |
| `/wp-pr-review` | Review WordPress plugin PRs for security and standards |
| `/dev-project-assemble` | Wire scaffold outputs into runnable project structure |
| `/backend-service-implement` | Generate service implementations from scaffold stubs |
| `/qa-test-generate` | Generate runnable Vitest/Playwright tests from BDD cases |
| `/sec-audit-remediate` | Generate security fixes from detect-dev findings |
| `/dev-output-integrate` | Copy generated outputs into project with config merging |
| `/devops-infra-scaffold` | Generate CI/CD, Dockerfiles, deployment configs |
| `/devops-deploy-activate` | Activate deployment pipeline with secrets and platform provisioning |
| `/qa-test-run` | Execute tests, diagnose failures, auto-fix, generate coverage reports |
| `/qa-test-mutate` | Run mutation testing and generate survivor reports |
| `/qa-tdd-orchestrate` | Orchestrate RED/GREEN/REFACTOR TDD cycle with isolated agents |
| `/qa-contract-validate` | Validate API contracts with Spectral, oasdiff, Prism, Schemathesis |
| `/qa-quality-gate` | Compute composite quality score from upstream skill outputs |
| `/qa-issue-validate` | Validate GitHub/GitLab issues against codebase with RCA |
| `/qa-issue-report` | Report issues to any GitHub/GitLab repository |
| `/pm-skill-discover` | Detect repeated workflow patterns and suggest skills |
| `/dev-verify` | Validate build pipeline and running services with health checks |
| `/dev-docs-fetch` | Fetch and cache library docs via Context7 MCP (Phase 7) |
| `/release-iterate-changelog` | Generate changelog with user impact and support guidance |
| `/jaan-init` | Initialize jaan-to for a project |
| `/jaan-issue-report` | Report issues to jaan-to GitHub repo |
| `/skill-create` | Create new skill with wizard |
| `/skill-update` | Update existing skill |
| `/docs-create` | Create documentation with templates |
| `/docs-update` | Audit and update stale documentation |
| `/learn-add` | Add lesson to skill's LEARN.md |
| `/pm-roadmap-add` | Add prioritized items to project roadmap |
| `/pm-roadmap-update` | Review and maintain project roadmap |
| `/learn-report` | View learning system dashboard |

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
| Role-based: `{role}-{domain}-{action}` | `/pm-prd-write` |
| Internal: `{domain}-{action}` | `/skill-create` |
| Directory: `skills/{skill-name}/` | `skills/pm-prd-write/` |
