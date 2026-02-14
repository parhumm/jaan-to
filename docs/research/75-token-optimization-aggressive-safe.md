Here’s what I see after reading the three docs you shared (Research #62, Research #18, and docs/token-strategy.md) — plus the gaps that are still “big token wins” for jaan.to, and a set of copy-paste deep-research prompts to push this further while keeping output quality.

What you already cover well (and should keep)

From docs/token-strategy.md, you already have the right primitives:
	•	Description budget management (15,000 chars + per-skill XML overhead + max description length + validation).
	•	Reference extraction (split “execution core” vs “reference payload”).
	•	Frontmatter control (disable-model-invocation, context: fork) and a rough per-session / per-invocation saving model.
	•	Line targets per skill complexity (great for enforcing compact skills).

This is a solid “skill-level” strategy. The main opportunity is: jaan.to still needs more session-level + tool-level + output-level controls to get aggressive without degrading quality.

⸻

Gaps to close for more aggressive token optimization

1) CLAUDE.md + rules loading strategy isn’t operationalized in jaan.to

Research #62 is loud about this: root CLAUDE.md is an always-loaded tax; nested CLAUDE.md can be lazily loaded; path-scoped rules should be conditional.

Gap in token-strategy.md:
	•	It references session-level behavior, but doesn’t define a concrete CLAUDE.md architecture (root minimal + trigger table + subtree CLAUDE.md + .claude/rules/ path scoping).
	•	No token budget target for root CLAUDE.md (ex: “< X lines” or “< Y tokens”).

Aggressive move (quality-safe):
	•	Turn root CLAUDE.md into a routing index (trigger table + a few global invariants).
	•	Push everything else into path-scoped rules and domain CLAUDE.md inside skill folders.

⸻

2) MCP/tool schema overhead strategy isn’t represented in jaan.to’s token strategy

Research #62 frames MCP tools as catastrophic without deferral/tool search. Research #18 mentions defer_loading: true as the big lever.

Gap in token-strategy.md:
	•	No explicit plan for tool schema deferral, tool registry minimization, or tool consolidation (merge many small tools into fewer “action-param” tools).
	•	No mention of limiting tool outputs (server-side pagination / summarization patterns).

Aggressive move (quality-safe):
	•	If jaan.to uses MCP-like connectors: require “deferred schema” or “tool search indexing”.
	•	Consolidate “CRUD explosion” tools into fewer parameterized tools.
	•	Set hard MAX_OUTPUT policies per tool response (and enforce in tool wrapper / hooks).

⸻

3) Hook strategy is missing (the best “dynamic context” lever)

Research #62: hooks are token-efficient unless they inject stdout in specific phases (SessionStart, UserPromptSubmit, exit-code 2).

Gap:
	•	No policy for using SessionStart to inject only current context (branch, workspace status, active services) instead of static docs.
	•	No policy for avoiding “death by validation hook errors” (exit code 2 → error text accumulates).

Aggressive move (quality-safe):
	•	Use SessionStart hooks to inject high-signal, tiny context (like “current repo, branch, changed files summary”).
	•	Treat hook outputs as budgeted (e.g., max 200–400 tokens) and auto-truncate.

⸻

4) Output budgeting & “verbosity contracts” aren’t defined

Token optimization isn’t just “what loads”—it’s also “what gets written back”.

Gap:
	•	No standard for response shape (summary-first, bounded detail, “ask before expanding”).
	•	No systematic truncation rules for bash logs / diffs / stack traces.

Aggressive move (quality-safe):
	•	Introduce Output Contracts per skill:
	•	“Return: executive summary + decisions + next steps; include details only if asked.”
	•	“All logs: top N lines + pointer to file artifact.”
	•	For heavy outputs: write to files and return a short index.

⸻

5) Measurement + regression prevention is underpowered

You have validate-skills.sh for description budget, but the rest is still “best effort”.

Gap:
	•	No automated baseline overhead snapshot check.
	•	No CI rule that fails if root CLAUDE.md / rules / tool schemas exceed budget.
	•	No standard “token burn audit” loop.

Aggressive move (quality-safe):
	•	Add “token budget CI gates”:
	•	root CLAUDE.md token count
	•	tool schema token count (or “tool search enabled” check)
	•	top 20 heaviest skills by SKILL.md size
	•	Keep a small “golden” set of tasks and measure context usage deltas.

⸻

Aggressive optimization ideas that usually don’t hurt quality
	1.	Skill “micro-frontmatter” discipline
	•	Keep descriptions trigger-oriented and short.
	•	Move “when to use / when not to use” into a compact table in CLAUDE.md trigger index (not per skill).
	2.	Hard tiering
	•	Always-on (very few), Auto-invocable (few), Manual-only (many), Fork/subagent (heavy).
	•	Make this a tracked ratio and enforce it.
	3.	Reference extraction v2
	•	Extract not only templates/tables, but also long checklists, multi-stack comparisons, anti-pattern lists.
	•	Keep “execution core” extremely compact and deterministic.
	4.	“Artifacts not chat” as default for large outputs
	•	Put big tables, long diffs, full test plans into files.
	•	Chat returns an index + key decisions.
	5.	Conversation resets by design
	•	Encourage /clear between unrelated tasks.
	•	Skills should persist state in files so resets don’t hurt.
	6.	Subagent model routing
	•	Use cheaper/smaller models for exploration/validation subagents, reserve heavy models for synthesis only.

⸻

Copy-paste deep research prompts (to generate ideas + implementation plan)

Use these as-is with your deep research workflow. They’re designed to produce actionable changes (not generic tips).

Prompt 1 — “Token budget audit plan for jaan.to”

You are auditing jaan.to’s Claude Code plugin for aggressive token optimization without lowering output quality.
Create a token budget model covering: system prompt + CLAUDE.md hierarchy + rules loading + skills metadata + skill bodies + tool schemas + hook injection + tool outputs.
Output: (1) a budget table with targets, (2) how to measure each component automatically, (3) CI gates that prevent regressions, (4) recommended thresholds and why.

Prompt 2 — “CLAUDE.md architecture redesign”

Design an optimal CLAUDE.md and rules architecture for a large skill framework.
Constraints: root CLAUDE.md must be minimal; detailed rules must load conditionally via nested CLAUDE.md and path-scoped rules.
Output: exact file tree, example root trigger table, examples of 3 path-scoped rules, and a migration checklist from current structure.

Prompt 3 — “Tool schema deferral / Tool Search strategy”

Propose an aggressive plan to reduce tool schema context overhead for a plugin with many connectors/tools.
Include: schema deferral/tool search indexing approach, tool consolidation patterns (action parameter), description trimming rules, output pagination strategy, and how to verify deferral is active.
Output: step-by-step implementation guide + risks.

Prompt 4 — “Hook strategy for dynamic context”

Create a hook strategy that replaces static context with dynamic session context while keeping token usage bounded.
Include: SessionStart payload design, UserPromptSubmit enrichment design, hard token caps + truncation rules, and guardrails to avoid exit-code-2 accumulation.
Output: a policy + example hook outputs + what NOT to do.

Prompt 5 — “Output Contracts per skill”

Define “Output Contracts” for skills to reduce tokens while preserving usefulness.
Include: default response schema, escalation ladder (ask before expanding), rules for logs/diffs/stack traces, and artifact-first patterns.
Output: a reusable template that can be embedded in each SKILL.md in <20 lines.

Prompt 6 — “Reference extraction playbook v2”

Build a playbook for splitting large SKILL.md files into execution core vs reference files.
Include: what must stay in SKILL.md, what must move out, how to write inline pointers, and how to ensure the model reliably loads references only when needed.
Output: checklist + examples of before/after refactors.

Prompt 7 — “Fork/subagent decision matrix”

Create a decision matrix for when a skill should run with context: fork, when it should be manual-only, and when it should be auto-invocable.
Include: token economics, risk profile (hallucination/overreach), and quality impact.
Output: a table + rules + examples for 10 archetypal skills.

Prompt 8 — “Regression tests for skill routing”

Design a testing strategy that ensures aggressive trimming doesn’t break skill routing quality.
Include: structural validation, deterministic tests, semantic eval sampling, and how to detect routing failures caused by shorter descriptions.
Output: CI-ready approach + what to measure + sample test cases.

Prompt 9 — “Compression style guide”

Create a writing style guide for token-efficient instructions that remain unambiguous.
Include: preferred formats (tables/bullets), banned patterns (redundant prose), “do / don’t” examples, and a lint checklist for reviewers.
Output: a 1–2 page guide.

Prompt 10 — “Worst-case stress test”

Propose a stress test that simulates the worst-case: many skills + many tools + large outputs.
Define scenarios, success criteria, measurement method, and how to attribute token usage to root causes.
Output: test plan + expected failure modes + mitigations.

---

# “Token budget audit plan for jaan.to”

Below is a token budget model + automation plan you can drop into jaan.to as a living “overhead contract” for aggressive optimization without quality loss. I’m assuming a 200K context window (Claude Code Sonnet/Opus) and a plugin-style skills framework.

Key ground truths from Claude docs / ecosystem:
	•	Skills load progressively: at startup only name + description metadata load; the full SKILL.md loads only when invoked.  ￼
	•	CLAUDE.md and unscoped rules are always-loaded overhead (and accumulate across hierarchy).  ￼
	•	MCP tools can dominate baseline context unless MCP Tool Search defers schemas when tool descriptions exceed 10% of context.  ￼
	•	Hooks: SessionStart and UserPromptSubmit stdout can be injected as context; exit-code-2 stderr gets fed back to Claude.  ￼

⸻

(1) Budget table with targets (baseline + per-invocation)

A) Baseline overhead budget (target ≤ 25% of context)

Component	What it includes	Target (tokens)	Hard cap (tokens)	Why / note
System prompt (non-skill)	global behavioral instructions, guardrails	2,500–4,000	6,000	Keep “always-on” instructions minimal; everything else should be skills or lazy files.
CLAUDE.md hierarchy	root + any imported via @... + user/global + enterprise	800–1,500	2,500	CLAUDE.md loads every session and can’t be progressively disclosed; biggest leverage area.  ￼
.claude/rules/ unscoped	rules without paths:	0–400	800	Unscoped rules behave like permanent system prompt. Prefer path-scoped rules.  ￼
Skills metadata	<available_skills>: name+description for auto-invocable skills	1,500–3,500	5,000	Startup loads only metadata, not bodies. Keep descriptions tight and reduce auto-suggested skills.  ￼
Tool schemas (MCP)	tool definitions + JSON schema	3,000–8,000 (with Tool Search)	20,000	With Tool Search, schemas load on-demand, reducing baseline. Tool Search triggers at ~10% context by default.  ￼
Hook injection (baseline)	SessionStart injected context	0–300	500	SessionStart stdout is injected; keep it tiny and dynamic.  ￼
Baseline overhead total		≤ 50,000	≤ 65,000	Leaves ~135K–150K for real work and avoids “lost-in-the-middle” degradation.

B) Per-skill invocation budget (per run)

Component	Target	Hard cap	Why / note
Skill body load (SKILL.md)	2K–5K tokens	8K tokens	Anthropic guidance emphasizes keeping skills compact; load references only when needed.  ￼
Reference files loaded	0–3K	6K	Only load a section on demand (not whole file).
Hook injection (UserPromptSubmit / PreToolUse additionalContext)	0–300	600	These can silently bloat every turn if uncapped.  ￼
Tool outputs	0–3K per call	8K per call	Big tool outputs are the fastest way to burn context; always paginate/summarize.  ￼
Fork isolation (context: fork)	Use for heavy workflows	N/A	Keeps large reasoning/tool chatter out of main thread; only summary returns (your own docs already use this idea).  ￼


⸻

(2) Automatic measurement (per component)

You want two layers of measurement:
	1.	Static estimators (fast, deterministic, in CI on every PR)
	2.	Dynamic reality checks (optional/nightly/manual; uses Claude Code itself)

A) System prompt (non-skill)

Static
	•	Keep the system prompt text in a single file (or generate it deterministically).
	•	Tokenize it in CI and enforce caps.

How to tokenize
	•	Use an Anthropic-compatible tokenizer library (Node or Python) in CI.
	•	If you can’t get exact Claude tokenization reliably, use character budgets as a proxy with conservative caps (e.g., 4 chars ≈ 1 token) and keep hard caps low.

B) CLAUDE.md hierarchy

Static
	•	Compute a “loaded set”:
	•	CLAUDE.md at repo root
	•	any @path imports (recursively)
	•	.claude/rules/ unscoped rules (treated separately)
	•	(optionally) user-level ~/.claude/CLAUDE.md can’t be read in CI; document it as “must be minimal” and measure locally.

Dynamic (recommended locally)
	•	Run Claude Code and check /context after startup for “memory/rules” contribution.

CLAUDE.md layering is widely discussed and confirmed by community + issues.  ￼

C) .claude/rules/ loading

Static
	•	Parse YAML frontmatter for paths::
	•	If paths is missing ⇒ counts as always-loaded.
	•	Budget: sum tokens of unscoped rules.

D) Skills metadata (name+description)

Static
	•	For each SKILL.md:
	•	parse frontmatter: name, description, disable-model-invocation
	•	Measure:
	•	count auto-invocable skills = disable-model-invocation != true
	•	sum description lengths (you already enforce a shared char budget in your repo)
	•	Enforce:
	•	description max length
	•	total description budget
	•	max # auto-invocable skills per tier

Skills progressive disclosure at discovery time is explicitly recommended.  ￼

E) Skill bodies (loaded on invocation)

Static
	•	Enforce:
	•	max lines per complexity tier
	•	max estimated tokens per SKILL.md
	•	“reference extraction” required when exceeding thresholds

Dynamic
	•	Trigger a skill in a controlled harness and check /context delta before/after (manual or nightly).

F) Tool schemas (MCP) + tool search

Static
	•	If your plugin ships MCP config, verify that Tool Search is enabled (if configurable) OR verify you’re safely under 10% threshold.
	•	For each MCP server/tool schema file you own: tokenize and sum.

Dynamic (high value)
	•	Start Claude Code with your MCP set and run /context:
	•	verify that tool schemas are “deferred/on-demand” (Tool Search active)
	•	record baseline tool tokens

MCP tool costs can be enormous (tens of thousands) and Tool Search was added to address this by deferring tools when tool descriptions exceed ~10% of context.  ￼

G) Hook injection

Static
	•	For hooks that print JSON / text:
	•	run the hook script in CI with representative env vars
	•	capture stdout/stderr and tokenize
	•	Enforce:
	•	SessionStart stdout tokens <= 300
	•	UserPromptSubmit stdout tokens <= 300
	•	exit code 2 usage: forbid in non-critical hooks (because stderr is fed into context).  ￼

H) Tool outputs

Static
	•	If you own wrappers/tools: enforce --limit, --max-results, pagination, etc.
	•	Lint tool calls inside skills (e.g., forbid git log without -n).

Dynamic
	•	On a test run, capture tool outputs and tokenize; fail if any single tool output exceeds cap.

⸻

(3) CI gates to prevent regressions (practical + enforceable)

Gate set (run on every PR)
	1.	CLAUDE.md hard cap
	•	CLAUDE.md + imported @... files tokenized ≤ 2,500 (warn at 1,500)
	•	Block PR if exceeded.
	2.	Unscoped rules cap
	•	Sum of .claude/rules/*.md without paths: ≤ 800 tokens (warn at 400)
	3.	Skill description budget
	•	Total description characters ≤ your existing 15,000-char budget
	•	Max description length ≤ 120 chars (or whatever you set)
	•	Max auto-invocable skills count (e.g., ≤ 60) so metadata doesn’t creep
	4.	Skill body limits
	•	Any SKILL.md > 500 lines ⇒ fail (or require a reference split)
	•	Any SKILL.md estimated > 8K tokens ⇒ fail (must extract references)
	5.	Hook output caps
	•	Run hook scripts; if stdout token count exceeds cap ⇒ fail
	•	If hook returns exit code 2 in non-allowlisted cases ⇒ fail
	6.	Tool-call linting inside skills
	•	Regex checks for unbounded commands:
	•	git log without -n
	•	cat on huge files without sed -n / head
	•	rg without file/path constraint in monorepos
	•	Fail or warn depending on severity.

Gate set (nightly or manual “release audit”)
	7.	Dynamic baseline /context snapshot
	•	Start Claude Code with the plugin + MCP config
	•	Record baseline tokens by category (skills metadata, tools, memory)
	•	Compare to last known baseline; fail if baseline overhead increased > X% (e.g., 5–10%)

This catches “it passed static checks but reality blew up” scenarios—especially MCP and any weird full-skill-loading regressions (which has been reported in issues).  ￼

⸻

(4) Recommended thresholds and why (the “aggressive but safe” rationale)

Core philosophy
	•	Always-loaded content must be tiny (CLAUDE.md, unscoped rules, startup hook injection, tool schemas).
	•	Everything else must be progressively disclosed (skills, references, tools on-demand).

Thresholds that typically keep quality intact
	•	Baseline overhead ≤ 25% (≤ 50K of 200K): preserves room for multi-step work without frequent /compact.
	•	Root CLAUDE.md + imports ≤ 1,500 target / 2,500 hard cap: forces the “trigger table + pointers” pattern instead of prose manuals. CLAUDE.md is always loaded.  ￼
	•	Unscoped rules ≤ 400 target / 800 hard cap: prevents rule creep; path-scoped rules are fine because they load conditionally (when relevant).
	•	Auto-invocable skills ≤ 60 (or whatever keeps your metadata under ~3–5K tokens): routing quality stays high if descriptions are precise; everything else can be manual-only (disable-model-invocation) while still available.  ￼
	•	Tool schemas baseline ≤ 8K with Tool Search; if Tool Search isn’t active, you’re playing with fire—real baselines of 60–80K+ happen quickly with a few MCP servers.  ￼
	•	Hook stdout caps (300 tokens): hooks are a stealth tax because they run often and can inject context. SessionStart/UserPromptSubmit stdout is context.  ￼
	•	Tool output cap 8K per call: you can keep quality by summarizing + paginating; dumping raw payloads burns context fastest.  ￼
	•	SKILL.md body cap ~5K target / 8K hard cap: encourages reference extraction, keeps invocation efficient; aligns with the “metadata at startup, body on demand” model.  ￼

---


# “CLAUDE.md architecture redesign”

Below is an optimal CLAUDE.md + rules architecture for a large skill framework (like jaan.to), designed to keep the root CLAUDE.md minimal while ensuring detailed guidance loads only when relevant via nested CLAUDE.md and path-scoped rules.

This design leans on Claude Code’s documented usage pattern for CLAUDE.md as persistent context and the newer rules directory for modular/path-scoped instructions.  ￼

⸻

1) Exact file tree

This tree separates:
	•	Always-loaded: root CLAUDE.md (tiny) + only truly global rules
	•	Conditionally loaded: path-scoped rules + nested CLAUDE.md inside subtrees (PM/dev/design/etc.)
	•	Skill content: still lives in skills/**/SKILL.md and loads only on invocation (progressive disclosure)  ￼

claude-code/
├─ CLAUDE.md                          # Minimal (routing + invariants only)
├─ .claude/
│  └─ rules/
│     ├─ 00-global-minimal.md         # Tiny global invariants (unscoped)
│     ├─ 10-project-activation.md     # paths: ["jaan-to/**"] activation + boundaries
│     ├─ 20-output-contracts.md       # paths: ["jaan-to/outputs/**"] write conventions
│     ├─ 30-skills-authoring.md       # paths: ["skills/**"] maintainers-only rules
│     ├─ 40-language-protocol.md      # paths: ["**/*"] OR tighter where needed
│     └─ 90-security-ops.md           # paths: ["scripts/**","hooks/**"] safety/risk rules
├─ skills/
│  ├─ pm/
│  │  ├─ CLAUDE.md                    # PM conventions (loaded when working in pm subtree)
│  │  └─ ... skills ...
│  ├─ dev/
│  │  ├─ CLAUDE.md                    # Dev conventions
│  │  └─ ... skills ...
│  ├─ qa/
│  │  ├─ CLAUDE.md                    # QA conventions
│  │  └─ ... skills ...
│  └─ ... other domains ...
├─ docs/
│  ├─ CLAUDE.md                       # “Docs mode” conventions (writing style, links, etc.)
│  └─ ...
├─ hooks/
│  ├─ CLAUDE.md                       # Hook constraints (token caps, exit code 2 policy)
│  └─ hooks.json
└─ scripts/
   └─ CLAUDE.md                       # Script conventions + output limiting rules

Why this tree works
	•	Root CLAUDE.md stays lean because detailed guidance moves into path-scoped rules and nested CLAUDE.md that only load when Claude touches that subtree. Modular rules are specifically intended to prevent “everything loads every session” bloat.  ￼
	•	Skills already benefit from progressive disclosure: metadata at startup; SKILL.md read when invoked.  ￼

⸻

2) Example root trigger table (minimal CLAUDE.md)

The root file should be a router + invariants. Keep it under ~150–200 lines max.

# jaan.to — Minimal Router (root)

## Hard invariants (always true)
- Operate only inside the active project’s `jaan-to/` directory unless explicitly asked otherwise.
- Prefer using existing skills over inventing new workflows.
- Keep tool outputs bounded (limit logs/results; summarize first).

## Where things live (short index)
- Skills: `skills/<domain>/<skill>/SKILL.md`
- Project activation: `jaan-to/` (exists only when `/jaan-to:jaan-init` has run)
- Outputs: `jaan-to/outputs/`
- Learning: `jaan-to/learn/`
- Hooks: `hooks/`
- Rules: `.claude/rules/`

## Skill triggers (routing table)
| User says / intent | Use skill | Domain |
|---|---|---|
| “activate jaan.to”, “init project”, “setup jaan-to” | `jaan-init` | core |
| “create PRD”, “write spec”, “product doc”, “scope feature” | `prd-generate` | pm |
| “implement backend/service”, “API endpoint”, “db migration” | `backend-service-implement` | dev |
| “write tests”, “test plan”, “QA cases” | `qa-test-generate` | qa |
| “security audit”, “OWASP”, “CWE”, “threat model” | `sec-audit-remediate` | sec |
| “infra scaffold”, “deploy”, “docker”, “k8s” | `devops-infra-scaffold` | devops |
| “token optimization”, “skills too big”, “context is full” | `token-optimize` | platform |

## Escalation rule
If unsure which skill applies: ask one clarifying question OR run the detection skill (`detect-*`) in fork context.

This matches Anthropic’s guidance that Skills routing depends heavily on concise, trigger-oriented metadata and lean always-on context.  ￼

⸻

3) Examples of 3 path-scoped rules

These are .claude/rules/*.md files with YAML frontmatter specifying paths. (Rules directory is designed exactly for this modular, conditional loading.)  ￼

Rule A — Project activation + boundaries (only when jaan-to/** is involved)

File: .claude/rules/10-project-activation.md

---
paths: ["jaan-to/**"]
---

# jaan.to Project Boundaries
- Only write generated deliverables to `jaan-to/outputs/` unless the user requests another location.
- Only write learning notes to `jaan-to/learn/`.
- Before any file write: show a short preview + ask for explicit approval.
- Prefer templates from `jaan-to/templates/` when available.

Rule B — Skill authoring constraints (only when editing skills/**)

File: .claude/rules/30-skills-authoring.md

---
paths: ["skills/**"]
---

# Skill Authoring Rules (maintainers)
- Keep SKILL.md concise; extract large tables/templates into reference files.
- Descriptions must be trigger-oriented and <= 120 chars.
- Use `disable-model-invocation: true` for internal-only skills.
- Use `context: fork` for heavy workflows that shouldn’t pollute main context.

(These align with Anthropic’s skill progressive-disclosure and authoring best practices.)  ￼

Rule C — Hooks safety + token caps (only when touching hooks/scripts)

File: .claude/rules/90-security-ops.md

---
paths: ["hooks/**", "scripts/**"]
---

# Hooks & Scripts Guardrails
- Hook stdout must be minimal; avoid printing large blobs.
- Avoid exit code 2 unless blocking is strictly required (stderr is fed back as context).
- Always bound CLI outputs: prefer `-n`, `--max-results`, `head`, `sed -n '1,200p'`.
- Never add “format-on-every-write” hooks; formatting should run in CI/pre-commit instead.

(Claude Code hook behavior and exit-code semantics are documented; path scoping keeps these rules from loading when irrelevant.)  ￼

⸻

4) Migration checklist from your current CLAUDE.md

Your current root CLAUDE.md includes: file location table, principles, trust rules, two-phase workflow, quality rules, language protocol pointer, references. The goal is to keep only what must be always-on, and move the rest into conditional rules / nested CLAUDE.md.

Step 0 — Define your “always-on” budget
	•	Target: root CLAUDE.md ≤ ~150–200 lines.
	•	Anything longer must justify being loaded in every session. (Claude Code guidance emphasizes keeping persistent context focused and relevant.)  ￼

Step 1 — Rewrite root CLAUDE.md into “Router + 6 invariants”

Keep:
	•	5–8 bullet invariants (boundaries, no duplication, ask approval before writes)
	•	Short “where things live” index
	•	Trigger table (skills routing)

Remove from root (move elsewhere):
	•	Most of the long “Trust / Two-phase / Quality” prose
	•	Anything that is only relevant when editing certain paths

Step 2 — Create .claude/rules/00-global-minimal.md (unscoped)

Put only the true invariants here (the ones you currently call “Critical Principles”):
	•	single source of truth
	•	approval before writes
	•	output location default
Keep this file tiny (few hundred tokens).

Step 3 — Convert “Trust / file operations” into path-scoped rules
	•	Move your “Output writes to jaan-to/outputs/ … Learning to jaan-to/learn/ …” into paths: ["jaan-to/**"] rule (like Rule A).
This ensures it loads only when the project is actually activated / relevant.

Step 4 — Move “Quality” to domain nested CLAUDE.md files

Example:
	•	skills/pm/CLAUDE.md → PRD structure requirements
	•	skills/qa/CLAUDE.md → QA standards/checklists
	•	skills/dev/CLAUDE.md → coding standards / stack conventions

Nested CLAUDE.md is the right pattern for monorepos or multi-domain frameworks where conventions differ by subtree.  ￼

Step 5 — Move “Language protocol” into a rule with careful scoping

Right now root says “Read and apply language protocol: docs/extending/language-protocol.md”.
Better:
	•	Convert it into .claude/rules/40-language-protocol.md
	•	Scope it narrowly if possible (e.g., only docs outputs) to avoid always-on cost.

Step 6 — Add a hooks rule + enforce caps
	•	Create .claude/rules/90-security-ops.md (Rule C)
	•	Ensure your hook scripts never print large stdout by default; hook docs show stdout/stderr handling and why exit code 2 can inflate context.  ￼

Step 7 — Keep “File Locations” as a short index (or move it)

Your file table is helpful, but long tables cost tokens.
Options:
	•	keep a short “where things live” list in root
	•	move the full table to docs/README.md or docs/CLAUDE.md (loaded when editing docs)

Step 8 — Verify behavior (smoke test)
	•	Start a fresh session and inspect baseline context usage (/context in Claude Code)
	•	Then open/edit something in skills/pm/** and ensure the PM nested CLAUDE.md + scoped rules apply.
	•	Edit hooks/** and ensure hook guardrails activate.

(Claude Code best practices emphasize testing workflows and staying aware of constraints.)  ￼


---


# Tool schema deferral / Tool Search strategy


Below is an aggressive (but quality-safe) plan to reduce tool schema context overhead for jaan.to when you have many connectors/tools (especially MCP). It covers schema deferral / tool search, tool consolidation, description trimming, output pagination, verification, and risks.

⸻

Strategy overview

Goal

Start sessions with minimal tool-definition tokens and load only the tools needed, while keeping tool behavior reliable and outputs bounded.

Core levers
	1.	On-demand tool loading via Tool Search (vs. preloading all schemas)  ￼
	2.	MCP Tool Search in Claude Code (auto-triggered when tool descriptions exceed ~10% context, but verify—there are known edge cases)  ￼
	3.	Tool consolidation to reduce catalog size and “schema surface area” (fewer tools, cleaner routing)
	4.	Strict output pagination/summarization to prevent tool responses from eating the context window (Claude Code best practices emphasize context fills quickly with command output)  ￼

⸻

Step-by-step implementation guide

Step 1) Inventory your tool overhead (baseline snapshot)

What to do
	•	Start a clean Claude Code session with all your connectors enabled.
	•	Run /context and record:
	•	baseline tokens before any work
	•	tool-related tokens (if shown)
	•	how much is consumed immediately

Why
Claude Code context can fill quickly and performance degrades as it fills—baseline overhead is the silent killer.  ￼
Several real-world reports show MCP tools alone can consume tens of thousands of tokens.  ￼

Artifact
	•	Store the baseline snapshot in jaan-to/learn/tool-overhead-baseline.json (or similar) for regression comparisons.

⸻

Step 2) Turn on schema deferral via Tool Search (preferred)

You have two routes depending on where your toolset is configured.

2A) If you’re using the Claude API “tool search tool”
Use the Tool Search tool pattern: keep a tool catalog (names/descriptions/arg names) searchable, and only load selected tool schemas on demand.  ￼

Outcome
	•	Massive reduction in upfront schema tokens
	•	The model “discovers” tools when needed, instead of carrying all schemas constantly

2B) If you’re using Claude Code + MCP
Claude Code has MCP Tool Search (lazy loading) that should automatically activate when MCP tool descriptions exceed ~10% of context.  ￼

Action
	•	Ensure you’re on a Claude Code version that includes MCP Tool Search (recent releases).
	•	Confirm it’s actually activating (Step 6).

Important note
There are open issues indicating Tool Search may not auto-enable in some situations even when the 10% threshold is exceeded—so you must verify.  ￼

⸻

Step 3) Apply “tool consolidation” patterns (reduce tool count + schema size)

Even with Tool Search, a smaller and cleaner tool catalog improves selection quality and reduces searchable metadata size.

Pattern A — “Action parameter tool” (recommended)
Instead of 25 tools like:
	•	db_get_user, db_update_user, db_list_users, db_delete_user, …

Create one tool:
	•	db(action, payload) where action ∈ {get_user, update_user, list_users, delete_user}

Benefits
	•	Fewer tool definitions to index
	•	Less schema duplication
	•	More consistent pagination and output shape

Quality guardrail
	•	Keep action enum small and well-described
	•	Validate payload server-side; return structured errors

Pattern B — “Resource + verbs” (HTTP-style)
Tools:
	•	users.read, users.search, users.update
	•	videos.search, videos.get, videos.update

This stays discoverable without exploding tool count.

Pattern C — “Batch endpoints”
Replace repeated calls with:
	•	analytics.queryBatch([{query1}, {query2}, ...])

Risk tradeoff
	•	Bigger single responses → must enforce pagination (Step 5)

⸻

Step 4) Trim tool descriptions for search efficiency (without breaking usability)

Tool Search indexes names, descriptions, argument names, argument descriptions.  ￼
So trimming doesn’t just reduce tokens—it reduces noise in tool selection.

Rules
	•	1–2 lines per tool description, max ~200–300 chars
	•	Start with an imperative verb: “Search…”, “Create…”, “Fetch…”
	•	Include only disambiguators:
	•	auth scope (read-only/write)
	•	domain (payments vs content vs analytics)
	•	output shape (paginated vs single)

Do not include
	•	Examples, edge cases, long error docs in description
Move those to a developer doc or a “help” tool.

⸻

Step 5) Enforce output pagination + summarization (hard caps)

Unbounded tool output (or command output) is a top context-burn source. Claude Code best practices call out that context includes every command output and fills fast.  ￼
Real-world MCP guidance shows tools can consume huge context before conversation even starts, and outputs worsen it.  ￼

Implement
	•	Every list/search tool must accept:
	•	limit (default 20; max 100)
	•	cursor / pageToken
	•	fields (server-side projection)
	•	Every tool response must include:
	•	items (bounded)
	•	nextCursor if more data exists
	•	summary (1–5 lines, computed server-side)

Server-side caps (strongly recommended)
	•	Hard truncate large text fields unless include=full_text is explicitly requested
	•	For logs/traces: return head + tail + “download link / file path” pattern

Known pitfall
Claude Code has an open issue where it doesn’t follow tools/list pagination in some setups (only sees first page of tools). If your MCP gateway returns a cursor, verify Claude Code retrieves subsequent pages.  ￼

⸻

Step 6) Verify deferral / Tool Search is active (don’t assume)

You need two proofs: user-visible and server-visible.

Proof A — /context delta
	•	Start session → run /context
	•	If tool schemas are deferred, baseline tool tokens should be dramatically lower than before.

Some tool-search guidance explicitly suggests checking /context to confirm the difference.  ￼
Also, Claude Code’s CLI docs cover built-in commands (use it as your canonical reference).  ￼

Proof B — MCP server logs
On your MCP server (or gateway), instrument:
	•	when the full schema is requested
	•	which tools are requested and when
	•	whether “search” requests occur prior to schema load

Expected
	•	At session start: few/no full schema loads
	•	On demand: narrow schema loads for selected tools only

Proof C — “Tripwire test”
Create a fake MCP server with:
	•	500 dummy tools (large total schema)
	•	1 real tool (“ping”)
If Tool Search/deferral works:
	•	session starts fine
	•	“ping” works
	•	dummy tools aren’t all loaded upfront

⸻

Step 7) Roll out safely (staged)
	•	Stage 1: enable Tool Search/deferral + output caps (biggest wins)
	•	Stage 2: consolidate highest-volume tool families (CRUD explosions)
	•	Stage 3: rewrite descriptions + add “help tool”
	•	Stage 4: remove legacy tools and enforce CI gates (below)

⸻

CI gates to prevent regression (tool-side)

Add a tool-budget check that fails PRs when:
	1.	Tool catalog token budget increases beyond threshold
	•	e.g., tool_catalog_tokens <= 8,000 baseline target
	2.	Any tool lacks pagination contract when returning lists
	•	enforce presence of limit + cursor args
	3.	Any tool can return >N bytes without an explicit override
	•	e.g., default max 50KB response; hard max 200KB
	4.	tools/list pagination is validated in integration tests (if you have a gateway)
	•	catch the “first 30 tools only” failure mode  ￼

⸻

Risks and how to mitigate

Risk 1 — Tool Search not activating when expected

Some users report MCP Tool Search not auto-enabling even above the 10% threshold.  ￼
Mitigation
	•	Always verify with /context + server logs
	•	Add a “baseline overhead” regression test in release checklist

Risk 2 — Tool discoverability drops after consolidation

Fewer tools can reduce “obviousness” for the model.
Mitigation
	•	Keep action enums tight and well named
	•	Provide a single “help / catalog search” tool or doc section
	•	Add tool examples outside the searchable description

Risk 3 — Latency increases (on-demand schema loads)

Deferral can add small round trips.
Mitigation
	•	Keep hot-path tools pinned / non-deferred if your platform supports mixed configs (defer most; keep a few always loaded). The API-level concept is discussed in the context of advanced tool use.  ￼

Risk 4 — Pagination bugs hide tools or results

Claude Code may not follow pagination in some contexts (tools/list).  ￼
Mitigation
	•	Test tools/list pagination explicitly in your environment
	•	Consider a gateway that returns ≤30 tools per server or flattens differently until fixed

Risk 5 — Over-trimming descriptions harms selection accuracy

If descriptions become too vague, the model calls wrong tools.
Mitigation
	•	Keep disambiguators (domain, read/write, output shape)
	•	Use consistent naming scheme (domain.verb)


---

# Hook strategy for dynamic context

Hook strategy policy (jaan.to) — replace static context with bounded dynamic context

Goals
	•	Move “stateful” info out of CLAUDE.md (branch, changed files, active project, recent outputs) into hooks.
	•	Keep hook-injected context small, structured, and refreshable, especially after /compact.
	•	Avoid the “exit-code-2 feedback loop” that can keep re-injecting long error text.

Non-negotiables from Claude Code hooks semantics
	•	For SessionStart and UserPromptSubmit, anything printed to stdout (exit 0) is added to Claude’s context.  ￼
	•	Exit code 2 blocks an action; a reason written to stderr becomes model feedback for many events (and can become a repeated token tax if verbose).  ￼
	•	Hooks can return structured JSON, and for UserPromptSubmit you should use hookSpecificOutput.additionalContext (instead of raw stdout dumps) to inject bounded text.  ￼
	•	Matching hooks run in parallel and identical commands are deduplicated, so design your hooks to be composable and cheap.  ￼

⸻

1) SessionStart payload design (dynamic “session header”)

When it runs
	•	Always on SessionStart with matcher: "startup|resume" (small header)
	•	Always on SessionStart with matcher: "compact" (re-inject only critical “anchors”)  ￼

What it should include (max signal / min tokens)

Format: 8–15 lines, stable keys, no prose.
	1.	Repo identity

	•	cwd, repo name, current branch

	2.	Change signal

	•	git status --porcelain counts (not full list unless tiny)
	•	top 5 changed files (paths only)

	3.	jaan.to activation

	•	whether jaan-to/ exists
	•	active output dir and learn dir (resolved paths)
	•	active settings “mode” (only a few key flags; never whole YAML)

	4.	Recent artifacts pointers

	•	last 3 files in jaan-to/outputs/ (filenames only)

Hard token caps + truncation rules
	•	Cap (startup/resume): 250 tokens
	•	Cap (compact): 120 tokens (anchors only)
	•	Truncation rules:
	•	cap file lists to ≤ 5 paths
	•	cap any command output to ≤ 800 chars
	•	if truncated: append … (truncated, see <path-to-log>) and write full output to a local file outside context (e.g., jaan-to/context/session-start.log)

Example SessionStart injected text (stdout, exit 0)

(This is intentionally “boring” and machine-readable.)

[jaan.to session]
cwd=/Users/parhumm/Projects/foo
repo=foo  branch=feature/token-opt
jaan_to_active=true  outputs=jaan-to/outputs  learn=jaan-to/learn
git_changed=7 (M=5 A=2)  top_changes=skills/dev/SKILL.md, docs/token-strategy.md, hooks/hooks.json
recent_outputs=outputs/prd-2026-02-14.md, outputs/qa-plan-2026-02-13.md
constraints=preview-before-write; ask-approval-for-file-ops; bounded-tool-output

“After compact” anchor (matcher: compact)

[jaan.to anchors]
write_to=jaan-to/outputs  learn_to=jaan-to/learn
workflow=two-phase(plan->confirm->write); always-preview

Claude Code’s docs explicitly call out using SessionStart with a compact matcher to re-inject critical context after compaction.  ￼

⸻

2) UserPromptSubmit enrichment design (minimal routing + guardrails)

Principle

UserPromptSubmit should not dump long policy. It should add only what improves first-pass routing and prevents expensive mistakes.

What to inject (max 6–10 lines)
	1.	Intent label (cheap classifier, rule-based)
	2.	Likely skill(s) (1–3 names)
	3.	Output contract reminder (2 lines)
	4.	Hard constraints relevant to the prompt (e.g., “don’t write files yet”)

Hard token caps + truncation rules
	•	Cap: 180 tokens for additionalContext
	•	Never include raw diffs, logs, or file contents
	•	If classification is uncertain: inject “ask 1 clarifying question before tool calls”

Example UserPromptSubmit output (structured JSON, exit 0)

Claude Code supports adding hookSpecificOutput.additionalContext for UserPromptSubmit.  ￼

{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[routing]\nintent=token_optimization\nsuggested_skills=token-optimize,claude-md-redesign,tool-deferral\n[output]\nreturn=summary+next_actions; ask_before_writing_files\n[guardrails]\nbound_tool_output=true; prefer references over full dumps"
  }
}

(Optional) Add a tiny “budget nudge”:
	•	If prompt contains “deep research / long analysis”: inject prefer context: fork for heavy analysis (1 line).

⸻

3) Guardrails to avoid exit-code-2 accumulation

Claude Code behavior makes it easy to accidentally turn hooks into a recursive token generator—especially if you put verbose text on stderr with exit 2.  ￼

Rules
	1.	Exit 2 is reserved for truly destructive prevention
	•	e.g., rm -rf, secret exfiltration, editing .env, dropping prod tables
	2.	When blocking, keep stderr ≤ 60 tokens
	•	one sentence + a suggested safe alternative
	3.	Prefer “deny with short reason” over “block with essay”
	•	For PreToolUse, use permission decision control with a short reason (Claude will adjust)  ￼
	4.	Never use exit 2 for “style reminders”
	•	use exit 0 + systemMessage (user-visible warning) or inject a 1–2 line additionalContext
	5.	De-duplicate recurring failures
	•	if the same block triggers repeatedly in a session, switch to:
	•	exit 0 + a concise reminder (no more than once per N minutes), and log details to file

Recommended “blocking reason” template (≤ 1 line)
	•	Blocked: modifying .env is not allowed. Use .env.example or config/defaults.yaml instead.

⸻

What NOT to do (common token traps)
	1.	Don’t print long stdout on SessionStart/UserPromptSubmit

	•	stdout becomes context for those events.  ￼
Bad: full git diff, full settings.yaml, full file trees.

	2.	Don’t use exit 2 for non-blocking guidance

	•	exit 2 is a blunt instrument and encourages repeated feedback loops.  ￼

	3.	Don’t inject “static manuals” via hooks

	•	If it’s static, keep it in docs or (sparingly) CLAUDE.md. The hooks guide even notes: for injecting context on every session start, consider CLAUDE.md—so if you choose hooks instead, keep it strictly dynamic.  ￼

	4.	Don’t run heavy commands on every hook

	•	Hooks run frequently; keep them O(1) and bounded (counts, top-N lists). Hooks also run in parallel; avoid contention and slowdowns.  ￼



---

# Output Contracts per skill

Here’s a reusable “Output Contract” template you can embed in every SKILL.md to cut tokens while keeping usefulness. It’s aligned with Claude Code’s guidance that context fills fast (including command output) and performance degrades as it fills, so skills should stay concise and progressively disclose detail.  ￼

## Output Contract (Token-Efficient)
- Default response = 5 parts: (1) Outcome (1–2 lines) (2) Decisions (bullets) (3) Next actions (3–7 bullets)
  (4) Risks/assumptions (bullets) (5) If-needed details (only on request).
- Escalation ladder: Summary → Outline → Full detail. Ask: “Want the full version?” before expanding.
- Artifacts-first: If output > ~40 lines OR includes long tables/templates → write to `jaan-to/outputs/<name>.md`
  and return: filename + 3–7 line index + key decisions.
- Logs: never paste raw logs. Return top 20 + bottom 20 lines + “full log saved to <path>”.
- Diffs: show only minimal unified diff for touched files; large diffs → save patch file and summarize changes.
- Stack traces/errors: paste only the first error + 3–5 most relevant frames; link/save full trace if needed.
- Data/tool results: request only needed fields; paginate (default 20). Summarize counts + nextCursor.
- No repetition: don’t restate the user prompt; don’t reprint large file excerpts already shown.

Why this works (and stays quality-safe):
	•	Claude Code explicitly warns that every command output and read content accumulates in the context window, so bounding logs/diffs and pushing bulk into artifacts preserves headroom.  ￼
	•	Anthropic’s skill guidance emphasizes concise, well-structured skills with on-demand loading, which this contract reinforces at the output layer (summary-first + progressive expansion).  ￼

---


# Reference extraction playbook v2

Below is a Reference Extraction Playbook v2 for splitting large SKILL.md files into a compact execution core plus on-demand reference files, while keeping Claude Code’s progressive disclosure behavior intact (metadata at startup → full SKILL.md only when invoked → extra resources only when needed).  ￼

⸻

Playbook goals
	•	Keep invocation payload small: the SKILL.md should be the minimum deterministic process Claude needs to execute the task well.  ￼
	•	Move “bulky but optional” material into reference files that are loaded only when requested by the workflow.  ￼
	•	Prevent context blowups: Claude Code context includes files read + command outputs, so reference extraction must pair with bounded reads/logs.  ￼

⸻

What stays in SKILL.md (execution core)

Keep only what Claude needs every time the skill runs:
	1.	Purpose + activation cues

	•	Short “when to use” (1–3 bullets)
	•	A crisp flow of how the skill runs (phases / steps)  ￼

	2.	The deterministic procedure

	•	Step headings and ordered steps
	•	Tool usage constraints / “how to proceed”
	•	Minimal decision tables (<10 rows) that are critical for routing the flow

	3.	User interaction contract

	•	What to ask the user, when to stop, confirmation gates

	4.	Quality checks + Definition of Done

	•	Short checklist (bullets), no long rubric

	5.	Reference pointer stubs

	•	Inline pointers that name the exact reference section to load

Why: Anthropic’s skill best practices emphasize skills should be concise, well-structured, and tested, and Claude Code guidance highlights context grows fast; a smaller core keeps repeated invocations efficient.  ￼

⸻

What moves OUT of SKILL.md (reference payload)

Move anything that is large, repetitive, or not always needed:
	•	Templates (PRD templates, test plan templates, RFC skeletons)
	•	Code blocks (snippets, scaffolds, multi-file examples)
	•	Long checklists (>10 items) and extensive “do/don’t”
	•	Multi-stack comparisons (tables, matrices)
	•	OWASP/CWE mapping tables, large policy lists
	•	Directory trees (>10 lines)
	•	Examples library (multiple “sample outputs”)
	•	Troubleshooting catalogs (error lists, “if X then Y” for many cases)

Why: Claude loads additional resources only when needed, and you want to preserve that third stage of progressive disclosure rather than paying it every invocation.  ￼

⸻

Reference file structure (make it “loadable by section”)

Create one reference file per heavy skill (or per domain if shared), using stable headings.

Recommended path
	•	docs/extending/<skill-name>-reference.md

Structure
	•	Use H2 sections (##) with unique names
	•	Keep sections independent (Claude should load one without requiring the rest)
	•	Put big templates under their own section

Example skeleton:

# <skill-name> Reference

## Template: PRD (Short)
...template...

## Template: PRD (Full)
...template...

## Checklist: QA
...bullets...

## Patterns: Error handling
...patterns...

## Examples: Good outputs
...examples...

This makes “load section X” reliable because Claude can search headings and read only that segment.  ￼

⸻

Inline pointer pattern (how to reference without bloating)

Use a consistent pointer block inside SKILL.md:

> **Reference (load only if needed):**
> `${CLAUDE_PLUGIN_ROOT}/docs/extending/<skill-name>-reference.md`
> Section: "Template: PRD (Full)"
> Use when: user asks for a full PRD or scope is >3 epics.

Rules for pointer blocks
	•	Always include: file path + exact section title + trigger condition
	•	Never include the full template inline in SKILL.md
	•	Prefer “load section” vs “load file”

This aligns with progressive disclosure: skill core loads on invocation; extra files only when a step explicitly needs them.  ￼

⸻

Ensuring Claude loads references only when needed (reliability tactics)
	1.	Make “need conditions” explicit

	•	Add “Use reference only when…” conditions next to pointers.
	•	Avoid vague language like “may consult”.

	2.	Require “section-targeted read”

	•	In the procedure step, instruct: “Read only the named section.”
	•	Avoid patterns that cause full-file inclusion (e.g., indiscriminate @file). Your own research note warns whole-file inclusion is expensive; pair reference extraction with targeted reads.  ￼

	3.	Keep reference sections short-ish

	•	If a section becomes huge, split it into Template A, Template B, etc.

	4.	Never “preload references” in the skill

	•	No “Before you start, read reference file.” That defeats the purpose.

	5.	Test with real tasks

	•	Anthropic explicitly recommends testing skills with realistic usage to confirm behavior and structure.  ￼

⸻

Checklist (refactor workflow)

A) Identify extraction candidates
	•	SKILL.md > ~500 lines or feels “library-like”
	•	Contains ≥2 of: long templates, large tables, big examples, long checklists

B) Split into core vs reference
	•	Keep only: phases/steps, questions, DoD, minimal decision tables
	•	Move: templates, examples, long lists, mappings, directory trees

C) Build reference file
	•	Create docs/extending/<skill>-reference.md
	•	Organize by ## sections with unique names
	•	Keep each section independently usable

D) Add inline pointers
	•	For each extracted chunk, add a pointer block with:
	•	file path
	•	section name
	•	“Use when…” trigger
	•	Add procedure step: “Load only this section if trigger condition is met.”

E) Guardrails
	•	Add explicit “don’t dump logs / keep outputs bounded” note
	•	Ensure the core doesn’t instruct reading entire directories/files

F) Test
	•	Run 3 scenarios:
	1.	simple case: reference never needed
	2.	medium case: one reference section needed
	3.	complex case: two sections needed
	•	Verify reference is not loaded in scenario (1)

⸻

Before/after refactor examples

Example 1: Moving a template library out of SKILL.md

Before (SKILL.md excerpt)

## Phase 2: Generate PRD
... (200+ lines of PRD template) ...
## Examples
... (150+ lines of examples) ...

After (SKILL.md excerpt)

## Phase 2: Generate PRD
- If scope is small (<= 3 epics), generate “Short PRD”.
- If scope is large or multi-team, load “Full PRD” template section.

> **Reference (load only if needed):**
> `${CLAUDE_PLUGIN_ROOT}/docs/extending/prd-generate-reference.md`
> Section: "Template: PRD (Full)"
> Use when: scope > 3 epics OR user requests full PRD.

- Produce output using the selected template; do not paste template boilerplate.

Reference file (new)
docs/extending/prd-generate-reference.md

## Template: PRD (Full)
... full PRD skeleton ...
## Template: PRD (Short)
... short skeleton ...
## Examples: Strong PRDs
... examples ...


⸻

Example 2: Moving tables + mappings out (OWASP/CWE style)

Before

## Security Mapping Table
| CWE | OWASP | Fix |
| ... 50 rows ... |

After (SKILL.md)

- If the task requires standards mapping (CWE/OWASP), load mapping section and extract ONLY relevant rows.

> **Reference (load only if needed):**
> `${CLAUDE_PLUGIN_ROOT}/docs/extending/sec-audit-remediate-reference.md`
> Section: "Mappings: CWE ↔ OWASP"
> Use when: user requests standards mapping OR compliance reporting.

Reference

## Mappings: CWE ↔ OWASP
...table...


⸻

Example 3: Moving multi-stack code scaffolds out

Before

## Implementation
(300 lines of Node + Python + Go scaffolds)

After

## Implementation
- Choose stack based on repo signals.
- Load the specific scaffold section for the chosen stack only.

> **Reference (load only if needed):**
> `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-service-implement-reference.md`
> Section: "Scaffold: Node/Express"
> Use when: stack=node


⸻

Anti-patterns (what breaks token gains)
	•	“Read the entire reference file before starting.” (forces always-load)
	•	One reference file with no sections (model reads too much)
	•	Pointer blocks without triggers (model loads references “just in case”)
	•	Dumping tool output instead of saving artifact + summary (context balloons)  ￼

---

# Fork/subagent decision matrix

Fork / Manual-only / Auto-invocable decision matrix (jaan.to)

Definitions (Claude Code reality)
	•	Auto-invocable: skill can be automatically applied by the model when relevant.
	•	Manual-only: set disable-model-invocation: true so Claude won’t auto-use it; only explicit /skill runs.  ￼
	•	Fork/subagent: run work in an isolated subagent context so exploration/tool chatter doesn’t pollute the main thread; only a bounded result returns.  ￼

⸻

Decision matrix (10 archetypal skills)

#	Archetype	Typical token economics	Risk profile (hallucination/overreach)	Quality impact if wrong mode	Recommended mode
1	Intent detection / routing (detect-*)	High read/explore; can balloon via repo scanning	Medium: wrong classification routes wrong tools	If not forked: main thread polluted; if auto: can over-trigger	Fork (and often manual-only if expensive)
2	Repo survey / architecture map	Very high file reads + tool outputs	Medium: may “invent” structure unless grounded	If inline: context fills and future turns degrade	Fork
3	Code search / snippet retrieval	Medium; depends on search breadth	Low–Medium: can fetch irrelevant code	If auto: can run too often; if manual: slower but safe	Auto if bounded + scoped; else Fork
4	Small code change (single-file fix)	Low–Medium	Medium: risk of wrong edit but local	If forked: you lose continuity for follow-ups	Auto (keep output contract tight)
5	Large refactor / multi-file changes	High; lots of diffs, tests, logs	High: overreach, touching too much	If auto+inline: huge diffs + regressions	Manual-only (optionally Fork for planning)
6	Security audit / compliance mapping	High; lots of standards tables if loaded	High: false positives/overreach	Auto can create noisy reports and risky patches	Manual-only, plus Fork for scanning phase
7	Prod-impacting ops (deploy, infra, migrations)	Medium (commands) but high blast radius	Very high: dangerous if auto-triggered	Wrong mode = catastrophic	Manual-only (hard guardrails)
8	Data/analytics queries (paginated tools)	Medium; tool outputs dominate	Medium: misinterpretation from partial data	Auto can spam tool calls	Auto if strict pagination; else Manual-only
9	Doc generation (PRD/spec/test plan)	Medium–High (templates can be big)	Medium: can hallucinate if missing inputs	Auto may generate premature long docs	Auto if “ask-first + outline-first”; else Manual-only
10	Knowledge distillation / learning log	Low–Medium	Low: mostly summarization	Auto is okay if it stays short	Auto (often a good background helper)


⸻

Rules (deterministic selection)

A) Choose Manual-only when ANY of these are true
	1.	Blast radius > “local edits”: deploys, infra, migrations, secrets, auth changes.
	2.	Non-reversible or high-cost mistakes: billing, payments, data deletion, security remediation.
	3.	Ambiguous intent: user prompt could map to risky operations.
	4.	Workflow requires explicit human gating (e.g., “HARD STOP before write”).
Implementation: set disable-model-invocation: true.  ￼

B) Choose Fork/subagent when ANY of these are true
	1.	Exploration-heavy: needs broad codebase search, multi-file reading, log scraping.
	2.	High tool chatter: multiple tools, long outputs, iterative probing.
	3.	You want a bounded deliverable: “give me findings + next actions” without polluting main thread.
Rationale: subagents run in isolated context windows and return summarized results.  ￼

C) Choose Auto-invocable when ALL of these are true
	1.	Low-to-medium token footprint by default (bounded reads/outputs).
	2.	Low blast radius (safe operations, reversible edits, planning).
	3.	High frequency / high ROI (users benefit from it triggering naturally).
	4.	Output contract is strict (summary-first; ask before expanding; artifacts for bulk).

⸻

Concrete examples (10 skill examples mapped)
	1.	detect-dev / detect-design → Fork (exploration-heavy; keep chatter isolated)  ￼
	2.	repo-architecture-map → Fork (wide reads + synthesis)  ￼
	3.	code-search-snippets → Auto if bounded (rg scoped + top-N); else Fork
	4.	bugfix-single-file → Auto (fast, local, iterative)
	5.	refactor-module → Manual-only (high overreach risk)  ￼
	6.	sec-audit-remediate → Manual-only + Fork scanning phase (avoid noisy auto-trigger)  ￼
	7.	deploy-prod / db-migrate-prod → Manual-only (highest blast radius)  ￼
	8.	analytics-query → Auto only with strict pagination; else Manual-only
	9.	prd-generate / qa-test-generate → Auto if outline-first + ask for missing inputs; else Manual-only
	10.	learn-add / “session notes” → Auto (short, structured, low risk)

⸻

Practical “scoring” heuristic (fast to apply during skill authoring)

Score each skill 0–2 on each axis:
	•	Token load (0 low, 2 high)
	•	Blast radius (0 local, 2 prod/system)
	•	Ambiguity (0 clear intent, 2 easy to mis-trigger)
	•	Need for continuity (0 discrete task, 2 iterative back-and-forth)

Decision
	•	If blast radius ≥ 1 OR ambiguity ≥ 1 → Manual-only
	•	Else if token load ≥ 1 AND need for continuity ≤ 1 → Fork
	•	Else → Auto

---

# Regression tests for skill routing

Here’s a CI-ready regression testing strategy to ensure aggressive trimming (especially shorter descriptions) doesn’t break skill routing quality in jaan.to.

This is built around how Claude Code Skills are model-invoked based on the user request + the skill’s description (so descriptions are routing-critical).  ￼

⸻

1) What to test (4-layer coverage)

Layer A — Structural validation (fast, deterministic)

Run on every PR.

Checks
	1.	Frontmatter schema + required fields

	•	name, description, flags (disable-model-invocation, context) present/valid.
	•	Prevent empty/duplicate names.

	2.	Description-budget + per-skill limits

	•	Enforce your 15,000-char total description budget (you already do).
	•	Enforce strict per-skill max (e.g., 120 chars) and ban “fluff” patterns.

	3.	Trigger coverage

	•	Every auto-invocable skill must include at least 1 verb + 1 domain noun in description (simple regex lint).
	•	Every manual-only skill (disable-model-invocation: true) must be excluded from routing tests.

	4.	Rules syntax safety (if you use .claude/rules/)

	•	Validate paths: frontmatter syntax matches what Claude Code actually accepts; there are active reports of doc/example mismatch, so treat this as an integration risk and lint it explicitly.  ￼

Output
	•	A machine-readable report: routing_lint_report.json with counts + failures.

⸻

Layer B — Deterministic routing tests (golden suite)

Run on every PR. These tests detect “we trimmed descriptions and now the router picks the wrong skill.”

Mechanism
	•	Build a routing harness that provides the model only:
	•	user query
	•	the list of skill names + descriptions (auto-invocable only)
	•	Ask it to return JSON:
	•	chosen_skill (or null)
	•	top_3 candidates
	•	confidence 0–1
	•	rationale (1 sentence; optional)

Why this matches reality
Claude decides to use skills “when relevant” and that relevance is driven by the skill description.  ￼

Determinism tactics
LLMs aren’t truly deterministic, so you make the test deterministic by:
	•	Running N=5 votes (same prompt) and taking majority vote.
	•	Passing “return JSON only” + strict schema.
	•	Checking stability (if 5 votes disagree → fail as “routing unstable”).

Assertions per test case
	•	chosen_skill == expected_skill (strict)
	•	plus: expected skill appears in top_3 (so you get signal even if tie-break changes)

⸻

Layer C — Semantic eval sampling (realistic, drift-resistant)

Run nightly or on release branches.

Dataset sources
	1.	Curated prompts: 200–500 “typical” user intents (PRD, QA plan, refactor, security audit, token optimization, etc.)
	2.	Confusables: prompts designed to be ambiguous (“write a spec” vs “write a test plan”)
	3.	Negative controls: prompts that should trigger no skill

What to measure
	•	Accuracy@1
	•	Recall@3 (did correct skill appear in top 3?)
	•	Abstain correctness (how often it correctly returns null)
	•	Confusion matrix for your top 20 most-triggered skills
	•	Entropy / instability score: disagreement across N votes

Why you need this
Anthropic’s skill guidance explicitly says good skills are tested with real usage; aggressive trimming changes semantics, so you need a semantic safety net beyond linting.  ￼

⸻

Layer D — “Shorter descriptions broke routing” detection

This is the key trimming-specific safety net.

Compute per skill (PR vs main)
	•	desc_len_delta
	•	token_est_delta (rough tokenizer proxy OK)
	•	keyword_coverage_delta (count of “trigger terms” present)

Add a “routing impact” check
	•	For each skill whose description changed, run:
	•	its 10–30 prompt cases (owned by that skill)
	•	compare pre vs post:
	•	accuracy@1
	•	recall@3
	•	abstain rate

Gate
	•	If a skill description shrinks by >X% (say 30%) and its accuracy drops >Y points (say 3–5%), fail the PR.

⸻

2) CI-ready pipeline (recommended)

Job 1 — lint:skills-routing
	•	Parse all SKILL.md frontmatter
	•	Validate schema
	•	Enforce description constraints
	•	Output routing_lint_report.json
	•	Fail on any error

Job 2 — test:routing-golden
	•	Load tests/routing/golden.json (your canonical suite)
	•	Run harness (N votes per case)
	•	Emit:
	•	routing_results.json
	•	routing_confusions.csv
	•	Fail on:
	•	any strict mismatch
	•	instability above threshold (e.g., >10% cases non-majority)

Job 3 — test:routing-regression-diff
	•	Detect which skills changed descriptions
	•	Run only their owned tests (fast)
	•	Compare to main baseline snapshot
	•	Fail on measured regressions

Job 4 (nightly) — eval:routing-semantic
	•	Run large suite + confusables + negatives
	•	Track time series metrics
	•	Alert on drift (no need to block PRs)

⸻

3) Sample test cases (drop-in)

Create tests/routing/golden.json:

[
  {
    "id": "prd_basic",
    "query": "Create a PRD for adding collaborative playlists",
    "expected_skill": "prd-generate",
    "expected_top3_contains": ["prd-generate"]
  },
  {
    "id": "qa_plan",
    "query": "Write a QA test plan for the new checkout flow",
    "expected_skill": "qa-test-generate",
    "expected_top3_contains": ["qa-test-generate"]
  },
  {
    "id": "token_opt",
    "query": "We’re hitting context limits. Propose aggressive token optimization for the plugin.",
    "expected_skill": "token-optimize",
    "expected_top3_contains": ["token-optimize"]
  },
  {
    "id": "security_audit",
    "query": "Do a security audit of this API and propose remediation steps",
    "expected_skill": "sec-audit-remediate",
    "expected_top3_contains": ["sec-audit-remediate"]
  },
  {
    "id": "negative_no_skill",
    "query": "What’s the capital of France?",
    "expected_skill": null,
    "expected_top3_contains": []
  }
]

Add a confusable pair suite:
	•	“Write a spec” → should choose PRD skill
	•	“Write a test plan” → should choose QA skill
	•	“Implement endpoint” → should choose dev skill
…and ensure trimming doesn’t collapse them into one bucket.

⸻

4) Practical gates (what to measure + thresholds)

Must-pass (PR blocking)
	•	Golden suite accuracy@1 = 100%
	•	Instability rate ≤ 5–10%
	•	For changed descriptions: accuracy@1 drop ≤ 3 points (or zero for owned cases)

Warn-only
	•	Recall@3 drop > 2 points
	•	Abstain correctness drop > 2 points
	•	Confusion spikes for top 5 skills

⸻

5) Implementation notes that prevent false failures
	•	Keep the harness prompt extremely short (token-efficient) and JSON-only.
	•	Separate auto-invocable and manual-only skills: manual-only should not appear in the routing candidate list (your tests should verify this behavior).  ￼
	•	Use /context snapshots (manual or nightly) to correlate routing failures with context bloat—Claude Code recommends keeping persistent context short and being mindful of context growth.  ￼



---


# Compression style guide

Compression Style Guide (Token-Efficient, Unambiguous)

This guide standardizes how we write instructions (CLAUDE.md, .claude/rules/*, SKILL.md, prompts, hook-injected context) so they stay small but deterministic. It assumes Claude Code context is precious and should not be spent on repetitive prose. Claude Code explicitly recommends keeping persistent context “short and human-readable,” and skills should be “concise” and “well-structured.”  ￼

⸻

1) Core principles

1.1 Determinism beats verbosity
	•	Prefer rules + thresholds + schemas over explanation.
	•	Prefer few, global invariants; everything else must be conditional (path-scoped rules, skill invocation, references).

1.2 Progressive disclosure
	•	Always start with a summary contract and expand only if asked.
	•	For skills: metadata routes; body loads on invocation; references load only when needed (keep core tight).  ￼

1.3 Structure > prose

Use formats that compress meaning:
	•	Numbered procedures
	•	Bulleted constraints
	•	Small decision tables
	•	Output schemas (JSON/Markdown skeletons)

Anthropic guidance on prompting emphasizes clarity and structure (lists, examples, explicit goals).  ￼

⸻

2) Preferred formats (use these by default)

A) Micro-spec layout (for any instruction doc)
	1.	Goal (1 sentence)
	2.	When to use / not use (2–6 bullets)
	3.	Workflow (numbered steps; max 7 steps)
	4.	Output Contract (exact schema)
	5.	Guardrails (bullets; thresholds)

This aligns with “concise, well-structured” skills and Claude Code’s “keep it short” guidance.  ￼

B) Decision tables (small)

Use when routing varies. Keep tables ≤ 10 rows and ≤ 4 columns.

Example:

If	Then	Tool/Skill	Notes


C) “If-needed details” blocks

Keep detail behind explicit triggers:

If needed: Load docs/... section “X” when (condition).

D) Output schemas

Prefer one of:
	•	JSON schema (for tools/harnesses)
	•	Markdown skeleton (headings only)
	•	“5-part response” (Outcome / Decisions / Next actions / Risks / Details-if-needed)

⸻

3) Compression techniques that preserve clarity

Technique 1 — Replace explanations with constraints

Instead of: “Be careful not to write large outputs because tokens…”
Use: “Max 40 lines in chat; write longer output to file and return an index.”

Technique 2 — One canonical phrase per concept

Pick one label and reuse it:
	•	“HARD STOP” = must ask user approval before writes
	•	“Bounded output” = top/bottom N lines, paginated

Technique 3 — Use thresholds, not adjectives

Bad: “Keep it short.”
Good: “Root CLAUDE.md ≤ 200 lines; hook additionalContext ≤ 180 tokens.”

Technique 4 — Prefer pointers over inline payload

Inline is permanent token cost; pointers are conditional:
	•	“See ref section X” > pasting templates/checklists.

⸻

4) Banned patterns (token-expensive and ambiguous)
	1.	Redundant prose

	•	“As mentioned above…”
	•	repeating the same rule in multiple places (duplication)

	2.	Narrative instructions

	•	paragraphs describing what to do instead of numbered steps

	3.	Vague modifiers without thresholds

	•	“quickly,” “efficiently,” “carefully,” “as needed” (unless you define “needed”)

	4.	Unbounded enumerations

	•	“Include all…”, “list everything…”, “dump logs…” without limits

	5.	Mixed layers

	•	Don’t mix routing metadata (“use proactively when…”) with expert logic (detailed workflow) in the same block—keep router minimal, body specific (matches skill best practices emphasis on concise discoverable skills).  ￼

⸻

5) Do / Don’t examples

Example A — Procedure

Don’t

First, you should think about the problem thoroughly and consider various approaches…

Do
	1.	Identify goal + constraints (1–3 bullets).
	2.	Choose path via table.
	3.	Execute steps.
	4.	Validate with checklist.
	5.	Return output per contract.

Example B — Logs/diffs

Don’t

Paste the full build log and the full diff.

Do
	•	Logs: show top 20 + bottom 20 lines; store full log in file and link path.
	•	Diffs: show only minimal unified diff; large diffs → patch file + summary.

(Claude Code best practices warn context fills quickly with outputs; bounded output is essential.)  ￼

Example C — Skill description (routing text)

Don’t

Helps with many tasks around engineering, planning, and writing…

Do

“Generate QA test plans for feature changes (cases + risks + coverage).”

Short, verb-first, domain noun, output hint.

Example D — Hook additionalContext

Don’t

Inject a full policy manual at SessionStart.

Do
[routing] intent=… suggested_skills=… [guardrails] bounded_output=true

⸻

6) Lint checklist (reviewer-ready)

Global
	•	No duplicated rules across CLAUDE.md / rules / skills (single source of truth).
	•	Every “must/never/always” is actionable and testable.

Formatting
	•	Goal is 1 sentence.
	•	Procedure is numbered; ≤ 7 steps.
	•	Tables ≤ 10 rows; no “kitchen sink” matrices.
	•	No paragraph > 4 lines unless it’s a definition.

Ambiguity
	•	All “short/large/quick” claims have thresholds.
	•	“If needed” has explicit conditions.

Token safety
	•	No inline templates/checklists > 20 lines in SKILL.md (move to reference).
	•	Any command/tool output rule includes caps (limits, pagination).
	•	Logs/diffs/stack traces follow bounded rules.

Routing safety (skills)
	•	Description: verb-first + domain noun + output hint; no fluff.
	•	Manual-only skills are clearly flagged and not in auto routing.
	•	High-chatter skills specify fork/subagent mode (where applicable).

Hooks (if relevant)
	•	Hook stdout / additionalContext is capped.
	•	Exit-code-2 is only used for true blocks; stderr is one-line reason.


---

# Worst-case stress test

Worst-case stress test plan (many skills + many tools + large outputs)

This test suite is designed to reproduce the worst failures you’ll see in Claude Code when: baseline overhead is huge, routing has too many candidates, and tools/logs/diffs flood the context window. Claude Code and Anthropic docs emphasize that the context window is shared across system prompt, history, skills metadata, and tool output—and once it fills, performance degrades.  ￼

⸻

1) Scenarios

Scenario S0 — Baseline overload (no user work yet)

Goal: quantify the “empty session tax” from: system prompt + CLAUDE.md/rules + skills metadata + tool schemas.

Setup
	•	Enable all skills (including internal ones) and all MCP/tool connectors.
	•	Start a fresh session and run /context immediately.

Expected stress
	•	Tool schemas can dominate baseline context; Tool Search / schema deferral is meant to reduce this by loading tools on demand.  ￼

⸻

Scenario S1 — Routing pressure (thin descriptions, many skills)

Goal: ensure aggressive description trimming doesn’t cause mis-routing and “skill drop” behavior.

Setup
	•	Create a routing corpus of 200 prompts:
	•	100 “clean intent”
	•	50 confusables (“spec” vs “test plan”; “audit” vs “refactor”)
	•	50 negatives (should trigger no skill)
	•	Run prompts in a fresh session with only metadata (no SKILL.md loads unless invoked) and record chosen skill(s).

Why it’s worst-case
	•	At startup, only skill metadata (name + description) is preloaded; trimming descriptions affects routing directly.  ￼

⸻

Scenario S2 — Tool schema explosion + tool discovery

Goal: verify tool deferral is active, and tool selection stays reliable under a huge catalog.

Setup
	•	Add a “dummy MCP server” with 300–1000 low-value tools + 5 real tools.
	•	Run tasks that need only the 5 real tools.

Pass condition
	•	Session baseline stays low; only the 5 real tools get loaded/used (via Tool Search / deferral).  ￼

⸻

Scenario S3 — Large outputs (logs/diffs/stack traces)

Goal: confirm your “bounded outputs” policies work under failure modes.

Setup
	•	Trigger:
	•	a failing build (long logs)
	•	a test run with many failures (stack traces)
	•	a large refactor (big diff)
	•	Enforce your output contract rules: head/tail logs, patch files, pagination.

Why it’s worst-case
	•	Claude Code best practices explicitly warn that outputs and file contents quickly consume context and degrade performance; you want hard caps + artifact-first behavior.  ￼

⸻

Scenario S4 — Long session churn (context growth + compaction)

Goal: simulate real prolonged work: 60–120 turns with periodic large tool outputs.

Setup
	•	Alternate between:
	•	planning
	•	tool calls
	•	code edits
	•	re-runs (logs)
	•	Trigger /compact at 80–90% usage, then continue.
	•	Include hooks if you use them (SessionStart/UserPromptSubmit).

Hook-specific risk
	•	Hook stdout for SessionStart/UserPromptSubmit can be added to context; exit code 2 can feed stderr back and become a repeated token tax if verbose.  ￼

⸻

Scenario S5 — Fork/subagent containment test

Goal: prove heavy “detect/scan” skills in context: fork don’t pollute the main conversation.

Setup
	•	Run 10 heavy analysis tasks (repo survey, detection, audits) both:
	1.	inline (no fork)
	2.	forked (subagent)
	•	Compare main-thread context growth and output quality.

(Use this to validate your “fork decision matrix” with measurements.)

⸻

2) Success criteria

A) Token / context criteria
	•	Baseline overhead (S0): stays under your cap (e.g., ≤ 25–30% of window).
	•	Tool schema baseline (S2): remains low and scales sublinearly with number of tools (deferral works).
	•	Per-tool output caps (S3): no single tool output exceeds your hard ceiling (e.g., 8K tokens) unless explicitly overridden.
	•	Long-session stability (S4): after /compact, performance remains usable and key anchors reappear (via compact-aware hooks).

Tool Search is explicitly intended to avoid loading all tool definitions up front by searching the tool catalog and loading only needed tools.  ￼

B) Routing quality criteria (S1)
	•	Accuracy@1 for “clean intent” prompts ≥ target (e.g., 95–99%)
	•	Confusables: correct skill in Top-3 ≥ target (e.g., 98%)
	•	Negatives: correct abstain rate ≥ target (e.g., 95% “no skill”)

This directly protects the part Anthropic calls out: only metadata is preloaded at startup, so metadata must be concise and effective.  ￼

C) Output usefulness criteria (S3)
	•	Responses remain actionable: “decisions + next actions” always present
	•	Large artifacts are written to files; chat returns index + pointers
	•	No repeated log spam across turns

⸻

3) Measurement method

Instrumentation sources (use all 3)
	1.	Claude Code /context snapshots at fixed checkpoints
	•	after startup (S0)
	•	after routing suite (S1)
	•	after enabling dummy tools (S2)
	•	after each large output event (S3)
	•	every N turns and pre/post /compact (S4)
	2.	Tool-side telemetry
	•	bytes/tokens returned per tool call
	•	pagination usage (% calls with limit/cursor)
	•	tool schemas loaded (when, which)
	3.	Token counting in CI
	•	Use Anthropic token counting for static payloads (CLAUDE.md, rules, descriptions, hook outputs, schemas) to enforce gates.  ￼

⸻

4) Root-cause attribution (so failures are actionable)

A) Budget breakdown model

Track token usage by bucket:
	•	System prompt + global rules
	•	CLAUDE.md hierarchy / unscoped rules
	•	Skills metadata (auto-invocable set)
	•	Skill body loads (invoked SKILL.md)
	•	Reference file loads
	•	Tool schemas (preloaded vs deferred)
	•	Tool outputs (per tool + totals)
	•	Hook injections (stdout/additionalContext, stderr from exit-code 2)

Hooks and their stdout/stderr behaviors are documented and should be treated as budgeted components.  ￼

B) Ablation tests (fast, decisive)

For any regression, rerun the same scenario toggling one variable:
	•	Tools: Tool Search ON/OFF (or serverInstructions/enable_tool_search)
	•	Skills: only top 20 auto-invocable vs full set
	•	Rules: unscoped rules removed vs present
	•	Hooks: enabled vs disabled; exit-2 blocks vs warnings
	•	Fork: inline vs fork for heavy skills

The goal is to isolate which bucket caused the spike.

C) “Delta over baseline” reporting

Every test run should publish:
	•	baseline tokens (S0)
	•	max tokens reached
	•	growth rate tokens/turn (S4)
	•	top 10 contributors (tool outputs, skill loads, rule files)

⸻

5) Expected failure modes and mitigations

Failure mode F1 — Baseline starts too high (before typing)

Symptoms: /context shows huge usage at startup; early degradation.
Likely root causes: tool schemas + unscoped rules + bloated CLAUDE.md.
Mitigations:
	•	Ensure Tool Search / schema deferral is active and verified (don’t assume auto-enable—there are reports of it not triggering).  ￼
	•	Make root CLAUDE.md minimal; move details to path-scoped rules.
	•	Reduce auto-invocable skills; keep internal skills disable-model-invocation.

Failure mode F2 — Routing becomes unstable after trimming

Symptoms: misfires, wrong skill triggered, or “no skill” when one is needed.
Likely root causes: descriptions lost disambiguating nouns/verbs; too many similar skills.
Mitigations:
	•	Maintain a golden routing suite (S1) with confusables.
	•	Enforce “verb + domain noun + output hint” lint for descriptions.
	•	Add “owned prompts” per skill and gate deltas when descriptions shrink.

Failure mode F3 — Tool output floods context

Symptoms: after one log/diff, context jumps massively; followups degrade.
Mitigations:
	•	Hard output contracts: paginate; head/tail; artifact-first.
	•	Tool wrappers enforce limit/cursor/fields defaults.

Failure mode F4 — Hook context leak / exit-2 accumulation

Symptoms: repeated policy blobs in context; rising tokens without progress.
Mitigations:
	•	Cap hook injected context; keep SessionStart/UserPromptSubmit short.
	•	Reserve exit code 2 for true blocks; keep stderr one line (since stderr can be fed back).  ￼

Failure mode F5 — Fork isolation not actually isolating

Symptoms: main thread still gets huge skill bodies or tool chatter.
Mitigations:
	•	Enforce context: fork on heavy skills; measure S5 deltas.
	•	Require forked skills to return only bounded summaries (Output Contract).

⸻

Deliverables (what this produces in CI)
	•	stress/context_snapshots/*.json (predefined checkpoints)
	•	stress/tool_telemetry/*.jsonl
	•	stress/routing_metrics.json (Accuracy@1, Recall@3, abstain)
	•	stress/top_contributors.csv (tokens by bucket + tool + file)
	•	A CI gate policy: fail if baseline > cap, routing drops beyond threshold, or any tool output exceeds limit unless opted-in.

---
title: "Research #75 — Aggressive Token Optimization (Quality-Safe)"
doc_type: research
created_date: 2026-02-14
updated_date: 2026-02-14
tags: [tokens, optimization, claude-code, skills, mcp, hooks, routing, ci]
related: [docs/token-strategy.md, docs/research/18-token-optimization.md, docs/research/62-ai-workflow-claude-code-token-optimization.md]
---

# Research #75 — Aggressive Token Optimization (Quality-Safe)

> Consolidated research notes + identified gaps + copy‑paste deep‑research prompts for jaan.to’s Claude Code plugin.

## Executive summary

jaan.to already has strong **skill-level** controls (description budget, reference extraction, `disable-model-invocation`, `context: fork`). The next “aggressive but safe” gains come from formalizing **session-level** (CLAUDE.md + rules), **tool-level** (schema deferral + pagination), **hook-level** (dynamic context with caps), and **output-level** (contracts) controls — and then enforcing them via **measurement + CI gates**.

## Sources reviewed

- `docs/token-strategy.md`
- `docs/research/18-token-optimization.md`
- `docs/research/62-ai-workflow-claude-code-token-optimization.md`

## What’s already solid (keep)

From `docs/token-strategy.md`:
- **Description budget** management (15,000 chars shared + per-skill overhead + per-skill max + validation).
- **Reference extraction** (execution core vs reference payload).
- **Frontmatter controls** (`disable-model-invocation`, `context: fork`) with meaningful savings.
- **Complexity-based SKILL.md size targets**.

## Gaps to close (highest ROI)

### 1) CLAUDE.md + rules architecture is not operationalized
**Gap:** Token strategy references “session-level” but doesn’t define a concrete, enforceable CLAUDE.md/rules layout.

**Quality-safe aggressive move:**
- Root `CLAUDE.md` becomes a **minimal router** (trigger table + a few invariants).
- Detailed guidance moves into **path-scoped rules** and **nested CLAUDE.md** files in subtrees.
- Add a **hard token cap** for root CLAUDE.md and for unscoped rules.

### 2) Tool schema overhead strategy is missing
**Gap:** No explicit plan for tool schema deferral / Tool Search indexing, tool consolidation, or output pagination contracts.

**Quality-safe aggressive move:**
- Require **schema deferral / Tool Search** when tool catalogs are large.
- Consolidate “CRUD explosion” tool sets into fewer tools (e.g., `resource(action, payload)` pattern).
- Enforce **pagination + field projection** (limit/cursor/fields) + response caps.

### 3) Hook strategy is missing (best dynamic-context lever)
**Gap:** No policy for replacing static context with dynamic session context, and no guardrails for exit-code-2 feedback accumulation.

**Quality-safe aggressive move:**
- Use `SessionStart` for a tiny session header (repo/branch, changed file counts, activation status, recent outputs) with strict caps.
- Use `UserPromptSubmit` to inject only routing hints + guardrails (also capped).
- Reserve exit code 2 for truly destructive prevention; keep stderr ultra short.

### 4) Output budgeting / verbosity contracts are not defined
**Gap:** Token optimization needs output control, not only loading control.

**Quality-safe aggressive move:**
- Add an **Output Contract** to every skill: summary-first, ask-before-expand, artifact-first.
- Define strict rules for logs/diffs/stack traces (head/tail + saved file paths).

### 5) Measurement + regression prevention is underpowered
**Gap:** Existing validation focuses mainly on skill descriptions.

**Quality-safe aggressive move:**
- Add “token budget CI gates” for root CLAUDE.md, unscoped rules, hook outputs, tool schemas, and top-N heaviest skills.
- Add routing regression tests to ensure trimmed descriptions don’t degrade skill selection.
- Add worst-case stress tests (many skills + many tools + large outputs) with attribution.

## Aggressive optimization ideas that usually preserve quality

1) **Hard tiering:** Always-on (very few) → Auto-invocable (small set) → Manual-only (many) → Fork/subagent (heavy).
2) **Reference extraction v2:** move not just templates, but also long checklists, large tables, anti-pattern catalogs, and multi-stack comparisons.
3) **Artifacts-not-chat default** for large outputs: return index + decisions; store bulk in files.
4) **Conversation resets by design:** encourage `/clear` between unrelated tasks; store state in files so resets don’t hurt.
5) **Subagent model routing:** run exploration/validation in cheaper/smaller contexts; reserve expensive synthesis only when needed.

---

# Deep‑research prompts (copy/paste)

## Prompt 1 — Token budget audit plan for jaan.to

You are auditing jaan.to’s Claude Code plugin for aggressive token optimization without lowering output quality.
Create a token budget model covering: system prompt + CLAUDE.md hierarchy + rules loading + skills metadata + skill bodies + tool schemas + hook injection + tool outputs.
Output: (1) a budget table with targets, (2) how to measure each component automatically, (3) CI gates that prevent regressions, (4) recommended thresholds and why.

## Prompt 2 — CLAUDE.md architecture redesign

Design an optimal CLAUDE.md and rules architecture for a large skill framework.
Constraints: root CLAUDE.md must be minimal; detailed rules must load conditionally via nested CLAUDE.md and path-scoped rules.
Output: exact file tree, example root trigger table, examples of 3 path-scoped rules, and a migration checklist from current structure.

## Prompt 3 — Tool schema deferral / Tool Search strategy

Propose an aggressive plan to reduce tool schema context overhead for a plugin with many connectors/tools.
Include: schema deferral/tool search indexing approach, tool consolidation patterns (action parameter), description trimming rules, output pagination strategy, and how to verify deferral is active.
Output: step-by-step implementation guide + risks.

## Prompt 4 — Hook strategy for dynamic context

Create a hook strategy that replaces static context with dynamic session context while keeping token usage bounded.
Include: SessionStart payload design, UserPromptSubmit enrichment design, hard token caps + truncation rules, and guardrails to avoid exit-code-2 accumulation.
Output: a policy + example hook outputs + what NOT to do.

## Prompt 5 — Output Contracts per skill

Define “Output Contracts” for skills to reduce tokens while preserving usefulness.
Include: default response schema, escalation ladder (ask before expanding), rules for logs/diffs/stack traces, and artifact-first patterns.
Output: a reusable template that can be embedded in each SKILL.md in <20 lines.

## Prompt 6 — Reference extraction playbook v2

Build a playbook for splitting large SKILL.md files into execution core vs reference files.
Include: what must stay in SKILL.md, what must move out, how to write inline pointers, and how to ensure the model reliably loads references only when needed.
Output: checklist + examples of before/after refactors.

## Prompt 7 — Fork/subagent decision matrix

Create a decision matrix for when a skill should run with context: fork, when it should be manual-only, and when it should be auto-invocable.
Include: token economics, risk profile (hallucination/overreach), and quality impact.
Output: a table + rules + examples for 10 archetypal skills.

## Prompt 8 — Regression tests for skill routing

Design a testing strategy that ensures aggressive trimming doesn’t break skill routing quality.
Include: structural validation, deterministic tests, semantic eval sampling, and how to detect routing failures caused by shorter descriptions.
Output: CI-ready approach + what to measure + sample test cases.

## Prompt 9 — Compression style guide

Create a writing style guide for token-efficient instructions that remain unambiguous.
Include: preferred formats (tables/bullets), banned patterns (redundant prose), “do / don’t” examples, and a lint checklist for reviewers.
Output: a 1–2 page guide.

## Prompt 10 — Worst-case stress test

Propose a stress test that simulates the worst-case: many skills + many tools + large outputs.
Define scenarios, success criteria, measurement method, and how to attribute token usage to root causes.
Output: test plan + expected failure modes + mitigations.