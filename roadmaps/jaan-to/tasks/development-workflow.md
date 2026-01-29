# Development Workflow

> Phase 3.5 | Status: pending

## Description

Establish project-wide development principles and tracking mechanisms for maintaining quality and consistency across all skills. Inspired by spec-kit's constitutional governance approach.

---

## Sub-Tasks

### 3.5.1 Project Constitution

**Location:** `context/constitution.md`

Create immutable development principles (inspired by spec-kit's articles):

- [ ] Draft 9 core principles for jaan.to development
- [ ] Define governance rules (amendments require documentation)
- [ ] Create version tracking (Version | Ratified | Last Amended)
- [ ] Link from CLAUDE.md for discoverability
- [ ] Reference in skill workflows for gate checks

**Proposed Principles:**

| # | Principle | Description |
|---|-----------|-------------|
| I | **Skills-First** | Every capability starts as a skill with SKILL.md |
| II | **Two-Phase** | Always: gather context → HARD STOP → generate |
| III | **Preview-First** | Never write without showing preview and approval |
| IV | **Learn-Always** | Capture feedback in LEARN.md for improvement |
| V | **Safe-Paths** | Only write to `.jaan-to/` and approved paths |
| VI | **Human-Loop** | Humans make final decisions, AI assists |
| VII | **Minimal-Questions** | Ask only necessary questions, use context |
| VIII | **Real-Context** | Use MCP for actual data, never assume |
| IX | **Complete-Work** | Definition of Done required, no half-finished |

### 3.5.2 Complexity Tracking

**Format:** Markers in generated outputs

- [ ] Define `[NEEDS CLARIFICATION]` marker format
- [ ] Define `[COMPLEXITY]` marker with justification table
- [ ] Define `[EXCEPTION]` marker for constitution deviations
- [ ] Define `[TRADEOFF]` marker for documented compromises
- [ ] Update skill templates to include markers
- [ ] Add complexity section to plan template

**Complexity Table Format:**

```markdown
## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
```

### 3.5.3 Constitution Check Integration

- [ ] Add Constitution Check section to /dev-tech-plan template
- [ ] Implement gate validation (ERROR if violations unjustified)
- [ ] Re-check after design phase completion
- [ ] Document exceptions in Complexity Tracking section

---

## Acceptance Criteria

- [ ] `context/constitution.md` created with 9 principles
- [ ] Constitution versioned (Version: 1.0 | Ratified: {date})
- [ ] Constitution Check section in plan template
- [ ] Complexity Tracking format documented
- [ ] Marker formats (`[NEEDS CLARIFICATION]`, etc.) documented
- [ ] Skills reference constitution in gate checks
- [ ] CLAUDE.md links to constitution

---

## Definition of Done

### Functional
- [ ] Constitution document exists at `context/constitution.md`
- [ ] All 9 principles documented with descriptions
- [ ] Complexity markers documented in style guide
- [ ] /dev-tech-plan includes Constitution Check section

### Quality
- [ ] Constitution follows markdown conventions
- [ ] Principles are clear and actionable
- [ ] Markers are consistent across skills

### Integration
- [ ] CLAUDE.md references constitution
- [ ] Skills read constitution for gate checks
- [ ] Templates include complexity sections

---

## Dependencies

- Phase 3 /dev-tech-* skills (to integrate constitution checks)

## References

- [spec-kit constitution](https://github.com/github/spec-kit) - Template reference
- [boundaries/](../../context/boundaries.md) - Existing safety rules
