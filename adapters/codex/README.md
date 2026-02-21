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
```

Then open `/path/to/your-project` in Codex app and use:

```bash
/skills
# or mention skills with $
$pm-prd-write
```

Terminal wrapper is still available:

```bash
./jaan-to list
./jaan-to run /jaan-to:pm-prd-write "user authentication"
./jaan-to /jaan-to:detect-dev --full
```

Important: Codex does not natively autocomplete `/jaan-to:*` plugin-style commands.
Setup installs skills into `.agents/skills` so they are discoverable via `/skills` and `$skill` invocation.

## Validation

```bash
bash scripts/validate-codex-runner.sh
```
