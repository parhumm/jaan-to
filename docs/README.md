---
title: "Introduction"
sidebar_position: 1
slug: /
---

# jaan.to

> Modular workflow layer for Claude Code. Skills generate outputs. System learns from feedback.

---

## What It Does

jaan.to adds structured commands to Claude Code that generate consistent, high-quality outputs. Each command follows a two-phase workflow: gather context, then generate with your approval.

---

## Features

- **Skills** - Commands that generate PRDs, plans, specs
- **Stacks** - Your team and tech context
- **Learning** - System improves from your feedback
- **Hooks** - Automated validation and prompts
- **Safety** - Write only to safe paths, preview before save

---

## Quick Start

```
/jaan-to:pm-prd-write "user authentication feature"
```

Output: `jaan-to/outputs/pm/user-auth/prd.md`

See [Getting Started](getting-started.md) for full walkthrough.

---

## Navigation

| Section | Description |
|---------|-------------|
| [Getting Started](getting-started.md) | First skill in 5 minutes |
| [Concepts](concepts.md) | Core ideas explained |
| [Token Strategy](token-strategy.md) | Token optimization approach |
| [Skills](skills/README.md) | Available commands by role |
| [Agents](agents/README.md) | Plugin agents |
| [Hooks](hooks/README.md) | Automated triggers |
| [Config](config/README.md) | Settings and context |
| [Learning](learning/README.md) | Feedback system |
| [Extending](extending/README.md) | Create new skills |
| [Roadmap](roadmap/roadmap.md) | Version history and tasks |
| [Research](research/README.md) | Deep research library |
| [Style Guide](https://github.com/parhumm/jaan-to/blob/main/docs/STYLE.md) | Documentation standards |

---

## Available Commands

50 skills across 13 roles. See [Skills by Role](skills/README.md) for the complete list.

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:pm-prd-write` | Generate PRD | `jaan-to/outputs/pm/{slug}/prd.md` |
| `/jaan-to:backend-scaffold` | Generate backend code | `jaan-to/outputs/backend/scaffold/{slug}/` |
| `/jaan-to:frontend-scaffold` | Generate frontend components | `jaan-to/outputs/frontend/scaffold/{slug}/` |
| `/jaan-to:dev-project-assemble` | Wire scaffolds into runnable project | `jaan-to/outputs/dev/project-assemble/{slug}/` |
| `/jaan-to:backend-service-implement` | Generate service implementations | `jaan-to/outputs/backend/service-implement/{slug}/` |
| `/jaan-to:qa-test-generate` | Generate Vitest/Playwright tests | `jaan-to/outputs/qa/test-generate/{slug}/` |
| `/jaan-to:sec-audit-remediate` | Fix security findings | `jaan-to/outputs/sec/remediate/{slug}/` |
| `/jaan-to:devops-infra-scaffold` | Generate CI/CD and Docker configs | `jaan-to/outputs/devops/infra-scaffold/{slug}/` |
| `/jaan-to:detect-dev` | Engineering audit | `jaan-to/outputs/detect/dev/` |
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code | `jaan-to/outputs/data/gtm/{slug}/` |
| `/jaan-to:docs-create` | Create documentation | `docs/{type}/{name}.md` |
| `/jaan-to:learn-add` | Add feedback | `jaan-to/learn/{name}.learn.md` |

---

## Key Paths

| Path | Purpose |
|------|---------|
| `jaan-to/outputs/` | Generated outputs (project-relative) |
| `jaan-to/context/` | Your context (tech, team) (project-relative) |
| `skills/` | Skill definitions (plugin-relative) |
| `.claude-plugin/plugin.json` | Plugin manifest |
