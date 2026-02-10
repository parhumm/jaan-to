# Changelog

All notable changes to the jaan.to Claude Code Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [5.0.0] - 2026-02-10

### Changed
- **Bootstrap now opt-in per project** — Projects require `/jaan-to:jaan-init` to activate. Existing projects with `jaan-to/` directory continue working unchanged. New skill: `/jaan-to:jaan-init`
- **Token optimization (v5)** — Reduced plugin token footprint across all sessions and skill invocations
  - **CLAUDE.md trimmed** from 282 → 97 lines — extracted Output Structure, Naming Conventions, and Development Workflow to `docs/extending/` reference files (~1,700 tokens/session saved)
  - **Frontmatter flags** — Added `disable-model-invocation` to 7 internal skills and `context: fork` to 6 detect skills (~280 tokens/session + ~30K-48K tokens per detect run saved)
  - **Boilerplate extraction** — Extracted Language Settings and Pre-Execution blocks from 31 skills into shared `docs/extending/language-protocol.md` and `docs/extending/pre-execution-protocol.md` (~6,350 tokens per skill invocation saved)
  - **Body trimming** — Extracted reference material from 8 large skills (skill-create, skill-update, detect-dev, pm-research-about, backend-task-breakdown, ux-microcopy-write, detect-pack, ux-research-synthesize) into dedicated `docs/extending/` reference files (~3.5K-5.5K tokens per trimmed skill invocation saved)
  - **Total savings**: ~2,000 tokens/session permanently, ~7K-48K tokens per skill invocation

---

## [4.5.1] - 2026-02-10

### Fixed
- **Standardized output paths for all 7 backend/frontend skills** — Aligned to `{role}/{domain}/{id}-{slug}/{id}-{slug}.md` convention, removing redundant domain names from filenames (e.g., `{id}-data-model-{slug}.md` → `{id}-{slug}.md`). Fixed stale `dev-fe-*/dev-be-*` references across 30 files (`387a084`)
- **Bootstrap migration for existing outputs** — Added 4 migration blocks to `bootstrap.sh`: `dev/contract/` → `backend/api-contract/`, backend/frontend numbered folder splitting by content pattern, and `frontend/components/` → `frontend/design/`. Existing user outputs auto-migrate on next session start (`387a084`)
- **Docusaurus sidebar missing skill categories** — Wired backend, frontend, release, and wp skill categories into sidebar config (`d489f60`)
- **Aligned specification docs to `{id}-{slug}.md` convention** — Updated CLAUDE.md, skill-create, skill-update specs, and all roadmap task output paths (dev, backend, wp-*) to use `{id}-{slug}.md` instead of `{id}-{report-type}-{slug}.md`. Fixed stale `dev-fe-state-machine` refs. Updated config seed to v4.5.1 (`c86c877`)
- **Corrected plugin skill count** — Fixed 32→31 in plugin.json, marketplace.json, and website landing page; added `ux-flowchart-generate` and `release-iterate-changelog` to roadmap quick reference commands table (`359f317`, `1851802`)

### Changed
- **Website landing page** — Refreshed for v4.5.0 release (`a1400aa`)

### Documentation
- **Synced skills README indexes** — Updated 4 stale `docs/skills/**/README.md` files (skills root, pm, dev, ux), created missing QA README, enhanced `docs-create` and `docs-update` skills to auto-maintain README indexes (`202a581`)

---

## [4.5.0] - 2026-02-09

### Added
- **`ux-flowchart-generate` skill** (`/jaan-to:ux-flowchart-generate`) — Generate GitHub-renderable Mermaid flowcharts from PRDs, docs, codebases, or any combination with evidence maps tracing every node to its source, confidence scoring, and structured unknowns lists. Supports 4 source types (`prd`, `doc`, `repo`, `mixed`), 4 diagram goals (`userflow`, `systemflow`, `architecture`, `stateflow`), 17 machine-checkable quality gates, auto-split for large diagrams, update mode with manual section preservation, and GitHub Mermaid v11.4.1 constraint enforcement
- **LEARN.md seed file** for ux-flowchart-generate — Pre-populated with research-validated lessons from 40+ sources (research 64/65-ux-flowchart-generate)

### Changed
- **Plugin skill count** — Updated from 31 to 32 skills across plugin.json and marketplace.json descriptions
- **Config seed** — Added ux-flowchart-generate to Available Skills table

---

## [4.4.0] - 2026-02-09

### Added
- **`release-iterate-changelog` skill** (`/jaan-to:release-iterate-changelog`) — Generate user-facing changelogs with impact notes and support guidance from git history. 5 input modes (auto-generate, create, release, add, from-input), Conventional Commits parsing with freeform heuristic fallback, Keep a Changelog formatting, SemVer bump suggestion, user impact analysis (high/medium/low), and support guidance for downstream help articles
- **`release` role** — New role for release management skills (iterate chain: top-fixes → changelog → help-article)
- **Release skills documentation** — `docs/skills/release/iterate-changelog.md` and `docs/skills/release/README.md`

### Changed
- **Plugin skill count** — Updated from 30 to 31 skills across plugin.json and marketplace.json
- **Config seed** — Added `release-iterate-changelog` to available skills table
- **Skills index** — Added `release` role to `docs/skills/README.md` Available Roles table

---

## [4.3.0] - 2026-02-09

### Added
- **`wp-pr-review` skill** (`/jaan-to:wp-pr-review`) — Review WordPress plugin pull requests for security vulnerabilities, performance issues, WPCS standards violations, backward compatibility, and add-on ecosystem impact. 5-phase workflow with deterministic grep scanning, confidence-scored findings (>=80 threshold), and optional PR comment posting via GitHub/GitLab CLI
- **`wp` role** — New WordPress-specific role for plugin development skills
- **`references/` directory pattern** — First skill to use progressive disclosure via reference files (5 checklists: security, performance, standards, vulnerability patterns, add-on ecosystem). Keeps SKILL.md under 500 lines while providing detailed knowledge on demand
- **WordPress skills documentation** — `docs/skills/wp/pr-review.md` and `docs/skills/wp/README.md`

### Changed
- **Plugin skill count** — Updated from 29 to 30 skills across plugin.json and marketplace.json
- **Config seed** — Added `wp` to enabled roles and `wp-pr-review` to available skills table
- **Skills index** — Added `wp` role to `docs/skills/README.md` Available Roles table

---

## [4.2.1] - 2026-02-09

### Fixed
- **`backend-scaffold` displaying as `/jaan-to:backend-scaffold` in command picker** — Removed YAML-unsafe colon from description (`specs: routes` → `with routes`). Claude Code's parser misinterpreted the colon-space as a key-value separator, corrupting skill metadata (`c1c5f0d`)

### Added
- **Colon detection in `validate-skills.sh`** — New validation pass flags any skill description containing `: ` (colon-space), preventing future YAML parsing issues (`c1c5f0d`)
- **Learn files tracked in repository** — All 9 LEARN.md files now committed to git for version control and collaboration (`9683ab7`)
- **Lesson: No colons in YAML descriptions** — Added to `skill-create` LEARN.md under Common Mistakes with symptom, fix, and prevention steps (`c0b0285`)

### Documentation
- Roadmap synced with v4.2.0 release (`ec9b334`)
- Research index updated with changelog skill research (`e2413fc`)
- Roadmap research refs and skill heading names fixed (`6969a80`)
- Description colon rules added to `docs/STYLE.md` and `docs/extending/create-skill.md` (`c1c5f0d`)

---

## [4.2.0] - 2026-02-09

### Added
- **`backend-scaffold` skill** (`/jaan-to:backend-scaffold`) — Generate production-ready backend code from API contracts, data models, and task breakdowns. Supports Node.js (Fastify v5 + Prisma + Zod), PHP (Laravel 12 / Symfony 7), and Go (Chi / stdlib). Includes routes, service layer, validation schemas, middleware, and RFC 9457 error handling
- **`frontend-scaffold` skill** (`/jaan-to:frontend-scaffold`) — Convert designs to React 19 / Next.js 15 component scaffolds with TailwindCSS v4 CSS-first config, typed API client hooks (Orval v7 + TanStack Query v5), Zustand v5 state management, and nuqs URL state. Generates components, hooks, types, pages, and config files
- **LEARN.md seed files** for both scaffold skills — Pre-populated with research-validated lessons (Better Questions, Edge Cases, Workflow, Common Mistakes) from research output 63-dev-scaffolds

### Changed
- **Plugin skill count** — Updated from 27 to 29 skills across plugin.json and marketplace.json descriptions
- **Config seed** — Added both scaffold skills to Available Skills table; updated dev role active count from 4 to 6

---

## [4.1.1] - 2026-02-09

### Fixed
- **Skills writing to plugin directory instead of project directory** — Replaced all hardcoded `jaan-to/outputs/`, `jaan-to/context/`, and `jaan-to/templates/` paths with `$JAAN_OUTPUTS_DIR`, `$JAAN_CONTEXT_DIR`, and `$JAAN_TEMPLATES_DIR` environment variables across 19 skill files
- **Restored intentional exception lines** in `skill-create` and `skill-update` that document deprecated v2.x patterns (bad examples, migration arrows)

### Added
- **Step 12.9: Automated Path Scan** in `skill-create` — scans generated SKILL.md for hardcoded paths before writing, preventing future regressions
- **V3.10: Display String Check** in `skill-update` — catches hardcoded paths in preview/confirmation text during skill compliance checks

---

## [4.1.0] - 2026-02-09

### Added
- **Light/Full mode for all 6 detect skills** — All detect skills (`detect-dev`, `detect-design`, `detect-writing`, `detect-product`, `detect-ux`, `detect-pack`) now support `--light` (default) and `--full` modes
  - **Light mode** (default, no flag): Reduced detection steps, single `summary.md` output per skill, `megathink` thinking mode — significantly lower token usage
  - **Full mode** (`--full`): All detection steps, all output files (9/6/7/7/6/4+), `ultrathink` thinking mode — identical to previous behavior
  - **detect-writing partial exception**: Backend/CLI platforms keep error message scoring even in light mode
  - **detect-pack mixed input handling**: Automatically detects whether each domain provided light-mode (`summary.md`) or full-mode (individual files) outputs
  - **Stale file cleanup**: Full mode deletes leftover `summary.md`; light mode preserves existing full-mode files
  - **N/A precedence**: Platform UI-presence checks always take priority over run_depth gates

### Changed
- **Detect skill documentation** — All 6 detect skill docs + README updated with light/full mode usage, output tables, and examples
- **Roadmap** — Added light/full mode tasks to Phase 5

---

## [4.0.0] - 2026-02-09

### Changed

- **[Breaking]** Renamed 5 dev skills to remove `dev-` prefix for cleaner naming:
  - `dev-be-data-model` → `backend-data-model` (`/jaan-to:backend-data-model`)
  - `dev-be-task-breakdown` → `backend-task-breakdown` (`/jaan-to:backend-task-breakdown`)
  - `dev-api-contract` → `backend-api-contract` (`/jaan-to:backend-api-contract`)
  - `dev-fe-design` → `frontend-design` (`/jaan-to:frontend-design`)
  - `dev-fe-task-breakdown` → `frontend-task-breakdown` (`/jaan-to:frontend-task-breakdown`)
- **Documentation reorganization** — Moved skill docs to role-based directories (`docs/skills/backend/`, `docs/skills/frontend/`)
- **Output paths simplified** — Skills now write to `outputs/backend/` and `outputs/frontend/` instead of `outputs/dev/backend/` and `outputs/dev/frontend/`

### Fixed

- **Bootstrap migration** — Automatically migrates existing outputs from old paths to new paths on session start
- **Language setting keys** — Updated per-skill language override keys to match new skill names
- **Cross-skill references** — Updated all command references in SKILL.md files and documentation

### Documentation

- All 104 files updated with new skill names and paths
- Research files updated (4 files: 52-backend-task-breakdown.md, 60-backend-data-model.md, 51-frontend-task-breakdown.md, research README)
- Website changelog synced with main CHANGELOG

---

## [3.24.0] - 2026-02-09

### Added
- **Multi-platform support in all 6 detect skills** — All detect skills (`detect-dev`, `detect-design`, `detect-writing`, `detect-product`, `detect-ux`, `detect-pack`) now automatically detect and analyze multi-platform monorepos (web, backend, mobile, TV apps, etc.)
  - **Platform auto-detection** — Scans folder structure using configurable patterns (`web/`, `backend/`, `mobile/`, etc.) with disambiguation rules for edge cases (microservices, Turborepo/Nx, mobile subfolders)
  - **Platform-scoped filenames** — Multi-platform outputs use flat files with platform suffixes (`stack-web.md`, `stack-backend.md`) instead of nested folders, maintaining backward compatibility
  - **Evidence ID prefixing** — Multi-platform format: `E-DEV-WEB-001`, `E-DSN-BACKEND-023`; single-platform format unchanged: `E-DEV-001`
  - **Cross-platform evidence linking** — Use `related_evidence` field to link findings across platforms (e.g., TypeScript issue in both web and backend)
  - **"Detect and Report N/A" pattern** — Non-applicable domains (e.g., Design for backend) produce minimal output with informational finding and perfect score (10.0)
  - **Merged pack** — detect-pack creates consolidated pack combining all platforms with cross-platform risk heatmap (platform × domain table), deduplicated findings, and unified unknowns backlog

### Changed
- **pack-detect renamed to detect-pack** — Command: `/jaan-to:detect-pack` (was `/jaan-to:pack-detect`); skill directory and 41 files renamed for naming consistency
- **Flat file architecture formalized** — detect outputs officially documented as exception to ID-based folder structure in CLAUDE.md (alongside research); rationale: detect skills produce system state snapshots (overwritten each run), not versioned reports (archived)
- **detect-pack orchestration enhanced** — Step 0 now asks "Is this a multi-platform project?" and displays platform-by-platform workflow guide
- **Evidence ID parsing updated** — Regex now handles both single-platform (`E-DEV-001`) and multi-platform (`E-DEV-WEB-001`) formats

### Documentation
- **Multi-platform sections added to all 6 detect skill docs** — Platform auto-detection, evidence ID formats, skip logic, and platform-specific behavior documented
- **Migration guide created** — Comprehensive v3.23 → v3.24 guide with FAQ, rollback instructions, and backward compatibility notes (`docs/guides/migration-v3.24.md`)
- **detect README updated** — Added multi-platform pipeline flow diagram, cross-platform linking examples, and shared standards updates
- **6 templates updated** — All detect templates now include `target.platform` field and evidence ID format examples

### Breaking Changes
- **Command rename**: `/jaan-to:pack-detect` → `/jaan-to:detect-pack` (old command removed)
- **Output paths** (backward compatible):
  - Single-platform: `detect/dev/stack.md` (unchanged)
  - Multi-platform: `detect/dev/stack-web.md`, `detect/dev/stack-backend.md` (new format)
- **Evidence IDs** (backward compatible): Both formats supported — single-platform `E-DEV-001`, multi-platform `E-DEV-WEB-001`

## [3.23.1] - 2026-02-09

### Changed
- **Detect skills output paths standardized** — All 6 detect skills (`detect-dev`, `detect-design`, `detect-product`, `detect-ux`, `detect-writing`, `detect-pack`) now write to `$JAAN_OUTPUTS_DIR/detect/{domain}/` instead of hardcoded `docs/current/{domain}/`, aligning with the plugin's configurable output system (`6bde383`)

## [3.23.0] - 2026-02-08

### Added
- **6 Detect & Knowledge Pack skills (Phase 5)** — Evidence-based repo audits with SARIF-compatible evidence, 4-level confidence scoring, and machine-parseable markdown output
  - `/jaan-to:detect-dev` — Engineering audit with OpenSSF-style scoring across 11+ language ecosystems, CI/CD security checks, and 9 output files (`52eb72f`)
  - `/jaan-to:detect-design` — Design system detection with drift findings (paired evidence), token inventory, component classification, and 6 output files (`280e4f7`)
  - `/jaan-to:detect-writing` — Writing system extraction with NNg tone dimensions (4 primary + 5 extended), 8-category UI copy classification, error message rubric, i18n maturity 0–5, and 6 output files (`eb0b4f5`)
  - `/jaan-to:detect-product` — Product reality extraction with 3-layer evidence model (surface + copy + code path), monetization/entitlement scanning, analytics SDK detection, and 7 output files (`ef3d455`)
  - `/jaan-to:detect-ux` — UX audit with framework-specific route extraction (React Router, Next.js, Vue Router, Angular, Express), Nielsen's 10 heuristics, Mermaid flow diagrams, and 7 output files (`6fa7cb5`)
  - `/jaan-to:detect-pack` — Consolidate all detect outputs into scored knowledge index with risk heatmap, evidence ID validation, unknowns backlog, and Step 0 orchestration for partial runs (`50a75f5`)

### Changed
- **`dev-stack-detect` merged into `detect-dev`** — All scanning patterns absorbed; old skill removed. Detection → `detect-dev`, context population remains via bootstrap (`bb9d0a7`, `9d944de`)
- **Bootstrap updated** — Suggests `/jaan-to:detect-pack` instead of `/jaan-to:dev-stack-detect` when context has placeholders (`9d944de`)
- **Plugin description** — Updated to reflect 27 skills (was 21)

### Documentation
- **Detect skill docs aligned with implementations** — All 7 docs updated with What It Scans tables, evidence ID namespaces, scoring formulas, and shared standards (`29901ae`)
- **Detect README** — Added pipeline flow diagram, output file counts, and Shared Standards section (`29901ae`)
- **`dev-stack-detect` deprecated** — Redirect doc pointing to `detect-dev` (`9d944de`)
- **30+ reference files updated** — All `dev-stack-detect` references replaced with `detect-dev`/`detect-pack` across docs, scripts, seeds, context, website, and examples (`9d944de`)

---

## [3.22.0] - 2026-02-08

### Added
- **Language settings in all 21 skills** — Every skill now reads language preference from `jaan-to/config/settings.yaml` on execution. Three variants: standard block (13 skills), code exception for dev/data skills (7 skills), microcopy exception for ux-microcopy-write. Updated skill-create template and validation checklist for future compliance (`b7cfa00`)
- **Docusaurus documentation site** — Full documentation site at `website/docs/` with sidebar navigation, roadmap integration, and detect skills docs (`7bec2d3`)

### Changed
- **Roadmap moved to docs/** — Relocated `roadmaps/jaan-to/` to `docs/roadmap/` and updated all references (`f332657`, `b845900`)
- **Versioning unified** — Removed `-dev` suffix convention, both branches use `X.Y.Z` format (`37516ab`)

### Documentation
- **Detect & Knowledge Pack** — Added 6 detect skills documentation and Phase 5 roadmap details (`6a1fd87`, `2848e94`)
- **4 gap skills identified** — Added dev-be-scaffold, dev-fe-scaffold, sre-pipeline-create, pm-trace-links to roadmap (`f470d3e`)
- **Research index updates** — Added repo-analysis output and content detection standards (`3888926`, `93e25b1`)

### Fixed
- **File naming** — Fixed file name inconsistencies (`c2ce826`)
- **Roadmap path references** — Updated all `roadmaps/jaan-to/` references to `docs/roadmap/` (`b845900`)

---

## [3.21.0] - 2026-02-08

### Changed
- **Examples replaced with Jaanify showcase** — Replaced starter-project examples with [Jaanify](https://github.com/parhumm/jaanify) README, a real-world project built entirely with jaan.to (`0bf37a1`)

### Fixed
- **Plugin and marketplace version sync** — Fixed `marketplace.json` plugins version mismatch (`807cad5`)

---

## [3.20.0] - 2026-02-08

### Added
- **Language preference system** — Set conversation and report language globally or per-skill via `settings.yaml`. Ask once on first skill run, persist for all future executions. Supports any language (en, fa, tr, etc.) with per-skill override (`language_{skill-name}`). Does not affect generated code, product localization, or ux-microcopy-write output.

### Documentation
- **Customization guide updated** — Added Step 2: Language Preference with settings table, YAML examples, scope boundaries, verification steps, and troubleshooting
- **Seed files doc updated** — Settings row now mentions language preference

---

## [3.19.0] - 2026-02-08

### Added
- **New skill: `dev-be-data-model`** — Generate comprehensive data model documentation from entity descriptions with Mermaid ER diagrams, engine-specific table definitions (PostgreSQL, MySQL, SQLite), ESR-ordered composite indexes, zero-downtime migration playbooks, and 5-dimension quality scorecard. Research-informed from 420-line compendium covering NLP constraint extraction, multi-tenancy patterns, and GDPR/retention strategies.

---

## [3.18.0] - 2026-02-08

### Added
- **New skill: `dev-api-contract`** — Generate OpenAPI 3.1 contracts from API resource entities with RFC 9457 error schemas, cursor-based pagination, flat `components/schemas` architecture, and named examples. Outputs `api.yaml` + companion markdown quick-start guide. Research-informed from 40+ sources.

---

## [3.17.0] - 2026-02-07

### Fixed
- **All 19 skills now discoverable** — Trimmed skill descriptions to fit Claude Code's 15,000 char system prompt budget; removed `Auto-triggers on:` and `Maps to:` lines from all SKILL.md description fields

### Added
- **CI: Skill budget validation** — New `scripts/validate-skills.sh` checks total description chars; added to `.github/workflows/release-check.yml` to block over-budget PRs
- **Spec: Description budget rules** — Updated `docs/extending/create-skill.md` with 120-char limit and budget documentation
- **Style: Skill description rules** — Added description length limits to `docs/STYLE.md`
- **skill-update: V3.9 compliance check** — Detects bloated descriptions during skill updates
- **skill-create: Lean descriptions** — Template no longer generates `Auto-triggers on:` / `Maps to:` lines

### Changed
- **Description format** — Descriptions are now 1-2 sentences (single-line YAML) instead of multi-line with metadata

---

## [3.16.3] - 2026-02-07

### Fixed
- **Spec: removed outdated "Logical Name" concept** — Removed colon-format `{role}:{domain-action}` references from `docs/extending/create-skill.md`; H1 title guidance now uses `# {name}` (kebab-case)
- **skill-create: fixed command format** — Command preview now shows `/jaan-to:{name}` instead of `/{name}`
- **skill-create: fixed spec path** — Validation step referenced wrong path `jaan-to/docs/create-skill.md` → `docs/extending/create-skill.md`
- **skill-create: template uses `{skill_name}`** — Replaced `{logical_name}` variable with `{skill_name}` in template.md
- **skill-update: fixed stale directory refs** — Updated `skills/jaan-to:pm-prd-write/` → `skills/pm-prd-write/` (2 locations)
- **skill-update: fixed spec path** — Same `jaan-to/docs/` → `docs/extending/` correction
- **LEARN.md files** — Fixed stale `jaan-to:pm-prd-write` directory references in both skill LEARN.md files

---

## [3.16.2] - 2026-02-07

### Changed
- **Skill naming standardization** — Removed redundant `jaan-to-` and `to-jaan-` prefixes from all 19 skill directories
  - Domain skills: `jaan-to-pm-prd-write` → `pm-prd-write` (12 skills)
  - Internal skills: `to-jaan-docs-create` → `docs-create` (7 skills)
  - Invocations now: `/jaan-to:pm-prd-write` instead of `/jaan-to:jaan-to-pm-prd-write`
- **Standardized colon-format names** — Replaced all `role:skill-name` shorthand with `role-skill-name` hyphen format across SKILL.md (Maps to, H1), templates, docs, and roadmaps
- **Updated all references** — scripts, agents, docs, roadmaps, seeds updated to use clean names with `/jaan-to:` prefix

### Fixed
- **Renamed doc file** — `docs/skills/dev/jaan-to-dev-be-task-breakdown.md` → `be-task-breakdown.md`
- **Fixed broken link paths** — Markdown links using `jaan-to:` in file paths corrected
- **README badge** — Updated stale version badge from 3.12.0 to 3.16.0
- **mcp-connectors.md** — Added missing `/jaan-to:` prefix to 76+ bare skill references

---

## [3.15.2] - 2026-02-07

### Fixed
- **Plugin installation failure** — Removed `skills`, `agents`, `hooks` fields from `plugin.json`
  - Root cause: `"agents": "./agents/"` triggers Claude Code manifest validation error: `agents: Invalid input`
  - Claude Code auto-discovers components from standard directories (`skills/`, `agents/`, `hooks/hooks.json`)
  - Official Anthropic plugins use minimal manifests with only `name`, `version`, `description`, `author`
- **CI release check** — Inverted component path validation to reject (not require) `skills`/`agents`/`hooks` in plugin.json

### Added
- **plugin.json Rules** in CLAUDE.md — Documented that component paths must never be declared in manifest
- **Troubleshooting entry** in README.md for "agents: Invalid input" error

---

## [3.15.1] - 2026-02-07

### Added
- **Troubleshooting Section** in README.md for plugin loading issues
- **Release Verification Step** (step 7) in CONTRIBUTING.md release checklist

### Fixed
- **Documented Workaround** for Claude Code v1/v2 registry sync bug affecting marketplace plugins
  - Users experiencing skills not loading can run: `/plugin uninstall jaan-to` then `/plugin install jaan-to@jaan-to`
  - This is a Claude Code bug, not a jaan-to issue — workaround documented for all users

---

## [3.15.0] - 2026-02-07

### Added
- **Two-Branch Development Workflow** — `main` for stable releases, `dev` for development/preview (`ba9c061`)
  - Users can install stable: `/plugin marketplace add parhumm/jaan-to`
  - Users can install dev: `/plugin marketplace add parhumm/jaan-to#dev`
  - Both branches use `X.Y.Z` format (e.g., `3.15.0`)
- **Version Management Scripts**
  - `scripts/bump-version.sh` — Update version in all 3 required locations atomically (plugin.json, marketplace.json top-level, marketplace.json plugins[0])
  - `scripts/setup-branch-protection.sh` — Configure GitHub branch protection (main: require PR + approval, dev: direct pushes allowed)
- **CI Release Validation** — `.github/workflows/release-check.yml` for PRs to main
  - Ensures all 3 version fields match
  - Checks CHANGELOG entry exists
  - Validates plugin.json has required component paths (skills, agents, hooks)

### Changed
- **Skill Workflow Alignment** — `/jaan-to:skill-create` and `/jaan-to:skill-update` now follow two-branch workflow (`ba9c061`)
  - Feature branches checkout from `dev` instead of `main`
  - PRs target `dev` branch (not `main`)
  - `gh pr create` uses `--base dev` flag
- **Documentation Updates**
  - README.md: Added stable/dev installation instructions, version switching guide
  - CONTRIBUTING.md: Added two-branch workflow documentation, release process checklist

### Fixed
- **Plugin Loading Issue** — Fixed skills not loading after marketplace installation (`d56ea2f`)
  - Root cause: plugin.json was missing component paths (`skills`, `agents`, `hooks`)
  - Added CI check to prevent regression

---

## [3.14.1] - 2026-02-07

### Fixed
- **Marketplace Schema Validation** — Fix `repository` field format in marketplace.json
  - Changed from npm-style object `{ "type": "git", "url": "..." }` to string `"https://github.com/parhumm/jaan-to"`
  - Resolves: `Invalid schema: plugins.0.repository: Expected string, received object`

---

## [3.14.0] - 2026-02-03

### Added
- **Frontend Component Design Skill** — `/jaan-to:dev-fe-design` generates distinctive, production-grade frontend component code (`48284c7`)
  - Creates working components in React, Vue, or vanilla JS/HTML based on tech.md detection
  - Generates bold, distinctive designs that avoid generic "AI slop" aesthetics (no Inter/Roboto, no purple gradients, unexpected layouts)
  - Full accessibility (WCAG AA minimum) with semantic HTML, ARIA, keyboard navigation, visible focus indicators
  - Responsive design (mobile-first) using modern CSS: Grid, Container Queries, Custom Properties, `:has()`, `prefers-color-scheme`
  - Complete deliverables: component code + documentation with design rationale + standalone preview file
  - Output structure: `dev/components/{id}-{slug}/` with ID-based folders and index management
  - Reads settings.yaml for design direction defaults, design.md for existing patterns, brand.md for guidelines
  - Complements `/jaan-to:dev-fe-task-breakdown`: task-breakdown plans what to build, fe-design builds the actual code
  - 478-line SKILL.md with two-phase workflow, 137-line template with variable syntax, 47-line LEARN.md with best practices

---

## [3.13.0] - 2026-02-03

### Added
- **Learning System Dashboard** — Make accumulated learning discoverable and actionable (`9f513c2`)
  - `scripts/learning-summary.sh` — Scan all LEARN.md files, count lessons per skill, extract Common Mistakes and Edge Cases sections, generate markdown/JSON report with stats
  - `/jaan-to:learn-report` command — Display formatted learning insights with skill coverage analysis and actionable next steps
  - `docs/learning/LESSON-TEMPLATE.md` — Structured lesson format with Context, What Happened, Root Cause, Fix, and Prevention sections
  - Quality-reviewer agent enhancement: Check if skill outputs reference existing LEARN.md lessons, suggest creating entries for repeated patterns
- **Distribution Package for Marketplace** — Lower barrier to adoption and enable community contributions (`3c03529`)
  - `examples/starter-project/` — Comprehensive EduStream Academy example with 37 markdown files (792KB) demonstrating 7+ skills across PM/Dev/UX/QA/Research roles
    - 3 PRDs (live streaming classroom, course marketplace, AI recommendations)
    - 6 user stories, backend/frontend task breakdowns, microcopy packs (7 languages), QA test cases
    - Complete roadmap showing 4 completed phases with Node.js/Express/React/WebRTC stack
  - `CONTRIBUTING.md` — Complete contribution guide with skill creation, LEARN.md improvement, code style, testing, and release process
  - `docs/QUICKSTART-VIDEO.md` — 3-5 minute demo video script for marketplace promotion
  - `scripts/verify-install.sh` enhancement — Added skill discovery checks, hook registration verification, and installation report generation
- **Validation Utilities Documentation** — `docs/development/VALIDATION.md` with jq-based validation patterns for hooks.json and agent frontmatter (`3994ef5`)
- **Skill Dependency Map** — `docs/skills/DEPENDENCIES.md` documenting skill call chains with visual dependency tree (`3108388`)

### Changed
- **Standards Compliance with Official Claude Code Patterns** — Align plugin with 13 official Anthropic plugins analysis (`3994ef5`)
  - Removed `.claude/settings.json` from plugin distribution (0/13 official plugins have this)
  - Enhanced agent descriptions with concrete `<example>` blocks showing triggering scenarios (quality-reviewer, context-scout)
  - Removed non-standard "capabilities" field from agent frontmatter
  - Added `.claude/` to .gitignore, documented optional project configuration in README
  - Updated `scripts/build-dist.sh` to exclude .claude/ from distribution
- **Command Naming Convention** — Renamed `learning-report` to `learn-report` following plugin naming standards (`369a36e`)
- **README Enhancement** — Added badges, quick stats table (18 skills, 2 agents, 4 hooks), verification steps, real-world workflow examples (`c386766`)
- **Marketplace Metadata** — Enhanced keywords (product-management, user-stories, gtm-tracking), updated plugin description with feature highlights (`c386766`)

### Fixed
- **Broken Skill References** — Removed references to non-existent follow-on skills (fe-state-machine, be-data-model) in task breakdown skills, added "Coming Soon" notes where appropriate (`3108388`)
- **Template Documentation** — Added explicit notes in docs-create and docs-update skills explaining template references (`3108388`)

### Documentation
- **WordPress Development Research** — Added comprehensive WordPress Analytics Plugin Development guide to research index (`c27cbcd`)

---

## [3.12.0] - 2026-02-03

### Added
- **`/jaan-to:ux-research-synthesize` skill** — Transform raw UX research data (interviews, usability tests, surveys) into actionable insights using validated methodologies (`550bf0f`)
  - Three synthesis modes: Speed (1-2h quick findings), Standard (1-2d full thematic analysis), Cross-Study (meta-analysis across multiple studies)
  - AI-assisted analysis with human validation checkpoints implementing Braun & Clarke's Six-Phase Thematic Analysis and Atomic Research Framework
  - 15-step workflow with HARD STOP between analysis (read-only) and generation (write phase)
  - Quality gates: 14-point validation checklist covering executive summary length, theme quality, evidence traceability, participant coverage balance
  - Participant coverage tracking prevents >25% single-participant bias
  - Evidence traceability ensures every claim traces to verbatim quote with participant ID
  - Dual outputs: main synthesis report + 1-page executive brief (auto-generated)
  - Methodologies: Braun & Clarke Six-Phase, Atomic Research (Experiments → Facts → Insights → Recommendations), Nielsen Severity Ratings (0-4 scale), Impact × Effort Matrix (Quick Wins, Big Bets, Fill-Ins, Money Pits), ISO 9241-11:2018 usability dimensions
  - Research-informed: 877-line methodology foundation ([jaan-to/outputs/research/47-ux-research-synthesize.md](docs/research/47-ux-research-synthesize.md))

### Changed
- **`/jaan-to:roadmap-update` enhanced** — Automatic release detection from git history when running in smart-default mode (`602d651`)

---

## [3.11.0] - 2026-02-03

### Added
- **`/jaan-to:qa-test-cases` skill** — Generate production-ready BDD/Gherkin test cases from acceptance criteria using ISTQB methodology (`3f1a8a7`)
  - ISTQB test design techniques: Equivalence Partitioning, Boundary Value Analysis (3-value BVA), and edge case taxonomy
  - Minimum 10 tests per acceptance criterion (3 positive + 3 negative + 2 boundary + 2 edge case)
  - 5 priority edge case categories based on production defect frequency: Empty/Null States (32%), Boundary Values (28%), Error Conditions (22%), Concurrent Operations (12%), State Transitions (6%)
  - 4 input modes: direct AC text, PRD file path, Jira ID (via MCP), or interactive wizard
  - Concrete test data (no placeholders) with standard test data library for reproducible scenarios
  - Quality validation: 10-point peer review checklist + 100-point scoring rubric (6 dimensions)
  - ISTQB conversion notes for traditional test management tools (Xray, TestRail, Azure DevOps)
  - Auxiliary quality checklist file with anti-patterns reference and coverage sufficiency analysis
  - Two-phase workflow with systematic test design techniques and human approval gate
  - Research-informed: 880-line methodology guide ([50-qa-test-cases.md](docs/research/50-qa-test-cases.md))

---

## [3.10.0] - 2026-02-03

### Added
- **`/jaan-to:ux-microcopy-write` skill** — Generate multi-language microcopy packs with cultural adaptation (`e4809b3`)
  - 7 languages: EN, FA (فارسی / Persian), TR (Türkçe), DE (Deutsch), FR (Français), RU (Русский), TG (Тоҷикӣ)
  - RTL/LTR support with ZWNJ handling for Persian, Persian punctuation (؟ ، ؛ « »)
  - Tone-of-voice management via context files (`localization.md`, `tone-of-voice.md`)
  - 11 microcopy categories with smart detection: Labels, Helper Text, Error Messages, Success Messages, Toast Notifications, Confirmation Dialogs, Empty States, Loading States, Tooltips, Placeholders, CTAs
  - Options iteration workflow: 3-5 rounds with custom user text support and style-matched variations
  - Dual output: Human-readable markdown + JSON for i18n frameworks (React i18next, Vue i18n, ICU MessageFormat)
  - Cultural adaptation (not literal translation): language-specific formality rules, text expansion rates (German +35%, Turkish +33%), 3-form pluralization for Russian
  - Research-informed: 2 comprehensive sources consulted ([56-ux-ux-writing-persian.md](jaan-to/outputs/research/56-ux-ux-writing-persian.md), [57-ux-microcopy-write.md](jaan-to/outputs/research/57-ux-microcopy-write.md))

---

## [3.9.0] - 2026-02-03

### Added
- **ID-based folder output structure** — All output-generating skills now use standardized structure:
  `jaan-to/outputs/{role}/{subdomain}/{id}-{slug}/{id}-{report-type}-{slug}.md` (`0364b4a`)
  - Per-subdomain sequential IDs (independent sequences for each subdomain)
  - Slug reusability across different role/subdomain combinations for cross-role feature tracking
  - Automatic index management via `scripts/lib/index-updater.sh`
  - Executive Summary requirement (1-2 sentence summaries in all outputs)
  - 7 skills updated: pm-prd-write, pm-story-write, data-gtm-datalayer, dev-fe-task-breakdown,
    dev-be-task-breakdown, ux-heatmap-analyze, dev-stack-detect
- **Output validation script** — `scripts/validate-outputs.sh` with 4 compliance checks:
  subdomain indexes, folder naming patterns, file naming consistency, ID matching (`c076da2`)
- **Core utilities** — `scripts/lib/id-generator.sh` and `scripts/lib/index-updater.sh`
  for sequential ID generation and automatic README.md index updates (`0364b4a`)

### Changed
- **`/jaan-to:skill-create` now generates compliant skills** — All new skills automatically
  include ID generation (Step 5.5), folder structure, index management, and Executive Summary
  sections in templates (`95d082e`)
- **`/jaan-to:skill-update` detects legacy output patterns** — Added V3.8 compliance checks
  and automatic migration handler for non-compliant skills (`68993d2`)

### Documentation
- **Comprehensive output standards** — Added complete "Skill Output Standards" specification
  to [docs/extending/create-skill.md](docs/extending/create-skill.md) with 6 components,
  implementation checklist, and common mistakes (`4d5631e`)
- **Master output index** — Created [jaan-to/outputs/README.md](jaan-to/outputs/README.md)
  with organization overview, navigation guide, and slug scoping rules (`4d5631e`)
- **Updated AI behavioral rules** — Expanded "Output Structure" section in
  [CLAUDE.md](CLAUDE.md) with standardized patterns (`4d5631e`)
- **Meta-skill LEARN.md updates** — Added output structure standards to
  `skill-create/LEARN.md` and compliance check patterns to
  `skill-update/LEARN.md` (`978a077`)

---

## [3.8.0] - 2026-02-03

### Removed
- **AskUserQuestion from all skills** — Reverted to simple text-based prompts for better
  compatibility and simpler skill implementation
  - Removed AskUserQuestion documentation from [docs/extending/create-skill.md](docs/extending/create-skill.md)
  - Removed AskUserQuestion conversion option from `/jaan-to:skill-update` tool
  - All skills now use clean text prompts instead of structured question blocks

### Changed
- **All 16 skills now use text prompts** instead of AskUserQuestion API:
  - **Simple prompts**: `> "Ready? [y/n]"`
  - **Multiple choice**: `> "[1] Option A\n[2] Option B"`
  - **Conditional**: `> "Confirm? [y/n/edit]"`
  - Affected skills: `data-gtm-datalayer`, `pm-prd-write`,
    `pm-research-about`, `pm-story-write`, `dev-be-task-breakdown`,
    `ux-heatmap-analyze`, `dev-stack-detect`, `docs-create`,
    `docs-update`, `learn-add`, `roadmap-add`,
    `roadmap-update`, `skill-create`, `skill-update`,
    and skill creation template

---

## [3.7.0] - 2026-02-03

### Added
- **`/jaan-to:dev-fe-task-breakdown` skill** — Transform UX design handoffs into production-ready
  frontend task breakdowns with component inventories, state matrices, estimate bands,
  dependency graphs (Mermaid), performance budgets, and risk assessment (`af90d27`)
  - Atomic Design taxonomy: Atoms (XS) → Pages (XL) with T-shirt size estimates
  - 6-state enumeration per component: Default, Loading, Success, Error, Empty, Partial
  - 50+ item coverage checklist: accessibility, responsive, interaction states, performance, SEO, testing
  - Core Web Vitals 2025 targets: LCP ≤2.5s, INP ≤200ms, CLS ≤0.1
  - State machine stubs for complex components
  - Tech-aware: reads `$JAAN_CONTEXT_DIR/tech.md` for framework-specific patterns
- **Dev role activated** — Second technical role after Data; `docs/skills/dev/` expanded

---

## [3.6.0] - 2026-02-03

### Changed
- **`/jaan-to:ux-heatmap-analyze` output restructured** — Report format shifted from
  research paper to action brief: insightful, practical, actionable
  - "Executive Summary" (narrative) → **Action Summary** (bullets only)
  - "Findings" (by severity) + "Recommendations" (separate table) → **Findings & Actions**
    (self-contained cards with Insight, Do this, ICE score, Evidence)
  - New **Test Ideas** section: A/B test and UX research suggestions derived from findings
  - Methodology + Metadata sections collapsed to single-line footer blockquote
  - 4 new quality checks: action bullets, insight lines, concrete actions, test ideas (`921a3f5`)

---

## [3.5.0] - 2026-02-03

### Added
- **User story auto-invoke in `/jaan-to:pm-prd-write`** — After PRD is written,
  optionally invoke `/jaan-to:pm-story-write` to expand user stories into full
  detailed stories with INVEST validation and Gherkin acceptance criteria (`90d67c3`)

---

## [3.4.0] - 2026-02-03

### Added
- **Roadmap auto-invoke** — `/jaan-to:skill-create` and `/jaan-to:skill-update` now
  automatically call `/jaan-to:roadmap-update` at end of workflow to keep roadmap in sync
- **`/jaan-to:dev-pr-review` documentation** added (`2750902`)

### Fixed
- **Specification compliance** for `/jaan-to:skill-update` and `/jaan-to:skill-create`:
  - H1 titles use logical name format (`skill:update`, `skill:create`)
  - Broken spec path reference fixed (`jaan-to/docs/` → `docs/extending/`)
  - Migration wizard converted to AskUserQuestion (4-option menu)
  - Duplicate Step 18 numbering fixed (→ Step 20)
  - template.md uses `{{double-brace}}` v3.0.0 syntax
- **`/jaan-to:roadmap-update`** — Unreleased management and branch merge in release mode (`db33d88`)
- Fixed stale path references (`206dcfd`)

### Changed
- Roadmap: Created v3.3.0 version section, refreshed Unreleased with post-tag commits

---

## [3.3.0] - 2026-02-03

### Added
- **`/jaan-to:ux-heatmap-analyze` skill** — First UX role skill. Analyze heatmap CSV exports
  and screenshots to generate prioritized UX research reports
  - Two data formats: aggregated element-click (Format A) and raw coordinates (Format B)
  - Claude Vision analysis of heatmap screenshots with cross-reference validation
  - HTML cross-reference for CSS selector to human-readable element mapping
  - Two-pass validation: corroborated findings (0.85-0.95), single-source (0.70-0.80)
  - ICE-scored recommendations (Impact x Confidence x Ease)
  - Output: `jaan-to/outputs/ux/heatmap/{slug}/report.md`
- **`/jaan-to:dev-stack-detect` skill** — Auto-detect project tech stack and populate context
- **UX role activated** — First role skill beyond PM and Data; `docs/skills/ux/` created

### Changed
- Renamed `roadmap-jaan-to.md` to `roadmap.md` and `vision-jaan-to.md` to `vision.md`
- `scripts/seeds/config.md` — UX moved from Planned to Enabled Roles

---

## [3.2.0] - 2026-02-03

### Added
- **AskUserQuestion interactive prompts** — All 11 skills now use structured
  multiple-choice UI instead of text-based `[y/n]` prompts
  - HARD STOP gates with Yes/No/Edit options
  - Preview approvals with Yes/No options
  - Feedback capture with No/Fix now/Learn/Both options
  - Mode selection with descriptive option labels
- **"User Interaction Patterns" section** in skill creation spec
  (`docs/extending/create-skill.md`) — documents when to use AskUserQuestion
  vs text prompts, JSON schema reference, instruction syntax
- **V3.8 AskUserQuestion compliance check** in `/jaan-to:skill-update`
- **Option [9] "Convert to AskUserQuestion"** in `/jaan-to:skill-update`
- **Skill factory AskUserQuestion support** — `/jaan-to:skill-create` now
  generates new skills with AskUserQuestion patterns

### Changed
- ~73 text prompts converted to AskUserQuestion across all skills
- Research size picker simplified: 5 options → 3 + "Other"
- Role picker simplified: 6 options → 3 + "Other"
- Feedback prompts consolidated: 2 sequential prompts → 1 AskUserQuestion
- Skill template (`template.md`) updated with AskUserQuestion skeleton

---

## [3.1.0] - 2026-02-03

### Added
- **`/jaan-to:roadmap-update` skill** — Maintain and sync roadmap with codebase
  - Detects stale tasks via git history comparison
  - Syncs task status between roadmap and task files
  - Generates progress reports and burndown summaries
  - Supports quick mode (status only) and full audit mode
- **Post-commit roadmap hook** — Automatically updates roadmap task status after commits
  - Matches commit messages to roadmap tasks
  - Marks tasks as complete with commit hash
- **Customization guide** — Comprehensive guide for v3.0.0 configuration system
  - Path customization, template inheritance, learning strategies
  - Environment variables, tech stack integration

---

## [3.0.0] - 2026-02-02

### Added
- **Multi-layer configuration system** — Plugin defaults + project customization
- **Path customization** — Configure templates, learning, context, output paths via `jaan-to/config/settings.yaml`
- **Template inheritance** — Extend base templates, override sections (v3.1+ feature, scaffolded)
- **Learning merge strategy** — Combine lessons from plugin + project sources
- **Tech stack integration** — PRDs auto-reference your stack from `jaan-to/context/tech.md`
- **Template variables** — Use `{{field}}`, `{{env:VAR}}`, `{{config:key}}`, `{{import:path#section}}` in templates
- **Environment variables** — `JAAN_*` vars (`$JAAN_TEMPLATES_DIR`, `$JAAN_LEARN_DIR`, `$JAAN_CONTEXT_DIR`, `$JAAN_OUTPUTS_DIR`) for path overrides
- **Configuration file** — `jaan-to/config/settings.yaml` for all customization
- **Enhanced tech.md** — Structured sections with anchors: Current Stack, Frameworks, Technical Constraints, Versioning, Common Patterns, Tech Debt
- **Migration guide** — Complete guide for upgrading from v2.x ([docs/guides/migration-v3.md](docs/guides/migration-v3.md))
- **Configuration examples** — 3 example configs: enterprise template, monorepo paths, learning override

### Changed
- **BREAKING**: Paths now use environment variables (`$JAAN_TEMPLATES_DIR`, etc.) instead of hardcoded `jaan-to/` paths
- **BREAKING**: Bootstrap creates `jaan-to/config/settings.yaml` on first run
- All 10 skills updated to support path customization
- Templates enhanced with variable support
- `tech.md` structure improved with section anchors for imports
- CLAUDE.md updated with customization documentation
- File Locations table now includes "Customizable" column

### Migration
See [Migration Guide](docs/guides/migration-v3.md) for detailed upgrade steps.

**Quick summary:**
- Update plugin: `/plugin update jaan-to`
- Review new config: `jaan-to/config/settings.yaml` (created automatically)
- Customize if needed, or leave defaults (no action required)

### Infrastructure
- **Phase 1**: Configuration system with YAML-based 2-layer config (plugin + project)
- **Phase 2**: Path resolution system with dynamic template/learning/context/output resolution
- **Phase 3**: Template processor with variable substitution and section extraction
- **Phase 4**: Learning merger for combining plugin + project lessons
- **Phase 5**: Tech stack integration for tech-aware PRD generation
- **Phase 6**: Full migration of all 10 skills + comprehensive documentation
- **Phase 7**: Unified integration testing (38+ test assertions across 5 E2E suites)

### Testing
- ✓ Phase 1 E2E: 8 tests (configuration system)
- ✓ Phase 2 E2E: 7 tests (path resolution)
- ✓ Phases 3-5 E2E: 3 tests (template + learning + tech)
- ✓ Phase 6 E2E: 5 tests (migration + docs)
- ✓ Unified Integration: 15+ assertions (full workflow)
- ✓ Master test suite: 5/5 passed, 0 failed

---

## [2.2.0] - 2026-02-02

### Added
- **`/jaan-to:pm-story-write` skill** — Generate user stories with Given/When/Then acceptance criteria following INVEST principles
  - Two-phase workflow: Analysis (read-only) → HARD STOP → Generation (write phase)
  - Input formats: [feature] [persona] [goal], narrative text, or Jira ID (via MCP)
  - Quality gates: INVEST compliance (6 criteria), AC testability, Definition of Ready (10 items)
  - Edge case mapping: Auto-detects 10 categories based on feature type (CRUD, API, workflow, forms, etc.)
  - Story splitting: Suggests 6 proven patterns when >7 ACs or >8 points
  - Export formats: Jira CSV and Linear JSON for easy import
  - Output: `jaan-to/outputs/pm/stories/{slug}/stories.md`
  - Research-informed: Based on comprehensive [45-pm-insights-synthesis.md](docs/research/45-pm-insights-synthesis.md) framework

---

## [2.1.1] - 2026-02-02

### Fixed
- **Research skill quality restored** — `/jaan-to:pm-research-about` restructured to match original focused workflow
  - Removed A- prefixes from all steps and phases (PHASE 1 instead of A-PHASE 1)
  - Removed SECTION A/B framing that buried the research workflow
  - Reduced input detection from 35 lines to 8 lines (less noise before research starts)
  - Moved add-to-index to compact appendix (118 lines vs 250 lines mixed in)
  - File size: 1,080 lines → 933 lines (-147 lines, -14%)
  - Research workflow now identical to pre-merge `to-jaan-research-about` (808-line version)

### Technical Details
- Step numbering: Clean `Step 0.1`, `Step 1`, `PHASE 1` (no A- prefixes)
- Checkmarks restored: 10 ✓ and 4 □ for better UX
- Add-to-index: Preserved as compact appendix at end of file
- Both modes work: research topics via main flow, file/URL via appendix

---

## [2.1.0] - 2026-02-01

### Changed
- **Research skills merged** — `to-jaan-research-about` and `to-jaan-research-add` combined into `pm-research-about`
  - Auto-detects input type: topic string triggers deep research, file path or URL triggers add-to-index
  - Renamed from internal (`to-jaan-*`) to role-based (`jaan-to-pm-*`) naming convention
  - Documentation moved from `docs/skills/core/` to `docs/skills/pm/`

### Removed
- `to-jaan-research-about` skill (replaced by `pm-research-about`)
- `to-jaan-research-add` skill (replaced by `pm-research-about`)

### Migration Notes
- `/jaan-to:research-about <topic>` → `/jaan-to:pm-research-about <topic>`
- `/jaan-to:research-add <file-or-url>` → `/jaan-to:pm-research-about <file-or-url>`
- Both commands now map to the same skill with automatic input detection

---

## [2.0.1] - 2026-02-01

### Fixed
- **Marketplace and plugin manifests** aligned to official Claude Code plugin schema
  - Added `$schema` to marketplace.json
  - Moved `version` and `description` to top-level (removed `metadata` wrapper)
  - Replaced `owner.url` / `author.url` with `email`
  - Removed non-standard fields (`repository`, `homepage`, `license`, `keywords`)
  - Added `category: "development"` to plugin entry

---

## [2.0.0] - 2026-01-31

### Changed
- **BREAKING: Project directory renamed** `.jaan-to/` → `jaan-to/` (non-hidden)
  - All skill references, scripts, and documentation updated
  - Bootstrap auto-migrates existing `.jaan-to/` directories

### Added
- **Version management rules** in CLAUDE.md — git tag + CHANGELOG required per release
- **Auto-migration** in bootstrap.sh for existing `.jaan-to/` directories
- **Retroactive git tags** for v1.0.0, v1.3.0, v1.3.1

### Migration Notes
- Existing projects: bootstrap auto-migrates on next session
- Manual: `mv .jaan-to jaan-to` + update `.gitignore`
- Update any custom `settings.json` permissions: `.jaan-to` → `jaan-to`

---

## [1.3.1] - 2026-01-31

### Fixed
- **Skills not reading LEARN files on installed projects** — 5 skills had a Phase 0
  (Input Validation, Git Branch, Duplicate Detection) that ran before the learn-file
  read step, causing Claude to skip it entirely. Moved learn-file reading to a
  mandatory Pre-Execution block before all phases.
- **Weak learn-file instructions** — 3 skills had the learn step in the right position
  but used soft "if it exists" language. Upgraded to "MANDATORY FIRST ACTION" with
  explicit Read tool instruction.
- **Missing learn-file reference** — `roadmap-add` had a LEARN.md but its
  SKILL.md never referenced it. Added Pre-Execution block and Context Files entry.

### Changed
- All 9 content-generating skills now use a consistent `## Pre-Execution: Apply Past
  Lessons` block positioned before any Phase, ensuring learn files are always read first.

---

## [1.3.0] - 2026-01-31

### Changed
- **Skill naming convention** - Renamed all skills to use consistent prefixes:
  - Role-based skills: `{role}-{domain}-{action}` (e.g., `pm-prd-write`, `data-gtm-datalayer`)
  - Internal skills: `{domain}-{action}` (e.g., `skill-create`, `docs-update`, `learn-add`)
- **Directory structure** - Updated all skill directories to match new naming convention
- **Documentation** - Updated all references across scripts, roadmaps, and documentation

### Migration Notes
- Old skill names (e.g., `pm-prd-write`, `jaan-docs-create`) are deprecated
- Commands now use new format: `/jaan-to:pm-prd-write` instead of `/jaan-to:pm-prd-write`
- Internal commands: `/jaan-to:skill-create` instead of `/jaan-to:jaan-skill-create`

---

## [1.0.0] - 2026-01-29

### Added

#### Skills (10)
- **pm-prd-write** - Generate comprehensive PRD from initiative with validation
- **data-gtm-datalayer** - Generate GTM tracking code and dataLayer specification
- **skill-create** - Create new skill with wizard and research integration
- **skill-update** - Update existing skill with specification compliance
- **docs-create** - Create documentation with templates and style guide
- **docs-update** - Audit and update stale documentation with git-based detection
- **learn-add** - Add lesson to project's LEARN.md knowledge base
- **to-jaan-research-about** - Deep research on any topic with source citations
- **to-jaan-research-add** - Add file/URL to research index for future reference
- **roadmap-add** - Add task to roadmap with priority and scope

#### Agents (2)
- **quality-reviewer** - Reviews outputs for completeness, accuracy, and quality standards
- **context-scout** - Gathers relevant context from codebase before generation

#### Hooks
- **PRD validation hook** - Skill-scoped PreToolUse on pm-prd-write ensures required sections
- **Feedback capture hook** - Global PostToolUse captures user feedback for learning

#### Context System
- Context templates for tech stack (`scripts/seeds/tech.md`)
- Context templates for team structure (`scripts/seeds/team.md`)
- Context templates for integrations (`scripts/seeds/integrations.md`)
- Boundary definitions for safe paths (`scripts/seeds/boundaries.md`)

#### Learning System
- Accumulated LEARN.md knowledge from 50+ skill runs
- Automatic feedback routing to appropriate skill's LEARN.md
- Project-level learning storage in `.jaan-to/learn/`

#### Infrastructure
- MCP scaffolding for future integrations
- Bootstrap script for first-run setup
- Plugin manifest (`.claude-plugin/plugin.json`)
- Marketplace distribution metadata
- Two-phase workflow with human approval checkpoints

#### Documentation
- Comprehensive README with installation and usage
- Getting started guide
- Skill creation specification
- Style guide for documentation
- Vision and roadmap documents
- Migration guide from standalone setup

### Changed (v1.0.0)
- Migrated from standalone `.claude/skills/` setup to plugin architecture
- Updated all skill command names to namespaced format
- Moved context files from `jaan-to/context/` to plugin-relative `scripts/seeds/`
- Moved hooks from shell scripts to JSON configuration
- Output directory standardized to project-relative `.jaan-to/outputs/`
- Learning files moved to project-relative `.jaan-to/learn/`

### Security
- Restricted write permissions to `.jaan-to/` directory only
- Removed hooks section from settings.json (now plugin-managed)
- Added permission tiers (Minimal, Standard, Power User)

---

## [Unreleased]

### Planned
- Additional quick-win skills (qa-test-cases, data-sql-query)
- Enhanced MCP integrations (GA4, GitLab, Jira, Figma)
- JSON export alongside markdown outputs
- External notifications (Slack)

---

[5.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v5.0.0
[4.5.1]: https://github.com/parhumm/jaan-to/releases/tag/v4.5.1
[4.5.0]: https://github.com/parhumm/jaan-to/releases/tag/v4.5.0
[4.4.0]: https://github.com/parhumm/jaan-to/releases/tag/v4.4.0
[4.3.0]: https://github.com/parhumm/jaan-to/releases/tag/v4.3.0
[4.2.1]: https://github.com/parhumm/jaan-to/releases/tag/v4.2.1
[4.2.0]: https://github.com/parhumm/jaan-to/releases/tag/v4.2.0
[4.1.1]: https://github.com/parhumm/jaan-to/releases/tag/v4.1.1
[4.1.0]: https://github.com/parhumm/jaan-to/releases/tag/v4.1.0
[4.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v4.0.0
[3.24.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.24.0
[3.23.1]: https://github.com/parhumm/jaan-to/releases/tag/v3.23.1
[3.23.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.23.0
[3.22.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.22.0
[3.21.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.21.0
[3.20.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.20.0
[3.19.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.19.0
[3.18.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.18.0
[3.17.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.17.0
[3.16.3]: https://github.com/parhumm/jaan-to/releases/tag/v3.16.3
[3.16.2]: https://github.com/parhumm/jaan-to/releases/tag/v3.16.2
[3.15.2]: https://github.com/parhumm/jaan-to/releases/tag/v3.15.2
[3.15.1]: https://github.com/parhumm/jaan-to/releases/tag/v3.15.1
[3.15.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.15.0
[3.14.1]: https://github.com/parhumm/jaan-to/releases/tag/v3.14.1
[3.14.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.14.0
[3.13.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.13.0
[3.12.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.12.0
[3.11.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.11.0
[3.10.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.10.0
[3.9.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.9.0
[3.8.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.8.0
[3.7.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.7.0
[3.6.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.6.0
[3.5.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.5.0
[3.4.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.4.0
[3.3.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.3.0
[3.2.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.2.0
[3.1.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.1.0
[3.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v3.0.0
[2.2.0]: https://github.com/parhumm/jaan-to/releases/tag/v2.2.0
[2.1.1]: https://github.com/parhumm/jaan-to/releases/tag/v2.1.1
[2.1.0]: https://github.com/parhumm/jaan-to/releases/tag/v2.1.0
[2.0.1]: https://github.com/parhumm/jaan-to/releases/tag/v2.0.1
[2.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v2.0.0
[1.3.1]: https://github.com/parhumm/jaan-to/releases/tag/v1.3.1
[1.3.0]: https://github.com/parhumm/jaan-to/releases/tag/v1.3.0
[1.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v1.0.0
