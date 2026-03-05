---
name: pm-sprint-plan
description: Assess project progress and build a prioritized sprint plan from ROADMAP gaps. Use when planning cycles.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Bash(git log:*), Bash(git diff:*), Bash(cp:*), Edit(jaan-to/config/settings.yaml)
argument-hint: "[--focus spec|scaffold|code|test|audit] [--tasks 'task1,task2']"
disable-model-invocation: true
user-invocable: true
license: PROPRIETARY
---

# pm-sprint-plan

> Assess project state and build a prioritized sprint plan with execution queue.

## Context Files

- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_CONTEXT_DIR/boundaries.md` - Trust rules
- `$JAAN_TEMPLATES_DIR/jaan-to-pm-sprint-plan.template.md` - Sprint plan template
- `$JAAN_LEARN_DIR/jaan-to-pm-sprint-plan.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech context (if exists)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-sprint-plan-reference.md` - Reference tables and schemas

## Input

**Arguments**: $ARGUMENTS

Parse from arguments:
1. **--focus** — optional scope filter: `spec`, `scaffold`, `code`, `test`, `audit`. If omitted, auto-detect from progress matrix bottleneck.
2. **--tasks** — optional comma-separated task keywords (case-insensitive substring match against ROADMAP.md unchecked `- [ ]` lines).
   - Each keyword matches as a case-insensitive substring against all unchecked lines.
   - If a keyword matches multiple lines, include ALL matches. Flag under "MULTI-MATCH KEYWORDS" in the plan.
   - If a keyword matches zero lines, list under "UNMATCHED KEYWORDS". Do NOT fail.
   - If omitted, auto-select by priority order: P0 → P1 → Quick Win → Fill-In.

---

## Pre-Execution Protocol

**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `pm-sprint-plan`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Tech stack for skill filtering
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration

If the file does not exist, continue without it.

### Language Settings

Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_pm-sprint-plan`

> **Language exception**: Generated sprint plans, skill names, YAML, and technical terms remain in English.

---

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing project state across multiple data sources
- Calculating progress matrix percentages from concrete evidence
- Classifying bottleneck via state machine transitions
- Building optimal execution queue from 7 priority sources
- Evaluating risk and dependency ordering

---

# PHASE 1: Assessment (Read-Only)

## Step 1: Read Project State

Read all available project data. Handle missing files gracefully.

### Required

1. **ROADMAP.md** — Read from project root. Extract all unchecked `- [ ]` items with their priority labels (P0, P1, etc.) and section groupings.
   - If ROADMAP.md does not exist → **STOP**: "No ROADMAP.md found. Create one first or run `/jaan-to:pm-roadmap-add` to generate."

### Optional (graceful fallback)

2. **Gap reports** — Glob `gap-reports/*-cycle/` directories. Read the latest gap report.
   - If missing → skip progress matrix, use ROADMAP priorities only.
3. **Scorecards** — Glob `scorecards/` directory. Read recent scorecards for trend data.
   - If missing → skip trend analysis.
4. **Launch gaps** — Read `launch-gaps.md` if it exists.
   - If missing → skip P0-P3 gap extraction.
5. **Tech stack** — Read `$JAAN_CONTEXT_DIR/tech.md` for stack-specific skill filtering.
   - If missing → include all skill variants.

Record which data sources were found and which were skipped.

## Step 2: Calculate Progress Matrix

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-sprint-plan-reference.md` section "Progress Matrix Calculation" for formulas, evidence types, and weighting rules.

**If gap reports exist**: Calculate percentages from concrete evidence:

| Dimension | How to Measure |
|-----------|---------------|
| Specification | PRD exists + stories written + acceptance criteria defined |
| Scaffold | Project structure created + API contracts + data models |
| Production Code | Service implementations + frontend components + integrations |
| Tests | Test coverage + test passing + mutation score |
| Infrastructure | Docker/CI + deployment config + monitoring |

**If gap reports missing**: Skip this step. Record: "Progress matrix unavailable — gap reports not found."

## Step 3: Classify Bottleneck

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-sprint-plan-reference.md` section "Bottleneck State Machine" for state definitions and transition rules.

**If progress matrix available**: Determine project stage:

| Stage | Condition | Focus |
|-------|-----------|-------|
| ideation-to-spec | Spec < 50% | Specification skills |
| spec-to-scaffold | Spec ≥ 50%, Scaffold < 30% | Scaffold skills |
| scaffold-to-code | Scaffold ≥ 30%, Code < 30% | Implementation skills |
| code-to-tested | Code ≥ 30%, Tests < 30% | Testing skills |
| tested-to-deployed | Tests ≥ 30%, Infra < 30% | DevOps skills |
| quality-and-polish | All ≥ 30% | Audit + polish skills |

If `--focus` argument provided, override auto-detected bottleneck.

**If progress matrix unavailable**: Use `--focus` if provided. Otherwise default to `spec` stage.

## Step 4: Map ROADMAP Items to Skills

For each unchecked ROADMAP item:
1. Analyze the task description
2. Map to one or more jaan-to skill invocations
3. Determine which role(s) are needed (pm, backend, frontend, qa, devops, security)

If `--tasks` filter is active, only include matching items.

**Mapping rules**:
- Requirements/PRD tasks → `pm-prd-write`, `pm-story-write`
- API/backend tasks → `backend-task-breakdown`, `backend-scaffold`, `backend-service-implement`
- Frontend tasks → `frontend-task-breakdown`, `frontend-scaffold`
- Testing tasks → `qa-test-generate`, `qa-tdd-orchestrate`
- Infrastructure → `devops-infra-scaffold`
- Security → `sec-audit-remediate`
- Documentation → `docs-create`, `docs-update`

If a task cannot be mapped to any skill, flag it as "MANUAL" — requires direct implementation.

## Step 5: Build Execution Queue

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-sprint-plan-reference.md` section "Execution Queue Algorithm" for priority sources, scoring, and ordering rules.

Build a prioritized queue of max 12 items from 7 priority sources:

| Source | Priority | Description |
|--------|----------|-------------|
| 1. P0 blockers | Highest | Critical path items from gap reports |
| 2. --tasks filter | High | User-specified task keywords |
| 3. Bottleneck skills | Medium-High | Skills that address the classified bottleneck |
| 4. P1 features | Medium | Important but not blocking |
| 5. Quick wins | Low-Medium | Small tasks completable in one skill invocation |
| 6. Untested skills | Low | Skills not yet validated in this project |
| 7. Closing skills | Always | detect-pack, release-iterate-changelog (always included) |

Source 7 (closing skills) ALWAYS runs regardless of other selections. Reserve 2 queue slots for closing skills.

Order items within each source by dependency (prerequisites first).

## Step 6: Assess Risk

For each queue item, flag risks:
- **Dependency risk**: Requires output from another item in the queue
- **Complexity risk**: Multi-file, multi-role task
- **Unknown risk**: First time running this skill in this project

---

# HARD STOP — Sprint Plan Review

Present the complete sprint plan to the user.

```
SPRINT PLAN
───────────
Data Sources: {list_found_and_skipped}

PROGRESS MATRIX (if available)
──────────────────────────────
Specification:    {spec_pct}%  {bar}
Scaffold:         {scaffold_pct}%  {bar}
Production Code:  {code_pct}%  {bar}
Tests:            {test_pct}%  {bar}
Infrastructure:   {infra_pct}%  {bar}

BOTTLENECK: {stage_name}
FOCUS: {focus_area}

EXECUTION QUEUE ({count}/12 items)
──────────────────────────────────
{numbered_list_with_skill_and_role}

TASK GROUPS
───────────
Group 1: {group_description}
  1. {skill_invocation} — {description}
  2. {skill_invocation} — {description}

Group 2: {group_description}
  3. {skill_invocation} — {description}
  ...

RISKS
─────
{risk_flags}

MULTI-MATCH KEYWORDS (if any)
─────────────────────────────
{keyword}: matched {count} items

UNMATCHED KEYWORDS (if any)
───────────────────────────
{keyword}: no matching ROADMAP items

DEFERRED (items beyond queue capacity)
──────────────────────────────────────
{deferred_items}
```

> "Approve this sprint plan? [y/approve/edit/n]"

- **y / approve** → proceed to Phase 2
- **edit** → revise based on feedback, re-present
- **n** → stop workflow

**Do NOT proceed without explicit approval.**

---

# PHASE 2: Generate Sprint Plan Artifact

## Step 7: Write Sprint Plan

Use the template from: `$JAAN_TEMPLATES_DIR/jaan-to-pm-sprint-plan.template.md`

Fill all sections with the approved plan data.

### Generate ID and Output Path

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"

SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/pm/sprint-plan"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

slug="sprint-plan"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${slug}.md"
```

### Write Output

```bash
mkdir -p "$OUTPUT_FOLDER"
```

Write the sprint plan artifact to `$MAIN_FILE` using the filled template.

The artifact MUST include a machine-readable YAML block at the top for consumption by `team-ship --track sprint`:

```yaml
---
type: sprint-plan
version: 1
created: {date}
focus: {focus_area}
bottleneck: {stage_name}
progress:                       # Omit section entirely if gap reports unavailable
  specification: {0-100}
  scaffold: {0-100}
  production_code: {0-100}
  tests: {0-100}
  infrastructure: {0-100}
queue_count: {count}
queue:
  - id: 1
    skill: {skill_name}
    role: {role}
    args: "{arguments}"
    group: {group_number}
    depends_on: []
    roadmap_ref: "{original_roadmap_line}"
  - id: 2
    skill: {skill_name}
    role: {role}
    args: "{arguments}"
    group: {group_number}
    depends_on: [1]
    roadmap_ref: "{original_roadmap_line}"
closing_skills:
  - detect-pack
  - release-iterate-changelog
deferred:                       # Omit if no items deferred
  - title: "{deferred_item}"
    reason: "{why_deferred}"
    priority_boost: true
---
```

### Validate Before Writing

Before writing the artifact, verify:
- `queue_count` equals actual `queue` array length
- All `depends_on` IDs reference valid `id` values in the queue
- `group` numbers are sequential (1, 2, 3...) with no gaps
- Items within the same group do NOT depend on each other
- `closing_skills` is present and non-empty

If validation fails → present errors to user, do NOT write. Offer to fix.

### Update Subdomain Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "Sprint Plan" \
  "{1-2 sentence summary of sprint focus and queue size}"
```

Confirm:
> Sprint plan written to: {MAIN_FILE}
> This artifact can be consumed by `/team-sprint` or `/team-ship --track sprint`.

## Step 8: Capture Feedback

> "Any feedback on this sprint plan? [y/n]"

**If yes:**
1. Ask what to improve
2. Offer: [1] Fix now [2] Learn for future [3] Both
3. For learn: `/jaan-to:learn-add pm-sprint-plan "{feedback}"`

**If no:** Sprint plan workflow complete.

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Template-driven output structure
- Generic across tech stacks (reads tech.md for stack context)
- Graceful fallback when optional data sources are missing
- Output artifact consumed by team-ship --track sprint
- Follows pre-execution protocol (Steps 0→A→B→C)

## Definition of Done

- [ ] ROADMAP.md read and parsed
- [ ] Progress matrix calculated (or skipped with reason)
- [ ] Bottleneck classified (or default applied)
- [ ] Execution queue built (max 12 items, closing skills included)
- [ ] Sprint plan presented and approved by user
- [ ] Artifact written to `$JAAN_OUTPUTS_DIR/pm/sprint-plan/`
- [ ] Machine-readable YAML block included for team-ship consumption
- [ ] User feedback captured (if given)
