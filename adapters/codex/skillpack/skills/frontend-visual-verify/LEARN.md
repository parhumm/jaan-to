# Lessons: frontend-visual-verify

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-frontend-visual-verify.learn.md`

---

## Better Questions

Questions that improve input quality:

- "Is Storybook running on localhost:6006?" — Saves time if server not started
- "What should this component look like?" — Reference description helps scoring
- "Any known visual issues?" — Focuses verification on reported problems
- "Which breakpoints matter most?" — Prioritizes responsive checks

## Edge Cases

Special cases to check:

- **Storybook not running** — Playwright will fail to navigate; detect early and suggest starting it
- **Components behind auth** — Storybook should not require login; if it does, note as configuration issue
- **Dynamic content** — Components with random data or dates may look different each time
- **Animation timing** — Screenshots may catch mid-animation; use browser_wait_for before capture

## Workflow

Process improvements:

- **Always check Playwright availability first** — Determine mode before planning verification
- **Accessibility tree is primary** — browser_snapshot gives structured data; screenshots are supplementary
- **Localhost-only by default** — Never navigate to external URLs without explicit user confirmation
- **static-mode honesty** — Never claim visual pass/fail without Playwright; code analysis alone is insufficient

## Common Mistakes

Pitfalls to avoid:

- Claiming visual pass in static-mode — Cannot verify visuals without Playwright
- Navigating to external URLs without user confirmation — Security policy violation
- Skipping accessibility tree analysis — browser_snapshot is the most valuable tool
- Testing only default state — Must verify loading, error, empty, and variant states
- Capturing screenshots without waiting for render — Use browser_wait_for to ensure content loaded
