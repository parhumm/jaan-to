# aidev — Implementation Plan v1.0

**Status:** Ready to build · **Date:** 2026-08-22 · **Supersedes:** `deep-research-report.md`

This is the build document. The research report answered *what should be true*; this answers
*what gets written, in what order, and how we know it works*. Every open question from the
report is resolved here into a locked decision, a deferred item, or an explicit spike.

---

## 0. How to use this document

| Convention | Meaning |
|---|---|
| **D-nn** | Locked decision. Changing it requires an ADR supersede, not a code review. |
| **I-nn** | Invariant. Must hold at all times; each has an enforcing test. |
| **M-n** | Milestone. Sequential; each has binary exit criteria. |
| **S-nn** | Spike. Time-boxed investigation that must finish before the milestone that needs it. |
| *Deferred* | Not in v1. Listed in Appendix B with the trigger that would revive it. |

Three rules govern all work below:

1. **Vertical slice before depth.** M0 must run a complete task end-to-end with fake workers
   before any real intelligence is added. Every later milestone deepens a slice that already runs.
2. **Determinism before capability.** If a behaviour can be a rule, it is a rule. The model is
   asked only for judgement that cannot be computed.
3. **Evidence before optimisation.** No routing, prompt, effort, or gate change ships after M8
   without paired evaluation evidence.

---

## 1. Product definition

`aidev` is a **local, single-user, deterministic development control plane**. It owns workflow
state, context assembly, policy, isolation, verification, and evidence. Claude Code and Codex are
*replaceable cognitive workers* invoked through adapters, not the system's brain.

The stable product is the control plane. Model names are configuration.

### 1.1 v1.0 Definition of Done

v1.0 ships when all of these are true on a real project, unassisted:

- [ ] `aidev run "<task>"` takes a task from intent to `READY` with no manual intervention for R0/R1.
- [ ] Every run executes in a private Git worktree; the user's checkout is never modified.
- [ ] Killing the daemon mid-run and restarting resumes from the last checkpoint with no lost or
      duplicated side effects.
- [ ] Every worker side effect (file write, shell command, network, git op) passed through the
      Action Broker and appears in the event log with an allow/deny decision.
- [ ] `READY` is only reachable with recorded deterministic verification evidence — never on a
      model's assertion.
- [ ] Risk is computed as a vector three times per run; a deterministic floor has never been
      lowered by a model.
- [ ] R2/R3 runs receive fresh-context independent review, and findings are adjudicated before
      any fix is applied.
- [ ] Human gates fire for every action on the mandatory list (§8.6), showing action, consequence,
      exact command, rollback, and evidence.
- [ ] Token/time/usage accounting is recorded per invocation and never presented as subscription cost.
- [ ] The offline evaluation harness runs ≥30 tasks and produces paired workflow comparisons.
- [ ] `uv tool install aidev` produces a working install on macOS and Linux.

### 1.2 Explicit non-goals for v1

Team/multi-user, cloud control plane, remote agents, autonomous production deployment, learned
routing, vector memory, plugin marketplace, Windows support, IDE extensions, agent swarms.

### 1.3 Invariants

| ID | Invariant | Enforced by |
|---|---|---|
| I-01 | `aidev`, never a model, decides state transitions | FSM guard tests; no LLM call in transition path |
| I-02 | The daemon is the only writer to the database | CLI has read-only DB access; write path is IPC only |
| I-03 | No worker process writes outside its run worktree + scratch | Broker path canonicalisation; sandbox filesystem policy |
| I-04 | Workers inherit an env allowlist, never `os.environ` | `spawn()` unit test asserts exact env set |
| I-05 | A deterministic risk floor can be raised, never lowered | Risk engine applies floors after model input |
| I-06 | `READY` requires ≥1 stored `VerificationReport` with `status=pass` | FSM guard on `REVIEW → READY` |
| I-07 | Untrusted content is never interpreted as instruction | Trust labels; prompt assembly rejects instruction-role untrusted items |
| I-08 | Stage boundaries commit in one SQL transaction | Checkpoint test with injected crash at every boundary |
| I-09 | Mandatory human gates cannot be satisfied by config or model | Gate list is a frozen constant, not policy-file data |
| I-10 | Repository-supplied agent config never executes | Adapter hardening flags (§9.4); asserted in adapter tests |

---

## 2. Locked decisions

| ID | Decision | Rationale (short) |
|---|---|---|
| D-01 | Custom typed FSM + SQLite as the workflow runtime | Local single-machine scope; Temporal/LangGraph add a second execution model for no gain |
| D-02 | FSM for lifecycle, bounded DAG *inside* a stage for parallelism | Deterministic lifecycle, concurrency where it is safe |
| D-03 | Mutable current state + append-only events + stage snapshots; **not** event sourcing | Model calls and shell effects cannot be replayed |
| D-04 | SQLite WAL + FTS5, one logical writer | Zero-ops, built-in search, matches daemon topology |
| D-05 | Git worktrees are the isolation unit; one per run, private branch | Cheap vs clone, shares object store |
| D-06 | Never mutate a dirty working tree. Build from committed `HEAD` and say so | Silent stash/reset is data risk and hostile UX |
| D-07 | Workers are CLI-backed by default (`claude`, `codex`); API adapters optional | Uses the user's own subscriptions; keeps plan and API billing distinct |
| D-08 | Capability-based routing (`coding.strong`, `review.critical`, …), never model names in workflows | Model names change; capabilities don't |
| D-09 | Model registry is versioned config, not code | Provider lineups shift faster than releases |
| D-10 | One `ArtifactEnvelope` + 9 payload families | Machine-validated contracts without 13 parallel taxonomies |
| D-11 | Contracts in Pydantic, exported to JSON Schema; schema-constrained model output where supported | Structured output beats inter-stage prose |
| D-12 | Risk is a 10-dimension vector with a derived R0–R3 class from safety floors | A scalar hides "small change, catastrophic blast radius" |
| D-13 | Risk recomputed after discovery, after design, after implementation diff | Implementations wander into auth/payments/migrations |
| D-14 | Context carries `trust` and `provenance` per item; only 4 trust levels may contain instructions | Creates the boundary policy can enforce |
| D-15 | Progressive disclosure retrieval with adaptive budgets; no fixed global token constants | Stop on evidence coverage, not a token count |
| D-16 | Serena is the primary semantic provider **behind a `ContextProvider` interface** | Best current fit; must not become a hard dependency |
| D-17 | Repomix is optional, for overview/snapshot/token-profiling only | Compression removes exactly the detail implementation needs |
| D-18 | Canonical memory is Markdown in-repo; history search is FTS5. No vector DB in v1 | Reviewable, revertable, diffable; vectors solve a problem we don't have yet |
| D-19 | All worker side effects cross a single **Action Broker** | Prompt injection is not solvable by prompting |
| D-20 | v1 sandbox = provider-native isolation + broker policy. OS sandbox backends land in M9 | Both CLIs now ship OS-level sandboxes; don't rebuild them first |
| D-21 | Env is an allowlist; secrets denied by default; network denied by default | Least privilege at the process boundary |
| D-22 | Policy is typed Python invariants + YAML overrides. No OPA/Cedar | A second policy runtime for one user is unjustified |
| D-23 | Project policy may only **tighten**; weakening a floor is a local config act, never a model act | Safety floors are not negotiable by the thing being constrained |
| D-24 | Verification is a plugin system with a risk-adaptive check matrix | Don't run fuzzing on a typo; don't skip SAST on auth |
| D-25 | Independent test plan → builder writes code + tests → independent reviewer finds gaps | Builder must not define its own oracle |
| D-26 | Generated tests are executed and reviewed, never treated as ground truth | Generated tests encode generated assumptions |
| D-27 | Review is fresh-context, evidence-driven, risk-triggered. No default swarms | Cost and false positives scale faster than value |
| D-28 | Findings have a lifecycle and are adjudicated before any fix | Reviewer false positives cause real regressions |
| D-29 | Cross-provider review is a preference for R2/R3, not an invariant | Context independence is the mechanism; provider diversity is unproven |
| D-30 | Quota pressure is ordinal (LOW/MED/HIGH/CRITICAL) and may only alter *optional* work | Never trade a required gate for tokens |
| D-31 | Internal event schema is stable and OTel-mappable; OTel export is optional | Own the schema; don't chase an evolving spec |
| D-32 | Prompt/output content logging is OFF by default; metadata always ON | Prompts contain source and secrets |
| D-33 | Cost is labelled "API-equivalent estimate", never subscription spend | Provider figures are client-side list-price estimates |
| D-34 | Offline eval harness is a v1 requirement, not a v2 feature | Nothing may be "optimised" without it |
| D-35 | Every stage is idempotent and resumable from checkpoint | Crash mid-run must not corrupt or duplicate |
| D-36 | Daemon listens on a Unix socket with `0600`, no TCP by default | The daemon is a code-execution API |
| D-37 | macOS + Linux only in v1 | Windows sandbox/socket work is not worth v1 time |
| D-38 | One active run per project by default; parallel DAG is M9 | Correctness first, speed second |
| D-39 | Python 3.12+ (developed on 3.13), `uv` packaging, `uv tool install` primary | Subprocess/SQLite/schema work, not compute throughput |
| D-40 | Verification adapters in v1: Python, Node/TS, and a config-declared generic adapter | Two real ecosystems + escape hatch covers most projects |

---

## 3. Architecture

### 3.1 Component map

```text
     aidev CLI / TUI  ──── Unix socket (0600) ────►  aidevd
     (thin client, read-only DB)                     (sole writer)
                                                        │
        ┌───────────────────────────────────────────────┼──────────────────────────┐
        │                        DETERMINISTIC CORE     │                          │
        │   FSM ── Risk Engine ── Policy Engine ── Workspace Mgr ── Verification    │
        └───────────────────────────────────────────────┼──────────────────────────┘
                                                        │
                                            Context Compiler
                                    (providers → packet + provenance + trust)
                                                        │
                                            Capability Router
                                        (registry + risk floors + quota)
                                                        │
                            ┌───────────────────────────┴───────────────────────────┐
                            ▼                                                       ▼
                    ClaudeCliAdapter                                        CodexCliAdapter
                            └───────────────────────────┬───────────────────────────┘
                                                        ▼
                                                 ACTION BROKER
                              policy · trust · path canon · arg validation
                              env filter · network policy · human gate
                                                        ▼
                                             Sandbox (provider-native v1)
                                                        ▼
                                       Run worktree · Git · toolchain
                                                        ▼
                                    Verification Engine → evidence artifacts
                                                        ▼
                                    Review → Findings → Adjudication
                                                        ▼
                                               Human gate (if required)
                                                        ▼
                                                     READY
```

### 3.2 Trust zones

| Zone | Contents | Trust |
|---|---|---|
| Core | aidev code, built-in invariants, user-approved project policy | Trusted |
| Control data | Approved artifacts, user's task text | Conditionally trusted |
| Worker | `claude`/`codex` subprocesses | Untrusted output, constrained capability |
| Content | Repo files, tool output, MCP output, dependency docs, network | Untrusted data — never instruction |

### 3.3 Module layout

```text
src/aidev/
├── cli/            typer commands, rich rendering, socket client
├── tui/            textual app (M8)
├── daemon/         fastapi app on UDS, lifespan, single-writer guard
├── core/
│   ├── fsm.py            states, transitions, guards
│   ├── run.py            run orchestration, stage attempts
│   ├── checkpoint.py     transactional stage commit + resume
│   └── ids.py            uuid7/ULID, short display ids
├── models/         pydantic contracts (§5); one module per payload family
├── store/
│   ├── db.py             connection, pragmas, migrations
│   ├── migrations/       forward-only .sql
│   ├── events.py         append-only event writer
│   └── artifacts.py      content-addressed blob store
├── risk/           dimensions, floors, derivation, recompute hooks
├── policy/         invariants.py (frozen), loader.py (yaml), evaluate.py
├── broker/         verbs, decisions, env, paths, network, gates
├── sandbox/        backend interface + provider-native + (M9) bwrap/podman
├── workspace/      worktree manager, dirty policy, checkpoint commits, gc
├── workers/
│   ├── base.py           WorkerAdapter, capabilities, events
│   ├── claude_cli.py
│   ├── codex_cli.py
│   ├── fake.py           deterministic fake worker (M0, and all tests)
│   └── registry.py       model registry loader
├── context/
│   ├── compiler.py       progressive disclosure loop
│   ├── providers/        serena, git, artifact, memory, fs, repomix, search
│   ├── budget.py         adaptive budget + coverage stop rule
│   └── packet.py         assembly, dedup, hashing
├── memory/         markdown store, promotion pipeline, fts index
├── verify/
│   ├── base.py           VerificationAdapter
│   ├── adapters/         python, node, generic, gitleaks, osv, semgrep
│   └── plan.py           risk→check matrix
├── review/         packet builder, finding model, adjudication
├── telemetry/      event schema, spans, usage, redaction, otel export
├── eval/           corpus loader, runner, stats, reports
└── config/         config.toml loading, project config, defaults
```

### 3.4 On-disk layout

```text
~/.aidev/
├── config.toml                  user config
├── aidev.db                     SQLite (WAL)
├── aidev.sock                   daemon socket, 0600
├── models.toml                  versioned model registry
├── policy.yaml                  user policy overrides (tighten-only)
├── artifacts/sha256/aa/bb/<hash>
├── logs/aidevd.jsonl            structured, redacted
└── workspaces/<project-id>/run-<id>/
    ├── primary/                 the run worktree
    ├── scratch/                 tool temp, TMPDIR target
    └── evidence/                verification output

<project>/.aidev/
├── project.toml                 detectors, commands, overrides
├── policy.yaml                  project policy (tighten-only)
└── memory/*.md                  canonical knowledge, committed to git
```

---

## 4. State model

### 4.1 FSM

```text
DISCOVER → CLASSIFY → DESIGN → IMPLEMENT → VERIFY → REVIEW → READY
                ↑         │         │          │        │
                └─────────┴─── risk escalation / repair loop
                                            │
   any state ──► BLOCKED_HUMAN ──► (resume) │
   any state ──► FAILED (terminal, resumable as new attempt)
   any state ──► CANCELLED (terminal)
```

Transition table — every transition has a guard, and no guard calls a model.

| From | To | Guard |
|---|---|---|
| `DISCOVER` | `CLASSIFY` | `TaskIntent` artifact stored; workspace created; base SHA recorded |
| `CLASSIFY` | `DESIGN` | `RiskAssessment` stored; derived class ≥ R1 |
| `CLASSIFY` | `IMPLEMENT` | derived class == R0 (design skipped by policy) |
| `DESIGN` | `IMPLEMENT` | `Design` + `TestSpecification` stored; R2/R3 also require challenge artifact |
| `IMPLEMENT` | `VERIFY` | `ChangeSet` stored; worktree SHA recorded; risk recomputed on diff |
| `VERIFY` | `REVIEW` | `VerificationReport.status == pass`; class ≥ R1 |
| `VERIFY` | `IMPLEMENT` | failing checks and `repair_count < max_repairs` |
| `VERIFY` | `FAILED` | `repair_count >= max_repairs` or non-retryable failure class |
| `VERIFY` | `READY` | class == R0 and policy allows no-review path |
| `REVIEW` | `IMPLEMENT` | ≥1 finding adjudicated `VALIDATED` with severity ≥ HIGH |
| `REVIEW` | `READY` | no open VALIDATED findings ≥ HIGH; final verification passed |
| `*` | `BLOCKED_HUMAN` | broker raised a mandatory gate |
| `BLOCKED_HUMAN` | previous | gate resolved `approved` |
| `*` | `CANCELLED` | user cancel; workers SIGINT then SIGTERM |

**Escalation rule:** if a risk recompute raises the derived class above the class the current path
was planned for, the run returns to `CLASSIFY` and re-plans. This is the only backward transition
that is not a repair loop.

### 4.2 Stage attempts and idempotency

Each stage execution is a `stage_attempt` row with `(run_id, stage, attempt_no)`. A stage is
idempotent because:

- All writes are inside the run worktree, which is reset to the stage's entry checkpoint on retry.
- Artifact writes are content-addressed; re-writing the same content is a no-op.
- Worker invocations are recorded with an `invocation_id`; a resumed stage never re-consumes a
  completed invocation, it reads the stored result.
- External side effects are impossible without a broker decision, and every broker decision is
  logged before the effect, so replay detects "already performed".

### 4.3 Checkpoint protocol

At every stage boundary, exactly one SQL transaction commits:

```text
BEGIN IMMEDIATE
  insert artifacts (hash refs; blobs already fsync'd to CAS via tmp+rename)
  insert worker_invocations + usage rows
  update run.current_state, run.workspace_sha
  insert stage_attempt result
  insert event 'stage.completed'
  insert checkpoint row (state, worktree SHA, artifact set, risk vector)
COMMIT
```

Blob rule: write to `artifacts/tmp/<uuid>`, `fsync`, `rename()` into CAS path, *then* record the
hash in the transaction. A crash leaves an orphan blob (GC'd), never a dangling reference.

### 4.4 Recovery algorithm

On daemon start, for each run not in a terminal state:

1. Load the newest checkpoint.
2. Reconcile the worktree: `git rev-parse HEAD` must equal `checkpoint.workspace_sha`.
   If it differs, `git reset --hard <sha>` **inside the aidev worktree only** and log
   `workspace.reconciled`.
3. Reap orphaned worker PIDs recorded in `worker_invocations` with no terminal event; mark them
   `interrupted`.
4. Resume at the checkpoint's state with `attempt_no + 1`.
5. If reconciliation is impossible (worktree deleted), mark run `FAILED` with
   `reason=workspace_lost` and keep all artifacts.

### 4.5 SQLite schema

Pragmas on every connection: `journal_mode=WAL`, `synchronous=NORMAL`, `foreign_keys=ON`,
`busy_timeout=5000`.

```sql
CREATE TABLE schema_version (version INTEGER PRIMARY KEY, applied_at TEXT NOT NULL);

CREATE TABLE project (
  id TEXT PRIMARY KEY, root_path TEXT NOT NULL UNIQUE,
  vcs_root TEXT NOT NULL, created_at TEXT NOT NULL, config_hash TEXT
);

CREATE TABLE run (
  id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES project(id),
  short_id TEXT NOT NULL UNIQUE, title TEXT NOT NULL,
  workflow_version TEXT NOT NULL, current_state TEXT NOT NULL,
  derived_class TEXT, base_git_sha TEXT NOT NULL, workspace_sha TEXT,
  worktree_path TEXT, branch TEXT, dirty_base INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  finished_at TEXT, outcome TEXT, failure_class TEXT
);
CREATE INDEX idx_run_project_state ON run(project_id, current_state);

CREATE TABLE stage_attempt (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  stage TEXT NOT NULL, attempt_no INTEGER NOT NULL,
  started_at TEXT NOT NULL, ended_at TEXT, status TEXT NOT NULL,
  failure_class TEXT, UNIQUE(run_id, stage, attempt_no)
);

CREATE TABLE checkpoint (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  seq INTEGER NOT NULL, state TEXT NOT NULL, workspace_sha TEXT,
  risk_vector_json TEXT, artifact_set_json TEXT, created_at TEXT NOT NULL,
  UNIQUE(run_id, seq)
);

CREATE TABLE artifact (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  stage TEXT NOT NULL, attempt_id TEXT, kind TEXT NOT NULL,
  schema_version TEXT NOT NULL, content_hash TEXT NOT NULL,
  producer TEXT, provider TEXT, model TEXT, effort TEXT,
  prompt_version TEXT, context_packet_hash TEXT,
  base_git_sha TEXT, workspace_git_sha TEXT, created_at TEXT NOT NULL
);
CREATE INDEX idx_artifact_run_kind ON artifact(run_id, kind);

CREATE TABLE event (
  seq INTEGER PRIMARY KEY AUTOINCREMENT, run_id TEXT REFERENCES run(id),
  ts TEXT NOT NULL, type TEXT NOT NULL, stage TEXT,
  span_id TEXT, parent_span_id TEXT, payload_json TEXT NOT NULL
);
CREATE INDEX idx_event_run_seq ON event(run_id, seq);
CREATE INDEX idx_event_type ON event(type);

CREATE TABLE worker_invocation (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  stage TEXT NOT NULL, role TEXT NOT NULL, capability TEXT NOT NULL,
  provider TEXT NOT NULL, model TEXT, model_snapshot TEXT, effort TEXT,
  auth_mode TEXT, session_id TEXT, pid INTEGER, exit_code INTEGER,
  status TEXT NOT NULL, started_at TEXT NOT NULL, ended_at TEXT,
  context_packet_hash TEXT, prompt_version TEXT, attempt INTEGER,
  retry_reason TEXT
);

CREATE TABLE usage (
  invocation_id TEXT PRIMARY KEY REFERENCES worker_invocation(id),
  input_tokens INTEGER, cached_input_tokens INTEGER, cache_write_tokens INTEGER,
  reasoning_tokens INTEGER, output_tokens INTEGER,
  wall_ms INTEGER, provider_active_ms INTEGER,
  tool_calls INTEGER, tool_ms INTEGER,
  files_touched INTEGER, lines_added INTEGER, lines_removed INTEGER,
  api_equivalent_usd REAL     -- estimate only; never displayed as spend
);

CREATE TABLE broker_decision (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  invocation_id TEXT, ts TEXT NOT NULL, verb TEXT NOT NULL,
  args_json TEXT NOT NULL, decision TEXT NOT NULL, reason TEXT,
  policy_rule TEXT, risk_class TEXT, gate_id TEXT, duration_ms INTEGER
);
CREATE INDEX idx_broker_run ON broker_decision(run_id, ts);

CREATE TABLE human_gate (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  ts TEXT NOT NULL, verb TEXT NOT NULL, summary TEXT NOT NULL,
  consequence TEXT, exact_command TEXT, rollback TEXT, evidence_json TEXT,
  status TEXT NOT NULL, resolved_at TEXT, resolved_by TEXT
);

CREATE TABLE context_item (
  id TEXT PRIMARY KEY, packet_hash TEXT NOT NULL, run_id TEXT NOT NULL,
  stage TEXT NOT NULL, source_type TEXT NOT NULL, source TEXT,
  symbol TEXT, git_sha TEXT, trust TEXT NOT NULL, purpose TEXT,
  priority TEXT NOT NULL, tokens INTEGER, content_hash TEXT,
  referenced INTEGER NOT NULL DEFAULT 0    -- set by downstream usage analysis
);
CREATE INDEX idx_context_packet ON context_item(packet_hash);

CREATE TABLE verification_result (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  stage_attempt_id TEXT, check_id TEXT NOT NULL, adapter TEXT NOT NULL,
  status TEXT NOT NULL, exit_code INTEGER, duration_ms INTEGER,
  evidence_path TEXT, summary TEXT, flaky INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL
);

CREATE TABLE finding (
  id TEXT PRIMARY KEY, run_id TEXT NOT NULL REFERENCES run(id),
  reviewer_invocation_id TEXT, severity TEXT NOT NULL, category TEXT NOT NULL,
  claim TEXT NOT NULL, location TEXT, evidence_json TEXT, reproduction TEXT,
  suggested_resolution TEXT, status TEXT NOT NULL,
  adjudication TEXT, adjudicated_by TEXT, fixed_in_attempt TEXT,
  reverified INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL
);

CREATE TABLE memory_record (
  id TEXT PRIMARY KEY, project_id TEXT NOT NULL REFERENCES project(id),
  path TEXT NOT NULL, kind TEXT NOT NULL, title TEXT NOT NULL,
  body TEXT NOT NULL, source_refs_json TEXT, validated_git_sha TEXT,
  status TEXT NOT NULL,               -- active | possibly_stale | retired
  approved_by TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);

CREATE VIRTUAL TABLE memory_fts USING fts5(
  title, body, content='memory_record', content_rowid='rowid'
);
CREATE VIRTUAL TABLE history_fts USING fts5(
  run_title, stage, summary, content=''
);
```

### 4.6 Event taxonomy

`run.created|completed|failed|cancelled` · `risk.assessed|escalated` ·
`stage.started|completed|failed` · `context.discovery.started|compiled|expanded` ·
`routing.decision` · `worker.started|streamed|completed|failed|interrupted` ·
`tool.requested|allowed|denied|completed` · `workspace.created|checkpoint|reconciled|removed` ·
`verification.started|check.completed|completed` · `review.started|finding|completed` ·
`finding.adjudicated` · `human_gate.requested|resolved` · `retry.scheduled` ·
`escalation.triggered` · `quota.pressure_changed` · `memory.promoted`

Every event carries `run_id`, `ts`, `span_id`, `parent_span_id`, and a typed payload. Payload
schemas live in `telemetry/schema.py` and are versioned with the event type name.

---

## 5. Core contracts

All models are Pydantic v2, exported to JSON Schema at build time into `schemas/<version>/`.

### 5.1 Envelope

```python
class ArtifactEnvelope(BaseModel):
    schema_version: str            # "1.0"
    artifact_id: str
    run_id: str
    stage_id: str
    attempt_id: str
    kind: ArtifactKind             # the 9 families below
    producer: Producer             # aidev | worker
    provider: str | None
    model: str | None
    effort: str | None
    workflow_version: str
    prompt_version: str | None
    base_git_sha: str
    workspace_git_sha: str | None
    context_packet_hash: str | None
    created_at: datetime
    content_hash: str
    payload: ArtifactPayload       # discriminated union on `kind`
```

Payload families (D-10): `TaskIntent`, `RiskAssessment`, `Requirements`, `Design`,
`TestSpecification`, `ChangeSet`, `VerificationReport`, `ReviewReport`, `FinalReport`.

`ReviewReport.kind` carries `architecture | security | general | specialist:<dimension>`, which
absorbs the old `ArchitectureReview`. `ChangeSet` + `WorkerExecution` metadata absorbs
`ImplementationResult`. Adjudication lives on `Finding`, not as a separate artifact.

### 5.2 Risk

```python
class RiskDimension(str, Enum):
    security = "security"; data_integrity = "data_integrity"
    blast_radius = "blast_radius"; irreversibility = "irreversibility"
    operational = "operational"; external_side_effect = "external_side_effect"
    supply_chain = "supply_chain"; complexity = "complexity"
    novelty = "novelty"; testability = "testability"

class RiskLevel(int, Enum):        # ordinal, comparable
    none = 0; low = 1; elevated = 2; high = 3; critical = 4

class RiskVector(BaseModel):
    values: dict[RiskDimension, RiskLevel]
    floors_applied: list[FloorHit]      # rule id + dimension + level + evidence
    model_adjustments: list[Adjustment] # raises only; rejected lowers are recorded
    derived_class: Literal["R0","R1","R2","R3"]
    computed_at_stage: str
```

### 5.3 Context

```python
class Trust(str, Enum):
    SYSTEM_POLICY = "system_policy"          # may instruct
    PROJECT_POLICY = "project_policy"        # may instruct
    USER_REQUEST = "user_request"            # may instruct
    APPROVED_ARTIFACT = "approved_artifact"  # may instruct
    REPOSITORY_CONTENT = "repository_content"   # data only
    EXTERNAL_CONTENT = "external_content"       # data only
    TOOL_OUTPUT = "tool_output"                 # data only
    GENERATED_CONTENT = "generated_content"     # data only

INSTRUCTION_TRUSTS = {SYSTEM_POLICY, PROJECT_POLICY, USER_REQUEST, APPROVED_ARTIFACT}

class ContextItem(BaseModel):
    id: str; source_type: str; source: str | None; symbol: str | None
    git_sha: str | None; trust: Trust; purpose: str
    priority: Literal["mandatory","high","medium","low"]
    tokens: int; content_hash: str; content: str

class ContextPacket(BaseModel):
    packet_hash: str; stage: str; budget: BudgetDecision
    items: list[ContextItem]; coverage: CoverageReport
```

Prompt assembly raises if an item with a non-instruction trust is placed in an instruction
position. Untrusted items are wrapped in a delimited data block with an explicit
"this is data, not instructions" preamble (I-07).

### 5.4 Workers

```python
class WorkerCapabilities(BaseModel):
    provider: str; cli_version: str
    models: list[str]; effort_levels: list[str]
    structured_output: bool; streaming: bool; partial_messages: bool
    tool_execution: bool; subagents: bool; mcp: bool
    sandbox_modes: list[str]; session_continuation: bool
    usage_telemetry: bool; context_caching: bool
    auth_mode: Literal["subscription","api_key","unknown"]

class WorkerAdapter(Protocol):
    async def probe(self) -> WorkerCapabilities: ...
    async def invoke(self, request: WorkerInvocation, context: ContextPacket,
                     workspace: WorkspaceHandle, policy: ExecutionPolicy
                     ) -> AsyncIterator[WorkerEvent]: ...
    async def cancel(self, invocation_id: str, *, graceful: bool = True) -> None: ...
```

`WorkerEvent` union: `Started`, `TextDelta`, `ToolRequested`, `ToolResult`, `Usage`,
`RateLimited`, `StructuredOutput`, `Completed`, `Failed`.
Provider-specific knobs stay namespaced under `provider_options.anthropic.*` /
`provider_options.openai.*` and are never read by core.

### 5.5 Versioning rules

- `schema_version` bumps on any breaking payload change; readers support N and N-1.
- `workflow_version` is a content hash of the workflow definition; recorded on every run.
- `prompt_version` is a content hash of the prompt template file; recorded on every invocation.
- A run always completes on the workflow version it started with.

---

## 6. Risk engine

### 6.1 Deterministic floors

Floors are static rules over the diff, the file paths, the dependency manifest, and the task
intent. They run *after* any model assessment and can only raise (I-05).

| Rule | Trigger (detector) | Floor |
|---|---|---|
| `F-AUTH` | Path/symbol match on auth, session, token, permission, role, acl | `security ≥ critical` |
| `F-CRYPTO` | Crypto primitives, key handling, signing | `security ≥ critical` |
| `F-MIGRATION-DESTRUCTIVE` | Migration file with drop/truncate/alter-column-type | `irreversibility ≥ critical`, `data_integrity ≥ high` |
| `F-MIGRATION` | Any schema migration file | `irreversibility ≥ high` |
| `F-PAYMENT` | Payment/charge/refund/billing symbols or SDKs | `external_side_effect ≥ critical` |
| `F-EXTERNAL-SEND` | Mail, SMS, push, webhook dispatch | `external_side_effect ≥ high` |
| `F-NEW-DEP` | New entry in a dependency manifest/lockfile | `supply_chain ≥ elevated` |
| `F-DEP-MAJOR` | Major version bump of an existing dependency | `supply_chain ≥ high` |
| `F-PUBLIC-API` | Change to an exported/public interface or route | `blast_radius ≥ elevated` |
| `F-INFRA` | IaC, CI config, Dockerfile, deployment manifests | `operational ≥ high` |
| `F-CONCURRENCY` | Threading/async primitives, locks, queues | `complexity ≥ high` |
| `F-NO-TESTS` | Touched module has no discoverable tests | `testability ≥ high` |
| `F-UNKNOWN-STACK` | Language/framework with no verification adapter | `novelty ≥ high` |
| `F-BLAST-N` | > N files or > M modules touched (project-configurable) | `blast_radius ≥ elevated` |

Detectors are pure functions with fixture tests. Each floor hit records the matching evidence
(path, line, symbol) so it is auditable and disputable by a human — never by a model.

### 6.2 Derivation

```python
def derive_class(v: RiskVector, policy: Policy) -> str:
    if any(l == CRITICAL for l in v.values.values()):        return "R3"
    if sum(l >= HIGH for l in v.values.values()) >= 2:       return "R3"
    if any(l == HIGH for l in v.values.values()):            return "R2"
    if sum(l >= ELEVATED for l in v.values.values()) >= 2:   return "R2"
    if any(l >= ELEVATED for l in v.values.values()):        return "R1"
    if v.values[COMPLEXITY] >= LOW and touches_code(v):      return "R1"
    return "R0"
    # then: policy.escalations may raise; nothing may lower
```

No averaging, ever (D-12). The thresholds above are the only tunable numbers, and they live in
`policy.yaml` under `risk.thresholds` with tighten-only semantics.

### 6.3 Recompute points

| When | Inputs | Typical effect |
|---|---|---|
| After `DISCOVER` | Task text, localisation results, repo signals | Initial class |
| After `DESIGN` | Planned files, planned dependencies, design artifact | Catches "the plan is bigger than the ask" |
| After `IMPLEMENT` | Actual diff, actual manifests | Catches the wander into auth/payments/migrations |

If the class rises above the planned path, emit `risk.escalated` and return to `CLASSIFY`.

---

## 7. Workspace manager

### 7.1 Layout and naming

- Branch: `aidev/run-<short_id>` created from the resolved base commit.
- Worktree: `~/.aidev/workspaces/<project-id>/run-<short_id>/primary`.
- Scratch: sibling `scratch/`, exported as `TMPDIR` to workers.

### 7.2 Base commit resolution (D-06)

```text
working tree clean  → base = HEAD
working tree dirty  → base = HEAD
                      record run.dirty_base = 1
                      list excluded paths in the run summary
                      tell the user, once, at run start
```

Never `stash`, `commit`, `reset`, `checkout`, or `clean` in the user's checkout. `--include-working-copy`
is a **v1.1** flag that builds a private snapshot commit on a detached ref without touching the
index or working tree; it is not in v1.0 scope.

Refuse to start (with a clear message) when: the repo has an unresolved merge/rebase in progress,
`HEAD` is unborn, or the path is not a git repository.

### 7.3 Checkpoint commits

Inside the run worktree, commit at every stage boundary with a structured message:

```text
aidev: <stage> attempt <n> [run <short_id>]

state: IMPLEMENT
risk: R2
artifacts: <ids>
```

These commits are the rollback unit for repair loops. They are squashed on hand-off (`aidev finish`)
unless the user asks to keep history.

### 7.4 Hand-off and cleanup

- `aidev diff <run>` — full diff against base.
- `aidev apply <run>` — creates a branch in the user's repo (never checks it out) or emits a patch.
- `aidev gc` — removes worktrees for terminal runs older than `retention_days`, keeps artifacts and DB rows.
- Worktree removal always uses `git worktree remove` + `git worktree prune`, never `rm -rf` on a path
  the daemon did not create.

---

## 8. Action Broker and sandboxing

The broker is the single choke point (D-19). Nothing a worker does that touches the world bypasses it.

### 8.1 Verb taxonomy

| Verb | Args | Default |
|---|---|---|
| `fs.read` | path | allow inside worktree + declared read roots |
| `fs.write` | path, bytes | allow inside worktree only |
| `fs.delete` | path | allow inside worktree; deny on protected paths |
| `proc.exec` | argv[], cwd, env_extra | allowlist by program + argument policy |
| `git.read` | subcommand | allow |
| `git.write` | subcommand | allow inside run branch; deny force-push, deny on user branches |
| `net.fetch` | url | deny by default; allowlist per project |
| `pkg.install` | manager, spec | deny → gate; network-scoped, lockfile diff recorded |
| `secret.read` | name | deny (mandatory gate, no policy override) |
| `mcp.call` | server, tool, args | allowlisted servers only; output labelled untrusted |

### 8.2 Decision pipeline

```python
def decide(req: ActionRequest, ctx: RunContext) -> Decision:
    if req.verb in FROZEN_DENY:                     return deny("frozen_invariant")
    args = canonicalise(req.args)                   # realpath, resolve symlinks, reject traversal
    if not within_allowed_roots(args, ctx):         return deny("path_outside_workspace")
    if violates(ctx.policy, req):                   return deny("policy")
    if req.influenced_by_untrusted and req.verb in ELEVATED_VERBS:
        return gate("untrusted_influence")          # provenance-aware escalation
    if req.verb in MANDATORY_GATE_VERBS:            return gate("mandatory")
    if ctx.risk.derived_class == "R3" and req.verb in R3_GATE_VERBS:
        return gate("risk_class")
    return allow()
```

Every decision — allow, deny, gate — is written to `broker_decision` *before* the effect runs.
`influenced_by_untrusted` is carried from the context packet: if the stage's packet contained
untrusted items that reference the target path or symbol, elevated verbs escalate to a gate.

### 8.3 Path canonicalisation rules

Resolve with `os.path.realpath`; reject if the resolved path escapes the allowed root even when
the literal path did not (symlink escape); reject paths containing NUL or control characters;
match both the link and its target for deny rules, and require both to match for allow rules.

### 8.4 Process execution

Prefer `argv` lists (`["git","diff","--stat"]`) over shell strings. Shell is available only for
verbs explicitly marked `shell_required` in project config, and the command is recorded verbatim.

Argument policy is a **prefix allowlist per program with an explicit deny list**, and must account
for the failure modes that make naive prefix matching unsafe:

- Compound commands split on `&&`, `||`, `;`, `|`, `|&`, `&`, and newlines; every subcommand must
  independently pass.
- Strip known wrappers (`timeout`, `time`, `nice`, `nohup`, `stdbuf`, `command`, `builtin`, bare `xargs`)
  before matching.
- Treat environment-runner prefixes (`npx`, `docker exec`, `devbox run`, `mise exec`, `direnv exec`,
  `uv run`, `poetry run`) as **opaque**: they require a rule naming the inner command, not the runner.
- Exec-capable forms (`find -exec`, `find -delete`, `watch`, `setsid`, `flock`, `ionice`) require an
  exact-match rule.
- Check redirection targets as writes.

### 8.5 Environment

```text
ALLOW: PATH, HOME→<scratch>/home, TMPDIR→<scratch>/tmp, LANG, LC_ALL, TZ, TERM=dumb,
       CI=1, project-declared safe vars, provider auth vars only for the adapter that needs them
DENY (never inherited): AWS_*, GCP_*, AZURE_*, GITHUB_TOKEN, GH_TOKEN, GITLAB_TOKEN,
       SSH_AUTH_SOCK, GPG_*, NPM_TOKEN, PYPI_TOKEN, DOCKER_*, KUBECONFIG,
       *_API_KEY, *_SECRET*, *_TOKEN, .env contents, keychain access, browser profile paths
```

Implemented as `env = build_env(policy, adapter)` — the only way a worker process is spawned. There
is no code path that calls `subprocess` with an inherited environment (I-04).

### 8.6 Mandatory human gates (frozen, not policy data — I-09)

Production deployment · production credential access · destructive migration ·
production database write · cloud infrastructure destruction · external spending ·
`git push --force` · package publication/public release · breaking a declared public API ·
weakening a security policy · any combination of network access plus secret access.

Gate presentation contract — the CLI/TUI must render all five fields:

```text
ACTION       what will happen, one line
CONSEQUENCE  what changes in the world, and where
COMMAND      the exact argv or diff hunk
ROLLBACK     the exact command/steps to undo, or "IRREVERSIBLE"
EVIDENCE     verification results and findings supporting the request
```

A gate with no rollback path must say `IRREVERSIBLE` in capitals. Approvals are per-action and
never remembered (no "don't ask again") for the frozen list.

### 8.7 Sandbox strategy (D-20)

v1 relies on **provider-native sandboxing plus broker policy**, because both worker CLIs now ship
OS-level isolation (Codex uses Seatbelt on macOS, Bubblewrap on Linux, restricted tokens on Windows;
Claude Code exposes filesystem/network sandbox settings for its Bash tool). Rebuilding that in M0
would be duplicated effort with worse coverage.

```python
class SandboxBackend(Protocol):
    def available(self) -> bool: ...
    def wrap(self, argv: list[str], profile: SandboxProfile) -> list[str]: ...
```

| Backend | Status |
|---|---|
| `ProviderNativeSandbox` | **v1** — configure the CLI's own sandbox; verify via its reported config |
| `NoSandbox` | v1, explicit opt-in, loud warning, denied for R2/R3 |
| `BubblewrapSandbox` | M9 (Linux) |
| `RootlessPodmanSandbox` | M9 (strict profile) |
| `SeatbeltSandbox` | M9 (macOS, `sandbox-exec` profile for non-CLI subprocesses) |
| `GVisorSandbox` / `AppleContainerSandbox` | Deferred |

Role profiles applied to every invocation:

| Role | Filesystem | Network | Secrets | Tools |
|---|---|---|---|---|
| ARCHITECT | read-only | deny | deny | semantic/search only |
| IMPLEMENTER | run worktree rw | deny | deny | edit + scoped exec |
| REVIEWER | read-only | deny | deny | read/search only |
| VERIFIER | worktree rw | deny unless dependency restore is declared | synthetic only | project commands |
| PRODUCTION | — | — | — | denied; gate only |

---

## 9. Worker adapters

This section is deliberately concrete: it is where a wrong assumption costs the most. **Flags and
event shapes change between CLI releases — S-01 (§22) re-verifies them against the installed
version before M3 starts, and the capability probe (§9.5) enforces it at runtime.**

### 9.1 Claude Code adapter

Base invocation for a non-interactive, machine-parsed run:

```bash
claude -p "<prompt>" \
  --output-format stream-json --verbose --include-partial-messages \
  --permission-mode dontAsk \
  --allowedTools "<role-specific list>" \
  --disallowedTools "<role-specific denies>" \
  --setting-sources user \
  --settings '{"disableAllHooks": true, ...aidev policy...}' \
  --mcp-config <aidev-managed.json> --strict-mcp-config \
  --model <from registry> \
  --max-turns <bounded> \
  --add-dir <extra read roots, if any>
```

Structured artifacts use JSON rather than the stream:

```bash
claude -p "<prompt>" --output-format json --json-schema "$(cat schemas/1.0/Design.json)"
# → response.structured_output holds the parsed object; response also carries session_id + usage
```

| Need | Mechanism |
|---|---|
| Streaming events | `--output-format stream-json` (requires `--verbose`); add `--include-partial-messages` for token deltas |
| Structured output | `--output-format json` + `--json-schema`; read `structured_output` |
| Session continuation | capture `session_id` from the first response, then `--resume <id>` |
| Permission posture | `--permission-mode dontAsk` = auto-deny anything not pre-approved — the correct default for an orchestrator |
| Read-only roles | `plan` mode or a `dontAsk` allowlist of read tools only |
| Capability/feature detection | `system/init` event: `capabilities`, `mcp_servers`, `mcp_server_errors`, `plugins`, `plugin_errors` |
| Rate-limit signal | `system` event with `subtype=api_retry` and `error=rate_limit` → feeds quota pressure (§9.6) |
| Usage | `result` message and `--output-format json` payload |
| Cancellation | **SIGINT ends the current turn cleanly; SIGTERM leaves the turn unfinished and exits 143.** Adapter sends SIGINT first, waits `grace_ms`, then SIGTERM, then SIGKILL |
| Background tasks | Background bash is killed shortly after the final result; background subagents are waited on with a capped ceiling — set the cap explicitly rather than relying on the default |
| stdin | Piped stdin is size-capped; write large context to a file in the worktree and reference the path (aidev does this always) |

**Deliberately never used:** `--dangerously-skip-permissions`, `bypassPermissions` mode, and any
flag that disables the permission system. If a task appears to need them, that is a policy question
for the human, not an adapter option.

### 9.2 Codex adapter

```bash
codex exec "<prompt>" \
  --json \
  --sandbox read-only|workspace-write \
  --ask-for-approval never \
  --ignore-user-config \
  --ignore-rules \
  --skip-git-repo-check \
  --cd <run worktree> \
  --model <from registry> \
  -c reasoning.effort=<low|medium|high> \
  --output-schema schemas/1.0/<Artifact>.json \
  -o <evidence path>
```

| Need | Mechanism |
|---|---|
| Event stream | `--json` emits JSONL events to stdout; progress goes to stderr, final message to stdout |
| Structured output | `--output-schema <file>` |
| Isolation | `-s/--sandbox read-only` for architects/reviewers, `workspace-write` for implementers. **Never `danger-full-access`.** |
| Approvals | `--ask-for-approval never` combined with a restrictive sandbox — the sandbox is the boundary, not the prompt |
| Config hygiene | `--ignore-user-config` (skip `$CODEX_HOME/config.toml`) and `--ignore-rules` (skip user/project execpolicy rules) |
| Extra writable path | `--add-dir <scratch>` — writable set is otherwise workdir, `/tmp`, `$TMPDIR` |
| Session continuation | `codex exec resume --last` / `resume <SESSION_ID>` |
| Shell control | `-c features.shell_tool=false` for pure-analysis roles |

**`--full-auto` is deprecated and removed in recent versions — never emit it.** Use explicit
`--sandbox` + `--ask-for-approval`.

### 9.3 Adapter responsibilities (both)

1. Build argv from `(role, capability, model registry, policy, workspace)` — never from model output.
2. Write the prompt and context to files in the run worktree; pass paths, not megabytes of stdin.
3. Parse the event stream into `WorkerEvent`s; unknown event types are logged and ignored, never fatal.
4. Map every tool/action the worker reports into a `broker_decision` record.
5. Extract usage into the `usage` table; mark provider cost figures as `api_equivalent_usd`.
6. Enforce wall-clock and turn limits; on breach, cancel per §9.1 semantics.
7. Never parse free-form prose where a structured mode exists.
8. Record `cli_version` on every invocation, so a behaviour change is attributable.

### 9.4 Untrusted-repository hardening (I-10)

This is the sharpest edge in the whole system and the research report did not capture it:

> In a non-interactive `-p`/SDK session, Claude Code shows no workspace-trust dialog. Hooks in the
> project's settings files, the settings `env` block, helper commands, and skill-declared tools are
> **used**, and servers in the project's `.mcp.json` are **connected without asking**. Codex likewise
> reads user and project config and execpolicy rules unless told not to.

So opening a worktree of an untrusted repository with a worker CLI is, by default, arbitrary code
execution from repository content. aidev must close this on every invocation:

| Threat | Claude Code | Codex |
|---|---|---|
| Project hooks execute | `--setting-sources user` **and** `--settings '{"disableAllHooks":true}'` | `--ignore-rules` |
| Project `.mcp.json` auto-connects | `--strict-mcp-config` with an aidev-managed config | `--ignore-user-config` + explicit MCP config |
| Project settings grant tools | `--setting-sources user`; deny rules from aidev's `--settings` win (deny precedes allow at every scope) | sandbox + `--ask-for-approval never` |
| Repo-supplied skills/subagents | excluded by `--setting-sources user` | `--ignore-rules` |

Additionally, before the first worker starts in a run worktree, the workspace manager **quarantines**
repo-supplied agent configuration: `.claude/`, `.mcp.json`, `.codex/`, `AGENTS.md`, `CLAUDE.md`
are moved to `evidence/quarantined-config/` inside the run directory, recorded as a
`workspace.quarantine` event, and offered to the user as context *data* (trust
`REPOSITORY_CONTENT`) rather than as executable configuration. Projects may opt specific files back
in via `.aidev/project.toml` — an explicit, local, human act (D-23).

Note the tension to keep in mind: Claude Code's `--bare` mode is the strongest isolation switch, but
**bare mode does not use subscription login** — it requires an API key. Since v1 is subscription-first
(D-07), aidev uses the flag combination above rather than `--bare`, and documents `--bare` as the
right choice for anyone running in API-key mode.

### 9.5 Capability probe

At daemon start and whenever a CLI version changes:

1. Run `<cli> --version`; record it.
2. Run the adapter's smoke invocation (a trivial prompt, structured output, read-only sandbox).
3. Parse `system/init` (Claude) or the initial JSONL events (Codex) for supported features.
4. Persist `WorkerCapabilities`; a routing request for an unsupported capability fails loudly at
   planning time rather than silently mid-run.
5. If a required flag is missing from `--help`, mark the adapter `degraded` and route away from it.

### 9.6 Quota pressure (D-30)

Ordinal signal computed from: observed tokens per rolling window, count and recency of
rate-limit/retry events (`api_retry` with `error=rate_limit`), provider-reported usage where a CLI
exposes it, and time since the last reset if known.

```text
LOW      → no change
MEDIUM   → prefer standard over strong tier for R0/R1; skip optional secondary analysis
HIGH     → serialise parallel work; skip optional review on R1; lower effort where no floor applies
CRITICAL → queue new runs; finish in-flight runs; notify the user
```

Never changed by quota: R3 required verification, required security review, human gates, required
migration validation. If quota pressure would block a *required* step, the run pauses and asks —
it does not silently downgrade (D-30).

### 9.7 Model registry

`~/.aidev/models.toml`, versioned, hot-reloadable:

```toml
registry_version = "2026-08-22"

[capabilities."coding.standard"]
primary   = { provider = "codex",  model = "<mid-tier>",  effort = "medium" }
fallback  = { provider = "claude", model = "<mid-tier>",  effort = "medium" }

[capabilities."reasoning.frontier"]
primary   = { provider = "claude", model = "<top-tier>",  effort = "high" }

[floors]
"security_critical" = { min_capability = "reasoning.frontier", min_effort = "high" }
```

Capabilities: `reasoning.frontier`, `reasoning.standard`, `coding.strong`, `coding.standard`,
`coding.fast`, `review.standard`, `review.critical`, `debug.frontier`, `mechanical.fast`.

**Concrete model names are intentionally absent from this plan.** They are filled in at install
time by S-02 (§22) against whatever each provider currently ships. Workflows reference capabilities
only (D-08).

### 9.8 Effort policy

```text
base_effort = capability default
+1 level if: retrieval uncertainty high · novelty high · previous attempt failed
             · reviewers disagree · runtime evidence ambiguous
never below: the risk floor for the touched dimension
max effort:  narrow escalation only — R3 adjudication, hard-bug diagnosis, security review
```

Never route on a model's self-reported confidence.

---

## 10. Context compiler

### 10.1 Providers

`SerenaProvider` (symbols, references, definitions) · `GitProvider` (history, blame, churn) ·
`ArtifactProvider` (prior stage outputs) · `MemoryProvider` (canonical Markdown) ·
`FilesystemProvider` (exact file/range reads) · `RepomixProvider` (optional structural snapshot) ·
`FallbackSearchProvider` (ripgrep + FTS5).

Every provider implements `available()`, and the compiler degrades rather than fails: if Serena
does not support the language, the compiler falls back to search + structural heuristics and records
`context.provider_degraded`.

### 10.2 Progressive disclosure loop

```python
packet = Packet(budget=initial_budget(stage, capability, risk))
packet += mandatory_items(task, policy, acceptance_criteria, target_symbols)
while True:
    coverage = assess_coverage(packet, requirements)
    if coverage.sufficient or packet.exhausted(): break
    candidates = rank(next_layer(packet))     # symbols → refs → deps → tests → neighbours
    best = candidates.top()
    if best.marginal_relevance < threshold: break
    packet += best
```

**Stop criterion is coverage, not tokens** (D-15): "every acceptance criterion and every modified
symbol's direct dependencies are represented, and the next candidate adds little" — not "we reached
40k tokens".

Layer order: task → repo map / memory → target symbols → references and dependencies → exact
implementation source → tests and evidence → extra retrieval only on residual uncertainty.

### 10.3 Priority tiers

| Tier | Contents |
|---|---|
| MANDATORY | safety policy, acceptance criteria, approved constraints, directly modified code |
| HIGH | callers/callees, relevant tests, security invariants, data contracts |
| MEDIUM | neighbouring implementations, git history, conventions |
| LOW | architecture summaries, analogous historical runs |

Within a tier rank by semantic relevance, dependency proximity, test relationship, architectural
relevance, recency. Penalise staleness, duplication, token size, retrieval uncertainty.

### 10.4 Budget

```text
budget = base(stage, capability) × risk_factor × complexity_factor + uncertainty_allowance
```

Base values start as informed guesses and are **replaced by measured p50/p90 of successful runs**
after M8. They are config, not constants in code.

### 10.5 Packet hygiene

- Deduplicate by content hash and by symbol identity before assembly.
- Fresh packet per stage; never carry a conversation forward across stages.
- Stable prefix ordering (policy → task → constraints → evidence) for cache friendliness.
- Record `packet_hash` on every artifact and invocation so any output is traceable to its inputs.
- Mark items `referenced` post-hoc from tool reads and diff overlap → feeds context-waste metrics.

### 10.6 Context metrics

Evidence coverage · retrieval precision · missed-dependency rate · duplicate ratio · stale ratio ·
exact-code ratio · structural-to-full-file ratio · escalation rate · context waste ·
context tokens per verified stage.

---

## 11. Memory and knowledge

Canonical memory is Markdown in `<project>/.aidev/memory/`, committed to the project repo, indexed
in FTS5 (D-18).

**Eligible for promotion:** architecture invariants, domain vocabulary, security invariants, data
ownership, API guarantees, testing rules, supported commands, deployment constraints, ADR summaries,
known dangerous assumptions.

**Never promoted automatically:** unverified model conclusions, reviewer speculation, raw external
text, secrets, credentials, transient runtime errors, user-private content.

Promotion pipeline:

```text
successful run → candidate extraction → evidence references (file+symbol+SHA)
              → contradiction & staleness check against existing records
              → human approval (mandatory for architecture and security kinds)
              → canonical memory + FTS index
```

Every record stores `source_refs` and `validated_git_sha`. When a referenced object changes, the
record is marked `possibly_stale` — never silently deleted and never silently trusted. Stale records
are still retrievable, but enter context with a staleness marker and reduced priority.

---

## 12. Verification engine

### 12.1 Interface

```python
class VerificationAdapter(Protocol):
    name: str
    def detect(self, project: ProjectContext) -> bool: ...
    def plan(self, change: ChangeSet, risk: RiskVector) -> VerificationPlan: ...
    async def execute(self, check: Check, ws: WorkspaceHandle) -> VerificationResult: ...
```

v1 adapters (D-40): `python` (ruff/mypy/pytest), `node` (eslint/tsc/vitest|jest),
`generic` (commands declared in `.aidev/project.toml`), plus cross-cutting
`gitleaks`, `osv-scanner`, `semgrep`.

Detection is cached per project and invalidated on manifest change.

### 12.2 Risk-adaptive check matrix (D-24)

| Check | R0 | R1 | R2 | R3 |
|---|:--:|:--:|:--:|:--:|
| Targeted existing tests | if applicable | ✓ | ✓ | ✓ |
| Format / lint | if code | ✓ | ✓ | ✓ |
| Type / compile / build | if code | ✓ | ✓ | ✓ |
| Full relevant unit suite | — | ✓ | ✓ | ✓ |
| Integration / contract | — | if relevant | ✓ | ✓ |
| Secret scan on diff | ✓ | ✓ | ✓ | ✓ |
| Dependency scan | on dep change | on dep change | ✓ when affected | ✓ |
| SAST (Semgrep) | — | optional | risk-triggered | ✓ security-sensitive |
| Property-based | — | — | risk-triggered | invariant paths |
| Fuzzing | — | — | parser/security paths | risk-triggered |
| Race detector | — | — | concurrency | concurrency |
| Migration dry-run | — | — | schema changes | mandatory |
| Mutation testing | — | — | selected modules | selected modules |
| Performance | — | — | perf-sensitive | perf/availability-sensitive |

### 12.3 Evidence

Every check writes stdout/stderr, exit code, duration, and machine-readable output (JUnit XML,
SARIF, JSON) to `run/evidence/<check_id>/`, referenced by `verification_result.evidence_path`.
A `VerificationReport` artifact aggregates them. **`READY` reads this table, never a model's
claim that tests pass (I-06).**

### 12.4 Flaky handling

A failing check is re-run once on the unchanged tree. Pass-then-fail or fail-then-pass marks
`flaky=1`, does not count toward the repair budget, and surfaces in the run summary. Three
consecutive flaky observations for the same check id raise a persistent project warning.

### 12.5 Test generation policy (D-25, D-26)

Independent test/acceptance plan is written by a different context than the implementer. The builder
implements code **and** executable tests. The reviewer identifies missing cases. For R3, independent
executable oracle tests are written for objectively specifiable behaviour: authorization matrices,
idempotency, data invariants, destructive operations. All generated tests are executed; a test that
does not run is not evidence.

---

## 13. Review and adjudication

### 13.1 Reviewer packet

Include: original task, acceptance criteria, approved design constraints, risk vector,
security/data invariants, final diff, relevant surrounding source, test plan, verification evidence.

Exclude by default: builder discussion, builder self-evaluation, builder rationalisation, failed
internal attempts. These remain retrievable as evidence on request.

### 13.2 Levels by risk (D-27)

| Class | Review |
|---|---|
| R0 | none for genuinely mechanical change |
| R1 | one fresh-context general reviewer |
| R2 | one strong reviewer + specialist for the triggered dimension only |
| R3 | strong general reviewer + relevant specialist + independent second-model confirmation for BLOCKER/HIGH findings and critical invariants |

Specialists are triggered by risk dimension, not run by default: security, data integrity,
concurrency, performance, API compatibility, migration.

Provider diversity is preferred for R2/R3 where available, but the enforced property is **context
independence** (D-29).

### 13.3 Finding lifecycle (D-28)

```text
PROPOSED → VALIDATED | REJECTED | UNCERTAIN → FIXED → REVERIFIED
```

Adjudication rules:

- A finding with reproducible evidence (failing test, scanner hit, exploitable path) → `VALIDATED`.
- A finding contradicted by executed evidence → `REJECTED`, with the contradicting evidence stored.
- `UNCERTAIN` findings for R3 escalate to an independent adjudicator; for R0–R2 they are recorded
  and surfaced to the human but do not block.
- **No auto-fix of unadjudicated findings.** Only `VALIDATED` findings enter the repair loop.
- Every fix must be re-verified before `REVIEWED → READY`.

### 13.4 Hard-bug workflow

Diagnosis is read-only and parallel; patching during diagnosis is prohibited:

```text
evidence packet → two independent read-only diagnoses (different providers where possible)
   → hypothesis comparison → targeted experiments → reproduced root cause
   → regression test (must fail before the fix) → minimal fix → verification → review
```

The regression test must be demonstrated failing on the pre-fix tree; a test that never failed is
not a regression test.

---

## 14. Observability and accounting

### 14.1 Spans

```text
run
├── discover ├── risk ├── design (context.compile, worker.invoke)
├── challenge (R2/R3) ├── implement (context.compile, worker.invoke, tool.*)
├── verify (check spans, parallel) └── review (reviewer spans, adjudication)
```

Internal schema is authoritative; the OTel exporter is an optional mapping layer (D-31).

### 14.2 Accounting semantics (D-33)

```text
ACTUAL PAYMENT MODEL   subscription plans
OBSERVED USAGE         tokens, sessions, rate-limit events, plan-pressure signals
API-EQUIVALENT COST    hypothetical list-price comparison, always labelled
```

Provider-reported dollar figures are client-side estimates against list prices and can differ from
any actual bill. The UI never renders "this task cost $X" under a subscription; it renders
"≈$X at API list prices".

### 14.3 Logging policy (D-32)

```text
ON  : metadata, token stats, tool metadata, context item ids, decisions, timings
OFF : full prompts, full model outputs (opt-in, stored as local artifacts only)
ALWAYS REDACTED: tool output, environment values
NEVER LOGGED   : secrets, credentials, tokens
```

Redaction runs on write, not on display, with a shared redactor and a test corpus of known secret
shapes.

### 14.4 Metrics

**Leading quality:** acceptance-criteria coverage, deterministic verification rate, first-pass
verification rate, BLOCKER/HIGH finding rate, repair-loop count, risk reclassification rate, policy
denial rate, missed-dependency rate.

**Lagging quality:** post-merge defects, hotfixes, reverts, security issues, incidents,
performance regressions. Recorded via `aidev outcome <run> --defect|--revert|--clean`, which is the
only honest source of ground truth.

**Efficiency:** time to READY, model-active time, verification time, control-plane overhead, tokens
per verified task by class, context tokens per successful stage, cache-hit ratio, escalation rate.

Objective: `minimize(time_to_verified_success + token_use) subject to (quality ≥ threshold, required
gates preserved)`. Never collapse quality and cost into one score.

---

## 15. Evaluation harness (D-34)

### 15.1 Corpus

≥30 tasks for v1.0, drawn from real project history, covering: small bug, cross-file feature, API
change, frontend behaviour, migration, authorization, dependency update, concurrency bug,
performance regression, large refactor, security vulnerability.

Task definition:

```yaml
id: auth-role-check-001
repo: fixtures/repo-a
base_commit: 9f2c1ab
request: "Editors should not be able to delete published posts."
hidden_tests: tests/hidden/test_auth_matrix.py
hidden_invariants: tests/hidden/test_no_privilege_escalation.py
expected_risk_dimensions: [security, blast_radius]
forbidden_behaviors:
  - modifies test assertions
  - adds a dependency
  - touches migrations
budget: { max_wall_s: 900 }
```

Hidden tests are never present in the worktree and never visible to any worker.

### 15.2 Runner

`aidev eval run --workflows A,B --tasks all --repeats 3` executes paired workflows over the same
task set, in isolated worktrees, with a fixed model registry version, and writes one row per
(task, workflow, repeat).

### 15.3 Statistics

- Binary success → beta-binomial credible intervals; report the interval, not the point estimate.
- Token/time → bootstrap paired differences on the same tasks.
- Post-merge failures → tracked individually and conservatively; never averaged away.
- **Never loosen a policy on the basis of a handful of successes.**

### 15.4 Change gate

```text
analytics → recommendation → offline eval → paired quality comparison
         → human approval → new workflow version → canary on low-risk tasks only
```

A workflow, prompt, routing, or effort change ships only with paired evidence that quality did not
regress. This is the enforcement mechanism for "evidence before optimisation".

---

## 16. Failure taxonomy and retry policy

Blind retries burn quota without new evidence. Every failure is classified, and the class determines
the action.

| Class | Detection | Action | Max attempts |
|---|---|---|---|
| `provider_rate_limit` | retry event / 429 | backoff with jitter; raise quota pressure | 5 |
| `provider_transient` | 5xx, connection reset | backoff | 3 |
| `provider_auth` | auth error category | stop run, tell the user how to re-auth | 0 |
| `worker_timeout` | wall clock exceeded | cancel (SIGINT→SIGTERM), retry once at higher effort | 1 |
| `schema_invalid` | structured output fails validation | one repair turn with the validation error, then fail stage | 1 |
| `verification_failed` | check exit non-zero | repair loop with failing evidence in context | `max_repairs` (default 3) |
| `verification_flaky` | inconsistent re-run | re-run once; does not consume repair budget | — |
| `policy_denied` | broker deny | do not retry; re-plan or gate | 0 |
| `gate_rejected` | human said no | stop stage; record reason as context for re-plan | 0 |
| `workspace_conflict` | worktree/base mismatch | reconcile to checkpoint; if impossible, fail | 1 |
| `context_insufficient` | coverage never reached | expand retrieval once, then escalate to human | 1 |
| `tool_unavailable` | adapter/binary missing | degrade the plan and record; never silently skip a required check | 0 |
| `internal_invariant` | assertion failure in core | fail loudly, preserve state, never auto-retry | 0 |

Rule: **a retry must change something** — more evidence, higher effort, different capability, or a
narrower scope. Repeating an identical invocation is a bug, and a test asserts that consecutive
attempts differ in at least one of those dimensions.

---

## 17. Build plan

Ten milestones. Each is shippable, each has binary exit criteria, and each keeps the vertical slice
running. Sizes are relative (S ≈ days, M ≈ 1–2 weeks, L ≈ 2–4 weeks at single-developer pace).

### M0 — Skeleton and vertical slice · **L** · depends on: nothing

**Goal:** a complete R0 run, end to end, with fake workers. This is the milestone that proves the
architecture; everything after it is depth.

Deliverables: package scaffold and `uv` packaging · SQLite store with migrations and pragmas ·
event log and content-addressed artifact store · Pydantic contracts for the 9 payload families ·
FSM with the full transition table and guards · stage attempts, checkpoints, transactional commit ·
`FakeWorker` producing deterministic scripted artifacts · daemon on a Unix socket · `aidev run`,
`status`, `events`, `show`, `cancel` · crash-recovery loop.

Exit criteria:
- [ ] `aidev run "rename X to Y"` reaches `READY` with the fake worker and produces all artifacts.
- [ ] `kill -9` the daemon at each of the 7 stage boundaries; each restart resumes correctly, with
      no duplicated artifacts and no lost events. Automated as a parametrised test.
- [ ] `aidev events <run>` shows a complete ordered trace.
- [ ] Every artifact validates against its exported JSON Schema.
- [ ] No component other than the daemon holds a write connection to the DB (I-02 test).

### M1 — Workspace manager · **M** · depends on: M0

Deliverables: worktree create/remove/prune · branch naming · base-commit resolution incl. dirty-tree
policy · checkpoint commits · reconciliation on resume · quarantine of repo-supplied agent config
(§9.4) · `aidev diff|apply|gc`.

Exit criteria:
- [ ] A run on a dirty checkout completes without any change to the user's working tree or index,
      verified by comparing `git status --porcelain` and file mtimes before/after.
- [ ] Worktree reconciliation restores the exact checkpoint SHA after an injected divergence.
- [ ] `.claude/`, `.mcp.json`, `.codex/`, `AGENTS.md` in a fixture repo are quarantined and recorded.
- [ ] `aidev gc` removes worktrees without touching artifacts or DB history.

### M2 — Action Broker, policy, gates · **L** · depends on: M1

Deliverables: verb taxonomy and request/decision types · decision pipeline · path canonicalisation
(incl. symlink escape tests) · argv policy with compound/wrapper/runner handling · env builder ·
network default-deny · frozen mandatory-gate list · gate presentation contract and resolution flow ·
policy loader with tighten-only merge.

Exit criteria:
- [ ] A red-team fixture suite of ≥25 escape attempts (symlink out, `../` traversal, `env` wrapper,
      `npx` runner, compound `&&`, redirect target, `find -exec`, background `&`) is fully denied.
- [ ] `build_env()` unit test asserts the exact allowed keys; grep test proves no other subprocess
      call site exists.
- [ ] Every mandatory gate verb triggers a gate that renders all five fields.
- [ ] A project policy that attempts to weaken a frozen invariant is rejected at load with a clear error.

### M3 — Real worker adapters · **L** · depends on: M2, S-01, S-02

Deliverables: `WorkerAdapter` base · `ClaudeCliAdapter` · `CodexCliAdapter` · capability probe ·
stream parsers · structured-output path · session continuation · cancellation semantics ·
usage extraction · model registry loader · hardening flag matrix (§9.4).

Exit criteria:
- [ ] Both adapters complete a real R0 task end to end on a fixture repo.
- [ ] Cancellation test: SIGINT path ends the turn and records usage; SIGTERM fallback exits cleanly;
      no orphan processes remain (checked by pgrep in the test teardown).
- [ ] A fixture repo containing a malicious hook and a malicious `.mcp.json` produces **zero**
      execution of either, proven by a canary file that is never created.
- [ ] Unknown/unsupported event types in the stream do not crash the run.
- [ ] Adapter reports `degraded` when a required flag is absent from the installed CLI.

### M4 — Verification engine · **M** · depends on: M3

Deliverables: adapter interface · python/node/generic adapters · gitleaks, osv-scanner, semgrep
integrations · risk→check matrix · evidence capture · flaky handling · `VerificationReport`.

Exit criteria:
- [ ] `READY` is unreachable without a stored passing `VerificationReport` (I-06 test).
- [ ] Repair loop consumes failing-check evidence and terminates at `max_repairs`.
- [ ] Evidence files exist for every executed check and are referenced from the DB.
- [ ] A project with no detectable adapter falls back to `generic` or fails loudly — never silently passes.

### M5 — Risk engine and routing · **M** · depends on: M4

Deliverables: 10-dimension vector · all floor detectors with fixtures · derivation · three recompute
points · escalation transition · capability router · effort policy · quota pressure signal.

Exit criteria:
- [ ] Each floor rule has a positive and a negative fixture test.
- [ ] A model attempt to lower a floor is rejected and recorded (I-05 test).
- [ ] A run that drifts into auth code during IMPLEMENT escalates and re-plans.
- [ ] Quota pressure at CRITICAL never removes a required verification or gate.

### M6 — Context compiler · **L** · depends on: M5

Deliverables: provider interface and all v1 providers · progressive disclosure loop · trust and
provenance labelling · prompt assembly with untrusted-data framing · dedup and hashing ·
adaptive budget · coverage assessment · Markdown memory + FTS5 + promotion pipeline ·
context metrics collection.

Exit criteria:
- [ ] Prompt assembly refuses to place a non-instruction trust level in an instruction position (I-07).
- [ ] An injected instruction inside a repository comment does not change worker behaviour in a
      dedicated fixture, and any elevated action it induces is gated by provenance escalation.
- [ ] Serena unavailable → run still completes via fallback, with `context.provider_degraded` recorded.
- [ ] Token use on the fixture corpus drops measurably versus the M5 whole-file baseline.
- [ ] Memory promotion requires human approval for architecture/security kinds.

### M7 — Review and adjudication · **M** · depends on: M6

Deliverables: reviewer packet builder with exclusion rules · review levels by class · specialist
triggers · finding model and lifecycle · adjudication rules · repair integration · re-verification ·
hard-bug workflow.

Exit criteria:
- [ ] Reviewer context provably excludes builder reasoning (packet inspection test).
- [ ] No fix is applied from an unadjudicated finding.
- [ ] Every applied fix triggers re-verification before `READY`.
- [ ] Hard-bug workflow refuses to patch during the diagnosis phase and requires a failing
      regression test before the fix.

### M8 — Observability and evaluation · **L** · depends on: M7

Deliverables: TUI with live events · local dashboard · redaction · usage/cost semantics ·
OTel exporter (optional) · eval corpus (≥30 tasks) · eval runner · paired statistics · baseline
measurement of every metric in §14.4 · initial p50/p95 SLOs derived from that baseline.

Exit criteria:
- [ ] Baseline report exists for the full corpus on the default workflow.
- [ ] Two workflows can be compared with paired statistics and credible intervals.
- [ ] A secret-shaped string in tool output never appears in logs (redaction corpus test).
- [ ] Dashboard queries stay interactive on a database with ≥1000 synthetic runs.

**From here on, D-34 is active: no routing/prompt/effort/gate change ships without eval evidence.**

### M9 — Hardening and optimisation · **L** · depends on: M8

Each item is individually gated by M8 evidence:

- Sandbox backends: bubblewrap (Linux), rootless podman, `sandbox-exec` (macOS) for non-CLI subprocesses.
- Parallel DAG executor inside `IMPLEMENT`, with predicted read/write sets: overlap → serialise,
  disjoint → isolated worktrees, optimistic merge only after verification.
- Token optimisation P0 set: symbol-level retrieval, progressive retrieval, dedup, fresh stage
  contexts, stable cache-friendly prefixes, warm Serena/LSP index, tier and effort routing.
- DuckDB analytics over exported Parquet.
- Repomix integration for overview packets.

Exit criteria:
- [ ] Every shipped optimisation has a paired eval showing no quality regression.
- [ ] Parallel execution produces no semantic merge conflicts on the concurrency fixtures.
- [ ] Strict sandbox profile is available and enforced for R3.

### 17.1 Milestone dependency graph

```text
M0 ──► M1 ──► M2 ──► M3 ──► M4 ──► M5 ──► M6 ──► M7 ──► M8 ──► M9
             (S-01, S-02 must complete before M3)
```

Do not reorder. In particular: the broker before real workers (never run a real model without the
boundary), verification before risk-driven routing (routing decisions need evidence to be worth
anything), and evaluation before optimisation (D-34).

---

## 18. Testing strategy

| Level | Scope | Notes |
|---|---|---|
| Unit | Pure functions: floors, canonicalisation, argv policy, derivation, budget, redaction | Fast, exhaustive fixtures |
| Contract | Every artifact against exported JSON Schema, both schema versions | Golden files |
| FSM | Every transition, every guard, every illegal transition | Property test over random event sequences |
| Crash | Injected `kill -9` at every stage boundary and mid-worker | Parametrised, runs in CI |
| Adapter | Recorded CLI event streams replayed offline | Record real streams once; replay forever |
| Red-team | Escape attempts, injected hooks, malicious `.mcp.json`, prompt injection in comments | Canary-file assertions |
| Integration | Full runs on fixture repos with `FakeWorker` | Deterministic, no network |
| Live smoke | Small set of real-provider runs | Manual/nightly, quota-aware |
| Eval | The M8 corpus | Not CI; run on demand |

Test doubles: `FakeWorker` is a first-class component, not a mock — it reads a YAML script of events
and is used by every integration test. Any behaviour that only works with a real provider is a
design smell.

---

## 19. Configuration

`~/.aidev/config.toml`:

```toml
[daemon]
socket = "~/.aidev/aidev.sock"
log_level = "info"

[workers]
default_provider_order = ["claude", "codex"]
wall_clock_limit_s = 1800
max_turns = 40

[limits]
max_repairs = 3
max_parallel_runs = 1

[logging]
store_prompts = false
store_model_output = false

[telemetry]
otel_enabled = false
```

`<project>/.aidev/project.toml`:

```toml
[project]
name = "acme-api"
languages = ["python", "typescript"]

[verify]
adapters = ["python", "node"]
generic_commands = { build = "make build", test = "make test" }

[risk]
blast_radius_file_threshold = 15

[context]
read_roots = ["src", "tests", "docs"]
exclude = ["vendor/**", "**/generated/**"]

[allow]
network_domains = []             # empty = deny all
agent_config_files = []          # opt specific quarantined files back in, explicitly
```

`policy.yaml` (user and project; tighten-only merge):

```yaml
risk:
  thresholds: { r3_critical_count: 1, r3_high_count: 2 }
gates:
  additional: ["Bash(kubectl *)", "git.write(push)"]
verbs:
  deny: ["net.fetch", "pkg.install"]
```

---

## 20. CLI surface

| Command | Purpose |
|---|---|
| `aidev run "<task>"` | Start a run (`--class`, `--dry-run`, `--attach`) |
| `aidev status [run]` | Current state, stage, risk, gates pending |
| `aidev events <run>` | Ordered event trace (`--follow`, `--type`) |
| `aidev show <run> <artifact>` | Render a stored artifact |
| `aidev diff <run>` | Diff against base |
| `aidev apply <run>` | Create branch or emit patch in the user's repo |
| `aidev approve <gate-id>` / `deny` | Resolve a human gate |
| `aidev cancel <run>` | Graceful cancel |
| `aidev resume <run>` | Explicit resume after failure |
| `aidev outcome <run> --clean\|--defect\|--revert` | Record ground truth for lagging metrics |
| `aidev memory list\|show\|approve` | Canonical knowledge management |
| `aidev doctor` | Probe CLIs, tools, sandbox availability, DB health |
| `aidev eval run\|report` | Evaluation harness |
| `aidev gc` | Workspace cleanup |
| `aidevd` | Daemon (usually auto-started by the CLI) |

`aidev doctor` is the first command a new user runs and the first thing to check when anything is
odd; it prints the capability probe results, adapter status, and any degraded subsystem.

---

## 21. Project risks

| Risk | Mitigation |
|---|---|
| Provider CLI flags/streams change under us | Capability probe + `cli_version` on every invocation + recorded-stream adapter tests + S-01 re-run at each milestone |
| Scope creep back toward the full conceptual product | Appendix B is a contract; adding to v1 requires removing something |
| M0 taken as "boring plumbing" and rushed | M0's crash tests are the hardest tests in the project; they are the exit criteria |
| Security work deferred "until it works" | M2 precedes M3 by construction: no real model runs before the broker exists |
| Optimising on vibes | D-34 + M8 gate |
| Building a second agent framework by accident | I-01 and the rule that no guard may call a model |
| Single-developer bandwidth | Milestones are independently shippable; the tool is useful from M4 onward |

---

## 22. Verify before coding

Time-boxed spikes. Each writes its findings into `docs/spikes/` and updates the model registry or
adapter matrix.

| ID | Spike | Box | Blocks |
|---|---|---|---|
| S-01 | Capture `--help` and a recorded event stream from the **installed** `claude` and `codex` versions; confirm every flag in §9.1/§9.2 exists and behaves as documented; note deprecations | 1 day | M3 |
| S-02 | Fill the model registry with the providers' current lineups and effort levels; record which capability maps to which model *today* | 0.5 day | M3 |
| S-03 | Confirm the untrusted-repo hardening actually blocks execution: fixture repo with a hook that writes a canary, run both CLIs with and without the hardening flags | 1 day | M3 |
| S-04 | Serena installation, pinning, language coverage for the target project; measure warm index latency | 1 day | M6 |
| S-05 | Provider-native sandbox verification: confirm the reported sandbox configuration matches the requested profile on both macOS and Linux | 1 day | M3 |
| S-06 | Baseline timing of the target project's own test/lint/build commands, to size the verification budget | 0.5 day | M4 |

Additionally, treat these as *known-to-drift* and re-check at every milestone: model names and
tiers, effort level names, usage/telemetry field names, sandbox flag names, permission-mode names.

---

## 23. ADR index

Write these as ADRs in `docs/adr/` before or during the milestone that implements them. Each links
to its decision ID.

| ADR | Title | Decisions | Milestone |
|---|---|---|---|
| 001 | Deterministic control-plane ownership | D-01, I-01 | M0 |
| 002 | FSM lifecycle with bounded internal DAG | D-02 | M0 |
| 003 | SQLite state, append-only events, snapshots | D-03, D-04 | M0 |
| 004 | Artifact contracts and versioning | D-10, D-11 | M0 |
| 005 | Checkpoint and recovery semantics | D-35, I-08 | M0 |
| 006 | Git worktree isolation | D-05 | M1 |
| 007 | Dirty-working-copy policy | D-06 | M1 |
| 008 | Action Broker architecture | D-19 | M2 |
| 009 | Default-deny secrets and network | D-21 | M2 |
| 010 | Policy model: typed invariants + tighten-only YAML | D-22, D-23 | M2 |
| 011 | Human action gates | I-09 | M2 |
| 012 | Provider adapters and capability negotiation | D-07 | M3 |
| 013 | Untrusted-repository hardening | I-10 | M3 |
| 014 | Sandbox backend abstraction | D-20 | M3 |
| 015 | MCP trust, allowlisting and pinning | D-19 | M3 |
| 016 | Deterministic verification ownership | D-24, I-06 | M4 |
| 017 | Multidimensional risk model | D-12, D-13 | M5 |
| 018 | Capability routing and model registry | D-08, D-09 | M5 |
| 019 | Quota pressure semantics | D-30 | M5 |
| 020 | Context compiler, provenance and trust | D-14, D-15, I-07 | M6 |
| 021 | Canonical Markdown memory; semantic memory deferred | D-18 | M6 |
| 022 | Independent review context | D-27, D-29 | M7 |
| 023 | Finding adjudication | D-28 | M7 |
| 024 | Usage and cost accounting semantics | D-33 | M8 |
| 025 | Telemetry schema and OTel mapping | D-31, D-32 | M8 |
| 026 | Evaluation before optimisation | D-34 | M8 |
| 027 | Workflow, prompt and model versioning | D-09 | M8 |

---

## Appendix A — Anti-patterns

Kept from the research because each one is a real failure mode with a cheap defence.

| Anti-pattern | Why it fails | What we do instead |
|---|---|---|
| One giant autonomous agent | Shared bias, uncontrolled agency | Deterministic control plane |
| Model decides stage completion | Nondeterministic lifecycle | FSM guards, no model in the transition path |
| Model asserts tests pass | Assertion is not evidence | Run the tests; read the table |
| Same-context self-review | Anchoring | Fresh reviewer packet |
| Generic agent swarm | Cost, conflicts, duplicated reasoning | Risk-triggered specialists |
| Infinite retry of the same prompt | Burns quota, learns nothing | Failure taxonomy; a retry must change something |
| Whole-repo prompt | Dilutes the relevant evidence | Hierarchical, progressive retrieval |
| One long chat across stages | Context pollution | Fresh packet per stage |
| Indiscriminate vector recall | Memory noise and poisoning | Canonical memory + selective retrieval |
| Auto-promoted model opinions | Long-term knowledge poisoning | Evidence-backed, human-approved promotion |
| Over-compressed context | Critical behaviour lost | Exact source for implementation and review |
| Repo text treated as instruction | Prompt injection | Trust labels + broker + provenance escalation |
| Frontier model everywhere | Latency and quota waste | Capability routing |
| Cheapest model everywhere | Safety loss | Risk floors |
| Review every mechanical edit | Poor marginal value | Risk-adaptive review |
| Reviewer auto-fix | False positives cause regressions | Adjudicate first |
| Generated tests as truth | Tests encode generated assumptions | Execute and review them |
| Maximum parallelism | Semantic merge conflicts | Write-set DAG, serialise on overlap |
| Silent stash/reset | User data risk, hostile UX | Build from HEAD; say so |
| Unlimited shell and network | Injection gains real authority | Broker + sandbox + default deny |
| API cost shown as plan cost | Misleading economics | "API-equivalent estimate" label |
| Toy-benchmark optimisation | Poor real-world validity | Real project corpus with hidden tests |
| Self-optimising gates | Safety drift | eval → recommendation → human |

## Appendix B — Deferred (with revival triggers)

| Deferred | Revive when |
|---|---|
| Vector memory / Mem0 / Qdrant | FTS5 + metadata recall is measurably insufficient on a corpus of ≥500 runs |
| LangGraph or Temporal as control plane | Execution genuinely spans machines or requires durable distributed semantics |
| OPA / Rego / Cedar | Policy is authored by someone other than the single user, or must be audited externally |
| Learned routing / contextual bandits | ≥500 evaluated runs with stable metrics exist |
| Agent swarms | Paired evaluation shows a quality gain that risk-triggered specialists do not |
| Autonomous production deployment | Never in v1; would require a separate safety design |
| gVisor / Apple Container backends | A strict R3 profile is needed on a platform where bubblewrap/podman are unavailable |
| Windows support | After macOS/Linux are stable; needs named pipes and a different sandbox story |
| Cloud dashboard, team features, enterprise IAM | Outside the single-user product definition |
| Plugin marketplace | After a plugin trust and pinning model exists |
| `--include-working-copy` | v1.1; requires a snapshot mechanism that provably never touches the user's index |

---

## Appendix C — The architecture in one picture

```text
                    USER INTENT
                         │
                 DETERMINISTIC CONTROL PLANE
                  policy · state · risk
                         │
                  CONTEXT COMPILER
              provenance + trust + budget
                         │
                REPLACEABLE AI WORKERS
                         │
                    ACTION BROKER
                least-privilege sandbox
                         │
                  ISOLATED WORKSPACE
                         │
                DETERMINISTIC EVIDENCE
                         │
                 INDEPENDENT REVIEW
                         │
                     HUMAN GATE
                         │
                       READY

  ╔══════════════════════════════════════════════════════╗
  ║  events · checkpoints · usage · context · provenance ║
  ║  evals · security decisions · knowledge · metrics    ║
  ╚══════════════════════════════════════════════════════╝
```

The stable product is not Claude + Codex orchestration. It is a deterministic, evidence-driven,
context-aware development control plane whose cognitive workers happen to be Claude and Codex today.
Build the control plane; keep the workers replaceable.
