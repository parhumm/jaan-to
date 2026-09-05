# Ready — Implementation Plan: M0 through M2

## Context

**Why:** `ready-aidev/docs/9-ready-plan-v5.4-frozen.md` is the frozen, canonical build spec for **Ready** — a local, single-user, deterministic development control plane (CLI `ready`, daemon `readyd`). Its banner says *"begin implementation. Start M0 today."* M0–M2 are explicitly unblocked; M3 is gated on spikes S-05/S-06 + E-03 labels, M4 on S-01–S-04/S-07/S-08. This plan turns the frozen spec's M0–M2 milestones into an executable build.

**User decisions (confirmed):**
- **Scope:** M0 (skeleton, vertical slice, instrumentation) + M1 (workspace) + M2 (security substrate) — everything the spec marks unblocked today.
- **Location:** a **separate new repo** at `~/Projects/jaan-to-ready`, remote `git@github.com:parhumm/jaan-to-ready.git`. The `ready-aidev/` folder in jaan-to stays a design archive only — nothing is written there.
- Import package is `ready` (spec §0.1); distribution name stays local-only until S-09 (name availability spike) runs before first publish. `pyproject` project name: `jaan-to-ready`.

**Environment facts:**
- macOS arm64 (darwin). Homebrew Python 3.14.6 present; **`uv` is NOT installed** — bootstrap must install it (D-39: Python 3.12+, uv packaging).
- `pyright` not installed globally (only needed at M3; not in this scope's critical path except optional type-checking of Ready's own code).
- Stack locked by spec: typer CLI, FastAPI daemon on Unix socket 0600 no TCP (D-36), Pydantic v2 → JSON Schema (D-11), SQLite WAL + FTS5 single-writer (D-04, I-02), pytest. Fully offline build — no model/API calls anywhere in M0–M2 (FakeWorker only).

**Authority:** every decision below implements the frozen spec; where the spec underdetermines something, the resolution chosen is noted and stays inside locked decisions D-01…D-40 / P-01…P-41 and invariants I-01…I-25. Base SQLite DDL comes from doc 2 (v1.0 plan) with all §12.5 additions and `aidev`→`ready` renames (§0.1).

---

## Part 1 — Repo bootstrap

All steps in a new standalone repo; nothing touches the jaan-to checkout.

```bash
brew install uv                 # uv absent; Homebrew present
mkdir -p ~/Projects/jaan-to-ready && cd ~/Projects/jaan-to-ready && git init -b main
git remote add origin git@github.com:parhumm/jaan-to-ready.git
echo "3.13" > .python-version   # pin 3.13 (mature wheels, pyright-exercised); FLOOR stays 3.12 (D-39)
uv python install
# write pyproject.toml (below), then:
uv sync                         # commit uv.lock
# FTS5 canary (mandatory before schema work; later becomes a `ready doctor` check):
uv run python -c "import sqlite3; sqlite3.connect(':memory:').execute('CREATE VIRTUAL TABLE t USING fts5(x)'); print('FTS5 OK')"
```

`pyproject.toml` key points:
- `name = "jaan-to-ready"` (local-only; distribution name pending S-09) + classifier `"Private :: Do Not Upload"` (PyPI rejects it — structural guard against pre-S-09 publish). `requires-python = ">=3.12"` — never raise the floor. Import package `ready` under `src/ready/` (hatchling, `packages = ["src/ready"]`).
- Deps: `typer` (brings rich), `fastapi`, `uvicorn` **bare** (native `uds=`; no `[standard]` — a local single-user daemon gains nothing from uvloop/httptools), `pydantic>=2.8,<3`, `httpx` (the one mainstream client with first-class UDS transport), `pyyaml` (policy.yaml + FakeWorker scripts). Rejected: watchfiles (nothing watches files — trust checks are hash-on-run-start), tomli (stdlib `tomllib`), ULID libs (~20 lines in `core/ids.py`), alembic (doc 2 already chose forward-only `.sql` + `schema_version`), **provider SDKs forbidden until M4** (audit-enforced — M0–M2 is fully offline).
- Dev deps: `pytest`, `pytest-asyncio`, `pytest-timeout` (crash tests never hang), `pytest-socket` (blocks TCP suite-wide, `allow_unix_socket=True` — offline-by-construction), `hypothesis` (I-19 property test), `jsonschema` (artifact validation), `ruff` (incl. `S` bandit rules — free `shell=True` flagging), `pyright`.
- **pyright, not mypy** — the spec embeds pyright anyway (S-05, `typecheck_daemon = "pyright"`); one checker, one dialect; I-16's type-level test at M3 runs on the same tool. `typeCheckingMode = "strict"`, `pythonVersion = "3.12"` (check against the floor so 3.13-only syntax can't creep in).
- Console scripts: `ready = ready.cli.main:main`, `readyd = ready.daemon.main:main`.
- Stdlib only for: `sqlite3`, `tomllib`, `hashlib`, `fcntl` (daemon flock), `signal`.
- `.gitignore`: `.venv/`, `__pycache__/`, `.pytest_cache/`, `.ruff_cache/`, `.hypothesis/`, `dist/`, `*.egg-info/`, `.DS_Store`. **Commit `uv.lock` and `schemas/`** (exported JSON Schema = the N/N-1 contract corpus, D-11).
- No task-runner dep; a 10-line `Makefile`: `check` (ruff+pyright), `test`, `crash` (serial), `audit`, `schemas`, `all`.
- Create the **full §6.2 package tree at M0** (empty `__init__.py` docstrings for post-M2 packages) + `docs/adr/` stubs for the M0–M2 ADRs (001–012, 035–038, 040, 045–049, 052–053).

---

## Part 2 — M0: skeleton, vertical slice, instrumentation

### 2.1 Modules (per §6.2; real at M0 unless noted)

**core/** —
- `ids.py`: `uuid7()`, `short_id()`, `new_id(prefix)`.
- `fsm.py`: `TransitionSpec`/`TransitionTable` (data, validated); fast and heavy tables are **separate objects** (§12.2); heavy states declared, orchestrator `NotImplementedError` (M7); global table for `* → BLOCKED_HUMAN | CANCELLED | FAILED`.
- `fastpath.py`: `FastState` enum (PREPARE, IMPLEMENT, POSTDIFF, VERIFY, REPAIR, READY, ESCALATED, BLOCKED_HUMAN, FAILED, CANCELLED); `FAST_TABLE` encoding §12.2 exactly — **`successors(REPAIR) == {POSTDIFF}` makes I-19 structural, in data**; pure guards over a `RunSnapshot` (frozen DB read); `FastPathOrchestrator` with phase executors; model-call sites exist only in `_implement`/`_repair` (the enumerated allowlist for the I-01 audit); `maybe_crashpoint(name)` — env-gated self-SIGKILL for the crash matrix, inert in production. M0 fact stand-ins: preflight class scripted by scenario; postdiff files/line counts computed **for real** from the applied diff (`static/` stays empty so M3's I-16 isn't preempted).
- `router.py`: stub — always fast path at M0.
- `checkpoint.py`: `commit_boundary(...)` — the §12.3 one-`BEGIN IMMEDIATE`-transaction protocol in exact insert order, checkpoint row carries `workspace_generation` + `action_attempt_watermark` (= MAX(attempt_seq) represented by the tree); `rollback_to_checkpoint(cp)` — **the single primitive** (§12.4): restore tree, void `generation == old_gen AND attempt_seq > watermark`, bump generation, emit `workspace.rolled_back`; `recover_all()` — §12.4 steps: scan non-terminal `action_attempt` first, reconcile content-addressable by hash, halt UNKNOWN-external runs in BLOCKED_HUMAN, rollback on tree/checkpoint mismatch, resume at `attempt_no + 1` with cold session (re-write cost recorded), `FAILED reason=workspace_lost` if workspace gone.

**models/** — `envelope.py` (ArtifactEnvelope, discriminated union on kind); `payloads/` one module per family (all 9, D-10; ChangeSet carries the structured patch + `status: applied|evidence_only`); `risk.py`; `facts.py` (`PreflightFacts`/`PostDiffFacts` verbatim §7.3 — distinct types); `patch.py` (`PatchOp` with `expected_base_blob_sha`/`expected_result_sha`, `StructuredPatch` — P-34); `worker_events.py` (Usage extended with cache decomposition fields); `report.py` (CostReport, CacheHealth); `export.py` → `schemas/1.0/<Kind>.json`.

**store/** — `db.py`: `open_writer()` (daemon-only, runs migrations) vs `open_reader()` (`mode=ro` URI + `query_only=ON`); pragmas everywhere: WAL, `synchronous=NORMAL`, `foreign_keys=ON`, `busy_timeout=5000`; FTS5 asserted at startup. `migrations/0001_base.sql` (doc 2 §4.5 DDL verbatim: project, run, stage_attempt, checkpoint, artifact, event, worker_invocation, usage, broker_decision, human_gate, context_item, verification_result, finding, memory_record, memory_fts, history_fts + indexes) and `0002_ready_v54.sql` (§12.5 verbatim — copy, don't paraphrase: run/checkpoint generation+watermark columns, worker_invocation session columns, usage cache columns, phase_timing, localization_result, action_journal, action_attempt, trusted_content, assessment, environment, env_lease + indexes). Forward-only SQL migrations recorded in `schema_version`; reader never migrates. `events.py`: `append_event` (inside boundary transactions) + `iter_events` + in-process `EventBus` for follow-streams. `artifacts.py`: CAS `put()` implementing §12.3 blob rule (tmp → fsync → rename → fsync dir), idempotent.

**workspace/** — `base.py`: `WorkspaceHandle` protocol (`read/write/delete/blob_sha/tree_hash/snapshot/restore`); `fake.py`: `FakeWorkspace` — real files under `<home>/workspaces/...`, `workspace_sha` = deterministic content-tree hash, snapshots in CAS. M1 swaps in git worktrees behind the same protocol without touching `checkpoint.py`.

**patch/ + journal/** — `patch/apply.py`: hash-guarded apply, **never fuzzy**; journals each op as a `workspace_local` `fs.write`/`fs.delete` action (strategy `hash`, `intended_hash`) through PLANNED→AUTHORIZED→STARTED→SUCCEEDED. `journal/record.py`: `plan_action()` (durable `action_id` once — P-35), `begin_attempt()` (from `run.next_attempt_seq`), `finish_attempt()`, `void_attempts(run, generation, seq_gt)`. Per-verb reconciliation beyond `hash` lands M2.

**workers/** — `base.py` (§8.4 `WorkerAdapter` protocol), `modes.py` (`ExecutionMode`, `PATCH_ONLY_TOOL_SURFACE = ()`), `pool.py` (minimal SessionPool: cold first acquire records synthetic `startup_ms`, warm after — makes `process_warm` honest across crash-restart), `scenario.py` (YAML models + loader, `auto` hash resolution against the live workspace), `fake.py` (FakeWorker — first-class per §19: cache fields **derived from session state**: cold → cache_creation, warm call 2+ → cache_read; `prefix_hash = sha256(invariant_block_text)`, byte-stable), `registry.py` ({"fake": FakeWorker}).

**verify/** — `scripted.py`: scenario-driven pass/fail per VERIFY visit, writes `verification_result` rows + evidence blobs; the VERIFY→READY guard reads the **stored** VerificationReport (I-06 shape from day one).

**telemetry/** — `phases.py` (PhaseTimer with §12.5 segments, flushed inside `commit_boundary` so I-08 covers timing), `usage.py`, `cache_health.py` (§16.2 verbatim; **one-call run reports `task_context_cached` = n/a, never 0/failure**), `report.py` (CostReport builder; API-equivalent estimate labelled per D-33), `redact.py` (minimal; corpus M8).

**daemon/** — `main.py` (READY_HOME resolution with env override for tests, dirs, singleton flock, migrate, `recover_all`, uvicorn on UDS with `umask(0o177)` → socket 0600, stale-socket cleanup); `singleton.py` (flock + pidfile); `app.py` (FastAPI + DaemonContext); `runs.py` (sequential FIFO executor, D-38 one active run; cancel flag between phases → durable CANCELLED boundary). Endpoints: `/health`, `/version`, `POST /runs`, `GET /runs/{id}`, `/runs/{id}/events?follow=` (NDJSON via EventBus), `/runs/{id}/artifacts[/{aid}]`, `/runs/{id}/cost`, `POST /runs/{id}/cancel`.

**cli/** — `client.py` (httpx-over-UDS `DaemonClient`, `ensure_daemon()` autostart via detached `python -m ready.daemon.main`, poll `/health` ≤5s); `main.py` (typer: `run [--attach|--scenario|--dry-run]`, `status`, `events [--follow|--type]`, `show`, `cancel`, **plus `cost`** — §21 lists it and exit criterion 3 needs the data anyway); `render.py` (rich). CLI never imports `open_writer`; all mutations via IPC (I-02).

**config/** — `settings.py`: `~/.ready/config.toml` via tomllib, defaults per §20; M0 keys: daemon.socket, workers.wall_clock_limit_s, limits.max_repairs_fast=1, fastpath.max_model_calls/max_diff_lines, logging.*; `READY_` env overrides.

### 2.2 FakeWorker scenarios (package data, drive every M0 test)

| Scenario | Drives |
|---|---|
| `happy_path.yaml` | 1 call → READY; exit criterion 1; `task_context_cached: n/a` |
| `repair_path.yaml` | VERIFY fail → REPAIR → POSTDIFF#2 → READY; I-19 trace, I-24 fixture, call-2 cache accounting, crash rows |
| `preflight_escalate.yaml` | preflight R2 → ESCALATED from PREPARE |
| `postdiff_promoted.yaml` | postdiff R2 → `rollback_to_checkpoint` + ESCALATED, patch stored `evidence_only`; exercises generation bump + watermark voiding |
| `repair_fails.yaml` | fail → repair → fail → ESCALATED (max_repairs_fast=1) |

Scenario YAML: `invariant_block_text` (hashed → byte-stable prefix_hash), `session.cold_startup_ms`, `workspace.files`, `preflight.derived_class`, ordered `calls` (events incl. usage with invariant/task token split; patches with `expected_base_blob_sha: auto` resolved by loader — a script may pin a wrong hash to force `patch_base_mismatch`), `postdiff[]` and `verify[]` entries per visit. UNKNOWN-external recovery is a **test fixture** (direct journal row insert + restart), not a scenario — FakeWorker holds no tools.

### 2.3 M0 exit criteria → tests

| Criterion / invariant | Test |
|---|---|
| 1. `ready run` → READY, artifacts schema-valid | `tests/integration/test_happy_path.py` (state + every artifact blob validates against `schemas/1.0/` via jsonschema) |
| 2. kill -9 at every boundary resumes, no dup artifacts / lost events | `tests/invariants/test_i08_crash_boundaries.py` — parametrised `{scenario × boundary × before/after_commit}` via `READY_TEST_CRASHPOINT` self-SIGKILL harness + one external-kill smoke test |
| 3. Itemised token report + phase timing | `tests/integration/test_cost_report.py` (per-call rows, call-2 cache_read > 0, phase×segment complete, one-call n/a semantics) |
| 4. Daemon sole writer (I-02) | `tests/invariants/test_i02_single_writer.py` (readonly reader, `open_writer` import audit, flock exclusion, CLI-mutations-via-IPC audit) |
| I-01 | `test_i01_no_model_in_guards.py` — AST call-graph audit + enumerated permitted call-site allowlist (grows into I-12 audit at M3) |
| I-19 (fake) | `test_i19_repair_reenters_postdiff.py` — table assertion + Hypothesis random-walk property test + orchestrator trace |
| I-24 (fake) | `test_i24_assessments_append_only.py` — both postdiff ordinals persist, supersedes chain, no-`UPDATE assessment` audit |

Supporting: unit tests for ids/CAS/migrations/contracts/fsm-table/cache-health/scenario-loader/hash-guard; integration tests for CLI surface, escalation paths, postdiff-promotion rollback (generation+watermark voiding — M0 pre-figure of I-25), UNKNOWN-external halt.

### 2.4 M0 task order (Appendix A2)

1. Bootstrap (git, uv, pyproject, package tree, ADR stubs) → 2. contracts + IDs → 3. SQLite + migrations + pragmas → 4. event log + CAS → 5. fake workspace + hash-guarded apply + minimal journal ∥ 6. fast FSM tables/guards → 7. checkpoints (`commit_boundary`, `rollback_to_checkpoint`, `recover_all`) → 8. FakeWorker + scenarios + scripted verifier → 9. orchestrator wired in-process (I-24, promotion, escalation, I-01 tests) → 10. daemon on UDS → 11. CLI → 12. instrumentation + `/cost` → 13. crash matrix → 14. close-out (suite green, ruff/pyright clean, README, tag `m0`).

### 2.5 M0 spec-ambiguity resolutions (flagged, no unfreeze)

- `usage` keeps doc-2 legacy cache columns (NULL) alongside §12.5 names; only §12.5 names written.
- `rollback_to_checkpoint()` ships at M0 (recovery needs it; §18 M0 requires the crash loop) against the WorkspaceHandle protocol; M2 finalizes git-backed behavior + the "only reset path" audit exactly as §19.1 schedules.
- BLOCKED_HUMAN reachable at M0 (recovery halt) but approve/deny CLI arrives M2 — documented limitation.
- Cache-concept decomposition rides on `cache.health` events (D-31), keeping the `usage` table exactly per §12.5.
- Deterministic kill -9 = self-delivered SIGKILL at named crashpoints (uncatchable, same semantics) + one real external-kill smoke test.

---

## Part 3 — Shared foundations (both milestones build on these; shapes fixed now)

- **`core/ids.py`**: `new_id()` = UUIDv7 (RFC 9562) as 32-char lowercase hex, implemented locally (~20 lines; honors the 3.12 floor), injectable clock/random for determinism; `new_short_id()` = 8-char lowercase Crockford base32 without `ilou` (git-branch- and case-insensitive-FS-safe), uniqueness DB-enforced (`run.short_id UNIQUE`, regenerate on collision); `content_hash()` = sha256 hex — the one hash for CAS/prefix/trust/packets; `idempotency_key(run_id, action_id)` = sha256 of canonical concat (§12.5); `canonical_json()` — the single canonicalization for `canonical_args_hash`.
- **Contract versioning**: `SCHEMA_VERSION = "1.0"`; `tools/export_schemas.py` → committed `schemas/1.0/`; drift test (freshly generated == committed); golden N/N-1 harness at `tests/contract/golden/<version>/` (add goldens, never delete) so the first version bump is mechanical.
- **`config/paths.py`**: every §6.3 path derives from **`READY_HOME`** (default `~/.ready`) — the test-isolation seam; an audit test forbids hardcoded `~/.ready` elsewhere. Daemon-touching tests use a **short** temp home (`/tmp/rdy-XXXXXX`) because macOS caps UDS paths at 104 bytes (pytest `tmp_path` is too deep to bind).
- **Store single-writer pattern**: daemon owns one rw connection in a `Store` with `BEGIN IMMEDIATE` transactions under a lock via `asyncio.to_thread`; AST audit: `sqlite3.connect` only in `store/db.py`, `open_writer` called only from `ready.daemon` (+ injected into `core/checkpoint`). Daemon `/health` carries a version field; CLI refuses on mismatch; reader never migrates.
- **CLI read model** (reconciled): `status/events/show/cost/journal` read the **ro DB directly** (`mode=ro` URI + `query_only=ON` — I-02's own wording); `run --attach` streams NDJSON from the daemon (it already POSTs there); all mutations are IPC.
- **Crash harness — ONE design for M0 boundaries and M2 journal states**: `src/ready/testing/crashpoints.py::maybe_crash(name)` — no-op unless `READY_CRASHPOINT` matches, then real self-`SIGKILL`. Sites: `boundary:<STATE>:{before,after}_commit`, `cas:after_tmp_write`, `cas:after_rename`, and (M2) `action:<verb_class>:{authorized,started,before_terminal}`. `tests/harness/crash.py::CrashHarness` (start/run/await_killed/restart + assertion helpers). Crash tests: serial, deadline-polled, `pytest-timeout` backstop.
- **Static-audit utility**: `tests/harness/audit.py` — **AST, not grep** (`iter_source_asts`, `find_calls`, `find_imports`/`import_graph`, `assert_only_in(findings, allowlist)`); one engine reused by I-01, I-02, I-04, I-13, the single-rollback-primitive audit, the offline guard (no provider SDK importable / in `uv.lock` until M4), and later I-12.
- **Hypothesis**: `RuleBasedStateMachine` over the fast-path table (I-19: REPAIR's only successor is POSTDIFF; no VERIFY after repair without POSTDIFF; READY only via passing VERIFY) + a watermark-algebra property test pre-validating the `generation == old AND attempt_seq > watermark` cut before M2 wires git. Deterministic profile in CI.
- **Test tree**: `tests/{harness,unit,contract,state,crash,redteam,integration,audit,fixtures}` mirroring §19 levels; `conftest.py` installs the READY_HOME fixture and pytest-socket (TCP blocked, unix sockets allowed).
- **FakeWorker determinism rules (hard)**: no wall-clock reads (wall_ms is script data), no randomness, `sleep_ms=0` in tests, payloads hashed into envelopes exactly like real output. Any test that only passes with a real provider is a design smell (§19).

---

## Part 4 — M1: Workspace manager

### 4.1 Modules (`src/ready/workspace/` + seeds)

- `errors.py`: typed refusals — `NOT_A_REPO`, `UNBORN_HEAD`, `MERGE_IN_PROGRESS`, `REBASE_IN_PROGRESS`.
- **`broker/spawn.py` is seeded in M1** (flagged resolution): the single subprocess call site — `shell=False` hardcoded, argv typed `Sequence[str]` (raises on `str`), takes an `EnvProfile`/`EgressClass`. M1's git calls must never leak `os.environ` or touch a shell; "the boundary precedes the effect" (rule 5). `build_env()` completes in M2.
- `gitio.py`: the only place git argv is constructed, via `spawn()`. Every call: `-c core.hooksPath=<empty daemon dir>` (user/repo hooks never fire on Ready commits), pinned identity, `GIT_CONFIG_NOSYSTEM=1`. Typed helpers (`rev_parse_head`, `status_porcelain`, `worktree_add/remove/prune`, `commit_all`, `diff`, `commit_tree`, `update_ref`) + private `_reset_hard(worktree, sha)` — **callable only by `rollback_to_checkpoint()`** (audit-enforced).
- `paths.py`: `WorkspaceLayout` (`primary/`, `scratch/{home,tmp}`, `quarantine-manifest.json`, `evidence/`) + `assert_daemon_owned()` — destructive ops refused outside `~/.ready/workspaces/` + DB registry.
- `base.py`: D-06 — `resolve_base()` → `BaseResolution{base_sha, dirty_base, excluded_paths, refusal}`; base is always committed HEAD; dirty → record + one notice; **no code path can stash/commit/reset/checkout/clean the user's tree**.
- `manager.py`: `create()` (resolve → layout → `git worktree add -b ready/run-<short_id> <ws>/primary <base_sha>` — writes only `.git/worktrees/*` admin files + one ref in the user's repo → quarantine scan → row + event), `remove()` (`git worktree remove --force` + `prune`, then delete only the daemon-created root), `prune()`.
- `quarantine.py` (P-36): `AGENT_CONFIG_PATHS = (".claude/", ".mcp.json", ".codex/", "AGENTS.md", "CLAUDE.md")`; pure read+inventory (rel_path, sha256, git_blob_sha, size, mode) → `quarantine-manifest.json` (tmp+fsync+rename) + CAS artifact + event. **Nothing moved/edited/chmod'd** → no diff pollution, structurally.
- `checkpoint_commit.py`: journals a `git.write(commit)` action (probe strategy), `git add -A && git commit --allow-empty` with `Ready-Run-Id/Ready-State/Ready-Action-Id` trailers (trailer+tree-hash = the probe key); SHA becomes `checkpoint.workspace_sha` inside the §12.3 transaction. Crash between git commit and DB commit → orphan commit; recovery sees divergence and rolls back — consistent by construction.
- `reconcile.py` (flagged resolution): "matches checkpoint" = HEAD equality **and** clean `git status --porcelain` in `primary/` (a dirty match triggers rollback — the safe reading of §12.4 step 3).
- `gc.py` + `cli/workspace.py`: `ready diff` (daemon-side `git diff <base>..HEAD`), `ready apply [--branch|--patch] [--keep-history]` (squash via `commit-tree` parented on base; never touches the user's working tree or index), `ready gc [--branches]`.
- `rollback_to_checkpoint()` gains its git backing (`_reset_hard` in the RUN worktree only); journal-void call is a no-op stub until M2. Migration `m1_workspace`: `run` columns `workspace_path, branch, base_sha, dirty_base, excluded_paths_json`.

### 4.2 M1 exit → tests

| Exit | Test |
|---|---|
| Dirty checkout untouched (porcelain + mtimes) | `tests/workspace/test_dirty_checkout.py` (snapshot porcelain-v2 + stat mtimes before/after a full FakeWorker run; dirty_base + excluded paths recorded; refusal cases: merge/rebase/unborn/non-repo) |
| Reconciliation restores exact checkpoint SHA | `tests/workspace/test_reconciliation.py` (injected extra commit; injected dirty tree; no-rollback-when-matching) |
| Quarantine without diff pollution | `tests/workspace/test_quarantine.py` (inventoried+hashed; `git status` clean; `git diff base..HEAD` empty for quarantined paths; original bytes+mtimes untouched; manifest schema + CAS) |
| Lifecycle/GC | `tests/workspace/test_worktree_lifecycle.py`, `tests/cli/test_diff_apply_gc.py` |

Fixture repos (built by committed scripts, not committed `.git` dirs): `repo-clean`, `repo-dirty`, `repo-merge-conflict`, `repo-rebase`, `repo-unborn`, `repo-agent-config`, `repo-ready-config`.

---

## Part 5 — M2: Security substrate

### 5.1 Broker (`src/ready/broker/`)

- `verbs.py`: `Verb` enum (§14.1), `EffectScope`, `ReconcileStrategy`, `VERB_TABLE` per-verb defaults.
- `decide.py`: §14.2 pipeline **in exact order** (FROZEN_DENY → canonicalise → roots → policy → untrusted-influence gate → mandatory gates → R3 gates → allow); pure function; Broker persists every decision **before** any effect.
- `paths.py`: canonicalisation — reject empty/NUL/control bytes → resolve → `realpath` (symlink components collapse; outside-target fails containment) → `is_relative_to` pre-resolved roots → deny `primary/.git/**` + gitdir. Case-insensitive APFS handled via resolved-realpath comparison, never string compare. Effect layer re-verifies + `O_NOFOLLOW` at syscall time (documented best-effort TOCTOU hardening; threat model is model output).
- `programs.py`: `ValueType` (`PATH_IN_ROOT`, `ENUM`, `INT`, `TEST_ID`, `SAFE_TOKEN` — **no free-string type**), per-program `ArgSpec` (enumerated flags, typed values, arity), `PROGRAM_TABLE` (M2 ships the **mechanism** + minimal test-only entries: fixture echo-argv script, `true`, reference `pytest` spec; real tools land M3/M5 — flagged resolution), `WRAPPERS` closed enumeration (`timeout` only; depth ≤ 2; peeled structurally from the argv array; inner program is what's matched). Project policy can only deny/gate programs, never add (tighten-only).
- `argv.py`: model names a **logical program** — Ready supplies `argv[0]` from the allowlist (resolved absolute realpath at daemon start); caller-supplied paths must realpath-equal an entry (kills executable substitution).
- `env.py` (I-04): `build_env(profile)` — **additive from empty**, never filtered `os.environ`; exact §14.4 allow set (`PATH` snapshot, `HOME→scratch/home`, `TMPDIR→scratch/tmp`, `LANG/LC_ALL/TZ`, `TERM=dumb`, `CI=1`, trust-approved project-safe vars, provider auth only for `ADAPTER_PARENT`); deny patterns asserted against the **result** (a hostile approved config declaring `GITHUB_TOKEN` "safe" is still rejected). Returns provenance type `BuiltEnv` that `spawn()` requires.
- `egress.py` (P-25): `ControlPlaneEgress` and `ToolEgress` as **distinct types with distinct evaluation paths**, no shared allowlist; tool egress default-deny, widened only by trust-approved `[allow].network_domains`; `net.fetch`/`pkg.install` denied by default at M2 (provisioning context flag arrives M3). **Honest scope** (flagged): OS-level socket denial for arbitrary spawned code is *not* enforceable by env scrubbing — M2 proves the policy path + env/spawn structure; ships an optional non-normative macOS seatbelt profile as defence in depth; the normative proof is S-08's canaries at M4 (§19.1 places I-17 there).
- `gates.py` (I-09/§14.7): `GateCard` with exactly five required non-empty fields (action/consequence/command/rollback-or-IRREVERSIBLE/evidence); `raise_gate` persists + parks run in BLOCKED_HUMAN; `resolve_gate`; render must succeed for all eleven frozen rules; **no "don't ask again" field exists**. New `gate` table (migration `m2_gate`). `cli/gates.py`: `ready approve|deny <gate-id>`.
- `effects.py`: fs verbs after decision+journal-STARTED — write tmp in target dir, fsync, verify against `intended_hash`, atomic rename, re-hash → outcome.
- `broker.py`: `submit()` orchestration (plan → decide → persist decision → authorized → started → effect → terminal) + `submit_replan(action_id)` for recovery re-derivation. **From M2, fast-path file mutations re-route through `Broker.submit(fs.write)`** — makes the I-25 fixtures end-to-end real.

### 5.2 Journal (`src/ready/journal/`)

- `states.py`: `planned→authorized→started→succeeded|failed|unknown`; `planned→failed` (denied/gate-rejected — flagged resolution: denial = `failed` with `{"decision":"deny",...}` payload, no schema invention); `unknown→succeeded|failed` (reconciliation only); `→void` **only** via `void_workspace_local_attempts` (workspace_local only, gen+seq cut). History never deleted.
- `journal.py`: `plan_action()` allocates durable `action_id` once (P-35), `idempotency_key=H(run_id,action_id)`, first attempt; `attempt_seq` via `UPDATE run SET next_attempt_seq=next_attempt_seq+1 RETURNING` in the single-writer transaction; `new_attempt()` same id / new seq; `void_workspace_local_attempts(run, generation, seq_gt)` voids regardless of prior state incl. SUCCEEDED, emits per-row events, records `action_generation_voided` ("not an error", §17).
- `reconcile.py`: per-verb dispatch (§14.5) — `hash` (fs.write: derive from tree), `idempotent`, `probe` (git commit by trailer+tree hash), `external_halt` (→ UNKNOWN, run to BLOCKED_HUMAN with a prompt naming action/key/how-to-check; **never replayed**); `recover_scan()` over **all** open attempts of all runs, **strictly before any run resumes** (daemon startup order: open DB → recover_scan → per-run recovery → accept IPC); `authorized`-never-`started` → `failed(crashed_before_start)`.
- **Watermark** (flagged resolution): `MAX(attempt_seq)` over workspace-local **succeeded** attempts in the current generation at checkpoint time; assert no workspace-local attempt is open at a checkpoint (`internal_invariant`); external attempts excluded. This is the only reading under which §12.4's worked example holds.

### 5.3 Trust root (`src/ready/trust/`) + Policy (`src/ready/policy/`)

- `trust/`: sha256 over exact bytes (no normalization); approved and proposed content stored in CAS so `ready trust review` always renders old→new; `approve` re-hashes at approval time (+ `--content-hash` for scripting; mismatch aborts — closes review→approve TOCTOU); `resolve_project_file()` → `APPROVED_CURRENT | APPROVED_FALLBACK` (changed → data-only; execution uses last-approved bytes from CAS) `| NONE` (fail closed per config, `trust_unapproved`); applies to `.ready/project.toml`, `.ready/policy.yaml`, `.ready/memory/*.md`. `cli/trust.py`: `ready trust list|review|approve`.
- `policy/invariants.py`: **frozen constants** — `FROZEN_GATES` (all eleven §14.7 rules, each renderable now), `FROZEN_DENY`, `MANDATORY_GATE_VERBS`, `ELEVATED_VERBS`, `R3_GATE_VERBS`, `FORBIDDEN_CONFIG_KEYS = {"agent_config_files"}`.
- `policy/schema.py`: `extra="forbid"`; typed Broker vocabulary for `gates.additional` (`{verb, program?, operation?}` — no `Bash(...)` glob surface exists, P-24); no field can remove a frozen gate or allow a FROZEN_DENY verb.
- `policy/loader.py`: raw key-tree check for the literal `agent_config_files` **before** Pydantic parse → purpose-built `ConfigRejected` naming P-41/I-10; project files load **only** through `trust/resolve.py` — no direct repo-bytes-to-config path exists.
- `policy/merge.py`: tighten-only — `verbs.deny` set-union only, `gates.additional` append only, thresholds `min()`; any loosening → loud `PolicyMergeError`; frozen invariants re-asserted over the merged result.
- `untrusted-influence` (flagged): `ActionRequest.influenced_by_untrusted` threaded now (default False), populated for real by the M4 context assembler; the pipeline branch is present and unit-tested with synthetic True.

### 5.4 M2 exit → tests

| Exit / invariant | Test |
|---|---|
| I-13 argv-only, no shell | `tests/audit/test_i13_no_shell.py` (AST: no `shell=True`/`os.system`/`os.popen`/pty) + `tests/broker/test_spawn.py` (rejects str argv; `"; rm -rf ~"` inert as argv byte) |
| Red-team ≥25 | `tests/redteam/test_broker_redteam.py` — **30 parametrised cases**: 14 path escapes (traversal ×2, symlink dir/file, home canary, user-checkout read, scratch escape, NUL, newline, APFS case-variation, `.git` writes ×2, UNC), 13 exec abuses (sh/bash argv0, substituted binary, symlinked lookalike, wrapper-wrapping-unlisted, depth>2, `env`/`find -exec` unlisted, shell metachars inert, redirection inert, unknown flag, bad positional type, backgrounding `&`), 3 verb cases (`net.fetch` deny, `pkg.install` deny, `secret.read` → gate). Each asserts deny/gate **and** no filesystem/process effect (canaries) |
| I-04 build_env + single spawn path | `tests/broker/test_build_env.py` (exact key-set equality per profile; deny patterns win over project-safe vars; additive-not-filtered) + `tests/audit/test_i04_single_spawn_path.py` |
| I-09 gates | `tests/policy/test_frozen_gates.py` (all 11 render 5 fields; loosening overlay → error; list is constant; no don't-ask-again) |
| I-14 trust | `tests/trust/test_trust_root.py` (mutated `project.toml` with `test = "touch /tmp/pwned"` → canary never created, fallback used; approval content-hash-specific; fail-closed; unapproved = data-not-instruction) |
| I-15 / I-22 | `tests/journal/test_crash_injection.py` (crash matrix {planned→authorized, authorized→started, started→terminal} × {hash, idempotent, probe, external_halt} via the shared harness; UNKNOWN-external halts, never replays) + `tests/journal/test_identity.py` (restart same `action_id` new seq; repeated action new id; `canonical_args_hash` asserted) |
| Single rollback primitive | `tests/audit/test_single_rollback_primitive.py` (`_reset_hard` has exactly one caller; no other reset/checkout/clean argv anywhere) |
| I-25 watermark cut | `tests/journal/test_watermark_cut.py` — two-write fixture (write A seq 7 SUCCEEDED → checkpoint C watermark 7 → write B seq 8 SUCCEEDED) run through **both callers**: crash-recovery (A survives + not re-derived, B void + re-derived in gen 1) and POSTDIFF promotion (same cut; patch carried `evidence_only`; B **not** re-derived by this caller); shared `assert_watermark_cut()` helper proves both callers produce identical journal+tree state |
| I-10 schema / P-41 | `tests/policy/test_config_schema.py` (`agent_config_files` rejected in both files; unknown keys forbidden) |
| Egress split | `tests/broker/test_egress_split.py` (distinct types/paths; tool default-deny; TOOL spawn refused with auth env present) |
| I-03 paths | `tests/broker/test_paths.py` + red-team overlap |
| Watermark computation | `tests/core/test_checkpoint_watermark.py` (max-succeeded-local-seq; open-attempt-at-checkpoint → internal_invariant; external excluded) |

---

## Part 6 — Master execution sequence

**Phase B (bootstrap, serial):** B1 uv+git+pin+FTS5 probe → B2 pyproject+`uv sync`+commit lock → B3 tool configs+Makefile+test tree+conftest → B4 audit harness. Verify: `ruff check && pyright && pytest -q` green on empty.

**Phase M0:** T1 ids ∥ T2 models+schemas+goldens ∥ T3 db+migrations (0001+0002) → T4 CAS ∥ T5 events ∥ T7 config → T6 telemetry → T8 FSM ∥ T10 FakeWorker+scenarios → T5b fake workspace+patch apply+minimal journal → T9 checkpoints (`commit_boundary`+`rollback_to_checkpoint`+`recover_all`) → T11 orchestrator wired in-process (I-24, promotion, escalation, I-01 audits) → T12 daemon UDS → T13 CLI → T14 crash harness → T15 crash matrix (I-08) → T16–T18 audits+property tests → T19 end-to-end + cost report. Verify after each block: `pytest tests/unit tests/contract tests/state -x` → `pytest tests/crash -x` → `pytest tests/audit -q` → manual `ready run "demo" --scenario happy_path` + `ready cost <run>`. Tag `m0`.

**Phase M1:** W1 spawn seed + gitio → W2 worktree lifecycle + dirty policy → W3 checkpoint commits + git-backed rollback → W4 quarantine ∥ W6 diff/apply/gc → W5 recovery reconciliation → W7 exit tests. Verify: `pytest tests/workspace tests/integration -x && pytest tests/crash -x` (boundary matrix now on real worktrees). Tag `m1`.

**Phase M2:** S1 verbs+models+gate table → S2 canonicalisation → S3 programs/argv → S4 build_env + spawn hardening → S5 policy (invariants/schema/loader/merge) ∥ S7 trust root ∥ S8 journal → S6 gates+CLI → S9 watermark computation + real void in rollback → S10 egress split → S11 red-team 30 → S12 journal crash matrix → S13 audits tightened (I-04, I-13, single-primitive) → S14 invariant tests (I-09, I-10-schema, I-14, I-22, I-25 both-callers). Verify: `pytest tests/redteam -x` → `pytest tests/crash -x` → `pytest tests/audit tests/state -q` → full `pytest -q`. Tag `m2`.

Commit per task-block; push to `origin` at each milestone tag.

---

## Part 7 — Definition of done (the whole arc)

**M0 exits:** run→READY with FakeWorker, artifacts schema-valid · kill -9 at every boundary resumes with no dup artifacts / lost events (parametrised) · itemised token + phase-timing report per run · daemon sole DB writer.
**M1 exits:** dirty checkout untouched (porcelain + mtimes) · reconciliation restores exact checkpoint SHA · quarantine recorded with zero diff pollution.
**M2 exits:** no model string reaches a shell · ≥25 red-team denials (30 shipped) · `build_env()` exact keys + no bypass spawn site · all frozen gates render 5 fields, policy cannot weaken · changed `.ready/project.toml` cannot execute (content-hash approval) · journal lifecycle + same `action_id` across restart + no ambiguous replay · single rollback implementation (audit) · exact watermark cut through both callers · `agent_config_files` rejected at load · egress paths separate, tool default-deny.
**§19.1 rows in scope:** I-01, I-02, I-08, I-19-fake, I-24-fake (M0) · I-03, I-04, I-09, I-10-schema, I-13, I-14, I-15, I-22, I-25 (M2) — each mapped to the named test files above.

**End-to-end verification:** `make all` (ruff + pyright + full pytest); manual demo: `uv run ready run "demo rename" --scenario happy_path`, `ready status`, `ready events <run> --follow`, `ready cost <run>`, `ready trust review/approve` against `repo-ready-config`, `ready journal <run>` after a crash-injected run.

## Part 8 — Flagged follow-ups (gate M3; not executed in this arc)

- **E-03 data task**: independently label ≥100 historical PRs at the R1/R2 and R2/R3 boundaries (Appendix A2: schedule during M1–M2; gates M3's classifier exits).
- **S-05** (pyright vs alternatives for the closure predicate; warm-daemon timings) and **S-06** (env provisioning baselines, EnvKey matrix, atomic publish crash recovery) — gate M3's start; kick off during late M2.
- BLOCKED_HUMAN approve/deny CLI arrives M2 (documented M0 limitation); OS-level tool-network denial normatively proven by S-08 at M4 (M2 ships policy-path + optional seatbelt profile as defence in depth).
- Spec-ambiguity resolutions are collected inline above, marked "flagged resolution" — all stay inside the locked decisions; none unfreezes anything.
