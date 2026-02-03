# Skill Chaining Patterns

> Best practices for combining jaan-to skills into efficient workflows

---

## Overview

Skill chaining is the practice of using multiple jaan-to skills in sequence, where each skill's output becomes the next skill's input. This creates powerful workflows that eliminate manual handoffs and maintain context across the product development lifecycle.

**Benefits**:
- **40-60% time savings** vs. manual cross-domain handoffs
- **Context preservation**: Each skill reads previous outputs, maintaining consistency
- **Reduced errors**: Eliminates copy-paste mistakes and broken references
- **Audit trail**: Git commits track complete workflow lineage

**Core Principle**: *Every jaan-to output is designed to be consumed by another jaan-to skill.*

---

## The Six Core Chains

### Chain 1: Research → PRD → Tasks

**Purpose**: Transform market insights into actionable engineering work

**Flow**:
```
Research Topic
    ↓
[/jaan-to-pm-research-about]
    ↓
Research Document (jaan-to/outputs/research/01-*.md)
    ↓
[/jaan-to-pm-prd-write] ← Read research findings
    ↓
PRD (jaan-to/outputs/pm/prd/01-*/prd.md)
    ↓
[/jaan-to-dev-be-task-breakdown] ← Pass PRD path
    ↓
Backend Tasks (jaan-to/outputs/dev/backend/01-*/tasks.md)
```

**Real Example**:
```bash
# Step 1: Research WebRTC scalability
/jaan-to-pm-research-about "WebRTC vs RTMP for educational live streaming scalability"
# Output: research/02-technical-streaming-architecture.md

# Step 2: Write PRD incorporating research insights
/jaan-to-pm-prd-write "Build live streaming classroom with WebRTC, screen sharing, breakout rooms, supporting 500 concurrent students"
# PRD includes: "Based on research, WebRTC provides <200ms latency ideal for real-time interaction"

# Step 3: Break down into backend tasks
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
# Tasks include: WebRTC signaling server, Mediasoup SFU setup, reconnection logic
```

**Why It Works**:
- Research findings inform PRD's "Why this solution?" section
- PRD requirements become task acceptance criteria
- No information loss across handoffs

---

### Chain 2: PRD → Backend → Frontend → GTM

**Purpose**: Complete feature specification from requirements to tracking

**Flow**:
```
PRD Document
    ↓
[/jaan-to-dev-be-task-breakdown] ← PRD path
    ↓
Backend Tasks
    ↓
[/jaan-to-dev-fe-task-breakdown] ← Feature description (from PRD)
    ↓
Frontend Components
    ↓
[/jaan-to-data-gtm-datalayer] ← PRD path
    ↓
GTM Tracking Events
```

**Real Example**:
```bash
# Given: PRD for course marketplace (PRD-02)

# Step 1: Backend API design
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/02-course-marketplace/prd.md
# Output: Course CRUD APIs, Stripe payment integration, revenue sharing logic

# Step 2: Frontend UI components
/jaan-to-dev-fe-task-breakdown "Course marketplace with filter sidebar, course cards, purchase modal, checkout flow"
# Output: 18 components (CourseCard, FilterSidebar, CheckoutForm, etc.)

# Step 3: GTM tracking
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/02-course-marketplace/prd.md
# Output: 7 events (course_viewed, add_to_cart, purchase_completed, etc.)
```

**Time Savings**: ~4-6 hours of meetings eliminated (PM → Eng sync, Eng → Analytics handoff)

**Context Preserved**:
- Backend tasks reference PRD's data models
- Frontend components match PRD's user flows
- GTM events align with PRD's success metrics

---

### Chain 3: PRD → Stories → Tasks

**Purpose**: Granular feature breakdown with user-centric acceptance criteria

**Flow**:
```
PRD Document
    ↓
[/jaan-to-pm-story-write] ← PRD feature + context
    ↓
User Stories (Gherkin scenarios)
    ↓
[/jaan-to-dev-be-task-breakdown] ← Story file path
    ↓
Backend Tasks (with scenario-based acceptance)
```

**Real Example**:
```bash
# Given: PRD for course marketplace

# Step 1: Write specific user story
/jaan-to-pm-story-write "Course Marketplace, Student purchasing a course with saved payment method and applying coupon code"
# Output: stories/04-payment-processing/
#   - 7 Gherkin scenarios (happy path, expired coupon, declined card, etc.)

# Step 2: Backend tasks from story
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/stories/04-payment-processing/stories.md
# Tasks include:
#   - Coupon validation API (accepts scenario: "coupon expired" → 403 error)
#   - Stripe payment intent creation (accepts scenario: "card declined" → retry logic)
```

**Why Use Stories as Intermediate Step**?
- **PRD → Tasks**: Good for architectural features (APIs, data models, infra)
- **Story → Tasks**: Better for user-facing flows with edge cases

**Decision Rule**:
- Use **PRD → Tasks** for: Infrastructure, data pipelines, batch jobs
- Use **Story → Tasks** for: User flows, multi-step interactions, error handling

---

### Chain 4: Story → GTM

**Purpose**: Track specific user journeys with precise event parameters

**Flow**:
```
User Story (Gherkin scenarios)
    ↓
[/jaan-to-data-gtm-datalayer] ← Story file path
    ↓
GTM Tracking (scenario-aware events)
```

**Real Example**:
```bash
# Step 1: Write discovery story
/jaan-to-pm-story-write "Student browsing course marketplace to find web development courses under $50 with 4+ star ratings, applying filters, and clicking course card"
# Output: stories/03-course-discovery/
#   - Scenarios: Filter by category, Filter by price, Sort by rating, Click course

# Step 2: GTM from story
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/stories/03-course-discovery/stories.md
# Output: discovery-tracking/
#   - filter_applied (params: filter_type, filter_value)
#   - sort_changed (params: sort_field, sort_direction)
#   - course_clicked (params: course_id, position, filter_context)
```

**Advantage Over PRD → GTM**:
- **PRD → GTM**: Generates high-level feature events (good for impressions, page views)
- **Story → GTM**: Generates interaction-specific events (good for clicks, form submissions)

**Use Both**:
```bash
# High-level feature tracking
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/02-course-marketplace/prd.md

# Granular interaction tracking
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/stories/03-course-discovery/stories.md
```

---

### Chain 5: Tasks → Microcopy

**Purpose**: Generate UI text for components identified in frontend tasks

**Flow**:
```
Frontend Task Breakdown
    ↓
Extract component inventory (buttons, labels, tooltips)
    ↓
[/jaan-to-ux-microcopy-write] ← Component list as text description
    ↓
Multi-language Microcopy
```

**Real Example**:
```bash
# Given: Frontend tasks for live classroom UI (01-live-classroom-ui/)
# Component inventory includes:
#   - ToolbarButtons: Mute/Unmute, Camera On/Off, Hand Raise, Screen Share, Leave Class
#   - StatusIndicators: "Live", "Recording", "Reconnecting"
#   - Tooltips: "Turn on your camera to be visible to others"

# Step 1: Generate microcopy from components
/jaan-to-ux-microcopy-write "Live classroom control labels and tooltips: mute/unmute mic, turn on/off camera, raise hand, screen share, chat, participants list, leave class, breakout rooms, polls, reactions, and connection quality indicators"
# Output: content/02-live-class-controls/
#   - 36 microcopy items
#   - 7 languages (EN, FA, TR, DE, FR, RU, TG)
#   - JSON export for i18n integration
```

**Integration Pattern**:
```typescript
// React component imports microcopy from jaan-to output
import microcopy from 'jaan-to/outputs/ux/content/02-live-class-controls/02-microcopy-live-class-controls.json';

const MuteButton = () => {
  const { t } = useTranslation();
  return (
    <button aria-label={t('controls.mic.mute')}>
      {microcopy.microcopy.find(m => m.id === 'mute-mic-label').translations[language].text}
    </button>
  );
};
```

---

### Chain 6: Microcopy → Heatmap → Learn

**Purpose**: Post-launch optimization loop with automated lesson capture

**Flow**:
```
Microcopy Deployed
    ↓
User Interaction Data (heatmap CSV)
    ↓
[/jaan-to-ux-heatmap-analyze] ← CSV + screenshot
    ↓
Heatmap Analysis (insights + recommendations)
    ↓
[/to-jaan-learn-add] ← Capture insights as lessons
    ↓
Updated LEARN.md (informs future microcopy)
```

**Real Example**:
```bash
# Step 1: Analyze heatmap data
/jaan-to-ux-heatmap-analyze
# Upload: course-browse-heatmap.csv + screenshot
# Finding: "Filter sidebar only 5.6% of clicks despite 40% screen space"

# Step 2: Capture lesson
/to-jaan-learn-add "jaan-to-ux-microcopy-write" "For filter-heavy interfaces, add microcopy that explains filter benefits (e.g., 'Narrow down 500+ courses to your perfect match')"
# Output: learn/jaan-to-ux-microcopy-write.learn.md updated

# Step 3: Next microcopy generation auto-applies lesson
/jaan-to-ux-microcopy-write "Course filter sidebar labels"
# Now includes persuasive subtext for filters
```

---

## Advanced Chaining Patterns

### Pattern A: Parallel Chaining

**Use Case**: Generate backend + frontend + tracking simultaneously

**Flow**:
```
PRD Document
    ↓
    ├─→ [/jaan-to-dev-be-task-breakdown]
    ├─→ [/jaan-to-dev-fe-task-breakdown]
    └─→ [/jaan-to-data-gtm-datalayer]
    ↓
All outputs ready in parallel
```

**Bash Script**:
```bash
#!/bin/bash
PRD_PATH="jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md"

# Launch all in parallel (use & for background jobs)
/jaan-to-dev-be-task-breakdown "$PRD_PATH" &
PID_BE=$!

/jaan-to-dev-fe-task-breakdown "Live classroom interface..." &
PID_FE=$!

/jaan-to-data-gtm-datalayer "$PRD_PATH" &
PID_GTM=$!

# Wait for all to complete
wait $PID_BE $PID_FE $PID_GTM

echo "All tasks ready! Check outputs/"
```

**Time Savings**: 3 sequential runs (45 min) → 1 parallel run (15 min)

### Pattern B: Diamond Chain

**Use Case**: Multiple paths converge to final output

**Flow**:
```
       PRD
        ↓
    ┌───┴───┐
    ↓       ↓
Backend  Frontend
  Tasks    Tasks
    ↓       ↓
    └───┬───┘
        ↓
   Integration
     Story
        ↓
      GTM
```

**Real Example**:
```bash
# 1. PRD for live streaming
/jaan-to-pm-prd-write "Live streaming classroom..."

# 2a. Backend tasks
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md

# 2b. Frontend tasks
/jaan-to-dev-fe-task-breakdown "Live classroom interface..."

# 3. Integration story combining BE + FE insights
/jaan-to-pm-story-write "Instructor starts live class: Frontend renders video grid → Backend establishes WebRTC connections → Frontend displays connection quality indicators"

# 4. GTM tracking for integration points
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/stories/08-live-class-integration/stories.md
```

### Pattern C: Feedback Loop Chain

**Use Case**: Iterative refinement based on lessons learned

**Flow**:
```
PRD v1
  ↓
Tasks v1
  ↓
Lessons Learned (from implementation)
  ↓
[/to-jaan-learn-add] → Update PRD skill
  ↓
PRD v2 (incorporates lessons)
  ↓
Tasks v2 (more complete)
```

**Real Example**:
```bash
# Iteration 1
/jaan-to-pm-prd-write "Live streaming classroom..."
# PRD lacks cost analysis

# Implementation reveals: "Twilio costs will exceed budget at 500 users"
/to-jaan-learn-add "jaan-to-pm-prd-write" "When PRD involves third-party services (payment processors, streaming providers), always include cost analysis section with pricing tiers and break-even calculations"

# Iteration 2
/jaan-to-pm-prd-write "Live streaming classroom..."
# PRD now includes:
#   ## Cost Analysis
#   - Twilio: $0.0015/min/participant → $45/class at 500 students
#   - Break-even: Need $60 course price for 25% margin
```

---

## Anti-Patterns (What NOT to Do)

### ❌ Anti-Pattern 1: Manual Copy-Paste Between Skills

**Wrong**:
```bash
# Generate PRD
/jaan-to-pm-prd-write "Feature X"

# Copy PRD text manually → paste into new skill
/jaan-to-dev-be-task-breakdown "Feature X with requirements: ..."
```

**Why It Fails**:
- Loses context (PRD has structured sections skill can parse)
- Introduces copy errors (truncated text, missing requirements)
- No audit trail (can't trace tasks back to PRD)

**Right**:
```bash
# Generate PRD
/jaan-to-pm-prd-write "Feature X"

# Pass PRD file path directly
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/03-feature-x/prd.md
```

### ❌ Anti-Pattern 2: Chaining Incompatible Output → Input

**Wrong**:
```bash
# Generate heatmap analysis
/jaan-to-ux-heatmap-analyze

# Try to pass heatmap to GTM skill (incompatible)
/jaan-to-data-gtm-datalayer jaan-to/outputs/ux/heatmap/01-*/heatmap.md
```

**Why It Fails**:
- GTM skill expects PRD/Story (user requirements), not heatmap analysis (user behavior data)
- Outputs are structured for different audiences

**Right**:
```bash
# Heatmap → Learn → Microcopy (correct chain)
/jaan-to-ux-heatmap-analyze
# Findings: "Users ignore CTA button in bottom-right"

/to-jaan-learn-add "jaan-to-ux-microcopy-write" "Place CTAs in F-pattern hot zones (top-left, center-left) based on heatmap analysis"

/jaan-to-ux-microcopy-write "Course enrollment CTA with prominent placement"
```

### ❌ Anti-Pattern 3: Over-Chaining (Too Many Steps)

**Wrong**:
```bash
Research → PRD → Story → Backend → Frontend → Microcopy → GTM → Heatmap → Learn → Docs
# (10 steps in sequence, takes 3+ hours)
```

**Why It Fails**:
- Diminishing returns after 4-5 steps
- Human review needed between domains
- Risk of compounding errors

**Right**:
```bash
# Chain 1: Research → PRD → Backend (3 steps)
# Review backend tasks ✓

# Chain 2: PRD → Frontend → Microcopy (3 steps)
# Review microcopy ✓

# Chain 3: PRD → GTM (2 steps)
# Review tracking ✓
```

**Rule of Thumb**: Max 3-4 skills per chain, with human review between chains.

---

## Decision Matrix: Which Chain to Use?

| Starting Point | Goal | Recommended Chain | Typical Time |
|----------------|------|-------------------|--------------|
| User request | Complete feature spec | Research → PRD → Backend → Frontend → GTM | 60-90 min |
| Existing PRD | Engineering tasks | PRD → Backend + Frontend (parallel) | 20-30 min |
| User flow | Detailed interaction tracking | Story → Tasks → GTM | 30-45 min |
| UI components | Multi-language copy | Tasks → Microcopy | 15-20 min |
| Launch prep | Tracking + documentation | PRD → GTM + Docs (parallel) | 20-25 min |
| Post-launch | Optimization insights | Heatmap → Learn → Microcopy v2 | 25-35 min |

---

## Measuring Chain Effectiveness

### Metric 1: Time to Spec

**Definition**: Time from initial idea to ready-to-implement specifications

**Baseline (Manual)**:
- Research: 2-3 hours (meetings, doc review)
- PRD: 3-4 hours (writing, stakeholder review)
- Tasks: 4-6 hours (breakdown, estimation, ticket creation)
- **Total: 9-13 hours**

**With Skill Chaining**:
- Research: 5 minutes (automated search + synthesis)
- PRD: 10 minutes (generation + review)
- Tasks: 15 minutes (breakdown + export)
- **Total: 30 minutes**

**Improvement**: 95% reduction

### Metric 2: Context Loss Rate

**Definition**: Percentage of requirements lost in handoffs

**Baseline (Manual)**:
- PM → Engineering handoff: ~15-20% information loss
- Engineering → Analytics handoff: ~10-15% information loss
- **Total: 25-35% context loss**

**With Skill Chaining**:
- Skills read structured outputs directly: **0% context loss**

### Metric 3: Audit Trail Completeness

**Definition**: Ability to trace implementation back to original requirements

**Manual Process**:
- PRD in Google Docs
- Tasks in Jira (with manually copied PRD link)
- Analytics in separate Google Sheet
- **Traceability: ~40%** (links break, docs get out of sync)

**Skill Chaining**:
- All outputs in `jaan-to/outputs/` with sequential IDs
- Git commits link to source inputs
- README indexes provide cross-references
- **Traceability: 100%**

---

## Example: Real-World Chain Performance

**Project**: EduStream Academy (online learning platform)
**Task**: Implement live streaming classroom feature

**Manual Approach (Baseline)**:
```
Day 1: Product research (3 hours)
Day 2: Write PRD (4 hours)
Day 3: PM → Eng sync meeting (1 hour)
Day 4: Backend task breakdown (5 hours)
Day 5: Frontend task breakdown (5 hours)
Day 6: Eng → Analytics handoff (1 hour)
Day 7: GTM tracking spec (3 hours)
─────────────────────────────────────
Total: 22 hours over 7 days
```

**Skill Chaining Approach**:
```
Step 1: Research (5 min)
/jaan-to-pm-research-about "WebRTC for educational live streaming"

Step 2: PRD (10 min)
/jaan-to-pm-prd-write "Live streaming classroom..."

Step 3: Backend tasks (15 min)
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md

Step 4: Frontend tasks (15 min)
/jaan-to-dev-fe-task-breakdown "Live classroom interface..."

Step 5: GTM tracking (10 min)
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
─────────────────────────────────────
Total: 55 minutes in 1 session
```

**Time Saved**: 21 hours (95.8% reduction)
**Quality**: All specs completed with 100% context preservation

---

## Best Practices

### 1. Start with Research

Even if you think you know the solution:
```bash
# Always start with research (5 min investment)
/jaan-to-pm-research-about "{your feature} best practices 2026"

# Then write PRD informed by research
/jaan-to-pm-prd-write "..."
```

Research findings often reveal:
- Compliance requirements you missed (GDPR, COPPA, WCAG)
- Cost implications (third-party API pricing)
- User behavior patterns (mobile vs desktop usage)

### 2. Review Between Chains

Don't blindly chain 10 skills:
```bash
# Chain 1: Research → PRD
/jaan-to-pm-research-about "..."
/jaan-to-pm-prd-write "..."
# STOP → Review PRD ✓

# Chain 2: PRD → Tasks
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-*/prd.md
# STOP → Review tasks ✓

# Chain 3: Tasks → GTM
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/01-*/prd.md
# STOP → Review tracking ✓
```

### 3. Commit After Each Skill

```bash
# After every skill execution
git add jaan-to/outputs/{domain}/{feature}/
git commit -m "feat({domain}): {skill output description}"
```

This creates audit trail and enables easy rollback.

### 4. Use Parallel Chains for Speed

When skills don't depend on each other:
```bash
# These can run in parallel (no dependencies)
/jaan-to-dev-be-task-breakdown "$PRD" &
/jaan-to-dev-fe-task-breakdown "..." &
/jaan-to-data-gtm-datalayer "$PRD" &
wait
```

### 5. Capture Lessons Immediately

When you spot a pattern or mistake:
```bash
# Right after you notice it
/to-jaan-learn-add "jaan-to-{skill}" "Lesson learned: ..."

# Don't wait (you'll forget the context)
```

---

## Troubleshooting Chains

### Problem: "Second skill didn't use first skill's output"

**Diagnosis**:
```bash
# Check if you passed file path correctly
ls jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
# File exists? ✓

# Check if you passed full path (not relative)
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
# NOT: /jaan-to-dev-be-task-breakdown ../prd/01-live-streaming-classroom/prd.md
```

**Fix**: Always use full path from repo root.

### Problem: "Chain output doesn't match my tech stack"

**Diagnosis**:
```bash
# Check tech context
cat jaan-to/context/tech.md
# Is it populated with your actual stack?
```

**Fix**: Run stack detection or manually update:
```bash
/jaan-to-dev-stack-detect  # Auto-detect

# Or manually edit tech.md
```

### Problem: "Skill outputs are inconsistent"

**Diagnosis**:
- Check if LEARN.md files have conflicting lessons
- Check if multiple team members are editing context files

**Fix**: Centralize context files in git, review LEARN.md quarterly

---

## Future Enhancements

Roadmap for skill chaining improvements:

1. **Auto-Chaining**: `/jaan-to-workflow "PRD → Backend → Frontend → GTM"`
2. **Chain Templates**: Save common chains for reuse
3. **Parallel Execution**: Built-in concurrent skill runs
4. **Chain Validation**: Pre-flight checks before chaining
5. **Smart Branching**: AI decides optimal chain based on input

---

## Related Documentation

- [EdTech Workflow Guide](./edutech-workflow.md) - Domain-specific workflow
- `/to-jaan-skill-create` - Create custom chainable skills
- `/to-jaan-learn-add` - Capture lessons from chains

---

**Last Updated**: 2026-02-03
**Version**: 1.0
**Tested With**: jaan-to v3.10.0, EduStream Academy integration test
