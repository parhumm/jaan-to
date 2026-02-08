# Technology Stack

> Project: {project-name}
> Last updated: {date}

**TIP**: Run `/jaan-to:detect-dev` to audit your codebase with evidence-backed findings, or `/jaan-to:pack-detect` for a full repo analysis.

---

## Current Stack {#current-stack}

### Backend
- **Language**: Python 3.11
- **Framework**: FastAPI 0.104
- **Database**: PostgreSQL 15
- **Cache**: Redis 7
- **Queue**: Celery + RabbitMQ

### Frontend
- **Language**: TypeScript 5.2
- **Framework**: React 18 + Next.js 14
- **State**: Redux Toolkit
- **Styling**: Tailwind CSS 3.3
- **Build**: Vite 5.0

### Mobile
- **iOS**: Swift 5.9 + SwiftUI
- **Android**: Kotlin 1.9 + Jetpack Compose
- **Cross-platform**: None

### Infrastructure
- **Cloud**: AWS (us-east-1, us-west-2)
- **Container**: Docker + ECS
- **CI/CD**: GitHub Actions
- **Monitoring**: DataDog
- **Logging**: CloudWatch

---

## Frameworks {#frameworks}

### API Development
- FastAPI (REST endpoints)
- Pydantic (validation)
- SQLAlchemy (ORM)

### Web Development
- Next.js App Router
- React Server Components
- TanStack Query (data fetching)

### Testing
- **Backend**: pytest, pytest-cov
- **Frontend**: Jest, React Testing Library
- **E2E**: Playwright

---

## Technical Constraints {#constraints}

1. **All APIs must return JSON:API format** - Company standard
2. **Mobile apps must work offline** - Sync on reconnect
3. **Sub-200ms p95 latency** - Performance requirement
4. **SOC2 compliant** - Security/audit logging required
5. **Multi-tenant architecture** - Data isolation enforced

---

## Versioning & Deprecation {#versioning}

- **API versioning**: URL path (`/v1/`, `/v2/`)
- **Breaking changes**: 6-month deprecation notice
- **Mobile**: Support last 2 major versions

---

## Common Patterns {#patterns}

### Authentication
- OAuth2 + JWT (15min access, 7d refresh)
- API keys for service-to-service

### Error Handling
- Structured errors with error codes
- Client-friendly messages

### Data Access
- Repository pattern for data layer
- No raw SQL in business logic

---

## Tech Debt {#tech-debt}

- [ ] Migrate from Redux to Zustand (Q2 2024)
- [ ] Upgrade Python 3.11 → 3.12 (Q3 2024)
- [ ] Split monolith → microservices (Q4 2024)

---

**Delete this section after customizing:**

This file is read by:
- `/jaan-to:pm-prd-write` - References stack in PRD
- `/jaan-to:dev-*` skills - Generates code matching conventions
- `/jaan-to:data-*` skills - Uses correct event names

Edit sections above to match your project. Use `#section-id` anchors for imports.
