# Claude Code Workflow

> Summary of: `deepresearch/dev-workflow/claude-code-workflow.md`

## Key Points

- **Interactive vs headless modes**: Interactive for development, headless (`--print`) for CI/CD
- **Session workflow**: Start with context review, use subagents for exploration, main agent for execution
- **Context management**: Load CLAUDE.md automatically, use `/compact` for context condensation
- **Task delegation pattern**: Main agent orchestrates, subagents perform specialized tasks
- **Tool selection**: Use specialized tools (Read, Write, Edit) over bash for file operations
- **Git operations**: Claude can commit, push, create PRs with proper configuration
- **Error handling**: Review errors, adjust approach, use `/clear` if context becomes polluted
- **Multi-file operations**: Plan first, execute sequentially, verify after each step

## Critical Insights

1. **Orchestration pattern works best** - Main agent plans, delegates to subagents, aggregates results
2. **Specialized tools outperform bash** - Read/Write/Edit are safer and more efficient than cat/sed/echo
3. **Context hygiene is critical** - Clear between unrelated tasks, compact when approaching limits

## Quick Reference

| Mode | Use Case | Command |
|------|----------|---------|
| Interactive | Development | `claude` |
| Headless | CI/CD | `claude -p "prompt" --print` |
| Print mode | Single query | `claude -p "question"` |
| JSON output | Automation | `--output-format json` |

## Workflow Phases
1. **Context Loading**: CLAUDE.md + relevant files
2. **Exploration**: Use Explore subagent for research
3. **Planning**: Use Plan subagent or main agent
4. **Execution**: Main agent with appropriate tools
5. **Verification**: Tests, linting, manual review
6. **Cleanup**: Clear context, commit changes

## Tool Preference Hierarchy
| Task | Preferred Tool | Avoid |
|------|---------------|-------|
| Read file | Read | cat, head, tail |
| Write file | Write | echo, cat heredoc |
| Edit file | Edit | sed, awk |
| Search files | Glob, Grep | find, grep |
| Explore code | Task (Explore) | Manual navigation |

