---
title: Bootstrap
sidebar_position: 2
doc_type: hook
created_date: 2026-01-29
updated_date: 2026-02-08
tags: [hooks, bootstrap, setup]
related: [README.md, ../config/context-system.md]
---

# bootstrap

> Idempotent first-run setup that creates project directories, copies seed data, and detects legacy installations.

---

## When It Runs

- **Type**: SessionStart
- **Trigger**: Every session start
- **Matches**: All sessions (empty matcher)

---

## What It Does

1. **Loads config system** — Sources `scripts/lib/config-loader.sh` to resolve customizable paths for templates, learn, context, and outputs. Falls back to defaults if missing.
2. **Migrates legacy directory** — Renames `.jaan-to/` to `jaan-to/` if the old directory exists and the new one doesn't.
3. **Migrates output directories** — Moves outputs from deprecated paths:
   - `jaan-to/outputs/dev/backend/**/*` → `jaan-to/outputs/backend/**/*`
   - `jaan-to/outputs/dev/frontend/**/*` → `jaan-to/outputs/frontend/**/*`
   - `jaan-to/outputs/dev/contract/**/*` → `jaan-to/outputs/backend/api-contract/**/*`
   - Splits `backend/` numbered folders into subdomain folders by filename pattern (data-model, task-breakdown)
   - Moves `frontend/components/**/*` → `frontend/design/**/*`
   - Splits `frontend/` numbered folders into subdomain folders by filename pattern (design, task-breakdown)
   - Removes empty parent directories after migration
4. **Creates directories** — Ensures all required project directories exist:
   - `jaan-to/outputs/`
   - `jaan-to/outputs/research/`
   - `jaan-to/learn/`
   - `jaan-to/context/`
   - `jaan-to/templates/`
   - `jaan-to/config/`
   - `jaan-to/docs/`
5. **Manages `.gitignore`** — Adds `jaan-to/` to `.gitignore`, migrating old `.jaan-to` entries if present. Creates `.gitignore` if it doesn't exist.
6. **Seeds config** — Copies `settings.yaml` from `scripts/seeds/` to `jaan-to/config/` if not present.
7. **Copies context files** — Copies `.md` seed files from `scripts/seeds/` to `jaan-to/context/` (skips existing).
8. **Copies skill templates** — Copies `skills/*/template.md` to `jaan-to/templates/{skill-name}.template.md` (skips existing).
9. **Copies docs** — Copies `STYLE.md` and `create-skill.md` to `jaan-to/docs/` (skips existing).
10. **Creates research README** — Generates `jaan-to/outputs/research/README.md` with index scaffold if not present.
11. **Copies LEARN.md seeds** — Copies `skills/*/LEARN.md` to `jaan-to/learn/{skill-name}.learn.md` (skips existing).
12. **Detects old standalone skills** — Scans `.claude/skills/` for legacy naming conventions (pre-v3.16 names).
13. **Checks context seeds** — Verifies expected seed files (`tech.md`, `team.md`, `integrations.md`, `config.md`, `boundaries.md`) exist in the plugin.
14. **Suggests detect skills** — If `tech.md` still contains `{project-name}` placeholder, suggests running `/jaan-to:detect-pack` to perform full repo analysis.

---

## Behavior

| Result | Condition | Action |
|--------|-----------|--------|
| Migrates directory | `.jaan-to/` exists, `jaan-to/` doesn't | Renames `.jaan-to/` → `jaan-to/` |
| Migrates output paths | `outputs/dev/backend` or `outputs/dev/frontend` exist | Moves to `outputs/backend` and `outputs/frontend` |
| Migrates api-contract | `outputs/dev/contract` exists | Moves to `outputs/backend/api-contract` |
| Splits backend outputs | Numbered folders in `outputs/backend/` | Routes to `backend/data-model/` or `backend/task-breakdown/` by filename pattern |
| Migrates design outputs | `outputs/frontend/components` exists | Moves to `outputs/frontend/design` |
| Splits frontend outputs | Numbered folders in `outputs/frontend/` | Routes to `frontend/design/` or `frontend/task-breakdown/` by filename pattern |
| Creates directories | Any missing | Creates all 7 directories listed above |
| Replaces gitignore entry | `.gitignore` has `.jaan-to` entry | Replaces with `jaan-to/` |
| Appends to gitignore | `.gitignore` exists without entry | Appends `jaan-to/` |
| Creates gitignore | No `.gitignore` exists | Creates file with `jaan-to/` |
| Seeds config | `jaan-to/config/settings.yaml` missing | Copies from plugin seeds |
| Seeds context | Context `.md` files missing | Copies from `scripts/seeds/` |
| Seeds templates | Template files missing | Copies from `skills/*/template.md` |
| Seeds docs | `STYLE.md` or `create-skill.md` missing | Copies from plugin docs |
| Seeds research index | `outputs/research/README.md` missing | Generates scaffold README |
| Seeds learn files | `{skill-name}.learn.md` missing | Copies from `skills/*/LEARN.md` |
| Skips copy | Any destination file already exists | Preserves existing files |
| Suggests detect skills | `tech.md` contains `{project-name}` | Sets `suggest_detect: true` |
| Warns | Old standalone skills detected | Reports `migration_needed: true` |
| Warns | Context seed files missing from plugin | Lists missing files |

---

## What You See

**First run** (new project — files are seeded):
```json
{
  "status": "complete",
  "config_loaded": true,
  "output_dir": "jaan-to/outputs",
  "learn_dir": "jaan-to/learn",
  "context_dir": "jaan-to/context",
  "templates_dir": "jaan-to/templates",
  "config_dir": "jaan-to/config",
  "paths_customized": false,
  "files_copied": {
    "config": 1,
    "context": 5,
    "templates": 12,
    "docs": 2,
    "learn": 8
  },
  "missing_context": [],
  "old_standalone_skills": [],
  "migration_needed": false,
  "suggest_detect": true
}
```

**Subsequent runs** (everything already exists):
```json
{
  "status": "complete",
  "config_loaded": true,
  "output_dir": "jaan-to/outputs",
  "learn_dir": "jaan-to/learn",
  "context_dir": "jaan-to/context",
  "templates_dir": "jaan-to/templates",
  "config_dir": "jaan-to/config",
  "paths_customized": false,
  "files_copied": {
    "config": 0,
    "context": 0,
    "templates": 0,
    "docs": 0,
    "learn": 0
  },
  "missing_context": [],
  "old_standalone_skills": [],
  "migration_needed": false,
  "suggest_detect": false
}
```

**With old standalone skills**:
```json
{
  "old_standalone_skills": ["pm-prd-write", "jaan-to-pm-prd-write"],
  "migration_needed": true
}
```

---

## Config-Driven Paths

All directory paths are resolved through `scripts/lib/config-loader.sh`, which reads from `jaan-to/config/settings.yaml`. This allows projects to customize where files are stored:

```yaml
# jaan-to/config/settings.yaml
paths_outputs: "artifacts/generated"
paths_templates: "my-templates"
paths_learning: "knowledge/learn"
paths_context: "knowledge/context"
```

When custom paths are active, the output includes `"paths_customized": true`.

---

## Why It Exists

The plugin needs project-local directories for config, context, templates, outputs, docs, and learning data. Bootstrap creates these on first use and seeds them with starter files so skills work immediately. It's idempotent — running it multiple times is safe and only creates what's missing. Existing project files are never overwritten.

---

## Related

- [Hooks Overview](docs/hooks/README.md)
- [Context System](../config/context-system.md)
- [Seed Files](../config/seed-files.md) — What each file contains and how to customize
