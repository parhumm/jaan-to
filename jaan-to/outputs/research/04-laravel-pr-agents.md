# Building Claude Code Agents for Laravel PR Review

> Summary of: `deepresearch/dev-workflow/building-claude-code-agents-laravel-pr-review.md`

## Key Points

- **CLAUDE.md for project context**: Include Laravel version, packages (Sanctum, Spatie Permission), coding standards, and explicit review guidelines
- **Diff-aware reviews**: Focus only on changed code to reduce noise; use GitHub API to fetch PR diffs
- **Multi-perspective audits**: Run separate passes for security, style, architecture - can use parallel agents
- **Structured JSON output**: Request findings in parseable format with file, line, severity, description, and suggestion
- **Minimize false positives**: Define non-goals explicitly (e.g., "don't comment on unchanged files")
- **CI/CD integration**: Use GitHub Actions with `pull_request` event to trigger reviews
- **Inline comments**: Map Claude findings to GitHub review comments using diff position calculation
- **Security focus**: Check for SQL injection, XSS, mass assignment, auth bypass, file path traversal

## Critical Insights

1. **Claude is only as good as the context** - Detailed CLAUDE.md with PSR standards, naming conventions, and Laravel patterns dramatically improves review quality
2. **Iterative refinement** - Test on sample PRs, observe output, adjust prompts and guidelines based on false positives/negatives
3. **AI reviews augment human reviewers** - Catch routine issues to free humans for nuanced review; never auto-merge without human approval

## Quick Reference

| Aspect | Recommendation |
|--------|---------------|
| Trigger | `pull_request` event (opened, synchronize) |
| Permissions | contents: read, pull-requests: write |
| Diff size limit | Skip PRs >2000 lines changed |
| Output format | Structured JSON with confidence scores |
| Comment style | File:line - issue, explanation, fix suggestion |

## Laravel-Specific Security Checks
- `whereRaw()`, `DB::raw()` without parameter binding
- `$request->all()` passed to `create()` or `update()`
- Missing `auth:sanctum` middleware on protected routes
- `{!! $variable !!}` unescaped Blade output
- User input in file paths without `basename()`

