---
title: Customizing jaan.to
sidebar_position: 1
doc_type: guide
created_date: 2026-02-03
updated_date: 2026-02-08
tags: [customization, configuration, paths, templates, learning, language]
related: []
---

# Customizing jaan.to

> Adapt paths, templates, learning, language, and tech context to your project.

---

## Overview

jaan.to uses a 3-layer configuration system. Each layer overrides the one below it:

| Layer | Source | Scope |
|-------|--------|-------|
| 1 (Base) | Plugin defaults | All projects |
| 2 (Project) | `jaan-to/config/settings.yaml` | This repo |
| 3 (Machine) | `$JAAN_*` environment variables | This machine |

You can customize: output paths, template files, learning behavior, language preference, and tech context.

---

## Prerequisites

- jaan.to v3.0.0+ installed
- Bootstrap has run (`jaan-to/` directory exists in your project)

---

## Step 1: Project Settings

Edit `jaan-to/config/settings.yaml` to override defaults for your repo.

| Setting | Default | Description |
|---------|---------|-------------|
| `paths_outputs` | `jaan-to/outputs` | Where generated files go |
| `paths_templates` | `jaan-to/templates` | Where templates live |
| `paths_learning` | `jaan-to/learn` | Where lessons accumulate |
| `paths_context` | `jaan-to/context` | Where context files live |
| `paths_docs` | `jaan-to/docs` | Where documentation files go |
| `learning_strategy` | `merge` | How lessons combine |
| `language` | `ask` | Conversation and report language |
| `language_{skill}` | _(global)_ | Per-skill language override |

Example — move outputs to `artifacts/`:

```yaml
# jaan-to/config/settings.yaml
paths_outputs: "artifacts/jaan-to"
```

All paths are relative to the project root. Use forward slashes on all platforms.

---

## Step 2: Language Preference

Set the language for plugin conversation, questions, and report .md files.

| Setting | Default | Effect |
|---------|---------|--------|
| `language` | `ask` | Prompts once on first skill run, saves your choice |
| `language_{skill-name}` | _(global)_ | Override for one specific skill |

Example — set فارسی globally, keep PRDs in English:

```yaml
# jaan-to/config/settings.yaml
language: "fa"
language_pm-prd-write: "en"
```

Options: `en`, `fa`, `tr`, or any language name/code. Set to `ask` to re-prompt.

**What changes**: Section headings, labels, prose, questions, and confirmations switch to the chosen language.

**What stays English**: Code, file paths, variable names, YAML keys, technical terms, template variables.

**What's unaffected**: Generated code output, product localization (`localization.md`), `/jaan-to:ux-microcopy-write` multi-language output.

---

## Step 3: Path Variables

Override paths per-machine using environment variables in `.claude/settings.json`:

```json
{
  "env": {
    "JAAN_OUTPUTS_DIR": "build/artifacts"
  }
}
```

| Variable | Overrides |
|----------|-----------|
| `JAAN_OUTPUTS_DIR` | `paths_outputs` |
| `JAAN_TEMPLATES_DIR` | `paths_templates` |
| `JAAN_LEARN_DIR` | `paths_learning` |
| `JAAN_CONTEXT_DIR` | `paths_context` |
| `JAAN_DOCS_DIR` | `paths_docs` |

**When to use**: Environment variables override settings.yaml. Use settings.yaml for team-wide config (committed to repo). Use env vars for machine-specific overrides (not committed).

---

## Step 4: Custom Templates

When you first run a skill, the [pre-execution protocol](../extending/pre-execution-protocol.md) offers to seed the plugin's default template into `jaan-to/templates/jaan-to-{skill}.template.md`. Accept the offer to get a local copy you can edit. For more control, override any skill's template by pointing to your own file:

```yaml
# jaan-to/config/settings.yaml
templates_jaan_to_pm_prd_write_path: "./docs/templates/enterprise-prd.md"
```

Templates support 4 variable types:

| Syntax | Resolves To |
|--------|-------------|
| `{{field}}` | Value from skill context |
| `{{env:VAR_NAME}}` | Environment variable |
| `{{config:key}}` | Value from settings.yaml |
| `{{import:path#section}}` | Markdown section from another file |

Place your custom template at the path you specified. The skill uses it instead of the plugin default.

---

## Step 5: Learning Strategy

Skills accumulate lessons over time. Two strategies control how plugin lessons and your project lessons combine:

| Strategy | Behavior |
|----------|----------|
| `merge` (default) | Combines plugin lessons with your project lessons |
| `override` | Uses only your project lessons, ignores plugin defaults |

Change in settings.yaml:

```yaml
learning_strategy: "override"
```

Use `merge` when starting out. Switch to `override` when your team has enough project-specific lessons that plugin defaults add noise.

---

## Step 6: Tech Stack

Edit `jaan-to/context/tech.md` to describe your project's technology. Skills reference this file when generating outputs.

Key sections to fill in:

| Section | What to Include |
|---------|----------------|
| Current Stack | Languages, frameworks, databases, infrastructure |
| Constraints | Hard rules (latency, compliance, API format) |
| Patterns | Auth, error handling, data access conventions |

When you run `/jaan-to:pm-prd-write`, the PRD references your stack in technical sections. When you run `/jaan-to:data-gtm-datalayer`, it uses your event naming conventions.

---

## Scenario: SaaS Team Setup

A SaaS team with a Next.js frontend and FastAPI backend customizes jaan.to:

**1. settings.yaml** — Custom output path and enterprise template:

```yaml
# jaan-to/config/settings.yaml
paths_outputs: "artifacts/product"
templates_jaan_to_pm_prd_write_path: "./docs/templates/enterprise-prd.md"
learning_strategy: "merge"
language: "fa"
```

**2. .claude/settings.json** — Machine-specific override for CI:

```json
{
  "env": {
    "JAAN_OUTPUTS_DIR": "build/artifacts"
  }
}
```

**3. tech.md** — Stack context:

```markdown
## Current Stack {#current-stack}
### Backend
- **Language**: Python 3.12
- **Framework**: FastAPI 0.110
### Frontend
- **Framework**: Next.js 14 + React 18
```

Result: PRDs land in `artifacts/product/pm/`, use the enterprise template, merge plugin + team lessons, reference FastAPI/Next.js in technical sections, and conversation runs in فارسی.

---

## Verification

After customizing, verify your setup:

1. Run any skill (e.g., `/jaan-to:pm-prd-write "test feature"`)
2. Check the output lands in your custom path
3. Confirm the template matches your custom file
4. Review the learning merge in the skill's output header
5. Set `language: "ask"` → run a skill → confirm language prompt appears
6. Choose a language → verify `settings.yaml` updated and next skill uses it without re-prompting

---

## Tips

- Commit `jaan-to/config/settings.yaml` to share settings with your team
- Restart the Claude session after changing settings.yaml or env vars
- Keep `merge` strategy until project lessons outgrow plugin defaults
- Use `{{import:path#section}}` in templates to pull in your tech context

---

## Troubleshooting

**Outputs in wrong path**: Check layer priority. Env vars override settings.yaml, which overrides defaults.

**Template not found**: Verify the path is relative to the project root, not absolute.

**Learning not merging**: Confirm `learning_strategy: "merge"` in settings.yaml. The `override` value skips plugin lessons.

**Language not switching**: Check `language` value in settings.yaml. Set to `ask` to re-prompt. Per-skill overrides (`language_{skill-name}`) take priority over the global setting.
