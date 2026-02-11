---
title: "dev-project-assemble"
sidebar_position: 3
doc_type: skill
created_date: 2026-02-11
updated_date: 2026-02-11
tags: [dev, project, assemble, scaffold, monorepo, configs, entry-points]
related: [backend-scaffold, frontend-scaffold, frontend-design]
---

# /jaan-to:dev-project-assemble

> Wire backend + frontend scaffold outputs into a runnable project with proper directory tree, configs, and entry points.

---

## Overview

Takes scaffold outputs (from `/jaan-to:backend-scaffold` and `/jaan-to:frontend-scaffold`) and assembles them into a working project structure with configs, entry points, provider wiring, and environment setup. Supports monorepo and separate-project layouts, auto-detected from `tech.md`.

---

## Usage

```
/jaan-to:dev-project-assemble
/jaan-to:dev-project-assemble backend-scaffold frontend-scaffold [target-dir]
```

| Argument | Required | Description |
|----------|----------|-------------|
| backend-scaffold | No | Path to backend scaffold output folder |
| frontend-scaffold | No | Path to frontend scaffold output folder |
| frontend-design | No | Path to HTML previews (optional) |
| target-dir | No | Target project directory (default: cwd) |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/dev/project-assemble/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Assembly log with decisions and structure |
| Project files | Entry points, configs, .env.example, .gitignore |

Supports monorepo (Turborepo/Nx) and separate project layouts.

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Project structure | Not in tech.md | Monorepo vs separate projects |
| Monorepo tool | Monorepo chosen | Turborepo / Nx |
| Package manager | Not in tech.md | npm / pnpm / yarn |
| Provider wiring plan | Always | Confirm shared providers and client hooks |

---

## Multi-Stack Support

Reads `$JAAN_CONTEXT_DIR/tech.md` to auto-detect:

| Stack | Monorepo Tool | Frontend | Backend |
|-------|---------------|----------|---------|
| Node.js / TypeScript | Turborepo / Nx | Next.js + TailwindCSS | Fastify + Prisma |
| PHP | Separate projects | Next.js / Blade | Laravel |
| Go | Separate projects | Next.js | Chi / stdlib |

---

## Workflow Chain

```
/jaan-to:backend-scaffold + /jaan-to:frontend-scaffold --> /jaan-to:dev-project-assemble --> /jaan-to:devops-infra-scaffold
```

---

## Example

**Input:**
```
/jaan-to:dev-project-assemble path/to/backend-scaffold path/to/frontend-scaffold
```

**Output:**
```
jaan-to/outputs/dev/project-assemble/01-my-app/
├── 01-my-app.md
├── src/
│   ├── backend/ (or packages/api/)
│   └── frontend/ (or packages/web/)
├── package.json
├── tsconfig.json
├── .env.example
└── .gitignore
```

---

## Tips

- Run `/jaan-to:backend-scaffold` and `/jaan-to:frontend-scaffold` first
- Set up `$JAAN_CONTEXT_DIR/tech.md` to skip detection questions
- Review the assembly log for wiring decisions before copying to your project
- Use `/jaan-to:devops-infra-scaffold` next to add CI/CD and Docker

---

## Related Skills

- [/jaan-to:backend-scaffold](../backend/scaffold.md) - Generate backend code from specs
- [/jaan-to:frontend-scaffold](../frontend/scaffold.md) - Convert designs to React/Next.js components
- [/jaan-to:devops-infra-scaffold](../devops/infra-scaffold.md) - Generate CI/CD and deployment configs

---

## Technical Details

- **Logical Name**: dev-project-assemble
- **Command**: `/jaan-to:dev-project-assemble`
- **Role**: dev
- **Output**: `$JAAN_OUTPUTS_DIR/dev/project-assemble/{id}-{slug}/`
