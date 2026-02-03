# Team Context

> Your team structure and processes - skills read this to understand how your team works

**This is a pre-configured example.** Edit sections below to match your actual team.

---

## Structure

| Role | Count | Notes |
|------|-------|-------|
| Backend Engineers | 2 | Python/FastAPI focus, 1 senior + 1 mid |
| Frontend Engineers | 2 | React specialists, both senior |
| Full-Stack Engineers | 1 | Mostly backend, some frontend |
| QA | 1 | Manual + automation, also handles Playwright tests |
| Design | 1 | Part-time (20h/week), shared with other products |
| Product | 1 | Also handles customer success, analytics |

**Team Size:** 8 people (6 eng, 1 design, 1 PM)

---

## Ceremonies

| Ceremony | Cadence | Day/Time |
|----------|---------|----------|
| Sprint Planning | Bi-weekly | Monday 10:00am PT |
| Standup | Daily | 9:30am PT (async in Slack) |
| Retro | Bi-weekly | Friday 3:00pm PT |
| Demo | Bi-weekly | Friday 2:00pm PT |
| Tech Sync | Weekly | Wednesday 2:00pm PT (eng only) |

---

## Sprint

| Setting | Value |
|---------|-------|
| Length | 2 weeks |
| Start Day | Monday (every other week) |
| Estimation | Story points (Fibonacci) |
| Scale | 1, 2, 3, 5, 8, 13 |
| Velocity | ~25 points/sprint (team avg) |

**Sprint Commitment:**
- 70% planned work (from roadmap)
- 20% bug fixes and tech debt
- 10% buffer for urgent issues

---

## Norms

> Team conventions that affect skill outputs

**Code Review:**
- All PRs need 1 approval from another engineer
- QA reviews UI changes before merge
- Design reviews UI changes >5 story points

**Documentation:**
- All PRDs need PM + Tech Lead sign-off before sprint planning
- Tech specs required for 8+ point stories
- API changes documented in Swagger before implementation

**Communication:**
- Slack for async updates
- Zoom for pair programming
- Linear for task tracking (Jira alternative)

**Testing:**
- Unit tests required for all new backend endpoints
- E2E tests required for critical user flows (login, signup, checkout)
- QA needs 2 business days notice for any release

---

## Approvals

| Type | Approvers | Timeline | Notes |
|------|-----------|----------|-------|
| PRD | PM, Tech Lead | 2-3 days | Before sprint planning |
| Tech Design | Tech Lead, Senior Dev | 1-2 days | For 8+ point stories |
| Code Review | 1 engineer | Same day | Auto-merge after approval |
| UI Changes | QA, Design | 1 day | Screenshots in PR description |
| Release | QA, PM | Day before | Go/no-go meeting Thurs 4pm |

---

## Tools

| Category | Tool | Purpose |
|----------|------|---------|
| Project Mgmt | Linear | Sprint planning, task tracking |
| Code | GitHub | Source control, code review |
| CI/CD | GitHub Actions | Build, test, deploy |
| Monitoring | DataDog | APM, logs, metrics |
| Communication | Slack | Team chat, standups |
| Design | Figma | Mockups, design system |
| Documentation | Notion | Internal docs, runbooks |

---

**Skills that read this file:**
- `/jaan-to-pm-prd-write` - References approval process and sprint cadence
- `/jaan-to-pm-story-write` - Uses story point scale for estimates
- `/jaan-to-dev-fe-task-breakdown` - References testing requirements
- `/jaan-to-dev-be-task-breakdown` - References code review and testing norms
- `/jaan-to-qa-test-cases` - Uses 2-day QA notice requirement
