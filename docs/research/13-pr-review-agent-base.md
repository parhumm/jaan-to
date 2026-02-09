# PR Review Agent Base

> Summary of: `deepresearch/dev-workflow/pr-review-agent-base.md`

## Key Points

- **Core architecture**: GitHub Actions workflow triggers Claude API on PR events
- **Diff processing**: Fetch PR diff via GitHub API, focus only on changed files
- **Prompt structure**: Static context (CLAUDE.md) + dynamic diff + output schema
- **Output format**: Structured JSON with findings array and summary object
- **Comment posting**: Use GitHub Review API for inline comments with position mapping
- **Confidence filtering**: Only post findings with confidence >= 0.8
- **Error handling**: Skip oversized PRs, handle API failures gracefully
- **Security**: Never expose API keys, use GitHub Secrets

## Critical Insights

1. **Diff-aware is essential** - Reviewing entire codebase creates noise; focus on changes only
2. **Position mapping is complex** - Converting file lines to diff positions requires careful algorithm
3. **Start simple, iterate** - Begin with single-pass review, add multi-pass filtering based on false positive rates

## Quick Reference

| Component | Purpose | Implementation |
|-----------|---------|----------------|
| Trigger | Start review | GitHub Actions on PR events |
| Diff fetch | Get changes | GitHub API (accept: diff media type) |
| Prompt | Instruct Claude | Static context + diff + schema |
| Output | Parse results | JSON with findings array |
| Comments | Post feedback | GitHub Review API |
| Filter | Reduce noise | Confidence threshold >= 0.8 |

## Workflow Steps
1. PR opened/updated triggers GitHub Action
2. Fetch PR diff and changed files list
3. Check size limits (skip if too large)
4. Build prompt with CLAUDE.md + diff
5. Call Claude API
6. Parse JSON response
7. Filter by confidence threshold
8. Post review comments via GitHub API

## Minimum Viable Implementation
```yaml
on:
  pull_request:
    types: [opened, synchronize]
permissions:
  contents: read
  pull-requests: write
```

