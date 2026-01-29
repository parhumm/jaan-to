# Building Enterprise-Grade Claude Code Plugin Packs

> Comprehensive plugin development guide covering structure, configuration, safety, MCP integration, and distribution.
> Source: Local file (building-enterprise-grade-claude-code-plugin-packs.md)
> Added: 2026-01-27

---

**Claude Code's plugin architecture provides a complete foundation for building what you're calling an "jaan.to"**—a layered system of commands, boundaries, and integrations that orchestrates developer workflows. The key architectural insight: Claude Code already implements a hierarchical configuration system where enterprise policies cascade down through project and user settings, making it possible to enforce upstream gates that downstream configurations cannot weaken.

---

## Plugin Architecture Fundamentals

Claude Code's extension system bundles four component types into shareable packages: **slash commands** (custom shortcuts), **subagents** (specialized AI workers), **MCP servers** (external tool connections), and **hooks** (event-driven behavior). Understanding how these interact is essential before designing your layered architecture.

### The Official Plugin Structure

The canonical directory layout places all components at the plugin root—not nested inside metadata folders:

```
ai-os-plugin-pack/
├── .claude-plugin/
│   └── plugin.json           # Manifest only
├── commands/                  # Slash commands (.md files)
│   ├── jaan-to-pm-prd-write.md
│   └── dev-lint-check.md
├── agents/                    # Subagents (.md files)
│   ├── code-reviewer.md
│   └── security-scanner.md
├── skills/                    # Auto-invoked capabilities
│   └── explain-code/
│       └── SKILL.md
├── hooks/
│   └── hooks.json            # Or in settings.json
├── .mcp.json                  # MCP server definitions
├── scripts/                   # Hook scripts, utilities
└── CLAUDE.md                  # Context documentation
```

**Critical rule**: Component directories must be at root level. The `.claude-plugin/` folder contains only `plugin.json`. Custom paths in the manifest supplement defaults—they don't replace auto-discovery.

### Plugin Manifest (plugin.json)

```json
{
  "name": "ai-os-core",
  "version": "1.0.0",
  "description": "Core jaan.to workflows and boundaries",
  "author": {
    "name": "Your Org",
    "url": "https://github.com/your-org"
  },
  "mcpServers": {
    "internal-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config/api.json"],
      "env": {
        "API_KEY": "${INTERNAL_API_KEY}"
      }
    }
  }
}
```

The `${CLAUDE_PLUGIN_ROOT}` variable ensures portability across installations—use it for all paths within plugins.

---

## Three-Layer Configuration That Enforces Upstream Gates

The core architectural requirement—ensuring downstream configs cannot weaken upstream boundaries—maps directly to Claude Code's built-in settings hierarchy. Higher-level settings **always override** lower-level ones.

### Settings Precedence (Highest to Lowest)

| Layer | Location | Purpose |
|-------|----------|---------|
| **Enterprise** | `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS) | Organizational policy—cannot be overridden |
| **CLI flags** | `--append-system-prompt`, etc. | Temporary session overrides |
| **Project local** | `.claude/settings.local.json` | Personal project overrides (gitignored) |
| **Project shared** | `.claude/settings.json` | Team-wide settings (version controlled) |
| **User** | `~/.claude/settings.json` | Global personal defaults |

### Implementing Core → Product → Team Layers

Your three-layer architecture maps to this hierarchy:

**Core layer (Enterprise managed-settings.json)**—deployed via MDM or configuration management:
```json
{
  "proxy": "http://proxy.corp.com:8080",
  "permissions": {
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(curl:*)",
      "Read(.env*)",
      "Read(~/.ssh/*)",
      "Write(.git/*)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

**Product layer (Project .claude/settings.json)**—committed to repository:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run:*)",
      "Bash(git:*)",
      "Write(src/*)",
      "Write(tests/*)"
    ],
    "deny": [
      "Write(production.*)",
      "Write(config/secrets/*)"
    ]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "npx prettier --write $FILE_PATH"
      }]
    }]
  }
}
```

**Team layer (User ~/.claude/settings.json or settings.local.json)**—personal preferences within boundaries:
```json
{
  "permissions": {
    "allow": ["Bash(npm run dev)"],
    "defaultMode": "acceptEdits"
  }
}
```

The critical design guarantee: **deny rules always win**. Enterprise denies cannot be overridden by project allows. This inheritance model means teams can grant additional permissions within their scope but cannot weaken upstream protections.

### MCP Server Restrictions for Enterprise

Control which MCP servers teams can use:
```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "jira" },
    { "serverCommand": ["npx", "-y", "@modelcontextprotocol/server-filesystem"] }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" }
  ]
}
```

---

## Skill and Command Naming Conventions

A stable, muscle-memory-friendly command interface requires consistent naming patterns that communicate purpose without requiring documentation lookup.

### Recommended Naming Taxonomy

**Pattern**: `/[role]-[domain]:[action]` or simpler `/[domain]:[action]`

| Pattern | Example | Use Case |
|---------|---------|----------|
| Role-domain-action | `/jaan-to-pm-prd:write` | PRD creation by PM role |
| Role-domain-action | `/dev-lint:check` | Lint check by developer |
| Domain-action | `/review:pr` | PR review workflow |
| Simple action | `/deploy` | Single-purpose commands |

### Command File Structure

Commands live in `.claude/commands/` as markdown files:

```markdown
---
allowed-tools: Bash(npm run:*), Bash(git:*)
argument-hint: [ticket-id] [--dry-run]
description: Create PR from Jira ticket with linked requirements
model: claude-sonnet-4-20250514
---

## Context
- Current branch: !`git branch --show-current`
- Jira ticket: $1
- Dry run mode: $2

## Task
Create a well-documented pull request for the changes on this branch.
Link to Jira ticket $1 in the PR description.
$ARGUMENTS contains any additional instructions.
```

### Discoverability Patterns

- **Always include `description` frontmatter**—appears in `/` autocomplete
- **Use `argument-hint`** to show expected parameters
- **Group related commands** with consistent prefixes (`pm-*`, `dev-*`, `qa-*`)
- **Provide examples** in command markdown showing typical invocations

### Skills vs Commands Decision Matrix

| Aspect | Slash Commands | Skills |
|--------|----------------|--------|
| **Invocation** | Manual (`/command`) | Automatic (context-triggered) |
| **Best for** | Explicit workflows | Behavioral enhancements |
| **Location** | `.claude/commands/*.md` | `.claude/skills/*/SKILL.md` |
| **Complexity** | Single prompts | Multi-step with resources |

Skills auto-invoke when Claude determines they're relevant—use them for coding standards enforcement, explanation patterns, or review behaviors rather than explicit workflows.

---

## Trust Guardrails and Human-in-the-Loop Gates

### File System Protection

Claude Code restricts writes to the working directory and subdirectories by default. Layer additional protections:

```json
{
  "permissions": {
    "deny": [
      "Write(.env*)",
      "Write(package-lock.json)",
      "Write(.git/*)",
      "Write(secrets/**)",
      "Read(.env*)",
      "Read(~/.ssh/*)"
    ]
  }
}
```

**Sandbox mode** provides filesystem and network isolation—enable with `/sandbox` or configure:
```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["git", "docker"]
  }
}
```

### Secrets Scanning Integration

**PreToolUse hook for blocking sensitive file access**:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "python3 -c \"import json,sys; d=json.load(sys.stdin); p=d.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(x in p for x in ['.env','secrets/','.pem']) else 0)\""
      }]
    }]
  }
}
```

**Pre-commit integration with TruffleHog**:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: trufflehog
        name: Secret scanning
        entry: bash -c 'trufflehog git file://. --since-commit HEAD --only-verified --fail'
        language: system
        stages: ["commit", "push"]
```

### Human Confirmation Gates

**PreToolUse hooks act as firewalls**—return exit code 2 to block with explanation:

```bash
#!/bin/bash
# scripts/validate-command.sh
set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Block dangerous patterns
if echo "$COMMAND" | grep -qE '(rm -rf|sudo|curl.*\|.*sh)'; then
    echo "Blocked: potentially dangerous command pattern" >&2
    exit 2
fi

# Require confirmation for production operations
if echo "$COMMAND" | grep -qE '(deploy|prod|release)'; then
    echo "Production operation requires explicit confirmation" >&2
    exit 2
fi

exit 0
```

**PermissionRequest hook** (v2.0.45+) enables programmatic approval:
```json
{
  "hooks": {
    "PermissionRequest": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "./scripts/permission-handler.sh"
      }]
    }]
  }
}
```

### Audit Logging

**Stop hook for session logging**:
```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "echo \"$(date -Iseconds): $CONVERSATION_SUMMARY\" >> ~/.claude/activity.log"
      }]
    }]
  }
}
```

---

## MCP Server Integration Patterns

### Self-Hosted Jira (Server/Data Center)

Use `sooperset/mcp-atlassian` with Personal Access Token authentication:

```json
{
  "mcpServers": {
    "jira": {
      "command": "uvx",
      "args": ["mcp-atlassian"],
      "env": {
        "JIRA_URL": "https://jira.your-company.com",
        "JIRA_PERSONAL_TOKEN": "${JIRA_PAT}"
      }
    }
  }
}
```

**Available tools**: `jira_search`, `jira_get_issue`, `jira_create_issue`, `jira_update_issue`, `jira_add_comment`

### Self-Hosted GitLab

For GitLab 18.2+, use the built-in MCP endpoint:
```json
{
  "mcpServers": {
    "gitlab": {
      "type": "http",
      "url": "https://gitlab.your-company.com/api/v4/mcp"
    }
  }
}
```

For enhanced features, use `zereight/gitlab-mcp`:
```json
{
  "mcpServers": {
    "gitlab": {
      "command": "docker",
      "args": ["run", "-i", "--rm",
        "-e", "GITLAB_PERSONAL_ACCESS_TOKEN",
        "-e", "GITLAB_API_URL",
        "zereight050/gitlab-mcp"
      ],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "${GITLAB_TOKEN}",
        "GITLAB_API_URL": "https://gitlab.your-company.com/api/v4"
      }
    }
  }
}
```

### Figma Design Context

Official remote server provides design-to-code context:
```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

**Key tools**: `get_design_context` (React + Tailwind representation), `get_variable_defs` (design tokens), `get_code_connect_map` (component mappings)

### Analytics Platforms

**Microsoft Clarity**:
```json
{
  "mcpServers": {
    "clarity": {
      "command": "npx",
      "args": ["@microsoft/clarity-mcp-server", "--clarity_api_token=${CLARITY_TOKEN}"]
    }
  }
}
```

**GA4 via Stape**:
```json
{
  "mcpServers": {
    "ga4": {
      "command": "npx",
      "args": ["-y", "mcp-remote@0.1.30", "https://mcp-ga.stape.ai/mcp"]
    }
  }
}
```

### OpenAPI/Swagger Specification

Use `swag-mcp` for strategic API context without hundreds of individual tools:
```json
{
  "mcpServers": {
    "api-spec": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/swag-mcp/start-mcp.sh",
      "env": {
        "OPENAPI_URL": "https://api.example.com/swagger.json",
        "API_BASE_URL": "https://api.example.com"
      }
    }
  }
}
```

**Four strategic tools**: `list_endpoints`, `search_endpoints`, `get_endpoint_details`, `execute_request`

### Telegram for Approval Workflows

For human-in-the-loop confirmation via Telegram:
```json
{
  "mcpServers": {
    "telegram-approval": {
      "command": "python",
      "args": ["${CLAUDE_PLUGIN_ROOT}/servers/telegram-approval.py"],
      "env": {
        "TELEGRAM_BOT_TOKEN": "${TELEGRAM_TOKEN}",
        "TELEGRAM_CHAT_ID": "${TELEGRAM_CHAT}"
      }
    }
  }
}
```

---

## MVP Workflow: PRD Creation with Human Gates

### Workflow Command (/jaan-to-pm-prd:write)

```markdown
---
allowed-tools: mcp__figma__*, mcp__jira__*, mcp__api-spec__*, Bash(git:*)
argument-hint: [figma-url] [--create-tickets]
description: Create PRD from Figma design with API context, optionally create Jira tickets
---

## Context Collection
1. Figma design: $1
2. Current API specs: !`Use api-spec tools to list relevant endpoints`
3. Existing Jira context: !`Search for related tickets in current sprint`

## Workflow Steps

### Step 1: Design Analysis
Use Figma MCP to extract:
- Component hierarchy and design tokens from $1
- User flow and interaction patterns
- Required data fields and states

### Step 2: API Context
Use api-spec MCP to identify:
- Existing endpoints that support this feature
- Required new endpoints or modifications
- Data models and schemas

### Step 3: PRD Generation
Create comprehensive PRD including:
- User stories with acceptance criteria
- Technical requirements with API mappings
- Design specifications with Figma references
- Scope boundaries and out-of-scope items

### Step 4: Human Review Gate
Present PRD summary and ASK for confirmation before proceeding.
If --create-tickets flag present, explain what tickets will be created.

### Step 5: Ticket Creation (if approved)
Only proceed if user explicitly confirms.
Create Jira tickets with proper linking and labels.
```

### State Management Across Steps

Use CLAUDE.md to persist workflow state:
```markdown
# Current Workflow State
- Active PRD: feature-xyz
- Stage: awaiting-review
- Figma: https://figma.com/file/xyz
- Created tickets: PROJ-123, PROJ-124
```

Or use the Memory MCP server for cross-session state:
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

---

## Plugin Pack Distribution Strategy

### Monorepo Structure for Related Plugins

```
ai-os-plugins/
├── packages/
│   ├── core/                    # Public: Base boundaries and patterns
│   │   ├── .claude-plugin/
│   │   ├── commands/
│   │   ├── hooks/
│   │   └── package.json
│   ├── integrations/            # Public: MCP server wrappers
│   │   ├── jira/
│   │   ├── gitlab/
│   │   └── figma/
│   └── internal/                # Private: Company-specific
│       ├── commands/
│       └── .mcp.json
├── pnpm-workspace.yaml
├── turbo.json
└── README.md
```

### Making Core Plugins Public-Friendly

**Never include in public packages**:
- Hardcoded URLs or API endpoints
- Authentication tokens or secrets
- Company-specific workflow assumptions

**Pattern for configurable plugins**:
```json
{
  "mcpServers": {
    "jira": {
      "command": "uvx",
      "args": ["mcp-atlassian"],
      "env": {
        "JIRA_URL": "${JIRA_URL:?JIRA_URL environment variable required}",
        "JIRA_PERSONAL_TOKEN": "${JIRA_TOKEN:?JIRA_TOKEN required}"
      }
    }
  }
}
```

### Installation and Distribution

**Via Claude Code marketplace**:
```bash
/plugin marketplace add your-org/ai-os-plugins
/plugin install ai-os-core@your-org
```

**Via settings.json for team deployment**:
```json
{
  "enabledPlugins": {
    "ai-os-core@your-org": true,
    "ai-os-integrations@your-org": true
  },
  "extraKnownMarketplaces": {
    "your-org": {
      "source": {
        "source": "github",
        "repo": "your-org/ai-os-plugins"
      }
    }
  }
}
```

---

## Metrics and Observability

### DORA Metrics with AI-Specific Extensions

Track these five metrics to measure AI workflow effectiveness:

| Metric | What to Measure | Target |
|--------|-----------------|--------|
| **Deployment Frequency** | PRDs → shipped features | Increase |
| **Lead Time** | Ticket creation → production | Decrease |
| **Change Failure Rate** | AI-generated code causing incidents | <15% |
| **MTTR** | Time to fix AI-related issues | Decrease |
| **Rework Rate** | Unplanned fixes after AI generation | <10% |

### Instrumentation Hooks

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "curl -X POST ${TELEMETRY_URL}/session/start -d '{\"user\":\"$USER\",\"project\":\"$CLAUDE_PROJECT_DIR\"}'"
      }]
    }],
    "PostToolUse": [{
      "matcher": "mcp__jira__*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/track-jira-usage.sh"
      }]
    }]
  }
}
```

### Adoption Tracking

Monitor plugin effectiveness:
- Command invocation frequency per user/team
- Success vs failure rates by command
- Token consumption per workflow type
- Time-to-completion for multi-step workflows
- Developer satisfaction (periodic surveys)

---

## Key Architectural Decisions and Tradeoffs

### Decision 1: Hooks vs MCP Servers for Integrations

| Approach | Pros | Cons | Use When |
|----------|------|------|----------|
| **Hooks** | Simple, no server management | Limited to event responses | File validation, formatting, logging |
| **MCP servers** | Full API access, complex operations | Requires server lifecycle | External tool integration, stateful operations |

**Recommendation**: Use hooks for boundaries and side effects; use MCP servers for tool integrations.

### Decision 2: Monorepo vs Separate Packages

| Approach | Pros | Cons |
|----------|------|------|
| **Monorepo** | Atomic updates, shared types, easier testing | Complex CI, version coupling |
| **Separate** | Independent versioning, focused ownership | Coordination overhead |

**Recommendation**: Monorepo for Core + Integrations maintained by same team; separate repos for team-specific extensions.

### Decision 3: Strict vs Permissive Default Permissions

| Approach | Pros | Cons |
|----------|------|------|
| **Deny-by-default** | Maximum security, explicit allowlisting | Higher friction, more configuration |
| **Allow-by-default** | Lower friction, faster adoption | Security risks, harder audit |

**Recommendation**: Enterprise layer should deny-by-default. Product layer can allow common safe operations. Never allow risky operations at any layer.

---

## Common Pitfalls to Avoid

**Over-engineering prompts**: Simple, direct commands outperform elaborate multi-page prompts. Start minimal, add complexity only when needed.

**Ignoring CLAUDE.md maintenance**: This is your primary context mechanism. Treat it as living documentation—update it as the project evolves.

**Mixing output modes**: MCP servers using STDIO transport must output only JSON. Human-readable messages in STDIO streams corrupt the protocol.

**Expecting perfection**: AI-generated code needs review. Build review gates into workflows rather than assuming first-pass quality.

**Neglecting downstream bottlenecks**: Faster code generation shifts bottlenecks to review, QA, and deployment. Automate those stages too.

**Hardcoding in plugins**: Use environment variables and `${CLAUDE_PLUGIN_ROOT}` for all configuration. This enables both public distribution and private customization.

---

## Implementation Checklist

Starting your jaan.to plugin pack:

1. **Create enterprise managed-settings.json** with core deny rules for secrets, dangerous commands, and sensitive paths
2. **Define project settings template** with standard hooks for formatting, testing, and logging
3. **Build core commands** following `/role-domain:action` naming convention
4. **Configure MCP servers** for Jira, GitLab, Figma with environment variable authentication
5. **Implement PreToolUse hooks** for human-in-the-loop gates on production operations
6. **Set up telemetry hooks** to track adoption and effectiveness metrics
7. **Create CLAUDE.md template** with project structure, commands, and conventions
8. **Test layered inheritance** to verify downstream cannot weaken upstream gates
9. **Document in README** with installation, configuration, and customization instructions
10. **Version with SemVer** and maintain CHANGELOG for breaking changes

The foundation is solid—Claude Code's architecture already supports enterprise-grade plugin development with proper configuration inheritance and security boundaries. Your task is applying these patterns consistently across your organization's workflows.
