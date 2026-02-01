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
| jaan-to-pm-prd-write | `/jaan-to-pm-prd-write` | Generate PRD from initiative |
| to-jaan-roadmap-add | `/to-jaan-roadmap-add` | [Internal] Add task to roadmap |
| to-jaan-learn-add | `/to-jaan-learn-add` | Add lesson to skill's LEARN.md |
| to-jaan-docs-create | `/to-jaan-docs-create` | [Internal] Create documentation |
| to-jaan-docs-update | `/to-jaan-docs-update` | [Internal] Audit and fix documentation |
| to-jaan-skill-create | `/to-jaan-skill-create` | [Internal] Create new skill with wizard |
| to-jaan-skill-update | `/to-jaan-skill-update` | [Internal] Update existing skill |
| jaan-to-data-gtm-datalayer | `/jaan-to-data-gtm-datalayer` | Generate GTM tracking code |
| jaan-to-pm-research-about | `/jaan-to-pm-research-about` | Deep research or add file/URL to index |

## Trust
- trust_paths: ["jaan-to/"]
- require_preview: true
- require_approval: true

## Defaults
- output_dir: jaan-to/outputs
- model: inherit
