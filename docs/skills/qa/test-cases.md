# qa-test-cases

> Generate production-ready BDD/Gherkin test cases from acceptance criteria using ISTQB methodology.

---

## Overview

The `/qa-test-cases` skill transforms acceptance criteria into comprehensive BDD/Gherkin test scenarios using systematic test design techniques from ISTQB standards. It generates test cases with concrete data values, proper edge case coverage, and built-in quality validation.

**Rank**: #1 highest-leverage QA task (AI Score: 5/5)

---

## Quick Start

```bash
# Basic usage with AC text
/qa-test-cases "User can login with valid email and password"

# From PRD file
/qa-test-cases jaan-to/outputs/pm/prd/01-user-auth/01-prd-user-auth.md

# Interactive wizard
/qa-test-cases
```

---

## What It Does

Generates **minimum 10 test cases per acceptance criterion**:
- **3 positive tests** - Happy path variations
- **3 negative tests** - Invalid inputs, error handling
- **2 boundary tests** - Min/max limits, off-by-one errors
- **2 edge case tests** - From 5 priority categories

**Output Format**: BDD/Gherkin (with ISTQB conversion notes for Xray/TestRail/Azure DevOps)

---

## Input Modes

### 1. Direct Text

Paste acceptance criteria directly:

```bash
/qa-test-cases "
- User can login with valid email and password
- Invalid credentials show error message
- Account locks after 5 failed attempts
"
```

### 2. PRD File Path

Reference a PRD file to extract acceptance criteria:

```bash
/qa-test-cases jaan-to/outputs/pm/prd/01-user-auth/01-prd-user-auth.md
```

The skill will:
1. Read the file
2. Extract the "Acceptance Criteria" or "User Stories" section
3. Preview extracted AC for approval
4. Generate test cases

### 3. Jira Integration (if MCP available)

```bash
/qa-test-cases PROJ-123
```

Fetches the story and extracts acceptance criteria automatically.

### 4. Interactive Wizard

```bash
/qa-test-cases
```

Prompts you to choose your preferred input method.

---

## Test Design Techniques Applied

### Equivalence Partitioning

Divides input domains into valid/invalid partitions, selecting representative values:

**Example**: Age field (18-64 for adults)
- Valid partition: 18-64 → Test with 35
- Invalid: <18 → Test with 10; >64 → Test with 70

### Boundary Value Analysis (3-value BVA)

Tests boundaries with values just below, at, and just above limits:

**Example**: Quantity 1-100
- Tests: 0 (below), 1 (min), 2 (above min), 99 (below max), 100 (max), 101 (above)

### Edge Case Taxonomy

**5 priority categories** based on production defect frequency:

1. **Empty/Null States** (32% of bugs) - Null input, empty strings, zero counts
2. **Boundary Values** (28% of bugs) - Min/max limits, overflow
3. **Error Conditions** (22% of bugs) - Timeouts, HTTP 500/503, failures
4. **Concurrent Operations** (12% of bugs) - Race conditions, double-submit
5. **State Transitions** (6% of bugs) - Invalid transitions, back button

---

## Output Structure

```
$JAAN_OUTPUTS_DIR/qa/cases/{id}-{slug}/
├── {id}-test-cases-{slug}.md              # Main test cases (BDD/Gherkin)
└── {id}-test-cases-quality-checklist-{slug}.md  # Quality validation
```

### Main File Contains

- **Executive Summary** (1-2 sentences)
- **Metadata** (test counts, coverage breakdown)
- **Acceptance Criteria Coverage** (mapping table)
- **BDD/Gherkin Scenarios** (all test cases)
  - Feature header with user story format
  - Background (shared preconditions)
  - Positive tests (@smoke, @positive tags)
  - Negative tests (@negative tags)
  - Boundary tests (@boundary tags)
  - Edge case tests (@edge-case, @{category} tags)
- **ISTQB Conversion Notes** (for traditional tools)
- **Traceability Matrix** (AC → Tests mapping)
- **Test Execution Guidelines**

### Quality Checklist Contains

- **10-Point Peer Review Checklist**
- **Anti-Patterns to Avoid**
- **100-Point Scoring Rubric** (6 dimensions)
- **Coverage Sufficiency Analysis**

---

## Example Output

### Input AC

```
- User can login with valid email and password
- Invalid credentials show error message
- Account locks after 5 failed attempts
```

### Generated Scenarios (excerpt)

```gherkin
@smoke @positive @priority-critical @REQ-AUTH-001
Scenario: Successful login with valid credentials
  Given I am on the login page
  When I enter "test@example.com" in the email field
  And I enter "ValidP@ss123!" in the password field
  And I click the "Login" button
  Then I should be redirected to the dashboard within 3 seconds
  And I should see "Welcome, Test User" in the header

@regression @negative @priority-high @REQ-AUTH-001
Scenario: Login fails with incorrect password
  Given I am on the login page
  When I enter "test@example.com" in the email field
  And I enter "wrongpassword" in the password field
  And I click the "Login" button
  Then I should see error "Invalid email or password"
  And I should remain on the login page

@security @edge-case @concurrent @priority-high @REQ-AUTH-001
Scenario: Account locks after 5 failed attempts
  Given I am on the login page
  When I attempt to login with wrong password 5 times consecutively
  Then my account should be locked
  And I should see "Account locked. Please contact support."
  And subsequent correct password attempts should also fail
```

---

## Key Features

### ✅ Concrete Test Data (Not Placeholders)

Uses specific values for reproducibility:
- **Emails**: test@example.com, invalid@test.com
- **Passwords**: ValidP@ss123!, weak, 123456
- **Dates**: 2024-01-15, 2024-12-31
- **Numbers**: 0, 1, 50, 99, 100, 101, -1

❌ **Never generates**: "[valid email]", "[password]", "click the button"

### ✅ Systematic Tagging

- **@smoke** - Critical path (1-3 per feature)
- **@regression** - All tests
- **@positive / @negative / @boundary / @edge-case** - By type
- **@priority-critical/high/medium/low** - By risk
- **@REQ-{id}** - Traceability to source AC

### ✅ Quality Validation

**10-Point Checklist**:
1. Alignment (maps to AC)
2. Clarity (unambiguous steps)
3. Completeness (preconditions/data/results)
4. Measurable results (thresholds)
5. Test data (concrete values)
6. Traceability (@REQ tags)
7. Independence (no dependencies)
8. Reproducibility (any tester)
9. Negative coverage (30%+)
10. Edge coverage (5 categories)

**100-Point Rubric** (90+ production-ready, <60 reject)

### ✅ ISTQB Export Ready

Includes conversion notes and examples for:
- Xray for Jira (CSV/JSON)
- TestRail (CSV/API)
- Azure DevOps Test Plans

---

## Workflow

### Phase 1: Analysis (Read-Only)

1. **Input Mode Detection** - Identifies AC source
2. **Ambiguity Resolution** - Asks 6 clarifying questions if AC is vague:
   - What happens when required fields are empty?
   - What are min/max boundaries for each input?
   - What specific error messages for failures?
   - What happens on system/network failure?
   - Any concurrent user scenarios?
   - What permissions/roles required?
3. **Test Design Techniques** - Applies EP, BVA, edge case taxonomy
4. **Test Inventory Summary** - Shows planned test count breakdown

### HARD STOP

Previews complete plan before generation:
- Source (input mode)
- AC count
- Total test case count
- Output format (BDD/Gherkin)
- Output paths

**Requires explicit approval to proceed.**

### Phase 2: Generation (Write Phase)

1. **Generate BDD/Gherkin Scenarios** - All test types with concrete data
2. **Generate ISTQB Conversion Notes** - Export guidance
3. **Quality Validation** - 10-point checklist + 5 AI failure mode checks
4. **Preview & Approval** - Shows executive summary + first 3 scenarios
5. **Write Output Files** - Main test cases + quality checklist
6. **Update Index** - Auto-updates README.md
7. **Capture Feedback** - Options to fix now, learn, or both

---

## Quality Gates

**AI Failure Mode Mitigations** (Research Section 8):

1. ❌ No vague steps ("properly", "correctly") → ✅ Specific elements, exact text
2. ❌ No missing preconditions → ✅ Explicit "Given" clauses
3. ❌ No placeholders → ✅ Concrete values only
4. ❌ No over-specification (DB/internal) → ✅ Observable behavior only
5. ❌ No missing negative tests → ✅ 30/40/30 distribution

**Coverage Targets**:
- 30% positive tests
- 40% negative tests
- 30% edge case tests
- **70-80% industry standard code coverage**

---

## Research Foundation

Based on comprehensive 880-line methodology guide:
- **ISTQB** Foundation Level Syllabus v4.0
- **IEEE 829-2008** Software Test Documentation
- **BDD/Gherkin** best practices (cucumber.io)
- **Production defect patterns** (5 edge case categories with bug frequencies)

Research document: `jaan-to/outputs/research/50-qa-test-cases.md`

---

## Tips

### When to Use

- After writing acceptance criteria in PRDs
- Before development starts (shift-left testing)
- During sprint planning for estimation
- For test case review and peer validation

### Best Practices

1. **Start with clear AC** - The better the input, the better the output
2. **Review first 3 scenarios** - Validate approach before approving all
3. **Use quality checklist** - Peer review with 10-point checklist
4. **Iterate with feedback** - Use "/learn-add" to improve over time
5. **Export to tools** - Use ISTQB conversion notes for Xray/TestRail

### Common Questions Answered

**Q: Can I modify generated test cases?**
A: Yes! Use the "Fix now" option in Step 9 feedback to make immediate changes.

**Q: How do I add more test cases later?**
A: Re-run the skill with the same AC - it generates a new ID and folder.

**Q: Can I use this with Jira?**
A: Yes, if Jira MCP is configured. Otherwise, paste AC from Jira tickets.

**Q: What if my AC is vague?**
A: The skill asks up to 6 clarifying questions to resolve ambiguities.

**Q: How do I export to TestRail?**
A: See the "ISTQB Conversion Notes" section in generated output for CSV format and examples.

---

## Related Skills

- [/pm-prd-write](../pm/prd-write.md) - Generate PRDs with acceptance criteria
- [/pm-story-write](../pm/story-write.md) - Generate user stories with AC
- `/jaan-to:qa-test-data` (planned) - Generate test data specifications

---

## Technical Details

- **Logical Name**: qa:test-cases
- **Command**: `/qa-test-cases`
- **Allowed Tools**: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/qa/**), Task, WebSearch
- **Output**: `$JAAN_OUTPUTS_DIR/qa/cases/{id}-{slug}/`
- **ID Generation**: Sequential per subdomain (01, 02, 03...)
- **Index**: Auto-updates `$JAAN_OUTPUTS_DIR/qa/cases/README.md`

---

**Generated**: 2026-02-03
**Skill**: qa:test-cases
**Version**: 1.0.0
