---
title: "Frontend PR Review Skill"
sidebar_position: 15
---

# Frontend PR Review Skill

> Phase 6 | Status: pending

## Problem

`/backend-pr-review` exists for backend code and `/wp-pr-review` for WordPress, but there is no dedicated frontend PR review skill. Frontend PRs have unique concerns — React patterns, Next.js conventions, bundle size, accessibility, component composition — that generic backend review misses. This leaves a gap in the PR review skill family.

## Solution

Create `/frontend-pr-review` following the same architecture as `/backend-pr-review` but with frontend-specific review categories. Use `gh pr diff` (or `glab mr diff` for GitLab) to fetch changes, then analyze against frontend-specific patterns.

### Review Categories

| Category | Focus |
|----------|-------|
| React Patterns | Hook rules, component composition, state management, effect dependencies |
| Next.js Conventions | App Router vs Pages, server/client components, metadata, caching |
| Performance | Bundle impact, lazy loading, image optimization, unnecessary re-renders |
| Accessibility | ARIA attributes, keyboard navigation, focus management, semantic HTML |
| TypeScript | Type safety, generic patterns, discriminated unions |
| Testing | Component test coverage, interaction tests, snapshot hygiene |
| Styling | TailwindCSS v4 patterns, CSS variable usage, responsive design |

## Scope

**In-scope:**
- PR diff analysis via `gh pr diff` / `glab mr diff`
- Findings with severity levels (critical/warning/suggestion)
- React 19 + Next.js 15 awareness
- TailwindCSS v4 pattern checks
- Risk score per file (same pattern as backend-pr-review)

**Out-of-scope:**
- Running tests or builds (that's `/qa-test-run`)
- Automated code fixes (review only)
- Vue/Angular/Svelte support (React/Next.js focus first)

## Implementation Steps

1. Create skill via `/jaan-to:skill-create frontend-pr-review`
2. Mirror `/backend-pr-review` SKILL.md structure:
   - Same two-phase workflow (analysis → HARD STOP → output + optional PR comment)
   - Same argument hint: `<pr-url | owner/repo#number | local>`
   - Same severity system: CRITICAL / WARNING / INFO
3. Add reference files for frontend patterns:
   - `references/react-patterns.md` — Hook rules, composition patterns
   - `references/nextjs-patterns.md` — App Router, server components
   - `references/a11y-patterns.md` — WCAG 2.2 checklist
   - `references/performance-patterns.md` — Core Web Vitals thresholds
4. Implement finding generators for each review category
5. Add Risk Score table (same weighted scoring as backend-pr-review)
6. Output at `$JAAN_OUTPUTS_DIR/frontend/pr-review/{NEXT_ID}-{slug}/`

## Skills Affected

- `/backend-pr-review` — sibling skill; share common review infrastructure
- `/wp-pr-review` — sibling skill; completes the PR review family
- `/frontend-task-breakdown` — upstream context for expected implementation
- `/detect-dev` — complementary codebase-level analysis

## Acceptance Criteria

- [ ] Skill reviews PR diff via `gh pr diff` (same pattern as `backend-pr-review`)
- [ ] Generates findings with severity levels (critical/warning/suggestion)
- [ ] React 19 + Next.js 15 awareness
- [ ] TailwindCSS v4 pattern checks
- [ ] Follows v3.0.0 skill patterns (`$JAAN_*` environment variables)
- [ ] Output at `$JAAN_OUTPUTS_DIR/frontend/pr-review/{pr-number}/`
- [ ] Two-phase workflow with HARD STOP gate
- [ ] Optional PR comment posting (same as backend-pr-review)

## Dependencies

- None (standalone new skill)
- Optionally benefits from `/frontend-design` update (#129) for current best practices

## References

- [#125](https://github.com/parhumm/jaan-to/issues/125)
- Sibling skill: `skills/backend-pr-review/SKILL.md`
- Sibling skill: `skills/wp-pr-review/SKILL.md`
