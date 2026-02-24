# Lessons: qa-issue-report

> Last updated: 2026-02-24

Accumulated lessons from past executions.

---

## Better Questions

- Ask whether the issue occurs in production, staging, or development — this affects severity framing
- Ask for the git branch early — issues on feature branches vs main have different urgency
- If the user mentions an error, ask for the full error message before searching code — partial messages lead to wrong references
- Ask for specific skill or command used if the issue relates to a CLI tool or plugin
- Clarify if bugs are consistent or intermittent before classifying severity
- Only ask deepening questions when session draft is accepted — don't re-ask what's captured
- Always close with "Is there anything else?"

## Edge Cases

- Monorepo projects may have multiple package.json/go.mod files — detect the root-level one
- Some repos use non-standard remotes (e.g., `upstream` instead of `origin`) — if origin parse fails, list available remotes
- Private repos require proper gh/glab authentication scope — check permissions before submission
- Forked repos: the user's fork remote may differ from the upstream repo they want to file the issue to
- Self-hosted GitLab instances may lack `glab` CLI — fall back to curl with GITLAB_PRIVATE_TOKEN
- GitLab group/subgroup paths need URL-encoding for API calls (slashes → %2F)
- Non-English issue descriptions — always translate to English for body, keep conversation in user's language
- Raw error output may contain tokens or private paths — sanitization step catches these
- First-command session invocation (no session context) — skip Step 0 entirely
- User may not have `gh` or `glab` CLI installed — detect and fall back to local-only gracefully
- GitHub does not support image upload via CLI — notify user to add manually post-creation

## Workflow

- Run session context scan first if mid-session — it provides better search terms for Step 6
- Code reference search is most effective AFTER gathering details (Step 4) — user answers provide better terms
- Present code references as a numbered list so users can quickly select/deselect
- When the user provides file paths, verify they exist before including them
- For GitLab: upload media BEFORE creating the issue (embed returned markdown URLs in body)
- For GitHub: note local files for post-creation notification (no CLI upload support)
- Skip local file creation when platform submission succeeds — avoid duplicating
- Show copy-paste version before asking about local file save
- Always sanitize before HARD STOP preview
- Merge session context with clarifying answers — don't present them separately

## Common Mistakes

- Don't include absolute paths from the user's machine — always use relative paths
- Don't assume the current directory's git remote is the target repo — always confirm with the user
- Don't run runtime version commands for stacks that aren't detected — a Python project doesn't need `node -v`
- Don't search the entire codebase with overly broad Grep patterns — scope searches to relevant directories
- Don't include credentials, tokens, or secrets in the issue body
- Don't include personal info (email, IP) without user approval
- Don't use raw stack traces as issue titles — extract the meaningful part
- Don't skip the HARD STOP preview — user must approve before submission
- Don't use `glab issue create` for long descriptions — it lacks `--body-file`, use REST API instead
- Don't hardcode `gitlab.com` as the only GitLab host — support self-hosted instances
