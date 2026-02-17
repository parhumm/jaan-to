---
title: "GitLab Support"
sidebar_position: 23
---

# GitLab Support

> Phase 6 | Status: pending

## Problem

jaan.to currently only supports GitHub via `gh` CLI. Teams using GitLab cannot use skills that interact with version control, CI/CD, or issue tracking. This excludes a significant portion of enterprise teams.

## Solution

Add first-class GitLab support across three integration levels:

1. **`glab` CLI** — GitLab CLI tool (mirrors `gh` patterns)
2. **GitLab MCP** — MCP connector for GitLab API (richer access)
3. **GitLab App** — Webhook-based integration for automated workflows (future)

### Platform Detection

Auto-detect platform from git remote URL:
```
github.com  → use `gh` CLI
gitlab.com  → use `glab` CLI
*.gitlab.*  → use `glab` CLI (self-hosted)
```

### CLI Command Mapping

| Operation | GitHub (`gh`) | GitLab (`glab`) |
|-----------|--------------|-----------------|
| PR/MR diff | `gh pr diff {n}` | `glab mr diff {n}` |
| PR/MR view | `gh pr view {n}` | `glab mr view {n}` |
| PR/MR create | `gh pr create` | `glab mr create` |
| PR/MR comment | `gh pr comment` | `glab mr note` |
| Issue view | `gh issue view` | `glab issue view` |
| Issue create | `gh issue create` | `glab issue create` |
| Release create | `gh release create` | `glab release create` |

## Scope

**In-scope:**
- Platform auto-detection from git remote
- `glab` CLI integration for merge request operations
- Update all `gh`-using skills to support `glab` equivalent
- Documentation for GitLab setup

**Out-of-scope:**
- GitLab App (webhook automation) — future Phase 7
- GitLab MCP connector — Phase 7
- Bitbucket support
- Azure DevOps support

## Implementation Steps

1. Create platform detection utility:
   - Parse `git remote get-url origin`
   - Determine `github` vs `gitlab` vs `unknown`
   - Make available as shell function in `scripts/lib/platform-detect.sh`
2. Abstract VCS operations:
   - Create `scripts/lib/vcs-ops.sh` with platform-agnostic functions
   - `vcs_pr_diff`, `vcs_pr_view`, `vcs_pr_create`, `vcs_pr_comment`
   - `vcs_issue_view`, `vcs_issue_create`
   - Each function dispatches to `gh` or `glab` based on detected platform
3. Update skills that use `gh` CLI:
   - `/backend-pr-review` — merge request review via `glab mr diff`
   - `/frontend-pr-review` (new, #125) — same
   - `/wp-pr-review` — same
   - `/jaan-issue-report` — issue creation via `glab issue create`
   - `/release-iterate-changelog` — release integration
   - `/devops-deploy-activate` — CI/CD pipeline awareness
4. Update skill `allowed-tools` to include `glab` commands:
   - Add `Bash(glab mr:*)`, `Bash(glab issue:*)` alongside existing `gh` permissions
5. Add GitLab CI/CD awareness to `/devops-deploy-activate`:
   - Detect `.gitlab-ci.yml` vs `.github/workflows/`
   - Generate GitLab CI pipeline configs alongside GitHub Actions
6. Document setup: `docs/guides/gitlab-setup.md`

## Skills Affected

- `/backend-pr-review` — add `glab mr diff` support
- `/frontend-pr-review` (new, #125) — build with GitLab from start
- `/wp-pr-review` — add `glab mr` support
- `/jaan-issue-report` — add `glab issue` support
- `/release-iterate-changelog` — add GitLab release support
- `/devops-deploy-activate` — add `.gitlab-ci.yml` support
- `/devops-infra-scaffold` — add GitLab CI template generation
- `/jaan-issue-review` (meta-skill) — add `glab` branching support

## Acceptance Criteria

- [ ] Platform auto-detection from git remote URL
- [ ] `glab` CLI integration for merge request operations
- [ ] PR review skills work with GitLab merge requests
- [ ] Issue creation works with GitLab issues
- [ ] GitLab CI/CD pipeline awareness in DevOps skills
- [ ] Platform detection utility in `scripts/lib/platform-detect.sh`
- [ ] VCS abstraction layer in `scripts/lib/vcs-ops.sh`
- [ ] Documentation for GitLab setup

## Dependencies

- `glab` CLI installed on user's system
- Skills that use `gh` must be updated (6+ skills)
- `/frontend-pr-review` (#125) should be built with GitLab support from the start

## References

- [#132](https://github.com/parhumm/jaan-to/issues/132)
- `glab` CLI: https://gitlab.com/gitlab-org/cli
- Phase 7 MCP connectors: `docs/roadmap/tasks/mcp-connectors.md`
- Skills using `gh`: `backend-pr-review`, `wp-pr-review`, `jaan-issue-report`, `release-iterate-changelog`
