# pm-workflow-audit Reference Material

> Operational tables, rubrics, spawn prompts, and the audit-ID → jaan-to-source map for `pm-workflow-audit`.
> `skills/pm-workflow-audit/SKILL.md` references this file via inline pointers. Do not duplicate this content into the SKILL.md.

---

## 1. Knowledge-type → component classifier

Every fact/procedure the audit finds has exactly one correct home. Misplacement is a defect (single source of truth). When inventorying an existing project (Phase 1b) and when drafting the conversion plan, classify each item into exactly one row.

| Knowledge type | Test question | Becomes | Lives in |
|---|---|---|---|
| Static environment info | Where am I working? | Context | `CLAUDE.md` / `AGENTS.md` + `@`imports |
| Always-true constraint | What is never allowed? | Rule | **enforced** via `permissions` / hooks (never prose) |
| Professional methodology | How is work done? | Method | doc referenced from `CLAUDE.md`/skill |
| Output structure | What is good output? | Template | file referenced by skill/command |
| Repeatable multi-step workflow | Several steps + judgment | Skill | `.claude/skills/` |
| Atomic operation | One bounded action | Command | `.claude/commands/` |
| Mechanical, no intelligence | Deterministic pass/fail | Hook | `settings.json` |
| Heavy isolated specialized job | Large, separable, parallelizable | Subagent | `.claude/agents/` |
| Judgment / irreversible | AI must not decide alone | Human Gate | approval + `permissions: ask` |

**Misplacement flags to raise:** judgment encoded as a hook; a single op built as a skill/subagent; mechanical work assigned to the model; a constraint written only as prose; a workflow copy-pasted across prompts instead of one referenced skill; a subagent added with no eval evidence and no parallelism.

---

## 2. Existing-workflow inventory layers (Phase 1b)

Enumerate each layer, classify per §1, and record status + overlap. Map & align — the conversion plan must **reuse/reference** what exists, never duplicate it.

| Layer | Where to look | What to record |
|---|---|---|
| Context | `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, `~/.claude/CLAUDE.md`, managed CLAUDE.md; `AGENTS.md` (repo + `~/.codex`), `.cursor/rules/*.mdc`, `.cursorrules` | size (line count), owner, staleness, duplication across files, whether it exceeds ~200 lines |
| Rules | `.claude/rules/*.md` (`paths:` scoping), permission deny/allow lists in `settings.json` | prose-only "never X" constraints (flag → should be a hook/permission), path-scoping correctness |
| Skills | `.claude/skills/*/SKILL.md`, plugin skills, `~/.codex/skills`, `.codex/skills` | count, overlap/duplication, single-responsibility violations, auto-invoke sprawl |
| Commands | `.claude/commands/*.md` | atomic vs multi-step (multi-step → should be a skill) |
| Agents | `.claude/agents/*.md`, `agents/*.md` | justification (parallelizable? eval-backed?), tool scoping, model choice |
| Hooks | `hooks/hooks.json`, `settings.json` hooks | which non-negotiables are actually enforced vs merely documented |
| MCP | `.mcp.json`, `~/.claude.json` (user MCP) | server count, version pinning, trust/vetting, tool-description attack surface |
| Config/Permissions | `settings.json`/`.local`, managed settings | least-privilege, deny-first for secrets/dangerous commands |
| Memory | `~/.claude/projects/<repo>/memory/MEMORY.md`, `~/.codex/memories`, `AGENTS.md` | is persistent context used? single-source or drifting across tools? |
| Outputs/Learning | `jaan-to/outputs/`, `jaan-to/learn/` (if jaan-to present) | captured lessons, unencoded corrections |

---

## 3. Cross-tool, cross-OS session / plan / memory paths (for `session-reader.sh` and manual checks)

`CLAUDE_CONFIG_DIR` / `CODEX_HOME` relocate the base dirs. WSL uses Linux paths inside the distro. Detect OS + format + version; never hardcode; absent/unknown → fall back and log.

| Tool | Item | macOS / Linux / WSL | Windows |
|---|---|---|---|
| Claude Code | sessions | `~/.claude/projects/<slug>/<session-id>.jsonl` (**flat**, not `sessions/`); subagents `<session-id>/subagents/agent-*.jsonl` | `%USERPROFILE%\.claude\projects\<slug>\<session-id>.jsonl` |
| Claude Code | plans | `~/.claude/plans/*.md` (**global, flat**; subagent plans `-agent-<hash>`) | `%USERPROFILE%\.claude\plans\*.md` |
| Claude Code | memory | `~/.claude/projects/<repo>/memory/MEMORY.md` (keyed by git repo root); subagent `./.claude/agent-memory/<agent>/MEMORY.md` | same under `%USERPROFILE%` |
| Claude Code | history | `~/.claude/history.jsonl` (no `sessions-index.json` in current versions) | `%USERPROFILE%\.claude\history.jsonl` |
| Codex (CLI) | sessions | `$CODEX_HOME/sessions/YYYY/MM/DD/rollout-<id>.jsonl`; `history.jsonl`; `session_index.jsonl` (v0.136+) | `%USERPROFILE%\.codex\sessions\...` |
| Codex (CLI) | plans | **no dedicated file — plan/step events live inside the rollout JSONL [undocumented]** | — |
| Codex (variant) | store | `~/.codex/*.sqlite` (`goals_*/memories_*/state_*/logs_*`) — SQLite, version-dependent | — |
| Codex | context | `AGENTS.md` (global `~/.codex/AGENTS.md` → git-root→cwd, concatenated, closer wins, 32 KiB cap) | same |
| Cursor | chat | `~/Library/Application Support/Cursor/User/globalStorage/state.vscdb` + `workspaceStorage/<hash>/state.vscdb`; Linux `~/.config/Cursor/…` (SQLite, reverse-engineered → best-effort) | `%APPDATA%\Cursor\User\globalStorage\state.vscdb` |
| Cursor | plans / memory | **N/A as separate artifacts — composer/agent state embedded in `state.vscdb`**; rules `.cursor/rules/*.mdc`, `.cursorrules`, `AGENTS.md` | — |

Managed/enterprise settings (Claude): macOS `/Library/Application Support/ClaudeCode/`, Linux `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\` (current) / `C:\ProgramData\ClaudeCode\` (legacy) + Registry policy.

---

## 4. Audit-ID → jaan-to-source map

The audit vocabulary (`[ID]`) has no definitional home elsewhere in jaan-to. Define each ID **once here**, then map it to the jaan-to source whose *content* substantively defines or applies it. **Methodology:** for each ID, grep the concept term in the candidate doc and anchor to the section that actually treats it — validate against content, never guess section numbers. Keep "definition" and "enforcement" columns distinct.

| ID | Concept (one line) | Definition source (content-verified) | Enforcement in jaan-to |
|---|---|---|---|
| SEC-01 | Lethal trifecta: untrusted input + private data + external action | `docs/research/78`, `docs/guides/perfect-prompt-injection-defense.md` | `scripts/pre-tool-security-gate.sh`, permission deny-rules |
| SEC-02 | Rule of Two: ≤2 of the 3 trifecta legs per unsupervised session | `docs/research/79` §1.5 (Core Design Axiom) + §3.3 (Planner/Executor); `perfect-prompt-injection-defense.md` | least-privilege `allowed-tools`, HARD STOP human gate |
| SEC-04 | All read content (docs, tickets, tool output) is untrusted | `docs/extending/threat-scan-reference.md` (Untrusted-Content Envelope) | envelope + secret-scan on outputs |
| PERM-01 | Prose "never X" fails; enforce non-negotiables as hooks/permissions | `docs/security-strategy.md` | `scripts/validate-security.sh`, hooks |
| TOK-01 | Stable cacheable prefix, dynamic content last | `docs/token-strategy.md`, `docs/guides/perfect-claude-md.md` | — |
| TOK-03 | Progressive disclosure: procedures in skills, facts in CLAUDE.md | `docs/research/62`, `docs/token-strategy.md` | `validate-skills.sh` line caps |
| LOOP-01 | Simplest agent first; add complexity only when it helps | `docs/research/76`, `docs/roadmap/vision.md` (Minimal by Default) | — |
| LOOP-03 | Bounded loops: step/cost/time budgets + stagnation detection | `docs/research/76` | orchestration (team-ship) |
| EVAL-01 | Seed 20–50 real-failure cases | `docs/research/76`, `docs/research/77` | `scripts/test/eval/` (this feature) |
| EVAL-02 | Grade outcome/state, not the path | `docs/research/76` | eval graders |
| EVAL-05 | Report pass^k (all k trials), not pass@k | `docs/research/76` | eval harness report |
| MULTI-01 | Multi-agent only for parallelizable breadth | `docs/research/76`, `skills/team-ship` | team-ship track gating |
| MULTI-04 | Subagents as a context-isolation / token lever | `docs/research/62`, `docs/token-strategy.md` | `context: fork` |
| OBS-02 | Optimize tokens-per-successful-task, not per-call | `docs/token-strategy.md` | — |
| GATE-01 | Human gate before high-risk / irreversible / all-three-legs actions | `docs/research/79` §3 | HARD STOP, `permissions: ask` |

> Extend this table as the SKILL.md cites new IDs. Never cite `security-strategy.md` as a *definition* of Rule of Two / trifecta (it never names them) — it is an enforcement source only.

---

## 5. Verify rubric (Phase 1.5 adversarial confirmation)

Each drafted-plan finding is confirmed or refuted independently. Default to **REFUTED** unless evidence clearly supports it (skeptic posture). Grade **outcome and process** — a correct recommendation whose justification violates the philosophy order is not a pass.

| Check | Confirm only if |
|---|---|
| Evidence | The claim cites a real file/symbol or a research ID that content-verifies; otherwise mark `[ASSUMPTION]`. |
| SSoT | The recommendation references an existing component instead of duplicating it. |
| Philosophy order | No multi-agent / added autonomy is proposed without eval evidence; simplest-first respected. |
| Safety | No new session holds all three trifecta legs unsupervised; guardrails are hooks/permissions, not prose. |
| Reuse | Existing skills/agents/hooks/MCP that already cover the need are named and reused. |
| Feasibility | The step has a checkable end-state and a rollback. |

Report verdicts as CONFIRMED / REFUTED with a one-line rationale. A 0% or 100% confirm rate across many findings usually signals a broken rubric, not reality — re-read traces.

---

## 6. Standards checklist (Phase 1.5 — jaan-to + Claude Code + Codex)

Run deterministic validators first, then interpret the gaps they do not cover.

**Deterministic (run these):** `bash scripts/validate-skills.sh`, `bash scripts/validate-security.sh`, `bash scripts/validate-outputs.sh`, `bash scripts/test/skill-standard-compliance-e2e.sh`.

**jaan-to conventions (interpret):** SKILL.md ≤ 600 lines (soft 500); 5 required frontmatter fields; description < 120 chars, no colon, has a "Use when/to/for" trigger; output under `$JAAN_OUTPUTS_DIR/{role}/{subdomain}/{id}-{slug}/`; registered in `marketplace.json` + `scripts/seeds/config.md`; reference-extraction over inlining; no exec-capable binary in `allowed-tools`.

**Claude Code conventions (interpret):** agent frontmatter uses `tools:` (not `allowed-tools:`) + `model:`; hooks enforce non-negotiables; permissions deny-first for secrets; `CLAUDE.md` ≤ ~200 lines with an owner; path-scoped rules load only on matching files.

**Codex conventions (interpret):** dual-runtime parity — skill packaged into `adapters/codex/skillpack` via `prepare-skill-pr.sh`; every `${CLAUDE_PLUGIN_ROOT}/docs/...` citation resolves inside `adapters/codex/skillpack/runtime/docs`; `Task`-dependent phases have a Codex-runtime degradation note; `AGENTS.md` shared-references list current.

---

## 7. Phased-plan output structure (the conversion plan the skill writes)

The generated plan (written in Phase 2) follows the six-step philosophy. Sections:

1. **Verdict** — maturity stage, biggest risk, single most important next action.
2. **Workflow understanding** — user, job, execution graph, trifecta legs per stage, success criteria.
3. **Knowledge map** — explicit + implicit knowledge, each with a component owner (per §1) and status; uncaptured knowledge and SSoT violations.
4. **Inventory** — the existing-workflow layers (§2) with reuse/duplication/gap notes.
5. **Reliability, gates, autonomy contract** — pass^k thresholds by risk tier, zero-tolerance failures, proceed/stop table.
6. **Injection-defense checklist** — layered controls with residual risk.
7. **Phased plan** — mapped to the six steps, each with goal, measurable exit criterion, components used, and what is deliberately not built yet.
8. **First implementation slice** — 1–2 days, ≥1 eval, reversible, explicit acceptance criteria.
9. **Anti-over-engineering pass** — what was cut and what evidence would justify it later (this is where *domain-specialist* agents stay deferred until the plan's own evals justify them).

---

## 8. Agent spawn prompts (Phase 1.5 fan-out — Slice 3, eval-gated)

Used only when the eval harness shows the fan-out beats the inline single-agent baseline. Each spawned via `Task`; each is read-only and returns a condensed (~1–2K token) structured result. On Codex (no `Task`), run these rubrics single-pass inline.

**`workflow-plan-reviewer`** (one per plan section):
> Review ONE section of a drafted AI-workflow conversion plan against the research evidence in `${CLAUDE_PLUGIN_ROOT}/docs/research/` and the philosophy order (simplest → evals → improve → specialized agents only where evals prove value → autonomy → monitor). Read the cited sources; do not write files. Return findings: {issue, severity blocker|major|minor, evidence (cite the plan claim + the source that supports/contradicts), suggested_fix}. Empty if the section is clean. Be adversarial but evidence-based — never invent problems.

**`workflow-plan-verifier`** (one per finding):
> Adversarially verify one review finding by reading the actual cited source and the project files yourself. Default to REFUTED unless the evidence clearly supports it. Return {verdict CONFIRMED|REFUTED, rationale, corrected_fix}. Grade both the outcome and whether the plan step respects the philosophy order.

**`workflow-standards-auditor`** (defaults to inline; split out only if evals justify):
> Run the deterministic validators, then interpret the jaan-to / Claude Code / Codex convention gaps in §6 that the scripts do not cover. Return {standard, status pass|warn|fail, evidence, remediation}.

---

## 9. Deep-research fallback prompt (Codex / Cursor format drift)

Codex and Cursor storage formats change fast and are partly undocumented. When `session-reader.sh` reports an unknown Codex format, or a target Codex version is chosen, re-pin the format:

```
/jaan-to:dev-docs-fetch "OpenAI Codex CLI session storage format for version <X>"
```

Or run deep research with this prompt:

> Determine, for OpenAI Codex CLI version <X> on macOS/Linux/Windows: (1) the exact session/rollout transcript path under `$CODEX_HOME` and the rollout filename stem; (2) whether plan/todo state is a separate file or embedded in the rollout JSONL; (3) the JSONL event schema (roles, tool calls, token usage); (4) any SQLite stores and their table schemas; (5) the `AGENTS.md` precedence rules. Cite primary sources (github.com/openai/codex, developers.openai.com) and date every claim. Flag anything version-dependent or undocumented.

Update §3 and `session-reader.sh` format detection with the findings.
