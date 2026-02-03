# Backend Task Breakdown: Live Streaming Classroom

**PRD**: [PRD-01: Live Streaming Classroom](../../../pm/prd/01-live-streaming-classroom/01-prd-live-streaming-classroom.md)
**Framework**: Node.js v20.x + Express.js v4.18 + Socket.io v4.6 + Mediasoup v3.13
**Database**: PostgreSQL 15.4 + Redis 7.2 + RabbitMQ 3.12
**Slicing Strategy**: Vertical (end-to-end feature slices)
**Scope**: MVP - Production-ready features supporting 500 concurrent users
**Generated**: 2026-02-03

---

## Executive Summary

This task breakdown delivers the backend infrastructure for EduStream Academy's live streaming classroom, supporting real-time video/audio for up to 500 concurrent students per session. The breakdown spans 38 tasks across 8 feature slices: Core Session Management, WebRTC Communication, Breakout Rooms, Interactive Features (Chat/Hand Raise), Recording & Playback, Whiteboard & Polls, Error Handling, and Security/Compliance.

**Critical Path**: 12 sequential tasks (~24-32 hours) from database schema to WebRTC integration to recording processing.

**Key Technical Challenges**:
- WebRTC multi-party routing via Mediasoup SFU with <200ms latency
- Multi-room breakout session orchestration
- Real-time event synchronization (chat, whiteboard, polls) via Socket.io
- Cloud recording capture, encoding (H.264), and S3 upload pipeline
- COPPA/FERPA compliant audit logging and data retention

---

## Entity Summary

| Entity | Table | Tasks | Key Relationships | Notes |
|--------|-------|-------|-------------------|-------|
| **Session** | `sessions` | 6 | hasMany Participants, BreakoutRooms, Recordings | Soft delete enabled |
| **Participant** | `session_participants` | 3 | belongsTo Session, User | Tracks connection status |
| **BreakoutRoom** | `breakout_rooms` | 6 | belongsTo Session, hasMany RoomAssignments | Auto-close on time limit |
| **RoomAssignment** | `room_assignments` | 2 | belongsTo BreakoutRoom, Participant | Unique constraint per room |
| **Recording** | `session_recordings` | 5 | belongsTo Session | S3 file path + metadata |
| **ChatMessage** | `chat_messages` | 3 | belongsTo Session, User | Hard delete after 90 days |
| **HandRaise** | `hand_raises` | 2 | belongsTo Session, User | Real-time queue management |
| **Whiteboard** | `whiteboards` | 2 | belongsTo Session | JSONB canvas data |
| **Poll** | `session_polls` | 2 | belongsTo Session, hasMany PollResponses | Real-time aggregation |

**Total Tables**: 9 core tables + 1 poll_responses junction table

---

## Task Breakdown

### Slice 1: Core Session Management

#### [STR-001] Migration: Create sessions table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000001_create_sessions_table.js`

**Dependencies:**
- blocked-by: None (foundation task)
- parallel-with: [STR-002]

**Description:**
Create the `sessions` table to store live class session metadata including scheduling, capacity, and join link tokens. Implements soft deletes for data retention compliance.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), title (VARCHAR 255), instructor_id (FK users), scheduled_start (TIMESTAMPTZ), scheduled_end (TIMESTAMPTZ), status (ENUM), max_capacity (INT), join_link_token (VARCHAR 64 UNIQUE), recording_enabled (BOOLEAN), created_at, updated_at, deleted_at (nullable)
- [ ] Status ENUM values: 'scheduled', 'live', 'ended'
- [ ] Foreign key constraint on instructor_id → users.id with ON DELETE CASCADE
- [ ] Indexes on: instructor_id, scheduled_start, join_link_token, status
- [ ] Up and down methods both implemented

**Data Model Notes:**
```yaml
table: sessions
columns:
  - name: id
    type: uuid
    primary_key: true
    default: gen_random_uuid()
  - name: title
    type: varchar(255)
    nullable: false
  - name: instructor_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
  - name: scheduled_start
    type: timestamptz
    nullable: false
  - name: scheduled_end
    type: timestamptz
    nullable: false
  - name: status
    type: enum ['scheduled', 'live', 'ended']
    default: 'scheduled'
  - name: max_capacity
    type: integer
    default: 500
    check: max_capacity > 0 AND max_capacity <= 1000
  - name: join_link_token
    type: varchar(64)
    nullable: false
    unique: true
  - name: recording_enabled
    type: boolean
    default: true
  - name: created_at
    type: timestamptz
    nullable: false
  - name: updated_at
    type: timestamptz
    nullable: false
  - name: deleted_at
    type: timestamptz
    nullable: true
indexes:
  - columns: [instructor_id, status]
    name: idx_sessions_instructor_status
  - columns: [scheduled_start]
    name: idx_sessions_scheduled_start
  - columns: [join_link_token]
    name: idx_sessions_join_token
    unique: true
constraints:
  - check: scheduled_end > scheduled_start
migration:
  zero_downtime: true (additive only)
  expand_contract: false
```

**Test Requirements:**
- Unit test: `tests/migrations/sessions-table.test.js`
- Coverage: Verify schema, indexes, constraints

---

#### [STR-002] Migration: Create session_participants table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000002_create_session_participants_table.js`

**Dependencies:**
- blocked-by: [STR-001] (foreign key dependency)
- parallel-with: None

**Description:**
Create the `session_participants` table to track user participation in sessions, including role (instructor/student/guest), connection status, and admission workflow (lobby → admitted).

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), session_id (FK), user_id (FK), role (ENUM), admitted_at (TIMESTAMPTZ nullable), left_at (TIMESTAMPTZ nullable), connection_status (ENUM), permissions (JSONB), created_at
- [ ] Role ENUM: 'instructor', 'student', 'guest'
- [ ] Connection status ENUM: 'lobby', 'connected', 'disconnected', 'removed'
- [ ] Composite unique constraint on (session_id, user_id)
- [ ] Indexes on: session_id, user_id, admitted_at
- [ ] Foreign keys cascade delete when session or user deleted

**Data Model Notes:**
```yaml
table: session_participants
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: user_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
  - name: role
    type: enum ['instructor', 'student', 'guest']
    nullable: false
  - name: admitted_at
    type: timestamptz
    nullable: true
  - name: left_at
    type: timestamptz
    nullable: true
  - name: connection_status
    type: enum ['lobby', 'connected', 'disconnected', 'removed']
    default: 'lobby'
  - name: permissions
    type: jsonb
    default: '{}'
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [session_id, connection_status]
    name: idx_participants_session_status
  - columns: [user_id]
    name: idx_participants_user
  - columns: [admitted_at]
    name: idx_participants_admitted
constraints:
  - unique: [session_id, user_id]
    name: uniq_session_user
migration:
  zero_downtime: true
```

---

#### [STR-003] Model: Session with relationships

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/models/Session.js`

**Dependencies:**
- blocked-by: [STR-001], [STR-002]
- needs: [STR-001] (table must exist)
- parallel-with: [STR-004]

**Description:**
Create Sequelize model for Session entity with relationships to User (instructor), Participants, BreakoutRooms, and Recordings. Includes business logic for session lifecycle (schedule → start → end) and join link token generation.

**Acceptance Criteria:**
- [ ] Model class extends Sequelize Model with all table columns defined
- [ ] Relationships: belongsTo User (instructor), hasMany SessionParticipant, hasMany BreakoutRoom, hasOne Recording
- [ ] Instance methods: `start()`, `end()`, `generateJoinToken()`, `isLive()`, `canJoin(user)`, `getParticipantCount()`
- [ ] Static methods: `findByJoinToken(token)`, `findUpcoming(instructorId)`
- [ ] Soft delete scope applied (paranoid: true)
- [ ] Validation: scheduled_end > scheduled_start, max_capacity between 1-1000

**Idempotency:**
- Type: Database unique constraint on join_link_token
- Duplicate handling: 409 Conflict if token collision (crypto.randomBytes ensures 1 in 2^256 odds)

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Session not found | 404 | Return error response |
| Join link expired | 403 | Check scheduled_end + 15 min grace period |
| Capacity exceeded | 403 | Return "Session is full" message |
| Invalid status transition | 400 | Log error, return current state |

**Test Requirements:**
- Unit test: `tests/unit/models/Session.test.js`
- Feature test: `tests/integration/session-lifecycle.test.js`
- Coverage: All instance methods, relationships, validations

---

#### [STR-004] Model: SessionParticipant with connection state

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/models/SessionParticipant.js`

**Dependencies:**
- blocked-by: [STR-002], [STR-003]
- parallel-with: None

**Description:**
Create Sequelize model for SessionParticipant with methods to manage admission workflow (lobby → admitted) and connection status updates (connected, disconnected, removed).

**Acceptance Criteria:**
- [ ] Model class with relationships: belongsTo Session, belongsTo User
- [ ] Instance methods: `admit()`, `remove()`, `updateConnectionStatus(status)`, `isAdmitted()`, `getDuration()`
- [ ] Static methods: `getLobbyQueue(sessionId)`, `getConnectedCount(sessionId)`
- [ ] Validation: role must be valid enum, connection_status transitions valid (lobby → connected, connected → disconnected)
- [ ] Auto-timestamp admitted_at when calling `admit()`

**Test Requirements:**
- Unit test: `tests/unit/models/SessionParticipant.test.js`
- Coverage: Admission workflow, status transitions, duration calculation

---

#### [STR-005] Controller: SessionController (CRUD + start/join/admit/end)

**Size:** L (4-6h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/controllers/SessionController.js`
- `src/routes/sessions.js`
- `src/validators/session.validator.js`

**Dependencies:**
- blocked-by: [STR-003], [STR-004]
- needs: [STR-008] (WebRTC signaling for start action)
- parallel-with: None

**Description:**
Implement REST API controller for session management covering full lifecycle: create scheduled session, start live broadcast, join (enter lobby), admit students, remove participants, and end session. Integrates with WebRTC SignalingService to initialize media server connections.

**Acceptance Criteria:**
- [ ] POST /api/sessions - Create scheduled session (instructor only)
- [ ] GET /api/sessions/:id - Get session details
- [ ] POST /api/sessions/:id/start - Start live session (instructor only, max 10 min before scheduled_start)
- [ ] POST /api/sessions/:id/join - Join session (student enters lobby with connection pre-check)
- [ ] POST /api/sessions/:id/admit - Admit participants from lobby (body: {studentIds: [] or admitAll: true})
- [ ] DELETE /api/sessions/:id/participants/:userId - Remove participant mid-session
- [ ] POST /api/sessions/:id/end - End session (instructor only)
- [ ] Input validation via express-validator for all endpoints
- [ ] Authorization checks: JWT token required, role-based permissions enforced

**Idempotency:**
- Type: Status-based idempotency (cannot start 'live' session twice)
- Key: Session status field acts as state machine lock
- Duplicate handling: Return 409 if session already live, 200 with current state if idempotent repeat

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Start session >10 min early | 403 | "Cannot start more than 10 minutes before scheduled time" |
| Start already-live session | 409 | Return current session state with signaling URL |
| Join ended session | 403 | "Session has ended" |
| Admit non-existent student | 404 | Skip invalid IDs, log warning |
| Remove last instructor | 400 | "Cannot remove last instructor from session" |
| Mediasoup SFU unavailable | 503 | Circuit breaker active, retry after 30s |

**Reliability Notes:**
- Queue: N/A (synchronous API calls)
- Transaction scope: Yes - wrap status updates + participant changes in DB transaction
- Timeout: 30s for /start endpoint (Mediasoup room creation)

**Security Checklist:**
- [ ] Input validation via SessionValidator class
- [ ] Authorization: instructorOnly middleware for start/admit/remove/end
- [ ] Rate limiting: 60 req/min per user (general), 5 req/min for /start (prevent spam)
- [ ] CSRF protection: N/A (stateless JWT API)
- [ ] SQL injection prevention: Sequelize ORM parameterized queries

**Test Requirements:**
- Unit test: `tests/unit/controllers/SessionController.test.js`
- Feature test: `tests/integration/session-api.test.js`
- Coverage: All 7 endpoints, error cases, authorization edge cases

---

#### [STR-006] Test: Session lifecycle integration test

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `tests/integration/session-lifecycle.test.js`

**Dependencies:**
- blocked-by: [STR-005]
- needs: [STR-005], [STR-008] (full stack required)
- parallel-with: None

**Description:**
End-to-end integration test covering complete session lifecycle: instructor creates scheduled session → starts 5 min early → students join lobby → instructor admits all → session runs → instructor ends → recording processes.

**Acceptance Criteria:**
- [ ] Test creates instructor user, schedules session, starts successfully
- [ ] Test creates 3 student users, each joins and enters lobby
- [ ] Test admits all students from lobby, verifies connection_status = 'connected'
- [ ] Test removes 1 student mid-session, verifies disconnection
- [ ] Test ends session, verifies status = 'ended' and recording initiated
- [ ] Test validates database state after each step (transactions committed)
- [ ] Test runs in <15 seconds (use test database with minimal fixtures)

**Test Requirements:**
- Feature test: This task itself
- Coverage: Happy path + 1 error case (start session too early)

---

### Slice 2: WebRTC & Real-time Communication

#### [STR-007] Service: SignalingService for WebSocket management

**Size:** L (4-6h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/services/SignalingService.js`
- `src/websocket/signaling.handler.js`

**Dependencies:**
- blocked-by: [STR-003] (needs Session model)
- parallel-with: [STR-008]

**Description:**
Implement WebSocket-based signaling server using Socket.io for WebRTC offer/answer/ICE candidate exchange, room state synchronization, and real-time presence tracking. Manages socket connections per session room with authentication and connection lifecycle events.

**Acceptance Criteria:**
- [ ] Socket.io server initialized with JWT authentication middleware
- [ ] Handles events: 'join-session', 'leave-session', 'webrtc-offer', 'webrtc-answer', 'ice-candidate', 'room-state-request'
- [ ] Maintains in-memory Map<sessionId, Set<socketId>> for active connections
- [ ] Broadcasts room state updates (new participant, participant left, status change) to all sockets in session room
- [ ] Emits 'peer-joined' event when new student admitted, includes user metadata for client-side peer connection setup
- [ ] Graceful disconnect handling: updates participant connection_status, notifies room, cleans up socket references
- [ ] Connection recovery: allows rejoining with same user_id, restores room state

**Idempotency:**
- Type: Connection-based idempotency (socket.id as unique key)
- Duplicate handling: If user already connected (duplicate tab), disconnect old socket and replace with new

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Invalid JWT on connect | 401 | Reject socket connection, emit 'error' event |
| Session not found | 404 | Emit 'session-not-found', disconnect socket |
| User not admitted | 403 | Emit 'not-admitted', keep in lobby namespace |
| WebSocket connection drops | N/A | Mark connection_status = 'disconnected', attempt reconnect for 30s |

**Reliability Notes:**
- Connection timeout: 30s ping interval, disconnect if 2 consecutive pings missed
- Reconnection window: 30s grace period before marking user as "left session"
- Redis pub/sub: Use for multi-server signaling (if horizontally scaled)

**Security Checklist:**
- [ ] JWT verification on socket connection
- [ ] Room isolation: sockets can only emit to rooms they've joined
- [ ] Rate limiting: 100 messages/min per socket (prevent spam)
- [ ] Input validation on all socket event payloads

**Test Requirements:**
- Unit test: `tests/unit/services/SignalingService.test.js`
- Integration test: `tests/integration/websocket-signaling.test.js`
- Coverage: Connection lifecycle, room broadcasts, error handling

---

#### [STR-008] Service: MediaServerService for Mediasoup integration

**Size:** XL (6-8h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/services/MediaServerService.js`
- `config/mediasoup.config.js`

**Dependencies:**
- blocked-by: [STR-003] (needs Session model)
- parallel-with: [STR-007]

**Description:**
Integrate Mediasoup SFU for WebRTC media routing. Manages Mediasoup Worker processes, creates Router instances per session, handles Producer (instructor stream) and Consumer (student subscriptions) creation, and implements adaptive bitrate layers (360p/720p/1080p) for bandwidth adaptation.

**Acceptance Criteria:**
- [ ] Initializes Mediasoup Worker pool (4 workers for CPU parallelism)
- [ ] Creates Router per session with configurable RTP capabilities (VP8, Opus codecs)
- [ ] Instance methods: `createSession(sessionId)`, `createProducer(sessionId, producerOptions)`, `createConsumer(sessionId, consumerId, rtpCapabilities)`, `closeSession(sessionId)`
- [ ] Handles WebRTC transport creation (WebRtcTransport) with TURN/STUN server configuration
- [ ] Implements simulcast layers: 360p (Layer 0), 720p (Layer 1), 1080p (Layer 2) for adaptive bitrate
- [ ] Automatically switches consumer layers based on bandwidth estimation (client-reported)
- [ ] Cleans up resources: closes transports, producers, consumers when session ends
- [ ] Exposes metrics: active routers, active producers/consumers, CPU usage per worker

**Idempotency:**
- Type: Session-based idempotency (one router per session_id)
- Duplicate handling: If session already has router, return existing router instead of creating new

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Worker crash | 500 | Restart worker, migrate sessions to new worker, log critical alert |
| Router creation fails | 500 | Retry once, if fails again return 503 Service Unavailable |
| TURN server unreachable | 503 | Fall back to STUN-only (may fail for users behind symmetric NAT) |
| Consumer creation timeout | 504 | Log error, notify client, do not block other consumers |

**Reliability Notes:**
- Worker pool: 4 workers, round-robin session assignment
- Graceful shutdown: Close all routers, wait for in-progress transports to drain (max 10s)
- Health check: Ping workers every 10s, restart if unresponsive
- Circuit breaker: If 3+ router creation failures in 1 min, return 503 and alert ops

**Security Checklist:**
- [ ] WebRTC transports use DTLS-SRTP encryption (built-in Mediasoup)
- [ ] TURN credentials rotate every 24 hours (Twilio API)
- [ ] No direct client access to Mediasoup workers (API proxies all requests)

**Test Requirements:**
- Unit test: `tests/unit/services/MediaServerService.test.js`
- Integration test: `tests/integration/mediasoup-webrtc.test.js` (requires Mediasoup running)
- Coverage: Router lifecycle, producer/consumer creation, error recovery

---

#### [STR-009] Middleware: WebRTC authentication & authorization

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/middleware/webrtc-auth.middleware.js`

**Dependencies:**
- blocked-by: [STR-007]
- parallel-with: [STR-010]

**Description:**
Express middleware to authenticate WebRTC signaling requests via JWT and authorize user access to specific session rooms based on participant status (admitted vs. lobby).

**Acceptance Criteria:**
- [ ] Verifies JWT token from `Authorization: Bearer <token>` header
- [ ] Extracts user_id and session_id from token payload
- [ ] Queries SessionParticipant to verify user is admitted (connection_status != 'removed')
- [ ] Attaches `req.user` and `req.participant` objects for downstream handlers
- [ ] Returns 401 if token invalid, 403 if user not admitted or removed
- [ ] Handles token expiration: returns 401 with 'token_expired' error code for client refresh

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Missing Authorization header | 401 | "Authorization token required" |
| Invalid JWT signature | 401 | "Invalid token" |
| Token expired | 401 | "Token expired", client should refresh |
| User not admitted to session | 403 | "Access denied - not admitted to session" |
| User removed from session | 403 | "Access denied - removed from session" |

**Test Requirements:**
- Unit test: `tests/unit/middleware/webrtc-auth.test.js`
- Coverage: Valid token, expired token, removed participant, missing token

---

#### [STR-010] Controller: WebRTC signaling endpoints

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/controllers/WebRTCController.js`
- `src/routes/webrtc.js`

**Dependencies:**
- blocked-by: [STR-008], [STR-009]
- parallel-with: None

**Description:**
REST API endpoints for WebRTC transport creation, RTP capabilities exchange, and producer/consumer setup. Wraps MediaServerService calls with authentication and error handling.

**Acceptance Criteria:**
- [ ] POST /api/webrtc/sessions/:id/router-rtp-capabilities - Get router RTP capabilities for client WebRTC initialization
- [ ] POST /api/webrtc/sessions/:id/transports/create - Create WebRtcTransport (send or receive)
- [ ] POST /api/webrtc/sessions/:id/transports/:transportId/connect - Connect transport with DTLS parameters
- [ ] POST /api/webrtc/sessions/:id/producers/create - Create producer (instructor video/audio stream)
- [ ] POST /api/webrtc/sessions/:id/consumers/create - Create consumer (student subscribes to instructor stream)
- [ ] DELETE /api/webrtc/sessions/:id/producers/:producerId - Close producer
- [ ] All endpoints require webrtc-auth middleware, return 403 if not admitted

**Idempotency:**
- Type: Client-provided idempotency key in request header `Idempotency-Key`
- Storage: Redis cache with 24h TTL: key = `idempotency:${session_id}:${user_id}:${endpoint}:${key}`, value = response JSON
- Duplicate handling: Return cached response with 200 status if key exists

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Mediasoup router not found | 404 | "Session media server not initialized" |
| Transport creation timeout | 504 | Log error, return timeout message, client retries |
| Consumer creation fails | 500 | Log error with producer_id, return generic error to client |

**Reliability Notes:**
- Timeout: 10s per Mediasoup operation (create transport/producer/consumer)
- Retry: Client-side retry recommended for transient failures (3 attempts)

**Security Checklist:**
- [ ] webrtc-auth middleware applied to all routes
- [ ] Rate limiting: 120 req/min per user (high limit for frequent signaling)
- [ ] Input validation for DTLS parameters, RTP capabilities

**Test Requirements:**
- Integration test: `tests/integration/webrtc-api.test.js`
- Coverage: Transport creation, producer/consumer flows, error cases

---

#### [STR-011] Test: WebRTC connection flow end-to-end

**Size:** L (4-6h)
**Priority:** P1
**Complexity:** High

**File(s):**
- `tests/integration/webrtc-connection-flow.test.js`

**Dependencies:**
- blocked-by: [STR-010]
- needs: [STR-007], [STR-008], [STR-010] (full WebRTC stack)
- parallel-with: None

**Description:**
Integration test simulating full WebRTC connection flow: instructor starts session → creates producer → student joins → creates consumer → verifies media stream routing via Mediasoup. Uses actual Mediasoup test instance and Socket.io client.

**Acceptance Criteria:**
- [ ] Test starts session, instructor creates send transport, produces video track
- [ ] Test student joins, creates receive transport, consumes instructor video
- [ ] Test verifies producer.id matches consumer.producerId (media routing correct)
- [ ] Test verifies RTP packets flowing (mock RTP send/receive, check stats)
- [ ] Test handles disconnection: closes transports, verifies cleanup
- [ ] Test runs in <30 seconds (uses in-memory Mediasoup workers)

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + disconnect/reconnect scenario

---

### Slice 3: Breakout Rooms

#### [STR-012] Migration: Create breakout_rooms table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000003_create_breakout_rooms_table.js`

**Dependencies:**
- blocked-by: [STR-001] (foreign key to sessions)
- parallel-with: [STR-013]

**Description:**
Create the `breakout_rooms` table to store breakout room metadata including room name, capacity, time limits, and lifecycle timestamps (created_at, closed_at).

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), session_id (FK), room_name (VARCHAR 100), capacity (INT default 10), time_limit_minutes (INT nullable), created_at, closed_at (nullable)
- [ ] Foreign key on session_id → sessions.id with ON DELETE CASCADE
- [ ] Index on session_id for querying all rooms in a session
- [ ] Check constraint: capacity between 2-50, time_limit_minutes between 1-120
- [ ] Up and down methods implemented

**Data Model Notes:**
```yaml
table: breakout_rooms
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: room_name
    type: varchar(100)
    nullable: false
  - name: capacity
    type: integer
    default: 10
    check: capacity >= 2 AND capacity <= 50
  - name: time_limit_minutes
    type: integer
    nullable: true
    check: time_limit_minutes >= 1 AND time_limit_minutes <= 120
  - name: created_at
    type: timestamptz
    nullable: false
  - name: closed_at
    type: timestamptz
    nullable: true
indexes:
  - columns: [session_id]
    name: idx_breakout_session
  - columns: [created_at]
    name: idx_breakout_created
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/breakout-rooms-table.test.js`

---

#### [STR-013] Migration: Create room_assignments table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000004_create_room_assignments_table.js`

**Dependencies:**
- blocked-by: [STR-012], [STR-002]
- parallel-with: None

**Description:**
Create the `room_assignments` table to track which participants are assigned to which breakout rooms, including transition timestamps (assigned_at, joined_at, left_at).

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), breakout_room_id (FK), participant_id (FK to session_participants), assigned_at, joined_at (nullable), left_at (nullable)
- [ ] Foreign keys with ON DELETE CASCADE for both breakout_room_id and participant_id
- [ ] Composite unique constraint on (breakout_room_id, participant_id)
- [ ] Indexes on: breakout_room_id, participant_id, assigned_at

**Data Model Notes:**
```yaml
table: room_assignments
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: breakout_room_id
    type: uuid
    nullable: false
    foreign_key: breakout_rooms.id
    on_delete: cascade
  - name: participant_id
    type: uuid
    nullable: false
    foreign_key: session_participants.id
    on_delete: cascade
  - name: assigned_at
    type: timestamptz
    nullable: false
  - name: joined_at
    type: timestamptz
    nullable: true
  - name: left_at
    type: timestamptz
    nullable: true
indexes:
  - columns: [breakout_room_id, participant_id]
    name: idx_room_assignments_unique
    unique: true
  - columns: [participant_id]
    name: idx_room_assignments_participant
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/room-assignments-table.test.js`

---

#### [STR-014] Model: BreakoutRoom with assignment logic

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/models/BreakoutRoom.js`
- `src/models/RoomAssignment.js`

**Dependencies:**
- blocked-by: [STR-012], [STR-013]
- parallel-with: None

**Description:**
Create Sequelize models for BreakoutRoom and RoomAssignment with methods for room creation, student assignment (manual or auto), capacity management, and time limit enforcement.

**Acceptance Criteria:**
- [ ] BreakoutRoom model: relationships to Session (belongsTo), RoomAssignments (hasMany)
- [ ] BreakoutRoom methods: `assignParticipants(participantIds)`, `isFull()`, `getActiveParticipants()`, `close()`, `getRemainingTime()`
- [ ] RoomAssignment model: relationships to BreakoutRoom (belongsTo), SessionParticipant (belongsTo)
- [ ] RoomAssignment methods: `markJoined()`, `markLeft()`, `getDuration()`
- [ ] Static method: `BreakoutRoom.createWithAssignments(sessionId, roomConfigs)` - bulk create rooms with assignments in transaction
- [ ] Validation: room capacity not exceeded, participant not assigned to multiple active rooms simultaneously

**Test Requirements:**
- Unit test: `tests/unit/models/BreakoutRoom.test.js`
- Coverage: Assignment logic, capacity checks, time limit enforcement

---

#### [STR-015] Controller: BreakoutRoomController (create/assign/broadcast/close)

**Size:** L (4-6h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/controllers/BreakoutRoomController.js`
- `src/routes/breakout-rooms.js`

**Dependencies:**
- blocked-by: [STR-014]
- needs: [STR-007] (WebSocket for broadcast messages)
- parallel-with: None

**Description:**
Implement REST API for breakout room orchestration: create rooms (manual or auto-assign), assign students, broadcast messages to all rooms, close rooms (manual or time-based auto-close).

**Acceptance Criteria:**
- [ ] POST /api/sessions/:id/breakout-rooms - Create breakout rooms (body: {rooms: [{name, capacity, participantIds}], autoAssign: bool})
- [ ] POST /api/sessions/:id/breakout-rooms/:roomId/assign - Manually assign additional students
- [ ] POST /api/sessions/:id/breakout-rooms/broadcast - Broadcast message to all rooms (body: {message})
- [ ] POST /api/sessions/:id/breakout-rooms/close-all - Close all breakout rooms, return students to main session
- [ ] DELETE /api/sessions/:id/breakout-rooms/:roomId - Close specific room
- [ ] GET /api/sessions/:id/breakout-rooms - List all rooms with participant counts
- [ ] Auto-assignment algorithm: distribute students evenly across N rooms
- [ ] WebSocket integration: emit 'breakout-room-assigned', 'broadcast-message', 'breakout-room-closing' events

**Idempotency:**
- Type: Database transaction + unique constraints (prevent double assignment)
- Duplicate handling: If create called twice with same config, return existing rooms

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Create rooms while rooms active | 409 | "Breakout rooms already active - close existing first" |
| Assign participant not in session | 404 | Skip invalid participant IDs, log warning |
| Broadcast to zero active rooms | 400 | "No active breakout rooms to broadcast to" |
| Close rooms that don't exist | 404 | Idempotent: return 200 if already closed |

**Reliability Notes:**
- Transaction scope: Yes - create all rooms + assignments in single transaction
- Timeout: 30s for create endpoint (multiple DB inserts + WebSocket emits)

**Security Checklist:**
- [ ] instructorOnly middleware on all endpoints (students cannot create rooms)
- [ ] Input validation: room names sanitized, capacity limits enforced
- [ ] Rate limiting: 10 req/min for create (prevent room spam)

**Test Requirements:**
- Integration test: `tests/integration/breakout-room-api.test.js`
- Coverage: Create, assign, broadcast, close workflows

---

#### [STR-016] Service: MultiRoomRoutingService for WebRTC breakout routing

**Size:** XL (6-8h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/services/MultiRoomRoutingService.js`

**Dependencies:**
- blocked-by: [STR-008], [STR-014]
- parallel-with: None

**Description:**
Extend MediaServerService to support multiple simultaneous WebRTC rooms per session (main room + up to 50 breakout rooms). Manages routing table to direct peer connections to correct room, handles room transitions (main → breakout → main), and cleans up room resources.

**Acceptance Criteria:**
- [ ] Maintains routing map: Map<sessionId, Map<roomId, Router>> (main room + breakout rooms)
- [ ] Methods: `createBreakoutRouter(sessionId, breakoutRoomId)`, `moveParticipant(participantId, fromRoomId, toRoomId)`, `closeBreakoutRouter(breakoutRoomId)`
- [ ] Participant transition: gracefully closes old producers/consumers, creates new ones in destination room
- [ ] Transition latency target: <3 seconds from breakout assignment to video visible in new room
- [ ] Resource limits: max 50 concurrent routers per session (main + 49 breakouts)
- [ ] Automatic cleanup: closes breakout routers when room closed_at timestamp set
- [ ] Broadcasting: supports instructor temporary join to breakout room (creates producer in that router)

**Idempotency:**
- Type: Room-based idempotency (one router per breakout_room_id)
- Duplicate handling: Return existing router if already created for room

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Exceed 50 room limit | 429 | "Maximum breakout room limit reached" |
| Move participant to non-existent room | 404 | "Breakout room not found" |
| Router creation fails | 500 | Retry once, log error, return 503 if retry fails |

**Reliability Notes:**
- Graceful degradation: If Mediasoup worker overloaded, reject new breakout rooms but keep main session running
- Resource monitoring: Alert if active routers >40 (approaching limit)

**Test Requirements:**
- Unit test: `tests/unit/services/MultiRoomRoutingService.test.js`
- Integration test: `tests/integration/multi-room-routing.test.js`
- Coverage: Room creation, participant transitions, cleanup

---

#### [STR-017] Test: Breakout room end-to-end flow

**Size:** L (4-6h)
**Priority:** P1
**Complexity:** High

**File(s):**
- `tests/integration/breakout-room-flow.test.js`

**Dependencies:**
- blocked-by: [STR-016]
- needs: [STR-015], [STR-016]
- parallel-with: None

**Description:**
Integration test simulating breakout room workflow: instructor creates 3 rooms → assigns 9 students (3 per room) → students transition to rooms → instructor broadcasts message → rooms close → students return to main session.

**Acceptance Criteria:**
- [ ] Test creates session with 10 participants (1 instructor, 9 students)
- [ ] Test creates 3 breakout rooms, auto-assigns students
- [ ] Test verifies each student receives 'breakout-room-assigned' WebSocket event with room details
- [ ] Test verifies WebRTC routers created per room, students connected to correct router
- [ ] Test instructor broadcasts "2 minutes remaining", verifies all 9 students receive message
- [ ] Test closes all rooms, verifies students return to main session router
- [ ] Test runs in <45 seconds

**Test Requirements:**
- Integration test: This task itself
- Coverage: Full breakout lifecycle + broadcast

---

### Slice 4: Interactive Features - Chat & Hand Raise

#### [STR-018] Migration: Create chat_messages table

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000005_create_chat_messages_table.js`

**Dependencies:**
- blocked-by: [STR-001], [STR-012]
- parallel-with: [STR-019]

**Description:**
Create the `chat_messages` table to store text chat messages sent during sessions (main room and breakout rooms). Includes message type (text, emoji, system) and supports both session-wide and breakout-room-specific messages.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), session_id (FK), breakout_room_id (FK nullable), user_id (FK), message_text (TEXT), message_type (ENUM), sent_at
- [ ] Message type ENUM: 'text', 'emoji', 'system'
- [ ] Foreign keys with ON DELETE CASCADE for session_id, breakout_room_id, user_id
- [ ] Indexes on: (session_id, sent_at), (breakout_room_id, sent_at), user_id
- [ ] Partitioning by sent_at (monthly partitions) for scalability
- [ ] Data retention: hard delete messages >90 days via cron job

**Data Model Notes:**
```yaml
table: chat_messages
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: breakout_room_id
    type: uuid
    nullable: true
    foreign_key: breakout_rooms.id
    on_delete: cascade
  - name: user_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
  - name: message_text
    type: text
    nullable: false
  - name: message_type
    type: enum ['text', 'emoji', 'system']
    default: 'text'
  - name: sent_at
    type: timestamptz
    nullable: false
    default: now()
indexes:
  - columns: [session_id, sent_at]
    name: idx_chat_session_time
  - columns: [breakout_room_id, sent_at]
    name: idx_chat_breakout_time
  - columns: [user_id]
    name: idx_chat_user
constraints:
  - check: length(message_text) <= 1000
migration:
  zero_downtime: true
  partitioning: true (by sent_at, monthly partitions)
```

**Test Requirements:**
- Unit test: `tests/migrations/chat-messages-table.test.js`

---

#### [STR-019] Migration: Create hand_raises table

**Size:** XS (0.5-1h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000006_create_hand_raises_table.js`

**Dependencies:**
- blocked-by: [STR-001]
- parallel-with: [STR-018]

**Description:**
Create the `hand_raises` table to track student hand raise queue with timestamps for raised, acknowledged, and dismissed states.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), session_id (FK), user_id (FK), raised_at, acknowledged_at (nullable), status (ENUM)
- [ ] Status ENUM: 'active', 'acknowledged', 'dismissed'
- [ ] Foreign keys with ON DELETE CASCADE
- [ ] Indexes on: (session_id, status, raised_at) for queue ordering
- [ ] Unique constraint on (session_id, user_id, status='active') - one active hand raise per student

**Data Model Notes:**
```yaml
table: hand_raises
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: user_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
  - name: raised_at
    type: timestamptz
    nullable: false
    default: now()
  - name: acknowledged_at
    type: timestamptz
    nullable: true
  - name: status
    type: enum ['active', 'acknowledged', 'dismissed']
    default: 'active'
indexes:
  - columns: [session_id, status, raised_at]
    name: idx_hand_raises_queue
constraints:
  - unique: [session_id, user_id, status] WHERE status = 'active'
    name: uniq_active_hand_raise
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/hand-raises-table.test.js`

---

#### [STR-020] Model: ChatMessage with real-time sync

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/models/ChatMessage.js`

**Dependencies:**
- blocked-by: [STR-018]
- parallel-with: [STR-021]

**Description:**
Create Sequelize model for ChatMessage with relationships and query methods for retrieving chat history (paginated, time-ordered).

**Acceptance Criteria:**
- [ ] Model with relationships: belongsTo Session, belongsTo User, belongsTo BreakoutRoom (optional)
- [ ] Static methods: `getSessionHistory(sessionId, limit, beforeTimestamp)`, `getBreakoutHistory(breakoutRoomId, limit)`
- [ ] Validation: message_text max 1000 chars, message_type valid enum
- [ ] Scopes: `mainSessionOnly` (breakout_room_id IS NULL), `breakoutOnly` (breakout_room_id IS NOT NULL)

**Test Requirements:**
- Unit test: `tests/unit/models/ChatMessage.test.js`
- Coverage: History queries, pagination, scope filters

---

#### [STR-021] Controller: ChatController & HandRaiseController

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/controllers/ChatController.js`
- `src/controllers/HandRaiseController.js`
- `src/routes/chat.js`
- `src/routes/hand-raise.js`

**Dependencies:**
- blocked-by: [STR-020]
- needs: [STR-007] (WebSocket for real-time broadcast)
- parallel-with: None

**Description:**
Implement REST API + WebSocket integration for chat messaging and hand raise queue management. Messages broadcast via Socket.io, hand raises emit to instructor dashboard.

**Acceptance Criteria:**
- [ ] POST /api/sessions/:id/chat - Send chat message (body: {message, messageType, breakoutRoomId})
- [ ] GET /api/sessions/:id/chat - Get chat history (query: limit=50, before=timestamp)
- [ ] POST /api/sessions/:id/hand-raise - Raise hand (idempotent: returns existing if already raised)
- [ ] DELETE /api/sessions/:id/hand-raise - Lower hand (dismiss active hand raise)
- [ ] POST /api/sessions/:id/hand-raise/:id/acknowledge - Instructor acknowledges hand raise
- [ ] GET /api/sessions/:id/hand-raise - Get current queue (ordered by raised_at)
- [ ] WebSocket: emit 'chat-message' to session room on new message, emit 'hand-raised' and 'hand-acknowledged' to instructor

**Idempotency:**
- Type: Unique constraint on hand_raises (session_id, user_id, status='active')
- Duplicate handling: POST hand-raise returns 200 with existing hand raise if already active

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Send empty chat message | 400 | "Message cannot be empty" |
| Chat message >1000 chars | 400 | "Message too long (max 1000 chars)" |
| Raise hand twice | 200 | Return existing hand raise (idempotent) |
| Acknowledge non-existent hand raise | 404 | "Hand raise not found" |

**Reliability Notes:**
- Queue: N/A (synchronous API)
- Transaction scope: No (single INSERT operations)

**Security Checklist:**
- [ ] Input validation: message sanitization (strip HTML), length check
- [ ] Rate limiting: 60 messages/min per user (chat), 10 hand raises/min
- [ ] Authorization: participants can only send messages to their current room (main or breakout)

**Test Requirements:**
- Integration test: `tests/integration/chat-hand-raise-api.test.js`
- Coverage: Send message, get history, raise hand, acknowledge, WebSocket events

---

#### [STR-022] Test: Chat and hand raise features

**Size:** S (1-2h)
**Priority:** P2
**Complexity:** Low

**File(s):**
- `tests/integration/chat-hand-raise-features.test.js`

**Dependencies:**
- blocked-by: [STR-021]
- parallel-with: None

**Description:**
Integration test verifying chat history retrieval, real-time message broadcast, and hand raise queue ordering.

**Acceptance Criteria:**
- [ ] Test sends 10 chat messages, retrieves history, verifies chronological order
- [ ] Test 3 students raise hand, verifies queue order by raised_at
- [ ] Test instructor acknowledges first hand raise, verifies status update
- [ ] Test WebSocket receives 'chat-message' and 'hand-raised' events in real-time

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + queue ordering

---

### Slice 5: Recording & Playback

#### [STR-023] Migration: Create session_recordings table

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000007_create_session_recordings_table.js`

**Dependencies:**
- blocked-by: [STR-001]
- parallel-with: None

**Description:**
Create the `session_recordings` table to store recording file metadata including S3 file path, processing status, duration, and availability timestamp.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), session_id (FK), file_path (VARCHAR 500), file_size_mb (DECIMAL), duration_seconds (INT), processing_status (ENUM), available_at (TIMESTAMPTZ nullable), created_at
- [ ] Processing status ENUM: 'pending', 'processing', 'available', 'failed'
- [ ] Foreign key on session_id → sessions.id with ON DELETE CASCADE
- [ ] Indexes on: session_id, processing_status, available_at
- [ ] Check constraint: file_size_mb > 0, duration_seconds > 0

**Data Model Notes:**
```yaml
table: session_recordings
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: file_path
    type: varchar(500)
    nullable: false
    comment: S3 bucket path (e.g., recordings/2026/02/session-abc123.mp4)
  - name: file_size_mb
    type: decimal(10,2)
    nullable: true
  - name: duration_seconds
    type: integer
    nullable: true
  - name: processing_status
    type: enum ['pending', 'processing', 'available', 'failed']
    default: 'pending'
  - name: available_at
    type: timestamptz
    nullable: true
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [session_id]
    name: idx_recordings_session
  - columns: [processing_status, created_at]
    name: idx_recordings_status_time
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/session-recordings-table.test.js`

---

#### [STR-024] Model: Recording with processing state

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/models/Recording.js`

**Dependencies:**
- blocked-by: [STR-023]
- parallel-with: None

**Description:**
Create Sequelize model for Recording with state machine methods for processing workflow (pending → processing → available/failed).

**Acceptance Criteria:**
- [ ] Model with relationship: belongsTo Session
- [ ] Instance methods: `markProcessing()`, `markAvailable(fileSize, duration)`, `markFailed(error)`, `getSignedUrl(expiresIn=3600)` - generates S3 presigned URL
- [ ] Static method: `findPendingRecordings()` - query for processing queue
- [ ] State machine: prevents invalid transitions (e.g., cannot go from 'available' back to 'pending')

**Test Requirements:**
- Unit test: `tests/unit/models/Recording.test.js`
- Coverage: State transitions, presigned URL generation

---

#### [STR-025] Job: RecordingProcessingJob (capture, encode, upload)

**Size:** XL (6-8h)
**Priority:** P1
**Complexity:** High

**File(s):**
- `src/jobs/RecordingProcessingJob.js`
- `src/services/RecordingCaptureService.js`
- `src/services/S3UploadService.js`

**Dependencies:**
- blocked-by: [STR-024]
- needs: [STR-008] (Mediasoup for stream capture)
- parallel-with: None

**Description:**
Background job to capture WebRTC streams from Mediasoup, encode to H.264 MP4 using FFmpeg, upload to S3, and update recording status. Handles multiple concurrent recordings and retry logic for transient failures.

**Acceptance Criteria:**
- [ ] Captures audio/video from Mediasoup PlainTransport (RTP stream → FFmpeg)
- [ ] Encodes to H.264 (video) + AAC (audio) at 1080p, 30fps, 5 Mbps bitrate
- [ ] Uploads to S3 bucket `recordings/YYYY/MM/session-{id}.mp4` with multipart upload
- [ ] Encrypts file at rest with AES-256 (S3 server-side encryption)
- [ ] Updates Recording model: processing_status transitions, file metadata, available_at timestamp
- [ ] Job triggered on session end via RabbitMQ queue 'recording-processing'
- [ ] Concurrency: max 5 concurrent processing jobs (FFmpeg CPU-intensive)
- [ ] Cleanup: deletes local temp files after successful upload

**Idempotency:**
- Type: Recording status check (skip if already processing/available)
- Key: Recording.id
- Duplicate handling: If job retried, checks status first, exits early if already processed

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| FFmpeg encoding fails | N/A | Retry job up to 3 times, mark 'failed' if all retries fail, alert ops |
| S3 upload timeout | N/A | Retry S3 upload (3 attempts with exponential backoff), keep local file until success |
| Mediasoup stream unavailable | N/A | Log error, mark 'failed', notify instructor via email |
| Disk space full | N/A | Alert ops, pause processing queue, free space before retry |

**Reliability Notes:**
- Queue: `recording-processing` (RabbitMQ)
- Tries: 3 attempts
- Backoff: Exponential (5 min, 15 min, 45 min)
- Timeout: 60 minutes per job (large sessions can take 30-40 min to encode)
- Transaction scope: No (updates Recording status progressively)
- Dead letter queue: Yes - failed jobs after 3 attempts moved to `recording-processing-failed`

**Security Checklist:**
- [ ] S3 bucket private (no public access), presigned URLs for playback
- [ ] Encryption at rest (AES-256 via S3 SSE)
- [ ] Encryption in transit (TLS for S3 upload)
- [ ] Temp files deleted immediately after upload (no local retention)

**Test Requirements:**
- Unit test: `tests/unit/jobs/RecordingProcessingJob.test.js`
- Integration test: `tests/integration/recording-processing.test.js` (requires FFmpeg, S3 mock)
- Coverage: Happy path, encoding failure, S3 upload retry

---

#### [STR-026] Controller: RecordingController (start, stop, playback)

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/controllers/RecordingController.js`
- `src/routes/recordings.js`

**Dependencies:**
- blocked-by: [STR-024], [STR-025]
- parallel-with: None

**Description:**
Implement REST API for recording management: start/stop recording during session, retrieve recording metadata, generate presigned playback URLs.

**Acceptance Criteria:**
- [ ] POST /api/sessions/:id/recording/start - Start recording (instructor only, creates Recording with status='pending')
- [ ] POST /api/sessions/:id/recording/stop - Stop recording (triggers RecordingProcessingJob)
- [ ] GET /api/recordings/:id - Get recording metadata (status, duration, file size)
- [ ] GET /api/recordings/:id/playback - Get presigned S3 URL for video playback (expires in 1 hour)
- [ ] GET /api/sessions/:id/recordings - List all recordings for session
- [ ] Authorization: participants can access recordings for sessions they attended, instructors can access all for their sessions

**Idempotency:**
- Type: Status-based (cannot start recording if already started)
- Duplicate handling: Return 409 if recording already started

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Start recording on ended session | 400 | "Cannot record ended session" |
| Stop recording not started | 400 | "No active recording to stop" |
| Access recording not available | 403 | "Recording still processing" |
| Access recording from non-participant | 403 | "Access denied - not a session participant" |

**Reliability Notes:**
- Timeout: 30s for start/stop (synchronous DB updates)
- Playback URL expires: 1 hour (regenerate on subsequent requests)

**Security Checklist:**
- [ ] instructorOnly middleware for start/stop
- [ ] Authorization: verify participant attended session for playback access
- [ ] Rate limiting: 120 req/min for playback (high limit for video player)
- [ ] Presigned URLs expire after 1 hour (prevent link sharing)

**Test Requirements:**
- Integration test: `tests/integration/recording-api.test.js`
- Coverage: Start, stop, playback, authorization checks

---

#### [STR-027] Test: Recording workflow end-to-end

**Size:** M (2-4h)
**Priority:** P2
**Complexity:** Medium

**File(s):**
- `tests/integration/recording-workflow.test.js`

**Dependencies:**
- blocked-by: [STR-026]
- needs: [STR-025], [STR-026]
- parallel-with: None

**Description:**
Integration test simulating full recording workflow: start recording → capture stream → stop → job processes → file uploaded to S3 → playback URL generated.

**Acceptance Criteria:**
- [ ] Test starts session, starts recording, verifies Recording created with status='pending'
- [ ] Test stops recording, verifies RecordingProcessingJob queued
- [ ] Test mocks FFmpeg encoding (fast mode), verifies status → 'processing'
- [ ] Test mocks S3 upload, verifies status → 'available', available_at set
- [ ] Test retrieves playback URL, verifies presigned URL format
- [ ] Test runs in <30 seconds (uses mocks, no actual encoding)

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + processing failure scenario

---

### Slice 6: Whiteboard & Polls

#### [STR-028] Migration: Create whiteboards table

**Size:** S (1-2h)
**Priority:** P2
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000008_create_whiteboards_table.js`

**Dependencies:**
- blocked-by: [STR-001], [STR-012]
- parallel-with: [STR-029]

**Description:**
Create the `whiteboards` table to store collaborative canvas state as JSONB, supporting both main session and breakout room whiteboards.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), session_id (FK), breakout_room_id (FK nullable), canvas_data (JSONB), last_updated_at
- [ ] Foreign keys with ON DELETE CASCADE
- [ ] Indexes on: session_id, breakout_room_id
- [ ] JSONB structure: {strokes: [{id, tool, color, width, points: []}], shapes: [], text: []}
- [ ] Check constraint: canvas_data size <10 MB (prevents abuse)

**Data Model Notes:**
```yaml
table: whiteboards
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: breakout_room_id
    type: uuid
    nullable: true
    foreign_key: breakout_rooms.id
    on_delete: cascade
  - name: canvas_data
    type: jsonb
    nullable: false
    default: '{"strokes": [], "shapes": [], "text": []}'
  - name: last_updated_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [session_id]
    name: idx_whiteboards_session
  - columns: [breakout_room_id]
    name: idx_whiteboards_breakout
constraints:
  - check: pg_column_size(canvas_data) < 10485760 (10 MB limit)
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/whiteboards-table.test.js`

---

#### [STR-029] Migration: Create session_polls and poll_responses tables

**Size:** S (1-2h)
**Priority:** P2
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000009_create_polls_tables.js`

**Dependencies:**
- blocked-by: [STR-001]
- parallel-with: [STR-028]

**Description:**
Create two tables: `session_polls` for poll questions and `poll_responses` for student answers. Supports multiple-choice polls with real-time result aggregation.

**Acceptance Criteria:**
- [ ] `session_polls` table: id, session_id (FK), question (TEXT), options (JSONB array), created_at, closed_at (nullable)
- [ ] `poll_responses` table: id, poll_id (FK), user_id (FK), selected_option_index (INT), responded_at
- [ ] Composite unique constraint on poll_responses (poll_id, user_id) - one response per student
- [ ] Indexes on: session_polls.session_id, poll_responses.poll_id

**Data Model Notes:**
```yaml
table: session_polls
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: question
    type: text
    nullable: false
  - name: options
    type: jsonb
    nullable: false
    comment: Array of strings, e.g. ["Option A", "Option B", "Option C"]
  - name: created_at
    type: timestamptz
    nullable: false
  - name: closed_at
    type: timestamptz
    nullable: true
indexes:
  - columns: [session_id, created_at]
    name: idx_polls_session_time

table: poll_responses
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: poll_id
    type: uuid
    nullable: false
    foreign_key: session_polls.id
    on_delete: cascade
  - name: user_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
  - name: selected_option_index
    type: integer
    nullable: false
    check: selected_option_index >= 0
  - name: responded_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [poll_id, user_id]
    name: idx_poll_responses_unique
    unique: true
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/polls-tables.test.js`

---

#### [STR-030] Controller: WhiteboardController & PollController

**Size:** M (2-4h)
**Priority:** P2
**Complexity:** Medium

**File(s):**
- `src/controllers/WhiteboardController.js`
- `src/controllers/PollController.js`
- `src/routes/whiteboard.js`
- `src/routes/polls.js`

**Dependencies:**
- blocked-by: [STR-028], [STR-029]
- needs: [STR-007] (WebSocket for real-time sync)
- parallel-with: None

**Description:**
Implement REST API + WebSocket for whiteboard real-time synchronization and poll creation/response/results.

**Acceptance Criteria:**
- [ ] GET /api/sessions/:id/whiteboard - Get current whiteboard canvas_data
- [ ] PUT /api/sessions/:id/whiteboard - Update whiteboard (body: {canvasData}), broadcasts via WebSocket
- [ ] POST /api/sessions/:id/polls - Create poll (instructor only, body: {question, options})
- [ ] POST /api/polls/:id/responses - Submit poll response (body: {selectedOptionIndex})
- [ ] GET /api/polls/:id/results - Get aggregated results (response counts per option)
- [ ] POST /api/polls/:id/close - Close poll (instructor only, no more responses allowed)
- [ ] WebSocket: emit 'whiteboard-updated' with stroke deltas, emit 'poll-created' and 'poll-results-updated' to session room

**Idempotency:**
- Type: Unique constraint on poll_responses (poll_id, user_id)
- Duplicate handling: Update existing response if student changes answer before poll closed

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Update whiteboard >10 MB | 400 | "Whiteboard data too large" |
| Submit response after poll closed | 403 | "Poll is closed" |
| Submit response with invalid option index | 400 | "Invalid option index" |
| Non-instructor creates poll | 403 | "Only instructors can create polls" |

**Reliability Notes:**
- Transaction scope: No (single UPDATE/INSERT operations)
- WebSocket throttle: 10 whiteboard updates/sec max (prevent flood)

**Security Checklist:**
- [ ] instructorOnly middleware for create poll, close poll, whiteboard (or student with permission)
- [ ] Input validation: poll question/options sanitized, whiteboard data size checked
- [ ] Rate limiting: 60 req/min for whiteboard updates

**Test Requirements:**
- Integration test: `tests/integration/whiteboard-polls-api.test.js`
- Coverage: Whiteboard sync, poll create/respond/results, WebSocket events

---

#### [STR-031] Test: Whiteboard sync and polls

**Size:** S (1-2h)
**Priority:** P2
**Complexity:** Low

**File(s):**
- `tests/integration/whiteboard-polls-features.test.js`

**Dependencies:**
- blocked-by: [STR-030]
- parallel-with: None

**Description:**
Integration test verifying whiteboard real-time updates and poll response aggregation.

**Acceptance Criteria:**
- [ ] Test instructor updates whiteboard, students receive 'whiteboard-updated' event
- [ ] Test instructor creates poll, 5 students respond, verifies results aggregation
- [ ] Test poll closed, student attempt to respond returns 403

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + closed poll scenario

---

### Slice 7: Error Handling & Reliability

#### [STR-032] Middleware: Circuit breaker for Mediasoup connections

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/middleware/circuit-breaker.middleware.js`
- `src/services/CircuitBreakerService.js`

**Dependencies:**
- blocked-by: [STR-008]
- parallel-with: None

**Description:**
Implement circuit breaker pattern for Mediasoup SFU connections using `opossum` library. Prevents cascade failures when Mediasoup workers become unresponsive or overloaded.

**Acceptance Criteria:**
- [ ] Circuit breaker wraps MediaServerService calls (createSession, createProducer, createConsumer)
- [ ] Thresholds: Opens circuit after 5 failures in 60 seconds, half-open after 30 seconds, closes after 3 consecutive successes
- [ ] Fallback: Returns 503 Service Unavailable when circuit open, includes retry-after header (30s)
- [ ] Monitoring: Emits 'circuit-opened', 'circuit-closed' events for logging/alerting
- [ ] Per-worker circuit: Separate circuit breaker per Mediasoup worker (isolated failures)

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Circuit open | 503 | "Media server temporarily unavailable - retry in 30s" |
| Circuit half-open (testing) | 503 or 200 | Allow 1 test request, fail fast others |

**Reliability Notes:**
- Timeout: 10s per Mediasoup operation (triggers circuit if exceeded)
- Fallback response: 503 with detailed error for client retry logic

**Test Requirements:**
- Unit test: `tests/unit/middleware/circuit-breaker.test.js`
- Coverage: Circuit open/close transitions, fallback responses

---

#### [STR-033] Job: Retry logic for recording uploads with exponential backoff

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/jobs/RecordingUploadRetryJob.js`

**Dependencies:**
- blocked-by: [STR-025]
- parallel-with: None

**Description:**
Enhance RecordingProcessingJob with retry logic for S3 upload failures using RabbitMQ retry mechanism and exponential backoff.

**Acceptance Criteria:**
- [ ] Configures RabbitMQ queue with retry policy: 3 attempts, backoff delays [5min, 15min, 45min]
- [ ] On S3 upload failure, job throws error to trigger retry
- [ ] After 3 failed attempts, job moves to dead letter queue 'recording-processing-failed'
- [ ] Failed jobs trigger alert email to ops team with session_id and error details

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| S3 timeout (attempt 1) | N/A | Retry in 5 minutes |
| S3 timeout (attempt 2) | N/A | Retry in 15 minutes |
| S3 timeout (attempt 3) | N/A | Move to DLQ, alert ops |

**Reliability Notes:**
- Dead letter queue: `recording-processing-failed`
- Alert: Email to ops@edustream.com when job enters DLQ

**Test Requirements:**
- Unit test: `tests/unit/jobs/RecordingUploadRetryJob.test.js`
- Coverage: Retry logic, DLQ behavior

---

#### [STR-034] Service: Error monitoring integration (Sentry/DataDog)

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/services/ErrorMonitoringService.js`
- `src/middleware/error-handler.middleware.js`

**Dependencies:**
- blocked-by: None (independent)
- parallel-with: None

**Description:**
Integrate Sentry for error tracking and alerting. Captures unhandled exceptions, API errors, and job failures with context (user_id, session_id, request details).

**Acceptance Criteria:**
- [ ] Initializes Sentry SDK with DSN from environment variable
- [ ] Middleware captures all 5xx errors from Express, sends to Sentry with request context
- [ ] Captures job errors from RabbitMQ queue failures
- [ ] Tags errors by: environment (dev/staging/prod), session_id, user_id, error_type
- [ ] Configures alert rules: >10 errors in 5 min → Slack #alerts channel
- [ ] Excludes 4xx errors (client errors) from Sentry to reduce noise

**Test Requirements:**
- Unit test: `tests/unit/services/ErrorMonitoringService.test.js`
- Coverage: Error capture, tagging, context enrichment

---

#### [STR-035] Configuration: Dead letter queue setup for failed jobs

**Size:** XS (0.5-1h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `config/rabbitmq.config.js`
- `src/queues/setup-dlq.js`

**Dependencies:**
- blocked-by: None
- parallel-with: None

**Description:**
Configure RabbitMQ dead letter queues for all job types (recording processing, notifications). Includes DLQ consumer for manual retry or error analysis.

**Acceptance Criteria:**
- [ ] Creates DLQ for each job queue: `recording-processing-failed`, `notifications-failed`
- [ ] DLQ messages include original error, retry count, timestamps
- [ ] DLQ consumer script (`src/scripts/process-dlq.js`) allows manual job replay
- [ ] DLQ messages retained for 7 days before auto-deletion

**Test Requirements:**
- Integration test: `tests/integration/dlq-setup.test.js`
- Coverage: Job failure → DLQ routing, message retention

---

### Slice 8: Security & Compliance

#### [STR-036] Middleware: Rate limiting per user and endpoint

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/middleware/rate-limit.middleware.js`

**Dependencies:**
- blocked-by: None
- parallel-with: None

**Description:**
Implement Redis-backed rate limiting using `express-rate-limit` with per-user and per-endpoint configurations.

**Acceptance Criteria:**
- [ ] Rate limit configurations:
  - General API: 60 req/min per user
  - Session start: 5 req/min per user
  - Chat: 60 messages/min per user
  - Hand raise: 10 req/min per user
  - WebRTC signaling: 120 req/min per user
- [ ] Uses Redis for distributed rate limiting (multi-server support)
- [ ] Returns 429 Too Many Requests with `Retry-After` header when limit exceeded
- [ ] Exempts instructors from rate limits on their own sessions (bypass for instructorOnly routes)

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Rate limit exceeded | 429 | "Too many requests - retry in {seconds}s" |

**Test Requirements:**
- Integration test: `tests/integration/rate-limiting.test.js`
- Coverage: Limit enforcement, 429 responses, Retry-After headers

---

#### [STR-037] Service: Recording encryption at rest (S3 SSE)

**Size:** XS (0.5-1h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/services/S3UploadService.js` (update)

**Dependencies:**
- blocked-by: [STR-025]
- parallel-with: None

**Description:**
Enable S3 server-side encryption (AES-256) for all recording uploads. Updates S3UploadService to include encryption headers.

**Acceptance Criteria:**
- [ ] S3 upload requests include header: `x-amz-server-side-encryption: AES256`
- [ ] Verifies encryption in S3 metadata after upload (head object request)
- [ ] Fails upload if encryption not applied (hard requirement for COPPA/FERPA)

**Test Requirements:**
- Unit test: `tests/unit/services/S3UploadService.test.js`
- Coverage: Encryption header included, verification check

---

#### [STR-038] Audit: Participant removal audit logs

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/models/AuditLog.js`
- `database/migrations/YYYY_MM_DD_000010_create_audit_logs_table.js`
- `src/controllers/SessionController.js` (update)

**Dependencies:**
- blocked-by: [STR-005]
- parallel-with: None

**Description:**
Create audit logging system for sensitive actions (participant removal, session end, recording start/stop) to comply with FERPA record-keeping requirements.

**Acceptance Criteria:**
- [ ] Migration creates `audit_logs` table: id, session_id, user_id (actor), action (ENUM), target_user_id (nullable), metadata (JSONB), created_at
- [ ] Action ENUM: 'participant_removed', 'session_ended', 'recording_started', 'recording_stopped'
- [ ] SessionController DELETE /participants/:userId creates audit log before removal
- [ ] Audit logs retained for 3 years (FERPA requirement)
- [ ] Admin dashboard view for audit log search (separate story)

**Data Model Notes:**
```yaml
table: audit_logs
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: session_id
    type: uuid
    nullable: false
    foreign_key: sessions.id
    on_delete: cascade
  - name: user_id
    type: uuid
    nullable: false
    comment: User who performed the action
  - name: action
    type: enum ['participant_removed', 'session_ended', 'recording_started', 'recording_stopped']
    nullable: false
  - name: target_user_id
    type: uuid
    nullable: true
    comment: User affected by the action (e.g., removed participant)
  - name: metadata
    type: jsonb
    default: '{}'
    comment: Additional context (reason, timestamp, IP address)
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [session_id, created_at]
    name: idx_audit_logs_session_time
  - columns: [user_id]
    name: idx_audit_logs_actor
retention: 3 years (FERPA compliance)
migration:
  zero_downtime: true
```

**Test Requirements:**
- Integration test: `tests/integration/audit-logging.test.js`
- Coverage: Audit log creation, retention policy

---

## Dependency Graph

### Critical Path (Sequential)

```
[STR-001] → [STR-002] → [STR-003] → [STR-004] → [STR-005] → [STR-006]
Migration → Migration → Model → Model → Controller → Test
Sessions    Participants  Session   Participant SessionCtrl  Integration
1-2h        1-2h          2-4h      1-2h        4-6h         2-4h
═══════════════════════════════════════════════════════════════════════
Total: ~15-24 hours (core session management)

[STR-007] → [STR-008] → [STR-009] → [STR-010] → [STR-011]
Signaling  MediaServer  Auth        WebRTC      Test
4-6h       6-8h         1-2h        2-4h        4-6h
═════════════════════════════════════════════════════════════════
Total: ~17-26 hours (WebRTC infrastructure)

[STR-012] → [STR-013] → [STR-014] → [STR-015] → [STR-016] → [STR-017]
Migration  Migration    Model       Controller  Routing     Test
Breakout   Assignments  Breakout    BreakoutCtrl MultiRoom  Integration
1-2h       1-2h         2-4h        4-6h        6-8h        4-6h
═════════════════════════════════════════════════════════════════════
Total: ~18-28 hours (breakout rooms)
```

**Overall Critical Path**: ~50-78 hours (longest sequential chain through core + WebRTC + breakout rooms)

### Parallel Tracks

**Track A (Core + WebRTC)**: STR-001 → STR-011 (~32-50 hours)
**Track B (Chat/Hand Raise)**: STR-018 → STR-022 (~6-10 hours, can start after STR-001)
**Track C (Recording)**: STR-023 → STR-027 (~14-20 hours, can start after STR-001, needs STR-008)
**Track D (Whiteboard/Polls)**: STR-028 → STR-031 (~6-10 hours, can start after STR-001)
**Track E (Error Handling)**: STR-032 → STR-035 (~6-10 hours, starts after STR-008)
**Track F (Security)**: STR-036 → STR-038 (~4-6 hours, parallel to most tasks)

**Total Estimated Effort**: 68-106 hours (sequential), can be reduced to ~50-78 hours with 2-3 developers working in parallel.

---

## Ambiguity Defaults Applied

| Area | PRD Ambiguity | Default Applied | Override? |
|------|---------------|-----------------|-----------|
| **Delete strategy** | Not specified | Soft delete for sessions/recordings/users; Hard delete for chat messages (90 days) | Can adjust retention period |
| **Pagination** | "Chat history" | Cursor-based pagination, 50 messages per page | - |
| **API versioning** | Not mentioned | No versioning in MVP (v1 implicit), future v2 via `/api/v2/` | - |
| **Error format** | Not specified | RFC 7807 Problem Details: `{type, title, status, detail, instance}` | - |
| **Timestamps** | All tables | `created_at`, `updated_at` (Sequelize timestamps: true) | - |
| **WebRTC reconnection** | "Connection drops" | 30-second reconnection window before marking disconnected | Can adjust timeout |
| **Recording format** | "Cloud recording" | H.264 video (1080p, 30fps), AAC audio, MP4 container | Can add additional formats |
| **Breakout room limit** | "2-50 breakout rooms" | Max 50 concurrent rooms per session, max 10 students per room | - |
| **Chat message retention** | Not specified | Hard delete after 90 days (automated cron job) | Can increase retention |
| **JWT expiration** | "1-hour expiration" from tech.md | 60 minutes, refresh token via `/api/auth/refresh` | - |
| **S3 bucket** | "Cloud storage" | AWS S3 in us-east-1 region, recordings bucket name: `edustream-recordings-prod` | Can adjust region for multi-region |

---

## Export Formats

### Jira CSV Import

```csv
Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels,Assignee
"[STR-001] Migration: Create sessions table","Create sessions table with soft deletes, FK to users, indexes on instructor_id and scheduled_start. See task card for schema.",Task,Highest,1,STREAM-001,"backend,database,migration",
"[STR-002] Migration: Create session_participants table","Create session_participants table with composite unique constraint, connection status tracking. See task card.",Task,Highest,1,STREAM-001,"backend,database,migration",
"[STR-003] Model: Session with relationships","Sequelize Session model with belongsTo User, hasMany Participants, lifecycle methods (start, end).",Task,Highest,3,STREAM-001,"backend,model,node",
"[STR-004] Model: SessionParticipant with connection state","Sequelize SessionParticipant model with admit(), remove(), connection status updates.",Task,Highest,1,STREAM-001,"backend,model,node",
"[STR-005] Controller: SessionController (CRUD + start/join/admit/end)","REST API for session lifecycle: create, start, join, admit, remove, end. 7 endpoints with auth.",Task,Highest,5,STREAM-001,"backend,controller,api,express",
"[STR-006] Test: Session lifecycle integration test","E2E test: instructor creates → starts → students join → admit → remove → end. Full stack.",Task,High,3,STREAM-001,"backend,test,integration",
"[STR-007] Service: SignalingService for WebSocket management","Socket.io signaling server for WebRTC offer/answer/ICE, room state sync, presence tracking.",Task,Highest,5,STREAM-001,"backend,webrtc,websocket,socketio",
"[STR-008] Service: MediaServerService for Mediasoup integration","Mediasoup SFU integration: worker pool, router per session, producer/consumer lifecycle, simulcast.",Task,Highest,8,STREAM-001,"backend,webrtc,mediasoup,sfu",
"[STR-009] Middleware: WebRTC authentication & authorization","JWT auth middleware for WebRTC signaling, verifies participant admitted status.",Task,Highest,1,STREAM-001,"backend,middleware,auth",
"[STR-010] Controller: WebRTC signaling endpoints","REST API for WebRTC transport creation, RTP capabilities, producer/consumer setup.",Task,Highest,3,STREAM-001,"backend,controller,webrtc,api",
"[STR-011] Test: WebRTC connection flow end-to-end","Integration test: instructor produces video → student consumes → verifies RTP routing via Mediasoup.",Task,High,5,STREAM-001,"backend,test,integration,webrtc",
"[STR-012] Migration: Create breakout_rooms table","Create breakout_rooms table with capacity, time_limit_minutes, FK to sessions.",Task,Highest,1,STREAM-001,"backend,database,migration",
"[STR-013] Migration: Create room_assignments table","Create room_assignments table with composite unique constraint (room_id, participant_id).",Task,Highest,1,STREAM-001,"backend,database,migration",
"[STR-014] Model: BreakoutRoom with assignment logic","Sequelize BreakoutRoom and RoomAssignment models with assignment logic, capacity checks.",Task,Highest,3,STREAM-001,"backend,model,node",
"[STR-015] Controller: BreakoutRoomController (create/assign/broadcast/close)","REST API for breakout room orchestration: create, assign, broadcast, close. WebSocket integration.",Task,Highest,5,STREAM-001,"backend,controller,api,websocket",
"[STR-016] Service: MultiRoomRoutingService for WebRTC breakout routing","Extend Mediasoup to support multi-room routing, participant transitions, resource limits (max 50 rooms).",Task,Highest,8,STREAM-001,"backend,webrtc,mediasoup,routing",
"[STR-017] Test: Breakout room end-to-end flow","Integration test: create rooms → assign students → transition → broadcast → close → return to main.",Task,High,5,STREAM-001,"backend,test,integration,breakout",
"[STR-018] Migration: Create chat_messages table","Create chat_messages table with message_type enum, partitioning by sent_at, 90-day retention.",Task,High,1,STREAM-001,"backend,database,migration",
"[STR-019] Migration: Create hand_raises table","Create hand_raises table with status enum, unique constraint on active hand raise per student.",Task,High,1,STREAM-001,"backend,database,migration",
"[STR-020] Model: ChatMessage with real-time sync","Sequelize ChatMessage model with history queries, pagination, scopes for main/breakout.",Task,High,1,STREAM-001,"backend,model,node",
"[STR-021] Controller: ChatController & HandRaiseController","REST API + WebSocket for chat messaging and hand raise queue. Real-time broadcasts.",Task,High,3,STREAM-001,"backend,controller,api,websocket",
"[STR-022] Test: Chat and hand raise features","Integration test: send messages → history retrieval → raise hand → queue ordering → acknowledge.",Task,Medium,1,STREAM-001,"backend,test,integration",
"[STR-023] Migration: Create session_recordings table","Create session_recordings table with processing_status enum, S3 file_path, duration metadata.",Task,High,1,STREAM-001,"backend,database,migration",
"[STR-024] Model: Recording with processing state","Sequelize Recording model with state machine methods (pending → processing → available/failed).",Task,High,1,STREAM-001,"backend,model,node",
"[STR-025] Job: RecordingProcessingJob (capture, encode, upload)","Background job: capture RTP from Mediasoup → FFmpeg H.264 encode → S3 upload → status update.",Task,High,8,STREAM-001,"backend,job,ffmpeg,s3,rabbitmq",
"[STR-026] Controller: RecordingController (start, stop, playback)","REST API for recording management: start, stop, metadata, presigned playback URLs.",Task,High,3,STREAM-001,"backend,controller,api,s3",
"[STR-027] Test: Recording workflow end-to-end","Integration test: start → capture → stop → process → upload → playback URL generation.",Task,Medium,3,STREAM-001,"backend,test,integration,recording",
"[STR-028] Migration: Create whiteboards table","Create whiteboards table with JSONB canvas_data, 10 MB size limit, FK to sessions/breakout_rooms.",Task,Medium,1,STREAM-001,"backend,database,migration",
"[STR-029] Migration: Create session_polls and poll_responses tables","Create polls tables with JSONB options, unique constraint on poll_responses (poll_id, user_id).",Task,Medium,1,STREAM-001,"backend,database,migration",
"[STR-030] Controller: WhiteboardController & PollController","REST API + WebSocket for whiteboard sync (real-time strokes) and poll management.",Task,Medium,3,STREAM-001,"backend,controller,api,websocket",
"[STR-031] Test: Whiteboard sync and polls","Integration test: whiteboard real-time updates, poll create/respond/results aggregation.",Task,Low,1,STREAM-001,"backend,test,integration",
"[STR-032] Middleware: Circuit breaker for Mediasoup connections","Circuit breaker using opossum for Mediasoup SFU calls, prevents cascade failures.",Task,Highest,3,STREAM-001,"backend,middleware,reliability,opossum",
"[STR-033] Job: Retry logic for recording uploads with exponential backoff","RabbitMQ retry policy for S3 upload failures: 3 attempts, exponential backoff, DLQ.",Task,High,1,STREAM-001,"backend,job,retry,rabbitmq",
"[STR-034] Service: Error monitoring integration (Sentry/DataDog)","Integrate Sentry for error tracking, captures 5xx errors, job failures, context enrichment.",Task,High,1,STREAM-001,"backend,monitoring,sentry",
"[STR-035] Configuration: Dead letter queue setup for failed jobs","Configure RabbitMQ DLQs for all job queues, manual retry script, 7-day retention.",Task,High,1,STREAM-001,"backend,queue,rabbitmq,dlq",
"[STR-036] Middleware: Rate limiting per user and endpoint","Redis-backed rate limiting via express-rate-limit, per-endpoint configurations.",Task,Highest,1,STREAM-001,"backend,middleware,security,redis",
"[STR-037] Service: Recording encryption at rest (S3 SSE)","Enable S3 AES-256 server-side encryption for all recording uploads, verification check.",Task,High,1,STREAM-001,"backend,security,encryption,s3",
"[STR-038] Audit: Participant removal audit logs","Create audit_logs table and logging for sensitive actions (removal, recording, session end). FERPA compliance.",Task,High,1,STREAM-001,"backend,security,audit,compliance",
```

### Linear Markdown

```markdown
## Backend Task Breakdown: Live Streaming Classroom

### Slice 1: Core Session Management
- [ ] [STR-001] Migration: Create sessions table (S, 1-2h) `backend` `database` `migration`
- [ ] [STR-002] Migration: Create session_participants table (S, 1-2h, blocked-by: STR-001) `backend` `database` `migration`
- [ ] [STR-003] Model: Session with relationships (M, 2-4h, blocked-by: STR-001, STR-002) `backend` `model` `node`
- [ ] [STR-004] Model: SessionParticipant with connection state (S, 1-2h, blocked-by: STR-002, STR-003) `backend` `model` `node`
- [ ] [STR-005] Controller: SessionController (CRUD + start/join/admit/end) (L, 4-6h, blocked-by: STR-003, STR-004) `backend` `controller` `api` `express`
- [ ] [STR-006] Test: Session lifecycle integration test (M, 2-4h, blocked-by: STR-005) `backend` `test` `integration`

### Slice 2: WebRTC & Real-time Communication
- [ ] [STR-007] Service: SignalingService for WebSocket management (L, 4-6h, blocked-by: STR-003) `backend` `webrtc` `websocket` `socketio`
- [ ] [STR-008] Service: MediaServerService for Mediasoup integration (XL, 6-8h, blocked-by: STR-003) `backend` `webrtc` `mediasoup` `sfu`
- [ ] [STR-009] Middleware: WebRTC authentication & authorization (S, 1-2h, blocked-by: STR-007) `backend` `middleware` `auth`
- [ ] [STR-010] Controller: WebRTC signaling endpoints (M, 2-4h, blocked-by: STR-008, STR-009) `backend` `controller` `webrtc` `api`
- [ ] [STR-011] Test: WebRTC connection flow end-to-end (L, 4-6h, blocked-by: STR-010) `backend` `test` `integration` `webrtc`

### Slice 3: Breakout Rooms
- [ ] [STR-012] Migration: Create breakout_rooms table (S, 1-2h, blocked-by: STR-001) `backend` `database` `migration`
- [ ] [STR-013] Migration: Create room_assignments table (S, 1-2h, blocked-by: STR-012, STR-002) `backend` `database` `migration`
- [ ] [STR-014] Model: BreakoutRoom with assignment logic (M, 2-4h, blocked-by: STR-012, STR-013) `backend` `model` `node`
- [ ] [STR-015] Controller: BreakoutRoomController (create/assign/broadcast/close) (L, 4-6h, blocked-by: STR-014) `backend` `controller` `api` `websocket`
- [ ] [STR-016] Service: MultiRoomRoutingService for WebRTC breakout routing (XL, 6-8h, blocked-by: STR-008, STR-014) `backend` `webrtc` `mediasoup` `routing`
- [ ] [STR-017] Test: Breakout room end-to-end flow (L, 4-6h, blocked-by: STR-016) `backend` `test` `integration` `breakout`

### Slice 4: Interactive Features - Chat & Hand Raise
- [ ] [STR-018] Migration: Create chat_messages table (S, 1-2h, blocked-by: STR-001, STR-012) `backend` `database` `migration`
- [ ] [STR-019] Migration: Create hand_raises table (XS, 0.5-1h, blocked-by: STR-001) `backend` `database` `migration`
- [ ] [STR-020] Model: ChatMessage with real-time sync (S, 1-2h, blocked-by: STR-018) `backend` `model` `node`
- [ ] [STR-021] Controller: ChatController & HandRaiseController (M, 2-4h, blocked-by: STR-020) `backend` `controller` `api` `websocket`
- [ ] [STR-022] Test: Chat and hand raise features (S, 1-2h, blocked-by: STR-021) `backend` `test` `integration`

### Slice 5: Recording & Playback
- [ ] [STR-023] Migration: Create session_recordings table (S, 1-2h, blocked-by: STR-001) `backend` `database` `migration`
- [ ] [STR-024] Model: Recording with processing state (S, 1-2h, blocked-by: STR-023) `backend` `model` `node`
- [ ] [STR-025] Job: RecordingProcessingJob (capture, encode, upload) (XL, 6-8h, blocked-by: STR-024) `backend` `job` `ffmpeg` `s3` `rabbitmq`
- [ ] [STR-026] Controller: RecordingController (start, stop, playback) (M, 2-4h, blocked-by: STR-024, STR-025) `backend` `controller` `api` `s3`
- [ ] [STR-027] Test: Recording workflow end-to-end (M, 2-4h, blocked-by: STR-026) `backend` `test` `integration` `recording`

### Slice 6: Whiteboard & Polls
- [ ] [STR-028] Migration: Create whiteboards table (S, 1-2h, blocked-by: STR-001, STR-012) `backend` `database` `migration`
- [ ] [STR-029] Migration: Create session_polls and poll_responses tables (S, 1-2h, blocked-by: STR-001) `backend` `database` `migration`
- [ ] [STR-030] Controller: WhiteboardController & PollController (M, 2-4h, blocked-by: STR-028, STR-029) `backend` `controller` `api` `websocket`
- [ ] [STR-031] Test: Whiteboard sync and polls (S, 1-2h, blocked-by: STR-030) `backend` `test` `integration`

### Slice 7: Error Handling & Reliability
- [ ] [STR-032] Middleware: Circuit breaker for Mediasoup connections (M, 2-4h, blocked-by: STR-008) `backend` `middleware` `reliability` `opossum`
- [ ] [STR-033] Job: Retry logic for recording uploads with exponential backoff (S, 1-2h, blocked-by: STR-025) `backend` `job` `retry` `rabbitmq`
- [ ] [STR-034] Service: Error monitoring integration (Sentry/DataDog) (S, 1-2h) `backend` `monitoring` `sentry`
- [ ] [STR-035] Configuration: Dead letter queue setup for failed jobs (XS, 0.5-1h) `backend` `queue` `rabbitmq` `dlq`

### Slice 8: Security & Compliance
- [ ] [STR-036] Middleware: Rate limiting per user and endpoint (S, 1-2h) `backend` `middleware` `security` `redis`
- [ ] [STR-037] Service: Recording encryption at rest (S3 SSE) (XS, 0.5-1h, blocked-by: STR-025) `backend` `security` `encryption` `s3`
- [ ] [STR-038] Audit: Participant removal audit logs (S, 1-2h, blocked-by: STR-005) `backend` `security` `audit` `compliance`

**Total Tasks**: 38
**Critical Path**: ~50-78 hours
**Parallel Execution**: Can be reduced to ~30-50 hours with 2-3 developers
```

### JSON Export

```json
{
  "feature": "live-streaming-classroom",
  "prd_reference": "PRD-01",
  "framework": "Node.js v20.x + Express.js v4.18",
  "database": "PostgreSQL 15.4 + Redis 7.2",
  "slicing": "vertical",
  "scope": "MVP",
  "total_tasks": 38,
  "total_estimated_hours_sequential": "68-106",
  "total_estimated_hours_parallel": "50-78",
  "critical_path_hours": "50-78",
  "slices": [
    {
      "name": "Core Session Management",
      "tasks": 6,
      "hours": "15-24"
    },
    {
      "name": "WebRTC & Real-time Communication",
      "tasks": 5,
      "hours": "17-26"
    },
    {
      "name": "Breakout Rooms",
      "tasks": 6,
      "hours": "18-28"
    },
    {
      "name": "Interactive Features - Chat & Hand Raise",
      "tasks": 5,
      "hours": "6-10"
    },
    {
      "name": "Recording & Playback",
      "tasks": 5,
      "hours": "14-20"
    },
    {
      "name": "Whiteboard & Polls",
      "tasks": 4,
      "hours": "6-10"
    },
    {
      "name": "Error Handling & Reliability",
      "tasks": 4,
      "hours": "6-10"
    },
    {
      "name": "Security & Compliance",
      "tasks": 3,
      "hours": "4-6"
    }
  ],
  "tasks": [
    {
      "id": "STR-001",
      "type": "Migration",
      "title": "Create sessions table",
      "size": "S",
      "duration_hours": "1-2",
      "priority": "P0",
      "complexity": "Low",
      "files": ["database/migrations/YYYY_MM_DD_000001_create_sessions_table.js"],
      "dependencies": {
        "blocked_by": [],
        "needs": [],
        "parallel_with": ["STR-002"]
      },
      "slice": "Core Session Management",
      "tags": ["backend", "database", "migration"]
    }
  ]
}
```

---

## Suggested Next Steps

**Skill Recommendations:**

1. **Frontend Task Breakdown**: Run `/jaan-to-dev-fe-task-breakdown` using this PRD to generate React/Next.js component tasks for the live classroom UI.

2. **GTM Tracking**: Run `/jaan-to-data-gtm-datalayer` to generate Google Tag Manager dataLayer events for session analytics.

3. **Microcopy**: Run `/jaan-to-ux-microcopy-write` for user-facing messages (lobby wait, connection errors, breakout transitions).

**Implementation Priority:**

Start with **Slice 1 + Slice 2** (Core Session + WebRTC) to establish foundation, then proceed with Slice 3 (Breakout Rooms) as highest-value feature.

---

*Generated by `/jaan-to-dev-be-task-breakdown` v3.10.0 | Output follows jaan.to ID-based structure and conventions*
