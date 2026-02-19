# jaan-issue-report — Reference Material

> Extracted from `skills/jaan-issue-report/SKILL.md` for token optimization.
> Contains tone guidance, variable mappings, privacy rules, result scenario templates, keyword/label tables, title format, output path spec, local file template, and definition of done.

---

## Tone and Framing Guidance

This skill follows jaan-to's **problem-focused, suggestive tone principles**:

### When Gathering Information:
- Ask **"what problem"** before **"what solution"**
- Use open questions that invite thinking: "What outcome would help?" not "What feature should we build?"
- If users provide solution-focused answers, **gently redirect**: "That's a helpful idea. First, help me understand what problem this would solve?"
- **Smart auto-conversion**: When users describe solutions ("Add --dry-run"), extract the underlying problem ("Need confidence about changes before committing")

### When Drafting Issues:
- **Focus on describing what's broken/missing/confusing** (the problem)
- **Solutions are optional suggestions**, not requirements
- Frame solutions as "possible approaches" or "ideas to consider" rather than "proposed solution" or "fix"

### When Reviewing with Users:
- Non-blaming language: "experienced an issue" not "hit a bug"
- Transparent about uncertainty: "I've inferred this from context" vs claiming certainty
- Focus on clarity: "Does this capture the problem you're facing?" not "Is this solution correct?"

**Why this matters:** Problem-focused issues give maintainers flexibility to find the best solution while ensuring the actual user need is well-understood.

---

## Variable Mapping (Tone-Aware)

### For `bug` type:
- `{{bug_description}}`: Synthesize from Q2 (what trying to accomplish), Q3 (expected outcome), Q4 (actual outcome). Focus on what's broken.
- `{{impact_description}}`: Extract from Q2 (goal blocked) and Q4 (what went wrong). Describe workflow impact clearly.
- `{{expected_outcome}}`: From Q3. What the user expected to achieve.
- `{{actual_outcome}}`: From Q4. What actually happened instead.
- `{{steps_to_reproduce}}`: From Q6. Step-by-step instructions.
- `{{additional_context}}`: From final "anything else?" question and any extra details.

### For `feature` type:
- `{{problem_description}}`: Extract from Q1 (problem experiencing), Q3 (situation where it occurs). Focus on current limitation.
- `{{impact_description}}`: Extract from Q4. How this problem affects workflow/results.
- `{{use_case}}`: From Q3. Concrete situation where problem occurs.
- `{{possible_approaches}}`: If user proposed solutions, include as suggestions with "User suggested: [idea]". Otherwise: "Not specified — open to maintainer's approach."
- `{{related_features}}`: From Q5. Related skills/features they've tried.

### For `skill` type:
- `{{skill_name}}` and `{{skill_command}}`: From Q1.
- `{{issue_description}}`: Overview synthesized from all answers.
- `{{current_behavior}}`: From Q3. What currently happens or what's missing.
- `{{challenge_description}}`: From Q2. The limitation or challenge faced.
- `{{desired_outcome}}`: From Q4. What outcome would address the challenge.
- `{{workflow_impact}}`: From Q5. How this impacts productivity/workflow.
- `{{example_scenario}}`: From Q6. Concrete scenario showing the problem.
- `{{what_happens}}`: Extract from Q6 - current state in the scenario.
- `{{what_should_happen}}`: Extract from Q6 - desired state in the scenario.

### For `docs` type:
- `{{doc_location}}`: From Q1. Page or section reference.
- `{{issue_description}}`: From Q2. What's incorrect/missing/confusing.
- `{{user_goal}}`: From Q3. What user was trying to accomplish when they encountered this.
- `{{what_would_help}}`: Synthesize from Q3 (user's goal) and Q4 (desired information/clarity). Focus on the knowledge gap.

### Smart Auto-Conversion
When user provides solution-focused answers:
1. Extract the underlying problem (e.g., "Add --dry-run" → "Need confidence about changes before committing")
2. Use problem for main description
3. Include user's solution idea in optional "Possible Approaches" section with: "User suggested: [their idea]"
4. Maintain problem-focused framing in body while honoring their contribution

**Tone Reminder:** When synthesizing user input into template variables, maintain problem-focused language. Focus on what's broken/missing/confusing and its impact, not on prescribing solutions.

---

## Privacy Sanitization Rules

**MANDATORY before HARD STOP preview.** Scan the generated issue body for private information:

### Path Sanitization
Scan for patterns: `/Users/`, `/home/`, `/var/`, absolute project paths.
- `/Users/{anything}/` → `{USER_HOME}/`
- Full project paths → `{USER_HOME}/{PROJECT_PATH}/...` (keep only relative portion)
- Keep relative plugin paths as-is (e.g., `skills/pm-prd-write/SKILL.md`)

### Credential Sanitization
Scan for patterns: `token=`, `key=`, `password=`, `secret=`, `Bearer `, `ghp_`, `sk-`, `api_key`.
Replace any detected values with `[REDACTED]`.

### Connection String Sanitization
Scan for database and service connection strings:
- `postgresql://`, `postgres://` → `[DB_CONNECTION_REDACTED]`
- `mysql://`, `mariadb://` → `[DB_CONNECTION_REDACTED]`
- `mongodb://`, `mongodb+srv://` → `[DB_CONNECTION_REDACTED]`
- `redis://`, `rediss://` → `[DB_CONNECTION_REDACTED]`
- `amqp://`, `amqps://` → `[MQ_CONNECTION_REDACTED]`
- `jdbc:` prefixed URLs → `[DB_CONNECTION_REDACTED]`
- Generic URL auth pattern `://user:pass@` → `://[AUTH_REDACTED]@`

### Personal Info Check
Scan for patterns that look like emails, IP addresses, or usernames embedded in paths.
Replace with generic placeholders unless the user explicitly included them.

### Safe to Keep
Do NOT sanitize (helps maintainers debug):
- jaan-to version number (e.g., `5.0.0`)
- Skill names and commands (e.g., `/jaan-to:pm-prd-write`)
- Hook names (e.g., `session-start`, `post-tool-use`)
- OS type (e.g., `Darwin`, `Linux`)
- Error message text (after stripping paths and tokens)
- Plugin config keys (not secret values)

### Count and Flag
Track the number of sanitized items. This count will be shown at HARD STOP.

---

## Result Scenario Templates (Step 11)

### Scenario A: GitHub Submission Succeeded (No Local File)
**When**: Step 9 succeeded, Step 10 was skipped.
> Issue successfully reported to GitHub:
> - URL: {clickable GitHub issue URL}
> - Issue #: {issue_number}
> - Label: {label}

### Scenario B: Local-Only Mode + Local File Saved
**When**: Step 1 set local-only mode, Step 10.3 created file.
> Issue saved locally:
> - Path: `{full path to .md file}`
> To submit manually, copy the content below the second `---` line and create a new issue at: https://github.com/parhumm/jaan-to/issues/new

### Scenario C: Local-Only Mode + No Local File
**When**: Step 1 set local-only mode, Step 10.2 user chose "No, skip".
> No file was created. You can use the copy-paste version shown above to submit manually at: https://github.com/parhumm/jaan-to/issues/new

### Scenario D: GitHub Failed + Local File Saved
**When**: Step 9 failed, Step 10.3 created file.
> GitHub submission failed: {error}
> Issue saved locally:
> - Path: `{full path to .md file}`
> To submit manually, copy the content below the second `---` line and create a new issue at: https://github.com/parhumm/jaan-to/issues/new

### Scenario E: GitHub Failed + No Local File
**When**: Step 9 failed, Step 10.2 user chose "No, skip".
> GitHub submission failed: {error}
> No file was created. You can use the copy-paste version shown above to submit manually at: https://github.com/parhumm/jaan-to/issues/new

---

## Keyword Detection Table (Step 2)

Use these keyword patterns to auto-detect issue type from the user's description:

| Keywords | Type |
|----------|------|
| broken, error, crash, fails, wrong, bug, doesn't work | `bug` |
| add, new, would be nice, request, missing feature, wish | `feature` |
| skill, `/jaan-to:`, command, workflow, generate | `skill` |
| docs, documentation, readme, guide, typo, unclear | `docs` |

### Type-to-Label Mapping

| Type | Label |
|------|-------|
| `bug` | `bug` |
| `feature` | `enhancement` |
| `skill` | `skill-request` |
| `docs` | `documentation` |

---

## Issue Title Format (Step 5)

Craft a clear, descriptive title. **Always in English.**

**Rules:**
- Under 80 characters
- Start with type prefix in brackets: `[Bug]`, `[Feature]`, `[Skill]`, `[Docs]`
- Be specific about what is affected
- If session draft was accepted, refine its title rather than starting fresh

**Pattern**: `[{Type}] {concise description of the issue}`

**Examples:**
- `[Bug] learn-add crashes when target skill has no LEARN.md`
- `[Feature] Support --dry-run flag for all generation skills`
- `[Skill] Need a skill for competitive analysis reports`
- `[Docs] Missing migration guide for v3.0.0 template variables`

---

## Output Path Generation (Step 8)

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"

SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/jaan-issues"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
SLUG={kebab-case from title, max 50 chars, strip type prefix bracket}
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${SLUG}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${SLUG}.md"
```

Store variables for potential local save:
- `NEXT_ID`: {NEXT_ID}
- `SLUG`: {kebab-case from title}
- `OUTPUT_FOLDER`: `$JAAN_OUTPUTS_DIR/jaan-issues/{NEXT_ID}-{SLUG}/`
- `MAIN_FILE`: `{NEXT_ID}-{SLUG}.md`

(These will be used only if local file creation is requested in Step 10.)

---

## Copy-Paste Ready Template (Step 10.1)

Present the issue content in the user's conversation language:

```
──────────────────────────────────────────
COPY-PASTE READY ISSUE
──────────────────────────────────────────

Title: {title}

{full issue body without YAML frontmatter}

──────────────────────────────────────────
```

**Contextual message:**

If GitHub submission failed (came from Step 9.5):
> "GitHub submission failed: {error}. You can copy the content above and submit manually at: https://github.com/parhumm/jaan-to/issues/new"

If local-only mode (never attempted GitHub):
> "You can copy the content above and submit manually at: https://github.com/parhumm/jaan-to/issues/new"

---

## Local Issue File Template (Step 10.3.2)

Write to `$MAIN_FILE` (the path generated in Step 8):

```markdown
---
title: "{issue_title}"
type: "{bug|feature|skill|docs}"
label: "{github_label}"
repo: "parhumm/jaan-to"
issue_url: ""
issue_number: null
date: "{YYYY-MM-DD}"
jaan_to_version: "{version}"
os: "{uname output}"
related_skill: "{skill_name or N/A}"
generated_by: "jaan-issue-report"
session_context: {true|false}
---

{full issue body}
```

**Note**: `issue_url` and `issue_number` remain empty for local-only issues.

---

## Definition of Done

- [ ] Session context scanned (if mid-session invocation)
- [ ] Issue type classified (bug/feature/skill/docs)
- [ ] All relevant details gathered via clarifying questions
- [ ] Environment info auto-collected (version, OS)
- [ ] Issue title is clear, English, under 80 chars
- [ ] Issue body follows template structure for the given type
- [ ] Issue body is in English regardless of conversation language
- [ ] Privacy sanitization completed (paths, tokens, personal info)
- [ ] HARD STOP approved by user (full preview shown)
- [ ] If submit mode active: GitHub issue creation attempted in Step 9
- [ ] If GitHub submission succeeded: Issue URL and number captured, Step 10 skipped
- [ ] If GitHub submission failed OR local-only mode: Copy-paste ready version shown in Step 10
- [ ] If copy-paste version shown: User asked whether to save local file
- [ ] If local file requested: File saved to `$JAAN_OUTPUTS_DIR/jaan-issues/{id}-{slug}/` and index updated
- [ ] User informed of result via appropriate scenario in Step 11
