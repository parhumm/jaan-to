# Hooks Reference

> Official technical reference for implementing hooks in Claude Code, covering all lifecycle events, input/output schemas, and security.
> Source: https://code.claude.com/docs/en/hooks.md
> Added: 2026-01-29

---

## Hook Lifecycle Events

| Hook | When It Fires |
|------|---------------|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | User submits a prompt |
| `PreToolUse` | Before tool execution |
| `PermissionRequest` | When permission dialog appears |
| `PostToolUse` | After tool succeeds |
| `PostToolUseFailure` | After tool fails |
| `SubagentStart` | When spawning a subagent |
| `SubagentStop` | When subagent finishes |
| `Stop` | Claude finishes responding |
| `PreCompact` | Before context compaction |
| `SessionEnd` | Session terminates |
| `Notification` | Claude sends notifications |

---

## Configuration

Stored in settings files:
- `~/.claude/settings.json` (User)
- `.claude/settings.json` (Project)
- `.claude/settings.local.json` (Local, not committed)
- Managed policy settings

### Structure
```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-command-here",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Matcher Rules
- Exact match: `Write`
- Regex: `Edit|Write`, `Notebook.*`
- All tools: `*` or empty string

---

## Hook Types

### Command Hooks (`type: "command"`)
Execute bash commands. Input via stdin (JSON), output via stdout/stderr.

### Prompt Hooks (`type: "prompt"`)
Send prompt to LLM (Haiku) for context-aware decisions.

```json
{
  "type": "prompt",
  "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete.",
  "timeout": 30
}
```

Response schema: `{"ok": true|false, "reason": "explanation"}`

Best for Stop, SubagentStop, UserPromptSubmit, PreToolUse events.

---

## Exit Codes

| Code | Behavior |
|------|----------|
| **0** | Success. stdout shown in verbose mode. JSON parsed for structured control |
| **2** | Blocking error. stderr fed back to Claude |
| **Other** | Non-blocking error. stderr shown in verbose mode |

### Exit Code 2 Behavior by Event

| Event | Behavior |
|-------|----------|
| PreToolUse | Blocks tool call, shows stderr to Claude |
| PermissionRequest | Denies permission, shows stderr to Claude |
| PostToolUse | Shows stderr to Claude (tool already ran) |
| UserPromptSubmit | Blocks prompt, erases it, shows stderr to user |
| Stop | Blocks stoppage, shows stderr to Claude |
| SubagentStop | Blocks stoppage, shows stderr to subagent |
| Others | Shows stderr to user only |

---

## Common Hook Input Fields

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/session.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "..." },
  "tool_use_id": "toolu_01ABC..."
}
```

### Key Tool Input Schemas

**Bash**: `{ command, description, timeout, run_in_background }`
**Write**: `{ file_path, content }`
**Edit**: `{ file_path, old_string, new_string, replace_all }`
**Read**: `{ file_path, offset, limit }`

---

## JSON Output Control

### Common Fields (all hooks)
```json
{
  "continue": true,
  "stopReason": "string",
  "suppressOutput": true,
  "systemMessage": "string"
}
```

### PreToolUse Decision Control
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "reason",
    "updatedInput": { "field": "new value" },
    "additionalContext": "extra info for Claude"
  }
}
```

### PermissionRequest Decision Control
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": { "command": "npm run lint" },
      "message": "reason for deny",
      "interrupt": false
    }
  }
}
```

### PostToolUse Decision Control
```json
{
  "decision": "block",
  "reason": "explanation"
}
```

### Stop/SubagentStop Decision Control
```json
{
  "decision": "block",
  "reason": "Must complete remaining tasks"
}
```

### UserPromptSubmit
- **Plain text stdout**: Added as context (exit code 0)
- **JSON with `additionalContext`**: Structured context injection
- **`"decision": "block"`**: Prevents prompt processing

### SessionStart
`CLAUDE_ENV_FILE` available for persisting environment variables:
```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

---

## Notification Matchers

- `permission_prompt` - Permission requests
- `idle_prompt` - Waiting for user input (60+ seconds)
- `auth_success` - Authentication success
- `elicitation_dialog` - MCP tool input needed

---

## PreCompact Matchers

- `manual` - From `/compact`
- `auto` - From auto-compact

---

## Setup Matchers

- `init` - From `--init` or `--init-only`
- `maintenance` - From `--maintenance`

---

## SessionStart Matchers

- `startup` - New session
- `resume` - From `--resume`, `--continue`, `/resume`
- `clear` - From `/clear`
- `compact` - From compaction

---

## Plugin Hooks

Defined in `hooks/hooks.json` at plugin root. Merged with user/project hooks. Uses `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths.

---

## Hooks in Skills and Agents

Supported events: PreToolUse, PostToolUse, Stop. Scoped to component lifecycle.

Skills support `once: true` to run hook only once per session.

---

## Execution Details

- **Timeout**: 60s default, configurable per command
- **Parallelization**: All matching hooks run in parallel
- **Deduplication**: Identical commands deduplicated
- **Environment**: `CLAUDE_PROJECT_DIR`, `CLAUDE_CODE_REMOTE`
- **Safety**: Snapshot at startup, warns if modified externally

---

## Security Considerations

1. Validate and sanitize inputs
2. Always quote shell variables (`"$VAR"`)
3. Block path traversal (`..`)
4. Use absolute paths
5. Skip sensitive files (`.env`, `.git/`, keys)
