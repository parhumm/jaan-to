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
| pm-prd-write | `/pm-prd-write` | Generate PRD from initiative |
| roadmap-add | `/roadmap-add` | [Internal] Add task to roadmap |
| learn-add | `/learn-add` | Add lesson to skill's LEARN.md |
| docs-create | `/docs-create` | [Internal] Create documentation |
| docs-update | `/docs-update` | [Internal] Audit and fix documentation |
| skill-create | `/skill-create` | [Internal] Create new skill with wizard |
| skill-update | `/skill-update` | [Internal] Update existing skill |
| data-gtm-datalayer | `/data-gtm-datalayer` | Generate GTM tracking code |
| pm-research-about | `/pm-research-about` | Deep research or add file/URL to index |
| pm-story-write | `/pm-story-write` | Generate user stories with Given/When/Then ACs |
| roadmap-update | `/roadmap-update` | [Internal] Maintain and sync roadmap |
| dev-stack-detect | `/dev-stack-detect` | Auto-detect tech stack and populate context |
| ux-research-synthesize | `/ux-research-synthesize` | Synthesize research findings into themes and recommendations |
| ux-heatmap-analyze | `/ux-heatmap-analyze` | Analyze heatmap CSV + screenshots for UX insights |
| ux-microcopy-write | `/ux-microcopy-write` | Generate multi-language microcopy packs |
| dev-fe-task-breakdown | `/dev-fe-task-breakdown` | Generate FE task breakdown from UX handoff |
| dev-be-task-breakdown | `/dev-be-task-breakdown` | Generate BE task breakdown from PRD |
| dev-fe-design | `/dev-fe-design` | Create distinctive, production-grade frontend components |
| qa-test-cases | `/qa-test-cases` | Generate test cases from acceptance criteria |

## Trust
- trust_paths: ["jaan-to/"]
- require_preview: true
- require_approval: true

## Defaults
- output_dir: jaan-to/outputs
- model: inherit
