# Claude Code Settings

> Official configuration reference for Claude Code covering scope hierarchy, settings files, permissions, environment variables, and available tools.
> Source: https://code.claude.com/docs/en/settings.md
> Added: 2026-01-29

---

## Configuration Scopes

| Scope | Location | Who It Affects | Shared? |
|-------|----------|----------------|---------|
| **Managed** | System-level `managed-settings.json` | All users on machine | Yes (IT deployed) |
| **User** | `~/.claude/` | You, all projects | No |
| **Project** | `.claude/` in repo | All collaborators | Yes (committed) |
| **Local** | `.claude/*.local.*` | You, this repo only | No (gitignored) |

**Precedence** (highest to lowest):
1. Managed (can't be overridden)
2. Command line arguments
3. Local
4. Project
5. User

---

## Settings Files

- **User**: `~/.claude/settings.json`
- **Project (shared)**: `.claude/settings.json`
- **Project (personal)**: `.claude/settings.local.json`
- **Managed**:
  - macOS: `/Library/Application Support/ClaudeCode/`
  - Linux/WSL: `/etc/claude-code/`
  - Windows: `C:\Program Files\ClaudeCode\`

---

## Available Settings

| Key | Description |
|-----|-------------|
| `permissions` | Allow/ask/deny rules for tool access |
| `env` | Environment variables for every session |
| `apiKeyHelper` | Custom script for auth values |
| `model` | Override default model |
| `hooks` | Commands before/after tool execution |
| `statusLine` | Custom status line context |
| `forceLoginMethod` | Restrict to `claudeai` or `console` |
| `sandbox` | Bash sandboxing behavior |
| `attribution` | Git commit/PR attribution |

---

## Permission Settings

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  }
}
```

**Evaluation order**: Deny (highest) > Ask > Allow (lowest)

**Wildcard patterns**:
- `Bash` or `Bash(*)` - all bash commands
- `Bash(npm run *)` - npm run commands
- `Read(.env)` - specific file
- `WebFetch(domain:example.com)` - domain match

---

## Sandbox Configuration

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["git", "docker"],
    "allowUnsandboxedCommands": false,
    "network": {
      "allowUnixSockets": ["~/.ssh/agent-socket"],
      "allowLocalBinding": true
    }
  }
}
```

---

## Attribution

```json
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

---

## Plugin Configuration

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/claude-plugins"
      }
    }
  }
}
```

---

## Key Environment Variables

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | API key |
| `ANTHROPIC_MODEL` | Override model |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | OpenTelemetry |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens (default: 32,000) |
| `CLAUDE_CODE_SHELL` | Override shell |
| `DISABLE_AUTOUPDATER` | Disable updates |
| `DISABLE_TELEMETRY` | Opt out of telemetry |
| `MAX_THINKING_TOKENS` | Extended thinking budget |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Return to project dir after each command |
| `MAX_MCP_OUTPUT_TOKENS` | MCP output limit |
| `ENABLE_TOOL_SEARCH` | Tool search behavior |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Compaction threshold |
| `CLAUDE_ENV_FILE` | Env setup script path |

---

## Available Tools

| Tool | Description |
|------|-------------|
| **Bash** | Execute shell commands |
| **Read** | Read file contents |
| **Write** | Create/overwrite files |
| **Edit** | Targeted file edits |
| **WebFetch** | Fetch URL content |
| **WebSearch** | Web searches |
| **Grep** | Search file patterns |
| **Glob** | Find files by pattern |
| **Task** | Run subagent tasks |
| **Skill** | Execute skills |
| **LSP** | Code intelligence via language servers |

---

## Bash Tool Behavior

- Working directory **persists** across commands
- Environment variables **do NOT persist** between commands

### Make Env Vars Persist

**Option 1**: Activate before starting Claude
```bash
conda activate myenv
claude
```

**Option 2**: Set `CLAUDE_ENV_FILE`
```bash
export CLAUDE_ENV_FILE=/path/to/env-setup.sh
claude
```

**Option 3**: SessionStart hook
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "echo 'conda activate myenv' >> \"$CLAUDE_ENV_FILE\""
      }]
    }]
  }
}
```
