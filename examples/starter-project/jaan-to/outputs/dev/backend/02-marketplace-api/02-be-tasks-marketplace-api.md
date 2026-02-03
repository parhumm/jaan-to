# Backend Task Breakdown: Course Marketplace

**PRD**: [PRD-02: Course Marketplace](../../../pm/prd/02-course-marketplace/02-prd-course-marketplace.md)
**Framework**: Node.js v20.x + Express.js v4.18
**Database**: PostgreSQL 15.4 + Redis 7.2
**Slicing Strategy**: Vertical (end-to-end feature slices)
**Scope**: MVP - Production-ready two-sided marketplace with 70/30 revenue split
**Generated**: 2026-02-03

---

## Executive Summary

This task breakdown delivers the backend API for EduStream Academy's course marketplace, enabling instructors to monetize expertise and students to discover/purchase courses. The breakdown spans 35 tasks across 7 feature slices: Course Management, Discovery & Search, Purchase & Payment, Revenue & Payouts, Enrollment & Progress, Reviews & Ratings, and Security & Compliance.

**Critical Path**: 14 sequential tasks (~30-40 hours) from database schema to Stripe integration to payout automation.

**Key Technical Challenges**:
- Stripe payment processing with 70/30 revenue split calculation
- Stripe Connect integration for automated instructor payouts
- Video upload pipeline with S3 storage and CDN distribution
- Course search/filtering (PostgreSQL full-text + filters for MVP)
- Escrow system (7-day hold before instructor payout)
- Transaction integrity with idempotency for payments
- Tax compliance (W-9/W-8 collection, 1099 generation)

---

## Entity Summary

| Entity | Table | Tasks | Key Relationships | Notes |
|--------|-------|-------|-------------------|-------|
| **Course** | `courses` | 7 | belongsTo User (instructor), hasMany Lessons, Enrollments | Soft delete enabled |
| **CourseLesson** | `course_lessons` | 3 | belongsTo Course | Video/resource files |
| **Transaction** | `transactions` | 5 | belongsTo Course, User (buyer) | Stripe payment records |
| **RevenueRecord** | `revenue_records` | 3 | belongsTo Transaction | 70/30 split tracking |
| **InstructorPayout** | `instructor_payouts` | 4 | belongsTo User (instructor) | Monthly automated payouts |
| **Enrollment** | `enrollments` | 3 | belongsTo Course, User (student) | Access control |
| **CourseReview** | `course_reviews` | 3 | belongsTo Course, User | Verified purchase only |
| **Coupon** | `coupons` | 2 | belongsTo User (creator) | Discount codes |
| **CourseProgress** | `course_progress` | 2 | belongsTo Enrollment, Lesson | Video completion tracking |

**Total Tables**: 9 core tables

---

## Task Breakdown

### Slice 1: Course Management

#### [MKT-001] Migration: Create courses table

**Size:** M (2-3h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `database/migrations/YYYY_MM_DD_000001_create_courses_table.js`

**Dependencies:**
- blocked-by: None (foundation task)
- parallel-with: [MKT-002]

**Description:**
Create the `courses` table to store course metadata including title, description, pricing model (one-time vs subscription), category, difficulty level, and publishing status. Implements soft deletes for course archival.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), instructor_id (FK users), title (VARCHAR 255), description (TEXT), category (ENUM), difficulty_level (ENUM), pricing_model (ENUM), price (DECIMAL 10,2), subscription_price (DECIMAL 10,2 nullable), status (ENUM), thumbnail_url (VARCHAR 500), total_duration_minutes (INT), published_at (TIMESTAMPTZ nullable), created_at, updated_at, deleted_at (nullable)
- [ ] Category ENUM: 'data_science', 'web_development', 'mobile_development', 'design', 'business', 'marketing', 'personal_development', 'health', 'music', 'photography', 'teaching', 'other' (12 categories)
- [ ] Difficulty level ENUM: 'beginner', 'intermediate', 'advanced'
- [ ] Pricing model ENUM: 'one_time', 'subscription'
- [ ] Status ENUM: 'draft', 'under_review', 'published', 'archived'
- [ ] Foreign key on instructor_id → users.id with ON DELETE CASCADE
- [ ] Indexes on: instructor_id, category, status, price, published_at
- [ ] Check constraints: price >= 9 AND price <= 499 (if one_time), subscription_price >= 4.99 AND subscription_price <= 49.99 (if subscription)

**Data Model Notes:**
```yaml
table: courses
columns:
  - name: id
    type: uuid
    primary_key: true
    default: gen_random_uuid()
  - name: instructor_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
  - name: title
    type: varchar(255)
    nullable: false
  - name: description
    type: text
    nullable: false
  - name: category
    type: enum [12 categories]
    nullable: false
  - name: difficulty_level
    type: enum ['beginner', 'intermediate', 'advanced']
    nullable: false
  - name: pricing_model
    type: enum ['one_time', 'subscription']
    nullable: false
  - name: price
    type: decimal(10,2)
    nullable: true
  - name: subscription_price
    type: decimal(10,2)
    nullable: true
  - name: status
    type: enum ['draft', 'under_review', 'published', 'archived']
    default: 'draft'
  - name: thumbnail_url
    type: varchar(500)
    nullable: true
  - name: total_duration_minutes
    type: integer
    default: 0
  - name: published_at
    type: timestamptz
    nullable: true
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
    name: idx_courses_instructor_status
  - columns: [category, status, published_at]
    name: idx_courses_category_status_date
  - columns: [price]
    name: idx_courses_price
constraints:
  - check: (pricing_model = 'one_time' AND price IS NOT NULL) OR (pricing_model = 'subscription' AND subscription_price IS NOT NULL)
  - check: price >= 9 AND price <= 499
  - check: subscription_price >= 4.99 AND subscription_price <= 49.99
migration:
  zero_downtime: true (additive only)
```

**Test Requirements:**
- Unit test: `tests/migrations/courses-table.test.js`
- Coverage: Verify schema, indexes, constraints

---

#### [MKT-002] Migration: Create course_lessons table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000002_create_course_lessons_table.js`

**Dependencies:**
- blocked-by: [MKT-001] (foreign key dependency)
- parallel-with: None

**Description:**
Create the `course_lessons` table to store individual lessons within courses, including video file paths, resources (PDFs, slides), lesson duration, and preview status (free vs paid).

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), course_id (FK), title (VARCHAR 255), description (TEXT nullable), video_url (VARCHAR 500), video_duration_seconds (INT), is_preview (BOOLEAN default false), lesson_order (INT), resource_urls (JSONB array), created_at, updated_at
- [ ] Foreign key on course_id → courses.id with ON DELETE CASCADE
- [ ] Indexes on: course_id, lesson_order, is_preview
- [ ] Unique constraint on (course_id, lesson_order)
- [ ] JSONB resource_urls structure: [{"filename": "slides.pdf", "url": "s3://...", "size_mb": 2.3}]

**Data Model Notes:**
```yaml
table: course_lessons
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: course_id
    type: uuid
    nullable: false
    foreign_key: courses.id
    on_delete: cascade
  - name: title
    type: varchar(255)
    nullable: false
  - name: description
    type: text
    nullable: true
  - name: video_url
    type: varchar(500)
    nullable: false
    comment: S3 path to video file
  - name: video_duration_seconds
    type: integer
    nullable: false
  - name: is_preview
    type: boolean
    default: false
    comment: Free preview lesson
  - name: lesson_order
    type: integer
    nullable: false
  - name: resource_urls
    type: jsonb
    default: '[]'
    comment: Array of supplementary resource files
  - name: created_at
    type: timestamptz
    nullable: false
  - name: updated_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [course_id, lesson_order]
    name: idx_lessons_course_order
    unique: true
  - columns: [course_id, is_preview]
    name: idx_lessons_preview
constraints:
  - check: video_duration_seconds > 0
  - check: lesson_order > 0
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/course-lessons-table.test.js`

---

#### [MKT-003] Model: Course with relationships

**Size:** L (4-6h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/models/Course.js`

**Dependencies:**
- blocked-by: [MKT-001], [MKT-002]
- parallel-with: None

**Description:**
Create Sequelize model for Course with relationships to User (instructor), CourseLessons, Enrollments, Reviews. Includes business logic for publishing workflow (draft → under_review → published), price validation, and preview lesson limits.

**Acceptance Criteria:**
- [ ] Model class extends Sequelize Model with all table columns defined
- [ ] Relationships: belongsTo User (instructor), hasMany CourseLesson, hasMany Enrollment, hasMany CourseReview
- [ ] Instance methods: `publish()`, `archive()`, `getTotalPreviewDuration()`, `getEnrollmentCount()`, `getAverageRating()`, `canUserAccess(userId)` - checks enrollment
- [ ] Static methods: `findPublished()`, `findByCategory(category)`, `findByInstructor(instructorId)`
- [ ] Validation: If pricing_model='one_time', price required; if 'subscription', subscription_price required
- [ ] Validation: Total preview duration (sum of is_preview lessons) ≤ 15 minutes
- [ ] Soft delete scope applied (paranoid: true)

**Test Requirements:**
- Unit test: `tests/unit/models/Course.test.js`
- Coverage: Relationships, validations, publishing workflow, preview duration calculation

---

#### [MKT-004] Model: CourseLesson with video metadata

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/models/CourseLesson.js`

**Dependencies:**
- blocked-by: [MKT-002], [MKT-003]
- parallel-with: None

**Description:**
Create Sequelize model for CourseLesson with methods for video access control (preview vs paid), resource file management, and lesson ordering.

**Acceptance Criteria:**
- [ ] Model with relationship: belongsTo Course
- [ ] Instance methods: `isAccessibleBy(userId)` - checks if user enrolled or lesson is preview, `getSignedVideoUrl(expiresIn=3600)` - generates S3 presigned URL
- [ ] Static methods: `getPreviewLessonsForCourse(courseId)`, `reorderLessons(courseId, lessonOrderMap)` - bulk update lesson_order
- [ ] Validation: lesson_order must be positive integer, video_duration_seconds > 0

**Test Requirements:**
- Unit test: `tests/unit/models/CourseLesson.test.js`
- Coverage: Access control, video URL generation, reordering

---

#### [MKT-005] Service: VideoUploadService (S3 integration)

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/services/VideoUploadService.js`
- `config/aws.config.js`

**Dependencies:**
- blocked-by: None (independent)
- parallel-with: [MKT-003]

**Description:**
Implement service for handling video file uploads to S3, including multipart upload for large files (5GB limit), thumbnail generation, duration extraction via ffprobe, and presigned URL generation for playback.

**Acceptance Criteria:**
- [ ] Methods: `uploadVideo(fileBuffer, filename, courseId)`, `getSignedUrl(s3Key, expiresIn)`, `extractVideoDuration(fileBuffer)`, `generateThumbnail(s3Key)` - uses ffmpeg
- [ ] Uploads to S3 bucket `edustream-course-videos-prod` with path: `courses/{courseId}/videos/{uuid}.mp4`
- [ ] Uses AWS SDK v3 with multipart upload for files >100MB
- [ ] Encrypts files at rest with AES-256 (S3 SSE)
- [ ] Extracts video duration using ffprobe before upload, returns duration_seconds
- [ ] Generates thumbnail (JPG) at 5-second mark, uploads to `courses/{courseId}/thumbnails/{uuid}.jpg`
- [ ] Returns object: {videoUrl: s3Key, thumbnailUrl, durationSeconds}

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| File size >5GB | 413 | "Video file too large (max 5GB)" |
| Invalid video format | 400 | "Only MP4/MOV formats supported" |
| S3 upload timeout | 504 | Retry once, if fails return 503 |
| ffprobe extraction fails | 500 | Log error, allow upload but set duration=0 |

**Security Checklist:**
- [ ] S3 bucket private (no public access)
- [ ] Presigned URLs expire after 1 hour
- [ ] Encryption at rest (AES-256 SSE)
- [ ] Validate file MIME type before upload

**Test Requirements:**
- Unit test: `tests/unit/services/VideoUploadService.test.js`
- Integration test: `tests/integration/video-upload-s3.test.js` (requires S3 mock)
- Coverage: Upload flow, presigned URLs, error handling

---

#### [MKT-006] Controller: CourseController (CRUD + publish)

**Size:** XL (6-8h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/controllers/CourseController.js`
- `src/routes/courses.js`
- `src/validators/course.validator.js`

**Dependencies:**
- blocked-by: [MKT-003], [MKT-004], [MKT-005]
- parallel-with: None

**Description:**
Implement REST API controller for course management covering instructor workflow: create draft, upload lessons, configure pricing/previews, submit for review, publish. Also includes student-facing endpoints for browsing published courses.

**Acceptance Criteria:**
- [ ] POST /api/courses - Create draft course (instructor only, body: {title, description, category, difficulty, pricingModel, price})
- [ ] GET /api/courses/:id - Get course details (public if published, instructor-only if draft)
- [ ] PUT /api/courses/:id - Update course metadata (instructor only)
- [ ] POST /api/courses/:id/lessons - Add lesson to course (body: {title, description, videoFile (multipart), isPreview, lessonOrder, resources[]})
- [ ] DELETE /api/courses/:id/lessons/:lessonId - Remove lesson (instructor only)
- [ ] POST /api/courses/:id/publish - Submit for review / publish (status: draft → under_review or under_review → published)
- [ ] DELETE /api/courses/:id - Archive course (soft delete, instructor only)
- [ ] GET /api/courses - List published courses (query params: category, minPrice, maxPrice, difficulty, sort, page, limit)
- [ ] Video upload handled via VideoUploadService, returns lesson with video_url
- [ ] Input validation: title (3-255 chars), price within ranges, preview duration ≤15 min total

**Idempotency:**
- Type: Course creation uses client-provided idempotency key header
- Key: `Idempotency-Key` header with UUID
- Storage: Redis cache with 24h TTL: key = `idempotency:course:${key}`, value = course_id
- Duplicate handling: Return existing course with 200 status

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Create course as student | 403 | "Only instructors can create courses" |
| Publish course with <3 lessons | 400 | "Course must have at least 3 lessons" |
| Publish course with preview >15 min | 400 | "Preview duration exceeds 15 minute limit" |
| Update archived course | 410 | "Course is archived" |
| Video upload fails | 503 | Return "Video processing failed, retry" |

**Security Checklist:**
- [ ] instructorOnly middleware for create/update/delete/publish
- [ ] Input validation via CourseValidator class
- [ ] Rate limiting: 60 req/min for general API, 10 req/min for publish (prevent spam)
- [ ] File upload size limit: 5GB per video
- [ ] SQL injection prevention: Sequelize ORM

**Test Requirements:**
- Integration test: `tests/integration/course-api.test.js`
- Coverage: All 8 endpoints, authorization, validation, file upload

---

#### [MKT-007] Test: Course creation and publishing workflow

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `tests/integration/course-workflow.test.js`

**Dependencies:**
- blocked-by: [MKT-006]
- parallel-with: None

**Description:**
Integration test simulating full course creation workflow: instructor creates draft → uploads 5 lessons (3 paid, 2 preview) → configures pricing → publishes → student views published course.

**Acceptance Criteria:**
- [ ] Test creates instructor user, creates draft course, verifies status='draft'
- [ ] Test uploads 5 video files (mocked), verifies lessons created with correct order
- [ ] Test selects 2 lessons as preview (total 10 min), verifies preview flag and duration calculation
- [ ] Test publishes course, verifies status='published', published_at timestamp set
- [ ] Test student user fetches course via GET /api/courses/:id, verifies can view preview lessons without authentication
- [ ] Test runs in <30 seconds (uses mock S3 uploads)

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + publish validation errors

---

### Slice 2: Discovery & Search

#### [MKT-008] Migration: Add full-text search indexes to courses

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000003_add_course_search_indexes.js`

**Dependencies:**
- blocked-by: [MKT-001]
- parallel-with: None

**Description:**
Add PostgreSQL full-text search (GIN index) on courses.title and courses.description for efficient keyword search. Also adds composite indexes for common filter queries.

**Acceptance Criteria:**
- [ ] Creates GIN index on to_tsvector('english', title || ' ' || description) for full-text search
- [ ] Creates composite index on (category, difficulty_level, price) for multi-filter queries
- [ ] Creates index on (status, published_at DESC) for published course sorting
- [ ] Migration includes up and down methods

**Data Model Notes:**
```yaml
indexes:
  - type: gin
    expression: to_tsvector('english', title || ' ' || description)
    name: idx_courses_fulltext_search
  - columns: [category, difficulty_level, price]
    name: idx_courses_filters
  - columns: [status, published_at DESC]
    name: idx_courses_published_sort
migration:
  zero_downtime: true (concurrent index creation)
```

**Test Requirements:**
- Unit test: `tests/migrations/course-search-indexes.test.js`

---

#### [MKT-009] Service: CourseSearchService (filter + search)

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/services/CourseSearchService.js`

**Dependencies:**
- blocked-by: [MKT-003], [MKT-008]
- parallel-with: None

**Description:**
Implement course search and filtering service using PostgreSQL full-text search (MVP approach, can migrate to Elasticsearch in Phase 2). Supports keyword search, category/price/rating/difficulty filters, and sorting.

**Acceptance Criteria:**
- [ ] Method: `search(params)` - params: {query (keyword), category, minPrice, maxPrice, minRating, difficulty, sort, page, limit}
- [ ] Query parameter: Uses ts_query for full-text search on title/description
- [ ] Filters: Applies WHERE clauses for category, price range (BETWEEN), difficulty, rating (computed from course_reviews)
- [ ] Sorting options: 'newest' (published_at DESC), 'highest_rated' (avg rating DESC), 'most_popular' (enrollment count DESC), 'price_asc', 'price_desc'
- [ ] Pagination: Cursor-based using published_at + id for stable results, default limit=25
- [ ] Returns: {courses: [{id, title, instructor, price, rating, enrollmentCount, thumbnail}], nextCursor, total}
- [ ] Performance: Search query execution <100ms for 5,000 courses

**Test Requirements:**
- Unit test: `tests/unit/services/CourseSearchService.test.js`
- Coverage: Keyword search, multi-filter combinations, sorting, pagination

---

#### [MKT-010] Controller: CourseSearchController

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `src/controllers/CourseSearchController.js`
- `src/routes/search.js`

**Dependencies:**
- blocked-by: [MKT-009]
- parallel-with: None

**Description:**
Implement REST API endpoint for course search with query parameter validation and caching.

**Acceptance Criteria:**
- [ ] GET /api/search/courses - Search courses (query params: q, category, minPrice, maxPrice, minRating, difficulty, sort, page, limit)
- [ ] Input validation: price range 0-500, rating 0-5, difficulty valid enum, limit ≤100
- [ ] Caching: Redis cache search results for popular queries (TTL 5 minutes)
- [ ] Returns paginated results with nextCursor for pagination

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Invalid price range | 400 | "Price range must be 0-500" |
| Invalid sort option | 400 | "Sort must be: newest, highest_rated, most_popular, price_asc, price_desc" |
| Limit >100 | 400 | "Limit must be ≤100" |

**Security Checklist:**
- [ ] Rate limiting: 120 req/min (high limit for search)
- [ ] Input sanitization for SQL injection (parameterized queries via ORM)

**Test Requirements:**
- Integration test: `tests/integration/course-search-api.test.js`
- Coverage: Search with filters, sorting, pagination, caching

---

### Slice 3: Purchase & Payment

#### [MKT-011] Migration: Create transactions table

**Size:** M (2-3h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `database/migrations/YYYY_MM_DD_000004_create_transactions_table.js`

**Dependencies:**
- blocked-by: [MKT-001]
- parallel-with: [MKT-012]

**Description:**
Create the `transactions` table to store all course purchases with Stripe payment metadata, coupon discounts, and transaction status tracking.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), course_id (FK), buyer_id (FK users), stripe_payment_intent_id (VARCHAR 100 UNIQUE), amount_gross (DECIMAL 10,2), amount_discount (DECIMAL 10,2 default 0), amount_net (DECIMAL 10,2), coupon_id (FK nullable), stripe_fee (DECIMAL 10,2), status (ENUM), payment_method (VARCHAR 50), created_at, completed_at (TIMESTAMPTZ nullable)
- [ ] Status ENUM: 'pending', 'completed', 'failed', 'refunded'
- [ ] Foreign keys with ON DELETE RESTRICT (preserve transaction history)
- [ ] Indexes on: buyer_id, course_id, stripe_payment_intent_id, status, created_at
- [ ] Computed column: amount_net = amount_gross - amount_discount
- [ ] Check constraints: amount_gross > 0, amount_discount >= 0, amount_net > 0

**Data Model Notes:**
```yaml
table: transactions
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: course_id
    type: uuid
    nullable: false
    foreign_key: courses.id
    on_delete: restrict
  - name: buyer_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: restrict
  - name: stripe_payment_intent_id
    type: varchar(100)
    nullable: false
    unique: true
  - name: amount_gross
    type: decimal(10,2)
    nullable: false
  - name: amount_discount
    type: decimal(10,2)
    default: 0
  - name: amount_net
    type: decimal(10,2)
    nullable: false
    comment: Computed: amount_gross - amount_discount
  - name: coupon_id
    type: uuid
    nullable: true
    foreign_key: coupons.id
  - name: stripe_fee
    type: decimal(10,2)
    nullable: false
    comment: 2.9% + $0.30 per transaction
  - name: status
    type: enum ['pending', 'completed', 'failed', 'refunded']
    default: 'pending'
  - name: payment_method
    type: varchar(50)
    nullable: true
    comment: 'card', 'apple_pay', 'google_pay'
  - name: created_at
    type: timestamptz
    nullable: false
  - name: completed_at
    type: timestamptz
    nullable: true
indexes:
  - columns: [buyer_id, created_at DESC]
    name: idx_transactions_buyer_time
  - columns: [course_id, status]
    name: idx_transactions_course_status
  - columns: [stripe_payment_intent_id]
    name: idx_transactions_stripe
    unique: true
constraints:
  - check: amount_gross > 0
  - check: amount_discount >= 0
  - check: amount_net > 0
  - check: stripe_fee >= 0
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/transactions-table.test.js`

---

#### [MKT-012] Migration: Create revenue_records table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000005_create_revenue_records_table.js`

**Dependencies:**
- blocked-by: [MKT-011]
- parallel-with: None

**Description:**
Create the `revenue_records` table to track 70/30 revenue split between instructor and platform per transaction. Used for payout calculations and accounting.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), transaction_id (FK), instructor_id (FK users), instructor_amount (DECIMAL 10,2), platform_amount (DECIMAL 10,2), escrow_release_date (DATE), payout_id (FK nullable), created_at
- [ ] Foreign keys with ON DELETE RESTRICT
- [ ] Indexes on: transaction_id (unique), instructor_id, escrow_release_date, payout_id
- [ ] Unique constraint on transaction_id (one revenue record per transaction)
- [ ] Check constraints: instructor_amount = transaction.amount_net * 0.70, platform_amount = transaction.amount_net * 0.30

**Data Model Notes:**
```yaml
table: revenue_records
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: transaction_id
    type: uuid
    nullable: false
    foreign_key: transactions.id
    on_delete: restrict
    unique: true
  - name: instructor_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: restrict
  - name: instructor_amount
    type: decimal(10,2)
    nullable: false
    comment: 70% of transaction.amount_net
  - name: platform_amount
    type: decimal(10,2)
    nullable: false
    comment: 30% of transaction.amount_net
  - name: escrow_release_date
    type: date
    nullable: false
    comment: created_at + 7 days
  - name: payout_id
    type: uuid
    nullable: true
    foreign_key: instructor_payouts.id
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [transaction_id]
    name: idx_revenue_transaction
    unique: true
  - columns: [instructor_id, escrow_release_date]
    name: idx_revenue_instructor_escrow
  - columns: [payout_id]
    name: idx_revenue_payout
constraints:
  - check: instructor_amount > 0
  - check: platform_amount > 0
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/revenue-records-table.test.js`

---

#### [MKT-013] Service: StripePaymentService (checkout integration)

**Size:** XL (6-8h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/services/StripePaymentService.js`
- `config/stripe.config.js`

**Dependencies:**
- blocked-by: [MKT-003], [MKT-011]
- parallel-with: None

**Description:**
Integrate Stripe Checkout for course purchases. Handles checkout session creation, webhook processing for payment confirmation, refund processing, and transaction record creation with revenue split calculation.

**Acceptance Criteria:**
- [ ] Method: `createCheckoutSession(courseId, userId, couponId)` - creates Stripe Checkout Session with line items (course price, discount, tax)
- [ ] Method: `handleWebhook(stripeEvent, signature)` - verifies webhook signature, processes payment_intent.succeeded event
- [ ] Method: `processRefund(transactionId)` - initiates Stripe refund, updates transaction status
- [ ] Checkout session includes: course title/description, price (with coupon discount applied), success_url, cancel_url
- [ ] On payment_intent.succeeded webhook: Creates Transaction record (status='completed'), creates RevenueRecord (70/30 split), creates Enrollment record (grants course access), sends confirmation email
- [ ] Revenue split calculation: instructor_amount = (amount_net * 0.70), platform_amount = (amount_net * 0.30), escrow_release_date = now() + 7 days
- [ ] Stripe fee calculation: (amount_gross * 0.029) + 0.30
- [ ] Idempotency: Uses Stripe payment_intent_id as unique key (prevents duplicate transactions)

**Idempotency:**
- Type: Stripe payment_intent_id as unique constraint
- Duplicate handling: If webhook received twice, query Transaction by stripe_payment_intent_id first, skip if exists

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Stripe API timeout | 504 | Retry webhook processing (Stripe retries automatically) |
| Invalid coupon code | 400 | "Coupon code invalid or expired" |
| Course not found | 404 | Return error before creating Stripe session |
| Webhook signature invalid | 401 | Log security alert, reject webhook |
| User already enrolled | 409 | "You already own this course" |

**Reliability Notes:**
- Webhook retries: Stripe retries failed webhooks with exponential backoff (up to 3 days)
- Idempotency: Check transaction exists by stripe_payment_intent_id before processing
- Transaction scope: Yes - wrap Transaction + RevenueRecord + Enrollment in DB::transaction

**Security Checklist:**
- [ ] Webhook signature verification (Stripe signing secret)
- [ ] Payment data never stored (Stripe-hosted checkout)
- [ ] PCI compliance via Stripe
- [ ] Refund authorization: Only instructor or admin can initiate

**Test Requirements:**
- Unit test: `tests/unit/services/StripePaymentService.test.js`
- Integration test: `tests/integration/stripe-payment-flow.test.js` (uses Stripe test mode)
- Coverage: Checkout session creation, webhook processing, refund flow, revenue split calculation

---

#### [MKT-014] Controller: CheckoutController (purchase flow)

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/controllers/CheckoutController.js`
- `src/routes/checkout.js`

**Dependencies:**
- blocked-by: [MKT-013]
- parallel-with: None

**Description:**
Implement REST API for course purchase flow: create checkout session, handle Stripe webhooks, process refunds.

**Acceptance Criteria:**
- [ ] POST /api/checkout/create - Create Stripe checkout session (body: {courseId, couponCode (optional)})
- [ ] POST /api/webhooks/stripe - Stripe webhook endpoint (verifies signature, delegates to StripePaymentService)
- [ ] POST /api/transactions/:id/refund - Request refund (student or instructor, within 30-day window)
- [ ] GET /api/transactions/:id - Get transaction details (buyer, instructor, or admin only)
- [ ] GET /api/transactions - List user's transactions (authenticated user, paginated)
- [ ] Validates user not already enrolled before creating checkout session
- [ ] Returns checkout session URL for redirect to Stripe-hosted page

**Idempotency:**
- Type: Client idempotency key for checkout creation
- Storage: Redis with 24h TTL
- Duplicate handling: Return existing checkout session URL if key exists

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Create checkout for owned course | 409 | "You already own this course" |
| Request refund >30 days | 400 | "Refund window expired (30 days)" |
| Access other user's transaction | 403 | "Access denied" |
| Stripe API down | 503 | "Payment processing unavailable - retry" |

**Security Checklist:**
- [ ] Authentication required for all endpoints
- [ ] Authorization checks: user can only view own transactions
- [ ] Rate limiting: 60 req/min for checkout, 10 req/min for refund
- [ ] Webhook endpoint: raw body required for signature verification

**Test Requirements:**
- Integration test: `tests/integration/checkout-api.test.js`
- Coverage: Checkout creation, webhook processing, refund requests

---

#### [MKT-015] Test: Purchase flow end-to-end

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `tests/integration/purchase-flow.test.js`

**Dependencies:**
- blocked-by: [MKT-014]
- needs: [MKT-013], [MKT-014]
- parallel-with: None

**Description:**
Integration test simulating complete purchase flow: student creates checkout → completes payment (mocked Stripe webhook) → receives enrollment → accesses course.

**Acceptance Criteria:**
- [ ] Test student user creates checkout session for $79 course
- [ ] Test mocks Stripe payment_intent.succeeded webhook with valid signature
- [ ] Test verifies Transaction created (status='completed', stripe_payment_intent_id)
- [ ] Test verifies RevenueRecord created (instructor_amount=$55.30, platform_amount=$23.70)
- [ ] Test verifies Enrollment created (student can access course)
- [ ] Test student fetches course, verifies can access paid lessons (not just previews)

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + enrollment duplication check

---

### Slice 4: Revenue & Payouts

#### [MKT-016] Migration: Create instructor_payouts table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000006_create_instructor_payouts_table.js`

**Dependencies:**
- blocked-by: None
- parallel-with: [MKT-011]

**Description:**
Create the `instructor_payouts` table to track monthly instructor payouts processed via Stripe Connect, including payout amount, transfer status, and bank account details.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), instructor_id (FK users), payout_period (DATE), total_amount (DECIMAL 10,2), stripe_transfer_id (VARCHAR 100 UNIQUE nullable), status (ENUM), initiated_at (TIMESTAMPTZ), completed_at (TIMESTAMPTZ nullable), failure_reason (TEXT nullable), created_at
- [ ] Status ENUM: 'pending', 'processing', 'completed', 'failed'
- [ ] Foreign key on instructor_id → users.id with ON DELETE RESTRICT
- [ ] Indexes on: instructor_id, payout_period, status
- [ ] Unique constraint on (instructor_id, payout_period) - one payout per instructor per month

**Data Model Notes:**
```yaml
table: instructor_payouts
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: instructor_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: restrict
  - name: payout_period
    type: date
    nullable: false
    comment: First day of payout month (e.g., 2026-02-01)
  - name: total_amount
    type: decimal(10,2)
    nullable: false
    comment: Sum of all instructor_amount from revenue_records
  - name: stripe_transfer_id
    type: varchar(100)
    nullable: true
    unique: true
  - name: status
    type: enum ['pending', 'processing', 'completed', 'failed']
    default: 'pending'
  - name: initiated_at
    type: timestamptz
    nullable: true
  - name: completed_at
    type: timestamptz
    nullable: true
  - name: failure_reason
    type: text
    nullable: true
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [instructor_id, payout_period]
    name: idx_payouts_instructor_period
    unique: true
  - columns: [status, initiated_at]
    name: idx_payouts_status_time
  - columns: [stripe_transfer_id]
    name: idx_payouts_stripe
    unique: true
constraints:
  - check: total_amount >= 50 (minimum payout threshold)
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/instructor-payouts-table.test.js`

---

#### [MKT-017] Service: StripeConnectService (instructor payouts)

**Size:** XL (6-8h)
**Priority:** P0
**Complexity:** High

**File(s):**
- `src/services/StripeConnectService.js`

**Dependencies:**
- blocked-by: [MKT-012], [MKT-016]
- parallel-with: None

**Description:**
Integrate Stripe Connect for automated instructor payouts. Handles Connect account creation, bank account linking, payout transfer initiation, and webhook processing for transfer status updates.

**Acceptance Criteria:**
- [ ] Method: `createConnectAccount(userId, email, country)` - creates Stripe Connect Express account, returns onboarding link
- [ ] Method: `initiateMonthlyPayouts()` - batch job triggered on 1st of month at 12:00 AM UTC
- [ ] Method: `processIndividualPayout(instructorId, period)` - creates Stripe Transfer, updates InstructorPayout status
- [ ] Method: `handleTransferWebhook(stripeEvent)` - processes transfer.paid / transfer.failed events
- [ ] Payout calculation: Sum of revenue_records.instructor_amount WHERE instructor_id={id} AND escrow_release_date <= now() AND payout_id IS NULL
- [ ] Minimum payout threshold: $50 (skip instructors below threshold, defer to next month)
- [ ] On transfer.paid webhook: Updates InstructorPayout status='completed', updates RevenueRecord.payout_id
- [ ] On transfer.failed webhook: Updates status='failed', sets failure_reason, sends email notification to instructor
- [ ] Idempotency: Uses InstructorPayout unique constraint (instructor_id, payout_period) to prevent duplicate payouts

**Idempotency:**
- Type: Database unique constraint on (instructor_id, payout_period)
- Duplicate handling: Query InstructorPayout first, skip if already exists for period

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Connect account not linked | N/A | Skip payout, email instructor to complete onboarding |
| Stripe transfer fails | N/A | Mark payout status='failed', retry next month, alert ops |
| Instructor earnings <$50 | N/A | Skip payout, defer to next month when threshold met |
| Transfer timeout | N/A | Webhook will update status asynchronously, no immediate action needed |

**Reliability Notes:**
- Queue: `instructor-payouts` (RabbitMQ)
- Tries: 3 attempts for transfer initiation
- Backoff: Exponential (1h, 4h, 12h)
- Timeout: 60s per transfer API call
- Transaction scope: Yes - wrap InstructorPayout creation + RevenueRecord updates
- Batch processing: Process 100 instructors per job, spawn multiple workers for parallelism

**Security Checklist:**
- [ ] Stripe Connect Express accounts (platform controls funds, not full access)
- [ ] Bank account verification via Stripe (microdeposit or instant)
- [ ] Transfer webhook signature verification
- [ ] W-9/W-8 tax forms collected via Stripe Identity

**Test Requirements:**
- Unit test: `tests/unit/services/StripeConnectService.test.js`
- Integration test: `tests/integration/stripe-connect-payout.test.js`
- Coverage: Connect account creation, payout calculation, transfer flow, minimum threshold, webhook handling

---

#### [MKT-018] Job: MonthlyPayoutProcessingJob

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/jobs/MonthlyPayoutProcessingJob.js`

**Dependencies:**
- blocked-by: [MKT-017]
- parallel-with: None

**Description:**
Background job scheduled to run on the 1st of each month at 12:00 AM UTC. Queries all instructors with pending payouts ≥$50, initiates Stripe Connect transfers, and sends payout notification emails.

**Acceptance Criteria:**
- [ ] Cron schedule: `0 0 1 * *` (1st day of month, midnight UTC)
- [ ] Queries revenue_records WHERE escrow_release_date <= now() AND payout_id IS NULL, grouped by instructor_id
- [ ] Filters instructors with total amount ≥$50
- [ ] Calls StripeConnectService.processIndividualPayout() per instructor (batched 100 at a time)
- [ ] Sends email notification to instructor with payout details (amount, transfer date, transaction breakdown)
- [ ] Logs payout summary: total instructors processed, total amount transferred, failures
- [ ] Job concurrency: max 5 concurrent worker processes (parallelism via RabbitMQ)

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Stripe API unavailable | N/A | Retry job in 1 hour (up to 3 attempts), alert ops if all fail |
| Email service down | N/A | Log error, payout still processes, email retried separately |
| Database timeout | N/A | Rollback transaction, retry batch |

**Reliability Notes:**
- Queue: `monthly-payouts` (RabbitMQ)
- Tries: 3 attempts
- Backoff: Exponential (1h, 4h, 12h)
- Timeout: 30 minutes per batch (100 instructors)
- Transaction scope: Yes per individual payout
- Dead letter queue: Yes - failed payouts after 3 attempts moved to DLQ for manual review

**Test Requirements:**
- Unit test: `tests/unit/jobs/MonthlyPayoutProcessingJob.test.js`
- Integration test: `tests/integration/monthly-payout-job.test.js`
- Coverage: Batch processing, minimum threshold, email notifications, error handling

---

#### [MKT-019] Controller: InstructorEarningsController

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/controllers/InstructorEarningsController.js`
- `src/routes/instructor-earnings.js`

**Dependencies:**
- blocked-by: [MKT-017]
- parallel-with: None

**Description:**
Implement REST API for instructor earnings dashboard: view total revenue, per-course breakdown, payout history, and pending earnings.

**Acceptance Criteria:**
- [ ] GET /api/instructor/earnings - Total earnings summary (total revenue, pending payout, lifetime payouts)
- [ ] GET /api/instructor/earnings/courses - Per-course breakdown (course title, total revenue, enrollment count, avg rating)
- [ ] GET /api/instructor/payouts - Payout history (payout_period, amount, status, transfer_id)
- [ ] GET /api/instructor/earnings/pending - Pending earnings (revenue not yet paid out, escrow release dates)
- [ ] All endpoints require instructor authentication
- [ ] Returns formatted currency values (USD)

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Non-instructor accesses | 403 | "Instructor-only endpoint" |
| No earnings yet | 200 | Return empty results with totals=0 |

**Security Checklist:**
- [ ] instructorOnly middleware
- [ ] Rate limiting: 60 req/min
- [ ] User can only view own earnings

**Test Requirements:**
- Integration test: `tests/integration/instructor-earnings-api.test.js`
- Coverage: All 4 endpoints, authorization, empty state

---

#### [MKT-020] Test: Payout processing workflow

**Size:** M (2-4h)
**Priority:** P2
**Complexity:** Medium

**File(s):**
- `tests/integration/payout-workflow.test.js`

**Dependencies:**
- blocked-by: [MKT-018]
- parallel-with: None

**Description:**
Integration test simulating monthly payout workflow: instructor earns revenue → escrow releases after 7 days → monthly job triggers → Stripe transfer initiated → payout completes.

**Acceptance Criteria:**
- [ ] Test creates instructor with 10 completed transactions (total $850 earnings)
- [ ] Test fast-forwards escrow_release_date to past (time travel for test)
- [ ] Test triggers MonthlyPayoutProcessingJob manually
- [ ] Test verifies InstructorPayout created (total_amount=$850, status='completed')
- [ ] Test verifies RevenueRecords updated with payout_id
- [ ] Test mocks Stripe transfer.paid webhook, verifies status update

**Test Requirements:**
- Integration test: This task itself
- Coverage: Happy path + minimum threshold skip scenario

---

### Slice 5: Enrollment & Progress

#### [MKT-021] Migration: Create enrollments table

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000007_create_enrollments_table.js`

**Dependencies:**
- blocked-by: [MKT-001]
- parallel-with: [MKT-022]

**Description:**
Create the `enrollments` table to grant students access to purchased courses, track enrollment dates, and link to transactions.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), course_id (FK), student_id (FK users), transaction_id (FK), enrolled_at, last_accessed_at (nullable), completed_at (nullable)
- [ ] Foreign keys with ON DELETE CASCADE for course_id, ON DELETE RESTRICT for student_id/transaction_id
- [ ] Indexes on: student_id, course_id, transaction_id
- [ ] Composite unique constraint on (course_id, student_id) - one enrollment per student per course

**Data Model Notes:**
```yaml
table: enrollments
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: course_id
    type: uuid
    nullable: false
    foreign_key: courses.id
    on_delete: cascade
  - name: student_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: restrict
  - name: transaction_id
    type: uuid
    nullable: false
    foreign_key: transactions.id
    on_delete: restrict
  - name: enrolled_at
    type: timestamptz
    nullable: false
  - name: last_accessed_at
    type: timestamptz
    nullable: true
  - name: completed_at
    type: timestamptz
    nullable: true
indexes:
  - columns: [student_id, enrolled_at DESC]
    name: idx_enrollments_student_time
  - columns: [course_id, student_id]
    name: idx_enrollments_unique
    unique: true
  - columns: [transaction_id]
    name: idx_enrollments_transaction
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/enrollments-table.test.js`

---

#### [MKT-022] Migration: Create course_progress table

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000008_create_course_progress_table.js`

**Dependencies:**
- blocked-by: [MKT-021], [MKT-002]
- parallel-with: None

**Description:**
Create the `course_progress` table to track student progress per lesson (video completion, timestamps).

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), enrollment_id (FK), lesson_id (FK course_lessons), progress_seconds (INT), completed (BOOLEAN default false), last_watched_at, created_at, updated_at
- [ ] Foreign keys with ON DELETE CASCADE
- [ ] Indexes on: enrollment_id, lesson_id
- [ ] Composite unique constraint on (enrollment_id, lesson_id)
- [ ] Check constraint: progress_seconds >= 0

**Data Model Notes:**
```yaml
table: course_progress
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: enrollment_id
    type: uuid
    nullable: false
    foreign_key: enrollments.id
    on_delete: cascade
  - name: lesson_id
    type: uuid
    nullable: false
    foreign_key: course_lessons.id
    on_delete: cascade
  - name: progress_seconds
    type: integer
    default: 0
    comment: Current playback position in video
  - name: completed
    type: boolean
    default: false
    comment: True if watched ≥90% of video
  - name: last_watched_at
    type: timestamptz
    nullable: false
  - name: created_at
    type: timestamptz
    nullable: false
  - name: updated_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [enrollment_id, lesson_id]
    name: idx_progress_enrollment_lesson
    unique: true
  - columns: [enrollment_id, completed]
    name: idx_progress_completion
constraints:
  - check: progress_seconds >= 0
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/course-progress-table.test.js`

---

#### [MKT-023] Model: Enrollment with progress tracking

**Size:** M (2-4h)
**Priority:** P0
**Complexity:** Medium

**File(s):**
- `src/models/Enrollment.js`
- `src/models/CourseProgress.js`

**Dependencies:**
- blocked-by: [MKT-021], [MKT-022]
- parallel-with: None

**Description:**
Create Sequelize models for Enrollment and CourseProgress with methods for completion calculation, certificate eligibility, and progress updates.

**Acceptance Criteria:**
- [ ] Enrollment model: relationships to Course (belongsTo), User (student), Transaction, CourseProgress (hasMany)
- [ ] Enrollment methods: `getCompletionPercentage()` - calculates % of lessons completed, `isEligibleForCertificate()` - checks ≥90% completion, `markCompleted()` - sets completed_at timestamp
- [ ] CourseProgress model: relationships to Enrollment (belongsTo), CourseLesson (belongsTo)
- [ ] CourseProgress methods: `updateProgress(seconds)` - updates progress_seconds, auto-marks completed if ≥90% of lesson duration
- [ ] Validation: progress_seconds cannot exceed lesson video_duration_seconds

**Test Requirements:**
- Unit test: `tests/unit/models/Enrollment.test.js`
- Coverage: Completion calculation, certificate eligibility, progress updates

---

#### [MKT-024] Controller: EnrollmentController (student dashboard)

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/controllers/EnrollmentController.js`
- `src/routes/enrollments.js`

**Dependencies:**
- blocked-by: [MKT-023]
- parallel-with: None

**Description:**
Implement REST API for student "My Learning" dashboard: list enrolled courses, view progress, update lesson progress, download certificates.

**Acceptance Criteria:**
- [ ] GET /api/enrollments - List student's enrolled courses (includes progress %, last accessed)
- [ ] GET /api/enrollments/:id/progress - Get detailed progress per lesson
- [ ] PUT /api/enrollments/:id/progress/:lessonId - Update lesson progress (body: {progressSeconds, completed})
- [ ] GET /api/enrollments/:id/certificate - Generate certificate PDF (requires ≥90% completion)
- [ ] Authentication required (student can only access own enrollments)
- [ ] Progress updates idempotent (upsert on enrollment_id + lesson_id)

**Idempotency:**
- Type: Database unique constraint on (enrollment_id, lesson_id)
- Duplicate handling: UPSERT query updates progress_seconds if record exists

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Request certificate <90% complete | 403 | "Complete 90% of course to earn certificate" |
| Update progress for unenrolled course | 403 | "Access denied - not enrolled" |
| Progress seconds exceed lesson duration | 400 | "Invalid progress value" |

**Security Checklist:**
- [ ] Authentication required
- [ ] User can only access own enrollments
- [ ] Rate limiting: 120 req/min for progress updates (frequent during video playback)

**Test Requirements:**
- Integration test: `tests/integration/enrollment-api.test.js`
- Coverage: All endpoints, progress updates, certificate generation

---

### Slice 6: Reviews & Ratings

#### [MKT-025] Migration: Create course_reviews table

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000009_create_course_reviews_table.js`

**Dependencies:**
- blocked-by: [MKT-001], [MKT-021]
- parallel-with: None

**Description:**
Create the `course_reviews` table to store student ratings and text reviews. Only verified purchases (enrollments) can review.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), course_id (FK), reviewer_id (FK users), enrollment_id (FK), rating (INT), review_text (TEXT nullable), helpful_count (INT default 0), created_at, updated_at
- [ ] Foreign keys with ON DELETE CASCADE for course_id, ON DELETE RESTRICT for reviewer_id/enrollment_id
- [ ] Indexes on: course_id, reviewer_id, rating, created_at
- [ ] Composite unique constraint on (course_id, reviewer_id) - one review per student per course
- [ ] Check constraint: rating BETWEEN 1 AND 5

**Data Model Notes:**
```yaml
table: course_reviews
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: course_id
    type: uuid
    nullable: false
    foreign_key: courses.id
    on_delete: cascade
  - name: reviewer_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: restrict
  - name: enrollment_id
    type: uuid
    nullable: false
    foreign_key: enrollments.id
    on_delete: restrict
    comment: Ensures verified purchase
  - name: rating
    type: integer
    nullable: false
    check: rating >= 1 AND rating <= 5
  - name: review_text
    type: text
    nullable: true
    check: length(review_text) <= 500
  - name: helpful_count
    type: integer
    default: 0
    comment: Upvotes from other students
  - name: created_at
    type: timestamptz
    nullable: false
  - name: updated_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [course_id, created_at DESC]
    name: idx_reviews_course_time
  - columns: [course_id, reviewer_id]
    name: idx_reviews_unique
    unique: true
  - columns: [reviewer_id]
    name: idx_reviews_reviewer
constraints:
  - check: rating >= 1 AND rating <= 5
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/course-reviews-table.test.js`

---

#### [MKT-026] Model: CourseReview with aggregation

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/models/CourseReview.js`

**Dependencies:**
- blocked-by: [MKT-025]
- parallel-with: None

**Description:**
Create Sequelize model for CourseReview with methods for rating aggregation (average, count, distribution), verified purchase check, and review submission eligibility.

**Acceptance Criteria:**
- [ ] Model with relationships: belongsTo Course, belongsTo User (reviewer), belongsTo Enrollment
- [ ] Static methods: `getAverageRating(courseId)`, `getRatingDistribution(courseId)` - returns {1: 5, 2: 3, 3: 10, 4: 25, 5: 57} counts per star rating
- [ ] Instance methods: `markHelpful()` - increments helpful_count
- [ ] Validation: User must have enrollment with ≥50% progress to submit review (business rule)

**Test Requirements:**
- Unit test: `tests/unit/models/CourseReview.test.js`
- Coverage: Aggregation methods, eligibility checks, helpful votes

---

#### [MKT-027] Controller: CourseReviewController

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/controllers/CourseReviewController.js`
- `src/routes/course-reviews.js`

**Dependencies:**
- blocked-by: [MKT-026]
- parallel-with: None

**Description:**
Implement REST API for course reviews: submit review/rating, list reviews for course, mark review as helpful.

**Acceptance Criteria:**
- [ ] POST /api/courses/:id/reviews - Submit review (body: {rating (1-5), reviewText (max 500 chars)})
- [ ] GET /api/courses/:id/reviews - List reviews (paginated, sorted by newest or most helpful)
- [ ] PUT /api/reviews/:id/helpful - Mark review as helpful (increment helpful_count)
- [ ] DELETE /api/reviews/:id - Delete own review (reviewer or admin only)
- [ ] Validates user has enrollment and ≥50% progress before allowing review submission
- [ ] Prevents duplicate reviews (composite unique constraint enforced)

**Idempotency:**
- Type: Database unique constraint on (course_id, reviewer_id)
- Duplicate handling: Return 409 if user already reviewed course

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Review without enrollment | 403 | "Purchase course to leave review" |
| Review with <50% progress | 403 | "Complete 50% of course to review" |
| Duplicate review | 409 | "You already reviewed this course" |
| Rating out of range (1-5) | 400 | "Rating must be 1-5 stars" |
| Review text >500 chars | 400 | "Review too long (max 500 chars)" |

**Security Checklist:**
- [ ] Authentication required for submit/helpful/delete
- [ ] Authorization: user can only delete own reviews
- [ ] Rate limiting: 10 reviews/hour per user (prevent spam)
- [ ] Input sanitization for review_text (strip HTML)

**Test Requirements:**
- Integration test: `tests/integration/course-review-api.test.js`
- Coverage: Submit review, list reviews, helpful votes, validation errors

---

### Slice 7: Coupons & Discounts

#### [MKT-028] Migration: Create coupons table

**Size:** S (1-2h)
**Priority:** P2
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000010_create_coupons_table.js`

**Dependencies:**
- blocked-by: [MKT-001]
- parallel-with: None

**Description:**
Create the `coupons` table for instructor-created discount codes with usage limits and expiration dates.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), code (VARCHAR 50 UNIQUE), creator_id (FK users), course_id (FK nullable), discount_type (ENUM), discount_value (DECIMAL 10,2), max_uses (INT nullable), current_uses (INT default 0), expires_at (TIMESTAMPTZ nullable), created_at
- [ ] Discount type ENUM: 'percentage', 'fixed_amount'
- [ ] Foreign keys with ON DELETE CASCADE for creator_id, course_id
- [ ] Indexes on: code (unique), course_id, expires_at
- [ ] Check constraints: discount_value > 0, max_uses >= 0, current_uses >= 0

**Data Model Notes:**
```yaml
table: coupons
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: code
    type: varchar(50)
    nullable: false
    unique: true
    comment: Case-insensitive coupon code (e.g., PYTHON20)
  - name: creator_id
    type: uuid
    nullable: false
    foreign_key: users.id
    on_delete: cascade
    comment: Instructor who created coupon
  - name: course_id
    type: uuid
    nullable: true
    foreign_key: courses.id
    on_delete: cascade
    comment: Specific course (null = applies to all creator's courses)
  - name: discount_type
    type: enum ['percentage', 'fixed_amount']
    nullable: false
  - name: discount_value
    type: decimal(10,2)
    nullable: false
    comment: 20.00 for 20% off OR 10.00 for $10 off
  - name: max_uses
    type: integer
    nullable: true
    comment: Null = unlimited uses
  - name: current_uses
    type: integer
    default: 0
  - name: expires_at
    type: timestamptz
    nullable: true
    comment: Null = never expires
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [code]
    name: idx_coupons_code
    unique: true
  - columns: [course_id]
    name: idx_coupons_course
  - columns: [expires_at]
    name: idx_coupons_expiry
constraints:
  - check: discount_value > 0
  - check: (discount_type = 'percentage' AND discount_value <= 100) OR discount_type = 'fixed_amount'
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/coupons-table.test.js`

---

#### [MKT-029] Controller: CouponController

**Size:** M (2-4h)
**Priority:** P2
**Complexity:** Medium

**File(s):**
- `src/controllers/CouponController.js`
- `src/routes/coupons.js`

**Dependencies:**
- blocked-by: [MKT-028]
- parallel-with: None

**Description:**
Implement REST API for coupon management: instructors create/list coupons, students validate coupon codes during checkout.

**Acceptance Criteria:**
- [ ] POST /api/coupons - Create coupon (instructor only, body: {code, courseId, discountType, discountValue, maxUses, expiresAt})
- [ ] GET /api/coupons - List instructor's coupons
- [ ] DELETE /api/coupons/:id - Delete coupon (instructor only)
- [ ] POST /api/coupons/validate - Validate coupon code (body: {code, courseId}) - returns discount info or error
- [ ] Validates coupon not expired, not exceeded max_uses, applies to correct course
- [ ] Increments current_uses when transaction completes (in StripePaymentService webhook)

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Coupon code invalid | 404 | "Coupon code not found" |
| Coupon expired | 400 | "Coupon expired" |
| Coupon max uses exceeded | 400 | "Coupon usage limit reached" |
| Coupon doesn't apply to course | 400 | "Coupon not valid for this course" |
| Duplicate coupon code | 409 | "Coupon code already exists" |

**Security Checklist:**
- [ ] instructorOnly middleware for create/delete
- [ ] Rate limiting: 60 req/min for validate (called during checkout)
- [ ] Coupon codes case-insensitive (convert to uppercase in DB)

**Test Requirements:**
- Integration test: `tests/integration/coupon-api.test.js`
- Coverage: Create, validate, expiration checks, usage limits

---

### Slice 8: Security & Compliance

#### [MKT-030] Middleware: Rate limiting per endpoint

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/middleware/rate-limit.middleware.js`

**Dependencies:**
- blocked-by: None
- parallel-with: None

**Description:**
Implement Redis-backed rate limiting using `express-rate-limit` with per-endpoint configurations for marketplace API.

**Acceptance Criteria:**
- [ ] Rate limit configurations:
  - General API: 60 req/min per user
  - Course publish: 10 req/min per user
  - Checkout: 60 req/min per user
  - Review submission: 10 req/hour per user
  - Video upload: 20 req/hour per user
- [ ] Uses Redis for distributed rate limiting (multi-server support)
- [ ] Returns 429 Too Many Requests with `Retry-After` header
- [ ] Exempts admin users from rate limits

**Test Requirements:**
- Integration test: `tests/integration/rate-limiting.test.js`
- Coverage: Limit enforcement, 429 responses, Redis integration

---

#### [MKT-031] Service: Tax collection (Stripe Tax integration)

**Size:** M (2-4h)
**Priority:** P1
**Complexity:** Medium

**File(s):**
- `src/services/TaxService.js`

**Dependencies:**
- blocked-by: [MKT-013]
- parallel-with: None

**Description:**
Integrate Stripe Tax for automated sales tax calculation and collection (US states only for MVP). Handles tax calculation at checkout, Stripe automatic remittance to states.

**Acceptance Criteria:**
- [ ] Method: `calculateTax(coursePrice, studentLocation)` - returns tax amount based on student's state
- [ ] Integrates with Stripe Tax API (automatic tax calculation in Stripe Checkout Session)
- [ ] Enables Stripe Tax in Stripe Dashboard for US states
- [ ] Tax collected added to transaction total, remitted by Stripe to state governments
- [ ] Returns tax breakdown: {taxAmount, taxRate, jurisdiction} for display on checkout page

**Error Scenarios:**
| Scenario | HTTP Code | Handling Strategy |
|----------|-----------|-------------------|
| Stripe Tax API unavailable | 503 | Proceed without tax (log error, alert finance team) |
| Invalid location data | 400 | "Unable to determine tax jurisdiction" |

**Test Requirements:**
- Unit test: `tests/unit/services/TaxService.test.js`
- Coverage: Tax calculation, Stripe Tax API integration

---

#### [MKT-032] Migration: Add audit logs for transactions

**Size:** S (1-2h)
**Priority:** P1
**Complexity:** Low

**File(s):**
- `database/migrations/YYYY_MM_DD_000011_create_transaction_audit_logs_table.js`

**Dependencies:**
- blocked-by: [MKT-011]
- parallel-with: None

**Description:**
Create audit logging table for sensitive transaction actions (refunds, payout failures, coupon usage) to comply with financial record-keeping requirements.

**Acceptance Criteria:**
- [ ] Table includes columns: id (UUID), transaction_id (FK nullable), action (ENUM), actor_id (FK users), metadata (JSONB), ip_address (INET), created_at
- [ ] Action ENUM: 'purchase', 'refund_requested', 'refund_processed', 'payout_initiated', 'payout_failed', 'coupon_applied'
- [ ] Indexes on: transaction_id, action, created_at
- [ ] Retention: 7 years (financial compliance)

**Data Model Notes:**
```yaml
table: transaction_audit_logs
columns:
  - name: id
    type: uuid
    primary_key: true
  - name: transaction_id
    type: uuid
    nullable: true
    foreign_key: transactions.id
  - name: action
    type: enum [6 actions]
    nullable: false
  - name: actor_id
    type: uuid
    nullable: false
    foreign_key: users.id
  - name: metadata
    type: jsonb
    default: '{}'
  - name: ip_address
    type: inet
    nullable: true
  - name: created_at
    type: timestamptz
    nullable: false
indexes:
  - columns: [transaction_id, created_at]
    name: idx_audit_logs_transaction_time
  - columns: [action, created_at]
    name: idx_audit_logs_action_time
retention: 7 years (compliance requirement)
migration:
  zero_downtime: true
```

**Test Requirements:**
- Unit test: `tests/migrations/transaction-audit-logs-table.test.js`

---

#### [MKT-033] Service: Video encryption and signed URLs

**Size:** S (1-2h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/services/VideoSecurityService.js`

**Dependencies:**
- blocked-by: [MKT-005]
- parallel-with: None

**Description:**
Enhance VideoUploadService with encryption at rest (S3 SSE) and time-limited presigned URLs for video playback. Prevents unauthorized video access.

**Acceptance Criteria:**
- [ ] All S3 uploads include header: `x-amz-server-side-encryption: AES256`
- [ ] Method: `generateSecurePlaybackUrl(lessonId, userId, expiresIn=3600)` - verifies enrollment before generating presigned URL
- [ ] Presigned URLs expire after 1 hour (default), regenerated on subsequent requests
- [ ] Validates user enrolled in course before generating URL (authorization check)

**Test Requirements:**
- Unit test: `tests/unit/services/VideoSecurityService.test.js`
- Coverage: Encryption verification, presigned URL generation, authorization

---

#### [MKT-034] Configuration: Stripe webhook signature verification

**Size:** XS (0.5-1h)
**Priority:** P0
**Complexity:** Low

**File(s):**
- `src/middleware/stripe-webhook-auth.middleware.js`

**Dependencies:**
- blocked-by: [MKT-013]
- parallel-with: None

**Description:**
Middleware to verify Stripe webhook signatures, preventing spoofed webhook attacks.

**Acceptance Criteria:**
- [ ] Extracts `Stripe-Signature` header from request
- [ ] Verifies signature using Stripe signing secret from environment variable
- [ ] Returns 401 Unauthorized if signature invalid
- [ ] Requires raw request body (not JSON parsed) for signature verification

**Test Requirements:**
- Unit test: `tests/unit/middleware/stripe-webhook-auth.test.js`
- Coverage: Valid signature, invalid signature, missing signature

---

#### [MKT-035] Test: End-to-end marketplace flow

**Size:** L (4-6h)
**Priority:** P2
**Complexity:** High

**File(s):**
- `tests/integration/marketplace-e2e.test.js`

**Dependencies:**
- blocked-by: [MKT-014], [MKT-024], [MKT-027]
- parallel-with: None

**Description:**
Comprehensive integration test covering full marketplace lifecycle: instructor creates course → student discovers → purchases with coupon → accesses lessons → leaves review → instructor receives payout.

**Acceptance Criteria:**
- [ ] Test instructor creates course with 5 lessons, publishes
- [ ] Test student searches, finds course, applies coupon, purchases ($79 → $63.20 with PYTHON20)
- [ ] Test payment webhook processed, enrollment created, revenue split recorded
- [ ] Test student watches lessons, progress tracked, completes 90%
- [ ] Test student leaves 5-star review
- [ ] Test monthly payout job runs, instructor receives $53.49 (70% of $76.41 net)
- [ ] Test runs in <60 seconds (uses mocks for Stripe/S3)

**Test Requirements:**
- Integration test: This task itself
- Coverage: Complete happy path from creation to payout

---

## Dependency Graph

### Critical Path (Sequential)

```
[MKT-001] → [MKT-002] → [MKT-003] → [MKT-004] → [MKT-005] → [MKT-006] → [MKT-007]
Migration   Migration   Model       Model       Service     Controller  Test
Courses     Lessons     Course      Lesson      VideoUpload CourseCtrl  Workflow
2-3h        1-2h        4-6h        1-2h        2-4h        6-8h        2-4h
═══════════════════════════════════════════════════════════════════════════════
Total: ~18-29 hours (course management foundation)

[MKT-011] → [MKT-012] → [MKT-013] → [MKT-014] → [MKT-015]
Migration   Migration   Service     Controller  Test
Transaction Revenue     Stripe      Checkout    Purchase
2-3h        1-2h        6-8h        2-4h        2-4h
═══════════════════════════════════════════════════════════════
Total: ~13-21 hours (payment processing)

[MKT-016] → [MKT-017] → [MKT-018] → [MKT-020]
Migration   Service     Job         Test
Payouts     StripeConn  MonthlyJob  PayoutTest
1-2h        6-8h        2-4h        2-4h
════════════════════════════════════════════
Total: ~11-18 hours (instructor payouts)
```

**Overall Critical Path**: ~42-68 hours (longest sequential chain through course management + payments + payouts)

### Parallel Tracks

**Track A (Courses)**: MKT-001 → MKT-007 (~18-29 hours)
**Track B (Search)**: MKT-008 → MKT-010 (~4-7 hours, can start after MKT-001)
**Track C (Payments)**: MKT-011 → MKT-015 (~13-21 hours, can start after MKT-001)
**Track D (Payouts)**: MKT-016 → MKT-020 (~11-18 hours, can start after MKT-011)
**Track E (Enrollments)**: MKT-021 → MKT-024 (~7-12 hours, can start after MKT-001)
**Track F (Reviews)**: MKT-025 → MKT-027 (~6-10 hours, can start after MKT-001 + MKT-021)
**Track G (Coupons)**: MKT-028 → MKT-029 (~3-6 hours, can start after MKT-001)
**Track H (Security)**: MKT-030 → MKT-034 (~5-8 hours, mostly parallel)
**Track I (E2E Test)**: MKT-035 (~4-6 hours, final integration)

**Total Estimated Effort**: 71-117 hours (sequential), can be reduced to ~42-68 hours with 2-3 developers working in parallel.

---

## Ambiguity Defaults Applied

| Area | PRD Ambiguity | Default Applied | Override? |
|------|---------------|-----------------|-----------|
| **Delete strategy** | Not specified | Soft delete for courses, hard delete for transactions/payouts (financial records) | - |
| **Pagination** | "List courses" | Cursor-based pagination, 25 courses per page | - |
| **Search technology** | "Elasticsearch or Algolia" | PostgreSQL full-text search (MVP), migrate to Elasticsearch in Phase 2 if needed | - |
| **Error format** | Not specified | RFC 7807 Problem Details: `{type, title, status, detail, instance}` | - |
| **Timestamps** | All tables | `created_at`, `updated_at` (Sequelize timestamps: true) | - |
| **Revenue split precision** | "70/30 split" | Calculated to 2 decimal places (DECIMAL 10,2), instructor = amount_net * 0.70 | - |
| **Payout threshold** | "Minimum payout" | $50 minimum, instructors below threshold deferred to next month | - |
| **Escrow period** | "7-day hold" | Revenue released 7 days after transaction, escrow_release_date = created_at + 7 days | - |
| **Preview duration limit** | "Up to 15 minutes" | Enforced in Course model validation, sum of is_preview lessons ≤ 15 min | - |
| **Video file size** | "Large files" | 5GB max per video file, multipart upload for files >100MB | - |
| **Tax calculation** | "Sales tax" | Stripe Tax integration (US only MVP), automatic calculation and remittance | - |
| **Coupon usage** | Not specified | Increment current_uses on successful transaction (webhook), prevent overuse via check | - |

---

## Export Formats

### Jira CSV Import

```csv
Summary,Description,Issue Type,Priority,Story Points,Epic Link,Labels
"[MKT-001] Migration: Create courses table","Create courses table with pricing models, categories, soft deletes. See task card for schema.",Task,Highest,3,MARKETPLACE-001,"backend,database,migration"
"[MKT-002] Migration: Create course_lessons table","Create course_lessons table with video URLs, preview flags, resource files.",Task,Highest,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-003] Model: Course with relationships","Sequelize Course model with publishing workflow, preview duration validation, relationships.",Task,Highest,5,MARKETPLACE-001,"backend,model,node"
"[MKT-004] Model: CourseLesson with video metadata","Sequelize CourseLesson model with access control, presigned URLs, lesson ordering.",Task,Highest,1,MARKETPLACE-001,"backend,model,node"
"[MKT-005] Service: VideoUploadService (S3 integration)","S3 video upload service with multipart upload, thumbnail generation, duration extraction.",Task,Highest,3,MARKETPLACE-001,"backend,service,aws,s3"
"[MKT-006] Controller: CourseController (CRUD + publish)","REST API for course management: CRUD, lesson upload, publishing workflow. 8 endpoints.",Task,Highest,8,MARKETPLACE-001,"backend,controller,api,express"
"[MKT-007] Test: Course creation and publishing workflow","Integration test: instructor creates course → uploads lessons → publishes → student views.",Task,High,3,MARKETPLACE-001,"backend,test,integration"
"[MKT-008] Migration: Add full-text search indexes","PostgreSQL GIN index for full-text search on course title/description.",Task,High,1,MARKETPLACE-001,"backend,database,migration,search"
"[MKT-009] Service: CourseSearchService (filter + search)","Course search/filter service using PostgreSQL full-text search, supports multi-filter.",Task,High,3,MARKETPLACE-001,"backend,service,search"
"[MKT-010] Controller: CourseSearchController","REST API for course search with query validation and Redis caching.",Task,High,1,MARKETPLACE-001,"backend,controller,api,search"
"[MKT-011] Migration: Create transactions table","Create transactions table with Stripe payment metadata, coupon discounts, status tracking.",Task,Highest,3,MARKETPLACE-001,"backend,database,migration"
"[MKT-012] Migration: Create revenue_records table","Create revenue_records table for 70/30 split tracking, escrow management.",Task,Highest,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-013] Service: StripePaymentService (checkout integration)","Stripe Checkout integration: session creation, webhook processing, refunds, revenue split.",Task,Highest,8,MARKETPLACE-001,"backend,service,stripe,payment"
"[MKT-014] Controller: CheckoutController (purchase flow)","REST API for purchase flow: checkout, webhooks, refunds, transaction history.",Task,Highest,3,MARKETPLACE-001,"backend,controller,api,stripe"
"[MKT-015] Test: Purchase flow end-to-end","Integration test: student checkout → payment webhook → enrollment → course access.",Task,High,3,MARKETPLACE-001,"backend,test,integration,stripe"
"[MKT-016] Migration: Create instructor_payouts table","Create instructor_payouts table for monthly automated payouts via Stripe Connect.",Task,Highest,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-017] Service: StripeConnectService (instructor payouts)","Stripe Connect integration: account creation, payout transfers, webhook processing.",Task,Highest,8,MARKETPLACE-001,"backend,service,stripe,connect"
"[MKT-018] Job: MonthlyPayoutProcessingJob","Background job for monthly instructor payouts, scheduled 1st of month, batched processing.",Task,Highest,3,MARKETPLACE-001,"backend,job,stripe,payout"
"[MKT-019] Controller: InstructorEarningsController","REST API for instructor earnings dashboard: total revenue, per-course, payout history.",Task,High,3,MARKETPLACE-001,"backend,controller,api"
"[MKT-020] Test: Payout processing workflow","Integration test: earnings → escrow release → monthly job → Stripe transfer → completion.",Task,Medium,3,MARKETPLACE-001,"backend,test,integration,payout"
"[MKT-021] Migration: Create enrollments table","Create enrollments table for student course access control, links to transactions.",Task,Highest,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-022] Migration: Create course_progress table","Create course_progress table for per-lesson progress tracking, completion status.",Task,High,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-023] Model: Enrollment with progress tracking","Sequelize Enrollment and CourseProgress models with completion calculation, certificate eligibility.",Task,Highest,3,MARKETPLACE-001,"backend,model,node"
"[MKT-024] Controller: EnrollmentController (student dashboard)","REST API for My Learning dashboard: enrolled courses, progress, certificate generation.",Task,High,3,MARKETPLACE-001,"backend,controller,api"
"[MKT-025] Migration: Create course_reviews table","Create course_reviews table for verified purchase reviews, ratings 1-5 stars.",Task,High,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-026] Model: CourseReview with aggregation","Sequelize CourseReview model with rating aggregation, verified purchase check.",Task,High,3,MARKETPLACE-001,"backend,model,node"
"[MKT-027] Controller: CourseReviewController","REST API for reviews: submit, list, mark helpful, delete. Verified purchase enforcement.",Task,High,3,MARKETPLACE-001,"backend,controller,api"
"[MKT-028] Migration: Create coupons table","Create coupons table for instructor-created discount codes with usage limits, expiration.",Task,Medium,1,MARKETPLACE-001,"backend,database,migration"
"[MKT-029] Controller: CouponController","REST API for coupon management: create, validate, list, delete. Usage tracking.",Task,Medium,3,MARKETPLACE-001,"backend,controller,api"
"[MKT-030] Middleware: Rate limiting per endpoint","Redis-backed rate limiting with per-endpoint configurations (publish, checkout, reviews).",Task,Highest,1,MARKETPLACE-001,"backend,middleware,security,redis"
"[MKT-031] Service: Tax collection (Stripe Tax integration)","Stripe Tax integration for automated sales tax calculation and collection (US only MVP).",Task,High,3,MARKETPLACE-001,"backend,service,stripe,tax"
"[MKT-032] Migration: Add audit logs for transactions","Create transaction_audit_logs table for financial record-keeping compliance (7-year retention).",Task,High,1,MARKETPLACE-001,"backend,database,migration,audit"
"[MKT-033] Service: Video encryption and signed URLs","Video encryption at rest (S3 SSE) and time-limited presigned URLs for authorized playback.",Task,Highest,1,MARKETPLACE-001,"backend,service,security,s3"
"[MKT-034] Configuration: Stripe webhook signature verification","Middleware to verify Stripe webhook signatures, prevents spoofed webhook attacks.",Task,Highest,1,MARKETPLACE-001,"backend,middleware,security,stripe"
"[MKT-035] Test: End-to-end marketplace flow","Comprehensive E2E test: create course → purchase with coupon → access → review → payout.",Task,Medium,5,MARKETPLACE-001,"backend,test,integration,e2e"
```

### Linear Markdown

```markdown
## Backend Task Breakdown: Course Marketplace

### Slice 1: Course Management
- [ ] [MKT-001] Migration: Create courses table (M, 2-3h) `backend` `database` `migration`
- [ ] [MKT-002] Migration: Create course_lessons table (S, 1-2h, blocked-by: MKT-001) `backend` `database` `migration`
- [ ] [MKT-003] Model: Course with relationships (L, 4-6h, blocked-by: MKT-001, MKT-002) `backend` `model` `node`
- [ ] [MKT-004] Model: CourseLesson with video metadata (S, 1-2h, blocked-by: MKT-002, MKT-003) `backend` `model` `node`
- [ ] [MKT-005] Service: VideoUploadService (S3 integration) (M, 2-4h) `backend` `service` `aws` `s3`
- [ ] [MKT-006] Controller: CourseController (CRUD + publish) (XL, 6-8h, blocked-by: MKT-003, MKT-004, MKT-005) `backend` `controller` `api` `express`
- [ ] [MKT-007] Test: Course creation and publishing workflow (M, 2-4h, blocked-by: MKT-006) `backend` `test` `integration`

### Slice 2: Discovery & Search
- [ ] [MKT-008] Migration: Add full-text search indexes (S, 1-2h, blocked-by: MKT-001) `backend` `database` `migration` `search`
- [ ] [MKT-009] Service: CourseSearchService (filter + search) (M, 2-4h, blocked-by: MKT-003, MKT-008) `backend` `service` `search`
- [ ] [MKT-010] Controller: CourseSearchController (S, 1-2h, blocked-by: MKT-009) `backend` `controller` `api` `search`

### Slice 3: Purchase & Payment
- [ ] [MKT-011] Migration: Create transactions table (M, 2-3h, blocked-by: MKT-001) `backend` `database` `migration`
- [ ] [MKT-012] Migration: Create revenue_records table (S, 1-2h, blocked-by: MKT-011) `backend` `database` `migration`
- [ ] [MKT-013] Service: StripePaymentService (checkout integration) (XL, 6-8h, blocked-by: MKT-003, MKT-011) `backend` `service` `stripe` `payment`
- [ ] [MKT-014] Controller: CheckoutController (purchase flow) (M, 2-4h, blocked-by: MKT-013) `backend` `controller` `api` `stripe`
- [ ] [MKT-015] Test: Purchase flow end-to-end (M, 2-4h, blocked-by: MKT-014) `backend` `test` `integration` `stripe`

### Slice 4: Revenue & Payouts
- [ ] [MKT-016] Migration: Create instructor_payouts table (S, 1-2h) `backend` `database` `migration`
- [ ] [MKT-017] Service: StripeConnectService (instructor payouts) (XL, 6-8h, blocked-by: MKT-012, MKT-016) `backend` `service` `stripe` `connect`
- [ ] [MKT-018] Job: MonthlyPayoutProcessingJob (M, 2-4h, blocked-by: MKT-017) `backend` `job` `stripe` `payout`
- [ ] [MKT-019] Controller: InstructorEarningsController (M, 2-4h, blocked-by: MKT-017) `backend` `controller` `api`
- [ ] [MKT-020] Test: Payout processing workflow (M, 2-4h, blocked-by: MKT-018) `backend` `test` `integration` `payout`

### Slice 5: Enrollment & Progress
- [ ] [MKT-021] Migration: Create enrollments table (S, 1-2h, blocked-by: MKT-001) `backend` `database` `migration`
- [ ] [MKT-022] Migration: Create course_progress table (S, 1-2h, blocked-by: MKT-021, MKT-002) `backend` `database` `migration`
- [ ] [MKT-023] Model: Enrollment with progress tracking (M, 2-4h, blocked-by: MKT-021, MKT-022) `backend` `model` `node`
- [ ] [MKT-024] Controller: EnrollmentController (student dashboard) (M, 2-4h, blocked-by: MKT-023) `backend` `controller` `api`

### Slice 6: Reviews & Ratings
- [ ] [MKT-025] Migration: Create course_reviews table (S, 1-2h, blocked-by: MKT-001, MKT-021) `backend` `database` `migration`
- [ ] [MKT-026] Model: CourseReview with aggregation (M, 2-4h, blocked-by: MKT-025) `backend` `model` `node`
- [ ] [MKT-027] Controller: CourseReviewController (M, 2-4h, blocked-by: MKT-026) `backend` `controller` `api`

### Slice 7: Coupons & Discounts
- [ ] [MKT-028] Migration: Create coupons table (S, 1-2h, blocked-by: MKT-001) `backend` `database` `migration`
- [ ] [MKT-029] Controller: CouponController (M, 2-4h, blocked-by: MKT-028) `backend` `controller` `api`

### Slice 8: Security & Compliance
- [ ] [MKT-030] Middleware: Rate limiting per endpoint (S, 1-2h) `backend` `middleware` `security` `redis`
- [ ] [MKT-031] Service: Tax collection (Stripe Tax integration) (M, 2-4h, blocked-by: MKT-013) `backend` `service` `stripe` `tax`
- [ ] [MKT-032] Migration: Add audit logs for transactions (S, 1-2h, blocked-by: MKT-011) `backend` `database` `migration` `audit`
- [ ] [MKT-033] Service: Video encryption and signed URLs (S, 1-2h, blocked-by: MKT-005) `backend` `service` `security` `s3`
- [ ] [MKT-034] Configuration: Stripe webhook signature verification (XS, 0.5-1h, blocked-by: MKT-013) `backend` `middleware` `security` `stripe`
- [ ] [MKT-035] Test: End-to-end marketplace flow (L, 4-6h, blocked-by: MKT-014, MKT-024, MKT-027) `backend` `test` `integration` `e2e`

**Total Tasks**: 35
**Critical Path**: ~42-68 hours
**Parallel Execution**: Can be reduced to ~30-45 hours with 2-3 developers
```

---

## Suggested Next Steps

**Skill Recommendations:**

1. **Frontend Task Breakdown**: Run `/jaan-to-dev-fe-task-breakdown` using this PRD to generate React/Next.js component tasks for the marketplace UI.

2. **GTM Tracking**: Run `/jaan-to-data-gtm-datalayer` to generate Google Tag Manager dataLayer events for purchase funnel analytics.

3. **Microcopy**: Run `/jaan-to-ux-microcopy-write` for user-facing messages (checkout flow, error states, confirmation emails).

**Implementation Priority:**

Start with **Slice 1 (Course Management) + Slice 3 (Purchase & Payment)** to establish core marketplace functionality, then proceed with Slice 4 (Payouts) as highest-value feature for instructor retention.

---

*Generated by `/jaan-to-dev-be-task-breakdown` v3.10.0 | Output follows jaan.to ID-based structure and conventions*
