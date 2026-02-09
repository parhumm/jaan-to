# CLI Reference

> Official complete reference for Claude Code command-line interface, including commands, flags, and configuration options.
> Source: https://code.claude.com/docs/en/cli-reference.md
> Added: 2026-01-29

---

## CLI Commands

| Command | Description |
|---------|-------------|
| `claude` | Start interactive REPL |
| `claude "query"` | Start REPL with initial prompt |
| `claude -p "query"` | Query via SDK, then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -c -p "query"` | Continue via SDK |
| `claude -r "<session>" "query"` | Resume by ID or name |
| `claude update` | Update to latest version |
| `claude mcp` | Configure MCP servers |

---

## Key CLI Flags

### Session Management

| Flag | Description |
|------|-------------|
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--fork-session` | Create new session ID when resuming |
| `--session-id` | Use specific UUID for conversation |
| `--no-session-persistence` | Don't save session to disk (print mode) |

### Model & Prompt

| Flag | Description |
|------|-------------|
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--fallback-model` | Fallback when default overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace from file (print mode) |
| `--append-system-prompt` | Append to default prompt |
| `--append-system-prompt-file` | Append from file (print mode) |

### Permissions & Safety

| Flag | Description |
|------|-------------|
| `--allowedTools` | Tools that execute without permission |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict available built-in tools |
| `--permission-mode` | Start in permission mode (plan, acceptEdits, etc.) |
| `--dangerously-skip-permissions` | Skip all permission checks |
| `--allow-dangerously-skip-permissions` | Enable as option without activating |

### Output & Format

| Flag | Description |
|------|-------------|
| `--print`, `-p` | Print mode (non-interactive) |
| `--output-format` | `text`, `json`, `stream-json` |
| `--input-format` | `text`, `stream-json` |
| `--json-schema` | Get validated JSON matching schema |
| `--include-partial-messages` | Include streaming events |
| `--verbose` | Full turn-by-turn output |

### Extensions

| Flag | Description |
|------|-------------|
| `--agents` | Define subagents via JSON |
| `--agent` | Specify agent for session |
| `--mcp-config` | Load MCP servers from JSON |
| `--strict-mcp-config` | Only use MCP from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory |
| `--chrome` / `--no-chrome` | Toggle Chrome integration |

### Other

| Flag | Description |
|------|-------------|
| `--add-dir` | Add working directories |
| `--betas` | Beta headers for API |
| `--debug` | Debug mode with category filtering |
| `--disable-slash-commands` | Disable skills/commands |
| `--ide` | Auto-connect to IDE |
| `--init` / `--init-only` | Run Setup hooks |
| `--maintenance` | Run Setup hooks with maintenance trigger |
| `--max-budget-usd` | Max API spend (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--remote` | Create web session on claude.ai |
| `--teleport` | Resume web session locally |
| `--setting-sources` | Comma-separated setting sources |
| `--settings` | Load settings from file or JSON |
| `--version`, `-v` | Show version |

---

## `--agents` JSON Format

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer.",
    "prompt": "You are a senior code reviewer.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | When to invoke the subagent |
| `prompt` | Yes | System prompt |
| `tools` | No | Tool array. Inherits all if omitted |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` |

---

## System Prompt Flags

| Flag | Behavior | Modes |
|------|----------|-------|
| `--system-prompt` | **Replaces** entire default | Interactive + Print |
| `--system-prompt-file` | **Replaces** with file contents | Print only |
| `--append-system-prompt` | **Appends** to default | Interactive + Print |
| `--append-system-prompt-file` | **Appends** file to default | Print only |

- `--system-prompt` and `--system-prompt-file` are mutually exclusive
- Append flags can combine with either replacement flag
- `--append-system-prompt` is recommended for most cases (preserves built-in capabilities)
