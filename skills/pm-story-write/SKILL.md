---
name: pm-story-write
description: Generate user stories with Given/When/Then acceptance criteria following INVEST principles. Use when writing user stories from PRDs.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Bash(cp:*), Task, Edit(jaan-to/config/settings.yaml)
argument-hint: [feature] [persona] [goal] OR [epic-id]
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# pm-story-write

> Generate user stories with Given/When/Then acceptance criteria.

## Context Files

Read before execution:
- `$JAAN_LEARN_DIR/jaan-to:pm-story-write.learn.md` - Past lessons (loaded in Pre-Execution)
- `skills/jaan-to:pm-story-write/template.md` - Story output template
- `$JAAN_OUTPUTS_DIR/research/45-pm-insights-synthesis.md` - Reference research (optional)
- Jira epic/context (if MCP available and epic ID provided)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Input**: $ARGUMENTS

Three input formats supported:

1. **Feature-Persona-Goal**: `[feature] [persona] [goal]`
   - Example: `/jaan-to:pm-story-write "bulk export feature" "system administrator" "analyze usage data offline"`

2. **Narrative Description**: Full feature description
   - Example: `/jaan-to:pm-story-write "As an admin I need to export user data to Excel for compliance reporting"`

3. **Jira Context**: Epic or story ID
   - Example: `/jaan-to:pm-story-write PROJ-123`

4. **Screenshot path** — Design screenshots showing the UI element this story refers to

The skill will extract feature/persona/goal from any format.

IMPORTANT: The input above is your starting point. Use it directly. Do NOT ask for the feature description again.

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `pm-story-write`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also optionally reference research insights:
`$JAAN_OUTPUTS_DIR/research/45-pm-insights-synthesis.md`
- INVEST checklist (Section 6)
- 10 edge case categories (Section 6)
- Splitting patterns if needed (Section 3)

If files don't exist, continue without them.

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_pm-story-write`

---

# PHASE 1: Analysis (Read-Only)

## Step 0: Parse Input

Analyze `$ARGUMENTS` format:

1. **Jira ID Pattern** (PROJ-123, EPIC-456):
   - Attempt to read via MCP Jira integration (graceful failure if not available)
   - Extract: epic name, description, acceptance criteria, related stories
   - Use as context for story generation
   - Continue to Step 1

2. **Structured Format** ([feature] [persona] [goal]):
   - Parse into three components
   - Continue to Step 1

3. **Narrative Format** (free text):
   - Apply 5 Whys technique to extract:
     - Feature: What capability is needed?
     - Persona: Who needs it? (avoid "user", be specific)
     - Goal: Why do they need it? (business value)
   - Continue to Step 1

**Show parsed understanding:**
> "I understand you want to create a story about:
> - **Feature**: {feature}
> - **Persona**: {persona}
> - **Goal**: {goal}
>
> Is this correct? [y/n]"

If "n", ask what needs clarification and reparse.

## Step 1: Gather Context

Ask clarifying questions (maximum 5, only if not already answered by input or Jira context):

**Core Questions** (from research Section 4):

1. "What specific context does this persona have? (e.g., 'busy parent', 'first-time user', 'power user with technical knowledge')"
   - Enhances template: "As a [persona] who [context]..."
   - Skip if persona context already clear

2. "What is the genuine business value? Why does this matter to the business or user?"
   - Apply 5 Whys if answer is feature-focused
   - Example: "So I can export data" → Why? → "So I can analyze trends" → Why? → "So I can reduce churn" (genuine value)
   - Strengthens "so that" clause

3. "What dependencies exist? (e.g., APIs, other stories, design mockups, data sources)"
   - Populates Dependencies section
   - Skip if no dependencies

4. "What is explicitly OUT of scope for this story? What's deferred to later?"
   - Prevents scope creep
   - Identifies follow-on stories
   - CRITICAL: Always ask this

5. "Is there an epic, related stories, or team conventions to reference?"
   - For context and consistency
   - Skip if already provided via Jira

6. "Do you have design screenshots related to this story? If yes, provide file paths."
   - If provided, read images to inform story structure and embed in Context section

**From LEARN.md "Better Questions":**
{Additional questions from past lessons, if file exists}

**Skip questions if:**
- Already answered in input or Jira context
- Obvious from feature type
- Not applicable to story domain

## Step 2: Map Edge Case Categories

Based on feature type, identify relevant edge case categories from research Section 6.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "10 Edge Case Categories" for the full category table and auto-detection matrix by feature type.

**Show mapping:**
> "Based on this being a **{feature_type}** feature, I've identified these applicable edge case categories:
> - {Category N}: {reason why applicable}
> - {Category M}: {reason why applicable}
>
> I'll generate acceptance criteria covering these scenarios."

## Step 3: Plan Story Structure

Based on gathered information, plan the complete story structure:

**1. Story Statement Components:**
- **As a**: {specific persona with context}
- **I want to**: {single, clear capability—avoid compound requirements}
- **So that**: {genuine business value, not feature restatement}

**2. Acceptance Criteria Plan (3-7 scenarios):**
- **Scenario 1**: Happy path (normal successful flow)
- **Scenario 2-3**: Primary edge cases from Step 2
- **Scenario 4-7**: Additional edge cases and error handling as needed

**3. Scope Boundaries:**
- **In-Scope**: {explicit deliverables—what ships with this story}
- **Out-of-Scope**: {deferred items with references to future stories}

**4. Dependencies:**
- {Blocking items from Step 1, if any}

**5. Metadata:**
- **Epic**: {if provided}
- **Priority**: {infer from context: critical/high/medium/low}
- **Estimate**: TBD (team will fill)
- **Labels**: {infer from domain: e.g., backend, frontend, api, auth, mobile}

---

# HARD STOP - Human Review Check

Present planned story structure:

```
STORY PLAN
──────────────────────────────────────
Title: {Verb-First Title (max 10 words)}

Persona: {specific persona with context}
Feature: {capability}
Value: {business value}

ACCEPTANCE CRITERIA (Draft)
───────────────────────────────────────
✓ Scenario 1 (Happy Path): {brief description}
✓ Scenario 2 (Edge Case): {brief description}
✓ Scenario 3 (Edge Case): {brief description}
✓ Scenario 4 (Error Handling): {brief description}
{...additional scenarios if needed}

SCOPE
───────────────────────────────────────
In-Scope:
- {in-scope item 1}
- {in-scope item 2}
- {in-scope item 3}

Out-of-Scope:
- {out-of-scope item 1} → {reference or reason}
- {out-of-scope item 2} → {reference or reason}

DEPENDENCIES
───────────────────────────────────────
{list dependencies or "None"}

EDGE CASE COVERAGE
───────────────────────────────────────
Categories addressed: {comma-separated list from Step 2}
Minimum ACs required: {number}
```

> "Ready to generate the full user story? [y/n/revise]"

**Do NOT proceed to Phase 2 without explicit approval.**

If "revise", ask what needs to change and return to the relevant Phase 1 step.

---

# PHASE 2: Generation (Write Phase)

## Step 4: Generate Story Content

Use template from `skills/jaan-to:pm-story-write/template.md` based on research Section 5.

### YAML Frontmatter

```yaml
---
story_id: US-XXX  # Placeholder for team to fill
epic: "{epic_name_or_id}"
title: "{Verb-First Title}"
priority: {high|medium|low|critical}
status: draft
estimate: TBD
labels: [{inferred_labels}]
created: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
---
```

### Markdown Body - 8 Sections

**Section 1: Title**
```markdown
# US-XXX: {Verb-First Title}
```

**Section 2: Context** (2-4 sentences)
Explain WHY this story exists: business drivers, user research insights, relevant metrics. Make self-contained—no tribal knowledge.
If design screenshots were provided, embed them here using `![Design Reference - {screen}](resolved-path)`.

**Section 3: Story Statement** (Connextra format)
```markdown
## Story Statement

**As a** {specific_persona_with_context}
**I want to** {single_capability}
**So that** {business_value}
```

**Section 4: Acceptance Criteria** (3-7 Gherkin scenarios)

Follow Gherkin best practices from research Section 2:
- **Given**: Preconditions in past tense, NOT user interaction (e.g., "Given user is logged in", not "Given user logs in")
- **When**: The action, technology-agnostic (e.g., "When user clicks submit", not "When React form submits")
- **Then**: Observable outcomes, testable assertions (e.g., "Then user sees success message", not "Then database updated")
- Use **And/But** for additional steps of same type
- One behavior per scenario
- Keep scenarios focused

```markdown
## Acceptance Criteria

### Scenario 1: {Happy_Path_Name}
\`\`\`gherkin
Given {precondition}
When {user_action}
Then {observable_outcome}
  And {additional_outcome_if_needed}
\`\`\`

### Scenario 2: {Edge_Case_Name}
\`\`\`gherkin
Given {precondition}
When {action}
Then {outcome}
\`\`\`

### Scenario 3: {Error_Handling_Name}
\`\`\`gherkin
Given {precondition}
When {error_condition_occurs}
Then {user_sees_error_message}
  And {system_maintains_data_integrity}
\`\`\`

[Include 3-7 scenarios covering happy path + key edge cases from Step 2]
```

**Sections 5-9: Scope, Dependencies, Technical Notes, Open Questions, Definition of Done**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "Story Template — Sections 5-9 Format Specifications" for the detailed markdown format of each section.

## Step 5: Quality Check

Before preview, validate against three checkpoints. All must pass.

### Checkpoint 1: INVEST Compliance

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "INVEST Compliance Checklist" for the full validation table with criteria, questions, and red flags.

### Checkpoint 2: AC Testability

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "AC Testability Checklist" for the full checklist of acceptance criteria verification items.

### Checkpoint 3: Definition of Ready

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "Definition of Ready Checklist" for the full 10-item readiness checklist.

### Checkpoint 4: Image Embedding (if screenshots provided)
- [ ] Design references embedded with `![alt](...)` syntax and URL-encoded paths

### If Any Check Fails:

1. Identify specific issue
2. Revise story content
3. Re-run quality check from Checkpoint 1
4. Continue only when all pass

### Story Splitting Detection

**If story seems too large (>7 ACs or estimated >8 story points):**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "Story Splitting Detection Patterns" for the 6 splitting patterns with examples.

Present the applicable patterns to the user and offer:
> [1] Split now using pattern #{n}
> [2] Refine and keep as single story
> [3] Proceed as-is (will flag as >5 points)

If user chooses [1], guide them through splitting and restart from Step 3 with split stories.
If user chooses [2], ask what to refine and return to Step 4.
If user chooses [3], add note to story: "Note: Estimated >5 points—consider splitting during refinement."

## Step 6: Preview & Approval

Show complete story in markdown format:

```markdown
---
{full YAML frontmatter}
---

{complete story content with all 9 sections}
```

> "📋 Preview complete. Approve writing to output? [y/n]"

If "n", ask what needs revision and return to Step 4.

## Step 6.5: Generate ID and Folder Structure

If approved, set up the output structure:

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/pm/stories"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Create folder and file paths
slug="{lowercase-hyphenated-from-title-max-50-chars}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-story-${slug}.md"
```

3. Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/pm/stories/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-story-{slug}.md

## Step 6.7: Resolve & Copy Assets

If design screenshot paths were provided:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/asset-embedding-reference.md` for the asset resolution protocol (path detection, copy rules, markdown embedding).

Source `${CLAUDE_PLUGIN_ROOT}/scripts/lib/asset-handler.sh`. For each screenshot: check `is_jaan_path` — if inside `$JAAN_*`, reference in-place; if external, ask user before copying. Use `resolve_asset_path` for markdown-relative paths.

## Step 7: Write Output

1. Create output folder:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. Write story to main file:
```bash
cat > "$MAIN_FILE" <<'EOF'
{generated story content with Executive Summary}
EOF
```

3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Story Title}" \
  "{1-2 sentence executive summary from story}"
```

4. Confirm completion:
> ✅ Story written to: $JAAN_OUTPUTS_DIR/pm/stories/{NEXT_ID}-{slug}/{NEXT_ID}-story-{slug}.md
> ✅ Index updated: $JAAN_OUTPUTS_DIR/pm/stories/README.md

### Export Formats

After writing the story, provide Jira CSV and Linear JSON export options.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "Export Formats" for the Jira CSV and Linear GraphQL mutation templates.

## Step 8: Capture Feedback

After story is written, ask:
> "Any feedback or improvements for this story? [y/n]"

**If yes:**
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this feedback?
   > [1] Fix now - Update this story
   > [2] Learn - Save for future stories via /jaan-to:learn-add
   > [3] Both - Fix now AND save lesson"

**Option 1 - Fix now:**
- Apply the feedback to the current story
- Re-run Step 6 (Preview & Approval) with updated content
- Re-write the updated story

**Option 2 - Learn for future:**
- Run: `/jaan-to:learn-add pm-story-write "{feedback}"`
- Let the learn-add skill categorize and save the lesson

**Option 3 - Both:**
- First: Apply fix to current story (Option 1)
- Then: Run `/jaan-to:learn-add pm-story-write "{feedback}"`

**If no:**
- Story workflow complete

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Template-driven output structure
- Generic across industries and domains
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/pm-story-write-reference.md` section "Skill Definition of Done Checklist" for the full 13-item completion checklist covering Steps 0-8.
