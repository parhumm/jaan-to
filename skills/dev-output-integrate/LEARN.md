# Lessons: dev-output-integrate

> Last updated: 2026-02-12

Accumulated lessons from past executions.

---

## Better Questions

- Ask which outputs to integrate before scanning — users often know exactly which outputs they want
- Confirm the target project directory early — monorepo roots vs app subdirectories
- Ask about existing customizations in config files before proposing merges

## Edge Cases

- Monorepo output placement: flat output structure may not map to `packages/*/src/` — ask user for workspace target
- Multiple outputs may declare conflicting dependency versions — detect and present conflicts before install
- Partial integration failure: if entry point edit fails, previously copied files are already in place — document rollback path
- Config files with user customizations: never blindly overwrite package.json or tsconfig.json

## Workflow

- Always parse README instructions first — they are the source of truth for file placement
- Present the full integration plan before any writes — users need to see the scope
- Process merges separately from copies — merges need diff review
- Run validation after all files are written, not after each file

## Common Mistakes

- Overwriting existing config files without showing diffs first
- Forgetting to create parent directories before writing files
- Registering security plugins in wrong order (must follow helmet → CORS → rate-limit → session → CSRF → sensible)
- Not detecting the correct package manager from lockfile
- Hardcoding `npm` instead of detecting the project's package manager
