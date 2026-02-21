# jaan.to Codex Adapter

This Codex package is generated from the same shared source as the Claude plugin.

## Single Source of Truth

- Shared skill logic: `skills/*/SKILL.md`
- Shared templates and lessons: `skills/*/template.md`, `skills/*/LEARN.md`
- Shared runtime utilities: `scripts/`
- Shared config defaults: `config/defaults.yaml`
- Shared references: `docs/extending/`, `docs/STYLE.md`

Only thin runtime adapters differ by target:
- Claude adapter: `.claude-plugin/`, `hooks/`, `CLAUDE.md`
- Codex adapter: this `AGENTS.md` and `jaan-to`

## Runtime Contract for Codex

1. Initialize project files once per project:
```bash
./jaan-to setup /path/to/your-project --mode auto
```

2. Treat `${CLAUDE_PLUGIN_ROOT}` as the package root.

3. Treat `${CLAUDE_PROJECT_DIR}` as the active project root.

4. Keep all writes within the project `jaan-to/` structure unless the skill explicitly requires another location.

5. Preserve each skill's two-phase workflow and human approval gates before write operations.

## Codex Invocation Contract

Codex global skillpack is the primary install mode. Local mode remains available for debug/development.

1. Global-first setup:
```bash
bash ./scripts/install-codex-skillpack.sh
# Restart Codex
./jaan-to setup /path/to/your-project --mode auto
```
In auto mode, setup resolves to global when `~/.agents/skills/jaan-to-codex-pack` exists.

2. Local legacy mode (only when intentionally testing symlinked local skills):
```bash
./jaan-to setup /path/to/your-project --mode local
```
Local mode is blocked by default when global pack is installed to prevent duplicate-name ambiguity.

3. In Codex app (opened at your project root), invoke skills via:
- `/skills` (discover installed skills)
- `$<skill-name>` mentions in the composer (example: `$pm-prd-write`)

4. Preserve aliases:
- `/jaan-to:{skill}` maps to `$<skill>`
- `/jaan-init` maps to `$jaan-init`

## CLI Router (Terminal Wrapper)

Use the package runner for terminal invocations:

```bash
./jaan-to list
./jaan-to run /jaan-to:pm-prd-write "feature"
./jaan-to /jaan-to:detect-dev --full
```

The runner uses the same shared registry and runtime context contract as slash routing.
