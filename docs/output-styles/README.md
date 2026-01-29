---
title: Output Styles
doc_type: index
created_date: 2026-01-29
updated_date: 2026-01-29
tags: [output-styles, formatting, plugin]
related: [../skills/README.md]
---

# Output Styles

> Formatting directives that skills apply to their generated outputs.

---

## Overview

Output styles control how skill outputs are formatted. Each style defines structure, tone, and layout rules. Skills can apply a style to produce outputs tailored to different audiences or use cases.

---

## Available Styles

| Style | Description | Best For |
|-------|-------------|----------|
| [enterprise-doc](enterprise-doc.md) | Formal documents with metadata headers and structured sections | Stakeholder-facing PRDs, specs, proposals |
| [concise-summary](concise-summary.md) | Brief format with bullets and tables only | Quick reviews, executive updates |

---

## Quick Reference

- Styles live in `outputStyles/` (plugin-relative)
- Skills reference styles in their body text instructions
- Each style is a markdown file with YAML frontmatter and formatting rules
