---
title: "repo-issue-report Reference"
sidebar_position: 50
---

# repo-issue-report — Reference Material

> Extracted from `skills/repo-issue-report/SKILL.md` for token optimization.
> Contains platform detection, API commands, clarifying questions, privacy rules, media upload strategy, environment detection, result templates, and definition of done.

---

## Platform Detection & Verification

### URL Pattern Matching

| Pattern | Platform |
|---------|----------|
| Contains `github.com` | GitHub |
| Contains `gitlab` in hostname | GitLab |
| SSH `git@github.com:` | GitHub |
| SSH `git@gitlab.com:` or `git@{host}:` with GitLab API responding | GitLab |
| HTTPS `https://{host}/group/subgroup/repo.git` (non-GitHub) | Attempt GitLab detection |

### Ambiguous Host Detection

If URL doesn't clearly indicate platform:
1. Run `gh repo view {TARGET_REPO} --json nameWithOwner 2>/dev/null` — if success → **GitHub**
2. Run `glab auth status 2>/dev/null` — if authenticated → **GitLab**
3. If both fail → ask user with AskUserQuestion: "GitHub" / "GitLab"

### Verification Commands

**GitHub:**
```bash
gh repo view {TARGET_REPO} --json nameWithOwner -q '.nameWithOwner'
```

**GitLab (glab available):**
```bash
glab repo view -R {TARGET_REPO}
```

**GitLab (curl fallback):**
```bash
curl -s -H "PRIVATE-TOKEN: $TOKEN" \
  "{base_url}/api/v4/projects/{url_encoded_path}" | jq -r '.path_with_namespace'
```

If verification fails: "Repository {TARGET_REPO} not found or not accessible."

### GitLab Token Discovery Chain

Check in order (use first found):
1. `$GITLAB_PRIVATE_TOKEN`
2. `$GITLAB_TOKEN`
3. `$CI_JOB_TOKEN`
4. `glab` CLI config (run `glab auth status`)

If no token found and submit mode is active → fall back to local-only.

### GitLab URL Encoding

For REST API calls, encode project path: `group/subgroup/repo` → `group%2Fsubgroup%2Frepo`

---

## Submission Commands

### GitHub

```bash
# Create labels (best effort)
gh label create "{label}" --repo {TARGET_REPO} 2>/dev/null || true

# Create issue (--body-file for reliable long body handling)
gh issue create --repo {TARGET_REPO} \
  --title "{title}" \
  --label "{label1},{label2}" \
  --body-file /tmp/repo-issue-body-clean.md
```

Capture issue URL from stdout output.

### GitLab — Label Creation (glab)

```bash
glab label create --name "{label}" -R {TARGET_REPO} 2>/dev/null || true
```

### GitLab — Issue Creation (REST API)

`glab issue create` lacks `--body-file`. Use REST API for reliable long description handling:

```bash
# Write payload JSON
cat > /tmp/repo-issue-payload.json <<'PAYLOAD_EOF'
{
  "title": "{title}",
  "description": "{sanitized issue body}",
  "labels": "{label1},{label2}"
}
PAYLOAD_EOF

# Create issue via REST API
curl --request POST \
  --header "PRIVATE-TOKEN: $TOKEN" \
  --header "Content-Type: application/json" \
  --data @/tmp/repo-issue-payload.json \
  "{base_url}/api/v4/projects/{url_encoded_path}/issues"
```

Parse response:
- `web_url` — the issue URL for user
- `iid` — the issue number within the project

### Cleanup

```bash
rm -f /tmp/repo-issue-body-clean.md /tmp/repo-issue-payload.json
```

---

## Media Upload Strategy

### GitLab — Upload Local Files Before Issue Creation

For each local file attachment:
```bash
curl --request POST --header "PRIVATE-TOKEN: $TOKEN" \
  --form "file=@{filepath}" \
  "{base_url}/api/v4/projects/{url_encoded_path}/uploads"
```

Response example:
```json
{
  "id": 5,
  "alt": "screenshot",
  "url": "/uploads/66dbcd21ec5d24ed6ea225176098d52b/screenshot.png",
  "full_path": "/-/project/1234/uploads/66dbcd21ec5d24ed6ea225176098d52b/screenshot.png",
  "markdown": "![screenshot](/uploads/66dbcd21ec5d24ed6ea225176098d52b/screenshot.png)"
}
```

Extract `markdown` field → replace attachment placeholders in issue body BEFORE creating the issue.

### GitHub — No CLI Upload Support

`gh issue create` does NOT support image/file uploads. Strategy:
- **URLs**: Embed directly as `![description](url)` in body — works immediately
- **Local files**: After issue creation, notify user:
  > "Issue created. Please add these attachments by editing the issue at {issue_url}:"
  > - `screenshot.png` — drag & drop into the issue body
  > - `error-log.txt` — drag & drop into the issue body

### Local-Only Mode

List file paths in the issue body as reference:
```markdown
_Attachments (add manually when submitting):_
- `{filepath}` — {description}
```

---

## Media Upload Commands

### GitLab Upload (per file)

```bash
UPLOAD_RESPONSE=$(curl -s --request POST \
  --header "PRIVATE-TOKEN: $TOKEN" \
  --form "file=@{filepath}" \
  "{base_url}/api/v4/projects/{url_encoded_path}/uploads")

# Extract markdown embed string
MARKDOWN_EMBED=$(echo "$UPLOAD_RESPONSE" | jq -r '.markdown')
```

Replace `{{attachments}}` placeholder in body with all collected `MARKDOWN_EMBED` values.

---

## Clarifying Questions per Type

### For `bug` type:
1. "Which feature, module, or component is affected?" (skip if known from session)
2. "What were you trying to accomplish?"
3. "What outcome did you expect?"
4. "What actually happened instead?"
5. "Can you share any error messages or unexpected output?" (skip if captured from session)
6. "What are the steps to reproduce this?"
7. "Does this occur consistently or intermittently?"

**Smart synthesis:** Focus bug description on the problem (broken functionality, unexpected behavior) and impact (workflow blocked, wrong results) rather than just error text.

### For `feature` type:
1. "What problem are you experiencing or trying to solve?"
2. "What outcome would you like to achieve?"
3. "Can you describe a concrete scenario where this problem occurs?"
4. "How does this problem impact your workflow?"
5. "Are there related existing features you've tried?"

**Smart auto-conversion:** If user describes a solution ("Add support for X"), extract the problem:
- Ask: "That's a helpful idea. What problem would that solve?"
- Synthesize: User wants to achieve [outcome] but currently experiences [problem]

### For `improvement` type:
1. "Which part of the codebase or workflow needs improvement?"
2. "What is the current behavior or limitation?"
3. "What would the improved version look like?"
4. "What impact would this improvement have?"
5. "Are there any constraints or considerations?"

**Smart synthesis:** Frame around the gap (current limitation) and its measurable impact.

### For `question` type:
1. "What are you trying to understand or accomplish?"
2. "What have you already tried or read?"
3. "Where did you get stuck?"
4. "What information would help you move forward?"

**Smart synthesis:** Focus on the knowledge gap and the user's blocked goal.

---

## Keyword Detection Table

| Keywords | Type |
|----------|------|
| broken, error, crash, fails, wrong, bug, doesn't work, exception, stacktrace | `bug` |
| add, new, would be nice, request, missing feature, wish, proposal | `feature` |
| improve, enhance, refactor, optimize, better, upgrade, performance | `improvement` |
| how to, why does, question, confused, help, what is, documentation | `question` |

### Type-to-Label Mapping

| Type | GitHub Label | GitLab Label |
|------|-------------|-------------|
| `bug` | `bug` | `bug` |
| `feature` | `enhancement` | `feature` |
| `improvement` | `improvement` | `improvement` |
| `question` | `question` | `question` |

---

## Issue Title Format

**Rules:**
- Under 80 characters
- Start with type prefix in brackets: `[Bug]`, `[Feature]`, `[Improvement]`, `[Question]`
- Be specific about what is affected
- Always in English
- If session draft was accepted, refine its title rather than starting fresh

**Pattern**: `[{Type}] {concise description of the issue}`

**Examples:**
- `[Bug] Login fails with 401 when using OAuth2 provider`
- `[Feature] Support batch import for CSV data files`
- `[Improvement] Reduce API response time for search endpoint`
- `[Question] How to configure custom middleware chain`

---

## Variable Mapping

### For `bug` type:
- `{{bug_description}}`: Synthesize from what user was trying, what went wrong. Focus on what's broken.
- `{{impact_description}}`: Workflow impact — what is blocked or degraded.
- `{{expected_behavior}}`: What the user expected to achieve.
- `{{actual_behavior}}`: What actually happened instead.
- `{{steps_to_reproduce}}`: Step-by-step instructions.
- `{{additional_context}}`: From final "anything else?" and extra details.

### For `feature` type:
- `{{problem_description}}`: Current limitation or gap. Focus on the problem, not the solution.
- `{{impact_description}}`: How this problem affects workflow/results.
- `{{use_case}}`: Concrete situation where the problem occurs.
- `{{possible_approaches}}`: If user proposed solutions, include as suggestions. Otherwise: "Open to maintainer's approach."
- `{{related_features}}`: Related features they've tried.

### For `improvement` type:
- `{{current_state}}`: How things work currently.
- `{{limitation_description}}`: What's limiting or suboptimal.
- `{{proposed_improvement}}`: What the improved version would look like.
- `{{impact_description}}`: Measurable impact of the improvement.
- `{{constraints}}`: Technical or business constraints.

### For `question` type:
- `{{question_description}}`: The core question, clearly stated.
- `{{user_goal}}`: What user is trying to accomplish.
- `{{already_tried}}`: What they've already tried or read.
- `{{stuck_description}}`: Where they got stuck.

### Common fields (all types):
- `{{code_references}}`: Table of file paths, line ranges, and descriptions from Step 6.
- `{{attachments}}`: Embedded images/videos or pending file list from Step 5.
- `{{tech_stack}}`: Detected from manifest files (Step 7).
- `{{runtime_version}}`: From runtime version command (Step 7).
- `{{os_info}}`: From `uname -s -r -m` (Step 7).
- `{{git_branch}}`: From `git branch --show-current` (Step 7).
- `{{key_dependencies}}`: Key packages/versions from manifest (Step 7).

---

## Privacy Sanitization Rules

**MANDATORY before HARD STOP preview.**

### Path Sanitization
Scan for patterns: `/Users/`, `/home/`, `/var/`, absolute project paths.
- `/Users/{anything}/` → `{USER_HOME}/`
- Full project paths → `{USER_HOME}/{PROJECT_PATH}/...` (keep only relative portion)
- Keep relative project paths as-is (e.g., `src/auth/login.ts`)

### Credential Sanitization
Scan for: `token=`, `key=`, `password=`, `secret=`, `Bearer `, `ghp_`, `sk-`, `api_key`, `glpat-`.
Replace any detected values with `[REDACTED]`.

### Connection String Sanitization
- `postgresql://`, `postgres://` → `[DB_CONNECTION_REDACTED]`
- `mysql://`, `mariadb://` → `[DB_CONNECTION_REDACTED]`
- `mongodb://`, `mongodb+srv://` → `[DB_CONNECTION_REDACTED]`
- `redis://`, `rediss://` → `[DB_CONNECTION_REDACTED]`
- `amqp://`, `amqps://` → `[MQ_CONNECTION_REDACTED]`
- `jdbc:` prefixed URLs → `[DB_CONNECTION_REDACTED]`
- Generic URL auth pattern `://user:pass@` → `://[AUTH_REDACTED]@`

### Personal Info Check
Scan for emails, IP addresses, or usernames embedded in paths.
Replace with generic placeholders unless user explicitly included them.

### Safe to Keep
Do NOT sanitize:
- Project version numbers
- Skill names, command names, hook names
- OS type (Darwin, Linux)
- Error message text (after stripping paths and tokens)
- Config keys (not secret values)
- Relative file paths within the project

### Count and Flag
Track the number of sanitized items. Show count at HARD STOP.

---

## Environment Detection Table

| Manifest File | Tech Stack | Runtime Command |
|---------------|-----------|-----------------|
| `package.json` | Node.js / JavaScript / TypeScript | `node -v` |
| `Cargo.toml` | Rust | `rustc --version` |
| `go.mod` | Go | `go version` |
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python | `python3 --version` |
| `composer.json` | PHP | `php -v` |
| `Gemfile` | Ruby | `ruby -v` |
| `pom.xml` / `build.gradle` | Java / Kotlin | `java -version` |
| `*.csproj` / `*.sln` | .NET | `dotnet --version` |

For detected manifest: read key fields (name, version, relevant dependencies).

---

## Output Path Generation

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"

SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/repo-issues"
mkdir -p "$SUBDOMAIN_DIR"

NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
SLUG={kebab-case from title, max 50 chars, strip type prefix bracket}
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${SLUG}"
MAIN_FILE="${OUTPUT_FOLDER}/${NEXT_ID}-${SLUG}.md"
```

---

## Copy-Paste Ready Template

```
──────────────────────────────────────────
COPY-PASTE READY ISSUE
──────────────────────────────────────────

Title: {title}

{full issue body without YAML frontmatter}

──────────────────────────────────────────
```

**Contextual message (GitHub failure or local-only):**
> "You can copy the content above and submit manually at: {manual_url}"

**Manual submit URLs:**
- GitHub: `https://github.com/{TARGET_REPO}/issues/new`
- GitLab: `{base_url}/{project_path}/-/issues/new`

---

## Local Issue File Template

Write to `$MAIN_FILE`:

```markdown
---
title: "{issue_title}"
type: "{bug|feature|improvement|question}"
label: "{github_or_gitlab_label}"
repo: "{TARGET_REPO}"
platform: "{GitHub|GitLab}"
issue_url: ""
issue_number: null
date: "{YYYY-MM-DD}"
tech_stack: "{detected stack}"
os: "{uname output}"
branch: "{git branch}"
generated_by: "repo-issue-report"
session_context: {true|false}
---

{full issue body}
```

---

## Result Scenario Templates

### Scenario A: Platform Submission Succeeded (No Local File)
> Issue successfully reported:
> - URL: {clickable issue URL}
> - Issue #: {issue_number}
> - Labels: {labels}

### Scenario B: Local-Only Mode + Local File Saved
> Issue saved locally:
> - Path: `{full path to .md file}`
> To submit manually: {manual_url}

### Scenario C: Local-Only Mode + No Local File
> No file was created. Use the copy-paste version shown above to submit manually at: {manual_url}

### Scenario D: Submission Failed + Local File Saved
> Submission failed: {error}
> Issue saved locally:
> - Path: `{full path to .md file}`
> To submit manually: {manual_url}

### Scenario E: Submission Failed + No Local File
> Submission failed: {error}
> No file was created. Use the copy-paste version shown above to submit manually at: {manual_url}

---

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
