# Skill Discovery Report

> Generated: {{date}} | Sessions analyzed: {{session_count}} | Period: {{period_days}} days

## Executive Summary

{{executive_summary}}

## Data Sources

| Source | Records | Period |
|--------|---------|--------|
| Claude Code sessions | {{cc_session_count}} | {{period}} |
| Git commits | {{git_commit_count}} | {{period}} |
| Learning files | {{learn_file_count}} | current |

## Analysis Summary

| Metric | Value |
|--------|-------|
| Episodes segmented | {{episode_count}} |
| Unique patterns found | {{pattern_count}} |
| Above threshold (score > 40) | {{candidate_count}} |
| Estimated total savings | {{total_savings_per_week}} min/week |

## Discovered Patterns

### {{pattern_rank}}. {{pattern_name}} (Score: {{pattern_score}}/100)

**Description**: {{pattern_description}}

| Dimension | Weight | Score | Evidence |
|-----------|--------|-------|----------|
| Frequency | 30% | {{frequency_score}} | {{frequency_evidence}} |
| Time Saved | 30% | {{time_score}} | {{time_evidence}} |
| Parameterizability | 25% | {{param_score}} | {{param_evidence}} |
| Risk | 15% | {{risk_score}} | {{risk_evidence}} |

**Action Sequence**: {{action_sequence}}

**Archetype Match**: {{archetype_name}} ({{archetype_confidence}}%)

**Suggested Skill**: `{{suggested_skill_name}}` (`{{suggested_role}}-{{suggested_domain}}-{{suggested_action}}`)

**Auto-create command**:
```
/jaan-to:skill-create "{{skill_create_input}}"
```

---

## Next Steps

{{next_steps}}

## Metadata

| Field | Value |
|-------|-------|
| Created | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/pm/skill-discover/ |
| Skill | pm-skill-discover |
| Status | {{status}} |
| Version | 3.0 |
