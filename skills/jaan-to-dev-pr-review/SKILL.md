---
name: jaan-to-dev-pr-review
description: |
  Review a PR/MR and generate a structured review pack with risk scoring,
  security and performance hints, missing tests, and CI failure correlation.
  Auto-triggers on: review PR, review MR, code review, pr review, merge request review
  Maps to: dev:pr-review
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git diff:*), Bash(git show:*), Bash(git branch:*), Write($JAAN_OUTPUTS_DIR/dev/**), Task, AskUserQuestion
argument-hint: [pr-link-or-branch]
---

# dev:pr-review

> Automated PR review pack: risk scoring, security/perf hints, missing tests, CI failures.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack (determines which security patterns to apply)
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_LEARN_DIR/jaan-to-dev-pr-review.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to-dev-pr-review.template.md` - Review pack template

## Input

**PR/MR Reference**: $ARGUMENTS

Accepts:
- GitLab MR URL: `https://gitlab.com/org/repo/-/merge_requests/42`
- GitHub PR URL: `https://github.com/org/repo/pull/42`
- Branch name: `feature/user-auth`
- Commit range: `main...feature/user-auth`

If no argument provided, ask: "Which PR/MR or branch should I review?"

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to-dev-pr-review.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

Also read tech context:
- `$JAAN_CONTEXT_DIR/tech.md` — Needed to determine which security patterns to apply (PHP, TypeScript, or both)

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Risk scoring calculations and file prioritization
- Security pattern matching with false positive filtering
- Cross-file impact analysis
- Confidence assessment of findings

## Step 1: Parse Input & Determine Source

Parse $ARGUMENTS to determine the diff source:

| Input Pattern | Platform | Action |
|---------------|----------|--------|
| `gitlab.com/.../merge_requests/{iid}` | GitLab | Extract project + MR IID |
| `github.com/.../pull/{number}` | GitHub | Extract owner/repo + PR number |
| Branch name (no URL) | Local | Validate with `git branch -a` |
| Commit range (`A...B`) | Local | Use directly |

**Decision tree for diff retrieval:**

1. **GitLab URL + GitLab MCP available** → Use MCP to get diff, MR metadata, pipeline status
2. **GitHub URL + GitHub MCP available** → Use MCP to get diff, PR metadata, check runs
3. **Branch name** → Use `git diff main...{branch}` (detect default branch first)
4. **MCP not available for URL** → Ask user: "MCP not configured. Provide branch name for local diff?"

## Step 2: Retrieve Diff

**Via GitLab MCP** (preferred for GitLab URLs):
- Get MR metadata (title, description, author, draft status)
- Get MR diffs (file changes with hunks)
- Get pipeline status

**Via GitHub MCP** (preferred for GitHub URLs):
- Get PR metadata (title, body, author, draft status)
- Get PR files with patches
- Get check runs status

**Via git** (fallback):
```
git diff main...{branch} --stat
git diff main...{branch}
git log main...{branch} --oneline --format="%h %s (%an)"
```

**Parse diff into structured format:**
For each changed file, record:
- `path`: file path
- `status`: added | modified | deleted | renamed
- `old_path`: (for renames only)
- `language`: detected from extension
- `additions`: line count
- `deletions`: line count
- `hunks`: array of change blocks with line numbers

## Step 3: Triage & Skip

### Files to skip entirely

| Pattern | Reason |
|---------|--------|
| `*.lock`, `package-lock.json`, `composer.lock`, `yarn.lock` | Generated lockfiles |
| `*.min.js`, `*.min.css` | Minified assets |
| `dist/*`, `build/*`, `.next/*` | Build outputs |
| `vendor/*`, `node_modules/*` | Dependencies |
| Binary files (images, fonts, PDFs) | Cannot content-review |

Log skipped files in a "Skipped Files" footnote.

### Large PR warning

If total additions + deletions > 400 lines:

> "This PR has {N} changed lines. Research shows defect detection drops 70% beyond 400 lines. Consider splitting for more effective review."

### Draft/WIP detection

If MR title starts with `[WIP]`, `WIP:`, `Draft:`, or MR is marked as draft:

> "Draft MR detected. Applying limited review: secrets scan, syntax check, and blocking issues only."

Set `review_mode = "limited"` — skip performance hints and suggestions sections.

## Step 4: Risk Score Files

For each non-skipped file, calculate a weighted risk score (0-10):

### Criticality Score (weight: 40%)

| Pattern | Score | Rationale |
|---------|-------|-----------|
| `auth/*`, `**/security/*`, `*credential*`, `*.env*` | 10 | Authentication & secrets |
| `**/api/*`, `**/payment/*`, `*migration*`, `*.sql` | 8 | Data integrity & APIs |
| `*config*`, `Dockerfile`, `*.yaml`, `*.yml` | 5 | Infrastructure |
| `**/middleware/*`, `**/policy/*`, `**/gate/*` | 8 | Authorization |
| `*.md`, `**/docs/*` | 2 | Documentation |
| `*.test.*`, `*.spec.*` | 2 | Tests |

### Change Size Score (weight: 30%)

| Lines Changed | Score |
|---------------|-------|
| 1-10 | 2 |
| 11-50 | 4 |
| 51-100 | 6 |
| 101-200 | 8 |
| 200+ | 10 |

### Historical Defects Score (weight: 20%)

Run: `git log --oneline --grep="fix\|bug\|hotfix" -- {file} | wc -l`

| Bug-fix Commits | Score |
|-----------------|-------|
| 0 | 1 |
| 1-2 | 4 |
| 3-5 | 7 |
| 6+ | 10 |

### Author Experience Score (weight: 10%)

Optional — skip if author info not available from MCP.
Based on number of prior commits to this file by the MR author.

### Final Score

```
total = (criticality * 0.4) + (change_size * 0.3) + (historical * 0.2) + (author * 0.1)
```

**Sort files by total risk score descending.** Review high-risk files first.

## Step 5: Security Pattern Detection

Read `$JAAN_CONTEXT_DIR/tech.md` to determine which language patterns to apply.

### PHP/Laravel Patterns (apply when PHP detected in tech stack)

| Pattern | Detection | Severity |
|---------|-----------|----------|
| SQL Injection | `whereRaw\s*\(\s*['"][^'"]*\$(?!.*\?)` or `DB::raw` with `$request` | Critical |
| Mass Assignment | `\$guarded\s*=\s*\[\s*\]` (exclude test factories) | Critical |
| XSS (Blade) | `\{!!\s*\$.*!!\}` | Critical |
| Command Injection | `(exec\|shell_exec\|system\|passthru)\s*\(\s*[^)]*\$` | Critical |
| Missing Auth | Controller methods without `$this->authorize()` or middleware | Warning |
| N+1 Queries | Relationship access in foreach without `::with()` | Warning |

### TypeScript/React Patterns (apply when TypeScript/React detected)

| Pattern | Detection | Severity |
|---------|-----------|----------|
| XSS | `dangerouslySetInnerHTML` without `DOMPurify.sanitize` | Critical |
| useEffect deps | Empty dependency array `[]` with referenced variables | Warning |
| Memory leaks | `setState` in useEffect without cleanup/AbortController | Warning |
| Type bypasses | `as any`, `@ts-ignore`, `@ts-nocheck` | Info |
| localStorage secrets | `localStorage.setItem` with auth/token/secret in key | Warning |

### Universal Patterns (always apply)

**Secrets Detection** (high-confidence regex from research):

| Secret Type | Pattern |
|-------------|---------|
| AWS Access Key | `(A3T[A-Z0-9]\|AKIA\|AGPA\|AIDA\|AROA\|AIPA\|ANPA\|ANVA\|ASIA)[A-Z0-9]{16}` |
| JWT Token | `eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*` |
| Generic API Key | `(api\|app\|auth\|access)[-_]?(key\|token\|secret)\s*[=:]\s*['"][a-zA-Z0-9_\-]{16,}['"]` |
| GitHub Token | `ghp_[0-9a-zA-Z]{36}` |
| GitLab Token | `glpat-[0-9a-zA-Z_\-]{20}` |
| Stripe Secret | `sk_(test\|live)_[A-Za-z0-9]{24,}` |

**False positive filters:**
- Exclude files in `test/`, `tests/`, `__tests__/`, `spec/`, `fixtures/`, `mock/`
- Exclude keys containing `test`, `fake`, `example`, `dummy`, `placeholder`
- Exclude UUIDs (common false positive)

**Other universal checks:**
- `.env` file changes (should never be committed)
- Hardcoded IP addresses or URLs pointing to internal services
- `TODO` or `FIXME` in new code (flag as nitpick)

## Step 6: Test Coverage Analysis

For each modified **source** file (not test files), check if a corresponding test file was also modified or exists:

### PHP/Laravel conventions

| Source Path | Expected Test Path |
|-------------|-------------------|
| `app/Models/User.php` | `tests/Unit/Models/UserTest.php` |
| `app/Http/Controllers/PostController.php` | `tests/Feature/Http/Controllers/PostControllerTest.php` |
| `app/Services/PaymentService.php` | `tests/Unit/Services/PaymentServiceTest.php` |

### TypeScript/React conventions

| Source Path | Expected Test Path |
|-------------|-------------------|
| `src/components/Button.tsx` | `src/components/Button.test.tsx` OR `__tests__/components/Button.test.tsx` |
| `src/utils/validation.ts` | `src/utils/validation.spec.ts` |
| `src/hooks/useAuth.ts` | `src/hooks/useAuth.test.ts` |

**For each source file without test changes:**
- Use Glob to check if the expected test file exists at all
- If test exists but wasn't modified: `suggestion: Source changed but tests not updated`
- If no test exists: `suggestion (blocking): No test file found for {source_file}`

## Step 7: CI/Pipeline Status (Conditional)

**If GitLab MCP available:**
- Get pipeline status for the MR
- For each failed job: extract job name, failure reason, and log snippet
- Attempt to correlate failures to changed files based on job name and error messages

**If GitHub MCP available:**
- Get check runs for the head commit
- For each failed check: extract name, conclusion, and output summary
- Correlate to changed files where possible

**If no MCP:**
- Skip this step
- Note in output: "CI status not checked (no MCP configured)"

## Step 8: Compile Findings

Group all findings into sections using Conventional Comments format:

### Section 1: Critical Issues (Blocking)

All `issue (blocking)` and `issue (blocking, security)` findings.
Each must include:
- File path and line number
- Conventional Comments label
- Description of the issue
- Suggested fix with code snippet
- Link to relevant documentation or advisory (if applicable)

### Section 2: Risky Files Analysis

Top 5 files by risk score. For each:
- File path and risk score breakdown
- Specific concerns identified during analysis
- Relationship to other changed files (cross-file impact)

### Section 3: Security Hints

All security-related findings grouped by type:
- Vulnerabilities found
- Secrets detected
- Authorization gaps
- Include remediation guidance for each

### Section 4: Performance Hints

- N+1 query patterns
- Missing database indexes (if migration files present)
- Bundle size concerns (large new dependencies)
- Unnecessary re-renders (React)

### Section 5: Missing Test Coverage

- Source files without corresponding tests
- Source files with test files that weren't updated
- Test coverage percentage change (if available from CI)

### Section 6: CI Failures (if available)

- Failed jobs/checks with error context
- Correlation to changed files
- Suggested fixes

### Section 7: Suggestions (Non-blocking)

All `suggestion`, `nitpick`, and `praise` findings:
- Refactoring opportunities
- Code quality improvements
- Positive acknowledgments of good patterns

---

# HARD STOP — Review Summary & User Choices

## Step 9: Present Executive Summary

Display a compact summary:

```
REVIEW COMPLETE
═══════════════

PR/MR: {title} ({source_ref})
Author: {author}
Risk Level: {risk_emoji} {risk_level}

FILES
─────
Changed: {files_count} | Skipped: {skipped_count}
Lines: +{additions} / -{deletions}

FINDINGS
────────
Blocking Issues: {blocking_count}
Security Hints: {security_count}
Performance Hints: {perf_count}
Missing Tests: {missing_test_count}
CI Failures: {ci_failure_count}
Suggestions: {suggestion_count}

TOP CONCERNS
────────────
1. {top_finding_1}
2. {top_finding_2}
3. {top_finding_3}
```

## Step 10: AskUserQuestion — Review Options

Use AskUserQuestion:
- Question: "How should I proceed with the review?"
- Header: "Review Options"
- Options:
  - "Full review" — Generate complete review pack with all sections
  - "Security only" — Focus on security findings, skip performance and suggestions
  - "Quick scan" — Blocking issues and security only (for draft MRs or large PRs)

If MCP is available AND blocking issues exist, follow up with:
- Question: "Post findings as inline comments on the MR/PR?"
- Header: "Post Comments"
- Options:
  - "Yes" — Post blocking issues as inline comments via API
  - "No" — Output file only

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 11: Generate Review Pack

1. Read template: `$JAAN_TEMPLATES_DIR/jaan-to-dev-pr-review.template.md`
2. Fill template variables with findings from Step 8
3. Apply selected focus from Step 10:
   - **Full review**: Include all 7 sections
   - **Security only**: Include sections 1, 3, and omit 4, 7
   - **Quick scan**: Include sections 1, 3, 5 only

4. Format all findings using Conventional Comments:
   ```
   {label} [{decorations}]: {subject}

   {discussion with code context}
   ```

5. For each finding, include:
   - Exact file path and line number (validated against diff)
   - Code snippet showing the issue
   - Suggested fix (where applicable)

## Step 12: Quality Check

Before preview, verify:

- [ ] Every finding references an actual file and line from the diff
- [ ] Line numbers are validated against the parsed diff (no hallucination)
- [ ] Security findings use `issue (blocking, security):` label
- [ ] Blocking vs non-blocking is clearly distinguished
- [ ] Executive summary metrics match actual finding counts
- [ ] No PHP patterns applied to TypeScript files or vice versa
- [ ] Secrets in test files are not flagged as real secrets
- [ ] Suggested fixes are syntactically correct for the target language

If any check fails, fix before proceeding.

## Step 13: Preview & Approval

Show the complete review pack to the user.

Use AskUserQuestion:
- Question: "Write this review pack?"
- Header: "Write"
- Options:
  - "Yes" — Write the file
  - "Edit" — Let me revise something first
  - "Cancel" — Discard

If "Edit": Ask what to change, apply edits, re-preview.

## Step 14: Write Output

1. Generate slug from input:
   - MR URL → `mr-{iid}` (e.g., `mr-142`)
   - PR URL → `pr-{number}` (e.g., `pr-456`)
   - Branch → `branch-{sanitized-name}` (e.g., `branch-feature-user-auth`)

2. Create directory: `$JAAN_OUTPUTS_DIR/dev/review/{slug}/`

3. Write file: `$JAAN_OUTPUTS_DIR/dev/review/{slug}/pr-review.md`

Confirm: "Review pack written to `$JAAN_OUTPUTS_DIR/dev/review/{slug}/pr-review.md`"

## Step 15: Post Comments (Optional)

Only execute if user approved in Step 10 AND MCP is available.

**GitLab:**
- Post executive summary as MR note (general comment)
- For each blocking issue: post as inline discussion on the specific file and line
- For each suggestion: post as inline comment (non-blocking)

**GitHub:**
- Create a review with "REQUEST_CHANGES" (if blocking issues) or "COMMENT" status
- Include inline comments for each finding with file path and line

**Rate limiting:** Post maximum 20 inline comments per review (prioritize by severity).

## Step 16: Capture Feedback

Use AskUserQuestion:
- Question: "Any feedback on this review?"
- Header: "Feedback"
- Options:
  - "No" — All good, done
  - "Fix now" — Update something in the review
  - "Learn" — Save lesson for future runs
  - "Both" — Fix now AND save lesson

- **Fix now**: Ask what to change, update review pack, re-write
- **Learn**: Run `/to-jaan-learn-add jaan-to-dev-pr-review "{feedback}"`
- **Both**: Do both

---

## Definition of Done

- [ ] Input parsed and diff source determined
- [ ] Diff retrieved (via MCP or git fallback)
- [ ] Files triaged (skip generated/binary, flag large PRs)
- [ ] Files scored by risk (criticality + change + history + author)
- [ ] Security patterns applied per tech stack
- [ ] Test coverage gaps identified
- [ ] CI status checked (if MCP available)
- [ ] Findings compiled with Conventional Comments format
- [ ] Executive summary shown to user
- [ ] User approved review scope via AskUserQuestion
- [ ] Review pack generated from template
- [ ] Quality check passed (line numbers validated, no false patterns)
- [ ] User approved and output file written
- [ ] Comments posted (if user opted in and MCP available)
- [ ] Feedback captured (if any)
