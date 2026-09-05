# The Best Free, Local, Open-Source Tools to Cut Claude Code Token Usage: A Technical Survey (July 2026)

## TL;DR
- **The single highest-leverage, evidence-backed free/local stack is: (1) built-in Claude Code discipline (`/effort`, `MAX_THINKING_TOKENS`, plan mode, subagents, skills-over-CLAUDE.md), (2) RTK for terminal-output compression, and (3) a symbol/graph navigation layer (Serena or token-savior) for medium-to-large repos.** These attack the two biggest token sinks — tool output and file reads — without degrading quality; independent testing shows quality often *improves* because noise is removed.
- **Beware the marketing.** The strongest independent benchmark (ComputingForGeeks, April 2026) shows real per-session reductions of ~20–43% for the best tools on a small repo — far below the "90x"/"71x"/"98%" headline numbers, which are cherry-picked to specific command types or monorepos. Output-compression "caveman"-style tools only shrink the ~1–10% of tokens that are visible prose and can go net-negative on terse workloads.
- **Match the tool to your bottleneck.** Run `/context` and `ccusage` first to find where your tokens actually go, then add tools one at a time and re-measure. On small repos most graph/index tools add overhead and *increase* tokens; on large monorepos they pay for themselves.

## Key Findings

### Where Claude Code tokens actually go
Claude Code's token consumption on a typical agentic turn splits roughly into: cached system prompt + skills + MCP tool manifest (30–50%), tool call inputs/outputs — Read/Grep/Glob/Bash (30–45%), extended-thinking reasoning (10–30%), and visible assistant output (1–10%) (ComputingForGeeks independent benchmark, April 2026). The compounding cost is **auto-compaction**: at ~93% of the 200K window Claude Code summarizes and restarts, re-reading everything at full rates, and this can fire multiple times per long session.

Two architectural facts drive everything:
1. **Claude Code does not use vector/embedding RAG for code.** Boris Cherny (creator and Head of Claude Code at Anthropic) stated it directly: *"Early versions of Claude Code used RAG + a local vector db, but we found pretty quickly that agentic search generally works better. It is also simpler and doesn't have the same issues around security, privacy, staleness, and reliability"* (Cherny, X/@bcherny and the Latent Space podcast, May 2025), adding in the same interview that agentic search *"outperformed everything. By a lot, and this was surprising."* This is why the largest token drains are raw file reads and shell output — and why symbol/graph tools that give the agent a precise map help. It is also why Anthropic's own multi-agent research system, built on the same agentic-retrieval idea, *"beat a single Claude Opus 4 by 90.2% on internal evals"* (Anthropic, "How we built our multi-agent research system") — while using ~15× the tokens.
2. **Fixed startup overhead is large.** A trivial "hi" prompt can consume ~31,000 tokens (GitHub issue #52979, cited by Firecrawl) because the system prompt, CLAUDE.md, memory files, MCP tool schemas, and skill descriptions all load up front. Every MCP server's full tool schema loads into every request: Anthropic's "Introducing advanced tool use" blog reports **~77K tokens consumed before any work begins with 50+ MCP tools** (vs ~8.7K with Tool Search), and a real user measurement (claude-code issue #11364, Nov 10 2025) found **seven MCP servers consuming 67,300 tokens of tool definitions — 33.7% of a 200K context window**.

### Anthropic's own built-in levers (free, first-party, zero install)
These are the most reliable savings and should be exhausted before installing anything:
- **`/effort` and `MAX_THINKING_TOKENS`** — cap extended thinking (default can allocate up to 64K reasoning tokens); `/effort none` for pure edits cuts 20–40% on simple tasks (ComputingForGeeks).
- **Plan mode** before non-trivial tasks — avoids the most expensive failure mode (going down the wrong path for 50K tokens).
- **Subagents / Task tool** — each runs in its own context; intermediate Read/Grep output stays inside the subagent, only a summary returns (40–70% main-thread reduction on research tasks). Pin subagents to Haiku via `CLAUDE_CODE_SUBAGENT_MODEL=haiku`.
- **Skills' progressive disclosure** — only ~100 tokens of YAML frontmatter per skill load at startup; the full SKILL.md body loads on activation. Anthropic docs and community writeups describe up to ~98% savings vs. loading everything up front. Move anything >2KB out of CLAUDE.md into skills.
- **Tool Search Tool + Programmatic Tool Calling** (Claude Developer Platform, beta) — defers loading tool definitions. Anthropic's engineering blog reports the Tool Search Tool *"preserves 191,300 tokens of context compared to 122,800 with Claude's traditional approach... an 85% reduction,"* with MCP-eval accuracy rising (**Opus 4: 49%→74%; Opus 4.5: 79.5%→88.1%**).
- **Context editing / server-side compaction** (`context-management-2025-06-27` beta) — automatically clears old tool-use/result pairs at the API level without breaking the prompt cache. Anthropic ("Managing context on the Claude Developer Platform") reports **context editing alone delivered a 29% improvement over baseline, and combined with the memory tool a 39% improvement; in a 100-turn web-search eval it cut token consumption by 84%.** Anthropic uses this internally in Claude Code.

### The independent benchmark (most trustworthy single source)
ComputingForGeeks (April 2026) ran an identical "propose 3 improvements" task on `sindresorhus/ky` (52 TS files, 17,461 LOC), Claude Code 2.1.116 + Sonnet 4.5, headless, measuring total tokens (input + cache create + cache read + output). Baseline: 284,473 tokens / $0.2666. Results (vs baseline):

| Tool | Total tokens | Δ |
|---|---|---|
| Mibayy/token-savior (core profile) | 160,740 | **−43%** |
| drona23/claude-token-efficient (CLAUDE.md rules) | 171,657 | **−40%** |
| caveman (ultra) | 177,790 | −38% |
| caveman (full) | 178,760 | −37% |
| ooples/token-optimizer-mcp | 219,118 | −23% |
| alexgreensh/token-optimizer | 233,978 | −18% |
| tirth8205/code-review-graph | 269,252 | −5% |
| Baseline | 284,473 | 0% |

Critically, **token-savior is the only tool in the field publishing a reproducible benchmark harness** (`tsbench`, github.com/Mibayy/tsbench: a seeded synthetic project with a documented ground-truth oracle, comparing plain / LSP / token-savior baselines). That makes it the highest evidence-quality entrant even though its adoption (~1k stars) is small.

### The output-compression caveat
caveman's own README is unusually honest: it cuts a **measured 65% of output tokens** (10-prompt suite, range 22–87%) but "only shrinks output tokens. Input and reasoning tokens are untouched, and the skill itself adds ~1–1.5k input tokens per turn... on already-terse workloads they can go net-negative." Since visible output is only 1–10% of a heavy agentic turn, whole-session savings are far smaller than the 65% headline. RDXmin (JayPokale) is the only tool in this class that publishes its own *failures*: across 20 tasks, rival terse tools went net-negative (up to 424% of baseline) 6–8 times; RDXmin once (capped 173%).

### Community-adoption vs evidence-quality ranking
Star counts have exploded for several tools in ways that warrant skepticism — a Medium deep-dive (Nam Vu, June 2026) and Reddit threads flag possible "hype inflation or star-botting," and documented failure modes (e.g., claude-mem "recursive memory looping" turning a $2 session into $25). **Ranked by evidence quality (not popularity):**
1. **Anthropic built-ins** — first-party, documented, measured.
2. **token-savior** — only reproducible public harness; top independent result.
3. **RTK** — 89% noise reduction across 2,900+ real commands (author data), corroborated by many independent user reports (`rtk gain` is locally verifiable); but ~0% on the ComputingForGeeks single-turn task because that task was read-heavy, not bash-heavy.
4. **Serena / claude-context** — Serena's benefits are widely reported but not independently quantified with a public harness; claude-context has a Zilliz-published (vendor) eval showing 39.4% token / 36.1% tool-call reduction at parity retrieval.
5. **caveman / drona23 CLAUDE.md** — measured but narrow (output/prose only).
6. **Graphify / code-review-graph / repowise** — vendor/author "70x/49x/96%" claims are real only for specific structural queries on large repos; independent test showed −5% (code-review-graph) on a small repo.

## Details — Tool Profiles

Verified GitHub stats are as of July 17, 2026 (fetched from repo pages). Note: several star counts show viral-growth patterns and should be treated as indicative, not as quality signals.

### 1. RTK (Rust Token Killer) — `rtk-ai/rtk`
- **License:** Apache-2.0. **Stars:** ~70.9k. **Language:** Rust. **Last activity:** v0.43.0, June 28, 2026 (242 releases — very active). **Website:** rtk-ai.app.
- **How it works:** A single Rust binary CLI proxy. `rtk init -g` installs a **PreToolUse hook** in Claude Code that transparently rewrites Bash commands (`git status` → `rtk git status`) before execution, then filters/compresses output via four strategies: smart filtering (strips ANSI/whitespace/boilerplate), grouping, truncation, deduplication. Tracks savings in SQLite (`rtk gain`). <10ms overhead, <5MB memory target.
- **Where savings come from:** Terminal output noise — passing tests, progress bars, verbose logs. cargo test 91.8%, git status 80.8%, find 78.3%, grep 49.5% (author data, 2,900+ commands). Failures/errors/diffs/stack traces preserved in full.
- **Compatibility:** Claude Code, Cursor, Gemini CLI, Codex, Aider, Windsurf, Cline, Copilot, Factory Droid, and more. Hook support: yes (its core mechanism). MCP: not an MCP server. **OS:** macOS, Linux, Windows (native hook since v0.37.2), WSL. Apple Silicon + Intel. **Install:** Homebrew (`brew install rtk-ai/tap/rtk`), Cargo, binary.
- **Latency/resources:** Sub-10ms per command, negligible CPU/memory.
- **Limitations:** Hook only intercepts **Bash** tool calls — Claude Code's built-in Read/Grep/Glob bypass it (use `rtk read/grep/find` or shell equivalents). Compression is lossy — may occasionally drop a needed log line. On the ComputingForGeeks read-heavy single-turn task it produced ~0% savings; its wins show on bash/test-heavy sessions (one developer reported 113.6K tokens saved at 74.6% across 80 commands on a .NET build).
- **Security/privacy:** Local, no telemetry, no accounts; failed commands' full output saved to disk. Name-collision warning: a different "rtk" (Rust Type Kit) exists on crates.io.
- **When NOT to use:** Debugging where you want Claude to see full logs to self-correct; workloads dominated by file reads; Windows without WSL (falls back to a CLAUDE.md instruction mode with per-turn overhead).

### 2. Serena — `oraios/serena`
- **License:** MIT. **Stars:** ~24.2k. **Language:** Python. **Last activity:** v1.3.0, May 11, 2026 (2,851 commits — very active).
- **How it works:** An MCP server that launches real **Language Servers (LSP)** — gopls, clangd, ruby-lsp, etc. — and exposes symbol-level tools: `find_symbol`, `get_symbols_overview`, `find_referencing_symbols`, `rename_symbol`. The agent navigates by symbol name-path (`MyClass/my_method`) instead of reading whole files or grepping. 40+ languages. Writes `.serena/memories` markdown files.
- **Where savings come from:** Replacing whole-file reads and grep-then-read loops with precise symbol retrieval; especially valuable on medium/large repos. Also improves edit safety (LSP-driven renames update all references).
- **Compatibility:** Claude Code, Cursor, Cline, VS Code, IntelliJ/JetBrains (optional paid plugin backend), Codex, Gemini CLI, Roo Code. MCP: yes (native). **OS:** macOS, Linux, Windows; Apple Silicon + Intel. **Install:** `uvx --from git+...serena` or PyPI (`serena-mcp`); Docker.
- **Limitations:** Not independently benchmarked with a public harness. First-run **onboarding reads many files and consumes many tokens**. Claude Code can "forget" to use Serena tools after auto-compaction and must be reminded (issue #802 requests a skill/CLI form for token-efficiency). Setup more involved than a self-contained assistant.
- **When NOT to use:** Tiny/greenfield projects; untyped/duck-typed code where LSP is weak.

### 3. token-savior (Token Savior Recall) — `Mibayy/token-savior`
- **License:** MIT. **Stars:** ~1k (small but active). **Language:** Python. **Last activity:** v4.x, May 2026.
- **How it works:** MCP server that indexes the codebase by symbol (functions, classes, imports, call graph) so the model navigates by pointer; adds a persistent memory engine (SQLite WAL + FTS5 + optional vector embeddings). Ships `core` and `optimized`/`full` profiles; 68+ tools; 8 Claude Code lifecycle hooks.
- **Evidence:** Top independent result (−43%, ComputingForGeeks). Author's `tsbench` is the field's only reproducible harness (40-task suite, seed 42, GROUND_TRUTH.json). Author claims −77% active tokens / 100% task pass on Opus 4.7 (self-reported; also validated on Sonnet 4.6 at 94.4% vs 86.7% base).
- **Compatibility:** Any MCP client (Claude Code, Cursor, etc.). MCP: yes. Hooks: yes. **OS:** cross-platform (Python 3.11+). **Install:** `pip install token-savior-recall[mcp]` in a venv, then `claude mcp add`.
- **Limitations:** The `full` profile advertises ~106 tools consuming ~11K tokens of manifest — cancels savings on short tasks; use `core`. Best on typed codebases; small adoption.
- **When NOT to use:** Tiny projects where whole files already fit; short one-shot tasks with the full profile.

### 4. claude-context — `zilliztech/claude-context`
- **License:** MIT. **Stars:** ~11.8k. **Language:** TypeScript. **Actively maintained** (Zilliz, the Milvus company).
- **How it works:** MCP server that chunks + embeds the codebase (AST-aware chunking, Merkle-tree incremental reindex) into Milvus/Zilliz Cloud, exposing **hybrid BM25 + dense-vector** semantic search.
- **Evidence:** Zilliz's *own* (vendor) controlled eval: **39.4% token reduction, 36.1% fewer tool calls at equivalent retrieval quality**; the eval set is in the repo (reproducible). r/ClaudeAI reports 30–50% on long sessions (anecdotal).
- **Compatibility:** Claude Code, Cursor, Codex CLI, Gemini CLI, Qwen, Cline, Roo Code, Windsurf, Augment, Claude Desktop (13+ clients). MCP: yes. **Install:** npm-based MCP config; needs an embedding provider (OpenAI/Voyage/Gemini) and a Milvus/Zilliz backend.
- **Limitations/privacy:** **Not fully local by default** — embeddings are sent to your chosen provider's API, and the recommended backend is Zilliz Cloud (a local Milvus is possible but heavier). This partially violates the "no cloud dependency" constraint unless you self-host Milvus + a local embedding model. Known bug class: snapshot-lock contention can trigger an infinite force-reindex loop (recently hardened). Runs counter to Anthropic's own grep-first philosophy.
- **When NOT to use:** Privacy-sensitive/proprietary code you won't send to an embedding API; small repos.

### 5. caveman — `JuliusBrussee/caveman`
- **License:** MIT. **Stars:** ~69.4k. **Language:** JavaScript. **Last activity:** v1.8.2, May 12, 2026.
- **How it works:** A skill/plugin (installs a SessionStart hook on Claude Code) that injects a rule telling the model to drop articles, filler, pleasantries, and hedging while keeping code/errors/technical terms byte-exact. Intensity levels: lite/full/ultra + 文言文 (classical Chinese) modes. Auto-pauses for destructive-action warnings. Includes `/caveman-compress` (rewrites CLAUDE.md, ~46% input reduction) and `/caveman-stats`.
- **Evidence:** **Measured 65% mean output-token reduction** (10 prompts, range 22–87%, reproducible `benchmarks/`); −38% total on the independent ComputingForGeeks task (output-heavy). Author is transparent that it only touches output tokens and adds ~1–1.5k input/turn.
- **Compatibility:** Claude Code, Codex, Gemini, Cursor, Windsurf, Cline, Copilot, 30+ agents. No telemetry, no network calls after install (passed SkillsLLM security scan). MCP: no. Hooks: yes (Claude Code SessionStart). **OS:** macOS/Linux/WSL/Windows (Node 18+).
- **When NOT to use:** Heavy agentic runs where tool I/O dominates (prose share is tiny); already-terse workloads (net-negative); when reviewing long traces where verbose prose aids scanning.

### 6. ccusage — `ryoppippi/ccusage`
- **License:** MIT. **Stars:** ~14.2k. **Language:** TypeScript. **Last activity:** v18.x, April 2026 (mature, 109 releases).
- **Role:** Measurement, not reduction. Reads local JSONL usage logs (`~/.claude/projects/`) without uploading data; daily/weekly/monthly/session/5-hour-block reports; offline mode; MCP integration. The community-consensus **prerequisite**: install first, establish a baseline, then add tools one at a time and measure deltas.
- **Compatibility:** Claude Code + 15+ other agent CLIs. **Install:** `npx ccusage`, npm, bunx, Nix. **OS:** cross-platform.
- **When NOT to use:** N/A (it doesn't affect quality); it simply doesn't reduce tokens by itself.

### 7. claude-mem — `thedotmack/claude-mem`
- **License:** Apache-2.0. **Stars:** ~86.9k. **Language:** JS/TS. **Last activity:** v13.x, July 5, 2026 (very active).
- **How it works:** 5 lifecycle hooks capture tool usage; observations are AI-compressed (Haiku/agent-sdk) into SQLite + Chroma vector store; a 3-layer search workflow (index → review IDs → fetch) injects only relevant context into new sessions (~10x token efficiency vs storing full outputs, author claim). Cross-session persistence.
- **Limitations (documented failure mode):** If misconfigured it can inject redundant memory blocks every turn — a Medium deep-dive reports a $2 session ballooning to $25 via "recursive memory looping," plus context pollution and heavy local DB resource use. High star count flagged for possible inflation.
- **Compatibility:** Claude Code, Gemini CLI, OpenClaw, Codex, Copilot, OpenCode. MCP: yes. Hooks: yes. **OS:** cross-platform (Node + Bun + uv). **Install:** `npx claude-mem install`.
- **When NOT to use:** Short single-session tasks; low-RAM laptops; until you've verified configuration with ccusage.

### 8. Graphify — `safishamsi/graphify`
- **License:** MIT. **Stars:** ~75.2k. **Language:** Python. **Last activity:** v0.9.4, July 1, 2026.
- **How it works:** Builds a persistent knowledge graph once (Tree-sitter AST across 31 languages, local, no API; docs/media via an LLM extraction pass), then the agent queries the graph instead of re-reading files. Tags edges EXTRACTED/INFERRED/AMBIGUOUS; surfaces "god nodes"; Leiden community detection; git-hook incremental rebuild (AST-only, free).
- **Evidence:** Author/community claim **up to 70–71.5x fewer tokens** on large codebases; more independent blog tests report a more honest **5–10x** on real repos and note it *increases* tokens on small projects (<~30 files) because each `/graphify` query carries overhead (8K+ tokens for 3–4 invocations, per the project's own issue tracker).
- **Compatibility:** Claude Code, Cursor, Codex, OpenCode, Copilot CLI, Gemini CLI, Aider (15+ platforms). MCP/skill. **OS:** cross-platform (Python 3.10+, uv). Semantic extraction needs an API key (Anthropic/Moonshot/Gemini/OpenRouter/local Ollama) — **AST-only mode is fully free/local**.
- **When NOT to use:** Projects under ~30 files; code you touch rarely (upfront cost never amortizes); dynamic-dispatch-heavy code the static AST misses.

### 9. code-review-graph — `tirth8205/code-review-graph`
- **License:** MIT. **Stars:** ~16k. **Language:** Python. **Last activity:** v2.3.3, May 8, 2026.
- **How it works:** Tree-sitter → local SQLite AST graph; 28 MCP tools computing "blast radius" (callers, dependents, affected tests) for a change so Claude reads only connected nodes.
- **Evidence:** Author's 6-repo/13-commit eval: avg **8.2x** token reduction, headline **49x** on one Next.js monorepo, and quality *up* (8.8 vs 7.2/10 rubric). Independent ComputingForGeeks: **−5%** on the small ky repo (matches author's own 0.7x on tiny Express changes — graph overhead exceeds benefit).
- **Compatibility:** Claude Code + MCP clients; auto-detects tools on install. MCP: yes. **Install:** `pip install code-review-graph` / `uv tool install`, then `build` (~10s for a 500-file project).
- **When NOT to use:** Small repos (net overhead); one-off tasks.

### 10. repowise — `repowise-dev/repowise`
- **License:** AGPL-3.0 (copyleft — matters for commercial embedding). **Stars:** ~3.6k. **Language:** Python. **Last activity:** v0.31.0, July 12, 2026 (active).
- **How it works:** Indexes 5 layers (dependency graph, git history, auto-docs, mined architectural decisions, code-health scores) once; exposes 9 MCP tools (`get_context`, `get_answer`, `get_symbol`, `search_codebase`, `get_risk`). Also `repowise distill <cmd>` compresses command output (errors-first, reversible markers). Deterministic, no extra LLM calls for the graph.
- **Evidence:** Author paired benchmarks: **−96% context tokens** to load a commit (2,391 vs 64,039), −89% file reads, −70% tool calls, "quality at parity"; ~50% overall Claude savings claimed. No independent harness.
- **Compatibility:** Claude Code, Cursor, Cline, Codex, any MCP client. MCP: yes. Hooks: opt-in. **Install:** `pip install repowise`; first `init` ~25 min. Self-hosted, zero telemetry; can run offline with a local model.
- **When NOT to use:** AGPL is a blocker for some companies; long first-index time not worth it for small repos.

### 11. RDXmin — `JayPokale/RDXmin` (experimental)
- **License:** MIT. **Stars:** ~3 (very new, pre-release v0.1.1, June 2026). **Language:** JavaScript.
- **How it works:** Three axes — terse persona (skill) + tool-output compressor (keeps head/tail/error lines) + context diet. Deterministic, zero-dependency, allowlists safe tools (never Read/Edit/Write). Publishes its own failures.
- **Evidence:** Author's 20-task/59-run benchmark: **52% of a bare model's bill** vs caveman 80% / ponytail 68%; only 1 backfire vs 6–8. Reproducible runner in repo. Very low adoption.
- **When NOT to use:** Production reliance (immature); non-Claude agents for the input-compression hook (Claude-only).

### Other notable free/local tools
- **drona23/claude-token-efficient** — a 619-byte CLAUDE.md of 11 rules; **−40%** on the independent benchmark (surprise runner-up). Net-positive only when output volume is high.
- **alexgreensh/token-optimizer** — plugin (PreToolUse/SessionStart/SessionEnd/UserPromptSubmit hooks), AST-skeleton reads, delta re-reads, local dashboard. −18% independent. **License: PolyForm Noncommercial** (free for individuals/OSS; companies need a license).
- **ooples/token-optimizer-mcp** — MCP caching server (Brotli + SQLite); −23% independent, 70–90% only on repeat reads.
- **mksglu/context-mode** — routes MCP tool outputs into a local SQLite sandbox, returning summaries; author/community report 50–90% cut on MCP-heavy sessions.
- **tokless (HoangP8)** — unified installer that wires RTK + caveman + ponytail + CodeGraph + Context-Mode + Karpathy rules across agents in one command (~129 stars).
- **andrej-karpathy-skills / RDXmin "ponytail"** — CLAUDE.md behavioral rules that reduce overbuild/rework (indirect savings via fewer correction cycles).
- **Usage monitors:** phuryn/claude-usage, Maciek-roboblog/Claude-Code-Usage-Monitor, tokscale — local dashboards/alerts (measurement only).
- **CPR (cpr-compress-preserve-resume)** — 3 skills for session save/restore; modeled ~55% session-restart savings (analytical, not measured).

## Architecture — where each optimization fits the pipeline

```
Developer prompt
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│  SESSION STARTUP (loads every turn — 30–50% of tokens)       │
│   • System prompt        → (fixed)                           │
│   • CLAUDE.md            → keep <2KB; move rest to Skills     │
│   • Skills (name+desc)   → progressive disclosure (~100 tok)  │
│   • MCP tool schemas     → Tool Search Tool / defer_loading   │
│                            (77K→8.7K on 50+ tools, Anthropic) │
│   • Memory files         → claude-mem / repowise inject only  │
│                            relevant context                   │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│  AGENTIC LOOP (30–45% of tokens — the big lever)             │
│   Reasoning ─────► /effort, MAX_THINKING_TOKENS cap           │
│                                                               │
│   Tool calls:                                                 │
│    • Bash output  ──[PreToolUse hook]──► RTK / RDXmin / repowise
│                     compress before it enters context         │
│    • File reads   ──► Serena / token-savior (symbol pointers) │
│    • Repo search  ──► Graphify / code-review-graph (graph)    │
│                       claude-context (BM25+vector)            │
│    • MCP output   ──► context-mode (sandbox → summary)        │
│                                                               │
│   Subagents (Task tool) ─► isolate intermediate output,       │
│                            Haiku for exploration              │
│   Output prose ─────────► caveman / RDXmin (terse)            │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│  CONTEXT GROWTH / COMPACTION                                  │
│   • Manual /compact at 60–70% (with preservation hints)       │
│   • Server-side context editing (clears old tool results,     │
│     cache-safe; 29–39% improvement, Anthropic)                │
│   • claude-mem / CPR persist across sessions                  │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
   Claude API  ──►  Results   ──►  ccusage / monitors measure spend
```

## Compatibility Matrix (core stack)

| Tool | macOS | Linux | Windows | Apple Silicon/Intel | Install | MCP | Hooks | Claude Code | Cursor | Gemini CLI | Codex CLI |
|---|---|---|---|---|---|---|---|---|---|---|---|
| RTK | ✅ | ✅ | ✅ (native) | ✅ | Homebrew, Cargo, binary | – | ✅ | ✅ | ✅ | ✅ | ✅ |
| Serena | ✅ | ✅ | ✅ | ✅ | uv/uvx, pip, Docker | ✅ | via reminders | ✅ | ✅ | ✅ | ✅ |
| token-savior | ✅ | ✅ | ✅ | ✅ | pip (venv) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| claude-context | ✅ | ✅ | ✅ | ✅ | npm + Milvus | ✅ | – | ✅ | ✅ | ✅ | ✅ |
| caveman | ✅ | ✅ | ✅ | ✅ | npm/plugin/curl | – | ✅ | ✅ | ✅ | ✅ | ✅ |
| Graphify | ✅ | ✅ | ✅ | ✅ | uv/pip | ✅/skill | ✅ (git) | ✅ | ✅ | ✅ | ✅ |
| code-review-graph | ✅ | ✅ | ✅ | ✅ | pip/uv | ✅ | – | ✅ | ✅ | ✅ | ✅ |
| ccusage | ✅ | ✅ | ✅ | ✅ | npm/bunx/Nix | ✅ | statusline | ✅ | – | ✅ | ✅ |
| claude-mem | ✅ | ✅ | ✅ | ✅ | npx | ✅ | ✅ | ✅ | – | ✅ | ✅ |
| repowise | ✅ | ✅ | ✅ | ✅ | pip | ✅ | opt-in | ✅ | ✅ | ✅ | ✅ |

## Installation Guide (canonical commands)
- **ccusage:** `npx ccusage@latest` (baseline first, no install needed).
- **RTK:** `brew install rtk-ai/tap/rtk` then `rtk init -g --hook-only`; restart Claude Code; verify `rtk gain`.
- **Serena:** `claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)`.
- **token-savior:** `python3 -m venv venv && venv/bin/pip install 'token-savior-recall[mcp]'` then `claude mcp add token-savior -e TOKEN_SAVIOR_PROFILE=core -- venv/bin/token-savior`.
- **caveman:** `claude plugin marketplace add JuliusBrussee/caveman && claude plugin install caveman@caveman`.
- **Graphify (AST-only, local):** `uv tool install graphify` then `graphify install --platform claude` and `graphify extract . --no-cluster`.
- **code-review-graph:** `uv tool install code-review-graph` then `code-review-graph install --platform claude-code --yes && code-review-graph build`.

## Recommended Stacks (installation order)

**Always first (all sizes):** `ccusage` to baseline → turn on built-ins (`/effort`, `MAX_THINKING_TOKENS=8000`, plan mode, subagents, skills-over-CLAUDE.md, trim CLAUDE.md <2KB). Expect 40–60% before any third-party install.

**Small repos (<~30–50 files):**
1. Built-ins + a lean CLAUDE.md (drona23 rules).
2. RTK (terminal output).
3. Optionally caveman/RDXmin if your work is conversational/output-heavy.
- *Skip* graph/index/vector tools — they add overhead and increase tokens at this size.
- Expected cumulative: ~40–55% vs vanilla; quality neutral-to-positive.

**Medium repos:**
1. ccusage → built-ins.
2. RTK.
3. Serena **or** token-savior (symbol navigation) — pick one, they overlap.
4. caveman optional for prose.
- Expected: ~50–65%; quality neutral-to-positive.

**Large monorepos (1000s of files):**
1. ccusage → built-ins.
2. RTK.
3. code-review-graph **or** Graphify **or** repowise (structural navigation) — pick one; these overlap heavily.
4. claude-context if you'll self-host Milvus + local embeddings and accept the privacy tradeoff (or if semantic recall matters).
5. claude-mem for cross-session state (configure carefully; watch for memory looping).
- Expected: graph tools deliver their multiplicative wins here (8x+ on navigation-heavy work); RTK + built-ins add the rest. This is the "$300/mo → $100/mo" tier (ComputingForGeeks stack guidance).

**AI-native engineering teams:** standardize built-ins + RTK (via managed settings/hooks) + one symbol/graph layer as team default; add ccusage dashboards for spend visibility; treat every hook-based tool with security review (they execute code and rewrite tool I/O). Prefer MIT/Apache tools; avoid AGPL (repowise) and PolyForm-Noncommercial (alexgreensh/token-optimizer) for commercial embedding.

### Overlapping / conflicting tools
- **Symbol navigation:** Serena ↔ token-savior — redundant; run one.
- **Graph navigation:** Graphify ↔ code-review-graph ↔ repowise — redundant; run one.
- **Output terseness:** caveman ↔ RDXmin ↔ ponytail — redundant; run one.
- **Memory:** claude-mem ↔ CPR ↔ repowise decisions — overlapping; pick per need.
- **Non-conflicting complements:** RTK (bash) + a symbol/graph tool (reads) + a terseness skill (prose) attack different token sinks and stack cleanly.

## Workflow Design (Developer → Results)
1. **Developer → Git:** work on a feature branch; a clean git history keeps diffs (a token sink) small.
2. **Git → Claude Code:** start session; SessionStart hooks fire (RTK installs its wrapper; claude-mem/repowise inject only relevant prior context; caveman sets terse mode).
3. **Claude Code → local optimization tools (pre-context):** every Bash call passes through RTK's **PreToolUse hook** → compressed before entering context. File reads route through Serena/token-savior symbol tools; repo questions route through the graph tool; MCP outputs route through context-mode's sandbox.
4. **Hooks:** PreToolUse gates/compresses (RTK, effort-aware guards); PostToolUse logs/caches; Stop/SessionEnd persist memory (claude-mem). Effort-aware hooks (`$CLAUDE_EFFORT`, Claude Code v2.1.133+) enforce per-turn budgets deterministically.
5. **MCP servers:** keep few; use Tool Search / `defer_loading` so schemas don't preload.
6. **Claude API:** server-side context editing/compaction clears stale tool results without breaking prompt cache.
7. **Results → measurement:** ccusage/monitors quantify the delta; iterate.

## Expected Token Savings (honest synthesis)
- **Built-ins alone:** 40–60% on typical sessions (largest, most reliable, quality-positive).
- **+ RTK:** additional large savings *only if* bash/test/log output is a meaningful share (60–90% on those commands; ~0% if reads dominate).
- **+ symbol/graph layer:** 20–43% on medium repos (token-savior independent); 5–10x realistic (up to 49–71x cherry-picked) on large monorepos; **negative on small repos**.
- **+ output terseness:** ~65% of the *prose slice* only (1–10% of total); net small on agentic work.
- **Combined realistic ceiling** for a heavy user on a large repo: roughly 2–3x fewer tokens end-to-end, not 10–70x.

## Best Practices
- Baseline with ccusage; add one tool at a time; keep only what `ccusage` proves helps.
- Keep CLAUDE.md <2KB; push everything else into skills (progressive disclosure).
- Fewer MCP servers; enable Tool Search / deferred loading.
- Compact deliberately at 60–70% with preservation hints; don't wait for auto-compaction.
- Use subagents (Haiku) for exploration to keep the main thread lean.
- Turn off lossy compression (RTK, caveman) when you need Claude to read full logs to self-correct.

## Common Mistakes
- Installing optimizers **without a baseline** — you can't tell if they help.
- Installing graph/index/vector tools on **small repos** — they add net overhead.
- Trusting **headline multipliers** (70x/49x/98%) — cherry-picked; independent single-turn results are 20–43%.
- Believing output-compression saves whole-session tokens — it only touches the 1–10% prose slice.
- Ignoring **MCP tool-manifest bloat** — seven servers measured at 67,300 tokens / 33.7% of the window.
- Leaving a giant CLAUDE.md — a 50K-token CLAUDE.md burns ~4% of the window every session before you type.
- Turning compression on during debugging where Claude needs full logs.

## Future Trends
- **Agentic search over RAG** is now the default (Anthropic, Cursor, Windsurf, Cline, Amp); expect first-party structural tools (LSP-as-tool) over community vector indexes. Anthropic's applied-AI post "How Claude Code Works in Large Codebases" points to MCP-exposed structured search for the repos where grep breaks down.
- **Server-side context management** (context editing, server-side compaction, Tool Search, Programmatic Tool Calling) is absorbing what community tools do client-side — future savings increasingly ship inside Claude Code itself.
- **Hybrid architectures** (vector prefilter + agentic confirmation) for the largest codebases.
- **Effort-aware hooks** (Claude Code v2.1.133 exposes `$CLAUDE_EFFORT` to hooks) enable per-turn token budgets deterministically.
- **Consolidation** (tokless-style unified installers) as the ecosystem matures.

## Caveats
- **Star counts are unreliable signals.** Several tools (claude-mem ~87k, graphify ~75k, rtk ~71k, caveman ~69k) show viral-growth patterns that Reddit/Medium sources flag as possibly inflated. Evidence quality ≠ popularity; I ranked by evidence.
- **Most "savings" numbers are author/vendor claims** without independent verification. The only strong independent benchmark (ComputingForGeeks) covers one small repo and one task type; token-savior is the only tool with a public reproducible harness; claude-context's eval is vendor-run but reproducible.
- **Where independent data is missing** (Serena, Graphify large-repo claims, repowise, claude-mem savings), I've said so explicitly. These are promising but unproven at the claimed magnitudes.
- **Numbers are workload-dependent.** The same tool can save 90% or 0% depending on whether your bottleneck is bash output, file reads, prose, or MCP schemas.
- **claude-context is not fully local by default** (embedding API + Zilliz Cloud) — it satisfies the "no cloud dependency" constraint only if you self-host Milvus and a local embedding model.
- **License watch:** most tools are MIT/Apache-2.0 (commercially safe); repowise is AGPL-3.0 and alexgreensh/token-optimizer is PolyForm-Noncommercial — read before commercial adoption.
- Dates/versions/stats are as of July 17, 2026 and move fast (RTK alone shipped 242 releases).