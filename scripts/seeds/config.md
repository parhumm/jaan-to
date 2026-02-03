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
- dev (Development) - 17 skills [2 active: fe-task-breakdown, be-task-breakdown]
- qa (Quality Assurance) - 12 skills
- growth (SEO + Content) - 15 skills

> See [roadmaps/jaan-to/tasks/role-skills.md](../roadmaps/jaan-to/tasks/role-skills.md) for full catalog

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| jaan-to-pm-prd-write | `/jaan-to-pm-prd-write` | Generate PRD from initiative |
| to-jaan-roadmap-add | `/to-jaan-roadmap-add` | [Internal] Add task to roadmap |
| to-jaan-learn-add | `/to-jaan-learn-add` | Add lesson to skill's LEARN.md |
| to-jaan-docs-create | `/to-jaan-docs-create` | [Internal] Create documentation |
| to-jaan-docs-update | `/to-jaan-docs-update` | [Internal] Audit and fix documentation |
| to-jaan-skill-create | `/to-jaan-skill-create` | [Internal] Create new skill with wizard |
| to-jaan-skill-update | `/to-jaan-skill-update` | [Internal] Update existing skill |
| jaan-to-data-gtm-datalayer | `/jaan-to-data-gtm-datalayer` | Generate GTM tracking code |
| jaan-to-pm-research-about | `/jaan-to-pm-research-about` | Deep research or add file/URL to index |
| jaan-to-pm-story-write | `/jaan-to-pm-story-write` | Generate user stories with Given/When/Then ACs |
| to-jaan-roadmap-update | `/to-jaan-roadmap-update` | [Internal] Maintain and sync roadmap |
| jaan-to-dev-stack-detect | `/jaan-to-dev-stack-detect` | Auto-detect tech stack and populate context |
| jaan-to-ux-research-synthesize | `/jaan-to-ux-research-synthesize` | Synthesize research findings into themes and recommendations |
| jaan-to-ux-heatmap-analyze | `/jaan-to-ux-heatmap-analyze` | Analyze heatmap CSV + screenshots for UX insights |
| jaan-to-ux-microcopy-write | `/jaan-to-ux-microcopy-write` | Generate multi-language microcopy packs |
| jaan-to-dev-fe-task-breakdown | `/jaan-to-dev-fe-task-breakdown` | Generate FE task breakdown from UX handoff |
| jaan-to-dev-be-task-breakdown | `/jaan-to-dev-be-task-breakdown` | Generate BE task breakdown from PRD |
| jaan-to-qa-test-cases | `/jaan-to-qa-test-cases` | Generate test cases from acceptance criteria |

## Trust
- trust_paths: ["jaan-to/"]
- require_preview: true
- require_approval: true

## Defaults
- output_dir: jaan-to/outputs
- model: inherit
