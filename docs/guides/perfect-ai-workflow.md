---
title: "Perfect AI Workflow"
sidebar_position: 7
---

# The Perfect AI Workflow — Best Practices, Anti-Patterns & Checklist

> A synthesized reference for converting an ad-hoc ("vibe coded") AI setup into a reliable, evaluated, safe execution system.
> Source: deep read of internal research summaries (76, 77, 80) + `docs/roadmap/vision.md`.
> Security and token pillars are **not** re-derived here — they link out to [Perfect Prompt-Injection Defense](./perfect-prompt-injection-defense.md), [`token-strategy.md`](../token-strategy.md), [Perfect CLAUDE.md](./perfect-claude-md.md), and [Perfect MCP](./perfect-mcp.md).

---

## The One Principle Everything Else Follows From

**Reliability comes from architecture, evidence, and deterministic enforcement — not from better prompts.**

The fastest way to a system that "usually works" is to keep adding instructions and agents. The fastest way to a system that *reliably* works is the opposite: build the **simplest agent that could work**, measure it against real failures, and only add complexity where the measurement proves it pays. Every added agent, tool, and instruction is a cost (latency, tokens, failure surface) that must earn its place with eval evidence.

The build order is fixed. Do not skip or reorder:

```text
1. Build the simplest agent that works
        ↓
2. Create evals (from real failures)
        ↓
3. Improve until it meets a reliability threshold
        ↓
4. Add specialized agents ONLY where evals show a distinct failing category
        ↓
5. Increase autonomy gradually (gated by reversibility + Rule of Two)
        ↓
6. Continuously monitor, evaluate, and harvest new knowledge
```

For every proposed addition, apply this filter:

> **"What eval evidence shows this is needed, and what does it cost per successful task?"** No evidence → don't build it yet.

---

## What to Include vs. Exclude

| ✅ Include (earns reliability) | ❌ Exclude (adds cost, not reliability) |
|---|---|
| A single well-tooled agent as the baseline | A multi-agent swarm before a baseline exists |
| Evals seeded from 20–50 real failures | "It looked good in a demo" as the quality bar |
| Outcome/state grading (pass^k) | Path grading that breaks on every refactor |
| Specialized subagents where work parallelizes | Specialists added "to be thorough" with no evidence |
| Non-negotiables as hooks/permissions | Non-negotiables as prose "never do X" |
| One home per fact/procedure (reference it) | The same rule copied into prompt + skill + agent |
| Progressive disclosure (skills load on demand) | A mega-prompt / mega-CLAUDE.md that always loads |
| Human gates on irreversible actions | Auto-executing model-proposed high-risk actions |

**Key reframe:** the goal is not the most capable-looking system — it is the highest **tokens-per-successful-task** at a known reliability. Measure that, not tokens-per-call.

---

## Recommended Structure

A mature workflow is layered, and each layer has exactly one responsibility (single source of truth):

```text
Environment / Context   → CLAUDE.md, AGENTS.md, .cursor/rules  (Where am I working?)
        ↓
Rules                   → hooks + permissions                  (What is never allowed?)
        ↓
Methods / Templates     → referenced docs                      (How is work done? What is good output?)
        ↓
Skills                  → .claude/skills/*                      (Repeatable multi-step workflows)
        ↓
Commands                → .claude/commands/*                    (Atomic operations)
        ↓
Agents                  → .claude/agents/*                      (Heavy, parallelizable, eval-justified)
        ↓
Hooks                   → settings.json                         (Mechanical, deterministic checks)
        ↓
Human Gates             → permissions: ask                      (Judgment / irreversible)
        ↓
Evals + Observability   → eval harness, traces                 (Is it reliable? Why did it fail?)
```

Reconstruct the actual workflow as an **execution graph** — every stage names its input, output, owner (which layer), quality gate, and next step. Tools without a graph are not yet a workflow.

---

## Best Practices

### Start simplest
1. **Begin with one looped agent or a workflow**, not a framework. Anthropic's consistent finding is that the most successful implementations use simple, composable patterns. Add agentic complexity only when it demonstrably improves an eval.
2. **Prefer a predefined workflow** (orchestrated code paths) for well-defined tasks; reserve autonomous agents for tasks whose path can't be hardcoded but whose progress can still be verified.

### Evaluate before optimizing
3. **Seed evals from 20–50 real failures** (bug tracker, support queue, dogfooding). Early changes have large effect sizes, so small sets suffice; evals only get harder to build the longer you wait.
4. **Grade the outcome/state, not the path.** Agents find creative valid routes; path grading penalizes better solutions and breaks on refactor.
5. **Report pass^k, not pass@k.** Production users experience "does it work every time," not "did it work at least once." A 75%-per-trial agent is ~42% at pass^3.
6. **Treat any LLM-as-judge as one biased signal** — calibrate against humans, prefer a different model family, output reasoning, use narrow scales. Read full traces to validate the grader; a 0% or 100% rate usually means a broken rubric.

### Improve, then specialize
7. **Fix measured failure classes first** (convert prose rules to hooks, collapse duplication to references, tighten context) before adding any new agent.
8. **Add a specialized subagent only when eval data proves a distinct failing category** a single agent can't solve more simply — and only for **parallelizable** work. Require a before/after and a token-budget justification. Subagents used purely for **context isolation** (returning a small summary from a big exploration) are a legitimate earlier move; *specialist* subagents are not.

### Increase autonomy gradually
9. **Widen autonomy by reversibility, idempotency, and rollback.** Auto-approve deterministic, reversible work (formatting, indexing, validation); gate irreversible/high-blast-radius actions behind a human.
10. **Never let one unsupervised session hold all three trifecta legs** (untrusted input + private data + external action). Break a leg by design or insert a human gate — see [Perfect Prompt-Injection Defense](./perfect-prompt-injection-defense.md).

### Monitor and harvest
11. **Instrument full traces** (prompt/model version, every tool call, cost, latency, failure reason) and track tokens-per-successful-task across the eval suite.
12. **Turn every production failure into a regression case** and route it to its correct home: corrections → Rules; manual work → automate (Skill/Command/Hook); edge cases → eval cases; unused tools → prune; missing context → Context.

### Discover work from real history
13. **Mine session + git history for repeated patterns** (e.g. via `/jaan-to:pm-skill-discover`) to find the workflows worth encoding — but classify each finding into exactly one component before building it.

---

## Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|---|---|---|
| Multi-agent before a baseline | ~15× token cost, more failure surface, no proof it helps | Ship the single-agent baseline; measure it first |
| Optimizing tokens-per-call | Cutting per-call tokens while lowering success rate raises true cost | Optimize tokens-per-successful-task, joined to eval outcomes |
| Path-based evals | Break on every refactor; reject valid alternative solutions | Grade final outcome/state |
| pass@k as the bar | Looks reliable in demos, fails in production repetition | Report pass^k |
| Prose "never do X" as a control | Violated under long sessions, ambiguity, or injection | Enforce with a hook or permission deny-rule |
| One rule copied into prompt + skill + agent | Drifts into conflicting copies; inflates every call | One home; reference it by pointer |
| Mega CLAUDE.md / mega prompt | Always-loaded tokens dilute adherence and cost every turn | Progressive disclosure — procedures in skills |
| Specialists added "to be thorough" | Cost with no reliability gain; fragmentation risk | Add only where evals prove a distinct failing category |
| Auto-executing model-proposed actions | An injected/wrong plan runs against real state | Human gate for irreversible/high-blast-radius actions |

---

## The Checklist

**Simplest first**
- [ ] A single well-tooled agent (or workflow) exists as the baseline
- [ ] Workflow-vs-agent chosen deliberately (predictable → workflow)
- [ ] Loop bounds (step/cost/time budgets, stagnation detection) enforced in orchestration, not prompted

**Evals**
- [ ] 20–50 eval cases seeded from **real** failures
- [ ] Graders check outcome/state, not path
- [ ] Reliability reported as **pass^k**; baseline recorded
- [ ] Any LLM judge calibrated against humans; traces read to validate it

**Improve → specialize**
- [ ] Measured failure classes fixed before any new agent
- [ ] Prose guardrails converted to hooks/permissions
- [ ] Duplication collapsed to single-source references
- [ ] Each specialized agent has eval evidence + a token-budget justification + parallelism

**Autonomy & safety**
- [ ] Autonomy widened only by reversibility/idempotency/rollback
- [ ] No unsupervised session holds all three trifecta legs (see prompt-injection guide)
- [ ] Human gates on irreversible / high-blast-radius actions

**Monitor & harvest**
- [ ] Full traces instrumented; tokens-per-successful-task tracked
- [ ] Production failures routed to Rules / Skills / evals / Context

---

## Token & Tooling Reference

| Concern | Where it lives |
|---|---|
| Context/CLAUDE.md hygiene | [Perfect CLAUDE.md](./perfect-claude-md.md), [`token-strategy.md`](../token-strategy.md) |
| MCP setup & attack surface | [Perfect MCP](./perfect-mcp.md) |
| Prompt injection / Rule of Two | [Perfect Prompt-Injection Defense](./perfect-prompt-injection-defense.md) |
| Evals / TDD / quality gates | `docs/research/76`, skills `qa-tdd-orchestrate`, `qa-quality-gate` |
| Issue validation / RCA | `docs/research/77`, skill `qa-issue-validate` |
| Session/skill discovery | `docs/research/80`, skill `pm-skill-discover` |
| Running this end-to-end | skill `/jaan-to:pm-workflow-audit` |

---

## TL;DR

Don't engineer your way to reliability by adding agents and instructions — you'll pay in tokens, latency, and failure surface without proof it helps. Build the **simplest agent that works**, seed **20–50 evals from real failures**, grade **outcomes not paths**, report **pass^k**, and improve until it clears a threshold. Only then add a specialized agent — and only where the evals show a distinct failing, parallelizable category. Widen autonomy step by step, gated by reversibility and the Rule of Two, and turn every production failure back into a rule, a skill, or an eval. `/jaan-to:pm-workflow-audit` runs this whole loop against your project's real session history.
