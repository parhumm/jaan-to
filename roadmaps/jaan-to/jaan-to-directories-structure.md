# jaan.to Directory Structure

> Complete directory layout of the jaan.to Claude Code plugin.

---

## Overview

```
project-root/
├── .claude-plugin/         Plugin manifest
├── .claude/                Claude Code registry (settings, skills)
├── skills/                 Skill definitions (plugin source)
├── agents/                 Sub-agent definitions
├── outputStyles/           Output formatting styles
├── hooks/                  Hook configuration
├── scripts/                Hook scripts
├── context/                Project context templates
├── .jaan-to/               Project-local outputs (gitignored)
├── jaan-to/                Legacy (deprecated)
├── docs/                   Human documentation
├── roadmaps/               Project planning
├── website/                Landing page
└── (root files)            CLAUDE.md, README.md, etc.
```

---

## Plugin Root

```
.claude-plugin/
└── plugin.json             Plugin manifest (name, version, keywords)
```

---

## Skills

Plugin source definitions. Each skill has a `SKILL.md` (required), optional `LEARN.md` and `template.md`.

```
skills/
├── docs-create/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── docs-update/
│   ├── LEARN.md
│   └── SKILL.md
├── learn-add/
│   └── SKILL.md
├── research-about/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── research-add/
│   ├── LEARN.md
│   └── SKILL.md
├── roadmap-add/
│   ├── SKILL.md
│   └── template.md
├── skill-create/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── skill-update/
│   ├── LEARN.md
│   └── SKILL.md
├── pm-prd-write/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
└── data-gtm-datalayer/
    ├── LEARN.md
    ├── SKILL.md
    └── template.md
```

---

## Agents

Sub-agents that skills delegate to. Read-only, model-specific.

```
agents/
├── context-scout.md        Gathers project context before generation
└── quality-reviewer.md     Reviews outputs for completeness
```

---

## Output Styles

Formatting directives skills apply to generated content.

```
outputStyles/
├── concise-summary.md      Bullets and tables only, no prose
└── enterprise-doc.md       YAML headers, numbered sections, decision logs
```

---

## Hooks & Scripts

```
hooks/
└── hooks.json              Hook configuration (SessionStart, PostToolUse)

scripts/
├── bootstrap.sh            Session initialization (creates .jaan-to/)
├── capture-feedback.sh     Post-write feedback capture
└── validate-prd.sh         PRD section validation
```

---

## Context

Project context templates. Skills read these to understand your environment.

```
context/
├── boundaries.md           Safe write paths, denied locations
├── config.md               Enabled roles, available skills, defaults
├── integrations.md         External tools, APIs, third-party services
├── team.md                 Team structure, roles, communication
└── tech.md                 Languages, frameworks, infrastructure
```

---

## Project-Local (.jaan-to/)

Generated at runtime by bootstrap hook. Gitignored.

```
.jaan-to/
├── learn/                  Project-specific learning files
│   └── {skill-name}.learn.md
└── outputs/                Skill-generated outputs
    ├── pm/spec/{slug}/prd.md
    ├── data/gtm/{slug}/
    └── research/{slug}/
```

---

## Claude Registry (.claude/)

Claude Code settings and skill registry (mirrors `skills/` with namespaced directories).

```
.claude/
├── settings.json           Permissions and tool allowlists
├── settings.local.json     Local overrides (gitignored)
└── skills/                 10 skills (namespaced copies)
    ├── jaan-to-pm-prd-write/
    ├── jaan-to-data-gtm-datalayer/
    ├── to-jaan-docs-create/
    ├── to-jaan-docs-update/
    ├── to-jaan-learn-add/
    ├── to-jaan-research-about/
    ├── to-jaan-research-add/
    ├── to-jaan-roadmap-add/
    ├── to-jaan-skill-create/
    └── to-jaan-skill-update/
```

---

## Documentation

```
docs/
├── README.md               Documentation index
├── STYLE.md                Documentation standards
├── concepts.md             Core ideas explained
├── getting-started.md      Quick start guide
├── agents/
│   ├── README.md
│   ├── context-scout.md
│   └── quality-reviewer.md
├── config/
│   ├── README.md
│   ├── context-system.md
│   ├── guardrails.md
│   ├── permissions.md
│   └── stacks.md
├── deepresearches/
│   ├── README.md
│   └── 01..43-*.md         43 numbered research files
├── extending/
│   ├── README.md
│   ├── create-hook.md
│   └── create-skill.md
├── hooks/
│   ├── README.md
│   ├── bootstrap.md
│   ├── capture-feedback.md
│   └── validate-prd.md
├── learning/
│   └── README.md
├── output-styles/
│   ├── README.md
│   ├── concise-summary.md
│   └── enterprise-doc.md
└── skills/
    ├── README.md
    ├── core/
    │   ├── README.md
    │   ├── docs-create.md
    │   ├── docs-update.md
    │   ├── learn-add.md
    │   ├── research-about.md
    │   ├── research-add.md
    │   ├── roadmap-task-add.md
    │   ├── skill-create.md
    │   └── skill-update.md
    ├── data/
    │   ├── README.md
    │   └── gtm-datalayer.md
    └── pm/
        ├── README.md
        └── prd-write.md
```

---

## Roadmaps

```
roadmaps/
└── jaan-to/
    ├── jaan-to-directories-structure.md   (this file)
    ├── roadmap-jaan-to.md
    ├── vision-jaan-to.md
    └── tasks/
        ├── README.md
        ├── dev-tech-skills.md
        ├── development-workflow.md
        ├── distribution.md
        ├── learning-system.md
        ├── mcp-connectors.md
        ├── mcp-context7.md
        └── role-skills.md
```

---

## Website

```
website/
└── index.html              Landing page
```

---

## Root Files

```
CHANGELOG.md                Version history
CLAUDE.md                   AI behavioral rules and context
LICENSE.md                  MIT license
README.md                   Plugin README (installation, usage)
marketplace.json            Plugin marketplace metadata
.gitignore                  Git ignore rules
.mcp.json                   MCP server configuration (empty)
```

---

## Legacy (Deprecated)

Kept for backward compatibility detection by `scripts/bootstrap.sh`.

```
jaan-to/
├── config.md               → replaced by context/config.md
├── boundaries/
│   └── safe-paths.md       → replaced by context/boundaries.md
├── context/
│   ├── integrations.md     → replaced by context/integrations.md
│   ├── team.md             → replaced by context/team.md
│   └── tech.md             → replaced by context/tech.md
└── hooks/
    ├── capture-feedback.sh → replaced by scripts/capture-feedback.sh
    └── validate-prd.sh     → replaced by scripts/validate-prd.sh
```
