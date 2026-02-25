---
title: "wp-pr-review"
sidebar_position: 2
doc_type: skill
created_date: 2026-02-09
updated_date: 2026-02-15
tags: [wordpress, security, code-review, pr-review, wpcs]
related: [detect-dev]
---

# wp-pr-review

> Review WordPress plugin pull requests for security, performance, standards, and backward compatibility.

---

## What It Does

Analyzes WordPress plugin PR diffs using a 5-phase review workflow: context gathering, diff analysis, deterministic security scanning, LLM-powered contextual analysis, and severity-classified report generation. Catches missing escaping, broken access control, SQL injection, performance anti-patterns, and WPCS violations that automated linters miss.

Findings are confidence-scored (0-100). Only issues with confidence >= 80 appear in the final report, reducing false positives.

---

## Quick Start

```bash
# Review a GitHub PR by URL
/wp-pr-review https://github.com/owner/plugin-name/pull/42

# Review by shorthand
/wp-pr-review owner/plugin-name#42

# Review local changes against main
/wp-pr-review local

# GitLab merge request
/wp-pr-review https://gitlab.com/owner/plugin-name/-/merge_requests/42
```

---

## Input Modes

| Mode | Format | Example |
|------|--------|---------|
| GitHub URL | `https://github.com/owner/repo/pull/N` | Full PR link |
| GitLab URL | `https://gitlab.com/owner/repo/-/merge_requests/N` | Full MR link |
| GitHub shorthand | `owner/repo#N` | `parhumm/wp-slimstat#42` |
| GitLab shorthand | `owner/repo!N` | `parhumm/wp-slimstat!42` |
| Local diff | `local` or empty | Uses `git diff main...HEAD` |

---

## Review Phases

### Phase 1: Context Gathering

Reads project configuration to understand the plugin:
- `composer.json` for PHP version constraints
- `phpcs.xml.dist` for WPCS rules, text domain, prefix
- `phpstan.neon` for static analysis level
- Main plugin file header for metadata

### Phase 2: Diff Analysis

Fetches the PR diff via `gh pr diff` (GitHub), `glab mr diff` (GitLab), or `git diff` (local). Identifies changed PHP files and skips `vendor/`, `node_modules/`.

For large GitHub PRs where `gh pr diff` fails (HTTP 406), falls back to the paginated REST API (`gh api repos/.../pulls/.../files --paginate`) to retrieve file patches individually. PRs with 50+ PHP files are processed in batches of 30 to reduce per-call context size.

### Phase 3: Deterministic Security Scan

Runs grep patterns against changed files for high-signal security issues:
- Unsanitized superglobal access (`$_POST`, `$_GET`, `$_REQUEST`)
- Database queries without `$wpdb->prepare()`
- Dangerous functions (`eval`, `unserialize`, `extract`, `shell_exec`)
- REST routes without `permission_callback`
- AJAX handlers without nonce verification
- `is_admin()` misused as authorization

### Phase 4: Contextual LLM Analysis

For each grep match, reads surrounding code to determine:
- **True/false positive**: Is the input actually sanitized nearby?
- **WPCS compliance**: Naming, Yoda conditions, i18n, prefixing
- **Backward compatibility**: PHP 8.x syntax, deprecated functions, named arguments
- **Performance**: N+1 queries, unbounded queries, global asset loading
- **Add-on ecosystem impact**: Hook signature changes, API stability

### Phase 5: Report Generation

Groups findings by severity, applies confidence threshold, generates actionable report with code snippets and fix suggestions.

---

## Severity Classification

| Severity | Triggers |
|----------|----------|
| **CRITICAL** | Security vulnerabilities, data loss, PHP fatal errors, broken access control |
| **WARNING** | Performance degradation, standards violations with functional impact, backward compat breaks |
| **INFO** | Style suggestions, improvement opportunities |

**Verdict logic**:
- Any CRITICAL findings -> `REQUEST_CHANGES`
- Only WARNING + INFO -> `COMMENT`
- No findings above threshold -> `APPROVE`

---

## Output

**Path**: `$JAAN_OUTPUTS_DIR/wp/pr/{id}-{slug}/{id}-pr-review-{slug}.md`

The report contains:
- **Executive Summary** with verdict
- **PR Metadata** table (plugin name, versions, PHPCS config)
- **Findings** grouped by severity with vulnerable code and fix suggestions
- **Review Categories** (Security, Performance, Standards, Compatibility, Add-on Impact)
- **Checklist Summary** (pass/fail per subcategory)
- **Methodology** and confidence scoring explanation

---

## Optional PR Comment

After generating the report, the skill offers to post it as a comment on the PR:

```
Would you like to post this review as a comment on the PR?
[1] Post full review
[2] Post summary only
[3] Skip
```

This uses `gh pr comment` (GitHub) or `glab mr comment` (GitLab). Requires explicit approval before posting.

---

## Reference Files

The skill includes detailed checklists loaded on demand:

| File | Content |
|------|---------|
| `references/security-checklist.md` | Sanitization, escaping, nonce, capability, DB security patterns |
| `references/performance-checklist.md` | N+1 queries, autoload, unbounded queries, asset loading |
| `references/standards-checklist.md` | WPCS naming, Yoda, i18n, prefix, WP API usage |
| `references/vulnerability-patterns.md` | CVE patterns from 2024-2025, grep commands |
| `references/addon-ecosystem.md` | Hook contracts, API stability, schema changes |

---

## Tips

### When to Use

- Before merging WordPress plugin PRs
- Auditing plugin code for security before deployment
- Checking WPCS compliance on new contributions
- Reviewing add-on/extension compatibility of core plugin changes

### Best Practices

1. **Provide context** - Use the full PR URL when possible for complete metadata
2. **Review the diff first** - The skill only reviews changed files, not the entire codebase
3. **Check project config** - Ensure `phpcs.xml.dist` exists for accurate text domain/prefix detection
4. **Iterate with feedback** - Use `/learn-add wp-pr-review` to improve accuracy over time

---

## Research Foundation

Based on comprehensive research covering:
- WordPress PHP Coding Standards (WPCS) and Plugin Review Team requirements
- OWASP Top 10 mapped to WordPress plugin vulnerabilities
- Real-world CVEs from 2024-2025 (Really Simple Security, GiveWP, WPML, Bricks Builder)
- Patchstack 2025 security report statistics
- wp-slimstat add-on ecosystem architecture patterns

Research document: `$JAAN_OUTPUTS_DIR/research/67-wp-pr-review.md`

---

## Related Skills

- [/detect-dev](../detect/detect-dev.md) - Engineering audit with OpenSSF scoring
- [/qa-test-cases](../qa/test-cases.md) - Generate test cases from acceptance criteria

---

## Technical Details

- **Logical Name**: wp-pr-review
- **Command**: `/wp-pr-review`
- **Role**: wp (WordPress)
- **Allowed Tools**: Read, Glob, Grep, Bash(gh/glab/git, gh api), Write($JAAN_OUTPUTS_DIR/wp/**)
- **Output**: `$JAAN_OUTPUTS_DIR/wp/pr/{id}-{slug}/`
- **ID Generation**: Sequential per subdomain (01, 02, 03...)
- **Index**: Auto-updates `$JAAN_OUTPUTS_DIR/wp/pr/README.md`
