---
name: jaan-to-pm-story-write
description: |
  Generate user stories with Given/When/Then acceptance criteria following INVEST principles.
  Auto-triggers on: write user story, create story, user story for, story write, generate story
  Maps to: jaan-to-pm-story:write
allowed-tools: Read, Glob, Grep, Write(jaan-to/**), Task
argument-hint: [feature] [persona] [goal] OR [epic-id]
---

# jaan-to-pm-story:write

> Generate user stories with Given/When/Then acceptance criteria.

## Context Files

Read before execution:
- `jaan-to/learn/jaan-to-pm-story-write.learn.md` - Past lessons (loaded in Pre-Execution)
- `skills/jaan-to-pm-story-write/template.md` - Story output template
- `jaan-to/outputs/research/45-pm-insights-synthesis.md` - Reference research (optional)
- Jira epic/context (if MCP available and epic ID provided)

## Input

**Input**: $ARGUMENTS

Three input formats supported:

1. **Feature-Persona-Goal**: `[feature] [persona] [goal]`
   - Example: `/jaan-to-pm-story-write "bulk export feature" "system administrator" "analyze usage data offline"`

2. **Narrative Description**: Full feature description
   - Example: `/jaan-to-pm-story-write "As an admin I need to export user data to Excel for compliance reporting"`

3. **Jira Context**: Epic or story ID
   - Example: `/jaan-to-pm-story-write PROJ-123`

The skill will extract feature/persona/goal from any format.

IMPORTANT: The input above is your starting point. Use it directly. Do NOT ask for the feature description again.

---

## Pre-Execution: Apply Past Lessons

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`jaan-to/learn/jaan-to-pm-story-write.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases" in Step 2
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

Also optionally reference research insights:
`jaan-to/outputs/research/45-pm-insights-synthesis.md`
- INVEST checklist (Section 6)
- 10 edge case categories (Section 6)
- Splitting patterns if needed (Section 3)

If files don't exist, continue without them.

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

**From LEARN.md "Better Questions":**
{Additional questions from past lessons, if file exists}

**Skip questions if:**
- Already answered in input or Jira context
- Obvious from feature type
- Not applicable to story domain

## Step 2: Map Edge Case Categories

Based on feature type, identify relevant edge case categories from research Section 6.

**The 10 Edge Case Categories:**

| # | Category | When to Apply | AC Needed? |
|---|----------|---------------|------------|
| 1 | **Empty States** | First use, no data, zero results | Yes |
| 2 | **Boundary Conditions** | Max/min values, limits, date ranges | Yes if data input |
| 3 | **Permission Failures** | Multi-user, roles, access tiers | Yes if auth/authz |
| 4 | **Concurrency** | Simultaneous edits, inventory conflicts | Maybe |
| 5 | **Network Failures** | Offline, timeout, slow connection | Yes if network calls |
| 6 | **Invalid Input** | Forms, APIs, user input | Yes |
| 7 | **State Transitions** | Browser back, session expiry, workflow interruption | Yes if multi-step |
| 8 | **Internationalization** | RTL languages, date formats, currency | Maybe |
| 9 | **Timeout/Expiry** | Long operations, sessions, token refresh | Yes if time-sensitive |
| 10 | **Bulk Operations** | Large uploads, batch ops, pagination | Yes if bulk |

**Auto-Detection Matrix** (apply based on feature type):

- **CRUD operations** → Categories 1, 2, 4, 6 (min 4 ACs required)
- **API integration** → Categories 5, 6, 9 (min 4 ACs required)
- **Multi-step workflow** → Categories 1, 7, 9 (min 4 ACs required)
- **User input forms** → Categories 1, 2, 6 (min 4 ACs required)
- **Multi-user/roles** → Categories 3, 4 (min 3 ACs required)
- **Data processing** → Categories 2, 9, 10 (min 4 ACs required)
- **International app** → Categories 2, 8 (min 3 ACs required)
- **Real-time features** → Categories 4, 5, 7 (min 4 ACs required)

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

Use template from `skills/jaan-to-pm-story-write/template.md` based on research Section 5.

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
Given {precondition_describing_state}
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

**Section 5: Scope**
```markdown
## Scope

### In-Scope
- {explicit_item_1}
- {explicit_item_2}
- {explicit_item_3}

### Out-of-Scope
- {deferred_item_1} → See [US-YYY](#reference) or Future epic
- {deferred_item_2} → v2 enhancement
- {deferred_item_3} → Separate story needed
```

**Section 6: Dependencies**
```markdown
## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| {dependency_name} | {Story/Technical/Design} | {Done/In Progress/Pending} | {@owner} |

Or: "None"
```

**Section 7: Technical Notes** (brief)
```markdown
## Technical Notes

{implementation_hints}

[Brief API contracts, database changes, performance requirements. Keep brief—details belong in task breakdown.]
```

**Section 8: Open Questions**
```markdown
## Open Questions

- [ ] {Unresolved question needing decision} — @decider by YYYY-MM-DD
- [x] ~~{Resolved question}~~ — **Decision**: {outcome} (YYYY-MM-DD)

Or: "None"
```

**Section 9: Definition of Done**
```markdown
## Definition of Done

- [ ] Acceptance criteria verified by QA
- [ ] Code reviewed and approved
- [ ] Unit tests written (≥80% coverage)
- [ ] Documentation updated
- [ ] PO acceptance received
```

## Step 5: Quality Check

Before preview, validate against three checkpoints. All must pass.

### Checkpoint 1: INVEST Compliance

| Criterion | Validation Question | Red Flag | Status |
|-----------|---------------------|----------|--------|
| **Independent** | Can ship without other stories? No blocking dependencies? | "Can only start after Story X completes" | [ ] |
| **Negotiable** | Describes WHAT not HOW? Flexible implementation? | "Use Redux for state management" | [ ] |
| **Valuable** | Delivers user/business value? Can articulate why? | "Refactor database schema" (no user value) | [ ] |
| **Estimable** | Team understands enough to estimate? Scope clear? | Team cannot agree on estimate range | [ ] |
| **Small** | Fits in one sprint? Ideally 1-3 days? | More than 8 points; spans sprints | [ ] |
| **Testable** | Can write pass/fail tests? Clear done definition? | "User has good experience" | [ ] |

### Checkpoint 2: AC Testability

Verify each acceptance criterion:
- [ ] Story statement has specific persona (not generic "user")
- [ ] "So that" clause shows business value (not feature restatement)
- [ ] Has 3-7 acceptance criteria
- [ ] Each AC is in Given/When/Then format
- [ ] Each AC is testable (observable outcome in "Then" clause)
- [ ] Scope section has both In/Out explicitly stated
- [ ] No implementation details in ACs (negotiable—describes WHAT not HOW)
- [ ] Edge cases covered (from Step 2 mapping)
- [ ] Each AC has clear pass/fail condition

### Checkpoint 3: Definition of Ready

- [ ] **Format**: Follows "As a / I want / So that" structure
- [ ] **Value**: Business value clearly articulated
- [ ] **Persona**: Specific user type identified (not generic "user")
- [ ] **Acceptance Criteria**: Defined, specific, testable (3-7 scenarios)
- [ ] **Edge Cases**: Error and boundary scenarios included
- [ ] **INVEST**: Passes all six criteria
- [ ] **Estimated**: Placeholder for story points (TBD is acceptable)
- [ ] **Small**: Fits within single sprint (≤8 points)
- [ ] **Dependencies**: All blockers identified, resolution planned
- [ ] **Resources**: Design mockups, API specs noted if needed

### If Any Check Fails:

1. Identify specific issue
2. Revise story content
3. Re-run quality check from Checkpoint 1
4. Continue only when all pass

### Story Splitting Detection

**If story seems too large (>7 ACs or estimated >8 story points):**

> "⚠️ This story may be too large to complete in a single sprint.
>
> **Suggested splitting patterns from research:**
>
> **Pattern 1: Workflow Steps** - Split multi-step processes into individual stages
> Example: Publish directly, publish with review, preview before publish
>
> **Pattern 2: CRUD Operations** - Separate Create/Read/Update/Delete
> Example: Create account, view account, update account, delete account
>
> **Pattern 3: Happy Path First** - Core success scenario now, edge cases later
> Example: Basic search now, filters later, zero results handling later
>
> **Pattern 4: Data Variations** - Split by data types or complexity levels
> Example: Upload PDF now, upload images later, upload large files later
>
> **Pattern 5: Spike + Implementation** - Research first when uncertainty high
> Example: Evaluate payment processors (spike), then implement chosen one
>
> **Pattern 6: Cross-Cutting Concerns** - Defer performance/security/scale
> Example: Search works correctly now, fast search later, concurrent search later
>
> Would you like to:
> [1] Split now using pattern #{n}
> [2] Refine and keep as single story
> [3] Proceed as-is (will flag as >5 points)"

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

> "📋 Preview complete. Write to `jaan-to/outputs/pm/stories/{slug}/stories.md`? [y/n]"

If "n", ask what needs revision and return to Step 4.

## Step 7: Write Output

If approved:

1. **Generate slug**: lowercase, hyphens, no special chars, max 50 chars from title
   - Example: "Update Email Notification Preferences" → "update-email-notification-preferences"
2. **Create directory**: `jaan-to/outputs/pm/stories/{slug}/`
3. **Write file**: `jaan-to/outputs/pm/stories/{slug}/stories.md`
4. **Confirm**:
   > "✅ Story written to `jaan-to/outputs/pm/stories/{slug}/stories.md`"

### Export Formats

Also provide tool export formats (from research Section 7):

> "📤 **Export options for tool import:**
>
> **Jira CSV Import:**
> ```csv
> Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels
> "{title}","{story_body_first_paragraph}","Story","{priority}",TBD,"{epic}","{labels}"
> ```
>
> **Linear GraphQL Mutation:**
> ```json
> {
>   "input": {
>     "title": "{title}",
>     "description": "{story_body_markdown}",
>     "priority": {priority_number},
>     "estimate": null,
>     "labelIds": ["{label_ids}"]
>   }
> }
> ```
>
> Copy the relevant format to import into your tool."

## Step 8: Capture Feedback

After story is written, ask:
> "Any feedback or improvements for this story? [y/n]"

**If yes:**
1. Ask: "What should be improved?"
2. Offer options:
   > "How should I handle this feedback?
   > [1] Fix now - Update this story
   > [2] Learn - Save for future stories via /to-jaan-learn-add
   > [3] Both - Fix now AND save lesson"

**Option 1 - Fix now:**
- Apply the feedback to the current story
- Re-run Step 6 (Preview & Approval) with updated content
- Re-write the updated story

**Option 2 - Learn for future:**
- Run: `/to-jaan-learn-add jaan-to-pm-story-write "{feedback}"`
- Let the learn-add skill categorize and save the lesson

**Option 3 - Both:**
- First: Apply fix to current story (Option 1)
- Then: Run `/to-jaan-learn-add jaan-to-pm-story-write "{feedback}"`

**If no:**
- Story workflow complete

---

## Definition of Done

- [ ] Input parsed and validated (Step 0)
- [ ] All clarifying questions answered (Step 1)
- [ ] Edge cases mapped to 10 categories (Step 2)
- [ ] Story structure planned (Step 3)
- [ ] User approved plan at HARD STOP
- [ ] Story content generated from template (Step 4)
- [ ] INVEST quality check passed—all 6 criteria (Step 5)
- [ ] AC testability verified—all observable outcomes (Step 5)
- [ ] Definition of Ready validated—all 10 items (Step 5)
- [ ] Story previewed and approved (Step 6)
- [ ] File written to correct path (Step 7)
- [ ] Export formats provided—Jira CSV, Linear JSON (Step 7)
- [ ] User feedback captured if provided (Step 8)
