# Integrations

> External tool configurations - skills read this to understand your tool ecosystem

**TIP**: Run `/jaan-to:detect-dev` to audit source control and CI/CD integrations, or `/jaan-to:pack-detect` for a full repo analysis.

---

## Issue Tracking

| Setting | Value |
|---------|-------|
| Tool | {Jira/Linear/GitHub Issues} |
| Project | {project key} |
| Board | {board name} |
| Default Labels | {labels} |
| Link Format | {url pattern} |

## Source Control

| Setting | Value |
|---------|-------|
| Tool | {GitLab/GitHub/Bitbucket} |
| Organization | {org name} |
| Main Branch | {branch name} |
| MR/PR Template | {path} |
| Branch Naming | {pattern} |

## Communication

| Channel | Purpose | Handle |
|---------|---------|--------|
| Releases | {purpose} | {#channel} |
| Alerts | {purpose} | {#channel} |
| Team | {purpose} | {#channel} |

## Analytics

| Tool | Purpose | Access |
|------|---------|--------|
| {tool} | {purpose} | {who has access} |

## Design

| Tool | Purpose | Notes |
|------|---------|-------|
| {tool} | {purpose} | {notes} |

## API Quirks

> Integration-specific behaviors that affect skill outputs

- {quirk 1}
- {quirk 2}

---

## Example (delete after filling in)

```markdown
## Issue Tracking

| Setting | Value |
|---------|-------|
| Tool | Jira |
| Project | ACME |
| Board | Sprint Board |
| Default Labels | from-jaan-to, needs-review |
| Link Format | https://acme.atlassian.net/browse/{key} |

## Source Control

| Setting | Value |
|---------|-------|
| Tool | GitLab |
| Organization | acme/backend |
| Main Branch | main |
| MR/PR Template | .gitlab/merge_request_templates/default.md |
| Branch Naming | {type}/{ticket}-{description} |

## Communication

| Channel | Purpose | Handle |
|---------|---------|--------|
| Releases | Release announcements | #releases |
| Alerts | Production issues | #engineering-alerts |
| Team | Daily coordination | #team-backend |

## Analytics

| Tool | Purpose | Access |
|------|---------|--------|
| GA4 | Web analytics | Product, Engineering |
| Mixpanel | Event tracking | Product |
| Datadog | APM metrics | Engineering |

## Design

| Tool | Purpose | Notes |
|------|---------|-------|
| Figma | UI designs | Team workspace |
| Storybook | Component library | Deployed to Vercel |

## API Quirks

- Jira API rate limits at 100 req/min - batch updates
- GitLab MR approvals reset on force push
- Slack webhooks timeout after 3s - use async
```
