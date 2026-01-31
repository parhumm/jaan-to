---
name: jaan-skill-create
description: |
  Guide users through creating new jaan.to skills step-by-step.
  Auto-triggers on: create skill, new skill, skill wizard, add skill.
  Maps to: jaan-to:jaan-skill-create
allowed-tools: Read, Glob, Grep, Task, WebSearch, Write(skills/**), Write(docs/**), Write(.jaan-to/**), Edit(.jaan-to/**), Bash(git checkout:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [optional-skill-idea]
---

# jaan-to:jaan-skill-create

> Guide users through creating new jaan.to skills with web research and best practices.

## Context Files

Read these before execution:
- `.jaan-to/docs/create-skill.md` - Skill specification (REQUIRED)
- `.jaan-to/learn/skill-create.learn.md` - Past lessons
- `.jaan-to/templates/skill-create.template.md` - Generation templates
- `.jaan-to/context/config.md` - Current skill catalog

## Input

**Skill Idea**: $ARGUMENTS

If provided, use as starting context. Otherwise, begin with identity questions.

---

# PHASE 0: Duplicate Detection (Single Source of Truth)

Before any creation, check for existing skills:

1. **Glob** `skills/*/SKILL.md` to get all skills
2. **For each skill**, compare:
   - Role + domain match
   - Purpose description similarity
   - Calculate overlap score (0-100%)

3. **Decision tree**:
   - **Exact match exists**: "Skill '{name}' already does this. Use: `/{command}` [show example]"
   - **>70% overlap**: "'{name}' is similar ({n}% overlap). Update it instead? [update/new]"
     - If update: Invoke `/jaan-to:jaan-skill-update {name}`
     - If new: Continue with creation
   - **<70% overlap**: Continue with creation

4. **Fast-track option** for simple skills:
   > "This seems straightforward. Create minimal skill directly? [y/wizard]"

   Skip wizard for:
   - Single-purpose skills with obvious structure
   - Skills that wrap an existing command
   - Internal/utility skills with <50 lines expected

---

# PHASE 1: Analysis (Interactive + Research)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing user requirements
- Planning skill structure
- Validating against specification
- Research synthesis

## Questioning Guidelines

Ask up to 7 clarifying questions across Phase 1 if needed.

**Skip questions when**:
- Information already provided in user input
- Research answered the question
- Context files contain the answer
- Question is redundant with previous answer

**Make questions smart**:
- Reference user's input: "You said '{X}' — does that mean...?"
- Build on research: "Best practices suggest Y — does that fit your case?"
- Probe specifics: "What should happen when Z?"

## Step 0: Apply Past Lessons

Read `.jaan-to/learn/skill-create.learn.md` if it exists:
- Add questions from "Better Questions"
- Note edge cases from "Edge Cases"
- Follow improvements from "Workflow"
- Avoid items in "Common Mistakes"

## Step 1: Basic Identity

Ask these questions one at a time:

| Question | Purpose | Validation |
|----------|---------|------------|
| "What role does this skill serve?" | Determine role prefix | Must be: pm, dev, qa, ux, data, growth, or custom |
| "What domain/area does it work in?" | Determine domain | 1-2 words, lowercase, hyphens allowed |
| "What action does it perform?" | Determine action verb | write, create, add, review, generate, update, analyze, etc. |

**After answers**, validate and show:
> "Skill name will be: `jaan-to-{role}-{domain}-{action}`"
> "Command: `/jaan-to:{role}-{domain}-{action}`"
> "Logical name: `jaan-to-{role}-{domain}:{action}`"

## Step 2: Web Research (Token-Optimized)

Use **Task tool with Explore subagent** to isolate research tokens:

```
Task prompt: "Research best practices for {domain} {action}:
1. Search '{domain} best practices {year}'
2. Search '{domain} report template'
3. Search 'how to {action} {domain}'
4. Search '{domain} checklist'

Return:
- 3-5 key best practices
- Suggested questions the skill should ask
- Suggested quality checks
- Suggested output sections
- Sources used"
```

**Present research summary to user**:
> "Research findings for {domain}:
>
> **Best Practices Found:**
> 1. {practice1}
> 2. {practice2}
> ...
>
> **Suggested Questions for Skill:**
> - {question1}
> - {question2}
> ...
>
> **Suggested Quality Checks:**
> - [ ] {check1}
> - [ ] {check2}
> ...
>
> **Suggested Output Sections:**
> - {section1}
> - {section2}
> ..."

## Step 3: Purpose & Triggers

Show research-based suggestions, then ask:

1. "What does this skill do? (1-2 sentences)"
   - [Suggested from research]: "{suggested_description}"

2. "What phrases should auto-trigger this skill?"
   - [Suggested]: {action} {domain}, {domain} {action}, etc.

## Step 4: Input & Output

1. "What input does the skill need?"
   - Examples: file path, topic name, feature description
   - Will become `$ARGUMENTS` handling

2. "What files/outputs does it produce?"
   - [Suggested from templates]: {format} file with {sections}

3. "What format? (markdown/json/both)"
   - Determines template.md creation

## Step 5: Questions, Quality & Done

Present research-based suggestions, let user accept/modify/add:

1. "What questions should the skill ask users?"
   - [Pre-filled from research]:
     - {research_question1}
     - {research_question2}
   - "Add more or modify? [accept/edit]"

2. "What quality checks before writing?"
   - [Pre-filled from research]:
     - [ ] {research_check1}
     - [ ] {research_check2}
   - "Add more or modify? [accept/edit]"

3. "What defines 'done' for this skill?"
   - [Suggested]:
     - [ ] Output file written
     - [ ] Quality checks pass
     - [ ] User approved

---

# HARD STOP - Human Review Check

Present complete skill structure:

```
SKILL SUMMARY
─────────────
Name: jaan-to-{role}-{domain}-{action}
Command: /jaan-to:{role}-{domain}-{action}
Logical: jaan-to-{role}-{domain}:{action}
Description: {description}

RESEARCH USED
─────────────
Sources: {source_count} web sources consulted
Best practices incorporated: {practice_count}

FILES TO CREATE
───────────────
□ skills/{name}/SKILL.md
□ .jaan-to/learn/{name}.learn.md
□ .jaan-to/templates/{name}.template.md (if needed)

WILL ALSO
─────────
□ Register in .jaan-to/context/config.md
□ Create docs/skills/{role}/{name}.md (via /jaan-to:jaan-docs-create)
□ Commit to branch skill/{name}
```

> "Create this skill? [y/n/edit]"

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 6: Create Git Branch

```bash
git checkout -b skill/jaan-to-{role}-{domain}-{action}
```

Confirm: "Created branch `skill/{name}`. All work on this branch."

## Step 7: Generate SKILL.md

Use template from `.jaan-to/templates/skill-create.template.md`:

1. Fill YAML frontmatter:
   - name: {name}
   - description: from Step 3
   - allowed-tools: based on needs from Step 5
   - argument-hint: from Step 4
   - **DO NOT add `model:` field** (use inherited default)

2. Fill markdown body:
   - Context Files from gathered info
   - Input handling from Step 4
   - Phase 1 questions from Step 5
   - HARD STOP section
   - Phase 2 generation steps
   - Quality checks from Step 5
   - Definition of Done from Step 5

## Step 8: Generate LEARN.md

Create with research insights as initial lessons:

```markdown
# Lessons: {name}

> Last updated: {YYYY-MM-DD}

Accumulated lessons from past executions.

---

## Better Questions

Questions to ask during information gathering:

{If research found methodology insights, add as initial questions}

## Edge Cases

Special cases to check and handle:

{If research found edge cases, add here}

## Workflow

Process improvements:

{If research found process best practices, add here}

## Common Mistakes

Things to avoid:

{If research found common pitfalls, add here}
```

## Step 9: Generate template.md (if needed)

Based on output format from Step 4:
- Use researched report structure
- Include required metadata section
- Add placeholders for dynamic content

## Step 10: Validate Against Specification

Check against `.jaan-to/docs/create-skill.md`:

**Frontmatter**:
- [ ] Has `name` matching directory
- [ ] Has `description` with purpose and mapping
- [ ] Has `allowed-tools` with valid patterns
- [ ] Has `argument-hint`
- [ ] Does NOT have `model:` field (causes API errors)

**Body**:
- [ ] Has H1 title with logical name
- [ ] Has tagline blockquote
- [ ] Has `## Context Files`
- [ ] Has `## Input`
- [ ] Has `# PHASE 1: Analysis`
- [ ] Has `## Step 0: Apply Past Lessons`
- [ ] Has `# HARD STOP`
- [ ] Has `# PHASE 2: Generation`
- [ ] Has `## Definition of Done`

**Trust**:
- [ ] Tool permissions are sandboxed (not `Write(*)`)
- [ ] Has human approval checks

If any check fails, fix before preview.

## Step 11: Preview All Files

Show complete content of:
1. SKILL.md
2. LEARN.md
3. template.md (if created)

> "Write these files? [y/n]"

## Step 12: Write Files

If approved:
1. Create directory: `skills/{name}/`
2. Write SKILL.md to `skills/{name}/SKILL.md`
3. Write LEARN.md to `.jaan-to/learn/{name}.learn.md`
4. Write template.md to `.jaan-to/templates/{name}.template.md` (if needed)

Confirm: "Skill files written to `skills/{name}/` and `.jaan-to/`"

## Step 13: Update Config Catalog

Edit `.jaan-to/context/config.md` to add skill to Available Skills table:

```markdown
| jaan-to-{role}-{domain}:{action} | `/{name}` | {short_description} |
```

## Step 14: Auto-Invoke Documentation

Run `/jaan-to:jaan-docs-create` to create:
- `docs/skills/{role}/{name}.md`

This ensures documentation is always created with the skill.

## Step 15: Commit to Branch

```bash
git add skills/{name}/ .jaan-to/ docs/skills/{role}/{name}.md
git commit -m "feat(skill): Add {name} skill

- {description}
- Research-informed: {source_count} sources consulted
- Auto-generated with /jaan-to:jaan-skill-create

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

# PHASE 3: Testing & PR

## Step 16: User Testing

> "Please test the skill in a new session. Here's a copy-paste ready example:"
>
> ```
> /jaan-to:{name} "{example_input_based_on_skill_purpose}"
> ```
>
> For example, if the skill is `pm-prd-write`:
> ```
> /jaan-to:pm-prd-write "Add user authentication with OAuth support"
> ```
>
> "Did it work correctly? [y/n]"

If issues:
1. Help debug the problem
2. Make fixes
3. Commit fixes
4. Repeat testing

## Step 17: Create Pull Request

When user confirms working:
> "Create pull request to merge to main? [y/n]"

If yes:
```bash
git push -u origin skill/{name}
gh pr create --title "feat(skill): Add {name} skill" --body "$(cat <<'EOF'
## Summary

- **Skill**: `{name}`
- **Command**: `/jaan-to:{name}`
- **Purpose**: {description}

## Research Used

Consulted {source_count} sources for best practices:
{research_summary}

## Files Created

- `skills/{name}/SKILL.md`
- `.jaan-to/learn/{name}.learn.md`
- `.jaan-to/templates/{name}.template.md` (if applicable)
- `docs/skills/{role}/{name}.md`

## Testing

✅ User confirmed skill works correctly

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Show PR URL to user.

If no:
> "Branch `skill/{name}` is ready. Merge manually when ready."

---

## Step 18: Capture Feedback

> "Any feedback on the skill creation process? [y/n]"

If yes:
- Run `/jaan-to:jaan-learn-add jaan-skill-create "{feedback}"`

---

## Definition of Done

- [ ] Duplicate check completed
- [ ] Web research performed
- [ ] All skill files created (SKILL.md, LEARN.md, template.md)
- [ ] Passes specification validation
- [ ] Registered in context/config.md
- [ ] Documentation created via /jaan-to:jaan-docs-create
- [ ] User tested and confirmed working
- [ ] PR created (or branch ready for manual merge)
- [ ] User approved final result
