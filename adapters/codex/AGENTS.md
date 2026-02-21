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
./jaan-to setup /path/to/your-project
```

2. Treat `${CLAUDE_PLUGIN_ROOT}` as the package root.

3. Treat `${CLAUDE_PROJECT_DIR}` as the active project root.

4. Keep all writes within the project `jaan-to/` structure unless the skill explicitly requires another location.

5. Preserve each skill's two-phase workflow and human approval gates before write operations.

## Slash Router Contract

Recognize and route these commands deterministically:
- `/jaan-init` -> `jaan-init` skill
- `/jaan-to:list` -> list available commands
- `/jaan-to:help` -> show quick usage
- `/jaan-to:{skill-name}` -> run matching skill if it exists

### Routing Rules

1. Parse command and arguments.
2. Resolve skill name via `scripts/lib/skill-registry.sh`.
3. If unknown skill, return suggestions from the registry and do not continue.
4. Resolve runtime context via `scripts/lib/runtime-context.sh`.
5. Apply pre-execution protocol from `docs/extending/pre-execution-protocol.md`.
6. Execute the target `skills/{name}/SKILL.md` exactly as written.
7. Enforce all skill-level hard stops and user approvals before write operations.

## CLI Router (Terminal)

Use the package runner for terminal invocations:

```bash
./jaan-to list
./jaan-to run /jaan-to:pm-prd-write "feature"
./jaan-to /jaan-to:detect-dev --full
```

The runner uses the same shared registry and runtime context contract as slash routing.
