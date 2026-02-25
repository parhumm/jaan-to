# Pre-Execution Protocol

**MANDATORY FIRST ACTION** — Before any other step, check project initialization, load lessons, and resolve the template for this skill.

> **Execution requirement**: Skills MUST execute Steps 0 → A → B → C in order.
> Do not skip any step. Each step has its own skip conditions documented below.

## Step 0: Initialization Guard

**Skip this step** if the current skill is `jaan-init`.

Check if the `jaan-to/` directory exists in the project root.

**If `jaan-to/` exists** → proceed to Step A.

**If `jaan-to/` does NOT exist** → the project has not been initialized. Ask the user:

> "This project hasn't been initialized with jaan-to yet. Context files and configuration won't be available, which may reduce output quality. Run `/jaan-init` to set up the project first?"
>
> Options: [1] Yes, run /jaan-init first (Recommended) — [2] No, continue without initialization

- **Option 1**: Run `/jaan-init` and follow its full workflow. After initialization completes, return here and continue from Step A.
- **Option 2**: Continue to Step A. Skills will operate with plugin defaults only (no project-specific context).

## Step A: Load Lessons

Read the project-specific learn file first (three-tier resolution):
1. `$JAAN_LEARN_DIR/jaan-to-{SKILL_NAME}.learn.md` (canonical)
2. `$JAAN_LEARN_DIR/{SKILL_NAME}.learn.md` (legacy — colon prefix)
3. `$JAAN_LEARN_DIR/{SKILL_NAME}.learn.md` (unprefixed)

If no project file exists at any tier, read the plugin seed:
`${CLAUDE_PLUGIN_ROOT}/skills/{SKILL_NAME}/LEARN.md`

If the file exists (from any source), apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 1
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If no learn file exists anywhere, continue without it.

## Step B: Resolve Template

When this skill's instructions reference a template path like
`$JAAN_TEMPLATES_DIR/jaan-to-{SKILL_NAME}.template.md`, resolve it as follows:

1. Try: `$JAAN_TEMPLATES_DIR/jaan-to-{SKILL_NAME}.template.md` (project, canonical dash prefix)
2. Try: `$JAAN_TEMPLATES_DIR/{SKILL_NAME}.template.md` (project, legacy colon prefix)
3. Try: `$JAAN_TEMPLATES_DIR/{SKILL_NAME}.template.md` (project, without prefix)
4. Fallback: `${CLAUDE_PLUGIN_ROOT}/skills/{SKILL_NAME}/template.md` (plugin source)

Use the first file found. If none exist, proceed without a template.

## Step C: Offer Template Seeding

If Step B resolved the template from the **plugin source** (step 4 — the `${CLAUDE_PLUGIN_ROOT}/skills/{SKILL_NAME}/template.md` path), offer to seed it into the project for future customization:

> "This skill used the default plugin template. Copy it to `$JAAN_TEMPLATES_DIR/jaan-to-{SKILL_NAME}.template.md` so you can customize it for future runs? [y/n]"

**If yes:**
1. Run: `${CLAUDE_PLUGIN_ROOT}/scripts/seed-template.sh {SKILL_NAME}`
2. Confirm the seeded path from the script output.
3. Continue skill execution using the **newly seeded project copy** as the resolved template.

**If no:**
- Continue skill execution using the plugin source template. No file is created.

**Skip this step** if the template was found at step 1, 2, or 3 (project copy already exists), or if no template exists anywhere.
