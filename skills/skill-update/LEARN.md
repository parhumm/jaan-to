# Lessons: skill-update

> Last updated: 2026-02-03

Accumulated lessons from past executions. Read this before updating skills to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during skill updates:

(none yet)

## Edge Cases

Special cases to check and handle:

(none yet)

## Workflow

Process improvements learned from past runs:

### Output Structure Compliance Check (2026-02-03)

**Context**: Legacy skills may use old output patterns. Always check V3.8 compliance and suggest migration when needed.

**What to check**:
1. Does skill source `scripts/lib/id-generator.sh`?
2. Does skill create folder `{id}-{slug}/`?
3. Does skill update index with `add_to_index()`?
4. Does template include Executive Summary?

**Migration suggestion format**:
```
❌ Output structure outdated
   Required changes:
   1. Add Step 5.5: ID generation
   2. Update output step: folder + index
   3. Update template: Executive Summary

   Reference: skills/jaan-to:pm-prd-write/SKILL.md
```

**What NOT to do**:
- Don't skip V3.8 output structure validation
- Don't update skill without suggesting output migration if needed
- Don't apply migration without user approval (HARD STOP required)

**Reference**: See Step 2.1 (V3.8 checks) and Step 10.5 (migration handler) in this skill.

## Common Mistakes

Things to avoid based on past feedback:

(none yet)
