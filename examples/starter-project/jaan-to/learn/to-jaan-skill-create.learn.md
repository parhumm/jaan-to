# Lessons: to-jaan-skill-create

> Last updated: 2026-02-03

Accumulated lessons from past executions. Read this before creating skills to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions to ask during skill creation:

(none yet)

## Edge Cases

Special cases to check and handle:

(none yet)

## Workflow

Process improvements learned from past runs:

### Output Structure Standards (2026-02-03)

**Context**: All output-generating skills must follow standardized ID-based folder output structure.

**What to do**:
- Always include Step 5.5 (ID generation) in generated SKILL.md
- Always include index update after output write
- Always add Executive Summary to template.md
- Reference `scripts/lib/id-generator.sh` and `scripts/lib/index-updater.sh`

**Template to include**:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-{report-type}-${slug}.md"
```

**What NOT to do**:
- Don't generate skills with direct file writes (no folder)
- Don't skip index management
- Don't forget Executive Summary section

**Reference**: See `skills/jaan-to-pm-prd-write/SKILL.md` for compliant example.

## Common Mistakes

Things to avoid based on past feedback:

(none yet)
