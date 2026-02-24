# Lessons: pm-roadmap-add

> Last updated: 2026-02-24

Accumulated lessons from past executions. Read this before adding roadmap items to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during roadmap item addition:

- Ask about dependencies before finalizing priority — blocked items should not be ranked as "Quick Wins"
- Ask if the item relates to existing PRDs or stories — cross-reference improves accuracy
- When bootstrapping a new roadmap, ask about existing planning artifacts (spreadsheets, Jira boards, etc.)

## Edge Cases

Special cases to check and handle:

- Items with >500 character descriptions should be split into smaller items or summarized
- Duplicate detection should handle synonyms (e.g., "auth" matches "authentication", "login")
- When no tech.md exists, skip codebase TODO/FIXME scan gracefully
- Items with circular dependencies (A blocks B, B blocks A) should be flagged

## Workflow

Process improvements learned from past runs:

- Always show the prioritization system legend when bootstrapping a new roadmap
- When appending to an existing roadmap, match the existing format exactly (don't introduce new section styles)
- If the user provides multiple items at once, process each through the full priority assessment

## Common Mistakes

Things to avoid based on past feedback:

- Don't assume all items are features — infrastructure, tech debt, and process items are valid roadmap entries
- Don't skip the duplication check even for items that seem unique — keyword overlap is common
- Don't include raw codebase content (file contents, code snippets) in roadmap output
- Don't default to "Must-Have" in MoSCoW — most items are Should-Have or Could-Have
