# skill-create Reference Material

> Extracted reference content for `skills/skill-create/SKILL.md`.
> This file contains detailed checklists and procedural lookups that support the skill creation workflow.

---

## Specification Validation Checklist

Used in **Step 10: Validate Against Specification** — check against `docs/extending/create-skill.md`:

### Frontmatter

- [ ] Has `name` matching directory
- [ ] Has `description` with purpose (max 120 chars, no colons)
- [ ] Has `allowed-tools` with valid patterns
- [ ] Has `argument-hint`
- [ ] Does NOT have `model:` field (causes API errors)
- [ ] If narrow-domain or internal: consider `disable-model-invocation: true`
- [ ] If heavy analysis (>30K tokens expected): consider `context: fork`

### Body

- [ ] Has H1 title matching skill name
- [ ] Has tagline blockquote
- [ ] Has `## Context Files`
- [ ] Has `## Input`
- [ ] Has `# PHASE 1: Analysis`
- [ ] Has `## Step 0: Apply Past Lessons`
- [ ] Has `# HARD STOP`
- [ ] Has `# PHASE 2: Generation`
- [ ] Has `## Definition of Done`

### Size

- [ ] SKILL.md under 500 lines (standard) or 600 lines (complex, hard cap)
- [ ] If over 500 lines: extract reference material to `docs/extending/{name}-reference.md` per `docs/extending/extraction-safety-checklist.md`

### Trust

- [ ] Tool permissions are sandboxed (not `Write(*)`)
- [ ] Has human approval checks

### Budget

- [ ] Run `scripts/validate-skills.sh` — description budget still under 15K chars

If any check fails, fix before preview.

---

## Team Roles Registry Update Procedure

Used in **Step 14.5: Update Team Roles Registry**.

Applies when skill name matches a role prefix (pm-, ux-, backend-, frontend-, qa-, devops-, sec-, data-, growth-, delivery-, sre-, support-, release-, detect-):

1. Read `${CLAUDE_PLUGIN_ROOT}/skills/team-ship/roles.md`
2. Find the role section (`## {role_prefix}`) matching the skill's prefix
3. If role section exists:
   - Add skill name to the **Skills** list (maintain workflow chain order)
   - If skill produces cross-role outputs (e.g., api-contract -> frontend), add to **Messages**
4. If role section does NOT exist (new role):
   - Create new section with: Title, Track (full), Model (sonnet), Skills ([new-skill]), Phase, Depends on, Outputs, Messages, Shutdown after
   - Ask user: "Which phase? [1-define / 2-build / 3-ship]" and "What inputs needed?"
5. Preview roles.md change -> confirm with user before writing

If `roles.md` does not exist (team-ship not yet created), skip silently.
