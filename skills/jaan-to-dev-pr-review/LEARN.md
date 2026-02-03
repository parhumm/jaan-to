# Lessons: jaan-to-dev-pr-review

> Last updated: 2026-02-03

Accumulated lessons from PR review research and past executions.

---

## Better Questions

- Ask about review focus when PR has >20 files (full review wastes time on low-risk files)
- Ask if draft MR should get full or limited review
- Confirm tech stack before applying security patterns (don't assume PHP or TypeScript)
- Ask about test conventions if non-standard paths detected (not all projects use `__tests__/`)
- Ask about custom security rules if the project has specific compliance requirements

## Edge Cases

- PRs >400 LOC: defect detection drops 70% — recommend splitting
- Deletion-only PRs: check for removed validation, auth checks, or error handling
- Renamed files: track renames to avoid treating as delete+add (inflates change count)
- Binary files: log but don't content-review
- Generated files (`*.lock`, `*.min.js`, `dist/*`): skip content, check version consistency only
- Draft/WIP MRs: limited review — secrets scan, syntax check, and blocking issues only
- Monorepo PRs: changes may span multiple packages with different tech stacks
- Migration files: always flag as high-risk regardless of change size
- `.env` file changes: always flag as critical (should not be committed)

## Workflow

- Score and sort files by risk BEFORE detailed analysis — saves tokens on low-risk files
- Read `tech.md` first to know which security patterns apply
- Group findings by severity, show blocking items first
- For large diffs: chunk at function/class boundaries, not arbitrary lines
- Always validate line numbers against actual diff before outputting
- Present executive summary before full review — let user choose depth
- Cap inline comments at 20 per review (more becomes noise)
- Use Conventional Comments format consistently for machine-parsable output

## Common Mistakes

- Don't hallucinate line numbers — cross-check every reference against the actual diff
- Don't flag test data as real secrets (check file path for test/fixture/mock directories)
- Don't mark style issues as blocking — use `nitpick:` label
- Don't apply PHP patterns to TypeScript files or vice versa
- Don't report N+1 queries without seeing the actual loop pattern with relationship access
- Don't flag `dangerouslySetInnerHTML` if `DOMPurify.sanitize` wraps the content
- Don't flag `$guarded = []` in test factories — only flag in actual Model files
- Don't flag `@ts-ignore` if it has a descriptive comment explaining why
- Don't count lockfile changes toward the 400-line PR size threshold
- Don't present uncertain findings with high confidence — use appropriate severity levels
