---
title: "Core Concepts"
sidebar_position: 3
---

# Core Concepts

> Six building blocks of jaan.to.

---

## Skills

Commands that generate outputs.

- Pattern: `/role-domain-action`
- Example: `/pm-prd-write`
- Output: Markdown files in `jaan-to/outputs/`

Skills follow a two-phase workflow:
1. **Analysis** - Read context, ask questions
2. **Generation** - Create artifact, preview, write

[Learn more](skills/README.md)

---

## Stacks

Your team and tech context.

| File | Contains |
|------|----------|
| `jaan-to/context/tech.md` | Languages, frameworks, tools |
| `jaan-to/context/team.md` | Team size, ceremonies, norms |
| `jaan-to/context/integrations.md` | Jira, GitLab, Slack setup |

Skills read context to generate context-aware outputs.

[Learn more](config/context-system.md)

---

## Templates

Output formats for outputs.

- Location: `jaan-to/templates/{skill}.template.md`
- Contains: Section structure, placeholders
- Override: Create your own version

Skills fill templates with generated content.

---

## Learning

System improves from feedback.

Each skill has a `LEARN.md` file with four categories:

| Category | Example |
|----------|---------|
| Better Questions | "Ask about i18n requirements" |
| Edge Cases | "Check for multi-tenant scenarios" |
| Workflow | "Generate metrics JSON alongside PRD" |
| Common Mistakes | "Don't assume single region" |

Add lessons: `/learn-add {skill} "lesson text"`

[Learn more](learning/README.md)

---

## Hooks

Automated triggers before/after actions.

| Type | When | Example |
|------|------|---------|
| PreToolUse | Before write | Validate required sections |
| PostToolUse | After write | Prompt for feedback |

Hooks run automatically. No action needed.

[Learn more](hooks/README.md)

---

## Guardrails

Safety boundaries.

- **Safe paths**: Only write to `jaan-to/`
- **Preview first**: Always show before saving
- **Approval required**: You confirm every write

Guardrails cannot be disabled.

[Learn more](config/guardrails.md)
