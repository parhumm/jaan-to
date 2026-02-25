# Lesson Template

Standard format for capturing lessons learned from skill usage. Use this template when adding entries to skill-specific `.learn.md` files via `/learn-add`.

---

## Template Structure

Each lesson should follow this format:

```markdown
## [Brief Title of Lesson]

**Date:** YYYY-MM-DD
**Skill:** [skill-name]
**Severity:** [Low | Medium | High | Critical]

### Context
[Describe the situation, task, or feature being worked on]

- What were you trying to accomplish?
- What was the user's request or requirement?
- What was the project context (tech stack, constraints, etc.)?

### What Happened
[Describe what went wrong or what was learned]

- What was the actual behavior or outcome?
- What was unexpected or problematic?
- What user feedback indicated an issue?

### Root Cause
[Explain why it happened]

- What was the underlying reason?
- What was misunderstood or overlooked?
- What assumption was incorrect?

### Fix
[Describe how it was resolved]

- What specific changes were made?
- What approach worked?
- What alternative solutions were considered?

### Prevention
[How to avoid this in the future]

- What checks should be added to the skill?
- What documentation needs updating?
- What validation should be built in?
- What questions should the skill ask upfront?

---

### Common Mistakes
[Optional: If this lesson represents a common mistake pattern]

- [Specific mistake pattern to watch for]
- [Trigger scenario that leads to this mistake]

### Edge Cases
[Optional: If this lesson revealed an edge case]

- [Specific edge case scenario]
- [How to detect this edge case]
- [Recommended handling]

---

### Related Skills
[Optional: Other skills affected by this lesson]

- `skill-name` — [How this lesson applies]
```

---

## Example Lesson

```markdown
## Always Validate PRD Scope Section Before Generation

**Date:** 2026-01-15
**Skill:** pm-prd-write
**Severity:** Medium

### Context
User requested PRD for "user authentication system" but didn't specify OAuth vs traditional login. Generated PRD assumed OAuth without confirming, leading to rework.

### What Happened
PRD included OAuth-specific sections (provider integration, token management) but user actually wanted simple email/password authentication with JWT tokens. Generated 8-page PRD had to be completely rewritten.

### Root Cause
Skill didn't ask clarifying questions when user input was ambiguous. "Authentication" can mean multiple implementation approaches but skill made assumptions instead of validating scope upfront.

### Fix
1. Added validation step in Phase 1: detect ambiguous terms ("authentication", "payments", "notifications")
2. Added clarifying questions for scope:
   - "Which auth method: OAuth (Google/GitHub) or traditional (email/password)?"
   - "Token type: JWT or session-based?"
   - "MFA required: yes/no?"

### Prevention
1. **Skill Update:** Add pre-generation validation with clarifying questions
2. **Validation Hook:** PRD validation hook now checks for ambiguous scope keywords
3. **Template:** PRD template now has [SCOPE-TYPE] placeholders that must be filled
4. **Documentation:** Added "Common Scope Ambiguities" section to skill docs

---

### Common Mistakes
- Assuming "authentication" always means OAuth
- Not validating scope keywords before generation
- Generating complete PRD without user confirmation of approach

### Edge Cases
- User says "authentication" but means "SSO with corporate LDAP"
- User says "payments" but means "invoice generation" not "Stripe integration"

---

### Related Skills
- `pm-story-write` — Also affected by ambiguous scope (stories will be wrong if PRD scope was wrong)
- `frontend-task-breakdown` — Frontend tasks depend on correct auth approach from PRD
```

---

## Usage

### Manual Entry (Rare)
When manually creating a lesson in `jaan-to/learn/{skill-name}.learn.md`:

```bash
# Copy template structure and fill in
cat docs/learning/LESSON-TEMPLATE.md
# Edit jaan-to/learn/pm-prd-write.learn.md
```

### Via Command (Recommended)
Use `/learn-add` which will:
1. Prompt for key fields (Context, What Happened, Fix)
2. Auto-fill Date, Skill from current session
3. Suggest Severity based on impact
4. Append to appropriate `.learn.md` file

**Example:**
```
/learn-add "Always validate email format before API submission - user entered 'john@' without domain, API returned 500 error instead of validation error. Added regex check before API call."
```

---

## Best Practices

### When to Capture Lessons

1. **After Errors:** Any time skill output needs correction or rework
2. **After User Feedback:** When user says "this isn't quite right"
3. **After Edge Cases:** When skill handles unexpected input
4. **After Improvements:** When you identify a better approach mid-execution

### Severity Levels

- **Critical:** Skill generated incorrect/dangerous output (security, data loss)
- **High:** Skill required complete rework (wrong approach, missing requirements)
- **Medium:** Skill required significant edits (missing sections, wrong tone)
- **Low:** Skill required minor tweaks (formatting, wording, small additions)

### Writing Tips

- **Be Specific:** "PRD missing Security section" not "PRD incomplete"
- **Include Context:** Always explain what you were trying to accomplish
- **Show Fix:** Explain exactly what changed, not just "fixed it"
- **Think Prevention:** How would this be caught automatically next time?

### Organization

- **One File Per Skill:** `jaan-to/learn/{skill-name}.learn.md`
- **Chronological Order:** Newest lessons at the top
- **Cross-Reference:** Link related skills when lesson applies to multiple
- **Regular Review:** Run `/learn-report` weekly to identify gaps

---

## Integration with Skills

Skills reference `.learn.md` files during execution:

1. **Pre-Generation:** Read Common Mistakes to avoid known issues
2. **Validation:** Check Edge Cases before finalizing output
3. **Quality Review:** Compare output against Prevention guidelines
4. **Suggestions:** Prompt user with relevant lessons when applicable

---

## Continuous Improvement

The LEARN.md system creates a feedback loop:

```
Skill Execution
     ↓
User Feedback / Error
     ↓
Capture Lesson (/learn-add)
     ↓
Update Skill Logic
     ↓
Better Skill Execution
```

Over time, skills become more reliable as lessons accumulate and patterns emerge.

---

**Last Updated:** 2026-02-03
