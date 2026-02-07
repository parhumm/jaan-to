---
title: /jaan-to:dev-pr-review
doc_type: skill
created_date: 2026-02-03
updated_date: 2026-02-03
tags: [dev, code-review, pr, merge-request, security, quality]
related: [stack-detect]
---

# /jaan-to:dev-pr-review

> Automated PR review pack: risk scoring, security and performance hints, missing tests, CI failures.

---

## What It Does

Reviews a GitLab merge request (or GitHub PR) and generates a structured review pack. Parses the diff, scores files by risk, detects security anti-patterns for PHP/Laravel and TypeScript/React, checks test coverage gaps, and correlates CI failures to changed files. Output uses Conventional Comments format so findings are machine-parsable and actionable.

---

## Usage

```
/jaan-to:dev-pr-review <pr-link-or-branch>
/jaan-to:dev-pr-review https://gitlab.com/org/repo/-/merge_requests/42
/jaan-to:dev-pr-review feature/user-auth
```

| Argument | Required | Description |
|----------|----------|-------------|
| pr-link-or-branch | Yes | MR/PR URL or branch name to review |

---

## What It Asks

| Question | Why |
|----------|-----|
| Review depth | Full review vs quick scan (draft MRs get limited review) |
| Focus area | Security-only, performance-only, or full review |
| Post comments? | Whether to post inline comments via GitLab/GitHub API |

---

## Review Sections

The output contains six sections, ordered by priority:

| Section | What It Covers |
|---------|---------------|
| Critical Issues (Blocking) | Security vulnerabilities, breaking changes, data integrity |
| Risky Files Analysis | Files ranked by risk score with specific concerns |
| Security Hints | OWASP patterns, secrets detection, authorization gaps |
| Performance Hints | N+1 queries, missing indexes, bundle size concerns |
| Missing Test Coverage | Source files without corresponding tests |
| Suggestions (Non-blocking) | Refactoring ideas, code quality improvements |

---

## Risk Scoring

Files are prioritized by a weighted risk score combining four factors:

| Factor | Weight | High-Risk Examples |
|--------|--------|--------------------|
| Criticality | 40% | auth/*, payment/*, migrations |
| Change size | 30% | Files with most lines changed |
| Historical defects | 20% | Files with past bug-fix commits |
| Author experience | 10% | New contributors to the file |

Files in `vendor/`, `dist/`, `*.lock` are skipped automatically.

---

## Security Patterns Detected

**PHP/Laravel:**
- SQL injection via `DB::raw()` or `whereRaw()` with unparameterized input
- Mass assignment with empty `$guarded`
- XSS via unescaped Blade output (`{!! !!}`)
- Command injection via `exec()` / `shell_exec()` with user input

**TypeScript/React:**
- XSS via `dangerouslySetInnerHTML` without DOMPurify
- `useEffect` dependency issues (missing deps, object references)
- Memory leaks from unmounted state updates
- Type safety bypasses (`any`, `@ts-ignore`)

**Secrets:** AWS keys, JWT tokens, API keys, database passwords, platform tokens (GitHub, GitLab, Stripe, Slack).

---

## Output

**Path**: `$JAAN_OUTPUTS_DIR/dev/review/{slug}/pr-review.md`

**Contains**:
- Executive summary with metrics (files, lines, risk level, blocking count)
- All findings in Conventional Comments format
- Suggested fixes with code snippets
- CI failure correlation

**Format options**: Markdown review pack (default), SARIF for CI integration.

---

## Example

**Input**:
```
/jaan-to:dev-pr-review https://gitlab.com/myorg/app/-/merge_requests/142
```

**Output** (`jaan-to/outputs/dev/review/mr-142/pr-review.md`):
```
# Automated Review: MR !142

| Metric        | Value        |
|---------------|--------------|
| Risk Level    | Medium       |
| Files Changed | 8            |
| Lines         | +156 / -43   |
| Blocking      | 1            |

## Blocking Issues
issue (blocking, security): SQL injection in UserController...
```

---

## Requirements

| Dependency | Required | Purpose |
|------------|----------|---------|
| GitLab MCP | Yes | Retrieve MR diffs, post comments, read pipelines |
| GitHub MCP | Alternative | For GitHub PRs instead of GitLab |
| Sentry MCP | Optional | Correlate changes to error regressions |

---

## Tips

- Keep PRs under 400 lines for best review quality — detection drops 70% beyond that
- The skill flags draft/WIP MRs and applies limited review automatically
- Deletion-only PRs get extra scrutiny for removed validation or auth checks
- Pair with `/jaan-to:dev-stack-detect` so security patterns match your actual stack

---

[Back to Dev Skills](README.md) | [Back to All Skills](../README.md)
