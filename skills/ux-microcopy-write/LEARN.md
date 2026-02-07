# Lessons: ux-microcopy-write

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:ux-microcopy-write.learn.md`

## Better Questions

- Ask about formality preference per language (شما vs تو for Persian, Sie vs du for German)
- Check if user needs ICU MessageFormat for pluralization (especially Russian)
- Confirm character limits for UI constraints (button labels, toasts, etc.)
- Ask if user has existing brand voice guidelines document
- Clarify if microcopy needs to work with screen readers (ARIA labels)

## Edge Cases

- Persian ZWNJ handling: Auto-add for plurals (-hā) and compound words
- Russian 3-form pluralization: Use ICU MessageFormat for counts (=0, =1, few, many, other)
- Mixed LTR/RTL content: Ensure proper bidirectional text handling in JSON metadata
- Text expansion: Warn if German/Turkish text exceeds UI space (35% longer than English)
- Empty state microcopy: Headline + motivation + CTA (3-part structure required)
- Modal confirmations: Always include consequence of action ("This cannot be undone")
- Numeric values in Persian: Western numerals (0-9) preferred for digital UI despite cultural alternatives

## Workflow

- Generate English baseline first, then translate (ensures consistency across languages)
- Show character counts alongside each language (UI constraint awareness)
- For Persian: Auto-validate ZWNJ, punctuation (؟ ، ؛), and numeral consistency
- Options iteration: Offer "My own" option in every round (not just after 5 rounds)
- Preview complete output with ID and folder structure before writing
- Update subdomain index after writing files

## Common Mistakes

- Literal translations without cultural adaptation (e.g., direct word-for-word translation)
- Inconsistent formality within a language (mixing شما and تو in same UI)
- Forgetting recovery instructions in error messages (what + how to fix)
- Not marking RTL languages in JSON output metadata (direction field)
- Using Western numerals in Persian without noting it's pragmatic choice over ۰۱۲
- Overapologizing in Russian (tone should be factual, solution-focused, not "Sorry!")
- Forgetting ZWNJ character in Persian compound words and plurals
- Not accounting for text expansion in German/Turkish when setting character limits
