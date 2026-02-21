# pm-story-write — Reference Material

> Extracted from `skills/pm-story-write/SKILL.md` for token optimization.
> Contains edge case categories, splitting patterns, and validation checklists.

---

## 10 Edge Case Categories

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

### Auto-Detection Matrix

Apply based on feature type:

- **CRUD operations** → Categories 1, 2, 4, 6 (min 4 ACs required)
- **API integration** → Categories 5, 6, 9 (min 4 ACs required)
- **Multi-step workflow** → Categories 1, 7, 9 (min 4 ACs required)
- **User input forms** → Categories 1, 2, 6 (min 4 ACs required)
- **Multi-user/roles** → Categories 3, 4 (min 3 ACs required)
- **Data processing** → Categories 2, 9, 10 (min 4 ACs required)
- **International app** → Categories 2, 8 (min 3 ACs required)
- **Real-time features** → Categories 4, 5, 7 (min 4 ACs required)

---

## INVEST Compliance Checklist

| Criterion | Validation Question | Red Flag | Status |
|-----------|---------------------|----------|--------|
| **Independent** | Can ship without other stories? No blocking dependencies? | "Can only start after Story X completes" | [ ] |
| **Negotiable** | Describes WHAT not HOW? Flexible implementation? | "Use Redux for state management" | [ ] |
| **Valuable** | Delivers user/business value? Can articulate why? | "Refactor database schema" (no user value) | [ ] |
| **Estimable** | Team understands enough to estimate? Scope clear? | Team cannot agree on estimate range | [ ] |
| **Small** | Fits in one sprint? Ideally 1-3 days? | More than 8 points; spans sprints | [ ] |
| **Testable** | Can write pass/fail tests? Clear done definition? | "User has good experience" | [ ] |

---

## AC Testability Checklist

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

---

## Definition of Ready Checklist

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

---

## Story Splitting Detection Patterns

If story seems too large (>7 ACs or estimated >8 story points), consider these patterns:

**Pattern 1: Workflow Steps** - Split multi-step processes into individual stages
Example: Publish directly, publish with review, preview before publish

**Pattern 2: CRUD Operations** - Separate Create/Read/Update/Delete
Example: Create account, view account, update account, delete account

**Pattern 3: Happy Path First** - Core success scenario now, edge cases later
Example: Basic search now, filters later, zero results handling later

**Pattern 4: Data Variations** - Split by data types or complexity levels
Example: Upload PDF now, upload images later, upload large files later

**Pattern 5: Spike + Implementation** - Research first when uncertainty high
Example: Evaluate payment processors (spike), then implement chosen one

**Pattern 6: Cross-Cutting Concerns** - Defer performance/security/scale
Example: Search works correctly now, fast search later, concurrent search later

---

## Story Template — Sections 5-9 Format Specifications

### Section 5: Scope
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

### Section 6: Dependencies
```markdown
## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| {dependency_name} | {Story/Technical/Design} | {Done/In Progress/Pending} | {@owner} |

Or: "None"
```

### Section 7: Technical Notes (brief)
```markdown
## Technical Notes

{implementation_hints}

[Brief API contracts, database changes, performance requirements. Keep brief—details belong in task breakdown.]
```

### Section 8: Open Questions
```markdown
## Open Questions

- [ ] {Unresolved question needing decision} — @decider by YYYY-MM-DD
- [x] ~~{Resolved question}~~ — **Decision**: {outcome} (YYYY-MM-DD)

Or: "None"
```

### Section 9: Definition of Done
```markdown
## Definition of Done

- [ ] Acceptance criteria verified by QA
- [ ] Code reviewed and approved
- [ ] Unit tests written (≥80% coverage)
- [ ] Documentation updated
- [ ] PO acceptance received
```

---

## Export Formats

Tool export formats for importing stories into project management tools (from research Section 7):

**Jira CSV Import:**
```csv
Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels
"{title}","{story_body_first_paragraph}","Story","{priority}",TBD,"{epic}","{labels}"
```

**Linear GraphQL Mutation:**
```json
{
  "input": {
    "title": "{title}",
    "description": "{story_body_markdown}",
    "priority": {priority_number},
    "estimate": null,
    "labelIds": ["{label_ids}"]
  }
}
```

---

## Skill Definition of Done Checklist

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
