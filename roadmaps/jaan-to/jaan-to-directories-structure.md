# jaan.to Directory Structure

> Complete directory layout of the jaan.to Claude Code plugin.

---

## Overview

```
project-root/
├── .claude-plugin/         Plugin manifest
├── .claude/                Claude Code registry (settings, skills - written at install)
├── skills/                 Skill definitions (plugin source)
├── agents/                 Sub-agent definitions
├── outputStyles/           Output formatting styles
├── hooks/                  Hook configuration
├── scripts/                Hook scripts (bootstrap, validation, feedback) + seeds
├── .jaan-to/               Project-local workspace (gitignored, bootstrapped)
├── docs/                   Human documentation
├── roadmaps/               Project planning and vision
├── website/                Landing page
└── (root files)            CLAUDE.md, README.md, LICENSE.md, etc.
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
├── to-jaan-docs-create/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── to-jaan-docs-update/
│   ├── LEARN.md
│   └── SKILL.md
├── to-jaan-learn-add/
│   ├── LEARN.md
│   └── SKILL.md
├── to-jaan-research-about/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── to-jaan-research-add/
│   ├── LEARN.md
│   └── SKILL.md
├── to-jaan-roadmap-add/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── to-jaan-skill-create/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
├── to-jaan-skill-update/
│   ├── LEARN.md
│   └── SKILL.md
├── jaan-to-pm-prd-write/
│   ├── LEARN.md
│   ├── SKILL.md
│   └── template.md
└── jaan-to-data-gtm-datalayer/
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
├── build-dist.sh           Build and install plugin to .claude/
├── verify-install.sh       Verify plugin installation
├── capture-feedback.sh     Post-write feedback capture
├── validate-prd.sh         PRD section validation
└── seeds/                  Context templates (copied to .jaan-to/context/)
    ├── boundaries.md
    ├── config.md
    ├── integrations.md
    ├── team.md
    └── tech.md
```

---

## Context Seeds

Project context templates located in `scripts/seeds/`. These are copied to `.jaan-to/context/` during bootstrap.

---

## Project-Local (.jaan-to/)

Generated at runtime by bootstrap hook. Gitignored.

```
.jaan-to/
├── context/                Copies of context templates (editable)
│   ├── tech.md
│   ├── team.md
│   ├── integrations.md
│   ├── boundaries.md
│   └── config.md
├── templates/              Copies of skill templates (editable)
│   └── {skill-name}-template.md
├── learn/                  Project-specific learning files
│   ├── {skill-name}.learn.md
│   ├── template-{name}.learn.md
│   └── context-{name}.learn.md
├── docs/                   Plugin documentation copies
│   ├── STYLE.md
│   └── create-skill.md
└── outputs/                Skill-generated outputs
    ├── pm/spec/{slug}/prd.md
    ├── data/gtm/{slug}/
    └── research/{slug}/
```

---

## Claude Registry (.claude/)

Claude Code settings and skill registry (written during install by build-dist.sh).

```
.claude/
├── settings.json           Permissions and tool allowlists
├── settings.local.json     Local overrides (gitignored)
└── skills/                 10 skills (namespaced for registry)
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

## Removed (Post-Migration)

The following directories were removed after plugin migration:

- `jaan-to/` - Old standalone structure, replaced by plugin architecture
- Old skill names without prefixes (e.g., `pm-prd-write`, `data-gtm-datalayer`, `jaan-docs-create`) - Now use `jaan-to-` or `to-jaan-` prefixes
- `skills/{role}/{domain}/` - Old nested structure, now flat `skills/{name}/`
- `LEARN.md` alongside skills - Now bootstrapped to `.jaan-to/learn/{name}.learn.md`
- `docs/deepresearches/` - Outputs now go to `.jaan-to/outputs/research/`
