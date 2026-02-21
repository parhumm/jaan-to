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
| `scripts/` | Shared bootstrap, validation, utilities, runtime contracts |
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
| Codex | `adapters/codex/AGENTS.md`, `adapters/codex/jaan-to`, `scripts/codex-bootstrap.sh` |

Adapter rule: keep adapters small and avoid duplicating skill logic.

---

## Runtime Contract Library

`/scripts/lib/runtime-contract.sh` defines runtime paths and required files in one place:
- Dist directory mapping (`claude`, `codex`)
- Required files per runtime
- Forbidden Codex artifacts in Claude dist
- Shared-core and adapter path references

Use this library from validators and build scripts instead of hardcoding runtime paths.

---

## Build Targets

Use one build entry point with runtime targets:

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

## Validation Gates

Use script-driven dual-runtime validation:

```bash
bash scripts/validate-multi-runtime.sh
bash scripts/validate-claude-compat.sh
bash scripts/validate-codex-runner.sh
```

This enforces:
- Claude non-regression
- Codex runner/router contract
- Shared skill parity across both outputs

---

## Development Workflow

1. Change shared files in `skills/`, `scripts/`, `agents/`, `config/`, `docs/extending/`
2. Build targets
3. Run dual-runtime validation scripts
4. Open PR (CI runs reusable dual-runtime gate)

This keeps behavior parity while allowing runtime-specific packaging.

---

## Extending to New Runtimes

When adding a new runtime:
1. Extend `scripts/lib/runtime-contract.sh` with new target + required files.
2. Add thin adapter files under `adapters/<runtime>/`.
3. Update `scripts/build-target.sh` with packaging logic.
4. Add runtime-specific validator and wire it into `validate-multi-runtime.sh`.
5. Reuse existing CI gate workflow instead of creating ad-hoc checks.

This preserves one development surface and minimizes runtime drift.
