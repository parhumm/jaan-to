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
- Codex adapter: this `AGENTS.md` and `scripts/codex-bootstrap.sh`

## Runtime Contract for Codex

1. Initialize project files once per project:
```bash
bash scripts/codex-bootstrap.sh /path/to/your-project
```

2. Treat `${CLAUDE_PLUGIN_ROOT}` in skill files as the package root.

3. Treat `${CLAUDE_PROJECT_DIR}` as the active project root.

4. Keep all writes within the project `jaan-to/` structure unless the skill explicitly requires another location.

5. Preserve each skill's two-phase workflow and human approval gates before write operations.

## Path Resolution

Skill files use existing path variables for portability. In Codex runs:
- `CLAUDE_PLUGIN_ROOT` must point to this package root
- `CLAUDE_PROJECT_DIR` must point to the target project root

The `scripts/codex-bootstrap.sh` wrapper sets these variables before calling the shared bootstrap flow.
