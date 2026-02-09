# Lessons: skill-create

> Last updated: 2026-02-09

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

**Reference**: See `skills/pm-prd-write/SKILL.md` for compliant example.

## Common Mistakes

Things to avoid based on past feedback:

### No colons in YAML description fields (2026-02-09)

**Context**: `backend-scaffold` was the only skill with `: ` (colon-space) in its description — `"from specs: routes, data model..."`. Claude Code's YAML parser misinterpreted `specs: routes` as a key-value pair, corrupting the skill metadata.

**Symptom**: Skill displayed as `/jaan-to:backend-scaffold` instead of `/backend-scaffold` in the command picker.

**What NOT to do**:
- Don't use `: ` (colon-space) in the `description` frontmatter field
- Don't use any YAML special characters (`:`, `#`, `[`, `]`, `{`, `}`) in unquoted descriptions

**What to do**:
- Rephrase to avoid colons: "from specs: routes" → "with routes"
- Run `scripts/validate-skills.sh` which now checks for colons
- If a colon is truly needed, quote the description: `description: "text with: colon"`

**Reference**: Fix commit `c1c5f0d`, docs rule added to `docs/STYLE.md` and `docs/extending/create-skill.md`.
