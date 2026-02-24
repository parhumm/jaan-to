# qa-test-cases — Reference Material

> Extracted from `skills/qa-test-cases/SKILL.md` for token optimization.
> Contains test design techniques, ISTQB mappings, test data standards, and tagging strategy.

---

## Declarative Gherkin Standards

### Declarative vs Imperative Steps

All BDD scenarios MUST use declarative style. Declarative steps describe business behavior; imperative steps describe UI interactions.

| Style | Example | Verdict |
|-------|---------|---------|
| Imperative | `When I click the "Login" button` | BAD |
| Imperative | `When I enter "test@example.com" in the email field` | BAD |
| Imperative | `When I scroll down and select "Plan A"` | BAD |
| Declarative | `When the user submits valid credentials` | GOOD |
| Declarative | `When the user requests password reset` | GOOD |
| Declarative | `When the user selects their preferred plan` | GOOD |

### Standardized Step Templates

Use these declarative patterns as starting points:

**Given (Preconditions)**:
- `Given a {entity} exists with {attribute} "{value}"`
- `Given the user is authenticated as {role}`
- `Given the system has {count} {entity} records`
- `Given the {entity} is in {state} state`

**When (Actions)**:
- `When the user {action} the {entity}`
- `When the user submits {valid/invalid} {data_type}`
- `When the system processes the {entity}`
- `When the {event} occurs`

**Then (Outcomes)**:
- `Then the {entity} should have {attribute} "{value}"`
- `Then the user should see {feedback_type}`
- `Then the system should {expected_behavior}`
- `Then the {entity} count should be {count}`

### Scenario Structure Limits

- **Steps per scenario**: 3-5 (Given/When/Then combined). Split if exceeding 5.
- **Scenarios per feature**: 5-10. Split into sub-features if exceeding 10.
- **Scenario Outline**: Use with `Examples` tables when 3+ input combinations exist.

---

## Test Design Techniques

### Equivalence Partitioning

Identify input domains and partition:
- **Valid partitions**: Acceptable inputs → correct behavior
- **Invalid partitions**: Inputs that should be rejected
- Select one representative value per partition

Example (from research):
- AC: "Age field accepts 18-64 for adults"
- Valid partition: 18-64 → Representative: 35
- Invalid: <18 → Representative: 10; >64 → Representative: 70

### Boundary Value Analysis

For numeric/date inputs (3-value BVA from research):
- Minimum valid, value just below, value just above
- Maximum valid, value just below, value just above

Example (from research):
- AC: "Quantity 1-100"
- Tests: 0 (below), 1 (min), 2 (above min), 99 (below max), 100 (max), 101 (above)

### Edge Case Categorization (Research Section 5)

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

### Test Generation Ratio (Research Section 4 recommendation)

For each AC, plan minimum:
- **3 positive tests** - Happy path variations
- **3 negative tests** - Invalid inputs, errors
- **2 boundary tests** - Min/max limits
- **2 edge case tests** - From priority categories

**Total: Minimum 10 tests per AC**

---

## ISTQB Field Mapping

### Field Mapping Table

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

---

## Test Data Standards

**CRITICAL - Use concrete values, NOT placeholders (Research Section 8 - AI Failure Mode #3):**

BAD:
- "Enter valid email"
- "Enter a password"
- "Click the button"

GOOD (from research):
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

---

## Tagging Strategy

Apply tags systematically (research Section 2):
- **@smoke** - Critical path tests (1-3 per feature)
- **@regression** - All tests
- **@positive / @negative / @boundary / @edge-case** - By type
- **@priority-critical/high/medium/low** - By risk
- **@REQ-{id}** - Traceability to source AC
- **@{category}** - Edge case category (@empty-state, @concurrency, @state-transition, etc.)
