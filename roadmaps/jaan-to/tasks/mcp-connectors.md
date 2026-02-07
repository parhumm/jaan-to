# MCP Connectors

> Phase 5 | Status: pending | 24 MCPs (11 core + 13 extended)

## Overview

MCP (Model Context Protocol) connectors provide real system context to skills. Skills stay generic while MCP provides per-product context from actual tools.

**Research source**: Analysis of [role-skills.md](role-skills.md) dependencies.

---

## Priority Order (by skill enablement)

### Tier 1: High Impact (20+ skills enabled)

#### 1. GA4 MCP

- **Skills Enabled**: 12
- **Roles**: PM, DATA, GROWTH, UX
- **Capabilities**: Metrics, funnels, cohorts, anomaly detection, baselines
- **Skills**:
  - `/pm-north-star` - baseline data
  - `/pm-release-review` - KPI deltas
  - `/data-event-spec` - measurement alignment
  - `/data-metric-spec` - dimension/metric checks
  - `/data-funnel-review` - funnel analysis
  - `/data-experiment-design` - baseline + segments
  - `/data-anomaly-triage` - anomaly detection
  - `/data-cohort-analyze` - cohort data
  - `/growth-weekly-report` - traffic deltas
  - `/growth-content-optimize` - engagement data
  - `/ux-heuristic-review` - behavior evidence (with Clarity)
  - `/ux-competitive-review` - validate assumptions

#### 2. GitLab MCP

- **Skills Enabled**: 9
- **Roles**: DEV, QA
- **Capabilities**: MRs, pipelines, code context, release branches
- **Skills**:
  - `/dev-tech-plan` - modules/flags
  - `/dev-test-plan` - diff impact
  - `/dev-pr-review` - MR + pipeline
  - `/dev-ship-check` - pipelines health
  - `/dev-docs-generate` - code context
  - `/qa-test-matrix` - impacted areas
  - `/qa-automation-plan` - automation MRs
  - `/qa-regression-runbook` - release branch
  - `/qa-release-signoff` - pipeline status

### Tier 2: Medium Impact (5-6 skills enabled)

#### 3. Jira MCP

- **Skills Enabled**: 6
- **Roles**: PM, QA
- **Capabilities**: Backlog, bugs, user stories, issue tracking
- **Skills**:
  - `/pm-scope-slice` - backlog context
  - `/pm-story-write` - backlog context
  - `/qa-bug-triage` - bug list
  - `/qa-test-cases` - user story context
  - `/qa-bug-report` - duplicate detection
  - `/qa-release-signoff` - test evidence

#### 4. Figma MCP

- **Skills Enabled**: 6
- **Roles**: UX, QA, DEV
- **Capabilities**: Designs, flows, components, states
- **Skills**:
  - `/dev-tech-plan` - optional constraints
  - `/qa-test-matrix` - flow-states
  - `/ux-flow-spec` - flow/state extraction
  - `/ux-microcopy-write` - components + strings
  - `/ux-research-plan` - flow context
  - `/ux-heuristic-review` - screens

#### 5. GSC MCP (Google Search Console)

- **Skills Enabled**: 5
- **Roles**: GROWTH
- **Capabilities**: Queries, pages, CTR, impressions, indexability
- **Skills**:
  - `/growth-content-outline` - opportunity pages + queries
  - `/growth-keyword-brief` - queries/pages
  - `/growth-seo-audit` - page CTR/impressions
  - `/growth-seo-check` - coverage/index diagnostics
  - `/growth-weekly-report` - traffic deltas

#### 6. Clarity MCP (Microsoft Clarity)

- **Skills Enabled**: 5
- **Roles**: PM, UX, DATA
- **Capabilities**: Session recordings, heatmaps, behavior signals
- **Skills**:
  - `/pm-decision-brief` - optional evidence
  - `/pm-release-review` - UX regressions
  - `/data-funnel-review` - qualitative insights
  - `/ux-research-plan` - pain signals
  - `/ux-heuristic-review` - behavior evidence

### Tier 3: Targeted Impact (2-4 skills enabled)

#### 7. Sentry MCP

- **Skills Enabled**: 4
- **Roles**: DEV, QA, DATA
- **Capabilities**: Error tracking, stack traces, health monitoring
- **Skills**:
  - `/dev-pr-review` - optional regressions
  - `/dev-ship-check` - health status
  - `/qa-bug-triage` - optional context
  - `/data-anomaly-triage` - error correlation

#### 8. BigQuery MCP

- **Skills Enabled**: 2
- **Roles**: DATA
- **Capabilities**: Advanced SQL, window functions, large datasets
- **Skills**:
  - `/data-cohort-analyze` - optional advanced queries
  - `/data-dbt-model` - schema context

#### 9. Playwright MCP

- **Skills Enabled**: 2
- **Roles**: QA
- **Capabilities**: Test automation direction, reliability
- **Skills**:
  - `/qa-automation-plan` - automation direction
  - `/qa-regression-runbook` - optional automation

### Tier 4: Single Skill (1 skill enabled)

#### 10. OpenAPI/Swagger MCP

- **Skills Enabled**: 1
- **Roles**: DEV
- **Capabilities**: API contract validation, schema generation
- **Skills**:
  - `/dev-api-contract` - contract generation

#### 11. dbt Cloud MCP

- **Skills Enabled**: 1
- **Roles**: DATA
- **Capabilities**: Model management, test results, documentation
- **Skills**:
  - `/data-dbt-model` - optional cloud integration

---

## Extended MCPs (from Research Report)

> Source: [MCP Servers by Role Report](https://modelcontextprotocol.io/) - January 2026

### Cross-Role High Impact

#### 12. Notion MCP (Official)

- **Skills Enabled**: 5+
- **Roles**: PM, UX, All
- **Pricing**: Free with Notion subscription
- **Capabilities**: Create pages, search workspace, manage databases, unified search
- **Skills**:
  - `/jaan-to:pm-prd-write` - PRD storage and templates
  - `/jaan-to:pm-north-star` - OKR tracking
  - `/jaan-to:ux-research-synthesize` - Research documentation
  - `/jaan-to:ux-persona-create` - Persona storage
  - All roles - Knowledge base access
- **Setup**: ⭐ Easy - OAuth one-click

#### 13. Slack MCP (Official)

- **Skills Enabled**: 3+
- **Roles**: All
- **Pricing**: Free with Slack subscription
- **Capabilities**: Search messages, post updates, channel management
- **Skills**:
  - `/pm-feedback-synthesize` - Feedback channel mining
  - `/pm-release-review` - Stakeholder notifications
  - All roles - Team communication context
- **Setup**: ⭐ Easy - OAuth one-click

#### 14. GitHub MCP (Official)

- **Skills Enabled**: 9 (GitLab alternative)
- **Roles**: DEV, QA
- **Pricing**: Free with GitHub account
- **Capabilities**: Repo management, PR operations, issue tracking, code search, file operations
- **Skills**:
  - `/dev-pr-review` - PR + CI status
  - `/dev-ship-check` - Actions health
  - `/dev-docs-generate` - Code context
  - `/qa-automation-plan` - Automation PRs
  - `/qa-regression-runbook` - Release branch
- **Setup**: ⭐ Easy - OAuth or PAT

### Role-Specific Medium Impact

#### 15. Linear MCP (Official)

- **Skills Enabled**: 6 (Jira alternative)
- **Roles**: PM, QA
- **Pricing**: Free with Linear subscription
- **Capabilities**: Issue CRUD, project management, cycle tracking, comments
- **Skills**:
  - `/pm-scope-slice` - Backlog context
  - `/pm-story-write` - Issue creation
  - `/qa-bug-triage` - Bug tracking
  - `/qa-bug-report` - Duplicate detection
- **Setup**: ⭐ Easy - OAuth
- **Note**: Modern teams alternative to Jira

#### 16. Mixpanel MCP (Official)

- **Skills Enabled**: 6
- **Roles**: PM, DATA
- **Pricing**: Free with Mixpanel account
- **Capabilities**: Segmentation, funnels, retention, event discovery, anomaly detection, session replay
- **Skills**:
  - `/pm-north-star` - Metric tracking
  - `/data-funnel-review` - Funnel analysis
  - `/data-cohort-analyze` - Retention analysis
  - `/data-anomaly-triage` - Anomaly detection
  - `/data-experiment-design` - A/B test analysis
- **Setup**: ⭐ Easy - OAuth remote connection
- **Note**: Best-supported official product analytics MCP

#### 17. Confluence MCP

- **Skills Enabled**: 3
- **Roles**: PM, DEV
- **Pricing**: Free with Confluence subscription
- **Capabilities**: Page creation, search, documentation management
- **Skills**:
  - `/jaan-to:pm-prd-write` - PRD storage
  - `/jaan-to:dev-docs-generate` - Technical documentation
  - `/jaan-to:pm-release-review` - Release notes
- **Setup**: ⭐⭐ Medium - API token required

### Targeted Impact

#### 18. Snowflake MCP (Official)

- **Skills Enabled**: 3 (BigQuery alternative)
- **Roles**: DATA
- **Pricing**: Freemium ($400 credits free)
- **Capabilities**: Cortex AI, SQL execution, semantic views, object management
- **Skills**:
  - `/data-sql-query` - Advanced SQL
  - `/data-cohort-analyze` - Large dataset analysis
  - `/data-dbt-model` - Schema context
- **Setup**: ⭐⭐⭐ Medium-Hard - Auth config, role setup
- **Note**: Enterprise data warehouse with AI features

#### 19. PostgreSQL MCP (Reference)

- **Skills Enabled**: 2
- **Roles**: DATA
- **Pricing**: Free (open-source)
- **Capabilities**: SQL queries, schema exploration
- **Skills**:
  - `/data-sql-query` - Direct database queries
  - `/data-metric-spec` - Schema validation
- **Setup**: ⭐⭐ Medium - Connection string

#### 20. Ahrefs MCP

- **Skills Enabled**: 3
- **Roles**: GROWTH
- **Pricing**: Free server; Ahrefs API from $99/mo
- **Capabilities**: Backlink analysis, keyword research, traffic analysis
- **Skills**:
  - `/growth-keyword-brief` - Keyword research
  - `/growth-content-outline` - Content opportunities
  - `/growth-seo-audit` - Backlink analysis
- **Setup**: ⭐⭐ Medium - API key required

#### 21. Semrush MCP

- **Skills Enabled**: 3
- **Roles**: GROWTH
- **Pricing**: Free server; Semrush plan from $139/mo
- **Capabilities**: Domain analytics, keyword metrics, competitor research
- **Skills**:
  - `/growth-keyword-brief` - Keyword metrics
  - `/growth-content-outline` - Competitor content gaps
  - `/ux-competitive-review` - Competitor analysis
- **Setup**: ⭐⭐ Medium - API key required

#### 22. LambdaTest MCP

- **Skills Enabled**: 2
- **Roles**: QA
- **Pricing**: Freemium (limited); Paid from $15/mo
- **Capabilities**: Cross-browser testing, SmartUI, accessibility testing
- **Skills**:
  - `/qa-test-matrix` - Cross-browser coverage
  - `/qa-automation-plan` - Browser automation strategy
- **Setup**: ⭐⭐ Medium - API key, cloud connection

### Supporting Infrastructure

#### 23. Google Drive MCP

- **Skills Enabled**: 2+
- **Roles**: All
- **Pricing**: Free (open-source)
- **Capabilities**: Access research files, recordings, docs
- **Skills**:
  - `/ux-research-synthesize` - Research file access
  - `/pm-feedback-synthesize` - Document mining
- **Setup**: ⭐⭐ Medium - OAuth setup

#### 24. Memory MCP (Reference)

- **Skills Enabled**: All
- **Roles**: All
- **Pricing**: Free (Anthropic reference)
- **Capabilities**: Persistent context across sessions
- **Skills**:
  - All skills - Context preservation
  - Learning retention across conversations
- **Setup**: ⭐ Easy - Local storage

---

## Implementation Notes

### Deferred Loading

Use `defer_loading: true` for 85% token savings on initialization:

```json
{
  "mcpServers": {
    "ga4": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-ga4"],
      "defer_loading": true
    }
  }
}
```

### Skill Integration Pattern

```markdown
## MCP Context
- GA4: Pull baseline metrics for [initiative]
- Jira: Check existing related tickets
- Figma: Read linked design frames
```

Skills request context, MCP provides real data. No hallucinating file structures.

---

## Acceptance Criteria

- [x] All 24 MCPs documented with configuration
- [ ] Core Tier 1 MCPs (GA4, GitLab) working
- [ ] Core Tier 2 MCPs (Jira, Figma, GSC, Clarity) working
- [ ] Extended cross-role MCPs (Notion, Slack, GitHub) working
- [ ] Deferred loading implemented
- [ ] Skills can read real context from connected systems

## Dependencies

- Phase 2.5 complete (Documentation & Tooling)
- MCP server packages available

## References

- [MCP Documentation](https://modelcontextprotocol.io/)
- [vision.md](../vision.md) - MCP philosophy section
- [role-skills.md](role-skills.md) - Skill MCP requirements
