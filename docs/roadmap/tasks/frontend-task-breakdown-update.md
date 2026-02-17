---
title: "Frontend Task Breakdown + Shadcn MCP"
sidebar_position: 19
---

# Frontend Task Breakdown + Shadcn MCP

> Phase 6 | Status: pending

## Problem

`/frontend-task-breakdown` generates task breakdowns from UX handoffs but is not aware of component libraries like Shadcn UI. Teams using Shadcn get generic task estimates that don't account for pre-built components, leading to overestimation and redundant custom work. The skill also needs React 19 / Next.js 15 awareness for server/client component decisions.

## Solution

Update `/frontend-task-breakdown` to:
1. Query Shadcn MCP for available components when MCP is configured
2. Match UX handoff elements to existing Shadcn components
3. Adjust effort estimates: "integrate" vs "build from scratch"
4. Add React 19 server/client component awareness to breakdown

### Component Matching Flow

```
UX Handoff Element → Check Shadcn Catalog (MCP) → Match Found?
  ├── Yes → Task: "Integrate <DataTable> from Shadcn" (effort: S)
  └── No  → Task: "Build custom data table component" (effort: L)
```

## Scope

**In-scope:**
- Shadcn MCP integration for component catalog queries
- Component matching logic (UX element → Shadcn component)
- Effort adjustment for pre-built vs custom components
- React 19 server/client component annotations per task
- Graceful fallback when Shadcn MCP not available

**Out-of-scope:**
- Other component library MCPs (Material UI, Ant Design)
- Automatic code generation (that's `/frontend-scaffold`)
- Shadcn component customization guidance

## Implementation Steps

1. Read current `skills/frontend-task-breakdown/SKILL.md`
2. Add Shadcn MCP integration section:
   - Check if Shadcn MCP is available in environment
   - If available: query component catalog (name, variants, props)
   - Build component lookup index for matching
3. Update Component Inventory section:
   - Add "Library Source" column: `shadcn` / `custom` / `native`
   - Add "Integration Effort" vs "Build Effort" distinction
4. Update task naming pattern:
   - Shadcn: `Integrate {Component} from Shadcn for {feature}`
   - Custom: `Build custom {Component} for {feature}`
5. Add React 19 awareness:
   - Annotate each component task: `[server]` or `[client]`
   - Flag components that need `"use client"` directive
   - Note React 19 features: `use()`, form actions, `useOptimistic()`
6. Update estimate bands to reflect library availability
7. Apply updates via `/jaan-to:skill-update frontend-task-breakdown`
8. Validate passes all 7 skill-update checks

## Skills Affected

- `/frontend-task-breakdown` — primary update target
- `/frontend-design` — upstream input (should align on component naming)
- `/frontend-scaffold` — downstream consumer (generates Shadcn-based code)

## Acceptance Criteria

- [ ] Skill queries Shadcn MCP for component catalog (when available)
- [ ] Task breakdown references specific Shadcn components where applicable
- [ ] Estimates adjusted for "integrate" vs "build from scratch"
- [ ] Graceful fallback when Shadcn MCP not available (generic mode)
- [ ] React 19 server/client component awareness in breakdown
- [ ] Updated SKILL.md passes `/jaan-to:skill-update` validation
- [ ] Component Inventory includes "Library Source" column

## Dependencies

- Shadcn MCP availability (optional — skill works without it)
- Benefits from `/frontend-design` update (#129) for consistent component naming

## References

- [#130](https://github.com/parhumm/jaan-to/issues/130)
- Target skill: `skills/frontend-task-breakdown/SKILL.md`
- Reference: `docs/extending/frontend-task-breakdown-reference.md`
- Shadcn UI: https://ui.shadcn.com
