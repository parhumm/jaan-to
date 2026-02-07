---
title: /dev-fe-design
doc_type: skill
created_date: 2026-02-03
updated_date: 2026-02-03
tags: [dev, frontend, component, design, accessibility, responsive, react, vue]
related: [fe-task-breakdown, stack-detect]
---

# /dev-fe-design

> Create distinctive, production-grade frontend interfaces.

---

## Overview

Generates working component code (HTML/CSS/JS, React, Vue, vanilla) with bold design choices that avoid generic "AI slop" aesthetics. Produces production-ready code with full accessibility (WCAG AA), responsive design, and comprehensive design rationale documentation.

---

## Usage

```
/dev-fe-design "Hero section for SaaS landing page"
/dev-fe-design "Pricing card component with 3 tiers and hover effects"
/dev-fe-design "Login form for admin panel"
```

| Argument | Required | Description |
|----------|----------|-------------|
| component-description | Yes | Component description, detailed requirements, or PRD path |

---

## What It Produces

Three files at `$JAAN_OUTPUTS_DIR/dev/components/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-component-{slug}.md` | Documentation with design rationale, usage guide, accessibility notes |
| `{id}-component-code-{slug}.{ext}` | Production-ready component code (.jsx/.vue/.html based on tech stack) |
| `{id}-component-preview-{slug}.html` | Standalone preview showing component in multiple states |

---

## What It Asks

| Question | Why |
|----------|-----|
| Design direction | Determines aesthetic approach (Bold, Professional, Playful, Minimal) |
| Framework | React, Vue, Svelte, or vanilla JS (if not in tech.md) |
| Styling approach | Tailwind, CSS Modules, styled-components, vanilla CSS |
| Accessibility level | WCAG AA (default) or AAA |
| Dark mode support | Whether to include dark theme variant |

---

## Design Principles

The skill generates components that:

- **Avoid generic patterns** — Distinctive typography (not Inter/Roboto), purposeful colors (not purple gradients), unexpected layouts
- **Use modern CSS** — Grid, Container Queries, Custom Properties, `:has()`, `prefers-color-scheme`
- **Prioritize accessibility** — Semantic HTML, ARIA when needed, keyboard navigation, visible focus indicators
- **Implement responsive design** — Mobile-first approach with fluid scaling
- **Include design rationale** — Documents WHY choices were made, HOW they avoid generic patterns

---

## Framework Detection

Reads `$JAAN_CONTEXT_DIR/tech.md` to auto-detect:
- Frontend framework (React, Vue, Svelte, vanilla JS)
- Framework version for API compatibility
- Styling approach (Tailwind, CSS Modules, styled-components)
- TypeScript usage

If tech.md is missing or incomplete, the skill asks interactively.

---

## Scope

Default scope: **Component + Preview**

| Scope | Deliverables |
|-------|--------------|
| Component only | Code + documentation |
| Component + Preview | Code + docs + standalone HTML preview (default) |
| Component + Variants | Multiple states/configurations |
| Full system | Component + docs + preview + Storybook stories |

---

## Workflow Chain

This skill fits in the dev workflow:

```
/pm-prd-write → /dev-fe-task-breakdown → /dev-fe-design → /qa-test-cases
```

- **task-breakdown** plans what to build (component inventory, tasks)
- **fe-design** builds the actual component code
- **qa-test-cases** generates tests for the component

---

## Example

**Input:**
```
/dev-fe-design "Hero section for SaaS landing page with bold typography"
```

**Output:**
- `jaan-to/outputs/dev/components/01-hero-section/01-component-hero-section.md`
- `jaan-to/outputs/dev/components/01-hero-section/01-component-code-hero-section.jsx`
- `jaan-to/outputs/dev/components/01-hero-section/01-component-preview-hero-section.html`

Component includes:
- Asymmetric layout with diagonal flow
- Distinctive display font paired with refined body font
- CSS Grid with overlap for visual depth
- Staggered animation on load
- Full keyboard navigation
- WCAG AA contrast (4.5:1)
- Mobile-first responsive breakpoints

---

## Tips

- **Check design.md first** — If your project has `$JAAN_CONTEXT_DIR/design.md`, the skill follows existing patterns for consistency
- **Specify brand elements** — Mention specific colors, fonts, or brand guidelines in your request
- **Use with task-breakdown** — Run `/dev-fe-task-breakdown` first to plan, then use this to build individual components
- **Preview in browser** — Open the generated preview file to see the component with multiple states
- **Customize via settings.yaml** — Set `design.default_direction` in `jaan-to/config/settings.yaml` to skip direction questions

---

[Back to Dev Skills](README.md) | [Back to All Skills](../README.md)
