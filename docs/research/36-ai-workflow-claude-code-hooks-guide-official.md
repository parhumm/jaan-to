# Get Started with Claude Code Hooks

> Official quickstart guide for customizing and extending Claude Code's behavior with shell commands that execute at lifecycle points.
> Source: https://code.claude.com/docs/en/hooks-guide.md
> Added: 2026-01-29

---

## What Are Hooks?

User-defined shell commands that execute at various points in Claude Code's lifecycle. Unlike CLAUDE.md instructions (advisory), hooks are **deterministic** and **guaranteed** to run.

### Use Cases
- **Notifications**: Custom alerts when Claude awaits input
- **Auto formatting**: Run `prettier`, `gofmt` after file edits
- **Logging**: Track all executed commands
- **Feedback**: Automated code convention checks
- **Custom permissions**: Block modifications to sensitive files

---

## Hook Events Overview

| Event | When It Fires |
|-------|---------------|
| **PreToolUse** | Before tool calls (can block them) |
| **PermissionRequest** | When permission dialog shown (can allow/deny) |
| **PostToolUse** | After tool calls complete |
| **UserPromptSubmit** | When user submits prompt, before processing |
| **Notification** | When Claude sends notifications |
| **Stop** | When Claude finishes responding |
| **SubagentStop** | When subagent tasks complete |
| **PreCompact** | Before compact operation |
| **Setup** | On `--init`, `--init-only`, or `--maintenance` |
| **SessionStart** | New session or resume |
| **SessionEnd** | Session terminates |

---

## Quickstart: Command Logger

### Step 1: Open hooks configuration
Run `/hooks` and select `PreToolUse`

### Step 2: Add matcher
Select `+ Add new matcher…`, type `Bash`

### Step 3: Add hook command
```bash
jq -r '"\(.tool_input.command) - \(.tool_input.description // "No description")"' >> ~/.claude/bash-command-log.txt
```

### Step 4: Save
Choose `User settings` for cross-project use.

### Result in settings.json:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '\"\\(.tool_input.command) - \\(.tool_input.description // \"No description\")\"' >> ~/.claude/bash-command-log.txt"
          }
        ]
      }
    ]
  }
}
```

---

## More Examples

### Code Formatting (PostToolUse)
Auto-format TypeScript files after editing:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read file_path; if echo \"$file_path\" | grep -q '\\.ts$'; then npx prettier --write \"$file_path\"; fi; }"
          }
        ]
      }
    ]
  }
}
```

### Markdown Formatting (PostToolUse)
Auto-fix missing language tags and formatting:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/markdown_formatter.py"
          }
        ]
      }
    ]
  }
}
```

Python script features:
- Detects programming languages in unlabeled code blocks
- Adds appropriate language tags for syntax highlighting
- Fixes excessive blank lines
- Only processes `.md` and `.mdx` files

### Custom Notifications
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Awaiting your input'"
          }
        ]
      }
    ]
  }
}
```

### File Protection (PreToolUse)
Block edits to sensitive files:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json, sys; data=json.load(sys.stdin); path=data.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(p in path for p in ['.env', 'package-lock.json', '.git/']) else 0)\""
          }
        ]
      }
    ]
  }
}
```

---

## Key Points

- **Matcher**: Tool name pattern (exact match, regex like `Edit|Write`, or `*` for all)
- **Exit code 0**: Success (proceed)
- **Exit code 2**: Block the action (stderr shown to Claude)
- **Other exit codes**: Non-blocking error
- Hooks run in parallel when multiple match
- 60-second default timeout (configurable per command)
- `$CLAUDE_PROJECT_DIR` available for project-relative paths
