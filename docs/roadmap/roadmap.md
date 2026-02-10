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

**Latest:** v4.5.1 — Standardize backend + frontend skill output paths

### v4.5.1 — Standardize backend + frontend skill output paths
- Aligned all 7 backend/frontend skills to `{role}/{domain}/{id}-{slug}/{id}-{slug}.md` convention (`387a084`)
- Removed redundant domain names from filenames (e.g., `{id}-data-model-{slug}.md` → `{id}-{slug}.md`)
- Fixed stale `dev-fe-*/dev-be-*` skill name references across skills, docs, and templates
- Added bootstrap migration for existing user outputs (4 migration blocks)
- Fixed missing skill categories in Docusaurus sidebar (`d489f60`)
- Refreshed website landing page for v4.5.0 (`a1400aa`)

### v4.5.0 — Add ux-flowchart-generate skill
- Added `ux-flowchart-generate` skill — generate GitHub-renderable Mermaid flowcharts from PRD/docs/codebase with evidence maps, confidence scoring, and unknowns lists (`df64dab`)
- LEARN.md seed from research 64/65-ux-flowchart-generate
- Plugin skill count updated from 31 to 32

### v4.4.0 — Add release-iterate-changelog skill
- Added `release-iterate-changelog` skill — changelog generation with user impact notes and support guidance from git history (`e19911c`)
- New `release` role with documentation (`7623812`)
- LEARN.md seed from research 66-release-iterate-changelog (`e19911c`)

### v4.3.0 — WordPress plugin PR review skill
- Added `wp-pr-review` skill — 5-phase WordPress plugin PR review with security scanning, confidence scoring, and optional PR commenting (`b5edd39`)
- New `wp` role (WordPress) with `references/` directory pattern for progressive disclosure
- Plugin skill count updated from 29 to 30

### v4.2.1 — Fix backend-scaffold command picker display
- Fixed `backend-scaffold` displaying as `/jaan-to:backend-scaffold` — removed YAML-unsafe colon from description (`c1c5f0d`)
- Added colon detection to `validate-skills.sh` to prevent future YAML parsing issues (`c1c5f0d`)
- Learn files tracked in repository (`9683ab7`)
- Lesson added to skill-create LEARN.md: No colons in YAML descriptions (`c0b0285`)

### v4.2.0 — Backend & frontend scaffold skills
- Added `backend-scaffold` skill — generate production-ready backend code (Fastify/Prisma/Zod, Laravel, Go) from API contracts, data models, and task breakdowns (`6ef0c32`)
- Added `frontend-scaffold` skill — convert designs to React 19/Next.js 15 scaffolds with TailwindCSS v4, typed API hooks, and accessibility (`6ef0c32`)
- LEARN.md seed files for both skills from research 63-dev-scaffolds
- Plugin skill count updated from 27 to 29
- Config seed updated with both skills; dev role active count 4 → 6

### v4.1.1 — Fix hardcoded paths across all skills
- Replaced all hardcoded `jaan-to/outputs/`, `jaan-to/context/`, `jaan-to/templates/` with `$JAAN_*` env vars across 19 skill files (`dc70857`)
- Added automated path scan in skill-create and skill-update to prevent regressions

### v4.1.0 — Light/Full mode for detect skills
- All 6 detect skills support `--light` (default) and `--full` modes
- Light mode: 1 summary file per domain, reduced steps, lower token usage
- Full mode (`--full`): All steps and files, identical to previous behavior
- detect-pack handles mixed light/full inputs from other domains
- Documentation updated for all detect skills

### v4.0.0 — Batch skill rename (breaking)
- Renamed 5 skills: `dev-be-data-model` → `backend-data-model`, `dev-be-task-breakdown` → `backend-task-breakdown`, `dev-api-contract` → `backend-api-contract`, `dev-fe-design` → `frontend-design`, `dev-fe-task-breakdown` → `frontend-task-breakdown` (`d93cbdc`)
- Moved documentation to role-based directories (`docs/skills/backend/`, `docs/skills/frontend/`)
- Updated output paths to `outputs/backend/` and `outputs/frontend/`
- Added bootstrap migration for automatic output path migration
- Fixed language setting keys and cross-skill command references

### v3.24.0 — Multi-platform support for detect skills
- Multi-platform monorepo analysis (web, backend, mobile, TV apps) with auto-detection (`f57a406`)
- Platform-scoped filenames with backward compatibility (`d7a1667`)
- Cross-platform risk heatmap and merged pack consolidation (`8768b41`)
- pack-detect renamed to detect-pack for consistency (`aed1c3f`)
- 6 templates updated with platform variables (`d7a1667`)
- Multi-platform documentation and migration guide (`a955bc7`)

### v3.23.1 — Detect output paths standardized
- All 6 detect skills now write to `$JAAN_OUTPUTS_DIR/detect/` instead of `docs/current/` (`6bde383`)

### v3.23.0 — Detect & Knowledge Pack (6 skills)
- 6 detect skills: detect-dev, detect-design, detect-writing, detect-product, detect-ux, detect-pack (`52eb72f`..`50a75f5`)
- dev-stack-detect merged into detect-dev and removed (`bb9d0a7`, `9d944de`)
- 30+ reference files updated, bootstrap updated (`9d944de`)
- All detect docs aligned with implementations (`29901ae`)
- Bootstrap .gitignore fix (`c95e4a9`)

### v3.22.0 — Language settings in all 21 skills
- Language settings support in all 21 skills (`b7cfa00`)
- Docusaurus documentation site (`7bec2d3`)
- Roadmap moved to docs/roadmap/ (`f332657`)
- Versioning unified — removed -dev suffix (`37516ab`)

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

## Phase 5: Detect & Knowledge Pack (6 skills) — DONE

> Details: [tasks/role-skills/detect.md](tasks/role-skills/detect.md)

Evidence-based repo audits that produce `$JAAN_OUTPUTS_DIR/detect/` knowledge. All detect skills are Quick Wins (no MCP required). Each outputs machine-parseable markdown with YAML frontmatter, SARIF-like evidence blocks, and confidence scoring.

Pipeline: detect-dev + detect-design + detect-writing + detect-product + detect-ux → detect-pack

- [x] `/jaan-to:detect-dev` — Engineering audit with OpenSSF scoring (`52eb72f`)
- [x] `/jaan-to:detect-design` — Design system detection with drift findings (`280e4f7`)
- [x] `/jaan-to:detect-writing` — Writing system extraction with NNg tone scoring (`eb0b4f5`)
- [x] `/jaan-to:detect-product` — Product reality extraction with 3-layer evidence (`ef3d455`)
- [x] `/jaan-to:detect-ux` — UX audit with Nielsen heuristics and journey mapping (`6fa7cb5`)
- [x] `/jaan-to:detect-pack` — Consolidate detect outputs into knowledge index (`50a75f5`)
- [x] Merge `dev-stack-detect` into `detect-dev` and remove (`bb9d0a7`)
- [x] Update all references (30+ files) (`9d944de`)
- [x] Align detect docs with implementations (`29901ae`)

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

### v4.5.1 — Standardize backend + frontend skill output paths (`387a084`)

- [x] Standardize output paths to `{role}/{domain}/{id}-{slug}/` convention across all 7 backend/frontend skills (`387a084`)
- [x] Remove redundant domain names from filenames (`387a084`)
- [x] Fix stale `dev-fe-*/dev-be-*` references in skills and docs (`387a084`)
- [x] Add bootstrap migration for existing user outputs (`387a084`)
- [x] Fix Docusaurus sidebar missing skill categories (`d489f60`)

### v4.4.0 — Add release-iterate-changelog skill (`e19911c`)

- [x] `/jaan-to:release-iterate-changelog` — Generate changelog with user impact notes and support guidance (`e19911c`)
- [x] New `release` role with documentation (`7623812`)
- [x] LEARN.md seed from research 66-release-iterate-changelog (`e19911c`)

### v4.2.0 — Backend & frontend scaffold skills (`6ef0c32`)

- [x] `/jaan-to:backend-scaffold` — Generate production-ready backend code from specs (`6ef0c32`)
- [x] `/jaan-to:frontend-scaffold` — Convert designs to React/Next.js scaffold code (`6ef0c32`)
- [x] LEARN.md seed files for both scaffold skills (`6ef0c32`)

### v4.0.0 — Batch skill rename (`d93cbdc`)

- [x] Renamed 5 skills: `dev-be-data-model` → `backend-data-model`, `dev-be-task-breakdown` → `backend-task-breakdown`, `dev-api-contract` → `backend-api-contract`, `dev-fe-design` → `frontend-design`, `dev-fe-task-breakdown` → `frontend-task-breakdown` (`3ab9a93`..`d93cbdc`)
- [x] Moved documentation to role-based directories (`docs/skills/backend/`, `docs/skills/frontend/`) (`1aa0b73`)
- [x] Updated output paths to `outputs/backend/` and `outputs/frontend/` (`fb0ddff`)
- [x] Added bootstrap migration for automatic output path migration (`d93cbdc`)
- [x] Fixed language setting keys and cross-skill command references (`d93cbdc`)

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

- [x] Plugin marketplace installation (`/plugin marketplace add parhumm/jaan-to`)
- [x] Fix hardcoded `jaan-to/` paths across all skills — replaced with `$JAAN_*` env vars so outputs write to project directory, not plugin directory (`4197238`, `dc70857`)
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
| `/jaan-to:backend-scaffold` | Generate production-ready backend code from specs |
| `/jaan-to:frontend-scaffold` | Convert designs to React/Next.js scaffold code |
| `/jaan-to:ux-heatmap-analyze` | Analyze heatmap CSV + screenshots |
| `/jaan-to:ux-microcopy-write` | Multi-language UX microcopy |
| `/jaan-to:ux-research-synthesize` | Synthesize UX research findings |
| `/jaan-to:qa-test-cases` | Generate test cases from PRDs |
| `/jaan-to:wp-pr-review` | Review WordPress plugin PRs for security and standards |
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
