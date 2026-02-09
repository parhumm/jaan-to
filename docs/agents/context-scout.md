---
title: Context Scout
sidebar_position: 2
doc_type: concept
created_date: 2026-01-29
updated_date: 2026-01-29
tags: [agents, context, exploration]
related: [README.md, ../config/context-system.md]
---

# Context Scout

> Explores the user's project to gather context for skills that need project understanding.

---

## What It Does

The context-scout agent examines the user's project before a skill generates output. It gathers tech stack details, project structure, documentation patterns, and testing patterns so skills produce context-aware results.

---

## What It Gathers

| Area | How |
|------|-----|
| **Tech stack** | Reads `package.json`, `requirements.txt`, `go.mod`, etc. |
| **Project structure** | Scans directory layout and key patterns |
| **Documentation patterns** | Checks existing docs format and conventions |
| **Testing patterns** | Identifies test frameworks and file organization |

---

## How It Works

1. Scans the project root for dependency files and config
2. Maps the directory structure
3. Samples existing documentation and test files
4. Returns a structured context summary for the invoking skill

---

## Output

Returns a structured summary that skills consume during generation. The summary includes detected technologies, project conventions, and relevant patterns.

---

## Configuration

| Field | Value |
|-------|-------|
| **Location** | `agents/context-scout.md` |
| **Tools** | Read, Glob, Grep, Bash |
| **Model** | haiku |
| **Invocation** | Automatic (by skills pre-generation) |

---

## Related

- [Agents Overview](docs/agents/README.md)
- [Context System](../config/context-system.md)
