# Acceptance Criteria Best Practices: A Production-Ready Research Guide

**Transforming PRDs into testable, actionable acceptance criteria for SaaS applications**

Acceptance criteria serve as the contract between product requirements and verifiable outcomes. This research synthesizes industry standards, proven methodologies, and AI-specific considerations to build a production-ready skill that transforms Product Requirements Documents into comprehensive, testable acceptance criteria—complete with edge cases, error handling, and analytics requirements.

## Executive summary of key findings

**Standards convergence**: IEEE, ISTQB, and IIBA all define acceptance criteria as pass/fail conditions that must be testable, atomic, and unambiguous. The BABOK v3 specifically states AC must be "expressed in a testable form" and "presented as statements which can be verified as true or false."

**Format selection matters**: Gherkin (Given-When-Then) excels for complex behaviors and BDD automation, while checklist formats work better for simple CRUD operations. The decision should be feature-driven, not team-preference-driven.

**Edge cases are systematically identifiable**: Using heuristics like SFDPOT (Structure, Function, Data, Platform, Operations, Time) and standard taxonomies, edge cases can be derived methodically rather than relying on intuition.

**AI-generated AC requires guardrails**: LLMs achieve **96% coverage** against ground truth requirements but "meet acceptance quality criteria less frequently" than human-written AC. Template enforcement, explicit edge case prompting, and human-in-the-loop validation are essential.

**Analytics AC enables measurement**: Every PRD success metric requires corresponding analytics events. The pattern "Track event X with properties {a, b, c}" should be standard practice for any feature touching core funnels.

---

## 1. Industry standards and format specifications

### Foundational standards

**ISO/IEC/IEEE 29148:2018** is the current international standard for requirements engineering, defining acceptance criteria as part of requirements documentation with emphasis on measurability and testability. **IEEE 830-1998** (now superseded) established that requirements must be "correct, unambiguous, complete, consistent, verifiable, modifiable, traceable."

**ISTQB** (International Software Testing Qualifications Board) provides the authoritative definition: acceptance criteria are "the exit criteria that a component or system must satisfy in order to be accepted by a user, customer, or other authorized entity." These serve as the **test basis**—documents from which test cases are derived.

**IIBA BABOK v3** (Technique 10.1) describes acceptance criteria as "the minimum set of requirements that must be met in order for a solution to be considered acceptable." Key BABOK guidance includes: AC must be pass/fail, expressed in testable form, and may require breaking requirements into atomic form.

**ISO/IEC 25010:2023** defines a software quality model with 9 characteristics (functional suitability, reliability, security, etc.) explicitly stating the model can be used for "identifying acceptance criteria for a product." This provides a comprehensive framework for non-functional AC coverage.

### The BDD/Gherkin specification

The official Cucumber.io specification defines Gherkin as "a set of grammar rules that makes plain text structured enough for Cucumber to understand." The primary keywords are:

- **Given** — Initial context/precondition (past tense, describes system state)
- **When** — Action/event (user interaction or system trigger)
- **Then** — Expected outcome/result (observable output)
- **And/But** — Additional steps
- **Scenario Outline + Examples** — Parameterized scenarios

Best practices from official documentation recommend **3-5 steps per scenario**—too many loses expressive power. `Given` steps should describe past state, not user interaction. `Then` steps should verify **observable outputs**, not internal database states.

### Format selection guidance

| Format | Best For | Automation | Complexity |
|--------|----------|------------|------------|
| **Gherkin (GWT)** | Complex behaviors, multiple paths, BDD automation | High | Medium-High |
| **Checklist** | Simple features, CRUD, quick validation | Low | Low |
| **Scenario-based** | Medium complexity, no automation planned | Medium | Medium |
| **Rules-based** | Business logic, conditional requirements | Medium | Medium |

**Use Gherkin when**: Feature has multiple paths/permissions/edge cases, team uses BDD automation tools (Cucumber, SpecFlow), behavior matters more than screens, defining complex business rules.

**Use Checklists when**: Simple requirements with straightforward pass/fail, tiny UI tweaks, quick validation needs, team doesn't use BDD tooling.

### INVEST criteria applied to acceptance criteria

The INVEST acronym, while designed for user stories, directly applies to AC quality:

- **Independent** — Each AC testable separately
- **Negotiable** — Open to refinement during discussion
- **Valuable** — Connects to user/business value
- **Estimable** — Effort can be assessed
- **Small** — Achievable within sprint
- **Testable** — Has clear pass/fail outcome

---

## 2. Core methodologies for writing acceptance criteria

### SMART validation framework

SMART criteria provide a validation checklist for AC quality:

| Dimension | Application to AC | Validation Question |
|-----------|-------------------|---------------------|
| **Specific** | Clearly state exact behavior without vague terms | Does it avoid "fast," "user-friendly," "appropriate"? |
| **Measurable** | Define quantifiable outcomes | Does it include numbers, timeframes, or verifiable states? |
| **Achievable** | Ensure criteria can realistically be implemented | Is it technically feasible within constraints? |
| **Relevant** | Connect directly to user value | Does it tie to the story's goal? |
| **Testable** | Can be objectively verified | Can QA write a test case from this? |

**Non-SMART examples to avoid**: "The system should be fast" → Transform to: "Search results load in under 200ms for catalogs up to 1,000 items."

### Example Mapping technique

Developed by **Matt Wynne** (Cucumber co-founder), Example Mapping uses four card colors in collaborative sessions:

- 🟡 **Yellow** — The user story being discussed (placed at top)
- 🔵 **Blue** — Rules/acceptance criteria (placed below story)
- 🟢 **Green** — Concrete examples illustrating rules (placed under relevant rule)
- 🔴 **Red** — Questions/uncertainties (captured for later resolution)

**Session structure** (recommended 25 minutes): Write story card → identify known rules → generate examples for each rule → capture questions → thumb-vote on readiness.

**Visual heuristics**: Many red cards indicate too much uncertainty. Many blue cards suggest the story is too big and should be split. Many green cards under one blue card means the rule may be overly complex.

### Specification by Example principles

**Gojko Adzic's** seven key patterns from research across 50+ projects:

1. **Derive scope from goals** — Start with business goal, not solution
2. **Specify collaboratively** — Involve business, development, and testing
3. **Illustrate using examples** — Concrete examples explore the domain
4. **Refine the specification** — Iterate until clear
5. **Automate validation without changing specifications** — Tests read like specs
6. **Validate frequently** — Run automated specs regularly
7. **Evolve living documentation** — Specs become always-current docs

### Three Amigos collaboration model

Three Amigos sessions bring together three perspectives before development:

| Role | Question Answered | Contribution |
|------|-------------------|--------------|
| **Product/Business** | "What problem are we solving?" | Business value, user needs, acceptance criteria drafts |
| **Development** | "How might we build this?" | Technical feasibility, constraints, alternatives |
| **Testing/QA** | "How will we know it works?" | Test scenarios, edge cases, testability validation |

**Optimal timing**: 30-60 minutes, scheduled 1-2 sprints before development. Share materials 24 hours in advance. Outputs include refined AC, identified test scenarios, logged questions, and documented dependencies.

### ATDD cycle: Discuss-Distill-Develop-Demo

Acceptance Test-Driven Development drives implementation from acceptance tests written before code:

1. **Discuss** — Three Amigos clarify requirements, identify AC
2. **Distill** — Convert discussions into formal acceptance tests (Given-When-Then)
3. **Develop** — Write code to make acceptance tests pass
4. **Demo** — Demonstrate feature to stakeholders against acceptance tests

The key distinction from TDD: ATDD is customer-focused (tests business requirements) while TDD is developer-focused (tests technical implementation).

---

## 3. PRD to acceptance criteria transformation

### Systematic extraction mapping

| PRD Section | Transformation Target | Extraction Technique |
|-------------|----------------------|----------------------|
| **Problem Statement** | Context for AC | Extract "why" to inform value proposition; use as rationale |
| **User Stories** | Base scenarios | Convert to Given-When-Then; each story gets 3-12 AC |
| **Success Metrics** | Analytics/Performance AC | Translate KPIs into measurable "Then" statements |
| **Scope (In/Out)** | Exclusion criteria | Document what system does NOT do; create negative scenarios |
| **Technical Constraints** | Non-functional AC | Security, scalability, performance become testable criteria |
| **Dependencies** | Integration AC | Define interface contracts, API behaviors, handoff points |

### Six-step transformation workflow

**Step 1: Requirements decomposition** — Break PRD into atomic units of functionality. Each feature becomes 1-5 user stories.

**Step 2: User story formulation** — Apply template: "As a [role], I want [action/feature] so that [value/goal]." Keep stories small enough for one sprint.

**Step 3: Acceptance criteria definition** — Target **3-12 AC per story**. If >12 AC, split the story. Each AC must be binary pass/fail.

**Step 4: Format selection** — Choose Gherkin for testable behaviors requiring automation, checklist for simple requirements.

**Step 5: Validation** — Review with Three Amigos. Confirm testability. Identify missing edge cases.

**Step 6: Traceability linking** — Map AC back to PRD requirements. Link to test cases. Document in Requirements Traceability Matrix.

### Handling ambiguous and incomplete PRDs

**Decision framework**:

| Situation | Action | Rationale |
|-----------|--------|-----------|
| Success metrics missing | **Ask PM** | Cannot infer business goals |
| Vague performance ("fast") | **Ask + propose metric** | Need testable threshold |
| Missing edge case handling | **Infer with flag** | Document assumption, validate later |
| Conflicting requirements | **Escalate immediately** | PM must resolve priorities |
| Missing persona details | **Infer from context** | Flag as low-confidence |

**Red flag words requiring clarification**: "generally," "reasonably," "mostly," "should," "could," "might," "intuitive," "easy to use"

**Assumption documentation template**:
```
[ASSUMPTION FLAG]
PRD Section: [Reference]
Missing Element: [What's missing]
Assumed Value: [What we're assuming]
Confidence: HIGH | MEDIUM | LOW
Action Required: [Clarify | Proceed | Defer]
```

### Story splitting patterns

**Triggers for splitting** (when AC indicates story is too large):

- More than 12 acceptance criteria
- Multiple "And" conditions in Given-When-Then
- Contains word "manage" (implies CRUD)
- Multiple user roles involved
- Performance and functionality mixed

**Primary splitting patterns**:

1. **Workflow steps** — Split by sequential stages
2. **Operations (CRUD)** — Separate create, read, update, delete
3. **Business rule variations** — One story per rule
4. **Data variations** — Split by data type/format
5. **Simple/Complex** — Build basic first, add complexity incrementally
6. **Defer performance** — "Make it work" then "make it fast"

---

## 4. Structure and organization patterns

### Recommended document hierarchy

```
PRD/Epic Level
└── Feature/User Story
    └── Acceptance Criteria
        ├── Happy Path Scenarios
        ├── Alternative Path Scenarios
        ├── Error/Exception Scenarios
        └── Edge Cases
```

### Required fields for each acceptance criterion

| Field | Description | Example |
|-------|-------------|---------|
| **AC-ID** | Unique identifier | `AC-001` or `FEAT-001-AC-001` |
| **Scenario/Title** | Descriptive name | "Successful user login with valid credentials" |
| **Preconditions (Given)** | State before action | "User has valid credentials" |
| **Action/Trigger (When)** | User or system action | "User clicks Login button" |
| **Expected Result (Then)** | Observable outcome | "User redirected to dashboard within 2 seconds" |
| **Priority** | Must/Should/Could | Must-have |
| **Type** | Functional/Non-functional/Analytics | Functional |
| **Status** | Draft/Ready/Verified | Ready |

**Optional fields**: Linked PRD section, linked user story, edge case category, test notes, automation status, dependencies, test data requirements.

### ID scheme options

| Scheme | Format | Best For |
|--------|--------|----------|
| Simple sequential | `AC-###` | Small projects |
| Feature-scoped | `FEAT-###-AC-###` | Feature-organized projects |
| Story-scoped | `US-###-AC-###` | Story-centric workflows |
| Hierarchical | `EPIC.STORY.AC` | Complex products |

### Organization strategies

**Hybrid approach (recommended)**:
1. **Primary**: Group by feature area
2. **Secondary**: Within feature, organize by Happy Path → Alternative → Error → Edge Cases
3. **Tagging**: Apply priority (P0-P3) and type (Functional/Non-functional) labels

**Atomic criteria principles**: Each AC should be independently testable, have a single pass/fail outcome, and not depend on other criteria for verification.

---

## 5. Coverage and completeness framework

### Coverage model categories

| Category | Coverage Elements |
|----------|------------------|
| **Functional** | All features, all user actions, CRUD operations |
| **Edge Case** | Empty states, boundaries, special characters |
| **Error Handling** | Validation errors, system errors, recovery |
| **Analytics** | Events, properties, success metric tracking |
| **Performance** | Load times, response times, concurrent users |
| **Security** | Authentication, authorization, input sanitization |
| **Accessibility** | WCAG compliance, screen readers, keyboard navigation |
| **Integration** | API contracts, webhooks, third-party services |

### Risk-based prioritization with MoSCoW

| Category | Definition | AC Allocation |
|----------|------------|---------------|
| **Must Have** | Critical for success; project fails without | ~60% of effort |
| **Should Have** | Important but not critical; workarounds possible | ~20% of effort |
| **Could Have** | Desirable if resources permit | ~15% of effort |
| **Won't Have** | Explicitly excluded from current scope | Documented for future |

### Sufficiency thresholds by feature type

| Feature Type | Min AC Count | Required Categories |
|--------------|--------------|---------------------|
| Simple form | 3-5 | Validation, success, error |
| CRUD operation | 5-8 | Create, read, update, delete, permissions |
| Multi-step workflow | 8-15 | Each step, transitions, error recovery |
| Integration point | 5-10 | Request, response, errors, edge cases |
| Report/dashboard | 4-8 | Data accuracy, filters, performance |

**Stop adding AC when**: New AC don't map to actual user scenarios, marginal defect detection approaches zero, team velocity significantly impacted, coverage reaches 85-95% for risk-adjusted features.

### Traceability matrix structure

| Req ID | PRD Section | User Story | AC ID | Test Case | Status |
|--------|-------------|------------|-------|-----------|--------|
| REQ-001 | 3.1 | US-005 | AC-001 | TC-001 | Verified |

**Bidirectional traceability**: Forward (PRD → Story → AC → Test → Result) and Backward (Defect → Test → AC → Story → PRD).

---

## 6. Edge cases and error handling taxonomy

### Comprehensive edge case categories for SaaS web apps

#### Data edge cases

| Category | Examples | Testing Approach |
|----------|----------|------------------|
| **Empty/null states** | No data on first use, empty search results, null fields | Verify placeholder text, CTAs, guidance messages |
| **Boundary values** | Min/max values, length limits (0, 1, max-1, max, max+1) | Test at exact boundaries plus one above/below |
| **Invalid formats** | Malformed emails, invalid dates, wrong phone formats | Validate input; show specific error messages |
| **Large datasets** | Pagination limits, 10K+ records, infinite scroll | Measure response times, test memory handling |
| **Special characters** | Unicode, emoji, HTML entities, injection attempts | Sanitize input; preserve legitimate characters |

#### User flow edge cases

| Scenario | Expected Behavior |
|----------|-------------------|
| **Back button mid-flow** | Preserve state or show clear message; prevent duplicate submissions |
| **Browser refresh mid-flow** | Warn before losing data; support auto-save |
| **Multi-tab usage** | Sync state across tabs; lock resources appropriately |
| **Session expiry during flow** | Save progress; redirect to login; restore after re-auth |
| **Permission changes mid-flow** | Graceful denial with clear message; prevent data loss |

#### Integration edge cases

| Type | Handling Strategy |
|------|-------------------|
| **API failures (5xx)** | Graceful degradation; cached fallbacks; clear user messaging |
| **Network timeouts** | Configurable timeouts; retry with exponential backoff; user cancellation |
| **Partial failures** | Report partial success; allow retry of failures; maintain consistency |
| **Rate limiting (429)** | Exponential backoff; queue requests; surface limits to users |
| **OAuth token expiry** | Silent refresh; re-authentication flow; preserve user context |

#### State edge cases

| Issue | Prevention/Detection |
|-------|---------------------|
| **Race conditions** | Atomic operations; database transactions; optimistic locking |
| **Double submissions** | Idempotency keys; disable button on click; server-side deduplication |
| **Conflicting updates** | Optimistic concurrency (ETags); conflict resolution UI |
| **Stale data** | Cache invalidation; real-time updates; refresh mechanisms |

### Systematic edge case identification using SFDPOT

| Letter | Element | Questions to Ask |
|--------|---------|------------------|
| **S** | Structure | What is the product made of? Components, architecture? |
| **F** | Function | What does it do? Features, calculations, workflows? |
| **D** | Data | What inputs/outputs? Types, formats, transformations? |
| **P** | Platform | What does it run on? Browsers, devices, dependencies? |
| **O** | Operations | Who uses it? User types, real-world patterns? |
| **T** | Time | How does time affect it? Timeouts, scheduling, concurrency? |

### Error handling pattern library

**Error classification**:

| Type | User Approach | Technical Approach |
|------|--------------|-------------------|
| **Validation errors** | Clear, specific message; highlight field; suggest correction | Client + server validation; field-level errors |
| **System errors** | "Please try again"; auto-retry option | Exponential backoff; circuit breakers |
| **Fatal errors** | Apologize; provide reference ID; offer support contact | Log extensively; alert on-call; preserve state |

**Recovery patterns**:
- **Retry**: Max 3-5 attempts, exponential backoff (1s, 2s, 4s), jitter to prevent thundering herd
- **Rollback**: Database transactions, compensating transactions for distributed systems
- **Fallback**: Cached data, degraded functionality, alternative endpoints
- **Graceful degradation**: Health status levels, feature flags, priority queues

---

## 7. Analytics requirements in acceptance criteria

### Standard analytics AC pattern

```
ANALYTICS: Track event '[Event Name]' with properties:
  - property_name: data_type (required/optional) - description
TRIGGER: [When the event should fire]
VALIDATION: [How to verify correct implementation]
```

### Event naming conventions

**Segment's Object-Action framework** (most widely adopted):
- Format: `Object Action` (Title Case)
- Examples: `User Signed Up`, `Product Added`, `Order Completed`
- Use past tense to indicate completed action

**Property naming**: Use `snake_case` consistently. Keep event properties and user properties with distinct names to avoid confusion.

### Core SaaS events (nearly mandatory)

| Event | Properties | Trigger |
|-------|------------|---------|
| `User Signed Up` | signup_method, referrer, plan_selected | Registration completed |
| `User Logged In` | login_method, success | Login attempt completed |
| `Subscription Started` | plan_id, billing_cycle, revenue | First payment processed |
| `Feature Activated` | feature_name, time_to_activate | Key feature first used |
| `Trial Started` | trial_duration, plan_id | Trial begins |

### Linking to PRD success metrics

**Traceability pattern**:
```
PRD Goal: "Increase signup conversion from 15% to 20%"
    ↓
Required Analytics:
- Event: Signup Form Viewed (funnel start)
- Event: Signup Form Submitted (funnel end)
- Property: experiment_variant (for A/B testing)
- Calculated Metric: Submitted / Viewed = Conversion Rate
```

### Example: Checkout flow analytics AC

```
Feature: E-commerce Checkout

ANALYTICS AC:
- Track 'Checkout Started' when user enters checkout
  Properties:
    - cart_value: number (required)
    - item_count: number (required)
    - currency: string (required)

- Track 'Payment Failed' on processor error
  Properties:
    - error_type: string (card_declined, expired, insufficient)
    - payment_method: string
    - retry_count: number

- Track 'Order Completed' on successful purchase
  Properties:
    - order_id: string (required)
    - revenue: number in cents (required)
    - billing_cycle: string
    - discount_applied: boolean
```

### PII considerations

**Never include in event properties**: Email addresses, full names, phone numbers, SSNs, IP addresses, precise geolocation.

**Safe pattern**:
```javascript
// ❌ Bad
analytics.track('Sign Up', { email: 'user@example.com' });

// ✅ Good
analytics.track('Sign Up', { 
  user_id: 'hashed_id_abc123',
  signup_method: 'email'
});
```

---

## 8. Tool ecosystem and integration patterns

### Jira implementation options

**Custom paragraph field**: Create via Project Settings → Issues → Custom Fields → "Paragraph (supports rich text)." Name it "Acceptance Criteria" and configure renderer to "Wiki style."

**Checklist plugins** (recommended for production):
- **Smart Checklist for Jira**: Custom statuses, full-screen editor, workflow validation
- **Issue Checklist Pro**: Permissions control, blocking transitions
- **Checklists for Jira (Pro)**: Templates, automation triggers

**Workflow integration**: Add validator to block transition (e.g., "In Progress" → "Done") unless all AC items checked.

**Test management linking**: Xray and Zephyr provide native traceability. Link types: `Tested By` (requirement → test) and `Tests` (test → requirement).

### Linear implementation

Linear uses markdown natively with interactive checkboxes:

```markdown
## Acceptance Criteria
- [ ] User can enter email and password
- [ ] System validates credentials  
- [ ] Successful login redirects to dashboard within 2 seconds
```

Use labels for categorization (happy-path, edge-case, etc.) and sub-issues for large AC requiring separate tracking.

### Import/export format schemas

**YAML schema for AC**:
```yaml
acceptance_criteria:
  - id: AC-001
    description: "User can enter email and password"
    type: functional
    priority: high
    status: approved
    gherkin:
      given: "User is on login page"
      when: "User enters valid credentials"
      then: "User is redirected to dashboard"
    test_cases:
      - TC-001
      - TC-002
```

**JSON schema** supports validation with required fields (id, description, status) and enumerated values for type and priority.

### Traceability patterns

**Forward**: PRD Document → Epic → User Story → AC → Test Case → Test Result
**Backward**: Defect → Failed Test → Test Case → AC → User Story → PRD Requirement

**Link types across tools**:
- Jira: `is tested by` / `tests`
- Azure DevOps: `Tested By` / `Tests`
- Custom: Bi-directional custom link types

---

## 9. Quality gates and validation rules

### Good vs. bad AC characteristics

| Quality Attribute | Validation Rule |
|------------------|-----------------|
| **Testable** | Can QA write a test for this criterion? |
| **Clear** | No terms like "fast," "user-friendly" without metrics |
| **Measurable** | Contains numbers, timeframes, verifiable states |
| **User-focused** | Describes behavior/outcome, not implementation |
| **Atomic** | One pass/fail condition only |

### Anti-pattern catalog

| Anti-Pattern | Bad Example | Good Example |
|--------------|-------------|--------------|
| **Vague success criteria** | "Page loads quickly" | "Page loads within 2 seconds on 3G" |
| **Implementation details** | "Use MySQL to store data" | "User data persists across sessions" |
| **Missing error scenarios** | Only happy path | Include: "If login fails 3x, account locks" |
| **Compound criteria** | "User can login AND view dashboard" | Split into 2 separate criteria |
| **UI-specific language** | "Button is blue and 44px" | "User can submit via clearly labeled action" |

### Peer review checklist

**Clarity & testability**:
- [ ] Written in clear, non-technical language?
- [ ] Can QA create test case directly from this?
- [ ] Pass/fail outcome unambiguous?
- [ ] Avoids vague terms?

**Scope & independence**:
- [ ] Describes WHAT, not HOW?
- [ ] Single, atomic requirement?
- [ ] Independent from other criteria?

**Completeness**:
- [ ] Positive scenarios covered?
- [ ] Error scenarios included?
- [ ] Edge cases addressed?

### Definition of Ready for AC

```
ACCEPTANCE CRITERIA REQUIREMENTS
□ AC is defined and documented
□ Each criterion is testable (pass/fail)
□ Positive scenarios are covered
□ Error scenarios are included
□ AC uses clear, unambiguous language
□ No implementation details
□ 3-5 AC per story (split if more needed)
□ AC reviewed by team (Three Amigos)
□ Product Owner has approved
□ QA can write tests from AC
```

---

## 10. AI-specific considerations for generating AC

### LLM capabilities and limitations

**What LLMs do well**:
- Generate initial AC drafts rapidly
- Apply consistent formats reliably
- Surface edge cases humans might overlook
- Produce grammatically correct, well-structured criteria

**Research findings**: LLMs achieve **96.23% coverage** against ground truth requirements but "meet acceptance quality criteria less frequently" than human-written AC, regardless of model scale.

### Failure mode taxonomy

| Failure Mode | Mitigation |
|--------------|------------|
| **Too generic/vague** | Provide detailed context, domain info, constraints |
| **Missing edge cases** | Explicitly prompt for error scenarios and boundaries |
| **Hallucinated requirements** | Ground with RAG; validate against requirements docs |
| **Implementation-specific** | Add instruction: "Focus on WHAT, not HOW" |
| **Inconsistent formatting** | Provide template examples in prompt |

### Effective prompt patterns

**Context-rich prompting**:
```
Context: [Product description, domain, user personas]
User Story: [Full user story]
Constraints: [Business rules, technical constraints]

Generate acceptance criteria that:
- Cover the happy path scenario
- Include validation/error handling
- Address edge cases for [specific boundaries]
- Use Given/When/Then format
```

**Few-shot example pattern**:
```
GOOD: "Given a user is on the login page, when they enter valid credentials 
       and click submit, then they are redirected to the dashboard within 2 seconds"

BAD: "User can login successfully" (too vague)
BAD: "System uses JWT tokens" (implementation detail)

Now generate AC for: [User Story]
```

**Edge case explicit prompting**:
```
Generate acceptance criteria specifically including:
- Empty/null input handling
- Maximum/minimum boundary values
- Timeout/unavailable service scenarios
- Permission/authorization failures
- Concurrent user scenarios
```

### Human-in-the-loop validation points

1. **Business logic validation** — AI cannot verify domain-specific rules
2. **Scope alignment** — Humans confirm AC matches project scope
3. **Priority assessment** — Business value prioritization requires judgment
4. **Stakeholder acceptance** — Final approval from Product Owner
5. **Technical feasibility** — Development team validates achievability

### Output validation rules

```
Template enforcement:
- format: "Given/When/Then"
- max_criteria: 5
- required_scenarios: ["happy_path", "error_handling", "edge_case"]
- forbidden_terms: ["should", "appropriate", "as expected"]
- required_fields: ["user_role", "action", "expected_outcome"]
```

---

## 11. Real-world examples across complexity levels

### Simple CRUD: User profile update

```gherkin
Feature: User Profile Update

Scenario: Successful profile update
Given a logged-in user is on their profile settings page
When they update their display name to "Jane Smith"
And click "Save Changes"
Then the display name updates to "Jane Smith"
And a success message "Profile updated" appears
And the change persists on page refresh

Scenario: Invalid email format
Given a user is editing their email address
When they enter "invalid-email-format"
Then error message "Please enter a valid email address" displays
And the Save button remains disabled

Edge Cases:
- [ ] Display name accepts Unicode characters (emoji, Chinese, Arabic)
- [ ] Display name rejects HTML/script tags (sanitization)
- [ ] Maximum 100 characters for display name
- [ ] Empty display name shows "Display name is required"
```

### Medium workflow: Multi-step checkout

```gherkin
Feature: E-commerce Checkout

Scenario: Successful checkout with proration
Given customer has items in cart totaling $99.00
And customer has valid payment method on file
When customer completes all checkout steps
Then order confirmation displays with order number
And confirmation email sent within 2 minutes
And cart is emptied

Scenario: Payment declined
Given customer completes shipping information
When payment processor declines the card
Then error message "Payment declined. Please try another card." displays
And customer remains on payment step
And cart contents are preserved

Scenario: Item becomes unavailable during checkout
Given customer has "Widget X" in cart
When another customer purchases last unit during checkout
Then alert displays "Widget X is no longer available"
And cart updates automatically
And total recalculates

Edge Cases:
- [ ] Session timeout (10 min inactivity): warn at 9 min, preserve cart
- [ ] Browser back button: confirm "Leave checkout?" if data entered
- [ ] Double-click submit: idempotency key prevents duplicate orders
- [ ] Network disconnect during payment: show "Processing..." max 30 seconds

Analytics:
- Track 'Checkout Started': cart_value, item_count, currency
- Track 'Payment Failed': error_type, retry_count
- Track 'Order Completed': order_id, revenue (cents), discount_applied
```

### Complex integration: Third-party API sync

```gherkin
Feature: CRM Data Synchronization

Scenario: Successful bidirectional sync
Given CRM integration is connected and authenticated
When sync runs on scheduled interval (every 15 minutes)
Then new contacts from CRM appear in system within 15 minutes
And new contacts from system appear in CRM within 15 minutes
And sync status shows "Last sync: [timestamp]"

Scenario: Partial sync failure
Given sync processes 100 contact records
When 3 records fail validation (invalid email format)
Then 97 records sync successfully
And error log shows "Synced 97/100. 3 failed. [View details]"
And failed records available for manual retry

Scenario: API rate limit exceeded
Given sync is running
When CRM API returns 429 (rate limited)
Then sync pauses with exponential backoff (1m, 5m, 15m)
And status shows "Sync paused - rate limited. Resuming in [X] minutes"
And admin notification sent if pause exceeds 1 hour

Scenario: OAuth token expiry mid-sync
Given sync is processing records
When OAuth token expires
Then system attempts silent token refresh
If refresh succeeds: sync continues uninterrupted
If refresh fails: status shows "Re-authentication required"
And sync pauses until user re-authenticates

Error Recovery:
- Retry failed records 3 times before marking as permanent failure
- Preserve partial progress on any failure
- Never lose data: queue locally if API unavailable
- Alert admin after 3 consecutive full-sync failures

Integration AC:
- [ ] Connection timeout: 30 seconds
- [ ] Request retry: 3 attempts with exponential backoff
- [ ] Rate limit handling: respect Retry-After header
- [ ] Conflict resolution: CRM is source of truth for contact data
- [ ] Webhook delivery: retry up to 72 hours on failure
```

### Before/after transformation examples

**Transform 1: Vague → Specific**
- ❌ "The system should be user-friendly"
- ✅ "All form fields have placeholder text and error messages appear within 1 second of invalid input. Tab order follows logical reading sequence."

**Transform 2: Implementation → Behavior**
- ❌ "When the system calls the authentication API..."
- ✅ "When I enter valid login credentials and click 'Login', I see my dashboard within 3 seconds."

**Transform 3: Missing error handling → Complete**
- ❌ "User can upload a file"
- ✅ "User can upload JPG/PNG files up to 5MB. Files exceeding limit show 'File too large (max 5MB).' Invalid formats show 'Please upload JPG or PNG only.'"

---

## 12. Cross-role integration patterns

### AC → Test cases (qa:test-cases)

Each AC scenario maps to one or more test cases:

```
AC: Given valid credentials, when user clicks Login, then redirected to dashboard

Test Cases:
- TC-001: Login with valid email/password → verify redirect
- TC-002: Login with valid email/password → verify redirect time <2s
- TC-003: Login with valid email/password → verify session created
```

**Format compatibility**: Gherkin AC directly executable in Cucumber, SpecFlow, Behave. Checklist AC requires manual test case derivation.

### AC → User stories (pm:story-write)

AC groupings inform story splitting:

```
If AC includes:
- Multiple user roles → split by role
- Multiple data variations → split by variation
- Performance AND functionality → split into separate stories
- >12 criteria → split by workflow step
```

### AC → Event specifications (data:event-spec)

Analytics AC maps directly to event specifications:

```
Analytics AC: Track 'User Signed Up' with signup_method, referrer
    ↓
Event Spec:
{
  "event_name": "User Signed Up",
  "properties": {
    "signup_method": {"type": "string", "enum": ["email", "google", "github"]},
    "referrer": {"type": "string", "required": false}
  }
}
```

### Handoff patterns

| From | To | Artifact | Validation |
|------|-----|----------|------------|
| PM | Dev | AC document | Dev understands what to build |
| PM | QA | AC document | QA can write test cases |
| Dev | QA | Implemented feature | All AC scenarios testable |
| QA | PM | Test results | Each AC marked pass/fail |

---

## Template recommendations

### Minimal AC template (for Jira/Linear)

```markdown
## Acceptance Criteria

### Happy Path
- [ ] **AC-001**: Given [context], when [action], then [outcome]

### Error Handling  
- [ ] **AC-002**: Given [error condition], then [error handling]

### Edge Cases
- [ ] **AC-003**: Given [boundary condition], then [expected behavior]
```

### Comprehensive AC template

```markdown
# Feature: [Feature Name]
**PRD Reference:** [PRD-XXX Section Y]
**User Story:** As a [role], I want [goal] so that [benefit]

## Acceptance Criteria

### Functional Requirements
| AC-ID | Scenario | Given | When | Then | Priority |
|-------|----------|-------|------|------|----------|
| AC-001 | Happy path | [precondition] | [action] | [result] | P0 |

### Error Handling
| AC-ID | Error Condition | Expected Behavior | Priority |
|-------|-----------------|-------------------|----------|
| AC-002 | [error] | [handling] | P0 |

### Edge Cases
| AC-ID | Boundary Condition | Expected Behavior | Priority |
|-------|-------------------|-------------------|----------|
| AC-003 | [edge case] | [behavior] | P1 |

### Non-Functional Requirements
| AC-ID | Category | Requirement | Measurement |
|-------|----------|-------------|-------------|
| AC-004 | Performance | Page load time | < 2 seconds |
| AC-005 | Accessibility | Screen reader | WCAG 2.1 AA |

### Analytics Requirements
- Track '[Event Name]' with properties: [property list]
- Trigger: [when event fires]

## Assumptions & Open Questions
- [ASSUMED] [assumption with confidence level]
- [TBD] [question requiring clarification]
```

---

## Quality validation checklist

### AC quality gates

✅ **Testable** — Clear pass/fail criteria; QA can write test from this  
✅ **Specific** — No ambiguous terms ("fast," "user-friendly")  
✅ **Measurable** — Includes numbers, timeframes, verifiable states  
✅ **User-focused** — Describes WHAT, not HOW  
✅ **Atomic** — One requirement per criterion  
✅ **Complete** — Covers happy path, errors, edge cases  
✅ **Sized appropriately** — 3-7 criteria per story  

### Red flags to catch

❌ Vague terms without metrics  
❌ Implementation details  
❌ Compound criteria (multiple AND/OR)  
❌ Missing error scenarios  
❌ Untestable statements  
❌ UI-specific appearance details  
❌ >12 criteria (split the story)  

### AI generation workflow

1. **Generate**: Use LLM with context-rich, templated prompts
2. **Validate**: Apply automated validation rules against quality checklist
3. **Review**: Human review for business alignment and technical feasibility
4. **Refine**: Iterative improvement targeting flagged issues
5. **Approve**: Product Owner final sign-off
6. **Document**: Add to backlog with DoR checklist complete

---

## Conclusion

Building a production-ready acceptance criteria skill requires synthesizing standards (IEEE, ISTQB, IIBA), methodologies (BDD, Example Mapping, ATDD), and practical patterns for edge cases, analytics, and tool integration. The key insight is that AC quality directly determines testability, and testability determines whether features can be verified as complete.

For AI-powered generation, the critical guardrails are: explicit edge case prompting, template enforcement, forbidden term detection, and mandatory human-in-the-loop validation for business logic and scope alignment. LLMs excel at structural consistency and coverage breadth but require grounding to avoid hallucination and over-generalization.

The most effective AC combines **specificity** (measurable outcomes), **completeness** (happy path + errors + edge cases), and **traceability** (linkage to PRD requirements, test cases, and analytics events). When these elements align, acceptance criteria become the reliable contract between product vision and verifiable delivery.