---
title: "qa-issue-report"
sidebar_position: 9
---

# /qa-issue-report

> Report clear issues to any GitHub/GitLab repo with code references, media, and smart session context.

---

## What It Does

Guides you through creating a structured issue for any repository you work on. Supports both GitHub and GitLab (including self-hosted instances). The skill auto-detects your platform from `git remote`, gathers details through targeted questions, searches the codebase for related code references, and sanitizes private data before preview.

When invoked mid-session, the skill scans the conversation for errors, stack traces, and frustration signals to auto-draft a suggested issue with pre-filled fields.

---

## How It Differs from jaan-issue-report

| Aspect | [jaan-issue-report](../core/jaan-issue-report.md) | qa-issue-report |
|--------|---------------------|---------------------|
| Target | jaan-to plugin repo only | Any GitHub or GitLab repo |
| Platform | GitHub only | GitHub and GitLab (including self-hosted) |
| Issue types | `bug`, `feature`, `skill`, `docs` | `bug`, `feature`, `improvement`, `question` |
| Media | No attachments | Screenshots, videos, logs via `--attach` |
| Code refs | No code search | Layered codebase search with user confirmation |
| Environment | jaan-to version info | Full tech stack detection (Node, Python, Go, etc.) |
| Use when | Reporting jaan-to plugin issues | Filing issues to your own project or any repo |

---

## Usage

```
/qa-issue-report "<description>"
/qa-issue-report "<description>" --repo owner/repo --type bug
/qa-issue-report "<description>" --submit --label bug,high-priority
/qa-issue-report "<description>" --attach screenshot.png,error.log
/qa-issue-report
```

---

## Arguments

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| `<description>` | Free text | — | Issue description in plain language |
| `--repo` | `owner/repo` | Auto-detect from git remote | Target repository |
| `--type` | `bug`, `feature`, `improvement`, `question` | Auto-detect | Issue category |
| `--submit` | (no value) | — | Force submit to platform |
| `--no-submit` | (no value) | — | Force local-only mode |
| `--label` | Comma-separated | Type-based default | Labels to apply |
| `--attach` | Comma-separated paths/URLs | — | Media files to attach |

**Submit mode resolution** (when neither flag is provided):

1. Saved preference in `jaan-to/config/settings.yaml` (`qa_issue_report_submit`)
2. If no preference saved: detects `gh`/`glab` CLI availability, asks once, saves your choice

---

## What It Asks

| Question | When |
|----------|------|
| "Is this what you'd like to report?" | Session draft detected (mid-session use) |
| "What did you expect to happen?" | Bug reports |
| "What actually happened?" | Bug reports |
| "Steps to reproduce?" | Bug reports |
| "What problem would this solve?" | Feature requests |
| "Do you have screenshots or files to attach?" | No `--attach` flag |
| "Which code references should I include?" | After code search |
| "Is there anything else?" | Always |

When a session draft is accepted, only deepening questions are asked.

---

## Key Features

### Dual Platform Support

Auto-detects GitHub or GitLab from your git remote URL. Handles HTTPS, SSH, and self-hosted GitLab instances. Verifies CLI authentication (`gh auth status` or `glab auth status`) before submission.

### Smart Session Context

When invoked mid-session, the skill reconstructs a conversation timeline: commands run, files edited, errors encountered, frustration signals. It drafts a suggested issue with pre-filled title, description, and type classification. You review and approve or discard the draft.

### Code Reference Search

Searches the codebase in layers: direct file/function mentions, error message text, semantic keywords, related tests, and files from the session. Presents findings as a numbered list. You choose which references to include in the issue.

### Media Attachments

Attach screenshots (png, jpg, gif, webp), videos (mp4, mov), or logs (txt, log) via `--attach` or when prompted. GitLab files upload automatically via API. GitHub files require manual drag-and-drop after issue creation (the skill provides instructions).

### Privacy Sanitization

Before preview, the skill sanitizes: private paths (`/Users/name/...` to `{USER_HOME}/...`), tokens and secrets (`[REDACTED]`), connection strings, and personal info (email, IP). The HARD STOP preview shows the count of sanitized items.

---

## Output

**Submit mode**:
- Creates an issue on the target platform (GitHub or GitLab)
- Displays the issue URL

**Local mode**:
```
$JAAN_OUTPUTS_DIR/qa-issues/{id}-{slug}/{id}-{slug}.md
```

Both modes show a copy-paste ready version with a manual submission URL as fallback.

---

## Example

**Report a bug from the current session**:
```
/qa-issue-report
```
The skill scans the conversation and suggests: "It looks like authentication fails after token refresh. Report this?" You approve, and it pre-fills steps to reproduce from the session timeline.

**Report to a specific repo with attachments**:
```
/qa-issue-report "Login button unresponsive on mobile" --repo myorg/frontend --type bug --attach screenshot.png
```

**Feature request with labels**:
```
/qa-issue-report "Add dark mode support" --type feature --label enhancement,ui
```

---

## Environment Detection

The skill auto-collects environment info without asking:

| Detected From | Info Collected |
|---------------|----------------|
| `package.json` | Node.js version |
| `requirements.txt` / `pyproject.toml` | Python version |
| `go.mod` | Go version |
| `Cargo.toml` | Rust version |
| `composer.json` | PHP version |
| `Gemfile` | Ruby version |
| System | OS type, architecture, current branch |

Only detected items appear in the issue.

---

## Tips

- Invoke mid-session right after hitting a problem for the best auto-draft
- Use `--repo` when working across multiple repositories to target the right one
- The skill creates missing labels automatically on both GitHub and GitLab
- Issue titles and bodies are always written in English regardless of conversation language
- The HARD STOP preview lets you review and edit before anything is saved or submitted
- Pair with session context: describe the problem in conversation first, then invoke the skill

---

[Back to QA Skills](README.md) | [Back to All Skills](../README.md)
