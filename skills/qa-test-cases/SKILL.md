---
name: qa-test-cases
description: Generate production-ready BDD/Gherkin test cases from acceptance criteria using ISTQB techniques.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/qa/**), Task, WebSearch, Edit(jaan-to/config/settings.yaml)
argument-hint: [acceptance-criteria | prd-path | jira-id | (interactive)]
---

# qa-test-cases

> Generate production-ready BDD/Gherkin test cases from acceptance criteria.

## Context Files

- `$JAAN_LEARN_DIR/jaan-to:qa-test-cases.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_TEMPLATES_DIR/jaan-to:qa-test-cases.template.md` - BDD/Gherkin template
- `$JAAN_TEMPLATES_DIR/jaan-to:qa-test-cases-quality-checklist.template.md` - Quality checklist template
- Research: `$JAAN_OUTPUTS_DIR/research/50-qa-test-cases.md` - ISTQB standards, test design techniques
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Acceptance Criteria Source**: $ARGUMENTS

Input modes:
1. **Direct text**: Paste acceptance criteria directly
2. **PRD path**: Path to PRD file (from /jaan-to:pm-prd-write output)
3. **Jira ID**: Story ID (if Jira MCP available)
4. **Interactive**: Empty arguments triggers wizard

IMPORTANT: The input above is your starting point. Determine mode and proceed accordingly.

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `qa-test-cases`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read the comprehensive research document:
`$JAAN_OUTPUTS_DIR/research/50-qa-test-cases.md`

This provides:
- ISTQB test case specification standards (Section 2)
- BDD/Gherkin format guidance (Section 2)
- Test design techniques: Equivalence Partitioning, BVA, Decision Tables (Section 3)
- Eight-step transformation workflow (Section 4)
- Edge case taxonomy - 5 priority categories (Section 5)
- Quality validation checklist (Section 6)
- AI failure mode mitigation patterns (Section 8)

If files do not exist, continue without them.

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_qa-test-cases`

---

# PHASE 1: Analysis (Read-Only)

## Step 1: Determine Input Mode and Extract AC

Check $ARGUMENTS to identify input mode:

**Mode A - Direct Text Input:**
If $ARGUMENTS contains acceptance criteria text:
1. Parse the AC directly
2. Extract testable conditions
3. Proceed to Step 2

**Mode B - PRD File Path:**
If $ARGUMENTS contains file path pattern (e.g., ".md" or "$JAAN_OUTPUTS_DIR/"):
1. Use Read tool to open the file
2. Locate "Acceptance Criteria" or "User Stories" section
3. Extract all AC statements
4. Preview extracted AC:
   ```
   EXTRACTED ACCEPTANCE CRITERIA
   ──────────────────────────────
   1. {ac_1}
   2. {ac_2}
   3. {ac_3}
   ```
5. Ask: "Use these acceptance criteria? [y/edit]"

**Mode C - Jira MCP Integration:**
If $ARGUMENTS matches pattern "PROJ-123" or "JIRA-123":
1. Check if Jira MCP is available
2. If available: Fetch story → extract AC → preview
3. If unavailable: "Jira MCP not detected. Please paste AC or provide file path."

**Mode D - Interactive Wizard:**
If $ARGUMENTS is empty:
1. Ask: "How would you like to provide acceptance criteria?"
   > [1] Paste AC text directly
   > [2] Provide PRD file path
   > [3] Enter Jira story ID
2. Based on selection, route to appropriate mode

**Ambiguity Resolution (from research Section 4):**

If AC is vague, ask these questions before proceeding:
1. "What happens when required fields are empty?"
2. "What are the min/max boundaries for each input field?"
3. "What specific error messages should display for each failure?"
4. "What happens on system/network failure mid-operation?"
5. "Are there concurrent user scenarios to consider?"
6. "What permissions/roles are required for this action?"

## Step 2: Apply Test Design Techniques

For each acceptance criterion, analyze using research Section 3 methodologies:

### 2.1 Equivalence Partitioning

Identify input domains and partition:
- **Valid partitions**: Acceptable inputs → correct behavior
- **Invalid partitions**: Inputs that should be rejected
- Select one representative value per partition

Example (from research):
- AC: "Age field accepts 18-64 for adults"
- Valid partition: 18-64 → Representative: 35
- Invalid: <18 → Representative: 10; >64 → Representative: 70

### 2.2 Boundary Value Analysis

For numeric/date inputs (3-value BVA from research):
- Minimum valid, value just below, value just above
- Maximum valid, value just below, value just above

Example (from research):
- AC: "Quantity 1-100"
- Tests: 0 (below), 1 (min), 2 (above min), 99 (below max), 100 (max), 101 (above)

### 2.3 Edge Case Categorization (Research Section 5)

Map AC to 5 priority categories based on defect frequency:

**Category 1: Empty/Null States (32% of bugs)**
- Null input, empty string, empty array, zero count, whitespace-only

**Category 2: Boundary Values (28% of bugs)**
- Min/max valid, just below/above, string length limits, integer overflow

**Category 3: Error Conditions (22% of bugs)**
- Network timeout, HTTP 500/503, malformed response, DB failure, rate limiting

**Category 4: Concurrent Operations (12% of bugs)**
- Race conditions, double-submit, optimistic locking, simultaneous access

**Category 5: State Transitions (6% of bugs)**
- Invalid transitions, back button, session expiry, refresh during process

### 2.4 Test Generation Ratio (Research Section 4 recommendation)

For each AC, plan minimum:
- **3 positive tests** - Happy path variations
- **3 negative tests** - Invalid inputs, errors
- **2 boundary tests** - Min/max limits
- **2 edge case tests** - From priority categories

**Total: Minimum 10 tests per AC**

## Step 3: Generate Test Inventory Summary

Calculate totals and show plan:

```
TEST GENERATION PLAN
────────────────────────────────────────
Acceptance Criteria: {n} criteria

Test Breakdown (per AC):
  - Positive tests: {n} × 3 = {total}
  - Negative tests: {n} × 3 = {total}
  - Boundary tests: {n} × 2 = {total}
  - Edge case tests: {n} × 2 = {total}

Total Test Cases: {grand_total}

Edge Case Distribution:
  - Empty/Null States: {count}
  - Boundary Values: {count}
  - Error Conditions: {count}
  - Concurrent Operations: {count}
  - State Transitions: {count}

Coverage Targets (Research Section 5):
  - Positive: 30%
  - Negative: 40%
  - Edge: 30%
  - Industry standard: 70-80% coverage
```

Ask: "Proceed with test case generation? [y/edit]"

---

# HARD STOP - Human Review Check

Show complete plan before generating:

```
FINAL CONFIRMATION
──────────────────────────────────────
Source: {input_mode}
Acceptance Criteria: {n} criteria
Total Test Cases: {count}

Output Format: BDD/Gherkin (with ISTQB conversion notes)
Output Folder: $JAAN_OUTPUTS_DIR/qa/cases/{id}-{slug}/
Main File: {id}-test-cases-{slug}.md
Quality Checklist: {id}-test-cases-quality-checklist-{slug}.md

Process:
1. Generate BDD/Gherkin scenarios using research patterns
2. Apply concrete test data values (no placeholders)
3. Add @tags for traceability and filtering
4. Include ISTQB conversion notes (research Section 2)
5. Generate quality checklist (research Section 6)
6. Preview before writing
```

> "Proceed with test case generation? [y/n]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 4: Generate BDD/Gherkin Test Cases

Following research Section 2 patterns and Section 4 worked examples:

### 4.1 Feature Header

```gherkin
@{test-type} @priority-{level} @REQ-{id}
Feature: {Feature Name}
  As a {role}
  I want {goal}
  So that {benefit}
```

### 4.2 Background Section

Common preconditions shared across scenarios:

```gherkin
  Background:
    Given {common_precondition_1 with concrete data}
    And {common_precondition_2}
    And {system_state}
```

### 4.3 Generate Scenarios (Research Section 4 pattern)

**Positive Tests (3 per AC):**

```gherkin
  @smoke @positive @priority-critical @REQ-{id}
  Scenario: {Main happy path}
    Given I am on the {page_name} page
    When I enter "{concrete_value}" in the {field_name} field
    And I enter "{concrete_value}" in the {field_name} field
    And I click the "{button_label}" button
    Then I should be redirected to {path} within {n} seconds
    And I should see "{exact_message}" in the {element}

  @regression @positive @priority-high @REQ-{id}
  Scenario: {Alternative happy path}
    Given {different_valid_state}
    When {valid_action_variation}
    Then {expected_outcome_with_threshold}
```

**Negative Tests (3 per AC):**

```gherkin
  @regression @negative @priority-high @REQ-{id}
  Scenario: {Invalid input scenario}
    Given {precondition}
    When I enter "{invalid_concrete_value}" in the {field} field
    And I click the "{button}" button
    Then I should see error "{exact_error_text}"
    And I should remain on the {page} page
    And {system_state_unchanged}
```

**Boundary Tests (2 per AC):**

```gherkin
  @boundary @edge-case @priority-medium @REQ-{id}
  Scenario: {Minimum boundary}
    Given {setup}
    When I enter "{min_value}" in the {field} field
    Then {expected_result_at_boundary}

  @boundary @edge-case @priority-medium @REQ-{id}
  Scenario: {Maximum boundary}
    Given {setup}
    When I enter "{max_value}" in the {field} field
    Then {expected_result_at_boundary}
```

**Edge Case Tests (2 per AC from priority categories):**

```gherkin
  @edge-case @empty-state @priority-low @REQ-{id}
  Scenario: {Empty/null handling}
    Given {setup}
    When I leave {field} field empty
    Then I should see validation error "{exact_text}"

  @edge-case @concurrent @priority-high @REQ-{id}
  Scenario: {Concurrent operation}
    Given {multi_user_state}
    When {user_1_action} and {user_2_action} occur simultaneously
    Then {system_prevents_race_condition}
```

### 4.4 Test Data Standards (Research Section 8 - AI Failure Mode #3)

**CRITICAL - Use concrete values, NOT placeholders:**

❌ BAD:
- "Enter valid email"
- "Enter a password"
- "Click the button"

✅ GOOD (from research):
- "Enter 'test@example.com' in the email field"
- "Enter 'ValidP@ss123!' in the password field"
- "Click the 'Submit Order' button"

**Standard concrete values:**
- Emails: test@example.com, invalid@test.com, user+test@example.com
- Passwords: ValidP@ss123!, weak, tooshort1, 123456
- Dates: 2024-01-15, 2024-12-31, 2024-02-29
- Numbers: 0, 1, 50, 99, 100, 101, -1, 999999
- URLs: https://app.example.com/login
- Names: "John Doe", "Test User"

### 4.5 Tagging Strategy

Apply tags systematically (research Section 2):
- **@smoke** - Critical path tests (1-3 per feature)
- **@regression** - All tests
- **@positive / @negative / @boundary / @edge-case** - By type
- **@priority-critical/high/medium/low** - By risk
- **@REQ-{id}** - Traceability to source AC
- **@{category}** - Edge case category (@empty-state, @concurrency, @state-transition, etc.)

## Step 5: Generate ISTQB Conversion Notes

From research Section 2 - BDD-to-ISTQB field mapping:

```markdown
## ISTQB Conversion Notes

For teams using traditional test management tools (Xray, TestRail, Azure DevOps):

### Field Mapping

| BDD Element | ISTQB Equivalent | Conversion |
|-------------|------------------|------------|
| Feature | Test Suite | Groups related scenarios |
| Background | Shared Preconditions | Apply to all test cases |
| Given | Preconditions | Initial system state |
| When | Test Steps/Actions | User actions triggering behavior |
| Then | Expected Results | Observable, verifiable outcomes |
| @tags | Test Attributes | Priority, type, traceability |

### Example Conversion

**BDD Scenario:**
```gherkin
@smoke @positive @REQ-AUTH-001
Scenario: Successful login with valid credentials
  Given I am on the login page
  When I enter "test@example.com" in the email field
  And I enter "ValidP@ss123!" in the password field
  And I click the "Login" button
  Then I should be redirected to the dashboard within 3 seconds
```

**ISTQB Format:**

| Test ID | TC-AUTH-001 |
| Title | Successful login with valid credentials |
| Priority | Critical |
| Traceability | REQ-AUTH-001 |
| Preconditions | User exists, not locked, on login page |
| Step 1 | Enter "test@example.com" in email field → Email populated |
| Step 2 | Enter "ValidP@ss123!" in password field → Password masked |
| Step 3 | Click "Login" button → Redirected to dashboard <3s |
```

## Step 6: Quality Validation (Research Section 6)

Before preview, validate against 10-point checklist:

**Universal Checks:**
- [ ] All tests map to an AC (Alignment)
- [ ] All steps unambiguous with specific elements (Clarity)
- [ ] All preconditions/data/results documented (Completeness)
- [ ] Expected results measurable with thresholds (Measurable)
- [ ] All test data explicit values, no placeholders (Test Data)
- [ ] Traceability tags present (@REQ-{id})
- [ ] Tests independent, no hidden dependencies (Independence)
- [ ] Tests reproducible by any tester (Reproducibility)
- [ ] Negative coverage included (30%+) (Negative Coverage)
- [ ] Edge coverage addressed (5 categories) (Edge Coverage)

**AI Failure Mode Checks (Research Section 8):**
- [ ] No vague steps ("properly", "correctly", "works")
- [ ] No missing preconditions
- [ ] No non-reproducible scenarios (relative dates, undefined entities)
- [ ] No over-specification (database/internal references)
- [ ] 30/40/30 distribution (positive/negative/edge)

If any check fails, fix before proceeding.

## Step 7: Preview & Approval

### 7.1 Generate Output Metadata

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/qa/cases"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
```

Generate slug:
- Extract feature name from AC or user title
- Convert to lowercase-kebab-case
- Max 50 characters
- Example: "User Login Authentication" → "user-login-authentication"

### 7.2 Generate Executive Summary

Template:
```
Production-ready BDD/Gherkin test cases for {feature_name} covering {n} acceptance criteria with {total_tests} test scenarios. Includes {positive_count} positive tests, {negative_count} negative tests, {boundary_count} boundary tests, and {edge_count} edge case tests across 5 priority categories (empty/null, boundary, error, concurrent, state transition). All tests use concrete test data values and include traceability tags.
```

### 7.3 Show Preview

```
OUTPUT PREVIEW
──────────────────────────────────────
ID: {NEXT_ID}
Folder: $JAAN_OUTPUTS_DIR/qa/cases/{NEXT_ID}-{slug}/
Main: {NEXT_ID}-test-cases-{slug}.md
Checklist: {NEXT_ID}-test-cases-quality-checklist-{slug}.md

# Test Cases: {Feature Name}

## Executive Summary
{executive_summary}

## Metadata
- Acceptance Criteria: {n}
- Total Test Cases: {count}
- Coverage: Positive {pct}%, Negative {pct}%, Edge {pct}%

[Show first 3 scenarios as preview]

@smoke @positive @priority-critical @REQ-001
Scenario: Successful login with valid credentials
  Given I am on the login page
  When I enter "test@example.com" in the email field
  And I enter "ValidP@ss123!" in the password field
  And I click the "Login" button
  Then I should be redirected to the dashboard within 3 seconds
  And I should see "Welcome, Test User" in the header

[Full output contains {total_tests} scenarios]
```

Ask: "Write these output files? [y/n]"

## Step 8: Write Output Files

If approved:

### 8.1 Create Folder

```bash
OUTPUT_FOLDER="$JAAN_OUTPUTS_DIR/qa/cases/${NEXT_ID}-${slug}"
mkdir -p "$OUTPUT_FOLDER"
```

### 8.2 Write Main File

Path: `$OUTPUT_FOLDER/${NEXT_ID}-test-cases-${slug}.md`

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:qa-test-cases.template.md`

Fill sections:
- Title, Executive Summary
- Metadata table
- Acceptance Criteria Coverage table
- BDD/Gherkin Test Scenarios (all scenarios)
- ISTQB Conversion Notes
- Traceability Matrix
- Test Execution Guidelines
- Quality Checklist Reference
- Appendix

### 8.3 Write Quality Checklist File

Path: `$OUTPUT_FOLDER/${NEXT_ID}-test-cases-quality-checklist-${slug}.md`

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to:qa-test-cases-quality-checklist.template.md`

Fill sections:
- 10-Point Peer Review Checklist
- Anti-Patterns to Reject
- Quality Scoring Rubric (100-point scale with 6 dimensions)
- Coverage Sufficiency Analysis

### 8.4 Update Index

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Feature Name} Test Cases" \
  "{Executive Summary}"
```

### 8.5 Confirm Completion

```
✅ TEST CASES GENERATED
───────────────────────────────────
ID: {NEXT_ID}
Folder: $JAAN_OUTPUTS_DIR/qa/cases/{NEXT_ID}-{slug}/
Main: {NEXT_ID}-test-cases-{slug}.md
Checklist: {NEXT_ID}-test-cases-quality-checklist-{slug}.md
Index: Updated $JAAN_OUTPUTS_DIR/qa/cases/README.md

Total: {count} test cases
Coverage: {positive_pct}% positive, {negative_pct}% negative, {edge_pct}% edge
```

## Step 9: Capture Feedback

Ask: "Any feedback on the test cases? [y/n]"

If yes:
> "[1] Fix now  [2] Learn  [3] Both"

**Option 1 - Fix now:**
- Ask what to improve
- Apply feedback
- Re-validate (Step 6)
- Re-preview (Step 7)
- Re-write

**Option 2 - Learn:**
- Run: `/jaan-to:learn-add qa-test-cases "{feedback}"`

**Option 3 - Both:**
- Fix current output (Option 1)
- Save lesson (Option 2)

If no: Complete

---

## Definition of Done

- [ ] AC extracted and parsed
- [ ] Test design techniques applied (EP, BVA, edge cases)
- [ ] BDD/Gherkin scenarios generated
- [ ] Concrete test data values (no placeholders)
- [ ] Quality validation passed (10-point checklist)
- [ ] ISTQB conversion notes included
- [ ] Executive Summary generated
- [ ] Sequential ID generated
- [ ] Folder created: `{id}-{slug}/`
- [ ] Main file written: `{id}-test-cases-{slug}.md`
- [ ] Quality checklist written: `{id}-test-cases-quality-checklist-{slug}.md`
- [ ] Index updated
- [ ] User approved
