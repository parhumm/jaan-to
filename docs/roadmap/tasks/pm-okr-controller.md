---
title: "PM OKR Controller Skill"
sidebar_position: 17
---

# PM OKR Controller Skill

> Phase 6 | Status: pending

## Problem

The PM skill chain covers discovery → PRD → stories → release, but lacks objective/OKR tracking. There is no way to define company/product objectives, set key results, and trace which features/stories contribute to which OKR. This breaks the strategic-to-tactical link — teams ship features without knowing whether they move business metrics.

## Solution

Create `/pm-okr-controller` for defining objectives, key results, and linking them to existing PM outputs (PRDs, stories). The skill manages OKR lifecycle: define → link → score → review.

### Data Model

```
Objective
├── Key Result 1 (metric, target, current, score 0.0-1.0)
│   ├── → PRD link
│   └── → Story links
├── Key Result 2
└── Key Result 3
```

### Modes

| Mode | Command | Action |
|------|---------|--------|
| Define | `/pm-okr-controller define Q1-2025` | Create objectives + key results |
| Link | `/pm-okr-controller link {story-id} {kr-id}` | Map story to key result |
| Score | `/pm-okr-controller score Q1-2025` | Update key result scores |
| Review | `/pm-okr-controller review Q1-2025` | Generate health dashboard |

## Scope

**In-scope:**
- OKR definition with measurable key results
- Bidirectional linking: stories/PRDs ↔ key results
- Progress scoring (0.0-1.0 scale per key result)
- Health dashboard (at-risk / on-track / achieved)
- Quarterly/monthly cycle management

**Out-of-scope:**
- Company-wide OKR cascading (team-level only)
- Integration with OKR platforms (Lattice, 15Five)
- Automated score calculation from analytics (needs GA4 MCP)

## Implementation Steps

1. Create skill via `/jaan-to:skill-create pm-okr-controller`
2. Design OKR file format (YAML frontmatter + markdown body):
   ```yaml
   ---
   cycle: Q1-2025
   status: active
   objectives:
     - id: O1
       title: "Increase user retention"
       key_results:
         - id: KR1.1
           metric: "D7 retention rate"
           baseline: 35%
           target: 50%
           current: 42%
           score: 0.47
           linked_stories: [S-001, S-003]
   ---
   ```
3. Implement four modes (define, link, score, review)
4. Build health dashboard output:
   - Traffic light status per objective (red/yellow/green)
   - Key result progress bars
   - Linked PRDs/stories per KR
   - Unlinked stories report (stories not contributing to any OKR)
5. Add cross-references to existing PM outputs in `$JAAN_OUTPUTS_DIR/pm/`
6. Output at `$JAAN_OUTPUTS_DIR/pm/okr/{cycle}-{slug}/`

## Skills Affected

- `/pm-prd-write` — Add optional OKR alignment field to PRD template
- `/pm-story-write` — Add optional KR reference in story metadata
- `/pm-priority-score` (pending) — OKR alignment as prioritization input

## Acceptance Criteria

- [ ] Define objectives with 3-5 key results each
- [ ] Link stories/PRDs to key results (bidirectional reference)
- [ ] Score key results with 0.0-1.0 scale
- [ ] Generate OKR health summary dashboard
- [ ] Quarterly/monthly cycle management
- [ ] Follows v3.0.0 skill patterns (`$JAAN_*` environment variables)
- [ ] Output at `$JAAN_OUTPUTS_DIR/pm/okr/{cycle}-{slug}/`

## Dependencies

- None for core OKR functionality
- `/pm-priority-score` (pending) for OKR-based prioritization
- GA4 MCP (Phase 7) for automated metric tracking

## References

- [#128](https://github.com/parhumm/jaan-to/issues/128)
- PM skill chain: `skills/pm-prd-write/SKILL.md`, `skills/pm-story-write/SKILL.md`
- PM role catalog: `docs/roadmap/tasks/role-skills/pm.md`
