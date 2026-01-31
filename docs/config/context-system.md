---
title: Context System
doc_type: config
created_date: 2026-01-29
updated_date: 2026-01-29
tags: [config, context, templates]
related: [README.md, stacks.md, guardrails.md]
---

# Context System

> Project context files that skills read to understand your environment, team, and constraints.

---

## What Is It?

The `context/` directory contains files that tell skills about your project. Skills read these before generating output so results match your tech stack, team structure, and integration tools.

---

## File Location

Plugin ships templates in `context/` (plugin-relative). Fill them in for your project.

---

## Context Files

| File | Purpose | Skills That Read It |
|------|---------|---------------------|
| `.jaan-to/context/config.md` | Enabled roles, available skills, trust settings, defaults | All skills |
| `.jaan-to/context/boundaries.md` | Safe write paths, denied locations, enforcement rules | All skills (write operations) |
| `.jaan-to/context/tech.md` | Languages, frameworks, infrastructure, tools, constraints | pm-prd-write, skill-create |
| `.jaan-to/context/team.md` | Team structure, roles, communication channels | pm-prd-write |
| `.jaan-to/context/integrations.md` | External tools, APIs, third-party services | data-gtm-datalayer, pm-prd-write |

---

## How to Configure

1. Open the context file you want to customize (e.g., `.jaan-to/context/tech.md`)
2. Replace `{placeholder}` values with your project details
3. Delete the example section at the bottom
4. Skills automatically read updated files on next invocation

---

## Examples

**Tech stack** (`.jaan-to/context/tech.md`):
```
| Layer | Technology | Version |
|-------|------------|---------|
| Backend | Python | 3.11 |
| Frontend | TypeScript | 5.0 |
```

**Boundaries** (`.jaan-to/context/boundaries.md`):
```
| Path | Purpose |
|------|---------|
| .jaan-to/ | All jaan.to generated outputs |
| .jaan-to/outputs/ | Skill outputs |
```

---

## Related

- [Config Overview](README.md)
- [Stacks](stacks.md)
- [Guardrails](guardrails.md)
