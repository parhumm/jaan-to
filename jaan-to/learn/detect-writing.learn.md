# Lessons: detect-writing

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before detecting writing systems to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions and patterns that improve detection quality:

- Ask "Is there a content style guide or writing guidelines document?" — it may not be in code
- Check if the project distinguishes between developer-facing and user-facing content
- Ask about target audience reading level if error messages seem unusually technical
- Confirm localization priorities when multiple locales are detected but unevenly covered

## Edge Cases

Special cases to check and handle:

- **i18n library installed but unused**: Check actual externalization ratio, not just dependency presence. Library in package.json with <5% strings externalized = Level 1 at best
- **Component-level vs centralized strings**: Some projects use co-located i18n files (e.g., `Component/i18n.json` alongside `Component.tsx`). This is NOT "scattered" — it's a valid architectural pattern
- **Formal tone in legal copy**: Legal, privacy, and terms pages intentionally use formal language. Don't flag these as "inconsistent" with casual app tone — separate them as a distinct category
- **Generated strings**: Ignore auto-generated i18n keys or machine-translated strings when scoring tone consistency
- **Markdown in strings**: Some i18n strings contain markdown formatting. Don't count markdown syntax in readability scoring
- **Pluralization complexity**: Languages like Arabic have 6 plural forms. Don't penalize projects that only handle `one`/`other` — mark as maturity signal, not defect

## Workflow

Process improvements learned from past runs:

- Start with i18n file discovery — it reveals the string corpus scope and localization strategy
- Detect the i18n framework first (react-i18next, vue-i18n, etc.) to know which glob patterns to prioritize
- Score tone dimensions per-category first (buttons, errors, etc.), then aggregate — per-category scores are more actionable
- Build the glossary last — it benefits from having already classified strings into categories

## Common Mistakes

Things to avoid based on past feedback:

- Don't count marketing/landing page copy in the main tone analysis — it has intentionally different voice
- Don't flag "OK" or "Cancel" buttons as "generic" — these are standard platform conventions
- Don't assume single-locale projects have "no i18n" — they may have full externalization for future localization
- Don't score readability on strings < 5 words — Flesch-Kincaid is unreliable for very short text
- Don't present NNg dimension scores as absolute truth — label them as heuristic-derived, confidence Tentative
