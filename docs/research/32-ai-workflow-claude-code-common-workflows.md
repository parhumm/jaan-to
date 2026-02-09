# Common Workflows

> Step-by-step guides for exploring codebases, fixing bugs, refactoring, testing, and other everyday tasks with Claude Code.
> Source: https://code.claude.com/docs/en/common-workflows.md
> Added: 2026-01-29

---

This page covers practical workflows for everyday development: exploring unfamiliar code, debugging, refactoring, writing tests, creating PRs, and managing sessions. Each section includes example prompts you can adapt to your own projects.

## Understand New Codebases

### Get a Quick Codebase Overview

1. Navigate to the project root and start Claude Code
2. Ask for a high-level overview: `give me an overview of this codebase`
3. Dive deeper into specific components:
   - `explain the main architecture patterns used here`
   - `what are the key data models?`
   - `how is authentication handled?`

**Tips**:
- Start with broad questions, then narrow down to specific areas
- Ask about coding conventions and patterns used in the project
- Request a glossary of project-specific terms

### Find Relevant Code

1. Ask Claude to find relevant files: `find the files that handle user authentication`
2. Get context on how components interact: `how do these authentication files work together?`
3. Understand the execution flow: `trace the login process from front-end to database`

**Tips**:
- Be specific about what you're looking for
- Use domain language from the project
- Install a code intelligence plugin for your language to give Claude precise "go to definition" and "find references" navigation

---

## Fix Bugs Efficiently

1. Share the error with Claude: `I'm seeing an error when I run npm test`
2. Ask for fix recommendations: `suggest a few ways to fix the @ts-ignore in user.ts`
3. Apply the fix: `update user.ts to add the null check you suggested`

**Tips**:
- Tell Claude the command to reproduce the issue and get a stack trace
- Mention any steps to reproduce the error
- Let Claude know if the error is intermittent or consistent

---

## Refactor Code

1. Identify legacy code: `find deprecated API usage in our codebase`
2. Get refactoring recommendations: `suggest how to refactor utils.js to use modern JavaScript features`
3. Apply the changes safely: `refactor utils.js to use ES2024 features while maintaining the same behavior`
4. Verify: `run tests for the refactored code`

**Tips**:
- Ask Claude to explain the benefits of the modern approach
- Request that changes maintain backward compatibility when needed
- Do refactoring in small, testable increments

---

## Use Specialized Subagents

1. **View available subagents**: `/agents`
2. **Use subagents automatically** — Claude delegates appropriate tasks:
   - `review my recent code changes for security issues`
   - `run all tests and fix any failures`
3. **Explicitly request specific subagents**:
   - `use the code-reviewer subagent to check the auth module`
   - `have the debugger subagent investigate why users can't log in`
4. **Create custom subagents**: `/agents` → "Create New subagent" → define identifier, when to use, tool access, system prompt

**Tips**:
- Create project-specific subagents in `.claude/agents/` for team sharing
- Use descriptive `description` fields to enable automatic delegation
- Limit tool access to what each subagent actually needs

---

## Use Plan Mode for Safe Code Analysis

Plan Mode instructs Claude to create a plan by analyzing the codebase with read-only operations. Claude uses `AskUserQuestion` to gather requirements and clarify goals before proposing a plan.

### When to Use Plan Mode

- **Multi-step implementation**: Feature requires edits to many files
- **Code exploration**: Research the codebase thoroughly before changing anything
- **Interactive development**: Iterate on the direction with Claude

### How to Use Plan Mode

| Method | Command |
|:--|:--|
| Toggle during session | **Shift+Tab** (cycles: Normal → Auto-Accept → Plan) |
| Start new session | `claude --permission-mode plan` |
| Headless query | `claude --permission-mode plan -p "Analyze the authentication system"` |
| Set as default | Add `"permissions": {"defaultMode": "plan"}` to `.claude/settings.json` |

**Tip**: Press `Ctrl+G` to open the plan in your default text editor, where you can edit it directly before Claude proceeds.

---

## Work with Tests

1. Identify untested code: `find functions in NotificationsService.swift that are not covered by tests`
2. Generate test scaffolding: `add tests for the notification service`
3. Add meaningful test cases: `add test cases for edge conditions in the notification service`
4. Run and verify: `run the new tests and fix any failures`

Claude examines existing test files to match the style, frameworks, and assertion patterns already in use. Ask Claude to identify edge cases — it can analyze code paths and suggest tests for error conditions, boundary values, and unexpected inputs.

---

## Create Pull Requests

**Quick method**: `/commit-push-pr` — commits, pushes, and opens a PR in one step.

If you have a Slack MCP server configured and channels specified in CLAUDE.md, the skill automatically posts the PR URL to those channels.

**Step-by-step method**:
1. Summarize changes: `summarize the changes I've made to the authentication module`
2. Generate PR: `create a pr`
3. Review and refine: `enhance the PR description with more context about the security improvements`

---

## Handle Documentation

1. Identify undocumented code: `find functions without proper JSDoc comments in the auth module`
2. Generate documentation: `add JSDoc comments to the undocumented functions in auth.js`
3. Review and enhance: `improve the generated documentation with more context and examples`
4. Verify: `check if the documentation follows our project standards`

**Tips**:
- Specify the documentation style you want (JSDoc, docstrings, etc.)
- Ask for examples in the documentation
- Request documentation for public APIs, interfaces, and complex logic

---

## Work with Images

**Methods to add images**:
1. Drag and drop an image into the Claude Code window
2. Copy and paste with `Ctrl+V` (not `Cmd+V`)
3. Provide a path: `Analyze this image: /path/to/your/image.png`

**Use cases**:
- `What does this image show?`
- `Describe the UI elements in this screenshot`
- `Here's a screenshot of the error. What's causing it?`
- `Generate CSS to match this design mockup`

**Tips**:
- You can work with multiple images in a conversation
- Works with diagrams, screenshots, mockups, and more
- `Cmd+Click` (Mac) or `Ctrl+Click` (Windows/Linux) image references to open them

---

## Reference Files and Directories

Use `@` to quickly include files or directories without waiting for Claude to read them.

| Syntax | What it does |
|:--|:--|
| `@src/utils/auth.js` | Includes full file content |
| `@src/components` | Provides directory listing |
| `@github:repos/owner/repo/issues` | Fetches MCP resource data |

**Tips**:
- File paths can be relative or absolute
- `@` file references add `CLAUDE.md` in the file's directory and parent directories to context
- You can reference multiple files in a single message

---

## Use Extended Thinking

Extended thinking is enabled by default, reserving up to 31,999 tokens for Claude to reason through complex problems step-by-step. Visible in verbose mode (`Ctrl+O`).

Particularly valuable for: complex architectural decisions, challenging bugs, multi-step implementation planning, evaluating tradeoffs.

> Phrases like "think", "think hard", "ultrathink", and "think more" are interpreted as regular prompt instructions and don't allocate thinking tokens.

### Configure Thinking Mode

| Scope | How |
|:--|:--|
| Toggle shortcut | `Option+T` (macOS) or `Alt+T` (Windows/Linux) |
| Global default | `/config` to toggle thinking mode |
| Limit budget | Set `MAX_THINKING_TOKENS` environment variable |

### Token Budgets

- **Enabled**: Up to 31,999 tokens for internal reasoning
- **Disabled**: 0 tokens for thinking
- **Limited**: Set `MAX_THINKING_TOKENS` to cap the budget

> You're charged for all thinking tokens used, even though Claude 4 models show summarized thinking.

---

## Resume Previous Conversations

| Method | Usage |
|:--|:--|
| Continue most recent | `claude --continue` |
| Open picker | `claude --resume` |
| Resume by name | `claude --resume auth-refactor` |
| Switch during session | `/resume` |

### Name Your Sessions

Use `/rename` during a session: `/rename auth-refactor`

### Session Picker Shortcuts

| Shortcut | Action |
|:--|:--|
| `↑` / `↓` | Navigate between sessions |
| `→` / `←` | Expand or collapse grouped sessions |
| `Enter` | Select and resume |
| `P` | Preview session content |
| `R` | Rename session |
| `/` | Search to filter |
| `A` | Toggle current directory / all projects |
| `B` | Filter to current git branch |
| `Esc` | Exit picker or search |

**Tips**:
- Name sessions early with `/rename` for easier discovery
- Use `--continue` for quick access to most recent conversation
- For scripts: `claude --continue --print "prompt"` for non-interactive mode
- Forked sessions (from `/rewind` or `--fork-session`) are grouped under root session

---

## Run Parallel Sessions with Git Worktrees

Git worktrees let you check out multiple branches into separate directories with isolated files while sharing Git history.

```bash
# Create worktree with new branch
git worktree add ../project-feature-a -b feature-a

# Create worktree with existing branch
git worktree add ../project-bugfix bugfix-123

# Run Claude Code in each worktree
cd ../project-feature-a && claude
cd ../project-bugfix && claude

# Manage worktrees
git worktree list
git worktree remove ../project-feature-a
```

**Tips**:
- Each worktree has independent file state — perfect for parallel Claude sessions
- Changes in one worktree won't affect others
- All worktrees share Git history and remote connections
- Remember to initialize dev environment in each new worktree (npm install, venv, etc.)

---

## Use Claude as a Unix-Style Utility

### As a Linter/Reviewer

```json
{
  "scripts": {
    "lint:claude": "claude -p 'you are a linter. please look at the changes vs. main and report any issues related to typos. report the filename and line number on one line, and a description of the issue on the second line. do not return any other text.'"
  }
}
```

### Pipe In, Pipe Out

```bash
cat build-error.txt | claude -p 'concisely explain the root cause of this build error' > output.txt
```

### Control Output Format

| Format | Flag | Use case |
|:--|:--|:--|
| Text (default) | `--output-format text` | Simple integrations, just Claude's response |
| JSON | `--output-format json` | Full conversation log with metadata (cost, duration) |
| Streaming JSON | `--output-format stream-json` | Real-time output of each conversation turn |

---

## Ask Claude About Its Capabilities

Claude has built-in access to its documentation:

- `can Claude Code create pull requests?`
- `how does Claude Code handle permissions?`
- `what skills are available?`
- `how do I use MCP with Claude Code?`
- `how do I configure Claude Code for Amazon Bedrock?`

Claude always has access to the latest Claude Code documentation regardless of version.

## Sources

- Anthropic Claude Code Documentation: [Common Workflows](https://code.claude.com/docs/en/common-workflows.md)
