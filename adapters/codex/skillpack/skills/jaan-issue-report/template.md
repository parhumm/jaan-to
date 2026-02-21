# Issue Body Templates — jaan-issue-report

> Language: Always English (regardless of conversation language).
> Template variables use `{{double-brace}}` syntax.
> Privacy: All content must pass sanitization before use.

---

## Bug Report Template

```markdown
## Problem Description

{{bug_description}}

## Impact

{{impact_description}}

## Steps to Reproduce

{{steps_to_reproduce}}

## Expected Outcome

{{expected_outcome}}

## Actual Outcome

{{actual_outcome}}

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

## Impact

{{impact_description}}

## Use Case

{{use_case}}

## Possible Approaches (Optional)

{{possible_approaches}}

_Note: This section is optional. Focus on describing the problem above. If you have ideas for how to address it, you can share them here as suggestions for consideration._

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

## Challenge/Gap

{{challenge_description}}

## Desired Outcome

{{desired_outcome}}

## Workflow Impact

{{workflow_impact}}

## Example Scenario

**Scenario:** {{example_scenario}}
**What happens:** {{what_happens}}
**What should happen:** {{what_should_happen}}

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

## Context

What I was trying to accomplish: {{user_goal}}

## What Would Help

{{what_would_help}}

_Note: Rather than prescribing a specific fix, this describes the information or clarity that would address the knowledge gap._

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
