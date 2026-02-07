# Safe Paths Guardrail

> Non-negotiable safety rules for jaan.to

**TIP**: Run `/dev-stack-detect` to auto-generate safe paths based on your project structure.

---

## Allowed Write Locations

Only these paths are permitted for artifact output:

| Path | Purpose |
|------|---------|
| `jaan-to/**` | All jaan.to generated outputs (project-relative dir) |
| `docs/**` | Project documentation |

## Denied Locations

Everything else, specifically:
- Source code directories (`src/`, `lib/`, etc.)
- Configuration files (`.env`, `*.config.*`)
- System directories
- Hidden directories (except `.claude/`)
- Package files (`package.json`, etc.)

## Enforcement

1. **Before any write**: Check path starts with allowed prefix
2. **If denied**: Stop and ask user for explicit permission
3. **Always**: Preview content before writing

## Override

Users can extend safe paths in `jaan-to/context/config.md`:

```markdown
## Safety
- safe_paths: ["jaan-to/", "docs/"]
```
