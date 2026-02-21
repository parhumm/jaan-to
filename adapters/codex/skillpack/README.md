# Codex Distribution

This directory contains Codex-specific adapter files.

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

## Quickstart in Codex

```bash
# Build skillpack source
bash ./scripts/build-codex-skillpack.sh

# Install global skillpack via Codex Skill Installer wrapper
bash ./scripts/install-codex-skillpack.sh
# Restart Codex
```

Then open `/path/to/your-project` in Codex app and use:

```bash
/skills
# or mention skills with $
$jaan-init
$pm-prd-write
```

Aliases are intentionally preserved:

```bash
/jaan-init
/jaan-to:pm-prd-write
$pm-prd-write
```

Terminal wrapper is still available:

```bash
# Global/default mode
./jaan-to setup /path/to/your-project --mode auto

# Local legacy mode (debug only)
./jaan-to setup /path/to/your-project --mode local
```

`auto` mode resolves to global when `~/.agents/skills/jaan-to-codex-pack` exists, otherwise local.
When global pack is present, local mode is blocked by default to prevent duplicate-name ambiguity.

### Troubleshooting

- SSL certificate failure in installer auto mode:
  - Wrapper retries install with `--method git`.
- Duplicate skill ambiguity:
  - Remove project-local `.agents/skills/<jaan-to-skill>` entries and run global mode.
- New skills not visible:
  - Restart Codex.

## Validation

```bash
bash scripts/validate-codex-skillpack.sh
bash scripts/validate-codex-runner.sh
```
