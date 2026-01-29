# jaan.to Configuration

> **DEPRECATED**: This file is superseded by `.claude-plugin/plugin.json` and `context/config.md`.
> Kept for backward compatibility during migration.

> Phase 1 | v0.1.0

---

## Version
- phase: 1
- version: 0.1.0

## References
- Skill Specification: [docs/extending/create-skill.md](../docs/extending/create-skill.md)
- Style Guide: [docs/STYLE.md](../docs/STYLE.md)

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
| jaan-to-pm-prd:write | `/jaan-to-pm-prd-write` | Generate PRD from initiative |
| to-jaan-roadmap:add | `/to-jaan-roadmap-add` | [Internal] Add task to roadmap |
| to-jaan-learn:add | `/to-jaan-learn-add` | Add lesson to skill's LEARN.md |
| to-jaan-docs:create | `/to-jaan-docs-create` | [Internal] Create documentation |
| to-jaan-docs:update | `/to-jaan-docs-update` | [Internal] Audit and fix documentation |
| to-jaan-skill:create | `/to-jaan-skill-create` | [Internal] Create new skill with wizard |
| to-jaan-skill:update | `/to-jaan-skill-update` | [Internal] Update existing skill |
| jaan-to-data-gtm:datalayer | `/jaan-to-data-gtm-datalayer` | Generate GTM tracking code |
| to-jaan-research:about | `/to-jaan-research-about` | Deep research on any topic |
| to-jaan-research:add | `/to-jaan-research-add` | Add file/URL to research index |

## Trust
- trust_paths: [".jaan-to/"]
- require_preview: true
- require_approval: true

## Defaults
- output_dir: .jaan-to/outputs
- model: inherit
