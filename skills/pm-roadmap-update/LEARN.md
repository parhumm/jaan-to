# Lessons: pm-roadmap-update

> Last updated: 2026-02-24

Accumulated lessons from past executions. Read this before updating roadmaps to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during roadmap updates:

- When marking items done, ask if subtasks or related items should also be updated
- Before reprioritizing, ask if the user's strategic direction has changed
- When reviewing, ask about any external factors not visible in the codebase (market changes, team changes)

## Edge Cases

Special cases to check and handle:

- Items may reference PRDs or stories that have been deleted — handle missing cross-references gracefully
- Roadmap may use a prioritization system not in the standard set — detect and preserve custom systems
- Multiple items may share the same dependency — updating one blocker affects several items
- Items with "Won't-Have" (MoSCoW) status should not appear in staleness checks
- Empty roadmaps (all items completed) should suggest archiving and starting a new roadmap

## Workflow

Process improvements learned from past runs:

- Always read the full roadmap before making any changes — context matters
- When marking items done, update the metadata summary counts at the bottom of the file
- In reprioritize mode, present changes sorted by magnitude of change (biggest shifts first)
- In validate mode, group issues by severity (High first) for easier triage
- After review mode, offer to run pm-roadmap-add if missing items were found

## Common Mistakes

Things to avoid based on past feedback:

- Don't change prioritization system during reprioritize — only change scores/categories within the existing system
- Don't remove items without explicit approval — mark as "Won't Do" or "Deprecated" instead
- Don't rewrite item descriptions during review — only update status and metadata fields
- Don't assume "In Progress" items are stale just because they have no PRD — some items are tracked externally
- Don't mix roadmap update with roadmap creation — if no roadmap exists, direct to pm-roadmap-add
