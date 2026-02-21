# Git & PR Workflow Reference

> Shared git branching, commit, and PR creation patterns for skill workflows.
> Referenced by: `skill-create`, `skill-update`

---

## skill-update: Git & PR Workflow

> Used by Phase 0 (branch setup), Step 13 (commit), Step 14 (user testing), and Step 15 (PR creation).

### Phase 0: Git Branch Setup

Create feature branch for updates:

```bash
git checkout dev
git pull origin dev
git checkout -b update/{skill-name}
```

Confirm: "Created branch `update/{name}` from `dev`. All updates on this branch."

### Step 13: Commit to Branch

```bash
git add skills/{name}/ jaan-to/ docs/skills/{role}/{name}.md
git commit -m "fix(skill): Update {name} skill

- {change_summary}
- Specification compliance: ✓

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 14: User Testing

> "Please test the updated skill in a new session. Here's a copy-paste ready example:"
>
> ```
> /{name} "{example_input_based_on_skill_purpose}"
> ```
>
> For example, if updating `docs-create`:
> ```
> /jaan-to:docs-create skill "my-new-feature"
> ```
>
> "Did it work correctly? [y/n]"

If issues:
1. Help debug the problem
2. Make fixes
3. Commit fixes
4. Repeat testing

### Step 15: Create Pull Request

When user confirms working:
> "Create pull request to merge to dev? [y/n]"

If yes:
```bash
git push -u origin update/{name}
gh pr create --base dev --title "fix(skill): Update {name} skill" --body "$(cat <<'EOF'
## Summary

Updated `{name}` skill with:
{change_list}

## Changes Made

{detailed_changes}

## Specification Compliance

✅ All checks pass after update

## Testing

✅ User confirmed skill works correctly

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Show PR URL to user.

If no:
> "Branch `update/{name}` is ready. Merge manually when ready."

---

## skill-create: Commit to Branch

After all skill files are written and validated:

```bash
git add skills/{name}/ jaan-to/ docs/skills/{role}/{name}.md
git commit -m "feat(skill): Add {name} skill

- {description}
- Research-informed: {source_count} sources consulted
- Auto-generated with /jaan-to:skill-create

Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## skill-create: Create Pull Request

When user confirms the skill is working:
> "Create pull request to merge to dev? [y/n]"

If yes:
```bash
git push -u origin skill/{name}
gh pr create --base dev --title "feat(skill): Add {name} skill" --body "$(cat <<'EOF'
## Summary

- **Skill**: `{name}`
- **Command**: `/{name}`
- **Purpose**: {description}

## Research Used

Consulted {source_count} sources for best practices:
{research_summary}

## Files Created

- `skills/{name}/SKILL.md`
- `$JAAN_LEARN_DIR/{name}.learn.md`
- `$JAAN_TEMPLATES_DIR/{name}.template.md` (if applicable)
- `docs/skills/{role}/{name}.md`

## Testing

User confirmed skill works correctly

Generated with Claude Code
EOF
)"
```

Show PR URL to user.

If no:
> "Branch `skill/{name}` is ready. Merge manually when ready."
