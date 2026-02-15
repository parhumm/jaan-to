# Lessons: jaan-issue-solve

> Last updated: 2026-02-12

---

## Better Questions
- Ask which version to target before scanning — don't assume latest
- Confirm scope: "Post comments on all {N} closed issues?" before proceeding
- If an issue was referenced in multiple versions, ask which version to credit

## Edge Cases
- Issues referenced in multiple changelog versions — credit the version that actually fixed it
- Issues closed but not referenced in any changelog entry — skip with note
- PRs referenced as #XX may be confused with issues — verify type via `gh issue view`
- Issues with existing resolution comments from manual posting — detect and skip (idempotent)
- Changelog entries that reference issues with `Closes #XX` vs `(#XX)` vs `[#XX]` — handle all patterns

## Workflow
- Always preview all comments before posting (HARD STOP is mandatory)
- Check for duplicate comments first — search existing comments for version string
- Parse changelog section carefully: stop at next `## [` header or `---` separator
- Use `gh issue view --json comments` to check existing comments for idempotency

## Common Mistakes
- Posting on open issues — always verify state is "closed"
- Generic comments that say "this was fixed" without explaining how
- Forgetting commit references when the changelog includes them
- Missing issue references because of inconsistent formatting (#XX vs [#XX](url))
- Not handling the case where `gh auth status` fails
