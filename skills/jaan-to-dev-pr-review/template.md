# Automated Review: {{title}}

> Generated: {{date}}
> Skill: dev:pr-review

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Risk Level** | {{risk_emoji}} {{risk_level}} |
| **Files Changed** | {{files_count}} |
| **Lines** | +{{additions}} / -{{deletions}} |
| **Skipped Files** | {{skipped_count}} |
| **Blocking Issues** | {{blocking_count}} |
| **Suggestions** | {{suggestion_count}} |

{{blocking_warning}}

---

## Blocking Issues ({{blocking_count}})

{{blocking_issues}}

---

## Risky Files Analysis

| File | Risk Score | Top Concern |
|------|-----------|-------------|
{{risky_files_table}}

{{risky_files_details}}

---

## Security Hints

{{security_findings}}

---

## Performance Hints

{{performance_hints}}

---

## Missing Test Coverage

| Source File | Expected Test | Status |
|-------------|--------------|--------|
{{missing_tests_table}}

{{missing_tests_notes}}

---

## CI Status

{{ci_status}}

---

## Suggestions ({{suggestion_count}})

{{suggestions}}

---

## Skipped Files

{{skipped_files}}

---

**Skill**: dev:pr-review
**Source**: {{source_ref}}
**Review Depth**: {{review_depth}}
**Author**: {{author}}
