# aidev: Deep Architecture Research and Implementation Blueprint

## Executive assessment

The proposed `aidev` architecture is directionally very strong. The most important architectural decision is already correct: **`aidev` should be a deterministic development control plane, not another autonomous coding agent.** Evidence from software-engineering-agent research supports keeping localization, execution, validation, and workflow transitions explicit rather than handing all control to an LLM. The Agentless work showed that a comparatively simple localization → repair → validation pipeline could be competitive with substantially more elaborate agent architectures, while SWE-agent showed that the quality of the agent-computer interface itself materially affects coding performance. More recent SWE-Bench analyses likewise show that successful systems span both agentic and non-agentic architectures rather than establishing “more agents” as inherently superior. citeturn19search2turn19search6turn19search1

The strongest version of the architecture is therefore:

```text
                         USER
                           │
                           ▼
                    aidev CLI / TUI
                           │
                           ▼
                 ┌───────────────────┐
                 │      aidevd       │
                 │  LOCAL CONTROL    │
                 │      PLANE        │
                 └─────────┬─────────┘
                           │
                  deterministic FSM
                           │
              ┌────────────┼──────────────┐
              │            │              │
              ▼            ▼              ▼
          Risk Engine  Context Compiler  Policy Engine
              │            │              │
              │      ┌─────┼─────┐        │
              │      │     │     │        │
              │   Serena Memory Repomix   │
              │      │     │     │        │
              │      └─────┼─────┘        │
              │            │              │
              └────────────┼──────────────┘
                           ▼
                    Context Packet
                           │
                           ▼
                  Capability Router
                     + Quota Model
                           │
                  ┌────────┴─────────┐
                  │                  │
                  ▼                  ▼
            Claude Adapter      Codex Adapter
                  │                  │
             Claude CLI           Codex CLI
            subscription          subscription
                  │                  │
                  └────────┬─────────┘
                           │
                           ▼
                    Action Broker
                  / Sandbox Manager
                           │
                           ▼
                    Workspace Manager
                    Git / worktrees
                           │
                           ▼
                   Verification Engine
                           │
                           ▼
                Review / Adjudication
                           │
                           ▼
                     Human Gate
                           │
                           ▼
                         READY
```

The most important change from the original diagram is the addition of an **Action Broker/Sandbox Manager between AI workers and the operating system**. Prompt injection and tool-output injection cannot be solved reliably by better prompting alone. OWASP explicitly recommends least privilege, tool restrictions, structured outputs, bounded retries/tool chains, human approval for high-impact actions, and auditability for agentic systems; NIST’s recent agent-security work similarly emphasizes authorization, accountability, and provenance of prompts and data inputs. citeturn7search4turn20search3turn20search7

A second important change is that the top-level process should be an **FSM with small DAGs inside individual states**, rather than either a pure FSM or an unrestricted DAG. The FSM governs lifecycle and safety:

```text
DISCOVER → CLASSIFY → DESIGN → IMPLEMENT → VERIFY → REVIEW → READY
```

while DAG execution handles safe parallel work inside stages:

```text
IMPLEMENT
   ├── backend
   ├── frontend
   └── tests
```

This preserves deterministic lifecycle semantics while still allowing speed through concurrency.

A third change is that the current R0–R3 scheme should become a **risk vector with an R0–R3 derived class**, rather than relying on a single classification. A single scalar can hide situations such as “small change, catastrophic data-loss potential.” The derived class should use safety floors rather than an averaging formula:

```text
RiskVector
├── security
├── data_integrity
├── blast_radius
├── irreversibility
├── operational
├── external_side_effect
├── supply_chain
├── complexity
├── novelty
└── testability
```

Then:

```text
derived_class =
    highest mandatory floor
    + policy escalation
    + model escalation
```

A critical dimension must never be “averaged away.”

The fourth important change is to treat **context provenance and trust level as first-class data**, not just context contents. NIST explicitly identifies provenance of prompts and input data as useful to agent risk and policy decisions, while SLSA uses a similar trusted/untrusted-input distinction for software provenance. citeturn20search3turn20search0

The fifth is to deliberately keep v1 simpler than the conceptual full product. In particular:

**Use:** custom FSM + SQLite, Git worktrees, Serena, optional Repomix, Markdown canonical memory, FTS5, provider CLIs, Pydantic/JSON Schema, Gitleaks, OSV-Scanner, risk-triggered Semgrep, local structured logs.

**Do not use in v1:** Temporal, LangGraph as the control plane, Mem0/Qdrant, OPA/Rego, generic multi-agent frameworks, cloud control planes, autonomous production deployment, learned routing, swarm agents, mandatory gVisor, or an elaborate vector-memory stack.

The evidence base also cautions against equating larger models, more agents, or more review passes with greater quality. A 2026 code-review study found major synthetic-to-real-world performance degradation and substantial sensitivity to diff size; although its specific model ranking should not be generalized beyond that experiment, the broader lesson is important: **review quality must itself be measured on real project data, not assumed from model size or benchmark reputation.** citeturn19search3turn19search7

The recommended priority stack is therefore:

```text
                 QUALITY / SAFETY
                       │
                       ▼
            deterministic evidence
                       │
                       ▼
             independent reasoning
                       │
                       ▼
               delivery latency
                       │
                       ▼
             token / quota economy
```

Not:

```text
cheap model
   ↓
hope tests catch it
```

### Overall subsystem assessment

| Subsystem | Current assessment | Recommended direction |
|---|---|---|
| CLI/TUI | Strong | Thin client over local daemon |
| `aidevd` | Strong | Make daemon sole state/database writer |
| Workflow engine | Strong concept | Custom FSM + bounded internal DAG |
| Risk engine | Needs revision | Multidimensional vector + derived R0–R3 |
| Context compiler | Strong | Add provenance, trust, evidence coverage |
| Policy engine | Under-engineered | Add central Action Broker |
| Model router | Strong concept | Route capabilities, not model names |
| Workspace | Under-engineered | Per-run worktrees + checkpoint commits |
| Verification | Under-engineered | Plugin-based deterministic evidence engine |
| Review | Needs revision | Risk-triggered, evidence-driven, not generic swarms |
| Human gates | Strong concept | Gate actions rather than normal reasoning |
| Observability | Strong concept | Internal schema aligned with OpenTelemetry |
| Knowledge | Needs restraint | Markdown + FTS5 first; vectors later |
| Evaluation | Critically missing | Build before automatic workflow optimization |
| Recovery | Critically missing | Transactional checkpoints + idempotent stages |
| Security | Critically missing | OS/process boundary enforcement, not prompt policy alone |

The **ten biggest missing architectural elements** are therefore: action brokering, multidimensional risk, trust/provenance-aware context, transactional state/checkpoints, capability negotiation, evidence-backed finding adjudication, dirty-worktree handling, project verification adapters, an evaluation harness, and plugin/version supply-chain controls.

## Architecture and component decisions

The most consequential platform choice is the workflow engine. For a single-user local laptop application, I recommend **a small custom typed FSM backed by SQLite**, with an internal DAG executor for parallelizable work. LangGraph can persist state and supports human interrupts, Temporal provides substantially stronger distributed/durable-execution semantics, and Prefect supports retries and persisted task results; however, each adds an additional orchestration model that `aidev` does not need for its initial single-machine lifecycle. Temporal additionally requires its workflow execution model and server infrastructure, which is excellent for distributed durable applications but excessive for a local developer daemon. citeturn5search1turn5search9turn5search0turn5search4turn5search2

| Workflow option | Reliability | Local simplicity | Auditability | Parallelism | Operational burden | Verdict |
|---|---|---|---|---|---|---|
| **Custom FSM + SQLite** | High if carefully implemented | **Excellent** | **Excellent** | Add bounded DAG | **Low** | **USE** |
| LangGraph | High | Good | Good | Good | Medium | Borrow checkpoint/interrupt ideas |
| Temporal | Excellent | Poor for this scope | Excellent | Excellent | **High** | Do not use in v1 |
| Prefect | High | Moderate | Good | Excellent | Medium | Not justified |
| Dagster | High | Moderate | Good | Excellent | Medium/high | Data-oriented overkill |
| Generic agent framework | Varies | Easy initially | Usually weaker | Often good | Hidden complexity | Do not make control plane depend on it |

**Storage should use mutable current state + append-only events + stage snapshots**, not full event sourcing. Full event sourcing is less useful here because AI calls and shell side effects cannot genuinely be recreated by replaying event history. SQLite WAL is well suited to a local daemon with one logical writer and concurrent readers, and SQLite FTS5 gives built-in full-text search without adding a second database. DuckDB can later query SQLite directly or analyse exported Parquet for heavy historical analytics. citeturn5search3turn5search7turn10search3turn10search6turn10search5turn10search9

Recommended persistence:

```text
                    aidevd
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
      SQLite       Artifact      Raw/redacted
                   objects         JSONL
          │
          ├─ current state
          ├─ append-only events
          ├─ checkpoints
          ├─ token usage
          ├─ context provenance
          ├─ verification
          └─ review findings

V2/V3 analytics:
SQLite / Parquet → DuckDB
```

Use one SQL transaction to commit, at each stage boundary:

```text
stage output
artifact references
usage accounting
workspace SHA
state transition
checkpoint event
```

and write large files through temporary-file + atomic-rename semantics before committing their content hash to the database.

**Git worktrees are the correct default isolation unit.** Git officially supports multiple linked working trees attached to one repository, each with its own checkout state while sharing repository object/history data. This is substantially cheaper than cloning the repository for each worker. citeturn16search0turn16search4

Recommended layout:

```text
~/.aidev/workspaces/
└── project-id/
    └── run-284/
        ├── primary/
        ├── backend/
        ├── frontend/
        └── tests/
```

Do **not** let workers edit the user's main checkout by default.

For a clean checkout:

```text
HEAD
 │
 └── aidev/run-284 private branch
       └── linked worktree
```

For a dirty checkout, `aidev` should not silently stash, commit, reset, or modify the user's files. Git's stash command explicitly saves working/index changes and restores the tree to `HEAD`, so silently invoking it would modify the user's active environment. citeturn16search3

The safest automatic default is:

```text
dirty main checkout
      │
      ├─ record that working tree is dirty
      │
      └─ create aidev worktree from committed HEAD
```

and tell the user that uncommitted edits were intentionally excluded. A future explicit `--include-working-copy` mode can construct a private snapshot/patch without modifying the original working tree.

**Provider abstraction should not become a lowest-common-denominator API.** Use a stable generic envelope plus provider capabilities:

```python
WorkerAdapter

capabilities() -> WorkerCapabilities

invoke(
    request: WorkerInvocation,
    context: ContextPacket,
    workspace: WorkspaceHandle,
    policy: ExecutionPolicy,
) -> AsyncIterator[WorkerEvent]

cancel(invocation_id)
```

`WorkerCapabilities` should advertise:

```text
models
effort levels
structured output
streaming
tool execution
subagents
MCP
sandbox modes
context caching
session continuation
usage telemetry
```

Provider-specific extensions remain namespaced:

```text
provider_options.anthropic.*
provider_options.openai.*
```

This avoids crippling Claude/Codex features while keeping the workflow provider-neutral.

This abstraction is viable because Claude Code currently exposes programmatic `-p` execution, JSON/stream-JSON modes and JSON-schema structured output, while Codex exposes model/effort selection, usage information, MCP integrations, review flows and sandbox controls in its CLI ecosystem. Claude subagents can also use separate models, effort levels, tools and contexts. citeturn1search5turn1search9turn1search4turn17search0

For the user's **Claude Max + ChatGPT/Codex subscription** requirement, make CLI-backed workers the primary mode:

```text
ClaudeSubscriptionAdapter
   └── claude -p ...

CodexSubscriptionAdapter
   └── codex ...
```

and make API adapters optional:

```text
AnthropicAPIAdapter
OpenAIAPIAdapter
```

This avoids accidentally conflating fixed-plan usage with separately billed API usage. Claude Code explicitly distinguishes subscription authentication from API-key/provider authentication, and its `/usage` reporting treats subscription usage differently; Codex's CLI exposes ChatGPT account token activity through `/usage`. citeturn17search1turn17search3turn17search0

**Structured artifacts should remain, but simplify their taxonomy.** Rather than 13 completely independent top-level types, use a universal artifact envelope plus about nine payload families:

```text
ArtifactEnvelope
├── TaskIntent
├── RiskAssessment
├── Requirements
├── Design
├── TestSpecification
├── ChangeSet
├── VerificationReport
├── ReviewReport
└── FinalReport
```

`ArchitectureReview` becomes a `ReviewReport(kind=architecture)`. `AdjudicationResult` becomes part of a finding lifecycle. `ImplementationResult` becomes `ChangeSet + WorkerExecution`. This reduces schema surface without sacrificing machine validation.

Every artifact should contain:

```text
schema_version
artifact_id
run_id
stage_id
attempt_id

producer
provider
model
effort

workflow_version
prompt_version

base_git_sha
workspace_git_sha

context_packet_hash

created_at
content_hash
```

Claude currently supports schema-constrained structured outputs, including programmatic JSON-schema validation, which makes this architecture more reliable than free-form inter-agent prose. citeturn1search5turn1search9

**Policy-as-code should initially be typed Python + declarative YAML, not OPA or Cedar.** OPA/Rego is a capable general policy language and Cedar is specifically built for authorization decisions, but introducing a second policy language and runtime for a single-user application adds considerable operational and cognitive complexity. citeturn21search0turn21search1turn21search5

Use immutable built-in invariants:

```python
PRODUCTION_WRITE_REQUIRES_HUMAN = True
SECRET_ACCESS_DEFAULT = "deny"
FORCE_PUSH_DEFAULT = "deny"
REVIEWER_WORKSPACE = "read_only"
```

with user/project policy able to **tighten** rules freely. Weakening a built-in safety floor should require an explicit local configuration decision, never an LLM decision.

**Packaging:** Python remains a good control-plane implementation language because the architecture needs subprocess management, SQLite, schemas, platform inspection and a local HTTP/TUI surface more than extreme compute throughput. Use `uv`-compatible packaging, with `uv tool` as the preferred distribution path and `pipx` as fallback; `uv` itself supports user-scoped installation and Python management. citeturn21search3turn21search7

A practical stack is:

| Layer | Recommendation |
|---|---|
| Runtime | Python 3.13+ |
| Async execution | `asyncio` |
| Contracts | Pydantic + JSON Schema |
| CLI | Typer + Rich |
| TUI | Textual |
| Daemon/API | FastAPI + Uvicorn |
| Local web UI | Jinja/HTMX initially |
| DB | SQLite WAL + FTS5 |
| Analytics later | DuckDB |
| Workspace | Git worktrees |
| Semantic code | Serena |
| Snapshot/compression | Repomix optional |
| Secrets | Gitleaks |
| Dependencies | OSV-Scanner |
| SAST | Semgrep CE, risk-triggered |
| Telemetry | internal event schema + optional OTel exporter |

### Major architecture alternatives

| Decision | Alternative | Quality | Reliability | Token efficiency | Complexity | Local-first | Recommendation |
|---|---|---:|---:|---:|---:|---:|---|
| FSM | LangGraph | High | High | Neutral | Medium | Good | Borrow only |
| FSM | Temporal | High | Excellent | Neutral | High | Fair | Reject v1 |
| Context | Serena | **High** | High | **High** | Medium | Excellent | **Integrate** |
| Context | custom Tree-sitter index | Potentially high | Your burden | High | **High** | Excellent | Later/fallback |
| Context | Aider-style repo-map | High pattern value | High | High | Medium | Excellent | Borrow design |
| Snapshot | Repomix | Good | Good | High for overview | Low | Excellent | Optional integration |
| Memory | Markdown + FTS5 | **High trust** | **High** | High | **Low** | Excellent | **Use v1** |
| Memory | Mem0/Qdrant | Good semantic recall | Medium | Variable | Medium/high | Good | V2 |
| Storage | SQLite | **Excellent** | **High** | N/A | **Low** | Excellent | **Use** |
| Analytics | DuckDB | Excellent | High | N/A | Low | Excellent | V2 |
| Workspace | worktrees | **High** | **High** | N/A | Low | Excellent | **Use** |
| Workspace | clone per agent | High | High | N/A | High I/O | Good | Strict fallback only |
| Sandbox | rootless OCI | High | High | N/A | Medium | Good | Strict-mode backend |
| Review | generic agent swarm | Unproven | Variable | Poor | High | Good | Reject default |
| Review | risk-triggered specialists | **High** | **High** | Good | Medium | Good | **Use** |

## Context, memory, routing, and workflow specification

**Serena should be the primary semantic-code provider in v1, but not a mandatory architectural dependency.** Serena provides symbol-level retrieval, reference finding and LSP-backed semantic operations through MCP, and its design explicitly avoids requiring whole-file reads for many navigation tasks. citeturn22search0turn22search5

That matches research from Agentless and Aider remarkably well. Agentless localizes hierarchically from files to code elements before repair instead of dumping the entire repository, while Aider's repository map ranks important symbols and fits them to a token budget. citeturn19search2turn4search2turn4search6

The right abstraction is therefore:

```text
ContextProvider
├── SerenaProvider
├── GitProvider
├── ArtifactProvider
├── MemoryProvider
├── FilesystemProvider
├── RepomixProvider
└── FallbackSearchProvider
```

If Serena is unsupported or broken for a language, the rest of `aidev` continues operating.

**Repomix is worth including, but not as the main retriever.** Its Tree-sitter compression keeps structural elements such as function signatures, interfaces and classes while removing many implementation details; however, its compression feature is currently documented as experimental. citeturn22search2

Use it for:

```text
repo overview
token-count estimation
structural snapshot
architecture packets
fallback packaging
```

Do not use it as the default mechanism for every implementation prompt.

The Context Compiler should implement **progressive disclosure**:

```text
task
 ↓
repo map / memory
 ↓
symbols
 ↓
references/dependencies
 ↓
selected exact implementation
 ↓
tests/evidence
 ↓
additional retrieval only if uncertainty remains
```

This is better than either:

```text
whole repo → model
```

or:

```text
vector search top-20 chunks → model
```

because code relevance is partly structural rather than purely semantic.

The context schema should add **trust** and **provenance**:

```json
{
  "id": "ctx_8472",
  "source_type": "repository",
  "source": "src/auth/session.ts",
  "symbol": "SessionService.rotate",
  "git_sha": "abc123",
  "trust": "UNTRUSTED_REPOSITORY_CONTENT",
  "purpose": "implementation_dependency",
  "priority": "high",
  "tokens": 1812,
  "content_hash": "..."
}
```

Recommended trust levels:

```text
SYSTEM_POLICY
PROJECT_POLICY
USER_REQUEST
APPROVED_ARTIFACT
REPOSITORY_CONTENT
EXTERNAL_CONTENT
TOOL_OUTPUT
GENERATED_CONTENT
```

Only the first four can contain **instructions**. The others are treated as evidence/data. This does not make prompt injection impossible, but it creates the right boundary for the model prompt and, more importantly, lets the Policy Engine reject dangerous actions that were causally influenced by untrusted material. NIST's agent-authorization work specifically calls out tracking provenance of prompts and data sources, while MCP and OWASP guidance warn that tools and their outputs can be untrusted. citeturn20search3turn7search0turn7search1

Context selection should not use a brittle fixed weighted formula initially. Use priority tiers:

```text
MANDATORY
  safety policy
  task acceptance criteria
  approved constraints
  directly modified code

HIGH
  callers/callees
  relevant tests
  security invariants
  data contracts

MEDIUM
  neighboring implementations
  Git history
  conventions

LOW
  broad architecture summaries
  historical analogous runs
```

Within each tier, rank by:

```text
semantic relevance
dependency proximity
test relationship
architectural relevance
recency
```

and penalize:

```text
staleness
duplication
token size
retrieval uncertainty
```

Do **not** establish universal 35k/60k token budgets as architecture constants. Instead implement adaptive budgets:

```text
initial_budget(stage, model)
     +
risk adjustment
     +
complexity adjustment
     +
retrieval uncertainty
```

followed by progressive retrieval.

The crucial stop criterion is not:

> “We used 40,000 tokens.”

It is:

> “We have sufficient evidence coverage for this stage, and the next retrieval candidate has low marginal relevance.”

Use historical successful-run percentiles later to tune actual ceilings.

Useful context-quality metrics are:

| Metric | Definition |
|---|---|
| Evidence coverage | Required constraints/dependencies represented in packet |
| Retrieval precision | Retrieved items later proven relevant |
| Missed dependency rate | Files/symbols discovered after implementation that should have been included |
| Duplicate-context ratio | Redundant tokens / total packet |
| Stale-context ratio | Tokens from artifacts later found stale |
| Exact-code ratio | Exact implementation tokens / total |
| Structural-to-full-file ratio | Symbol/structure retrieval versus whole-file retrieval |
| Context escalation rate | Runs requiring extra retrieval after model starts |
| Context waste | Packet items never referenced/accessed downstream |
| Context-to-success | Context tokens per verified successful stage |

Recent research on software-engineering context shows why this matters: accurate prior context can improve success and reduce runtime/token use, whereas irrelevant or poorly selected prior context provides substantially less benefit and can be harmful. citeturn6search8

**Canonical memory should remain plain Markdown in v1.** Serena itself deliberately uses human-readable Markdown memories that can be committed, reviewed and reverted alongside the code. citeturn22search1

Recommended durable knowledge:

```text
architecture invariants
domain vocabulary
security invariants
data ownership
API guarantees
testing rules
supported commands
deployment constraints
important ADR summaries
known dangerous assumptions
```

Run history should contain:

```text
prompts
model outputs
tool calls
hypotheses
failed fixes
review comments
diffs
verification logs
```

Never automatically promote:

```text
unverified model conclusions
reviewer speculation
raw external text
secrets
credentials
temporary runtime errors
user-private content unrelated to project knowledge
```

Knowledge promotion should be:

```text
successful run
     ↓
candidate extraction
     ↓
evidence references
     ↓
contradiction/staleness check
     ↓
human approval for architecture/security
     ↓
canonical memory
```

Memory records should include references to relevant source files/symbols and the Git SHA at validation. If those source objects change, mark the memory **possibly stale** rather than silently deleting or continuing to trust it.

SQLite FTS5 is sufficient for v1 historical search. Vector memory becomes valuable only when the historical corpus is large enough that semantic recall is demonstrably poor with metadata + FTS. Mem0 can run locally with Ollama and Qdrant, so it is a viable later option; it is simply unnecessary infrastructure before the problem exists. citeturn22search3turn22search7turn10search3

**Risk should be recomputed three times:**

```text
after discovery
after design/plan
after implementation diff
```

A seemingly R1 task can become R3 if implementation unexpectedly touches authorization, payment or destructive migration code.

Recommended risk vector:

| Dimension | Meaning |
|---|---|
| Security | Auth, permissions, encryption, attack surface |
| Data integrity | Corruption/loss/consistency risk |
| Blast radius | Number/criticality of affected components |
| Irreversibility | Ease of rollback |
| Operational | Deployment/runtime availability risk |
| External side effects | Payments, mail, cloud APIs, user actions |
| Supply chain | Dependencies/build pipeline |
| Complexity | State space/concurrency/cross-component reasoning |
| Novelty | Unknown framework/domain/path |
| Testability | Ability to deterministically establish correctness |

Static rules establish floors:

```text
authorization touched      => security >= critical
destructive migration      => irreversibility >= critical
payment capture            => external_side_effect >= critical
new package                => supply_chain >= elevated
public API change           => blast_radius >= elevated
```

An LLM can raise a risk classification. It should not autonomously lower a deterministic floor.

**Model routing should target logical capabilities, not model names.**

```text
reasoning.frontier
reasoning.standard

coding.strong
coding.standard
coding.fast

review.standard
review.critical

debug.frontier
mechanical.fast
```

As of August 2026, an example mapping can use Anthropic's current Fable/Opus/Sonnet family and OpenAI's current Sol/Terra/Luna family, but this mapping belongs in a versioned model registry rather than workflow definitions. Anthropic currently distinguishes Fable as its highest-end widely released model, Opus for demanding reasoning/agentic coding and Sonnet as its speed/intelligence balance; OpenAI currently positions Sol as its flagship GPT‑5.6 model, Terra as the middle price/performance tier, and Luna as its fastest/lowest-cost member. citeturn11search7turn11search6turn13search0

Recommended initial routing:

| Work | Logical role | Current example | Effort |
|---|---|---|---|
| Mechanical | `mechanical.fast` | Codex Luna | low |
| Normal implementation | `coding.standard` | Codex Terra | medium |
| Difficult implementation | `coding.strong` | Codex Sol | high |
| Normal requirements | `reasoning.standard` | Claude Sonnet | medium/high |
| High-risk architecture | `reasoning.frontier` | Claude Opus | high/xhigh |
| Critical architecture | `reasoning.frontier+` | strongest available Claude tier | high/xhigh |
| Normal review | `review.standard` | Sonnet | high |
| Critical review | `review.critical` | Opus | xhigh |
| Hard-bug diagnosis | `debug.frontier` | Opus + Sol independently | xhigh |
| Narrow final adjudication | strongest eligible | strongest available | max only when justified |

Current Claude effort settings explicitly trade depth against resource usage, with higher settings causing deeper reasoning and more thinking tokens, so `max` should be a narrow escalation mechanism rather than the default. citeturn11search2turn11search6

The effort heuristic should start deterministically:

```text
base effort = task class
+ one level if:
    retrieval uncertainty high
    novelty high
    previous attempt failed
    review disagreement
    ambiguous runtime evidence

never reduce below:
    risk-specific safety floor
```

Do not route using an LLM's self-reported confidence alone.

**Quota pressure** should be an ordinal signal:

```text
LOW
MEDIUM
HIGH
CRITICAL
```

calculated from recent observed usage, provider-reported usage, recent rate-limit events and time since reset where available. Claude Code currently exposes token/session usage and plan-related usage breakdowns, while Codex exposes `/usage` for daily, weekly or cumulative ChatGPT token activity. These are useful inputs, but `aidev` should not present them as a mathematically precise “remaining token balance” when the provider does not expose one. citeturn17search1turn17search5turn17search0

Quota may change:

```text
Terra vs Sol for R1
Sonnet vs Opus for optional analysis
whether optional secondary review runs
parallelism
```

Quota must **not** change:

```text
R3 required verification
required security review
human destructive-action gate
required migration validation
```

### Risk-adaptive workflows

| Workflow | Required path |
|---|---|
| **R0** | Discover → localize → change → targeted verification → READY |
| **R1** | Discover → concise requirements → localize/plan → implementation → deterministic verification → independent review → final verification |
| **R2** | Discover → risk → architecture → independent challenge → test plan → implementation → verification → strong review → fixes → re-verify |
| **R3** | Discover → full risk → architecture → independent red-team → explicit test/invariant spec → strict implementation → verification → specialist review → independent second review/adjudication → final verification → human gate if side effects |
| **Hard Bug** | Evidence packet → two independent diagnoses → experiments → root-cause adjudication → regression test → fix → verification → review |
| **Migration** | Data invariants → migration design → rollback/roll-forward → dry-run → implementation → representative-data verification → integrity checks → human production gate |
| **Large refactor** | Characterization tests → dependency map → staged plan → incremental changes/checkpoints → full regression verification |
| **Dependency upgrade** | Dependency rationale → advisory/provenance assessment → lockfile update in sandbox → vulnerability scan → build/test → review |
| **Security-sensitive** | Threat model → architecture review → constrained implementation → security tests/SAST → specialist independent review → human gate for external/production effects |

The **Hard Bug workflow** should specifically prohibit patching during the first diagnosis phase:

```text
Bug evidence
    │
 ┌──┴─────────────┐
 │                │
 ▼                ▼
Opus            Sol
diagnosis       diagnosis
read-only       read-only
 │                │
 └──────┬─────────┘
        ▼
 hypothesis comparison
        ▼
 targeted experiments
        ▼
 reproduced root cause
        ▼
 regression test
        ▼
 minimal fix
```

That is more consistent with scientific debugging than repeated “try another patch” loops.

## Security, workspace, verification, and review

Security is the area where the original proposal most needs additional engineering.

Prompt injection against agents with tools is an established problem, not a theoretical concern. NIST's CAISI evaluations have examined indirect prompt injection leading toward consequences such as remote code execution and data exfiltration, and OWASP's agent guidance explicitly treats prompt injection, excessive agency, memory poisoning, tool misuse and data exfiltration as core threats. citeturn7search2turn7search4

The security model should assume:

```text
LLM output      = untrusted
repo text       = untrusted
MCP output      = untrusted
tool output     = untrusted
dependency docs = untrusted
network content = untrusted
```

while:

```text
aidev core policy = trusted
approved project policy = trusted
explicit user request = trusted
approved structured artifact = conditionally trusted
```

The **Action Broker** should be the only path through which an aidev-controlled worker gets high-impact capabilities.

```text
AI Worker
   │
   │ request
   ▼
Action Broker
   │
   ├── policy evaluation
   ├── trust/provenance check
   ├── path canonicalization
   ├── argument validation
   ├── environment filtering
   ├── network policy
   ├── risk classification
   └── human gate if needed
   │
   ▼
Sandbox
   │
   ▼
OS / Git / compiler / network
```

Prefer structured process execution:

```python
subprocess(["git", "diff", "--stat"])
```

over:

```text
shell("git diff --stat")
```

wherever possible. Shell syntax should be allowed only where genuinely necessary.

The environment inherited by workers should be an allowlist, not `os.environ.copy()`.

Example:

```text
ALLOW
PATH
HOME -> synthetic sandbox home
LANG
TMPDIR
project-specific safe variables

DENY
AWS_*
GITHUB_TOKEN
SSH_AUTH_SOCK
OPENAI_API_KEY unless worker requires it
ANTHROPIC_API_KEY unless worker requires it
browser/profile directories
keychains
.env contents
cloud credentials
```

**Sandboxing should have multiple backends rather than one universal answer.**

For Linux, bubblewrap provides user/mount/PID/network namespace isolation and supports seccomp integration, but its maintainers explicitly position it as a building block rather than a complete security policy. Rootless Podman is also designed to run containers without root and user IDs are remapped through user namespaces. citeturn8search0turn8search4turn8search6

For stronger isolation, gVisor adds an additional userspace-kernel boundary, but at greater complexity and compatibility cost; it is better suited to an optional strict/R3 backend than mandatory local development. citeturn8search7turn8search3

On macOS, there is currently no single lightweight analogue I would make a universal dependency. Apple's newer `container` project provides OCI-compatible Linux containers using lightweight VMs on Apple Silicon/macOS 26, but it remains pre-1.0 and explicitly allows breaking changes across minor releases, making it a promising **WATCH** item rather than the v1 portability baseline. citeturn8search1turn8search5

Therefore implement:

```text
SandboxBackend
├── ProviderNativeSandbox
├── BubblewrapSandbox       Linux
├── RootlessPodmanSandbox   Linux/macOS VM-backed
├── DockerSandbox           optional
├── GVisorSandbox           optional strict Linux
└── AppleContainerSandbox   future/experimental
```

Anthropic itself recommends stronger OS/container isolation such as containers, gVisor or VMs for agents operating on untrusted code, and OpenAI warns that Codex full-access mode removes project-directory protections and can cause destructive actions. citeturn1search6turn17search2

A safe default profile:

```text
ARCHITECT
  filesystem: read-only
  network: deny
  secrets: deny
  tools: semantic/search only

IMPLEMENTER
  filesystem: run worktree only
  network: deny by default
  secrets: deny
  package install: controlled

REVIEWER
  filesystem: read-only
  network: deny
  secrets: deny

VERIFICATION
  worktree: read/write where build requires
  network: deny unless dependency restoration explicitly required
  secrets: synthetic/test only

PRODUCTION
  automatic access: DENY
```

**MCP servers deserve their own threat boundary.** The MCP specification treats tools as potentially executing arbitrary code and requires user awareness/consent around tool use; OWASP recommends sandboxing local servers, restricting filesystem/network access, treating tool results as untrusted, validating inputs/outputs and controlling destructive/data-sharing actions. citeturn7search1turn7search5turn7search0

For `aidev`:

```text
MCP allowlist only
local stdio preferred
exact package/version pin
resolved executable path recorded
tool schemas hashed at setup
network denied unless necessary
outputs labelled TOOL_UNTRUSTED
```

Do not let workers install arbitrary MCP packages from model suggestions.

Serena should run from a pinned, explicit installation. Its own project warns users not to rely on random MCP/plugin marketplace installation commands. citeturn22search0

**Secrets:** use Gitleaks as the default lightweight diff/repository scanner. TruffleHog is valuable as an optional deeper scanner because it can verify certain secrets and covers broader sources, but that makes it heavier. citeturn9search0turn9search1

**Dependency safety:** OSV-Scanner is a strong local/open-source baseline for lockfile/SBOM vulnerability scanning. OpenSSF Scorecard can provide additional project-level security posture information for newly introduced dependencies, although it should be treated as one risk signal rather than a yes/no package oracle. citeturn9search2turn20search1

A dependency introduction should create an explicit artifact:

```text
DependencyDecision
├── package
├── requested version
├── purpose
├── existing alternative considered
├── vulnerability status
├── licence
├── package provenance/maintenance signals
├── lifecycle-script risk
└── approval requirement
```

SLSA's provenance model is also a useful design inspiration for aidev artifacts: preserve who/what produced an artifact, which inputs were external/untrusted, which version of the process was run and what by-products/evidence were emitted. citeturn20search0

**Verification should be a plugin system.**

Universal interface:

```python
class VerificationAdapter:
    def detect(project) -> bool: ...
    def plan(change, risk) -> VerificationPlan: ...
    async def execute(check) -> VerificationResult: ...
```

Checks can include:

```text
format
lint
types/compiler
unit
integration
contract
e2e
build
dependency vulnerability
secret detection
SAST
migration
property tests
fuzzing
race detection
sanitizers
performance regression
```

Do not run every expensive check on every R0 typo.

Recommended matrix:

| Check | R0 | R1 | R2 | R3 |
|---|---:|---:|---:|---:|
| Existing targeted tests | As applicable | ✓ | ✓ | ✓ |
| Formatter/lint | If code | ✓ | ✓ | ✓ |
| Type/compiler/build | If code | ✓ | ✓ | ✓ |
| Full relevant unit suite | — | ✓ | ✓ | ✓ |
| Integration/contract | — | If relevant | ✓ | ✓ |
| Secret scan on diff | ✓ | ✓ | ✓ | ✓ |
| Dependency scan | On dep change | On dep change | ✓ when affected | ✓ |
| SAST | — | Optional | Risk-triggered | ✓ security-sensitive |
| Property-based | — | — | Risk-triggered | Often for invariants |
| Fuzzing | — | — | Parser/security paths | Risk-triggered |
| Race detector | — | — | Concurrency | Concurrency |
| Migration dry-run | — | — | Schema changes | Mandatory critical migration |
| Mutation testing | — | — | Selected modules | Selected only |
| Performance | — | — | Perf-sensitive | Perf/availability-sensitive |

Semgrep CE can run local scans and produce machine-readable output, making it a useful risk-triggered general SAST provider rather than an always-on universal gate. citeturn9search7turn9search3

**Test generation should use Pattern B + D as the default**, rather than forcing either “builder writes everything” or universal AI-generated test-first execution:

```text
Independent test/acceptance plan
           ↓
Builder implements code + executable tests
           ↓
Deterministic execution
           ↓
Independent reviewer identifies missing cases
```

For R3, independent executable oracle tests are useful where the expected behavior is sufficiently objective, especially around authorization matrices, idempotency, data invariants and destructive operations.

Large-scale empirical work on LLM-generated tests has found compilation/execution failures and hallucination-driven test problems in some configurations, supporting the principle that generated tests must themselves be executed and validated rather than treated as ground truth. citeturn6search3turn6search7

**Review should be fresh-context and evidence-driven.** OpenAI's own Codex review workflow uses a read-only sandbox and asks for concrete correctness/security/performance issues rather than free-form rewrites. citeturn14search3

Reviewer packet:

```text
original task
acceptance criteria
approved architecture constraints
risk vector
security/data invariants
final diff
relevant surrounding source
test plan
verification evidence
```

Exclude by default:

```text
builder chain of discussion
builder self-evaluation
builder rationalization
failed internal attempts
```

Those can be retrieved later as evidence if needed.

Cross-provider review is sensible as a **diversity heuristic**, but current evidence is insufficient to assert a universal quantitative improvement from “Claude reviews Codex” versus “fresh Codex reviews Codex.” Therefore, require **context independence**; prefer provider diversity for R2/R3 when available, but evaluate it empirically rather than encoding it as dogma.

Review levels:

```text
R0
  no AI review for genuinely mechanical change

R1
  one fresh-context general reviewer

R2
  one strong reviewer
  + specialist only for triggered risk dimension

R3
  strong general reviewer
  + relevant specialist
  + independent second-model confirmation for
    BLOCKER/HIGH or critical invariants
```

Avoid running seven reviewers for every task.

The recent code-review study's large synthetic-to-real drop and diff-size sensitivity makes **small, focused diffs and deterministic evidence** more valuable than simply adding reviewers. citeturn19search3turn19search7

Every significant finding should be represented as:

```text
Finding
├── severity
├── category
├── claim
├── affected location
├── evidence
├── reproduction
├── suggested resolution
├── status
└── adjudication
```

Finding state:

```text
PROPOSED
  ↓
VALIDATED / REJECTED / UNCERTAIN
  ↓
FIXED
  ↓
REVERIFIED
```

Do not automatically patch every reviewer suggestion. A recent code-review benchmark design likewise emphasizes specific, actionable, objectively verifiable findings and uses actual failing/passing tests as stronger validation. citeturn6search6

### Security threat model

| Asset | Threat / attack path | Impact | Primary mitigation | Residual risk |
|---|---|---|---|---|
| Source tree | Prompt injection in comments/docs | Malicious actions | Trust labels + action broker + sandbox | Medium |
| Secrets | Agent reads `.env`, SSH, browser stores | Credential theft | Env allowlist, no home mount, secret redaction | Low/medium |
| Host | Shell escape/destructive command | Data loss | Worktree sandbox, command policy | Low/medium |
| Network | Exfiltration | Source/secret leakage | Default deny, proxy/allowlist | Low |
| MCP | Malicious server/tool schema | Arbitrary execution | Explicit allowlist, version pin, isolation | Medium |
| Tool output | Injected instructions | Policy bypass attempt | Tool output untrusted + broker | Medium |
| Dependencies | Lifecycle script malware | Host compromise | sandbox install, network policy, dependency gate | Medium |
| Git | Worker modifies main checkout | User data loss | separate worktree | Low |
| Memory | Poisoned generated “facts” | Long-term bad decisions | gated promotion + provenance | Low/medium |
| Logs | Tokens/secrets captured | Privacy leak | redaction + local perms + content opt-in | Low |
| Daemon API | Local process hijacks aidevd | Arbitrary workflow control | Unix socket / local auth / permissions | Low |
| Generated code | Backdoor/subtle vulnerability | Product compromise | tests + SAST + independent review | Non-zero |
| Production | Autonomous destructive action | Severe incident | hard human gate | Very low if enforced |

Human approval should be mandatory for:

```text
production deployment
production credential access
destructive migration
production database write
cloud infrastructure destruction
external spending
force push
package/public release
breaking public API policy exception
security-policy weakening
persistent network-secret combination
```

The approval screen should show **action + consequence + exact command/change + rollback + evidence**, not a generic “Allow?” prompt. This minimizes approval fatigue.

## Observability, evaluation, performance, and optimization

`aidev` should implement its own stable internal event schema, while making it **mappable to OpenTelemetry**. OpenTelemetry's semantic conventions define standardized tracing/metric vocabulary and now include GenAI conventions, but the GenAI conventions remain an actively evolving area. citeturn20search2turn20search6

Use internal events like:

```text
run.created
run.completed
run.failed

risk.assessed
risk.changed

stage.started
stage.completed
stage.failed

context.discovery.started
context.compiled
context.expanded

routing.decision

worker.started
worker.completed
worker.failed

tool.requested
tool.allowed
tool.denied
tool.completed

workspace.created
workspace.checkpoint

verification.started
verification.completed

review.finding
review.completed
finding.adjudicated

human_gate.requested
human_gate.resolved

retry.scheduled
escalation.triggered
```

Trace shape:

```text
Run span
├── Discovery
├── Risk
├── Architecture
│   ├── Context compilation
│   └── Claude invocation
├── Red-team
│   ├── Context compilation
│   └── Codex invocation
├── Implementation
│   ├── Context compilation
│   ├── Codex invocation
│   └── tool spans
├── Verification
│   ├── lint
│   ├── test
│   └── build
└── Review
```

Each worker invocation should record:

```text
provider
model
model snapshot/identifier
effort
plan/auth mode
context-window limit if known

input tokens
cached-input tokens
cache-write tokens if exposed
reasoning tokens if exposed
output tokens

wall time
provider-active time if exposed

context packet hash
context tokens by layer

tool count
tool duration
files touched
lines added/removed

attempt
retry reason
```

Claude Code's current `/usage` screen reports token usage, model breakdown and API-equivalent dollar figures; Anthropic explicitly notes that these dollar values are calculated from list prices and may not reflect a user's actual subscription/billing. citeturn17search1turn17search5

Therefore `aidev` must distinguish:

```text
ACTUAL PAYMENT MODEL
  Claude Max subscription
  ChatGPT/Codex subscription

OBSERVED USAGE
  tokens
  sessions
  plan-pressure signals

API-EQUIVALENT COST
  hypothetical comparison only
```

Never label API-equivalent cost:

> “this feature cost $8.42”

when it ran under a fixed monthly plan.

OpenTelemetry guidance also warns that recording full GenAI prompt/tool content can capture sensitive data; its metadata-focused conventions can be used without automatically recording content. citeturn20search6

Recommended logging policy:

```text
metadata       ON
token stats    ON
tool metadata  ON
context IDs    ON

full prompts       OFF by default
full model output  stored as local artifact only if configured
tool output        redacted
environment        never raw
secrets            never
```

**Quality metrics should be hierarchical.**

Leading quality indicators:

```text
acceptance-criteria coverage
deterministic verification rate
first-pass verification rate
BLOCKER/HIGH finding rate
repair-loop count
risk reclassification rate
policy denial rate
context missed-dependency rate
```

Lagging quality indicators:

```text
post-merge defect
hotfix
revert
security issue
incident
performance regression
```

Efficiency metrics:

```text
time to READY
model-active time
verification time
control-plane overhead

tokens / verified R1 task
tokens / verified R2 task
context tokens / successful stage

cache-hit ratio
context duplication
escalation rate
parallel efficiency
```

The primary optimization objective should be something conceptually like:

```text
minimize:
  time_to_verified_success
  + token_resource_use

subject to:
  quality >= safety threshold
  required gates = preserved
```

Never combine everything into a single opaque “AI efficiency score.” Keep quality and safety constraints visible.

**Evaluation is mandatory before automatic optimization.** SWE-Bench and related work are useful external indicators, but SWE-Bench Pro was specifically introduced because older issue-resolution benchmarks were becoming less representative of longer-horizon work, and its creators include private tasks to reduce overfitting concerns. citeturn19search5

Your own evaluation corpus should therefore contain real project-like tasks:

```text
small bug
cross-file feature
API change
frontend behavior
migration
authorization
dependency update
concurrency bug
performance regression
large refactor
security vulnerability
```

Each task contains:

```text
clean base commit
task request
hidden acceptance tests
optional hidden security/invariant tests
expected risk dimensions
forbidden behaviors
```

Evaluate workflow versions, not just models:

```text
workflow A:
  Terra M → Sonnet H

workflow B:
  Sol H → Sonnet H

workflow C:
  Terra M → Opus H
```

Use paired tasks so the same task set is applied to each workflow.

For low sample sizes:

```text
binary success:
  beta-binomial credible intervals

token/time distributions:
  bootstrap paired differences

post-merge failures:
  track individually and conservatively
```

Do not automatically loosen a policy based on ten successful tasks.

Workflow change lifecycle:

```text
analytics
   ↓
recommendation
   ↓
offline evaluation
   ↓
quality comparison
   ↓
human approval
   ↓
new workflow version
   ↓
canary on low-risk tasks
```

A contextual bandit or learned router may eventually optimize R0/R1 model selection, but reinforcement-learning-style self-optimization is unnecessary for a single developer until a large dataset exists. Use transparent deterministic routing first.

**Token optimization priorities**, ordered by expected benefit with low quality risk:

| Technique | Expected benefit | Quality risk | Complexity | Recommendation |
|---|---|---:|---:|---|
| Symbol-level retrieval | High | Low | Medium | **P0** |
| Progressive context retrieval | High | Low | Medium | **P0** |
| Remove duplicate context | High | Very low | Low | **P0** |
| Fresh stage contexts | High | Low | Low | **P0** |
| Stable prompt prefixes/cache-friendly design | Medium/high | Very low | Low | **P0** |
| Cache Serena/LSP indexes | High latency benefit | Very low | Low | **P0** |
| Model tier routing | High | Medium | Medium | **P0** with eval |
| Effort routing | High | Medium | Medium | **P0** with floors |
| Compact structured artifacts | Medium | Low | Low | **P0** |
| Avoid optional second review on R1 | Medium/high | Low after eval | Low | P1 |
| Log/output summarization | Medium | Medium | Medium | P1 |
| Semantic cache of old solutions | Unclear | Medium/high | Medium | V2 |
| Aggressive code compression | Medium | **Medium** | Low | Only overview contexts |
| Vector memory | Unclear initially | Medium | High | V2 |
| Agent swarms | Usually expensive | High | High | Reject default |

Repomix's structural compression is useful precisely because it removes implementation details while preserving structural signatures, but that also explains why it should not be used where implementation details constitute the evidence. citeturn22search2

**Latency optimization should prioritize deterministic concurrency before model concurrency.**

Safe:

```text
Serena retrieval ─┐
Git analysis ─────┼─ parallel
test discovery ───┘

unit shards ──────┐
lint ─────────────┼─ parallel
SAST ─────────────┘

Opus diagnosis ───┐
                  ├─ parallel read-only
Sol diagnosis ─────┘
```

More dangerous:

```text
three agents editing same subsystem simultaneously
```

Parallel writers should only run when the planning stage establishes non-overlapping write sets and explicit dependencies.

A conservative scheduler:

```text
task DAG
   ↓
predict read/write sets
   ↓
if write overlap:
    serialize
else:
    isolated worktrees
    parallelize
```

Use optimistic merge only after verification. Do not use file locks as the primary solution; locks stop simultaneous writes but do not solve semantic conflicts.

**Performance SLOs should be derived from baseline measurements rather than invented before implementation.** The sensible architecture targets are relative:

```text
daemon stays warm
LSP/index stays warm
local status operations feel interactive
context compilation is small relative to model inference
dashboard queries remain interactive over normal run history
verification uses project-native incremental caches
```

After the first benchmark suite, define numerical p50/p95 SLOs for:

```text
CLI local command
ContextCompiler warm compile
SQLite query
dashboard load
run checkpoint
workspace creation
```

and ensure control-plane overhead remains a small fraction of AI + verification wall time.

## Tool landscape, anti-patterns, and roadmap

The strongest open-source strategy is **selective integration**, not framework accumulation.

| Tool/project | Decision | Role |
|---|---|---|
| **Git** | **ADOPT** | Workspace/change authority |
| **SQLite** | **ADOPT** | Source-of-truth state/events |
| **Pydantic/JSON Schema** | **ADOPT** | Artifact contracts |
| **Serena** | **INTEGRATE** | Primary semantic code provider |
| **Repomix** | **INTEGRATE OPTIONAL** | Snapshot/compression/token profiling |
| **Gitleaks** | **INTEGRATE** | Default secret detection |
| **OSV-Scanner** | **INTEGRATE** | Dependency vulnerability detection |
| **Semgrep CE** | **INTEGRATE** | Risk-triggered SAST |
| **OpenTelemetry** | BORROW/EXPORT | Semantic naming + optional telemetry |
| **Aider repo-map** | **BORROW IDEAS** | Ranked token-budget repository mapping |
| **Agentless** | **BORROW IDEAS** | Localization → repair → validation |
| **SWE-agent** | **BORROW IDEAS** | Purpose-built agent-computer interface |
| LangGraph | BORROW IDEAS | Checkpoints/human interrupts |
| Temporal | BORROW IDEAS | Durable/idempotent workflow principles |
| Prefect/Dagster | REJECT V1 | Unnecessary workflow runtime |
| Mem0 | WATCH/V2 | Long-run semantic memory |
| Qdrant | WATCH/V2 | Vector layer only after proven need |
| OpenMemory | WATCH | Cross-agent historical memory |
| OPA/Rego | REJECT V1 | Too much policy infrastructure |
| Cedar | REJECT V1 | Authorization engine unnecessary initially |
| Rootless Podman | INTEGRATE OPTIONAL | Strict sandbox |
| Bubblewrap | INTEGRATE LINUX | Lightweight Linux sandbox |
| gVisor | OPTIONAL R3 | Stronger Linux isolation |
| Apple Container | WATCH | Promising but currently pre-1.0 |
| CrewAI | REJECT CORE | Agent hierarchy adds little to deterministic control plane |
| AutoGen | REJECT CORE | Same reason |
| generic multi-agent swarm | REJECT | Cost/complexity without proven general benefit |

Serena's semantic symbol operations and plain-file memory make it particularly compatible with this architecture, while Aider's dynamic repo-map and Agentless's hierarchical localization are valuable ideas to incorporate into the Context Compiler rather than dependencies to embed wholesale. citeturn22search0turn22search1turn4search2turn19search2

**Key anti-patterns:**

| Anti-pattern | Symptom | Why it fails | Safer pattern |
|---|---|---|---|
| Giant autonomous agent | One model plans/builds/reviews/deploys | Shared bias + uncontrolled agency | Deterministic control plane |
| Model as state machine | Agent decides stages complete | Nondeterministic lifecycle | Explicit FSM |
| Model as verifier | “Tests should pass” | Assertion is not evidence | Run tests/compiler |
| Same-context self-review | Builder reviews own reasoning | Anchoring | Fresh reviewer context |
| Blind agent swarm | Many generic agents | Cost, conflicts, duplicated reasoning | Risk-triggered specialization |
| Infinite retry loop | Same prompt repeated | Burns quota without new evidence | Failure taxonomy + escalation |
| Entire-repo dump | Huge context | Dilutes relevant evidence | Hierarchical retrieval |
| Persistent giant chat | Every stage shares history | Context pollution/anchoring | Fresh Context Packets |
| Indiscriminate vectors | Every historical note retrieved | Memory noise/poisoning | Canonical memory + selective retrieval |
| Auto-memory | Model opinions become “facts” | Long-term poisoning | Evidence-backed promotion |
| Overcompression | Function internals omitted | Critical behavior lost | Exact source for implementation/review |
| Untrusted text as policy | Repo comment says “run X” | Prompt injection | Provenance/trust labels |
| Frontier model everywhere | Opus/Sol highest effort for CRUD | Latency/quota waste | Capability routing |
| Cheapest model everywhere | Luna handles critical auth | Safety loss | Safety floor |
| Review every mechanical edit | Expensive/noisy | Poor marginal value | Risk-adaptive review |
| All specialist reviewers always | 5–10 review agents | Token explosion/false positives | Trigger specialists by risk |
| Reviewer auto-fix | Every comment rewritten | False-positive damage | Adjudicate first |
| Tests only after implementation | Builder defines own oracle | Blind spots | Independent test plan |
| LLM-generated tests as truth | Generated tests “prove” correctness | Tests can be wrong | Execute + review tests |
| Maximum parallelism | Agents touch shared files | Semantic merge conflicts | Write-set DAG |
| Silent stash/reset | User edits disappear/move | Hostile UX/data risk | Separate worktree from HEAD |
| Direct main checkout writes | Agent modifies user state | Hard rollback | Private worktree |
| Unlimited shell/network | Prompt injection gains authority | Exfiltration/destruction | Broker + sandbox |
| API-cost display as plan cost | Says `$12` under subscription | Misleading economics | API-equivalent label |
| Toy benchmark optimization | Routing looks excellent | Poor real-world validity | Real + hidden project tasks |
| Auto self-optimization | System weakens gates | Safety drift | eval → recommendation → human |

The Agentless results and the recent code-review results are particularly strong warnings against assuming architecture complexity or model size automatically produces better outcomes. citeturn19search2turn19search3

**Trustworthy v1 scope:**

```text
aidev / aidevd
SQLite state/events
custom deterministic FSM
risk vector + R0-R3
Claude CLI adapter
Codex CLI adapter
capability/model registry
Context Compiler
Serena integration
optional Repomix
Markdown memory + FTS5
Context provenance/trust
Git worktrees
Action Broker
baseline sandbox abstraction
checkpoint/resume
structured artifacts
project detectors
verification plugins
Gitleaks
OSV-Scanner
risk-triggered Semgrep
independent review
finding adjudication
hard-bug workflow
usage/context/time accounting
CLI/TUI
basic local dashboard
offline evaluation suite
human dangerous-action gates
```

**Explicitly delay to v2/v3:**

```text
semantic vector memory
Mem0/Qdrant
automatic learned routing
contextual bandits
complex speculative execution
cross-machine agents
cloud dashboard
team collaboration
enterprise IAM
automatic CI/CD deployment
full Temporal-like execution
autonomous production operations
mandatory gVisor
advanced graph database
general plugin marketplace
fully autonomous knowledge promotion
```

**Suggested staged roadmap:**

| Phase | Deliverable | Why |
|---|---|---|
| Foundation | Data models, events, FSM, fake workers, checkpoints | Prove determinism/recovery first |
| Workspace | Git worktrees, dirty-tree handling, rollback | Protect developer source |
| Security | Action Broker, trust labels, env/network/path policy | Establish safety boundary |
| Workers | Claude/Codex CLI adapters | Enable real work |
| Artifacts | Typed schemas, validation/repair | Stable inter-stage contracts |
| Risk/routing | Risk vector, model capabilities, effort rules | Adaptive workflow |
| Context | Serena, memory, provenance, progressive retrieval | Token/quality efficiency |
| Verification | Project adapters, Gitleaks/OSV/Semgrep | Evidence gates |
| Review | Independent context, findings, adjudication | Quality control |
| Observability | TUI, dashboard, OTel exporter | Optimization data |
| Evaluation | Offline hidden tasks + production outcomes | Evidence for routing changes |
| Parallelism | DAG scheduler + isolated worktrees | Speed after correctness |
| Intelligence | Learned recommendations, semantic memory | Only after data exists |

**Architecture Decision Records to write before production implementation:**

| ADR | Decision |
|---|---|
| ADR-001 | Deterministic control-plane ownership |
| ADR-002 | FSM lifecycle + bounded DAG execution |
| ADR-003 | SQLite state + append-only event log |
| ADR-004 | Provider adapters and capability negotiation |
| ADR-005 | Structured artifact contracts |
| ADR-006 | Multidimensional risk model |
| ADR-007 | Context Compiler and provenance |
| ADR-008 | Canonical Markdown memory |
| ADR-009 | Semantic memory deferred |
| ADR-010 | Git worktree isolation |
| ADR-011 | Dirty-working-copy policy |
| ADR-012 | Action Broker architecture |
| ADR-013 | Sandbox backend abstraction |
| ADR-014 | Default-deny secrets/network |
| ADR-015 | MCP trust and pinning |
| ADR-016 | Deterministic verification ownership |
| ADR-017 | Independent review context |
| ADR-018 | Finding adjudication |
| ADR-019 | Human-action gates |
| ADR-020 | Checkpoint/recovery semantics |
| ADR-021 | Usage/token accounting semantics |
| ADR-022 | Internal telemetry + OTel mapping |
| ADR-023 | Evaluation-before-optimization policy |
| ADR-024 | Workflow/model/prompt versioning |
| ADR-025 | Plugin trust and discovery policy |

**Prioritized backlog:**

| Priority | Item | Value | Risk reduced | Dependencies | Complexity |
|---|---|---|---|---|---|
| P0 | Core artifact/event schemas | Very high | State ambiguity | None | M |
| P0 | FSM + transition invariants | Critical | Workflow drift | schemas | L |
| P0 | SQLite transactions/checkpoints | Critical | Crash/data loss | FSM | M |
| P0 | Worktree manager | Critical | User-code damage | Git | M |
| P0 | Action Broker | Critical | Host compromise | policy | XL |
| P0 | Worker adapter contract | Very high | Provider coupling | schemas | M |
| P0 | Claude CLI adapter | High | — | adapter | M |
| P0 | Codex CLI adapter | High | — | adapter | M |
| P0 | Risk vector | High | Under-classification | discovery | M |
| P0 | Verification interface | Critical | False success | project detector | L |
| P0 | Context Packet/provenance | High | Prompt/context errors | artifacts | M |
| P1 | Serena integration | High | Token waste | Context Compiler | M |
| P1 | Model/effort router | High | Cost/quality imbalance | workers/risk | M |
| P1 | Review/adjudication | High | Escaped defects | verification | L |
| P1 | Secret/dependency scans | High | Security | verification | S/M |
| P1 | TUI/live events | High UX | Operability | event system | M |
| P1 | Offline eval harness | Critical long term | Unsafe optimization | core workflow | L |
| P2 | Repomix integration | Medium | Oversized context | context | S |
| P2 | Semgrep adapters | Medium/high | Security | verification | M |
| P2 | Strict container sandbox | High for R3 | Host risk | Action Broker | L |
| P2 | Parallel DAG executor | High speed | — | stable sequential flow | L |
| P2 | OTel exporter | Medium | Observability | internal events | M |
| P2 | DuckDB analytics | Medium | Analytics performance | data volume | S |
| P3 | Mem0/Qdrant | Unproven initially | Historical recall | large corpus | L |
| P3 | Learned routing | Potentially high | — | substantial eval data | XL |
| P3 | Remote/team control plane | Outside initial goal | — | auth/cloud | XL |

## Decision register and final recommendations

The thirty explicit research questions resolve as follows.

| Question | Decision |
|---|---|
| Biggest missing elements | Action Broker, transactional recovery, risk vector, context trust/provenance, capability negotiation, eval system, verification plugins, adjudication, dirty-worktree strategy, plugin supply-chain controls |
| Over-engineered choices | Semantic memory in v1, heavy workflow frameworks, specialist review everywhere, complex agent swarms, vector DB, enterprise policy engine |
| Under-engineered choices | Security boundary, recovery, risk, Git isolation, evals, context provenance |
| Required v1 | Deterministic FSM, worktrees, provider CLI adapters, context compiler, verification, security broker, review, telemetry, evals |
| Delay | Vector memory, learned routing, cloud/team features, autonomous deploy, advanced parallelism |
| Workflow engine | **Custom FSM + SQLite + small internal DAG executor** |
| Serena | **Yes, best current primary semantic integration for this design; keep replaceable** |
| Repomix | **Yes, optional secondary snapshot/compression provider** |
| Semantic/vector memory | **No in v1** |
| Sandbox | Layered provider-native + Action Broker; bubblewrap/rootless OCI strict backends; optional stronger isolation |
| Git design | Private per-run branch/worktree; never edit user's main checkout automatically |
| Review by risk | None/minimal R0; one independent R1; strong risk-triggered R2; specialist + second confirmation R3 |
| Testing by risk | Existing/targeted R0; independent plan + builder tests R1; broader independent plan R2; invariant/high-assurance R3 |
| Model routing | Logical capabilities + risk floors + observed eval performance |
| Effort routing | Risk/complexity/uncertainty/failure based; max only narrow escalation |
| Quota routing | Ordinal pressure; only change equivalent/optional routing, never mandatory safety |
| Context budgets | Adaptive progressive budgets, not hard universal constants |
| Context quality | Evidence coverage, missed dependencies, precision, duplication, staleness, useful-token ratio |
| Telemetry | Full lifecycle events, tokens, context, time, tool/action, workspace, verification, review, human gates |
| Optimization metrics | Verified quality first, time-to-READY second, tokens per verified outcome third |
| Directly incorporate | Git, SQLite, Pydantic, Serena, Gitleaks, OSV, optional Repomix/Semgrep |
| Borrow ideas | Aider repo-map, Agentless, SWE-agent, Temporal, LangGraph, SLSA |
| `aidev` must implement | FSM, risk, context compiler, router, action broker, workspace manager, evidence/review orchestration |
| Non-negotiable security | Default deny, workspace isolation, no secret inheritance, network control, human production gates, provenance |
| Biggest failures | Prompt/tool injection, bad context, silent risk downgrade, destructive shell, false review, wrong tests, crash state loss, memory poisoning, model drift, dependency compromise |
| Dangerous anti-patterns | Giant agent, self-review, unlimited access, whole-repo prompts, blind retries, swarms, auto-memory, cheapest/frontier everywhere |
| Evaluation | Hidden offline corpus + paired workflows + real post-merge outcomes |
| Safe learning | Candidate knowledge + evidence + stale/contradiction checks + human approval for critical knowledge |
| Token optimization | Retrieval first, caching/dedup second, routing/effort third, semantic memory much later |
| Best 2–3 year architecture | Thin deterministic stable control plane + replaceable capability workers + pluggable context/security/eval adapters |

### Final architecture decision table

| Area | Current proposal | Recommended decision | Confidence | Evidence quality |
|---|---|---|---|---|
| Control plane | deterministic | **Keep** | Very high | Strong |
| Workflow | FSM | FSM + internal DAG | Very high | Strong systems reasoning |
| Daemon | `aidevd` | **Keep** | High | Strong |
| Risk | R0–R3 | Vector + derived class | Very high | Strong security reasoning |
| Context | Context Compiler | **Keep, add trust/provenance** | Very high | Strong |
| Serena | primary context | Integrate but abstract | High | Good |
| Repomix | context tool | Optional structural/snapshot provider | High | Good |
| Memory | Markdown + later vectors | Markdown + FTS5 v1 | Very high | Good |
| Vector DB | considered | Delay | Very high | Good |
| Worker models | explicit Claude/Codex | Logical capabilities + current mapping | Very high | Strong |
| Subscription access | CLI | **Prefer CLI adapters** | High | Official provider docs |
| Structured artifacts | many types | Consolidate to ~9 payload families | High | Engineering judgment |
| Storage | SQLite | SQLite WAL + events + snapshots | Very high | Strong |
| Full event sourcing | possible | Reject | High | Engineering judgment |
| Analytics | SQLite | DuckDB later | High | Strong |
| Workspace | Git worktrees | **Use** | Very high | Official Git docs |
| Dirty working tree | unspecified | Never mutate; work from HEAD by default | Very high | Strong |
| Sandbox | unspecified | Backend abstraction + Action Broker | Very high | Strong security guidance |
| Policy | policy engine | Typed built-ins + YAML; no OPA v1 | High | Good |
| MCP | integration | Allowlist/pin/isolate/untrusted output | Very high | Strong |
| Tests | verification engine | Risk-adaptive deterministic suite | Very high | Strong |
| AI test generation | implicit | Test-plan independent; generated tests verified | High | Empirical evidence |
| Review | independent | Fresh context + evidence + risk specialists | Very high | Good |
| Cross-provider review | preferred | Preference, not invariant | Medium | Evidence insufficient |
| Multi-agent swarms | possible | Reject default | High | Good |
| Quota | router input | Ordinal pressure only | High | Provider constraints |
| Telemetry | broad | Internal stable schema + OTel export | Very high | Strong |
| Raw prompt logging | likely | Off by default | Very high | Security guidance |
| Eval framework | planned | Make v1 requirement | Very high | Strong |
| Learned routing | future | V2/V3 after sufficient data | Very high | Strong |
| Production deployment | human gate | **Keep human-controlled** | Very high | Strong |

### Top decisions to lock before coding

| | Decision |
|---:|---|
| 1 | `aidev`, not an LLM, owns workflow state |
| 2 | Custom FSM + SQLite is the v1 workflow runtime |
| 3 | Every AI worker is replaceable behind a capability adapter |
| 4 | All worker side effects cross the Action Broker |
| 5 | Every run uses an isolated Git worktree |
| 6 | Context is stage-compiled with provenance and trust labels |
| 7 | Risk is multidimensional and can only be silently escalated, never downgraded |
| 8 | READY requires deterministic evidence |
| 9 | Important review is fresh-context and evidence-driven |
| 10 | Workflow changes require evaluation before adoption |

### Things not to build yet

| | Delay |
|---:|---|
| 1 | Vector database |
| 2 | Mem0/Qdrant production integration |
| 3 | LangGraph control plane |
| 4 | Temporal runtime |
| 5 | OPA/Rego policy layer |
| 6 | Agent swarm engine |
| 7 | Automatic production deployment |
| 8 | Learned model router |
| 9 | Remote/team cloud platform |
| 10 | Plugin marketplace |

### Failure modes to design against

| | Failure mode |
|---:|---|
| 1 | Repository prompt injection triggers dangerous tool action |
| 2 | Worker reads/exfiltrates credentials |
| 3 | Bad context causes confident wrong implementation |
| 4 | Risk engine underclassifies a critical change |
| 5 | Generated tests encode incorrect behavior |
| 6 | Reviewer false positive causes regression |
| 7 | Multiple writers produce semantic merge conflict |
| 8 | Crash leaves workflow state inconsistent |
| 9 | Bad generated memory poisons future tasks |
| 10 | Provider/model update changes quality without detection |

### Highest-value optimization opportunities

| | Optimization |
|---:|---|
| 1 | Symbol-first context retrieval |
| 2 | Progressive retrieval rather than giant prompts |
| 3 | Context deduplication |
| 4 | Stable cache-friendly prompt prefixes |
| 5 | Fresh contexts between stages |
| 6 | Terra/Luna-class routing for proven low-risk work |
| 7 | Adaptive reasoning effort |
| 8 | Risk-triggered rather than universal review |
| 9 | Parallel deterministic checks/read-only analysis |
| 10 | Historical eval-driven routing changes |

### Metrics that should dominate the dashboard

| | Metric |
|---:|---|
| 1 | Post-merge defect/revert rate |
| 2 | First-pass deterministic verification rate |
| 3 | BLOCKER/HIGH review finding rate |
| 4 | Repair-loop count |
| 5 | Time to READY |
| 6 | Tokens per verified task by risk |
| 7 | Context tokens per successful stage |
| 8 | Missed-dependency/context rate |
| 9 | Escalation and human-intervention rates |
| 10 | Quality change by workflow/model version |

The decisive architecture is therefore:

```text
                     USER INTENT
                         │
                         ▼
                  DETERMINISTIC
                  CONTROL PLANE
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       POLICY          STATE          RISK
          │              │              │
          └──────────────┼──────────────┘
                         │
                         ▼
                   CONTEXT COMPILER
                         │
             provenance + trust + budget
                         │
                         ▼
                REPLACEABLE AI WORKERS
                Claude / Codex / future
                         │
                         ▼
                    ACTION BROKER
                         │
               least privilege sandbox
                         │
                         ▼
                  ISOLATED WORKSPACE
                         │
                         ▼
              DETERMINISTIC EVIDENCE
                         │
                         ▼
                INDEPENDENT REVIEW
                         │
                         ▼
                     HUMAN GATE
                         │
                         ▼
                       READY

       ╔══════════════════════════════════╗
       ║ events / checkpoints / tokens   ║
       ║ context / provenance / evals    ║
       ║ security / knowledge / metrics  ║
       ╚══════════════════════════════════╝
```

This architecture should remain durable even as model names change: **the stable product is not Claude + Codex orchestration; it is a deterministic, evidence-driven, context-aware development control plane whose cognitive workers happen to be Claude and Codex today.** That distinction is the key to keeping `aidev` reliable, fast, measurable and economically efficient over the next several model generations.