# Claude Code Plugin Best Practices & Standards

> Quick-reference standards for configuration hierarchy, permission patterns, skill naming, and safety boundaries.
> Source: Local file (claude-code-plugin-best-practices-standards.md)
> Added: 2026-01-27

---

## Core Architectural Principles

### 1. Configuration Hierarchy Enforcement

The settings precedence (highest to lowest) that guarantees upstream gates cannot be weakened:

| Layer | Location | Your Mapping |
|-------|----------|--------------|
| Enterprise (MDM-deployed) | `managed-settings.json` | **Core** |
| Project shared | `.claude/settings.json` | **Product Config** |
| Project local | `.claude/settings.local.json` | **Team Config** |
| User | `~/.claude/settings.json` | Individual prefs |

**Key guarantee**: `deny` rules always win. Enterprise denies cannot be overridden by project allows.

---

### 2. Permission Model Standards

```
Format: Tool(pattern:args)

Examples:
- Bash(npm run:*)     → Allow npm run with any args
- Write(src/**)       → Allow writes in src tree
- Read(.env*)         → Match .env, .env.local, etc.
- mcp__jira__*        → All Jira MCP tools
```

**Safe defaults for Core layer**:
- Deny: `rm -rf`, `curl|sh`, `.env*`, `~/.ssh/*`, `.git/*`, `secrets/**`
- Deny network tools in non-sandboxed mode
- Require explicit allows for production paths

---

### 3. Skill Naming Convention

**Pattern**: `/[ROLE]-[DOMAIN]:[ACTION]`

| Component | Purpose | Examples |
|-----------|---------|----------|
| ROLE | Who executes | `pm`, `dev`, `qa`, `devops` |
| DOMAIN | What area | `prd`, `lint`, `test`, `deploy`, `review` |
| ACTION | What happens | `write`, `check`, `run`, `create`, `sync` |

**Stable command examples**:
- `/jaan-to-pm-prd-write` — Create PRD
- `/dev-lint:check` — Run linting
- `/qa-test:run` — Execute tests
- `/devops-deploy:preview` — Deploy to preview

**Discoverability requirements**:
- Always set `description` in frontmatter
- Use `argument-hint` for expected params
- Group with consistent prefixes

---

## Trust & Guardrails Standards

### 4. Hook Exit Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| 0 | Proceed | Validation passed |
| 1 | Error (logged, continues) | Non-critical warning |
| 2 | Block with message | Hard gate—stops execution |

**Human-in-the-loop pattern**: PreToolUse hook returns exit 2 with explanation for risky operations.

---

### 5. Gate Hierarchy (Non-Weakening)

```
Core Layer (Enterprise)
├── MUST deny: secrets, credentials, dangerous patterns
├── MUST deny: production paths without explicit approval
└── Cannot be overridden downstream

Product Layer (Project)
├── CAN allow: safe build/test commands
├── CAN add: project-specific denies
└── Cannot remove Core denies

Team Layer (Local/User)
├── CAN allow: personal workflow shortcuts
├── CAN set: UI preferences, default modes
└── Cannot remove Product or Core denies
```

---

### 6. Secrets Protection Checklist

| Control | Implementation |
|---------|----------------|
| File access | Deny `Read(.env*)`, `Read(**/secrets/*)` |
| Output scanning | PostToolUse hook with pattern matching |
| Pre-commit | TruffleHog or gitleaks integration |
| MCP auth | Environment variables only, never hardcoded |

---

## MCP Integration Standards

### 7. Self-Hosted Service Patterns

| Service | Auth Method | Key Consideration |
|---------|-------------|-------------------|
| Jira Server/DC | Personal Access Token | Use `mcp-atlassian`, not Cloud OAuth |
| GitLab Self-Hosted | PAT or Deploy Token | GitLab 18.2+ has native MCP endpoint |
| Figma | OAuth via remote server | Official `mcp.figma.com/mcp` |

**Environment variable naming**:
```
SERVICE_URL       → Base URL
SERVICE_TOKEN     → Auth credential
SERVICE_PROJECT   → Default project/workspace
```

---

### 8. MCP Server Restrictions (Enterprise)

```json
{
  "allowedMcpServers": [
    { "serverName": "approved-server" },
    { "serverCommand": ["npx", "-y", "@org/approved-mcp"] }
  ],
  "deniedMcpServers": [
    { "serverName": "*" }  // Allowlist mode
  ]
}
```

---

## Plugin Structure Standards

### 9. Directory Layout

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Manifest ONLY
├── commands/            # At root, not nested
├── agents/
├── skills/
├── hooks/
├── .mcp.json
└── CLAUDE.md
```

**Critical**: Components at root level. `.claude-plugin/` contains only manifest.

---

### 10. Public vs Internal Plugin Separation

| Aspect | Public (Core) | Internal |
|--------|---------------|----------|
| URLs | Environment vars only | Can hardcode internal |
| Secrets | Never | Via secure env injection |
| Defaults | Generic, configurable | Company-specific |
| Distribution | Marketplace/GitHub | Private registry |

---

## Metrics Standards

### 11. Required Measurements

| Metric | Definition | Target Direction |
|--------|------------|------------------|
| Cycle time | Command invocation → completion | ↓ Decrease |
| Rework rate | Edits within 24h of generation | < 10% |
| Adoption | Active users / total eligible | ↑ Increase |
| Gate bypass attempts | Blocked operations / total | Monitor |
| Token efficiency | Tokens per successful task | ↓ Decrease |

**Instrumentation points**:
- `SessionStart` / `Stop` — Session duration
- `PostToolUse` — Command success/failure
- `PreToolUse` exit 2 — Gate blocks

---

## Key Decision Standards

### 12. When to Use What

| Need | Use | Not |
|------|-----|-----|
| External API integration | MCP server | Hooks |
| File validation/blocking | PreToolUse hook | MCP |
| Human confirmation | PreToolUse exit 2 | Prompt instructions |
| Auto-formatting | PostToolUse hook | Manual commands |
| Cross-session state | Memory MCP | CLAUDE.md |
| Workflow orchestration | Slash commands | Skills |
| Behavioral defaults | Skills | Commands |

---

### 13. Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Instead |
|--------------|--------------|---------|
| Elaborate multi-page prompts | Context dilution | Simple, direct commands |
| Hardcoded URLs in plugins | Blocks distribution | Environment variables |
| Allow-by-default permissions | Security debt | Explicit allowlists |
| Skipping human gates for "speed" | Production incidents | Always gate risky ops |
| Single monolithic plugin | Hard to maintain | Layered: Core → Product → Team |
| Mixing STDIO output formats | Protocol corruption | JSON only for MCP |

---

## Quick Reference Card

**Permission Pattern Syntax**:
```
Tool(command:args)
Bash(npm run:*)
Write(path/**)
Read(path/*)
mcp__server__tool
```

**Hook Lifecycle**:
```
PreToolUse → [Tool Execution] → PostToolUse
SessionStart → [Session] → Stop
Notification (async, non-blocking)
```

**Settings Merge Order**:
```
Enterprise (wins) > CLI flags > Project local > Project shared > User
```

**Command Frontmatter**:
```yaml
---
allowed-tools: Bash(npm:*), mcp__jira__*
argument-hint: [required] [--optional]
description: One-line for autocomplete
model: claude-sonnet-4-20250514  # Optional override
---
```
