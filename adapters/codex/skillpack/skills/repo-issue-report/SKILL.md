---
name: repo-issue-report
description: Report clear issues to any GitHub/GitLab repo with code refs and media. Use when filing bugs or feature requests.
allowed-tools: Read, Glob, Grep, Bash(gh auth status *), Bash(gh issue create *), Bash(gh label create *), Bash(gh repo view *), Bash(glab auth status *), Bash(glab issue create *), Bash(glab label create *), Bash(curl *), Bash(git remote *), Bash(git branch *), Bash(git log *), Bash(uname *), Bash(node -v *), Bash(python3 --version *), Bash(go version *), Bash(rustc --version *), Bash(java -version *), Bash(php -v *), Bash(ruby -v *), Bash(dotnet --version *), Bash(rm -f /tmp/repo-issue-*), Bash(mkdir -p $JAAN_OUTPUTS_DIR/repo-issues/*), Bash(cat *), Write($JAAN_OUTPUTS_DIR/repo-issues/**), Write(/tmp/repo-issue-*), Edit($JAAN_LEARN_DIR/**), Edit(jaan-to/config/settings.yaml)
argument-hint: "<issue-description> [--repo owner/repo] [--type bug|feature|improvement|question] [--submit | --no-submit] [--label l1,l2] [--attach path1,path2]"
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# repo-issue-report

> Report clear issues to any GitHub/GitLab repo with code references, media, and smart session context.

## Context Files

Read these before execution:
- `$JAAN_LEARN_DIR/jaan-to-repo-issue-report.learn.md` - Project-side learned lessons
- `${CLAUDE_PLUGIN_ROOT}/skills/repo-issue-report/LEARN.md` - Plugin-side seed lessons
- `${CLAUDE_PLUGIN_ROOT}/skills/repo-issue-report/template.md` - Issue body templates per type
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` - Privacy rules, env detection, API commands, result templates

## Input

**Arguments**: $ARGUMENTS

Parse from arguments:
1. **Issue description** — Free text describing the issue
2. **--repo** — Target repository as `owner/repo`. Default: auto-detect from `git remote get-url origin`
3. **--type** — Issue type: `bug`, `feature`, `improvement`, `question`. Default: auto-detect from description or session context.
4. **--submit** — Force submit to platform (overrides saved preference)
5. **--no-submit** — Force local-only mode (overrides saved preference)
6. **--label** — Comma-separated labels to apply (e.g., `--label bug,high-priority`)
7. **--attach** — Comma-separated file paths or URLs to attach (e.g., `--attach screenshot.png,error.log`)

If no arguments provided, proceed to session context scan (Step 0) or ask: "What issue would you like to report?"

---

# PHASE 1: Analysis (Read-Only)

## Pre-Execution Protocol

**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `repo-issue-report`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

**MANDATORY FIRST ACTION** — Before any other step, use the Read tool to read:
`$JAAN_LEARN_DIR/jaan-to-repo-issue-report.learn.md`

If the file exists, apply its lessons throughout this execution.
If the file does not exist, continue without it.

Also read the plugin-side seed lessons:
`${CLAUDE_PLUGIN_ROOT}/skills/repo-issue-report/LEARN.md`

### Language Settings

Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_repo-issue-report`

**CRITICAL LANGUAGE RULE:**
- **Conversation** (questions, confirmations, status messages, HARD STOP prompts): Use the resolved language preference
- **Issue output** (title + body): **ALWAYS in English** regardless of conversation language. Issues target international developer audiences.

**Keep in English always**: technical terms, file paths, variable names, code snippets, error messages.

---

## Step 0: Smart Session Context Analysis

**This step runs ONLY when the skill is invoked mid-session** (not as the first command). If no useful session context is found, skip to Step 1.

Analyze the current conversation deeply as an intelligent observer:

### 0.1 Conversation Timeline Reconstruction
Scan conversation chronologically. Build a timeline of commands run, tools used, files edited, errors encountered. Identify the user's goal ("story arc").

### 0.2 Error & Frustration Detection
Search for: error messages, failed tool calls, stack traces, frustration signals ("doesn't work", "wrong", "expected X got Y"), repeated retries. Capture exact error messages verbatim.

### 0.3 Code Context Extraction
Identify which files were being edited/read when the issue occurred. Note the sequence of changes, workarounds attempted, and relevant code snippets discussed.

### 0.4 Root Cause Hypothesis
Form a hypothesis about what went wrong. Identify the likely affected component/module/file. Note if it's a regression.

### 0.5 Generate Smart Draft

If signals were found:
- Auto-classify type: `bug` if errors found, `feature` if user expressed a wish, `improvement` if performance/quality discussed
- Draft a title (English, under 80 chars, `[Type] description`)
- Draft a 2-3 sentence description based on session signals
- Pre-fill template fields where possible (steps to reproduce, expected/actual, code refs, error messages)

**Present to user** using AskUserQuestion (in their conversation language):

Show the draft context first:
> "Based on this session, it looks like you experienced an issue:
>
> **Observed issue:** {draft title}
> {draft description — 2-3 sentences}
> **Likely affected area:** {component/file identified}
> **Root cause hypothesis:** {brief hypothesis}"

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

- **Yes, report this**: Continue to Step 1 with draft pre-filled. Step 4 will ask only deepening questions.
- **No, something else**: Discard draft, proceed to Step 1 with standard flow.
- **Close, let me adjust**: User modifies the draft, then continue to Step 1 with the adjusted version.

---

## Step 1: Resolve Target Repository & Platform

### 1.1 Check for --repo flag (highest priority)

If `--repo` is provided: set `TARGET_REPO` to the value. Proceed to 1.3.

### 1.2 Auto-detect from git remote

```bash
git remote get-url origin
```

Parse `owner/repo` from the URL. Handle all formats:
- HTTPS GitHub: `https://github.com/owner/repo.git` → `owner/repo`
- SSH GitHub: `git@github.com:owner/repo.git` → `owner/repo`
- HTTPS GitLab: `https://gitlab.com/group/repo.git` or `https://self-hosted.com/group/subgroup/repo.git`
- SSH GitLab: `git@gitlab.com:group/repo.git`

If parse fails: ask user "Which repository should I file this issue to? (format: owner/repo)"

### 1.3 Detect Platform & Verify Access

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Platform Detection & Verification" for URL pattern matching, `gh`/`glab` auth checks, GitLab token discovery chain, and verification commands.

Confirm to user: "Issues will be filed to: **{TARGET_REPO}** ({GitHub|GitLab})"

---

## Step 2: Resolve Submit Mode

Priority order: explicit flags (`--submit`/`--no-submit`) → saved preference (`repo_issue_report_submit` in settings.yaml) → smart detection (check `gh auth status` for GitHub, token availability for GitLab).

If CLI/token not available: inform user, override to local-only (don't save preference — user may configure later).

---

## Step 3: Classify Issue Type

Determine issue type using this priority order:

1. **From `--type` flag** (if provided): use directly
2. **From session draft** (if accepted in Step 0): use auto-classified type
3. **From keyword detection** in the description:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Keyword Detection Table" for keyword-to-type mapping.

4. **If uncertain**, ask using AskUserQuestion with options: Bug, Feature, Improvement, Question.

Type-to-label mapping:

| Type | GitHub Label | GitLab Label |
|------|-------------|-------------|
| `bug` | `bug` | `bug` |
| `feature` | `enhancement` | `feature` |
| `improvement` | `improvement` | `improvement` |
| `question` | `question` | `question` |

---

## Step 4: Gather Details

Ask targeted clarifying questions to build a complete issue. **If a session draft was accepted in Step 0, only ask deepening questions.**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Clarifying Questions per Type" for the full question sets per type (bug, feature, improvement, question).

**Always ask** (for all types): "Is there anything else that would help understand this?"

**Skip questions the user already answered** in their initial description or session context.

---

## Step 5: Media Attachment Collection

### 5.1 Check --attach flag

If `--attach` is provided, parse comma-separated file paths or URLs.

### 5.2 Ask about attachments

If no `--attach` flag:
```
AskUserQuestion:
  question: "Do you have screenshots, videos, or other files to attach?"
  header: "Attachments"
  options:
    - label: "Yes, I have files"
      description: "Provide file paths or URLs to attach to the issue"
    - label: "No attachments"
      description: "Continue without media"
```

If **Yes**: ask user for file paths or URLs. Accept multiple entries.

### 5.3 Collect & Validate

For each attachment: verify URLs are valid, verify local files exist via Glob. Accept images (png, jpg, gif, webp), video (mp4, mov), logs (txt, log). Warn and skip invalid paths.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Media Upload Strategy" for platform-specific upload details (GitLab API upload, GitHub post-creation notice, local-only mode).

---

## Step 6: Code Reference Search

Based on issue details AND session context, search the codebase for related code.

### 6.1 Extract Search Terms

From the issue description, user answers, and session context, extract:
- Function/method names mentioned
- Class/module names mentioned
- Error message text (for Grep)
- Feature names or keywords
- File paths mentioned by the user
- Files that were being edited/read during the session

### 6.2 Layered Search

Execute searches (stop when ~10 references found):

- **A. Direct mentions** — Glob/Grep for files/functions user explicitly named
- **B. Error text** — Grep for distinctive error message phrases
- **C. Semantic keywords** — Grep for function/class/route definitions related to the feature
- **D. Related tests** — Glob for `**/*test*` or `**/*spec*` in related directories
- **E. Session files** — Include files being edited/read during conversation (from Step 0.3)

### 6.3 Present Findings

Show findings as a numbered list:
> "I found these potentially related code areas:"
>
> 1. `src/auth/login.ts:45-78` — `authenticateUser()` function
> 2. `src/auth/middleware.ts:12-30` — JWT validation middleware
> 3. `tests/auth/login.test.ts:23-45` — Login tests

### 6.4 User Confirmation

```
AskUserQuestion:
  question: "Which references should I include in the issue?"
  header: "Code refs"
  options:
    - label: "All of them"
      description: "Include all found references"
    - label: "Let me select"
      description: "Choose specific references by number"
    - label: "None"
      description: "Skip code references"
```

If **Let me select**: ask for numbers. If user wants to add more: accept additional file paths.

---

## Step 7: Collect Environment Info

Auto-collect without user interaction:

### 7.1 Project Tech Stack Detection

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Environment Detection Table" for manifest-to-stack mapping and runtime commands.

Check for manifest files and run the corresponding runtime version command.

### 7.2 System Info

- `uname -s -r -m` — OS type and architecture (do NOT include hostname)
- `git branch --show-current` — Current branch

### 7.3 Compile Environment Block

Format as a table for the issue body. Only include what was detected.

---

## Step 8: Generate Issue Title

Craft a clear, descriptive title. **Always in English.**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Issue Title Format" for rules and examples.

Pattern: `[{Type}] {concise description}` (under 80 chars).

---

## Step 9: Generate Issue Body

Read the template from `${CLAUDE_PLUGIN_ROOT}/skills/repo-issue-report/template.md`.

Select the matching type template (bug / feature / improvement / question) and fill all `{{field}}` variables using:
- User's answers from Step 4
- Session context signals from Step 0 (if available)
- Code references from Step 6
- Media attachment placeholders from Step 5
- Environment info from Step 7

Merge all sources into a coherent, well-structured issue body. **All issue body content must be in English.**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Variable Mapping" for complete field mapping per issue type.

---

## Step 10: Privacy Sanitization

**MANDATORY before HARD STOP preview.**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Privacy Sanitization Rules" for path, credential, connection string, and personal info rules.

Apply all sanitization rules. Track the number of sanitized items for HARD STOP display.

---

# HARD STOP — Issue Review

Present the complete issue preview:

```
ISSUE PREVIEW
──────────────────────────────────────────
Platform: {GitHub|GitLab}
Repo:     {owner/repo}
Type:     {type}
Labels:   {label(s)}
Title:    {title}
Attach:   {N file(s) | None}
Mode:     {Submit to platform / Save locally}

BODY:
──────────────────────────────────────────
{full issue body — every line}
──────────────────────────────────────────
```

If items were sanitized in Step 10, flag:
> "For privacy, {N} path(s)/value(s) have been sanitized. Please review carefully."

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
      description: "Make changes before proceeding"
```

- **Yes**: Proceed to Phase 2
- **No**: Abort, nothing saved
- **Edit**: User provides changes → revise body, re-run sanitization, show preview again

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Generation (Write Phase)

## Step 11: Upload Media & Prepare Body File

**GitLab local files**: Upload via `POST /api/v4/projects/:id/uploads` → extract `markdown` field from response → replace placeholders in body.
**GitHub local files**: Mark for post-creation notification (Step 14).
**URLs (both)**: Already embedded as markdown in body.

Write the final sanitized body to `/tmp/repo-issue-body-clean.md`.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Media Upload Commands" for exact curl commands and response parsing.

---

## Step 12: Generate Output Path

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Output Path Generation" for the bash script.

Store variables: `NEXT_ID`, `SLUG`, `OUTPUT_FOLDER`, `MAIN_FILE` for potential local save.

---

## Step 13: Submit Issue (if submit mode is active)

If submit mode is **local-only**: skip to Step 15.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Submission Commands" for exact GitHub (`gh issue create --body-file`) and GitLab (REST API `POST /projects/:id/issues`) commands, label creation, and response parsing.

**If successful**: capture issue URL and number. Proceed to Step 14.
**If failed**: capture error. Continue to Step 15 for local fallback.

---

## Step 14: Post-Creation Attachment Notice (GitHub only)

If GitHub platform AND local file attachments that couldn't be uploaded:
> "Issue created successfully. Please add these attachments by editing the issue at {issue_url}:"
> - `screenshot.png` — drag & drop into the issue body
> - `error-log.txt` — drag & drop into the issue body

---

## Step 15: Handle Local Copy (conditional)

**Reached when**: local-only mode OR submission failed. **Skipped if** submission succeeded.

Show copy-paste ready version with platform-specific manual submit URL. Ask if user wants to save a local file. If yes: create folder, write file with YAML frontmatter + body, update index.

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` sections "Copy-Paste Ready Template", "Local Issue File Template", and "Output Path Generation" for formats and commands.

---

## Step 16: Confirm Result

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/repo-issue-report-reference.md` section "Result Scenario Templates" for all 5 scenarios.

---

## Step 17: Capture Feedback

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

If **Yes**: ask for details, then run `/jaan-to:learn-add repo-issue-report "{feedback}"`

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Single source of truth (no duplication)
- Generic and scalable (any repo, any stack)
- Maintains human control over submissions

## Definition of Done

- [ ] Target repository resolved and verified (GitHub or GitLab)
- [ ] Platform detected and confirmed with user
- [ ] Session context analyzed (if mid-session invocation)
- [ ] Issue type classified (bug/feature/improvement/question)
- [ ] All relevant details gathered via clarifying questions
- [ ] Media attachments collected and validated (if any)
- [ ] Code reference search completed and user confirmed references
- [ ] Environment info auto-collected (tech stack, runtime, OS, branch)
- [ ] Issue title is clear, English, under 80 chars
- [ ] Issue body follows template structure and is in English
- [ ] Code references section populated with confirmed references
- [ ] Privacy sanitization completed (paths, tokens, personal info)
- [ ] HARD STOP approved by user (full preview shown)
- [ ] If submit mode: issue creation attempted on correct platform
- [ ] If GitLab + local attachments: files uploaded via API before issue creation
- [ ] If GitHub + local attachments: user notified to add manually post-creation
- [ ] If local-only or submission failed: copy-paste version shown
- [ ] User informed of result
