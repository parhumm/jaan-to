# Learning System

> Phase 2 | Status: done

## Description

Implement a three-layer learning system where skills remember lessons from past executions. When something fails or users give feedback, it's captured and applied to future runs.

## Three Layers

### Layer 1: Skill Learning

**Location:** `LEARN.md` alongside each skill
**What it improves:** How execution happens

Captures:
- Better questions to ask
- Edge cases to check
- Workflow improvements
- Common mistakes to avoid

Example:
```markdown
# Lessons: pm:prd-write

## Better Questions
- Always ask about internationalization requirements
- Ask "who else needs to approve this?" early

## Edge Cases
- Multi-tenant features need tenant isolation section
- API changes need versioning strategy
```

### Layer 2: Template Learning

**Location:** `templates/LEARN.md`
**What it improves:** How outputs are written

Captures:
- Missing sections that users always add
- Phrasing that causes confusion
- Structure improvements

### Layer 3: Stack Learning

**Location:** `context/LEARN.md`
**What it improves:** Which context matters

Captures:
- Tech constraints that always apply
- Team norms that affect output
- Integration quirks to remember

---

## Sub-Tasks

### 2.1 Stacks Foundation
- [ ] Create `context/` directory
- [ ] Create `tech.md` with template
- [ ] Create `team.md` with template
- [ ] Create `integrations.md` with template

### 2.2 Skill LEARN.md
- [ ] Define LEARN.md file format
- [ ] Create LEARN.md for pm-prd-write
- [ ] Update SKILL.md to read LEARN.md
- [ ] Update SKILL.md to read context

### 2.3 /jaan-to:learn-add Command
- [ ] Create learn-add skill
- [ ] Implement routing logic (skill/template/stack)
- [ ] Implement categorization logic
- [ ] Test feedback capture

### 2.4 Feedback Hook
- [ ] Create capture-feedback.sh hook
- [ ] Add PostToolUse hook to hooks/hooks.json
- [ ] Test feedback prompt after artifact creation

### 2.5 Documentation
- [ ] Update config.md with new skill
- [ ] Update CLAUDE.md with learning system docs
- [ ] Update roadmap with completed tasks

---

## Acceptance Criteria

- [ ] `LEARN.md` file created for `pm-prd-write` skill
- [ ] Skills read LEARN.md before execution
- [ ] Skills read context context before execution
- [ ] `/jaan-to:learn-add` command to capture feedback
- [ ] Learning applies to subsequent executions
- [ ] PostToolUse hook prompts for feedback

---

## Definition of Done

### Functional
- [ ] LEARN.md format documented and implemented
- [ ] pm-prd-write reads and applies LEARN.md lessons
- [ ] Stacks directory exists with tech.md, team.md, integrations.md
- [ ] Skills read and incorporate stack context
- [ ] `/jaan-to:learn-add` routes feedback to correct LEARN.md
- [ ] `/jaan-to:learn-add` auto-categorizes lessons
- [ ] PostToolUse hook prompts for feedback after artifact creation

### Quality
- [ ] All files follow existing markdown conventions
- [ ] Skills follow two-phase pattern with HARD STOP
- [ ] Hooks follow existing shell script patterns
- [ ] Documentation updated in CLAUDE.md

### Testing
- [ ] E2E: Skill reads LEARN.md and applies lessons
- [ ] E2E: /learn:add routes correctly
- [ ] E2E: Stacks incorporated into output
- [ ] E2E: Feedback prompt after execution

---

## E2E Test Plan

### Test 1: Learning Application
```
Setup: Add "Always ask about API versioning" to LEARN.md
Execute: /jaan-to:pm-prd-write "new API endpoint"
Verify: Skill asks about API versioning
```

### Test 2: Feedback Routing
```
Setup: Clean LEARN.md
Execute: /jaan-to:learn-add "pm-prd-write" "Check for i18n requirements"
Verify: Lesson appears in LEARN.md under "Better Questions"
```

### Test 3: Stack Context
```
Setup: Set tech.md to Python/FastAPI
Execute: /jaan-to:pm-prd-write "backend service"
Verify: PRD mentions Python/FastAPI context
```

### Test 4: Full Learning Cycle
```
Setup: Fresh state
Execute:
  1. Run /jaan-to:pm-prd-write "test feature"
  2. Complete PRD generation
  3. Add lesson via /jaan-to:learn-add
  4. Run /jaan-to:pm-prd-write "another feature"
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
├── Read .jaan-to/learn/{name}.learn.md
├── Read skills/{name}/LEARN.md (if exists)
├── Read context/tech.md (if exists)
├── Read context/team.md (if exists)
└── Apply all lessons to current execution

AFTER EXECUTION
└── User feedback → routes to appropriate LEARN.md
```

### Feedback Routing

| Feedback Type | Routes To |
|---------------|-----------|
| "Ask this earlier" | Skill learning |
| "Missing section" | Template learning |
| "Didn't know about X" | Stack learning |

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
- Stacks directory created (this task)

## References

- [vision-jaan-to.md](../vision-jaan-to.md) - Learning System section
