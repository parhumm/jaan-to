# Lessons: jaan-to-qa-test-cases

> Last updated: 2026-02-03

Accumulated lessons from past executions. Read this before generating test cases to avoid past mistakes and apply learned improvements.

Seed content extracted from research: `jaan-to/outputs/research/50-qa-test-cases.md`

---

## Better Questions

Questions to ask when AC is ambiguous (from research Section 4):

- **Empty field handling**: "What happens when required fields are empty?"
- **Min/max boundaries**: "What are the min/max boundaries for each input field?"
- **Error messages**: "What specific error messages should display for each failure condition?"
- **System/network failures**: "What happens on system/network failure mid-operation?"
- **Concurrent scenarios**: "Are there concurrent user scenarios to consider?"
- **Permissions/roles**: "What permissions/roles are required for this action?"
- **Device coverage**: "Should tests cover mobile and desktop, or desktop only?"
- **Accessibility**: "Are there accessibility requirements to test (WCAG compliance)?"

## Edge Cases

Special cases from research Section 5 (5 priority categories with production bug frequency):

### Category 1: Empty/Null States (catches 32% of input validation bugs)

- **Null input**: Pass `null` to function expecting object
- **Empty string**: Submit form with empty text field
- **Empty array**: Process list with zero elements
- **Zero count**: Shopping cart with 0 items
- **Whitespace-only**: Input containing only spaces
- **Empty file upload**: Upload 0-byte file
- **Null in collection**: Array containing null elements

### Category 2: Boundary Values (catches 28% of off-by-one and range errors)

- **Minimum valid**: Age field: enter minimum (e.g., 18)
- **Maximum valid**: Enter max (e.g., 120 for age)
- **Just below minimum**: Enter 17 for 18+ age requirement
- **Just above maximum**: Enter 121 for max 120
- **String at length limit**: Password exactly at min/max chars
- **Integer overflow**: Enter value exceeding INT_MAX
- **Date boundaries**: Dec 31 → Jan 1, Feb 28/29 transitions
- **Time boundaries**: 23:59:59 → 00:00:00 transitions

### Category 3: Error Conditions (catches 22% of failure handling gaps)

- **Network timeout**: API call exceeds timeout threshold
- **HTTP 500**: Backend crashes mid-request
- **HTTP 503**: Server overloaded
- **Malformed response**: JSON parse error handling
- **Database failure**: DB unreachable mid-operation
- **Rate limiting**: Exceed API rate limit (429)
- **Certificate errors**: Expired SSL certificate

### Category 4: Concurrent Operations (catches 12% of race conditions)

- **Race condition**: Two users modify same record simultaneously
- **Double-submit**: User clicks submit twice quickly
- **Optimistic locking**: Record modified during edit
- **Simultaneous login**: Same user from two browsers
- **Connection pool exhaustion**: All connections in use

### Category 5: State Transitions (catches 6% of workflow bugs)

- **Invalid transition**: Skip from "Draft" to "Complete" without intermediate states
- **Back button**: Press back during checkout
- **Session expiry**: Timeout mid-operation
- **Refresh during process**: F5 during form submission
- **Cancel mid-workflow**: Cancel at various stages

## Workflow

Process improvements from research Section 3 & 4:

- **Apply test design techniques BEFORE generating scenarios**: Use Equivalence Partitioning and BVA in Step 2
- **Generate test inventory summary at HARD STOP**: Show counts (positive/negative/boundary/edge) for user approval
- **Use 3-value BVA for boundaries**: Test min-1, min, min+1, max-1, max, max+1
- **Tag systematically**: @smoke for critical (1-3 per feature), @regression for all, @priority-{level}, @REQ-{id}
- **Preview first 3 scenarios only**: Don't preview all—too verbose, slows approval
- **Include ISTQB conversion notes**: For teams using Xray/TestRail/Azure DevOps
- **Quality checklist as separate auxiliary file**: Not inline—keeps main file focused
- **Minimum 10 tests per AC**: 3 positive + 3 negative + 2 boundary + 2 edge
- **30/40/30 distribution**: 30% positive, 40% negative, 30% edge for optimal bug detection

## Common Mistakes

AI failure modes from research Section 8:

### Failure Mode 1: Vague Steps
- ❌ **BAD**: "Verify system works correctly"
- ✅ **GOOD**: "Verify order confirmation displays order ID #12345"
- **Fix**: Include specific UI elements, exact text, numeric thresholds

### Failure Mode 2: Missing Preconditions
- ❌ **BAD**: Test starts with "When I click Submit"
- ✅ **GOOD**: "Given I am logged in as 'test@example.com' And I am on the checkout page"
- **Fix**: Every test MUST begin with explicit preconditions (user state, data prerequisites, system config)

### Failure Mode 3: Placeholder Data (MOST CRITICAL)
- ❌ **BAD**: "Enter valid email", "Enter a password", "Click the button"
- ✅ **GOOD**: "Enter 'test@example.com' in the email field", "Enter 'ValidP@ss123!' in the password field", "Click the 'Submit Order' button"
- **Fix**: Use concrete values from standard library:
  - Emails: test@example.com, invalid@test.com, user+test@example.com
  - Passwords: ValidP@ss123!, weak, tooshort1, 123456
  - Dates: 2024-01-15, 2024-12-31, 2024-02-29
  - Numbers: 0, 1, 50, 99, 100, 101, -1
  - URLs: https://app.example.com/login

### Failure Mode 4: Over-Specification (Implementation Testing)
- ❌ **BAD**: "Verify database row created in users table", "Verify API endpoint called"
- ✅ **GOOD**: "Verify confirmation message displays 'Account created successfully'"
- **Fix**: Test ONLY observable behavior (UI elements, messages, API responses), NOT internal implementation

### Failure Mode 5: Missing Negative Tests
- ❌ **BAD**: All tests verify success scenarios only
- ✅ **GOOD**: 30/40/30 distribution (30% positive, 40% negative, 30% edge)
- **Fix**: For every feature, generate:
  - 3 positive tests (valid inputs, happy path)
  - 3 negative tests (invalid inputs, errors)
  - 2 boundary tests (min/max limits)
  - 2 edge case tests (from 5 priority categories)

### Additional Common Mistakes

- **Non-reproducible scenarios**: Using relative dates ("yesterday") instead of absolute ("2024-01-15")
- **Undefined entities**: Referencing data not created in preconditions
- **No traceability tags**: Missing @REQ-{id} tags linking tests to requirements
- **Inconsistent tagging**: Not following @smoke/@regression/@priority pattern
- **Duplicate tests**: Creating multiple tests for same condition with different wording
