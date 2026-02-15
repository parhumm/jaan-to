---
title: "backend-pr-review"
sidebar_position: 6
doc_type: skill
created_date: 2026-02-15
updated_date: 2026-02-15
tags: [backend, security, code-review, pr-review, multi-stack]
related: [wp-pr-review, detect-dev, sec-audit-remediate]
---

# backend-pr-review

> Review backend pull requests for security, performance, code quality, and testing gaps across any stack.

---

## What It Does

Analyzes backend PR diffs using a two-pass review workflow: stack detection via tech.md, diff acquisition with platform fallbacks, deterministic security scanning with stack-specific grep patterns, two-pass LLM analysis with variable confidence thresholds, and risk-based file prioritization.

Supports PHP/Laravel, Node/TypeScript, Python/Django, Go, and Rust stacks. Works with both GitHub and GitLab (including self-hosted instances).

Findings are confidence-scored with severity-dependent thresholds: CRITICAL >= 90, WARNING >= 85, INFO >= 80. Maximum 20 findings per review to avoid noise.

---

## Quick Start

```bash
# Review a GitHub PR by URL
/jaan-to:backend-pr-review https://github.com/owner/repo/pull/42

# Review by shorthand
/jaan-to:backend-pr-review owner/repo#42

# Review a GitLab MR (any host)
/jaan-to:backend-pr-review https://gitlab.example.com/group/project/-/merge_requests/15

# GitLab shorthand
/jaan-to:backend-pr-review owner/repo!15

# Review local changes against main
/jaan-to:backend-pr-review local
```

---

## Input Modes

| Mode | Format | Example |
|------|--------|---------|
| GitHub URL | `https://github.com/owner/repo/pull/N` | Full PR link |
| GitLab URL | `https://{host}/group/project/-/merge_requests/N` | Any GitLab instance |
| GitHub shorthand | `owner/repo#N` | `acme/api-service#42` |
| GitLab shorthand | `owner/repo!N` | `acme/api-service!15` |
| Local diff | `local` or empty | Uses `git diff main...HEAD` |

---

## Supported Stacks

| Stack | Detection | Extensions | Framework Patterns |
|-------|-----------|------------|-------------------|
| PHP / Laravel | `composer.json`, `config/app.php` | `*.php` | Eloquent, Sanctum, Blade |
| TypeScript / Node | `package.json`, `tsconfig.json` | `*.ts`, `*.js` | Express, NestJS, Prisma |
| Python / Django | `pyproject.toml`, `requirements.txt` | `*.py` | Django ORM, DRF, Jinja2 |
| Go | `go.mod`, `.golangci.yml` | `*.go` | net/http, Gin, GORM |
| Rust | `Cargo.toml`, `clippy.toml` | `*.rs` | Actix, Axum, SQLx |

Stack is detected automatically from `$JAAN_CONTEXT_DIR/tech.md`. If tech.md is not available, the skill asks the user for the backend language.

---

## Review Phases

### Phase 1: Context Gathering

- Detects backend stack from tech.md
- Reads framework config files (composer.json, package.json, go.mod, etc.)
- Loads project-specific review standards from `$JAAN_CONTEXT_DIR/review-standards.md` (if exists)

### Phase 2: Diff Analysis

Fetches the PR/MR diff using platform-appropriate tools with fallback chains:
- **GitHub**: `gh pr diff` -> paginated REST API -> grep-only
- **GitLab**: `glab mr diff` -> curl API -> git refspec fallback
- **Local**: `git diff main...HEAD`

Filters to backend files only (by stack), skips vendored/generated files. Large PRs (50+ files) processed in batches of 30.

### Phase 3: Deterministic Security Scan

Runs stack-specific grep patterns from reference files. Universal patterns (hardcoded secrets, command injection, path traversal) are always included.

### Phase 4: Two-Pass LLM Analysis

**Pass 1 (Liberal)**: Generates all potential findings with confidence >= 50, reading 10-15 lines of context per grep match.

**Pass 2 (Conservative)**: Re-evaluates with broader context, applies variable confidence thresholds by severity, filters known false positives, caps at 20 findings.

### Phase 5: Report Generation

Groups findings by severity, includes risk-scored file ranking, generates actionable report with code snippets and fix suggestions.

---

## Review Categories

| Category | What It Checks |
|----------|---------------|
| **Security** | Injection, auth bypass, secrets, XSS, mass assignment |
| **Code Quality** | Error handling, dead code, naming violations |
| **Backend Patterns** | Framework-specific anti-patterns (N+1, missing middleware) |
| **Testing** | Missing tests for new endpoints/services |
| **Database** | Migration safety, query patterns, schema issues |
| **Performance** | Unbounded queries, resource leaks, missing pagination |

---

## Severity Classification

| Severity | Min Confidence | Triggers |
|----------|---------------|----------|
| **CRITICAL** | >= 90 | Security vulnerabilities, data loss, runtime crashes, broken access control |
| **WARNING** | >= 85 | Performance degradation, missing error handling, framework anti-patterns |
| **INFO** | >= 80 | Style improvements, minor suggestions |

**Verdict logic**:
- Any CRITICAL findings -> `REQUEST_CHANGES`
- Only WARNING + INFO -> `COMMENT`
- No findings above threshold -> `APPROVE`

---

## Output

**Path**: `$JAAN_OUTPUTS_DIR/backend/pr-review/{id}-{slug}/{id}-pr-review-{slug}.md`

The report contains:
- **Executive Summary** with verdict
- **PR Metadata** table (repository, stack, framework version)
- **Findings** grouped by severity with code snippets and fix suggestions
- **Review Categories** (Security, Code Quality, Backend Patterns, Testing, Database, Performance)
- **Risk Score** table ranking files by weighted risk
- **Methodology** with confidence thresholds and two-pass explanation

---

## Optional PR/MR Comment

After generating the report, the skill offers to post it on the PR/MR:

```
Would you like to post this review as a comment on the PR/MR?
[1] Post full review
[2] Post summary only
[3] Skip
```

Uses `gh pr comment` (GitHub), `glab mr comment` (GitLab), or `curl` API (self-hosted GitLab). Comments include a deduplication marker to prevent duplicates on re-runs.

---

## Reference Files

The skill includes stack-specific pattern catalogs loaded on demand:

| File | Content |
|------|---------|
| `references/security-patterns.md` | SQL injection, XSS, auth bypass, secrets detection per stack |
| `references/performance-patterns.md` | N+1 queries, unbounded queries, connection pooling per stack |
| `references/code-quality-patterns.md` | Error handling, naming, anti-patterns, test conventions per stack |

---

## Tips

### When to Use

- Before merging backend PRs in any stack
- Security auditing backend code changes
- Checking framework-specific best practices on new contributions
- Reviewing migration safety before deploying database changes

### Best Practices

1. **Set up tech.md** - Stack auto-detection works best when `$JAAN_CONTEXT_DIR/tech.md` describes your backend
2. **Add review-standards.md** - Customize review rules per project via `$JAAN_CONTEXT_DIR/review-standards.md`
3. **Use full PR URLs** - Provides complete metadata for accurate reviews
4. **Keep PRs small** - PRs under 500 lines get significantly better review coverage
5. **Iterate with feedback** - Use `/jaan-to:learn-add backend-pr-review` to improve accuracy over time

---

## Research Foundation

Based on comprehensive research covering:
- OWASP Top 10 mapped to multi-stack backend vulnerabilities
- Claude Code PR review best practices and GitHub Actions integration patterns
- Two-pass analysis architecture for false positive reduction (40-60% improvement)
- Risk-based file prioritization algorithms
- Production blueprint patterns for inline comment placement and deduplication

Research document: `docs/research/53-dev-pr-review.md`

---

## Related Skills

- [/jaan-to:wp-pr-review](../wp/pr-review.md) - WordPress-specific PR review
- [/jaan-to:detect-dev](../detect/detect-dev.md) - Engineering audit with OpenSSF scoring
- [/jaan-to:sec-audit-remediate](../security/sec-audit-remediate.md) - Generate security fixes from findings

---

## Technical Details

- **Logical Name**: backend-pr-review
- **Command**: `/jaan-to:backend-pr-review`
- **Role**: backend
- **Allowed Tools**: Read, Glob, Grep, Bash(gh/glab/git/curl), Write($JAAN_OUTPUTS_DIR/backend/**)
- **Output**: `$JAAN_OUTPUTS_DIR/backend/pr-review/{id}-{slug}/`
- **ID Generation**: Sequential per subdomain (01, 02, 03...)
- **Index**: Auto-updates `$JAAN_OUTPUTS_DIR/backend/pr-review/README.md`
