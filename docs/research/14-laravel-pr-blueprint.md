# PR Review Agent Blueprint for Laravel 10 with Claude

> Summary of: `deepresearch/dev-workflow/pr-review-agent-blueprint-laravel-10-claude.md`

## Key Points

- **Implementation time**: 1-2 days for MVP, additional week for production refinement
- **Three architecture options**: Single-pass (MVP), Multi-agent parallel, Two-pass filter (production recommended)
- **Two-pass architecture**: Pass 1 generates all findings, Pass 2 filters for 40-60% false positive reduction
- **CLAUDE.md template provided**: Complete Laravel 10 context with naming conventions, database patterns, security checks
- **Security check list**: SQL injection, mass assignment, XSS, auth bypass, file operations, command injection
- **GitHub Actions workflow**: Complete YAML template with diff fetching, Claude API call, comment posting
- **Diff position mapping**: PHP algorithm for converting file line numbers to GitHub diff positions
- **Cost estimation**: $0.02-0.50 per PR depending on size; ~$10-50/month for 200 PRs

## Critical Insights

1. **Two-pass is essential for production** - Single-pass has too many false positives; invest in filtering
2. **Prompt injection protection required** - PR diffs can contain malicious content; treat as untrusted
3. **Confidence thresholds by severity** - Critical needs >= 0.9, High >= 0.85, Medium/Low >= 0.8

## Quick Reference

| Architecture | Complexity | Cost/PR | Latency | Best For |
|--------------|------------|---------|---------|----------|
| Single-pass | Low | $0.01-0.05 | 15-45s | MVP, small PRs |
| Multi-agent | Medium | $0.05-0.15 | 30-60s | Complex PRs |
| Two-pass | Medium | $0.03-0.08 | 45-90s | Production |

## Implementation Timeline
### Day 1
- Set up GitHub Action workflow
- Create CLAUDE.md with Laravel conventions
- Implement Claude API integration
- Add JSON parsing and comment posting

### Day 2
- Add confidence filtering
- Implement comment deduplication
- Add prompt injection safeguards
- Test and tune false positive filters

## Token Budget (200K Context)
| Component | Tokens | Percentage |
|-----------|--------|------------|
| System prompt + CLAUDE.md | ~3,000 | 1.5% |
| Diff content | ~50,000 max | 25% |
| Response buffer | ~4,000 | 2% |
| Safety margin | ~141,500 | 70% |

