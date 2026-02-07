# Changelog

All notable changes to the jaan.to Claude Code Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.16.1] - 2026-02-07

### Fixed
- **Inconsistent `Maps to:` field** — Standardized all 8 skills that used colon shorthand (`dev:fe-design`) to match actual skill name (`dev-fe-design`)

---

## [3.16.0] - 2026-02-07

### Changed
- **BREAKING: Skill names simplified** — Removed redundant `jaan-to-` / `to-jaan-` prefixes from all 19 skills
  - Commands change: `/jaan-to:jaan-to-pm-prd-write` → `/jaan-to:pm-prd-write`
  - Config keys change: `templates_jaan_to_pm_prd_write_path` → `templates_pm_prd_write_path`
  - Users with customized `settings.yaml` paths must update key names
- **Naming conventions updated** in CLAUDE.md — Role-based: `{role}-{domain}-{action}`, Internal: `{domain}-{action}`
- **All documentation, scripts, agents, hooks references updated** to use new names

### Renamed Skills (19 total)
| Old | New |
|-----|-----|
| `jaan-to-pm-prd-write` | `pm-prd-write` |
| `jaan-to-pm-story-write` | `pm-story-write` |
| `jaan-to-pm-research-about` | `pm-research-about` |
| `jaan-to-dev-fe-design` | `dev-fe-design` |
| `jaan-to-dev-fe-task-breakdown` | `dev-fe-task-breakdown` |
| `jaan-to-dev-be-task-breakdown` | `dev-be-task-breakdown` |
| `jaan-to-dev-stack-detect` | `dev-stack-detect` |
| `jaan-to-qa-test-cases` | `qa-test-cases` |
| `jaan-to-ux-research-synthesize` | `ux-research-synthesize` |
| `jaan-to-ux-microcopy-write` | `ux-microcopy-write` |
| `jaan-to-ux-heatmap-analyze` | `ux-heatmap-analyze` |
| `jaan-to-data-gtm-datalayer` | `data-gtm-datalayer` |
| `to-jaan-docs-create` | `docs-create` |
| `to-jaan-docs-update` | `docs-update` |
| `to-jaan-learn-add` | `learn-add` |
| `to-jaan-roadmap-add` | `roadmap-add` |
| `to-jaan-roadmap-update` | `roadmap-update` |
| `to-jaan-skill-create` | `skill-create` |
| `to-jaan-skill-update` | `skill-update` |

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
  - Stable versions: `X.Y.Z` (e.g., `3.15.0`)
  - Dev versions: `X.Y.Z-dev` (e.g., `3.15.0-dev`)
- **Version Management Scripts**
  - `scripts/bump-version.sh` — Update version in all 3 required locations atomically (plugin.json, marketplace.json top-level, marketplace.json plugins[0])
  - `scripts/setup-branch-protection.sh` — Configure GitHub branch protection (main: require PR + approval, dev: direct pushes allowed)
- **CI Release Validation** — `.github/workflows/release-check.yml` for PRs to main
  - Validates no `-dev` suffix in version
  - Ensures all 3 version fields match
  - Checks CHANGELOG entry exists
  - Validates plugin.json has required component paths (skills, agents, hooks)

### Changed
- **Skill Workflow Alignment** — `/skill-create` and `/skill-update` now follow two-branch workflow (`ba9c061`)
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
- **Frontend Component Design Skill** — `/dev-fe-design` generates distinctive, production-grade frontend component code (`48284c7`)
  - Creates working components in React, Vue, or vanilla JS/HTML based on tech.md detection
  - Generates bold, distinctive designs that avoid generic "AI slop" aesthetics (no Inter/Roboto, no purple gradients, unexpected layouts)
  - Full accessibility (WCAG AA minimum) with semantic HTML, ARIA, keyboard navigation, visible focus indicators
  - Responsive design (mobile-first) using modern CSS: Grid, Container Queries, Custom Properties, `:has()`, `prefers-color-scheme`
  - Complete deliverables: component code + documentation with design rationale + standalone preview file
  - Output structure: `dev/components/{id}-{slug}/` with ID-based folders and index management
  - Reads settings.yaml for design direction defaults, design.md for existing patterns, brand.md for guidelines
  - Complements `/dev-fe-task-breakdown`: task-breakdown plans what to build, fe-design builds the actual code
  - 478-line SKILL.md with two-phase workflow, 137-line template with variable syntax, 47-line LEARN.md with best practices

---

## [3.13.0] - 2026-02-03

### Added
- **Learning System Dashboard** — Make accumulated learning discoverable and actionable (`9f513c2`)
  - `scripts/learning-summary.sh` — Scan all LEARN.md files, count lessons per skill, extract Common Mistakes and Edge Cases sections, generate markdown/JSON report with stats
  - `/jaan-to-learn-report` command — Display formatted learning insights with skill coverage analysis and actionable next steps
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
- **Command Naming Convention** — Renamed `learning-report` to `jaan-to-learn-report` following plugin naming standards (`369a36e`)
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
- **`/ux-research-synthesize` skill** — Transform raw UX research data (interviews, usability tests, surveys) into actionable insights using validated methodologies (`550bf0f`)
  - Three synthesis modes: Speed (1-2h quick findings), Standard (1-2d full thematic analysis), Cross-Study (meta-analysis across multiple studies)
  - AI-assisted analysis with human validation checkpoints implementing Braun & Clarke's Six-Phase Thematic Analysis and Atomic Research Framework
  - 15-step workflow with HARD STOP between analysis (read-only) and generation (write phase)
  - Quality gates: 14-point validation checklist covering executive summary length, theme quality, evidence traceability, participant coverage balance
  - Participant coverage tracking prevents >25% single-participant bias
  - Evidence traceability ensures every claim traces to verbatim quote with participant ID
  - Dual outputs: main synthesis report + 1-page executive brief (auto-generated)
  - Methodologies: Braun & Clarke Six-Phase, Atomic Research (Experiments → Facts → Insights → Recommendations), Nielsen Severity Ratings (0-4 scale), Impact × Effort Matrix (Quick Wins, Big Bets, Fill-Ins, Money Pits), ISO 9241-11:2018 usability dimensions
  - Research-informed: 877-line methodology foundation ([jaan-to/outputs/research/47-ux-research-synthesize.md](jaan-to/outputs/research/47-ux-research-synthesize.md))

### Changed
- **`/roadmap-update` enhanced** — Automatic release detection from git history when running in smart-default mode (`602d651`)

---

## [3.11.0] - 2026-02-03

### Added
- **`/qa-test-cases` skill** — Generate production-ready BDD/Gherkin test cases from acceptance criteria using ISTQB methodology (`3f1a8a7`)
  - ISTQB test design techniques: Equivalence Partitioning, Boundary Value Analysis (3-value BVA), and edge case taxonomy
  - Minimum 10 tests per acceptance criterion (3 positive + 3 negative + 2 boundary + 2 edge case)
  - 5 priority edge case categories based on production defect frequency: Empty/Null States (32%), Boundary Values (28%), Error Conditions (22%), Concurrent Operations (12%), State Transitions (6%)
  - 4 input modes: direct AC text, PRD file path, Jira ID (via MCP), or interactive wizard
  - Concrete test data (no placeholders) with standard test data library for reproducible scenarios
  - Quality validation: 10-point peer review checklist + 100-point scoring rubric (6 dimensions)
  - ISTQB conversion notes for traditional test management tools (Xray, TestRail, Azure DevOps)
  - Auxiliary quality checklist file with anti-patterns reference and coverage sufficiency analysis
  - Two-phase workflow with systematic test design techniques and human approval gate
  - Research-informed: 880-line methodology guide ([50-qa-test-cases.md](jaan-to/outputs/research/50-qa-test-cases.md))

---

## [3.10.0] - 2026-02-03

### Added
- **`/ux-microcopy-write` skill** — Generate multi-language microcopy packs with cultural adaptation (`e4809b3`)
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
- **`/skill-create` now generates compliant skills** — All new skills automatically
  include ID generation (Step 5.5), folder structure, index management, and Executive Summary
  sections in templates (`95d082e`)
- **`/skill-update` detects legacy output patterns** — Added V3.8 compliance checks
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
  - Removed AskUserQuestion conversion option from `/skill-update` tool
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
- **`/dev-fe-task-breakdown` skill** — Transform UX design handoffs into production-ready
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
- **`/ux-heatmap-analyze` output restructured** — Report format shifted from
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
- **User story auto-invoke in `/pm-prd-write`** — After PRD is written,
  optionally invoke `/pm-story-write` to expand user stories into full
  detailed stories with INVEST validation and Gherkin acceptance criteria (`90d67c3`)

---

## [3.4.0] - 2026-02-03

### Added
- **Roadmap auto-invoke** — `/skill-create` and `/skill-update` now
  automatically call `/roadmap-update` at end of workflow to keep roadmap in sync
- **`/jaan-to-dev-pr-review` documentation** added (`2750902`)

### Fixed
- **Specification compliance** for `/skill-update` and `/skill-create`:
  - H1 titles use logical name format (`skill:update`, `skill:create`)
  - Broken spec path reference fixed (`jaan-to/docs/` → `docs/extending/`)
  - Migration wizard converted to AskUserQuestion (4-option menu)
  - Duplicate Step 18 numbering fixed (→ Step 20)
  - template.md uses `{{double-brace}}` v3.0.0 syntax
- **`/roadmap-update`** — Unreleased management and branch merge in release mode (`db33d88`)
- Fixed stale path references (`206dcfd`)

### Changed
- Roadmap: Created v3.3.0 version section, refreshed Unreleased with post-tag commits

---

## [3.3.0] - 2026-02-03

### Added
- **`/ux-heatmap-analyze` skill** — First UX role skill. Analyze heatmap CSV exports
  and screenshots to generate prioritized UX research reports
  - Two data formats: aggregated element-click (Format A) and raw coordinates (Format B)
  - Claude Vision analysis of heatmap screenshots with cross-reference validation
  - HTML cross-reference for CSS selector to human-readable element mapping
  - Two-pass validation: corroborated findings (0.85-0.95), single-source (0.70-0.80)
  - ICE-scored recommendations (Impact x Confidence x Ease)
  - Output: `jaan-to/outputs/ux/heatmap/{slug}/report.md`
- **`/dev-stack-detect` skill** — Auto-detect project tech stack and populate context
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
- **V3.8 AskUserQuestion compliance check** in `/skill-update`
- **Option [9] "Convert to AskUserQuestion"** in `/skill-update`
- **Skill factory AskUserQuestion support** — `/skill-create` now
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
- **`/roadmap-update` skill** — Maintain and sync roadmap with codebase
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
- **`/pm-story-write` skill** — Generate user stories with Given/When/Then acceptance criteria following INVEST principles
  - Two-phase workflow: Analysis (read-only) → HARD STOP → Generation (write phase)
  - Input formats: [feature] [persona] [goal], narrative text, or Jira ID (via MCP)
  - Quality gates: INVEST compliance (6 criteria), AC testability, Definition of Ready (10 items)
  - Edge case mapping: Auto-detects 10 categories based on feature type (CRUD, API, workflow, forms, etc.)
  - Story splitting: Suggests 6 proven patterns when >7 ACs or >8 points
  - Export formats: Jira CSV and Linear JSON for easy import
  - Output: `jaan-to/outputs/pm/stories/{slug}/stories.md`
  - Research-informed: Based on comprehensive [45-pm-insights-synthesis.md](jaan-to/outputs/research/45-pm-insights-synthesis.md) framework

---

## [2.1.1] - 2026-02-02

### Fixed
- **Research skill quality restored** — `/pm-research-about` restructured to match original focused workflow
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
- `/to-jaan-research-about <topic>` → `/pm-research-about <topic>`
- `/to-jaan-research-add <file-or-url>` → `/pm-research-about <file-or-url>`
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
  - Role-based skills: `jaan-to-{role}-{domain}-{action}` (e.g., `pm-prd-write`, `data-gtm-datalayer`)
  - Internal skills: `to-jaan-{domain}-{action}` (e.g., `skill-create`, `docs-update`, `learn-add`)
- **Directory structure** - Updated all skill directories to match new naming convention
- **Documentation** - Updated all references across scripts, roadmaps, and documentation

### Migration Notes
- Old skill names (e.g., `pm-prd-write`, `jaan-docs-create`) are deprecated
- Commands now use new format: `/pm-prd-write` instead of `/jaan-to:pm-prd-write`
- Internal commands: `/skill-create` instead of `/jaan-to:jaan-skill-create`

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
