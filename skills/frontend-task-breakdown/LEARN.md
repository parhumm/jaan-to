# Lessons: frontend-task-breakdown

> Last updated: 2026-02-03

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:frontend-task-breakdown.learn.md`

Seeded from research: $JAAN_OUTPUTS_DIR/research/51-dev-fe-task-breakdown.md

---

## Better Questions

Questions to ask during information gathering:

- Ask "Is this greenfield or extending existing components?" — reuse changes task count significantly
- Ask about team's component library / design system — avoids recreating existing atoms
- Ask about target browsers early — Safari iOS has unique flexbox/position:fixed issues
- Ask "Which states does the design NOT show?" — catches 50-70% of commonly missed work
- Ask about API readiness — if contracts undefined, add mock strategy tasks

## Edge Cases

Special cases to check and handle:

- Long text (100+ chars): needs CSS truncation with text-overflow: ellipsis + tooltip
- Missing images: always include fallback placeholder component
- Slow network (3G): test with throttling, add timeout handling (30s default)
- Race conditions: concurrent API calls need AbortController cleanup
- Double-click submissions: disable button on click, use idempotency keys
- Safari iOS: 100vh inconsistency (use dvh), date input formatting, position:fixed in scroll containers
- Optimistic updates: must handle rollback on API failure
- Very long lists (1000+ items): evaluate virtualization (react-window/tanstack-virtual)

## Workflow

Process improvements:

- Start with design tokens extraction before component breakdown — unblocks all atom work
- Size tasks as T-shirt sizes (XS/S/M/L/XL) not hours — avoids false precision and estimation anxiety
- Apply the 1 task = 1 PR rule — keeps PRs reviewable and mergeable independently
- Use the "screens x states x breakpoints" coverage matrix to systematically catch gaps
- Generate Mermaid dependency graph early — reveals critical path and parallel tracks for team allocation
- Group related micro-tasks (padding, margin, color) into single S-sized tasks — avoid over-decomposition
- For React 18+: treat each Suspense boundary as a discrete task unit with its own fallback UI

## Common Mistakes

Things to avoid:

- Forgetting loading/error/empty states — the "invisible work" that distinguishes production from prototype
- Over-decomposing atoms: "Add padding to button" should be grouped into "Create Button component with variants"
- Under-decomposing pages: "Build entire checkout flow" hides 20+ tasks — split by user action or screen section
- Missing accessibility tasks: every organism+ needs keyboard navigation + screen reader consideration
- Ignoring performance budgets: no bundle size target = bloated builds discovered too late
- Prescribing solutions in task names: "Use dropdown menu" vs "Enable country selection" — describe the need
- Skipping state machine definitions: boolean flag explosion (isLoading && isError && isRetrying) causes UI glitches
- Not flagging API dependency risks: frontend tasks blocked by undefined API contracts is the #1 integration delay
