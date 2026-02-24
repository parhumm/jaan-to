---
title: "pm-skill-discover"
sidebar_position: 7
---

# /jaan-to:pm-skill-discover

> Detect workflow patterns from AI sessions and suggest reusable skills.

---

## What It Does

Analyzes your recent AI development sessions to detect repeated workflow patterns and suggests new skills you could create to automate them. Includes:
- Claude Code session transcript analysis (tool usage patterns)
- Git history analysis (file-group patterns, commit frequency)
- jaan-to learning file analysis (skill usage frequency)
- 4-dimension scoring rubric (frequency, time saved, parameterizability, risk)
- Matching against 10 known workflow archetypes from research
- Optional auto-invocation of `/jaan-to:skill-create` for selected patterns

---

## Usage

```
/jaan-to:pm-skill-discover
/jaan-to:pm-skill-discover --days=7
/jaan-to:pm-skill-discover --days=30 --min-frequency=5 --max-suggestions=3
```

---

## Parameters

| Flag | Default | Description |
|------|---------|-------------|
| `--days=N` | 14 | Number of days to analyze |
| `--min-frequency=N` | 3 | Minimum pattern occurrences to surface |
| `--max-suggestions=N` | 5 | Maximum suggestions to present |

---

## Data Sources

| Source | What It Extracts |
|--------|-----------------|
| Claude Code sessions | Tool names, result status, timestamps (structural metadata only) |
| Git history | File groups, commit frequency, message categories |
| jaan-to learn files | Skill usage frequency, accumulated lesson counts |

**Privacy**: Only structural metadata is extracted. No raw code, prompts, file paths, or variable values are stored or displayed.

---

## Scoring Rubric

Each candidate pattern is scored on 4 dimensions:

| Dimension | Weight | What It Measures |
|-----------|--------|-----------------|
| Frequency | 30% | How often the pattern occurs per week |
| Time Saved | 30% | Estimated duration x frequency |
| Parameterizability | 25% | Ratio of variable to fixed steps |
| Risk | 15% | Inverse of destructive operations |

Patterns scoring above 40/100 are surfaced as candidates.

---

## Known Archetypes

Detected patterns are matched against 10 research-backed workflow archetypes:

1. Error diagnosis and fix cycle
2. Red-green-refactor loop
3. CI pipeline repair
4. Dependency update workflow
5. Code review response pattern
6. Feature scaffolding
7. Migration execution
8. API integration
9. Merge conflict resolution
10. Post-deployment verification

---

## Output

**Path**: `jaan-to/outputs/pm/skill-discover/{id}-{slug}/{id}-{slug}.md`

**Contains**:
- Executive summary with total estimated time savings
- Data source statistics
- Discovered patterns with full scoring breakdown
- Archetype matches
- Pre-filled `/jaan-to:skill-create` commands for each candidate

---

## Example

**Input**:
```
/jaan-to:pm-skill-discover --days=14
```

**Preview at HARD STOP**:
```
SKILL DISCOVERY REPORT
══════════════════════
Period: 14 days | Sessions: 23 | Episodes: 67
Patterns detected: 12 | Above threshold: 3

TOP SUGGESTIONS
───────────────
1. [Score: 87] "Error Diagnosis Cycle"
   Frequency: 12x/week | Est. savings: ~40 min/week
   Archetype: Error diagnosis and fix cycle
   Suggested skill: qa-error-fix

2. [Score: 72] "Feature File Scaffolding"
   Frequency: 5x/week | Est. savings: ~25 min/week
   Archetype: Feature scaffolding
   Suggested skill: dev-feature-scaffold
```

---

## Tips

- Run after at least 2 weeks of active development for meaningful patterns
- Combine with `/jaan-to:skill-create` for end-to-end discovery-to-creation pipeline
- Re-run monthly to detect new patterns as workflow evolves
- Use `--min-frequency=5` for high-activity repos to reduce noise

---

## Learning

This skill reads from:
```
jaan-to/learn/jaan-to-pm-skill-discover.learn.md
```

Add feedback:
```
/jaan-to:learn-add pm-skill-discover "Check for monorepo context mixing"
```
