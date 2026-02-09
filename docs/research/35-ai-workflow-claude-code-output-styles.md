# Output Styles

> Official guide for adapting Claude Code for uses beyond software engineering through output styles that modify the system prompt.
> Source: https://code.claude.com/docs/en/output-styles.md
> Added: 2026-01-29

---

## Overview

Output styles allow you to use Claude Code as any type of agent while keeping its core capabilities (running scripts, reading/writing files, tracking TODOs).

---

## Built-in Output Styles

| Style | Description |
|-------|-------------|
| **Default** | Standard system prompt for software engineering tasks |
| **Explanatory** | Provides educational "Insights" between helping with tasks. Helps understand implementation choices and codebase patterns |
| **Learning** | Collaborative learn-by-doing mode. Shares "Insights" and asks you to contribute code with `TODO(human)` markers |

---

## How Output Styles Work

- All styles exclude instructions for efficient output (concise responses)
- Custom styles exclude coding instructions unless `keep-coding-instructions` is true
- Custom instructions added to end of system prompt
- Reminders injected during conversation to maintain adherence

---

## Changing Output Style

```
/output-style                    # Menu selection
/output-style explanatory        # Direct switch
```

Saved in `.claude/settings.local.json` at local project level. Can also edit `outputStyle` field in settings directly.

---

## Creating Custom Output Styles

Custom output styles are Markdown files with frontmatter:

```markdown
---
name: My Custom Style
description: Brief description for UI display
---

# Custom Style Instructions

You are an interactive CLI tool that helps users with...

## Specific Behaviors
[Define behavior...]
```

### Storage Locations
- **User level**: `~/.claude/output-styles/`
- **Project level**: `.claude/output-styles/`

### Frontmatter

| Field | Purpose | Default |
|-------|---------|---------|
| `name` | Display name | Inherits from filename |
| `description` | UI description | None |
| `keep-coding-instructions` | Keep coding-related system prompt | `false` |

---

## Comparisons

### Output Styles vs CLAUDE.md vs --append-system-prompt
- **Output Styles**: Turn off default SE system prompt entirely
- **CLAUDE.md**: Added as user message following default prompt
- **--append-system-prompt**: Appended to system prompt (doesn't replace)

### Output Styles vs Agents
- **Output Styles**: Affect main agent loop, only modify system prompt
- **Agents**: Invoked for specific tasks, can include model, tools, context settings

### Output Styles vs Skills
- **Output Styles**: Modify how Claude responds (formatting, tone). Always active once selected
- **Skills**: Task-specific prompts invoked with `/skill-name` or auto-loaded when relevant
