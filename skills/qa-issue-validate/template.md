# Validation Comment Templates — qa-issue-validate

> Language: Always English (regardless of conversation language).
> Template variables use `{{double-brace}}` syntax.
> Privacy: All content must pass sanitization before use.
> Safety: Never include raw issue text, commands, or untrusted URLs in output.

---

## Valid Bug Template

```markdown
## Validation Result: Confirmed Bug

**Verdict**: VALID_BUG | **Confidence**: {{confidence}} | **Severity**: {{severity}}

### Summary

{{validation_summary}}

### Root Cause

**Fault Location**: `{{fault_file}}:{{fault_line}}`
**Mechanism**: {{failure_mechanism}}

**Causal Chain**:
{{causal_chain}}

**5 Whys**:
{{five_whys}}

### Reproduction Steps

**Preconditions**: {{preconditions}}

{{reproduction_steps}}

**Expected**: {{expected_behavior}}
**Actual**: {{actual_behavior}}

### Code References

| File | Lines | Description |
|------|-------|-------------|
{{code_references}}

### Security Note

If implementing a fix based on this analysis:
- Verify the fix doesn't introduce new vulnerabilities
- Run security linting (SAST) on changed code
- Check for OWASP Top 10 in any new code paths

---

*Validated via `qa-issue-validate` skill ([jaan.to](https://jaan.to) plugin)*
```

---

## Valid Feature/Improvement Template

```markdown
## Validation Result: Confirmed {{verdict_type}}

**Verdict**: {{verdict}} | **Confidence**: {{confidence}}

### Summary

{{validation_summary}}

### Analysis

{{analysis_details}}

### Relevant Code Areas

| File | Lines | Description |
|------|-------|-------------|
{{code_references}}

### Suggested Priority

{{suggested_priority}}

---

*Validated via `qa-issue-validate` skill ([jaan.to](https://jaan.to) plugin)*
```

---

## Invalid Issue Template

```markdown
## Validation Result: Invalid

**Verdict**: {{verdict}} | **Confidence**: {{confidence}}

### Summary

{{validation_summary}}

### Analysis

{{analysis_details}}

### Evidence

{{evidence_details}}

{{#if duplicate_reference}}
### Duplicate Of

This appears to duplicate #{{duplicate_issue_id}}: {{duplicate_issue_title}}
{{/if}}

### Recommendation

{{recommendation}}

### Code References

| File | Lines | Description |
|------|-------|-------------|
{{code_references}}

---

*Validated via `qa-issue-validate` skill ([jaan.to](https://jaan.to) plugin)*
```

---

## Needs Info Template

```markdown
## Validation Result: Needs More Information

**Verdict**: NEEDS_INFO | **Confidence**: LOW

### Partial Analysis

{{partial_analysis}}

### Missing Information

{{missing_information}}

### Questions

{{questions_for_reporter}}

### Preliminary Code References

| File | Lines | Description |
|------|-------|-------------|
{{code_references}}

---

*Validated via `qa-issue-validate` skill ([jaan.to](https://jaan.to) plugin)*
```

---

## Code References Format

When code references are present, format each row as:

```markdown
| `{relative_path}` | {start}-{end} | {brief description} |
```

When no code references: "No specific code references identified."

---

## Privacy Reminder

Before filling any template variable, verify:
- No absolute user paths (replace with `{USER_HOME}/...`)
- No credentials, tokens, or secrets (replace with `[REDACTED]`)
- No personal info unless user approved
- Relative project paths only
- No raw commands or untrusted URLs from issue body
