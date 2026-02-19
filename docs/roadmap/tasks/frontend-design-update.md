---
title: "Frontend Design Skill Update"
sidebar_position: 18
---

# Frontend Design Skill Update

> Phase 6 | Status: pending

## Problem

`/frontend-design` was built during Phase 5. The UX/frontend landscape has evolved — new design system patterns (Shadcn UI, Radix Primitives), updated React 19 / Next.js 15 conventions, WCAG 2.2 standards, and TailwindCSS v4 need to be reflected. A full audit of this skill and related UX skills is overdue.

## Solution

Audit and update `/frontend-design` via `/jaan-to:skill-update frontend-design`. Cross-review 4 related UX skills for consistency. Apply current best practices for design systems, accessibility, and component patterns.

### Audit Areas

| Area | Current State | Target State |
|------|--------------|--------------|
| Design system | Generic component patterns | Shadcn/Radix-aware, design token support |
| Accessibility | WCAG 2.1 references | WCAG 2.2 (focus-not-obscured, dragging, target size) |
| React patterns | Class + hooks mixed | React 19 (use, actions, compiler) |
| Next.js | Pages Router references | App Router, Server Components, Partial Prerendering |
| Styling | TailwindCSS v3 | TailwindCSS v4 (CSS-first config, `@theme`) |
| Theming | Basic dark mode | CSS custom properties, `prefers-color-scheme`, forced-colors |
| Animation | None | View Transitions API, CSS scroll-driven animations |

## Scope

**In-scope:**
- Full audit of `/frontend-design` SKILL.md
- Cross-review of `/ux-flowchart-generate`, `/ux-microcopy-write`, `/ux-research-synthesize`, `/ux-heatmap-analyze`
- Update SKILL.md via `/jaan-to:skill-update`
- Update reference files in `skills/frontend-design/references/`

**Out-of-scope:**
- Creating new UX skills
- Changing output format or path structure
- Vue/Angular/Svelte support

## Implementation Steps

1. Read current `skills/frontend-design/SKILL.md` (target skill)
2. Audit against review criteria:
   - Design system integration (Shadcn, Radix, custom)
   - Accessibility standards (WCAG 2.2 new criteria)
   - Responsive/mobile-first patterns
   - Dark mode / theming support
   - Animation and micro-interaction guidance
   - Component composition patterns (compound components, render props)
   - Design token usage (CSS custom properties)
3. Cross-review 4 UX sibling skills for consistency:
   - `/ux-flowchart-generate` — verify design terminology alignment
   - `/ux-microcopy-write` — verify accessibility language patterns
   - `/ux-research-synthesize` — verify design system references
   - `/ux-heatmap-analyze` — verify UX metrics alignment
4. Apply updates via `/jaan-to:skill-update frontend-design`
5. Update reference files for current standards
6. Validate updated skill passes all 7 skill-update checks

## Skills Affected

- `/frontend-design` — primary update target
- `/ux-flowchart-generate` — cross-review for consistency
- `/ux-microcopy-write` — cross-review for consistency
- `/ux-research-synthesize` — cross-review for consistency
- `/ux-heatmap-analyze` — cross-review for consistency
- `/frontend-scaffold` — downstream consumer; may need alignment

## Acceptance Criteria

- [ ] Full audit of `/frontend-design` SKILL.md completed
- [ ] Cross-review of all 4 UX skills for consistency
- [ ] Updated SKILL.md passes `/jaan-to:skill-update` validation (7 checks)
- [ ] Design system references updated to current standards (Shadcn, Radix)
- [ ] Accessibility checklist reflects WCAG 2.2
- [ ] React 19 + Next.js 15 patterns documented
- [ ] TailwindCSS v4 patterns included

## Dependencies

- None (updates existing shipped skill)

## References

- [#129](https://github.com/parhumm/jaan-to/issues/129)
- Target skill: `skills/frontend-design/SKILL.md`
- UX skills: `skills/ux-flowchart-generate/`, `skills/ux-microcopy-write/`, `skills/ux-research-synthesize/`, `skills/ux-heatmap-analyze/`
