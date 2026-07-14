# Building skill discovery across AI coding tools

**The three dominant AI coding tools — Claude Code, OpenAI Codex, and Cursor — all support reusable skills and MCP integration but lack automated pattern detection, creating a clear opportunity for a Jaan.to skill discovery layer.** Claude Code offers the richest integration surface via its 12+ lifecycle hooks and JSONL session transcripts. Codex provides MCP server mode and a TypeScript SDK. Cursor relies on VS Code extension events and MCP tools. None of these tools proactively detect repeated developer workflows or suggest automations — the exact gap a skill discovery system fills. This guide provides a complete comparative analysis and a production-ready implementation blueprint.

---

## How each tool handles memory, context, and reuse today

All three tools have converged on remarkably similar patterns: markdown-based project instructions (CLAUDE.md / AGENTS.md / .cursor/rules), directory-based skill storage (SKILL.md), and MCP as the extensibility protocol. The differences lie in depth of implementation and integration surface area.

### Claude Code: deepest configuration surface

Claude Code's memory system is a **four-tier hierarchy** loaded at session start. Enterprise policies sit at OS-level paths, user memory at `~/.claude/CLAUDE.md`, project memory at `./CLAUDE.md` or `./.claude/CLAUDE.md`, and local project memory at `./CLAUDE.local.md` (auto-gitignored). Files are read recursively upward from the working directory. The `@path/to/import` syntax enables composition across files, with recursive imports up to 5 hops.

Auto-memory is a newer feature where Claude writes persistent notes at `~/.claude/projects/<project>/memory/MEMORY.md`, including topic-specific files like `debugging.md` or `api-conventions.md`. This is the closest any tool comes to cross-session learning, though it is passive note-taking rather than active pattern recognition.

The **hooks system** is Claude Code's most powerful feature for external integration. Twelve lifecycle events fire deterministically: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `PreCompact`, `Notification`, `PermissionRequest`, `Setup`, and several newer events. Each hook can run shell commands, LLM prompts (via Haiku), or spawn subagents with codebase access. Matchers use case-sensitive regex against tool names. Hooks receive full JSON payloads via stdin including `session_id`, `transcript_path`, `tool_name`, `tool_input`, and `tool_response` — providing comprehensive observability into every action Claude takes.

**Skills** follow the emerging Agent Skills open standard, stored as `SKILL.md` files that bundle instructions with scripts, templates, and assets. Claude auto-discovers skills whose descriptions match the current task context. Custom slash commands (`.claude/commands/*.md`) support `$ARGUMENTS` interpolation, YAML frontmatter for tool allowlists and model selection, and backtick syntax for pre-execution bash commands.

Claude Code also has **native OpenTelemetry support** exporting metrics (session counts, lines changed, token usage, costs) and events (tool decisions, API requests, user prompts) to any OTEL-compatible backend.

### OpenAI Codex: two products, one ecosystem

OpenAI ships Codex as an interconnected suite. **Codex CLI** is open-source (Apache-2.0, Rust), installed via `npm i -g @openai/codex`. **ChatGPT Codex** runs tasks in isolated cloud containers at `chatgpt.com/codex`. The **Codex App** (macOS desktop) bridges both with worktree support and automation management.

For context persistence, Codex CLI stores session transcripts at `~/.codex/sessions/` with `codex resume` commands for continuation. Project context uses **AGENTS.md** files, read recursively from git root to working directory — functionally equivalent to CLAUDE.md. The `project_doc_max_bytes` setting (default 32 KiB) caps instruction size. ChatGPT Codex caches container state for **up to 12 hours** between tasks, invalidated on setup/env changes.

Codex's **Skills system** mirrors Claude Code's: SKILL.md files at repo (`/.codex/skills/`), user (`~/.codex/skills/`), admin (`/etc/codex/skills/`), and system scopes. Built-in skills include `$plan`, `$skill-creator`, and `$skill-installer`. Codex auto-selects matching skills based on description — the same progressive disclosure pattern. Configuration uses `config.toml` with named profiles (e.g., `[profiles.deep-review]`) for switching between workflow configurations.

**Codex has no hooks system.** This is the most significant architectural difference from Claude Code. Integration requires the TypeScript SDK, the app-server JSON-RPC protocol, or wrapping `codex exec --json` for structured output. However, Codex can run as an MCP server (`codex mcp-server`), exposing `codex` and `codex-reply` tools to other agents — a unique capability for multi-agent orchestration.

Codex's **multi-agent system** is experimental but rich: configure agent roles in `[agents]` sections of config.toml, each running in isolated git worktrees with separate config files. Full traces are captured in the OpenAI Traces dashboard.

### Cursor: IDE-native with marketplace ambitions

Cursor, a VS Code fork now valued at **$10B+** with over $1B annualized revenue, has the broadest user base but the shallowest programmatic integration surface.

The **Rules system** replaces the deprecated `.cursorrules` file with `.cursor/rules/*.mdc` (MDC = Markdown with YAML frontmatter). Four application modes control when rules activate: `alwaysApply: true` for every context, glob-matched auto-attachment for file-specific rules, description-based agent-requested rules, and manual `@ruleName` invocation. Team rules propagate through a dashboard to all members. Agent rules use the same `AGENTS.md` convention as Codex.

**Notepads** are Cursor-specific: markdown-based context bundles that reference files, folders, docs, and web links via `@` mentions. They sync across local workspaces but aren't version-controlled. The **Memories** feature (since v1.0) extracts facts from conversations and persists them, but requires sharing data with Cursor's servers — disabled in Privacy/Ghost Mode.

Cursor's **Agent Mode** (default via ⌘I) autonomously plans and executes multi-file changes, creates terminals, runs commands, and iterates on errors. The **Composer model** (Cursor 2.0, October 2025) is their own frontier coding model with ~4× speed improvements. **Background Agents** run in isolated Ubuntu VMs, work on separate branches, and can open PRs — kicked off from the IDE, Slack, or mobile.

**Hooks** arrived in v1.7 (beta) as custom scripts at agent lifecycle points, configured in `hooks.json`. The **Plugins & Marketplace** launched in February 2026 with curated bundles from Amplitude, AWS, Figma, Linear, and Stripe — each packaging MCP servers, skills, subagents, rules, and hooks.

Critically, Cursor **does not expose AI interactions through its extension API**. You cannot intercept what users ask the Composer/Agent or what code changes it proposes. Only file-level and terminal events are capturable through the VS Code extension API. The `vscode.cursor.mcp.registerServer` API allows programmatic MCP server registration, which is the primary extension point.

---

## The skill discovery gap none of these tools fill

**No tool currently detects repeated developer workflows or proactively suggests automations.** This is confirmed across all three ecosystems.

Claude Code's auto-memory is passive note-taking. Codex's implicit skill matching selects from existing skills but doesn't create new ones. Cursor's Agent Autocomplete suggests files and context based on recent edits, but doesn't analyze workflow patterns. BugBot proactively finds bugs in PRs — the closest to proactive intelligence — but operates on code quality, not workflow optimization.

The community has partially filled this gap. Third-party memory MCP servers (mem0, claude-mem, Recallium) add persistent knowledge graphs. The `$skill-creator` built-in skill in Codex generates new skills from descriptions. Community-created "Memory Bank" rules in Cursor write to `memory_bank/` directories. But **no existing system watches developer actions, detects repeated sequences, and suggests reusable automations** — this is the Jaan.to opportunity.

---

## Reference architecture for the Jaan.to skill discovery pipeline

The pipeline transforms raw developer events into ranked automation suggestions through six stages: instrumentation, normalization, segmentation, pattern discovery, generalization, and suggestion delivery.

### Instrumentation layer: what to capture from each tool

**Claude Code** provides the richest capture surface. Deploy hooks on `PreToolUse` (all tools), `PostToolUse` (all tools), `UserPromptSubmit`, `SessionStart`, and `Stop`. Each hook receives full JSON payloads including tool name, input, output, session ID, and transcript path. Additionally, parse JSONL session transcripts at `~/.claude/projects/<project>/sessions/<uuid>.jsonl` for complete conversation records including thinking blocks, token usage, and subagent spawn events.

**Cursor** requires a VS Code extension capturing `onDidChangeTextDocument` (file edits), `onDidSaveTextDocument` (saves), `onDidChangeActiveTextEditor` (context switches), and terminal data via `onDidWriteTerminalData`. Register a capture MCP server via `vscode.cursor.mcp.registerServer` for Agent-invoked logging. Hooks (v1.7 beta) provide `afterFileEdit` events but lack the breadth of Claude Code's system.

**Codex** uses the TypeScript SDK to wrap `thread.run()` calls and capture results programmatically. The `codex exec --json` mode streams structured JSONL events. Connect the shared MCP capture server via `config.toml`. The app-server JSON-RPC protocol provides `turn/start` and command execution events for embedded usage.

**Cross-cutting watchers** operate regardless of tool: `chokidar` or `watchman` for file system events, git hooks (`post-commit`, `pre-push`) for commit-level capture, and shell wrappers for terminal session recording.

### Event schema: the canonical action record

Every captured event normalizes into this structure:

```typescript
interface SkillDiscoveryEvent {
  event_id: string;                    // UUID
  timestamp: number;                   // Unix milliseconds
  source_tool: "claude-code" | "cursor" | "codex-cli" | "codex-cloud";
  session_id: string;                  // Groups related events
  
  action: {
    type: string;                      // Canonical: file.edit, terminal.command, git.commit
    sub_type?: string;                 // Specific: save, rename, run_test, install_dep
    result: "success" | "error" | "timeout" | "pending";
    duration_ms?: number;
  };
  
  target: {
    type: "file" | "terminal" | "git" | "browser" | "tool";
    language?: string;                 // typescript, python, etc.
    file_hash?: string;                // SHA-256 of relative path (never raw paths)
    component: "source" | "test" | "config" | "docs" | "infra";
  };
  
  context: {
    project_hash: string;              // Hashed project identifier
    framework?: string;                // react, django, etc.
    task_id?: string;                  // Linked ticket/issue if available
    preceding_event_id?: string;       // Causal chain
    time_since_previous_ms: number;
  };
}
```

The **action type taxonomy** uses a two-level hierarchy: `file.open`, `file.edit`, `file.save`, `file.create`, `file.delete`, `file.rename`, `terminal.command`, `terminal.output.error`, `terminal.output.success`, `git.commit`, `git.push`, `git.branch`, `git.merge`, `test.run`, `test.pass`, `test.fail`, `build.start`, `build.success`, `build.fail`, `review.comment`, `review.approve`, `search.code`, `search.web`, `refactor.rename`, `refactor.extract`, `dependency.install`, `dependency.update`. This taxonomy must be extensible — new sub-types added without breaking existing patterns.

### Segmentation: splitting sessions into meaningful episodes

Raw event streams must be segmented into episodes — coherent sequences representing a single developer intent. Three signals drive segmentation:

**Temporal gaps** greater than 5 minutes between events suggest a context switch. **Intent markers** like git commits, test runs, or new file creation often bracket episodes. **Tool switches** (moving from terminal to editor to browser) often signal phase transitions within an episode.

The segmenter uses a sliding window approach: maintain a buffer of events, compute a "coherence score" based on temporal proximity (inverse of gap), target similarity (same files = high), and action pattern (edit-test-edit = single episode). When coherence drops below threshold, split.

### Pattern discovery: three complementary approaches

**Frequency-based mining** is the fastest path to production. Apply sequential pattern mining (PrefixSpan or GSP algorithm) on segmented episodes. Extract all subsequences of length 2-8 that occur with support ≥ 3 (minimum three independent occurrences). Rank by frequency × average sequence length. This catches the "edit-test-fail-edit-test-pass" loop and similar common patterns within days.

**Clustering-based discovery** groups structurally similar episodes using edit-distance metrics on action sequences. Convert each episode to a string of action type codes, compute Levenshtein distance between all pairs, and apply DBSCAN clustering. Each cluster represents a workflow archetype. The cluster centroid becomes the canonical pattern.

**LLM-based generalization** uses an LLM to analyze a batch of clustered episodes and abstract them into parameterized skill templates. This is the SkillRL approach: the model identifies variable components (specific files, commands, error types) and replaces them with parameters. The model also generates a natural-language description suitable for the SKILL.md `description` field.

---

## Ten coding workflow patterns that become generic skills

Each pattern includes the action sequence, parameterizable components, and the skill interface.

**1. Error diagnosis and fix cycle**: `terminal.output.error → search.code → file.edit → terminal.command → terminal.output.success`. Parameters: error_type, search_scope, fix_strategy. This is the highest-frequency pattern in most codebases, occurring **5-20 times per developer per day**.

**2. Red-green-refactor loop**: `file.edit(test) → test.run → test.fail → file.edit(source) → test.run → test.pass → refactor.extract`. Parameters: test_framework, source_file, refactor_type. Stable, highly parameterizable.

**3. CI pipeline repair**: `build.fail → terminal.command(read_logs) → search.code → file.edit → git.commit → git.push → build.start`. Parameters: ci_system, log_source, fix_category. High time savings per occurrence (**15-30 minutes**).

**4. Dependency update workflow**: `dependency.update → build.start → build.fail → file.edit(config) → test.run → git.commit`. Parameters: package_manager, dependency_name, breaking_change_type.

**5. Code review response pattern**: `review.comment(received) → file.edit → test.run → git.commit → git.push → review.comment(resolved)`. Parameters: review_platform, comment_type, resolution_strategy.

**6. Feature scaffolding**: `file.create(source) → file.create(test) → file.edit(source, boilerplate) → file.edit(test, boilerplate) → file.edit(index, export)`. Parameters: component_type, framework, naming_convention.

**7. Migration execution**: `file.create(migration) → terminal.command(migrate_up) → test.run → terminal.command(migrate_down) → terminal.command(migrate_up) → git.commit`. Parameters: migration_framework, schema_change_type.

**8. API integration**: `search.web(docs) → file.create(client) → file.edit(client, auth) → file.edit(client, error_handling) → file.create(test) → test.run`. Parameters: api_name, auth_type, response_format.

**9. Merge conflict resolution**: `git.merge → terminal.output.error(conflict) → file.edit(resolve) → test.run → git.commit`. Parameters: merge_strategy, conflict_files, test_suite.

**10. Post-deployment verification**: `git.push → terminal.command(deploy) → search.web(monitoring) → terminal.command(health_check) → terminal.command(rollback|confirm)`. Parameters: deploy_target, monitoring_tool, health_endpoints.

---

## Scoring rubric: should this pattern become a skill?

Each candidate pattern scores on eight dimensions, weighted to produce a **0-100 composite score**. Patterns scoring above **65** are strong candidates; above **80** are near-certain automations.

| Dimension | Weight | Scoring (0-12.5 each at max weight) | Measurement |
|---|---|---|---|
| **Frequency** | 20% | 0=once, 5=monthly, 10=weekly, 15=daily, 20=multiple/day | Count occurrences over 30-day window |
| **Stability** | 15% | Coefficient of variation of action sequence across instances | Low variance = high score |
| **Time saved** | 20% | Median duration of manual execution × frequency | Estimated from event timestamps |
| **Parameterizability** | 15% | Ratio of variable to fixed steps; higher = more reusable | Automated via LLM analysis |
| **Risk** | 10% | Inverse: destructive operations (delete, deploy) reduce score | Flag git push, rm, deploy actions |
| **Dependencies** | 5% | Fewer external dependencies = higher score | Count unique external tools/services |
| **Explainability** | 10% | Can the pattern be described in ≤2 sentences? | LLM-generated description clarity score |
| **Failure tolerance** | 5% | Does the pattern have natural checkpoints/rollback? | Presence of test.run, git.commit in sequence |

**Formula**: `Score = Σ(weight_i × normalize(raw_score_i, 0, 1)) × 100`

Apply a **minimum frequency threshold** of 3 occurrences before scoring. Apply a **recency decay** — patterns not seen in 14 days lose 20% of their score per week. Patterns that a user has **dismissed** twice get a permanent -30 penalty (resettable).

---

## Skill specification standard: the machine-readable contract

Every discovered skill compiles into a SKILL.md-compatible specification that works across Claude Code, Codex, and Cursor:

```yaml
---
name: fix-test-failure
version: 1.2.0
description: "Diagnose and fix failing tests by reading error output, locating the 
  failing assertion, editing the source, and re-running until green"
intent: error-resolution
confidence: 0.87          # Discovery confidence score
discovery_date: 2026-02-20
last_triggered: 2026-02-24
trigger_count: 47

inputs:
  test_command:
    type: string
    default: "npm test"
    description: "Command to run the test suite"
  test_file:
    type: string
    required: false
    description: "Specific test file, or empty for full suite"

outputs:
  fix_applied:
    type: boolean
  files_modified:
    type: array
    items: string
  test_result:
    type: enum
    values: [pass, fail, error]

preconditions:
  - "Test suite is configured and runnable"
  - "Git working directory is clean or changes are committed"

steps:
  - action: terminal.command
    command: "{{test_command}} {{test_file}}"
    capture: error_output
  - action: search.code
    query: "{{error_output.failing_assertion}}"
    scope: source
  - action: file.edit
    target: "{{search_result.file}}"
    intent: "Fix the failing assertion based on error context"
  - action: terminal.command
    command: "{{test_command}} {{test_file}}"
    validate: exit_code == 0
    max_retries: 3

determinism: semi-deterministic  # Same input may produce different fixes
allowed-tools: [Bash, Read, Edit, Grep, Glob]

validation:
  - test: "All previously passing tests still pass"
    command: "{{test_command}}"
  - test: "No unintended file modifications"
    command: "git diff --stat"

observability:
  metrics: [duration_ms, retry_count, files_changed_count]
  events: [step_started, step_completed, validation_passed, validation_failed]

safe_mode:
  enabled: true
  dry_run: "Show proposed changes without applying"
  confirmation_required: [file.edit, terminal.command]

rollback:
  strategy: git-stash
  command: "git checkout -- ."
---
```

This format is compatible with Claude Code's skills directory (`.claude/skills/`), Codex's SKILL.md system (`.codex/skills/`), and can be adapted into Cursor's `.cursor/rules/*.mdc` format by extracting the description and steps into rule instructions.

---

## Integration architecture: where Jaan.to hooks into each tool

### Claude Code: hooks + session parsing + MCP

Claude Code provides three integration channels. **Hooks** are the primary capture mechanism: register `PostToolUse` hooks with an empty matcher (matches all tools) that pipe the JSON payload to a local capture daemon. The payload includes tool name, input, output, session ID, and transcript path — everything needed for event normalization.

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "curl -s -X POST http://localhost:4200/events -d @-",
        "timeout": 5
      }]
    }],
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "curl -s -X POST http://localhost:4200/sessions/start -d @-"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "curl -s -X POST http://localhost:4200/sessions/stop -d @-"
      }]
    }]
  }
}
```

**Session transcript parsing** provides retroactive analysis. The JSONL files at `~/.claude/projects/<project>/sessions/` contain complete conversation records. A background job can parse new transcripts, extract action sequences, and feed them to the pattern discovery engine. The sessions index at `sessions-index.json` provides metadata for efficient scanning.

**MCP server** delivers suggestions back to Claude. Register a custom MCP server that exposes `suggest_skill` (called when Claude detects a workflow matching known patterns), `list_discovered_skills` (resource for browsing), and `apply_skill` (executes a stored skill). Claude will opportunistically invoke these tools when descriptions match the current context.

### Cursor: VS Code extension + MCP + rules

Build a VS Code extension (`.vsix`) that runs in Cursor and captures workspace events. The extension listens to `onDidChangeTextDocument`, `onDidSaveTextDocument`, `onDidChangeActiveTextEditor`, and terminal events. It normalizes these into the canonical event schema and posts to the local capture daemon.

The extension also registers the shared MCP server via `vscode.cursor.mcp.registerServer`, giving Cursor's Agent access to suggestion and skill-application tools. Because Cursor limits MCP to **40 tools**, the Jaan.to server should expose at most 3-5 focused tools.

For delivering discovered skills back to users, generate `.cursor/rules/*.mdc` files automatically. When a pattern scores above the threshold, create a rule file with appropriate globs and description for auto-attachment. This integrates naturally with Cursor's existing workflow.

**Key limitation**: Cursor does not expose AI Composer/Agent interactions. You cannot capture what the user asked or what code changes the Agent proposed — only the resulting file modifications. This means Cursor captures are less rich than Claude Code's.

### Codex: SDK wrapper + MCP + exec monitoring

Wrap Codex interactions via the TypeScript SDK, intercepting `thread.run()` calls and capturing inputs, outputs, and tool invocations. For CLI usage, `codex exec --json` streams structured JSONL events parseable by the capture daemon.

Register the shared MCP server in `~/.codex/config.toml`:

```toml
[mcp_servers.jaanto]
command = "node"
args = ["./node_modules/@jaanto/capture-server/index.js"]
```

Codex's MCP client will make the suggestion and skill-application tools available alongside built-in tools. Skills discovered by Jaan.to can be written directly as SKILL.md files in `.codex/skills/`, immediately available to Codex's auto-selection system.

---

## MVP algorithm: ship pattern detection in two weeks

The minimum viable skill discovery algorithm prioritizes speed to production over sophistication.

**Step 1: Collect.** Deploy PostToolUse hooks in Claude Code, a minimal VS Code extension for Cursor, and a Codex SDK wrapper. Store all events in a local SQLite database with the canonical schema. No server required — everything runs on the developer's machine.

**Step 2: Segment.** Split event streams into episodes using a simple heuristic: any gap exceeding **3 minutes** or a `git.commit` event starts a new episode. Each episode gets a UUID and a list of ordered events.

**Step 3: Mine.** Run a simplified PrefixSpan on episodes: extract all contiguous subsequences of length 3-6. Count occurrences across episodes. Filter to sequences appearing ≥ 3 times in the last 14 days. This runs in **under 1 second** on typical developer activity.

**Step 4: Score.** Apply a simplified rubric: `score = frequency × 20 + avg_duration_minutes × 10 + parameterizable_steps/total_steps × 30`. Threshold at score > 40.

**Step 5: Suggest.** Present the top 3 candidates via the MCP server's `suggest_skill` tool. Include the pattern description, frequency, estimated time savings, and a one-click "Create Skill" action that writes a SKILL.md file.

**Step 6: Learn.** Track accept/dismiss/snooze actions. Dismissed patterns get a cooldown. Accepted patterns become skills. After 30 days, retrain thresholds based on acceptance rate.

This MVP requires approximately **800-1200 lines of code**: ~200 for capture hooks/extension, ~200 for segmentation, ~200 for PrefixSpan, ~200 for scoring, ~200 for the MCP server.

---

## Five UX patterns to prevent suggestion fatigue

**1. Confidence-gated progressive disclosure.** Show only a subtle badge ("3 patterns found") until the user explicitly opens the suggestion panel. Never interrupt active coding flow. Suggestions appear at natural breakpoints: after a git commit, when starting a new session, or during idle periods exceeding 30 seconds. Each suggestion shows its confidence score (0-100) prominently — users learn to trust high-confidence suggestions and ignore low ones.

**2. Intelligent batching at session boundaries.** Never present individual suggestions mid-task. Accumulate discovered patterns and present them in a **daily digest** (configurable to weekly) or at session end via a `Stop` hook or `SessionEnd` event. Bundle related patterns: "We found 3 test-related patterns this week" with a single expand action. This reduces notification frequency by **80-90%** compared to per-discovery alerts.

**3. Snooze and cooldown with exponential backoff.** Dismissing a suggestion applies a 7-day cooldown. Dismissing the same pattern type twice applies a 30-day cooldown. Three dismissals permanently suppress that pattern unless the user manually re-enables it. Cooldowns are per-pattern-type, not per-instance — dismissing "fix test failure" doesn't suppress "update dependencies." A global "Do Not Disturb" toggle pauses all suggestions.

**4. Preview and dry-run before commitment.** Every suggested skill includes a "Preview" mode showing exactly what the automation would do on the most recent relevant episode. Display a diff-like view: "This skill would have automated these 6 steps you did manually on Feb 22." The preview provides concrete evidence of value without requiring trust. A "Dry Run" button executes the skill in safe mode (no writes, no commands) to demonstrate behavior.

**5. Outcome-first presentation with escape hatches.** Lead with the value proposition: "**Save ~20 min/week** — automate your test-fix-verify cycle." Follow with a one-line description of what the skill does. Expand for full details only on click. Include three action buttons: "Enable" (creates SKILL.md), "Snooze 7 days", "Never show this." Never show more than **3 suggestions** at once. If more are queued, show only the top 3 by score with a "See all" link.

---

## Privacy and safety model

**Local-first processing is non-negotiable.** All event capture, storage, pattern mining, and scoring runs on the developer's machine. No raw events, code content, file paths, or prompt text ever leaves the local system. The SQLite database lives in `~/.jaanto/` with filesystem permissions restricted to the current user.

**Content is never stored.** Events record structural metadata only: action type, file hash (SHA-256 of relative path), language, result status, and duration. Variable values, string literals, API keys, and actual code changes are stripped at capture time. The pattern mining operates on action type sequences, not content.

**Consent is granular and opt-in.** On first run, the system presents a consent dialog listing each capture channel (Claude Code hooks, Cursor extension, Codex wrapper, git hooks, file watchers) with individual toggles. Users enable only what they're comfortable with. A real-time telemetry viewer (inspired by VS Code's `Developer: Show Telemetry`) lets users inspect exactly what's being captured at any moment.

**PII detection runs pre-storage.** Before any event hits SQLite, a lightweight PII detector (regex-based for emails, IPs, tokens, secrets; optionally ML-based via ONNX models running locally) scans all string fields. Detected PII is replaced with `[REDACTED]` tokens. File paths are always hashed, never stored raw.

**Opt-in cloud enhancement.** For users who opt in, anonymized pattern frequencies (not raw events) can be sent to a cloud service for cross-user pattern aggregation. This enables "other developers in React projects commonly automate X" suggestions. The cloud service never receives code, file names, or identifiable information — only structural pattern hashes and frequency counts.

---

## Failure modes and how to mitigate them

**False positives** — suggesting automations for patterns that aren't actually repetitive or valuable — are the primary risk. Mitigation: require a minimum of 3 independent occurrences across at least 2 separate days before surfacing. Apply the stability score (coefficient of variation across instances) to filter out noisy patterns that look superficially similar but vary significantly. Track acceptance rates per pattern type; if a category drops below 20% acceptance, raise its threshold by 15 points.

**Overfitting to individual quirks** can produce hyper-specific skills that only work in one project context. Mitigation: the parameterizability score penalizes patterns where >70% of steps are project-specific (hardcoded paths, specific commands). The LLM generalization step explicitly abstracts away project-specific details. Discovered skills include preconditions that must be met before activation.

**Suggestion fatigue** is addressed by the five UX patterns above, but the system also implements a **global fatigue monitor**: if a user dismisses >50% of suggestions in a 30-day window, automatically raise all thresholds by 20 points and reduce suggestion frequency to weekly digests. Reset when acceptance rate improves.

**Stale skills** — patterns that were once common but no longer occur — accumulate cruft. Mitigation: skills have a `last_triggered` timestamp. Skills not triggered in 60 days are automatically archived (moved to `.jaanto/archive/`). Users receive a quarterly cleanup prompt: "These 5 skills haven't been used in 2 months. Archive them?"

**Security risks from automated execution** are managed through the safe mode and rollback specification in every skill. Skills that include destructive operations (`file.delete`, `git push --force`, deployment commands) are flagged with a "requires confirmation" marker that cannot be disabled. The rollback strategy (git stash, checkpoint) is validated before first execution.

---

## Conclusion

The AI coding tool landscape has converged on shared primitives — markdown instructions, SKILL.md bundles, and MCP as the extensibility protocol — but left automated pattern discovery entirely unaddressed. Claude Code's hook system provides the most comprehensive event capture available today, with **12+ lifecycle events and full JSON payloads** on every tool invocation. Codex offers SDK-level programmatic access and unique MCP server capabilities. Cursor provides the broadest user base but the most constrained integration surface, limited to VS Code extension events and 40-tool MCP ceilings.

The Jaan.to system exploits this gap with a local-first architecture that requires no cloud dependencies for core functionality. The MVP — a PrefixSpan miner on hook-captured events, scoring against an 8-dimension rubric, delivering suggestions via a shared MCP server — is implementable in approximately 1,200 lines of code. The SKILL.md-compatible output format ensures discovered skills integrate natively with all three tools' existing skill systems, turning the skill discovery layer into a force multiplier rather than another tool to manage.