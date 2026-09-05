# Ready — Design Archive

> Ten documents, ~19,400 lines. Nine trace one product from open research question to a frozen build
> spec; the tenth turns that spec's first three milestones into an executable build.
>
> **Spec authority: [9-ready-plan-v5.4-frozen.md](docs/9-ready-plan-v5.4-frozen.md).
> Build plan: [10-ready-impliment-v5.4.md](docs/10-ready-impliment-v5.4.md).
> Documents 1–8 are history.**

---

## What Ready is

**Ready** (`jaan.to/ready` · CLI `ready` · daemon `readyd`) is a **local, single-user, deterministic
development control plane**. It owns workflow state, context assembly, policy, isolation,
verification, and evidence. Claude Code and Codex are replaceable cognitive workers behind adapters —
not the system's brain.

A run reaches the terminal state `READY` only with recorded deterministic verification evidence
(I-06), never because a model said so. The product is named after that guarantee.

**Formerly `aidev`.** Documents 1–8 use the old name. The rename landed at v5.4 as identifier-level
substitutions only — zero architectural deltas.

---

## Start here

| Document | Why |
|----------|-----|
| **[9 — Ready, Implementation Baseline v5.4 (FROZEN)](docs/9-ready-plan-v5.4-frozen.md)** | *What to build.* The spec. Frozen 2026-08-23: *"begin implementation. Start M0 today."* Locked decisions (D-nn / P-nn), 25 invariants each with a named enforcing test, milestones M0–M9, spikes S-01–S-09, experiments E-01–E-06, ADRs 001–053. Its §0 carries a defect-by-defect changelog of **every** prior version, so the eight superseded siblings need not be read to understand it. |
| **[10 — Implementation Plan: M0 through M2](docs/10-ready-impliment-v5.4.md)** | *How to build the first third of it.* Turns the spec's three unblocked milestones into a task-ordered build: repo bootstrap, module-by-module design, exit-criteria-to-test mapping, and a master execution sequence. Stops where the spec's gates do — M3 needs spikes S-05/S-06 and E-03 labels, M4 needs S-01–S-04/S-07/S-08. |

Remaining uncertainty is discharged by spikes and experiments writing ADR supersedes — explicitly
**not** by another architecture version (§1, rule 4).

---

## Index

| # | Document | What it is | Status |
|---|----------|-----------|--------|
| 1 | [aidev: Deep Architecture Research and Implementation Blueprint](docs/1-aidev-deep-research-report.md) | Citation-backed critique of the original architecture, grading every subsystem and resolving 30 research questions into adopt / defer / reject calls. Argues positions; specifies no tasks. | Foundation |
| 2 | [aidev — Implementation Plan v1.0](docs/2-aidev-implementation-plan.md) | The first build document: 40 locked decisions, 10 invariants, a ten-milestone M0–M9 order. Turns "what should be true" into "what gets written, in what order." | Superseded |
| 3 | [aidev at R0/R1: The Achievable Frontier, Not the Target](docs/3-aidev-at_R0_R1_The_Achievable_Frontier_Under_Cold_Start_and_Cache.md) | Evidence review that killed the 2× speed / 0.5× token target. 27 graded findings (A1–G3), a cold-start/cache cost model, and the six cheapest experiments to settle what remains unmeasured. | Foundation |
| 4 | [aidev — Final Implementation Plan v2.0](docs/4-aidev-plan-v2-final.md) | First plan built on the performance evidence. Introduces the two-track fast/heavy split, the static-analysis core, and the cached byte-stable prefix. | Superseded |
| 5 | [aidev — Implementation Baseline v3.0](docs/5-aidev-plan-v3-baseline.md) | Closes the v2.0 design review: two-phase assessment, worker execution modes, local trust root, action journal. | Superseded |
| 6 | [aidev — Implementation Baseline v5.0](docs/6-aidev-plan-v5-final.md) | The consistency freeze. v4.0's decisions were right but ten sections still described the v2/v3 world — a plan that *"is not a baseline — it is two plans in one file."* This pass propagates them everywhere. | Superseded |
| 7 | [aidev — Implementation Baseline v5.1 (FROZEN)](docs/7-aidev-plan-v5.1-frozen.md) | Six-defect correctness patch, then the freeze. Three P0s: the `BROKERED_TOOLS` sandbox loophole, the assessment `UNIQUE` collision, and `SUCCEEDED` effects surviving rollback. | Superseded |
| 8 | [aidev — Implementation Baseline v5.3 (FROZEN)](docs/8-aidev-plan-v5.3-frozen.md) | The GO-to-implementation patch: `attempt_seq` rollback watermark, one rollback primitive, agent-config opt-in deleted. Adds Appendix A2, the typing order for M0–M2. | Superseded |
| 9 | [Ready — Implementation Baseline v5.4 (FROZEN)](docs/9-ready-plan-v5.4-frozen.md) | **Canonical spec.** v5.3 renamed `aidev` → Ready, plus §1.1 resolving the `READY` naming collision. Zero architectural deltas. | **Current** |
| 10 | [Ready — Implementation Plan: M0 through M2](docs/10-ready-impliment-v5.4.md) | **The build plan.** Not another design version — an execution plan derived from doc 9. Eight parts: bootstrap, M0 skeleton, shared foundations, M1 workspace, M2 security substrate, master sequence, definition of done, M3 follow-ups. | **Active** |

---

## The lineage

Two research inputs feed a plan that was revised seven times. Each revision states its own defects
and fixes, so the chain is auditable end to end.

```text
doc 1 · deep research
   │
   ▼
v1.0 ──→ v2.0 ──→ v3.0 ──→ (v4.0) ──→ v5.0 ──→ v5.1 ──→ v5.3 ──→ v5.4 ──→ build
#2       #4       #5       no doc     #6       #7       #8       #9       #10
         ▲                                     └────── frozen ──────┘       │
         │                                                    canonical     │
doc 3 · performance research — a critique of v1.0, folded in at v2.0        │
                                                                            ▼
                                          M0–M2, executed in a separate repo
```

Doc 10 is **not** a v5.5. It adds no decision and reverses none; it reads the frozen spec and says
what to type, in what order. Where the spec underdetermines something it marks a *flagged
resolution* and stays inside D-01…D-40 / P-01…P-41 and I-01…I-25.

| Version | Doc | Pass | What it changed |
|---------|-----|------|-----------------|
| v1.0 | [2](docs/2-aidev-implementation-plan.md) | First build plan | Resolved the research report's open questions into D-01…D-40, ten invariants, and the M0–M9 order. |
| v2.0 | [4](docs/4-aidev-plan-v2-final.md) | Performance research | Reversed six v1.0 commitments — fresh context per stage, process per stage, mandatory R1 review, model-based risk classification, full unit suite at R1, adaptive token budgets. The security architecture survived intact; the *performance* architecture was rebuilt. |
| v3.0 | [5](docs/5-aidev-plan-v3-baseline.md) | Design review | Four promises the spec did not keep: the preflight/post-diff assessment split (P-19), `PATCH_ONLY` vs `BROKERED_TOOLS` (P-20), the local trust root (P-22), the action journal with reconciliation (P-23). Broker execution narrowed to argv + `shell=False` (P-24). |
| v4.0 | *(no document)* | Baseline freeze review | Ten boundary defects: tool-less fast path, mandatory `REPAIR → POSTDIFF`, security substrate moved into M2, platform-complete `EnvKey`, hash-guarded patch contract, durable `action_id`, logical quarantine. Recorded in doc [6](docs/6-aidev-plan-v5-final.md) §0.2 and doc [9](docs/9-ready-plan-v5.4-frozen.md) §0.5. |
| v5.0 | [6](docs/6-aidev-plan-v5-final.md) | Consistency freeze | Propagated every v4 decision into the ten sections that still contradicted it, and closed the gaps that exposed. |
| v5.1 | [7](docs/7-aidev-plan-v5.1-frozen.md) | Freeze patch | Interception — not containment — grants tool authority (P-37/I-23). Append-only ordinal assessments (P-38/I-24). Generation-scoped effects voided on rollback (P-39/I-25). Directional classifier gates replace overall accuracy (P-40). **Document frozen.** |
| v5.3 | [8](docs/8-aidev-plan-v5.3-frozen.md) | Implementation-readiness | Rollback cut corrected to `generation == old_gen AND attempt_seq > watermark`; a single `rollback_to_checkpoint()` primitive; the repo-agent-config opt-in deleted outright (P-41) — *"An absolute invariant with an approval escape hatch is not an invariant."* |
| v5.4 | [9](docs/9-ready-plan-v5.4-frozen.md) | Naming release | `aidev` → **Ready**, `ready`, `readyd`, `~/.ready/`, `READY_`. The FSM state `READY` is unchanged. Adds spike S-09 (name and namespace availability). |

**No standalone v4.0 document survives in this archive** — its review is preserved only in the
changelogs of v5.0 onward, though every `Supersedes:` line from doc 6 on cites an `aidev-plan-v4`.
Nine load-bearing decisions (P-28…P-36) and five invariants (I-18…I-22) were introduced there and
appear here only as already-settled facts. **v5.2 was skipped, not lost:** v5.3's own changelog is
titled *"From v5.1 → v5.3."*

---

## Reading paths

| Your goal | Path |
|-----------|------|
| **Build M0–M2 today** | Doc [10](docs/10-ready-impliment-v5.4.md) start to finish, with doc [9](docs/9-ready-plan-v5.4-frozen.md) open beside it as the normative reference. Doc 10 Part 6 is the master execution sequence; Part 7 is the definition of done for the whole arc. |
| **Build past M2** | Doc [9](docs/9-ready-plan-v5.4-frozen.md). §2.2 Definition of Done, §2.4 invariants, §3 locked decisions, §18 milestones. §24 lists the spikes gating M3 and M4 — doc 10 Part 8 says which to kick off during late M2. |
| **Understand why it looks like this** | Doc [9](docs/9-ready-plan-v5.4-frozen.md) §0 — seven delta tables covering v1.0 → v5.4 — then doc [1](docs/1-aidev-deep-research-report.md) for architectural rationale and doc [3](docs/3-aidev-at_R0_R1_The_Achievable_Frontier_Under_Cold_Start_and_Cache.md) for why the performance targets moved. |
| **Challenge a decision** | Doc [1](docs/1-aidev-deep-research-report.md) holds the rejected alternatives (Temporal, LangGraph, vector DBs, agent swarms) and the evidence against them; doc [3](docs/3-aidev-at_R0_R1_The_Achievable_Frontier_Under_Cold_Start_and_Cache.md) holds the cost arithmetic. Then read doc [9](docs/9-ready-plan-v5.4-frozen.md) §1 rule 4 — the answer is a spike and an ADR supersede, not a v5.5. |
| **Review security or architecture** | Doc [9](docs/9-ready-plan-v5.4-frozen.md) §6 architecture, §12 state and recovery, §14 Action Broker and sandboxing, §15A environment provisioning. |
| **Audit a reversal** | Start at doc [9](docs/9-ready-plan-v5.4-frozen.md) §0. Open an older document only when you need the exact wording it replaced. |

---

## Conventions used throughout

| Marker | Meaning |
|--------|---------|
| **D-nn** | Locked decision. Changing it requires an ADR supersede. |
| **P-nn** | Performance decision. Introduced at v2.0; runs P-01…P-41. |
| **I-nn** | Invariant. Must hold always; each has a named enforcing test. |
| **M-n** | Milestone. Sequential, binary exit criteria. M0–M9, plus M5.5 (eval-lite). |
| **S-nn** | Spike. Must finish before the milestone that needs it. |
| **E-nn** | Open experiment. Measures something currently unmeasured. |

### The `READY` collision

The product is named after its terminal state, which makes one word mean two things. Doc 9 §1.1
fixes a convention — apply it in anything written about Ready:

| Form | Means |
|------|-------|
| **Ready** (roman, capital R) | the product |
| `ready` (code, lowercase) | the CLI binary or import package |
| `READY` (code, caps) | the terminal FSM state |
| `readyd` | the daemon |

Never write "ready" in roman lowercase for either the product or the state. *"The run is ready"* is
ambiguous; write *"the run reached `READY`."*

---

## Traps

These will mislead a reader who opens a document without this index.

- **Five documents claim to be final or frozen. Only one is current.** Doc 4 is titled *"Final Implementation Plan v2.0"*; doc 6's banner reads *"FINAL v1 baseline"*; docs 7, 8, and 9 all say **(FROZEN)**. Docs 4, 6, 7, and 8 are superseded. The `-final` in `4-aidev-plan-v2-final.md` and `6-aidev-plan-v5-final.md` is the worst trap in the folder — neither was final.
- **Doc [8](docs/8-aidev-plan-v5.3-frozen.md) is indistinguishable from the authority when opened alone.** Its banner — *"FROZEN v1 baseline — begin implementation. Start M0 today"* — is worded exactly like doc 9's, its §0.1 frames v5.3 as the end of the line, and it never mentions v5.4, Ready, or doc 9. Nothing inside it tells you it is stale.
- **Doc 9's `Supersedes:` line omits v5.3.** It is byte-identical to doc 8's own list and stops at `aidev-plan-v5.1`. Doc 9's authority over doc 8 rests on §0.1 (*"From v5.3 → v5.4"*) and on content, not on that header.
- **No `Supersedes:` list names a file that exists on disk.** They cite `deep-research-report.md`, `aidev-plan-v2`, `aidev-plan-v5.1` and so on; the real files are number-prefixed. Doc 9 §0.1 asserts these "refer to files that exist under those names" — that sentence is false for every entry, and `aidev-plan-v4` exists nowhere. Map them through the [index](#index) above.
- **Docs [1](docs/1-aidev-deep-research-report.md) and [3](docs/3-aidev-at_R0_R1_The_Achievable_Frontier_Under_Cold_Start_and_Cache.md) carry no status, date, or version line** — they read as timeless. Doc 1 in particular opens with an architecture diagram and a "use / do not use in v1" stack list that looks exactly like a specification.
- **Doc 1's recommendations were later reversed** — read it for rationale, never as guidance. Repomix went from "optional secondary provider" to D-17 *deferred entirely*; Serena from "best current primary semantic integration" (19 mentions in doc 1, 2 in doc 9) to D-16 *"a `ContextProvider`, not a hard dependency"*; mandatory R1 review became conditional; adaptive budgets became the closure predicate plus a file ceiling. Doc 3 is the opposite — no plan supersedes it; they all say *Incorporates*.
- **Quote performance numbers only from doc [9](docs/9-ready-plan-v5.4-frozen.md) §2.1, and quote the right row.** Every plan's prose headline — 1.2–1.6× faster, 0.7–0.9× tokens — is the **R1** row. R0 is better (1.5–2.0× / 0.5–0.7×) and R2/R3 are deliberately worse (0.5–0.8× / 1.5–3×). The headline understates R0 and badly overstates R2/R3.
- **Doc 9's changelog is not a verbatim historical record.** §0.2–§0.7 describe v2.0–v4.0 defects in the *new* vocabulary — §0.6 writes `.ready/memory/*.md` for a defect doc 5 records as `.aidev/memory/*.md`. Accurate about substance; wrong about wording. Quote the older document when the exact phrasing matters.
- **Doc 9's header says uncertainty is resolved by "S-01…S-08"**, while §24 defines nine spikes. S-09 arrived with the rename and the header was not updated; the S-09 row is also separated from its table by a blank line, so it renders as an orphan.
- **Doc [1](docs/1-aidev-deep-research-report.md) carries 45 unresolved inline citation markers** that render as `citeturn19search2…` where source links should be. Claims are attributed in prose (Agentless, SWE-agent, SWE-Bench Pro, OWASP, NIST, SLSA, OpenTelemetry); the links are not recoverable from the file.
- **Doc [10](docs/10-ready-impliment-v5.4.md) builds somewhere else.** It targets a new standalone repo at `~/Projects/jaan-to-ready` (`git@github.com:parhumm/jaan-to-ready.git`). This `ready-aidev/` folder stays a design archive — *"nothing is written there."* Do not start typing code into jaan-to.
- **Doc 10's `-v5.4` names its input, not its own version**, and its filename misspells *implement* as `impliment` — grepping the folder for "implement" will not find it. Its scope is M0–M2 only; M3 onward is not planned in it, by design.
- **Filenames are not authoritative.** Every plan states its version and status in its first five lines. Where a filename and a body disagree, the body wins.

---

> Give soul to your workflow.
