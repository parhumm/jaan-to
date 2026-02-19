---
title: "jaan-init"
sidebar_position: 9
doc_type: skill
created_date: 2026-02-10
updated_date: 2026-02-10
tags: [skills, core, setup, initialization]
related: [docs-create.md, ../../hooks/bootstrap.md]
---

# /jaan-to:jaan-init

> Activate jaan-to for the current project with directory setup and seed files.

---

## What It Does

Creates the `jaan-to/` directory in your project root and seeds it with starter files. After initialization, the bootstrap hook runs automatically on every session to keep directories and seeds up to date.

Projects without `jaan-to/` are not affected by the plugin.

---

## Usage

```
/jaan-to:jaan-init
```

No arguments required. Run once per project.

---

## What It Asks

| Question | Why |
|----------|-----|
| "Initialize jaan-to for this project?" | Confirms before creating directories |

---

## What Gets Created

```
jaan-to/
  config/settings.yaml    — Project configuration
  context/                 — Project context (tech.md, team.md, etc.)
  templates/               — Output templates (customizable)
  outputs/                 — Generated outputs from skills
  outputs/research/        — Research index and reports
  learn/                   — Accumulated skill lessons
  docs/                    — Reference docs (STYLE.md, create-skill.md)
```

Also adds `jaan-to/` to `.gitignore` (creates the file if missing).

---

## Output

**Path**: `jaan-to/` (project root)

**Contains**:
- `config/settings.yaml` — language, paths, template overrides
- `context/*.md` — tech stack, team, integrations, boundaries
- `templates/*.template.md` — one template per skill
- `learn/*.learn.md` — one learn file per skill
- `docs/STYLE.md` — documentation standards
- `docs/create-skill.md` — skill authoring spec

---

## Example

**Input**:
```
/jaan-to:jaan-init
```

**First run** (files are seeded):
```json
{
  "status": "complete",
  "files_copied": {
    "config": 1,
    "context": 5,
    "templates": 12,
    "docs": 2,
    "learn": 8
  },
  "suggest_detect": true
}
```

**Already initialized**:
```
jaan-to is already initialized for this project.
Bootstrap runs automatically on each session.
```

---

## Next Steps After Init

1. Edit `jaan-to/context/tech.md` with your project's tech stack
2. Run `/jaan-to:detect-pack` for automatic project analysis
3. Run any skill: `/jaan-to:pm-prd-write "feature name"`

---

## Tips

- Run once per project — bootstrap handles subsequent sessions automatically
- Existing files are never overwritten by bootstrap
- Customize paths in `jaan-to/config/settings.yaml` if defaults don't fit
- If `tech.md` still has `{project-name}` placeholder, run `/jaan-to:detect-pack`

---

## Related

- [Bootstrap Hook](../../hooks/bootstrap.md) — What runs on every session after init
- [Getting Started](../../getting-started.md) — First skill in 5 minutes
- [Configuration](../../config/README.md) — Customize settings and context
