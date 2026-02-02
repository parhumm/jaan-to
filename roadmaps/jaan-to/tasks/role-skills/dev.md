# DEV Skills (17)

> Part of [Role Skills Catalog](../role-skills.md) | Phase 4 + Phase 6

**Chains**: Discovery → Architecture → BE → API → FE → Integration → Test → Observability → Ship

## Userflow Schema

```mermaid
flowchart TD
    jaan-to-dev-feasibility-check["Feasibility Check\nRisks + deps + complexity"] --> jaan-to-dev-arch-proposal["Arch Proposal\nArchitecture + tradeoffs + data flow"]
    jaan-to-dev-arch-proposal --> jaan-to-dev-tech-plan["Tech Plan\nApproach + rollout/rollback"]
    jaan-to-dev-tech-plan --> jaan-to-dev-be-task-breakdown["BE Task Breakdown\nBE tasks + data model notes"]
    jaan-to-dev-tech-plan --> jaan-to-dev-fe-task-breakdown["FE Task Breakdown\nFE tasks + estimates + risks"]
    jaan-to-dev-be-task-breakdown --> jaan-to-dev-be-data-model["BE Data Model\nTables + constraints + indexes"]
    jaan-to-dev-be-data-model --> jaan-to-dev-api-contract["API Contract\nOpenAPI + payloads + errors"]
    jaan-to-dev-api-contract --> jaan-to-dev-api-versioning["API Versioning\nCompatibility + deprecation plan"]
    jaan-to-dev-api-versioning --> jaan-to-dev-docs-generate["Docs Generate\nREADME + API docs + runbooks"]
    jaan-to-dev-api-contract --> jaan-to-dev-docs-generate
    jaan-to-dev-fe-task-breakdown --> jaan-to-dev-fe-state-machine["FE State Machine\nUI states + transitions"]
    jaan-to-dev-fe-state-machine --> jaan-to-dev-test-plan["Test Plan\nUnit/integration/e2e scope"]
    jaan-to-dev-integration-plan["Integration Plan\nAPI sequence + retry + failures"] --> jaan-to-dev-integration-mock-stubs["Integration Mock Stubs\nStub interfaces + fake responses"]
    jaan-to-dev-integration-mock-stubs --> jaan-to-dev-test-plan
    jaan-to-dev-test-plan -.-> jaan-to-qa-test-cases["QA: test-cases"]
    jaan-to-dev-observability-events["Observability Events\nLog fields + metrics + traces"] --> jaan-to-dev-observability-alerts["Observability Alerts\nThresholds + severity + noise"]
    jaan-to-dev-observability-alerts -.-> jaan-to-sre-slo-setup["SRE: slo-setup"]
    jaan-to-dev-ship-check["Ship Check\nFlags + migrations + Go/No-Go"] -.-> jaan-to-release-prod-runbook["RELEASE: prod-runbook"]
    jaan-to-dev-ship-check -.-> jaan-to-qa-release-signoff["QA: release-signoff"]

    style jaan-to-qa-test-cases fill:#f0f0f0,stroke:#999
    style jaan-to-sre-slo-setup fill:#f0f0f0,stroke:#999
    style jaan-to-release-prod-runbook fill:#f0f0f0,stroke:#999
    style jaan-to-qa-release-signoff fill:#f0f0f0,stroke:#999
```

**Legend**: Solid = internal | Dashed = cross-role exit | Gray nodes = other roles

### /jaan-to-dev-feasibility-check

- **Logical**: `dev:feasibility-check`
- **Description**: Risks + dependencies, unknowns + spike recommendations, rough complexity estimate
- **Quick Win**: Yes
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `dev-arch-proposal`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/dev/discovery/{slug}/feasibility-check.md`

### /jaan-to-dev-arch-proposal

- **Logical**: `dev:arch-proposal`
- **Description**: Architecture outline, key choices + tradeoffs, data flow + failure modes
- **Quick Win**: Yes
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `dev-tech-plan`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/dev/discovery/{slug}/arch-proposal.md`

### /jaan-to-dev-tech-plan

- **Logical**: `dev:tech-plan`
- **Description**: Tech approach with architecture, tradeoffs, risks, rollout/rollback, unknowns
- **Quick Win**: Yes - extends existing pattern
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `dev-fe-task-breakdown`, `dev-be-task-breakdown`
- **MCP Required**: GitLab (modules/flags), Figma (optional constraints)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/plan/{slug}/tech-plan.md`

### /jaan-to-dev-be-task-breakdown

- **Logical**: `dev:be-task-breakdown`
- **Description**: BE tasks list, data model notes, reliability considerations
- **Quick Win**: Yes
- **Key Points**:
  - Data model constraints first (unique, indexes, retention)
  - Idempotency + retries for safety
  - Clear error taxonomy
- **→ Next**: `dev-be-data-model`
- **MCP Required**: None
- **Input**: [prd]
- **Output**: `jaan-to/outputs/dev/backend/{slug}/task-breakdown.md`

### /jaan-to-dev-be-data-model

- **Logical**: `dev:be-data-model`
- **Description**: Tables/collections + fields, constraints + indexes, retention + migration notes
- **Quick Win**: Yes
- **Key Points**:
  - Data model constraints first (unique, indexes, retention)
  - Idempotency + retries for safety
  - Clear error taxonomy
- **→ Next**: `dev-api-contract`
- **MCP Required**: None
- **Input**: [entities]
- **Output**: `jaan-to/outputs/dev/backend/{slug}/data-model.md`

### /jaan-to-dev-api-contract

- **Logical**: `dev:api-contract`
- **Description**: OpenAPI contract with payloads, errors, versioning, example requests/responses
- **Quick Win**: No - needs OpenAPI MCP
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: `dev-api-versioning`, `dev-docs-generate`
- **MCP Required**: OpenAPI/Swagger, Postman (optional)
- **Input**: [entities]
- **Output**: `jaan-to/outputs/dev/contract/{slug}/api.yaml`

### /jaan-to-dev-api-versioning

- **Logical**: `dev:api-versioning`
- **Description**: Compatibility strategy, migration notes + timeline, deprecation communication plan
- **Quick Win**: Yes
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: `dev-docs-generate`
- **MCP Required**: None
- **Input**: [api]
- **Output**: `jaan-to/outputs/dev/contract/{slug}/versioning-plan.md`

### /jaan-to-dev-fe-task-breakdown

- **Logical**: `dev:fe-task-breakdown`
- **Description**: FE tasks list (components, screens, states), estimate bands, risks + dependencies
- **Quick Win**: Yes
- **Key Points**:
  - Explicit state machine prevents "UI glitches"
  - Define caching/loading strategies
  - Performance budgets where needed
- **→ Next**: `dev-fe-state-machine`
- **MCP Required**: None
- **Input**: [ux-handoff]
- **Output**: `jaan-to/outputs/dev/frontend/{slug}/task-breakdown.md`

### /jaan-to-dev-fe-state-machine

- **Logical**: `dev:fe-state-machine`
- **Description**: UI states + transitions, events that trigger transitions, edge-case behavior
- **Quick Win**: Yes
- **Key Points**:
  - Explicit state machine prevents "UI glitches"
  - Define caching/loading strategies
  - Performance budgets where needed
- **→ Next**: `dev-test-plan`
- **MCP Required**: None
- **Input**: [screen]
- **Output**: `jaan-to/outputs/dev/frontend/{slug}/state-machine.md`

### /jaan-to-dev-integration-plan

- **Logical**: `dev:integration-plan`
- **Description**: API call sequence, retry policy + failure modes, observability events
- **Quick Win**: Yes
- **Key Points**:
  - Define retries + backoff + idempotency
  - Plan for partial failures and timeouts
  - Provide mocks/stubs for local dev
- **→ Next**: `dev-integration-mock-stubs`
- **MCP Required**: None
- **Input**: [provider] [use-case]
- **Output**: `jaan-to/outputs/dev/integration/{slug}/integration-plan.md`

### /jaan-to-dev-integration-mock-stubs

- **Logical**: `dev:integration-mock-stubs`
- **Description**: Stub interfaces, fake responses (success/fail), test harness guidance
- **Quick Win**: Yes
- **Key Points**:
  - Define retries + backoff + idempotency
  - Plan for partial failures and timeouts
  - Provide mocks/stubs for local dev
- **→ Next**: `dev-test-plan`
- **MCP Required**: None
- **Input**: [provider]
- **Output**: `jaan-to/outputs/dev/integration/{slug}/mock-stubs.md`

### /jaan-to-dev-test-plan

- **Logical**: `dev:test-plan`
- **Description**: Dev-owned test plan: unit/integration/e2e scope, fixtures, mocks, highest-risk scenarios
- **Quick Win**: Yes - simple test plan
- **Key Points**:
  - Identify dependencies and "unknown unknowns"
  - Call out risky assumptions early
  - Produce options, not just one path
- **→ Next**: `qa-test-cases`
- **MCP Required**: GitLab (diff impact)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/test/{slug}/test-plan.md`

### /jaan-to-dev-observability-events

- **Logical**: `dev:observability-events`
- **Description**: Log fields + metric names, trace spans suggestions, dashboard checklist
- **Quick Win**: Yes
- **Key Points**:
  - Define structured logs and consistent fields
  - Metrics for latency/error/throughput
  - Alerts should map to user impact
- **→ Next**: `dev-observability-alerts`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `jaan-to/outputs/dev/observability/{slug}/events.md`

### /jaan-to-dev-observability-alerts

- **Logical**: `dev:observability-alerts`
- **Description**: Suggested alerts + thresholds, severity levels, noise reduction ideas
- **Quick Win**: Yes
- **Key Points**:
  - Define structured logs and consistent fields
  - Metrics for latency/error/throughput
  - Alerts should map to user impact
- **→ Next**: `sre-slo-setup`
- **MCP Required**: None
- **Input**: [service]
- **Output**: `jaan-to/outputs/dev/observability/{slug}/alert-rules.md`

### /jaan-to-dev-docs-generate

- **Logical**: `dev:docs-generate`
- **Description**: Technical documentation: README files, API docs, runbooks, architecture decisions
- **Quick Win**: Yes - draft generation, format standardization
- **AI Score**: 5 | **Rank**: #14
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: —
- **MCP Required**: GitLab (code context, optional)
- **Input**: [component] [doc_type]
- **Output**: `jaan-to/outputs/dev/docs/{slug}/{doc_type}.md`
- **Failure Modes**: Documentation stale; inconsistent formatting; missing context
- **Quality Gates**: Up-to-date with code; follows style guide; onboarding-friendly

### /jaan-to-dev-pr-review

- **Logical**: `dev:pr-review`
- **Description**: PR review pack: summary, risky files, security/perf hints, missing tests, CI failures
- **Quick Win**: No - needs GitLab MCP
- **Key Points**:
  - Define schemas with examples
  - Versioning + deprecation strategy
  - Ownership: who maintains, who consumes
- **→ Next**: —
- **MCP Required**: GitLab (MR + pipeline), Sentry (optional regressions)
- **Input**: [pr-link-or-branch]
- **Output**: `jaan-to/outputs/dev/review/{slug}/pr-review.md`

### /jaan-to-dev-ship-check

- **Logical**: `dev:ship-check`
- **Description**: Pre-ship checklist: flags, migrations, monitoring, rollback, Go/No-Go recommendation
- **Quick Win**: No - needs multiple MCPs
- **Key Points**:
  - Feature flags with targeting and kill switch
  - Gradual rollout with monitoring gates
  - Data migrations planned for rollback
- **→ Next**: `release-prod-runbook`, `qa-release-signoff`
- **MCP Required**: GitLab (pipelines), Sentry (health)
- **Input**: [initiative]
- **Output**: `jaan-to/outputs/dev/release/{slug}/ship-check.md`
