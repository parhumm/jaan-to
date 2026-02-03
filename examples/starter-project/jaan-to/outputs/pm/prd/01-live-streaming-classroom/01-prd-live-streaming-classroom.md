# PRD: Live Streaming Classroom Feature

**ID**: 01
**Status**: Draft
**Owner**: Product Team
**Created**: 2026-02-03
**Last Updated**: 2026-02-03

---

## Executive Summary

EduStream Academy will launch a live streaming classroom feature enabling real-time instruction for up to 500 concurrent students per session. The feature addresses critical engagement gaps in online education by providing instructor video/audio, screen sharing, interactive whiteboard, breakout rooms, real-time chat, and session recording. This positions EduStream Academy as a comprehensive synchronous learning platform competing directly with Zoom Education and Google Classroom while maintaining superior engagement features.

**Key Success Metrics**: 70%+ active participation rate, <200ms latency at scale, 85%+ session completion, 60%+ breakout room adoption within 3 months.

---

## Problem Statement

### Current State

Online learning platforms face three critical challenges:

1. **Isolation & Disengagement**: Students in asynchronous-only environments report feeling disconnected from instructors and peers, leading to 40-60% dropout rates in online courses. Research shows students need real-time interaction to maintain motivation and accountability.

2. **Limited Collaboration Tools**: Existing platforms offer either live video (Zoom) OR learning management (Canvas/Blackboard) but rarely integrate both seamlessly. Instructors must juggle multiple tools, creating friction and reducing instructional time.

3. **Scalability vs. Interactivity Trade-off**: Platforms scaling to 500+ participants typically sacrifice interactive features (breakout rooms, whiteboards, individual attention). Small-group tools don't scale economically for large courses.

### Impact

**For Students:**
- 55% report difficulty staying engaged without live interaction (EdTech Engagement Research, 2026)
- Group project collaboration requires switching between 3-4 different tools
- Lack of real-time feedback delays learning and compounds confusion

**For Instructors:**
- 2-3 hours/week lost to tool-switching and troubleshooting
- Cannot effectively facilitate discussions with 100+ students simultaneously
- Limited ability to assess real-time comprehension and adjust pacing

**For Institution:**
- Lower course completion rates (40-50% vs. 80%+ for in-person)
- Higher support costs from fragmented tool ecosystem
- Competitive disadvantage against platforms offering integrated live learning

### User Research

From student interviews (n=50, January 2026):
- 82% prefer live sessions with recording over asynchronous-only
- 73% want small group breakout functionality for discussions
- 68% cite "ability to ask questions in real-time" as top engagement driver

---

## Solution Overview

### What We're Building

A fully-integrated live streaming classroom feature within EduStream Academy that enables:

**Core Live Streaming:**
- HD video/audio broadcasting from instructor to up to 500 concurrent students
- Low-latency (<200ms) WebRTC-based streaming optimized for educational content
- Adaptive bitrate streaming ensuring quality across varying connection speeds
- Instructor controls: mute all, spotlight student, record session

**Interactive Tools:**
- **Screen Sharing**: Instructor shares slides, applications, or entire desktop with annotation capabilities
- **Interactive Whiteboard**: Real-time collaborative canvas for diagrams, equations, visual explanations with undo/redo, shapes, text, drawing tools
- **Real-time Chat**: Text communication with message moderation, emoji reactions, threaded replies, and @mentions
- **Hand Raising**: Virtual hand-raise queue with instructor acknowledgment and promotion to speak
- **Polls & Quizzes**: In-session quick assessments with real-time results display

**Breakout Rooms:**
- Instructor creates 2-50 breakout rooms with manual or auto-assignment
- Students collaborate in small groups (2-10 per room) with video, audio, chat, and whiteboard
- Instructor can broadcast messages to all rooms, visit rooms individually, and set time limits
- Automatic return to main session with notification

**Recording & Playback:**
- Cloud-based session recording capturing video, audio, screen shares, whiteboard, and chat
- Post-session playback with chapter markers, searchable transcripts (Phase 2), and downloadable files
- Recording consent workflow compliant with COPPA/FERPA regulations

### How It Works

**Pre-Session:**
1. Instructor schedules class via EduStream dashboard (date, time, duration, max capacity)
2. Students receive calendar invites with join link and pre-session reminders
3. System performs connectivity pre-check for instructor and early joiners

**During Session:**
1. Instructor starts broadcast; students join via web browser (no downloads)
2. Main classroom view: instructor video (large), participant grid (thumbnails), side panel (chat/participants/resources)
3. Instructor uses toolbar to toggle mic/camera, share screen, launch whiteboard, create polls
4. Students interact via chat, hand raising, reactions, and designated speaking slots
5. Instructor creates breakout rooms for group activities (5-15 min typically)
6. System records entire session automatically with optional manual pause

**Post-Session:**
1. Recording processes and becomes available within 5 minutes
2. Students access recording library with playback controls (speed, chapters, captions)
3. Instructor reviews engagement analytics (attendance, chat activity, poll results, breakout participation)

### Why This Solves The Problem

**Addresses Isolation:**
- Real-time video presence and interaction recreate classroom dynamics
- Breakout rooms enable peer-to-peer collaboration missing in asynchronous learning
- Research shows 86% attendance with gamification + live sessions vs. 61% without (Gamification Research, 2026)

**Consolidates Tools:**
- Single integrated platform eliminates tool-switching friction
- Instructors save 2-3 hours/week previously lost to juggling Zoom + LMS + collaborative docs
- Students experience seamless workflow from joining to breakout to recording access

**Scales Interactivity:**
- Architecture supports 500 concurrent participants without degrading performance
- Breakout rooms enable small-group discussion even in large courses
- Selective video/audio permissions optimize bandwidth while maintaining engagement

---

## Success Metrics

| Metric | Target | Measurement Method | Timeline |
|--------|--------|-------------------|----------|
| **Active Participation Rate** | 70%+ | % of students who chat, raise hand, or speak during session | 30 days post-launch |
| **System Latency (p95)** | <200ms | WebRTC latency monitoring for instructor → student video/audio | Continuous |
| **Session Completion Rate** | 85%+ | % of students staying for ≥90% of scheduled session duration | 60 days post-launch |
| **Breakout Room Adoption** | 60%+ | % of sessions utilizing breakout rooms at least once | 90 days post-launch |
| **Recording Playback Rate** | 50%+ | % of students who watch recording within 7 days of live session | 60 days post-launch |
| **Instructor Satisfaction (NPS)** | 40+ | Net Promoter Score from post-session instructor surveys | 90 days post-launch |
| **Time to Join (p95)** | <30 seconds | Time from clicking join link to video stream visible | Continuous |
| **Connection Stability** | 95%+ | % of sessions with <2% participant disconnections | Continuous |

**Leading Indicators:**
- Week 1: 200+ live sessions hosted
- Week 4: Average session size 75 students
- Week 8: 40% of courses adopt live sessions as primary format

---

## Scope

### In Scope (MVP)

**Technical Delivery:**
- WebRTC-based video streaming infrastructure supporting 500 concurrent users per session
- Signaling server for WebRTC connection management and room orchestration
- TURN/STUN server configuration for NAT traversal
- Adaptive bitrate streaming (360p-1080p based on bandwidth)

**User-Facing Features:**
- Instructor broadcast (video, audio, screen share)
- Student participation (view stream, text chat, hand raising, reactions)
- Interactive whiteboard with basic tools (pen, shapes, text, eraser, undo/redo)
- Breakout room system (create, assign, monitor, broadcast, time limits)
- Session recording and cloud storage
- Recording playback with basic controls (play/pause, speed, progress bar)
- Attendance tracking and basic engagement metrics

**User Roles & Permissions:**
- Instructor: Full session control (mute, kick, promote, record, breakout)
- Student: Participate with moderated permissions (raise hand to speak, chat always-on)
- Guest: View-only mode for auditors or parents (no interaction)

**Platform Support:**
- Desktop web browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- Tablet web browsers (iPad Safari, Android Chrome)
- Responsive design for screens 1024px+ wide

**Compliance & Privacy:**
- COPPA-compliant recording consent workflows for users <13
- FERPA-compliant data handling for educational records
- Session data retention: 90 days default, configurable by institution

### Out of Scope (Future Phases)

**Phase 2 (Q3 2026):**
- Mobile native apps (iOS, Android)
- Automated transcription and closed captions
- Multi-language real-time translation
- AI-powered noise suppression and background blur
- Integration with external LMS (Canvas, Blackboard, Moodle)

**Phase 3 (Q4 2026+):**
- Breakout room recording (currently only main session)
- Whiteboard templates and lesson plan library
- Advanced analytics (sentiment analysis, engagement heatmaps, attention tracking)
- Instructor copilot (AI suggestions for pacing, breakout timing, poll questions)

**Explicitly NOT Included:**
- Recorded lecture editing or post-production tools (use external video editors)
- Test proctoring or anti-cheating surveillance (separate product consideration)
- Physical classroom hybrid integration (cameras/mics in physical spaces)
- Third-party plugin marketplace (security and compliance concerns)

---

## User Stories

### Story 1: Instructor Starts Live Session

**As an** instructor
**I want to** start a scheduled live class and see my students join
**So that** I can begin teaching with real-time interaction and visual engagement

**Acceptance Criteria:**
- Given I have a scheduled session, when I click "Start Class" 5 minutes before start time, then the session initializes and generates a join link
- Given the session is live, when students click the join link, then they enter a lobby and I can admit them individually or all at once
- Given students are admitted, when I view the participant list, then I see real-time count, names, and connection status (green/yellow/red indicators)
- Given I am broadcasting, when I toggle my camera or mic, then the change reflects instantly for all students with <200ms latency

**Priority**: P0 (Must-Have)
**Estimated Effort**: 8 points
**Dependencies**: WebRTC infrastructure, signaling server, user authentication system

---

### Story 2: Student Participates in Breakout Room Discussion

**As a** student
**I want to** join a breakout room for small group discussion and then return to the main session
**So that** I can collaborate with peers on exercises without distraction from the full class

**Acceptance Criteria:**
- Given the instructor creates breakout rooms, when I am assigned to Room 3, then I automatically transition to a 5-person video/audio space
- Given I am in a breakout room, when I share ideas via video/chat, then my 4 groupmates see and hear me in real-time with the same latency as main session
- Given we are discussing, when the instructor broadcasts "2 minutes remaining", then I see a persistent notification without audio interruption
- Given time expires, when the instructor closes breakout rooms, then I automatically return to main session with a smooth transition (no re-authentication)

**Priority**: P0 (Must-Have)
**Estimated Effort**: 13 points
**Dependencies**: Room management system, WebRTC multi-room routing, notification service

---

### Story 3: Instructor Uses Interactive Whiteboard for Visual Explanation

**As an** instructor
**I want to** draw diagrams and equations on a shared whiteboard during my lecture
**So that** I can explain complex visual concepts that are difficult to convey with words alone

**Acceptance Criteria:**
- Given I am presenting, when I click "Open Whiteboard", then a full-screen collaborative canvas appears for all students with a 5-tool toolbar (pen, eraser, shapes, text, undo)
- Given I draw a diagram, when I add shapes and annotations, then all students see my strokes in real-time with <500ms latency
- Given a student asks to contribute, when I grant whiteboard permission, then they can add to the canvas and I can see their changes immediately
- Given the session ends, when I save the whiteboard, then it exports as PNG and embeds in the session recording at the correct timestamp

**Priority**: P1 (Should-Have)
**Estimated Effort**: 8 points
**Dependencies**: Real-time canvas synchronization library, WebSocket infrastructure, recording integration

---

### Story 4: Student Watches Recorded Session After Missing Live Class

**As a** student who missed the live session
**I want to** watch the full recording with all visual elements (video, screen shares, whiteboard)
**So that** I can catch up on the material and learn asynchronously without losing context

**Acceptance Criteria:**
- Given a session was recorded, when I navigate to the course page, then I see a "Recordings" tab with all past sessions listed chronologically
- Given I click on a recording, when the player loads, then I see synchronized video (instructor), screen shares, and whiteboard as they appeared live
- Given I am watching, when I adjust playback speed to 1.5x, then audio pitch remains natural and video playback is smooth
- Given I return later, when I resume the recording, then playback starts where I left off with a "Resume" button

**Priority**: P1 (Should-Have)
**Estimated Effort**: 5 points
**Dependencies**: Cloud recording processing, video player component, user progress tracking

---

### Story 5: Instructor Monitors Engagement During Large Lecture

**As an** instructor teaching 300 students
**I want to** see real-time engagement signals (chat activity, hand raises, reactions)
**So that** I can gauge comprehension and adjust my teaching pace accordingly

**Acceptance Criteria:**
- Given I am teaching, when I glance at the side panel, then I see a live activity feed showing recent chats, hand raises (count in queue), and reaction emojis with timestamps
- Given multiple students raise hands, when I view the queue, then I see names in order raised with a "Call On" button next to each
- Given I run a poll, when students respond, then I see real-time results update as a bar chart with percentage distribution
- Given engagement drops (no chat for 3+ minutes), when the system detects this, then I receive a subtle alert suggesting a poll or question break

**Priority**: P1 (Should-Have)
**Estimated Effort**: 5 points
**Dependencies**: Activity aggregation service, real-time analytics dashboard, notification service

---

### Story 6: Student Joins from Low-Bandwidth Connection

**As a** student with a slow internet connection (2 Mbps)
**I want to** participate in the live session with acceptable quality
**So that** I can learn without constant buffering or being excluded due to technical limitations

**Acceptance Criteria:**
- Given my connection is 2 Mbps, when I join the session, then the system auto-detects bandwidth and streams video at 360p resolution
- Given the stream is at 360p, when the instructor shares screen with slides, then text remains readable and updates are smooth
- Given I want to reduce data usage further, when I toggle "Audio Only" mode, then video stops but I continue hearing the instructor with no interruptions
- Given my connection improves mid-session, when bandwidth increases to 5 Mbps, then the system automatically upgrades me to 720p within 30 seconds

**Priority**: P0 (Must-Have)
**Estimated Effort**: 8 points
**Dependencies**: Adaptive bitrate streaming, bandwidth detection service, quality level fallback logic

---

## Technical Architecture

### High-Level Components

**Frontend (Web Client):**
- React-based single-page application
- WebRTC peer connection management
- Real-time UI updates via WebSocket
- Canvas-based whiteboard rendering
- HTML5 video player for recordings

**Backend Services:**
- **Signaling Server**: WebSocket server managing WebRTC offer/answer exchange, room state, user presence
- **Media Server**: Selective Forwarding Unit (SFU) for efficient multi-party video routing (Mediasoup or Janus)
- **Recording Service**: Streams capture, encoding (H.264), and upload to cloud storage
- **Chat & Events Service**: Real-time message broadcast, hand raise queue, poll aggregation
- **Room Orchestration**: Breakout room creation, assignment, lifecycle management

**Infrastructure:**
- WebRTC TURN/STUN servers for NAT traversal
- CDN for recording distribution
- Cloud storage (S3 or equivalent) for recordings
- Redis for session state and real-time caching
- PostgreSQL for session metadata, attendance, analytics

### Data Flow: Student Joins Session

1. Student clicks join link → Web client authenticates via JWT token
2. Client requests session metadata from API (instructor, start time, permissions)
3. Client establishes WebSocket connection to Signaling Server
4. Signaling Server sends room state (current participants, chat history, whiteboard state)
5. Client initiates WebRTC peer connection: offer → Signaling Server → SFU → answer → Client
6. SFU begins forwarding instructor's video/audio stream to student with adaptive bitrate
7. Student's UI renders video player, chat panel, participant list, and interaction controls
8. Client subscribes to real-time events (new chat messages, hand raises, breakout assignments) via WebSocket

### Scalability Considerations

**Per-Session Limits:**
- 500 concurrent students per session (SFU can handle with 4-core instance)
- 50 concurrent breakout rooms (10 students each maximum)
- 100 messages/second chat throughput

**Infrastructure Scaling:**
- Horizontal SFU scaling: Route sessions to multiple SFU instances based on session ID hash
- Database read replicas for analytics queries
- CDN caching for recordings (99% cache hit rate target)

### Security & Privacy

**Authentication & Authorization:**
- JWT tokens with 1-hour expiration for session access
- Role-based permissions (Instructor, Student, Guest) enforced at API and WebRTC layer
- Session join links expire 15 minutes after scheduled end time

**Data Protection:**
- All video/audio streams encrypted via DTLS-SRTP (WebRTC standard)
- Chat messages encrypted in transit (TLS) and at rest
- Recording files encrypted at rest with AES-256
- COPPA compliance: Parental consent workflow for users <13 before recording

**Privacy Controls:**
- Students can disable their own camera/mic at any time
- Instructor can mute individual students or all at once
- Recording opt-out: Students can request exclusion from recording (audio/video muted in recorded file)

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Required By |
|------------|-------|--------|-------------|
| User Authentication System | Auth Team | ✅ Available | Week 1 |
| Course Management API | Platform Team | ✅ Available | Week 2 |
| Analytics Dashboard | Data Team | 🔄 In Progress | Week 6 |
| Mobile Responsive Framework | Frontend Team | 🔄 In Progress | Week 4 |

### External Dependencies

| Dependency | Provider | Purpose | Cost Estimate |
|------------|----------|---------|---------------|
| WebRTC SFU (Mediasoup) | Open Source | Media server for video routing | Free (self-hosted) |
| TURN/STUN Servers | Twilio or Xirsys | NAT traversal | $0.004/min/user → ~$500/mo at scale |
| Cloud Storage (S3) | AWS | Recording storage | $0.023/GB → ~$200/mo for 10TB |
| CDN (CloudFront) | AWS | Recording delivery | $0.085/GB transfer → ~$400/mo |
| **Total Monthly Cost** | | | **~$1,100/mo** (1,000 sessions, 75 students avg, 60 min avg) |

### Third-Party Integrations

**Future Phase:**
- Calendar integrations (Google Calendar, Outlook) for session scheduling
- LMS integrations (Canvas, Blackboard) for roster import and grade sync
- SSO providers (Google Workspace, Microsoft 365) for enterprise authentication

---

## Open Questions

### Technical

1. **Recording Storage Lifecycle**: Should we auto-delete recordings after 90 days or allow indefinite storage with pricing tiers? *Owner: Product + Finance*

2. **Breakout Room Recording**: Do we record breakout room audio/video in MVP or defer to Phase 2? Student privacy concerns vs. instructor accountability. *Owner: Legal + Product*

3. **Bandwidth Requirements**: Should we enforce minimum bandwidth requirements (1 Mbps) or allow students to attempt joining from any connection? Impact on experience vs. accessibility. *Owner: Engineering + UX*

4. **Browser Compatibility**: Do we support IE11 and older Safari versions with polyfills, or enforce modern browsers only? Reduces dev time but excludes 5-8% of users. *Owner: Engineering + Analytics*

### Product

5. **Pricing Model**: Will live streaming be available on all plans or premium tier only? Impacts revenue but also competitive positioning. *Owner: Product + Finance*

6. **Session Size Caps**: Should we allow 1,000+ student sessions with degraded features (no breakout rooms), or hard cap at 500? Enterprise demand vs. technical feasibility. *Owner: Product + Sales*

7. **Moderator Role**: Do we introduce a third role (Teaching Assistant / Moderator) who can manage chat, hand raises, and breakout rooms without full instructor permissions? Frequent request in higher ed. *Owner: Product + User Research*

### Compliance

8. **COPPA Consent**: For K-12 institutions, do we require school district-level consent or individual parent consent for recording? Legal interpretation varies by state. *Owner: Legal + Compliance*

9. **Data Residency**: Do we offer region-specific data storage (EU, US, APAC) for recordings to comply with GDPR and local laws, or US-only in MVP? *Owner: Legal + Engineering*

---

## Success Criteria

**Phase 1 (Weeks 1-4): Alpha Launch**
- ✅ 50 instructor pilot users successfully host 200+ sessions
- ✅ System maintains <200ms latency at 100 concurrent users per session
- ✅ Zero critical security vulnerabilities identified in penetration testing
- ✅ 90% of alpha testers rate experience 4/5 or higher

**Phase 2 (Weeks 5-8): Beta Launch**
- ✅ 500 instructors host 2,000+ sessions with 75 avg students
- ✅ 70%+ active participation rate (students chat, raise hand, or speak)
- ✅ 85%+ session completion rate (students stay ≥90% of duration)
- ✅ Breakout rooms used in 40%+ of sessions

**Phase 3 (Weeks 9-12): General Availability**
- ✅ 5,000+ live sessions hosted per week
- ✅ 500 concurrent students per session tested and stable
- ✅ 60%+ of sessions utilize breakout rooms
- ✅ Instructor NPS score 40+ (target)
- ✅ <2% participant disconnection rate per session

**Long-Term (6 Months Post-Launch):**
- ✅ 20,000+ weekly live sessions across platform
- ✅ 50%+ of all courses incorporate live sessions as primary format
- ✅ 80%+ instructor retention rate (continue using after first month)
- ✅ Competitive win rate: 60%+ of evaluations choose EduStream over Zoom Education / Google Classroom

---

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **WebRTC browser compatibility issues** | Medium | High | Extensive cross-browser testing (BrowserStack), fallback to HLS for incompatible browsers |
| **Scalability bottlenecks at 300+ concurrent users** | Medium | High | Load testing from Week 2, horizontal SFU scaling plan, circuit breakers for degraded mode |
| **Recording storage costs exceed budget** | High | Medium | Implement 90-day auto-deletion, offer paid extended storage, compress recordings with H.265 |
| **COPPA compliance violations** | Low | Critical | Legal review of consent workflows, third-party compliance audit, automated age verification |
| **Instructor adoption lower than expected** | Medium | High | Instructor training program, onboarding wizard, 1:1 support for first 100 adopters |
| **Latency spikes during peak hours** | Medium | Medium | CDN for static assets, edge caching for signaling, Redis caching for session state |
| **Data breach or privacy incident** | Low | Critical | Encryption at rest/transit, SOC 2 compliance, penetration testing, incident response plan |

---

## Timeline

**Week 1-2: Infrastructure Setup**
- WebRTC signaling server deployment
- SFU (Mediasoup) setup and configuration
- Database schema for sessions, attendance, recordings

**Week 3-4: Core Streaming MVP**
- Instructor broadcast (video, audio, screen share)
- Student viewing experience with adaptive bitrate
- Basic chat functionality

**Week 5-6: Interactive Features**
- Interactive whiteboard integration
- Hand raise queue and participant list
- Reactions and emoji support

**Week 7-8: Breakout Rooms**
- Room creation and assignment logic
- Multi-room WebRTC routing
- Instructor broadcast to all rooms

**Week 9-10: Recording & Playback**
- Cloud recording capture and encoding
- Playback UI with speed controls
- Recording library and access permissions

**Week 11-12: Polish & Beta Launch**
- Cross-browser testing and bug fixes
- Performance optimization and load testing
- Beta user onboarding and support

---

## Appendix

### Research References

This PRD incorporates insights from the following completed research:

1. **Online Learning Platforms: Student Engagement Strategies 2026** (Research ID: 01)
   - 6-minute video sweet spot, 80% microlearning completion rates
   - 2.5x performance improvement for engaged students
   - Real-time interaction critical for dropout prevention

2. **WebRTC vs RTMP: Educational Live Streaming Architecture** (Research ID: 02)
   - WebRTC recommended for <500 participants with low latency requirements
   - RTMP better for 10,000+ passive viewers
   - Browser compatibility and NAT traversal considerations

3. **COPPA & FERPA Compliance for Online Education Platforms** (Research ID: 03)
   - 2025 amendments require formal security programs and enhanced consent
   - $53,088 per violation penalties for non-compliance
   - April 22, 2026 full compliance deadline

4. **Gamification Techniques for Adult Learning Motivation** (Research ID: 04)
   - 86.25% attendance with gamification + live sessions vs. 61% control
   - Self-Determination Theory alignment (autonomy, competence, relatedness)
   - Avoid competitive leaderboards; use performance dashboards

### Glossary

**Adaptive Bitrate Streaming**: Technology that adjusts video quality in real-time based on viewer's bandwidth, providing the best possible experience without buffering.

**Breakout Room**: A temporary sub-session where a small group of students (typically 2-10) collaborate privately before returning to the main session.

**COPPA**: Children's Online Privacy Protection Act, U.S. law regulating data collection from users under 13 years old.

**FERPA**: Family Educational Rights and Privacy Act, U.S. law protecting student education records.

**Latency**: Time delay between an action (instructor speaks) and its effect (student hears audio). Target <200ms for real-time interaction.

**SFU (Selective Forwarding Unit)**: Media server architecture that routes video streams efficiently by forwarding only requested streams to each participant, reducing bandwidth compared to peer-to-peer mesh.

**TURN/STUN**: Servers that enable WebRTC connections through firewalls and NAT (Network Address Translation) by relaying traffic or discovering public IP addresses.

**WebRTC**: Web Real-Time Communication, browser-native technology for peer-to-peer audio, video, and data transmission without plugins.

---

*Note: Tech stack references are generic as `jaan-to/context/tech.md` is not yet populated. Run `/jaan-to-dev-stack-detect` to enable framework-specific references in future PRDs.*
