# Codex Distribution

This directory contains Codex-specific adapter files.

## Quick Install (Global-First)

```bash
# End-user one-command install
bash <(curl -fsSL https://raw.githubusercontent.com/parhumm/jaan-to/main/scripts/install-codex-skillpack.sh)
```

Local fallback (inside this repo):

```bash
bash ./scripts/install-codex-skillpack.sh
```

After install:

1. Restart Codex.
2. Open your project in Codex.
3. Run `/jaan-init` once.
4. Use `/skills`, `/jaan-to:*`, `/jaan-init`, or native `$skill`.

Quick verify:

```text
/skills
/jaan-init
/jaan-to:pm-prd-write
$pm-prd-write
```

## Purpose

jaan.to development stays centralized in shared sources (`skills/`, `scripts/`, `agents/`, `config/`, `docs/extending/`).
This adapter adds only Codex runtime instructions and a thin `./jaan-to` runner.

## Build

```bash
./scripts/build-target.sh codex
bash ./scripts/build-codex-skillpack.sh
```

Output package:
- `dist/jaan-to-codex/AGENTS.md`
- `dist/jaan-to-codex/jaan-to`
- `dist/jaan-to-codex/skills/`
- `dist/jaan-to-codex/scripts/`
- `dist/jaan-to-codex/agents/`
- `dist/jaan-to-codex/config/`
- `adapters/codex/skillpack/` (installable skillpack source for Codex Skill Installer)

## Invocation Contract

Aliases are intentionally preserved:

```bash
/jaan-init
/jaan-to:pm-prd-write
$pm-prd-write
```

Terminal wrapper remains available:

```bash
# Global/default mode
./jaan-to setup /path/to/your-project --mode auto

# Local legacy mode (debug only)
./jaan-to setup /path/to/your-project --mode local
```

`auto` mode resolves to global when `~/.agents/skills/jaan-to-codex-pack` exists, otherwise local.
When global pack is present, local mode is blocked by default to prevent duplicate-name ambiguity.

## Troubleshooting

- SSL certificate failure in installer auto mode:
  - Wrapper retries install with `--method git`.
- Duplicate skill ambiguity:
  - Remove project-local `.agents/skills/<jaan-to-skill>` entries and run global mode.
- New skills not visible:
  - Restart Codex.

## Validation

```bash
bash scripts/prepare-skill-pr.sh --check
bash scripts/validate-codex-skillpack.sh
bash scripts/validate-codex-runner.sh
```
