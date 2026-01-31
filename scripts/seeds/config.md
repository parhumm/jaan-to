# jaan.to Configuration

> Phase 1 | v0.1.0

---

## Version
- phase: 1
- version: 0.1.0

## References
- Skill Specification: `.jaan-to/docs/create-skill.md` (project)
- Style Guide: `.jaan-to/docs/STYLE.md` (project)

## Enabled Roles
- pm (Product Manager)
- data (Analytics)
- core (Internal)

## Planned Roles (Phase 3)
- dev (Development) - 5 skills
- qa (Quality Assurance) - 5 skills
- growth (SEO + Content) - 5 skills
- ux (User Experience) - 5 skills

> See [roadmaps/jaan-to/tasks/role-skills.md](../roadmaps/jaan-to/tasks/role-skills.md) for full catalog

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| jaan-to:pm-prd-write | `/jaan-to:pm-prd-write` | Generate PRD from initiative |
| jaan-to:jaan-roadmap-add | `/jaan-to:jaan-roadmap-add` | [Internal] Add task to roadmap |
| jaan-to:jaan-learn-add | `/jaan-to:jaan-learn-add` | Add lesson to skill's LEARN.md |
| jaan-to:jaan-docs-create | `/jaan-to:jaan-docs-create` | [Internal] Create documentation |
| jaan-to:jaan-docs-update | `/jaan-to:jaan-docs-update` | [Internal] Audit and fix documentation |
| jaan-to:jaan-skill-create | `/jaan-to:jaan-skill-create` | [Internal] Create new skill with wizard |
| jaan-to:jaan-skill-update | `/jaan-to:jaan-skill-update` | [Internal] Update existing skill |
| jaan-to:data-gtm-datalayer | `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code |
| jaan-to:jaan-research-about | `/jaan-to:jaan-research-about` | Deep research on any topic |
| jaan-to:jaan-research-add | `/jaan-to:jaan-research-add` | Add file/URL to research index |

## Trust
- trust_paths: [".jaan-to/"]
- require_preview: true
- require_approval: true

## Defaults
- output_dir: .jaan-to/outputs
- model: inherit
