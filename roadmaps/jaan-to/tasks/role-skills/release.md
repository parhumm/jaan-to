# RELEASE Skills (8)

> Part of [Role Skills Catalog](../role-skills.md) | Phase 4 + Phase 6

**Chains**: Beta Rollout → Issue Log → Triage → Hotfix | Prod Runbook → War Room | Iterate → Changelog

## Userflow Schema

```mermaid
flowchart TD
    jaan-to-release-beta-rollout-plan["/jaan-to-release-beta-rollout-plan\nBeta Rollout Plan\nPhased rollout + exit criteria"] --> jaan-to-release-beta-issue-log["/jaan-to-release-beta-issue-log\nBeta Issue Log\nCategorized issues + trends"]
    jaan-to-release-beta-issue-log["/jaan-to-release-beta-issue-log\nBeta Issue Log\nCategorized issues + trends"] --> jaan-to-release-triage-decision["/jaan-to-release-triage-decision\nTriage Decision\nFix/defer + rationale + risk"]
    jaan-to-release-beta-issue-log["/jaan-to-release-beta-issue-log\nBeta Issue Log\nCategorized issues + trends"] --> jaan-to-release-prod-runbook["/jaan-to-release-prod-runbook\nProd Runbook\nLaunch steps + rollback triggers"]
    jaan-to-release-triage-decision["/jaan-to-release-triage-decision\nTriage Decision\nFix/defer + rationale + risk"] --> jaan-to-release-triage-hotfix-scope["/jaan-to-release-triage-hotfix-scope\nTriage Hotfix Scope\nMinimal scope + test focus"]
    jaan-to-release-triage-hotfix-scope["/jaan-to-release-triage-hotfix-scope\nTriage Hotfix Scope\nMinimal scope + test focus"] -.-> jaan-to-dev-pr-review["/jaan-to-dev-pr-review\nDEV: pr-review"]
    jaan-to-release-prod-runbook["/jaan-to-release-prod-runbook\nProd Runbook\nLaunch steps + rollback triggers"] --> jaan-to-release-prod-war-room-pack["/jaan-to-release-prod-war-room-pack\nProd War Room Pack\nDashboard + roles + comms"]
    jaan-to-release-prod-war-room-pack["/jaan-to-release-prod-war-room-pack\nProd War Room Pack\nDashboard + roles + comms"] -.-> jaan-to-support-launch-monitor["/jaan-to-support-launch-monitor\nSUPPORT: launch-monitor"]
    jaan-to-release-iterate-top-fixes["/jaan-to-release-iterate-top-fixes\nIterate Top Fixes\nImprovements + prioritization"] --> jaan-to-release-iterate-changelog["/jaan-to-release-iterate-changelog\nIterate Changelog\nChangelog + user impact"]
    jaan-to-release-iterate-changelog["/jaan-to-release-iterate-changelog\nIterate Changelog\nChangelog + user impact"] -.-> jaan-to-support-help-article["/jaan-to-support-help-article\nSUPPORT: help-article"]

    style jaan-to-dev-pr-review fill:#f0f0f0,stroke:#999
    style jaan-to-support-launch-monitor fill:#f0f0f0,stroke:#999
    style jaan-to-support-help-article fill:#f0f0f0,stroke:#999
```

**Legend**: Solid = internal | Dashed = cross-role exit | Gray nodes = other roles

### /jaan-to-release-beta-rollout-plan

- **Logical**: `release:beta-rollout-plan`
- **Description**: Phased rollout plan, exit criteria per phase, targeting + monitoring notes
- **Quick Win**: Yes
- **Key Points**:
  - Phase gates + exit criteria
  - Track issues by category/owner
  - Prepare rollback triggers
- **→ Next**: `release-beta-issue-log`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/release/beta/{slug}/rollout-plan.md`

### /jaan-to-release-beta-issue-log

- **Logical**: `release:beta-issue-log`
- **Description**: Categorized issues + owners, trend summary, "stop the line" triggers
- **Quick Win**: Yes
- **Key Points**:
  - Phase gates + exit criteria
  - Track issues by category/owner
  - Prepare rollback triggers
- **→ Next**: `release-triage-decision`, `release-prod-runbook`
- **MCP Required**: None
- **Input**: [reports]
- **Output**: `jaan-to/outputs/release/beta/{slug}/issue-log.md`

### /jaan-to-release-prod-runbook

- **Logical**: `release:prod-runbook`
- **Description**: Launch steps + rollback triggers, verification checklist, dependencies + comms notes
- **Quick Win**: Yes
- **Key Points**:
  - Runbook with explicit steps
  - War room roles and timing
  - Monitoring dashboard links and thresholds
- **→ Next**: `release-prod-war-room-pack`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/release/prod/{slug}/runbook.md`

### /jaan-to-release-prod-war-room-pack

- **Logical**: `release:prod-war-room-pack`
- **Description**: Dashboard links + roles + schedule, incident comms templates, decision log structure
- **Quick Win**: Yes
- **Key Points**:
  - Runbook with explicit steps
  - War room roles and timing
  - Monitoring dashboard links and thresholds
- **→ Next**: `support-launch-monitor`
- **MCP Required**: None
- **Input**: [release]
- **Output**: `jaan-to/outputs/release/prod/{slug}/war-room-pack.md`

### /jaan-to-release-triage-decision

- **Logical**: `release:triage-decision`
- **Description**: Fix/defer decision + rationale, risk notes, suggested comms
- **Quick Win**: Yes
- **Key Points**:
  - Tie decisions to user impact and risk
  - Define minimal hotfix scope
  - Document rationale
- **→ Next**: `release-triage-hotfix-scope`
- **MCP Required**: None
- **Input**: [bug]
- **Output**: `jaan-to/outputs/release/triage/{slug}/decision.md`

### /jaan-to-release-triage-hotfix-scope

- **Logical**: `release:triage-hotfix-scope`
- **Description**: Minimal hotfix scope, test focus areas, rollback considerations
- **Quick Win**: Yes
- **Key Points**:
  - Tie decisions to user impact and risk
  - Define minimal hotfix scope
  - Document rationale
- **→ Next**: `dev-pr-review`
- **MCP Required**: None
- **Input**: [bugs]
- **Output**: `jaan-to/outputs/release/triage/{slug}/hotfix-scope.md`

### /jaan-to-release-iterate-top-fixes

- **Logical**: `release:iterate-top-fixes`
- **Description**: Next sprint improvements list, prioritization rationale, owners suggestions
- **Quick Win**: Yes
- **Key Points**:
  - Prioritize by impact + confidence
  - Keep changelog user-facing
  - Track whether fixes moved the metric
- **→ Next**: `release-iterate-changelog`
- **MCP Required**: None
- **Input**: [insights]
- **Output**: `jaan-to/outputs/release/iterate/{slug}/top-fixes.md`

### /jaan-to-release-iterate-changelog

- **Logical**: `release:iterate-changelog`
- **Description**: Changelog + user impact notes, internal notes (optional), support guidance
- **Quick Win**: Yes
- **Key Points**:
  - Prioritize by impact + confidence
  - Keep changelog user-facing
  - Track whether fixes moved the metric
- **→ Next**: `support-help-article`
- **MCP Required**: None
- **Input**: [changes]
- **Output**: `jaan-to/outputs/release/iterate/{slug}/changelog.md`
