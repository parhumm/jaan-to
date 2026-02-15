# jaan-release - Accumulated Lessons

## Better Questions

### Clarifying Questions to Ask Users

- "Is the working tree clean? (Uncommitted changes will block release)"
- "Are you on the dev branch? (Releases prepare from dev)"
- "Have you pulled latest changes from origin/dev?"
- "Do you want to use the suggested version or specify a custom one?"
- "Should I apply the website catalog updates automatically or let you review manually?"

## Edge Cases

### Edge Cases to Watch For

1. **Dirty working tree** - Block at Phase 1 with clear message showing uncommitted files
2. **Version already exists** - Detect with `git tag -l vX.Y.Z`, suggest next version
3. **Empty [Unreleased] section** - Offer to auto-generate from commits via release-iterate-changelog
4. **CI workflow failure** - Show logs with `gh run view --log`, user fixes and re-pushes
5. **GitHub CLI not authenticated** - Detect with `gh auth status`, show login instructions
6. **Merge conflicts on PR** - Show conflict files, user resolves manually
7. **Documentation build fails** - Show npm error from website/docs build, block Phase 3
8. **Network issues during push** - Retry with exponential backoff, max 3 attempts
9. **Wrong branch** - If not on dev, offer to switch: `git checkout dev`
10. **Behind origin/dev** - If local dev is behind remote, suggest: `git pull origin dev`

## Workflow

### Best Practices

- Always run full validation (24 checks) before any writes
- Use atomic commits (4 files in 1 commit via roadmap-update release mode)
- Never push --force or skip hooks
- Stop at PR creation - let human merge for safety
- Provide clear rollback instructions at each HARD STOP gate
- Keep validation logic in scripts (single source of truth)
- Let CI run same scripts as local validation (no duplication)

### Validation Architecture

**Single Source of Truth:**
- All validation logic lives in `.claude/scripts/`
- Local skill invokes these scripts
- CI workflows invoke same scripts
- No bash code duplicated in skill or CI config

**Script Responsibilities:**
- `validate-compliance.sh` - Advisory checks 1-10 (warnings OK)
- `validate-plugin-standards.sh` - Critical checks 11-16 (must pass)
- `validate-release-readiness.sh` - Git state, docs, version detection
- `update-website.sh` - Website HTML updates with smart suggestions

## Common Mistakes

### What Can Go Wrong

1. **Mistake:** Proceeding with dirty working tree
   - **Fix:** Check `git status --porcelain` in Phase 1, block if non-empty

2. **Mistake:** Missing CHANGELOG entry for version
   - **Fix:** CI validation in Phase 3 catches this before merge

3. **Mistake:** Version mismatch across 3 locations (plugin.json × 2, marketplace.json)
   - **Fix:** roadmap-update release mode updates all 3 atomically

4. **Mistake:** Forgetting to sync dev after merge
   - **Fix:** Included in PR description "Post-Merge Steps"

5. **Mistake:** Pushing tag on dev instead of main
   - **Fix:** Skill creates tag locally but doesn't push. Human pushes tag after merging to main

6. **Mistake:** Auto-merging PR without human review
   - **Fix:** Skill stops at HARD STOP 4, user must manually approve and merge

7. **Mistake:** Not running CI simulation before push
   - **Fix:** Phase 3 Step 3.3 runs same checks CI will run

8. **Mistake:** Website catalog updates not applied
   - **Fix:** update-website.sh detects new skills and generates HTML, asks for confirmation

9. **Mistake:** Skipping validation to save time
   - **Fix:** Validation is Phase 1, runs before any changes. Fast (<30 sec total)

10. **Mistake:** Creating release on wrong branch
    - **Fix:** Pre-Execution Protocol Step B verifies on dev branch

## Performance

### Typical Execution Time

- Phase 1 (Validation): ~30 seconds (3 scripts, parallel IO)
- Phase 2 (Docs Sync): ~45 seconds (4 operations, some invoke skills)
- Phase 3 (Version Bump): ~20 seconds (atomic commit + CI simulation)
- Phase 4 (PR Creation): ~15 seconds (push + gh CLI)

**Total: ~2 minutes** (vs. 30-45 minutes manual process)

**Time savings: ~28-43 minutes per release**

## Success Patterns

### What Works Well

1. **Validation first** - Catch issues early before any writes
2. **Atomic operations** - All version fields updated in single commit
3. **Preview before commit** - Show diffs at HARD STOP 2
4. **CI simulation** - Run locally what CI will run (no surprises)
5. **Clear rollback** - Specific commands at each gate
6. **Smart suggestions** - Website script detects new skills/roles automatically
7. **Human approval gates** - 4 HARD STOPs maintain control
8. **Single source scripts** - Same validation everywhere (local + CI)

## Integration Points

### Works Best With

- `/jaan-to:roadmap-update sync` - Marks tasks done before release
- `/jaan-to:roadmap-update release` - Atomic version bump
- `/jaan-to:docs-update --fix` - Auto-fixes stale docs
- `/jaan-to:release-iterate-changelog auto-generate` - CHANGELOG from commits
- `/jaan-issue-solve` - Post-release issue acknowledgments (manual step)

### Depends On

- Clean git state (no uncommitted changes)
- `gh` CLI authenticated (`gh auth status`)
- `jq` for JSON parsing
- `npm` for docs site build test
- Internet connection (git push, gh pr create)
- Being on dev branch (releases prepare from dev)

## Recovery

### If Skill Fails Mid-Execution

**Phase 1 failure:**
- No changes made (read-only)
- Fix validation errors and re-run

**Phase 2 failure:**
- Rollback: `git restore CHANGELOG.md docs/ website/index.html`
- Fix issue and re-run

**Phase 3 failure:**
- Rollback: `git tag -d vX.Y.Z && git reset --hard HEAD~1`
- Fix issue and re-run

**Phase 4 failure (after push):**
- If PR created: Close with `gh pr close <PR>` and delete remote tag `git push origin :vX.Y.Z`
- If PR not created: Force push to revert `git push origin dev --force`
- Then rollback locally and re-run

### Manual Completion

If skill fails at Phase 4 but everything else is done:
1. Manually create PR: `gh pr create --base main --title "release: X.Y.Z"`
2. Wait for CI checks
3. Merge via GitHub UI
4. Follow post-merge steps from SKILL.md
