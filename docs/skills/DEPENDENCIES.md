# Skill Dependencies

Visual map of skill relationships and suggested workflows.

---

## Dependency Graph

### Primary Workflows

```
Product Development Flow:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:pm-prd-write                                  │
│  "Generate PRD from initiative"                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:pm-story-write (Optional)
                 │    "Generate user stories from PRD"
                 │
                 ├──> /jaan-to:dev-stack-detect
                 │    "Auto-detect tech stack for context"
                 │
                 ├──> /jaan-to:dev-fe-task-breakdown
                 │    "Frontend task breakdown from PRD"
                 │     │
                 │     └──> /jaan-to:dev-fe-state-machine (Future)
                 │          "State machine definitions"
                 │
                 ├──> /jaan-to:dev-be-task-breakdown
                 │    "Backend task breakdown from PRD"
                 │     │
                 │     └──> /jaan-to:dev-be-data-model (Future)
                 │          "Data model specification"
                 │
                 ├──> /jaan-to:qa-test-cases
                 │    "Generate BDD test cases from PRD"
                 │
                 └──> /jaan-to:data-gtm-datalayer
                      "GTM tracking code from PRD"
```

### Research Flow

```
Research & Learning:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:pm-research-about                             │
│  "Deep research on any topic"                           │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /jaan-to:learn-add (Suggested)
                      "Capture research insights as lessons"
```

### Documentation Flow

```
Documentation Management:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:docs-create                                   │
│  "Create new documentation"                             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  /jaan-to:docs-update                                   │
│  "Audit and update stale docs"                          │
└─────────────────────────────────────────────────────────┘
```

### UX Research Flow

```
UX Research & Design:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:ux-research-synthesize                        │
│  "Synthesize UX research findings"                      │
└─────────────────────────────────────────────────────────┘
                 │
                 ├──> /jaan-to:ux-microcopy-write
                 │    "Multi-language UI copy from insights"
                 │
                 └──> /jaan-to:ux-heatmap-analyze
                      "Analyze interaction patterns from heatmaps"
```

### Skill Development Flow

```
Plugin Development:
┌─────────────────────────────────────────────────────────┐
│  /jaan-to:skill-create                                  │
│  "Create new skill with wizard"                         │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /jaan-to:skill-update
                      "Update existing skill"
```

---

## Cross-Cutting Skills

These skills are suggested by multiple other skills:

### Learning & Feedback
- **Used by:** ALL skills (after execution)
- **Command:** `/jaan-to:learn-add`
- **Purpose:** Capture lessons learned for continuous improvement
- **Trigger:** User provides feedback about skill execution

### Roadmap Management
- **Used by:** Skills that create new features
- **Command:** `/jaan-to:roadmap-add`
- **Purpose:** Track feature requests and improvements
- **Trigger:** User identifies missing functionality

---

## Skill Chains (Common Workflows)

### 1. Feature Development (Complete Flow)

```bash
# Step 1: Research & PRD
/jaan-to:pm-research-about "authentication best practices"
/jaan-to:pm-prd-write "OAuth2 authentication"

# Step 2: User Stories
/jaan-to:pm-story-write from prd

# Step 3: Tech Planning
/jaan-to:dev-stack-detect
/jaan-to:dev-fe-task-breakdown from prd
/jaan-to:dev-be-task-breakdown from prd

# Step 4: QA & Tracking
/jaan-to:qa-test-cases from prd
/jaan-to:data-gtm-datalayer "auth flow tracking"
```

### 2. UX Enhancement Flow

```bash
# Step 1: Analyze Current State
/jaan-to:ux-heatmap-analyze "homepage-heatmap.csv"

# Step 2: Synthesize Research
/jaan-to:ux-research-synthesize "UX research notes"

# Step 3: Generate Microcopy
/jaan-to:ux-microcopy-write based on insights
```

### 3. Documentation Maintenance

```bash
# Step 1: Audit Staleness
/jaan-to:docs-update --check-only

# Step 2: Fix Stale Docs
/jaan-to:docs-update --fix

# Step 3: Create New Docs as Needed
/jaan-to:docs-create guide "API integration"
```

---

## Standalone Skills

These skills don't typically call others:

| Skill | Purpose | Usage Pattern |
|-------|---------|---------------|
| `/jaan-to:pm-story-write` | Generate user stories | Standalone or from PRD |
| `/jaan-to:dev-stack-detect` | Auto-detect tech stack | Run once per project |
| `/jaan-to:ux-microcopy-write` | Multi-language UI copy | Standalone |
| `/jaan-to:ux-heatmap-analyze` | Heatmap analysis | Standalone (requires CSV/screenshot) |
| `/jaan-to:roadmap-add` | Add roadmap task | Standalone |
| `/jaan-to:roadmap-update` | Sync roadmap | Standalone (maintenance) |

---

## Future Skills (Planned)

These skills are referenced but not yet implemented:

| Skill | Referenced By | Purpose |
|-------|---------------|---------|
| `/jaan-to:dev-fe-state-machine` | fe-task-breakdown | Component state machine definitions |
| `/jaan-to:dev-be-data-model` | be-task-breakdown | Detailed data model specification |

See [roadmap.md](../../roadmaps/jaan-to/roadmap-jaan-to.md) for implementation timeline.

---

## Agent Integration

Skills may invoke agents automatically:

| Agent | Triggered By | Purpose |
|-------|-------------|---------|
| **quality-reviewer** | All output-generating skills | Review output completeness and quality |
| **context-scout** | pm-prd-write, task breakdowns | Gather project context before generation |

---

## Notes

- **Suggested vs Required:** Most skill chains are suggestions, not hard requirements
- **Flexibility:** You can use skills in any order that makes sense for your workflow
- **Feedback Loop:** All skills suggest `/jaan-to:learn-add` after execution for continuous improvement
- **Context Reuse:** Running `/jaan-to:dev-stack-detect` once benefits all subsequent tech-aware skills

---

**Last Updated:** 2026-02-03
