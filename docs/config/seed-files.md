---
title: Seed Files
sidebar_position: 6
doc_type: config
created_date: 2026-02-08
updated_date: 2026-02-08
tags: [config, bootstrap, seed, setup]
related: [README.md, ../hooks/bootstrap.md, ../guides/customization.md]
---

# Seed Files

> Starter files the plugin copies into your project on first run — edit them to make jaan.to yours.

---

## What Is It?

When you first use the plugin, the [bootstrap hook](../hooks/bootstrap.md) copies default files into your project's `jaan-to/` directory. These are **seed files** — starting points you customize for your team and stack.

Every seed follows a **skip-if-exists** rule: your edits are never overwritten. Delete a file and bootstrap re-copies the default next session.

---

## What Gets Seeded

| Category | Source (plugin) | Destination (project) | What's Inside |
|----------|----------------|----------------------|---------------|
| Settings | `scripts/seeds/settings.yaml` | `jaan-to/config/settings.yaml` | Path overrides, learning strategy, language preference, template paths |
| Context | `scripts/seeds/*.md` | `jaan-to/context/` | 5 required: tech.md, team.md, integrations.md, config.md, boundaries.md + 2 optional: localization.md, tone-of-voice.md |
| Docs | _(loaded from plugin at runtime)_ | — | STYLE.md and create-skill.md read from plugin source; not copied to project |
| Templates | `skills/*/template.md` | `jaan-to/templates/jaan-to:{skill}.template.md` | Output structure for each skill — seeded on first use (with approval) via [pre-execution protocol Step C](../extending/pre-execution-protocol.md#step-c-offer-template-seeding) |
| Learn files | `skills/*/LEARN.md` | _(loaded from plugin at runtime)_ | Better questions, edge cases, workflow tips — project files created via `/jaan-to:learn-add` |

---

## Your First Steps

After bootstrap runs, customize files in this order:

1. **Edit `jaan-to/context/tech.md`** — Replace the placeholder stack with yours. Or run `/jaan-to:detect-dev` to audit your codebase and produce evidence-backed findings.
2. **Fill `jaan-to/context/team.md`** — Team size, ceremonies, sprint settings, approval workflows.
3. **Add tools to `jaan-to/context/integrations.md`** — Jira project keys, GitHub repos, Slack channels, analytics IDs.
4. **Customize a template** (optional) — When you first run a skill, you'll be offered to seed its template into `jaan-to/templates/jaan-to:{skill}.template.md`. Accept to get a local copy you can edit. You can also manually copy any template from the plugin (`skills/{skill}/template.md`).
5. **Override paths** (advanced) — Uncomment settings in `jaan-to/config/settings.yaml` to redirect where outputs, templates, or learn files live. See [Customization Guide](../guides/customization.md).

---

## Example

Customizing `tech.md` for a Laravel project:

**Before** (seed default):
```markdown
> Project: {project-name}

### Backend
- **Language**: Python 3.11
- **Framework**: FastAPI 0.104
```

**After** (your version):
```markdown
> Project: Acme Dashboard

### Backend
- **Language**: PHP 8.3
- **Framework**: Laravel 11
- **Database**: MySQL 8
```

**Result**: When you run `/jaan-to:pm-prd-write`, the generated PRD references Laravel and MySQL. When you run `/jaan-to:backend-task-breakdown`, task cards use Laravel conventions.

---

## Metrics

The plugin tracks usage locally. Nothing leaves your machine.

| Metric | Location | Trigger |
|--------|----------|---------|
| Session log | `jaan-to/metrics/sessions.jsonl` | Stop hook — one JSON line per session end |
| Bootstrap stats | stdout JSON | SessionStart — `files_copied` counts per category |
| Skill budget | `scripts/validate-skills.sh` | Manual or CI — chars used vs 15,000 budget |
| Install health | `scripts/verify-install.sh` | Manual — checks passed/failed, file counts |

`jaan-to/metrics/` is created by the Stop hook, not bootstrap. The session log grows over time — safe to delete or truncate.

---

## Tips

- **Reset a file**: Delete it from `jaan-to/` and start a new session — bootstrap restores the default (for context and config files). Templates are seeded on first skill use; delete a seeded template to re-trigger the seeding offer on next run. Learn files are read from the plugin at runtime.
- **Check completeness**: Run `scripts/verify-install.sh` for a full health report.
- **Placeholders**: Context seeds use `{placeholder}` syntax. Fill what's relevant, delete sections you don't need.
- **Template variables**: Templates use `{{handlebars}}` variables. Change the structure around them, but keep the variables so skills can fill them.
- **Learning strategy**: `settings.yaml` defaults to `merge` — plugin lessons combine with any project-specific lessons you add.

---

## Related

- [Bootstrap Hook](../hooks/bootstrap.md) — How and when seed files get copied
- [Customization Guide](../guides/customization.md) — 3-layer config system (defaults, project, env vars)
- [Context System](context-system.md) — How skills read your context files
- [Stacks](stacks.md) — Deep dive into tech.md, team.md, integrations.md
