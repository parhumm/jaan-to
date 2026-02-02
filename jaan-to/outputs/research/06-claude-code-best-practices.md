# Claude Code Best Practices

> Summary of: `deepresearch/dev-workflow/claude-code-best-practices.md`

## Key Points

- **CLAUDE.md structure**: Include project overview, tech stack, architecture, coding standards, and AI-specific guidelines
- **Keep CLAUDE.md focused**: Under 500 lines; avoid including entire codebases or irrelevant details
- **Custom commands**: Create `.claude/commands/` for repetitive tasks; use frontmatter for model, tools, description
- **MCP (Model Context Protocol)**: Configure servers for external tool access (databases, APIs, file systems)
- **Allowed tools**: Restrict tool access per command for security and token efficiency
- **Extended thinking**: Use "think", "think hard", "ultrathink" keywords to increase reasoning depth
- **Hooks system**: Configure pre/post hooks for tool calls (validation, logging, notifications)
- **Session management**: Use `/compact` to condense context, `/clear` between unrelated tasks

## Critical Insights

1. **Context quality > context quantity** - Focused, well-structured context outperforms verbose context
2. **Command library is force multiplier** - Well-designed commands encode team knowledge and reduce repetitive prompting
3. **Tool restrictions serve dual purpose** - Both security (limit damage) and efficiency (reduce token overhead)

## Quick Reference

| Feature | Location | Purpose |
|---------|----------|---------|
| CLAUDE.md | Project root | Project context for all sessions |
| Commands | `.claude/commands/` | Reusable task templates |
| Agents | `.claude/agents/` | Specialized subagent configurations |
| Settings | `.claude/settings.json` | Global/project settings |
| Hooks | Settings file | Pre/post tool call automation |

## CLAUDE.md Template Sections
1. Project Overview
2. Tech Stack & Dependencies
3. Architecture Patterns
4. Coding Standards
5. Testing Guidelines
6. AI Behavioral Guidelines
7. What NOT to do

## Command Frontmatter Options
```markdown
