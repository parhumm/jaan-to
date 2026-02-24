---
title: "Product Management"
sidebar_position: 1
slug: /skills/pm
---

# PM Skills

> Product Manager commands for specs and planning.

---

## Available Skills

| Command | Description |
|---------|-------------|
| [/jaan-to:pm-prd-write](prd-write.md) | Generate PRD from initiative |
| [/jaan-to:pm-research-about](research-about.md) | Deep research or add to index |
| [/jaan-to:pm-story-write](story-write.md) | Generate user stories with Given/When/Then AC |
| [/jaan-to:pm-roadmap-add](roadmap-add.md) | Add prioritized items to project roadmap |
| [/jaan-to:pm-roadmap-update](roadmap-update.md) | Review and maintain project roadmap |

---

## Role Context

PM skills generate product outputs:
- Product Requirements Documents (PRDs)
- Feature specifications
- Metrics definitions
- Product roadmaps with prioritization

---

## Common Workflow

1. Start with an initiative idea
2. Run `/jaan-to:pm-prd-write "your idea"`
3. Answer clarifying questions
4. Review and approve PRD
5. Run `/jaan-to:pm-roadmap-add "your item"` to add to roadmap
6. Run `/jaan-to:pm-roadmap-update review` to maintain roadmap
7. Share with team

---

## Output Location

```
jaan-to/outputs/pm/{domain}/{id}-{slug}/{id}-{slug}.md
```
