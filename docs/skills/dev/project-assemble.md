---
title: "dev-project-assemble"
sidebar_position: 3
doc_type: skill
created_date: 2026-02-11
updated_date: 2026-02-11
tags: [dev, project, assemble, scaffold, monorepo, configs, entry-points]
related: [backend-scaffold, frontend-scaffold, frontend-design]
---

# /dev-project-assemble

> Wire backend + frontend scaffold outputs into a runnable project with proper directory tree, configs, and entry points.

---

## Overview

Takes scaffold outputs (from `/backend-scaffold` and `/frontend-scaffold`) and assembles them into a working project structure with configs, entry points, provider wiring, and environment setup. Supports monorepo and separate-project layouts, auto-detected from `tech.md`.

---

## Usage

```
/dev-project-assemble
/dev-project-assemble backend-scaffold frontend-scaffold [target-dir]
```

| Argument | Required | Description |
|----------|----------|-------------|
| backend-scaffold | No | Path to backend scaffold output folder |
| frontend-scaffold | No | Path to frontend scaffold output folder |
| frontend-design | No | Path to HTML previews (optional) |
| backend-api-contract | Optional | Path to OpenAPI spec. Enables API documentation page generation (Scalar for Next.js). |
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

When an API contract is provided and the project is Node.js/TypeScript, generates a Scalar API reference page at `/reference`.

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
/backend-scaffold + /frontend-scaffold --> /dev-project-assemble --> /devops-infra-scaffold
```

---

## Example

**Input:**
```
/dev-project-assemble path/to/backend-scaffold path/to/frontend-scaffold
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

- Run `/backend-scaffold` and `/frontend-scaffold` first
- Set up `$JAAN_CONTEXT_DIR/tech.md` to skip detection questions
- Review the assembly log for wiring decisions before copying to your project
- Use `/devops-infra-scaffold` next to add CI/CD and Docker

---

## Related Skills

- [/backend-scaffold](../backend/scaffold.md) - Generate backend code from specs
- [/frontend-scaffold](../frontend/scaffold.md) - Convert designs to React/Next.js components
- [/devops-infra-scaffold](../devops/infra-scaffold.md) - Generate CI/CD and deployment configs

---

## Technical Details

- **Logical Name**: dev-project-assemble
- **Command**: `/dev-project-assemble`
- **Role**: dev
- **Output**: `$JAAN_OUTPUTS_DIR/dev/project-assemble/{id}-{slug}/`
