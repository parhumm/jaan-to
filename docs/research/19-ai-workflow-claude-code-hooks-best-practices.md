# Claude Code Hooks Best Practices

> Research conducted: 2025-01-27

## Executive Summary

- **Hooks are deterministic automation**: Shell commands that execute at specific lifecycle events, providing guaranteed behavior vs. relying on LLM memory to "remember" to do something
- **Exit codes control flow**: 0=success (continue), 2=blocking error (stderr sent to Claude), other=non-blocking error (shown to user)
- **Security is paramount**: Hooks run with your user credentials and can access/modify any file you can—treat them like untrusted shell scripts from the internet
- **JSON output enables sophisticated control**: Beyond simple pass/fail, hooks can approve/block actions, modify tool inputs, inject context, and control Claude's behavior
- **Prefer PreToolUse for guards, PostToolUse for feedback**: Use PreToolUse to block dangerous operations before they happen; use PostToolUse for formatting, linting, and providing feedback after successful execution

## Background & Context

Claude Code hooks are user-defined shell commands that execute automatically at specific points in Claude Code's lifecycle. Unlike prompting instructions that Claude may or may not follow, hooks provide deterministic control—they execute every time the specified event occurs, without exception.

The hooks system was introduced to address a fundamental limitation of LLM-based assistants: unreliable adherence to instructions. By encoding rules as executable code rather than prompts, developers can enforce standards, automate workflows, and maintain quality gates that cannot be bypassed by the AI.

Hooks integrate deeply with Claude Code's architecture, receiving JSON payloads via stdin with session and event-specific data, and communicating results through exit codes and stdout/stderr. This design enables everything from simple logging to sophisticated permission systems and input transformation pipelines.

## Key Findings

### Hook Events & Lifecycle

Claude Code provides 8 hook events that fire at different points in the workflow:

| Event | When It Fires | Common Use Cases |
|-------|---------------|------------------|
| **SessionStart** | When Claude Code starts or resumes | Load development context, git status, recent issues |
| **UserPromptSubmit** | When user submits a prompt | Validate input, block sensitive queries, inject context |
| **PreToolUse** | Before any tool execution | Permission guards, block dangerous commands, modify inputs |
| **PostToolUse** | After successful tool completion | Auto-format, lint, run tests, provide feedback |
| **PermissionRequest** | When permission dialog shown (v2.0.45+) | Programmatic allow/deny based on custom logic |
| **Stop** | When Claude finishes responding | Git commit, send notifications, cleanup |
| **SubagentStop** | When a subagent finishes (v1.0.41+) | Monitor subagent behavior, aggregate results |
| **SessionEnd** | When session terminates | Backup transcripts, final cleanup |

### Configuration & Matchers

Hooks are configured in JSON settings files with a hierarchical priority:

1. **User settings**: `~/.claude/settings.json` (applies to all projects)
2. **Project settings**: `.claude/settings.json` (shared with team, checked into git)
3. **Local project settings**: `.claude/settings.local.json` (personal, ignored by git)

**Matcher patterns:**
- Simple string: `"Bash"` matches the Bash tool exactly
- Regex pattern: `"Edit|Write"` matches either tool
- Wildcard: `"*"` matches all tools
- MCP tools: `"mcp__memory__.*"` matches all tools from the memory MCP server

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/validate-bash.sh"
          }
        ]
      }
    ]
  }
}
```

### JSON Payload Structure

**Input payload (received via stdin):**

All hooks receive common fields:
- `session_id`: Current session identifier
- `transcript_path`: Path to session transcript
- `cwd`: Current working directory
- `permission_mode`: Current permission mode
- `hook_event_name`: Name of the triggering event

Event-specific fields:
- **PreToolUse**: `tool_name`, `tool_input`
- **PostToolUse**: `tool_name`, `tool_input`, `tool_response` (including `exit_code` for Bash)
- **UserPromptSubmit**: `prompt` (the user's input)

**Output payload (via stdout with exit code 0):**

```json
{
  "decision": "approve" | "block",
  "reason": "Explanation shown to user/Claude",
  "hookSpecificOutput": {
    "permissionDecision": "allow" | "deny",
    "permissionDecisionReason": "Why",
    "updatedInput": { "modified": "tool_input" },
    "additionalContext": "Info for Claude"
  },
  "continue": true,
  "stopReason": "Message when continue=false",
  "suppressOutput": false
}
```

### Real-World Use Cases

**1. Auto-Format on Edit (PostToolUse)**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/auto-format.sh"
      }]
    }]
  }
}
```

```bash
#!/usr/bin/env bash
set -euo pipefail
file_path=$(jq -r '.tool_input.file_path // ""')
if [[ "$file_path" == *.ts ]] || [[ "$file_path" == *.tsx ]]; then
  npx prettier --write "$file_path"
elif [[ "$file_path" == *.go ]]; then
  gofmt -w "$file_path"
fi
exit 0
```

**2. Block Dangerous Commands (PreToolUse)**
```bash
#!/usr/bin/env bash
set -euo pipefail
cmd=$(jq -r '.tool_input.command // ""')
if echo "$cmd" | grep -qE '(rm -rf|sudo|chmod 777|> /dev/)'; then
  echo "Blocked dangerous command: $cmd" >&2
  exit 2
fi
exit 0
```

**3. Git Backup Before Changes (PreToolUse)**
```bash
#!/usr/bin/env bash
git stash push -m "claude-backup-$(date +%s)" --include-untracked 2>/dev/null || true
exit 0
```

**4. Run Tests After Code Changes (PostToolUse)**
```bash
#!/usr/bin/env bash
file_path=$(jq -r '.tool_input.file_path // ""')
if [[ "$file_path" == *.py ]]; then
  python -m pytest tests/ -x -q 2>&1 | head -20
fi
exit 0
```

**5. Context Loading on Session Start (SessionStart)**
```bash
#!/usr/bin/env bash
echo "=== Development Context ==="
echo "Branch: $(git branch --show-current)"
echo "Status: $(git status --short | head -5)"
echo "Recent commits: $(git log --oneline -3)"
exit 0
```

### Security Best Practices

**Critical security considerations:**

1. **Hooks execute with your credentials**: They can read, modify, or delete any file your user account can access
2. **Malicious hooks can exfiltrate data**: Always review hook code before adding it
3. **Hooks run automatically**: No confirmation dialog—they execute every time the event fires

**Input validation checklist:**
- Always quote shell variables: `"$VAR"` not `$VAR`
- Block path traversal: check for `..` in file paths
- Use absolute paths for critical tools
- Validate JSON structure before processing
- Skip sensitive files: `.env`, `.git/`, credential files

**Permission minimization:**
- Use allowlists as the first line of defense
- Set default mode to "Ask" for unmatched commands
- Create deny lists for nuclear-level dangerous operations
- Treat Claude "like an untrusted but powerful intern"

**Example secure hook pattern:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Validate input exists
input=$(cat)
if ! echo "$input" | jq -e . >/dev/null 2>&1; then
  echo "Invalid JSON input" >&2
  exit 1
fi

# Extract and validate file path
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
if [[ -z "$file_path" ]] || [[ "$file_path" == *".."* ]]; then
  echo "Invalid or dangerous file path" >&2
  exit 2
fi

# Skip sensitive files
if [[ "$file_path" == *.env* ]] || [[ "$file_path" == *credentials* ]]; then
  exit 0  # Silently skip
fi

# Your logic here
exit 0
```

### Debugging & Troubleshooting

**Debugging tools:**
- `/hooks` command: Interactive hook configuration editor
- `claude --debug`: Verbose output mode
- `Ctrl-R`: View transcript including hook outputs
- `Ctrl-O`: Verbose mode showing non-blocking errors

**Testing hooks manually:**
```bash
# Make executable
chmod +x .claude/hooks/your-hook.sh

# Test with sample input
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | .claude/hooks/your-hook.sh
echo "Exit code: $?"
```

**Common issues:**
- **"Hook Error" label on success**: Known UI bug—check actual exit code
- **JSON not processed**: Only processed with exit code 0; exit code 2 uses stderr directly
- **Hook not firing**: Check matcher pattern (case-sensitive), verify settings file location

## Recent Developments (2024-2025)

- **PermissionRequest event** (v2.0.45+): Allows programmatic permission decisions without manual intervention
- **SubagentStop event** (v1.0.41+): Enables monitoring of subagent behavior in multi-agent workflows
- **Skill/Subagent frontmatter hooks**: Hooks can now be defined directly in skill SKILL.md files, scoped to component lifecycle
- **Plugin hooks**: Multiple hooks from different sources (plugins, user, project) run in parallel for the same event
- **Windows native support** (Dec 2025): Claude Code now installs directly on Windows without WSL
- **Enhanced SessionStart**: Now includes source field ("startup", "resume", "clear") for context-aware initialization

## Best Practices & Recommendations

1. **Use PreToolUse for guards, PostToolUse for feedback**: Block dangerous operations before they happen; provide formatting/linting feedback after successful execution

2. **Scope matchers precisely**: Target specific tools (`"Edit|Write"`) rather than wildcards (`"*"`) to maintain responsiveness and avoid unexpected behavior

3. **Handle errors gracefully**: Use non-blocking errors (exit 1) for non-critical failures to avoid interrupting workflow

4. **Validate all inputs**: Treat hook inputs as untrusted; validate JSON structure, check for path traversal, sanitize before use

5. **Use absolute paths**: Reference scripts and tools with absolute paths to avoid PATH manipulation attacks

6. **Test in isolation first**: Run hooks manually with sample inputs before deploying to production workflow

7. **Keep hooks fast**: Slow hooks block Claude's execution; use `run_in_background` for long-running operations like test suites

8. **Document hook behavior**: Add comments explaining what each hook does and why—future you will thank present you

## Comparisons

| Aspect | Hooks | MCP Tools |
|--------|-------|-----------|
| **Purpose** | Automation triggers tied to lifecycle events | External integrations and data sources |
| **Execution** | Shell commands that run automatically | Tool calls that Claude initiates |
| **Direction** | React to what Claude does | Extend what Claude can do |
| **Timing** | Fixed lifecycle points | On-demand by Claude |
| **Use cases** | Quality gates, formatting, validation | External APIs, databases, third-party services |
| **Overhead** | Minimal (shell process) | Higher (MCP server context in window) |

**When to use hooks:**
- Enforcing code standards (formatting, linting)
- Blocking dangerous operations
- Automatic backups and version control
- Notifications and logging

**When to use MCP:**
- Integrating with external services (GitHub, Jira, Slack)
- Database queries and modifications
- Complex tool workflows requiring Claude's reasoning

## Open Questions

- How will hooks evolve with multi-agent orchestration patterns?
- Will there be a visual hook builder for non-technical users?
- How can hooks be securely shared across teams without exposing credentials?
- What's the performance impact of multiple parallel hooks on complex workflows?

## Sources

1. [Claude Code Hooks Reference - Anthropic](https://code.claude.com/docs/en/hooks) - Official documentation with complete event reference and JSON schemas
2. [Get started with Claude Code hooks - Anthropic](https://code.claude.com/docs/en/hooks-guide) - Official getting started guide with examples
3. [Claude Code Hooks Mastery - GitHub](https://github.com/disler/claude-code-hooks-mastery) - Community repository with advanced patterns and observability tools
4. [Claude Code Hooks: A Practical Guide - DataCamp](https://www.datacamp.com/tutorial/claude-code-hooks) - Comprehensive tutorial with real-world examples
5. [A complete guide to hooks in Claude Code - eesel.ai](https://www.eesel.ai/blog/hooks-in-claude-code) - Detailed workflow automation guide
6. [Claude Hooks Best Practices - PRPM](https://prpm.dev/blog/claude-hooks-best-practices) - Security and reliability recommendations
7. [Claude Code: Best practices for agentic coding - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices) - Official engineering best practices
8. [Automate Your AI Workflows with Claude Code Hooks - GitButler](https://blog.gitbutler.com/automate-your-ai-workflows-with-claude-code-hooks) - Practical automation examples
9. [Understanding Claude Code's Full Stack - alexop.dev](https://alexop.dev/posts/understanding-claude-code-full-stack/) - Comparison of hooks, MCP, skills, and subagents
10. [Claude Code Security Best Practices - Backslash](https://www.backslash.security/blog/claude-code-security-best-practices) - Security-focused configuration guide
11. [awesome-claude-code - GitHub](https://github.com/hesreallyhim/awesome-claude-code) - Curated list of hooks, skills, and plugins
12. [Claude Code Hook Examples - Steve Kinney](https://stevekinney.com/courses/ai-development/claude-code-hook-examples) - Practical examples with explanations

## Research Metadata

- **Date Researched:** 2025-01-27
- **Category:** ai-workflow
- **Search Queries Used:**
  - "Claude Code hooks explained fundamentals Anthropic CLI"
  - "Claude Code hooks 2025 latest developments event system"
  - "Claude Code hooks best practices recommendations workflow automation"
  - "Claude Code hooks vs MCP tools comparison"
  - "Claude Code hooks configuration examples bash shell scripts"
  - "Claude Code hooks security risks validation sanitization best practices"
  - "Claude Code hooks debugging troubleshooting exit codes JSON output"
  - "Claude Code hooks PreToolUse PostToolUse payload JSON structure fields"
  - "Claude Code hooks real-world examples auto-format lint git backup"
