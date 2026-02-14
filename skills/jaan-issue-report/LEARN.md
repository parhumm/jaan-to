# Lessons: jaan-issue-report

> Last updated: 2026-02-10

Accumulated lessons from past executions of issue reporting. Read this before executing to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions that improve issue report quality:

- Always ask for the specific skill command that was being used when the issue occurred (e.g., `/jaan-to:pm-prd-write`) — this helps maintainers reproduce the context
- For bug reports, ask whether the issue is consistent (happens every time) or intermittent — intermittent bugs need more context about conditions
- When session draft is accepted, ask only deepening questions — don't repeat what's already captured from the conversation
- Always close with "Is there anything else that would help understand this issue?" — users often have additional context they don't think to share upfront

## Edge Cases

Special cases to check and handle:

- User may not have `gh` CLI installed or authenticated — detect this upfront with `gh auth status` before offering submit mode
- User may be reporting an issue from a project that has custom path configuration — include whether paths are default or customized in environment info
- Issue description may be in a non-English language — always translate to English for the issue body while keeping conversation in user's language
- User may paste raw error output containing tokens or private paths — sanitization step must catch these before preview
- Skill may be invoked as the first command in a session — no session context available, skip Step 0 entirely

## Workflow

Process improvements:

- Run session context scan (Step 0) before anything else when mid-session — pre-drafting from conversation saves user time and produces more accurate reports
- When GitHub submission succeeds, skip local file creation to reduce clutter — the GitHub issue is the source of truth
- Show copy-paste ready version before asking about local file creation — gives users immediate access to the content even if they skip saving
- Local files are created only when: (1) GitHub submission fails, (2) user is in local-only mode, AND (3) user explicitly requests it
- Strip YAML frontmatter using `awk` before `gh issue create` — frontmatter renders as visible text in GitHub issues
- Always run privacy sanitization scan before HARD STOP preview — never show unsanitized content to the user for approval
- When generating the issue body, merge session context signals with user's clarifying answers for the most complete picture

## Common Mistakes

Things to avoid:

- Don't skip the submit mode resolution in Step 1 — respect the priority: `--submit`/`--no-submit` flags > saved `issue_report_submit` preference > default submit (if `gh` authenticated)
- Don't include absolute user paths (`/Users/name/...`, `/home/name/...`) — sanitize to `{USER_HOME}/{PROJECT_PATH}/...`
- Don't include credentials, tokens, secrets, or `.env` values — replace with `[REDACTED]`
- Don't include personal info (real name, email, IP addresses) unless user explicitly approves
- Don't put raw stack traces in the issue title — keep titles concise and descriptive (under 80 chars)
- Don't skip clarifying questions — even when session context provides a draft, deeper details make better issues
- Don't use jaan-to internal jargon in issue titles that GitHub maintainers wouldn't understand
- Don't include the user's hostname in environment info — OS type and architecture are sufficient
