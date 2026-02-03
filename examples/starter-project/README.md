# jaan.to Starter Project — EduStream Academy Example

**Comprehensive demonstration** of the jaan.to plugin showing real-world outputs from 7+ skills across PM, Dev, UX, QA, and Research roles.

---

## What's This?

This is a **realistic EdTech platform example** with **37 pre-generated files (792KB)** demonstrating jaan.to's full capabilities. Instead of a simple "hello world", you'll see:

✅ **Complete product lifecycle**: Research → PRD → Stories → Tasks → QA
✅ **Multiple domains**: Live streaming, marketplace, AI recommendations
✅ **Advanced features**: WebRTC architecture, payment processing, multi-language UX
✅ **Real tech stack**: Node.js, Express, React, Next.js, PostgreSQL, WebRTC

---

## What's Included

### 📋 Product Management (PM)

**PRDs:**
- `01-live-streaming-classroom` — Real-time video classroom for 500 students
- `02-course-marketplace` — Stripe-integrated course purchasing platform
- `03-ai-content-recommendations` — Personalized learning path engine

**User Stories:**
- `01-instructor-starts-live-class` — Given/When/Then acceptance criteria
- `02-student-joins-breakout-room` — Collaborative learning flows
- `03-student-discovers-course` — Course browsing and filtering
- Plus 3 more stories with INVEST principles

### 💻 Development (Dev)

**Backend Tasks:**
- `01-streaming-infrastructure` — WebRTC SFU setup with Mediasoup
- `02-marketplace-api` — Stripe integration, revenue sharing, escrow

**Frontend Tasks:**
- `01-live-classroom-ui` — Video player, participant grid, chat, whiteboard
- `02-course-marketplace-ui` — Browse, filter, cart, checkout flow

### 🎨 UX Design

**Microcopy Packs:**
- `01-student-onboarding` — 31 UI strings in 7 languages (English, Spanish, French, German, Arabic, Chinese, Japanese)
- `02-live-class-controls` — 36 control labels translated with cultural sensitivity

### ✅ Quality Assurance (QA)

**Test Cases:**
- `01-instructor-goes-live` — BDD scenarios (happy path + edge cases + errors)

### 🔬 Research

**Deep Research Files:**
- `01-product-edtech-engagement` — Student engagement patterns and psychology
- `02-technical-streaming-architecture` — WebRTC implementation best practices
- `03-legal-education-compliance` — COPPA, FERPA compliance requirements
- `04-product-gamification-psychology` — Learning motivation and rewards

### 📅 Roadmap

**4 Completed Phases:**
- Phase 1: Foundation (stack detection, domain research)
- Phase 2: Core features (3 PRDs with user stories)
- Phase 3: Development specs (backend + frontend task breakdowns)
- Phase 4: UX (multi-language microcopy)

---

## Tech Stack (EduStream Academy)

**Backend:**
- Node.js v20.x LTS
- Express.js v4.18
- Socket.io v4.6 (WebRTC signaling)
- Mediasoup v3.13 (SFU video routing)

**Frontend:**
- TypeScript v5.3
- React v18.2 + Next.js v14.1
- Redux Toolkit v2.0
- TailwindCSS v3.4

**Infrastructure:**
- PostgreSQL 15.4 (RDS)
- Redis 7.2 (ElastiCache)
- RabbitMQ 3.12 (Amazon MQ)
- AWS (ECS, CloudFront, S3)

**Performance Requirements:**
- WebRTC latency: <200ms p95 for 500 concurrent users
- API response: <100ms p95
- Session init: <10 seconds
- COPPA/FERPA compliance

---

## Installation

### 1. Install jaan.to Plugin

```bash
# From marketplace
claude
/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to

# Or local development
claude --plugin-dir /path/to/jaan-to
```

### 2. Copy This Example

```bash
# Create test directory
mkdir -p ~/edustream-demo
cd ~/edustream-demo

# Copy the jaan-to directory
cp -r /path/to/jaan-to/examples/starter-project/jaan-to .
```

### 3. Start Claude Code

```bash
cd ~/edustream-demo
claude
```

The bootstrap hook will detect the existing `jaan-to/` directory and skip re-initialization.

---

## Explore the Outputs

### View PRDs

```bash
# Live streaming classroom PRD
cat jaan-to/outputs/pm/prd/01-live-streaming-classroom/01-prd-live-streaming-classroom.md

# Course marketplace PRD
cat jaan-to/outputs/pm/prd/02-course-marketplace/02-prd-course-marketplace.md
```

**What to notice:**
- Executive summary with key metrics
- Problem statement with user research
- Technical approach with WebRTC architecture
- Security considerations (DTLS-SRTP encryption)
- Testing plan (unit, integration, E2E)

### View User Stories

```bash
cat jaan-to/outputs/pm/stories/01-instructor-starts-live-class/01-story-instructor-starts-live-class.md
```

**What to notice:**
- Given/When/Then acceptance criteria
- INVEST principles (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- Edge cases and error scenarios
- Links to parent PRD

### View Task Breakdowns

```bash
# Frontend tasks
cat jaan-to/outputs/dev/frontend/01-live-classroom-ui/01-frontend-tasks-live-classroom-ui.md

# Backend tasks
cat jaan-to/outputs/dev/backend/01-streaming-infrastructure/01-backend-tasks-streaming-infrastructure.md
```

**What to notice:**
- Component inventory (hierarchy and responsibilities)
- State management plan (Redux slices, actions)
- API integration points
- Story point estimates per task
- Testing requirements

### View Research

```bash
cat jaan-to/outputs/research/02-technical-streaming-architecture.md
```

**What to notice:**
- Research question and scope
- Key findings with source citations
- Technical recommendations
- Implementation considerations

### View Roadmap

```bash
cat jaan-to/roadmap.md
```

**What to notice:**
- 4 completed phases with tasks marked [x]
- Progression from research → PRD → implementation → UX
- Organized by goals and deliverables

---

## Try These Commands

### Generate a New PRD

```
/jaan-to-pm-prd-write "Add real-time collaborative whiteboard for breakout rooms"
```

**What happens:**
1. Reads `jaan-to/context/tech.md` (Node.js, Express, React, WebRTC stack)
2. Reads existing PRDs to understand EduStream Academy domain
3. Generates PRD matching the established pattern
4. Saves to `jaan-to/outputs/pm/prd/04-collaborative-whiteboard/`

**Expected output:** 8-10 page PRD with WebRTC data channels, canvas API, conflict resolution

---

### Generate User Stories from Existing PRD

```
/jaan-to-pm-story-write from prd at jaan-to/outputs/pm/prd/03-ai-content-recommendations/
```

**What happens:**
1. Reads PRD 03 (AI content recommendations)
2. Extracts user flows and acceptance criteria
3. Generates stories with Given/When/Then format
4. Saves to `jaan-to/outputs/pm/stories/07-ai-learning-path/`

---

### Break Down Backend Tasks

```
/jaan-to-dev-be-task-breakdown from prd at jaan-to/outputs/pm/prd/01-live-streaming-classroom/
```

**What happens:**
1. Reads PRD 01 (live streaming)
2. Analyzes technical approach (WebRTC, Socket.io, Mediasoup)
3. Generates task breakdown with API endpoints, data models, services
4. References your Node.js/Express patterns from `tech.md`
5. Saves to `jaan-to/outputs/dev/backend/03-streaming-tasks/`

---

### Generate QA Test Cases

```
/jaan-to-qa-test-cases from prd at jaan-to/outputs/pm/prd/02-course-marketplace/
```

**What happens:**
1. Reads PRD 02 (marketplace) acceptance criteria
2. Generates BDD scenarios in Gherkin format
3. Includes happy path, edge cases, and error scenarios
4. Covers payment flows, revenue sharing, refunds
5. Saves to `jaan-to/outputs/qa/02-marketplace-test-cases/`

---

### Analyze UX Heatmap

If you have heatmap data:

```
/jaan-to-ux-heatmap-analyze path/to/homepage-clicks.csv
```

**What it does:**
- Identifies click patterns and engagement zones
- Detects usability issues (low CTA engagement, high scroll depth)
- Suggests UI improvements

---

## Customizing for Your Project

### Option 1: Use as Learning Example

Keep the EduStream Academy example intact and explore it to understand jaan.to's capabilities.

### Option 2: Adapt to Your Domain

Edit the context files to match your project:

```bash
# Update tech stack
vim jaan-to/context/tech.md

# Update team structure
vim jaan-to/context/team.md

# Clear existing outputs
rm -rf jaan-to/outputs/*
rm -rf jaan-to/roadmap.md

# Start fresh with your domain
```

### Option 3: Auto-Detect Your Stack

If you have an existing codebase:

```
/jaan-to-dev-stack-detect
```

This scans your project files and auto-populates `tech.md` with detected languages, frameworks, and patterns.

---

## Learning System

As you use skills, capture lessons:

```
/to-jaan-learn-add "Always include breakout room capacity limits in live streaming PRDs - prevents scaling issues"
```

Lessons accumulate in `jaan-to/learn/{skill-name}.learn.md` and improve skill execution over time.

---

## Output Directory Structure

```
jaan-to/
├── context/              # Project context (customizable)
│   ├── tech.md          # Node.js, Express, React, WebRTC stack
│   ├── team.md          # Team structure (optional, not in this example)
│   ├── integrations.md  # Git config (minimal)
│   ├── localization.template.md
│   └── tone-of-voice.template.md
├── outputs/              # Generated files (37 markdown files, 792KB)
│   ├── pm/
│   │   ├── prd/         # 3 PRDs (streaming, marketplace, AI)
│   │   └── stories/     # 6 user stories
│   ├── dev/
│   │   ├── backend/     # 2 task breakdowns (streaming, marketplace)
│   │   └── frontend/    # 2 task breakdowns (classroom UI, marketplace UI)
│   ├── ux/
│   │   └── microcopy/   # 2 packs (onboarding, live class controls)
│   ├── qa/
│   │   └── test-cases/  # 1 BDD scenario file
│   └── research/        # 4 deep research files
├── roadmap.md           # 4 completed phases
├── docs/
│   ├── STYLE.md        # Documentation style guide
│   └── create-skill.md # Skill creation spec
└── learn/              # Learning seeds (not modified in this example)
```

---

## Why This Example?

### Complexity Demonstration

**Simple auth example** (alternative):
- 1 PRD (user authentication)
- Basic tech stack (Python/FastAPI)
- Demonstrates 1-2 skills

**EduStream Academy** (this example):
- 3 PRDs across multiple domains (streaming, marketplace, AI)
- Advanced tech stack (WebRTC, real-time, video routing)
- Demonstrates 7+ skills (PRD write, stories, BE/FE tasks, microcopy, research, QA)
- Shows progression through product lifecycle
- Real-world complexity (compliance, performance, security)

### Domain Diversity

- **Live Streaming:** WebRTC architecture, latency requirements, breakout rooms
- **Marketplace:** Stripe integration, revenue sharing, refunds, escrow
- **AI Recommendations:** ML model integration, personalization, A/B testing
- **Compliance:** COPPA (users <13), FERPA (educational records)

### Skill Coverage

| Skill | Demonstrated | Example File |
|-------|--------------|--------------|
| `/jaan-to-pm-prd-write` | ✅ | 3 PRDs (01, 02, 03) |
| `/jaan-to-pm-story-write` | ✅ | 6 stories |
| `/jaan-to-dev-be-task-breakdown` | ✅ | Backend tasks (streaming, marketplace) |
| `/jaan-to-dev-fe-task-breakdown` | ✅ | Frontend tasks (classroom, marketplace) |
| `/jaan-to-ux-microcopy-write` | ✅ | 2 packs (31 + 36 items, 7 languages) |
| `/jaan-to-pm-research-about` | ✅ | 4 research files |
| `/jaan-to-qa-test-cases` | ✅ | 1 test case file |

---

## Next Steps

1. **Explore the outputs** — Read through PRDs, stories, tasks to understand depth
2. **Try generating new content** — Add a 4th PRD or generate tasks from existing PRD
3. **Customize context** — Edit `tech.md` to match your actual stack
4. **Capture lessons** — Use `/to-jaan-learn-add` after using skills
5. **Read full docs** — See [../../docs/README.md](../../docs/README.md)

---

## Questions?

- [Documentation](../../docs/README.md)
- [Skills Reference](../../docs/skills/README.md)
- [Creating Skills](../../docs/extending/create-skill.md)
- [GitHub Issues](https://github.com/parhumm/jaan-to/issues)

---

*Give soul to your workflow.*
