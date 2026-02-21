# Jaan.to — Give soul to your product

**AI-powered skills for PM, Data, QA, Dev workflows. PRD generation, GTM tracking, documentation management, and more.**

[![Version](https://img.shields.io/badge/version-7.2.0-blue.svg)](.claude-plugin/plugin.json)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code Plugin](https://img.shields.io/badge/Plugin-Claude%20Code-purple.svg)](https://claude.ai)
[![Skills](https://img.shields.io/badge/skills-44-orange.svg)](skills/)
[![Agent Skills](https://img.shields.io/badge/npx%20skills-compatible-brightgreen.svg)](https://skills.sh)
[![Agents](https://img.shields.io/badge/agents-2-yellow.svg)](docs/agents/README.md)

### Plugin Contents

| Component | Count | Description |
|-----------|-------|-------------|
| **Skills** | 44 | PM, Dev, Backend, Frontend, QA, UX, Data, Detect, WordPress, Release, Security, DevOps, Core |
| **Agents** | 2 | quality-reviewer, context-scout |
| **Hooks** | 7 | Setup, SessionStart, PreToolUse, PostToolUse, Stop, TaskCompleted, TeammateIdle |
| **Output Styles** | 2 | enterprise-doc, concise-summary |

---

## What is "jaan"?

"Jaan" is a Persian word meaning "soul" or "life." When you say "jaan-e man" — "my soul" — you're expressing the deepest form of care.

**Jaan.to** means "giving soul to something" — a person, a project, a product. It's the act of breathing life into work that would otherwise feel mechanical.

---

## Installation

### Stable Version (Recommended)
```
claude
/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to
/jaan-init
```

### Development Version (Preview)
For testing latest features before release:
```
claude
/plugin marketplace add parhumm/jaan-to#dev
/plugin install jaan-to
/jaan-init
```

### Switching Versions
To switch from dev to stable (or vice versa):
```
/plugin uninstall jaan-to
/plugin marketplace add parhumm/jaan-to       # stable
/plugin marketplace add parhumm/jaan-to#dev   # dev
/plugin install jaan-to
/jaan-init
```

### Check Installed Version
```
/plugin list
```
- All versions use the same format: `3.15.0`, `3.16.0`, etc.

### Local Development
```bash
claude --plugin-dir /path/to/jaan-to
```

### Distribution Builds
```bash
# Claude plugin package
./scripts/build-dist.sh
claude --plugin-dir ./dist/jaan-to-claude

# Codex skillpack source (global installer path)
bash ./scripts/build-codex-skillpack.sh

# Install global Codex skillpack (uses Codex Skill Installer)
bash ./scripts/install-codex-skillpack.sh
# Restart Codex after install

# Build both targets
./scripts/build-all-targets.sh

# Integrated dual-runtime smoke E2E (blocking gate equivalent)
bash scripts/test/e2e-dual-runtime-smoke.sh

# Full E2E suite (smoke + legacy integration tests)
bash scripts/test/e2e-dual-runtime-full.sh
```

Then open `/path/to/your-project` in Codex and invoke skills with:

```text
/skills
$jaan-init
/jaan-init
$pm-prd-write
$detect-dev
```

In Codex, `/jaan-to:*` and `/jaan-init` are maintained as aliases for native `$skill` invocation.
Global skillpack installation is the default path.

### Codex Local Mode (Legacy/Debug)

Use local mode only when explicitly testing project-local symlinks:

```bash
./scripts/build-target.sh codex
cd ./dist/jaan-to-codex
./jaan-to setup /path/to/your-project --mode local
```

`setup --mode auto` resolves to:
- `global` when `~/.agents/skills/jaan-to-codex-pack` exists
- `local` otherwise

### Codex Troubleshooting

- SSL certificate failure in Skill Installer `auto` mode:
  - The wrapper retries with `--method git` automatically.
- Duplicate name ambiguity (`$skill` not resolving):
  - Remove duplicate project `.agents/skills/<jaan-to-skill>` entries and use global mode.
- Skills not showing after install:
  - Restart Codex to reload installed skills.

Integrated smoke E2E validates end-to-end Claude + Codex packaging and setup flow in one command.

### Claude Compatibility Guarantee

Claude Code installation, command namespace (`/jaan-to:*`), and plugin behavior remain unchanged.
Codex support is added as a thin adapter and runner layer without changing Claude runtime contracts.

### Agent Skills (Cross-Platform)

Install skills via the [Agent Skills](https://skills.sh) ecosystem — works across Claude Code, Cursor, VS Code, GitHub Copilot, and 18+ agents:

```bash
# Install all 44 skills
npx skills add parhumm/jaan-to

# Install a specific skill
npx skills add parhumm/jaan-to --skill pm-prd-write

# Browse available skills
npx skills find "product requirements"
```

> **Note:** This installs skill definitions only. For the full jaan.to experience (hooks, agents, config system, learning), use the [plugin installation](#stable-version-recommended) instead.

### First run
The bootstrap hook automatically creates `jaan-to/` in your project with:
- `context/` — Config and boundary templates (customize for your project)
- `templates/` — Output templates for each skill
- `learn/` — Learning seeds (improve over time)
- `outputs/` — Generated outputs (PRDs, tracking code, research, etc.)
- `docs/` — Reference docs (style guide, skill spec)

### Verify installation
```bash
./scripts/verify-install.sh /path/to/your-project
```

---

## Optional: Project-Level Configuration

jaan.to follows Claude Code best practices by NOT shipping with configuration files. All settings are OPTIONAL and should be added to YOUR project's `.claude/settings.json` if needed.

**Why?** Configuration is project-specific, not plugin-specific. This keeps the plugin portable and ensures you maintain full control over permissions and environment variables in your own codebase.

See [Recommended Permissions](#recommended-permissions) below for examples of common permission patterns.

---

## Available Skills

### Product Management

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:pm-prd-write` | Generate comprehensive PRD from initiative | `jaan-to/outputs/pm/{slug}/prd.md` |
| `/jaan-to:pm-story-write` | Generate user stories with Given/When/Then ACs following INVEST principles | `jaan-to/outputs/pm/stories/{slug}/stories.md` |

**Example:**
```
/jaan-to:pm-prd-write "user authentication with OAuth2"
```

### Data & Analytics

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code and dataLayer spec | `jaan-to/outputs/data/gtm/{slug}/tracking.md` |

**Example:**
```
/jaan-to:data-gtm-datalayer "checkout flow tracking"
```

### Documentation

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:docs-create` | Create documentation with templates | `docs/` |
| `/jaan-to:docs-update` | Audit and update stale documentation | Updates existing docs |

**Example:**
```
/jaan-to:docs-create "API integration guide"
```

### Research

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:pm-research-about` | Deep research or add file/URL to index | `jaan-to/outputs/research/{slug}/` |

**Examples:**
```
/jaan-to:pm-research-about "React Server Components best practices"
/jaan-to:pm-research-about https://example.com/article
```

### Learning & Feedback

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:learn-add` | Add lesson to project's LEARN.md | `jaan-to/learn/LEARN.md` |

**Example:**
```
/jaan-to:learn-add "Always validate email format before API submission"
```

### Workflow Management

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:roadmap-add` | Add task to roadmap | `jaan-to/roadmap.md` |
| `/jaan-to:skill-create` | Create new skill with wizard | `skills/{name}/` |
| `/jaan-to:skill-update` | Update existing skill | Updates skill definition |

**Example:**
```
/jaan-to:roadmap-add "Implement dark mode toggle"
```

---

## Available Agents

jaan.to includes specialized agents that enhance skill execution:

| Agent | Purpose | Usage |
|-------|---------|-------|
| **quality-reviewer** | Reviews outputs for completeness, accuracy, and quality standards | Automatically invoked by skills that require quality checks |
| **context-scout** | Gathers relevant context from your codebase before generation | Automatically invoked by skills that need project context |

---

## First-Time Setup

jaan.to runs a bootstrap script automatically on your first session. This creates:

- `jaan-to/outputs/` directory for generated files
- `jaan-to/learn/` directory for accumulated knowledge
- `jaan-to/.gitignore` to exclude temporary files

### Optional: Customize Context

Enhance jaan.to's understanding of your project by customizing these files in your project (after installing the plugin):

```markdown
<!-- jaan-to/context/tech.md -->
## Languages
- Backend: Python 3.11, FastAPI
- Frontend: TypeScript, React 18

## Infrastructure
- Cloud: AWS (ECS, RDS, S3)
- Database: PostgreSQL 15
```

```markdown
<!-- jaan-to/context/team.md -->
## Team Size
- 2 engineers, 1 PM, 1 designer

## Sprint Cadence
- 2 weeks, story points, Monday start
```

```markdown
<!-- jaan-to/context/integrations.md -->
## Analytics
- Google Analytics 4
- GTM container ID: GTM-XXXXXXX

## Project Management
- Jira workspace: https://company.atlassian.net
```

---

## Recommended Permissions

Configure permissions in your project's `.claude/settings.json`:

### Minimal (Read-Only User)

Best for: Reviewing generated outputs, learning from examples

```json
{
  "permissions": {
    "allow": [
      "Write(jaan-to/**)"
    ],
    "deny": [
      "Bash(*)",
      "Write(src/**)",
      "Write(.env*)"
    ]
  }
}
```

### Standard (IC Developer)

Best for: Individual contributors generating specs, tracking, documentation

```json
{
  "permissions": {
    "allow": [
      "Write(jaan-to/**)",
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff *)"
    ],
    "deny": [
      "Write(.env*)",
      "Bash(rm:*)",
      "Bash(curl:*)"
    ]
  }
}
```

### Power User (Tech Lead / PM)

Best for: Team leads, PMs, architects managing documentation and workflows

```json
{
  "permissions": {
    "allow": [
      "Write(jaan-to/**)",
      "Write(docs/**)",
      "Write(jaan-to/outputs/**)",
      "Bash(npm run *)",
      "Bash(git *)"
    ],
    "deny": [
      "Write(.env*)",
      "Bash(rm -rf *)"
    ]
  }
}
```

---

## Output Directory

All generated files are written to `jaan-to/outputs/` in your project directory:

```
jaan-to/
├── outputs/
│   ├── pm/{slug}/prd.md
│   ├── data/gtm/{slug}/tracking.md
│   └── research/{slug}/report.md
├── learn/
│   └── LEARN.md
└── .gitignore
```

**Recommended `.gitignore` entry:**
```
jaan-to/outputs/
jaan-to/temp/
```

jaan.to automatically creates `jaan-to/.gitignore` with sensible defaults on first run.

---

## Migration from Standalone

If you previously used jaan.to as a standalone .claude/ setup, follow these steps to migrate:

### Cleanup Old Skills

```bash
# Remove standalone skill definitions (old naming)
rm -rf .claude/skills/pm-prd-write
rm -rf .claude/skills/data-gtm-datalayer
rm -rf .claude/skills/jaan-skill-create
rm -rf .claude/skills/jaan-skill-update
rm -rf .claude/skills/jaan-docs-create
rm -rf .claude/skills/jaan-docs-update
rm -rf .claude/skills/jaan-learn-add
rm -rf .claude/skills/jaan-research-about
rm -rf .claude/skills/jaan-research-add
rm -rf .claude/skills/jaan-roadmap-add
```

### Update Settings

Remove hooks from `.claude/settings.json` that reference `jaan-to/hooks/`:

```json
{
  "permissions": {
    "allow": [
      "Read(jaan-to/**)",
      "Read(docs/**)",
      "Write(jaan-to/**)",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Write(src/**)",
      "Write(.env*)",
      "Bash(rm:*)"
    ]
  }
}
```

**Remove the entire `"hooks"` section** — hooks are now managed by the plugin.

### Migrate Context Files

If you customized context files in `jaan-to/context/`, migrate them to `jaan-to/context/`:

```bash
# Create new context directory
mkdir -p jaan-to/context

# Migrate your customizations
cp jaan-to/context/tech.md jaan-to/context/tech.md
cp jaan-to/context/team.md jaan-to/context/team.md
cp jaan-to/context/integrations.md jaan-to/context/integrations.md

# Clean up old structure
rm -rf jaan-to/
```

---

## How It Works

Every skill follows a **two-phase workflow** with human approval:

```
┌─────────────────────────────────────────────────────────┐
│  PHASE 1: Analysis (Read-Only)                          │
│  - Read context files                                   │
│  - Gather requirements                                  │
│  - Plan structure                                       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  HARD STOP: Human Approval                              │
│  "Ready to generate? [y/n]"                             │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  PHASE 2: Generation (Write)                            │
│  - Generate output                                      │
│  - Quality check (via quality-reviewer agent)           │
│  - Preview                                              │
│  - Write to jaan-to/                                   │
└─────────────────────────────────────────────────────────┘
```

**Why this matters:** No accidental writes. You review the plan before anything happens.

---

## Real-World Examples

### Example 1: Feature Development (End-to-End)

```
Goal: Add OAuth2 authentication to your app

1. Research & PRD
   /jaan-to:pm-research-about "OAuth2 best practices for SaaS"
   /jaan-to:pm-prd-write "OAuth2 authentication with Google and GitHub"

2. User Stories
   /jaan-to:pm-story-write from prd
   → Generates: jaan-to/outputs/pm/stories/01-oauth2-auth/

3. Task Breakdowns
   /jaan-to:frontend-task-breakdown from prd
   → Frontend tasks: Component inventory, state machines, estimates

   /jaan-to:backend-task-breakdown from prd
   → Backend tasks: API endpoints, data models, security

4. QA & Analytics
   /jaan-to:qa-test-cases from prd
   → BDD scenarios with Given/When/Then

   /jaan-to:data-gtm-datalayer "OAuth signup flow tracking"
   → GTM dataLayer pushes for analytics
```

**Flow Diagram:**
```
Research → PRD → Stories → Tasks → QA + Tracking
   ↓         ↓       ↓        ↓         ↓
  Docs    Context  Tickets  Code   Analytics
```

### Example 2: UX Improvement

```
Goal: Improve homepage based on user behavior

1. Analyze Heatmaps
   /jaan-to:ux-heatmap-analyze "homepage-clicks.csv"
   → Identifies: Low engagement on CTA, high scroll depth

2. Synthesize Research
   /jaan-to:ux-research-synthesize "UX interview transcripts"
   → Themes: Users want clearer value prop

3. Generate Microcopy
   /jaan-to:ux-microcopy-write for homepage CTA
   → 7 languages: English, Spanish, French, German, Arabic, Chinese, Japanese
```

### Example 3: Documentation Maintenance

```
Goal: Keep docs in sync with code changes

1. Detect Stale Docs
   /jaan-to:docs-update --check-only
   → Reports: 3 stale skill docs, 1 outdated hook doc

2. Fix Automatically
   /jaan-to:docs-update --fix
   → Updates docs based on code changes in last 7 days

3. Add New Documentation
   /jaan-to:docs-create guide "API Integration Tutorial"
   → Creates: docs/guides/api-integration-tutorial.md
```

### Skill Chain Visualization

```
┌─────────────┐
│   Initial   │
│   Request   │
└──────┬──────┘
       │
   ┌───▼────────────────────────────────────────────┐
   │ Which workflow?                                │
   ├────────────┬────────────┬──────────────┬───────┤
   │            │            │              │       │
┌──▼──┐   ┌────▼────┐  ┌────▼─────┐  ┌────▼─────┐ │
│ PRD │   │Research │  │  UX Res  │  │   Docs   │ │
└──┬──┘   └────┬────┘  └────┬─────┘  └────┬─────┘ │
   │           │            │              │       │
   ├─Stories   │            │              │       │
   ├─Tasks     └─Learn      └─Microcopy    └─Update│
   ├─Tests                                         │
   └─GTM                                           │
       │                                           │
       └───────────────────────────────────────────┘
                           │
                      ┌────▼─────┐
                      │  Output  │
                      │  Files   │
                      └──────────┘
```

---

## Your Data Stays Safe

jaan.to runs entirely on your machine. No telemetry, no analytics, no servers to trust.

### What It Accesses

| | What | Details |
|---|------|---------|
| **Reads** | Project context | `jaan-to/context/`, `jaan-to/config/` — your tech stack, team, boundaries |
| **Writes** | Generated outputs only | `jaan-to/outputs/`, `jaan-to/learn/`, `jaan-to/templates/` |
| **Never touches** | Secrets & credentials | `.env`, SSH keys, API tokens, hidden directories |
| **Network** | None by default | Only `pm-research-about` (web search) and `jaan-issue-report` (GitHub) — both require explicit approval |

### How Skills Stay Contained

Every skill declares exactly which tools it can use. No skill has unrestricted shell access, unrestricted file editing, or access to secret files. Every write-heavy skill follows a **HARD STOP** pattern — you see a complete preview and approve before anything is written.

Path validation prevents directory traversal: a malicious `settings.yaml` with `paths_outputs: "../../.ssh"` is rejected using canonical (`realpath`) checks. Scripts use `set -euo pipefail`, temp files use `mktemp` with cleanup traps, and a PreToolUse security gate blocks dangerous commands (`sudo`, `eval`, `curl | sh`, `rm -rf /`).

### Automated Security Checks

Security standards are enforced automatically. A central validation script (`scripts/validate-security.sh`) checks skill permissions, shell script safety, hook integrity, and dangerous patterns. It runs on every PR to `main`, every release preparation, and every issue review — violations block the merge.

See [Security Guide](docs/config/security.md) for full details on what jaan.to accesses and how privacy sanitization works.

---

## Token Efficiency

jaan.to actively manages its context window footprint so your AI assistant stays fast and responsive, even with 44+ skills installed.

| Layer | What | Effect |
|-------|------|--------|
| **Description budget** | All skill descriptions share a 15,000-char budget | Skills beyond budget are silently dropped — jaan.to stays well under |
| **Reference extraction** | Large skills split into compact execution + on-demand reference | 25-60% reduction in per-invocation token cost |
| **Fork isolation** | Heavy analysis skills run in isolated subagents | Parent session never sees the 30-48K token analysis cost |
| **CI enforcement** | 6 automated gates prevent regression | SKILL.md cap, description budget, CLAUDE.md size, hook stdout cap |

**Result:** A typical session with 3 skill invocations saves 5,000-52,000 tokens versus an unoptimized plugin of equivalent capability.

See [Token Strategy](docs/token-strategy.md) for the full architecture.

---

## From Idea to Product

**Go from a napkin sketch to a deployed product using jaan.to skill chains.**

The [Idea to Product Guide](https://github.com/parhumm/jaanify/blob/main/docs/idea-to-product.md) walks through the full pipeline — research, PRD, design, code generation, testing, and deployment — with minimum human intervention. Each skill's output feeds the next.

| Path | Skills | Time | Result |
|------|--------|------|--------|
| **Fast Track** | 8 skills | ~4 hours | Working MVP |
| **Full Track** | 20 skills | ~1 day | Production-grade app |

```
Define → Design → Build → Quality → Ship
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/getting-started.md) | First skill in 5 minutes |
| [Concepts](docs/concepts.md) | Core ideas explained |
| [Skills Reference](docs/skills/README.md) | All available commands |
| [Creating Skills](docs/extending/create-skill.md) | Build your own skills |
| [Configuration](docs/config/README.md) | Settings and context |
| [Security](docs/config/security.md) | What jaan.to accesses and why your data stays safe |
| [Token Strategy](docs/token-strategy.md) | How jaan.to manages context window efficiency |
| [Vision](docs/roadmap/vision.md) | Philosophy and architecture |
| [Roadmap](docs/roadmap/roadmap.md) | What's coming |

---

## Contributing

jaan.to is open source. To extend:

1. Read [Creating Skills](docs/extending/create-skill.md)
2. Use `/jaan-to:skill-create` to scaffold a new skill
3. Submit a PR

---

## Troubleshooting

### "agents: Invalid input" or plugin install fails?

Claude Code validates `plugin.json` strictly. Only these fields are allowed:
`name`, `version`, `description`, `author`.

Component paths (`skills`, `agents`, `hooks`, `commands`) must **not** be declared — Claude Code auto-discovers them from standard directories.

If you see validation errors during install, check `.claude-plugin/plugin.json` for extra fields.

### Skills not loading after installation?

If skills don't appear after installing or updating the plugin:

```
/plugin uninstall jaan-to
/plugin install jaan-to@jaan-to
```

This reinstalls the plugin and refreshes the registry. You may also need to **restart Claude Code** (exit and reopen) for changes to take effect.

### Commands not recognized?

Ensure the plugin is properly installed:
```
/plugin list
```

You should see `jaan-to` with version `3.x.x`. If not, reinstall:
```
/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
<strong>Give soul to your workflow.</strong>
</p>
