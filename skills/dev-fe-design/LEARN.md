# Lessons: dev-fe-design

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:dev-fe-design.learn.md`

---

## Better Questions

Questions that improve input quality:

- "What emotion should this component evoke?" — Helps determine tone beyond just "bold" or "minimal"
- "Who is the target audience?" — Business users vs consumers affects design choices
- "What's the one thing users should remember about this component?" — Forces clarity on differentiation
- "Are there any brand guidelines or existing design patterns I should follow?" — Prevents conflicts

## Edge Cases

Special cases to check:

- **Framework version mismatches** — React 18 vs 17 have different APIs (e.g., ReactDOM.render vs createRoot)
- **TypeScript vs JavaScript** — Check project setup before generating typed code
- **Existing component conflicts** — Always check for similar components before creating
- **Dark mode without design tokens** — Fallback to media query if no CSS custom properties

## Workflow

Process improvements:

- **Show design system first** — If design.md exists, present patterns BEFORE asking questions
- **Preview always default** — Component + Preview scope gives best user experience
- **Code file extension** — Match project: .jsx vs .js vs .tsx based on tech.md
- **Mobile-first breakpoints** — Always start with mobile, scale up (not desktop-down)

## Common Mistakes

Pitfalls to avoid:

- ✗ Generating Inter or Roboto fonts without user asking — These are overused generic fonts
- ✗ Using `outline: none` without visible focus replacement — Accessibility violation
- ✗ Hardcoding colors instead of CSS custom properties — Makes theming impossible
- ✗ Assuming React when tech.md says Vue — Always check framework first
- ✗ Creating components without semantic HTML — Use proper elements (button, nav, article, etc.)
- ✗ Skipping Executive Summary in documentation — Required for all outputs
- ✗ Using px units for everything — Use rem/em for typography, clamp() for fluidity
- ✗ Adding animations without prefers-reduced-motion check — Accessibility issue
