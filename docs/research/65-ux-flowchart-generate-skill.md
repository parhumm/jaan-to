---
name: ux-flowchart-generate
description: >
  Generate a GitHub-renderable Markdown Mermaid flowchart from PRD / docs / codebase,
  with an Evidence Map (node → sources), confidence scoring, and an Unknowns list.
  Supports generating new diagrams and updating/diffing existing ones.
  Outputs two files: flowchart.md (diagram + metadata) and evidence-map.md (traceability table).
---

# UX Flowchart Generate

Generate a GitHub-renderable Markdown Mermaid flowchart from PRDs, docs, codebases, or any
combination — complete with an Evidence Map that traces every node to its source, confidence
scoring, and a structured Unknowns list. Also supports updating existing diagrams when
sources change.

## Command Signature

```
/ux-flowchart-generate [source_type] [paths...] [goal] [scope?]
```

**Parameters:**

| Param | Required | Values | Default |
|---|---|---|---|
| `source_type` | Yes | `prd`, `doc`, `repo`, `mixed` | — |
| `paths` | Yes | Space-separated file/directory paths | — |
| `goal` | Yes | `userflow`, `systemflow`, `architecture`, `stateflow` | `userflow` |
| `scope` | No | Free text to narrow scope (e.g., "checkout only", "auth module") | Entire source |

**Output:**

```
$JAAN_OUTPUTS_DIR/ux/diagrams/{slug}/flowchart.md
$JAAN_OUTPUTS_DIR/ux/diagrams/{slug}/evidence-map.md
```

The `{slug}` is derived from the flow name (kebab-cased, e.g., `password-reset`, `checkout-flow`).

---

## Execution Pipeline

Follow these phases in order. Do not skip phases.

### Phase 0: Diff Check (update mode only)

If `flowchart.md` already exists at the output path:

1. Read the `@sources` comment from the existing Mermaid block.
2. Check if any listed source files have changed since the `@generated` timestamp.
3. **If <30% of nodes affected by changes** → incremental update. Preserve all content
   between `%% ===== MANUAL (DO NOT AUTO-EDIT) =====` markers.
4. **If ≥30% of nodes affected** → full regeneration with manual-section preservation warning.
5. For incremental updates, highlight changes using classDef styling:
   - Added nodes: `classDef added fill:#D1FAE5,stroke:#059669`
   - Removed nodes: shown in a "Removed in this update" note (do not leave orphan nodes)
   - Modified nodes: `classDef modified fill:#FEF3C7,stroke:#D97706`
6. Include a `## Changelog` section at the bottom showing what changed and why.

### Phase 1: Parse Sources

Based on `source_type`, extract entities:

| Source type | Extract |
|---|---|
| `prd` / `doc` | Screens, user actions, decisions, error cases, permissions, stated requirements |
| `repo` | API routes, page/component exports, middleware chains, service calls, error handlers, state machines |
| `mixed` | Both of the above, cross-referenced |

Build an intermediate graph model:
- **Nodes**: each entity becomes a node with a semantic ID, label, and source reference
- **Edges**: connections derived from document flow, code call chains, or explicit cross-references
- **Gaps**: entities found in PRD but not in code (or vice versa) are flagged immediately

### Phase 2: Select Diagram Type

| Input available | Goal | Diagram type |
|---|---|---|
| PRD only | `userflow` | `flowchart` — decision branches, multiple entry/exit |
| PRD only | `stateflow` | `stateDiagram-v2` — when >4 distinct states with non-trivial transitions |
| Codebase only | `systemflow` | `flowchart` — derived from code structure, API routes, service calls |
| Codebase only | `architecture` | `flowchart` with subgraphs per service/module |
| Mixed | `userflow` | `flowchart` — user-facing paths from PRD, system detail from code, mismatch callouts |
| Mixed | any | Merge both; highlight mismatches with `classDef mismatch` |

### Phase 3: Generate Mermaid

Apply ALL of the following rules. These are non-negotiable.

#### Direction

- **Default: `TD` (top-down)** for user flows with decision trees and hierarchical branching.
- **Use `LR` (left-to-right)** when flow is primarily linear/sequential (pipelines, wizards, CI/CD)
  OR when the diagram has >3 parallel branches at the same level (prevents vertical sprawl).

#### Node Shapes (strict mapping)

| UX Concept | Mermaid Shape | Syntax | When to use |
|---|---|---|---|
| Entry point / trigger | Stadium (pill) | `id([Label])` | First node(s), external triggers, deep links |
| User action / process | Rectangle | `id[Label]` | Any action step |
| Decision / condition | Diamond | `id{Label?}` | Binary branch points (always end label with `?`) |
| Success / completion | Double circle | `id(((Label)))` | Terminal success states |
| Error state | Rectangle + error class | `id[Error: Label]:::error` | All error/failure states |
| Loading / async wait | Rounded rectangle | `id(Label)` | Async operations, API calls in progress |
| External system / API | Subroutine | `id[[Label]]` | Third-party services, external APIs |
| Data store | Cylinder | `id[(Label)]` | Databases, caches, file storage |
| Sub-process reference | Subroutine | `id[[See: Detail Diagram]]` | Links to split-out detail diagrams |

#### Node ID Conventions

- Format: `{prefix}_{descriptive_name}` using lowercase snake_case.
- Prefixes: `entry_`, `step_`, `dec_`, `success_`, `err_`, `load_`, `ext_`, `data_`, `sub_`.
- **Never** use `end` as a node ID (Mermaid reserved word).
- **Never** start a node ID with `o` or `x` immediately adjacent to `---` (creates unintended shapes).
- Keep IDs stable across regenerations — use semantic names, not sequential numbering.

#### Edge Conventions

- **Solid arrows** (`-->`) for primary/happy path.
- **Dotted arrows** (`-.->`) for error/fallback paths.
- **Thick arrows** (`==>`) for critical path emphasis (max 1–2 per diagram).
- **All edges MUST have labels** — even if just `|success|` or `|next|`.
- Decision edges: always `-->|Yes|` and `-->|No|` (not True/False, not unlabeled).

#### Grouping

- Apply `subgraph` when diagram has **>15 nodes**.
- Group by **user-facing domain** (auth, payment, onboarding) not technical layer.
- Name subgraphs with readable labels: `subgraph sg_auth ["Authentication"]`.
- Maximum **5 subgraphs** per diagram; more means the diagram should be split.

#### Mandatory Checklist (every diagram)

Every generated diagram MUST include:

- [ ] At least 1 entry point (stadium shape)
- [ ] At least 1 success terminal (double circle)
- [ ] At least 1 error path from every decision node
- [ ] Loading states for any async operation
- [ ] Permission/auth checks where applicable
- [ ] All 5 UI states for data-dependent screens: ideal, empty, error, loading, partial
      (when evidence exists — flag as Unknown if not mentioned in sources)

#### Style Definitions (always include)

```mermaid
classDef error fill:#FEE2E2,stroke:#DC2626,color:#991B1B
classDef success fill:#D1FAE5,stroke:#059669,color:#065F46
classDef decision fill:#FEF3C7,stroke:#D97706,color:#92400E
classDef entry fill:#DBEAFE,stroke:#2563EB,color:#1E40AF
classDef mismatch fill:#FEF3C7,stroke:#DC2626,stroke-width:3px,stroke-dasharray:5 5
```

#### Splitting Rules

Split into "Overview + Detail" diagrams when ANY threshold is exceeded:

| Metric | Threshold | Action |
|---|---|---|
| Node count | >25 | Split — overview shows subprocesses as subroutine nodes linking to detail diagrams |
| Edge count | >50 | Split |
| Cyclomatic complexity | >15 (edges − nodes + 2) | Split |
| Parallel branches | >8 at any single level | Split |
| Mermaid source chars | >20,000 | Split (headroom below GitHub's 50K limit) |

When splitting, the overview diagram uses `[[See: {name}-detail.md]]` nodes, and each
detail diagram is a separate file in the same directory.

#### Source Format (Mermaid block structure)

Structure the Mermaid block in this exact order for clean git diffs:

```
%% @generated-by: jaan-to:ux-flowchart-generate
%% @sources: {comma-separated source file paths}
%% @generated: {ISO-8601 timestamp}
%% @version: {semver or YYYY-MM-DD}

%% === NODES ===
{all node declarations, grouped by subgraph if applicable}

%% === EDGES: Happy Path ===
{primary flow edges}

%% === EDGES: Error Paths ===
{error/fallback edges}

%% === EDGES: Mismatch (PRD ↔ Code) ===
{only in mixed mode — edges for spec-vs-reality discrepancies}

%% ===== MANUAL (DO NOT AUTO-EDIT) =====
{preserved across regenerations}
%% ===== END MANUAL =====

%% === STYLES ===
{classDef declarations and class assignments}
```

### Phase 4: Build Evidence Map

For every node in the diagram, create a row in `evidence-map.md`:

| Column | Description | Required |
|---|---|---|
| Node ID | Exact ID from diagram | Yes |
| Node Label | Human-readable label | Yes |
| PRD Reference | Section/heading in PRD (e.g., `PRD §2.1`) | If source includes PRD |
| Code Path | File path + line number (e.g., `src/auth.ts:42`) | If source includes code |
| Code Symbol | Function/class name (e.g., `AuthMiddleware.verify()`) | If source includes code |
| Test Path | Test file covering this node | If discoverable |
| Confidence | 🟢 High / 🟡 Medium / 🔴 Low / ⚫ Unknown | Yes |
| Status | `FOUND` / `INFERRED` / `MISMATCH` / `UNKNOWN` | Yes |
| Notes | Free text — why this confidence, what's missing | Yes |

#### Confidence Scoring (automated derivation — do not override manually)

| Level | Symbol | Criteria |
|---|---|---|
| **High** | 🟢 | Node traced to PRD section AND code symbol AND passing test. Automated verification exists. |
| **Medium** | 🟡 | Node traced to PRD OR code (not both). Manual verification only. Some links unvalidated. |
| **Low** | 🔴 | No direct code trace. Inferred from naming conventions, file structure, or PRD language. No test. |
| **Unknown** | ⚫ | Not yet assessed. New or changed requirement awaiting analysis. |

Confidence is derived from evidence completeness, not subjective judgment:
- `prd_ref` + `code_path` + `test_path` all present → 🟢 High
- `prd_ref` + `code_path` (no test) → 🟡 Medium
- Only `prd_ref` OR only `code_path` → 🟡 Medium
- Neither `prd_ref` nor `code_path` → 🔴 Low
- Not yet checked → ⚫ Unknown

### Phase 5: Identify Unknowns & Mismatches

Generate a structured Unknowns table:

| Column | Description |
|---|---|
| ID | Sequential: `U1`, `U2`, ... |
| Unknown | What couldn't be determined |
| Impact | 🔴 High / 🟡 Medium / 🟢 Low |
| Source Gap | What's missing (PRD silent? Code absent? Test missing?) |
| Suggested Resolution | Concrete next step to resolve |

**Mismatch callouts** (mixed mode only): when PRD specifies something the code doesn't
implement (or vice versa), add a `MISMATCH` row to the evidence map AND include the
mismatch as a dotted edge in the diagram with `:::mismatch` styling and a `⚠️` label.

### Phase 6: Validate (Quality Gates)

Run these checks before writing output. ALL must pass.

#### Machine-checkable gates (hard fail)

```
[ ] SYNTAX_VALID       — Mermaid parses without error
[ ] NODE_CAP           — Total nodes ≤ 25 (per diagram)
[ ] EDGE_CAP           — Total edges ≤ 50 (per diagram)
[ ] TEXT_CAP            — Mermaid source < 40,000 characters
[ ] CYCLOMATIC          — (edges − nodes + 2) ≤ 15
[ ] NO_ORPHANS          — Every defined node appears in ≥1 edge
[ ] DECISION_COMPLETE   — Every diamond node has ≥2 outgoing edges
[ ] ENTRY_EXISTS         — ≥1 node with 0 incoming edges
[ ] EXIT_EXISTS          — ≥1 node with 0 outgoing edges
[ ] ERROR_PATHS          — ≥1 edge labeled with error/failure/retry/deny/invalid
[ ] LABELS_PRESENT       — Every edge has a non-empty label
[ ] SEMANTIC_IDS         — All node IDs match [a-z]+_[a-z_0-9]+
[ ] NO_RESERVED          — No node ID equals "end" (case-insensitive)
[ ] DIRECTION_SET        — Diagram declares explicit direction (TD or LR)
[ ] STYLES_DEFINED       — classDef for error, success, decision, entry present
[ ] METADATA_PRESENT     — @generated-by, @sources, @generated comments exist
[ ] EVIDENCE_COMPLETE    — Every node in diagram has a row in evidence map
```

#### Machine-checkable gates (warn, don't fail)

```
[ ] SUBGRAPH_THRESHOLD  — If nodes > 15, subgraphs should be used
[ ] NO_UNKNOWN_ONLY     — Evidence map has ≥1 node with confidence ≠ ⚫
```

#### Human-review flags (include as notes in output)

```
[ ] AUDIENCE_FIT            — No code jargon in node labels (for userflow goal)
[ ] ABSTRACTION_CONSISTENT  — All nodes at same level of abstraction
[ ] FLOW_DIRECTION          — No backward arrows crossing >2 levels
[ ] UI_STATES_COMPLETE      — All 5 states represented for data-dependent screens
[ ] MISMATCH_FLAGGED        — PRD-vs-code discrepancies called out
```

### Phase 7: Write Output

Write two files:

#### File 1: `flowchart.md`

```markdown
# UX Flowchart: {Flow Name}

> **Skill:** `/ux-flowchart-generate`
> **Source(s):** `{source_type}` — {comma-separated paths}
> **Goal:** {userflow|systemflow|architecture|stateflow}
> **Generated:** {ISO-8601 timestamp}
> **Confidence:** {Overall: 🟢|🟡|🔴} — {one-line rationale}

## Overview

{2-3 sentences: what this flow covers, primary actor, success outcome.}

## Diagram

```mermaid
flowchart {TD|LR}
    %% @generated-by: jaan-to:ux-flowchart-generate
    %% @sources: {paths}
    %% @generated: {timestamp}
    %% @version: 1.0.0

    %% === NODES ===
    ...

    %% === EDGES: Happy Path ===
    ...

    %% === EDGES: Error Paths ===
    ...

    %% ===== MANUAL (DO NOT AUTO-EDIT) =====
    %% ===== END MANUAL =====

    %% === STYLES ===
    classDef error fill:#FEE2E2,stroke:#DC2626,color:#991B1B
    classDef success fill:#D1FAE5,stroke:#059669,color:#065F46
    classDef decision fill:#FEF3C7,stroke:#D97706,color:#92400E
    classDef entry fill:#DBEAFE,stroke:#2563EB,color:#1E40AF
    ...
```

## Unknowns & Gaps

| # | Unknown | Impact | Source Gap | Suggested Resolution |
|---|---|---|---|---|
| U1 | ... | ... | ... | ... |

## Diagram Metrics

| Metric | Value | Threshold |
|---|---|---|
| Nodes | {N} | ≤ 25 |
| Edges | {N} | ≤ 50 |
| Cyclomatic complexity | {N} | ≤ 15 |
| Subgraphs | {N} | ≤ 5 |
| Mermaid chars | {N} | < 40,000 |
| Evidence coverage | {N}% nodes at 🟢 | Target: ≥ 50% |

## Validation

{List of quality gates with pass/warn/fail status.}

---
*→ Next skills: `ux:wireframe-notes`, `dev:fe-state-map`, `data:event-spec`*
*→ Evidence detail: see `evidence-map.md` in this directory*
```

#### File 2: `evidence-map.md`

```markdown
# Evidence Map: {Flow Name}

> Companion to `flowchart.md` — traces every diagram node to its source.
> **Generated:** {ISO-8601 timestamp}

## Confidence Key

| Level | Symbol | Criteria |
|---|---|---|
| High | 🟢 | PRD + code + test |
| Medium | 🟡 | PRD or code (not both), or missing test |
| Low | 🔴 | Inferred only — no direct trace |
| Unknown | ⚫ | Not yet assessed |

## Node Evidence

| Node ID | Label | PRD Ref | Code Path | Code Symbol | Test Path | Confidence | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| `entry_start` | ... | PRD §X.X | `src/...` | `Fn()` | `tests/...` | 🟢 | FOUND | ... |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

## Mismatches

{Only present in `mixed` source mode. List PRD-vs-code discrepancies.}

| # | Description | PRD Says | Code Does | Severity | Recommendation |
|---|---|---|---|---|---|
| M1 | ... | ... | ... | 🔴 High | ... |

## Source File Index

{List of all source files analyzed, with last-modified timestamps. Used by Phase 0
for staleness detection on subsequent runs.}

| File Path | Last Modified | Nodes Derived |
|---|---|---|
| `docs/prd.md` | {timestamp} | entry_start, dec_auth, ... |
| `src/auth.ts` | {timestamp} | step_verify, err_invalid, ... |
```

---

## GitHub Rendering Constraints

These are hard limits. Violating them produces broken or missing diagrams.

- **Mermaid version on GitHub: v11.4.1** (as of early 2025). Do not use syntax from newer versions.
- **Max characters: 50,000** per Mermaid block. Skill targets < 40,000 for headroom.
- **Max edges: 500** per graph. Skill targets ≤ 50.
- **Security level: strict.** No `click` events, no tooltips, no JavaScript callbacks, no FontAwesome.
- **Layout engine: Dagre only.** ELK is unavailable on GitHub. Complex diagrams may have overlapping edges.
- **HTML in labels stripped** by DOMPurify. Use Markdown strings (`"\`**bold**\`"`) instead.
- **Emoji in node labels** may break rendering on some GitHub environments — use sparingly.

## Node Label Guidelines

- Use **verb-noun phrasing**: "Submit form", "Verify email", "Check permissions".
- No ALL CAPS, no abbreviations without context.
- For `userflow` goal: use user-facing language only. "User enters password" not "bcrypt.hash()".
- For `systemflow` goal: technical language is acceptable. "JWT.verify()" is fine.
- For `mixed` goal: user-facing labels on nodes, technical detail in evidence map.
- Decision labels always end with `?` — "Email registered?", "Token valid?".
- Error labels always start with "Error:" — "Error: Payment failed", "Error: Session expired".

## Failure Modes to Guard Against

| Failure Mode | How the Skill Prevents It |
|---|---|
| **Hallucinated nodes** | Every node requires an evidence map entry. Nodes without source traces get 🔴 Low confidence and are flagged. |
| **Missing error paths** | Quality gate: DECISION_COMPLETE + ERROR_PATHS. At least 1 error edge per decision. |
| **Spaghetti diagram** | Node cap (25), cyclomatic limit (15), branch limit (8) → auto-split. |
| **Stale diagram** | Phase 0 diff check on re-runs. `@sources` metadata enables staleness detection. |
| **Overly technical labels** | Audience check based on `goal` parameter. `userflow` enforces user-facing language. |
| **Mixed abstraction** | One diagram = one abstraction level. Never mix "Click button" with "Execute SQL query". |
| **Manual edits destroyed** | `MANUAL` markers preserved across regenerations. Abort if markers malformed. |
| **GitHub render failure** | Pre-validation: < 40K chars, < 50 edges, no `click`, no FontAwesome, Dagre-only layout. |
| **Confidence inflation** | Automated derivation from evidence columns. Cannot manually override to higher than evidence supports. |

## Downstream Skills

After generating a flowchart, the user typically proceeds to:

- **`ux:wireframe-notes`** — annotate wireframes with flow states and edge cases from this diagram
- **`dev:fe-state-map`** — derive frontend state machines from the flowchart's decision logic
- **`data:event-spec`** — generate analytics event specifications from flow nodes and transitions

---

## Examples

### Example A: PRD-only password reset

```
/ux-flowchart-generate prd docs/prd-auth.md goal=userflow scope="password reset"
```

Produces a flowchart with 12 nodes covering forgot-password → email → token → new-password → success,
with all nodes at 🔴 Low confidence (PRD-only, no code verification), and unknowns flagging
rate limiting, token format, and password complexity rules as unspecified.

### Example B: Repo-only auth middleware

```
/ux-flowchart-generate repo src/middleware/ goal=systemflow scope="auth"
```

Produces a system flow derived from code analysis: request → extract token → verify JWT →
check expiry → refresh → check role → proceed/deny. Nodes with tests get 🟢 High; nodes
without tests get 🟡 Medium. No PRD reference columns populated.

### Example C: Mixed checkout with mismatches

```
/ux-flowchart-generate mixed docs/prd-checkout.md src/checkout/ goal=userflow
```

Produces a user flow with mismatch callouts: PRD specifies guest checkout but code doesn't
implement it (dotted edge with ⚠️ label, `:::mismatch` style). Evidence map shows `MISMATCH`
status. Unknowns table recommends confirming with product whether guest checkout is descoped.
