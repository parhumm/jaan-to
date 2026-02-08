---
title: "pm-story-write"
sidebar_position: 4
---

# pm-story-write

> Generate user stories with Given/When/Then acceptance criteria following INVEST principles.

---

## Purpose

The `/jaan-to:pm-story-write` skill generates production-ready user stories in Connextra format ("As a [role], I want [action], so that [value]") with Gherkin Given/When/Then acceptance criteria. It enforces INVEST quality standards, provides systematic edge case coverage, and validates stories against Definition of Ready criteria.

---

## Command

```bash
/jaan-to:pm-story-write [input]
```

---

## Input Formats

The skill accepts three input formats:

### 1. Structured Format
```bash
/jaan-to:pm-story-write "[feature]" "[persona]" "[goal]"
```

**Example:**
```bash
/jaan-to:pm-story-write "bulk export feature" "system administrator" "analyze usage data offline"
```

### 2. Narrative Format
Provide a full feature description in natural language:

```bash
/jaan-to:pm-story-write "As an admin I need to export user data to Excel for compliance reporting"
```

The skill will extract feature, persona, and goal using the 5 Whys technique.

### 3. Jira Context (requires MCP)
Provide a Jira epic or story ID:

```bash
/jaan-to:pm-story-write PROJ-123
```

The skill will attempt to read context from Jira via MCP and use it to inform the story.

---

## Output

Creates a story file at:
```
jaan-to/outputs/pm/stories/{slug}/stories.md
```

Where `{slug}` is generated from the story title (lowercase, hyphens, max 50 chars).

---

## Workflow

The skill follows a two-phase workflow with a mandatory approval checkpoint:

### Phase 1: Analysis (Read-Only)

1. **Parse Input** - Extracts feature, persona, and goal from any input format
2. **Gather Context** - Asks up to 5 clarifying questions (only if needed):
   - Persona context (avoid generic "user")
   - Business value (applies 5 Whys technique)
   - Dependencies
   - Out-of-scope items
   - Related epic/stories
3. **Map Edge Cases** - Detects applicable categories from 10 standard patterns:
   - Empty States, Boundary Conditions, Permission Failures, Concurrency
   - Network Failures, Invalid Input, State Transitions, Internationalization
   - Timeout/Expiry, Bulk Operations
4. **Plan Story Structure** - Drafts persona/capability/value + 3-7 acceptance criteria scenarios
5. **HARD STOP** - Presents plan and waits for explicit approval

### Phase 2: Generation (Write Phase)

1. **Generate Content** - Creates 8-section story using template
2. **Quality Check** - Validates against three checkpoints:
   - INVEST Compliance (6 criteria)
   - AC Testability (observable outcomes)
   - Definition of Ready (10 items)
3. **Splitting Detection** - Suggests patterns if story is too large (>7 ACs or >8 points)
4. **Preview & Approval** - Shows complete story, waits for approval
5. **Write Output** - Saves to file system
6. **Export Formats** - Provides Jira CSV and Linear JSON for easy import
7. **Capture Feedback** - Offers to fix now, learn for future, or both

---

## Story Format

Generated stories follow this 8-section structure:

### 1. YAML Frontmatter
```yaml
---
story_id: US-XXX
epic: "Epic Name"
title: "Verb-First Title"
priority: high
status: draft
estimate: TBD
labels: [label1, label2]
created: 2026-02-02
last_updated: 2026-02-02
---
```

### 2. Context Paragraph
2-4 sentences explaining WHY this story exists (business drivers, metrics, user research).

### 3. Story Statement (Connextra Format)
```markdown
**As a** [specific persona with context]
**I want to** [single capability]
**So that** [business value]
```

### 4. Acceptance Criteria (Gherkin)
3-7 scenarios covering happy path + edge cases:

```gherkin
### Scenario 1: Happy Path Name
```gherkin
Given [precondition state]
When [user action]
Then [observable outcome]
  And [additional outcome]
```

### Scenario 2: Edge Case Name
```gherkin
Given [precondition]
When [action]
Then [outcome]
```
```

### 5. Scope
- **In-Scope**: Explicit deliverables
- **Out-of-Scope**: Deferred items with references

### 6. Dependencies
Table format with dependency, type, status, and owner.

### 7. Technical Notes
Brief implementation hints (API contracts, performance requirements).

### 8. Open Questions
Unresolved items with decision owners and deadlines.

### 9. Definition of Done
Standard checklist for completion criteria.

---

## Quality Gates

### INVEST Compliance (Checkpoint 1)

Every story is validated against all 6 INVEST criteria:

| Criterion | Validates |
|-----------|-----------|
| **Independent** | Can ship without other stories |
| **Negotiable** | Describes WHAT not HOW |
| **Valuable** | Delivers user/business value |
| **Estimable** | Team can understand and size |
| **Small** | Fits in one sprint (≤8 points) |
| **Testable** | Has clear pass/fail criteria |

### AC Testability (Checkpoint 2)

- Every "Then" clause has observable outcome
- No subjective criteria ("good UX", "fast")
- Quantified where applicable ("<2 seconds", "3 steps")

### Definition of Ready (Checkpoint 3)

10-item checklist including:
- Connextra format ✓
- Business value articulated ✓
- Specific persona (not "user") ✓
- 3-7 testable acceptance criteria ✓
- Edge cases covered ✓
- INVEST criteria pass ✓
- Sprint-sized ✓
- Dependencies identified ✓

---

## Edge Case Coverage

The skill auto-detects applicable edge case categories based on feature type:

### Detection Matrix

| Feature Type | Auto-Detected Categories | Min ACs |
|--------------|-------------------------|---------|
| CRUD operations | Empty States, Invalid Input, Concurrency, Boundary Conditions | 4 |
| API integration | Network Failures, Timeout/Expiry, Invalid Input | 4 |
| Multi-step workflow | State Transitions, Timeout/Expiry, Empty States | 4 |
| User input forms | Invalid Input, Boundary Conditions, Empty States | 4 |
| Multi-user/roles | Permission Failures, Concurrency | 3 |
| Data processing | Bulk Operations, Boundary Conditions, Timeout/Expiry | 4 |
| International app | Internationalization, Boundary Conditions | 3 |
| Real-time features | Concurrency, Network Failures, State Transitions | 4 |

All stories require: Happy path + at least 1 error handling + empty state (if data-driven)

---

## Story Splitting

If the story is too large (>7 acceptance criteria or >8 story points), the skill suggests splitting using one of 6 proven patterns:

1. **Workflow Steps** - Split multi-step processes into stages
2. **CRUD Operations** - Separate Create/Read/Update/Delete
3. **Happy Path First** - Core success now, edge cases later
4. **Data Variations** - Split by data types or complexity
5. **Spike + Implementation** - Research first, then implement
6. **Cross-Cutting Concerns** - Defer performance/security/scale

---

## Export Formats

After creating a story, the skill provides ready-to-use export formats:

### Jira CSV Import
```csv
Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels
"Story Title","Full story content","Story","High",TBD,"EPIC-123","label1,label2"
```

### Linear GraphQL
```json
{
  "input": {
    "title": "Story Title",
    "description": "Full story markdown",
    "priority": 2,
    "estimate": null,
    "labelIds": ["label-uuid"]
  }
}
```

---

## Examples

### Example 1: Password Reset Feature

**Input:**
```bash
/jaan-to:pm-story-write "password reset" "web app user" "regain access if forgotten"
```

**Generated Story:**
- **Persona**: Web app user who forgot their password
- **Feature**: Password reset via email link
- **Value**: Regain account access without support intervention
- **ACs**: 5 scenarios covering happy path, invalid email, expired link, password requirements, network timeout
- **Edge Cases**: Empty States, Invalid Input, Network Failures, Timeout/Expiry
- **Output**: `jaan-to/outputs/pm/stories/password-reset/stories.md`

### Example 2: Bulk Data Export

**Input:**
```bash
/jaan-to:pm-story-write "bulk export feature" "system administrator" "analyze usage data offline"
```

**Generated Story:**
- **Persona**: System administrator managing large datasets
- **Feature**: Export user data to CSV/Excel
- **Value**: Perform offline analysis and compliance reporting
- **ACs**: 6 scenarios covering export initiation, format selection, large files, progress tracking, download, empty state
- **Edge Cases**: Empty States, Bulk Operations, Timeout/Expiry, Invalid Input
- **Output**: `jaan-to/outputs/pm/stories/bulk-data-export/stories.md`

---

## Common Use Cases

| Use Case | Input Format | Expected ACs | Edge Cases |
|----------|-------------|--------------|------------|
| User authentication | Structured | 4-5 | Permission Failures, Invalid Input, Network Failures |
| Data export | Structured | 5-6 | Bulk Operations, Boundary Conditions, Timeout/Expiry |
| Multi-step checkout | Narrative | 6-7 | State Transitions, Network Failures, Empty States |
| Role-based access | Structured | 4-5 | Permission Failures, Concurrency |
| Search functionality | Structured | 5-6 | Empty States, Boundary Conditions, Invalid Input |
| Form validation | Structured | 4-5 | Invalid Input, Boundary Conditions, Empty States |

---

## Tips

### Best Practices

1. **Be specific with personas** - "Busy parent managing family schedule" is better than "user"
2. **State genuine value** - Apply 5 Whys to avoid feature-focused "so that" clauses
3. **Include out-of-scope** - Prevents scope creep and documents decisions
4. **Leverage Jira context** - Provides consistency with existing stories and team conventions
5. **Accept splitting suggestions** - Stories >7 ACs rarely fit in a sprint

### Common Mistakes to Avoid

- Using generic "As a user" without context
- Feature-focused value: "so I can export data" (output) vs "so I can reduce churn" (outcome)
- Implementation details in ACs: "Use Redux" (implementation) vs "Cart persists" (behavior)
- Skipping Out-of-Scope section
- Subjective ACs: "Intuitive UX" (not testable) vs "Completes in ≤3 steps" (testable)
- Missing empty state handling

---

## Feedback Capture

After generating a story, the skill offers three feedback options:

1. **Fix now** - Apply feedback to current story immediately
2. **Learn** - Save lesson via `/jaan-to:learn-add` for future improvements
3. **Both** - Fix current story AND save lesson

This continuous learning system improves story quality over time.

---

## Related

- **Research**: `jaan-to/outputs/research/45-pm-insights-synthesis.md` - Comprehensive framework
- **PRD Generation**: `/jaan-to:pm-prd-write` - Create full PRDs with success metrics
- **Learning**: `/jaan-to:learn-add` - Add lessons to improve skill execution

---

> Generated by jaan.to | 2026-02-02
