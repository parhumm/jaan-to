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
| [Skills](skills/README.md) | Available commands by role |
| [Agents](agents/README.md) | Plugin agents |
| [Hooks](hooks/README.md) | Automated triggers |
| [Config](config/README.md) | Settings and context |
| [Learning](learning/README.md) | Feedback system |
| [Extending](extending/README.md) | Create new skills |
| [Style Guide](https://github.com/parhumm/jaan-to/blob/main/docs/STYLE.md) | Documentation standards |

---

## Available Commands

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:pm-prd-write` | Generate PRD | `jaan-to/outputs/pm/{slug}/prd.md` |
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code | `jaan-to/outputs/data/gtm/{slug}/` |
| `/jaan-to:skill-create` | Create new skill | `skills/{name}/` |
| `/jaan-to:skill-update` | Update existing skill | `skills/{name}/SKILL.md` |
| `/jaan-to:docs-create` | Create documentation | `docs/{type}/{name}.md` |
| `/jaan-to:docs-update` | Audit documentation | Fixes in-place |
| `/jaan-to:learn-add` | Add feedback | `jaan-to/learn/{name}.learn.md` |
| `/jaan-to:pm-research-about` | Deep research or add to index | `jaan-to/outputs/research/` |
| `/jaan-to:roadmap-add` | Add roadmap task | `jaan-to/roadmap.md` |

---

## Key Paths

| Path | Purpose |
|------|---------|
| `jaan-to/outputs/` | Generated outputs (project-relative) |
| `jaan-to/context/` | Your context (tech, team) (project-relative) |
| `skills/` | Skill definitions (plugin-relative) |
| `.claude-plugin/plugin.json` | Plugin manifest |
