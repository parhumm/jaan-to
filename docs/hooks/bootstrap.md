---
title: Bootstrap
doc_type: hook
created_date: 2026-01-29
updated_date: 2026-01-29
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

## What It Does

1. Creates `jaan-to/outputs/` and `jaan-to/learn/` directories
2. Adds `jaan-to/` to the project's `.gitignore`
3. Copies seed LEARN.md files from plugin `skills/*/LEARN.md` to `jaan-to/learn/{name}.learn.md`
4. Detects old standalone skills (`.claude/skills/jaan-to-*` or `.claude/skills/to-jaan-*`)
5. Checks for missing context files in the plugin

---

## Behavior

| Result | Condition | Action |
|--------|-----------|--------|
| Creates directories | `jaan-to/` doesn't exist | Makes `jaan-to/outputs/` and `jaan-to/learn/` |
| Skips copy | `jaan-to/learn/{name}.learn.md` already exists | Preserves existing project lessons |
| Warns | Old standalone skills detected | Reports migration needed |
| Warns | Context files missing | Lists missing files |

---

## What You See

**First run** (new project):
```json
{
  "status": "created",
  "path": "jaan-to/"
}
```

**Subsequent runs** (existing project):
```json
{
  "status": "complete",
  "output_dir": "jaan-to/outputs",
  "learn_dir": "jaan-to/learn",
  "missing_context": [],
  "old_standalone_skills": [],
  "migration_needed": false
}
```

**With old standalone skills**:
```json
{
  "old_standalone_skills": ["jaan-to-pm-prd-write", "to-jaan-learn-add"],
  "migration_needed": true
}
```

---

## Why It Exists

The plugin needs project-local directories for outputs and learning data. Bootstrap creates these on first use so skills work immediately. It's idempotent — running it multiple times is safe and only creates what's missing.

---

## Related

- [Hooks Overview](README.md)
- [Context System](../config/context-system.md)
