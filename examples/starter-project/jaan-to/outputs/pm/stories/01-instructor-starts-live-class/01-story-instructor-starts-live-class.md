---
story_id: US-001
epic: "PRD-01: Live Streaming Classroom"
title: "Instructor Starts Scheduled Live Class"
priority: critical
status: draft
estimate: TBD
labels: [live-streaming, instructor, webrtc, session-management]
created: 2026-02-03
last_updated: 2026-02-03
---

# US-001: Instructor Starts Scheduled Live Class

## Executive Summary

Instructors need the ability to initiate scheduled live classes with a single click, automatically setting up the WebRTC streaming infrastructure, admitting students from a lobby, and providing real-time visibility into who has joined. This story delivers the core "go-live" workflow that is the foundation of the entire live streaming classroom feature, directly addressing the 86% attendance improvement metric when live sessions are available (from gamification research).

---

## Context

Research shows that **86.25% attendance** occurs when live streaming is combined with engagement features, compared to 61% for asynchronous-only courses (Research ID: 04 - Gamification Psychology). However, instructors currently have no mechanism to start live sessions within EduStream Academy, forcing them to use external tools (Zoom, Google Meet) and manually share links—a friction point causing 2-3 hours/week of lost time.

This story implements the critical "Start Class" workflow, enabling instructors to transition from a scheduled session to a live broadcast where up to 500 students can join in real-time. The WebRTC infrastructure must initialize reliably (<200ms latency target), handle early joiners in a lobby system, and provide instructor controls for admitting students individually or in bulk.

**Business Impact**: Unlocks live streaming feature adoption, directly supports 70%+ active participation rate success metric from [PRD-01](../../prd/01-live-streaming-classroom/01-prd-live-streaming-classroom.md), and differentiates EduStream from Coursera/Udemy which lack integrated live classroom features.

---

## Story Statement

**As an** instructor teaching a scheduled course
**I want to** start a live class session 5 minutes before the scheduled time and see students join from a controlled lobby
**So that** I can begin teaching with real-time interaction, ensure only enrolled students access the session, and maintain control over session timing

---

## Acceptance Criteria

### Scenario 1: Instructor Successfully Starts Class on Time

```gherkin
Given I have a class scheduled for 2:00 PM with 75 enrolled students
  And the current time is 1:55 PM (5 minutes before start time)
When I navigate to my dashboard and click "Start Class" next to the scheduled session
Then the session initializes within 10 seconds
  And I see a confirmation message "Class is now live - students can join"
  And a unique join link is generated and displayed (e.g., "edustream.com/live/abc123")
  And my video/audio preview appears showing my camera and microphone are active
  And the participant counter shows "0 students" initially
```

### Scenario 2: Students Join and Instructor Admits from Lobby

```gherkin
Given my class is live and the join link has been shared via email/calendar
  And 15 students have clicked the join link and are waiting in the lobby
When I view the "Lobby" tab in the instructor dashboard
Then I see a list of 15 student names with profile photos and "Admit" buttons
  And I see two options: "Admit All" and "Admit Individually"
When I click "Admit All"
Then all 15 students enter the main session within 3 seconds
  And the participant counter updates to "15 students"
  And each student's name appears in the participant list with connection status (green indicator)
  And students immediately see my video/audio stream with <200ms latency
```

### Scenario 3: Instructor Checks Connection Status Before Going Live

```gherkin
Given I am about to start my class
When I click "Start Class"
Then the system runs a pre-flight connectivity check (5-second test)
  And displays results: "Camera: ✓", "Microphone: ✓", "Network: ✓ (8 Mbps upload)"
When all checks pass
Then the "Confirm Start" button becomes enabled
When I click "Confirm Start"
Then the class goes live immediately
```

### Scenario 4: Instructor Handles Poor Network Connection

```gherkin
Given I am attempting to start a live class
  And my internet connection is unstable (1.5 Mbps upload speed, 30% packet loss)
When the pre-flight connectivity check runs
Then I see a warning message: "⚠️ Your connection is unstable. Video quality may be reduced. Proceed anyway?"
  And connection details are shown: "Upload: 1.5 Mbps (recommended: 3+ Mbps), Packet loss: 30%"
When I click "Proceed Anyway"
Then the class starts but my video automatically degrades to 480p resolution
  And I see a persistent banner: "Poor connection detected - using reduced quality"
  And students receive audio clearly but video is lower resolution
```

### Scenario 5: Instructor Attempts to Start Class Too Early

```gherkin
Given I have a class scheduled for 2:00 PM
  And the current time is 1:30 PM (30 minutes before start time)
When I navigate to my dashboard and click "Start Class"
Then I see an error message: "Cannot start class more than 10 minutes before scheduled time (2:00 PM)"
  And the "Start Class" button remains disabled
  And a countdown timer displays: "Available in 20 minutes"
```

### Scenario 6: Late Students Join After Class Has Started

```gherkin
Given my class started at 2:00 PM and is currently live with 50 students
  And the current time is 2:15 PM (15 minutes into the session)
  And 10 additional students click the join link
When these 10 students enter the lobby
Then I receive a notification: "10 new students in lobby"
  And the lobby list updates to show the 10 new arrivals with timestamps (e.g., "Joined 2:15 PM")
When I click "Admit All" for these late joiners
Then they enter the session and see my current live stream immediately (not from the 2:00 PM start)
  And they can view chat history from the past 15 minutes
  And they do NOT see video playback from before they joined (only live content)
```

### Scenario 7: Instructor Manually Removes Disruptive Student Mid-Session

```gherkin
Given my class is live with 75 students
  And student "Alex Johnson" is being disruptive (spamming chat, inappropriate behavior)
When I locate "Alex Johnson" in the participant list
  And I click the "..." menu next to their name
  And I select "Remove from Session"
Then a confirmation dialog appears: "Remove Alex Johnson from the session? They will not be able to rejoin."
When I click "Confirm Removal"
Then Alex Johnson is immediately disconnected from the session
  And their name is removed from the participant list
  And they see a message: "You have been removed from this session by the instructor"
  And the participant counter decreases by 1 (e.g., 75 → 74 students)
  And Alex Johnson cannot click the join link again to re-enter
```

---

## Scope

### In-Scope

- Instructor dashboard "Start Class" button for scheduled sessions
- Pre-flight connectivity check (camera, microphone, network speed test)
- WebRTC session initialization and signaling server connection
- Join link generation (unique per session, e.g., `edustream.com/live/{session_id}`)
- Student lobby system where students wait before being admitted
- Instructor lobby view showing waiting students (name, photo, timestamp)
- "Admit All" and "Admit Individually" controls for instructor
- Real-time participant list with connection status indicators (green/yellow/red)
- Participant counter displaying current student count
- Manual student removal controls (kick from session)
- Session start 5-10 minutes before scheduled time (early start window)
- Automatic video quality degradation on poor connections (adaptive bitrate)
- Late student admission (join after class has started)

### Out-of-Scope

- **Automated lobby admission** (auto-admit enrolled students without instructor approval) → Future enhancement, [US-002](#)
- **Waiting room chat** (students chatting while in lobby before admission) → Future enhancement, Phase 2
- **Bulk student removal** (remove multiple students at once) → Low priority, defer to v1.1
- **Session recording start** → Separate story [US-010](#), auto-record feature
- **Breakout room creation** → Separate story [US-015](#), distinct workflow from session start
- **Instructor co-host/moderator** → Future enhancement, multi-instructor sessions
- **Mobile instructor app** → Phase 2, web browser only for MVP
- **Attendance tracking** → Separate story [US-008](#), analytics feature
- **Automatic session end** (when scheduled end time reached) → Future enhancement, manual end only in MVP

---

## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| WebRTC Signaling Server | Technical | ✅ Done | Infrastructure Team |
| Mediasoup SFU Deployment | Technical | 🔄 In Progress | Infrastructure Team |
| User Authentication System | Story | ✅ Done | Auth Team |
| Scheduled Session Management | Story | 🔄 In Progress | Platform Team |
| Video/Audio Permissions API | Technical | ✅ Done | Frontend Team |
| Session Join Link Generation Service | Technical | ❌ Pending | Backend Team |

---

## Technical Notes

**API Endpoints:**
```
POST /api/sessions/{session_id}/start
- Initializes WebRTC session, returns signaling server details
- Response: {session_id, signaling_url, turn_servers, stun_servers}

GET /api/sessions/{session_id}/lobby
- Returns list of students waiting in lobby
- Response: [{student_id, name, photo_url, joined_at}]

POST /api/sessions/{session_id}/admit
- Body: {student_ids: []} or {admit_all: true}
- Moves students from lobby to active session

DELETE /api/sessions/{session_id}/participants/{student_id}
- Removes student from active session, prevents rejoin
```

**WebRTC Flow:**
1. Instructor clicks "Start Class" → Frontend calls `/api/sessions/{id}/start`
2. Backend provisions SFU resources, generates join link
3. Frontend establishes WebSocket connection to signaling server
4. Signaling server sends TURN/STUN server details for NAT traversal
5. Frontend creates RTCPeerConnection, begins local media capture (camera/mic)
6. Instructor's video/audio stream published to SFU
7. Students join → SFU forwards instructor stream to all admitted participants

**Performance Requirements:**
- Session initialization: <10 seconds from button click to "live" status
- Student admission: <3 seconds from "Admit All" to video stream visible
- Lobby list updates: Real-time via WebSocket, <500ms latency
- Participant count updates: Real-time, <1 second lag

**Database Changes:**
- `sessions` table: Add `status` column (scheduled, live, ended)
- `session_participants` table: Add `admitted_at` timestamp, `removed` boolean
- `session_lobby` table: Track students waiting for admission

**Security:**
- Join links expire 15 minutes after scheduled session end time
- DTLS-SRTP encryption for all video/audio streams (WebRTC standard)
- Only enrolled students can enter lobby (verified via JWT token)
- Removed students blacklisted by session ID (cannot re-enter same session)

---

## Open Questions

- [x] ~~Should instructors be able to start class more than 10 minutes early?~~ — **Decision**: No, 5-10 minute early window only to prevent accidental early starts (2026-02-03)
- [ ] Should we send automatic email notifications to students when class goes live, or rely on calendar reminders only? — @Product by 2026-02-10
- [ ] Do we need a "Practice Mode" where instructors can test their camera/mic without students joining? — @UX Research by 2026-02-12
- [x] ~~What happens if instructor loses connection mid-session?~~ — **Decision**: Separate story [US-020](#) for reconnection logic, not in MVP (2026-02-03)

---

## Definition of Done

- [ ] Acceptance criteria verified by QA (all 7 scenarios pass)
- [ ] Code reviewed and approved by 2+ engineers
- [ ] Unit tests written (≥80% coverage for session start logic)
- [ ] Integration tests for WebRTC session initialization
- [ ] Load tested with 500 concurrent students joining lobby
- [ ] Documentation updated (API endpoints, WebRTC flow diagrams)
- [ ] Product Owner acceptance received
- [ ] No critical bugs or P0 issues from QA testing
- [ ] Performance targets met (<10s session start, <200ms latency)
- [ ] Cross-browser testing passed (Chrome, Firefox, Safari, Edge)

---

## Export Formats

**Jira CSV Import:**
```csv
Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels
"Instructor Starts Scheduled Live Class","Instructors need the ability to initiate scheduled live classes with a single click, automatically setting up the WebRTC streaming infrastructure, admitting students from a lobby, and providing real-time visibility into who has joined.","Story","Critical",TBD,"PRD-01: Live Streaming Classroom","live-streaming, instructor, webrtc, session-management"
```

**Linear GraphQL Mutation:**
```json
{
  "input": {
    "title": "Instructor Starts Scheduled Live Class",
    "description": "Instructors need the ability to initiate scheduled live classes with a single click...",
    "priority": 1,
    "estimate": null,
    "labelIds": ["live-streaming", "instructor", "webrtc", "session-management"]
  }
}
```

---

## Related Stories

- **[US-002]**: Auto-Admit Enrolled Students (removes lobby approval step)
- **[US-008]**: Attendance Tracking and Analytics
- **[US-010]**: Automatic Session Recording
- **[US-015]**: Breakout Room Creation During Live Session
- **[US-020]**: Instructor Reconnection After Network Failure
- **[PRD-01]**: Live Streaming Classroom Feature (parent PRD)
