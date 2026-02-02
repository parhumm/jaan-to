---
name: jaan-to-pm-prd-write
description: |
  Generate a Product Requirements Document from an initiative description.
  Auto-triggers on: feature requirements, PRD requests, product specifications.
  Maps to: jaan-to-pm-prd-write
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/**)
argument-hint: [initiative-description]
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/validate-prd.sh"
          timeout: 5000
---

# jaan-to-pm-prd-write

> Generate a PRD from initiative description.

## Context Files

- `$JAAN_CONTEXT_DIR/config.md` - Configuration
- `$JAAN_CONTEXT_DIR/boundaries.md` - Trust rules
- `$JAAN_TEMPLATES_DIR/jaan-to-pm-prd-write.template.md` - PRD template
- `$JAAN_LEARN_DIR/jaan-to-pm-prd-write.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech context (if exists)
- `$JAAN_CONTEXT_DIR/team.md` - Team context (if exists)

## Input

**Initiative**: $ARGUMENTS

IMPORTANT: The initiative above is your input. Use it directly. Do NOT ask for the initiative again.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to-pm-prd-write.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` - Know the tech stack to reference
- `$JAAN_CONTEXT_DIR/team.md` - Know team structure and norms

If the file does not exist, continue without it.

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
Use the template from: `$JAAN_TEMPLATES_DIR/jaan-to-pm-prd-write.template.md`

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
> "Here's the PRD preview. Write to `$JAAN_OUTPUTS_DIR/pm/{slug}/prd.md`? [y/n]"

## Step 6: Write Output
If approved:
1. Generate slug: lowercase, hyphens, no special chars, max 50 chars
2. Create path: `$JAAN_OUTPUTS_DIR/pm/{slug}/prd.md`
3. Write the PRD
4. Confirm: "PRD written to {path}"

## Step 7: Capture Feedback

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
- Run: `/to-jaan-learn-add jaan-to-pm-prd-write "{feedback}"`
- Follow /to-jaan-learn-add workflow (categorize → preview → commit)

**Option 3 - Both:**
- First: Apply fix to current PRD (Option 1)
- Then: Run `/to-jaan-learn-add` (Option 2)

**If no:**
- PRD workflow complete

---

## Definition of Done
- [ ] PRD file exists at correct path
- [ ] All quality checks pass
- [ ] User has approved the content
