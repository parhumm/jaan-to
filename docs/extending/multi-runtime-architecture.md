---
title: "Multi-Runtime Architecture"
sidebar_position: 8
---

# Multi-Runtime Architecture

> One canonical source tree, multiple runtime packages.

---

## Goal

Maintain jaan.to in one place, then produce runtime-specific outputs that match each agent:
- Claude Code plugin package
- Codex package

No forked skill logic.

---

## Canonical Source (Shared)

These directories are the single source of truth for development:

| Path | Role |
|------|------|
| `skills/` | Skill behavior and templates |
| `scripts/` | Shared bootstrap, validation, and utilities |
| `agents/` | Reusable subagent instructions |
| `config/` | Default settings |
| `docs/extending/` | Skill protocol references |
| `docs/STYLE.md` | Documentation style contract |

---

## Runtime Adapters (Thin Layer)

Only runtime-specific wrappers live outside shared core:

| Runtime | Adapter Files |
|---------|---------------|
| Claude | `.claude-plugin/`, `hooks/`, `CLAUDE.md` |
| Codex | `adapters/codex/AGENTS.md`, `scripts/codex-bootstrap.sh` |

Adapter rule: keep adapters small and avoid duplicating skill logic.

---

## Build Targets

Use a single build entry point with runtime targets:

```bash
./scripts/build-target.sh claude
./scripts/build-target.sh codex
./scripts/build-all-targets.sh
```

Outputs:
- `dist/jaan-to-claude` (Claude package)
- `dist/jaan-to-codex` (Codex package)

`scripts/build-dist.sh` is preserved as a backward-compatible Claude wrapper.

---

## Development Workflow

1. Change shared files in `skills/`, `scripts/`, `agents/`, `config/`, `docs/extending/`
2. Build targets
3. Smoke-test each target runtime

This keeps behavior parity while allowing runtime-specific packaging.

---

## Practical Guidance

- Put execution rules in `SKILL.md`, not in adapters.
- Keep runtime bootstrap wrappers focused on environment mapping.
- If a runtime needs special behavior, implement it as a thin wrapper script that calls shared logic.

## Shared Core vs Adapters

To keep features naturally compatible across Claude and Codex:

- **Shared core** (default location for new feature logic):
  - `skills/`
  - `scripts/`
  - `agents/`
  - `config/`
  - `docs/extending/`
- **Runtime adapters only** (small wrappers, no core behavior):
  - `.claude-plugin/`, `hooks/`, `CLAUDE.md`
  - `adapters/codex/AGENTS.md`

Rule of thumb: avoid platform-specific behavior inside `skills/*/SKILL.md`.
