# Extending jaan.to

> Add new skills and hooks.

---

## What Can You Extend?

| Extension | Difficulty | Reference |
|-----------|------------|-----------|
| [New Skill](create-skill.md) | Medium | Complete specification for skill creation |
| [New Hook](create-hook.md) | Easy | Add automation trigger |

---

## Extension Principles

1. **Follow patterns** - Match existing naming and structure
2. **Start minimal** - Add complexity only when needed
3. **Test first** - Verify behavior before committing
4. **Document** - Add docs alongside implementation

---

## Quick Reference

**Skill location**: `skills/{name}/`

**Hook location**: `scripts/{hook-name}.sh`

**Register hook**: `hooks/hooks.json` (plugin-level) or SKILL.md frontmatter (skill-scoped)

---

## Next Steps

- [Create a Skill](create-skill.md) - Complete specification (schemas, examples, validation)
- [Create a Hook](create-hook.md) - Full walkthrough
