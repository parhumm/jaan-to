# /jaan-to-pm-prd-write

> Generate a Product Requirements Document from an initiative.

---

## What It Does

Takes your feature idea and creates a structured PRD with:
- Problem statement
- Success metrics
- Scope (in/out)
- User stories

The skill reads your tech stack and team context to generate relevant content.

---

## Usage

```
/jaan-to-pm-prd-write "user authentication feature"
```

---

## What It Asks

| Question | Why |
|----------|-----|
| What problem does this solve? | Core of PRD |
| How will you measure success? | Defines metrics |
| What's NOT included? | Sets boundaries |

The skill may ask follow-up questions based on your context.

---

## Output

**Path**: `.jaan-to/outputs/pm/spec/{slug}/prd.md`

**Example**: `.jaan-to/outputs/pm/spec/user-auth/prd.md`

**Contains**:
- Title
- Problem Statement
- Solution Overview
- Success Metrics (table)
- In Scope / Out of Scope
- User Stories
- Open Questions
- Appendix

---

## Example

**Input**:
```
/jaan-to-pm-prd-write "password reset flow"
```

**Questions asked**:
- What problem does this solve?
- "Users forget passwords and can't log in"
- How will you measure success?
- "Reduce support tickets by 30%"

**Output** (`.jaan-to/outputs/pm/spec/password-reset/prd.md`):
```
# Password Reset Flow

## Problem Statement
Users forget passwords and cannot access their accounts...

## Success Metrics
| Metric | Target |
|--------|--------|
| Support tickets | -30% |
| Reset completion rate | >80% |

## Scope
### In Scope
- Email-based reset
- Token expiration

### Out of Scope
- SMS reset
- Security questions
```

---

## Tips

- Be specific in your initiative description
- Mention constraints early (timeline, tech limits)
- Answer questions with measurable details
- Review the preview carefully before approving

---

## Learning

This skill reads from:
```
.jaan-to/learn/pm-prd-write.learn.md
```

Add feedback:
```
/to-jaan-learn-add pm-prd-write "Always ask about i18n"
```
