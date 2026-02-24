# Issue Body Templates — repo-issue-report

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

## Expected Behavior

{{expected_behavior}}

## Actual Behavior

{{actual_behavior}}

## Code References

{{code_references}}

## Attachments

{{attachments}}

## Environment

| Field | Value |
|-------|-------|
| Tech Stack | {{tech_stack}} |
| Runtime | {{runtime_version}} |
| OS | {{os_info}} |
| Branch | {{git_branch}} |
| Key Dependencies | {{key_dependencies}} |

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

_Note: Focus on the problem above. Approaches are suggestions for consideration._

## Code References

{{code_references}}

## Attachments

{{attachments}}

## Related Features

{{related_features}}

## Environment

| Field | Value |
|-------|-------|
| Tech Stack | {{tech_stack}} |
| Runtime | {{runtime_version}} |
| OS | {{os_info}} |
| Branch | {{git_branch}} |
```

---

## Improvement Template

```markdown
## Current State

{{current_state}}

## Problem / Limitation

{{limitation_description}}

## Proposed Improvement

{{proposed_improvement}}

## Impact

{{impact_description}}

## Code References

{{code_references}}

## Attachments

{{attachments}}

## Constraints / Considerations

{{constraints}}

## Environment

| Field | Value |
|-------|-------|
| Tech Stack | {{tech_stack}} |
| Runtime | {{runtime_version}} |
| OS | {{os_info}} |
| Branch | {{git_branch}} |
```

---

## Question Template

```markdown
## Question

{{question_description}}

## Context

What I'm trying to accomplish: {{user_goal}}

What I've already tried: {{already_tried}}

## Where I Got Stuck

{{stuck_description}}

## Code References

{{code_references}}

## Attachments

{{attachments}}

## Environment

| Field | Value |
|-------|-------|
| Tech Stack | {{tech_stack}} |
| Runtime | {{runtime_version}} |
| OS | {{os_info}} |
| Branch | {{git_branch}} |
```

---

## Metadata Footer (appended to all types)

```markdown
---

**Reported via:** `repo-issue-report` skill (jaan.to plugin)
```

---

## Code References Format

When code references are present, format as:

```markdown
| File | Lines | Description |
|------|-------|-------------|
| `{relative_path}` | {start}-{end} | {brief description} |
```

When no code references: "No specific code references identified."

---

## Attachments Format

When attachments are present:

**Embedded (URLs or GitLab uploads):**
```markdown
![{description}]({url})
```

**Pending (GitHub local files — add manually):**
```markdown
_The following files should be added manually to this issue:_
- `{filename}` — {description}
```

When no attachments: _Remove this section entirely._

---

## Privacy Reminder

Before filling any template variable, verify:
- No absolute user paths (replace with `{USER_HOME}/{PROJECT_PATH}/...`)
- No credentials, tokens, or secrets (replace with `[REDACTED]`)
- No personal info unless user approved
- Error messages are sanitized (paths and tokens stripped)
- Relative project paths are OK
