# Issue Body Templates — jaan-issue-report

> Language: Always English (regardless of conversation language).
> Template variables use `{{double-brace}}` syntax.
> Privacy: All content must pass sanitization before use.

---

## Bug Report Template

```markdown
## Description

{{bug_description}}

## Steps to Reproduce

{{steps_to_reproduce}}

## Expected Behavior

{{expected_behavior}}

## Actual Behavior

{{actual_behavior}}

## Environment

| Field | Value |
|-------|-------|
| jaan-to version | {{jaan_to_version}} |
| OS | {{os_info}} |
| Related skill | {{related_skill}} |

## Additional Context

{{additional_context}}
```

---

## Feature Request Template

```markdown
## Problem

{{problem_description}}

## Proposed Solution

{{proposed_solution}}

## Use Case

{{use_case}}

## Alternatives Considered

{{alternatives}}

## Related Skills/Features

{{related_features}}

## Environment

| Field | Value |
|-------|-------|
| jaan-to version | {{jaan_to_version}} |
| OS | {{os_info}} |
| Related skills | {{related_features}} |
```

---

## Skill Issue Template

```markdown
## Skill

`{{skill_name}}` (`/jaan-to:{{skill_command}}`)

## Description

{{issue_description}}

## Current Behavior

{{current_behavior}}

## Expected Behavior

{{expected_behavior}}

## Workflow Impact

{{workflow_impact}}

## Example

**Input:** {{example_input}}
**Expected output:** {{example_expected_output}}
**Actual output:** {{example_actual_output}}

## Environment

| Field | Value |
|-------|-------|
| jaan-to version | {{jaan_to_version}} |
| OS | {{os_info}} |
```

---

## Documentation Issue Template

```markdown
## Page/Section

{{doc_location}}

## Issue

{{issue_description}}

## Suggested Fix

{{suggested_fix}}

## Environment

| Field | Value |
|-------|-------|
| jaan-to version | {{jaan_to_version}} |
| OS | {{os_info}} |
```

---

## Metadata Footer (appended to all types)

```markdown
---

**Reported via:** `jaan-issue-report` skill
**jaan-to version:** {{jaan_to_version}}
**Session context used:** {{session_context}}
```

---

## Privacy Reminder

Before filling any template variable, verify:
- No absolute user paths (replace with `{USER_HOME}/{PROJECT_PATH}/...`)
- No credentials, tokens, or secrets (replace with `[REDACTED]`)
- No personal info (email, real name, IP) unless user approved
- Error messages are sanitized (paths and tokens stripped)
- Relative plugin paths are OK (e.g., `skills/pm-prd-write/SKILL.md`)
- Skill names, hook names, version numbers are OK
