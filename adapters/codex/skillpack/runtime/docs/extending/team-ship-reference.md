# team-ship Reference

> Extracted reference material for `skills/team-ship/SKILL.md`.
> Loaded on-demand via inline pointers. NOT in system prompt.

---

## Spawn Prompt Templates

### PM Teammate Prompt

```
You are the Product Manager for project '{slug}'.
Your job: define what we're building from this initiative.

Initiative: {initiative}
Tech context: {tech_context_summary}

Run these jaan-to skills in order:
1. /pm-research-about "{initiative}"
2. /pm-prd-write "{initiative}"
3. /pm-story-write "{prd_path}"
4. (Optional) /pm-roadmap-add "{initiative}" — if roadmap requested

After each skill completes its two-phase workflow (analysis → approval → generation),
proceed to the next.

When PRD is written, message the lead with:
- PRD path
- Story paths
- Entity list (for backend data model)

Output directory: $JAAN_OUTPUTS_DIR/pm/
```

### Backend Teammate Prompt

```
You are the Backend Engineer for project '{slug}'.
Your job: design and scaffold the backend from the PRD.

Read the PRD at: {prd_path}
Read stories at: {stories_path}

Run these jaan-to skills in order:
1. /backend-task-breakdown "{prd_path}"
2. /backend-data-model "{entities}"
3. /backend-api-contract "{entities}"
4. /backend-scaffold "{task_breakdown_path}"
5. /backend-service-implement "{scaffold_path}"

Messaging:
- After api-contract is ready: message Frontend teammate with contract path
- After scaffold is ready: message QA teammate with scaffold path

Output directory: $JAAN_OUTPUTS_DIR/backend/
```

### Backend Teammate Prompt (Fast Track)

```
You are the Backend Engineer for project '{slug}'.

Read the PRD at: {prd_path}

Run these jaan-to skills in order:
1. /backend-task-breakdown "{prd_path}"
2. /backend-scaffold "{task_breakdown_path}"

After scaffold is ready: message QA teammate with scaffold path.

Output directory: $JAAN_OUTPUTS_DIR/backend/
```

### Frontend Teammate Prompt

```
You are the Frontend Engineer for project '{slug}'.
Your job: design and scaffold the frontend from the PRD.

Read the PRD at: {prd_path}

Run these jaan-to skills in order:
1. /frontend-task-breakdown "{prd_path}"
2. Wait for API contract from Backend teammate (they will message you)
3. /frontend-scaffold "{task_breakdown_path}"
4. /frontend-design "{screen_descriptions}"

After scaffold is ready: message QA teammate with scaffold path.

Output directory: $JAAN_OUTPUTS_DIR/frontend/
```

### Frontend Teammate Prompt (Fast Track)

```
You are the Frontend Engineer for project '{slug}'.

Read the PRD at: {prd_path}

Run these jaan-to skills in order:
1. /frontend-scaffold "{prd_path}"

After scaffold is ready: message QA teammate with scaffold path.

Output directory: $JAAN_OUTPUTS_DIR/frontend/
```

### QA Teammate Prompt

```
You are the QA Engineer for project '{slug}'.
Your job: ensure quality through test planning and execution.

Read the PRD at: {prd_path}

Run these jaan-to skills in order:
1. /qa-test-cases "{prd_path}"
2. Wait for scaffold code from Backend and Frontend teammates (they will message you)
3. /qa-test-generate "{test_cases_path}"
4. Wait for lead to confirm integration is complete
5. /qa-test-run

Message the lead with test results (pass/fail + coverage).

Output directory: $JAAN_OUTPUTS_DIR/qa/
```

### QA Teammate Prompt (Fast Track)

```
You are the QA Engineer for project '{slug}'.

Wait for scaffold code from Backend and Frontend teammates.
Then:
1. /qa-test-generate (from code)
2. Wait for lead to confirm integration
3. /qa-test-run

Message the lead with test results.

Output directory: $JAAN_OUTPUTS_DIR/qa/
```

### UX Teammate Prompt

```
You are the UX Designer for project '{slug}'.
Your job: create user flows and microcopy from the PRD.

Read the PRD at: {prd_path}

Run these jaan-to skills in order:
1. /ux-flowchart-generate prd "{prd_path}" userflow
2. /ux-microcopy-write "{prd_path}"

Message Frontend teammate with flowchart and microcopy paths when ready.

Output directory: $JAAN_OUTPUTS_DIR/ux/
```

### DevOps Teammate Prompt

```
You are the DevOps Engineer for project '{slug}'.
Your job: create CI/CD and deployment infrastructure.

Wait for lead to confirm code integration is complete.
Then:
1. /devops-infra-scaffold
2. /devops-deploy-activate

Message the lead when infrastructure is ready.
```

### Security Teammate Prompt

```
You are the Security Engineer for project '{slug}'.
Your job: audit the integrated code for vulnerabilities.

Wait for lead to confirm code integration is complete.
Then:
1. /sec-audit-remediate

Message the lead with audit results.

Output directory: $JAAN_OUTPUTS_DIR/sec/
```

### Detect Teammate Prompt (Generic)

```
You are the {detect_title} for this repository.

Run: /{detect_skill}

Message the lead with the output path when complete.

Output directory: $JAAN_OUTPUTS_DIR/detect/{detect_domain}/
```

---

## Dependency Graph Resolution Algorithm

The lead builds a dependency graph from `roles.md` and resolves execution order:

```
1. Parse roles.md → extract all roles for selected track
2. Build dependency edges:
   For each role:
     If "Depends on" contains a role output key → add edge (dependency_role → this_role)
3. Topological sort → phased execution groups:
   Phase 1: Roles with depends_on = "user-input" or "repo"
   Phase 2: Roles whose dependencies are satisfied by Phase 1 outputs
   Phase 3: Roles whose dependencies are satisfied by Phase 2 outputs
4. Within each phase: spawn all roles in parallel
5. Between phases: wait for all teammates in current phase to complete/message
```

### Dependency Resolution Table

| Output Key | Produced By | Consumed By |
|-----------|------------|-------------|
| prd_path | pm | backend, frontend, qa, ux |
| stories_path | pm | backend, qa |
| api_contract_path | backend | frontend |
| scaffold_path (backend) | backend | qa, lead (integration) |
| scaffold_path (frontend) | frontend | qa, lead (integration) |
| flowchart_paths | ux | frontend |
| integrated_code | lead | devops, security |
| test_results_path | qa | lead (verify decision) |

---

## Checkpoint YAML Schema

Written to `$JAAN_OUTPUTS_DIR/team/{id}-{slug}/checkpoint.yaml`:

```yaml
# Team checkpoint — enables --resume
team_id: "01-my-product"
track: "full"                          # fast | full | detect | custom
initiative: "AI task manager with..."  # original initiative text
created_at: "2026-02-18T14:30:00Z"
updated_at: "2026-02-18T15:45:00Z"

phase: 2                               # current phase (0-4)
status: "in_progress"                   # in_progress | paused | completed | failed

# Role status per teammate
roles:
  pm:
    status: "done"                      # pending | spawned | in_progress | done | failed
    model: "inherit"
    outputs:
      prd_path: "$JAAN_OUTPUTS_DIR/pm/prd/01-my-product/01-my-product.md"
      stories_path: "$JAAN_OUTPUTS_DIR/pm/stories/01-my-product/"
    completed_skills: [pm-research-about, pm-prd-write, pm-story-write]
    shutdown: true

  backend:
    status: "in_progress"
    model: "sonnet"
    last_skill: "backend-scaffold"
    outputs:
      api_contract_path: "$JAAN_OUTPUTS_DIR/backend/api-contract/01-my-product/api.yaml"
    completed_skills: [backend-task-breakdown, backend-data-model, backend-api-contract]

  frontend:
    status: "waiting"
    waiting_for: "api_contract_path"

  qa:
    status: "in_progress"
    last_skill: "qa-test-cases"
    completed_skills: [qa-test-cases]

pending_roles: [devops, security]       # not yet spawned

# Shared artifacts
artifacts:
  prd_path: "$JAAN_OUTPUTS_DIR/pm/prd/01-my-product/01-my-product.md"
  entities: "User, Task, DailyPlan, DailyPlanSlot"
```

### Resume Logic

```
1. Read checkpoint.yaml
2. For each role with status "done" → skip
3. For each role with status "in_progress" → respawn with last_skill as starting point
4. For each role with status "waiting" → check if dependency is now satisfied
5. For each role in pending_roles → check if phase allows spawning
6. Continue normal orchestration from current phase
```

---

## Dry-Run Display Format

```
TEAM PLAN: {slug}
{'=' * (12 + len(slug))}

Track: {track} ({skill_count} skills)
Initiative: "{initiative}"

TEAM ROSTER ({teammate_count} teammates):
  {role_name:<12} → {skill_1}, {skill_2}, ...
  ...

EXECUTION PHASES:
  Phase 1 (Sequential): {phase_1_roles} → PRD approval gate
  Phase 2 (Parallel):   {phase_2_roles}
  Phase 3 (Parallel):   {phase_3_roles}
  Phase 4 (Sequential): Verify + Changelog

DEPENDENCY GRAPH:
  {from_role}.{skill} ──→ {to_role}.{skill}
  ...

TOKEN ESTIMATE:
  Teammates: {count} ({concurrent_max} max concurrent)
  Models: {model_breakdown}
  Estimated overhead: ~{tokens}K tokens

Proceed? [y/n]
```

---

## Error Recovery Procedures

### Teammate Fails Mid-Skill

```
1. Lead receives idle notification from failed teammate
2. Check teammate's last output — was the skill partially complete?
3. If partial output exists:
   - Update checkpoint with last_skill
   - Spawn replacement teammate with resume instructions
4. If no output:
   - Retry: spawn new teammate with same prompt
   - After 2 failures: ask user to run skill manually
```

### Dependency Deadlock

```
1. If teammate waits >10 minutes for a dependency message:
   - Lead checks if the dependency-producing teammate is still active
   - If active: send nudge message "Frontend is waiting for api-contract"
   - If idle/failed: escalate to user
2. Lead can break deadlock by providing the dependency path manually
```

### Integration Failure

```
1. If dev-project-assemble or dev-output-integrate fails:
   - Do NOT re-scaffold — scaffolds are valid
   - Present error to user with scaffold paths
   - User can fix integration manually and resume with --resume
2. Update checkpoint: phase=3, status=paused
```

---

## Token Budget Estimation Formulas

Rough estimates for planning display:

```
session_overhead = 5000  # tokens per teammate session
skill_cost_avg = 8000    # tokens per skill invocation (varies widely)
message_cost = 200       # tokens per inter-teammate message

total_estimate = (
    teammate_count * session_overhead +
    total_skill_count * skill_cost_avg +
    message_count * message_cost
)

# Haiku teammates cost ~30% of Sonnet teammates
haiku_factor = 0.3
```
