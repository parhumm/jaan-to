---
title: "pm-roadmap-add"
sidebar_position: 5
---

# /jaan-to:pm-roadmap-add

> Add prioritized items to a project roadmap with codebase-aware context.

---

## What It Does

Creates or extends a product roadmap with properly prioritized items. Includes:
- Codebase context scanning (PRDs, stories, tech stack, TODO counts)
- Duplication check against existing items
- Priority assessment using your chosen framework (Value-Effort, MoSCoW, or RICE)
- Milestone/theme assignment

When no roadmap exists, bootstraps a new one with your chosen prioritization system.

---

## Usage

```
/jaan-to:pm-roadmap-add "add user authentication feature"
```

---

## What It Asks

| Question | Why |
|----------|-----|
| Which prioritization system? | Sets framework (first run only) |
| What is the expected value/impact? | Priority scoring |
| What is the estimated effort? | Priority scoring |
| What milestone/theme? | Groups related items |
| Who owns this? | Accountability |
| Any dependencies? | Blocking relationships |

Questions vary by chosen prioritization system.

---

## Output

**Path**: `jaan-to/outputs/pm/roadmap/{id}-{slug}/{id}-roadmap-{slug}.md`

**Contains**:
- Vision statement
- Prioritization system legend
- Roadmap items table (priority, status, owner, target, dependencies)
- Item details (description, success metrics)
- Completed items
- Dependencies map
- Metadata

---

## Prioritization Systems

| System | Best For | Speed |
|--------|----------|-------|
| Value-Effort Matrix | Most teams, brainstorming | Fast |
| MoSCoW | Fixed deadlines, scope control | Fast |
| RICE Scoring | Data-driven orgs, large backlogs | Slower |

---

## Example

**Input**:
```
/jaan-to:pm-roadmap-add "real-time notifications"
```

**Preview at HARD STOP**:
```
Item:         Real-time notifications
Priority:     Quick Win (Value-Effort: High value, Low effort)
Milestone:    Q1 2026
Timeframe:    Now
Owner:        Backend Team
Dependencies: None
Status:       To Do
```

---

## Tips

- Provide enough context in your item description for accurate priority assessment
- Run after `/jaan-to:pm-prd-write` to add PRD-derived items to the roadmap
- Use specific descriptions to avoid false duplicate matches
- Review the codebase context scan results — they inform priority assessment

---

## Learning

This skill reads from:
```
jaan-to/learn/jaan-to-pm-roadmap-add.learn.md
```

Add feedback:
```
/jaan-to:learn-add pm-roadmap-add "Always ask about platform constraints"
```
