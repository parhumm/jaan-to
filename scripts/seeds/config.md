# jaan.to Configuration

> Phase 1 | v0.1.0

---

## Version
- phase: 1
- version: 0.1.0

## References
- Skill Specification: `jaan-to/docs/create-skill.md` (project)
- Style Guide: `jaan-to/docs/STYLE.md` (project)

## Enabled Roles
- pm (Product Manager)
- dev (Development)
- data (Analytics)
- ux (User Experience)
- core (Internal)

## Planned Roles (Phase 5)
- dev (Development) - 17 skills [4 active: fe-task-breakdown, be-task-breakdown, be-data-model, api-contract]
- qa (Quality Assurance) - 12 skills
- growth (SEO + Content) - 15 skills

> See [roadmaps/jaan-to/tasks/role-skills.md](../roadmaps/jaan-to/tasks/role-skills.md) for full catalog

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
| dev-stack-detect | `/jaan-to:dev-stack-detect` | Auto-detect tech stack and populate context |
| ux-research-synthesize | `/jaan-to:ux-research-synthesize` | Synthesize research findings into themes and recommendations |
| ux-heatmap-analyze | `/jaan-to:ux-heatmap-analyze` | Analyze heatmap CSV + screenshots for UX insights |
| ux-microcopy-write | `/jaan-to:ux-microcopy-write` | Generate multi-language microcopy packs |
| dev-fe-task-breakdown | `/jaan-to:dev-fe-task-breakdown` | Generate FE task breakdown from UX handoff |
| dev-be-task-breakdown | `/jaan-to:dev-be-task-breakdown` | Generate BE task breakdown from PRD |
| dev-fe-design | `/jaan-to:dev-fe-design` | Create distinctive, production-grade frontend components |
| dev-be-data-model | `/jaan-to:dev-be-data-model` | Generate data model docs with constraints, indexes, and migrations |
| dev-api-contract | `/jaan-to:dev-api-contract` | Generate OpenAPI 3.1 contracts from API entities |
| qa-test-cases | `/jaan-to:qa-test-cases` | Generate test cases from acceptance criteria |

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
