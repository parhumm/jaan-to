# Guardrails

> Safety boundaries that cannot be disabled.

---

## What Are Guardrails?

Non-negotiable safety rules. Unlike permissions, boundaries cannot be overridden.

---

## Core Rules

| Rule | Description |
|------|-------------|
| Safe Paths | Only write to `.jaan-to/` by default |
| Preview First | Always show content before writing |
| Approval Required | User must confirm every write |
| No Secrets | Scan output for credentials |

---

## Safe Paths

**Default allowed**:
- `.jaan-to/` - All outputs
- `.jaan-to/outputs/` - Skill outputs

**Always denied**:
- `src/`, `lib/` - Source code
- `.env`, `*.config.*` - Configuration
- Hidden directories (except `.jaan-to/`)
- `package.json` - Package files

---

## Preview Requirement

Before any write, you see:

```
Preview:
---
[content here]
---
Write this file? [y/n]
```

You must explicitly approve.

---

## Extending Safe Paths

Add to `.jaan-to/context/config.md`:

```markdown
## Trust Overrides
- safe_paths: [".jaan-to/", "docs/"]
```

This allows writing to `docs/` in addition to `.jaan-to/`.

---

## Why Guardrails Exist

Skills generate outputs, not production code. Guardrails ensure:
- No accidental source changes
- No credential exposure
- Human review of all outputs

---

## Guardrail File

`.jaan-to/context/boundaries.md`

Contains the detailed rules and enforcement logic.
