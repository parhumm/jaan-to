---
name: backend-task-breakdown
description: Convert a PRD into structured backend development tasks with reliability patterns. Use when planning backend work from requirements.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/backend/task-breakdown/**), Task, Edit(jaan-to/config/settings.yaml)
argument-hint: [prd-path] OR [feature-description]
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# backend-task-breakdown

> Convert PRDs into structured backend development tasks with data model notes, reliability patterns, and error taxonomy.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` - Tech stack context (CRITICAL: determines framework patterns)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`, `#patterns`
- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to:backend-task-breakdown.template.md` - Output template
- `$JAAN_LEARN_DIR/jaan-to:backend-task-breakdown.learn.md` - Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` - Reference: task card template, export formats, sizing benchmarks, quality checklists

## Input

**PRD/Feature**: $ARGUMENTS

Accepts any of:
- **PRD file path** — Path to PRD file (primary input)
- **Tech plan path** — Path to tech plan from `/jaan-to:dev-tech-plan`
- **Feature description** — Free text describing the feature

If no input provided, ask: "What PRD or feature should I break down into backend tasks?"

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `backend-task-breakdown`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read tech context (CRITICAL for this skill):
- `$JAAN_CONTEXT_DIR/tech.md` - Determines framework (Laravel, FastAPI, Django, etc.), constraints, patterns

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_backend-task-breakdown`

> **Language exception**: Generated code output (variable names, code blocks, schemas, SQL, API specs) is NOT affected by this setting and remains in the project's programming language.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing PRD to extract entities and actions
- Mapping requirements to task types (migrations, models, controllers, jobs)
- Building dependency graphs
- Detecting implicit tasks that PRDs don't mention
- Assessing complexity and risks

## Step 1: Parse Input

Analyze the provided input to extract requirements:

**If PRD file path:**
1. Read the PRD file using the Read tool
2. Extract:
   - Title and problem statement
   - User stories and acceptance criteria
   - Technical constraints mentioned
   - API requirements
3. Parse content for entity extraction (Step 3)

**If tech plan path:**
1. Read the tech plan file
2. Extract:
   - Architecture decisions
   - Data model notes
   - API contracts
   - Technical approach
3. Use as additional context for task breakdown

**If feature description:**
1. Parse the description
2. Identify:
   - Core entities (nouns)
   - User actions (verbs)
   - Data relationships
   - Integration points

Build an initial understanding:
```
INPUT SUMMARY
─────────────
Type:      {prd/tech-plan/description}
Entities:  {list of identified entities}
Actions:   {list of user actions}
Integrations: {external systems}
Unknown:   {areas needing clarification}
```

## Step 2: Clarify Scope

Ask up to 5 smart questions based on what's unclear from Step 1. Skip questions already answered by the input or tech.md.

**Slicing strategy** (always ask):
1. > "What task breakdown approach?
   > [1] Vertical — Each task delivers complete functionality through all layers (recommended)
   > [2] Horizontal — Separate by layer (migrations, models, controllers)
   > [3] Hybrid — Foundation layer + vertical feature slices"

**Framework questions** (ask if tech.md unavailable):
2. "What backend framework?" — only if not in tech.md
   - Affects file paths, naming conventions, component types

**Team context** (ask if relevant):
3. "Team size and sprint duration?" — for sizing calibration
   - 2-dev team vs 8-dev team changes task granularity

**Data model defaults** (ask if entities identified):
4. "Delete strategy per entity?" — with defaults suggested
   - Show extracted entities, suggest soft delete for all
   - User can override per entity

**API conventions** (ask if not in tech.md):
5. "API conventions?" — pagination, versioning, error format
   - Default: cursor-based pagination (25/page), RFC 7807 errors

## Step 3: Extract Entities and Actions

Apply the **PRD-to-Task Mapping Engine**:

| PRD Content Pattern | Recognition Signal | Task Type | Example |
|---------------------|-------------------|-----------|---------|
| **Nouns (stored data)** | "user profile", "order history", "subscription" | Migration + Model | "users table", "User.php" |
| **Verbs (user actions)** | "create", "submit", "approve", "cancel" | Controller/Action | "OrderController@store" |
| **Temporal indicators** | "later", "scheduled", "async", "background" | Queue Job | "ProcessOrderJob.php" |
| **Authorization language** | "only if admin", "requires permission", "owner can" | Policy/Middleware | "OrderPolicy@update" |
| **Relationship phrases** | "belongs to", "has many", "associated with" | Model relationships | "belongsTo(User::class)" |
| **Integration mentions** | Third-party APIs, webhooks, external services | Service class + Job | "StripePaymentService" |

**For each entity identified, record:**
- Name (singular, PascalCase for models)
- Table name (plural, snake_case)
- Key attributes (from PRD context)
- Relationships to other entities
- Operations needed (CRUD, custom actions)

**For each action identified, record:**
- HTTP method and endpoint
- Controller and method
- Request validation needs
- Authorization requirements

**Present extraction results:**
```
ENTITY EXTRACTION
═════════════════

Entities: {count}
─────────
1. User → users (registration, profile, auth)
2. Order → orders (create, update, cancel, fulfill)
3. Payment → payments (process, refund, void)

Actions: {count}
────────
1. POST /api/orders → OrderController@store
2. PUT /api/orders/{id}/cancel → OrderController@cancel
3. POST /api/payments → PaymentController@process

Relationships:
──────────────
- Order belongsTo User
- Order hasMany OrderItems
- Payment belongsTo Order
```

## Step 4: Detect Implicit Tasks

Automated scan for tasks the PRD doesn't explicitly mention but are required for production:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Implicit Tasks Detection Checklists" for the full checklists across all 4 categories (Database, Error Handling, Security, Observability) with signals and task patterns.

Scan for implicit tasks across all 4 categories. For each detected task, record the signal that triggered it.

**Present detected implicit tasks:**
```
IMPLICIT TASKS DETECTED
═══════════════════════

Database (4 tasks):
- Add index on users.email (search/login)
- Add soft deletes to orders (restoration requirement)
- Add cascade delete orders→order_items
- Add unique constraint on subscriptions (user_id, status='active')

Error Handling (3 tasks):
- Add circuit breaker for Stripe API calls
- Configure retry logic for ProcessPaymentJob (3 attempts, exponential backoff)
- Set 30s timeout for webhook deliveries

Security (2 tasks):
- Create OrderPolicy for ownership checks
- Add rate limiting to /api/auth/* endpoints (5 req/min)

Observability (2 tasks):
- Add audit log for order cancellations
- Configure error monitoring for payment failures
```

## Step 5: Plan Task Structure

Organize all extracted and implicit tasks into a structured breakdown:

### Slicing Strategy

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Slicing Strategy Examples" for Vertical and Horizontal slicing patterns with examples.

**Vertical** (default): Group by user-facing feature — each slice delivers end-to-end functionality.
**Horizontal**: Group by technical layer — requires careful dependency management.
**Hybrid**: Foundation layer + vertical feature slices.

### T-shirt Sizing

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "T-shirt Sizing" for size benchmarks (XS through XXL) and escalation factors.

### Dependency Notation

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Dependency Notation Format" for blocked-by, needs, and parallel-with marker syntax with examples.

### Critical Path Calculation

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Critical Path Calculation" for identification method and example.

Identify the longest chain of sequential dependencies — this determines minimum project duration.

### Anti-pattern Detection

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Anti-pattern Detection Rules" for the 5 anti-patterns (too granular, too coarse, missing error handling, orphan tasks, hero tasks) with fix strategies.

Flag issues before HARD STOP.

**Present planned structure:**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Task Breakdown Plan Display Template" for the full display format.

---

# HARD STOP — Review Breakdown Plan

Present the complete analysis summary:

```
TASK BREAKDOWN PLAN
═══════════════════

SUMMARY
───────
PRD:           {title}
Framework:     {from tech.md}
Slicing:       {Vertical/Horizontal/Hybrid}
Total Tasks:   {count}
Critical Path: {n} tasks ({duration estimate})
Parallel Tracks: {n} independent streams

ENTITIES ({count})
──────────────────
{table with entity → table → task count → key notes}

TASKS ({count})
───────────────
{numbered list with: [ID] Type: Description (Size, duration)}
{with dependency markers}

IMPLICIT TASKS ({count})
─────────────────────────
{auto-detected tasks with rationale}

VALIDATION
──────────
✓ Coverage: All PRD requirements mapped
✓ Structure: No XXL tasks, clear dependencies
✓ Technical: Idempotency, errors, security checked
✗ Anti-pattern: {any warnings flagged}
```

> "Proceed with generating the full task breakdown? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Generate Task Breakdown Document

1. Read template: `$JAAN_TEMPLATES_DIR/jaan-to:backend-task-breakdown.template.md`
2. If tech stack needed, extract sections from tech.md:
   - Current Stack: `#current-stack`
   - Frameworks: `#frameworks`
   - Constraints: `#constraints`
   - Patterns: `#patterns`

3. Fill all template sections with analysis from Phase 1:

### Master Task Card Template

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Master Task Card Template" for the full task card format including: Size/Priority/Complexity fields, File paths, Dependencies, Acceptance Criteria, Data Model Notes (YAML schema), Idempotency, Error Scenarios, Reliability Notes, Security Checklist, and Test Requirements.

### Dependency Graph

Generate a text-based dependency graph showing critical path, parallel tracks, and integration points.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Dependency Graph Format" for the full graph template.

### Ambiguity Defaults Applied

Document all defaults applied where PRD was ambiguous (delete strategy, pagination, timestamps, status fields, error format).

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Ambiguity Defaults Table" for the standard defaults table.

## Step 7: Generate Export Formats

Append export-ready formats to the document: Jira CSV Import, Linear Markdown, and JSON Export.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Export Formats" for full templates of all three formats (Jira CSV, Linear Markdown, JSON).

## Step 8: Quality Check

Before preview, validate the breakdown against all four checklists: Coverage, Structure, Technical, and Anti-pattern validation.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/backend-export-formats.md` section "Quality Checklists" for the complete validation checklists.

If any check fails, fix before preview.

## Step 9: Preview & Approval

Show the complete task breakdown document.

> "Here's the task breakdown preview. Write to `$JAAN_OUTPUTS_DIR/backend/task-breakdown/{id}-{slug}/{id}-{slug}.md`? [y/n]"

## Step 9.5: Generate ID and Folder Structure

If approved, set up the output structure:

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/backend/task-breakdown"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Create folder and file paths
slug="{lowercase-hyphenated-from-prd-title-max-50-chars}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
```

3. Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/backend/task-breakdown/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-{slug}.md

## Step 10: Write Output

1. Create output folder:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. Write task breakdown to main file:
```bash
cat > "$MAIN_FILE" <<'EOF'
{generated task breakdown with Executive Summary}
EOF
```

3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Feature Title}" \
  "{1-2 sentence summary: backend task breakdown for feature}"
```

4. Confirm completion:
> ✓ Task breakdown written to: $JAAN_OUTPUTS_DIR/backend/task-breakdown/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md
> ✓ Index updated: $JAAN_OUTPUTS_DIR/backend/task-breakdown/README.md

## Step 11: Suggest Next Skill

> "Backend task breakdown complete."
>
> **Recommended next step**: For comprehensive data model documentation with constraints, indexes, migration playbooks, and retention policies:
> ```
> /jaan-to:backend-data-model "{entity-list-from-extraction}"
> ```

## Step 12: Capture Feedback

> "Any feedback or improvements needed? [y/n]"

**If yes:**
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this?
   > [1] Fix now - Update the breakdown
   > [2] Learn - Save for future runs
   > [3] Both - Fix now AND save lesson"

- **Option 1 - Fix now**: Update the output file, re-preview, re-write
- **Option 2 - Learn**: Run `/jaan-to:learn-add backend-task-breakdown "{feedback}"`
- **Option 3 - Both**: Do both

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-stack support via `tech.md` detection
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] Input parsed and entities/actions extracted
- [ ] Scope clarified with user (slicing strategy, defaults)
- [ ] PRD parsing engine applied to extract entities and actions
- [ ] Implicit tasks detected across 4 categories (DB, errors, security, observability)
- [ ] Task structure planned with sizes, dependencies, critical path
- [ ] User approved plan at HARD STOP
- [ ] Full task cards generated with master template per task
- [ ] Export formats generated (Jira CSV, Linear MD, JSON)
- [ ] Quality checks passed (Coverage, Structure, Technical, Anti-patterns)
- [ ] Task breakdown document written to `$JAAN_OUTPUTS_DIR/backend/task-breakdown/{id}-{slug}/{id}-{slug}.md`
- [ ] User approved final result
