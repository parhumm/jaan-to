# EdTech Product Development Workflow

> Complete workflow for building online learning platforms using jaan-to skills

---

## Overview

This guide documents a battle-tested workflow for building EdTech (Educational Technology) products using the jaan-to skill ecosystem. It covers the complete product development lifecycle from initial research through deployment tracking, with real-world examples from building EduStream Academy, a comprehensive online learning platform.

**What You'll Learn**:
- How to chain PM → Dev → UX → Data skills for maximum efficiency
- EdTech-specific considerations (COPPA/FERPA compliance, real-time collaboration, gamification)
- Skill execution patterns that reduce handoff friction
- Common pitfalls and how to avoid them

**Prerequisites**:
- jaan-to plugin installed (v3.10.0+)
- Basic understanding of product development lifecycle
- Familiarity with EdTech domain (helpful but not required)

---

## The Four-Domain Workflow

EdTech projects typically flow through four interconnected domains:

```
┌─────────────────────────────────────────────────────────────┐
│                     1. PRODUCT MANAGEMENT                    │
│  Research → PRD → User Stories → Requirements Validation    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     2. DEVELOPMENT                           │
│  Backend Tasks → Frontend Tasks → Integration Planning      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     3. USER EXPERIENCE                       │
│  Microcopy → Localization → Heatmap Analysis               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     4. DATA & ANALYTICS                      │
│  GTM Tracking → Funnel Analysis → KPI Dashboards           │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Research & Discovery

**Goal**: Understand the problem space, competitive landscape, and technical constraints.

### 1.1 Domain Research

Start with broad domain research to understand EdTech patterns:

```bash
/jaan-to-pm-research-about "online learning platforms student engagement strategies 2026"
```

**EdTech-Specific Research Topics**:
- **Engagement**: Gamification, learning streaks, social features
- **Compliance**: COPPA (students under 13), FERPA (educational records), GDPR
- **Pedagogy**: Spaced repetition, adaptive learning, Bloom's taxonomy
- **Monetization**: B2C subscriptions, B2B enterprise licenses, marketplace models
- **Accessibility**: WCAG 2.1 AA compliance, screen reader support, keyboard navigation

**Output**: `jaan-to/outputs/research/01-product-{topic}.md`

**Real Example**:
```
Topic: "online learning platforms student engagement strategies 2026"
Key Findings:
- Gamification increases course completion by 25-40%
- Live classes have 3x higher engagement than pre-recorded
- Mobile learners complete 15% fewer courses (attention span)
- Cohort-based learning increases social accountability
```

### 1.2 Technical Architecture Research

Research technical stack decisions:

```bash
/jaan-to-pm-research-about "WebRTC vs RTMP for educational live streaming scalability"
```

**EdTech Tech Stack Considerations**:
- **Video Delivery**: WebRTC (low-latency), RTMP (high-scale), HLS (VOD)
- **Real-time Collaboration**: Socket.io, WebSockets, Firebase Realtime Database
- **Content Security**: DRM, token-based access, watermarking
- **Scalability**: CDN for video, edge caching, database sharding

**Output**: `jaan-to/outputs/research/02-technical-{topic}.md`

### 1.3 Stack Detection (Existing Projects)

If working on an existing codebase:

```bash
/jaan-to-dev-stack-detect
```

This populates `jaan-to/context/tech.md` for framework-specific code generation later.

**Example Output**:
```yaml
Backend: Node.js v20.x + Express.js v4.18
Frontend: React v18.2 + Next.js v14.1
Database: PostgreSQL 15.4 + Redis 7.2
Video: Mediasoup v3.13 (WebRTC SFU)
```

---

## Phase 2: Product Requirements

**Goal**: Define features with clear scope, success metrics, and user stories.

### 2.1 Write PRD (Product Requirements Document)

Start with your most critical feature:

```bash
/jaan-to-pm-prd-write "Build a live streaming classroom feature with instructor video/audio, screen sharing, interactive whiteboard, breakout rooms for group activities, real-time chat, and recording capabilities. Support up to 500 concurrent students per class."
```

**PRD Best Practices for EdTech**:
- **Problem Statement**: Start with pedagogical need (e.g., "Students need synchronous interaction to ask questions")
- **Success Metrics**: Course completion rate, engagement time, NPS, learning outcomes
- **Compliance Section**: COPPA age gates, FERPA data handling, accessibility requirements
- **Cost Analysis**: Third-party service costs (Twilio, Agora, Zoom API)
- **Rollout Plan**: Beta with small cohort → Gradual capacity increase

**Output**: `jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md`

**Real Example - Live Streaming Classroom PRD**:
```markdown
## Problem
Students in large online courses feel isolated and struggle to get real-time help. Pre-recorded videos lack the engagement of live instruction.

## Solution
Live streaming classroom supporting 500 concurrent students with:
- Instructor video/audio + screen share
- Interactive whiteboard with collaboration
- Breakout rooms for small-group work
- Real-time chat with moderation
- Recording for later review

## Success Metrics
- Target: 70%+ students attend at least 1 live session per week
- Target: 85%+ session completion rate (stay for >90% of class)
- Target: <200ms latency for real-time interaction

## Compliance
- FERPA: Recordings stored with access controls
- COPPA: Parental consent for users under 13 before camera access
- WCAG AA: Live captions, keyboard-only navigation
```

### 2.2 Break Down into User Stories

Convert PRD into concrete user stories:

```bash
/jaan-to-pm-story-write "Live Streaming Classroom, Instructor starting a scheduled live class"
```

**Story Formats Supported**:
- **Feature + Context**: "Live Streaming, Instructor goes live"
- **Connextra Format**: "As a student, I want to join breakout rooms..."
- **Narrative**: "Student browsing course marketplace to find web dev courses"

**Output**: `jaan-to/outputs/pm/stories/01-instructor-goes-live/stories.md`

**Real Example - Instructor Goes Live Story**:
```gherkin
Feature: Instructor Starting Live Class

Scenario: Instructor starts scheduled class on time
  Given I am an instructor with a scheduled class at 2:00 PM
  And I am on the class dashboard
  When I click "Go Live"
  Then the live stream starts within 3 seconds
  And students receive a notification "Your class is starting"
  And my video/audio preview appears
  And the recording begins automatically
```

### 2.3 Multiple PRDs for Complex Projects

For marketplace-style platforms, create separate PRDs:

```bash
# Core learning experience
/jaan-to-pm-prd-write "Live streaming classroom..."

# Monetization
/jaan-to-pm-prd-write "Course marketplace where instructors publish courses..."

# Personalization
/jaan-to-pm-prd-write "AI-powered content recommendation engine..."
```

**Typical EdTech PRD Set**:
1. Core Learning (video player, progress tracking, assessments)
2. Live Features (streaming, chat, breakouts)
3. Marketplace (course browse, purchase, revenue sharing)
4. Gamification (badges, streaks, leaderboards)
5. Admin Tools (instructor analytics, content moderation)

---

## Phase 3: Backend Development

**Goal**: Break down PRD into backend engineering tasks with clear acceptance criteria.

### 3.1 Backend Task Breakdown from PRD

```bash
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
```

**Interactive Prompts**:
1. **Slicing Strategy**: Vertical (end-to-end features) vs Horizontal (by layer)
   - **Vertical**: Recommended for MVPs (e.g., "Student joins class" includes API + DB + WebSocket)
   - **Horizontal**: Recommended for mature products (e.g., "All database models" → "All APIs" → "All WebSocket handlers")

2. **Scope**: MVP vs In-between vs Production-ready
   - **MVP**: Basic happy path, minimal error handling
   - **Production-ready**: Full error handling, monitoring, load testing

**Output**: `jaan-to/outputs/dev/backend/01-streaming-infrastructure/01-be-tasks-streaming-infrastructure.md`

**Real Example - Streaming Backend Tasks**:
```markdown
## Task 1: WebRTC Signaling Server Setup
**Size**: L (5-8 days)
**Files**:
- `src/signaling/SignalingServer.ts`
- `src/signaling/RoomManager.ts`

**Acceptance Criteria**:
- [ ] Socket.io server handles SDP offer/answer exchange
- [ ] Room manager supports 500 concurrent connections
- [ ] Reconnection logic with state recovery (<5s)
- [ ] Graceful degradation if SFU unavailable

**Data Models**:
```typescript
interface Room {
  id: string;
  instructorId: string;
  participants: Participant[];
  startedAt: Date;
  status: 'waiting' | 'live' | 'ended';
}
```

**Dependencies**: Redis (pub/sub), Mediasoup (SFU)
```

**EdTech Backend Considerations**:
- **Real-time State**: Use Redis pub/sub for cross-server room state
- **Recording**: S3 storage with signed URLs, HLS packaging for playback
- **Scalability**: Horizontal SFU scaling (assign students to least-loaded server)
- **Moderation**: Chat filter (profanity, spam), breakout room monitoring

### 3.2 Export to Project Management Tools

Backend tasks export in 3 formats:
- **Jira CSV**: `backend-tasks-jira.csv` (ready to import)
- **Linear Markdown**: `backend-tasks-linear.md` (paste into Linear)
- **JSON**: `backend-tasks.json` (custom integrations)

---

## Phase 4: Frontend Development

**Goal**: Break down UI into components with state management and interaction patterns.

### 4.1 Frontend Task Breakdown from Description

```bash
/jaan-to-dev-fe-task-breakdown "Live classroom interface with main video player (instructor), participant grid (up to 50 visible), side panel with tabs (chat, participants, polls, resources), floating toolbar (mic, camera, hand raise, screen share), and breakout room modal. Responsive for desktop and tablet."
```

**Interactive Prompts**:
1. **Scope**: MVP vs Production-ready
   - **MVP**: Basic components, inline state, minimal responsive
   - **Production-ready**: Atomic design, Redux state, full responsive + mobile

**Output**: `jaan-to/outputs/dev/frontend/01-live-classroom-ui/01-fe-tasks-live-classroom-ui.md`

**Real Example - Live Classroom UI Tasks**:
```markdown
## Component Inventory (24 components)

### Atoms (7)
- IconButton - Mic, camera, hand raise buttons
- Avatar - Participant thumbnails
- StatusBadge - "Live", "Recording", "Reconnecting"

### Molecules (8)
- VideoTile - Single participant video with name overlay
- ChatMessage - Message with sender, timestamp, avatar
- ToolbarGroup - Grouped action buttons

### Organisms (5)
- ParticipantGrid - 3x4 grid of VideoTiles (50 visible + pagination)
- ChatPanel - MessageList + ChatInput + scroll-to-bottom
- MainVideoPlayer - Instructor video with controls

### Templates (2)
- LiveClassroomLayout - Main stage + sidebar + toolbar
- BreakoutRoomModal - Overlay for small group work

### Pages (2)
- LiveClassPage - Full experience
- WaitingRoomPage - Pre-class holding area
```

**EdTech Frontend Considerations**:
- **Performance Budget**: LCP ≤2.5s (critical for engagement)
- **Accessibility**: Keyboard-only navigation, ARIA live regions for chat
- **Responsive Design**: Desktop-first (70% traffic), tablet support, mobile view-only
- **Real-time Updates**: WebSocket connection state, optimistic UI updates

### 4.2 State Management Matrix

Frontend breakdown includes Redux state slices:

```typescript
// streamSlice.ts
{
  roomId: string | null,
  participants: Participant[],
  localStream: MediaStream | null,
  connectionQuality: 'excellent' | 'good' | 'poor',
  isRecording: boolean
}

// chatSlice.ts
{
  messages: Message[],
  unreadCount: number,
  isTyping: Record<string, boolean>
}
```

---

## Phase 5: User Experience

**Goal**: Create multi-language microcopy and analyze user behavior patterns.

### 5.1 Microcopy Generation

Generate UI text for all interactive elements:

```bash
/jaan-to-ux-microcopy-write "Live classroom control labels and tooltips: mute/unmute mic, turn on/off camera, raise hand, screen share, chat, participants list, leave class, breakout rooms, polls, reactions (👍👏❤️), and connection quality indicators."
```

**Interactive Prompts**:
1. **Tone**: Friendly & Encouraging vs Clear & Concise vs Professional & Formal
   - **EdTech Recommendation**: Friendly for onboarding, Clear for controls, Professional for billing
2. **Languages**: Auto-detects from `jaan-to/context/localization.md`

**Output**: `jaan-to/outputs/ux/content/02-live-class-controls/02-microcopy-live-class-controls.md` + `.json`

**Real Example - Live Class Controls Microcopy**:
```markdown
### 1.1 Mute Mic Label
- **EN** (LTR): Mute Mic (8 chars)
- **ES** (LTR): Silenciar Micrófono (20 chars)
- **FR** (LTR): Couper le micro (16 chars)
- **DE** (LTR): Mikrofon stumm (15 chars)

### 11.5 Reconnecting Status
- **EN** (LTR): Reconnecting...
- **ES** (LTR): Reconectando...
- **FR** (LTR): Reconnexion...
- **DE** (LTR): Verbindung wird wiederhergestellt... (38 chars)
```

**EdTech Microcopy Best Practices**:
- **Error Messages**: Be specific (not "Error occurred", but "Your mic is unavailable. Check permissions.")
- **Encouragement**: Celebrate progress ("Great job! You've completed 5 lessons this week!")
- **Accessibility**: Avoid "click here" (say "Select your learning goal")
- **Localization**: German text expands 30-35% (reserve extra width)

### 5.2 Heatmap Analysis (Post-Launch)

Analyze user interaction patterns:

```bash
/jaan-to-ux-heatmap-analyze
```

Upload CSV (aggregated clicks or raw coordinates) + screenshot.

**EdTech Heatmap Use Cases**:
- **Course Browse Page**: Are students using filters or just scrolling?
- **Video Player**: Are students rewatching sections or skipping ahead?
- **Dashboard**: Do students notice recommended courses or ignore them?

**Output**: `jaan-to/outputs/ux/heatmap/01-course-browse-abandonment/01-heatmap-course-browse-abandonment.md`

**Real Example - Insights**:
```markdown
### Finding 1: Filter Sidebar Ignored
**Evidence**: Only 5.6% of clicks on filters despite 40% position prominence
**Hypothesis**: Filters too complex, students prefer search bar
**Recommendation (ICE Score: 8.5)**:
- Impact: 9/10 (could reduce bounce rate by 20%)
- Confidence: 8/10 (supported by A/B test data)
- Ease: 9/10 (2-day implementation)
- Action: Simplify to 3 quick filters (Price, Rating, Category)
```

---

## Phase 6: Analytics & Tracking

**Goal**: Implement comprehensive event tracking for product analytics.

### 6.1 GTM Tracking from PRD

Auto-generate tracking from feature spec:

```bash
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
```

Skill auto-analyzes PRD to identify trackable interactions.

**Output**: `jaan-to/outputs/data/gtm/01-live-class-tracking/01-gtm-live-class-tracking.md`

**Real Example - Live Class Events**:
```javascript
// Event 1: Class Started (impression)
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "live-class",
    item: "session",
    params: {
      session_id: "sess_abc123",
      instructor_id: "inst_456",
      scheduled_participants: 75,
      max_capacity: 500,
      recording_enabled: true
    }
  },
  _clear: true
});

// Event 3: Hand Raised (click)
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "hand-raise",
    action: "Click",
    params: {
      session_id: "sess_abc123",
      student_id: "stud_789",
      queue_position: 3
    }
  },
  _clear: true
});
```

### 6.2 E-commerce Funnel Tracking

For marketplace features, track purchase funnel:

```bash
/jaan-to-data-gtm-datalayer "Track course purchase funnel: course_viewed, preview_watched, add_to_cart, coupon_applied, checkout_started, payment_submitted, purchase_completed"
```

**EdTech Tracking Priorities**:
1. **Engagement Events**: video_played, quiz_attempted, discussion_post
2. **Learning Outcomes**: lesson_completed, skill_mastered, certificate_earned
3. **Retention Events**: daily_login, streak_extended, course_resumed
4. **Revenue Events**: course_purchased, subscription_renewed, upsell_clicked

### 6.3 GA4 Integration

Tracking documents include GA4 event mapping:

```javascript
// Map custom events to GA4 standard events
al.item === "course-detail" → GA4: view_item
al.item === "add-to-cart" → GA4: add_to_cart
al.item === "purchase-completed" → GA4: purchase
```

---

## Skill Chaining Workflows

**Efficiency Tip**: Chain skills to minimize context switching.

### Workflow 1: PRD → Backend → Frontend → GTM

Complete feature development in one flow:

```bash
# 1. Write PRD
/jaan-to-pm-prd-write "Live streaming classroom..."

# 2. Backend tasks from PRD
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md

# 3. Frontend tasks from description
/jaan-to-dev-fe-task-breakdown "Live classroom interface..."

# 4. GTM tracking from PRD
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/01-live-streaming-classroom/prd.md
```

**Time Saved**: ~40% (vs. manual handoffs between PM → Eng → Analytics)

### Workflow 2: Research → PRD → Story → Microcopy

Content-heavy features:

```bash
# 1. Research gamification patterns
/jaan-to-pm-research-about "gamification techniques for adult learning motivation"

# 2. Write PRD incorporating research
/jaan-to-pm-prd-write "AI-powered content recommendations..."

# 3. User story for recommendation flow
/jaan-to-pm-story-write "Student receives personalized learning path recommendation"

# 4. Microcopy for recommendation UI
/jaan-to-ux-microcopy-write "Personalized learning path: headline, CTA, recommendation cards"
```

### Workflow 3: Story → Backend → GTM

Granular feature tracking:

```bash
# 1. Write story
/jaan-to-pm-story-write "Student purchasing a course with saved payment method"

# 2. Backend tasks from story
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/stories/04-payment-processing/stories.md

# 3. GTM tracking from story
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/stories/04-payment-processing/stories.md
```

---

## EdTech-Specific Pitfalls

### Pitfall 1: Ignoring FERPA Compliance

**Problem**: Educational records have strict privacy requirements.

**Solution**:
- Add FERPA section to every PRD that handles student data
- Backend tasks: Include data retention policies (e.g., "Delete recordings after 1 year")
- Tracking: Never log PII in GTM (hash student IDs, avoid full names)

### Pitfall 2: Under-Specifying Real-Time Requirements

**Problem**: "Real-time" means different things (100ms vs 5s acceptable latency).

**Solution**:
- PRD: Specify latency targets (e.g., "Chat messages appear within 500ms")
- Backend tasks: Include reconnection logic, state sync on reconnect
- Frontend tasks: Add connection quality indicators, offline fallbacks

**Lesson Added** (from Phase 7):
```markdown
## Edge Cases (Backend Task Breakdown)
- For real-time features (WebRTC, WebSockets), always include reconnection
  logic, state synchronization on reconnect, and graceful degradation tasks
```

### Pitfall 3: Forgetting Cost Analysis

**Problem**: EdTech uses expensive third-party services (video streaming, AI, live transcription).

**Solution**:
- PRD: Add "Cost Analysis" section with pricing tiers and break-even calculations
- Example: "Twilio costs $0.0015/min/participant → 100 students × 60 min = $9/class → Need $15 course price for profitability"

**Lesson Added** (from Phase 7):
```markdown
## Better Questions (PRD Write)
- When PRD involves third-party services (payment processors, streaming
  providers), always include cost analysis section with pricing tiers and
  break-even calculations
```

### Pitfall 4: English-Only Microcopy

**Problem**: EdTech platforms need localization for global reach.

**Solution**:
- Set up `jaan-to/context/localization.md` early with target languages
- Microcopy skill auto-generates all languages (no extra cost)
- Account for text expansion (German +30%, Turkish +25%)

---

## Complete Example: Building "Live Class Recording Playback"

Let's walk through building a feature end-to-end.

### Step 1: Research (5 min)

```bash
/jaan-to-pm-research-about "video player features for online education playback speed chapter markers"
```

**Key Findings**:
- 65% of students use 1.5x-2x playback speed
- Chapter markers reduce "seek time" by 40%
- Transcript search increases engagement by 25%

### Step 2: PRD (10 min)

```bash
/jaan-to-pm-prd-write "Recorded class playback with variable speed (0.5x-2x), chapter markers, transcript panel with search, note-taking, and bookmark key moments. Support HLS streaming for mobile."
```

**Generated PRD Includes**:
- Problem: Students waste time scrubbing through 2-hour recordings
- Solution: Smart playback features (speed, chapters, search)
- Metrics: Target 80% of students watch at least 50% of recording
- Technical: HLS for adaptive bitrate, S3 + CloudFront for delivery

### Step 3: Backend Tasks (15 min)

```bash
/jaan-to-dev-be-task-breakdown jaan-to/outputs/pm/prd/03-recording-playback/prd.md
```

**Scope**: Production-ready
**Slicing**: Vertical

**Generated Tasks (8 total)**:
1. Recording storage (S3 + metadata DB)
2. HLS transcoding pipeline (FFmpeg + Lambda)
3. Chapter marker CRUD API
4. Transcript generation (AWS Transcribe)
5. Bookmark API (per-user timestamps)
6. Playback analytics (watch time, drop-off points)
7. CDN integration (CloudFront signed URLs)
8. Load testing (1000 concurrent playbacks)

### Step 4: Frontend Tasks (15 min)

```bash
/jaan-to-dev-fe-task-breakdown "Recording playback page with video player (custom controls: speed, quality, chapters), transcript panel (synchronized highlighting, search, click to jump), note-taking sidebar, bookmark toolbar, and mobile responsive"
```

**Generated Components (18 total)**:
- Atoms: PlayButton, SpeedControl, QualitySelector
- Molecules: ChapterList, TranscriptLine, BookmarkButton
- Organisms: VideoPlayer, TranscriptPanel, NoteSidebar
- Pages: RecordingPlaybackPage

**State Management**:
```typescript
// playbackSlice.ts
{
  recordingId: string,
  currentTime: number,
  playbackSpeed: number,
  selectedChapter: Chapter | null,
  transcript: TranscriptSegment[],
  bookmarks: Bookmark[]
}
```

### Step 5: Microcopy (10 min)

```bash
/jaan-to-ux-microcopy-write "Recording playback controls: speed selector (0.5x, 1x, 1.5x, 2x), chapter list, transcript search placeholder, bookmark button, note-taking prompts, and empty states (no chapters, no transcript)"
```

**Tone**: Clear & Concise
**Languages**: EN, ES, FR, DE, ZH, JA, KO (7 languages)

**Generated Microcopy (28 items)**:
- "Playback Speed" → 7 languages
- "Jump to Chapter" → 7 languages
- "Search transcript..." → 7 languages
- "No chapters available for this recording" → 7 languages

### Step 6: GTM Tracking (10 min)

```bash
/jaan-to-data-gtm-datalayer jaan-to/outputs/pm/prd/03-recording-playback/prd.md
```

**Generated Events (9 total)**:
1. recording_started (impression)
2. playback_speed_changed (click)
3. chapter_clicked (click)
4. transcript_searched (click)
5. bookmark_added (click)
6. note_created (click)
7. playback_completed (impression, watch 90%+)
8. playback_abandoned (impression, watch <10%)
9. transcript_download (click)

**KPIs**:
- Completion Rate: (completed / started) × 100 (Target: 60%)
- Avg Watch %: SUM(watch_percentage) / COUNT(sessions) (Target: 70%)
- Feature Adoption: (users_using_speed_chapters_bookmarks / total_users) × 100 (Target: 50%)

### Step 7: Git Commit All Outputs (5 min)

```bash
git add jaan-to/outputs/pm/prd/03-recording-playback/
git add jaan-to/outputs/dev/backend/03-playback-backend/
git add jaan-to/outputs/dev/frontend/03-playback-ui/
git add jaan-to/outputs/ux/content/03-playback-controls/
git add jaan-to/outputs/data/gtm/03-playback-tracking/

git commit -m "feat: Complete specs for recording playback feature

- PRD with HLS streaming and smart playback features
- 8 backend tasks (storage, transcoding, CDN, analytics)
- 18 frontend components (video player, transcript, bookmarks)
- 28 microcopy items in 7 languages
- 9 GTM events for engagement tracking"
```

### Total Time: ~70 minutes

From research to ready-to-implement specs with tracking.

**Without jaan-to**: ~8-12 hours (meetings, handoffs, documentation)
**Time Saved**: ~85%

---

## Maintenance & Iteration

### Adding Lessons to Skills

When you discover a pattern or mistake, capture it:

```bash
/to-jaan-learn-add "jaan-to-pm-prd-write" "Always include mobile responsiveness requirements in EdTech PRDs (70% of learners use mobile at some point)"
```

This lesson will be auto-applied in future PRD generations.

### Updating Documentation

Periodically check for stale docs:

```bash
/to-jaan-docs-update --quick
```

Identifies docs outdated by recent skill changes.

### Roadmap Planning

Add feature requests to roadmap:

```bash
/to-jaan-roadmap-add "Add offline content download and sync capabilities to course player for students with unreliable internet connections"
```

---

## Advanced Patterns

### Pattern 1: Multi-PRD Epic

For large features spanning multiple domains:

```bash
# 1. Core PRD (video streaming)
/jaan-to-pm-prd-write "Live streaming infrastructure..."

# 2. Engagement PRD (gamification)
/jaan-to-pm-prd-write "Gamification layer with badges, streaks, leaderboards..."

# 3. Analytics PRD (instructor insights)
/jaan-to-pm-prd-write "Instructor analytics dashboard showing engagement, completion, quiz scores..."

# 4. Generate master epic story
/jaan-to-pm-story-write "Launch complete live learning platform with streaming, gamification, and analytics"
```

### Pattern 2: Phased Rollout Tracking

Track feature adoption across rollout phases:

```bash
# Phase 1: Internal beta (10 instructors)
/jaan-to-data-gtm-datalayer "Track beta feature usage: feature_enabled, feature_used, feature_feedback_submitted with beta_phase=1"

# Phase 2: Public release (all instructors)
/jaan-to-data-gtm-datalayer "Track general release: feature_adoption_rate, feature_churn, feature_daily_active_users with rollout_phase=2"
```

### Pattern 3: A/B Test Documentation

Document experiments with expected tracking:

```bash
# 1. PRD with two variants
/jaan-to-pm-prd-write "Course recommendation algorithm: A) Collaborative filtering, B) Content-based. Success metric: Click-through rate on recommendations."

# 2. Tracking with variant parameter
/jaan-to-data-gtm-datalayer "Track recommendation clicks with variant (A/B), course_id, position, and conversion within 24 hours"
```

---

## Troubleshooting

### Issue: "Skill outputs don't match my tech stack"

**Solution**: Update `jaan-to/context/tech.md` with your actual stack:

```bash
/jaan-to-dev-stack-detect  # Auto-detect from codebase

# Or manually edit:
# Backend: Ruby on Rails, PostgreSQL, Sidekiq
# Frontend: Vue.js 3, Nuxt 3, Pinia
```

Skills will generate framework-specific code (Rails controllers, Vue components).

### Issue: "PRDs are too generic, not EdTech-specific"

**Solution**: Add domain context to `jaan-to/context/domain.md`:

```yaml
Industry: EdTech (K-12 and Higher Education)
Key Constraints:
- FERPA compliance mandatory
- COPPA for users under 13
- Accessibility (WCAG 2.1 AA)
- Mobile-first (70% traffic)

Terminology:
- "Learner" not "user"
- "Course" not "product"
- "Instructor" not "admin"
```

### Issue: "GTM events don't match our naming convention"

**Solution**: Edit tracking before final approval. Skill follows lowercase-kebab-case by default, but you can request changes during review:

```
Current: "course-detail"
Your Convention: "course_detail_view"
→ Edit params during "Proceed with code generation? [y/n/edit]"
```

---

## Checklist: Launching a New EdTech Feature

Use this checklist for every feature launch:

**Product (PM)**:
- [ ] Research completed (domain + technical)
- [ ] PRD written with compliance section (COPPA/FERPA)
- [ ] User stories with acceptance criteria
- [ ] Cost analysis for third-party services
- [ ] Mobile considerations documented

**Development (Eng)**:
- [ ] Backend tasks with data models and APIs
- [ ] Frontend components with state management
- [ ] Real-time features include reconnection logic
- [ ] Accessibility requirements in component inventory
- [ ] Performance budgets defined (LCP, INP, CLS)

**User Experience (UX)**:
- [ ] Microcopy in all target languages
- [ ] Text expansion accounted for (German +30%)
- [ ] Error messages are specific and helpful
- [ ] Accessibility: ARIA labels, keyboard navigation

**Analytics (Data)**:
- [ ] GTM tracking for all key interactions
- [ ] GA4 event mapping configured
- [ ] Funnel analysis dashboard created
- [ ] GDPR consent checks for tracking PII

**Launch**:
- [ ] All outputs committed to git
- [ ] Feature flag created for gradual rollout
- [ ] Monitoring alerts configured (error rate, latency)
- [ ] Lessons captured in LEARN.md files

---

## Resources

**Related Docs**:
- `/to-jaan-skill-create` - Create custom skills for your domain
- `/to-jaan-docs-update` - Keep documentation fresh
- `/to-jaan-roadmap-add` - Plan future features

**External Resources**:
- [FERPA Compliance Guide](https://www2.ed.gov/policy/gen/guid/fpco/ferpa/index.html)
- [COPPA Requirements](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)
- [WCAG 2.1 AA Checklist](https://www.w3.org/WAI/WCAG21/quickref/)
- [EdTech Design Patterns](https://edtechbooks.org/)

**Support**:
- Questions: [GitHub Issues](https://github.com/yourorg/jaan-to/issues)
- Slack: #jaan-to-support

---

**Last Updated**: 2026-02-03
**Version**: 1.0
**Tested With**: jaan-to v3.10.0, EduStream Academy project
