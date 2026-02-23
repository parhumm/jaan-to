# Lessons: backend-pr-review

> Last updated: 2026-02-15

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-backend-pr-review.learn.md`

Seeded from research: `docs/research/53-dev-pr-review.md`

---

## Better Questions

Questions to ask during information gathering:

- Ask about the project's backend framework version before reviewing -- older versions have different security patterns and deprecated APIs
- Ask if the project uses an ORM or raw queries -- determines which SQL injection patterns to prioritize
- Ask about authentication middleware (Sanctum, Passport, JWT, session) -- affects auth bypass detection patterns
- Ask if there are custom linter rules or CI checks already catching style issues -- avoids duplicate noise

## Edge Cases

Special cases to check and handle:

- GitLab MR refspec `refs/merge-requests/{iid}/head` may fail if MR doesn't exist or SSH key isn't configured -- provide clear error messages and fall back to curl API
- Diff position mapping for inline comments requires `base_sha`, `head_sha`, `start_sha` from MR metadata -- git-based fallback cannot provide these (post summary comments only)
- `gh pr diff` returns HTTP 406 for PRs with 300+ changed files -- fall back to paginated file list API
- ECONNRESET during large PR analysis -- batch file processing (30 files per batch) to reduce per-call context size
- Self-hosted GitLab instances may lack `glab` CLI -- fall back to curl with `GITLAB_PRIVATE_TOKEN`
- Multi-language repos may have backend files mixed with frontend -- filter strictly by detected stack extensions

## Workflow

Process improvements:

- Run deterministic grep FIRST (Step 3) before LLM analysis -- catches dangerous patterns with near-zero false negatives
- Focus review ONLY on changed files in the PR diff -- never flag legacy code outside the diff
- Variable confidence thresholds by severity prevent over-filtering critical findings while keeping noise low for info-level items
- Comment deduplication via `<!-- jaan-to:backend-pr-review -->` marker prevents duplicate comments on PR re-pushes
- For PRs >500 lines, warn about 70% defect detection drop and recommend splitting
- Two-pass analysis reduces false positives by 40-60% compared to single-pass

## Common Mistakes

Things to avoid:

- Never flag code outside the diff -- only review changed lines to avoid re-litigating stable code
- Skip vendored/generated files (`vendor/`, `node_modules/`, `dist/`, `*.lock`) -- review project-owned code only
- Don't assume what other parts of the codebase might do -- only report issues visible in the provided diff (grounding principle)
- Avoid "wall of comments" -- cap at 20 findings per review, prioritize by severity
- Don't report formatting issues already caught by linters (indentation, spacing, brace style) -- these create noise
- Don't use generic security advice -- use framework-specific functions and patterns for the detected stack
- Don't flag test fixture data (fake API keys, example tokens) as hardcoded secrets
