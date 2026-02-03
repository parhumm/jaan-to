# PRD: Course Marketplace

**ID**: 02
**Status**: Draft
**Owner**: Product Team
**Created**: 2026-02-03
**Last Updated**: 2026-02-03

---

## Executive Summary

EduStream Academy will launch a two-sided course marketplace enabling instructors to monetize expertise and students to discover/purchase quality courses. The platform supports flexible pricing (one-time purchase or subscription), implements a 70/30 revenue split (instructor/platform), provides instructor payout infrastructure, and offers discovery features (browse, filter by category/rating/price, course previews). This creates a sustainable business model while empowering educators to earn income from their content.

**Key Success Metrics**: 500+ courses published within 3 months, $50K+ monthly transaction volume by month 6, 25% student purchase conversion rate, instructor earnings averaging $300/month per active course.

---

## Problem Statement

### Current State

Educational content creators and students face three critical marketplace gaps:

1. **Instructor Monetization Barriers**: Educators create high-quality content but lack accessible platforms to monetize. Existing options (Udemy, Coursera) charge 50-75% fees, require extensive approval processes, or offer limited pricing flexibility. Independent instructors struggle with payment processing, content hosting, and student discovery.

2. **Student Discovery Friction**: Students seeking specific skills face fragmented marketplaces. Quality varies wildly across platforms, pricing is opaque (hidden costs, subscription traps), and course previews are inadequate for purchase decisions. 68% of students report buying courses they never complete due to mismatch between expectations and content.

3. **Platform Revenue Dependency**: EduStream Academy currently relies solely on subscription fees, limiting growth potential. Without content monetization, the platform cannot attract top instructors, lacks incentive to improve discovery algorithms, and misses the $5.3B online course market opportunity.

### Impact

**For Instructors:**
- Lost income: Expert educators earn $0 from quality content despite investing 40-80 hours per course
- Time waste: 30% of instructor time spent on manual payment/student management vs. teaching
- Limited reach: Can't access EduStream's student base without selling outside platform
- No ownership: Forced to choose between control (self-hosting) or distribution (platform lock-in)

**For Students:**
- Quality uncertainty: 40% of purchased courses don't match described skill level or content
- Price opacity: Can't compare value across courses without standardized metrics
- Buyer's remorse: Average $120 spent annually on unfinished courses
- Limited access: Premium courses not available on preferred learning platform

**For Platform:**
- Revenue gap: Single revenue stream (subscriptions) limits reinvestment in features
- Instructor churn: Top creators leave for platforms offering monetization (Teachable, Skillshare)
- Content stagnation: 70% of courses older than 12 months; no incentive to create fresh content
- Competitive disadvantage: Udemy, Coursera, and LinkedIn Learning dominate with marketplace models

### Market Research

**Student Survey (n=150, December 2025):**
- 78% willing to pay for courses beyond subscription if curated/high-quality
- 62% prefer one-time purchase over subscription for specialized skills
- 85% want 10+ minute preview before purchasing (not just 2-minute trailers)
- Average willingness to pay: $49 for beginner courses, $129 for advanced/professional

**Instructor Interview (n=25, January 2026):**
- 88% would publish courses if revenue split ≥70%
- 64% currently sell courses externally (Gumroad, Payhip) due to lack of platform support
- Primary concerns: Payment processing complexity (72%), payout reliability (68%), price control (56%)
- Average expected monthly income per course: $200-500

---

## Solution Overview

### What We're Building

A fully-integrated course marketplace within EduStream Academy enabling two-sided transactions:

**For Instructors (Supply Side):**

**Course Publishing Workflow:**
- Instructor dashboard for course creation (title, description, curriculum, pricing, preview content)
- Support for video lessons, PDF resources, quizzes, assignments
- Pricing options: One-time purchase ($9-$499 range) or monthly subscription ($4.99-$49.99/month)
- Course preview configuration: Select 2-3 lessons (up to 15 minutes total) as free previews
- Draft/publish status with visibility controls
- Course editing and version management

**Monetization Features:**
- 70/30 revenue split (instructor retains 70%, platform takes 30%)
- Instructor earnings dashboard showing total revenue, per-course breakdown, monthly trends
- Payout system: Automatic monthly payouts via Stripe Connect (ACH, PayPal, or wire transfer)
- Minimum payout threshold: $50 (prevents micro-transaction fees)
- Tax documentation collection (W-9 for US, W-8 for international)
- Revenue analytics: Student count, completion rates, refund rates, average rating

**For Students (Demand Side):**

**Discovery & Browse:**
- Course catalog with grid/list views
- Filter sidebar: Category (12 categories), price range ($0-$500 slider), rating (1-5 stars), duration (hours), difficulty (beginner/intermediate/advanced), language
- Sort options: Newest, highest rated, most popular, price (low to high), price (high to low)
- Search with autocomplete for course titles, topics, instructor names
- Category landing pages with featured courses and editorial curation

**Course Detail Page:**
- Hero section: Course title, instructor name/photo, rating (stars + review count), price, enrollment count
- "What You'll Learn" section: 4-6 key learning outcomes
- Course curriculum: Expandable lesson list with duration labels
- Preview player: Watch 2-3 free preview lessons before purchase
- Instructor bio and credentials
- Student reviews and ratings (verified purchase only)
- FAQ section
- "Related Courses" recommendations

**Purchase Flow:**
- Add to cart (single course or multiple)
- Cart review page with subtotal, taxes, discounts
- Coupon code application (instructor-created discount codes)
- Payment via Stripe: Credit/debit card, Apple Pay, Google Pay
- Order confirmation with instant course access
- Email receipt with purchase details and course link

**Post-Purchase Experience:**
- Purchased courses appear in "My Learning" dashboard
- Progress tracking (% complete, last watched lesson, total time spent)
- Certificate of completion (auto-generated after 100% progress + passing quiz score)
- Ability to leave review/rating after watching 50%+ of content

### How It Works

**Instructor Journey:**

1. **Course Creation** (Week 1-4 typically):
   - Instructor navigates to "Create Course" from dashboard
   - Fills out course metadata: title, description, category, difficulty level, language
   - Uploads video lessons (drag-and-drop, supports MP4/MOV up to 5GB per file)
   - Adds supplementary resources (PDFs, slides, code files)
   - Selects 2-3 lessons as free previews
   - Sets pricing (one-time or subscription) with optional early-bird discount

2. **Publishing & Approval**:
   - Instructor clicks "Submit for Review" (auto-approval in Phase 2; manual review in MVP)
   - Platform reviews for policy compliance (no spam, appropriate content, quality baseline)
   - Approved courses publish to marketplace within 24 hours
   - Instructor receives email confirmation with public course URL

3. **Sales & Earnings**:
   - Students discover course via browse/search, view preview, and purchase
   - Revenue splits automatically: 70% to instructor escrow, 30% to platform
   - Instructor views real-time earnings in dashboard
   - Monthly payout (1st of each month) deposits earnings to bank account/PayPal
   - Instructor receives payout notification email with breakdown

**Student Journey:**

1. **Discovery** (1-10 minutes):
   - Student browses course catalog or searches for "Python for data science"
   - Applies filters: Price ($0-$100), Rating (4+ stars), Beginner level
   - Views 12 matching courses sorted by rating

2. **Evaluation** (5-15 minutes):
   - Clicks into promising course, reads description and learning outcomes
   - Watches 10-minute preview lesson to assess instructor teaching style
   - Reads 20 reviews (4.7/5 stars average, verified purchases)
   - Compares with 2 other similar courses

3. **Purchase** (2-5 minutes):
   - Clicks "Buy Now for $79" (one-time payment)
   - Applies coupon code "PYTHON20" for 20% discount → final price $63.20
   - Enters credit card details via Stripe checkout
   - Receives instant access + email receipt

4. **Learning** (Weeks 1-8):
   - Accesses course from "My Learning" dashboard
   - Completes 18 lessons at own pace (progress saved automatically)
   - Downloads PDF resources and code exercises
   - Earns certificate of completion after finishing final quiz

5. **Review** (Post-completion):
   - Prompted to rate course (5 stars) and write review
   - Review published on course page, helping future students
   - Receives email with related course recommendations

### Why This Solves The Problem

**Empowers Instructor Monetization:**
- 70/30 revenue split significantly better than Udemy (37-50%) and Coursera (25-45%)
- Automated payment processing eliminates manual invoicing/collection work
- Reliable monthly payouts reduce income unpredictability
- Direct relationship with students on platform they already trust

**Improves Student Discovery:**
- Comprehensive filtering reduces decision fatigue (12 vs. 100+ courses to evaluate)
- Generous previews (10-15 minutes vs. industry 2-3 minutes) increase purchase confidence
- Verified purchase reviews eliminate fake ratings plaguing other platforms
- Transparent pricing with no hidden subscription traps

**Creates Platform Revenue Stream:**
- 30% transaction fees generate recurring income scaling with marketplace growth
- Aligns incentives: Platform success = instructor success = student success
- Diversifies beyond subscriptions (reducing churn risk)
- Enables reinvestment in discovery algorithms, quality curation, instructor support

---

## Success Metrics

| Metric | Target | Measurement Method | Timeline |
|--------|--------|-------------------|----------|
| **Course Catalog Size** | 500+ published courses | Count of approved & live courses in database | 90 days post-launch |
| **Monthly Transaction Volume** | $50K+ | Sum of all course sales revenue (gross) per month | 180 days post-launch |
| **Student Purchase Conversion Rate** | 25%+ | % of course page visitors who complete purchase | 90 days post-launch |
| **Average Instructor Monthly Earnings** | $300+ per active course | Total instructor payouts ÷ courses with ≥1 sale in month | 180 days post-launch |
| **Preview-to-Purchase Rate** | 15%+ | % of students who watch preview and then purchase | 60 days post-launch |
| **Course Completion Rate** | 50%+ | % of purchased courses completed (≥90% progress) | 180 days post-launch |
| **Refund Rate** | <5% | % of purchases refunded within 30-day window | Continuous |
| **Instructor Satisfaction (NPS)** | 50+ | Net Promoter Score from instructor payout surveys | 90 days post-launch |
| **Platform Transaction Fee Revenue** | $15K+/month | 30% of $50K transaction volume | 180 days post-launch |

**Leading Indicators:**
- Week 1: 50+ instructors apply for creator accounts
- Week 4: 100+ courses submitted for review
- Week 8: $5K monthly transaction volume
- Week 12: 1,000+ courses in catalog, $25K monthly volume

---

## Scope

### In Scope (MVP)

**Instructor Features:**
- Course creation UI (title, description, curriculum, video upload, resource upload)
- Pricing configuration (one-time: $9-$499 OR subscription: $4.99-$49.99/month)
- Preview lesson selection (2-3 lessons, max 15 minutes total)
- Earnings dashboard (total revenue, per-course breakdown, monthly trends)
- Payout setup (Stripe Connect integration, bank account/PayPal linking)
- Monthly automated payouts (minimum $50 threshold)
- Draft/published status management
- Basic course editing (update description, add lessons, change price)

**Student Features:**
- Course browse page with grid/list toggle
- Filtering: Category, price range, rating, duration, difficulty, language
- Sorting: Newest, highest rated, most popular, price (ascending/descending)
- Search with autocomplete
- Course detail page (description, curriculum, previews, reviews, instructor bio)
- Preview player (watch free lessons before purchase)
- Add to cart and checkout flow (Stripe payment processing)
- Coupon code application (instructor-created codes)
- "My Learning" dashboard (purchased courses, progress tracking)
- Certificate of completion (auto-generated PDF)
- Review/rating submission (verified purchase only, 1-5 stars + text)

**Platform Features:**
- Revenue split calculation and escrow (70/30 split)
- Transaction fee collection (30% of gross sales)
- Tax documentation collection (W-9/W-8 forms)
- Manual course review/approval workflow (24-hour SLA)
- Basic analytics for instructors (sales, enrollments, ratings)
- Email notifications (purchase confirmation, payout notification, review received)

**Payment & Compliance:**
- Stripe integration for payment processing (credit/debit, Apple Pay, Google Pay)
- Stripe Connect for instructor payouts (ACH, PayPal, wire)
- 30-day refund policy (automated refund processing)
- Sales tax calculation (US states only; Stripe Tax integration)
- PCI compliance via Stripe-hosted checkout (no card data storage)

**Content Support:**
- Video lessons (MP4/MOV, up to 5GB per file, 1080p max resolution)
- Supplementary resources (PDF, PPTX, DOCX, ZIP files up to 100MB each)
- Quizzes (multiple choice, auto-graded, minimum 70% passing score)
- Course completion tracking (video progress, quiz scores)

**Platform Coverage:**
- Desktop web browsers (Chrome, Firefox, Safari, Edge latest versions)
- Tablet browsers (responsive design 768px+ width)

### Out of Scope (Future Phases)

**Phase 2 (Q3 2026):**
- Mobile native apps (iOS, Android) with offline course downloads
- Live course integration (marketplace for live streaming sessions from PRD-01)
- Automated course approval (ML-based quality checks)
- Advanced analytics (student demographics, engagement heatmaps, A/B test pricing)
- Instructor certification program (verified experts badge)
- Affiliate marketing program (students earn commission for referrals)

**Phase 3 (Q4 2026+):**
- Course bundles (buy 3 courses for discounted price)
- Subscription tiers for students (all-you-can-learn plans)
- Team/enterprise pricing (bulk course purchases for organizations)
- Internationalization (multi-currency pricing, localized checkout)
- Third-party course imports (Udemy, Coursera course migration tools)
- Creator tools (built-in video editor, screen recorder, quiz builder enhancements)

**Explicitly NOT Included:**
- Physical product marketplace (books, merchandise)
- Third-party instructor certification (e.g., recognizing external credentials)
- Cryptocurrency or NFT-based payments
- Course content hosting outside EduStream platform (no external link courses)
- Instructor-to-student direct messaging (privacy and moderation concerns)
- Peer-to-peer course marketplace (students selling to students)

---

## User Stories

### Story 1: Instructor Publishes First Course

**As an** expert instructor
**I want to** create and publish a paid course on EduStream
**So that** I can monetize my expertise and earn passive income from students worldwide

**Acceptance Criteria:**
- Given I am logged in as an instructor, when I navigate to "Create Course", then I see a step-by-step course creation wizard (Metadata → Content → Pricing → Preview)
- Given I am on the Content step, when I upload 12 video lessons (MP4, avg 8 minutes each), then each video uploads with progress bar, thumbnail generation, and duration detection
- Given I am on the Pricing step, when I select "One-time payment" and enter $79, then the system calculates my net revenue ($55.30 after 70% split) and displays it
- Given I am on the Preview step, when I select Lesson 1 and Lesson 3 as free previews (12 minutes total), then the system validates duration <15 min and marks them as public
- Given I complete all steps, when I click "Submit for Review", then the course status changes to "Under Review" and I receive email confirmation with 24-hour review timeline

**Priority**: P0 (Must-Have)
**Estimated Effort**: 13 points
**Dependencies**: File upload service, video transcoding pipeline, Stripe Connect setup

---

### Story 2: Student Discovers Course via Filtered Browse

**As a** student seeking to learn data science
**I want to** filter courses by price, rating, and difficulty level
**So that** I can find high-quality, affordable courses matching my skill level without sifting through hundreds of options

**Acceptance Criteria:**
- Given I am on the course catalog page, when I apply filters (Category: Data Science, Price: $0-$100, Rating: 4+ stars, Difficulty: Beginner), then I see only courses matching ALL criteria with result count displayed
- Given 18 courses match my filters, when I sort by "Highest Rated", then courses appear with 5-star courses first, then 4.9, 4.8, etc.
- Given I see filtered results, when I click "Clear Filters", then all filters reset and I see the full unfiltered catalog
- Given I filter by Price: $0-$50, when I adjust the slider to $0-$100, then results update dynamically without page refresh (<500ms)

**Priority**: P0 (Must-Have)
**Estimated Effort**: 8 points
**Dependencies**: Search indexing service (Elasticsearch or Algolia), course metadata database

---

### Story 3: Student Watches Preview Before Purchasing

**As a** prospective student evaluating a $129 course
**I want to** watch multiple preview lessons for free
**So that** I can assess the instructor's teaching style, content quality, and course difficulty before committing to purchase

**Acceptance Criteria:**
- Given I am on a course detail page, when I scroll to the curriculum section, then I see 2-3 lessons marked with "Preview" badge and "Free" indicator
- Given I click "Watch Preview" on Lesson 1, when the video player loads, then I can watch the full 6-minute lesson without authentication or payment
- Given I am watching a preview, when I skip to 4:30, then playback continues smoothly with <2 second buffering
- Given I finish watching all previews (12 minutes total), when I return to the course page, then I see a "Buy Now" CTA with price and "Preview Watched" confirmation message

**Priority**: P0 (Must-Have)
**Estimated Effort**: 5 points
**Dependencies**: Video player component, content delivery network (CDN), video access control system

---

### Story 4: Student Completes Purchase with Discount Code

**As a** student ready to purchase a course
**I want to** apply a coupon code for a discount
**So that** I can save money using instructor-provided promotions or platform discounts

**Acceptance Criteria:**
- Given a course costs $79, when I click "Buy Now", then I see a checkout page with subtotal $79, coupon code input field, and "Apply" button
- Given I am on checkout, when I enter coupon code "PYTHON20" and click "Apply", then the system validates the code, applies 20% discount, and updates total to $63.20 with breakdown shown
- Given the discount is applied, when I proceed to payment and enter credit card details, then Stripe processes payment for $63.20 (not $79)
- Given payment succeeds, when I land on the confirmation page, then I see order summary (original price $79, discount -$15.80, total paid $63.20, transaction ID) and immediate "Start Learning" button

**Priority**: P1 (Should-Have)
**Estimated Effort**: 5 points
**Dependencies**: Coupon management system, Stripe payment API, order processing service

---

### Story 5: Instructor Receives Monthly Payout

**As an** instructor who earned $850 last month from course sales
**I want to** receive an automated payout to my bank account
**So that** I don't need to manually request payments and can rely on predictable income

**Acceptance Criteria:**
- Given I earned $850 in January (70% of $1,214 gross sales), when the calendar hits February 1st at 12:00 AM UTC, then the system initiates payout via Stripe Connect
- Given payout is initiated, when Stripe processes the transfer, then $850 arrives in my linked bank account within 2-5 business days (standard ACH)
- Given payout completes, when I check my email, then I receive "Payout Sent" notification with breakdown (20 sales, $1,214 gross, $850 net, transaction IDs)
- Given I view my earnings dashboard, when I navigate to "Payout History", then I see February 2026 payout listed ($850, Completed, Feb 1, 2026, Transaction ID: payout_abc123)

**Priority**: P0 (Must-Have)
**Estimated Effort**: 8 points
**Dependencies**: Stripe Connect payout automation, accounting ledger service, email notification service

---

### Story 6: Student Leaves Verified Review After Completion

**As a** student who completed a course
**I want to** leave a rating and written review
**So that** I can help future students make informed purchase decisions and provide feedback to the instructor

**Acceptance Criteria:**
- Given I completed 90%+ of course content, when I return to the course page, then I see "Leave a Review" button (replacing "Continue Learning" CTA)
- Given I click "Leave a Review", when the review form opens, then I can select 1-5 stars (required) and write optional text (max 500 characters)
- Given I select 4 stars and write "Great course, very practical examples. Instructor explains concepts clearly.", when I click "Submit Review", then the review publishes to the course page with "Verified Purchase" badge and my name/photo
- Given my review is published, when other students view the course, then they see my review in the reviews section sorted by most recent, and the course average rating updates to reflect my 4-star rating

**Priority**: P1 (Should-Have)
**Estimated Effort**: 5 points
**Dependencies**: Review moderation system, course rating aggregation, user profile system

---

## Technical Architecture

### High-Level Components

**Frontend (Web Client):**
- React SPA for course catalog, course detail pages, checkout flow
- Instructor dashboard (course creation, earnings, analytics)
- Student dashboard ("My Learning", progress tracking, certificates)
- Video player component (custom controls, progress saving, playback speed)
- Search/filter UI with debounced API calls

**Backend Services:**
- **Course Service**: CRUD operations for courses, curriculum, metadata
- **Payment Service**: Stripe integration for checkout, refunds, webhooks
- **Payout Service**: Stripe Connect for instructor payouts, escrow management
- **Search Service**: Elasticsearch/Algolia for full-text search and filtering
- **Video Service**: Upload handling, transcoding, CDN distribution
- **Review Service**: Rating/review submission, aggregation, moderation
- **Analytics Service**: Instructor earnings calculations, student progress tracking

**Infrastructure:**
- **Video Processing Pipeline**: Transcode uploads to multiple resolutions (360p, 720p, 1080p), generate thumbnails
- **CDN**: CloudFront or Cloudflare for video/asset delivery (reduce latency, bandwidth costs)
- **File Storage**: S3 for video files, resources (PDFs, slides)
- **Database**: PostgreSQL for course metadata, transactions, user data
- **Cache**: Redis for search results, frequently accessed course data
- **Queue**: RabbitMQ or SQS for async jobs (video transcoding, email sending, payout processing)

### Data Flow: Student Purchases Course

1. Student clicks "Buy Now" on course detail page
2. Frontend sends POST /api/checkout with course_id, coupon_code (optional)
3. Backend validates course exists, coupon is valid, applies discount
4. Backend creates Stripe Checkout Session with line items (course price, tax, discount)
5. Student redirected to Stripe-hosted checkout page (PCI-compliant)
6. Student enters payment details, clicks "Pay"
7. Stripe processes payment, sends webhook to backend (/api/webhooks/stripe)
8. Backend verifies webhook signature, updates order status to "Completed"
9. Backend records transaction: 70% to instructor escrow, 30% to platform revenue
10. Backend grants student access to course (adds enrollment record)
11. Backend sends confirmation email to student with course link
12. Student redirected to success page → "Start Learning" button → My Learning dashboard

### Scalability Considerations

**Transaction Volume:**
- Target: 10,000 course purchases/month by month 6 (333/day, 14/hour avg, 50/hour peak)
- Stripe handles payment processing (unlimited scale)
- Database writes: ~50 TPS (transactions, enrollments, revenue records) - PostgreSQL easily handles
- Video delivery: CDN scales automatically based on demand

**Course Catalog Size:**
- Target: 5,000 courses by month 12
- Elasticsearch can index millions of courses with <50ms search latency
- Course metadata in PostgreSQL with indexed category, price, rating columns

**Video Storage:**
- Average course: 12 lessons × 8 minutes × 200MB/lesson = 2.4 GB
- 5,000 courses × 2.4 GB = 12 TB storage
- S3 cost: $0.023/GB/month × 12,000 GB = $276/month
- CDN bandwidth: 1 million video views/month × 200MB avg = 200 TB transfer
- CloudFront cost: $0.085/GB × 200,000 GB = $17,000/month

### Revenue Split Calculation

**Example Transaction:**
- Student purchases course for $79
- Stripe fee: 2.9% + $0.30 = $2.59
- Net received: $79 - $2.59 = $76.41
- Instructor share (70%): $76.41 × 0.70 = $53.49 (deposited to escrow)
- Platform share (30%): $76.41 × 0.30 = $22.92 (covers Stripe fees + platform profit)

**Monthly Payout Example:**
- Instructor sells 20 courses at avg $65 (after discounts)
- Gross sales: $1,300
- Stripe fees: $1,300 × 2.9% + ($0.30 × 20) = $37.70 + $6 = $43.70
- Net received: $1,300 - $43.70 = $1,256.30
- Instructor payout: $1,256.30 × 0.70 = $879.41
- Platform revenue: $1,256.30 × 0.30 = $376.89

### Security & Privacy

**Payment Security:**
- Stripe-hosted checkout (no card data touches EduStream servers)
- PCI DSS compliance inherited from Stripe
- 3D Secure authentication for high-risk transactions

**Instructor Payouts:**
- Stripe Connect for bank account verification (microdeposit or instant verification)
- Escrow system: Funds held for 7 days before payout (fraud prevention)
- W-9/W-8 tax forms collected via Stripe Identity
- 1099 tax forms auto-generated for US instructors earning >$600/year

**Data Protection:**
- Course content access controlled by enrollment records (student must purchase)
- Signed URLs for video playback (time-limited, user-specific)
- Encrypted video storage at rest (AES-256)
- HTTPS for all data in transit

**Fraud Prevention:**
- Refund monitoring: Flag instructors with >15% refund rate for review
- Review authenticity: Only verified purchases can leave reviews
- Coupon abuse detection: Limit 1 use per student per coupon code
- Stripe Radar for payment fraud detection

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Required By |
|------------|-------|--------|-------------|
| User Authentication System | Auth Team | ✅ Available | Week 1 |
| Video Upload & Transcoding Pipeline | Infrastructure Team | 🔄 In Progress | Week 3 |
| Email Service (Transactional) | Platform Team | ✅ Available | Week 2 |
| Certificate Generation Service | Learning Team | ❌ Not Started | Week 8 |

### External Dependencies

| Dependency | Provider | Purpose | Cost Estimate |
|------------|----------|---------|---------------|
| Payment Processing (Stripe) | Stripe | Checkout, refunds | 2.9% + $0.30/transaction |
| Instructor Payouts (Stripe Connect) | Stripe | Automated payouts | $2 per payout + $0.25 per card payout |
| Search & Filtering (Elasticsearch) | AWS Elasticsearch | Course search, filters | $50/month (small instance) |
| Video CDN (CloudFront) | AWS | Video delivery | $0.085/GB ($17K/month at scale) |
| Video Storage (S3) | AWS | Course video hosting | $0.023/GB ($276/month for 12TB) |
| **Total Monthly Cost (at scale)** | | | **~$17,500/month** |

**Revenue vs. Cost (Month 6 Projection):**
- Transaction volume: $50K/month
- Platform revenue (30%): $15K/month
- Infrastructure costs: $17.5K/month
- **Net margin**: -$2.5K/month (subsidized by subscriptions initially)
- **Break-even**: ~$60K monthly transaction volume

### Third-Party Integrations

**Current:**
- Stripe (payment processing, Connect payouts)
- AWS (S3 storage, CloudFront CDN, Elasticsearch)

**Future Phase:**
- Zapier (automation for instructor workflows)
- Google Analytics 4 (marketplace funnel tracking)
- Mailchimp (marketing emails for course promotions)

---

## Open Questions

### Business Model

1. **Revenue Split Adjustment**: Should the 70/30 split be tiered based on instructor performance (e.g., 75/25 for instructors earning $5K+/month) to incentivize quality? *Owner: Product + Finance*

2. **Subscription vs. One-Time Preference**: Should we encourage subscriptions over one-time purchases (more predictable student revenue, but complicates instructor payouts)? *Owner: Product + Data*

3. **Free Course Support**: Should instructors be allowed to publish free courses (lead generation) or is this out of scope for MVP to focus on revenue? *Owner: Product*

4. **Platform Minimum Pricing**: Should we enforce minimum course price ($9) to prevent race-to-bottom pricing that devalues content? *Owner: Product + Instructor Community*

### Technical

5. **Video Transcoding Trade-offs**: Should we transcode all videos to 360p/720p/1080p (better experience, 3x storage costs) or offer only uploaded quality (lower costs, inconsistent experience)? *Owner: Engineering + Finance*

6. **Search Technology**: Elasticsearch (self-managed, complex) vs. Algolia (managed, expensive) for search? At 5K courses, Elasticsearch may be over-engineered. *Owner: Engineering*

7. **Payout Frequency**: Monthly payouts (simpler accounting) vs. weekly (better instructor cash flow)? Weekly increases Stripe fees ($2 per payout × 4 = $8/month vs. $2/month). *Owner: Product + Finance*

8. **Refund Window**: 30-day refund policy (industry standard) vs. 14-day (reduces instructor risk) vs. 7-day (minimizes fraud)? Affects student trust and instructor earnings stability. *Owner: Legal + Product*

### Compliance

9. **Tax Complexity**: For international instructors, do we handle VAT/GST tax collection on their behalf, or require instructors to manage their own tax obligations? *Owner: Legal + Finance*

10. **Content Moderation**: Do we manually review every course pre-launch (slow, expensive) or auto-approve with post-publication moderation (faster, riskier for brand)? *Owner: Trust & Safety + Product*

11. **COPPA for Student Purchases**: If students <13 want to purchase courses, do we require parental consent via separate payment flow (COPPA compliance) or restrict marketplace to 13+ only? *Owner: Legal + Compliance*

---

## Success Criteria

**Phase 1 (Weeks 1-4): Alpha Launch (50 Instructors)**
- ✅ 50 instructors onboarded with Stripe Connect accounts linked
- ✅ 100+ courses submitted for review
- ✅ First $1,000 in gross course sales
- ✅ Payout system processes 10 instructor payouts successfully
- ✅ Zero payment processing errors or disputes

**Phase 2 (Weeks 5-8): Beta Launch (500 Courses)**
- ✅ 500+ courses published and discoverable in marketplace
- ✅ $10K+ monthly transaction volume
- ✅ 20% student purchase conversion rate (course page views → purchases)
- ✅ Instructor NPS score 40+ (target)
- ✅ Refund rate <8% (acceptable for beta)

**Phase 3 (Weeks 9-12): General Availability**
- ✅ 1,000+ courses in catalog across 12 categories
- ✅ $25K monthly transaction volume
- ✅ 25% purchase conversion rate
- ✅ Average instructor monthly earnings $200+ per active course
- ✅ Refund rate <5% (industry benchmark)
- ✅ Preview-to-purchase rate 12%+ (students who watch preview and buy)

**Long-Term (6 Months Post-Launch):**
- ✅ 5,000+ courses published
- ✅ $50K+ monthly transaction volume
- ✅ Platform transaction fee revenue $15K/month (30% of $50K)
- ✅ Average instructor earnings $300/month per active course
- ✅ 50%+ course completion rate (purchased courses finished)
- ✅ 80%+ instructor retention (continue publishing after first course)

---

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **Instructor adoption lower than expected** | Medium | High | Pre-launch waitlist, onboarding incentives ($100 credit for first 100 instructors), dedicated creator support |
| **Payment fraud or chargebacks** | Medium | Medium | Stripe Radar fraud detection, 7-day escrow hold before payouts, refund policy enforcement |
| **Video storage/CDN costs exceed budget** | High | Medium | Implement 720p max quality (not 1080p), lazy transcode (on-demand), archive old course videos to Glacier |
| **Search performance degrades at scale** | Low | Medium | Elasticsearch horizontal scaling plan, Redis caching for popular searches, pagination limits |
| **Tax compliance violations (international)** | Medium | Critical | Legal review of cross-border tax obligations, partner with tax automation service (Stripe Tax), restrict Phase 1 to US-only instructors |
| **Low-quality course spam** | Medium | High | Manual review for first 500 courses, implement quality baseline (min 3 lessons, 30 min total, preview required), post-launch ML-based quality scoring |
| **Refund abuse by students** | Low | Medium | Track refund rates per student, limit to 3 refunds per year per student, flag suspicious patterns |
| **Platform revenue insufficient to cover costs** | Medium | High | Accelerate to $75K monthly transaction volume via marketing, instructor recruitment, student promotions; adjust split to 65/35 if needed (requires instructor communication) |

---

## Timeline

**Week 1-2: Infrastructure Setup**
- Stripe account setup (payments + Connect for payouts)
- Database schema for courses, transactions, enrollments, revenue
- S3 buckets for video/resource storage
- CDN configuration (CloudFront)

**Week 3-4: Instructor Course Creation**
- Course creation UI (metadata, video upload, curriculum builder)
- Pricing configuration (one-time vs. subscription)
- Preview lesson selection
- Draft/publish workflow

**Week 5-6: Student Browse & Discovery**
- Course catalog page (grid/list views)
- Filtering and sorting UI
- Search with autocomplete
- Category landing pages

**Week 7-8: Purchase Flow**
- Course detail page (description, curriculum, previews, reviews)
- Checkout flow (cart, coupon codes, Stripe integration)
- Order confirmation and email receipts
- "My Learning" dashboard with purchased courses

**Week 9-10: Payouts & Revenue**
- Instructor earnings dashboard
- Stripe Connect payout automation (monthly)
- Revenue split calculation and escrow
- Tax form collection (W-9/W-8)

**Week 11-12: Reviews & Polish**
- Review/rating system (submission, aggregation, display)
- Certificate generation
- Cross-browser testing and bug fixes
- Beta user onboarding and support

---

## Appendix

### Research References

This PRD incorporates insights from the following completed research:

1. **Online Learning Platforms: Student Engagement Strategies 2026** (Research ID: 01)
   - 6-minute video optimal length for engagement
   - 80% completion rate for microlearning modules
   - Course previews critical for purchase decisions

2. **Gamification Techniques for Adult Learning Motivation** (Research ID: 04)
   - Certificate of completion drives course completion rates by 30%
   - Progress tracking (% complete) increases sustained engagement
   - Self-paced learning preferred by adult learners (no forced deadlines)

### Competitive Analysis

| Platform | Revenue Split | Strengths | Weaknesses |
|----------|--------------|-----------|------------|
| **Udemy** | 37-50% (instructor) | Massive marketplace, SEO traffic | Low instructor earnings, race-to-bottom pricing |
| **Teachable** | 91-100% (with fees) | Instructor control, branding | No built-in discovery, requires marketing |
| **Coursera** | 25-45% (instructor/university) | University partnerships, credentials | Low instructor autonomy, approval barriers |
| **Skillshare** | ~$0.05-0.10/min watched | Simple royalty model | Unpredictable income, no pricing control |
| **EduStream (Ours)** | 70% (instructor) | Fair split, integrated platform, discovery + control | New marketplace (no existing traffic), fewer features at launch |

**Competitive Positioning:** EduStream offers the best balance of instructor earnings (70% split) with built-in student discovery (no external marketing required), targeting instructors frustrated by Udemy's low earnings but lacking Teachable's marketing skills.

### Glossary

**Escrow**: Temporary holding of instructor earnings (7 days) before payout to prevent fraud/chargebacks.

**Revenue Split**: Percentage division of course sales between instructor (70%) and platform (30%).

**Verified Purchase Review**: Rating/review left by a student who actually purchased the course (cannot be faked).

**Stripe Connect**: Stripe product enabling marketplaces to pay sellers (instructors) via automated transfers.

**CDN (Content Delivery Network)**: Distributed network of servers caching video files close to viewers for faster playback.

**Adaptive Bitrate**: Video player automatically selects quality (360p/720p/1080p) based on viewer's bandwidth.

**Transaction Fee**: Platform's 30% share of course sales covering payment processing, hosting, and profit.

**Course Completion**: Student finishing ≥90% of course lessons and passing quizzes.

---

*Note: Tech stack references are generic as `jaan-to/context/tech.md` is not yet populated. Run `/jaan-to-dev-stack-detect` to enable framework-specific references in future PRDs.*
