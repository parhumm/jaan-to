# GTM Tracking: Live Streaming Classroom

> **ID**: 01
> **Feature**: Live Streaming Classroom
> **Source**: PRD-01 Live Streaming Classroom
> **Events**: 10 tracking events
> **Generated**: 2026-02-03

---

## Executive Summary

Comprehensive Google Tag Manager (GTM) tracking implementation for live streaming classroom feature covering instructor session management, student interactions, breakout rooms, screen sharing, chat, polls, and recording. Includes 10 dataLayer events using lowercase-kebab-case naming convention with proper event types (click-datalayer for user actions, impression for automatic events) and structured parameters for analytics segmentation.

**Key Tracked Actions:**
- Class lifecycle (started, joined, ended)
- Student engagement (hand raise, chat, poll voting)
- Collaboration (breakout rooms, screen sharing)
- Recording management (start, stop, playback)

**Implementation:** All events use `al_tracker_custom` or `al_tracker_impression` with consistent `al.feature`, `al.item`, `al.action` structure and `_clear: true` for dataLayer hygiene.

---

## Naming Conventions

All tracking follows **lowercase-kebab-case** naming:
- Feature: `live-class`
- Items: `hand-raise`, `screen-share`, `breakout-room`, `chat-message`, `poll-vote`, `recording`, `session`
- Actions: `Click`, `Start`, `Stop`, `Join`, `Leave`, `Send`, `Vote`

**Event Types:**
- **click-datalayer**: User-initiated actions (buttons, controls)
- **impression**: Automatic system events (session start, join confirmation)

---

## Event 1: Class Started (Instructor)

**Type**: impression (automatic when instructor starts broadcast)

**Trigger**: Instructor clicks "Start Class" button and session initializes

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "live-class",
    item: "session",
    params: {
      session_id: "sess_abc123",           // string: unique session identifier
      instructor_id: "inst_456",           // string: instructor user ID
      scheduled_participants: 75,          // int: expected student count
      max_capacity: 500,                   // int: maximum allowed participants
      recording_enabled: true,             // bool: whether recording is active
      duration_minutes: 90                 // int: scheduled duration
    }
  },
  _clear: true
});
```

**When to Fire**: Immediately after WebRTC connection establishes and first frame is transmitted

**Use Cases**:
- Track instructor session start rate
- Measure time between scheduled start and actual start
- Analyze session parameters (capacity, duration patterns)
- Monitor recording adoption rate

---

## Event 2: Student Joined

**Type**: impression (automatic when student enters session)

**Trigger**: Student successfully connects to live stream and video loads

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "live-class",
    item: "student-joined",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      student_id: "stud_789",              // string: student user ID
      join_time_seconds: 42,               // int: seconds after session start
      connection_quality: "good",          // string: "excellent" | "good" | "fair" | "poor"
      device_type: "desktop",              // string: "desktop" | "tablet" | "mobile"
      is_first_time: false                 // bool: first time joining any live class
    }
  },
  _clear: true
});
```

**When to Fire**: After student's WebRTC connection succeeds and instructor video renders

**Use Cases**:
- Track session attendance and late joins
- Measure connection quality distribution
- Analyze device preferences
- Identify first-time users for onboarding optimization

---

## Event 3: Hand Raised

**Type**: click-datalayer (user action)

**Trigger**: Student clicks "Raise Hand" button

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "hand-raise",
    action: "Click",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      student_id: "stud_789",              // string: student user ID
      queue_position: 3,                   // int: position in hand-raise queue
      session_elapsed_minutes: 15,         // int: time into session when raised
      previous_hands_raised: 2             // int: how many times this student raised hand before
    }
  },
  _clear: true
});
```

**When to Fire**: Immediately on button click (before acknowledgment by instructor)

**Use Cases**:
- Measure student engagement and question frequency
- Identify highly engaged students
- Analyze timing of questions (early vs. late in session)
- Track instructor response times (pair with acknowledgment event)

---

## Event 4: Hand Lowered

**Type**: click-datalayer (user action)

**Trigger**: Student clicks "Lower Hand" button or instructor acknowledges

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "hand-lower",
    action: "Click",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      student_id: "stud_789",              // string: student user ID
      was_acknowledged: true,              // bool: whether instructor acknowledged before lowering
      wait_time_seconds: 45,               // int: time hand was raised
      lowered_by: "instructor"             // string: "student" | "instructor" | "timeout"
    }
  },
  _clear: true
});
```

**When to Fire**: When hand is lowered by any method

**Use Cases**:
- Measure instructor responsiveness (wait times)
- Track acknowledgment rates
- Identify abandoned questions (not acknowledged)

---

## Event 5: Screen Share Started

**Type**: click-datalayer (user action)

**Trigger**: Instructor or student clicks "Share Screen" button and selects window/screen

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "screen-share",
    action: "Start",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      user_id: "inst_456",                 // string: user who initiated share
      user_role: "instructor",             // string: "instructor" | "student"
      share_type: "window",                // string: "window" | "screen" | "tab"
      has_audio: false,                    // bool: whether sharing system audio
      session_elapsed_minutes: 20          // int: when sharing started
    }
  },
  _clear: true
});
```

**When to Fire**: After user grants browser permission and stream initializes

**Use Cases**:
- Track screen share adoption
- Measure share duration (pair with stop event)
- Analyze share types (full screen vs. window)
- Monitor student-initiated shares (if permitted)

---

## Event 6: Screen Share Stopped

**Type**: click-datalayer (user action)

**Trigger**: User clicks "Stop Sharing" or closes shared window

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "screen-share",
    action: "Stop",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      user_id: "inst_456",                 // string: user who stopped share
      user_role: "instructor",             // string: "instructor" | "student"
      duration_seconds: 420,               // int: how long screen was shared
      stopped_by: "user",                  // string: "user" | "system" | "error"
      session_elapsed_minutes: 27          // int: when sharing stopped
    }
  },
  _clear: true
});
```

**When to Fire**: When screen share stream ends

**Use Cases**:
- Calculate average screen share duration
- Identify premature disconnections (error stops)
- Analyze content presentation patterns

---

## Event 7: Breakout Room Joined

**Type**: click-datalayer (user action)

**Trigger**: Student clicks "Join Breakout Room" button after assignment

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "breakout-room",
    action: "Join",
    params: {
      session_id: "sess_abc123",           // string: main session identifier
      room_id: "room_5",                   // string: breakout room identifier
      student_id: "stud_789",              // string: student user ID
      room_number: 5,                      // int: room number (1-50)
      room_size: 6,                        // int: number of students in this room
      total_rooms: 10,                     // int: total breakout rooms created
      assignment_type: "auto",             // string: "auto" | "manual" | "self-select"
      time_limit_minutes: 15               // int: breakout duration set by instructor
    }
  },
  _clear: true
});
```

**When to Fire**: After student's connection to breakout room succeeds

**Use Cases**:
- Track breakout room participation rates
- Measure join latency (from assignment to join)
- Analyze room size effectiveness
- Compare auto vs. manual assignment engagement

---

## Event 8: Breakout Room Returned

**Type**: impression (automatic when timer expires or manual return)

**Trigger**: Student returns to main session from breakout room

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "live-class",
    item: "breakout-return",
    params: {
      session_id: "sess_abc123",           // string: main session identifier
      room_id: "room_5",                   // string: breakout room identifier
      student_id: "stud_789",              // string: student user ID
      duration_seconds: 840,               // int: actual time spent in breakout room
      scheduled_duration: 900,             // int: planned duration (15 min = 900s)
      return_reason: "timer",              // string: "timer" | "manual" | "instructor-recall"
      messages_sent: 8                     // int: chat messages sent in breakout room
    }
  },
  _clear: true
});
```

**When to Fire**: When student's connection returns to main session

**Use Cases**:
- Measure actual vs. scheduled breakout duration
- Track early returns (indicator of issues or completion)
- Analyze breakout room engagement via message counts
- Monitor instructor recall usage

---

## Event 9: Chat Message Sent

**Type**: click-datalayer (user action)

**Trigger**: User clicks "Send" button or presses Enter in chat input

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "chat-message",
    action: "Send",
    params: {
      session_id: "sess_abc123",           // string: session identifier (or room_id if in breakout)
      user_id: "stud_789",                 // string: sender user ID
      user_role: "student",                // string: "instructor" | "student"
      message_length: 42,                  // int: character count
      has_mention: true,                   // bool: whether message includes @mention
      has_emoji: false,                    // bool: whether message includes emoji
      is_reply: false,                     // bool: whether threaded reply
      location: "main",                    // string: "main" | "breakout" | "private"
      session_elapsed_minutes: 35          // int: when message was sent
    }
  },
  _clear: true
});
```

**When to Fire**: After message successfully sends (not on typing)

**Use Cases**:
- Measure chat engagement and frequency
- Analyze message lengths and types
- Track @mention usage (direct questions to instructor)
- Compare main session vs. breakout chat activity

---

## Event 10: Poll Voted

**Type**: click-datalayer (user action)

**Trigger**: Student selects answer and clicks "Submit Vote" on instructor poll

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "poll-vote",
    action: "Vote",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      poll_id: "poll_xyz",                 // string: unique poll identifier
      student_id: "stud_789",              // string: voter user ID
      question_type: "multiple-choice",    // string: "multiple-choice" | "true-false" | "rating"
      answer_index: 2,                     // int: selected answer (0-indexed)
      time_to_answer_seconds: 8,           // int: time from poll display to vote
      poll_number: 3,                      // int: nth poll in this session
      session_elapsed_minutes: 40          // int: when vote was cast
    }
  },
  _clear: true
});
```

**When to Fire**: After vote is successfully submitted (not on answer selection)

**Use Cases**:
- Measure poll participation rates
- Analyze answer speed (comprehension indicator)
- Track poll effectiveness by question type
- Monitor engagement decline over session duration

---

## Event 11: Recording Started

**Type**: click-datalayer (user action)

**Trigger**: Instructor clicks "Start Recording" button

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "recording",
    action: "Start",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      recording_id: "rec_def789",          // string: unique recording identifier
      instructor_id: "inst_456",           // string: instructor user ID
      session_elapsed_minutes: 2,          // int: when recording started (usually early)
      consent_required: true,              // bool: whether COPPA/FERPA consent needed
      consents_collected: 72,              // int: number of students who consented
      total_participants: 75               // int: current participant count
    }
  },
  _clear: true
});
```

**When to Fire**: After recording service confirms recording has begun

**Use Cases**:
- Track recording adoption rate
- Monitor consent compliance
- Measure recording start timing (immediate vs. delayed)
- Identify instructors who always/never record

---

## Event 12: Recording Stopped

**Type**: click-datalayer (user action)

**Trigger**: Instructor clicks "Stop Recording" or session ends with auto-stop

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "live-class",
    item: "recording",
    action: "Stop",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      recording_id: "rec_def789",          // string: unique recording identifier
      instructor_id: "inst_456",           // string: instructor user ID
      duration_minutes: 88,                // int: recording duration
      file_size_mb: 1250,                  // int: approximate file size
      stop_reason: "manual",               // string: "manual" | "auto-session-end" | "error" | "storage-limit"
      session_elapsed_minutes: 90          // int: when recording stopped
    }
  },
  _clear: true
});
```

**When to Fire**: After recording service confirms recording has stopped and file is processing

**Use Cases**:
- Calculate average recording durations
- Monitor storage usage patterns
- Track premature stops (errors or manual)
- Analyze recording vs. scheduled session duration

---

## Event 13: Session Ended

**Type**: impression (automatic when instructor ends session)

**Trigger**: Instructor clicks "End Class" and all participants are disconnected

**dataLayer Code**:
```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "live-class",
    item: "session-ended",
    params: {
      session_id: "sess_abc123",           // string: session identifier
      instructor_id: "inst_456",           // string: instructor user ID
      duration_minutes: 92,                // int: actual session duration
      scheduled_duration: 90,              // int: planned duration
      peak_participants: 78,               // int: maximum concurrent students
      average_participants: 72,            // int: average concurrent students
      completion_rate: 0.96,               // float: % of students who stayed >=90% of session
      hands_raised: 15,                    // int: total hand raises
      messages_sent: 234,                  // int: total chat messages
      polls_created: 4,                    // int: total polls
      breakout_rooms_used: 10,             // int: number of breakout rooms created
      screen_shares: 3,                    // int: number of screen share sessions
      recording_duration: 88               // int: recording duration (if recorded)
    }
  },
  _clear: true
});
```

**When to Fire**: After all participants have been disconnected and session data is aggregated

**Use Cases**:
- Calculate session completion rates
- Measure actual vs. scheduled duration variance
- Analyze feature usage (breakouts, polls, screen share)
- Track engagement metrics (hands raised, messages)
- Identify high-performing sessions (high completion, high engagement)

---

## Implementation Guide

### 1. Installation

Add GTM container to base HTML template:

```html
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-XXXXXXX');</script>
<!-- End Google Tag Manager -->
```

### 2. Event Firing Locations

**Frontend Components:**
- `InstructorControls.tsx`: Events 1, 5, 6, 11, 12, 13
- `StudentControls.tsx`: Events 2, 3, 4, 9, 10
- `BreakoutRoomModal.tsx`: Events 7, 8
- `WebRTCClient.ts`: Connection quality tracking for Event 2

**Backend Webhooks:**
- Consider firing Events 1, 2, 13 from backend for reliability (WebRTC connection confirmations)
- Use frontend as primary, backend as backup for critical lifecycle events

### 3. Timing Best Practices

- **Fire early**: Trigger events as soon as action is confirmed (don't wait for full completion)
- **Non-blocking**: Use `setTimeout(() => dataLayer.push(...), 0)` to avoid blocking UI
- **Retry logic**: For critical events (session start/end), implement retry on network failure

**Example:**
```javascript
// In React component
const handleHandRaise = () => {
  // Optimistic UI update
  setHandRaised(true);

  // Non-blocking GTM event
  setTimeout(() => {
    dataLayer.push({
      event: "al_tracker_custom",
      al: {
        feature: "live-class",
        item: "hand-raise",
        action: "Click",
        params: {
          session_id: sessionId,
          student_id: userId,
          queue_position: handRaiseQueue.length + 1,
          session_elapsed_minutes: getElapsedMinutes(),
          previous_hands_raised: userHandRaiseCount
        }
      },
      _clear: true
    });
  }, 0);

  // API call
  api.raiseHand(sessionId, userId);
};
```

### 4. Testing

**Local Development:**
```javascript
// Preview dataLayer in console
console.table(dataLayer);

// Monitor all pushes
const originalPush = dataLayer.push;
dataLayer.push = function(...args) {
  console.log('dataLayer.push:', args);
  return originalPush.apply(this, args);
};
```

**Staging:**
- Use GTM Preview Mode to validate event structure
- Verify all params are correctly typed (strings in quotes, ints/bools without)
- Check `_clear: true` is present in all events

**Production:**
- Monitor GTM debug panel for first 48 hours
- Set up GA4 custom events to receive these dataLayer pushes
- Create dashboards for key metrics (participation rate, engagement score)

### 5. Analytics Setup (GA4)

Create custom events in GA4 to receive these dataLayer events:

**GA4 Event Configuration:**
```
Event Name: live_class_started
Trigger: Custom Event = al_tracker_impression
Conditions: al.feature = "live-class" AND al.item = "session"
Parameters:
  - session_id (text)
  - scheduled_participants (number)
  - recording_enabled (boolean)
```

Repeat for all 13 events.

**Recommended GA4 Dashboards:**
1. **Session Health**: class_started, student_joined, session_ended counts
2. **Engagement Score**: hands_raised, messages_sent, poll_votes per session
3. **Feature Adoption**: screen_share, breakout_room, recording usage rates
4. **Connection Quality**: Distribution from student_joined events

---

## Key Metrics & KPIs

### Engagement Metrics

**Active Participation Rate** (Target: 70%+):
```
(hands_raised + poll_votes + messages_sent) / total_students
```

Track via Events 3, 9, 10.

**Session Completion Rate** (Target: 85%+):
```
students_staying_90%+ / total_students_joined
```

Track via Event 13 `completion_rate` param.

**Breakout Room Adoption** (Target: 60%+ within 3 months):
```
sessions_using_breakouts / total_sessions
```

Track via Events 7, 8, 13 `breakout_rooms_used`.

### Performance Metrics

**Join Latency** (Target: <10 seconds):
```
median(join_time_seconds) from Event 2
```

**Connection Quality Distribution**:
```
excellent: X%, good: Y%, fair: Z%, poor: W% from Event 2
```

**Instructor Response Time** (Target: <60 seconds):
```
median(wait_time_seconds) from Event 4
```

### Usage Metrics

**Recording Adoption** (Monitor trend):
```
sessions_recorded / total_sessions from Events 11-12
```

**Screen Share Frequency** (Monitor trend):
```
avg(screen_shares) per session from Event 13
```

**Poll Engagement** (Target: 80%+ participation):
```
unique_voters / session_participants from Event 10
```

---

## Troubleshooting

### Common Issues

**1. Events not firing**
- Check GTM container is loaded: `typeof dataLayer !== 'undefined'`
- Verify GTM Preview Mode shows the container
- Check browser console for JavaScript errors blocking execution

**2. Params showing as strings when should be numbers**
- Ensure ints/bools don't have quotes: `count: 3` NOT `count: "3"`
- Validate JSON structure before pushing to dataLayer

**3. Duplicate events**
- Ensure components don't double-mount (React StrictMode in dev)
- Check event handlers aren't attached multiple times
- Use `_clear: true` to prevent event persistence

**4. Missing session_id**
- Pass session_id down via React Context or Redux
- Fallback to URL param if context unavailable
- Log warning if session_id is missing before pushing event

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-03 | Initial tracking implementation for live classroom feature (13 events) |

---

**Generated by**: jaan-to Plugin v3.10.0
**Skill**: `/jaan-to-data-gtm-datalayer`
**Source**: PRD-01 Live Streaming Classroom
**Output**: `jaan-to/outputs/data/gtm/01-live-class-tracking/01-gtm-live-class-tracking.md`
