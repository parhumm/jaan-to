# jaan.to Configuration

> Phase 6 | v4.5.1

---

## Version
- phase: 6
- version: 4.5.1

## References
- Skill Specification: `jaan-to/docs/create-skill.md` (project)
- Style Guide: `jaan-to/docs/STYLE.md` (project)

## Enabled Roles
- pm (Product Manager)
- dev (Development)
- data (Analytics)
- ux (User Experience)
- wp (WordPress)
- core (Internal)

## Planned Roles (Phase 5)
- dev (Development) - 17 skills [7 active: frontend-task-breakdown, backend-task-breakdown, backend-data-model, backend-api-contract, backend-scaffold, frontend-scaffold, frontend-design]
- qa (Quality Assurance) - 12 skills
- growth (SEO + Content) - 15 skills

> See [docs/roadmap/tasks/role-skills.md](../docs/roadmap/tasks/role-skills.md) for full catalog

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| pm-prd-write | `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| roadmap-add | `/jaan-to:roadmap-add` | [Internal] Add task to roadmap |
| learn-add | `/jaan-to:learn-add` | Add lesson to skill's LEARN.md |
| docs-create | `/jaan-to:docs-create` | [Internal] Create documentation |
| docs-update | `/jaan-to:docs-update` | [Internal] Audit and fix documentation |
| skill-create | `/jaan-to:skill-create` | [Internal] Create new skill with wizard |
| skill-update | `/jaan-to:skill-update` | [Internal] Update existing skill |
| data-gtm-datalayer | `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code |
| pm-research-about | `/jaan-to:pm-research-about` | Deep research or add file/URL to index |
| pm-story-write | `/jaan-to:pm-story-write` | Generate user stories with Given/When/Then ACs |
| roadmap-update | `/jaan-to:roadmap-update` | [Internal] Maintain and sync roadmap |
| detect-dev | `/jaan-to:detect-dev` | Repo engineering audit with scored findings |
| detect-design | `/jaan-to:detect-design` | Design system detection with drift findings |
| detect-writing | `/jaan-to:detect-writing` | Writing system extraction with tone scoring |
| detect-product | `/jaan-to:detect-product` | Product reality extraction with evidence |
| detect-ux | `/jaan-to:detect-ux` | UX audit with journey/pain-point findings |
| detect-pack | `/jaan-to:detect-pack` | Consolidate detect outputs into knowledge index |
| ux-research-synthesize | `/jaan-to:ux-research-synthesize` | Synthesize research findings into themes and recommendations |
| ux-heatmap-analyze | `/jaan-to:ux-heatmap-analyze` | Analyze heatmap CSV + screenshots for UX insights |
| ux-microcopy-write | `/jaan-to:ux-microcopy-write` | Generate multi-language microcopy packs |
| ux-flowchart-generate | `/jaan-to:ux-flowchart-generate` | Generate Mermaid flowcharts from PRD/docs/codebase with evidence maps |
| frontend-task-breakdown | `/jaan-to:frontend-task-breakdown` | Generate FE task breakdown from UX handoff |
| backend-task-breakdown | `/jaan-to:backend-task-breakdown` | Generate BE task breakdown from PRD |
| frontend-design | `/jaan-to:frontend-design` | Create distinctive, production-grade frontend components |
| backend-data-model | `/jaan-to:backend-data-model` | Generate data model docs with constraints, indexes, and migrations |
| backend-api-contract | `/jaan-to:backend-api-contract` | Generate OpenAPI 3.1 contracts from API entities |
| qa-test-cases | `/jaan-to:qa-test-cases` | Generate test cases from acceptance criteria |
| backend-scaffold | `/jaan-to:backend-scaffold` | Generate production-ready backend code from specs |
| frontend-scaffold | `/jaan-to:frontend-scaffold` | Convert designs to React/Next.js scaffold code |
| wp-pr-review | `/jaan-to:wp-pr-review` | Review WordPress plugin PRs for security and standards |
| release-iterate-changelog | `/jaan-to:release-iterate-changelog` | Generate changelog with user impact notes and support guidance |
| jaan-issue-report | `/jaan-to:jaan-issue-report` | [Internal] Report issues to jaan-to GitHub repo or save locally |

## Language
- language: ask
- scope: plugin conversation, questions, report headings, labels, prose
- excluded: code, file paths, technical terms, variable names, YAML keys
- not affected: generated code output, product localization (localization.md), ux-microcopy-write multi-language output
- storage: jaan-to/config/settings.yaml
- per-skill override: language_{skill-name} in settings.yaml (optional)

## Trust
- trust_paths: ["jaan-to/"]
- require_preview: true
- require_approval: true

## Defaults
- output_dir: jaan-to/outputs
- model: inherit
