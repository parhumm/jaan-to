# Claude Code Planning: Architecture, Best Practices, and Enterprise Integration

> Plan Mode architecture, 30-minute rule, enterprise configuration, hooks, and anti-patterns.
> Source: Local file (claude-code-planning-architecture-best-practices-and-enterprise-integration.md)
> Added: 2026-01-27

---

**Plan Mode transforms Claude Code from a reactive coding assistant into a deliberate, auditable development partner.** For enterprise plugin packs with layered configuration (Core → Product → Team), planning provides the structural control layer that separates research from execution, enables human review gates, and creates audit trails.

---

## How Plan Mode Actually Works Under the Hood

Claude Code's planning system operates through a **permission mode architecture** that fundamentally changes available tools. When Plan Mode is active (indicated by `⏸ plan mode on`), Claude enters a read-only research phase with access restricted to non-mutating operations: `Read`, `Glob`, `Grep`, `WebFetch`, `WebSearch`, and `AskUserQuestion`. File writes, bash execution, and code modifications are blocked entirely.

Three methods activate Plan Mode:
- **Keyboard**: `Shift+Tab` twice cycles through Normal → Auto-Accept → Plan
- **Slash command**: `/plan` enables plan mode directly from the prompt
- **CLI flag**: `claude --permission-mode plan` starts sessions in planning state

Plans themselves are stored as **markdown files in `~/.claude/plans/`**—a global directory, not project-level. This is a known limitation; multiple GitHub issues request project-scoped storage for version control. The SDK exposes four permission modes via TypeScript: `'default'`, `'acceptEdits'`, `'bypassPermissions'`, and `'plan'`.

When Claude completes planning, it invokes the **ExitPlanMode tool** which prompts users to approve the plan before execution begins. This creates a natural human gate—the plan exists as reviewable text before any changes occur.

### Plan vs Execution Mode: Key Differences

| Aspect | Plan Mode | Execution Mode |
|--------|-----------|----------------|
| File operations | Read-only | Read and write |
| Bash commands | Blocked | Available with permissions |
| Tool access | Research tools only | All tools |
| Subagent type | Plan subagent (research-focused) | Task subagent (full capabilities) |
| Visual indicator | `⏸ plan mode on` | None or `⏵⏵ accept edits on` |

The **Plan subagent** is a built-in specialized agent that handles codebase research during planning—it inherits the read-only constraints and cannot delegate to execution-capable agents.

---

## When Explicit Planning Delivers Value (and When It Doesn't)

The most consistent finding across all sources: **planning before implementation is non-negotiable for production code**. However, the investment varies by task complexity.

### High-Value Planning Scenarios

Explicit planning delivers outsized returns for:
- **Multi-file implementations** requiring coordinated changes across components
- **Complex architectural decisions** needing deep reasoning about tradeoffs
- **Major refactors** where understanding dependencies prevents cascading failures
- **Unknown codebases** where research prevents wasted implementation cycles
- **Team handoffs** where plans become communication outputs

Anthropic's recommended workflow follows an **Explore → Plan → Checkpoint → Implement → Commit** pattern. The exploration phase explicitly tells Claude *not to write code yet*—this separation prevents the "ready, fire, aim" anti-pattern where Claude jumps to implementation before understanding context.

### When to Skip Formal Planning

Planning overhead exceeds value for:
- Simple bug fixes with clear, isolated targets
- Small changes with obvious implementations
- Tasks with existing tests that define success criteria
- Quick formatting or linting fixes
- When you have a clear, verifiable target state

The decision heuristic: **if you can describe the complete change in one sentence and verify it with existing tests, skip planning**.

---

## Optimal Plan Granularity and the 30-Minute Rule

Plan effectiveness degrades at both extremes—too vague provides no guidance, too detailed becomes brittle. Community experience converges on the **30-minute rule**: scope plans to what can be accomplished in 30 minutes or less of implementation work.

Within that scope, **5-8 concrete steps** is the sweet spot for autonomous completion. Claude can work effectively for 10-20 minutes before context degradation affects quality. Beyond that, break into subtasks with their own plans.

Effective plan documents follow this structure:

```markdown
## Progress Summary
- [ ] Step 1: [Concrete action with specific file]
- [ ] Step 2: [Concrete action with specific file]

## Overview (2-3 sentences max)
## Current State Analysis
## Target State
## Implementation Steps (each names files to modify)
## Acceptance Criteria (functional, UI/UX, technical)
## Files Involved (new, modified, potentially affected)
```

Critical insight: Claude's built-in plans **do not persist** after sessions. Written plans in markdown files serve as persistent references for both humans and future Claude sessions. Store them in a tracked location like `docs/plans/` or `.claude/plans/`.

---

## Configuration Hierarchy for Layered Enterprise Architecture

Claude Code's configuration system maps directly to a Core → Product → Team layered model through its precedence hierarchy:

| Layer | Location | Scope | Your "jaan.to" Equivalent |
|-------|----------|-------|------------------------|
| **Enterprise managed** | `/Library/Application Support/ClaudeCode/managed-settings.json` | Organization-wide, cannot be overridden | Core |
| **User global** | `~/.claude/settings.json` | All projects for user | - |
| **Project shared** | `.claude/settings.json` | Team-shared, committed to git | Product |
| **Project local** | `.claude/settings.local.json` | Personal, gitignored | Team/Individual |

### Default to Plan Mode Organization-Wide

For enterprise environments requiring review gates:

```json
// managed-settings.json (Core layer)
{
  "permissions": {
    "defaultMode": "plan",
    "disableBypassPermissionsMode": "disable"
  }
}
```

This forces all sessions to start in Plan Mode—execution requires explicit exit approval.

### Model Selection Strategy: opusplan

The `opusplan` model alias provides automatic model switching:
- **In Plan Mode**: Uses Opus for complex reasoning and architecture decisions
- **In Execution Mode**: Automatically switches to Sonnet for code generation

This optimizes cost while maintaining reasoning quality where it matters most. Enable via `/model opusplan` or settings:

```json
{
  "model": "opusplan",
  "env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-5-20251101",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-5-20250929"
  }
}
```

---

## Hooks System Integration for Plan-Driven Workflows

The hooks system enables programmatic control over planning lifecycle. Key hook events for plan workflows:

| Event | Planning Use Case |
|-------|------------------|
| `UserPromptSubmit` | Inject planning context before Claude processes prompts |
| `PreToolUse` with `ExitPlanMode` matcher | Validate plans before execution approval |
| `Stop` | Evaluate if planning is complete; force continuation if not |
| `SubagentStop` | Validate Plan subagent completed research |
| `PostToolUse` | Log plan outputs for audit trails |

### Pre-Plan Context Injection

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/inject-planning-context.sh"
      }]
    }]
  }
}
```

### Plan Validation Gate

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "ExitPlanMode",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validate-plan.sh"
      }]
    }]
  }
}
```

The validation script receives plan content via stdin and can return `{"decision": "block", "reason": "Plan missing acceptance criteria"}` to prevent execution without proper planning.

### LLM-Evaluated Stop Conditions

For intelligent planning completion:

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Return continue:true if plan is incomplete."
      }]
    }]
  }
}
```

---

## Human-in-the-Loop Gate Patterns

### Built-in Permission Gates

Claude Code's permission system provides three control points:

```json
{
  "permissions": {
    "allow": ["Read", "Bash(git status:*)"],
    "ask": ["Write(src/**)", "Bash(npm:*)"],
    "deny": ["Bash(rm -rf:*)", "Write(.env*)"]
  }
}
```

For enterprise workflows requiring human approval on all changes, set `"ask"` as the default and explicitly `"allow"` only read operations.

### Two-Phase Review Pattern

A production-proven pattern separates AI analysis from human decision:

1. **Phase 1**: Claude creates PENDING review with findings and recommendations
2. **Phase 2**: Human reviews findings, requests changes, or approves
3. **Phase 3**: Upon approval, Claude executes with implementation
4. **Phase 4**: Human maintains final merge authority

This maps to Plan Mode → Review → Execution → PR Review.

### Confidence-Based Routing

```python
if finding.confidence >= 80:
    post_as_pr_comment()  # Auto-proceed with visibility
elif finding.is_security_critical:
    escalate_to_human()   # Hard gate
else:
    log_for_internal_review()  # Async review
```

### HARD STOP Markers in Plans

For explicit checkpoints in multi-step plans:

```markdown
## Tasks
- [ ] 1. Initialize database schema
- [ ] 2. Implement model classes
- [ ] 3. **HARD STOP** - Checkpoint: verify migrations run correctly
- [ ] 4. Add API endpoints
- [ ] 5. Write integration tests
```

Claude recognizes these markers and pauses for human confirmation.

---

## Checkpoint, Resume, and Rollback Strategies

### Native Checkpointing

Claude Code **automatically checkpoints** before each file edit. Access via:
- `Esc` twice → Opens rewind menu
- `/rewind` command

Options include restoring conversation only, code only, or both. However, checkpoints **do not track bash command changes** (`rm`, `mv`, database operations)—only file edits.

### Session Resumption

```bash
claude --continue          # Resume most recent session
claude --resume            # Interactive session picker
claude -p "continue implementing step 3" --continue  # Non-interactive
```

Sessions persist locally with 30-day retention. For long-running tasks, name sessions early via `/rename` for easy retrieval.

### Git-Based Rollback Strategy

For production safety, layer git commits as checkpoints:

```bash
# Commit after each plan step
git commit -m "Plan step 1: Initialize database schema"

# Rollback on failure
git reset --hard HEAD~1
```

Pattern for multi-step execution:
1. Start in Plan Mode, create written plan
2. Execute step 1, verify, commit
3. Execute step 2, verify, commit
4. On failure at step N, `git reset` to step N-1
5. Re-plan step N with learnings from failure

### Parallel Execution via Worktrees

For team coordination without conflicts:

```bash
git worktree add ../feature-auth feature/auth
git worktree add ../feature-payments feature/payments

# Run independent Claude sessions
cd ../feature-auth && claude
cd ../feature-payments && claude
```

Each worktree provides isolated context—no cross-contamination of plans or changes.

---

## Planning at Scale: Monorepo and Team Coordination

### CLAUDE.md Hierarchy for Monorepos

```
project/
├── CLAUDE.md                    # Root: global patterns, architecture
├── packages/
│   ├── frontend/
│   │   └── CLAUDE.md            # Module: React conventions, component patterns
│   ├── backend/
│   │   └── CLAUDE.md            # Module: API conventions, DB patterns
│   └── shared/
│       └── CLAUDE.md            # Module: shared type definitions
└── .claude/
    └── rules/
        ├── security.md          # Cross-cutting: security requirements
        └── testing.md           # Cross-cutting: test conventions
```

Keep root CLAUDE.md under **10,000 words**—longer files cause Claude to ignore sections. Use `@imports` to reference detailed documentation:

```markdown
## Architecture
See @docs/architecture.md for system design
See @docs/api-contracts.md for API specifications
```

### Shared Command Library

Team commands in `.claude/commands/` become available via `/project:command-name`:

```markdown
# .claude/commands/fix-github-issue.md
Analyze and fix GitHub issue: $ARGUMENTS

Process:
1. Use `gh issue view $ARGUMENTS` for details
2. Search codebase for relevant files
3. Create plan in Plan Mode
4. Implement fix after plan approval
5. Write regression test
6. Create PR with issue reference
```

Check `.claude/commands/` into version control for team-wide consistency.

### Plan Versioning with Git

Store plans as tracked outputs:

```
docs/plans/
├── active/
│   └── feature-auth-v2.md
├── completed/
│   └── feature-auth-v1.md
└── templates/
    └── feature-template.md
```

Git history provides versioning; PRs provide review mechanism for plan changes before execution.

---

## Critical Anti-Patterns to Avoid

### Context Pollution ("Kitchen Sink Session")

**Problem**: Starting with one task, switching to unrelated work, returning to original—context fills with irrelevant information.

**Fix**: Use `/clear` between unrelated tasks. One task per session for complex work.

### The Correction Spiral

**Problem**: Claude makes mistake, you correct, still wrong, correct again. Context becomes polluted with failed approaches.

**Fix**: After **two failed corrections**, `/clear` and write a better initial prompt incorporating learnings.

### CLAUDE.md Overload

**Problem**: CLAUDE.md exceeds 10,000 words; Claude ignores important rules lost in noise.

**Fix**: Ruthlessly prune. If Claude already does something correctly without the instruction, delete it. Convert behavioral rules to hooks where possible.

### Trust-Then-Verify Gap

**Problem**: Claude produces plausible-looking code that doesn't handle edge cases.

**Fix**: Include tests, screenshots, or expected outputs so Claude can self-verify. This is **the single highest-leverage practice**.

### Subagents for Implementation

**Problem**: Spawning subagents for coding tasks—they lack project context.

**Fix**: Use subagents only for exploration/research. Keep implementation in main context.

### Vibe Coding Complex Features

**Problem**: Asking Claude to "just implement" large features without planning produces messy, debug-heavy code.

**Community consensus**: "Vibe coding works for throwaway MVPs; production code requires structured planning, validation, and documentation."

---

## Audit Trails and Compliance Integration

### Enterprise Audit Logging

Claude Code supports compliance requirements through:
- SOC 2 Type II certified infrastructure
- Compliance API for real-time usage/conversation logs
- Zero Data Retention (ZDR) endpoints
- SAML/OIDC SSO integration

### Hooks-Based Audit Capture

```json
{
  "hooks": {
    "PreToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "audit-log.sh pre-tool $SESSION_ID $TOOL_NAME"
      }]
    }],
    "PostToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "audit-log.sh post-tool $SESSION_ID $TOOL_NAME $EXIT_CODE"
      }]
    }]
  }
}
```

### Minimum Audit Fields

For compliance, capture:
- User authentication events
- Repository/codebase access
- Code modifications accepted (with diffs)
- Plan approval/rejection decisions
- Security policy violations
- Human override actions with justification

Plans themselves serve as audit outputs—written plans with timestamps document the reasoning before changes.

---

## Implementation Architecture for Enterprise Plugin Packs

For an "jaan.to" with Core → Product → Team layering, implement planning as a control layer:

### Plan Execution Engine

```yaml
plan_engine:
  storage:
    format: yaml  # Structured for programmatic access
    location: .claude/plans/active/
    versioning: git-tracked

  step_tracking:
    states: [pending, in_progress, completed, failed, blocked]
    metadata: [started_at, completed_at, executor, approval_by]

  rollback:
    strategy: git_reset
    checkpoint_on: step_completion
```

### Human Gate Framework

```yaml
human_gates:
  triggers:
    - confidence_below: 80
    - file_sensitivity: [.env, secrets/, production.*]
    - security_impact: [auth, permissions, crypto]
    - plan_exit: always  # Require approval to exit Plan Mode

  workflow:
    notification: [slack, email]
    approval: async_with_timeout
    override: requires_justification

  audit:
    log_all_decisions: true
    include_context: true
```

### Layered Configuration Schema

```yaml
# Core (managed-settings.json)
core:
  permissions:
    defaultMode: plan
    disableBypassPermissionsMode: disable
  security:
    deny: [Bash(rm -rf:*), Write(.env*)]

# Product (.claude/settings.json)
product:
  model: opusplan
  hooks:
    PreToolUse: [validate-plan-hook]
    PostToolUse: [audit-log-hook]

# Team (.claude/settings.local.json)
team:
  permissions:
    allow: [Bash(npm test:*)]  # Team-specific tools
```

---

## Conclusion: Key Decision Points for Implementation

**Planning mode selection**: Default to Plan Mode (`defaultMode: plan`) for enterprise environments; use explicit opt-out for simple tasks rather than opt-in for complex ones.

**Model strategy**: Use `opusplan` to optimize reasoning quality in planning while controlling execution costs. Override at Product layer for cost-sensitive teams.

**Gate placement**: Insert human gates at Plan Mode exit (always), security-sensitive files (configurable), and low-confidence decisions (threshold-based). Avoid gates on every step—balance safety with velocity.

**Context management**: Enforce 60% context ceiling through aggressive `/clear` usage and file-based plan persistence. Context pollution is the primary failure mode.

**Audit integration**: Capture plan approval decisions, not just execution results. Plans are the reasoning outputs; modifications are the outcomes.

**Anti-pattern prevention**: Build validation hooks to catch correction spirals (>2 failed attempts triggers auto-clear), CLAUDE.md bloat (warn at 8,000 words), and missing acceptance criteria in plans.

The fundamental insight: **Plan Mode isn't just a feature—it's an architectural pattern** that separates intent from action, enables review, and creates accountability. For enterprise plugin packs, planning provides the control plane that makes autonomous agent execution safe and auditable.
