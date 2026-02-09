# Lessons: detect-design

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before detecting design systems to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions and patterns that improve detection quality:

- Ask "Is there a dedicated design system package?" when monorepo detected — design tokens may live in a separate package
- Check if Tailwind theme extends or overrides defaults — `extend:` vs root-level in `tailwind.config`
- Ask about dark mode strategy when theme switching patterns detected (CSS variables vs class-based vs media query)

## Edge Cases

Special cases to check and handle:

- **Tailwind projects**: Tokens live in `tailwind.config.*` theme section, not in separate token files. Don't report "no tokens found" — check Tailwind config first
- **Dark mode tokens**: May be defined as separate token sets or CSS variable overrides under `.dark` class or `@media (prefers-color-scheme: dark)`. Scan both
- **Vendor CSS exclusion**: Ignore token-like patterns in `node_modules/`, vendor CSS libraries, and third-party themes
- **CSS-in-JS**: Tokens may be JavaScript objects (styled-components theme, Emotion theme), not CSS variables. Check `ThemeProvider` patterns
- **Utility-first frameworks**: In Tailwind/UnoCSS projects, "drift" means using arbitrary values (`text-[#333]`) instead of theme classes
- **Component library wrappers**: Projects may wrap a UI library (MUI, Chakra, Ant Design) with custom tokens. Detect the base library AND customizations

## Workflow

Process improvements learned from past runs:

- Start with token files — they establish the design vocabulary for the rest of the scan
- Scan Storybook config early — it often reveals the component hierarchy and categorization
- Check for `ThemeProvider` or equivalent to understand the theming strategy before scanning for drift
- Group drift findings by severity: hardcoded brand colors > hardcoded spacing > minor inconsistencies

## Common Mistakes

Things to avoid based on past feedback:

- Don't report third-party component library internals as "the project's design system"
- Don't flag standard CSS resets or normalizations as "drift"
- Don't claim WCAG compliance or failure from repo evidence alone — scope accessibility findings to what's observable in code
- Don't assume absence of Storybook means absence of component documentation — check for other tools (Docusaurus, custom docs)
- Don't report CSS custom properties from third-party libraries as project tokens
