# Lessons: jaan-to-pm-story-write

> Last updated: 2026-02-02

Accumulated lessons from past executions. Read this before generating stories to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions that should be asked during information gathering:

- Ask for specific persona context: "What makes this user unique?" (avoid generic "user")
- Apply 5 Whys to get genuine value: Keep asking "why" until you hit business value, not just feature restatement
- Ask about Jira epic/project context early for consistency with team conventions
- Check if related stories exist to maintain naming and format consistency
- Clarify which of the 10 edge case categories apply to avoid missing critical scenarios
- Ask about Definition of Ready requirements for the team (may vary by organization)
- For SaaS features: Ask about multi-tenant isolation requirements early
- For API features: Ask about versioning strategy (v1, v2) and backward compatibility
- For user-facing features: Ask about accessibility considerations (WCAG level)
- For data features: Ask about GDPR/privacy requirements and data retention policies
- Ask "Who else needs to approve this story?" to identify stakeholders early

## Edge Cases

Special cases to check and handle:

### The 10 Core Categories (Research Section 6):

1. **Empty States** - First use, no data, zero results (often forgotten in happy path focus)
   - Examples: New user with no history, search with zero results, empty cart
2. **Boundary Conditions** - Max/min values, character limits, date ranges
   - Examples: 255-char limit, max file size, past/future date validation
3. **Permission Failures** - Multi-role systems need authorization scenarios
   - Examples: Standard user accessing admin feature, expired subscription tier
4. **Concurrency** - Inventory, booking, editing scenarios need simultaneous user handling
   - Examples: Two users booking last item, simultaneous edits to same record
5. **Network Failures** - Any API call needs timeout/offline handling
   - Examples: Request timeout, 503 service unavailable, intermittent connectivity
6. **Invalid Input** - Forms and APIs need validation error scenarios
   - Examples: SQL injection attempts, XSS patterns, malformed JSON
7. **State Transitions** - Multi-step flows need "back button" and "session expiry" handling
   - Examples: Browser back during checkout, session timeout mid-workflow
8. **Internationalization** - Date formats, currency, RTL languages if multi-region
   - Examples: DD/MM vs MM/DD, currency symbols, Arabic RTL layout
9. **Timeout/Expiry** - Long operations, session management, token refresh
   - Examples: Password reset link expiry, upload timeout, JWT token refresh
10. **Bulk Operations** - Pagination, performance scenarios if batch processing
    - Examples: Upload 10,000 records, delete all items, export large dataset

### Domain-Specific Patterns:

- **SaaS/Multi-tenant**: Tenant isolation, cross-tenant data leakage prevention, tenant-scoped queries
- **E-commerce**: Payment failures (declined card, insufficient funds), abandoned cart recovery, inventory conflicts
- **Fintech**: Compliance requirements (KYC, AML), audit trails, regulatory reporting, PCI-DSS for payments
- **Mobile**: Offline mode with sync, background state handling, push notification permissions

### Detection Rules:

- **CRUD operations** → Always check: Empty States, Invalid Input, Concurrency, Boundary Conditions
- **API integration** → Always check: Network Failures, Timeout/Expiry, Invalid Input
- **Multi-step workflow** → Always check: State Transitions, Timeout/Expiry, Empty States
- **Forms with input** → Always check: Invalid Input, Boundary Conditions, Empty States
- **Multi-user features** → Always check: Permission Failures, Concurrency

## Workflow

Process improvements learned from best practices:

- Parse Jira context FIRST if provided (saves asking redundant questions and ensures consistency)
- Map to edge case categories BEFORE generating ACs (ensures comprehensive coverage, prevents omissions)
- Validate INVEST BEFORE preview (saves revision cycles, catches issues early)
- Provide splitting suggestions if >7 scenarios (prevents oversized stories that span sprints)
- Include export formats (Jira CSV, Linear JSON) with output for easy import
- Reference research doc (45-pm-insights-synthesis.md) for pattern examples when uncertain
- Use table format for dependencies (clearer than bullet list, shows status and owners)
- Generate stories in batch when possible during sprint planning (efficiency for team)
- Always provide context paragraph explaining WHY (prevents tribal knowledge, aids future developers)
- Link out-of-scope items to future stories with references (maintains backlog hygiene)
- For complex features, suggest spike story first to reduce uncertainty
- Present full story plan at HARD STOP (prevents misunderstandings before generation)
- Quantify performance criteria when mentioning speed (not "fast", use "<2 seconds at p95")

## Common Mistakes

Things to avoid based on research findings:

### Format Mistakes:
- Don't use generic "As a user" - always get specific persona with context
- Don't accept feature-focused "so that" - dig for business value with 5 Whys technique
- Don't put implementation details in ACs - keep negotiable (describe WHAT not HOW)
- Don't skip Out-of-Scope section - this prevents scope creep and documents decisions
- Don't mix non-functional requirements - split performance/security into separate stories

### Size Mistakes:
- Don't generate >7 scenarios without suggesting split - story is too large for sprint
- Don't estimate >8 points without questioning if it fits in sprint timeframe
- Don't assume story is small just because it "sounds simple" - check complexity
- Don't split too early - sometimes 6-7 ACs is appropriate for coherent user value

### Gherkin Mistakes:
- Don't make Given a user action - it's precondition state (past tense)
- Don't make Then assertions non-observable - must be testable by QA
- Don't use subjective criteria - "good UX" is not testable, use "completes in ≤3 steps"
- Don't skip And clauses when multiple outcomes expected (each outcome needs assertion)
- Don't make scenarios technology-specific - avoid "Redux updates store" (implementation detail)

### Coverage Mistakes:
- Don't skip empty state handling - one of most common production bugs
- Don't forget error messages in error scenarios - users need feedback
- Don't assume single-tenant - ask about multi-tenant isolation if SaaS domain
- Don't skip permission checks for multi-role features - security requirement
- Don't assume perfect network - add timeout/offline scenarios for API calls
- Don't forget accessibility - WCAG compliance may be required

### Value Mistakes:
- Don't confuse output with outcome - "generate report" (output) vs "make informed decisions" (outcome)
- Don't write technical stories without user value - "refactor service layer" needs business justification
- Don't forget to validate genuine value - ask "would user pay for this?" or "would they choose our product for this?"
