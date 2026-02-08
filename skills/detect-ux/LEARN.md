# Lessons: detect-ux

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before auditing UX to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions and patterns that improve detection quality:

- Ask "Is this a web app, mobile app, or API-only service?" — UX audit scope differs dramatically
- Check if the project uses a component library (MUI, Chakra, Ant) — many heuristic signals come from library defaults, not project decisions
- Ask about primary user type when multiple personas are inferred

## Edge Cases

Special cases to check and handle:

- **SPA routing**: Single-page apps may have client-side routing only. Don't scan server routes for user flows — check the router configuration instead
- **API-only backends**: Express/Fastify/NestJS backends without frontend have no traditional UX. Scope audit to API developer experience (DX): documentation, error responses, consistency
- **Component library defaults**: Don't credit the project for a11y features that come from the UI library (e.g., MUI's built-in ARIA). Note the dependency but distinguish project-added vs library-provided
- **Storybook as documentation**: Storybook stories are component documentation, not user flows. Don't include them in flow mapping
- **Feature flags hiding routes**: Some routes may be behind feature flags and not visible in normal navigation. Note as "potential additional flows" with Uncertain confidence
- **Server-side rendering**: Next.js/Nuxt pages may have server components that don't show loading states — this is intentional SSR, not a missing loading state

## Workflow

Process improvements learned from past runs:

- Start with route mapping — it defines the entire audit scope
- Detect the framework first to use the right route extraction patterns
- Map flows BEFORE assessing heuristics — you need the flow context to evaluate heuristics meaningfully
- Keep Nielsen assessments evidence-based — "Unknown" is better than speculation

## Common Mistakes

Things to avoid based on past feedback:

- Don't present inferred personas as validated research — always label as "inferred from code structure"
- Don't flag library-provided accessibility as project achievements
- Don't assume missing keyboard shortcuts = poor flexibility — assess in context of the application type
- Don't count API endpoints as "screens" for user flow mapping
- Don't make claims about visual aesthetics from code alone — component complexity is a proxy, not proof
- Don't mark server-rendered pages as "missing loading states"
