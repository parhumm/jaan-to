# Lessons: pm-prd-write

> Last updated: 2026-02-18

Accumulated lessons from past executions. Read this before generating PRDs to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions that should be asked during information gathering:

- Ask about API versioning strategy for backend features
- Ask "who else needs to approve this?" early in the process
- Clarify rollback/rollback strategy for risky changes
- Ask about existing tracking/analytics system during info gathering - needed for actionable success metrics
- Ask "Is this a gap analysis or audit-based initiative?" — triggers alternate document flow with requirements overview, methodology, and per-entity status matrices
- Ask about output language early — RTL languages need `dir="rtl"` wrapper and native vocabulary

## Edge Cases

Special cases to check and handle:

- Multi-tenant features need tenant isolation section
- API changes need versioning strategy section
- User-facing features need accessibility considerations
- Data migrations need rollback plan
- When items are partially implemented across multiple entities (e.g., gateways, regions), don't list them as "existing" — use per-entity status matrix with checkmark/cross
- RTL languages (Persian, Arabic, Hebrew) need `<div dir="rtl">` wrapper, native vocabulary preference, and correct orthography (hamze, kasre-ye ezafe)

## Workflow

Process improvements learned from past runs:

- Generate metrics in table format for easy stakeholder review
- Include "Dependencies" section when feature touches multiple teams
- Add "Rollback Plan" for any feature with data changes
- Use bullet points for prose sections (Problem Statement, Executive Summary, Solution Overview) — paragraphs reduce scannability
- Limit tables to 4 columns max — wider tables overflow on normal screens
- For gap-analysis PRDs: use requirements-first flow (Requirements Overview → Methodology → Current State Matrix → Gap Prioritization)

## Common Mistakes

Things to avoid based on past feedback:

- Don't assume single-region deployment without asking
- Don't skip "Out of Scope" section - it prevents scope creep
- Don't use technical jargon in Problem Statement - keep it user-focused
- Don't generate dense paragraphs for descriptive sections — always use bullet points
- Don't list partially-implemented items as "existing" without per-entity breakdown
- Don't use English loanwords in RTL output when native equivalents exist
- Don't create tables with more than 4 columns — restructure or split instead
