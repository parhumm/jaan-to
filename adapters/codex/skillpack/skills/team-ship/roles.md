# Role Definitions for Agent Teams

> Data file read by team-ship orchestrator. NOT loaded in system prompt.
> Add new roles here — the orchestrator picks them up automatically.

## Format

Each role section defines:
- **Title**: Human-readable role name
- **Track**: Which tracks include this role (fast, full, or both)
- **Model**: AI model for teammate (inherit = use lead's model)
- **Skills**: Ordered skill chains per track
- **Phase**: Pipeline phase (1=define, 2=design+build, 3=ship+quality)
- **Depends on**: What inputs this role needs before starting
- **Outputs to share**: File paths this role produces for other roles
- **Messages**: Which teammates to notify and when
- **Shutdown after**: When to release this teammate's context

---

## pm

- **Title**: Product Manager
- **Track**: fast, full
- **Model**: inherit
- **Skills**: [pm-research-about, pm-prd-write, pm-story-write, pm-roadmap-add]
- **Phase**: 1 (define)
- **Depends on**: user-input
- **Outputs to share**: prd_path, stories_path
- **Messages**: Lead (PRD ready for approval)
- **Shutdown after**: Phase 1

## ux

- **Title**: UX Designer
- **Track**: full
- **Model**: sonnet
- **Skills**: [ux-flowchart-generate, ux-microcopy-write]
- **Phase**: 2 (design)
- **Depends on**: prd_path
- **Outputs to share**: flowchart_paths, microcopy_paths
- **Messages**: Frontend (flowcharts ready)
- **Shutdown after**: Phase 2

## backend

- **Title**: Backend Engineer
- **Track**: fast, full
- **Model**: sonnet
- **Skills**:
  - fast: [dev-docs-fetch, backend-task-breakdown, backend-scaffold]
  - full: [dev-docs-fetch, backend-task-breakdown, backend-data-model, backend-api-contract, backend-scaffold, backend-service-implement]
- **Phase**: 2 (design+build)
- **Depends on**: prd_path
- **Outputs to share**: api_contract_path, scaffold_path
- **Messages**: Frontend (api-contract ready), QA (scaffold ready)
- **Shutdown after**: Phase 2

## frontend

- **Title**: Frontend Engineer
- **Track**: fast, full
- **Model**: sonnet
- **Skills**:
  - fast: [dev-docs-fetch, frontend-scaffold]
  - full: [dev-docs-fetch, frontend-task-breakdown, frontend-scaffold, frontend-design]
- **Phase**: 2 (design+build)
- **Depends on**: prd_path, api_contract_path (from backend)
- **Outputs to share**: scaffold_path
- **Messages**: QA (scaffold ready)
- **Shutdown after**: Phase 2

## qa

- **Title**: QA Engineer
- **Track**: fast, full
- **Model**: sonnet
- **Skills**:
  - fast: [qa-test-generate, qa-test-run, qa-issue-validate]
  - full: [qa-test-cases, qa-test-generate, qa-test-run, qa-issue-validate]
- **Phase**: 2 (test-cases) + 3 (test-gen/run after integration)
- **Depends on**: prd_path, scaffold_paths (from backend + frontend)
- **Outputs to share**: test_results_path
- **Messages**: Lead (tests pass/fail)
- **Shutdown after**: Phase 3

## devops

- **Title**: DevOps Engineer
- **Track**: fast, full
- **Model**: sonnet
- **Skills**: [devops-infra-scaffold, devops-deploy-activate]
- **Phase**: 3 (ship)
- **Depends on**: integrated_code
- **Outputs to share**: infra_paths
- **Messages**: Lead (infra ready)
- **Shutdown after**: Phase 3

## security

- **Title**: Security Engineer
- **Track**: full
- **Model**: sonnet
- **Skills**: [sec-audit-remediate]
- **Phase**: 3 (quality)
- **Depends on**: integrated_code
- **Outputs to share**: audit_path
- **Messages**: Lead (audit complete)
- **Shutdown after**: Phase 3

---

## Detect Roles (--detect mode)

## detect-dev

- **Title**: Engineering Auditor
- **Track**: detect
- **Model**: haiku
- **Skills**: [detect-dev]
- **Phase**: 1
- **Depends on**: repo
- **Outputs to share**: detect_dev_path
- **Shutdown after**: Phase 1

## detect-design

- **Title**: Design Auditor
- **Track**: detect
- **Model**: haiku
- **Skills**: [detect-design]
- **Phase**: 1
- **Depends on**: repo
- **Outputs to share**: detect_design_path
- **Shutdown after**: Phase 1

## detect-ux

- **Title**: UX Auditor
- **Track**: detect
- **Model**: haiku
- **Skills**: [detect-ux]
- **Phase**: 1
- **Depends on**: repo
- **Outputs to share**: detect_ux_path
- **Shutdown after**: Phase 1

## detect-writing

- **Title**: Writing Auditor
- **Track**: detect
- **Model**: haiku
- **Skills**: [detect-writing]
- **Phase**: 1
- **Depends on**: repo
- **Outputs to share**: detect_writing_path
- **Shutdown after**: Phase 1

## detect-product

- **Title**: Product Auditor
- **Track**: detect
- **Model**: haiku
- **Skills**: [detect-product]
- **Phase**: 1
- **Depends on**: repo
- **Outputs to share**: detect_product_path
- **Shutdown after**: Phase 1

---

## Future Roles (add when skills ship)

<!--
## data
- **Title**: Data Analyst
- **Track**: full
- **Model**: sonnet
- **Skills**: [data-event-spec, data-gtm-datalayer, data-experiment-design]
- **Phase**: 3
- **Depends on**: prd_path, measurement_plan

## growth
- **Title**: Growth Marketer
- **Track**: full
- **Model**: sonnet
- **Skills**: [growth-launch-announcement, growth-meta-write, growth-content-optimize]
- **Phase**: 3
- **Depends on**: prd_path, live_product

## delivery
- **Title**: Delivery Manager
- **Track**: full
- **Model**: sonnet
- **Skills**: [delivery-release-readiness, delivery-plan-milestones]
- **Phase**: 3
- **Depends on**: all_outputs

## sre
- **Title**: Site Reliability Engineer
- **Track**: full
- **Model**: sonnet
- **Skills**: [sre-slo-setup, sre-alert-tuning]
- **Phase**: 3
- **Depends on**: deployed_infra

## support
- **Title**: Support Engineer
- **Track**: full
- **Model**: haiku
- **Skills**: [support-help-article, support-launch-monitor]
- **Phase**: 3
- **Depends on**: live_product

## release
- **Title**: Release Manager
- **Track**: full
- **Model**: sonnet
- **Skills**: [release-prod-runbook, release-beta-rollout-plan]
- **Phase**: 3
- **Depends on**: qa_signoff
-->
