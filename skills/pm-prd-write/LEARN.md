# Lessons: pm:prd-write

> Last updated: 2026-01-26

Accumulated lessons from past executions. Read this before generating PRDs to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions that should be asked during information gathering:

- Ask about API versioning strategy for backend features
- Ask "who else needs to approve this?" early in the process
- Clarify rollback/rollback strategy for risky changes
- Ask about existing tracking/analytics system during info gathering - needed for actionable success metrics

## Edge Cases

Special cases to check and handle:

- Multi-tenant features need tenant isolation section
- API changes need versioning strategy section
- User-facing features need accessibility considerations
- Data migrations need rollback plan

## Workflow

Process improvements learned from past runs:

- Generate metrics in table format for easy stakeholder review
- Include "Dependencies" section when feature touches multiple teams
- Add "Rollback Plan" for any feature with data changes

## Common Mistakes

Things to avoid based on past feedback:

- Don't assume single-region deployment without asking
- Don't skip "Out of Scope" section - it prevents scope creep
- Don't use technical jargon in Problem Statement - keep it user-focused
