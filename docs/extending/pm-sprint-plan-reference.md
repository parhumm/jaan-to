# pm-sprint-plan Reference Material

> Extracted reference tables, scoring algorithms, and schemas for the `pm-sprint-plan` skill.
> This file is loaded by `pm-sprint-plan` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Progress Matrix Calculation

### Evidence Types

Each dimension is measured by the existence and completeness of concrete artifacts.

#### Specification (%)

| Evidence | Weight | How to Detect |
|----------|--------|--------------|
| PRD exists | 25% | Glob `$JAAN_OUTPUTS_DIR/pm/prd/` for `.md` files |
| User stories exist | 25% | Glob `$JAAN_OUTPUTS_DIR/pm/stories/` for `.md` files |
| Acceptance criteria defined | 25% | Search stories for Gherkin `Given/When/Then` blocks |
| API contracts defined | 15% | Glob `$JAAN_OUTPUTS_DIR/backend/api-contract/` |
| Data models defined | 10% | Glob `$JAAN_OUTPUTS_DIR/backend/data-model/` |

#### Scaffold (%)

| Evidence | Weight | How to Detect |
|----------|--------|--------------|
| Project structure created | 30% | Check for `src/` or `app/` or `packages/` directory |
| Package manager initialized | 20% | Check for `package.json`, `composer.json`, `go.mod`, or `Cargo.toml` |
| API contract files | 20% | Glob `$JAAN_OUTPUTS_DIR/backend/api-contract/` |
| Frontend scaffold | 15% | Check for component directories matching frontend framework |
| Database schema files | 15% | Check for migration files or schema definitions |

#### Production Code (%)

| Evidence | Weight | How to Detect |
|----------|--------|--------------|
| Backend services implemented | 35% | Count implementation files vs scaffold stubs |
| Frontend components built | 30% | Count component files with actual logic (>50 lines) |
| API endpoints functional | 20% | Check for route handlers with business logic |
| Integrations connected | 15% | Check for external service connectors |

#### Tests (%)

| Evidence | Weight | How to Detect |
|----------|--------|--------------|
| Test files exist | 25% | Glob `**/*.test.*`, `**/*.spec.*`, `**/test_*` |
| Tests passing | 30% | Check latest test run output or CI results |
| Coverage measured | 25% | Check for coverage reports |
| Mutation testing | 20% | Check for mutation test results in scorecards |

#### Infrastructure (%)

| Evidence | Weight | How to Detect |
|----------|--------|--------------|
| Docker configuration | 25% | Check for `Dockerfile`, `docker-compose.yml` |
| CI/CD pipeline | 25% | Check for `.github/workflows/`, `Jenkinsfile`, etc. |
| Deployment config | 25% | Check for deployment manifests, Terraform, etc. |
| Monitoring setup | 15% | Check for logging/monitoring configuration |
| Environment config | 10% | Check for `.env.example`, config templates |

### Calculation Formula

```
dimension_pct = sum(evidence_weight * evidence_present) * 100
```

Where `evidence_present` is 1 (found) or 0 (not found). Partial credit: if evidence exists but is incomplete (e.g., 3 of 5 API endpoints implemented), use fractional value.

### Fallback

If gap reports are not found, skip all progress matrix calculations. Record:
```
Progress matrix: UNAVAILABLE (gap reports not found)
```

---

## Bottleneck State Machine

### State Definitions

| State | Entry Condition | Focus Skills | Exit When |
|-------|-----------------|-------------|-----------|
| `ideation-to-spec` | Spec < 50% | pm-prd-write, pm-story-write, pm-research-about | Spec ≥ 50% |
| `spec-to-scaffold` | Spec ≥ 50%, Scaffold < 30% | backend-scaffold, frontend-scaffold, backend-data-model, backend-api-contract | Scaffold ≥ 30% |
| `scaffold-to-code` | Scaffold ≥ 30%, Code < 30% | backend-service-implement, frontend components | Code ≥ 30% |
| `code-to-tested` | Code ≥ 30%, Tests < 30% | qa-test-generate, qa-tdd-orchestrate, qa-test-mutate | Tests ≥ 30% |
| `tested-to-deployed` | Tests ≥ 30%, Infra < 30% | devops-infra-scaffold, devops-deploy-activate | Infra ≥ 30% |
| `quality-and-polish` | All ≥ 30% | sec-audit-remediate, detect-*, qa-quality-gate | All ≥ 80% |

### Transition Rules

1. States are evaluated top-to-bottom — first matching state wins
2. `--focus` argument overrides auto-detected state
3. If progress matrix is unavailable, default to `ideation-to-spec` (unless `--focus` is provided)
4. Multiple consecutive cycles in the same state → flag as "stuck" and suggest research (`pm-research-about`)

### Focus Argument Mapping

| --focus value | Maps to State |
|--------------|---------------|
| `spec` | ideation-to-spec |
| `scaffold` | spec-to-scaffold |
| `code` | scaffold-to-code |
| `test` | code-to-tested |
| `audit` | quality-and-polish |

---

## Execution Queue Algorithm

### Priority Sources

The queue is built by evaluating 7 sources in priority order. Each source contributes items until the queue reaches 12 items (minus 2 reserved for Source 7 closing skills).

| Source | Priority | Max Items | Selection Logic |
|--------|----------|-----------|----------------|
| 1. P0 Blockers | Highest | 3 | Items tagged P0 in gap reports or ROADMAP |
| 2. --tasks Filter | High | 5 | User-specified task keywords from ROADMAP |
| 3. Bottleneck Skills | Medium-High | 4 | Skills that address the classified bottleneck |
| 4. P1 Features | Medium | 3 | Items tagged P1 in ROADMAP |
| 5. Quick Wins | Low-Medium | 2 | Single-skill tasks with no dependencies |
| 6. Untested Skills | Low | 1 | Skills never run in this project |
| 7. Closing Skills | Always | 2 | detect-pack + release-iterate-changelog |

### Scoring Algorithm

For items within the same source, rank by:

```
score = (priority_weight * 0.4) + (dependency_freedom * 0.3) + (bottleneck_alignment * 0.2) + (effort_inverse * 0.1)
```

Where:
- `priority_weight`: P0=1.0, P1=0.8, P2=0.5, Quick Win=0.3
- `dependency_freedom`: 1.0 if no dependencies, 0.5 if dependencies are in queue, 0.0 if dependencies are missing
- `bottleneck_alignment`: 1.0 if addresses current bottleneck, 0.5 if adjacent, 0.0 if unrelated
- `effort_inverse`: 1.0 for single-skill tasks, 0.5 for multi-skill, 0.3 for multi-role

### Task Group Ordering

Items are organized into groups for execution:

1. **Group by dependency**: Items with dependencies are placed after their prerequisites
2. **Group by role**: Items for the same role execute together (enables Agent Teams parallelism)
3. **Source 7 always last**: Closing skills run after all other groups complete

### Queue Overflow Handling

If more items qualify than queue capacity (12):
1. Lower-priority items are deferred
2. Deferred items are listed in the sprint plan under "DEFERRED"
3. Deferred items carry over to the next sprint with priority boost (+1 source level)

---

## Sprint Plan Output Schema

The sprint plan artifact includes a machine-readable YAML frontmatter block. This schema is consumed by `team-ship --track sprint`.

### YAML Schema

```yaml
---
type: sprint-plan         # Fixed identifier
version: 1                # Schema version
created: "YYYY-MM-DD"     # Generation date
focus: string             # spec|scaffold|code|test|audit
bottleneck: string        # State machine stage name
progress:                 # Progress matrix (omitted if unavailable)
  specification: number   # 0-100
  scaffold: number        # 0-100
  production_code: number # 0-100
  tests: number           # 0-100
  infrastructure: number  # 0-100
queue_count: number       # Total items in queue
queue:                    # Ordered execution queue
  - id: number            # Sequential (1-based)
    skill: string         # jaan-to skill name
    role: string          # pm|backend|frontend|qa|devops|sec
    args: string          # Skill arguments
    group: number         # Execution group (1-based)
    source: number        # Priority source (1-7)
    depends_on: [number]  # IDs of prerequisite items
    roadmap_ref: string   # Original ROADMAP.md line (for marking complete)
    risk: string          # dependency|complexity|unknown|none
closing_skills:           # Always-run closing skills
  - detect-pack
  - release-iterate-changelog
deferred:                 # Items beyond queue capacity
  - title: string
    reason: string
    priority_boost: boolean
---
```

### Validation Rules

1. `queue_count` must equal length of `queue` array
2. All `depends_on` IDs must reference valid items in the same queue
3. `group` numbers must be sequential (no gaps)
4. Items within a group must not depend on each other
5. `closing_skills` must always be present

---

## Risk Assessment Matrix

| Risk Type | Indicator | Mitigation |
|-----------|-----------|------------|
| Dependency | Item requires output from another queue item | Order correctly in groups |
| Complexity | Multi-file or multi-role task | Allocate to dedicated Agent Team |
| Unknown | First time running skill in project | Include in queue for validation |
| Conflict | Two items modify the same files | Place in separate groups |
| External | Requires API keys, credentials, or services | Flag for user pre-check |

### Risk Scoring

```
risk_level = count(risk_types_present)
```

| Count | Level | Action |
|-------|-------|--------|
| 0 | Low | Proceed normally |
| 1 | Medium | Note in plan, no special action |
| 2 | High | Flag prominently, suggest mitigation |
| 3+ | Critical | Consider splitting into multiple sprints |

---

## Related

- [Token Strategy](../token-strategy.md) — Layer 2 optimization
- [Extraction Safety Checklist](extraction-safety-checklist.md) — What to extract
- [team-ship Reference](team-ship-reference.md) — Sprint track consumption
