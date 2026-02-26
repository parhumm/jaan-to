# Lessons: frontend-component-fix

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-frontend-component-fix.learn.md`

---

## Better Questions

Questions that improve input quality:

- "Can you describe what you see vs what you expected?" — Differentiates visual from functional bugs
- "Does this happen on all screen sizes or specific breakpoints?" — Narrows responsive issues
- "When did this start happening? After a recent change?" — Helps identify root cause
- "Does the component work in Storybook isolation?" — Distinguishes component vs integration bugs

## Edge Cases

Special cases to check:

- **Multi-file fixes** — A visual bug may trace to a shared utility (cn(), theme config) not the component itself
- **CVA variant bugs** — Issue in one variant often traces to compoundVariants or missing defaultVariants
- **CSS specificity** — Tailwind utility conflicts; check for competing classes
- **Server vs Client** — Component rendering differently on server (SSR) vs client (hydration mismatch)

## Workflow

Process improvements:

- **Always read the full component** — Don't patch based on description alone
- **Minimal patch** — Change only what's needed to fix the bug; resist refactoring urges
- **Preserve API** — Never change props interface in a fix; that's a breaking change
- **Offer guided mode** — Most users want Integrate+Verify, not manual patch application

## Common Mistakes

Pitfalls to avoid:

- Writing patches directly to src/ — This skill is OUTPUT-ONLY; always write to $JAAN_OUTPUTS_DIR
- Over-fixing — Changing unrelated code alongside the actual fix
- Missing the integration readme — Without it, dev-output-integrate cannot map files
- Skipping before/after diff — Users need to understand what changed and why
- Assuming the bug is in the component — It might be in the parent, the CSS layer, or the data
