# Token Optimization Mastery for Claude Code

> Summary of: `deepresearch/dev-workflow/token-optimization.md`

## Key Points

- **MCP tool overhead is massive**: 55,000-134,000 tokens before conversation starts; use `defer_loading: true` for 85% reduction
- **Subagent isolation is key**: Subagents consume 10,000+ tokens internally but return only 500-1,000 to main context
- **Model selection transforms costs**: Haiku costs 3x less than Sonnet; use for 80% of routine operations
- **Prompt caching delivers 90% savings**: Cache reads cost 0.1x base price; structure static content first
- **File inclusion is dangerous**: `@filename` loads entire contents; target specific files, not directories
- **Bash output is unbounded**: Always limit output (e.g., `git log -5` not `git log`)
- **Extended thinking levels**: "think" (5-10K), "think hard" (20-50K), "think harder" (50-100K), "ultrathink" (100-128K)
- **Session management**: Use `/compact` before 95% capacity, `/clear` between unrelated tasks

## Critical Insights

1. **Compounding effect is multiplicative** - Caching (90%) + model routing (3x) + isolation (37%) + deferral (85%) compounds
2. **MCP tools are hidden cost** - Most teams don't realize tool definitions consume tokens before any work begins
3. **Typical cost reduction**: From $6/day average to $2-3/day with proper optimization

## Quick Reference

| Optimization | Savings | Implementation |
|--------------|---------|----------------|
| Prompt caching | 90% | Static instructions first |
| Model routing | 3x | Haiku for routine tasks |
| Subagent isolation | 37% | Task tool for research |
| Tool deferral | 85% | `defer_loading: true` |
| Context clearing | Variable | `/clear` between tasks |

## Token Cost by Model
| Model | Input/MTok | Output/MTok | Use Case |
|-------|------------|-------------|----------|
| Haiku 4.5 | $1 | $5 | Quick fixes, searches |
| Sonnet 4.5 | $3 | $15 | Standard development |
| Opus 4.5 | $5 | $25 | Complex architecture |

## Token Budget Guidelines
| Operation | Token Budget | Time |
|-----------|--------------|------|
| Simple fix (Haiku) | 2-5K | 1-2 min |
| Standard feature (Sonnet) | 10-20K | 5-10 min |
| Complex refactor | 30-50K | 15-25 min |
| Architecture review (Opus) | 50-100K | 20-40 min |

## Command Template for Cost Efficiency
```markdown
