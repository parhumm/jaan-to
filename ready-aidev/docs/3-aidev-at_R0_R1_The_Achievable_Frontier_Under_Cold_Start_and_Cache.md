# aidev at R0/R1: The Achievable Frontier, Not the Target

## TL;DR

- **The 2x-faster / 0.5x-token / higher-quality triple target is not simultaneously achievable at R0/R1 with a multi-stage, fresh-context-per-stage, one-worker-call-per-stage design.** The evidence says the realistic frontier is roughly **1.2–1.6x faster and 0.7–0.9x tokens at equal-or-better quality** — and only if aidev abandons process-per-stage cold starts, keeps a warm cache, and does most R0/R1 classification and verification model-free. The binding constraint is the **per-invocation cold-start tax** (~14k–33k fixed prompt tokens + multi-second process startup) multiplied by stage count.
- **The single largest quality lever at R0/R1 is not the reviewer — it is running the existing impacted test suite and a type check on the diff.** Solo-agent failures are dominated by localization errors (~40%) and semantically-wrong-but-plausible patches (~27–72%); an LLM diff reviewer has F1 <20% and high false-positive rates on small diffs, so mandatory R1 review is likely net-negative.
- **The correct shape for R0/R1 is Agentless-style, not FSM-with-agents:** one model-free localization+classification pass, one constrained-schema implementation call (2–3 calls total, one warm cached prefix), then deterministic verification (impacted tests + types + fast-fail ordering). Reserve the full multi-stage FSM for R2/R3.

-----

## Key Findings

**The optimization target is misspecified in two of three axes.** Tokens: a multi-call orchestrator can be made token-competitive (0.7–0.9x) but only by defeating the cold-start tax that its own architecture creates; 0.5x is out of reach because a single long agent session already gets ~98% cache-read rates on its growing prefix. Speed: 2x is unreachable at R0 because model inference is not the dominant term — process startup + test execution are, and aidev adds startup events. Quality: aidev can plausibly win on quality per token, and this is where its structural advantage genuinely lives.

-----

## Details

FINDING A1 — Token anatomy
Claim: For a small/medium solo agent run, the fixed system-prompt+tool-schema prefix is ~14k–33k tokens and re-sent context (history + file reads/re-reads + tool output) dominates total spend; file reads alone are ~40% of tokens.
Evidence: Claude Code base system prompt + built-in tool schemas measured at ~14,328 tokens (resets to this floor after every compaction; dev.to trace study). A proxy-instrumented measurement put Claude Code’s pre-user-prompt send at ~33k tokens (systima.ai/HN — competitor-authored, treat as single-source; direction corroborated by the independent 14k figure). Codex CLI system prompt + AGENTS.md is lighter at ~2–5k tokens/turn (Codex Knowledge Base, practitioner). SWE-Pruner (arXiv 2601.16746) removed 39.2% (Sonnet 4.5) / 43.6% (GLM 4.6) of total tokens by pruning file-read content from a mini-SWE-agent baseline — implying file reads/re-reads are ~40% of the total. Conversation history is re-sent every turn (stateless API): turn 1 ≈15k → turn 30 ≈167k tokens. Reasoning tokens on a sampled Codex turn ≈1.7x visible output (3,200 reasoning vs 1,847 output). Final output diff is consistently the smallest category.
Confidence: medium — the aggregate pattern (input ≫ output; file-reads and re-sent history dominate) is well-corroborated; exact R0/R1 category percentages are unmeasured.
Mechanism: LLM APIs are stateless; each turn re-bills the full prefix, so cost grows ~O(N²) in turn count. The fixed prefix is paid once per process.
Plan impact: Treat the ~14k+ fixed prefix as the unit of waste to amortize. Every extra process invocation re-pays it. Set a hard budget: R0/R1 should be ≤3 model calls sharing ONE cached prefix. Strip MCP servers on R0/R1 (each adds ~10–20k tokens/session; a 93-tool GitHub server ≈55k tokens/turn).
Cost: Requires prompt assembly you control (not delegating to the CLI’s own context builder). Trades away the convenience of letting the worker CLI freely explore.

FINDING A2 — Latency anatomy
Claim: At R0 wall clock is dominated by process startup + tool/test execution, NOT model inference; model-side optimization is largely irrelevant for trivial tasks.
Evidence: `claude` binary alone starts in ~0.19s but interactive/degraded startup measured at 8–12.5s (GitHub Issues #11442, #17974 — failure/degradation modes; a clean warm start is low-single-digit seconds). Codex startup ~10s and `/resume` +~20s on heavy local state (Issue #18839). A model round-trip ≈2–4s/turn (practitioner); bare-API TTFT at ~10k input ≈1.0s (Haiku 4.5) to 2.5–4.3s (Opus, reasoning; Artificial Analysis). Test/build execution is governed by the repo’s own suite and is often the single largest external wall-clock item. “Cutting ten unnecessary tool calls saves more time than emptying your context window” (practitioner analysis).
Confidence: medium — startup numbers are real but many come from bug reports; the qualitative dominance of round-trip-count + test execution over token processing is well-supported.
Mechanism: Fixed per-process costs (Node/Bun spin-up, shell snapshot, config/network calls) and external test runtime do not shrink with a smaller/faster model.
Plan impact: If a stage’s model work is <4s but each stage spawns a fresh CLI costing multi-second startup, the FSM loses on wall clock by construction. Kill per-stage process spawning. If test execution dominates (measure per-repo), Block E is where 2x lives, not model routing.
Cost: Requires a warm worker pool or in-process SDK use rather than shelling out to `claude -p`/`codex exec` per stage.

FINDING A3 — Waste rate / retrieval precision
Claim: A large fraction of what a solo agent reads is never referenced in the final diff; frontier agents run block-level retrieval F1 <0.45 and line-level <0.35.
Evidence: ContextBench (arXiv 2602.05892): SOTA LLMs’ block-level F1 <0.45, line-level <0.35; GPT-5 achieves higher recall but sacrifices precision, yielding lower issue-resolution than Claude Sonnet 4.5. SWE-Pruner’s ~40% token removal without quality loss is direct evidence of read-waste. BM25 Top-30 hits 87.7% recall at 3.4% precision (SWE-Tester, arXiv 2601.13713).
Confidence: high — multiple independent benchmarks agree.
Mechanism: Agents broaden retrieval when unsure, inflating context; excess context then dilutes attention.
Plan impact: Pre-assembled precise context beats agent self-exploration on precision-per-token. This validates aidev’s symbol-level retrieval bet — but only if retrieval is done ONCE and cached, not re-derived per stage.
Cost: Requires a good static localizer (LSP/import-graph); see C1/C3.

FINDING A4 — Cold-start tax (the core structural disadvantage)
Claim: Each fresh `claude -p`/`codex exec` re-pays ~14k–33k prefix tokens and multi-second startup, and session resume avoids the token re-processing only via server-side prompt caching within the ~5-min TTL — not by skipping the send.
Evidence: Fresh process pays full ~14k system+tools (or ~33k incl. context injection) on turn 1; no persisted model KV state — both CLIs reconstruct context from transcript, not saved model state (verdent.ai; dev.to). Resume relies on prompt caching: your machine re-sends everything and the provider serves a matching cached prefix at ~10x discount (Anthropic) / 75–90% (Codex); Codex mid-session turn showed 90.9% cache hit. Conversation cache TTL ≈5 min; after expiry the next call pays full price again. Codex has persistent `app-server`/`exec-server`/`mcp-server` modes (developers.openai.com/codex reference) — latency benefit unmeasured. Claude Code has no documented persistent daemon for `-p`.
Confidence: high for the mechanism; medium for exact token magnitudes.
Mechanism: Cold start = fixed prefix reprocessing + process spin-up. Multiplied by stage count, it is aidev’s dominant structural tax versus one long session.
Plan impact: THIS is the number that decides the whole design. With 6 stages × 14k fixed prefix = 84k tokens of pure ceremony before any real work — versus one solo session paying 14k once. aidev MUST either (a) collapse to ≤3 calls, and (b) keep all calls within one warm cached prefix inside the 5-min TTL, or it cannot be token-competitive. Prefer in-process SDK / warm pool over process-per-stage.
Cost: High — this contradicts “one worker call per stage” and “fresh context per stage.” See H3.

FINDING B1 — Cache mechanics
Claim: Anthropic prompt cache is prefix-based: reads cost 0.1x base input regardless of TTL; writes cost 1.25x for the 5-min TTL and 2x for the 1-hour TTL; minimum cacheable prefix is 1,024 tokens (2,048 for Haiku); up to 4 breakpoints; per-model; invalidated by any single-token change in the prefix; cached reads do NOT count against ITPM rate limits on current models (except Haiku 3.5).
Evidence: Anthropic docs (as cited by keepmyprompts.com and dev.to): TTL options are “5 minutes (1.25× the base input token price for writes) and 1 hour (2× for writes); cache reads cost 0.1× regardless of TTL.” “If anything in the prefix differs by even one token, you get a cache miss and pay full input price”; the cache is “matched as a prefix, not a substring”; you may mark “up to 4 points in that prompt with cache_control” (respan.ai citing Anthropic docs). Prefix order is tools→system→messages (platform.claude.com). Rate limits: “Prompt cache read tokens no longer count against your ITPM limit” (Anthropic), example 2M ITPM + 80% cache hit → 10M effective input tokens/min; Haiku 3.5 is the exception that still counts cache reads. OpenAI/Codex: automatic caching, per OpenAI’s Oct 2024 announcement, gives “a 50% discount and faster prompt processing times” applied automatically “on prompts longer than 1,024 tokens”; newer models cut input token costs “by up to 90%” and TTFT “by up to 80%” (OpenAI Prompt Caching 201 cookbook), with no separate write fee.
Confidence: high — primary vendor docs.
Mechanism: Provider stores encoded KV state for the exact leading byte sequence; any change before the breakpoint forces a full re-prefill.
Plan impact: Design a stable invariant preamble (policy + tool schema + repo invariants) as the cached prefix across all R0/R1 calls; put variable content (the specific task, retrieved symbols) AFTER the last breakpoint. Never put timestamps/UUIDs/task-id in the prefix. Choose the 1-hour TTL (2x write premium) only when the test suite between calls can exceed 5 minutes — otherwise the write premium is wasted.
Cost: Requires disciplined byte-stable prompt assembly and staying within TTL between calls.

FINDING B2 — The central comparison (crossover model)
Claim: One long session (growing history, high cache-hit) usually consumes FEWER tokens than N cold orchestrated calls until N calls can share a warm cached prefix; the answer flips only when the orchestrator (a) shares a cache and (b) prunes per-call context below what the long session accumulates.
Evidence: Long session reaches ~98% cache-read rate (dev.to trace). Naive multi-step loops rebill history O(N²) (Augment Code). But orchestrated calls that prune stale context to only what each step needs cut waste substantially (LeanOps: pruning 8k→800 gives 7,200 tokens/step saved). Claude Code docs: cross-model-boundary delegation is billed at least twice (orchestrator output + worker input, worker output + orchestrator input) — “every token that crosses a model boundary is billed at least twice”  (claudefa.st). Note also that Anthropic silently changed the Claude Code prompt-cache TTL default from 1 hour to 5 minutes in early March 2026, which “caused a 20–32% increase in cache creation costs and a measurable spike in quota consumption for subscription users” (anthropics/claude-code Issue #46829) — a recency caveat: the crossover math is sensitive to provider TTL defaults that can change without notice.
Confidence: medium — synthesized from measured components; no single head-to-head R0/R1 study exists (unmeasured, see Open Experiments).
Mechanism: The long session’s cost is cache-read-dominated and cheap; the orchestrator wins only when its per-call fresh context is smaller than the long session’s accumulated history AND it shares one cached prefix so it doesn’t re-pay writes.
Plan impact: aidev only beats the solo session on tokens if it (1) prunes context hard per call, (2) shares ONE cached prefix, (3) avoids re-crossing model boundaries. Structured multi-part output in one call beats N calls whenever context would otherwise repeat.
Cost: Loses the “clean fresh reviewer context” ideal unless the reviewer reuses the same cached prefix with only the diff appended.

FINDING B3 — Cache-friendly multi-stage design
Claim: Named patterns that preserve cache across orchestrated calls: (1) stable invariant preamble with a single breakpoint after tools+policy; (2) session forking instead of new sessions; (3) batching stages into one structured call; (4) warm-session pool; each avoids re-paying the ~14k write.
Evidence: Codex `fork`/`resume` reconstruct from transcript and hit cache (90.9% observed). Claude Code: “resumable sub-agents beat one-shot ones on cost as well as quality” because persistent sub-agents keep loaded context  (claudefa.st). Adding one MCP tool invalidates the entire cached prefix; Claude Code locks the tool list at startup for this reason  (claudecodecamp.com). 1-hour TTL via ENABLE_PROMPT_CACHING_1H for runs >5 min. 
Confidence: medium-high.
Mechanism: Cache hit requires byte-identical prefix within TTL; forking preserves it, new processes destroy it.
Plan impact: Adopt a single warm session per task that forks for the independent-review step (fresh reasoning, shared cached prefix + only the diff differs). Batch DISCOVER+CLASSIFY into one structured call. Never mutate the prefix mid-task (no dynamic tool registration).
Cost: Forking couples review context to build context slightly — mitigated by appending only the diff and an independent test plan after the breakpoint.

FINDING B4 — Subscription/quota accounting
Claim: Cached input tokens do NOT count against ITPM rate limits on current Claude models, so cache optimization relieves the actual throughput constraint, not just the bill.
Evidence: Anthropic docs and news: “Prompt cache read tokens no longer count against your ITPM limit”; example: 2M ITPM + 80% cache hit → 10M effective input tokens/min. Exception: Claude Haiku 3.5 counts cache reads toward ITPM.
Confidence: high — primary docs.
Mechanism: Provider serves cached prefix without re-running attention prefill, so it doesn’t consume rate-limited compute.
Plan impact: For subscription/rate-limited operation, caching is a throughput multiplier — strongly favors the warm-cached-prefix design. Avoid Haiku 3.5 as the cached-prefix model.
Cost: None; pure upside.

FINDING C1 — What signal predicts the edit set
Claim: File-level localization is the dominant factor (15–17x improvement over no-file baseline); LLM-based retrieval generally beats structural heuristics using fewer files and tokens, but static signals (import graph, git co-change) are competitive at near-zero token cost.
Evidence: arXiv 2604.05481 (500 SWE-bench Verified, GPT-5-mini, 61 configs): file-level localization = 15–17x over no-file; best results at ~6–10 relevant files; line-level context expansion frequently DEGRADES performance (noise amplification); LLM retrieval > structural heuristics with fewer tokens.  Git co-change: Random Forest on co-change history beats file-proximity/clones/StarCoder2 baselines by 4.7–537.5% NDCG@5 (arXiv, 150 Java projects); accuracy declines after 60 days (needs bi-monthly retraining).  `git log` retains the bug-inducing commit in 100% of cases at 27.3s avg vs CodeShovel 521s (arXiv 2502.12922). 
Confidence: high.
Mechanism: The correct file localizes most of the answer; extra line-level slicing adds noise faster than signal.
Plan impact: Rank signals for R0/R1 by precision-per-token: (1) exact symbol/import-graph reachability (free), (2) git co-change (cheap, retrain bi-monthly), (3) LSP call-graph, (4) embedding similarity last. Target ~6–10 files max; do NOT over-slice to line level for the model.
Cost: Build a static localizer; retrain co-change model bi-monthly.

FINDING C2 — Minimum sufficient context / distraction knee
Claim: There is a knee: adding context past ~6–10 relevant files stops helping and line-level over-specification actively hurts; more context reduces quality via distraction, not just cost.
Evidence: arXiv 2604.05481: “more context does not consistently improve repair performance”; line-level expansion “frequently degrades performance due to noise amplification.”  README-maintenance study (arXiv 2603.00489): adding full PR context “significantly degrades” Gemma localization; “surplus of low-level details introduces noise.”  SWEzze (arXiv 2603.28119): preserving the small sufficient subset beats aggressive compression AND beats no-compression; a retained distracting fragment causes an incorrect patch. 
Confidence: high.
Mechanism: Attention dilutes over irrelevant tokens; distractors can flip a correct patch to incorrect.
Plan impact: Set a context ceiling for R0/R1 (e.g., the localized symbol + its direct callers/callees + the impacted test), not whole files where avoidable. Treat context minimization as a QUALITY lever, not only a cost lever.
Cost: Requires symbol-closure extraction rather than file dumps.

FINDING C3 — A model-free stop rule with teeth
Claim: Sufficiency can be judged without a model call using compiler/type-checker resolution + import-graph reachability + symbol closure; “evidence coverage” should be defined as: every symbol referenced by the change site resolves within the assembled context and the impacted test’s imports are reachable.
Evidence: pyright retains a dependency graph and limits reanalysis to affected files (microsoft/pyright discussion #5974);  import-graph tools (tach, pytest-impacted via astroid/NetworkX) map changed modules to dependents statically with no model call. “Context deemed sufficient if ≥half of generated patches pass tests” is the research oracle (SWEzze) — but that needs execution; the cheaper static proxy is symbol-closure completeness.
Confidence: medium — the components exist and are deterministic; no published system packages exactly this “evidence coverage” metric (partially unmeasured).
Mechanism: If every free identifier at the edit site resolves to a definition present in context and the test’s transitive imports are included, the model has what a compiler would need.
Plan impact: Replace the placeholder “evidence coverage” with a computable predicate: `closure_complete = (unresolved_symbols == 0) AND (impacted_test_imports ⊆ assembled_context)`. Gate the IMPLEMENT call on it; expand context deterministically until it holds. Zero model calls.
Cost: Language-specific resolvers (pyright for Python, tsc/ts-morph for TS). Medium effort, high payoff.

FINDING C4 — Asymmetric cost of error
Claim: A missing needed file is far more expensive (failed run → repair loop → possibly wrong patch) than an extra unneeded file (dilution), so the operating point should favor recall — but only up to the distraction knee, past which extra files also cause wrong patches.
Evidence: Localization failures dominate agent failure taxonomies (40% in SHERLOC/AgentForge; see F1). But C2 shows distractors flip correct→incorrect patches. So the cost curve is U-shaped, not monotonic: under-inclusion causes repair loops (each loop = another full-context turn), over-inclusion causes silent wrong patches.
Confidence: medium.
Mechanism: Absence forces re-derivation (expensive, multi-turn); mild excess is cheap; heavy excess is a correctness hazard.
Plan impact: Tune the static localizer to favor recall to ~6–10 files, then STOP (don’t keep adding). Use the C3 closure predicate as the recall floor and the ~10-file count as the precision ceiling.
Cost: One tuning parameter (max files) + the closure floor.

FINDING D1 — Decomposition vs one strong call (complexity threshold)
Claim: At low task complexity, decomposition/orchestration buys almost nothing; the cheapest agent reaches ~92% of the most expensive agent’s pass@1 on the simplest coding tasks, and simpler scaffolds match complex ones within a few points at far lower token cost.
Evidence: arXiv 2602.02751 (Qwen3 agents, complexity-conditioned): on simplest coding tasks the cheapest agent = ~92% of the most expensive’s pass@1 (scaling curve nearly flat); separation only appears at high complexity (cheapest = 17% at hardest).  CodeTracer (arXiv 2604.11641): MiniSWE-Agent 44.6k tokens vs SWE-Agent/OpenHands 86.7k/91.4k tokens for only +2.4–5.5pp success.  Agentless (FSE2025, arXiv 2407.01489): “the simplistic Agentless is able to achieve both the highest performance (32.00%, 96 correct fixes) and low cost ($0.70) compared with all existing open-source software agents”; HuggingFace paper page reports “$0.70 per issue vs $3.34 for some agent approaches.”
Confidence: high.
Mechanism: Simple tasks have a single correct trajectory; orchestration adds overhead without adding necessary decisions.
Plan impact: This is the core justification for a SEPARATE R0/R1 pipeline. The FSM’s value appears only at R2/R3 complexity. For R0/R1, one well-prepared call ≈ the whole ceremony at a fraction of cost. Build the two-track system explicitly.
Cost: Maintaining two pipelines — but the R0/R1 track is small.

FINDING D2 — Which stages are load-bearing at R0/R1
Claim: At R0/R1 the load-bearing stages are localization (deterministic), implementation (one call), and verification (deterministic); DESIGN and mandatory REVIEW are largely ceremony; CLASSIFY can be model-free.
Evidence: Agentless’s three phases (localize, repair, validate) suffice for the majority of contained issues (arXiv 2407.01489). Adding a reviewer raises cost with negligible turn benefit in single-agent settings ($3.28→$3.49; arXiv 2606.00370: “Single Agent at $3.28/run achieves comparable quality at the lowest cost”).  LLM review F1 <20% with high false positives on real diffs (F3/F4). Localization is the dominant failure point (F1).
Confidence: medium-high.
Mechanism: Design is implicit for a one-module change; review by a weak model on a small diff adds noise; classification is a static-signal problem.
Plan impact: Delete DESIGN as a discrete model call at R0/R1 (fold into the implementation prompt). Make CLASSIFY model-free (D3). Make REVIEW conditional, not mandatory (F3). Keep DISCOVER (as deterministic localization) and VERIFY.
Cost: Reverses “mandatory review at R1.” Political/architectural, low code cost.

FINDING D3 — Model-free classification
Claim: R0/R1 risk classification and localization can be done with static analysis + git history + path rules at zero model calls, with useful accuracy — every eliminated call is pure speed and token savings.
Evidence: Test-impact/import-graph tools (tach 8x faster,  pytest-impacted, pytest-tia) map diffs→affected modules/tests statically with no model. Git co-change RF models predict co-changed methods with strong NDCG@5 (arXiv). Diff+commit-message defect classifiers reach F1 0.83–0.88 (arXiv 2505.08263)  — but that needs a model; the purely static path/size/co-change signal is cheaper and sufficient for R0 vs R1 vs escalate.
Confidence: medium — components proven; the exact classifier accuracy for aidev’s R-tiers is unmeasured (Open Experiments).
Mechanism: R0 (rename/typo/comment) is detectable from diff shape and AST-equivalence; R1 vs R2 boundary from #files, #symbols, cyclomatic delta, test blast radius.
Plan impact: Replace model-based risk classification with a deterministic scorer over: files touched, symbols touched, import fan-out, co-change coupling, test blast radius, path rules (config/migration/security paths force escalation). Reserve a model call only for ambiguous mid-band cases.
Cost: Reverses “model-based risk classification.” Medium build; large recurring savings.

FINDING D4 — Structured output vs agentic loop
Claim: For a bounded task with pre-assembled context, one constrained-schema completion is cheaper, faster, and more reliable in output shape than an agentic tool loop; native constrained decoding gives ~100% schema fidelity vs unpredictable free-form tool loops.
Evidence: Strict structured outputs offer “near 100% schema fidelity”; function-calling loops are “statistically unpredictable” (machinelearningmastery).  WorkBench Revisited (arXiv 2606.13715): switching from free-form ReAct to native structured tool-calling “removes the format-adherence failures that dominated the 2024 results.”  Agentless deliberately does NOT let the LLM decide future actions and wins on cost.  A single forced tool = a typed function return, not “agentic” (72technologies). 
Confidence: high.
Mechanism: Each agentic turn is a fresh round-trip re-billing context and risking malformed actions; a single constrained call emits the diff directly.
Plan impact: For R0/R1 IMPLEMENT, use Claude `--json-schema` / Codex `--output-schema` to emit a structured patch in one call from pre-assembled context, not an agentic edit loop. Quantify: replaces ~12-turn median agent run with 1 call.
Cost: Requires the context to be genuinely sufficient (C3). If insufficient, one repair round; still far cheaper than an open loop.

FINDING E1 — Test impact analysis
Claim: Selecting only diff-affected tests cuts test time ~2–8x per ecosystem, but static (import-graph) TIA can under-select on non-import couplings and must fail safe.
Evidence: Testmon halved median test time (Instawork).  tach test 8x faster on FastAPI via module dependency graph.  Jest `--findRelatedTests $(git diff --name-only)`; teams report 45-min → <10-min runs (Augment Code).  pytest-tia warns the “cardinal sin” is skipping a test that would fail; coverage.py sysmon core silently drops non-first tests hitting a shared line (a real false-negative source).  pytest-impacted deliberately favors false positives; forces all-tests when lockfiles/pyproject change. 
Confidence: high.
Mechanism: Most tests can’t be affected by a small diff; the dependency graph identifies the few that can.
Plan impact: Adopt import-graph TIA for R0/R1 (tach/pytest-impacted for Python, `jest --findRelatedTests` for TS). Fail safe: run full impacted-module suite if the map is stale or dependency files changed. This is likely the single biggest wall-clock win if tests dominate (A2).
Cost: Coverage-map maintenance (or accept over-selection with cheaper static analysis).

FINDING E2 — Warm infrastructure
Claim: Persistent type-checkers/LSP in watch mode turn 30s cold checks into ~3s incremental checks; keeping them warm across runs is the main type-check speedup.
Evidence: pyright runs persistently with `--watch`, retaining a dependency graph and limiting reanalysis to affected files; per-invocation startup is “very slow” because each cold run re-evaluates builtins/imports (microsoft/pyright #5974).  TypeScript incremental + `.tsbuildinfo` cache drops type-check “from 30s to 3s on unchanged files” (dev.to);  note tsc `--watch` initial build can be slower than a plain `tsc` (TS #42960)  — warmth pays off only after the first build. pyright is ~3–5x faster than mypy for incremental checks (DataCamp). 
Confidence: high.
Mechanism: Warm process keeps the type graph and symbol cache in memory, avoiding re-parsing dependencies each run.
Plan impact: Run a persistent pyright `--watch` / tsc `-b --watch` daemon in the worktree, queried by the VERIFY stage — do NOT spawn a cold checker per verification. Pair with warm-worker pool (A4/E3).
Cost: Memory (pyright/tsc daemons ~hundreds MB) and lifecycle management per worktree.

FINDING E3 — Safe overlap
Claim: Lint, type-check, and SAST can run concurrently with model inference and with each other; pre-warming caches and speculative test selection overlap safely because they don’t mutate the diff being generated.
Evidence: General CI practice (Augment Code “12 faster testing strategies”): parallelize independent checks. Type-check is separable from emit (`tsc --noEmit`). Codex `app-server` and warm pools allow pre-warming (A4). Speculative prewarming of sandboxes is an emerging Codex pattern (danielvaughan.com references SpecBox).
Confidence: medium — parallelism is standard; specific “run previous checkpoint’s suite while next stage generates” is an inference, not a measured result.
Mechanism: Read-only checks on a fixed diff are order-independent and side-effect-free.
Plan impact: While the IMPLEMENT call streams, pre-warm the test runner and type daemon and pre-compute the impacted-test set. Run lint/type/SAST in parallel on the produced diff. Fold overlap into the latency budget.
Cost: Orchestration complexity; must invalidate speculative work if the diff changes.

FINDING E4 — Fast-fail ordering
Claim: Order checks cheapest-and-most-discriminative first: syntax/parse → type-check → impacted unit tests → lint/SAST; this surfaces the most agent-introduced defects per second because localization/semantic errors show up as type or test failures fastest.
Evidence: Agent regressions are frequent and test-detectable: a vanilla agent caused 562 pass-to-pass failures across 100 instances (6.5 broken tests/patch; TDAD arXiv 2603.17973).  METR: ~half of SWE-bench-passing patches wouldn’t be merged; CI failures are a leading cause of rejected agent PRs.  Type errors are cheap to surface (seconds, warm daemon E2) and catch a class of wrong-symbol edits before tests run.
Confidence: medium — ordering logic is sound; exact “defects caught per second by check type” is unmeasured for agent diffs.
Mechanism: Cheapest deterministic checks eliminate the largest, most obvious failure classes before expensive test execution.
Plan impact: VERIFY runs: (1) parse/compile, (2) warm type-check on changed files, (3) impacted tests fail-fast (`-x`), (4) lint/SAST in parallel. Abort on first hard failure → repair.
Cost: Low; mostly ordering configuration.

FINDING F1 — Failure taxonomy at R0/R1
Claim: Solo-agent failures are dominated by localization errors (~40%) and correct-file-wrong-change / semantically-wrong-but-plausible patches (~27–72%); “tests never run” and outright tooling errors are smaller.
Evidence: SHERLOC (arXiv 2606.24820): of zero-recall localization failures, 40% reasoning error (saw correct file, picked wrong), 27% close miss (right dir, wrong file), 25% wrong module; 67% pick-wrong-among-nearby.  AgentForge (arXiv 2604.13120): faulty localization 40.0%, ineffective patch 26.7%, cognitive deadlock 20.0%, environment/tooling 13.3%.  AutoCodeRover (arXiv 2404.05427): 29.3% correct location but wrong patch, 20.0% correct file wrong location, plus wrong-file and no-patch.  OmniCode / SWE-Bench 5G: dominant mode is “incorrect/incomplete fix” (semantically misaligned), 72–80 instances/model. 
Confidence: high — consistent across ≥4 independent studies.
Mechanism: LLMs reach the right neighborhood but mis-select the exact site or violate a latent invariant.
Plan impact: The highest-yield interventions target (a) localization precision (deterministic localizer + closure predicate, C1/C3) and (b) catching invariant violations (impacted tests + type check, E). Reviewer LLMs do NOT address the dominant modes well (F3).
Cost: Concentrates effort on localization + deterministic verification, not on more model stages.

FINDING F2 — Highest-yield single intervention
Claim: Running the existing impacted test suite (plus type-check) catches the largest share of R0/R1 failures per token — more than diff-review, failing-test-first, or caller-checking as a first line.
Evidence: F1’s dominant failure is semantically-wrong patches that violate existing behavior → caught by pass-to-pass tests (562 regressions/100 instances would be caught; TDAD). Type-check catches wrong-symbol/signature edits cheaply (E2). Generated-test filtering improves precision to 47.8% but drops recall to 20% (Otter, arXiv 2502.05368)  — good as a gate, weaker as a catch-all. Reviewer LLM F1 <20% (F3). Anthropic: deterministic graders (does it compile, do tests pass) are the reliable signal. 
Confidence: high.
Mechanism: Existing tests encode the repo’s real invariants; executing them is deterministic truth, unlike a model’s opinion.
Plan impact: Make “run impacted tests + type-check” the mandatory, non-negotiable R1 gate. Make reviewer optional. This aligns with “recorded test evidence decides completion.”
Cost: Requires reliable impacted-test selection (E1) and a warm type daemon (E2).

FINDING F3 — Cheap review economics
Claim: A fast/small-model diff review is likely net-negative on small R0/R1 diffs due to low precision and high false-positive rate; false positives trigger bad “fixes.”
Evidence: SWR-Bench (arXiv 2509.01494): best ACR technique (PR-Review + Gemini-2.5-Pro) F1 only 19.38%; four other techniques <10% precision — “severely undermined by an excessive number of false positives.”  Static analysis tools address only ~16% of issues found in manual review and generate false positives (arXiv 2405.18216).  LLM code review earns trust only above ~80% actionable rate; first-gen tools got ~20% (tianpan.co).  BUT hybrid LLM+static false-alarm reduction eliminates 94–98% of static-analysis false positives with high recall (arXiv 2601.18844)  — review is valuable as an FP-filter for static findings, not as a primary bug finder.
Confidence: medium-high.
Mechanism: On a tiny diff there’s little signal; the reviewer hallucinates issues, and an auto-fix loop then degrades a correct patch.
Plan impact: Do NOT make a weak-model reviewer mandatory at R1. Use the model only to triage/explain DETERMINISTIC findings (failing tests, type errors, SAST hits), never to independently opine on small correct diffs. If a reviewer is used, gate its findings behind a deterministic signal.
Cost: Reverses “mandatory review at R1.” Saves tokens and avoids induced regressions.

FINDING F4 — Diff size and review reliability
Claim: Review quality (human and AI) drops sharply above ~200–400 changed lines; forcing smaller diffs is a stronger quality lever than adding reviewers.
Evidence: “Defect detection drops sharply above 200–400 lines of code” (qwe.edu.pl, citing review research).  Information-flooding failure mode: context fill >60–80% scatters model attention (tianpan.co).  Modern-code-review roadmap: risky files often get less rigorous review (arXiv 2405.18216). 
Confidence: medium — the 200–400 LOC threshold is widely repeated but the primary sources are review-research summaries.
Mechanism: Attention and human diligence both degrade with diff size.
Plan impact: Enforce a diff-size ceiling for R0/R1 (split beyond ~200–400 LOC into separate tasks); this improves BOTH quality and (via smaller context) cost. Prefer small-diff discipline over reviewer count.
Cost: Task-splitting logic; occasionally forces multi-task decomposition of an R1.

FINDING G1 — Capability boundary of fast/cheap tiers
Claim: The cheapest tiers reliably handle the simplest coding tasks (~92% of top-tier pass@1) and fail progressively as complexity rises; the reliable detection signal that a task exceeded the cheap tier is a DETERMINISTIC failure (tests/type-check fail), not the model’s self-confidence.
Evidence: arXiv 2602.02751: cheapest agent = ~92% of most-expensive on simplest coding tasks, 17% on hardest.  Self-reported LLM confidence is poorly calibrated — “confidently wrong and unconfidently right” (agentropic; GATEKEEPER arXiv 2502.19335).  Cascade escalation should key on a trained/deterministic signal, not raw confidence.
Confidence: high.
Mechanism: Cheap models match on-distribution simple edits; the honest signal of failure is the test/type oracle aidev already owns.
Plan impact: Run R0 and easy R1 on the cheapest tier at minimal/low reasoning; escalate ONLY when deterministic verification fails (not on model confidence). aidev’s deterministic verification is the perfect, free escalation trigger a generic cascade lacks.
Cost: None beyond wiring verify→escalate.

FINDING G2 — Cascade design
Claim: Try-cheap-then-escalate is net-positive when the cheap tier resolves most tasks and the escalation trigger is well-calibrated; blended cost = p_cheap + (1−resolve_rate)·p_expensive.
Evidence: FrugalGPT (arXiv 2305.05176, Chen, Zaharia, Zou) reports it “can match the performance of the best individual LLM (e.g. GPT-4) with up to 98% cost reduction or improve the accuracy over GPT-4 by 4% with the same cost.” Cluster-Route-Escalate (arXiv 2606.27457) retains 97–99% of strongest-model accuracy. Cascade “lives or dies on the scoring function” (agentropic); it adds the cheap call’s cost even on escalated tasks and stacks latency on the hard ones.
Confidence: high.
Mechanism: If most R0/R1 resolve on the cheap tier and escalation keys on the deterministic test oracle (perfectly calibrated), the wasted first attempt is small and bounded.
Plan impact: Use a two-tier cascade: cheap tier + minimal reasoning first; on deterministic verify failure, escalate to a stronger tier / higher reasoning with the failure evidence appended (cached prefix reused). Because escalation keys on tests, false escalation ≈ 0.
Cost: Wasted first attempt on the minority that escalate (~one cheap call + one test run).

FINDING G3 — Reasoning effort vs quality curve
Claim: For bounded coding tasks, minimal→low reasoning gives the big jump and medium is the plateau; high/xhigh rarely helps and sometimes hurts. Minimal is often sufficient for genuine R0.
Evidence: Sonar/GPT-5 study (4,400 Java tasks): minimal ~75% → low ~80% → medium ~82% (peak) ≈ high ~82%; “medium is the sweet spot.”  arXiv 2512.15699: medium→high can DROP performance (15.3→12.6).  Codex Knowledge Base: default medium; run routine tasks at low/minimal; “high should not be your default.”  GPT-5.1-Codex-Max: better SWE-bench at medium using 30% fewer thinking tokens than prior at medium. 
Confidence: high.
Mechanism: A little reasoning fixes shallow mistakes; past the plateau, extra thinking adds tokens/latency and can over-engineer.
Plan impact: R0 = minimal effort; R1 = low (escalate to medium only on verify failure). Never default R0/R1 to high. This directly cuts both tokens and latency.
Cost: One parameter per tier; trivial.

-----

## Recommendations

**Stage 1 — Reverse the cache-hostile and cold-start commitments (do first).**

1. Replace process-per-stage (`claude -p`/`codex exec` spawned per FSM stage) with a **single warm session per task that forks for review**, or an in-process SDK worker pool. Rationale: the ~14k–33k fixed prefix × stage count is aidev’s dominant structural tax (A4, B2). Benchmark to change: if per-task cold-start tokens > 1× the fixed prefix, you are re-paying it.
1. Define ONE **byte-stable cached prefix** (policy + tool schema + repo invariants) with a single breakpoint; put all variable content after it; stay within the 5-min TTL (or enable the 1-hr TTL, at a 2x write premium, only when the test suite between calls exceeds 5 minutes) (B1, B3). Threshold: `cache_read_input_tokens/total_input > 0.8`.
1. Collapse R0/R1 to **≤3 model calls**: (a) one structured localize+classify (mostly model-free), (b) one constrained-schema IMPLEMENT, (c) conditional escalation/repair only on verify failure (D4, G2).

**Stage 2 — Make classification and verification deterministic (do second).**
4. **Model-free risk classifier and localizer** over files/symbols touched, import fan-out, git co-change, test blast radius, path rules (D3, C1). Reserve a model call only for ambiguous mid-band cases.
5. Replace placeholder “evidence coverage” with the computable **closure predicate**: zero unresolved symbols at edit site AND impacted-test imports ⊆ assembled context (C3).
6. **Impacted-test selection + warm type daemon** as the mandatory R1 gate, fail-fast ordered: parse → type → impacted tests → lint/SAST in parallel (E1, E2, E4, F2).

**Stage 3 — Right-size effort and make review conditional (do third).**
7. R0 = cheapest tier + minimal reasoning; R1 = cheap tier + low reasoning; escalate on deterministic verify failure only (G1, G2, G3).
8. **Make the LLM reviewer conditional, not mandatory at R1** — use the model only to triage/explain deterministic findings, never to opine on small correct diffs; enforce a ~200–400 LOC diff ceiling (F3, F4).

**Benchmarks that would change these recommendations:** If profiling shows test execution is <20% of R1 wall clock and model inference >50%, shift investment from Block E to caching/routing. If the model-free classifier’s R1-vs-R2 boundary accuracy is <~85%, keep a cheap model classifier for the mid-band. If cache-read fraction can’t exceed ~0.7 in practice (TTL expiry from slow tests), the token target degrades toward 1.0x and you must batch stages into a single call.

-----

## Token & Latency Budget Models

**Token budget (illustrative; conditions: Python single-module R1, Claude Sonnet-class, warm cache).**

Solo baseline (one session, ~12-turn median): fixed prefix ~14k (paid once, then cache-read) + accumulated history growth to ~80–100k by end, ~40% of which is file reads/re-reads; total ~120–160k input (mostly cache-read after turn 1) + ~10–20k output. Effective *billable* input heavily discounted by ~98% cache reads.

aidev recommended (3 calls, one shared cached prefix):

- Call 1 (localize/classify, mostly model-free; small model call only if ambiguous): ~14k prefix (cache-write once) + ~2k task = ~16k in / ~1k out.
- Call 2 (constrained IMPLEMENT): ~14k prefix (cache-READ ~0.1x) + ~8k pruned context (≤10 files, symbol closure) + ~2k reasoning + ~2k diff out.
- Call 3 (conditional, ~30% of tasks: repair on verify failure): prefix cache-read + failure evidence ~3k + ~2k out.
- Net billable input ≈ prefix-once + Σ(pruned per-call context); because context is pruned to closure and the prefix is cache-read, **aidev lands ~0.7–0.9x the solo baseline’s billable tokens** — NOT 0.5x, because the solo session already gets ~98% cache reads on its (larger but discounted) history. The 0.5x target fails here.

**Latency budget (illustrative; R1).**

Solo baseline: startup (warm ~2–4s) + ~12 turns × (2–4s inference + tool/test execution). Test execution can be the largest term.

aidev recommended:

- Localize/classify: deterministic, <1s (no model) or ~2–3s if a small model call.
- IMPLEMENT: one round-trip ~3–5s (structured output, no agentic loop) — replaces ~12 agent turns.
- VERIFY: impacted tests (2–8x faster than full suite via TIA) + warm type-check (~3s incremental vs ~30s cold) running fail-fast, partly overlapped with generation.
- Repair (30%): +1 round-trip + re-verify.
- Net: **~1.2–1.6x faster than solo at R1**, driven mostly by (a) replacing ~12 agent turns with 1–2 calls and (b) TIA + warm daemons on verification. **At pure R0, aidev can approach or exceed 2x ONLY IF it eliminates per-stage process startup**; if it retains process-per-stage, aidev is SLOWER at R0 (startup tax > the trivial edit’s inference).

-----

## Ranked Change List (by impact/effort)

**Must happen first (highest impact/effort):**

1. Kill process-per-stage; single warm session + fork-for-review with one shared cached prefix (A4, B2, B3). High impact, medium effort.
1. Model-free localize + classify (D3, C1, C3). High impact, medium effort.
1. Impacted-test selection + warm type daemon + fail-fast ordering as the mandatory R1 gate (E1/E2/E4/F2). High impact, medium effort.

**Next:**
4. Constrained-schema single-call IMPLEMENT instead of agentic loop at R0/R1 (D4). High impact, low effort.
5. Make reviewer conditional; enforce diff-size ceiling (F3, F4). Medium impact, low effort.
6. Effort tiering: R0 minimal / R1 low, escalate on verify failure (G3, G2). Medium impact, trivial effort.
7. Two-track architecture: R0/R1 Agentless-style, R2/R3 keep the FSM (D1). High impact, higher effort.
8. Byte-stable cached-prefix discipline + strip MCP on R0/R1 (A1, B1). Medium impact, low effort.

-----

## Contradictions With the Current Plan

- **“Fresh context per stage” is cache-hostile and directly raises tokens** — it forces a cache write (or full reprocess) every stage. Contradicted by A4/B1/B2/B3.
- **“One worker call per stage” pays the cold-start tax N times** — the ~14k–33k fixed prefix × stage count is the main reason a multi-stage orchestrator loses on tokens. Contradicted by A1/A4.
- **“Mandatory review at R1”** — LLM diff review F1 <20% on real diffs; on small correct diffs it is likely net-negative (induced regressions). Contradicted by F1/F3/F4.
- **“Model-based risk classification”** — R0/R1 classification is a deterministic problem; a model call here is pure waste. Contradicted by D3.
- **“Running the full relevant unit suite at R1”** — impacted-test selection gives the same regression coverage at 2–8x less wall clock; full-suite is unnecessary except when the impact map is stale. Contradicted by E1.
- **The 2x/0.5x/higher-quality target itself** — unreachable simultaneously; the achievable frontier is ~1.2–1.6x / ~0.7–0.9x / equal-or-better quality. Contradicted by the budget arithmetic above.

-----

## Binding Constraint

**The single thing preventing the target is the per-invocation cold-start tax (fixed prefix reprocessing + process startup) multiplied by stage count, compounded by the fact that a solo long session already achieves ~98% prompt-cache reads.** To move the frontier you would have to: (architecture) eliminate process-per-stage and share one warm cached prefix, collapsing to ≤3 calls; (providers) get a true persistent-daemon/warm-KV mode for `claude -p` (Codex has `app-server`; Claude Code does not document one) so cold starts vanish; or (target) accept ~1.5x/0.8x. A live recency risk sharpens this: Anthropic silently cut the Claude Code cache TTL default from 1 hour to 5 minutes in early March 2026, raising cache-creation costs 20–32% for subscription users (Issue #46829) — provider-side TTL changes can erode the token math without warning, so aidev must monitor `cache_read_input_tokens` continuously. Without the architecture change, aidev is SLOWER and token-neutral-at-best at R0/R1, exactly as the internal reasoning feared.

-----

## Open Experiments (cheapest test for each)

1. **R0/R1 token/latency decomposition for aidev’s actual worker CLIs** (unmeasured). Cheapest test: instrument 20 real R0 and 20 R1 tasks with `--output-format json` (Claude) / `--json` (Codex), log input/output/cache_read/cache_creation tokens and per-phase wall clock. Settles A1/A2/A4 for your stack.
1. **Long-session vs 3-call crossover** (unmeasured head-to-head). Cheapest test: run the same 20 R1 tasks solo vs the 3-call design; compare billable tokens and wall clock. Settles B2 and the budget model.
1. **Model-free classifier accuracy at the R1/R2 boundary** (unmeasured). Cheapest test: label 100 historical PRs by tier; measure the static scorer’s confusion matrix; target ≥85% before removing the model classifier. Settles D3.
1. **“Defects caught per second” by check type on agent diffs** (unmeasured). Cheapest test: inject the known agent-failure classes (regressions, wrong-symbol) into a sample and measure which of parse/type/test/lint catches each and how fast. Settles E4/F2 ordering.
1. **Closure-predicate sufficiency** (partially unmeasured). Cheapest test: on 50 tasks, compare patch correctness when context is gated by the closure predicate vs +2 extra files; confirms the C3 stop rule doesn’t under-include.
1. **Conditional-reviewer value** (unmeasured for aidev). Cheapest test: A/B the reviewer ON vs OFF on 50 R1 tasks; measure escaped defects and induced regressions; keep it only if net defects drop. Settles F3.