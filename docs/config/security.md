---
title: "Security"
sidebar_position: 5
---

# Security

> What jaan-to accesses, how it works, and why your data stays safe.

---

## What jaan-to Accesses

jaan-to is a Claude Code plugin that adds structured workflows (skills) to your development process. Here is exactly what it reads, writes, and executes.

### Reads

| What | Where | Purpose |
|------|-------|---------|
| Project config | `jaan-to/config/settings.yaml` | Customize paths, language, features |
| Context files | `jaan-to/context/*.md` | Project-specific tech stack, team, boundaries |
| Project files | `src/`, `apps/`, etc. | Analysis only (e.g., detect skills, code review) |
| Plugin defaults | `config/defaults.yaml` (plugin) | Fallback values for settings |

### Writes

All generated content goes to project-local directories only:

| What | Where |
|------|-------|
| Generated outputs | `jaan-to/outputs/` |
| Accumulated lessons | `jaan-to/learn/` |
| Custom templates | `jaan-to/templates/` |
| Context files | `jaan-to/context/` |
| Metrics | `jaan-to/metrics/` |

jaan-to **never touches**: `.env`, secrets, credentials, SSH keys, hidden directories outside `jaan-to/`.

### Executes

Shell scripts from the plugin's `scripts/` directory run at specific lifecycle events (see Hooks below). All scripts are:
- Visible and auditable in `scripts/`
- Non-obfuscated plain bash
- Using `set -euo pipefail` for safety
- Cleaning up temp files via `trap ... EXIT`

### Network

jaan-to makes **no network calls** by default. The only skills that access the network:
- `pm-research-about` — uses `WebSearch` and `WebFetch` for public web research
- `jaan-issue-report` — uses `gh` CLI to submit issues to GitHub (with explicit user approval)
- `devops-deploy-activate` — uses platform CLIs (`gh`, `vercel`, `railway`, `fly`) for deployment setup

No telemetry, analytics, or data is sent to jaan-to servers. There are no jaan-to servers.

---

## How Hooks Work

Hooks are shell scripts that run automatically at specific points in a Claude Code session.

### Lifecycle Events

| Event | When | What Runs |
|-------|------|-----------|
| SessionStart | Session begins | `bootstrap.sh` — creates directories, loads config |
| PreToolUse (Bash) | Before any Bash command | `pre-tool-security-gate.sh` — blocks dangerous commands |
| PostToolUse (Write) | After file writes | Feedback capture, drift detection, roles sync |
| PostToolUse (Bash) | After Bash commands | Roadmap suggestion after commits |
| TaskCompleted | After agent tasks | Quality gate check |
| Stop | Session ends | `session-end.sh` — cleanup |

### Key Properties

- **Non-blocking**: All hooks exit 0 by default. A hook failure never blocks your work.
- **Read-only checks**: PostToolUse hooks only read files and print suggestions.
- **Security gate**: The PreToolUse hook can block dangerous Bash commands before execution.
- **No secrets**: Hooks never read `.env` files or credentials.
- **Auditable**: Every hook command is defined in `hooks/hooks.json` and points to a visible script.

---

## Permission Model

### Skill-Level Permissions

Each skill declares exactly which tools it can use in its `allowed-tools` frontmatter. Skills cannot access tools outside their allowlist.

**Examples of narrowly-scoped permissions:**
- `Write($JAAN_OUTPUTS_DIR/**)` — can only write to outputs directory
- `Bash(npm test:*)` — can only run test commands, not arbitrary npm
- `Edit(src/**)` — can only edit source files, not config or secrets

**What's NOT allowed:**
- No skill has `Read(.env*)` or access to secret files
- No skill has bare `Bash` (unrestricted shell access)
- No skill has bare `Edit` (unrestricted file editing)
- No skill can run `npm install` of arbitrary packages without explicit scoping

### Human Approval Gates

Every write-heavy skill follows the **HARD STOP** pattern:
1. Analyze and plan (read-only)
2. Show complete preview of what will change
3. Wait for explicit user approval
4. Only then write files

You always see what will happen before it happens.

### Claude Code Layer

On top of skill permissions, Claude Code's own permission system applies. You can further restrict operations in `.claude/settings.json`. See [Permissions](permissions.md) for details.

---

## Data Privacy

### What Stays Local

- All processing runs locally on your machine via Claude Code
- Generated outputs, learned lessons, and config are local files
- No data is collected, transmitted, or stored externally
- No analytics, telemetry, or usage tracking

### External Interactions

When a skill does interact externally (only with your explicit approval):

| Skill | External Service | What's Sent | Sanitization |
|-------|-----------------|-------------|--------------|
| `jaan-issue-report` | GitHub Issues | Bug report text | Paths, credentials, personal info redacted |
| `pm-research-about` | Public web | Search queries | No project data sent |
| `devops-deploy-activate` | GitHub, Vercel, etc. | Deployment config | Secrets entered by user, never logged |

### Privacy Sanitization

Before any external submission, jaan-to sanitizes:
- Absolute paths (`/Users/you/...` becomes `{USER_HOME}/...`)
- Credentials (`ghp_*`, `sk-*`, `Bearer *`, API keys)
- Database connection strings (`postgresql://`, `mongodb://`, etc.)
- Personal information (emails, IPs embedded in paths)

---

## What You Can Customize

| What | Where | Effect |
|------|-------|--------|
| Output paths | `jaan-to/config/settings.yaml` | Redirect where outputs are written |
| Language | `settings.yaml` → `language` | UI language for skill output |
| Safety boundaries | `jaan-to/context/boundaries.md` | Custom rules skills must follow |
| Feature toggles | `settings.yaml` → feature flags | Enable/disable specific behaviors |
| Templates | `jaan-to/templates/` | Customize output formats |
| Claude Code permissions | `.claude/settings.json` | Allow/deny rules at the CLI level |

All customization uses local files. No account, registration, or cloud config needed.

---

## Path Security

jaan-to validates all configurable paths to prevent directory traversal attacks:

- **No `..` segments**: Paths containing `..` are rejected
- **No absolute paths**: Paths starting with `/` are rejected
- **Canonical validation**: After resolution, paths are verified to stay within the project directory using `realpath`
- **Template imports**: `{{import:path}}` directives are validated before reading any file

A malicious `settings.yaml` with `paths_outputs: "../../.ssh"` would be rejected with a clear error.

---

## Temp File Safety

Plugin scripts that use temporary files:
- Create them with `mktemp` (unpredictable filenames, atomic creation)
- Clean them up via `trap cleanup EXIT`
- Never store sensitive data in temp files

---

## Uninstalling

To completely remove jaan-to from a project:

1. Remove the plugin from Claude Code settings (`.claude/settings.json`)
2. Delete the `jaan-to/` directory from your project
3. Done

There are no system-level changes to undo, no background processes, no global config files, and no remote accounts to deactivate.

---

## Related

- [Guardrails](guardrails.md) — Non-negotiable safety rules
- [Permissions](permissions.md) — Claude Code allow/deny configuration
- [Security Strategy](../../docs/security-strategy.md) — Developer security reference
