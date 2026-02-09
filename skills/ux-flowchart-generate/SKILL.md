---
name: ux-flowchart-generate
description: Generate GitHub-renderable Mermaid flowcharts from PRD/docs/codebase with evidence maps and confidence scoring.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/ux/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [source_type] [paths...] [goal] [scope?]
---

# ux-flowchart-generate

> Generate GitHub-renderable Mermaid flowcharts from PRDs, docs, codebases, or any combination — with evidence maps tracing every node to its source, confidence scoring, and structured unknowns lists.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:ux-flowchart-generate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:ux-flowchart-generate.template.md` - Output templates (flowchart + evidence map)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional, auto-imported if exists)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`

## Input

**Flowchart Request**: $ARGUMENTS

Parse as: `[source_type] [paths...] [goal] [scope?]`

| Param | Required | Values | Default |
|---|---|---|---|
| `source_type` | Yes | `prd`, `doc`, `repo`, `mixed` | — |
| `paths` | Yes | Space-separated file/directory paths | — |
| `goal` | Yes | `userflow`, `systemflow`, `architecture`, `stateflow` | `userflow` |
| `scope` | No | Free text to narrow focus (e.g., "checkout only", "auth module") | Entire source |

- If all parameters provided → Proceed to Phase 1
- If partial → Ask for missing parameters
- If empty → Interactive wizard (ask source type, paths, goal)

**Output**:
```
$JAAN_OUTPUTS_DIR/ux/diagrams/{id}-{slug}/
  ├── {id}-flowchart-{slug}.md       # Diagram + unknowns + metrics
  └── {id}-evidence-map-{slug}.md    # Traceability table + mismatches
```

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:ux-flowchart-generate.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

If the file does not exist, continue without it.

Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for code parsing in `repo`/`mixed` modes

### Language Settings

**Read language preference** from `jaan-to/config/settings.yaml`:

1. Check for per-skill override: `language_ux-flowchart-generate` field
2. If no override, use the global `language` field
3. Resolve:

| Value | Action |
|-------|--------|
| Language code (`en`, `fa`, `tr`, etc.) | Use that language immediately |
| `"ask"` or field missing | Prompt: "What language do you prefer for conversation and reports?" — Options: "English" (default), "فارسی (Persian)", "Other (specify)" — then save choice to `jaan-to/config/settings.yaml` |

**Keep in English always**: technical terms, code snippets, file paths, variable names, YAML keys, command names, Mermaid syntax.

**Apply resolved language to**: all questions, confirmations, section headings, labels, and prose in output files for this execution.

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Validate Inputs & Detect Source Type

Parse $ARGUMENTS to identify source type, file paths, goal, and optional scope.

**For each path**:
- **If file path**: Use Read to validate file exists and is readable
- **If directory**: Use Glob to find relevant files:
  - PRD/doc: `**/*.md`, `**/*.txt`, `**/*.pdf`
  - Repo: Source files based on tech stack (see Step 2)
- **If empty**: Ask for file paths interactively

**Check for existing output** (update mode):
If `flowchart.md` already exists at the expected output path:
1. Read the `@sources` comment from the existing Mermaid block
2. Check if any listed source files have changed since the `@generated` timestamp
3. **If <30% of nodes affected** → incremental update mode. Preserve all content between `%% ===== MANUAL (DO NOT AUTO-EDIT) =====` markers
4. **If ≥30% of nodes affected** → full regeneration with manual-section preservation warning
5. For incremental updates, highlight changes using classDef styling:
   - Added nodes: `classDef added fill:#D1FAE5,stroke:#059669`
   - Removed nodes: shown in a "Removed in this update" note
   - Modified nodes: `classDef modified fill:#FEF3C7,stroke:#D97706`

Build input summary:
```
INPUT SUMMARY
════════════════════════════════════════
Source type: {prd|doc|repo|mixed}
Goal: {userflow|systemflow|architecture|stateflow}
Scope: {scope or "Entire source"}
Mode: {New | Update (incremental) | Update (full regen)}

Files to analyze: {N} files
  PRD/docs: {n} files
  Source code: {n} files
════════════════════════════════════════
```

## Step 2: Parse Sources & Build Intermediate Graph

Based on `source_type`, extract entities:

| Source type | Extract |
|---|---|
| `prd` / `doc` | Screens, user actions, decisions, error cases, permissions, stated requirements |
| `repo` | API routes, page/component exports, middleware chains, service calls, error handlers, state machines |
| `mixed` | Both of the above, cross-referenced |

**For `repo` / `mixed` modes** — code parsing patterns by tech stack:

Read `$JAAN_CONTEXT_DIR/tech.md` if available. Otherwise infer from file extensions.

| Language | Glob Patterns | Grep Patterns |
|---|---|---|
| TypeScript/JS | `**/routes/**/*.ts`, `**/api/**/*.ts`, `**/pages/**/*.tsx` | `export (const\|function)`, `router\.(get\|post\|put\|delete)`, `if \(`, `try {`, `catch \(` |
| Python | `**/views/**/*.py`, `**/api/**/*.py` | `def \w+\(`, `@app\.route\(`, `@router\.(get\|post)`, `try:`, `except` |
| Go | `**/handlers/**/*.go`, `**/api/**/*.go` | `func \w+\(`, `r\.GET\(\|r\.POST\(`, `if err != nil` |
| PHP | `**/controllers/**/*.php`, `**/routes/**/*.php` | `function \w+\(`, `Route::(get\|post)`, `try {`, `catch \(` |

Build an intermediate graph model:
- **Nodes**: each entity becomes a node with a semantic ID, label, and source reference
- **Edges**: connections derived from document flow, code call chains, or explicit cross-references
- **Gaps**: entities found in PRD but not in code (or vice versa) are flagged immediately

## Step 3: Select Diagram Type

| Input available | Goal | Diagram type |
|---|---|---|
| PRD only | `userflow` | `flowchart` — decision branches, multiple entry/exit |
| PRD only | `stateflow` | `stateDiagram-v2` — when >4 distinct states with non-trivial transitions |
| Codebase only | `systemflow` | `flowchart` — derived from code structure, API routes, service calls |
| Codebase only | `architecture` | `flowchart` with subgraphs per service/module |
| Mixed | `userflow` | `flowchart` — user-facing paths from PRD, system detail from code, mismatch callouts |
| Mixed | any | Merge both; highlight mismatches with `classDef mismatch` |

## Step 4: Plan Mermaid Structure

Before generating, plan the diagram:

1. **Node inventory**: List all planned nodes with IDs, labels, and shapes
2. **Edge plan**: List all planned connections with labels
3. **Subgraph grouping**: If >15 nodes, plan subgraph domains
4. **Splitting decision**: Check if any threshold will be exceeded:
   - Node count >25
   - Edge count >50
   - Cyclomatic complexity >15 (edges − nodes + 2)
   - Parallel branches >8 at any single level
   - Estimated Mermaid chars >20,000

If splitting needed, plan Overview + Detail diagram breakdown:
- Overview uses subprocess nodes: `sub_{name}[[See: {slug}-detail-{name}.md]]`
- Each detail diagram is a separate file in the same output directory

5. **Direction choice**:
   - **TD (top-down)**: Default for user flows with decision trees
   - **LR (left-to-right)**: For linear/sequential flows or >3 parallel branches

## Step 5: Clarify with User

Ask using AskUserQuestion (skip questions already answered by input):

1. **Audience**: "Who is the primary audience?"
   - Options: "Developers", "Designers", "Product managers", "QA engineers", "Stakeholders (mixed)"
   - Determines label language: technical vs user-facing

2. **Update mode** (if existing diagram detected): "How should I handle the existing diagram?"
   - Options: "Incremental update (preserve manual edits)", "Full regeneration", "New version alongside"

3. **Scope confirmation** (if scope was provided): "Narrowing to '{scope}' — should I include related error paths and edge cases, or only the happy path?"

---

# HARD STOP - Human Review Gate

Present planned diagram structure for approval:

```
DIAGRAM PLAN
════════════════════════════════════════
Source: {source_type} — {comma-separated paths}
Goal: {goal}
Scope: {scope or "Entire source"}
Diagram type: {flowchart | stateDiagram-v2}
Direction: {TD | LR}

PLANNED STRUCTURE:
  Nodes: {N} total ({N entry, N process, N decision, N success, N error})
  Edges: {N} total ({N happy, N error, N mismatch})
  Subgraphs: {N} ({names if applicable})
  Estimated complexity: Cyclomatic {N}

SPLITTING: {Not needed | Will split into {N} diagrams}

SOURCE COVERAGE:
  PRD sections analyzed: {N}/{total}
  Code files analyzed: {N}/{total}
  Gaps detected: {N} (entities in one source but not the other)

CONFIDENCE PREVIEW:
  Expected 🟢 High: {N} nodes
  Expected 🟡 Medium: {N} nodes
  Expected 🔴 Low: {N} nodes
  Expected ⚫ Unknown: {N} nodes
════════════════════════════════════════
```

> "Proceed with diagram generation? [y/edit/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

**If edit**: Ask "What should be changed?" and return to appropriate step
**If n**: Stop and ask for next steps

---

# PHASE 2: Generation (Write Phase)

## Step 6: Generate Slug

Generate slug from the flow name:
- Lowercase kebab-case
- Max 50 characters
- Example: "Password Reset Flow" → `password-reset-flow`

## Step 6.5: Generate ID and Folder Structure

Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

Generate sequential ID and output paths:
```bash
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/ux/diagrams"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

slug="{generated-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-flowchart-${slug}.md"
EVIDENCE_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-evidence-map-${slug}.md"
```

Preview output configuration:
> "**Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/ux/diagrams/{NEXT_ID}-{slug}/
> - Flowchart: {NEXT_ID}-flowchart-{slug}.md
> - Evidence map: {NEXT_ID}-evidence-map-{slug}.md"

## Step 7: Generate Mermaid Code

Apply ALL of the following rules. These are non-negotiable.

### Node Shapes (strict mapping)

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

### Node ID Conventions

- Format: `{prefix}_{descriptive_name}` using lowercase snake_case
- Prefixes: `entry_`, `step_`, `dec_`, `success_`, `err_`, `load_`, `ext_`, `data_`, `sub_`
- **Never** use `end` as a node ID (Mermaid reserved word)
- **Never** start a node ID with `o` or `x` immediately adjacent to `---` (creates unintended shapes)
- Keep IDs stable across regenerations — use semantic names, not sequential numbering
- Example: `entry_login`, `dec_email_valid`, `err_timeout`

### Node Label Guidelines

- Use **verb-noun phrasing**: "Submit form", "Verify email", "Check permissions"
- No ALL CAPS, no abbreviations without context
- For `userflow` goal: use user-facing language only. "User enters password" not "bcrypt.hash()"
- For `systemflow` goal: technical language is acceptable. "JWT.verify()" is fine
- For `mixed` goal: user-facing labels on nodes, technical detail in evidence map
- Decision labels always end with `?` — "Email registered?", "Token valid?"
- Error labels always start with "Error:" — "Error: Payment failed", "Error: Session expired"

### Edge Conventions

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

### Grouping

- Apply `subgraph` when diagram has **>15 nodes**
- Group by **user-facing domain** (auth, payment, onboarding) not technical layer
- Name subgraphs with readable labels: `subgraph sg_auth ["Authentication"]`
- Maximum **5 subgraphs** per diagram; more means the diagram should be split

### Style Definitions (always include)

```
classDef error fill:#FEE2E2,stroke:#DC2626,color:#991B1B
classDef success fill:#D1FAE5,stroke:#059669,color:#065F46
classDef decision fill:#FEF3C7,stroke:#D97706,color:#92400E
classDef entry fill:#DBEAFE,stroke:#2563EB,color:#1E40AF
classDef mismatch fill:#FEF3C7,stroke:#DC2626,stroke-width:3px,stroke-dasharray:5 5
```

### Mermaid Block Structure

Structure the Mermaid block in this exact order for clean git diffs:

```
flowchart {TD|LR}
    %% @generated-by: jaan-to:ux-flowchart-generate
    %% @sources: {comma-separated source file paths}
    %% @generated: {ISO-8601 timestamp}
    %% @version: 1.0.0

    %% === NODES ===
    {all node declarations, grouped by subgraph if applicable}

    %% === EDGES: Happy Path ===
    {primary flow edges}

    %% === EDGES: Error Paths ===
    {error/fallback edges}

    %% === EDGES: Mismatch (PRD ↔ Code) ===
    {only in mixed mode}

    %% ===== MANUAL (DO NOT AUTO-EDIT) =====
    {preserved across regenerations}
    %% ===== END MANUAL =====

    %% === STYLES ===
    classDef error fill:#FEE2E2,stroke:#DC2626,color:#991B1B
    classDef success fill:#D1FAE5,stroke:#059669,color:#065F46
    classDef decision fill:#FEF3C7,stroke:#D97706,color:#92400E
    classDef entry fill:#DBEAFE,stroke:#2563EB,color:#1E40AF
    classDef mismatch fill:#FEF3C7,stroke:#DC2626,stroke-width:3px,stroke-dasharray:5 5
    {class assignments}
```

### Mandatory Checklist (every diagram)

Every generated diagram MUST include:
- [ ] At least 1 entry point (stadium shape)
- [ ] At least 1 success terminal (double circle)
- [ ] At least 1 error path from every decision node
- [ ] Loading states for any async operation
- [ ] Permission/auth checks where applicable
- [ ] All 5 UI states for data-dependent screens: ideal, empty, error, loading, partial (when evidence exists — flag as Unknown if not mentioned in sources)

### GitHub Rendering Constraints

These are hard limits (GitHub runs Mermaid v11.4.1):
- Max characters: 50,000 per Mermaid block. Target < 40,000 for headroom
- Max edges: 500 per graph. Target ≤ 50
- Security level: strict. No `click` events, no tooltips, no JavaScript callbacks, no FontAwesome
- Layout engine: Dagre only. ELK is unavailable on GitHub
- HTML in labels stripped by DOMPurify. Use Markdown strings instead
- Emoji in node labels may break rendering — use sparingly

## Step 8: Build Evidence Map

For every node in the diagram, create a row in the evidence map:

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

### Confidence Scoring (automated derivation — do not override manually)

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

### Status Derivation

For `mixed` source mode:
- PRD ref present AND code path present → `FOUND`
- PRD ref present AND code path absent → `MISMATCH` (PRD-only)
- PRD ref absent AND code path present → `MISMATCH` (code-only)
- Neither present → `INFERRED`

For single source modes (`prd`, `doc`, `repo`):
- Source reference found → `FOUND`
- Inferred from context → `INFERRED`
- Not assessable → `UNKNOWN`

## Step 9: Identify Unknowns & Mismatches

Generate a structured Unknowns table:

| Column | Description |
|---|---|
| ID | Sequential: `U1`, `U2`, ... |
| Unknown | What couldn't be determined |
| Impact | 🔴 High / 🟡 Medium / 🟢 Low |
| Source Gap | What's missing (PRD silent? Code absent? Test missing?) |
| Suggested Resolution | Concrete next step to resolve |

**Mismatch callouts** (mixed mode only): when PRD specifies something the code doesn't implement (or vice versa):
- Add a `MISMATCH` row to the evidence map
- Include the mismatch as a dotted edge in the diagram with `:::mismatch` styling and a `⚠️` label
- Add to Mismatches table: `# | Description | PRD Says | Code Does | Severity | Recommendation`

## Step 10: Validate Quality Gates

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

## Step 11: Preview & Approval

Show both outputs in conversation:

1. **Flowchart** (full Mermaid code + metadata)
2. **Evidence Map** (full traceability table)
3. **Quality gate results** (pass/warn/fail status for each)

> "**Preview: Flowchart Outputs**
>
> {display flowchart.md content}
>
> ---
>
> {display evidence-map.md content}
>
> ---
>
> Quality gates: {N}/17 passed, {N} warnings, {N} human-review flags
>
> Write these outputs? [y/n]"

**If n**: Ask "What should be changed?" and return to appropriate step

## Step 12: Write Output Files

If approved, write files:

1. **Create output folder**:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. **Write flowchart file** to `$MAIN_FILE`

3. **Write evidence map file** to `$EVIDENCE_FILE`

4. **Update subdomain index**:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"

EXEC_SUMMARY="{extract 1-2 sentence overview from flowchart}"

add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Flow Name}" \
  "$EXEC_SUMMARY"
```

5. **If update mode**, include a `## Changelog` section at the bottom of flowchart.md showing what changed and why.

6. **Confirm completion**:
> "✓ Flowchart written to: $JAAN_OUTPUTS_DIR/ux/diagrams/{NEXT_ID}-{slug}/{NEXT_ID}-flowchart-{slug}.md
> ✓ Evidence map written to: $JAAN_OUTPUTS_DIR/ux/diagrams/{NEXT_ID}-{slug}/{NEXT_ID}-evidence-map-{slug}.md
> ✓ Index updated: $JAAN_OUTPUTS_DIR/ux/diagrams/README.md"

## Step 13: Capture Feedback

> "Any feedback or improvements needed? [y/n]"

**If yes**:
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this?
   > [1] Fix now - Update this flowchart
   > [2] Learn - Save for future flowcharts
   > [3] Both - Fix now AND save lesson"

**Options**:
- **[1] Fix now**: Revise outputs, re-preview, re-write to same paths
- **[2] Learn**: Run `/jaan-to:learn-add ux-flowchart-generate "{feedback}"`
- **[3] Both**: Do both

---

## Definition of Done

- [ ] Source type validated and files readable
- [ ] Entities extracted and intermediate graph built
- [ ] Diagram type selected based on goal + sources
- [ ] Mermaid structure planned and approved by user
- [ ] Mermaid code generated with all conventions applied
- [ ] Evidence map complete (every node has a row)
- [ ] Unknowns documented with impact and resolution suggestions
- [ ] All 17 quality gates pass (hard-fail)
- [ ] Warnings and human-review flags reported
- [ ] Output files written to correct paths
- [ ] Index updated with add_to_index()
- [ ] User approved final result
