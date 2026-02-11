---
name: jaan-issue-report
description: Report bugs, feature requests, or skill issues to the jaan-to GitHub repo or save locally
allowed-tools: Read, Glob, Grep, Bash(gh auth status *), Bash(gh issue create *), Bash(gh label create *), Bash(uname *), Bash(awk *), Bash(rm -f /tmp/jaan-issue-body-*), Write($JAAN_OUTPUTS_DIR/jaan-issues/**), Edit($JAAN_LEARN_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: "<issue-description> [--type bug|feature|skill|docs] [--submit | --no-submit]"
disable-model-invocation: true
---

# jaan-issue-report

> Report issues to the jaan-to GitHub repo or save locally for manual submission.

## Context Files

Read these before execution:
- `${CLAUDE_PLUGIN_ROOT}/skills/jaan-issue-report/LEARN.md` - Plugin-side seed lessons
- `$JAAN_LEARN_DIR/jaan-to:jaan-issue-report.learn.md` - Project-side learned lessons
- `${CLAUDE_PLUGIN_ROOT}/skills/jaan-issue-report/template.md` - Issue body templates per type
- `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` - Plugin version
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution

## Input

**Arguments**: $ARGUMENTS

Parse from arguments:
1. **Issue description** — Free text describing the issue
2. **--type** — Issue type: `bug`, `feature`, `skill`, `docs`. Default: auto-detect from description or session context.
3. **--submit** — Force submit to GitHub (overrides saved preference)
4. **--no-submit** — Force local-only mode (overrides saved preference)

If neither `--submit` nor `--no-submit` is provided, submit mode is resolved in Step 1 via saved preference or smart detection.

If no arguments provided, proceed to session context scan (Step 0) or ask: "What issue would you like to report?"

---

# PHASE 1: Analysis (Read-Only)

## Pre-Execution: Apply Past Lessons

Read and apply: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `jaan-issue-report`

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to:jaan-issue-report.learn.md`

If the file exists, apply its lessons throughout this execution:
- Add questions from "Better Questions" to Step 3
- Note edge cases to check from "Edge Cases"
- Follow workflow improvements from "Workflow"
- Avoid mistakes listed in "Common Mistakes"

If the file does not exist, continue without it.

Also read the plugin-side seed lessons:
`${CLAUDE_PLUGIN_ROOT}/skills/jaan-issue-report/LEARN.md`

### Language Settings

Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_jaan-issue-report`

**CRITICAL LANGUAGE RULE:**
- **Conversation** (questions, confirmations, status messages, HARD STOP prompts): Use the resolved language preference
- **Issue output** (title + body): **ALWAYS in English** regardless of conversation language. GitHub issues target English-speaking maintainers.

**Keep in English always**: technical terms, file paths, variable names, skill names, code snippets, error messages.

---

## Step 0: Session Context Scan (Smart Pre-Draft)

**This step runs ONLY when the skill is invoked mid-session** (not as the first command). If no useful session context is found, skip to Step 1.

Scan the current conversation history silently:

### 0.1 Detect Active Skills

Look for `/jaan-to:*` invocations in the conversation. Identify which skill(s) were used this session and what they produced.

### 0.2 Detect Errors and Frustrations

Search for patterns:
- Error messages, failed tool calls, unexpected output
- User expressions: "doesn't work", "wrong output", "expected X got Y", "broken", "bug", "missing"
- Repeated retries of the same action
- Skill output that didn't match expectations

### 0.3 Extract Key Signals

From the conversation, extract:
- **Skill name + command** used when the issue occurred
- **What the user was trying to accomplish**
- **What went wrong** (error, wrong output, missing feature, unexpected behavior)
- **Any workarounds** the user tried

### 0.4 Generate Suggested Draft

If signals were found:
- Auto-classify type: `bug` if errors found, `feature` if user expressed a wish, `skill` if skill-specific
- Draft a title (English, under 80 chars, `[Type] description`)
- Draft a 2-3 sentence description based on session signals
- Pre-fill template fields where possible (related skill, steps to reproduce)

**Present to user** (in their conversation language):

> "Based on this session, it looks like you hit an issue with `/jaan-to:{skill-name}`:
>
> **Suggested issue:** {draft title}
> {draft description — 2-3 sentences}
>
> Is this what you'd like to report? [yes / no, it's something else / close but let me adjust]"

- **yes**: Continue to Step 1 with draft pre-filled. Step 3 will ask only deepening questions.
- **no**: Discard draft, proceed to Step 1 with standard flow.
- **adjust**: User modifies the draft, then continue to Step 1 with the adjusted version.

---

## Step 1: Resolve Submit Mode

Determine submit mode using this priority order:

### 1.1 Check for explicit flags (highest priority)

- If `--submit` flag is present: set submit mode = **submit**. Proceed to 1.4.
- If `--no-submit` flag is present: set submit mode = **local-only**. Skip to Step 2.

### 1.2 Check saved preference

Read `jaan-to/config/settings.yaml` and look for the `issue_report_submit` key.

- If `issue_report_submit: true`: set submit mode = **submit**. Proceed to 1.4.
- If `issue_report_submit: false`: set submit mode = **local-only**. Skip to Step 2.
- If key is missing or `"ask"`: proceed to 1.3.

### 1.3 Smart detection (first-time flow)

1. Run `gh auth status` silently.
2. If `gh` is **not available or not authenticated**:
   > "GitHub CLI is not installed or not authenticated. Issues will be saved locally. You can submit them manually later."
   Set submit mode = **local-only**. Skip to Step 2. Do NOT save this as a preference (user may install gh later).
3. If `gh` **is authenticated**: ask the user in their conversation language:
   > "GitHub CLI is available. Would you like to submit issues directly to GitHub? (recommended) [yes / no]"
   - **yes**: Set submit mode = **submit**. Save `issue_report_submit: true` to `jaan-to/config/settings.yaml`. Proceed to 1.4.
   - **no**: Set submit mode = **local-only**. Save `issue_report_submit: false` to `jaan-to/config/settings.yaml`. Skip to Step 2.

### 1.4 Verify gh availability (for submit mode)

If submit mode is **submit** (from any source):

1. Run `gh auth status` to verify GitHub CLI is still installed and authenticated.
2. If **available**: Confirm submit mode is active.
3. If **not available**: Inform user in their conversation language:
   > "GitHub CLI is not installed or not authenticated. Your issue will be saved locally instead. You can submit it manually later."
   Override to local-only mode.

---

## Step 2: Classify Issue Type

Determine issue type using this priority order:

1. **From `--type` flag** (if provided): use directly
2. **From session draft** (if accepted in Step 0): use the auto-classified type
3. **From keyword detection** in the description:

| Keywords | Type |
|----------|------|
| broken, error, crash, fails, wrong, bug, doesn't work | `bug` |
| add, new, would be nice, request, missing feature, wish | `feature` |
| skill, `/jaan-to:`, command, workflow, generate | `skill` |
| docs, documentation, readme, guide, typo, unclear | `docs` |

4. **If uncertain**, ask: "What type of issue is this? [bug / feature / skill / docs]"

Map type to GitHub label:

| Type | Label |
|------|-------|
| `bug` | `bug` |
| `feature` | `enhancement` |
| `skill` | `skill-request` |
| `docs` | `documentation` |

---

## Step 3: Gather Details

Ask targeted clarifying questions to build a complete, detailed issue. **If a session draft was accepted in Step 0, only ask deepening questions** — don't re-ask what's already captured from the conversation.

### For `bug` type:
1. "Which skill or feature were you using?" (skip if known from session)
2. "What did you expect to happen?"
3. "What actually happened?"
4. "Can you paste any error messages or unexpected output?" (skip if captured from session)
5. "Steps to reproduce?"
6. "Does this happen every time or only sometimes?"

### For `feature` type:
1. "What problem would this solve?"
2. "What would the ideal behavior look like?"
3. "Any related existing skills or features?"
4. "Can you describe a concrete use case?"

### For `skill` type:
1. "Which skill is affected? Or describe the new skill you'd like." (skip if known from session)
2. "What's the current behavior vs expected behavior?"
3. "How would this improve your workflow?"
4. "Can you share an example input and what output you'd expect?"

### For `docs` type:
1. "Which documentation page or section?"
2. "What's incorrect, missing, or confusing?"
3. "What would be the correct or clearer version?"

**Always ask** (for all types): "Is there anything else that would help understand this issue?"

**Skip questions the user already answered** in their initial description or session context.

---

## Step 4: Collect Environment Info

Auto-collect without user interaction:

1. Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` — extract `version` field
2. Run `uname -s -r -m` — extract OS type and architecture (do NOT include hostname)
3. Note the related skill name from Step 0/Step 3 (if identified)

Store as environment data for the issue body.

---

## Step 5: Generate Issue Title

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

## Step 6: Generate Issue Body

Read the template from `${CLAUDE_PLUGIN_ROOT}/skills/jaan-issue-report/template.md`.

Select the matching type template (bug / feature / skill / docs) and fill all `{{field}}` variables using:
- User's answers from Step 3
- Session context signals from Step 0 (if available)
- Environment info from Step 4

Merge all sources into a coherent, well-structured issue body. **All issue body content must be in English.**

---

## Step 7: Privacy Sanitization

**MANDATORY before HARD STOP preview.** Scan the generated issue body for private information:

### 7.1 Path Sanitization

Scan for patterns: `/Users/`, `/home/`, `/var/`, absolute project paths.

Replace:
- `/Users/{anything}/` → `{USER_HOME}/`
- Full project paths → `{USER_HOME}/{PROJECT_PATH}/...` (keep only the relative portion relevant to the issue)
- Keep relative plugin paths as-is (e.g., `skills/pm-prd-write/SKILL.md`)

### 7.2 Credential Sanitization

Scan for patterns: `token=`, `key=`, `password=`, `secret=`, `Bearer `, `ghp_`, `sk-`, `api_key`.

Replace any detected values with `[REDACTED]`.

### 7.3 Personal Info Check

Scan for patterns that look like emails, IP addresses, or usernames embedded in paths.

Replace with generic placeholders unless the user explicitly included them as part of the issue.

### 7.4 Safe to Keep

Do NOT sanitize these (they help maintainers debug):
- jaan-to version number (e.g., `5.0.0`)
- Skill names and commands (e.g., `/jaan-to:pm-prd-write`)
- Hook names (e.g., `session-start`, `post-tool-use`)
- OS type (e.g., `Darwin`, `Linux`)
- Error message text (after stripping paths and tokens from it)
- Plugin config keys (not secret values)

### 7.5 Count and Flag

Track the number of sanitized items. This count will be shown at HARD STOP.

---

# HARD STOP — Issue Review

Present the complete issue preview:

```
ISSUE PREVIEW
──────────────────────────────────────────
Repo:    parhumm/jaan-to
Type:    {type}
Label:   {label}
Title:   {title}
Mode:    {Submit to GitHub / Save locally}

BODY:
──────────────────────────────────────────
{full issue body — every line}
──────────────────────────────────────────
```

If items were sanitized in Step 7, flag:
> "Sanitized {N} private path(s)/value(s). Please review the preview carefully before approving."

Ask in the user's conversation language:
> "Does this look correct? [y/n/edit]"

- **y**: Proceed to Phase 2
- **n**: Abort, nothing saved
- **edit**: User provides changes → revise body, re-run sanitization, show preview again

**Do NOT proceed to Phase 2 without explicit "y" approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 8: Generate Output Path

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"

SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/jaan-issues"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
SLUG={kebab-case from title, max 50 chars, strip type prefix bracket}
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${SLUG}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${SLUG}.md"
```

Preview:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/jaan-issues/{NEXT_ID}-{SLUG}/`
> - Main file: `{NEXT_ID}-{SLUG}.md`

## Step 9: Save Local Copy

Write the issue to `$JAAN_OUTPUTS_DIR/jaan-issues/{id}-{slug}/{id}-{slug}.md`:

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

Update subdomain index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${SLUG}" \
  "{title}" \
  "{one-line summary}"
```

Confirm:
> "Local copy saved to: `$JAAN_OUTPUTS_DIR/jaan-issues/{NEXT_ID}-{SLUG}/{NEXT_ID}-{SLUG}.md`"

## Step 10: Submit to GitHub (if submit mode is active)

If submit mode is **submit** (as resolved in Step 1) and `gh auth status` passed in Step 1.4:

### 10.1 Strip YAML Frontmatter

```bash
awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "{MAIN_FILE}" > /tmp/jaan-issue-body-clean.md
```

### 10.2 Create Label (best effort)

```bash
gh label create "{label}" --repo parhumm/jaan-to --description "{description}" 2>/dev/null || true
```

### 10.3 Create Issue

```bash
gh issue create --repo parhumm/jaan-to \
  --title "{title}" \
  --label "{label}" \
  --body-file /tmp/jaan-issue-body-clean.md
```

### 10.4 Clean Up

```bash
rm -f /tmp/jaan-issue-body-clean.md
```

### 10.5 Handle Result

Capture the returned issue URL and extract the issue number.

**If successful**: Update the local copy frontmatter:
- Set `issue_url` to the returned GitHub URL
- Set `issue_number` to the extracted issue number

**If failed** (auth error, network, permissions):
> "GitHub submission failed: {error}. Your issue is saved locally at {path}. You can copy the content and create an issue manually at: https://github.com/parhumm/jaan-to/issues/new"

## Step 11: Confirm

Show in the user's conversation language:

**If submitted to GitHub:**
- Issue URL (clickable)
- Local copy path
- Label applied

**If saved locally only:**
- Local file path
- Instructions: "To submit manually, open `{file_path}`, copy the content below the YAML frontmatter (below the second `---`), and create a new issue at: https://github.com/parhumm/jaan-to/issues/new"

## Step 12: Capture Feedback

> "Any feedback on this issue report? [y/n]"

If yes:
- Run `/jaan-to:learn-add jaan-issue-report "{feedback}"`

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
- [ ] Local copy saved to `$JAAN_OUTPUTS_DIR/jaan-issues/{id}-{slug}/`
- [ ] Index updated
- [ ] If submit mode active: GitHub issue created and URL captured
- [ ] If submit mode active: Local copy updated with issue URL and number
- [ ] User informed of result and next steps
