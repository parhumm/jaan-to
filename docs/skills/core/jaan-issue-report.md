---
title: "jaan-issue-report"
sidebar_position: 8
---

# /jaan-to:jaan-issue-report

> Report bugs, feature requests, or skill issues to the jaan-to GitHub repo.

---

## What It Does

Guides you through creating a structured issue report for the jaan-to plugin. Gathers details through clarifying questions, auto-collects environment info, sanitizes private data, and either submits directly to GitHub or saves locally for manual submission.

When invoked mid-session, the skill scans the conversation for errors, failed tool calls, and frustrations to auto-draft a suggested issue.

---

## Usage

```
/jaan-to:jaan-issue-report "<description>"
/jaan-to:jaan-issue-report "<description>" --type bug --submit
/jaan-to:jaan-issue-report
```

**Flags**:

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| `--type` | `bug`, `feature`, `skill`, `docs` | Auto-detect | Issue category |
| `--submit` | (no value) | Off | Submit directly to GitHub |

---

## What It Asks

| Question | When |
|----------|------|
| "Which skill were you using?" | Bug or skill issues |
| "What did you expect?" | Bug reports |
| "What actually happened?" | Bug reports |
| "Steps to reproduce?" | Bug reports |
| "What problem would this solve?" | Feature requests |
| "Is there anything else?" | Always |

When a session draft is available, only deepening questions are asked.

---

## Output

**Local mode** (default):
```
$JAAN_OUTPUTS_DIR/jaan-issues/{id}-{slug}/{id}-{slug}.md
```

**Submit mode** (`--submit`):
- Creates a GitHub issue at `parhumm/jaan-to`
- Also saves a local copy with the issue URL

---

## Examples

**Report a bug from the current session**:
```
/jaan-to:jaan-issue-report
```
The skill scans the conversation and suggests: "It looks like pm-prd-write skipped the Success Metrics section. Report this?"

**Report a feature request**:
```
/jaan-to:jaan-issue-report "Support --dry-run for all generation skills" --type feature
```

**Report and submit directly**:
```
/jaan-to:jaan-issue-report "learn-add crashes when LEARN.md is missing" --type bug --submit
```

---

## Privacy

The skill sanitizes all issue content before preview:
- Private paths (`/Users/name/...`) replaced with `{USER_HOME}/...`
- Tokens and secrets replaced with `[REDACTED]`
- Personal info (email, IP) removed

Safe to include: jaan-to version, skill names, hook names, OS type, sanitized error messages.

---

## Tips

- Invoke mid-session right after hitting a problem for the best auto-draft
- Use `--submit` only if you have `gh` CLI installed and authenticated
- The HARD STOP preview lets you review and edit before anything is saved or submitted
- All issue content is written in English regardless of your conversation language
