# Lessons: data-gtm-datalayer

> Last updated: 2026-01-27

Accumulated lessons from past executions. Read this before executing to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during information gathering:

- Ask "What user flow is this part of?" to understand context for naming
- Ask "Are there non-happy path interactions?" (close, dismiss, cancel, click-outside)
- When tracking a modal: always ask about both impression AND click events

## Edge Cases

Special cases to check and handle:

- Multiple elements with same feature/item: ensure unique identification via params
- Dynamic content: ask if feature/item values need to be dynamic
- Single-page apps: confirm if tracking fires on route change

## Workflow

Process improvements:

- Always show kebab-case conversion before confirming
- For PRD input: group suggested tracking by user flow/journey
- Offer to generate all related tracking at once (impression + all clicks for a feature)

## Common Mistakes

Things to avoid:

- Never use camelCase or PascalCase in feature/item/action values
- Never include empty `params: {}` - omit the key entirely
- Never invent or modify user-provided semantic meaning (only format conversion)
- Don't assume "Click" action for impressions - impressions have no action field
