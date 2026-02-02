# Best Practices for Claude Code

> Official tips and patterns for getting the most out of Claude Code, from configuring your environment to scaling across parallel sessions.
> Source: https://code.claude.com/docs/en/best-practices.md
> Added: 2026-01-29

---

## Core Principle

Most best practices stem from one constraint: **Claude's context window fills up fast, and performance degrades as it fills.** The context window holds your entire conversation, every file read, and every command output.

---

## Give Claude a Way to Verify Its Work

**The single highest-leverage thing you can do.**

| Strategy | Before | After |
|----------|--------|-------|
| Provide verification criteria | "implement a function that validates email addresses" | "write a validateEmail function. example test cases: user@example.com is true, invalid is false. run the tests after implementing" |
| Verify UI changes visually | "make the dashboard look better" | "[paste screenshot] implement this design. take a screenshot and compare" |
| Address root causes | "the build is failing" | "the build fails with this error: [paste]. fix it and verify the build succeeds" |

---

## Explore First, Then Plan, Then Code

Four-phase workflow:

1. **Explore** (Plan Mode): Read files, understand the codebase
2. **Plan** (Plan Mode): Create detailed implementation plan. `Ctrl+G` to edit in text editor
3. **Implement** (Normal Mode): Code against the plan, run tests
4. **Commit** (Normal Mode): Descriptive message + PR

> Skip planning when scope is clear and fix is small. Planning is most useful when uncertain about approach, modifying multiple files, or unfamiliar with the code.

---

## Provide Specific Context

| Strategy | Example |
|----------|---------|
| Scope the task | "write a test for foo.py covering the edge case where the user is logged out. avoid mocks." |
| Point to sources | "look through ExecutionFactory's git history and summarize how its api came to be" |
| Reference existing patterns | "look at how existing widgets are implemented. HotDogWidget.php is a good example. follow the pattern" |
| Describe the symptom | "users report that login fails after session timeout. check the auth flow in src/auth/" |

### Rich Content Options
- **`@` references**: Reference files directly
- **Paste images**: Copy/paste or drag & drop
- **Give URLs**: Use `/permissions` to allowlist domains
- **Pipe data**: `cat error.log | claude`
- **Let Claude fetch**: Tell Claude to pull context itself

---

## Configure Your Environment

### CLAUDE.md Best Practices

Run `/init` to generate a starter file, then refine.

| Include | Exclude |
|---------|---------|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions | File-by-file descriptions |
| Developer environment quirks | Self-evident practices |

**Key tips:**
- Keep it concise. Bloated files cause Claude to ignore instructions
- Use emphasis ("IMPORTANT", "YOU MUST") to improve adherence
- Check into git so your team contributes
- Use `@path/to/import` syntax for imports
- Place in: home (`~/.claude/CLAUDE.md`), project root, parent/child directories

### Configure Permissions
- **Permission allowlists**: `/permissions` to permit safe commands
- **Sandboxing**: `/sandbox` for OS-level isolation
- **`--dangerously-skip-permissions`**: Only in sandbox without internet

### CLI Tools
Install `gh`, `aws`, `gcloud`, `sentry-cli` etc. Claude knows how to use them.

### MCP Servers
`claude mcp add` to connect Notion, Figma, databases, etc.

### Hooks
Deterministic actions at specific workflow points. Unlike CLAUDE.md (advisory), hooks are guaranteed.

### Skills
`SKILL.md` files in `.claude/skills/` for domain knowledge and reusable workflows.

### Subagents
Specialized assistants in `.claude/agents/` with own context and tool access.

### Plugins
Run `/plugin` to browse marketplace for bundled skills, hooks, subagents, and MCP servers.

---

## Communicate Effectively

### Ask Codebase Questions
- How does logging work?
- How do I make a new API endpoint?
- What does `async move { ... }` do on line 134 of `foo.rs`?

### Let Claude Interview You
```
I want to build [brief description]. Interview me in detail using the AskUserQuestion tool.
Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs.
Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

Then start a fresh session to execute the spec.

---

## Manage Your Session

### Course-Correct Early
- **`Esc`**: Stop mid-action
- **`Esc + Esc`** or **`/rewind`**: Restore previous state
- **`"Undo that"`**: Revert changes
- **`/clear`**: Reset context between unrelated tasks

> After 2+ failed corrections, `/clear` and start fresh with a better prompt.

### Manage Context Aggressively
- `/clear` frequently between tasks
- Auto compaction summarizes when context fills
- `/compact <instructions>` for manual control
- Customize compaction in CLAUDE.md

### Use Subagents for Investigation
```
Use subagents to investigate how our authentication system handles token
refresh, and whether we have any existing OAuth utilities I should reuse.
```
Subagents explore in separate context, report back summaries.

### Rewind with Checkpoints
Every action creates a checkpoint. Double-tap `Escape` or `/rewind`:
- Restore conversation only (keep code)
- Restore code only (keep conversation)
- Restore both

### Resume Conversations
```bash
claude --continue    # Resume most recent
claude --resume      # Select from recent
```
Use `/rename` for descriptive session names.

---

## Automate and Scale

### Headless Mode
```bash
claude -p "Explain what this project does"
claude -p "List all API endpoints" --output-format json
claude -p "Analyze this log file" --output-format stream-json
```

### Multiple Parallel Sessions
- **Claude Desktop**: Multiple local sessions with isolated worktrees
- **Claude Code on the web**: Secure cloud VMs

**Writer/Reviewer pattern**: Session A implements, Session B reviews in fresh context.

### Fan Out Across Files
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

---

## Common Failure Patterns

| Pattern | Fix |
|---------|-----|
| Kitchen sink session (mixing unrelated tasks) | `/clear` between unrelated tasks |
| Correcting over and over | After 2 failures, `/clear` + better prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert to hooks |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope narrowly or use subagents |

---

## Key Takeaway

Pay attention to what works. Notice prompt structure, context provided, and mode used when Claude produces great output. Develop intuition for when to be specific vs open-ended, when to plan vs explore, when to clear context vs let it accumulate.
