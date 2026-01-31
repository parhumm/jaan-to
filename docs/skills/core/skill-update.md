# /to-jaan-skill-update

> Update existing jaan.to skills with specification compliance.

---

## What It Does

Updates an existing skill while maintaining specification compliance. Validates the skill, applies targeted changes, syncs documentation, and handles git workflow including PR creation.

---

## Usage

```
/to-jaan-skill-update {skill-name}
```

If skill name not provided, lists available skills to choose from.

---

## What It Asks

| Step | Questions |
|------|-----------|
| Update Type | What to change (7 options) |
| Details | Specific changes based on selection |
| Research | Optionally search for updated best practices |
| Confirmation | Preview changes before applying |

---

## Update Options

| Option | Description |
|--------|-------------|
| [1] Questions | Add or modify Phase 1 questions |
| [2] Quality | Update Phase 2 quality checks |
| [3] Template | Modify output format |
| [4] Tools | Add tool permissions |
| [5] LEARN→SKILL | Incorporate lessons into skill |
| [6] Compliance | Fix specification issues |
| [7] Other | Custom changes |

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Specification Validation** | Checks compliance before and after |
| **Diff Preview** | Shows current vs proposed changes |
| **LEARN.md Sync** | Incorporates accumulated lessons |
| **Web Research** | Optional search for updated practices |
| **Auto-Documentation** | Invokes `/to-jaan-docs-update` automatically |
| **Git Workflow** | Creates branch, commits, offers PR creation |

---

## Workflow

```
1. Create update/{name} branch
2. Read existing skill files
3. Validate against specification
4. Ask what to change
5. Optional web research
6. Plan specific changes
7. HARD STOP - show diff preview
8. Apply updates
9. Re-validate specification compliance
10. Sync documentation
11. User testing
12. Create PR
```

---

## LEARN.md → SKILL.md Sync

When selecting option [5], lessons are incorporated:

| LEARN.md Section | Goes Into |
|------------------|-----------|
| Better Questions | Phase 1 Step 1 questions |
| Edge Cases | Phase 2 quality checks |
| Workflow | Process steps + Definition of Done |
| Common Mistakes | Warnings in relevant sections |

---

## Example

**Input**:
```
/to-jaan-skill-update pm-prd-write
```

**Interaction**:
```
CURRENT SKILL: pm-prd-write
────────────────────────────
Command: /jaan-to-pm-prd-write
Logical: pm:prd-write

SPECIFICATION COMPLIANCE
────────────────────────
✓ Frontmatter: 4/4 fields
✓ Body: 9/9 sections
✓ Safety: sandboxed

What do you want to change?
[1] Add/modify questions
[2] Update quality checks
...

→ 5 (Incorporate LEARN.md lessons)

Found 4 lessons in LEARN.md:
- Better Questions: 4 items
- Edge Cases: 4 items
- Workflow: 3 items
- Common Mistakes: 3 items

Apply these changes? [y/n]
```

---

## Tips

- Run periodically to incorporate accumulated lessons
- Use option [6] to fix specification drift
- Always test the updated skill before creating PR
- Review the diff carefully before approving
