---
name: pm-prd-write
description: Generate a Product Requirements Document from an initiative description.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: [initiative-description]
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/validate-prd.sh"
          timeout: 5000
---

# pm-prd-write

> Generate a PRD from initiative description.

## Context Files

- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_CONTEXT_DIR/boundaries.md` - Trust rules
- `$JAAN_TEMPLATES_DIR/jaan-to:pm-prd-write.template.md` - PRD template
- `$JAAN_LEARN_DIR/jaan-to:pm-prd-write.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech context (if exists)
- `$JAAN_CONTEXT_DIR/team.md` - Team context (if exists)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Initiative**: $ARGUMENTS

IMPORTANT: The initiative above is your input. Use it directly. Do NOT ask for the initiative again.

---

## Pre-Execution: Apply Past Lessons
Read and apply: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `pm-prd-write`

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack to reference
- `$JAAN_CONTEXT_DIR/team.md` - Know team structure and norms

If the file does not exist, continue without it.

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_pm-prd-write`

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Gather Information
You already have the initiative from the Input section above. Now ask these questions:

1. "What problem does this solve for users?"
2. "How will you measure success? (specific metrics)"
3. "What is explicitly NOT included in this scope?"

## Step 2: Plan PRD Structure
After receiving answers, mentally outline:
- Title (from initiative)
- Problem Statement (from Q1)
- Success Metrics (from Q2)
- Scope boundaries (from Q3)
- User Stories (derive 3+ from context)

---

# HARD STOP - Human Review Check

Before generating the PRD, confirm with the user:

> "I have all the information needed. Ready to generate the PRD for '{initiative}'? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 3: Generate PRD
Use the template from: `$JAAN_TEMPLATES_DIR/jaan-to:pm-prd-write.template.md`

Fill all sections:
- **Title**: From initiative
- **Problem Statement**: From question 1
- **Solution Overview**: Synthesized from input
- **Success Metrics**: From question 2 (table format, minimum 2)
- **Scope**: In-scope from input, out-of-scope from question 3
- **User Stories**: Derived from problem + solution (minimum 3)
- **Open Questions**: Any unresolved items

### Tech Context Integration

If `$JAAN_CONTEXT_DIR/tech.md` exists:
1. **Read the file** to understand tech stack
2. **When generating User Stories**:
   - Reference appropriate backend framework (e.g., "API endpoint in FastAPI")
   - Reference appropriate frontend framework (e.g., "React component with Redux state")
   - Reference mobile platforms if applicable
3. **When generating Technical Constraints**:
   - Include relevant constraints from tech.md
   - Reference specific technical requirements (e.g., "Must maintain sub-200ms p95 latency")
4. **When generating Success Metrics**:
   - Consider performance targets from tech.md
   - Include technical success criteria where relevant

If tech.md doesn't exist:
- Generate generic technical references
- Add note in PRD: "Update `$JAAN_CONTEXT_DIR/tech.md` for tech-aware PRDs"

## Step 4: Quality Check
Before showing preview, verify:
- [ ] Has clear problem statement
- [ ] Has at least 2 measurable success metrics
- [ ] Has explicit out-of-scope section
- [ ] Has at least 3 user stories

If any check fails, revise before preview.

## Step 5: Preview & Approval
Show the complete PRD and ask:
> "Here's the PRD preview. Approve writing to output? [y/n]"

## Step 5.5: Generate ID and Folder Structure

If approved, set up the output structure:

1. Source ID generator utility:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
```

2. Generate sequential ID and output paths:
```bash
# Define subdomain directory
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/pm/prd"
mkdir -p "$SUBDOMAIN_DIR"

# Generate next ID
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")

# Create folder and file paths
slug="{lowercase-hyphenated-from-title-max-50-chars}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-prd-${slug}.md"
```

3. Preview output configuration:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: $JAAN_OUTPUTS_DIR/pm/prd/{NEXT_ID}-{slug}/
> - Main file: {NEXT_ID}-prd-{slug}.md

## Step 6: Write Output

1. Create output folder:
```bash
mkdir -p "$OUTPUT_FOLDER"
```

2. Write PRD to main file:
```bash
cat > "$MAIN_FILE" <<'EOF'
{generated PRD content with Executive Summary}
EOF
```

3. Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{PRD Title}" \
  "{1-2 sentence executive summary from PRD}"
```

4. Confirm completion:
> ✓ PRD written to: $JAAN_OUTPUTS_DIR/pm/prd/{NEXT_ID}-{slug}/{NEXT_ID}-prd-{slug}.md
> ✓ Index updated: $JAAN_OUTPUTS_DIR/pm/prd/README.md

## Step 7: Auto-Invoke User Story Generation

Use AskUserQuestion:
- Question: "Generate detailed user stories from this PRD?"
- Header: "Stories"
- Options:
  - "Yes" — Choose stories to expand
  - "No" — Skip, done with PRD only

If "No", skip to Step 8.

If "Yes":

List the user stories from the generated PRD:

> "Which stories to expand into full user stories?"
>
> [1] As a {persona}, I want {action} so that {benefit}
> [2] As a {persona}, I want {action} so that {benefit}
> [3] As a {persona}, I want {action} so that {benefit}
> [All] Generate all stories
>
> Enter numbers (e.g., "1,3" or "all"):

For each selected story, run:
`/jaan-to:pm-story-write "{story_statement}"`

This invokes the full story-write skill with INVEST validation,
Gherkin acceptance criteria, and edge case mapping.

## Step 8: Capture Feedback

After PRD is written, ask:
> "Any feedback or improvements needed? [y/n]"

**If yes:**
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this?
   > [1] Fix now - Update this PRD
   > [2] Learn - Save for future PRDs
   > [3] Both - Fix now AND save lesson"

**Option 1 - Fix now:**
- Apply the feedback to the current PRD
- Re-run Step 5 (Preview & Approval) with updated content
- Write the updated PRD

**Option 2 - Learn for future:**
- Run: `/jaan-to:learn-add pm-prd-write "{feedback}"`
- Follow /jaan-to:learn-add workflow (categorize → preview → commit)

**Option 3 - Both:**
- First: Apply fix to current PRD (Option 1)
- Then: Run `/jaan-to:learn-add` (Option 2)

**If no:**
- PRD workflow complete

---

## Definition of Done
- [ ] PRD file exists at correct path
- [ ] All quality checks pass
- [ ] User has approved the content
- [ ] User stories generated via /jaan-to:pm-story-write (if selected)
