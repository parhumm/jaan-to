# jaan.to Roadmap

> See [vision.md](vision.md) for philosophy and concepts

---

## Overview

| Phase | Focus | Status |
|-------|-------|--------|
| v1.x | Foundation, plugin migration, stabilization | Done |
| v2.x | Directory restructure, research, story writing | Done |
| v3.x | Customization, roadmap tooling, interactive prompts | Done |
| 4 | Development workflow | Planned |
| 5 | Role skills (137 across 11 roles) | Planned |
| 6 | MCP connectors | Planned |
| 7 | Testing and polish | Planned |
| 8 | Distribution | Planned |

---

## v1.x — Foundation and Plugin Migration

### v1.0.0 — Initial Release (`fdbd152`)

All pre-plugin work landed in a single initial commit:

- 10 skills: pm-prd-write, data-gtm-datalayer, skill-create, skill-update, docs-create, docs-update, learn-add, research-about, research-add, roadmap-add
- Two-phase workflow with human approval checkpoints
- Validation hooks (PRD sections, feedback capture)
- Learning system (LEARN.md per skill, three-layer learning)
- Context system (tech.md, team.md, integrations.md, boundaries.md)
- Agents: quality-reviewer, context-scout
- Plugin manifest and bootstrap script
- Documentation (README, guides, style guide, vision, roadmap)

### v1.0.0 → v1.3.0 — Plugin Stabilization

- Marketplace distribution (marketplace.json, plugin.json schema fixes)
- Project-relative path resolution (`c5dbc1f`)
- 66+ stale path references fixed across docs and roadmap files
- Clean plugin installation (`scripts/build-dist.sh`, `scripts/verify-install.sh`)
- Plugin format aligned to official Claude Code standards

### v1.3.0 — Naming Convention (`0e541a6`)

- Skill naming standardized: `jaan-to-{role}-{domain}-{action}` (role-based) and `to-jaan-{domain}-{action}` (internal)
- All directories, scripts, and documentation updated

### v1.3.1 — LEARN File Fix (`8ea0a12`)

- All 9 content-generating skills reliably read LEARN files before execution
- Introduced Pre-Execution block pattern (mandatory first action)

---

## v2.x — Restructuring and New Skills

### v2.0.0 — Directory Rename (`852c3d9`)

- **Breaking**: `.jaan-to/` renamed to `jaan-to/` (non-hidden directory)
- Bootstrap auto-migration for existing projects
- Version management rules established (tag + changelog per release)

### v2.0.1 — Schema Alignment (`1cc62ee`)

- Marketplace and plugin manifests aligned to official Claude Code schema
- Deprecated output styles removed

### v2.1.0 — Research Consolidation (`bf9413e`)

- Merged `to-jaan-research-about` + `to-jaan-research-add` into `/jaan-to-pm-research-about`
- Auto-detects input type (topic string vs file/URL)
- Renamed from internal (`to-jaan-*`) to role-based (`jaan-to-pm-*`) convention

### v2.1.1 — Research Quality and Role Skills Catalog (`f5fd860`)

- Research skill restructured to restore original focused workflow (-14% file size)
- Role skills catalog expanded to 137 skills across 11 roles
- Per-role skill files created (11 files in `tasks/role-skills/`)
- Userflow schema diagrams added to all role-skill files

### v2.2.0 — Story Writing and Research Infrastructure (`dd12b2e`)

- **New skill**: `/jaan-to-pm-story-write` — User stories with Given/When/Then AC, INVEST principles, edge case mapping, Jira CSV and Linear JSON export
- Deep research documents added: acceptance criteria, QA test cases, backend task breakdown, PR review, frontend task breakdown, UX research synthesis, documentation generation

---

## v3.x — Customization, Roadmap Tooling, Interactive Prompts

### v3.0.0 — Multi-Layer Customization System (`ae91303`)

The largest architectural change since v1.0.0. Introduced full project-level customization.

**Configuration**:
- Multi-layer config: plugin `config/defaults.yaml` + project `jaan-to/config/settings.yaml`
- Path customization via `$JAAN_*` environment variables (`$JAAN_TEMPLATES_DIR`, `$JAAN_LEARN_DIR`, `$JAAN_CONTEXT_DIR`, `$JAAN_OUTPUTS_DIR`)

**Templates and Learning**:
- Template variables: `{{field}}`, `{{env:VAR}}`, `{{config:key}}`, `{{import:path#section}}`
- Learning merge strategy (combine plugin + project lessons)

**Tech Stack Integration**:
- Skills auto-reference project tech stack from `jaan-to/context/tech.md`
- Enhanced `tech.md` with structured sections and anchors

**Migration**:
- All 10 skills migrated to v3.0.0 patterns
- Migration guide: [docs/guides/migration-v3.md](../../docs/guides/migration-v3.md)
- 38+ E2E test assertions across 5 test suites

### v3.1.0 — Roadmap Tooling and Meta-Skills (`5745a6e`)

- **New skill**: `/to-jaan-roadmap-update` — Sync roadmap with git history, mark tasks, manage releases, validate structure
- Post-commit roadmap hook for automatic task status updates
- Meta-skills v3.0.0 support: skill-create (8 components), skill-update (7 compliance checks + migration wizard), docs/extending expanded to ~1300 lines (`f77d4e6`)
- Customization guide for v3.0.0 configuration system
- Role-skills catalog updated for v3.0.0 compliance and WordPress skills

### v3.2.0 — Interactive Prompts (`68bddb1`)

- AskUserQuestion interactive prompts added to all 11 skills (~73 text prompts converted)
- Skill creation spec updated with "User Interaction Patterns" section
- V3.8 AskUserQuestion compliance check in `/to-jaan-skill-update`

---

## Unreleased

- **New skill**: `/jaan-to-dev-stack-detect` — Detect project tech stack automatically (`d3dbb66`)
- **New skill**: `/jaan-to-ux-heatmap-analyze` — Analyze heatmap CSV + screenshots for UX research reports (first UX role skill)

---

## Phase 4: Development Workflow

> Details: [tasks/development-workflow.md](tasks/development-workflow.md) | [tasks/lsp-support.md](tasks/lsp-support.md)

- [ ] Project constitution document (`context/constitution.md`) — 9 immutable development principles
- [ ] Complexity tracking in outputs — `[NEEDS CLARIFICATION]`, `[COMPLEXITY]`, `[EXCEPTION]`, `[TRADEOFF]` markers
- [ ] LSP support — Bundle TypeScript + Python language server configs, make skills LSP-aware

---

## Phase 5: Role Skills (137 across 11 roles)

> Details: [tasks/role-skills.md](tasks/role-skills.md)

137 skills cataloged across 11 roles. Quick-win skills (no MCP required) are built first, followed by advanced skills that depend on MCP connectors.

All new skills must follow v3.0.0 patterns: `$JAAN_*` environment variables, template variables, tech stack integration, and pass `/to-jaan-skill-update` validation.

| Role | Total | Quick Wins | Advanced | File |
|------|-------|------------|----------|------|
| PM | 23 | 17 | 6 | [pm.md](tasks/role-skills/pm.md) |
| DEV | 17 | 13 | 4 | [dev.md](tasks/role-skills/dev.md) |
| QA | 12 | 8 | 4 | [qa.md](tasks/role-skills/qa.md) |
| DATA | 14 | 8 | 6 | [data.md](tasks/role-skills/data.md) |
| GROWTH | 15 | 9 | 6 | [growth.md](tasks/role-skills/growth.md) |
| UX | 20 | 15 | 5 | [ux.md](tasks/role-skills/ux.md) |
| SEC | 4 | 4 | 0 | [sec.md](tasks/role-skills/sec.md) |
| DELIVERY | 8 | 8 | 0 | [delivery.md](tasks/role-skills/delivery.md) |
| SRE | 8 | 4 | 4 | [sre.md](tasks/role-skills/sre.md) |
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
| `/jaan-to-pm-prd-write` | Generate PRD from initiative |
| `/jaan-to-pm-research-about` | Deep research or add file/URL to index |
| `/jaan-to-pm-story-write` | Generate user stories with Given/When/Then AC |
| `/jaan-to-data-gtm-datalayer` | Generate GTM tracking code |
| `/to-jaan-skill-create` | Create new skill with wizard |
| `/to-jaan-skill-update` | Update existing skill |
| `/to-jaan-docs-create` | Create documentation with templates |
| `/to-jaan-docs-update` | Audit and update stale documentation |
| `/to-jaan-learn-add` | Add lesson to skill's LEARN.md |
| `/to-jaan-roadmap-add` | Add task to roadmap |
| `/to-jaan-roadmap-update` | Maintain and sync roadmap |
| `/jaan-to-dev-stack-detect` | Detect project tech stack |
| `/jaan-to-ux-heatmap-analyze` | Analyze heatmap CSV + screenshots for UX insights |

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
| `roadmaps/jaan-to/tasks/` | Task details |

### Skill Naming

| Pattern | Example |
|---------|---------|
| Role-based: `jaan-to-{role}-{domain}-{action}` | `/jaan-to-pm-prd-write` |
| Internal: `to-jaan-{domain}-{action}` | `/to-jaan-skill-create` |
| Directory: `skills/{skill-name}/` | `skills/jaan-to-pm-prd-write/` |
