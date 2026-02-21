# Codex Distribution

This directory contains Codex-specific adapter files.

## Purpose

jaan.to development stays centralized in shared sources (`skills/`, `scripts/`, `agents/`, `config/`, `docs/extending/`).
This adapter adds only Codex runtime instructions.

## Build

```bash
./scripts/build-target.sh codex
```

Output package:
- `dist/jaan-to-codex/AGENTS.md`
- `dist/jaan-to-codex/skills/`
- `dist/jaan-to-codex/scripts/`
- `dist/jaan-to-codex/agents/`
- `dist/jaan-to-codex/config/`

## Project Initialization in Codex

```bash
bash scripts/codex-bootstrap.sh /path/to/your-project
```
