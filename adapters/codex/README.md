# Codex Distribution

This directory contains Codex-specific adapter files.

## Purpose

jaan.to development stays centralized in shared sources (`skills/`, `scripts/`, `agents/`, `config/`, `docs/extending/`).
This adapter adds only Codex runtime instructions and a thin `./jaan-to` runner.

## Build

```bash
./scripts/build-target.sh codex
```

Output package:
- `dist/jaan-to-codex/AGENTS.md`
- `dist/jaan-to-codex/jaan-to`
- `dist/jaan-to-codex/skills/`
- `dist/jaan-to-codex/scripts/`
- `dist/jaan-to-codex/agents/`
- `dist/jaan-to-codex/config/`

## Quickstart in Codex

```bash
cd dist/jaan-to-codex
./jaan-to setup /path/to/your-project
./jaan-to list
./jaan-to run /jaan-to:pm-prd-write "user authentication"
```

Alias form:

```bash
./jaan-to /jaan-to:detect-dev --full
```

## Validation

```bash
bash scripts/validate-codex-runner.sh
```
