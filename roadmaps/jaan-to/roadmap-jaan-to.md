# jaan.to Roadmap

> See [vision-jaan-to.md](vision-jaan-to.md) for philosophy and concepts

---

## Phase Overview

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | Foundation & Optimization | Done |
| 2 | Learning & Documentation | Done |
| 2.5 | Plugin Migration | Done |
| 3 | Development Workflow | Pending |
| 4 | Quick Win Skills (18) | Pending |
| 5 | MCP Connectors | Pending |
| 6 | Advanced Role Skills (23) | Pending |
| 7 | Testing & Polish | Pending |
| 8 | Distribution | Pending |

---

## Phase 1: Foundation & Optimization (Done)

- [x] Directory structure (`1d9fd35`)
- [x] Config `jaan-to/config.md` (`dd8e360`)
- [x] Guardrails `jaan-to/boundaries/safe-paths.md` (`c233efe`)
- [x] Settings `.claude/settings.json` (`9d0891e`)
- [x] PRD skill + template (`85db425`, `fb0f826`)
- [x] Two-phase workflow with hard stop (`ba1856e`)
- [x] Validation hook for PRD (`363cbe9`)
- [x] CLAUDE.md project context (`4bf9d5d`)
- [x] Token optimization - model routing (`ba1856e`)

## Phase 2: Learning & Documentation (Done)

> Details: [tasks/learning-system.md](tasks/learning-system.md)

- [x] LEARN.md files alongside skills (`d554fa6`)
- [x] Stacks: `tech.md`, `team.md`, `integrations.md` (`bd0eff3`)
- [x] PostToolUse feedback capture hook (`b2e7687`)
- [x] `/jaan-to:jaan-learn-add` command for feedback routing (`5775df6`)
- [x] Auto-commit option for `/jaan-to:jaan-learn-add` (`74e4163`)
- [x] `/jaan-to:jaan-docs-create` skill for documentation authoring (`b3b2383`)
- [x] `/jaan-to:jaan-docs-update` skill with git-based staleness detection (`b3b2383`, `df9cdea`)
- [x] Auto-invoke `/jaan-to:jaan-learn-add` from `/jaan-to:pm-prd-write` (`9d9c7e1`)
- [x] Human-focused documentation structure (`48bf028`)
- [x] Documentation style guide (`de92247`)
- [x] Rename pm-spec-prd-write → pm-prd-write (`7c7c29d`)
- [x] Rename docs/skills/internal/ → docs/skills/core/ (`aad168c`)
- [x] Skill creation specification for AI + humans

## Phase 2.5: Plugin Migration (Done)

- [x] Plugin manifest (`.claude-plugin/plugin.json`)
- [x] Migrate 10 skills from `.claude/skills/` to `skills/` (flat structure)
- [x] Context files: `jaan-to/` → `context/` (config, boundaries, tech, team, integrations)
- [x] Hook system: `jaan-to/hooks/` → `scripts/` + `hooks/hooks.json`
- [x] Agents: `agents/context-scout.md`, `agents/quality-reviewer.md`
- [x] Output styles: `outputStyles/enterprise-doc.md`, `outputStyles/concise-summary.md`
- [x] Command namespace: `/to-jaan-*` → `/jaan-to:*` (colon-separated)
- [x] Documentation: 8 new docs created, 27 existing docs updated
- [x] Marketplace distribution (`marketplace.json` catalog format, manifest component paths, README install instructions)
- [x] Directory structure reference updated
- [x] Clean plugin installation — exclude non-essential files; `scripts/build-dist.sh` produces clean distribution
- [x] Store jaan.to output files in `.jaan-to/` inside the target project; bootstrap seeds context, templates, learn, docs
- [x] End-to-end plugin install testing — `scripts/verify-install.sh` validates all bootstrap artifacts

## Phase 3: Development Workflow

> Details: [tasks/development-workflow.md](tasks/development-workflow.md)

- [ ] Project constitution document (`jaan-to/constitution.md`) - Immutable development principles
- [ ] Complexity tracking in outputs - Document tradeoffs and exceptions
- [ ] Support official Claude Code output styles format ([docs](https://code.claude.com/docs/en/output-styles))
- [ ] Support LSP (Language Server Protocol) — bundle LSP configs + make skills LSP-aware → [details](tasks/lsp-support.md)

## Phase 4: Quick Win Skills (18)

> Details: [tasks/role-skills.md](tasks/role-skills.md) | No MCP required

- [x] `/jaan-to:jaan-skill-create` skill with web research and PR workflow
- [x] `/jaan-to:jaan-skill-update` skill with specification compliance
- [ ] Update `/jaan-to:jaan-skill-create` to integrate `/jaan-to:jaan-research-about` (optional, recommended) for research-informed skill planning

**Ranked by research impact (1-19):**

- [ ] `/jaan-to:qa-test-cases` - Test cases from AC with edge cases (**Rank #1**)
- [ ] `/jaan-to:data-sql-query` - Ad-hoc SQL from natural language (**Rank #2**)
- [ ] `/jaan-to:pm-story-write` - User stories with Given/When/Then AC (Rank #6)
- [ ] `/jaan-to:ux-research-synthesize` - Research findings synthesis with themes (Rank #8)
- [ ] `/jaan-to:qa-bug-report` - Structured bug reports with repro steps (Rank #10)
- [ ] `/jaan-to:growth-meta-write` - Meta titles/descriptions with CTR optimization (Rank #12)
- [ ] `/jaan-to:dev-docs-generate` - Technical documentation: README, API docs, runbooks (Rank #14)
- [ ] `/jaan-to:pm-feedback-synthesize` - Customer feedback synthesis with themes (Rank #15)
- [ ] `/jaan-to:ux-persona-create` - User personas with goals, pain points, JTBD (Rank #16)

**Additional quick wins (unranked):**

- [ ] `/jaan-to:pm-decision-brief` - 1-page decision record with options, recommendation, risks
- [ ] `/jaan-to:dev-tech-plan` - Tech approach with architecture, tradeoffs, risks
- [ ] `/jaan-to:dev-test-plan` - Dev-owned test plan with unit/integration/e2e scope
- [ ] `/jaan-to:qa-test-matrix` - Risk-based matrix: flows × states × devices × env
- [ ] `/jaan-to:qa-bug-triage` - Dedupe + severity + repro hints + next action
- [ ] `/jaan-to:data-event-spec` - GA4-ready event/param spec with naming, triggers
- [ ] `/jaan-to:data-metric-spec` - Metric definition, formula, caveats, owner
- [ ] `/jaan-to:ux-flow-spec` - Flow spec with happy path + error states
- [ ] `/jaan-to:ux-microcopy-write` - Labels, helper text, errors, toasts, empty states

## Phase 5: MCP Connectors

> Details: [tasks/mcp-connectors.md](tasks/mcp-connectors.md)

### Core MCPs (11 - skill enablement priority)

- [ ] GA4 MCP - Enables 12 skills (PM metrics, DATA funnels, GROWTH reports)
- [ ] GitLab MCP - Enables 9 skills (DEV PRs/pipelines, QA automation)
- [ ] Jira MCP - Enables 6 skills (PM backlog, QA bugs/triage)
- [ ] Figma MCP - Enables 6 skills (UX flows, design specs, QA states)
- [ ] GSC MCP - Enables 5 skills (GROWTH SEO/keywords)
- [ ] Clarity MCP - Enables 5 skills (UX behavior, PM insights)
- [ ] Sentry MCP - Enables 4 skills (DEV errors, QA regressions)
- [ ] BigQuery MCP - Enables 2 skills (DATA cohorts, dbt)
- [ ] Playwright MCP - Enables 2 skills (QA automation)
- [ ] OpenAPI/Swagger MCP - Enables 1 skill (DEV api-contract)
- [ ] dbt Cloud MCP - Enables 1 skill (DATA models)

### Extended MCPs (13 - from MCP research report)

**Cross-role high impact:**

- [ ] Notion MCP - Enables PM (PRDs, OKRs), UX (research), All (knowledge base) | Free
- [ ] Slack MCP - Enables All roles (feedback synthesis, notifications) | Free
- [ ] GitHub MCP - Enables 9 skills (DEV PRs/code review, QA automation) | Free - GitLab alternative

**Role-specific:**

- [ ] Linear MCP - Enables 6 skills (PM backlog, QA bugs) | Free - Jira alternative
- [ ] Mixpanel MCP (Official) - Enables PM metrics, DATA funnels/cohorts | Free
- [ ] Confluence MCP - Enables PM docs, DEV technical docs | Free

**Targeted:**

- [ ] Snowflake MCP - Enables DATA warehouse queries, cohorts | Freemium - BigQuery alternative
- [ ] PostgreSQL MCP - Enables DATA direct SQL queries | Free
- [ ] Ahrefs MCP - Enables GROWTH keyword research, backlinks | Free server
- [ ] Semrush MCP - Enables GROWTH competitive SEO analysis | Free server
- [ ] LambdaTest MCP - Enables QA cross-browser testing | Freemium

**Supporting:**

- [ ] Google Drive MCP - Enables All (research files, docs access) | Free
- [ ] Memory MCP - Enables All (persistent context across sessions) | Free

### Community Plugins (from [firecrawl best-plugins list](https://www.firecrawl.dev/blog/best-claude-code-plugins)):

- [ ] Firecrawl MCP - Turns websites into clean, LLM-ready data
- [ ] Ralph Loop - Autonomous AI agent loop
- [ ] Security Guidance MCP - Keeps code and secrets safe
- [ ] Frontend Design MCP - Makes AI-generated UI look professional
- [ ] Code Review MCP - Reviews PRs before merge
- [ ] Chrome DevTools MCP - Debugs browser from Claude

### Infrastructure:

- [ ] MCP deferred loading for token savings
- [ ] MCP Context7 integration → [details](tasks/mcp-context7.md)
- [ ] Model routing per skill type

## Phase 6: Advanced Role Skills (23)

> Details: [tasks/role-skills.md](tasks/role-skills.md) | Requires MCP connectors

### PM (3)

- [ ] `/jaan-to:pm-north-star` - North star metric + drivers + boundaries + cadence
- [ ] `/jaan-to:pm-scope-slice` - MVP vs Later slicing with milestones and dependencies
- [ ] `/jaan-to:pm-release-review` - Post-release KPI deltas, learnings, follow-ups

### DEV (3)

- [ ] `/jaan-to:dev-api-contract` - OpenAPI contract with payloads, errors, examples
- [ ] `/jaan-to:dev-pr-review` - PR review pack with risky files, hints, checklist
- [ ] `/jaan-to:dev-ship-check` - Pre-ship checklist with go/no-go recommendation

### QA (3)

- [ ] `/jaan-to:qa-automation-plan` - What to automate now vs later + flakiness risk
- [ ] `/jaan-to:qa-regression-runbook` - Step-by-step regression runbook with timing/owners
- [ ] `/jaan-to:qa-release-signoff` - Go/No-Go summary with evidence and risks

### DATA (5)

- [ ] `/jaan-to:data-funnel-review` - Funnel baseline + drop-offs + hypotheses
- [ ] `/jaan-to:data-experiment-design` - Experiment plan: hypothesis, metrics, ramp criteria
- [ ] `/jaan-to:data-anomaly-triage` - Triage pack: scope, causes, next checks
- [ ] `/jaan-to:data-cohort-analyze` - Cohort/retention analysis with LTV projections
- [ ] `/jaan-to:data-dbt-model` - dbt staging/mart models with tests (Rank #19)

### GROWTH (6)

- [ ] `/jaan-to:growth-content-outline` - Writing-ready outline with H1-H3, FAQs, entities
- [ ] `/jaan-to:growth-keyword-brief` - Keyword + intent map with content angle
- [ ] `/jaan-to:growth-seo-audit` - On-page checklist: title/meta, headings, links
- [ ] `/jaan-to:growth-seo-check` - Technical audit: indexability, crawl signals
- [ ] `/jaan-to:growth-weekly-report` - Weekly wins/losses, top pages, actions
- [ ] `/jaan-to:growth-content-optimize` - Existing content refresh for traffic recovery (Rank #18)

### UX (3)

- [ ] `/jaan-to:ux-research-plan` - Research plan: questions, method, participants
- [ ] `/jaan-to:ux-heuristic-review` - Heuristic review with issues, severity, fixes
- [ ] `/jaan-to:ux-competitive-review` - Competitive teardown with patterns + opportunities

## Phase 7: Testing & Polish

- [ ] E2E test framework in `tests/`
- [ ] JSON export alongside markdown
- [ ] External notifications (Slack)
- [ ] Mocked MCP responses for testing

## Phase 8: Distribution

> Details: [tasks/distribution.md](tasks/distribution.md)

- [ ] Installation via `claude plugin install` (pending marketplace submission)
- [ ] Multi-agent compatibility research (Cursor, Copilot, Windsurf, Gemini)
- [ ] CLI installer tool (`jaan-to-cli`) for easy setup
- [ ] Public documentation site and branding guidelines

---

## Quick Reference

### Commands

| Command | Description |
|---------|-------------|
| `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| `/jaan-to:jaan-roadmap-add` | [Internal] Add task to roadmap |
| `/jaan-to:jaan-learn-add` | Add lesson to skill's LEARN.md |
| `/jaan-to:jaan-docs-create` | Create documentation with templates |
| `/jaan-to:jaan-docs-update` | Audit and update stale documentation |
| `/jaan-to:jaan-skill-create` | Create new skill with wizard |
| `/jaan-to:jaan-skill-update` | Update existing skill |

### Key Paths

| Path | Purpose |
|------|---------|
| `skills/` | Skill definitions (plugin-relative) |
| `.jaan-to/docs/create-skill.md` | Skill creation specification (project) |
| `.jaan-to/context/` | Context templates (project-relative) |
| `.jaan-to/templates/` | Output templates (project-relative) |
| `.jaan-to/outputs/` | Generated outputs (project-relative) |
| `.jaan-to/learn/` | Learning files (project-relative) |
| `.claude-plugin/plugin.json` | Plugin manifest |
| `roadmaps/jaan-to/tasks/` | Task details |

### Skill Naming

| Pattern | Example |
|---------|---------|
| Logical: `role-domain:action` | `pm-prd:write` |
| Command: `/jaan-to:role-domain-action` | `/jaan-to:pm-prd-write` |
| Directory: `skills/role-domain-action/` | `skills/pm-prd-write/` |
