---
title: "docs-update"
sidebar_position: 3
---

# /jaan-to:docs-update

> Smart documentation auditing with git-based staleness detection.

---

## What It Does

**Default (no args):** Uses git history to find docs that are out of sync with their source code. Compares when code changed vs when docs were last updated.

**Full audit:** Scans all docs for quality issues, checks frontmatter, structure, links, duplicates, and STYLE.md compliance.

---

## Usage

```
/jaan-to:docs-update [path] [--full] [--fix] [--check-only] [--quick]
```

| Argument | Effect |
|----------|--------|
| (none) | **Smart default:** staleness check |
| `[path]` | Check specific path only |
| `--full` | Skip staleness, do full audit |
| `--fix` | Auto-fix issues |
| `--check-only` | Report only, no changes |
| `--quick` | Inventory only |

---

## How It Maps Code to Docs

| Code Path | Related Doc |
|-----------|-------------|
| `skills/{name}/` | `docs/skills/{role}/{slug}.md` |
| `scripts/{name}.sh` | `docs/hooks/{name}.md` |
| `jaan-to/context/config.md` | `docs/config/README.md` |
| `jaan-to/context/*.md` | `docs/config/context-system.md` |

---

## What It Checks (Full Audit)

| Check | Description |
|-------|-------------|
| Frontmatter | Valid YAML with required fields |
| Structure | H1, tagline, separators |
| Line limits | Under max for doc type |
| Links | Internal links valid |
| Duplicates | Similar content detected |
| Location | File in correct folder |

---

## Output: Staleness Report (Default)

```markdown
# Documentation Staleness Report
**Code changes:** 5 files | **Docs checked:** 12

## Potentially Outdated
| Doc | Related Code | Delta |
|-----|--------------|-------|
| docs/skills/pm/prd-write.md | pm-prd-write/SKILL.md | 15d stale |

## Missing Documentation
| Code File | Expected Doc |
|-----------|--------------|
| new-skill/SKILL.md | docs/skills/?/new-skill.md |

[1] Review stale  [2] Full audit  [3] Quick fix  [4] Exit
```

---

## Output: Full Audit Report

```markdown
# Documentation Audit Report
**Files:** 21 | **Issues:** 5

## Summary
| Category | Count |
|----------|-------|
| ✅ Healthy | 16 |
| ⚠️ Need Updates | 3 |
| 🔴 Deprecated | 1 |
| 📦 Duplicates | 1 |

## Priority Actions
1. **hooks/old-hook.md** - Deprecated - Archive
2. **config/settings.md** - Missing frontmatter - Fix
```

---

## Example

**Smart staleness check (default)**:
```
/jaan-to:docs-update
```

**Full audit**:
```
/jaan-to:docs-update --full
```

**Full audit with auto-fix**:
```
/jaan-to:docs-update --full --fix
```

**Check specific path**:
```
/jaan-to:docs-update docs/skills/ --check-only
```

---

## Fixes Applied

| Issue | Auto-Fix |
|-------|----------|
| Missing frontmatter | Adds with defaults |
| Missing dates | Adds current date |
| Missing separators | Adds `---` |
| H4+ headings | Converts to H3 |
| Deprecated docs | Archives to docs/archive/ |
| Broken links | Reports with suggestions |
| Duplicates | Suggests consolidation |

---

## Tips

- Run without args for smart staleness detection
- Use `--full` when you want comprehensive quality checks
- Staleness threshold is 7 days (code changed > 7d before doc)
- Deprecated docs are archived, never deleted
- Updates `updated_date` on all modified files
