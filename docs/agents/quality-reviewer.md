---
title: Quality Reviewer
sidebar_position: 3
doc_type: concept
created_date: 2026-01-29
updated_date: 2026-01-29
tags: [agents, quality, review]
related: [README.md, ../STYLE.md]
---

# Quality Reviewer

> Reviews skill outputs for completeness, formatting, and STYLE.md compliance.

---

## What It Does

The quality-reviewer agent checks generated documents against project standards. Skills invoke it after generating output to catch issues before the user sees the final result.

---

## What It Checks

| Check | Description |
|-------|-------------|
| Required sections | Compares output against the skill's `$JAAN_TEMPLATES_DIR/jaan-to-{skill}.template.md` structure |
| STYLE.md compliance | Validates formatting rules from `${CLAUDE_PLUGIN_ROOT}/docs/STYLE.md` |
| LEARN.md patterns | Checks accumulated lessons from `$JAAN_LEARN_DIR/jaan-to-{skill}.learn.md` |
| Placeholder text | Flags leftover `{placeholders}` or TODO markers |

---

## How It Works

1. Reads the skill's `$JAAN_TEMPLATES_DIR/jaan-to-{skill}.template.md` to know expected structure
2. Reads `${CLAUDE_PLUGIN_ROOT}/docs/STYLE.md` for formatting rules
3. Reads the skill's LEARN.md for accumulated patterns
4. Compares the generated output against all three
5. Returns a list of issues with severity levels

---

## Report Format

Issues are reported with severity:

| Severity | Meaning |
|----------|---------|
| **Blocker** | Must fix before output is usable |
| **Warning** | Should fix, but output is functional |
| **Info** | Suggestion for improvement |

---

## Configuration

| Field | Value |
|-------|-------|
| **Location** | `agents/quality-reviewer.md` |
| **Tools** | Read, Glob, Grep |
| **Model** | haiku |
| **Invocation** | Automatic (by skills post-generation) |

---

## Related

- [Agents Overview](docs/agents/README.md)
- [Style Guide](https://github.com/parhumm/jaan-to/blob/main/docs/STYLE.md)
