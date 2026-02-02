# Changelog

All notable changes to the jaan.to Claude Code Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.1] - 2026-02-02

### Fixed
- **Research skill quality restored** — `/jaan-to-pm-research-about` restructured to match original focused workflow
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
- **Research skills merged** — `to-jaan-research-about` and `to-jaan-research-add` combined into `jaan-to-pm-research-about`
  - Auto-detects input type: topic string triggers deep research, file path or URL triggers add-to-index
  - Renamed from internal (`to-jaan-*`) to role-based (`jaan-to-pm-*`) naming convention
  - Documentation moved from `docs/skills/core/` to `docs/skills/pm/`

### Removed
- `to-jaan-research-about` skill (replaced by `jaan-to-pm-research-about`)
- `to-jaan-research-add` skill (replaced by `jaan-to-pm-research-about`)

### Migration Notes
- `/to-jaan-research-about <topic>` → `/jaan-to-pm-research-about <topic>`
- `/to-jaan-research-add <file-or-url>` → `/jaan-to-pm-research-about <file-or-url>`
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
- **Missing learn-file reference** — `to-jaan-roadmap-add` had a LEARN.md but its
  SKILL.md never referenced it. Added Pre-Execution block and Context Files entry.

### Changed
- All 9 content-generating skills now use a consistent `## Pre-Execution: Apply Past
  Lessons` block positioned before any Phase, ensuring learn files are always read first.

---

## [1.3.0] - 2026-01-31

### Changed
- **Skill naming convention** - Renamed all skills to use consistent prefixes:
  - Role-based skills: `jaan-to-{role}-{domain}-{action}` (e.g., `jaan-to-pm-prd-write`, `jaan-to-data-gtm-datalayer`)
  - Internal skills: `to-jaan-{domain}-{action}` (e.g., `to-jaan-skill-create`, `to-jaan-docs-update`, `to-jaan-learn-add`)
- **Directory structure** - Updated all skill directories to match new naming convention
- **Documentation** - Updated all references across scripts, roadmaps, and documentation

### Migration Notes
- Old skill names (e.g., `pm-prd-write`, `jaan-docs-create`) are deprecated
- Commands now use new format: `/jaan-to-pm-prd-write` instead of `/jaan-to:pm-prd-write`
- Internal commands: `/to-jaan-skill-create` instead of `/jaan-to:jaan-skill-create`

---

## [1.0.0] - 2026-01-29

### Added

#### Skills (10)
- **jaan-to-pm-prd-write** - Generate comprehensive PRD from initiative with validation
- **jaan-to-data-gtm-datalayer** - Generate GTM tracking code and dataLayer specification
- **to-jaan-skill-create** - Create new skill with wizard and research integration
- **to-jaan-skill-update** - Update existing skill with specification compliance
- **to-jaan-docs-create** - Create documentation with templates and style guide
- **to-jaan-docs-update** - Audit and update stale documentation with git-based detection
- **to-jaan-learn-add** - Add lesson to project's LEARN.md knowledge base
- **to-jaan-research-about** - Deep research on any topic with source citations
- **to-jaan-research-add** - Add file/URL to research index for future reference
- **to-jaan-roadmap-add** - Add task to roadmap with priority and scope

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

### Planned for 1.1.0
- Additional quick-win skills (qa-test-cases, data-sql-query, pm-story-write)
- Enhanced MCP integrations (GA4, GitLab, Jira, Figma)
- JSON export alongside markdown outputs
- External notifications (Slack)

---

[2.1.1]: https://github.com/parhumm/jaan-to/releases/tag/v2.1.1
[2.1.0]: https://github.com/parhumm/jaan-to/releases/tag/v2.1.0
[2.0.1]: https://github.com/parhumm/jaan-to/releases/tag/v2.0.1
[2.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v2.0.0
[1.3.1]: https://github.com/parhumm/jaan-to/releases/tag/v1.3.1
[1.3.0]: https://github.com/parhumm/jaan-to/releases/tag/v1.3.0
[1.0.0]: https://github.com/parhumm/jaan-to/releases/tag/v1.0.0
