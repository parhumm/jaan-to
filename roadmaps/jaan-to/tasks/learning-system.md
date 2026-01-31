# Learning System

> Phase 2 | Status: done

## Description

Implement a three-layer learning system where skills remember lessons from past executions. When something fails or users give feedback, it's captured and applied to future runs.

## Three Layers

### Layer 1: Skill Learning

**Location:** `skills/{name}/LEARN.md` (seed) → `.jaan-to/learn/{name}.learn.md` (project)
**What it improves:** How execution happens

Captures:
- Better questions to ask
- Edge cases to check
- Workflow improvements
- Common mistakes to avoid

Example:
```markdown
# Lessons: pm-prd-write

## Better Questions
- Always ask about internationalization requirements
- Ask "who else needs to approve this?" early

## Edge Cases
- Multi-tenant features need tenant isolation section
- API changes need versioning strategy
```

### Layer 2: Template Learning

**Location:** `.jaan-to/learn/template-{name}.learn.md`
**What it improves:** How outputs are written

Captures:
- Missing sections that users always add
- Phrasing that causes confusion
- Structure improvements

### Layer 3: Context Learning

**Location:** `.jaan-to/learn/context-{name}.learn.md`
**What it improves:** Which context matters

Captures:
- Tech constraints that always apply
- Team norms that affect output
- Integration quirks to remember

---

## Sub-Tasks

### 2.1 Context Foundation
- [x] Create `context/` directory
- [x] Create `tech.md` with template
- [x] Create `team.md` with template
- [x] Create `integrations.md` with template

### 2.2 Skill LEARN.md
- [x] Define LEARN.md file format
- [x] Create LEARN.md for pm-prd-write
- [x] Update SKILL.md to read .jaan-to/learn/{name}.learn.md
- [x] Update SKILL.md to read context

### 2.3 /to-jaan-learn-add Command
- [x] Create jaan-learn-add skill
- [x] Implement routing logic (skill/template/context)
- [x] Implement categorization logic
- [x] Test feedback capture

### 2.4 Feedback Hook
- [x] Create scripts/capture-feedback.sh hook
- [x] Add PostToolUse hook to hooks/hooks.json
- [x] Test feedback prompt after artifact creation

### 2.5 Documentation
- [x] Update context/config.md with new skill
- [x] Update CLAUDE.md with learning system docs
- [x] Update roadmap with completed tasks

---

## Acceptance Criteria

- [x] `LEARN.md` file created for `pm-prd-write` skill
- [x] Skills read `.jaan-to/learn/{name}.learn.md` before execution
- [x] Skills read context files before execution
- [x] `/to-jaan-learn-add` command to capture feedback
- [x] Learning applies to subsequent executions
- [x] PostToolUse hook prompts for feedback

---

## Definition of Done

### Functional
- [x] LEARN.md format documented and implemented
- [x] pm-prd-write reads and applies .jaan-to/learn/ lessons
- [x] Context directory exists with tech.md, team.md, integrations.md
- [x] Skills read and incorporate context
- [x] `/to-jaan-learn-add` routes feedback to correct .learn.md
- [x] `/to-jaan-learn-add` auto-categorizes lessons
- [x] PostToolUse hook prompts for feedback after artifact creation

### Quality
- [x] All files follow existing markdown conventions
- [x] Skills follow two-phase pattern with HARD STOP
- [x] Hooks follow existing shell script patterns
- [x] Documentation updated in CLAUDE.md

### Testing
- [x] E2E: Skill reads .learn.md and applies lessons
- [x] E2E: /to-jaan-learn-add routes correctly
- [x] E2E: Context incorporated into output
- [x] E2E: Feedback prompt after execution

---

## E2E Test Plan

### Test 1: Learning Application
```
Setup: Add "Always ask about API versioning" to .jaan-to/learn/pm-prd-write.learn.md
Execute: /jaan-to-pm-prd-write "new API endpoint"
Verify: Skill asks about API versioning
```

### Test 2: Feedback Routing
```
Setup: Clean .jaan-to/learn/pm-prd-write.learn.md
Execute: /to-jaan-learn-add "jaan-to-pm-prd-write" "Check for i18n requirements"
Verify: Lesson appears in .jaan-to/learn/jaan-to-pm-prd-write.learn.md under "Better Questions"
```

### Test 3: Context Integration
```
Setup: Set .jaan-to/context/tech.md to Python/FastAPI
Execute: /jaan-to-pm-prd-write "backend service"
Verify: PRD mentions Python/FastAPI context
```

### Test 4: Full Learning Cycle
```
Setup: Fresh state
Execute:
  1. Run /jaan-to-pm-prd-write "test feature"
  2. Complete PRD generation
  3. Add lesson via /to-jaan-learn-add
  4. Run /jaan-to-pm-prd-write "another feature"
Verify: Second run applies the lesson from step 3
```

---

## Implementation Notes

### LEARN.md File Format

```markdown
# Lessons: {skill-name}

> Last updated: {date}

## Better Questions
- {questions to ask early}

## Edge Cases
- {special cases to handle}

## Workflow
- {process improvements}

## Common Mistakes
- {things to avoid}
```

### Update Flow

```
BEFORE EXECUTION
├── Read .jaan-to/learn/{name}.learn.md (project-specific)
├── Read skills/{name}/LEARN.md (seed lessons, if not bootstrapped)
├── Read .jaan-to/context/tech.md (project-specific)
├── Read .jaan-to/context/team.md (project-specific)
└── Apply all lessons to current execution

AFTER EXECUTION
└── User feedback → routes to appropriate .jaan-to/learn/*.learn.md
```

### Feedback Routing

| Feedback Type | Routes To |
|---------------|-----------|
| "Ask this earlier" | .jaan-to/learn/{skill}.learn.md |
| "Missing section" | .jaan-to/learn/template-{name}.learn.md |
| "Didn't know about X" | .jaan-to/learn/context-{name}.learn.md |

### Auto-Categorization Keywords

| Category | Keywords |
|----------|----------|
| Better Questions | ask, question, clarify, confirm |
| Edge Cases | edge, special, case, handle, check |
| Workflow | workflow, process, step, order |
| Common Mistakes | avoid, mistake, wrong, don't |

---

## Dependencies

- Phase 1.5 complete (done)
- Context directory created (done)
- Bootstrap script implemented (done)

## References

- [vision-jaan-to.md](../vision-jaan-to.md) - Learning System section
