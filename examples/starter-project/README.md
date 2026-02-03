# jaan.to Starter Project

Pre-configured example project demonstrating the jaan.to plugin in action. Use this to evaluate the plugin or as a template for your own projects.

---

## What's Included

This directory contains a **realistic SaaS product example** with:

### ✅ Pre-Configured Context
- **Tech Stack:** Python/FastAPI backend, React/Next.js frontend, PostgreSQL database
- **Team Structure:** Small startup (5 engineers, 1 PM, 1 designer)
- **Integrations:** Stripe payments, SendGrid email, Google Analytics

### 📄 Sample Outputs
Demonstration outputs from each major skill:
- **PRD:** User authentication feature (OAuth + JWT)
- **User Stories:** Login, signup, password reset flows
- **GTM Tracking:** Authentication event tracking code
- **Frontend Tasks:** Component breakdown with estimates
- **Test Cases:** BDD scenarios for auth flows

### 🎯 Try These Commands
Step-by-step commands you can run to see skills in action.

---

## Quick Start

### 1. Install jaan.to Plugin

```bash
# From marketplace
claude
/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to

# Or local development
claude --plugin-dir /path/to/jaan-to
```

### 2. Copy This Example to Your Test Project

```bash
# Create a test directory
mkdir -p ~/test-jaan-to
cd ~/test-jaan-to

# Copy context files
cp -r /path/to/jaan-to/examples/starter-project/jaan-to .
```

### 3. Open Claude Code in Test Directory

```bash
cd ~/test-jaan-to
claude
```

---

## Try These Commands

### Example 1: Generate a PRD

```
/jaan-to-pm-prd-write "Add social login with Google and GitHub OAuth"
```

**What happens:**
1. Skill reads your tech stack from `jaan-to/context/tech.md`
2. Generates PRD matching your stack (Python backend, React frontend)
3. Includes sections: Problem Statement, Success Metrics, User Stories, Technical Approach
4. Saves to `jaan-to/outputs/pm/prd/02-social-login/02-prd-social-login.md`

**Expected output:** 6-8 page PRD with OAuth provider integration details

---

### Example 2: Break Down Frontend Tasks

```
/jaan-to-dev-fe-task-breakdown from prd at jaan-to/outputs/pm/prd/01-user-auth/
```

**What happens:**
1. Reads PRD from specified path
2. Analyzes user flows and generates component inventory
3. Creates task breakdown with estimates
4. References your React conventions from `tech.md`
5. Saves to `jaan-to/outputs/dev/frontend/01-user-auth-tasks/`

**Expected output:** 15-20 tasks organized by component, with story point estimates

---

### Example 3: Generate GTM Tracking Code

```
/jaan-to-data-gtm-datalayer "Track signup funnel: form view, email entry, password entry, submit success/error"
```

**What happens:**
1. Generates dataLayer.push() code for each event
2. Creates click tracking and impression tracking
3. Uses your GTM container ID from `integrations.md`
4. Saves to `jaan-to/outputs/data/gtm/01-signup-funnel/`

**Expected output:** Copy-paste ready JavaScript + implementation guide

---

### Example 4: Create User Stories from PRD

```
/jaan-to-pm-story-write from prd at jaan-to/outputs/pm/prd/01-user-auth/
```

**What happens:**
1. Reads PRD and extracts user flows
2. Generates stories with Given/When/Then acceptance criteria
3. Follows INVEST principles (Independent, Negotiable, Valuable, Estimable, Small, Testable)
4. Saves to `jaan-to/outputs/pm/stories/01-user-auth/`

**Expected output:** 8-12 user stories with acceptance criteria

---

### Example 5: Generate QA Test Cases

```
/jaan-to-qa-test-cases from prd at jaan-to/outputs/pm/prd/01-user-auth/
```

**What happens:**
1. Reads acceptance criteria from PRD
2. Generates BDD scenarios (Given/When/Then)
3. Includes happy path + edge cases + error scenarios
4. Saves to `jaan-to/outputs/qa/01-user-auth/`

**Expected output:** 20-30 test scenarios in Gherkin format

---

## Customizing for Your Project

### Edit Context Files

```bash
# Tech stack
vim jaan-to/context/tech.md

# Team structure and processes
vim jaan-to/context/team.md

# Third-party integrations
vim jaan-to/context/integrations.md
```

### Auto-Detect Your Stack

If you have an existing codebase:

```
/jaan-to-dev-stack-detect
```

This scans your project files and auto-populates `tech.md` with detected languages, frameworks, and patterns.

---

## What to Try Next

### End-to-End Product Workflow

```bash
# 1. Research
/jaan-to-pm-research-about "OAuth 2.0 best practices for SaaS"

# 2. Generate PRD
/jaan-to-pm-prd-write "User authentication with OAuth"

# 3. Create User Stories
/jaan-to-pm-story-write from prd

# 4. Break Down Frontend Tasks
/jaan-to-dev-fe-task-breakdown from prd

# 5. Break Down Backend Tasks
/jaan-to-dev-be-task-breakdown from prd

# 6. Generate Test Cases
/jaan-to-qa-test-cases from prd

# 7. Add Analytics Tracking
/jaan-to-data-gtm-datalayer "Auth flow tracking"
```

### UX Research Workflow

```bash
# 1. Analyze user behavior
/jaan-to-ux-heatmap-analyze "homepage-heatmap.csv"

# 2. Synthesize research findings
/jaan-to-ux-research-synthesize "user-interview-transcripts.md"

# 3. Generate UI copy in multiple languages
/jaan-to-ux-microcopy-write for login page
```

### Documentation Workflow

```bash
# 1. Create new docs
/to-jaan-docs-create guide "API Integration Tutorial"

# 2. Check for stale docs
/to-jaan-docs-update --check-only

# 3. Fix stale docs automatically
/to-jaan-docs-update --fix
```

---

## Sample Outputs Explained

### `jaan-to/outputs/pm/prd/01-user-auth/`

**Purpose:** Demonstrates PRD generation for authentication feature

**Files:**
- `01-prd-user-auth.md` — Full PRD with problem statement, success metrics, technical approach

**Key Sections:**
- Problem Statement (why we need this)
- Success Metrics (how we measure success)
- User Stories (who benefits and how)
- Technical Approach (architecture, data models, APIs)
- Security Considerations (OAuth flows, token management)
- Testing Plan (unit, integration, E2E)

### `jaan-to/outputs/pm/stories/01-login-flow/`

**Purpose:** User stories broken down from PRD

**Files:**
- `01-story-login-flow.md` — Stories with Given/When/Then acceptance criteria

**Example Story:**
```
As a returning user
I want to log in with my email and password
So that I can access my account

Acceptance Criteria:
- Given I'm on the login page
  When I enter valid email and password
  Then I should be redirected to my dashboard
  And I should see a welcome message with my name
```

### `jaan-to/outputs/data/gtm/01-auth-tracking/`

**Purpose:** GTM tracking implementation for authentication

**Files:**
- `01-gtm-auth-tracking.md` — dataLayer.push() code + implementation guide

**Includes:**
- Click tracking (login button, signup CTA)
- Impression tracking (login form view)
- Success/error event tracking
- Event naming conventions (lowercase-kebab-case)

### `jaan-to/outputs/dev/frontend/01-auth-components/`

**Purpose:** Frontend task breakdown

**Files:**
- `01-frontend-tasks-auth-components.md` — Component inventory + tasks + estimates

**Breakdown:**
- Component tree (LoginForm → EmailInput → PasswordInput → SubmitButton)
- State management (form state, validation, auth flow)
- API integration (POST /auth/login, token storage)
- Error handling (network errors, validation errors, auth errors)
- Estimates in story points

---

## Learning System

As you use skills, capture lessons:

```
/to-jaan-learn-add "Always validate OAuth redirect URI against whitelist - prevents open redirect attacks"
```

Lessons accumulate in `jaan-to/learn/{skill-name}.learn.md` and improve skill execution over time.

---

## Output Directory Structure

```
jaan-to/
├── context/              # Your project context (customizable)
│   ├── tech.md
│   ├── team.md
│   └── integrations.md
├── outputs/              # Generated files
│   ├── pm/
│   │   ├── prd/
│   │   └── stories/
│   ├── data/
│   │   └── gtm/
│   ├── dev/
│   │   ├── frontend/
│   │   └── backend/
│   └── qa/
└── learn/                # Accumulated lessons
    ├── pm-prd-write.learn.md
    ├── data-gtm-datalayer.learn.md
    └── ...
```

---

## Tips for Evaluation

### Focus on Context Awareness

jaan.to skills **read your context files** before generating. Try editing `tech.md` to use different frameworks (e.g., change React → Vue) and regenerate a PRD — you'll see the output adapts.

### Two-Phase Workflow

Every skill follows a pattern:
1. **Phase 1 (Analysis):** Read context, gather requirements, plan structure
2. **HARD STOP:** Confirm with you before writing anything
3. **Phase 2 (Generation):** Generate, validate, preview, write

**Why:** No accidental writes. You review the plan before committing.

### Quality Checks

Skills invoke the `quality-reviewer` agent automatically to:
- Check for required sections
- Validate formatting against STYLE.md
- Ensure completeness

### Continuous Improvement

The LEARN.md system creates a feedback loop:
```
Use Skill → Provide Feedback → Capture Lesson → Better Skill
```

Over time, skills learn from mistakes and edge cases.

---

## Next Steps

1. **Try the commands above** in this example project
2. **Customize context files** to match your real project
3. **Run `/jaan-to-dev-stack-detect`** if you have an existing codebase
4. **Start capturing lessons** with `/to-jaan-learn-add`
5. **Read full documentation** at [docs/README.md](../../docs/README.md)

---

**Questions?**
- [Documentation](../../docs/README.md)
- [Skills Reference](../../docs/skills/README.md)
- [Creating Skills](../../docs/extending/create-skill.md)
- [GitHub Issues](https://github.com/parhumm/jaan-to/issues)

---

*Give soul to your workflow.*
