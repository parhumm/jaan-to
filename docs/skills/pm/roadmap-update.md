---
title: "pm-roadmap-update"
sidebar_position: 6
---

# /pm-roadmap-update

> Review and maintain a project roadmap with codebase-aware analysis.

---

## What It Does

Keeps your roadmap accurate and current through four maintenance modes:
- **Review**: Cross-reference roadmap against PRDs, stories, and codebase
- **Mark**: Mark specific items as complete with evidence
- **Reprioritize**: Re-evaluate priorities based on current context
- **Validate**: Check consistency, completeness, and dependencies

---

## Usage

```
/pm-roadmap-update                    # Default: review mode
/pm-roadmap-update review             # Full cross-reference review
/pm-roadmap-update mark "auth" done   # Mark item as complete
/pm-roadmap-update reprioritize       # Re-evaluate all priorities
/pm-roadmap-update validate           # Quality/consistency check
```

---

## Modes

### Review (default)

Scans PRDs, stories, and codebase to find:
- **Completion candidates**: Items with evidence of completion
- **Stale items**: No progress activity detected
- **Past-due items**: Target timeframe has passed
- **Blocked items**: Dependencies not yet resolved
- **Missing items**: PRDs/stories without roadmap entries

### Mark

Marks a specific roadmap item as done:
- Fuzzy-matches item text against roadmap
- Asks for completion evidence
- Moves item to "Completed" section

### Reprioritize

Re-evaluates all non-completed items against current context:
- Checks for changed dependencies
- Cross-references new PRDs and stories
- Suggests priority adjustments with reasons

### Validate

Checks roadmap quality:
- **Completeness**: All items have required fields
- **Consistency**: Terminology, formats, and scales are uniform
- **Dependencies**: No circular deps, all refs valid
- **Staleness**: No items unchanged for >90 days

---

## Output

Updates the existing roadmap file in-place. Reports are shown inline during the HARD STOP review.

---

## Example

**Input**:
```
/pm-roadmap-update review
```

**Review findings**:
```
FINDINGS (4 total)

Completion Candidates:
  "User authentication" — PRD exists, all stories done

Stale Items:
  "Dark mode support" — status: To Do, no activity

Past-Due Items:
  "API rate limiting" — target: Q4 2025, still To Do

Missing from Roadmap:
  "Payment integration" — PRD exists, no roadmap entry
```

---

## Tips

- Run `review` regularly (weekly or at sprint boundaries)
- Use `validate` before sharing the roadmap with stakeholders
- `reprioritize` works best when project context has changed significantly
- Provide evidence when marking items done for better audit trail

---

## Learning

This skill reads from:
```
jaan-to/learn/jaan-to-pm-roadmap-update.learn.md
```

Add feedback:
```
/learn-add pm-roadmap-update "Check external trackers too"
```
