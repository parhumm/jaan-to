---
title: "Task Documentation"
sidebar_position: 1
---

# Task Documentation Standards

> Guidelines for detailed task documents in `docs/roadmap/tasks/`

## When to Create a Task Doc

Create a separate task doc when:
- Task has multiple acceptance criteria
- Task requires detailed specifications
- Task has dependencies on other work
- Task needs implementation notes

## File Naming

```
tasks/{phase}-{slug}.md
```

Examples:
- `tasks/mcp-connectors.md`
- `tasks/learning-system.md`
- `tasks/plugin-packaging.md`

## Template

```markdown
# {Task Title}

> Phase {n} | Status: pending/in-progress/done

## Description
{What needs to be done and why}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}

## Dependencies
- {dependency or "None"}

## Implementation Notes
{Technical details, approaches, considerations}

## References
- {Links to relevant docs, issues, or commits}
```

## Status Values

| Status | Meaning |
|--------|---------|
| pending | Not started |
| in-progress | Currently being worked on |
| done | Completed |
| blocked | Waiting on dependency |

## Linking from Roadmap

Reference task docs in the main roadmap:
```markdown
- [ ] Task title → [details](tasks/task-slug.md)
```
