# Agent Best Practices

> Summary of: `deepresearch/dev-workflow/agent-best-practices.md`

## Key Points

- **CLAUDE.md is essential**: Create a comprehensive project context file that includes tech stack, architecture patterns, coding conventions, and explicit AI behavioral guidelines
- **Use headless mode for CI/CD**: Run Claude Code with `--print` flag for non-interactive automation in pipelines
- **Subagent delegation**: Use the Task tool with specialized subagents (Explore, Plan, general-purpose) to keep main context lean and avoid context pollution
- **Prompt caching reduces costs by 90%**: Structure commands with static instructions first, dynamic content last to maximize cache hits
- **Model selection matters**: Use Haiku for quick tasks (commits, searches), Sonnet for standard work, Opus for complex reasoning
- **Hooks for automation**: Configure pre/post hooks for tool calls to integrate with existing workflows (linting, testing, notifications)
- **Memory management**: Use `/compact` and `/clear` commands to manage context; auto-compact triggers at 95% capacity
- **Allowed-tools restriction**: Limit tools in commands for both security and token efficiency

## Critical Insights

1. **Context isolation is the primary optimization lever** - Subagents can consume 10,000+ tokens internally but return only 500-1,000 tokens to main conversation
2. **The 80/20 rule applies** - Use Haiku for 80% of routine operations, reserving Sonnet/Opus for the 20% requiring deep reasoning
3. **AI is an assistant, not the boss** - All decisions should have human oversight; use AI for grunt work while humans ensure correctness

## Quick Reference

| Aspect | Recommendation |
|--------|---------------|
| Project context | Create CLAUDE.md with <500 lines |
| CI/CD integration | Use `claude -p "prompt" --print` |
| Cost optimization | Prompt caching + model routing |
| Token efficiency | Subagent isolation (37% reduction) |
| Command structure | Static first, dynamic last |

