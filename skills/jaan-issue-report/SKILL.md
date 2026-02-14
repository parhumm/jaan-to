---
name: jaan-issue-report
description: Report bugs, feature requests, or skill issues to the jaan-to GitHub repo or save locally
allowed-tools: Read, Glob, Grep, Bash(gh auth status *), Bash(gh issue create *), Bash(gh label create *), Bash(uname *), Bash(awk *), Bash(rm -f /tmp/jaan-issue-body-*), Bash(mkdir -p $JAAN_OUTPUTS_DIR/jaan-issues/*), Write($JAAN_OUTPUTS_DIR/jaan-issues/**), Edit($JAAN_LEARN_DIR/**), Edit(jaan-to/config/settings.yaml)
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

## Pre-Execution Protocol

**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `jaan-issue-report`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

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

**Present to user** using AskUserQuestion (in their conversation language):

Show the draft context first:
> "Based on this session, it looks like you hit an issue with `/jaan-to:{skill-name}`:
>
> **Suggested issue:** {draft title}
> {draft description — 2-3 sentences}"

Then ask:
```
AskUserQuestion:
  question: "Is this what you'd like to report?"
  header: "Draft"
  options:
    - label: "Yes, report this"
      description: "Continue with this draft. Only deepening questions will be asked."
    - label: "No, something else"
      description: "Discard this draft and start fresh."
    - label: "Close, let me adjust"
      description: "Edit the draft before continuing."
```

- **Yes, report this**: Continue to Step 1 with draft pre-filled. Step 3 will ask only deepening questions.
- **No, something else**: Discard draft, proceed to Step 1 with standard flow.
- **Close, let me adjust**: User modifies the draft, then continue to Step 1 with the adjusted version.

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

### 1.3 Smart detection (default: submit)

1. Run `gh auth status` silently.
2. If `gh` is **not available or not authenticated**:
   > "GitHub CLI is not installed or not authenticated. Issues will be saved locally. You can submit them manually later."
   Set submit mode = **local-only**. Skip to Step 2. Do NOT save this as a preference (user may install gh later).
3. If `gh` **is authenticated**: Set submit mode = **submit**. Proceed to 1.4.
   No question asked — submit is the default. Users can opt out with `--no-submit` or by setting `issue_report_submit: false` in `jaan-to/config/settings.yaml`.

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

4. **If uncertain**, ask using AskUserQuestion:
   ```
   AskUserQuestion:
     question: "What type of issue is this?"
     header: "Issue type"
     options:
       - label: "Bug"
         description: "Something is broken or not working as expected"
       - label: "Feature"
         description: "A new capability or enhancement"
       - label: "Skill"
         description: "Issue with a specific jaan-to skill"
       - label: "Docs"
         description: "Documentation is incorrect, missing, or unclear"
   ```

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

Ask using AskUserQuestion (in the user's conversation language):
```
AskUserQuestion:
  question: "Does this look correct?"
  header: "Approve"
  options:
    - label: "Yes, looks good"
      description: "Proceed to save and/or submit the issue"
    - label: "No, abort"
      description: "Cancel — nothing will be saved or submitted"
    - label: "Edit"
      description: "Make changes to the issue before proceeding"
```

- **Yes**: Proceed to Phase 2
- **No**: Abort, nothing saved
- **Edit**: User provides changes → revise body, re-run sanitization, show preview again

**Do NOT proceed to Phase 2 without explicit approval.**

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

Store variables for potential local save:
- `NEXT_ID`: {NEXT_ID}
- `SLUG`: {kebab-case from title}
- `OUTPUT_FOLDER`: `$JAAN_OUTPUTS_DIR/jaan-issues/{NEXT_ID}-{SLUG}/`
- `MAIN_FILE`: `{NEXT_ID}-{SLUG}.md`

(These will be used only if local file creation is requested in Step 10.)

## Step 9: Submit to GitHub (if submit mode is active)

If submit mode is **local-only** (as resolved in Step 1), skip this step entirely and proceed to Step 10.

If submit mode is **submit**:

### 9.1 Prepare Issue Body

Write the sanitized issue body (without YAML frontmatter) directly to a temp file:

```bash
cat > /tmp/jaan-issue-body-clean.md <<'EOF'
{full issue body content — generated in Step 6, sanitized in Step 7}
EOF
```

### 9.2 Create Label (best effort)

```bash
gh label create "{label}" --repo parhumm/jaan-to --description "{description}" 2>/dev/null || true
```

### 9.3 Create Issue

```bash
gh issue create --repo parhumm/jaan-to \
  --title "{title}" \
  --label "{label}" \
  --body-file /tmp/jaan-issue-body-clean.md
```

### 9.4 Clean Up Temp File

```bash
rm -f /tmp/jaan-issue-body-clean.md
```

### 9.5 Handle Result

**If successful:**
1. Capture the returned issue URL (e.g., `https://github.com/parhumm/jaan-to/issues/123`)
2. Extract issue number from URL
3. Store both for Step 11 confirmation
4. **Skip Step 10 entirely** — proceed directly to Step 11 (do NOT create local file)

**If failed** (authentication error, network issue, API error):
1. Capture error message
2. Continue to Step 10 to handle local copy options

---

## Step 10: Handle Local Copy (conditional)

**This step is reached in two scenarios:**
1. Submit mode is **local-only** (GitHub was never attempted)
2. Submit mode was **submit** but GitHub submission failed in Step 9

**This step is SKIPPED if:**
- GitHub submission succeeded in Step 9 (proceed directly to Step 11)

### 10.1 Show Copy-Paste Ready Version

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

### 10.2 Ask About Local File

Use AskUserQuestion (in the user's conversation language):

```
AskUserQuestion:
  question: "Would you like to save a local copy of this issue as a file?"
  header: "Save file"
  options:
    - label: "Yes, save local copy"
      description: "Save the issue as a .md file with metadata for future reference"
    - label: "No, skip"
      description: "Don't create a file — use the copy-paste version above instead"
```

### 10.3 Save Local File (if user chooses "Yes")

If user selected **"Yes, save local copy"**:

#### 10.3.1 Create Folder Structure

```bash
mkdir -p "$OUTPUT_FOLDER"
```

#### 10.3.2 Write Issue File

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

#### 10.3.3 Update Index

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

### 10.4 Skip Local File (if user chooses "No")

If user selected **"No, skip"**:
- Do NOT create any folders or files
- Do NOT update the index
- Proceed directly to Step 11

---

## Step 11: Confirm Result

Show the appropriate result message in the user's conversation language.

### Scenario A: GitHub Submission Succeeded (No Local File)

**When**: Step 9 succeeded, Step 10 was skipped.

> Issue submitted to GitHub:
> - URL: {clickable GitHub issue URL}
> - Issue #: {issue_number}
> - Label: {label}

### Scenario B: Local-Only Mode + Local File Saved

**When**: Step 1 set local-only mode, Step 10.3 created file.

> Issue saved locally:
> - Path: `{full path to .md file}`
>
> To submit manually, copy the content below the second `---` line and create a new issue at: https://github.com/parhumm/jaan-to/issues/new

### Scenario C: Local-Only Mode + No Local File

**When**: Step 1 set local-only mode, Step 10.2 user chose "No, skip".

> No file was created. You can use the copy-paste version shown above to submit manually at: https://github.com/parhumm/jaan-to/issues/new

### Scenario D: GitHub Failed + Local File Saved

**When**: Step 9 failed, Step 10.3 created file.

> GitHub submission failed: {error}
>
> Issue saved locally:
> - Path: `{full path to .md file}`
>
> To submit manually, copy the content below the second `---` line and create a new issue at: https://github.com/parhumm/jaan-to/issues/new

### Scenario E: GitHub Failed + No Local File

**When**: Step 9 failed, Step 10.2 user chose "No, skip".

> GitHub submission failed: {error}
>
> No file was created. You can use the copy-paste version shown above to submit manually at: https://github.com/parhumm/jaan-to/issues/new

## Step 12: Capture Feedback

```
AskUserQuestion:
  question: "Any feedback on this issue reporting experience?"
  header: "Feedback"
  options:
    - label: "No feedback"
      description: "All good, skip feedback"
    - label: "Yes, I have feedback"
      description: "Share feedback to improve this skill"
```

If **Yes, I have feedback**: ask for details, then run `/jaan-to:learn-add jaan-issue-report "{feedback}"`

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
