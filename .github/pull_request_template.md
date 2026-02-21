## Summary

- What changed:
- Why this change is needed:
- How it was tested:

## Dual-Runtime Required Checklist

- [ ] I ran `bash scripts/validate-multi-runtime.sh` successfully.
- [ ] I ran `bash scripts/validate-claude-compat.sh` successfully.
- [ ] I ran `bash scripts/validate-codex-runner.sh` successfully.
- [ ] I did not add adapter-specific logic inside `skills/*/SKILL.md`.
- [ ] Claude compatibility and install flow are unchanged.

## Runtime Scope

- [ ] Shared core only (`skills/`, `scripts/`, `agents/`, `config/`, `docs/extending/`)
- [ ] Adapter-only changes (`.claude-plugin/`, `hooks/`, `CLAUDE.md`, `adapters/codex/`)

## Validation Output (paste key lines)

```text
# validate-multi-runtime.sh output summary:

# validate-claude-compat.sh output summary:

# validate-codex-runner.sh output summary:
```
