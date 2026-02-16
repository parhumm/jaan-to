---
name: ux-flowchart-generate
description: Generate GitHub-renderable Mermaid flowcharts from PRD/docs/codebase with evidence maps and confidence scoring.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/ux/**), Bash(cp:*), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [source_type] [paths...] [goal] [scope?]
---

# ux-flowchart-generate

> Generate GitHub-renderable Mermaid flowcharts from PRDs, docs, codebases, or any combination — with evidence maps tracing every node to its source, confidence scoring, and structured unknowns lists.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:ux-flowchart-generate.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:ux-flowchart-generate.template.md` - Output templates (flowchart + evidence map)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (optional, auto-imported if exists)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

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

**Optional**: Screenshot paths can be provided alongside source files for visual context. UI screenshots will be embedded in the output as `![UI Reference - {screen}](resolved-path)` alongside relevant subgraphs.

**Output**:
```
$JAAN_OUTPUTS_DIR/ux/diagrams/{id}-{slug}/
  ├── {id}-flowchart-{slug}.md       # Diagram + unknowns + metrics
  └── {id}-evidence-map-{slug}.md    # Traceability table + mismatches
```

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `ux-flowchart-generate`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read tech context if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack for code parsing in `repo`/`mixed` modes

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_ux-flowchart-generate`

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

### Node Shapes & ID Conventions

> **Reference**: Full node shape mapping table (9 UX concepts with Mermaid syntax) and ID conventions (prefixes, reserved words, naming rules) in [`docs/extending/ux-flowchart-reference.md` → Node Shapes / Node ID Conventions](${CLAUDE_PLUGIN_ROOT}/docs/extending/ux-flowchart-reference.md).

### Node Label Guidelines

- Use **verb-noun phrasing**: "Submit form", "Verify email", "Check permissions"
- Decision labels always end with `?`; Error labels always start with "Error:"
- Label language adapts to goal: user-facing for `userflow`, technical for `systemflow`, mixed uses evidence map for technical detail

### Edge Conventions

> **Reference**: Full edge type table (6 types with syntax and label format) in [`docs/extending/ux-flowchart-reference.md` → Edge Conventions](${CLAUDE_PLUGIN_ROOT}/docs/extending/ux-flowchart-reference.md).

- **All edges MUST have labels** — even if just `|success|` or `|next|`
- Decision edges: always `-->|Yes|` and `-->|No|` (not True/False, not unlabeled)

### Grouping

- Apply `subgraph` when diagram has **>15 nodes**
- Group by **user-facing domain** (auth, payment, onboarding) not technical layer
- Name subgraphs with readable labels: `subgraph sg_auth ["Authentication"]`
- Maximum **5 subgraphs** per diagram; more means the diagram should be split

### Style Definitions (always include)

> **Reference**: Full classDef declarations (5 styles with hex color codes) in [`docs/extending/ux-flowchart-reference.md` → Style Definitions](${CLAUDE_PLUGIN_ROOT}/docs/extending/ux-flowchart-reference.md).

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

> **Reference**: Full GitHub Mermaid rendering limits (v11.4.1: character caps, edge limits, security restrictions, layout engine) in [`docs/extending/ux-flowchart-reference.md` → GitHub Rendering Constraints](${CLAUDE_PLUGIN_ROOT}/docs/extending/ux-flowchart-reference.md).

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

> **Reference**: Full confidence scoring table (4 levels with criteria) and derivation rules in [`docs/extending/ux-flowchart-reference.md` → Confidence Scoring](${CLAUDE_PLUGIN_ROOT}/docs/extending/ux-flowchart-reference.md).

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

> **Reference**: Full quality gate checklist (17 hard-fail gates, 2 warn gates, 5 human-review flags) in [`docs/extending/ux-flowchart-reference.md` → Quality Gate Checklist](${CLAUDE_PLUGIN_ROOT}/docs/extending/ux-flowchart-reference.md).

If any hard-fail gate fails: fix the issue, then re-validate until all gates pass.

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

## Step 11.7: Resolve & Copy Assets

If screenshot paths were provided as input:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/asset-embedding-reference.md` for the asset resolution protocol (path detection, copy rules, markdown embedding).

Source `${CLAUDE_PLUGIN_ROOT}/scripts/lib/asset-handler.sh`. For each screenshot: check `is_jaan_path` — if inside `$JAAN_*`, reference in-place; if external, ask user before copying. Use `resolve_asset_path` for markdown-relative paths.

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
