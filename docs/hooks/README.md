---
title: "Hooks"
sidebar_position: 1
---

# Hooks

> Automated triggers that run before or after actions.

---

## What is a Hook?

A hook is a script that runs automatically:
- **PreToolUse** - Before an action (e.g., validate before write)
- **PostToolUse** - After an action (e.g., prompt after write)

You don't call hooks. They run automatically when triggered.

---

## Available Hooks

| Hook | Type | Trigger |
|------|------|---------|
| [validate-prd](validate-prd.md) | PreToolUse | Before writing PRD |
| [capture-feedback](capture-feedback.md) | PostToolUse | After writing artifact |
| [post-commit-roadmap](post-commit-roadmap.md) | PostToolUse | After git commit |
| [bootstrap](bootstrap.md) | PreToolUse | Before skill execution |
| [team-quality-gate](team-quality-gate.md) | TaskCompleted | After task completion in agent teams |
| [team-idle-redirect](team-idle-redirect.md) | TeammateIdle | When agent teammate goes idle |
| [team-roles-sync-check](team-roles-sync-check.md) | PostToolUse | After writing SKILL.md files |

---

## How They Work

**PreToolUse hooks** can:
- Allow the action (exit 0)
- Warn but allow (exit 1)
- Block the action (exit 2)

**PostToolUse hooks** can:
- Display messages
- Prompt for input
- Never block

**TaskCompleted hooks** (Agent Teams):
- Allow completion (exit 0)
- Block completion with feedback (exit 2)

**TeammateIdle hooks** (Agent Teams):
- Allow idle (exit 0)
- Send feedback to keep working (exit 2)

---

## Hook Location

```
scripts/{hook-name}.sh
```

---

## Configuration

Hooks are registered in `hooks/hooks.json` (plugin-level) or SKILL.md frontmatter (skill-scoped):

**Plugin-level** (`hooks/hooks.json`):
```json
{
  "PreToolUse": [
    {
      "matcher": "Write",
      "hooks": ["scripts/validate-prd.sh"]
    }
  ]
}
```

**Skill-scoped** (SKILL.md frontmatter):
```yaml
---
hooks:
  PreToolUse:
    - matcher: Write
      hooks: ["scripts/validate-prd.sh"]
---
```

---

## Creating Hooks

See [Create a Hook](../extending/create-hook.md) for step-by-step guide.
