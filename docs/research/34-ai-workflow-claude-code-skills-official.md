# Extend Claude with Skills

> Official guide for creating, managing, and sharing skills to extend Claude's capabilities in Claude Code. Includes custom slash commands.
> Source: https://code.claude.com/docs/en/skills.md
> Added: 2026-01-29

---

## Overview

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or invoke directly with `/skill-name`.

Skills follow the [Agent Skills](https://agentskills.io) open standard.

> Custom slash commands (`.claude/commands/`) have been merged into skills. Existing files keep working. Skills add: directory for supporting files, frontmatter for invocation control, and automatic loading.

---

## Where Skills Live

| Location | Path | Applies to |
|----------|------|------------|
| Enterprise | Managed settings | All users in org |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace.

### Skill Directory Structure
```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in
├── examples/
│   └── sample.md      # Example output
└── scripts/
    └── validate.sh    # Script Claude can execute
```

---

## Frontmatter Reference

```yaml
---
name: my-skill
description: What this skill does
argument-hint: [issue-number]
disable-model-invocation: true
user-invocable: false
allowed-tools: Read, Grep, Glob
model: sonnet
context: fork
agent: Explore
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
---
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name (lowercase, hyphens, max 64 chars). Falls back to directory name |
| `description` | Recommended | What it does; Claude uses for auto-loading decisions |
| `argument-hint` | No | Hint for autocomplete (e.g., `[issue-number]`) |
| `disable-model-invocation` | No | `true` = only user can invoke. Default: `false` |
| `user-invocable` | No | `false` = hidden from `/` menu. Default: `true` |
| `allowed-tools` | No | Tools Claude can use without permission when skill active |
| `model` | No | Model to use when skill active |
| `context` | No | `fork` to run in forked subagent context |
| `agent` | No | Which subagent type when `context: fork` |
| `hooks` | No | Hooks scoped to skill's lifecycle |

---

## String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed. If absent, args appended automatically |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | Current session ID |

---

## Content Types

### Reference Content (Knowledge)
```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
When writing API endpoints:
- Use RESTful naming
- Return consistent error formats
```

### Task Content (Workflows)
```yaml
---
name: deploy
description: Deploy to production
context: fork
disable-model-invocation: true
---
Deploy the application:
1. Run test suite
2. Build application
3. Push to deployment target
```

---

## Invocation Control

| Frontmatter | You can invoke | Claude can invoke | When loaded |
|-------------|----------------|-------------------|-------------|
| (default) | Yes | Yes | Description always in context, full skill on invoke |
| `disable-model-invocation: true` | Yes | No | Not in context, loads when you invoke |
| `user-invocable: false` | No | Yes | Description in context, loads when invoked |

---

## Advanced Patterns

### Dynamic Context with `!`command``
```yaml
---
name: pr-summary
context: fork
agent: Explore
---
## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`

## Your task
Summarize this pull request...
```

Commands run as preprocessing before Claude sees the prompt.

### Run in Subagent (`context: fork`)
Skill content becomes the subagent's task. Use `agent` field to specify agent type (Explore, Plan, general-purpose, or custom).

### Generate Visual Output
Skills can bundle scripts that generate interactive HTML files opened in the browser. Example: codebase-visualizer skill with Python script generating collapsible tree view.

---

## Restricting Claude's Skill Access

- **Disable all skills**: Deny `Skill` tool in `/permissions`
- **Allow/deny specific**: `Skill(commit)`, `Skill(review-pr *)`
- **Hide individual**: Add `disable-model-invocation: true` to frontmatter

---

## Sharing Skills

- **Project**: Commit `.claude/skills/` to version control
- **Plugins**: Create `skills/` directory in plugin
- **Managed**: Deploy via managed settings
