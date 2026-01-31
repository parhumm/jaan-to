# Jaan.to — Give soul to your product

**AI-powered skills for PM, Data, QA, Dev workflows. PRD generation, GTM tracking, documentation management, and more.**

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Claude Code Plugin](https://img.shields.io/badge/Plugin-Claude%20Code-blue.svg)](https://claude.ai)

---

## What is "jaan"?

"Jaan" is a Persian word meaning "soul" or "life." When you say "jaan-e man" — "my soul" — you're expressing the deepest form of care.

**Jaan.to** means "giving soul to something" — a person, a project, a product. It's the act of breathing life into work that would otherwise feel mechanical.

---

## Installation

### Quick start (local development)
```bash
claude --plugin-dir /path/to/jaan-to
```

### Clean distribution
```bash
./scripts/build-dist.sh
claude --plugin-dir ./dist/jaan-to
```

### First run
The bootstrap hook automatically creates `.jaan-to/` in your project with:
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

## Available Skills

### Product Management

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:pm-prd-write` | Generate comprehensive PRD from initiative | `.jaan-to/outputs/pm/spec/{slug}/prd.md` |

**Example:**
```
/jaan-to:pm-prd-write "user authentication with OAuth2"
```

### Data & Analytics

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:data-gtm-datalayer` | Generate GTM tracking code and dataLayer spec | `.jaan-to/outputs/data/gtm/{slug}/tracking.md` |

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
| `/jaan-to:research-about` | Deep research on any topic with sources | `.jaan-to/outputs/research/{slug}/` |
| `/jaan-to:research-add` | Add file/URL to research index | Updates research index |

**Example:**
```
/jaan-to:research-about "React Server Components best practices"
```

### Learning & Feedback

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:learn-add` | Add lesson to project's LEARN.md | `.jaan-to/learn/LEARN.md` |

**Example:**
```
/jaan-to:learn-add "Always validate email format before API submission"
```

### Workflow Management

| Command | Description | Output |
|---------|-------------|--------|
| `/jaan-to:roadmap-add` | Add task to roadmap | `.jaan-to/roadmap.md` |
| `/jaan-to:skill-create` | Create new skill with wizard | `.claude/skills/{name}/` |
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

## Available Output Styles

Customize how jaan.to formats outputs:

| Style | Description | Best For |
|-------|-------------|----------|
| **enterprise-doc** | Formal, comprehensive documentation format with full sections and details | PRDs, technical specs, formal documentation |
| **concise-summary** | Brief, executive-level summaries with key points only | Quick reviews, status updates, decision briefs |

**Usage:** Styles are automatically applied based on skill configuration. You can request a specific style by mentioning it in your command.

---

## First-Time Setup

jaan.to runs a bootstrap script automatically on your first session. This creates:

- `.jaan-to/outputs/` directory for generated files
- `.jaan-to/learn/` directory for accumulated knowledge
- `.jaan-to/.gitignore` to exclude temporary files

### Optional: Customize Context

Enhance jaan.to's understanding of your project by customizing these files in your project (after installing the plugin):

```markdown
<!-- .jaan-to/context/tech.md -->
## Languages
- Backend: Python 3.11, FastAPI
- Frontend: TypeScript, React 18

## Infrastructure
- Cloud: AWS (ECS, RDS, S3)
- Database: PostgreSQL 15
```

```markdown
<!-- .jaan-to/context/team.md -->
## Team Size
- 2 engineers, 1 PM, 1 designer

## Sprint Cadence
- 2 weeks, story points, Monday start
```

```markdown
<!-- .jaan-to/context/integrations.md -->
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
      "Write(.jaan-to/**)"
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
      "Write(.jaan-to/**)",
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
      "Write(.jaan-to/**)",
      "Write(docs/**)",
      "Write(.claude/skills/**)",
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

All generated files are written to `.jaan-to/outputs/` in your project directory:

```
.jaan-to/
├── outputs/
│   ├── pm/spec/{slug}/prd.md
│   ├── data/gtm/{slug}/tracking.md
│   └── research/{slug}/report.md
├── learn/
│   └── LEARN.md
└── .gitignore
```

**Recommended `.gitignore` entry:**
```
.jaan-to/outputs/
.jaan-to/temp/
```

jaan.to automatically creates `.jaan-to/.gitignore` with sensible defaults on first run.

---

## Migration from Standalone

If you previously used jaan.to as a standalone .claude/ setup, follow these steps to migrate:

### Cleanup Old Skills

```bash
# Remove standalone skill definitions
rm -rf .claude/skills/jaan-to-pm-prd-write
rm -rf .claude/skills/jaan-to-data-gtm-datalayer
rm -rf .claude/skills/to-jaan-skill-create
rm -rf .claude/skills/to-jaan-skill-update
rm -rf .claude/skills/to-jaan-docs-create
rm -rf .claude/skills/to-jaan-docs-update
rm -rf .claude/skills/to-jaan-learn-add
rm -rf .claude/skills/to-jaan-research-about
rm -rf .claude/skills/to-jaan-research-add
rm -rf .claude/skills/to-jaan-roadmap-add
```

### Update Settings

Remove hooks from `.claude/settings.json` that reference `jaan-to/hooks/`:

```json
{
  "permissions": {
    "allow": [
      "Read(.jaan-to/**)",
      "Read(docs/**)",
      "Write(.jaan-to/**)",
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

If you customized context files in `jaan-to/context/`, migrate them to `.jaan-to/context/`:

```bash
# Create new context directory
mkdir -p .jaan-to/context

# Migrate your customizations
cp jaan-to/context/tech.md .jaan-to/context/tech.md
cp jaan-to/context/team.md .jaan-to/context/team.md
cp jaan-to/context/integrations.md .jaan-to/context/integrations.md

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
│  - Write to .jaan-to/                                   │
└─────────────────────────────────────────────────────────┘
```

**Why this matters:** No accidental writes. You review the plan before anything happens.

---

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/getting-started.md) | First skill in 5 minutes |
| [Concepts](docs/concepts.md) | Core ideas explained |
| [Skills Reference](docs/skills/README.md) | All available commands |
| [Creating Skills](docs/extending/create-skill.md) | Build your own skills |
| [Configuration](docs/config/README.md) | Settings and context |
| [Vision](roadmaps/jaan-to/vision-jaan-to.md) | Philosophy and architecture |
| [Roadmap](roadmaps/jaan-to/roadmap-jaan-to.md) | What's coming |

---

## Contributing

jaan.to is open source. To extend:

1. Read [Creating Skills](docs/extending/create-skill.md)
2. Use `/jaan-to:skill-create` to scaffold a new skill
3. Submit a PR

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
<strong>Give soul to your workflow.</strong>
</p>
