# Technology Stack {#tech-stack}

> Manually configured for EduStream Academy integration testing
> Last Updated: 2026-02-03
> Status: **Sample Stack** - Representative EdTech platform architecture

---

## Current Stack {#current-stack}

### Backend
- **Language**: Node.js (v20.x LTS)
- **Framework**: Express.js v4.18
- **Version**: 4.18.2
- **Additional**: Socket.io for WebRTC signaling

### Frontend
- **Language**: TypeScript (v5.3)
- **Framework**: React v18.2 with Next.js v14.1
- **Version**: Next.js 14.1.0
- **State Management**: Redux Toolkit v2.0

### Mobile
- **Platform**: React Native (planned Phase 2)
- **Framework**: React Native v0.73

### Infrastructure
- **Cloud Provider**: AWS
- **Container**: Docker + ECS
- **CI/CD**: GitHub Actions

---

## Databases {#databases}

- **Primary**: PostgreSQL 15.4 (RDS)
- **Cache**: Redis 7.2 (ElastiCache)
- **Queue**: RabbitMQ 3.12 (Amazon MQ)

---

## Frameworks {#frameworks}

### Backend Frameworks
- Express.js v4.18 (REST API)
- Socket.io v4.6 (WebRTC signaling, real-time events)
- Mediasoup v3.13 (SFU for video routing)

### Frontend Frameworks
- React v18.2 with Next.js v14.1 (SSR + CSR)
- Redux Toolkit v2.0 (state management)
- TailwindCSS v3.4 (styling)

### Testing
- **Unit Testing**: Jest v29, React Testing Library v14
- **E2E Testing**: Playwright v1.41
- **Component Testing**: Storybook v7.6

---

## Dependencies {#dependencies}

### Package Management
- **Tool**: {To be detected}
- **Monorepo**: {To be detected}

### Key Libraries
- {To be detected}

---

## Technical Constraints {#technical-constraints}

> Defined from PRD requirements (PRD-01, PRD-02)

**Performance Requirements:**
- WebRTC latency: <200ms p95 for 500 concurrent users
- API response time: <100ms p95 for read operations
- Session initialization: <10 seconds from button click to live
- Video CDN delivery: <2 second buffering for 1080p

**Security Requirements:**
- DTLS-SRTP encryption for all video/audio streams
- JWT tokens with 1-hour expiration
- PCI DSS compliance via Stripe integration
- SOC 2 Type II certification (in progress)

**Compliance Requirements:**
- COPPA compliance for users <13 (parental consent, formal security programs)
- FERPA compliance for educational records (vendor agreements, data retention)
- Full compliance deadline: April 22, 2026

**Browser/Platform Support:**
- Desktop: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- Mobile Web: iOS Safari 14+, Android Chrome 90+
- Native Apps: React Native (Phase 2)

---

## Common Patterns {#common-patterns}

> **Manual Entry Required** - Requires code analysis

- API conventions
- State management patterns
- Error handling patterns
- Authentication/authorization patterns
