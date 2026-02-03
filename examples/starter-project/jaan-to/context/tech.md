# Technology Stack

> Project: TaskFlow SaaS (Example)
> Last updated: 2026-02-03

**This is a pre-configured example.** Edit sections below to match your actual project.

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
- **iOS**: None (mobile-first web)
- **Android**: None (mobile-first web)
- **Cross-platform**: PWA with service workers

### Infrastructure
- **Cloud**: AWS (us-east-1, us-west-2)
- **Container**: Docker + ECS Fargate
- **CI/CD**: GitHub Actions
- **Monitoring**: DataDog
- **Logging**: CloudWatch + Structured JSON logs

---

## Frameworks {#frameworks}

### API Development
- FastAPI (REST endpoints)
- Pydantic v2 (validation + serialization)
- SQLAlchemy 2.0 (ORM with async support)
- Alembic (database migrations)

### Web Development
- Next.js App Router
- React Server Components
- TanStack Query v5 (data fetching)
- React Hook Form (forms)
- Zod (client-side validation)

### Testing
- **Backend**: pytest, pytest-asyncio, pytest-cov
- **Frontend**: Vitest, React Testing Library
- **E2E**: Playwright
- **Load**: Locust

---

## Technical Constraints {#constraints}

1. **All APIs must return JSON:API format** - Standardized error responses
2. **Sub-200ms p95 latency for API calls** - Performance SLA
3. **SOC2 Type II compliant** - Audit logging required for all data access
4. **Multi-tenant architecture** - Row-level security, tenant_id on all tables
5. **WCAG 2.1 AA accessibility** - Required for all UI components

---

## Versioning & Deprecation {#versioning}

- **API versioning**: URL path (`/api/v1/`, `/api/v2/`)
- **Breaking changes**: 90-day deprecation notice
- **Database**: Blue-green deployments for zero-downtime migrations
- **Frontend**: Rolling deploys with feature flags

---

## Common Patterns {#patterns}

### Authentication
- OAuth2 + JWT (15min access token, 7d refresh token)
- API keys for service-to-service (rotated quarterly)
- MFA via TOTP (Google Authenticator, Authy)

### Error Handling
```python
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email format is invalid",
    "details": {"field": "email", "constraint": "format"}
  }
}
```

### Data Access
- Repository pattern for all database operations
- No raw SQL in business logic (use SQLAlchemy queries)
- Soft deletes (deleted_at timestamp, never hard delete)

### API Design
- RESTful resources with standard verbs (GET, POST, PATCH, DELETE)
- Pagination: cursor-based (not offset)
- Filtering: `?filter[status]=active&filter[created_after]=2024-01-01`
- Sorting: `?sort=-created_at,name` (- prefix = descending)

---

## Tech Debt {#tech-debt}

- [ ] Migrate Redux → Zustand (Q2 2026) - Reduce bundle size
- [ ] Split monolith API → domain-based services (Q3 2026)
- [ ] Upgrade PostgreSQL 15 → 16 (Q4 2026)
- [ ] Implement GraphQL for complex queries (Backlog)

---

**Skills that read this file:**
- `/jaan-to-pm-prd-write` - References stack in Technical Approach section
- `/jaan-to-dev-fe-task-breakdown` - Uses frontend patterns for component design
- `/jaan-to-dev-be-task-breakdown` - Uses backend patterns for API design
- `/jaan-to-data-gtm-datalayer` - Uses correct event naming conventions
- `/jaan-to-qa-test-cases` - Tests against API error format standards

**To auto-detect your stack:** Run `/jaan-to-dev-stack-detect` to scan your codebase.
