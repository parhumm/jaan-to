---
title: Customizing jaan.to
doc_type: guide
created_date: 2026-02-03
updated_date: 2026-02-03
tags: [customization, configuration, paths, templates, learning]
related: []
---

# Customizing jaan.to

> Adapt paths, templates, learning, and tech context to your project.

---

## Overview

jaan.to uses a 3-layer configuration system. Each layer overrides the one below it:

| Layer | Source | Scope |
|-------|--------|-------|
| 1 (Base) | Plugin defaults | All projects |
| 2 (Project) | `jaan-to/config/settings.yaml` | This repo |
| 3 (Machine) | `$JAAN_*` environment variables | This machine |

You can customize: output paths, template files, learning behavior, and tech context.

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
| `learning_strategy` | `merge` | How lessons combine |

Example — move outputs to `artifacts/`:

```yaml
# jaan-to/config/settings.yaml
paths_outputs: "artifacts/jaan-to"
```

All paths are relative to the project root. Use forward slashes on all platforms.

---

## Step 2: Path Variables

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

**When to use**: Environment variables override settings.yaml. Use settings.yaml for team-wide config (committed to repo). Use env vars for machine-specific overrides (not committed).

---

## Step 3: Custom Templates

Override any skill's template by pointing to your own file:

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

## Step 4: Learning Strategy

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

## Step 5: Tech Stack

Edit `jaan-to/context/tech.md` to describe your project's technology. Skills reference this file when generating outputs.

Key sections to fill in:

| Section | What to Include |
|---------|----------------|
| Current Stack | Languages, frameworks, databases, infrastructure |
| Constraints | Hard rules (latency, compliance, API format) |
| Patterns | Auth, error handling, data access conventions |

When you run `/pm-prd-write`, the PRD references your stack in technical sections. When you run `/data-gtm-datalayer`, it uses your event naming conventions.

---

## Scenario: SaaS Team Setup

A SaaS team with a Next.js frontend and FastAPI backend customizes jaan.to:

**1. settings.yaml** — Custom output path and enterprise template:

```yaml
# jaan-to/config/settings.yaml
paths_outputs: "artifacts/product"
templates_jaan_to_pm_prd_write_path: "./docs/templates/enterprise-prd.md"
learning_strategy: "merge"
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

Result: PRDs land in `artifacts/product/pm/`, use the enterprise template, merge plugin + team lessons, and reference FastAPI/Next.js in technical sections.

---

## Verification

After customizing, verify your setup:

1. Run any skill (e.g., `/pm-prd-write "test feature"`)
2. Check the output lands in your custom path
3. Confirm the template matches your custom file
4. Review the learning merge in the skill's output header

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
