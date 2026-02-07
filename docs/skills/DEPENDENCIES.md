# Skill Dependencies

Visual map of skill relationships and suggested workflows.

---

## Dependency Graph

### Primary Workflows

```
Product Development Flow:
┌─────────────────────────────────────────────────────────┐
│  /pm-prd-write                                  │
│  "Generate PRD from initiative"                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├──> /pm-story-write (Optional)
                 │    "Generate user stories from PRD"
                 │
                 ├──> /dev-stack-detect
                 │    "Auto-detect tech stack for context"
                 │
                 ├──> /dev-fe-task-breakdown
                 │    "Frontend task breakdown from PRD"
                 │     │
                 │     └──> /jaan-to:dev-fe-state-machine (Future)
                 │          "State machine definitions"
                 │
                 ├──> /dev-be-task-breakdown
                 │    "Backend task breakdown from PRD"
                 │     │
                 │     └──> /jaan-to:dev-be-data-model (Future)
                 │          "Data model specification"
                 │
                 ├──> /qa-test-cases
                 │    "Generate BDD test cases from PRD"
                 │
                 └──> /data-gtm-datalayer
                      "GTM tracking code from PRD"
```

### Research Flow

```
Research & Learning:
┌─────────────────────────────────────────────────────────┐
│  /pm-research-about                             │
│  "Deep research on any topic"                           │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /learn-add (Suggested)
                      "Capture research insights as lessons"
```

### Documentation Flow

```
Documentation Management:
┌─────────────────────────────────────────────────────────┐
│  /docs-create                                   │
│  "Create new documentation"                             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  /docs-update                                   │
│  "Audit and update stale docs"                          │
└─────────────────────────────────────────────────────────┘
```

### UX Research Flow

```
UX Research & Design:
┌─────────────────────────────────────────────────────────┐
│  /ux-research-synthesize                        │
│  "Synthesize UX research findings"                      │
└─────────────────────────────────────────────────────────┘
                 │
                 ├──> /ux-microcopy-write
                 │    "Multi-language UI copy from insights"
                 │
                 └──> /ux-heatmap-analyze
                      "Analyze interaction patterns from heatmaps"
```

### Skill Development Flow

```
Plugin Development:
┌─────────────────────────────────────────────────────────┐
│  /skill-create                                  │
│  "Create new skill with wizard"                         │
└─────────────────────────────────────────────────────────┘
                 │
                 └──> /skill-update
                      "Update existing skill"
```

---

## Cross-Cutting Skills

These skills are suggested by multiple other skills:

### Learning & Feedback
- **Used by:** ALL skills (after execution)
- **Command:** `/learn-add`
- **Purpose:** Capture lessons learned for continuous improvement
- **Trigger:** User provides feedback about skill execution

### Roadmap Management
- **Used by:** Skills that create new features
- **Command:** `/roadmap-add`
- **Purpose:** Track feature requests and improvements
- **Trigger:** User identifies missing functionality

---

## Skill Chains (Common Workflows)

### 1. Feature Development (Complete Flow)

```bash
# Step 1: Research & PRD
/pm-research-about "authentication best practices"
/pm-prd-write "OAuth2 authentication"

# Step 2: User Stories
/pm-story-write from prd

# Step 3: Tech Planning
/dev-stack-detect
/dev-fe-task-breakdown from prd
/dev-be-task-breakdown from prd

# Step 4: QA & Tracking
/qa-test-cases from prd
/data-gtm-datalayer "auth flow tracking"
```

### 2. UX Enhancement Flow

```bash
# Step 1: Analyze Current State
/ux-heatmap-analyze "homepage-heatmap.csv"

# Step 2: Synthesize Research
/ux-research-synthesize "UX research notes"

# Step 3: Generate Microcopy
/ux-microcopy-write based on insights
```

### 3. Documentation Maintenance

```bash
# Step 1: Audit Staleness
/docs-update --check-only

# Step 2: Fix Stale Docs
/docs-update --fix

# Step 3: Create New Docs as Needed
/docs-create guide "API integration"
```

---

## Standalone Skills

These skills don't typically call others:

| Skill | Purpose | Usage Pattern |
|-------|---------|---------------|
| `/pm-story-write` | Generate user stories | Standalone or from PRD |
| `/dev-stack-detect` | Auto-detect tech stack | Run once per project |
| `/ux-microcopy-write` | Multi-language UI copy | Standalone |
| `/ux-heatmap-analyze` | Heatmap analysis | Standalone (requires CSV/screenshot) |
| `/roadmap-add` | Add roadmap task | Standalone |
| `/roadmap-update` | Sync roadmap | Standalone (maintenance) |

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
- **Feedback Loop:** All skills suggest `/learn-add` after execution for continuous improvement
- **Context Reuse:** Running `/dev-stack-detect` once benefits all subsequent tech-aware skills

---

**Last Updated:** 2026-02-03
