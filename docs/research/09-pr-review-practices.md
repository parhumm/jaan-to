# Claude Code PR Review Best Practices

> Summary of: `deepresearch/dev-workflow/claude-code-pr-review-best-practices.md`

## Key Points

- **Focus on changed code only**: Diff-aware reviews reduce noise and improve relevance
- **Structured output format**: Use JSON with file, line, severity, category, description, suggestion, confidence
- **Severity levels**: Critical (blocks merge), High (request changes), Medium/Low (comments only)
- **Confidence thresholds**: Only post findings with confidence >= 0.8 to reduce false positives
- **Category taxonomy**: Security, structure, database, dependency, performance, maintainability
- **Two-pass architecture**: Generate all findings, then filter with second pass for 40-60% false positive reduction
- **Comment deduplication**: Track posted comments to avoid duplicates on PR updates
- **Rate limiting**: Max 20 comments per review to avoid overwhelming developers

## Critical Insights

1. **Precision over recall** - Better to miss some issues than flood PRs with false positives; trust erodes quickly
2. **Two-pass filtering is essential** - Single-pass generates too many false positives for production use
3. **Severity-based actions** - Critical auto-blocks, High requests changes, Medium/Low are informational

## Quick Reference

| Severity | Confidence Required | Action |
|----------|---------------------|--------|
| Critical | >= 0.9 | Block PR, require fix |
| High | >= 0.85 | Request changes |
| Medium | >= 0.8 | Comment only |
| Low | >= 0.8 | Comment only (limit 5/PR) |

## Security Checks Priority
1. SQL Injection (raw queries, user-controlled columns)
2. Command Injection (exec, shell_exec)
3. Auth Bypass (missing middleware, direct object references)
4. Mass Assignment ($request->all(), $guarded = [])
5. XSS (unescaped output)
6. Path Traversal (user input in file paths)

## Output Schema
```json
{
  "findings": [{
    "file": "string",
    "line": "number",
    "severity": "critical|high|medium|low",
    "category": "string",
    "title": "string (max 60 chars)",
    "description": "string",
    "suggestion": "string",
    "confidence": "0.0-1.0"
  }],
  "summary": {
    "total_findings": "number",
    "critical": "number",
    "approved": "boolean"
  }
}
```

