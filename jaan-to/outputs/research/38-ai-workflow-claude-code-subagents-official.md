# Create Custom Subagents

> Official guide for creating specialized AI subagents in Claude Code for task-specific workflows and improved context management.
> Source: https://code.claude.com/docs/en/sub-agents.md
> Added: 2026-01-29

---

## Overview

Subagents are specialized AI assistants running in their own context window with custom system prompts, specific tool access, and independent permissions. They help:

- **Preserve context** by isolating exploration/implementation
- **Enforce constraints** by limiting tools
- **Reuse configurations** across projects (user-level)
- **Specialize behavior** with focused system prompts
- **Control costs** by routing to cheaper models (Haiku)

---

## Built-in Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherits | All | Complex multi-step tasks requiring exploration + action |
| **Bash** | Inherits | - | Running terminal commands in separate context |
| **statusline-setup** | Sonnet | - | Configure status line via `/statusline` |
| **Claude Code Guide** | Haiku | - | Answer questions about Claude Code features |

---

## Creating Subagents

### Using `/agents` Command
Interactive interface for creating, editing, deleting subagents. Can generate with Claude.

### Writing Subagent Files

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific,
actionable feedback on quality, security, and best practices.
```

### Scope & Priority

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` | Where plugin enabled | 4 |

### CLI-Defined Subagents
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

---

## Frontmatter Reference

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When Claude should delegate |
| `tools` | No | Tool allowlist. Inherits all if omitted |
| `disallowedTools` | No | Tools to deny |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `skills` | No | Skills to preload into context at startup |
| `hooks` | No | Lifecycle hooks scoped to this subagent |

---

## Permission Modes

| Mode | Behavior |
|------|----------|
| `default` | Standard permission checking |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny prompts (allowed tools still work) |
| `bypassPermissions` | Skip all checks (use with caution) |
| `plan` | Read-only exploration |

---

## Foreground vs Background

- **Foreground**: Blocks main conversation. Permission prompts pass through to you
- **Background**: Runs concurrently. Pre-approved permissions, auto-denies anything not pre-approved. MCP tools unavailable

Press **Ctrl+B** to background a running task.

---

## Common Patterns

### Isolate High-Volume Operations
```
Use a subagent to run the test suite and report only failing tests
```

### Parallel Research
```
Research the authentication, database, and API modules in parallel using separate subagents
```

### Chain Subagents
```
Use code-reviewer to find performance issues, then use optimizer to fix them
```

---

## Preload Skills
```yaml
---
name: api-developer
skills:
  - api-conventions
  - error-handling-patterns
---
```
Full skill content injected into context (not just made available for invocation).

---

## Hooks in Subagents

### In Frontmatter (scoped to subagent)
```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
```

### In settings.json (project-level)
```json
{
  "hooks": {
    "SubagentStart": [{ "matcher": "db-agent", "hooks": [...] }],
    "SubagentStop": [{ "matcher": "db-agent", "hooks": [...] }]
  }
}
```

---

## Disabling Subagents

```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

---

## When to Use

| Use subagents when... | Use main conversation when... |
|----------------------|-------------------------------|
| Task produces verbose output | Frequent back-and-forth needed |
| Need tool restrictions | Multiple phases share context |
| Work is self-contained | Quick, targeted change |
| Want separate context | Latency matters |

> Subagents cannot spawn other subagents. Use skills or chain from main conversation.
