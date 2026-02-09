# Claude Code Optimization

> Summary of: `deepresearch/dev-workflow/claude-code-optimization.md`

## Key Points

- **Token consumption hierarchy**: MCP tools (55K-134K), file inclusion (variable), bash output (unbounded), command descriptions (low)
- **Subagent context isolation**: Primary optimization lever - subagents return only results, not full context
- **Model selection impact**: Haiku costs 3x less than Sonnet for routine tasks; capability difference is minimal for constrained tasks
- **Prompt caching**: 90% cost reduction possible; cache reads cost only 0.1x base price
- **Tool deferral**: Use `defer_loading: true` for 85% reduction in tool token overhead
- **CLAUDE.md optimization**: Target under 1,000 tokens; focused context outperforms verbose context
- **Command frontmatter**: Specify model and allowed-tools to reduce token overhead
- **Session management**: Clear context between unrelated tasks; compact at 80% capacity

## Critical Insights

1. **MCP tool definitions are the biggest hidden cost** - 55K-134K tokens before any conversation; use defer_loading
2. **Subagent isolation creates 37% token reduction** - Complex research in subagent, only summary returns to main
3. **Compounding effect is significant** - Caching (90%) + model routing (3x) + isolation (37%) + deferral (85%) = multiplicative savings

## Quick Reference

| Optimization | Impact | Implementation |
|--------------|--------|----------------|
| Prompt caching | 90% cost reduction | Static instructions first, dynamic last |
| Model routing | 3x savings on routine | Haiku for 80% of tasks |
| Subagent isolation | 37% context reduction | Use Task tool for research |
| Tool deferral | 85% tool token reduction | `defer_loading: true` |
| Context clearing | Prevents context bloat | `/clear` between tasks |

## Token Budget Reference
| Operation Type | Token Budget | Optimal Time |
|----------------|--------------|--------------|
| Simple fix (Haiku) | 2-5K | 1-2 min |
| Standard feature (Sonnet) | 10-20K | 5-10 min |
| Complex refactor (Sonnet+thinking) | 30-50K | 15-25 min |
| Architecture review (Opus) | 50-100K | 20-40 min |

## Extended Thinking Keywords
- `"think"` → 5,000-10,000 tokens
- `"think hard"` → 20,000-50,000 tokens
- `"think harder"` → 50,000-100,000 tokens
- `"ultrathink"` → 100,000-128,000 tokens (maximum)

