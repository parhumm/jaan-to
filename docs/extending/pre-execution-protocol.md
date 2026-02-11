# Pre-Execution Protocol

**MANDATORY FIRST ACTION** — Before any other step, load lessons and resolve the template for this skill.

## Step A: Load Lessons

Read the project-specific learn file first:
`$JAAN_LEARN_DIR/jaan-to:{SKILL_NAME}.learn.md`

If NOT found, try without the namespace prefix:
`$JAAN_LEARN_DIR/{SKILL_NAME}.learn.md`

If neither project file exists, read the plugin seed:
`${CLAUDE_PLUGIN_ROOT}/skills/{SKILL_NAME}/LEARN.md`

If the file exists (from any source), apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If no learn file exists anywhere, continue without it.

## Step B: Resolve Template

When this skill's instructions reference a template path like
`$JAAN_TEMPLATES_DIR/jaan-to:{SKILL_NAME}.template.md`, resolve it as follows:

1. Try: `$JAAN_TEMPLATES_DIR/jaan-to:{SKILL_NAME}.template.md` (project, with namespace prefix)
2. Try: `$JAAN_TEMPLATES_DIR/{SKILL_NAME}.template.md` (project, without prefix)
3. Fallback: `${CLAUDE_PLUGIN_ROOT}/skills/{SKILL_NAME}/template.md` (plugin source)

Use the first file found. If none exist, proceed without a template.

Do NOT create or copy template files during skill execution.
