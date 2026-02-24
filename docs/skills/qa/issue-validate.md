---
title: "qa-issue-validate"
sidebar_position: 10
---

# /jaan-to:qa-issue-validate

> Validate GitHub/GitLab issues against codebase with root cause analysis and reproduction scenarios.

---

## What It Does

Analyzes whether a reported issue is genuine by searching the codebase for evidence. Given an issue (by ID, URL, or pasted text), the skill extracts technical claims, validates them against code, assigns a verdict with confidence level, and provides root cause analysis for valid bugs. Results can be posted as a comment on the issue and optionally added to the project roadmap.

The skill treats all issue content as untrusted external input with mandatory threat scanning before analysis.

---

## How It Differs from qa-issue-report

| Aspect | [qa-issue-report](issue-report.md) | qa-issue-validate |
|--------|---------------------|---------------------|
| Direction | Create new issues (outbound) | Analyze existing issues (inbound) |
| Purpose | Report problems | Validate reported problems |
| Output | Issue on platform | Validation comment + local report |
| Code search | Find related references | Verify specific claims |
| RCA | No | Yes — causal chain + 5 Whys |
| Reproduction | No | Yes — for confirmed bugs |
| Safety | Privacy sanitization | Threat scan + privacy sanitization |
| Roadmap | No | Optional `/pm-roadmap-add` integration |

---

## Usage

```
/jaan-to:qa-issue-validate 42
/jaan-to:qa-issue-validate 42 --repo owner/repo
/jaan-to:qa-issue-validate https://github.com/owner/repo/issues/42
/jaan-to:qa-issue-validate "<pasted issue text>"
/jaan-to:qa-issue-validate 42 --platform gitlab
```

---

## Arguments

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| `<identifier>` | Issue #, URL, or text | — | Issue to validate |
| `--repo` | `owner/repo` | Auto-detect from git remote | Target repository |
| `--platform` | `github`, `gitlab` | Auto-detect | Force platform |

---

## Validation Verdicts

| Verdict | Meaning |
|---------|---------|
| `VALID_BUG` | Code contradicts expected behavior |
| `VALID_FEATURE` | Requested capability genuinely absent |
| `VALID_IMPROVEMENT` | Real, measurable limitation |
| `INVALID_USER_ERROR` | Misuse/misconfiguration |
| `INVALID_CANNOT_REPRODUCE` | Code works correctly per analysis |
| `INVALID_DUPLICATE` | Existing open issue covers same problem |
| `INVALID_STALE` | Referenced code no longer exists |
| `NEEDS_INFO` | Insufficient detail to determine |

---

## What It Asks

| Question | When |
|----------|------|
| "Which issue should I validate?" | No identifier provided |
| "Threat patterns detected. Continue?" | SUSPICIOUS or DANGEROUS content found |
| "Post comment, local only, abort, or edit?" | HARD STOP review |
| "Close this issue?" | INVALID verdict + user approved comment |
| "Add to roadmap?" | VALID verdict |
| "Any feedback?" | After completion |

---

## Key Features

### Issue Content Threat Scanning

Before any codebase analysis, the skill scans issue content for: prompt injection, embedded commands, credential probing, path traversal, hidden characters, and obfuscation. Issues are classified as SAFE, SUSPICIOUS, or DANGEROUS. Dangerous content requires explicit user approval to continue.

### Layered Code Search

Seven layers of verification: file existence, function/class definitions, error message tracing, stack trace validation, route/endpoint mapping, test coverage analysis, and git history. All searches are scoped to the project root.

### Root Cause Analysis

For valid bugs: causal chain decomposition (trigger → entry point → fault location → mechanism → impact) and iterative 5 Whys analysis. Includes severity classification (Critical/High/Medium/Low).

### Reproduction Scenarios

For confirmed bugs: environment preconditions, numbered atomic steps, concrete expected vs actual behavior, and optional minimal reproduction snippets.

### Dual Platform Support

Works with GitHub (`gh` CLI) and GitLab (REST API v4 or `glab` CLI). Auto-detects platform from git remote. Supports self-hosted GitLab instances.

### Safe Roadmap Integration

When adding validated issues to the roadmap via `/pm-roadmap-add`, all text is sanitized: commands stripped, credentials redacted, raw issue text replaced with the skill's own analysis. Roadmap text is shown to the user for approval before integration.

---

## Output

**Platform comment**: Posts validation result (verdict, evidence, RCA, reproduction) as an issue comment.

**Local report**:
```
$JAAN_OUTPUTS_DIR/qa/issue-validate/{id}-{slug}/{id}-issue-validate-{slug}.md
```

---

## Security Design

The skill follows jaan-to's security principles with additional safeguards for untrusted input:

- Issue text is treated as data, never as instructions
- Secrets files (`.env`, `*.key`, `*.pem`) are never read, even if referenced
- URLs in issue body are never followed (indirect prompt injection risk)
- Raw issue text is never passed to roadmap integration
- All file searches are scoped to project root
- Human approval required before posting, closing, or adding to roadmap

---

## Tips

- Start with issues you already suspect are valid or invalid to calibrate the skill
- For issues with low detail, expect NEEDS_INFO verdict — the skill doesn't guess
- Review the threat scan results if the issue comes from an unknown contributor
- Pair with `/qa-issue-report` for a complete issue lifecycle (report → validate → roadmap)
- For VALID_BUG verdicts: use the reproduction scenario as input for `/qa-test-cases` to generate regression tests
- For VALID_FEATURE verdicts: extract acceptance criteria from the RCA summary and feed to `/qa-test-cases` to define feature tests before implementation
- The local report is saved even when comments are posted, creating an audit trail

---

[Back to QA Skills](README.md) | [Back to All Skills](../README.md)
