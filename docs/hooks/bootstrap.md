---
title: Bootstrap
sidebar_position: 2
doc_type: hook
created_date: 2026-01-29
updated_date: 2026-02-11
tags: [hooks, bootstrap, setup]
related: [README.md, ../config/context-system.md]
---

# bootstrap

> Idempotent first-run setup that creates project directories and copies seed data.

---

## When It Runs

- **Type**: SessionStart
- **Trigger**: Every session start
- **Matches**: All sessions (empty matcher)

---

## Per-Project Opt-In

Bootstrap checks if the project has been initialized before running. If `jaan-to/` directory does not exist, bootstrap exits early:

```json
{
  "status": "not_initialized",
  "message": "Run /jaan-to:jaan-init to activate jaan-to for this project"
}
```

To initialize a project, run `/jaan-to:jaan-init`. Once `jaan-to/` exists, bootstrap runs normally on every session start.

---

## What It Does

1. **Loads config system** — Sources `scripts/lib/config-loader.sh` to resolve customizable paths for templates, learn, context, and outputs. Falls back to defaults if missing.
2. **Creates directories** — Ensures all required project directories exist:
   - `jaan-to/outputs/`
   - `jaan-to/outputs/research/`
   - `jaan-to/learn/`
   - `jaan-to/context/`
   - `jaan-to/templates/`
   - `jaan-to/config/`
   - `jaan-to/docs/`
3. **Manages `.gitignore`** — Adds `jaan-to/` to `.gitignore` if not present. Creates `.gitignore` if it doesn't exist.
4. **Seeds config** — Copies `settings.yaml` from `scripts/seeds/` to `jaan-to/config/` if not present.
5. **Copies context files** — Copies `.md` seed files from `scripts/seeds/` to `jaan-to/context/` (skips existing).
6. **Copies docs** — Copies `STYLE.md` and `create-skill.md` to `jaan-to/docs/` (skips existing).
7. **Creates research README** — Generates `jaan-to/outputs/research/README.md` with index scaffold if not present.

> **Note**: Templates and learn files are **not** copied during bootstrap. They are loaded from the plugin at runtime (lazy loading). Project-level overrides can be created in `jaan-to/templates/` for templates and via `/jaan-to:learn-add` for learn files.
8. **Checks context seeds** — Verifies expected seed files (`tech.md`, `team.md`, `integrations.md`, `config.md`, `boundaries.md`) exist in the plugin.
9. **Suggests detect skills** — If `tech.md` still contains `{project-name}` placeholder, suggests running `/jaan-to:detect-pack` to perform full repo analysis.

---

## Behavior

| Result | Condition | Action |
|--------|-----------|--------|
| Creates directories | Any missing | Creates all 7 directories listed above |
| Appends to gitignore | `.gitignore` exists without entry | Appends `jaan-to/` |
| Creates gitignore | No `.gitignore` exists | Creates file with `jaan-to/` |
| Seeds config | `jaan-to/config/settings.yaml` missing | Copies from plugin seeds |
| Seeds context | Context `.md` files missing | Copies from `scripts/seeds/` |
| Seeds docs | `STYLE.md` or `create-skill.md` missing | Copies from plugin docs |
| Seeds research index | `outputs/research/README.md` missing | Generates scaffold README |
| Skips copy | Any destination file already exists | Preserves existing files |
| Suggests detect skills | `tech.md` contains `{project-name}` | Sets `suggest_detect: true` |
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
    "templates": 0,
    "docs": 2,
    "learn": 0
  },
  "missing_context": [],
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
  "suggest_detect": false
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

The plugin needs project-local directories for config, context, templates, outputs, docs, and learning data. Bootstrap creates these directories on first use and seeds context and config files so skills work immediately. Templates and learn files are loaded from the plugin at runtime (lazy loading) — project-level overrides are created only when the user explicitly customizes a template or adds lessons via `/jaan-to:learn-add`. Bootstrap is idempotent — running it multiple times is safe and only creates what's missing. Existing project files are never overwritten.

---

## Related

- [Hooks Overview](docs/hooks/README.md)
- [Context System](../config/context-system.md)
- [Seed Files](../config/seed-files.md) — What each file contains and how to customize
