# Product Changelog

What's new, improved, and fixed in jaan.to — written for humans.

For technical details, see [CHANGELOG.md](CHANGELOG.md).

---

## 7.5.1 — 2026-02-25

### New
- **Changelog rewrite skill** — Transform technical changelogs into user-friendly product updates with `/jaan-to:pm-changelog-rewrite`. Supports latest, specific version, or full rewrite modes.

### Improved
- **Smarter roadmap and changelog workflows** — Roadmap updates and changelog generation now auto-discover files, commit changes automatically, and link issue references for better traceability.

### Important
- **Strengthened security protections** — Multiple layers of defense hardened against prompt injection attacks, keeping your workflows safer.

---

## 7.5.0 — 2026-02-24

### New
- **Issue reporting skill** — Report bugs and feature requests directly to any GitHub or GitLab repository with `/jaan-to:qa-issue-report`. Auto-detects your repo, collects environment info, and sanitizes private data before submission.
- **Mutation testing skill** — Validate how thorough your test suite really is with `/jaan-to:qa-test-mutate`. Supports multiple stacks (Node.js, PHP, Go, Python) and iterates until quality targets are met.
- **TDD orchestration skill** — Run full Red/Green/Refactor TDD cycles with `/jaan-to:qa-tdd-orchestrate`. Coordinates test writing, implementation, and refactoring phases automatically.
- **API contract validation skill** — Validate your API specs through a multi-tool pipeline with `/jaan-to:qa-contract-validate` — linting, breaking change detection, conformance checks, and fuzz testing.
- **Quality gate skill** — Get a composite quality score across tests, security, code review, and mutation testing with `/jaan-to:qa-quality-gate`. Routes decisions: auto-approve high quality, flag low quality for human review.
- **Issue validation skill** — Automatically validate reported issues against your codebase with `/jaan-to:qa-issue-validate`. Checks if bugs are real, finds root causes, and posts findings back to the issue. (#77)
- **Roadmap management skills** — Two new skills for any project: `/jaan-to:pm-roadmap-add` for prioritized roadmap planning (MoSCoW, RICE, or Value-Effort) and `/jaan-to:pm-roadmap-update` for reviewing, marking progress, and reprioritizing.
- **Workflow pattern discovery skill** — Detect repeated patterns in your AI sessions and get skill suggestions to automate them with `/jaan-to:pm-skill-discover`. (#80)

### Improved
- **Test case generation** — Stricter behavior-focused scenarios, better structure limits, and data-driven test promotion.
- **Test execution** — New mutation testing tier with iteration tracking and smart escalation to humans after repeated failures.
- **Infrastructure scaffolding** — New optional CI stages for API linting, breaking change detection, mutation testing, and fuzz testing.
- **Team orchestration** — New `--track tdd` option in `/jaan-to:team-ship` for full TDD pipeline workflows.
- **API contract generation** — Now generates validation rulesets alongside your OpenAPI spec.

### Fixed
- **Windows compatibility** — Fixed file naming issue that prevented cloning repos with jaan-to files on Windows. Existing files auto-migrate on next session. (#157)

---

## 7.4.0 — 2026-02-22

### New
- **Live documentation fetching** — Skills can now access real, up-to-date library documentation instead of relying on stale training data, powered by Context7 MCP integration.
- **Documentation fetch skill** — Fetch and cache library docs on demand with `/jaan-to:dev-docs-fetch`. Auto-detects your tech stack, caches results for 7 days, and works standalone or as part of other skills.

### Improved
- **Dual-runtime support** — Documentation fetching works on both Claude Code and OpenAI Codex runtimes.

---

## 7.3.0 — 2026-02-21

### New
- **OpenAI Codex support** — jaan.to skills now run on both Claude Code and OpenAI Codex. Install once, use on either platform.

---

## 7.2.0 — 2026-02-19

### New
- **Cross-platform skill discovery** — jaan.to skills are now discoverable via the [Agent Skills](https://agentskills.io) open standard, making them findable across AI coding tools.
- **Automated security enforcement** — All skills and scripts are now continuously validated for security best practices in CI.
- **Team orchestration skill** — Assemble a virtual team of AI agents (PM, UX, Backend, Frontend, QA, DevOps, Security) to ship ideas from concept to production with `/jaan-to:team-ship`. Three modes: fast (8 skills), full (20 skills), or detect-only (5 auditors). (#77)

### Fixed
- **Better PRD formatting** — Improved readability with bullet-point formatting and right-to-left language support for Persian and Arabic. (#141)

---

## 7.1.0 — 2026-02-16

### New
- **Image embedding in documents** — Skills that accept images (PRDs, heatmap analysis, task breakdowns, flowcharts, stories, microcopy) now embed them as viewable images in the generated output. (#119)

---

## 7.0.0 — 2026-02-16

### Improved
- **Faster, leaner skill execution** — Major optimization reducing token usage by 25-60% per skill invocation, making workflows faster and more cost-efficient.

---

## 6.4.0 — 2026-02-16

### New
- **Backend PR review skill** — Review backend pull requests across any stack (PHP, Node.js, Python, Go, Rust) with `/jaan-to:backend-pr-review`. Detects security issues, performance problems, and code quality concerns with confidence scoring. Supports GitHub and GitLab. (#110)

### Fixed
- **Large PR handling** — PR review now handles very large pull requests (300+ files) without connection errors. (#107)

---

## 6.3.0 — 2026-02-15

### New
- **Incremental audits** — `/jaan-to:detect-dev` now supports `--incremental` to scan only files changed since the last audit, making re-audits much faster. (#81)
- **Health monitoring** — Infrastructure scaffolding now generates automated health check workflows with incident detection and auto-recovery. (#83)
- **Secret rotation reminders** — Infrastructure scaffolding generates quarterly reminders to rotate credentials. (#83)
- **Test execution skill** — Run tests, diagnose failures, and auto-fix common issues with `/jaan-to:qa-test-run`. Supports Node.js, PHP, and Go. (#82)
- **Build verification skill** — Validate your project builds and services run correctly with `/jaan-to:dev-verify`. Checks types, compiles, starts services, and runs smoke tests. (#78, #85)
- **Integration drift detection** — Get warned when new generated outputs appear that haven't been integrated into your project yet. (#75)

### Fixed
- **pnpm version conflicts** — CI workflow generation now respects your project's pnpm version setting. (#83)

---

## 6.2.3 — 2026-02-14

*Maintenance release — improved reliability of template customization across all skills. (#92)*

---

## 6.2.2 — 2026-02-14

*Maintenance release — skills now check for project initialization before running and guide you to set up if needed. (#87)*

---

## 6.2.1 — 2026-02-14

*Maintenance release — clearer guidance when running skills on uninitialized projects. (#87)*

---

## 6.2.0 — 2026-02-14

### Improved
- **Smarter issue reporting** — `/jaan-to:jaan-issue-report` now submits directly to GitHub by default when authenticated. No local file clutter unless you want it.

---

## 6.1.1 — 2026-02-12

### Improved
- **Template customization** — Skills now offer to save their default template to your project for customization when you first use them. (#73)

---

## 6.1.0 — 2026-02-12

### New
- **Output integration skill** — Copy generated outputs into your actual project with smart placement, config merging, and dependency installation using `/jaan-to:dev-output-integrate`. (#70)
- **Deployment activation skill** — Set up secrets, provision platforms (Railway, Vercel, Fly.io), and trigger deployment pipelines with `/jaan-to:devops-deploy-activate`. (#70)
- **Post-detect auto-sync** — After running detect skills, findings can automatically update your project's context files (tech stack, tone of voice, integrations). (#63)

### Improved
- **Leaner project setup** — Bootstrap no longer copies unnecessary files. Skills load what they need at runtime. (#60)

---

## 6.0.0 — 2026-02-11

### New
- **5 new skills completing the spec-to-ship pipeline:**
  - **Service implementation** (`/jaan-to:backend-service-implement`) — Generate full service code with business logic from your specs.
  - **Test generation** (`/jaan-to:qa-test-generate`) — Produce runnable unit and E2E tests from your BDD test cases.
  - **Security remediation** (`/jaan-to:sec-audit-remediate`) — Generate targeted security fixes from audit findings with regression tests.
  - **Infrastructure scaffolding** (`/jaan-to:devops-infra-scaffold`) — Generate CI/CD workflows, Dockerfiles, and deployment configs.
  - **Project assembly** (`/jaan-to:dev-project-assemble`) — Wire backend + frontend scaffold outputs into a runnable project.

---

## 5.1.0 — 2026-02-10

### New
- **Issue reporting skill** — Report bugs, feature requests, or documentation problems to the jaan-to GitHub repo with `/jaan-to:jaan-issue-report`. Auto-drafts from your current session context and sanitizes private data.

### Improved
- **Opt-in activation** — jaan.to is now opt-in per project. Run `/jaan-to:jaan-init` to activate. Projects without `jaan-to/` are completely unaffected.

---

## 5.0.0 — 2026-02-10

### Improved
- **Significantly reduced token usage** — Plugin overhead cut by ~2,000 tokens per session and ~7K-48K tokens per skill invocation through smarter reference loading.

---

## 4.5.1 — 2026-02-10

*Maintenance release — standardized output file paths and fixed documentation navigation.*

---

## 4.5.0 — 2026-02-09

### New
- **Flowchart generation skill** — Generate Mermaid flowcharts from PRDs, docs, or codebases with `/jaan-to:ux-flowchart-generate`. Supports user flows, system flows, architecture diagrams, and state flows. Renders directly in GitHub.

---

## 4.4.0 — 2026-02-09

### New
- **Changelog generation skill** — Generate changelogs from git history with `/jaan-to:release-iterate-changelog`. Parses commit messages, suggests version bumps, analyzes user impact, and formats in Keep a Changelog style.

---

## 4.3.0 — 2026-02-09

### New
- **WordPress PR review skill** — Review WordPress plugin pull requests for security, performance, and coding standards with `/jaan-to:wp-pr-review`. Supports GitHub and GitLab.

---

## 4.2.1 — 2026-02-09

*Maintenance release — fixed skill display issues in command picker and improved validation.*

---

## 4.2.0 — 2026-02-09

### New
- **Backend scaffold skill** — Generate production-ready backend code from specs with `/jaan-to:backend-scaffold`. Supports Node.js (Fastify + Prisma), PHP (Laravel/Symfony), and Go (Chi/stdlib). Includes routes, services, validation, and error handling.
- **Frontend scaffold skill** — Convert designs to React/Next.js component scaffolds with `/jaan-to:frontend-scaffold`. Includes TailwindCSS, typed API hooks, state management, and URL state.

---

## 4.1.1 — 2026-02-09

*Maintenance release — fixed skills writing to wrong directory.*

---

## 4.1.0 — 2026-02-09

### New
- **Light mode for all audits** — All 6 detect skills now support `--light` (default) for faster, cheaper scans and `--full` for comprehensive analysis. Light mode uses significantly fewer tokens.

---

## 4.0.0 — 2026-02-09

### Improved
- **Cleaner skill names** — Backend and frontend skills renamed for simplicity (e.g., `dev-be-data-model` is now `backend-data-model`). Commands updated accordingly.
- **Simpler output paths** — Outputs now write to `outputs/backend/` and `outputs/frontend/` directly.

### Important
- **Breaking change** — Skill commands and output paths changed. Existing outputs auto-migrate on next session.

---

## 3.24.0 — 2026-02-09

### New
- **Multi-platform project support** — All 6 audit skills now auto-detect and analyze monorepos with multiple platforms (web, backend, mobile, TV apps). Each platform gets its own findings with cross-platform linking.

### Important
- **Breaking change** — `/jaan-to:pack-detect` renamed to `/jaan-to:detect-pack`.

---

## 3.23.1 — 2026-02-09

*Maintenance release — standardized audit output paths to use configurable locations.*

---

## 3.23.0 — 2026-02-08

### New
- **6 audit skills for comprehensive project analysis:**
  - `/jaan-to:detect-dev` — Engineering quality audit with scoring across 11+ language ecosystems.
  - `/jaan-to:detect-design` — Design system detection with drift and inconsistency findings.
  - `/jaan-to:detect-writing` — Writing and content system analysis with tone mapping.
  - `/jaan-to:detect-product` — Product feature extraction with monetization and analytics scanning.
  - `/jaan-to:detect-ux` — UX audit with route extraction, heuristic evaluation, and flow diagrams.
  - `/jaan-to:detect-pack` — Consolidate all audit results into a scored knowledge index with risk heatmap.

---

## 3.22.0 — 2026-02-08

### New
- **Language preference system** — All skills now respect your language preference. Set once in settings, applied everywhere.
- **Documentation site** — Full Docusaurus-powered documentation site with navigation and skill docs.

---

## 3.21.0 — 2026-02-08

### New
- **Real-world showcase** — Examples replaced with [Jaanify](https://github.com/parhumm/jaanify), a project built entirely with jaan.to.

---

## 3.20.0 — 2026-02-08

### New
- **Language preference** — Set your preferred language for conversations and reports. Supports any language, configurable globally or per-skill.

---

## 3.19.0 — 2026-02-08

### New
- **Data model skill** — Generate comprehensive data model documentation with ER diagrams, table definitions, indexes, and migration playbooks using `/jaan-to:backend-data-model`.

---

## 3.18.0 — 2026-02-08

### New
- **API contract skill** — Generate OpenAPI 3.1 contracts from your API resources with `/jaan-to:backend-api-contract`. Includes error schemas, pagination, and a companion quick-start guide.

---

## 3.17.0 — 2026-02-07

### Fixed
- **All skills now appear in command picker** — Previously some skills were hidden due to description length limits.

---

## 3.16.3 — 2026-02-07

*Maintenance release — fixed command format and internal path references.*

---

## 3.16.2 — 2026-02-07

### Improved
- **Cleaner skill commands** — Skill commands simplified (e.g., `/jaan-to:jaan-to-pm-prd-write` is now `/jaan-to:pm-prd-write`).

---

## 3.15.2 — 2026-02-07

### Fixed
- **Plugin installation** — Fixed a manifest issue preventing skills from loading after marketplace installation.

---

## 3.15.1 — 2026-02-07

### Fixed
- **Plugin loading** — Added troubleshooting guidance and workaround for a Claude Code registry sync issue affecting marketplace plugins.

---

## 3.15.0 — 2026-02-07

### New
- **Stable and preview channels** — Install the stable release from `main` or the latest preview from `dev`. Switch anytime.
- **CI release validation** — Automated checks ensure every release is consistent and complete.

### Fixed
- **Plugin loading** — Fixed skills not loading after marketplace installation.

---

## 3.14.1 — 2026-02-07

*Maintenance release — fixed marketplace schema validation.*

---

## 3.14.0 — 2026-02-03

### New
- **Frontend design skill** — Generate distinctive, production-grade frontend components with `/jaan-to:frontend-design`. Creates working React/Vue/vanilla components with bold designs, full accessibility, and responsive layouts using modern CSS.

---

## 3.13.0 — 2026-02-03

### New
- **Learning insights dashboard** — View accumulated learning across all skills with `/jaan-to:learn-report`. See coverage, common mistakes, and actionable next steps.
- **Starter example project** — EduStream Academy example with 37 files demonstrating 7+ skills across PM, Dev, UX, and QA roles.
- **Contribution guide** — Complete guide for contributing skills, lessons, and improvements.

---

## 3.12.0 — 2026-02-03

### New
- **UX research synthesis skill** — Transform raw research data (interviews, usability tests, surveys) into actionable insights with `/jaan-to:ux-research-synthesize`. Three modes: Speed, Standard, or Cross-Study meta-analysis.

---

## 3.11.0 — 2026-02-03

### New
- **Test case generation skill** — Generate production-ready BDD/Gherkin test cases from acceptance criteria with `/jaan-to:qa-test-cases`. Minimum 10 tests per criterion covering positive, negative, boundary, and edge cases.

---

## 3.10.0 — 2026-02-03

### New
- **Microcopy writing skill** — Generate multi-language UI text with cultural adaptation using `/jaan-to:ux-microcopy-write`. Supports 7 languages including Persian (with RTL), Turkish, German, French, and Russian. Covers 11 microcopy categories with tone-of-voice management.

---

## 3.9.0 — 2026-02-03

### Improved
- **Organized output structure** — All generated files now use a consistent ID-based folder structure with automatic indexing and executive summaries.

---

## 3.8.0 — 2026-02-03

### Improved
- **Simpler prompts** — All skills now use clean text prompts instead of structured question blocks for better compatibility.

---

## 3.7.0 — 2026-02-03

### New
- **Frontend task breakdown skill** — Transform UX design handoffs into production-ready task breakdowns with `/jaan-to:frontend-task-breakdown`. Includes component inventories, state matrices, estimates, dependency graphs, and performance budgets.

---

## 3.6.0 — 2026-02-03

### Improved
- **Actionable heatmap reports** — Heatmap analysis now produces action briefs instead of research papers — bullets, concrete actions, ICE scores, and A/B test suggestions.

---

## 3.5.0 — 2026-02-03

### Improved
- **PRD to stories flow** — After writing a PRD, you can now automatically expand user stories into detailed stories with acceptance criteria.

---

## 3.4.0 — 2026-02-03

### Improved
- **Auto-synced roadmap** — Skill creation and updates now automatically keep the roadmap in sync.

---

## 3.3.0 — 2026-02-03

### New
- **Heatmap analysis skill** — Analyze heatmap CSV exports and screenshots to generate prioritized UX reports with `/jaan-to:ux-heatmap-analyze`. Includes ICE-scored recommendations and cross-reference validation.
- **Tech stack detection skill** — Auto-detect your project's tech stack and populate context files.
- **UX role activated** — First UX skill available alongside PM and Data roles.

---

## 3.2.0 — 2026-02-03

### Improved
- **Interactive prompts** — All skills now use structured multiple-choice prompts for clearer decision points.

---

## 3.1.0 — 2026-02-03

### New
- **Roadmap maintenance skill** — Keep your roadmap in sync with your codebase using `/jaan-to:roadmap-update`. Detects stale tasks, syncs status, and generates progress reports.
- **Auto-commit roadmap updates** — Roadmap task status updates automatically after commits.

---

## 3.0.0 — 2026-02-02

### New
- **Full configuration system** — Customize paths, templates, learning behavior, and tech stack integration via `jaan-to/config/settings.yaml`.
- **Template variables** — Use `{{field}}`, `{{env:VAR}}`, and `{{config:key}}` in your templates.
- **Tech stack integration** — PRDs and other outputs auto-reference your project's tech stack.

### Important
- **Breaking change** — Paths now use environment variables. See the migration guide for upgrade steps.

---

## 2.2.0 — 2026-02-02

### New
- **User story skill** — Generate user stories with Given/When/Then acceptance criteria using `/jaan-to:pm-story-write`. INVEST validation, edge case mapping, story splitting, and Jira/Linear export.

---

## 2.1.1 — 2026-02-02

*Maintenance release — improved research skill quality and workflow.*

---

## 2.1.0 — 2026-02-01

### Improved
- **Unified research skill** — Topic research and file/URL indexing merged into a single `/jaan-to:pm-research-about` command with automatic input detection.

---

## 2.0.1 — 2026-02-01

*Maintenance release — fixed marketplace and plugin manifest formatting.*

---

## 2.0.0 — 2026-01-31

### Important
- **Breaking change** — Project directory renamed from `.jaan-to/` (hidden) to `jaan-to/` (visible). Existing projects auto-migrate on next session.

---

## 1.3.1 — 2026-01-31

### Fixed
- **Skills now properly learn from past runs** — Fixed an issue where accumulated lessons were skipped during skill execution.

---

## 1.3.0 — 2026-01-31

### Improved
- **Consistent skill naming** — All skills renamed to use clear, consistent prefixes based on their role.

---

## 1.0.0 — 2026-01-29

### New
- **jaan.to launches** with 10 skills, 2 AI agents, and a learning system:
  - **PRD writing** (`/jaan-to:pm-prd-write`) — Generate comprehensive product requirements documents.
  - **GTM tracking** (`/jaan-to:data-gtm-datalayer`) — Generate Google Tag Manager dataLayer specifications.
  - **Deep research** (`/jaan-to:pm-research-about`) — Research any topic with source citations.
  - **Documentation** (`/jaan-to:docs-create`, `/jaan-to:docs-update`) — Create and maintain project documentation.
  - **Skill management** (`/jaan-to:skill-create`, `/jaan-to:skill-update`) — Create and update skills.
  - **Learning** (`/jaan-to:learn-add`) — Capture lessons that improve future skill runs.
  - **Roadmap** (`/jaan-to:roadmap-add`) — Add prioritized tasks to your roadmap.
  - **Quality reviewer agent** — Reviews outputs for completeness and accuracy.
  - **Context scout agent** — Gathers relevant context from your codebase before generation.
  - **Two-phase workflow** — Every skill runs Analysis first, then asks for your approval before generating.
