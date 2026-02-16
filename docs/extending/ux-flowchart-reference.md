# ux-flowchart-generate — Reference Material

> Extracted from `skills/ux-flowchart-generate/SKILL.md` for token optimization.
> Contains Mermaid syntax conventions, quality gates, and confidence scoring.

---

## Node Shapes (strict mapping)

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

---

## Node ID Conventions

- Format: `{prefix}_{descriptive_name}` using lowercase snake_case
- Prefixes: `entry_`, `step_`, `dec_`, `success_`, `err_`, `load_`, `ext_`, `data_`, `sub_`
- **Never** use `end` as a node ID (Mermaid reserved word)
- **Never** start a node ID with `o` or `x` immediately adjacent to `---` (creates unintended shapes)
- Keep IDs stable across regenerations — use semantic names, not sequential numbering
- Example: `entry_login`, `dec_email_valid`, `err_timeout`

---

## Edge Conventions

| Edge Type | Syntax | Label Format |
|---|---|---|
| Happy path | `-->` | Verb or "success" |
| Error/fallback path | `-.->` | Error condition |
| Critical path emphasis | `==>` | Max 1-2 per diagram |
| Decision Yes | `-->` | `\|Yes\|` |
| Decision No | `-->` | `\|No\|` |
| Mismatch (mixed mode) | `-.->` + mismatch class | `\|⚠️ PRD ref\|` |

- **All edges MUST have labels** — even if just `|success|` or `|next|`
- Decision edges: always `-->|Yes|` and `-->|No|` (not True/False, not unlabeled)

---

## Style Definitions (always include)

```
classDef error fill:#FEE2E2,stroke:#DC2626,color:#991B1B
classDef success fill:#D1FAE5,stroke:#059669,color:#065F46
classDef decision fill:#FEF3C7,stroke:#D97706,color:#92400E
classDef entry fill:#DBEAFE,stroke:#2563EB,color:#1E40AF
classDef mismatch fill:#FEF3C7,stroke:#DC2626,stroke-width:3px,stroke-dasharray:5 5
```

---

## Quality Gate Checklist

Run ALL checks before writing output.

### Machine-checkable gates (hard fail)

```
[ ] SYNTAX_VALID       — Mermaid parses without error
[ ] NODE_CAP           — Total nodes ≤ 25 (per diagram)
[ ] EDGE_CAP           — Total edges ≤ 50 (per diagram)
[ ] TEXT_CAP           — Mermaid source < 40,000 characters
[ ] CYCLOMATIC         — (edges − nodes + 2) ≤ 15
[ ] NO_ORPHANS         — Every defined node appears in ≥1 edge
[ ] DECISION_COMPLETE  — Every diamond node has ≥2 outgoing edges
[ ] ENTRY_EXISTS       — ≥1 node with 0 incoming edges
[ ] EXIT_EXISTS        — ≥1 node with 0 outgoing edges
[ ] ERROR_PATHS        — ≥1 edge labeled with error/failure/retry/deny/invalid
[ ] LABELS_PRESENT     — Every edge has a non-empty label
[ ] SEMANTIC_IDS       — All node IDs match [a-z]+_[a-z_0-9]+
[ ] NO_RESERVED        — No node ID equals "end" (case-insensitive)
[ ] DIRECTION_SET      — Diagram declares explicit direction (TD or LR)
[ ] STYLES_DEFINED     — classDef for error, success, decision, entry present
[ ] METADATA_PRESENT   — @generated-by, @sources, @generated comments exist
[ ] EVIDENCE_COMPLETE  — Every node in diagram has a row in evidence map
```

### Machine-checkable gates (warn, don't fail)

```
[ ] SUBGRAPH_THRESHOLD — If nodes > 15, subgraphs should be used
[ ] NO_UNKNOWN_ONLY    — Evidence map has ≥1 node with confidence ≠ ⚫
```

### Human-review flags (include as notes in output)

```
[ ] AUDIENCE_FIT            — No code jargon in node labels (for userflow goal)
[ ] ABSTRACTION_CONSISTENT  — All nodes at same level of abstraction
[ ] FLOW_DIRECTION          — No backward arrows crossing >2 levels
[ ] UI_STATES_COMPLETE      — All 5 states represented for data-dependent screens
[ ] MISMATCH_FLAGGED        — PRD-vs-code discrepancies called out
```

If any hard-fail gate fails:
1. Identify the failing gate(s)
2. Fix the issue (e.g., split diagram if NODE_CAP exceeded, add missing error paths)
3. Re-validate until all gates pass

---

## Confidence Scoring (automated derivation — do not override manually)

| Level | Symbol | Criteria |
|---|---|---|
| **High** | 🟢 | Node traced to PRD section AND code symbol AND passing test |
| **Medium** | 🟡 | Node traced to PRD OR code (not both), or missing test |
| **Low** | 🔴 | No direct code trace. Inferred from naming conventions, file structure, or PRD language |
| **Unknown** | ⚫ | Not yet assessed. New or changed requirement awaiting analysis |

Derivation rules:
- `prd_ref` + `code_path` + `test_path` all present → 🟢 High
- `prd_ref` + `code_path` (no test) → 🟡 Medium
- Only `prd_ref` OR only `code_path` → 🟡 Medium
- Neither `prd_ref` nor `code_path` → 🔴 Low
- Not yet checked → ⚫ Unknown

---

## GitHub Rendering Constraints

These are hard limits (GitHub runs Mermaid v11.4.1):
- Max characters: 50,000 per Mermaid block. Target < 40,000 for headroom
- Max edges: 500 per graph. Target ≤ 50
- Security level: strict. No `click` events, no tooltips, no JavaScript callbacks, no FontAwesome
- Layout engine: Dagre only. ELK is unavailable on GitHub
- HTML in labels stripped by DOMPurify. Use Markdown strings instead
- Emoji in node labels may break rendering — use sparingly
