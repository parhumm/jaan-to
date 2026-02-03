---
story_id: US-002
epic: "PRD-01: Live Streaming Classroom"
title: "Student Joins Breakout Room for Group Collaboration"
priority: high
status: draft
estimate: TBD
labels: [live-streaming, breakout-rooms, student, webrtc, collaboration]
created: 2026-02-03
last_updated: 2026-02-03
---

# US-002: Student Joins Breakout Room for Group Collaboration

## Executive Summary

Students need seamless transitions from main live class sessions to breakout rooms where small groups (2-10 students) can collaborate on exercises without distraction from the full class. This story enables instructor-assigned breakout room functionality with automatic room assignment, smooth transitions, real-time collaboration (video/audio/chat/whiteboard), and easy return to the main session. Breakout rooms are critical for the 60%+ adoption success metric from [PRD-01](../../prd/01-live-streaming-classroom/01-prd-live-streaming-classroom.md) and directly support active learning pedagogies.

---

## Context

Research on online learning engagement shows that peer-to-peer collaboration drives 2.5x performance improvements compared to passive lecture watching (Research ID: 01 - EdTech Engagement). However, facilitating small-group discussions in large online classes (100-500 students) is technically challenging without dedicated breakout room infrastructure.

This story implements the student experience for breakout rooms, complementing the instructor's ability to create and manage rooms ([US-003](#)). Students must be able to transition to assigned rooms with <5 second latency, collaborate effectively with groupmates using the same video/audio/chat/whiteboard tools available in the main session, and automatically return when the instructor closes breakout rooms or time expires.

**Business Impact**: Enables small-group collaboration at scale, directly addresses the "85%+ session completion rate" success metric by increasing engagement, and differentiates EduStream from basic webinar platforms (Zoom Webinars) that lack robust breakout functionality.

---

## Story Statement

**As a** student participating in a live online class with 200 other students
**I want to** join a breakout room assigned by my instructor and collaborate with a small group (5 peers)
**So that** I can engage in focused discussion and group exercises without distraction from the full class, improving my learning outcomes

---

## Acceptance Criteria

### Scenario 1: Student Successfully Joins Assigned Breakout Room

```gherkin
Given I am in a live class with 200 students
  And the instructor has created 40 breakout rooms with 5 students each
  And I have been assigned to "Breakout Room 7"
When the instructor activates breakout rooms
Then I see a notification: "You've been assigned to Breakout Room 7 with 4 other students"
  And a countdown timer appears: "Breakout rooms will open in 5 seconds... 4... 3... 2... 1"
When the countdown reaches zero
Then I automatically transition to Breakout Room 7 within 3 seconds
  And I see video feeds from my 4 groupmates (or placeholder avatars if cameras off)
  And I hear audio from active speakers in my group
  And the room title displays: "Breakout Room 7 (5 students)"
  And I retain access to chat, whiteboard, and screen sharing (same tools as main session)
```

### Scenario 2: Student Collaborates with Groupmates in Breakout Room

```gherkin
Given I am in Breakout Room 7 with 4 other students
When I turn on my microphone and say "Let's start with question 1"
Then all 4 groupmates hear my audio in real-time (<200ms latency)
  And my video feed updates to show "speaking" indicator (audio waveform animation)
When my groupmate Sarah shares her screen showing a diagram
Then I see Sarah's screen share replace her video feed in the main view
  And her camera feed moves to a small thumbnail in the corner
  And other groupmates see the same screen share simultaneously
When I type "Great idea, Sarah!" in the breakout room chat
Then the message appears in the chat panel immediately
  And all 4 groupmates see my message within 1 second
  And the main session chat is NOT visible (breakout chat is isolated)
```

### Scenario 3: Instructor Broadcasts Message to All Breakout Rooms

```gherkin
Given I am collaborating in Breakout Room 7
  And the instructor has set a 10-minute breakout time limit
  And 8 minutes have elapsed (2 minutes remaining)
When the instructor clicks "Broadcast to All Rooms" and types "2 minutes remaining - prepare to share findings"
Then I see a persistent notification banner at the top of my screen: "📢 Instructor: 2 minutes remaining - prepare to share findings"
  And my audio/video collaboration continues without interruption
  And the banner remains visible for 10 seconds, then fades but is still accessible via a "Messages" icon
When the 10-minute timer expires
Then I see a countdown notification: "Returning to main session in 10... 9... 8..."
  And my groupmates see the same countdown simultaneously
```

### Scenario 4: Student Automatically Returns to Main Session

```gherkin
Given the breakout room timer has reached zero (10 minutes elapsed)
  And the instructor has clicked "Close All Breakout Rooms"
When the countdown reaches zero
Then I automatically transition back to the main session within 3 seconds
  And I see the instructor's video/audio stream immediately (live, not from 10 minutes ago)
  And the participant list updates to show all 200 students back in main session
  And the chat panel switches from "Breakout Room 7 Chat" to "Main Session Chat"
  And I can see chat history from before I entered the breakout room (scrollable)
  And any whiteboard work from my breakout room is saved and accessible via "My Breakout Notes" download
```

### Scenario 5: Student Experiences Network Disconnection in Breakout Room

```gherkin
Given I am in Breakout Room 7 actively discussing with groupmates
  And my internet connection drops (WiFi disconnected, 0 Mbps)
When the connection is lost
Then I see an overlay message: "⚠️ Connection lost. Reconnecting..."
  And my video/audio freezes for groupmates (they see "Reconnecting..." status)
  And the system attempts reconnection for up to 30 seconds
When my connection is restored within 15 seconds
Then I automatically rejoin Breakout Room 7 without manual intervention
  And I see my groupmates' current video/audio (picking up where I left off)
  And I see chat messages sent during the disconnection (synced history)
  And a subtle notification confirms: "✓ Reconnected successfully"
```

### Scenario 6: Student Encounters Empty Breakout Room (First to Arrive)

```gherkin
Given the instructor has assigned me to Breakout Room 12
  And I am the first student to transition (my internet is fastest)
  And my 4 groupmates are still loading (slower connections)
When I enter Breakout Room 12
Then I see a message: "Waiting for groupmates... (1 of 5 students present)"
  And I see my own video feed with a placeholder message: "Others will join shortly"
  And I do NOT hear silence errors or see broken video feeds
When my first groupmate joins 2 seconds later
Then the message updates: "Waiting for groupmates... (2 of 5 students present)"
  And my groupmate's video/audio feed appears
  And we can immediately begin talking (no additional "ready" step needed)
When all 5 students have joined
Then the "Waiting for groupmates" message disappears automatically
  And the full collaboration interface is active (chat, whiteboard, screen sharing)
```

### Scenario 7: Student Manually Requests Help from Instructor While in Breakout Room

```gherkin
Given I am in Breakout Room 7 working on a difficult problem
  And my group is stuck and needs instructor clarification
When I click the "Ask for Help" button in the breakout room toolbar
Then a help request is sent to the instructor with my room number
  And I see confirmation: "Help requested - instructor notified"
  And the instructor sees: "Breakout Room 7 needs help" in their dashboard
When the instructor clicks "Visit Room 7"
Then the instructor joins Breakout Room 7 temporarily (video/audio/chat)
  And I see the instructor's video feed appear with a "Host" badge
  And the instructor can hear our discussion and provide guidance
  And other breakout rooms continue independently (instructor is only in Room 7)
When the instructor clicks "Leave Room 7"
Then the instructor disappears from our room
  And collaboration continues with just the 5 original students
```

---

## Scope

### In-Scope

- Automatic transition to assigned breakout room (<5 second transition time)
- Countdown notification before entering breakout room (5-second warning)
- Real-time video/audio collaboration in breakout rooms (same quality as main session)
- Breakout room-specific chat (isolated from main session chat)
- Whiteboard sharing in breakout rooms
- Screen sharing in breakout rooms
- Instructor broadcast messages visible in all breakout rooms (persistent banner)
- Timer countdown for automatic return to main session
- Automatic return to main session when breakout rooms close
- Network reconnection logic (30-second reconnect window)
- Empty breakout room handling (first student sees "waiting" message)
- Help request button to summon instructor to breakout room
- Instructor "visit room" capability (temporarily join a breakout room)
- Chat history sync after reconnection
- Breakout room notes download (whiteboard content saved)

### Out-of-Scope

- **Student-initiated breakout room creation** (only instructors can create rooms) → Future enhancement, student-led study groups
- **Breakout room recording** (only main session records) → Separate story [US-016](#), privacy concerns
- **Cross-breakout-room chat** (students chatting between rooms) → Not planned, defeats purpose of focused groups
- **Persistent breakout rooms across sessions** (rooms exist only for duration of single session) → Future enhancement, study groups feature
- **Manual breakout room switching** (students choosing their own room) → Instructor controls assignments to prevent self-segregation
- **Breakout room participant list editing** (moving students mid-session) → Separate story [US-018](#), instructor tools
- **Breakout room co-host** (student moderator role within breakout) → Future enhancement, Phase 2
- **Mobile app breakout rooms** → Phase 2, web browser only for MVP
- **Breakout room analytics** (participation tracking per room) → Separate story [US-025](#), analytics feature
- **AI-generated breakout groups** (automatic grouping by skill level) → Future research, ML-powered feature

---

## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| [US-001]: Instructor Starts Live Class | Story | ✅ Done | Product Team |
| [US-003]: Instructor Creates Breakout Rooms | Story | 🔄 In Progress | Product Team |
| WebRTC Multi-Room Routing | Technical | 🔄 In Progress | Infrastructure Team |
| Breakout Room State Management | Technical | ❌ Pending | Backend Team |
| Real-time Notification Service | Technical | ✅ Done | Platform Team |
| Chat History Sync Service | Technical | ✅ Done | Backend Team |

---

## Technical Notes

**API Endpoints:**
```
GET /api/sessions/{session_id}/breakout-rooms/assignment
- Returns student's assigned breakout room
- Response: {room_id, room_name, student_ids: [], transition_countdown}

POST /api/sessions/{session_id}/breakout-rooms/{room_id}/join
- Establishes WebRTC connection to breakout room
- Response: {signaling_url, room_state, participants: []}

POST /api/sessions/{session_id}/breakout-rooms/{room_id}/help-request
- Sends help request to instructor
- Response: {request_id, status: "sent", timestamp}

GET /api/sessions/{session_id}/breakout-rooms/{room_id}/chat
- Retrieves breakout room chat history (for reconnection)
- Response: [{message_id, sender, text, timestamp}]

POST /api/sessions/{session_id}/breakout-rooms/return
- Triggered when timer expires or instructor closes rooms
- Returns student to main session
```

**WebRTC Multi-Room Architecture:**
- Each breakout room is a separate SFU room instance (5-10 students per room)
- Students maintain WebSocket connection to signaling server during breakout
- Room assignments stored in Redis cache for fast lookup
- Automatic cleanup when breakout session ends (resources released)

**State Transitions:**
1. Main Session → Breakout Room Assigned → Countdown (5s) → Breakout Room Active → Countdown (10s) → Main Session Restored

**Performance Requirements:**
- Breakout room transition: <5 seconds from assignment to video visible
- Return to main session: <3 seconds from close command to instructor stream visible
- Reconnection window: 30 seconds before marking student as "left session"
- Chat sync: <2 seconds to catch up on missed messages after reconnection

**Database Changes:**
- `breakout_rooms` table: room_id, session_id, room_name, student_ids, created_at, closed_at
- `breakout_room_assignments` table: assignment_id, session_id, student_id, room_id, joined_at, left_at
- `breakout_room_help_requests` table: request_id, room_id, student_id, instructor_visited, timestamp

**Security:**
- Students can only join assigned breakout room (verified via session token)
- Chat messages encrypted in transit (TLS) and at rest
- Breakout room recordings disabled by default (privacy protection)
- Instructor can monitor all rooms but students cannot visit other rooms

---

## Open Questions

- [x] ~~Should students be able to switch breakout rooms voluntarily?~~ — **Decision**: No, instructor controls assignments to prevent self-segregation (2026-02-03)
- [ ] Should we allow text-only mode for students with low bandwidth (audio/video off, chat only)? — @Product by 2026-02-10
- [ ] Do we need a "raise hand" feature within breakout rooms, or is that only for main session? — @UX Research by 2026-02-12
- [x] ~~What happens if a student's browser crashes during breakout room?~~ — **Decision**: 30-second reconnect window, then marked as "left" and can rejoin via main session (2026-02-03)
- [ ] Should breakout room whiteboard content be saved permanently or only for session duration? — @Product + Legal by 2026-02-15 (FERPA considerations)

---

## Definition of Done

- [ ] Acceptance criteria verified by QA (all 7 scenarios pass)
- [ ] Code reviewed and approved by 2+ engineers
- [ ] Unit tests written (≥80% coverage for breakout room state transitions)
- [ ] Integration tests for multi-room WebRTC routing
- [ ] Load tested with 40 breakout rooms (5 students each = 200 concurrent)
- [ ] Network failure scenarios tested (disconnect/reconnect)
- [ ] Documentation updated (breakout room API, state machine diagrams)
- [ ] Product Owner acceptance received
- [ ] No critical bugs or P0 issues from QA testing
- [ ] Performance targets met (<5s transition, <200ms latency in rooms)
- [ ] Cross-browser testing passed (Chrome, Firefox, Safari, Edge)

---

## Export Formats

**Jira CSV Import:**
```csv
Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels
"Student Joins Breakout Room for Group Collaboration","Students need seamless transitions from main live class sessions to breakout rooms where small groups (2-10 students) can collaborate on exercises without distraction from the full class.","Story","High",TBD,"PRD-01: Live Streaming Classroom","live-streaming, breakout-rooms, student, webrtc, collaboration"
```

**Linear GraphQL Mutation:**
```json
{
  "input": {
    "title": "Student Joins Breakout Room for Group Collaboration",
    "description": "Students need seamless transitions from main live class sessions to breakout rooms...",
    "priority": 2,
    "estimate": null,
    "labelIds": ["live-streaming", "breakout-rooms", "student", "webrtc", "collaboration"]
  }
}
```

---

## Related Stories

- **[US-001]**: Instructor Starts Scheduled Live Class (prerequisite)
- **[US-003]**: Instructor Creates Breakout Rooms (parallel, instructor view)
- **[US-016]**: Breakout Room Recording (future enhancement)
- **[US-018]**: Instructor Moves Students Between Breakout Rooms (future)
- **[US-025]**: Breakout Room Participation Analytics (future)
- **[PRD-01]**: Live Streaming Classroom Feature (parent PRD)
