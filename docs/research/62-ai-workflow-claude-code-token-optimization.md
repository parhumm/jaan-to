# Scaling Claude Code plugins to 141 skills without burning your context window

**A framework of 141 skills, 24 MCP connectors, and multiple custom agents can operate within Claude Code's 200K-token context window — but only with aggressive optimization.** The key insight: Claude Code uses progressive disclosure for skills (loading only ~40-token metadata at startup, not full SKILL.md files), and MCP Tool Search can reduce tool registration overhead by 85%. Without these mechanisms, a framework at this scale would consume 60–100% of available context before any work begins. With them, baseline overhead drops to roughly 10% of the context window, leaving ~178K tokens for actual conversation and work.

This report synthesizes findings from Anthropic's official documentation, Claude Code's GitHub issues, community case studies, and the emerging Agent Skills open standard to provide immediately actionable optimization techniques for scaling the jaan.to framework.

---

## How Claude Code actually consumes your skill definitions

Understanding the three-layer progressive disclosure system is foundational to every optimization that follows. Claude Code does **not** load all 141 SKILL.md files into context at startup.

**Layer 1 — Metadata (always loaded):** Only the `name` and `description` fields from each skill's YAML frontmatter are injected into an `<available_skills>` XML block within the Skill tool definition. Anthropic's documentation states this costs approximately **~100 tokens per skill** (community measurements suggest **~30–50 tokens** in practice, depending on description length). For 141 skills, this means **4,200–14,100 tokens** of permanent overhead.

**Layer 2 — Full SKILL.md body (loaded on invocation):** When Claude determines a skill matches the user's request, it reads the complete SKILL.md via bash and injects the content as new user messages. Anthropic recommends keeping each SKILL.md **under 500 lines (~5K tokens)**. This content enters context only when the skill fires.

**Layer 3 — Bundled resources (accessed on demand):** Scripts in `scripts/`, references, templates, and assets are accessed only when Claude navigates to them. Executable scripts run without reading into context at all — there is effectively **no context penalty for bundled content that isn't used**.

Three YAML frontmatter fields are critical for token optimization at scale:

- **`disable-model-invocation: true`** removes the skill from the `<available_skills>` list entirely, eliminating its ~40-token metadata overhead. The skill becomes manual-only (slash command invocation). For 141 skills, marking 80 as manual-only saves **~3,200 tokens** from base context.
- **`context: fork`** runs the skill in an isolated subagent context with its own conversation history. Work output stays out of the main context window, with only a summary returning. This is ideal for self-contained workflows like PR reviews, test suites, and audits.
- **`allowed-tools`** restricts which tools the skill can access, reducing both token overhead and execution surface area.

**A reported bug (GitHub issue #14882)** indicates some plugin skills may consume their full token count at startup rather than just frontmatter. Monitor this with the `/context` command and verify progressive disclosure is functioning correctly.

### Writing token-efficient SKILL.md files

Keep the YAML `description` field precise and trigger-oriented — include "when to use" information here, not in the body. The description is the only content permanently in context, so it must enable Claude's routing without verbose prose. Use formats like: *"Use when user requests sprint planning, backlog grooming, or iteration setup."*

For the body, adopt YAML/Markdown formatting over JSON — this yields **20–30% token savings** for structured content. Move detailed reference material to separate files and reference them with clear descriptions of when Claude should read them. Use executable scripts (Python/Bash) instead of inline code, since scripts execute without loading into context. Split mutually exclusive contexts into separate files: if PM protocols and QA protocols never co-occur, keep them in separate referenced documents.

---

## CLAUDE.md: the always-loaded context tax

Unlike skills, **all CLAUDE.md content loads into context at every session start with no lazy loading**. This includes every level of the hierarchy: enterprise policy, project root, user-level, and project-local files, plus any content imported via the `@path/to/file` syntax (recursive up to 5 levels deep).

This makes CLAUDE.md optimization the highest-leverage activity for reducing baseline overhead. A bloated CLAUDE.md of 2,800+ lines — a documented anti-pattern — wastes **62% of tokens per session**. Community case studies show optimized CLAUDE.md files achieve **54–62% reduction** in initial context consumption.

**The skill trigger table pattern** is the most effective CLAUDE.md optimization for large frameworks. Instead of documenting detailed protocols inline, use a compact lookup table:

```markdown
## Skill triggers
| Triggers | Skill | Domain |
|----------|-------|--------|
| sprint, backlog, iteration | sprint-planner | PM |
| deploy, release, ship | deployment | Dev |
| wireframe, mockup, prototype | ux-design | UX |
```

This replaces verbose per-skill documentation with a scannable reference that costs **~800 tokens** instead of 3,000+. All detailed protocols live in individual SKILL.md files, loaded only when triggered.

**Nested CLAUDE.md files in subdirectories are lazily loaded** — they enter context only when Claude reads files in those subtrees. Use this for domain-specific rules: place PM conventions in `skills/pm/CLAUDE.md`, QA rules in `skills/qa/CLAUDE.md`, and so on. Only the conventions relevant to the current work surface enter context.

**Path-scoped rules** in `.claude/rules/` offer another conditional loading mechanism. Rules with a `paths` YAML frontmatter field apply only when Claude works with matching files:

```yaml
---
paths: ["src/frontend/**", "components/**"]
---
Use React Server Components by default. Prefer Tailwind CSS.
```

Rules without a `paths` field load unconditionally, so keep those minimal. Anthropic internally runs CLAUDE.md files through their prompt improver and tunes instructions with emphasis markers like "IMPORTANT" or "YOU MUST" to improve adherence — but only for critical rules that justify the token cost.

---

## Hooks inject context only in specific, controllable scenarios

Hooks are far more token-efficient than most developers assume. The critical rule: **hook stdout is generally NOT injected into Claude's context**. Exit code 0 output is shown to the user in verbose mode only, not fed to Claude.

The exceptions are specific and manageable:

- **SessionStart hooks (exit code 0):** stdout IS added to context. Use this deliberately to inject dynamic, session-relevant context (current git branch, running services, environment state) instead of static CLAUDE.md content.
- **UserPromptSubmit hooks (exit code 0):** stdout IS injected alongside the user's prompt. Useful for dynamic context enrichment but must be kept lean.
- **Exit code 2 (blocking):** stderr IS fed back to Claude as an error message. Use sparingly — each blocked action's error text enters context.
- **PreToolUse hooks (v2.1.9+):** Can return `additionalContext` in JSON output, providing extra context to the model.

**The optimal hook strategy for a 141-skill framework** uses SessionStart hooks to dynamically inject only relevant context based on detected project state, replacing static CLAUDE.md content. One documented approach achieved **62% token reduction** (2,100 → 800 tokens per session start) by moving from static CLAUDE.md documentation to a three-tier system: essential rules always loaded (~800 tokens), session-relevant context injected by hooks, and detailed protocols loaded on-demand via skills.

Be cautious with PostToolUse validation hooks that trigger on every tool execution — if they emit exit code 2 errors frequently, the accumulated error text in context can become significant. Formatting hooks are a documented anti-pattern: one case consumed **160K tokens in 3 rounds** through write-time formatting hooks.

---

## MCP tool registration will consume your context if unmanaged

This is the most critical optimization area for a 24-connector deployment. **Every MCP tool schema — name, description, full JSON parameter definitions — is injected into context at session start by default.** Real-world measurements show staggering costs:

| MCP Server | Tools | Token Cost |
|------------|-------|------------|
| GitHub | 35 | ~26,000 |
| Slack | 11 | ~21,000 |
| Jira | ~20 | ~17,000 |
| Playwright | 21 | ~13,647 |
| Docker | 135 | ~126,000 |

The average is **~500–710 tokens per tool**. A conservative estimate for 24 connectors: **48,000–120,000 tokens** — potentially **60% of a 200K context window** consumed before any conversation.

**MCP Tool Search is the essential solution.** Shipped in Claude Code v2.1.7 and activated automatically when tool descriptions exceed **10% of the context window** (~20K tokens), Tool Search builds a lightweight index of tool names and descriptions (~5K tokens total) and loads full tool schemas on demand. Anthropic's internal testing showed reduction from **134K to ~5K tokens — an 85% reduction** — while actually improving accuracy (Opus 4: 49% → 74% on MCP evaluations). Tools loaded on demand stay cached for the session.

For maximum efficiency with 24 connectors, combine Tool Search with these practices:

**Consolidate related tools into fewer definitions with parameters.** One developer reduced 20 tools (14,214 tokens) to 8 tools (5,663 tokens) — a **60% reduction** — by merging CRUD operations into single tools with action parameters. Instead of `create_issue`, `update_issue`, `delete_issue`, `list_issues`, use `manage_issues({ action: "create" | "update" | "delete" | "list" })`.

**Trim descriptions aggressively.** A 87-token description like "Search the web using Tavily Search API. Best for factual queries requiring reliable sources and citations..." becomes 12 tokens: "Search using Tavily. Best for factual/academic topics with citations."

**Prefer CLI tools over MCP servers when possible.** Tools like `gh`, `aws`, `gcloud`, and `sentry-cli` execute via bash without adding persistent tool definitions to context. This is substantially more context-efficient for tools used occasionally.

**Set `MAX_MCP_OUTPUT_TOKENS` conservatively.** The default 25K per tool response may be too generous with 24 servers. Implement server-side pagination and summary-first response patterns. Use **Programmatic Tool Calling** for complex multi-tool workflows — Claude writes orchestration code that processes results in a sandboxed environment, with only final results entering context. This achieved **37% token reduction** on complex research tasks in Anthropic's testing.

---

## Custom agents provide context isolation but multiply total token spend

Each custom agent (subagent) in Claude Code gets **its own isolated context window** — a separate 200K-token space that never pollutes the parent conversation. This is architecturally powerful for a large skill framework: complex, self-contained tasks run in isolation, returning only concise summaries to the parent context.

However, Anthropic documents that **agent teams use approximately 7x more tokens** than standard sessions. Each agent spawns as a separate Claude instance with its own context window, system prompt loading, and tool initialization overhead. Per-agent overhead includes work summarization (5,000–25,000 tokens), handoff protocols (3,000–15,000 tokens), and state persistence (2,000–10,000 tokens).

Custom agent definitions themselves are lightweight — measured at **~584 tokens** in context for the agent registry. But the optimization imperative is in how you configure them:

- **Use `model: haiku` for read-only agents** (explorers, analyzers, validators). Haiku is faster, cheaper, and sufficient for non-creative tasks. Reserve Sonnet for moderate tasks and Opus only for deep reasoning.
- **Restrict tool access** to only what each agent needs. An agent that only reads code shouldn't have Write, Bash, or MCP tool access.
- **Assign specific skills** via the `skills:` frontmatter field so agents auto-load only relevant skills into their isolated context.
- **Include "PROACTIVELY" or "MUST BE USED"** in agent descriptions for reliable auto-delegation. Claude's routing depends on description matching, and emphatic language improves adherence.

Context isolation is currently all-or-nothing — no scoped context passing exists between parent and subagent (feature request: GitHub issue #4908). This means subagents must re-discover context the parent already had, consuming extra tokens. Mitigate this by writing focused task descriptions that include essential context inline, rather than relying on agents to re-read project files.

---

## A concrete context budget for 141 skills and 24 MCP connectors

With all optimizations applied, here is the realistic token budget for a 200K context window:

| Component | Tokens | % of 200K |
|-----------|--------|-----------|
| System prompt (internal) | 3,200 | 1.6% |
| Built-in tools (Read, Write, Bash, etc.) | 11,600 | 5.8% |
| CLAUDE.md (optimized, trigger table) | 1,500 | 0.75% |
| Auto-invocable skill metadata (60 skills × 40 tokens) | 2,400 | 1.2% |
| Manual-only skills (81 skills, no metadata loaded) | 0 | 0% |
| MCP tools (Tool Search enabled, 24 connectors deferred) | 3,000 | 1.5% |
| Custom agent registry | ~600 | 0.3% |
| Auto-compact buffer | 32,000 | 16% |
| **Total baseline overhead** | **~54,300** | **~27%** |
| **Available for conversation and active skill content** | **~145,700** | **~73%** |

Without optimization, this same setup would consume **80,000–160,000+ tokens** at startup — leaving 20–60% for actual work, with severe performance degradation in the "lost in the middle" problem zone.

**The four-tier skill categorization** is essential for achieving these numbers:

- **Always-on (~20 skills):** Core coding, testing, git workflows. Metadata always in context, content loaded on demand.
- **Auto-invocable (~40 skills):** Domain-specific but commonly triggered. Metadata loaded, content on demand. Use concise descriptions.
- **Manual-only (~50 skills):** Deployment, notifications, rare workflows. Set `disable-model-invocation: true`. Zero metadata overhead.
- **Fork/subagent (~31 skills):** Reviews, audits, parallel analysis tasks. Set `context: fork`. Execution stays in isolated context.

Compact proactively at **60–70% context usage** rather than waiting for auto-compact at 95%. Use `/clear` between unrelated tasks. Document progress to files before clearing context so it can be recovered.

---

## Testing 141 skills without burning tokens requires a tiered strategy

No official Claude Code skills testing framework exists. The community consensus is a three-tier approach:

**Tier 1 — Structural validation (zero tokens, every commit):** Parse YAML frontmatter for required fields (`name`, `description`), validate file paths and directory structure, check that referenced scripts and templates exist, detect placeholder content. The claudecodeplugins.io marketplace uses automated validators that catch files listed in READMEs that don't exist, stub scripts with placeholder code, and boilerplate masquerading as documentation. Build these checks into CI/CD with standard linting tools.

**Tier 2 — Deterministic command tests (zero tokens, every PR):** Execute skill scripts with fixed inputs and verify outputs against expected results. Use record/replay patterns for MCP responses. For Python-based testing, LangChain's `FakeListChatModel` returns predefined responses without API calls while capturing the assembled prompt for inspection.

**Tier 3 — Semantic evaluation (budgeted tokens, nightly/weekly):** Use **promptfoo** for declarative YAML-based prompt testing with assertion validation and CI/CD integration. Use **DeepEval** for pytest-like LLM evaluation with metrics including relevancy and hallucination detection. Test a representative sample (~10–15% of skills), not all 141.

For monitoring in production, **ccusage** reads Claude's local JSONL session files to show daily/monthly token consumption per project. **Claude-Code-Usage-Monitor** provides real-time terminal monitoring with burn rate predictions. The built-in `/cost`, `/context`, and `/stats` commands provide immediate visibility into token allocation.

---

## Cross-agent compatibility through the Agent Skills open standard

The most significant development for multi-agent skill design is the **Agent Skills specification** (agentskills.io), originally developed by Anthropic and adopted as an open standard by GitHub Copilot, OpenAI Codex, Cursor, and Goose. The format — SKILL.md files with YAML frontmatter in standardized directories — is the same format Claude Code uses natively.

This means skills designed for jaan.to are inherently portable if they follow the spec strictly. Key compatibility considerations:

**Use `.github/skills/` as the primary skill location** for maximum portability. GitHub Copilot recommends this location; Claude Code and other agents support it. Keep Claude-specific configuration (CLAUDE.md, hooks, custom agents) separate from the portable skills directory.

**Avoid agent-specific features in skill bodies.** Don't reference Claude-specific tools (`Task()`, `/compact`) or Cursor-specific features (`@files`) in skill instructions. Write instructions in natural language that any agent can interpret. Agent-specific configuration belongs in agent-specific config files (CLAUDE.md for Claude, `.cursor/rules/` for Cursor, `.github/copilot-instructions.md` for Copilot).

**Design for the smallest context window.** While Claude Code has 200K tokens, Cursor varies by model, and Copilot historically had 4K–8K (now 64K). Skill instructions that work within tighter constraints will work everywhere. This naturally enforces the discipline of keeping SKILL.md files concise.

**The skilz CLI** (SkillzWave) enables universal installation across 30+ coding agents with automatic agent detection and path resolution: `skilz install anthropics/skills/pdf-reader` installs to whichever agent is detected. This infrastructure supports distributing jaan.to skills to Cursor, Copilot, and Windsurf users without modification.

Different LLMs vary dramatically in how they interpret instructions. Cursor's MDC rules evolved similarly to Claude Skills but failed to become cross-agent due to IDE-specific positioning. The lesson: skills built around the open Agent Skills spec have the broadest compatibility and longest shelf life.

---

## Anti-patterns that will sabotage your framework at scale

Production usage across the community has identified consistent failure modes:

**Bloated CLAUDE.md files** are the most common token waste. Keep the root file under 200 lines. Document what Claude gets wrong — not comprehensive manuals. Use the trigger table pattern and push detailed protocols to SKILL.md files.

**Complex custom slash commands at scale** become an anti-pattern. As Anthropic developer Shrivu Shankar noted: "If you have a long list of complex custom slash commands, you've created an anti-pattern." Let Claude's natural language understanding handle routing; use skills with auto-invocation rather than manual slash commands for most workflows.

**MCP tool overload without Tool Search** is catastrophic. One developer reported only 20K tokens remaining for actual work after loading MCP tools, noting the context was "cooked." Another documented 67,000 tokens consumed by just four MCP servers. Always verify Tool Search is active via `/context`.

**Embedding files via @-imports in CLAUDE.md** loads entire file contents on every session start. Use pointers instead: "For deployment protocol, see Skill('deployment')." This defers loading until the skill is actually needed.

**Long autonomous sessions without context clearing** degrade quality progressively. Research shows performance drops **15–47%** as context fills, with the "lost in the middle" problem affecting information retrieval in long conversations. Reset context per task iteration and maintain state via files and git, not conversation history.

**Write-time formatting hooks** that trigger on every file write can consume 160K tokens in just 3 rounds. Handle formatting between sessions or via pre-commit git hooks, not Claude Code hooks.

**Using Opus for everything** costs ~1.7x more and exhausts caps faster. Default to Sonnet for 80% of tasks; reserve Opus for complex architectural reasoning. Use Haiku for exploration and analysis subagents — it's faster, cheaper, and sufficient for read-only operations.

---

## Conclusion: the optimization hierarchy for maximum impact

The optimizations in this report follow a clear priority order based on impact. **MCP Tool Search** delivers the largest single improvement — reducing 48K–120K tokens of tool definitions to ~5K, making the 24-connector architecture viable. **CLAUDE.md optimization** via skill trigger tables and path-scoped rules eliminates 54–62% of baseline overhead that loads on every session. **Skill tiering** with `disable-model-invocation: true` on 50+ manual-only skills removes ~2,000–4,000 tokens from the permanent metadata registry. **Subagent isolation** via `context: fork` keeps complex skill execution out of the main context entirely. And **prompt caching** — which Claude Code enables by default — provides 90% cost reduction on the stable prefix (system prompt, tool definitions, skill metadata) that repeats every turn.

The counterintuitive insight: a 141-skill framework can be more context-efficient than a poorly optimized 10-skill framework. Progressive disclosure means skill count scales at only ~40 tokens per auto-invocable skill. The real danger is in the always-loaded components — CLAUDE.md, unconditional rules, and undeferred MCP tool schemas. Optimize these three aggressively, and the 141-skill target is achievable within Claude Code's 200K context window with **73% of context still available** for productive conversation and work.