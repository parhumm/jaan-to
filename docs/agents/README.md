---
title: Agents
doc_type: index
created_date: 2026-01-29
updated_date: 2026-01-29
tags: [agents, plugin, automation]
related: [../skills/README.md]
---

# Agents

> Sub-agents that skills delegate to for focused tasks like quality review and context gathering.

---

## Overview

Agents are specialized sub-agents bundled with the jaan.to plugin. Skills invoke them to handle focused sub-tasks — reviewing output quality, gathering project context, etc.

Agents differ from skills:
- **Skills** are user-invoked commands (`/jaan-to-pm-prd-write`)
- **Agents** are skill-invoked helpers (users don't call them directly)
- **Agents** use restricted tool sets and lightweight models (haiku)

---

## Available Agents

| Agent | Description | Tools | Model |
|-------|-------------|-------|-------|
| [quality-reviewer](quality-reviewer.md) | Reviews outputs for completeness and STYLE.md compliance | Read, Glob, Grep | haiku |
| [context-scout](context-scout.md) | Explores user's project to gather context for generation | Read, Glob, Grep, Bash | haiku |

---

## Quick Reference

- Agents live in `agents/` (plugin-relative)
- Skills reference agents via the `agent:` frontmatter field in SKILL.md
- Agents are read-only by default (no Write tool)
- All agents use haiku for fast, low-cost execution
