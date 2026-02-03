# Third-Party Integrations

> External services and tools your project uses - skills reference these when generating code

**This is a pre-configured example.** Edit sections below to match your actual integrations.

---

## Payments

**Provider:** Stripe

| Setting | Value |
|---------|-------|
| Account ID | `acct_1A2B3C4D5E6F7G8H` |
| Mode | Test + Production |
| Webhook Secret | Stored in AWS Secrets Manager |
| Products | Subscriptions (recurring) + One-time payments |

**Supported Methods:**
- Credit/debit cards (Visa, Mastercard, Amex, Discover)
- ACH direct debit (US only)
- Apple Pay / Google Pay

**Integration:**
- Stripe Checkout (hosted payment page)
- Stripe Elements (embedded forms)
- Stripe Webhooks (`/webhooks/stripe`) for event handling

---

## Analytics

**Provider:** Google Analytics 4 (GA4)

| Setting | Value |
|---------|-------|
| Measurement ID | `G-XXXXXXXXXX` |
| GTM Container | `GTM-XXXXXXX` |
| Environment | Production + Staging (separate containers) |

**Tracking:**
- Page views (automatic via GTM)
- Custom events via `dataLayer.push()`
- User properties (plan tier, signup date)
- E-commerce events (purchase, refund, subscription)

**Event Naming Convention:** `lowercase_snake_case`

---

## Email

**Provider:** SendGrid

| Setting | Value |
|---------|-------|
| API Key | Stored in AWS Secrets Manager |
| Sender Domain | `noreply@taskflow.app` |
| Verified | Yes (SPF, DKIM, DMARC configured) |

**Email Types:**
- Transactional (password reset, email verification)
- Marketing (newsletters, product updates)
- Notifications (task assigned, comment added)

**Templates:**
- Managed in SendGrid dashboard
- Template IDs stored in environment variables
- Liquid syntax for personalization

---

## File Storage

**Provider:** AWS S3

| Setting | Value |
|---------|-------|
| Bucket | `taskflow-prod-uploads` |
| Region | `us-east-1` |
| Access | IAM role (no static keys) |
| CDN | CloudFront distribution |

**File Types:**
- User avatars (max 5MB, JPEG/PNG)
- Task attachments (max 25MB, any file type)
- Export files (CSV, PDF) - 7-day expiration

---

## Authentication

**OAuth Providers:**

| Provider | Client ID | Scopes |
|----------|-----------|--------|
| Google | `123456789.apps.googleusercontent.com` | `email`, `profile` |
| GitHub | `Iv1.abcdef123456` | `user:email` |
| Microsoft | `a1b2c3d4-e5f6-...` | `User.Read` |

**Configuration:**
- Redirect URI: `https://app.taskflow.app/auth/callback`
- Token storage: HTTP-only secure cookies
- Session duration: 7 days

---

## Error Tracking

**Provider:** Sentry

| Setting | Value |
|---------|-------|
| DSN | `https://abc123@o123456.ingest.sentry.io/7654321` |
| Environment | `production`, `staging`, `development` |
| Release Tracking | Yes (git commit SHA) |

**Tracked Errors:**
- Backend exceptions (500 errors)
- Frontend JavaScript errors
- API rate limit violations
- Failed webhook deliveries

---

## Infrastructure

**Provider:** AWS

| Service | Purpose | Region |
|---------|---------|--------|
| ECS Fargate | Container hosting | us-east-1 |
| RDS PostgreSQL | Primary database | us-east-1 (Multi-AZ) |
| ElastiCache Redis | Cache + sessions | us-east-1 |
| SQS | Task queue | us-east-1 |
| Secrets Manager | API keys, credentials | us-east-1 |

---

## CI/CD

**Provider:** GitHub Actions

**Workflows:**
- `ci.yml` - Run tests on every PR
- `deploy-staging.yml` - Deploy to staging on merge to `main`
- `deploy-production.yml` - Deploy to production on tag `v*`

**Deployment:**
- Docker images → ECR
- ECS task definitions updated automatically
- Rolling deployments (zero downtime)

---

## Monitoring

**Providers:**

| Tool | Purpose | Alerts |
|------|---------|--------|
| DataDog | APM, metrics | Slack `#alerts` |
| PagerDuty | On-call rotation | SMS + Phone |
| Uptime Robot | External uptime | Email |

**Key Metrics:**
- API latency (p50, p95, p99)
- Error rate (5xx responses)
- Database query performance
- Cache hit rate

---

## Project Management

**Provider:** Linear

| Setting | Value |
|---------|-------|
| Workspace | `taskflow` |
| Teams | Engineering, Design, Product |
| Integrations | GitHub (auto-link PRs), Slack (notifications) |

**Workflow:**
- Backlog → Planned → In Progress → In Review → Done
- Labels: `bug`, `feature`, `tech-debt`, `documentation`
- Sprints: 2-week cycles

---

**Skills that read this file:**
- `/jaan-to-pm-prd-write` - References integrations in Technical Approach
- `/jaan-to-data-gtm-datalayer` - Uses GTM container ID and event naming
- `/jaan-to-dev-be-task-breakdown` - References Stripe, SendGrid, S3 integrations
- `/jaan-to-dev-fe-task-breakdown` - References GA4, Sentry for frontend
- `/jaan-to-qa-test-cases` - Tests OAuth flows, payment flows
