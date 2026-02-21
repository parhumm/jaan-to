# CI Workflows

> GitHub Actions workflows for jaan-to plugin development and releases

**Audience:** jaan-to contributors and maintainers

---

## Active Workflows

### `.github/workflows/dev-dist-build.yml`

**Trigger:** Pull requests to `dev` branch (`opened`, `synchronize`, `reopened`)
**Purpose:** Enforce dual-platform packaging and publish PR-ready dist artifacts
**Duration:** ~2-4 minutes

**What it validates/builds:**

1. **Plugin Standards** → `bash .claude/scripts/validate-plugin-standards.sh`
2. **Skill Budget** → `bash scripts/validate-skills.sh`
3. **Security Standards** → `bash scripts/validate-security.sh`
4. **Multi-Runtime Dist Validation** → `bash scripts/validate-multi-runtime.sh`
   - Builds both targets
   - Verifies `dist/jaan-to-claude` and `dist/jaan-to-codex`
   - Checks required runtime files and skill parity
5. **Artifact Upload**
   - `jaan-to-claude-pr-<number>` from `dist/jaan-to-claude`
   - `jaan-to-codex-pr-<number>` from `dist/jaan-to-codex`
   - Retention: 7 days

**Artifact download flow (PR):**

1. Open the PR to `dev`
2. Wait for `Dev Dist Build` workflow to complete
3. Open workflow run → **Artifacts**
4. Download the Claude and Codex dist zip files

---

### `.github/workflows/release-check.yml`

**Trigger:** Pull requests to `main` branch
**Purpose:** Validate release readiness before merge
**Duration:** ~2-3 minutes

**What it validates:**

1. **Plugin Standards** → `bash .claude/scripts/validate-plugin-standards.sh`
   - JSON syntax (plugin.json, marketplace.json, hooks.json)
   - Version consistency (3 locations must match)
   - Hooks configuration (at least one hook defined)
   - Skills structure (all have YAML frontmatter)
   - Context files (all have markdown headers)
   - Output structure validation
   - Permission safety (no dangerous patterns)

2. **Skill Description Budget** → `bash scripts/validate-skills.sh`
   - Character count under 15,000 limit
   - Token optimization for Claude Code discovery

3. **CHANGELOG Entry** → Check version has changelog section
   - Ensures new version documented

4. **Docs Site Build** → `cd website/docs && npm ci && npm run build`
   - Verifies documentation builds without errors
5. **Multi-Runtime Dist Validation** → `bash scripts/validate-multi-runtime.sh`
   - Ensures both Claude and Codex dist targets build successfully on release PRs

**Exit behavior:**
- ✅ All steps pass → PR can be merged
- ❌ Any step fails → PR blocked from merge

**Example run:**
```bash
# Locally simulate CI checks
bash .claude/scripts/validate-plugin-standards.sh
bash scripts/validate-skills.sh
bash scripts/validate-multi-runtime.sh
cd website/docs && npm ci && npm run build
```

---

### `.github/workflows/deploy-docs.yml`

**Trigger:** Push to `main` branch
**Purpose:** Deploy documentation website to GitHub Pages
**Duration:** ~1-2 minutes

**What it does:**

1. **Build** Docusaurus site from `website/docs/`
2. **Deploy** to `gh-pages` branch
3. **Publish** to https://docs.jaan.to

**No validation** - assumes main branch is already validated.

---

## Script-Based Validation

### Philosophy

All validation logic lives in scripts, not inline in YAML:

**✅ GOOD (Single Source of Truth):**
```yaml
- name: Validate plugin standards
  run: bash .claude/scripts/validate-plugin-standards.sh
```

**❌ BAD (Duplication):**
```yaml
- name: Validate plugin standards
  run: |
    jq empty .claude-plugin/plugin.json || exit 1
    V1=$(jq -r '.version' .claude-plugin/plugin.json)
    # ... hundreds of lines of inline bash
```

### Benefits

- ✅ Same logic for local and CI (single source)
- ✅ Easy to test independently (`bash script.sh`)
- ✅ Version controlled and reviewable
- ✅ Follows CLAUDE.md principles

---

## Adding New CI Checks

### Option 1: Add to Existing Script

**When:** Check fits existing script's purpose

1. Edit `.claude/scripts/validate-plugin-standards.sh` (or appropriate script)
2. Add new check following existing pattern
3. Test locally: `bash .claude/scripts/validate-plugin-standards.sh`
4. Push to dev branch
5. Create PR to verify CI runs check

**Example:**
```bash
# In validate-plugin-standards.sh

echo "Check 17: New Validation"
echo "────────────────────────────────────────────────────────"

# Validation logic here
if [ validation passes ]; then
  echo "  ✓ Check 17 passed"
else
  echo "  ::error::Check 17 failed: reason"
  ((ERRORS++))
fi
echo ""
```

### Option 2: Create New Script

**When:** Check is standalone or complex enough to warrant separate script

1. Create `.claude/scripts/validate-new-thing.sh`
2. Add shebang and `set -euo pipefail`
3. Implement validation logic with `::error::` format
4. Make executable: `chmod +x .claude/scripts/validate-new-thing.sh`
5. Test locally
6. Add to `.github/workflows/release-check.yml`:

```yaml
- name: Validate new thing
  run: bash .claude/scripts/validate-new-thing.sh
```

7. Commit both script and workflow
8. Create PR to verify

---

## CI Check Reference

### Currently Running Checks

| Check | Script | Blocking | Notes |
|-------|--------|----------|-------|
| Plugin Standards | `validate-plugin-standards.sh` | ✅ Yes | JSON, hooks, skills structure |
| Skill Budget | `validate-skills.sh` | ✅ Yes | 15K char limit |
| Multi-Runtime Dist | `validate-multi-runtime.sh` | ✅ Yes | Builds and verifies Claude + Codex packages |
| Version Consistency | Part of plugin standards | ✅ Yes | 3 locations match |
| CHANGELOG Entry | Inline YAML | ✅ Yes | Should extract to script |
| Docs Build | `npm run build` | ✅ Yes | Ensures docs valid |

### LOCAL-Only Checks (Not in CI)

| Check | Script | Why Not in CI |
|-------|--------|---------------|
| Compliance (1-10) | `validate-compliance.sh` | Advisory, not blocking |
| Git State | `validate-release-readiness.sh` | Contextual to local env |
| Docs Sync | Part of release-readiness | Auto-fixed by skill |
| Version Suggestion | Part of release-readiness | Determined before PR |
| Website Updates | `update-website.sh` | Manual review required |

---

## Debugging CI Failures

### View Logs

```bash
# List recent workflow runs
gh run list --workflow=release-check.yml

# View specific run
gh run view <run-id> --log

# View failed step
gh run view <run-id> --log-failed
```

### Reproduce Locally

**All CI checks can be run locally:**

```bash
# Run all validation scripts
bash .claude/scripts/validate-plugin-standards.sh
bash scripts/validate-skills.sh
bash scripts/validate-multi-runtime.sh

# Check CHANGELOG (manual for now, should be scripted)
grep -q "## \[6.3.0\]" CHANGELOG.md || echo "Missing CHANGELOG entry"

# Build docs
cd website/docs
npm ci
npm run build
cd ../..
```

**If CI fails but local passes:**
- Check you're on latest commit
- Ensure all files committed
- Verify script is executable (`chmod +x`)
- Check for environment-specific issues

### Common Failures

#### 1. Version Mismatch

**Error:**
```
::error::Version mismatch:
         plugin.json: 6.3.0
         marketplace.json (top): 6.2.0
         marketplace.json (plugins[0]): 6.3.0
```

**Fix:**
```bash
# Use atomic version bump (recommended)
/jaan-to:roadmap-update release 6.3.0 "Summary"

# OR manual fix
./scripts/bump-version.sh 6.3.0
```

#### 2. Missing CHANGELOG Entry

**Error:**
```
::error::No CHANGELOG entry for v6.3.0
```

**Fix:**
```bash
# Add to CHANGELOG.md manually
## [6.3.0] - 2026-02-15
### Added
- Feature description

# OR use skill
/jaan-to:release-iterate-changelog auto-generate
```

#### 3. Skill Budget Exceeded

**Error:**
```
::error::Skill descriptions exceed budget by 234 chars (15,234 / 15,000)
```

**Fix:**
```bash
# Option 1: Shorten descriptions in skills/*/SKILL.md
# Each description should be ~120 chars max

# Option 2: Extract content to reference docs
# Move large tables/examples to docs/extending/*-reference.md

# Check after changes
bash scripts/validate-skills.sh
```

#### 4. Docs Build Failure

**Error:**
```
ERROR in website/docs/docs/skill-name.md
Missing image: ./assets/screenshot.png
```

**Fix:**
```bash
cd website/docs
npm ci
npm run build  # See full error

# Fix the issue (e.g., add missing image)
# Test build passes
```

---

## Workflow File Structure

### release-check.yml

```yaml
name: Release Checks

on:
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate plugin standards
        run: bash .claude/scripts/validate-plugin-standards.sh

      - name: Validate skill budget
        run: bash scripts/validate-skills.sh

      - name: Check CHANGELOG entry
        run: |
          VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
          grep -q "## \[$VERSION\]" CHANGELOG.md || {
            echo "::error::No CHANGELOG entry for v$VERSION"
            exit 1
          }

      - name: Build docs site
        run: |
          cd website/docs
          npm ci
          npm run build
```

**Key points:**
- Uses `ubuntu-latest` (same as most CIs)
- Checks out code first
- Each validation is separate step (clear in UI)
- Use `::error::` format for GitHub annotations
- Exit 1 on failure

---

## Triggering Workflows

### Manual Trigger (Testing)

```bash
# Trigger workflow manually via GitHub UI
# Or via gh CLI:
gh workflow run release-check.yml
```

### Automatic Triggers

**release-check.yml:**
- Every PR to `main`
- Every push to PR branch targeting `main`

**dev-dist-build.yml:**
- Every PR to `dev` on `opened`, `synchronize`, `reopened`

**deploy-docs.yml:**
- Every push to `main` (after merge)

### Skip CI (Emergency Only)

```bash
# Add to commit message to skip CI
git commit -m "docs: typo fix [skip ci]"
```

⚠️ **Use sparingly** - release PRs should ALWAYS run CI.

---

## CI Performance

### Current Timings

- **Checkout:** ~5 seconds
- **Plugin standards:** ~5 seconds (JSON + file checks)
- **Skill budget:** ~3 seconds (parse frontmatter)
- **CHANGELOG check:** ~1 second (grep)
- **Docs build:** ~60-90 seconds (npm install + build)

**Total: ~2-3 minutes**

### Optimization Opportunities

1. **Cache npm dependencies:**
   ```yaml
   - uses: actions/setup-node@v4
     with:
       cache: 'npm'
       cache-dependency-path: website/docs/package-lock.json
   ```
   Saves ~30 seconds

2. **Run checks in parallel:**
   ```yaml
   jobs:
     validate-scripts:
       # ...validation steps

     build-docs:
       # ...docs build steps
   ```
   Saves ~60 seconds (parallel execution)

3. **Skip docs build on non-doc PRs:**
   ```yaml
   - name: Build docs
     if: contains(github.event.pull_request.files, 'docs/')
     run: cd website/docs && npm ci && npm run build
   ```
   Saves ~90 seconds when docs unchanged

---

## Best Practices

### DO

✅ Keep validation logic in scripts
✅ Use `::error::` and `::warning::` formats
✅ Provide specific error messages with fix commands
✅ Test scripts locally before pushing
✅ Make scripts executable (`chmod +x`)
✅ Use semantic step names in workflows

### DON'T

❌ Duplicate bash logic in YAML
❌ Use vague error messages ("Validation failed")
❌ Skip CI checks ([skip ci])
❌ Put complex logic inline in workflow
❌ Forget to test locally first
❌ Leave failing checks unfixed

---

## Future Enhancements

**Planned improvements:**

1. **Extract CHANGELOG check to script**
   - Current: Inline YAML
   - Future: `bash .claude/scripts/validate-changelog.sh`

2. **Parallel job execution**
   - Current: Sequential steps
   - Future: Parallel jobs (save ~60 seconds)

3. **Matrix testing** (multiple Node versions)
   - Test docs build on Node 18, 20, 22
   - Ensure compatibility

4. **Pre-commit hooks integration**
   - Run basic checks before commit
   - Catch issues even earlier

5. **Release automation**
   - Auto-create GitHub release after merge
   - Auto-sync dev branch
   - Auto-bump next version

---

## See Also

- [Validation Architecture](validation-architecture.md) - How scripts are structured
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Full release process
- [GitHub Actions Docs](https://docs.github.com/en/actions) - Official reference

---

Last updated: 2026-02-15
