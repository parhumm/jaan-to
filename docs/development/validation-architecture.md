# Validation Architecture

> Single Source of Truth approach for jaan-to release validation

**Audience:** jaan-to contributors and maintainers

## Philosophy

All validation logic lives in `.claude/scripts/` directory. Both the LOCAL `/jaan-release` skill and CI workflows invoke the same scripts. **No duplication.**

This ensures:
- ✅ Same validation locally and in CI
- ✅ Update logic once, applies everywhere
- ✅ Easy to test scripts independently
- ✅ Follows CLAUDE.md principle: "Reference, don't copy"

---

## Script Inventory

| Script | Purpose | Used By | Exit Codes |
|--------|---------|---------|------------|
| `validate-compliance.sh` | Checks 1-10 (advisory) | Local `/jaan-release` only | 0=pass, 1=fail (warnings OK) |
| `validate-plugin-standards.sh` | Checks 11-16 (critical) | Local + CI | 0=pass, 1=fail |
| `validate-release-readiness.sh` | Git state, docs, version | Local only | 0=pass, 1=fail |
| `update-website.sh` | Website HTML updates | Local only | 0=success, 1=error |
| **Distributed Scripts** |||
| `validate-skills.sh` | Description budget | Local + CI | 0=pass, 1=fail |
| `validate-outputs.sh` | Output structure | Local + CI | 0=pass, 1=fail |

**Key distinction:**
- Scripts in `.claude/scripts/` → LOCAL only (for jaan-to development)
- Scripts in `scripts/` → DISTRIBUTED (users get these)

---

## Validation Layers

```
┌─────────────────────────────────────────────────────┐
│ Local (/jaan-release Phase 1)                       │
│ • All 24 checks (~30 seconds)                       │
│ • Fast feedback before any changes                  │
│ • Invokes: .claude/scripts/validate-*.sh           │
└─────────────────────────────────────────────────────┘
                      ↓ git push
┌─────────────────────────────────────────────────────┐
│ CI (release-check.yml)                              │
│ • 11 critical checks (~2-3 minutes)                 │
│ • Enforcement gate (blocks merge)                   │
│ • Invokes: .claude/scripts/validate-*.sh           │
│            (via relative paths)                     │
└─────────────────────────────────────────────────────┘
                      ↓ merge approved
┌─────────────────────────────────────────────────────┐
│ Human Review                                         │
│ • Final approval                                     │
│ • Release timing control                            │
│ • Manual steps (tag, release, sync)                 │
└─────────────────────────────────────────────────────┘
```

---

## Check Distribution

### Local-Only Checks (Advisory)

**Checks 1-8, 10** (via `validate-compliance.sh`):
- Skill alignment, generic applicability, multi-stack coverage
- Not blocking, provide guidance for quality improvements
- Run locally for early feedback

**Why local-only?**
- Advisory checks shouldn't block CI
- Give developers early warnings
- Can be addressed over time, not release-blockers

### Local + CI Checks (Critical)

**Check 9** (Token Strategy):
- Via `scripts/validate-skills.sh` (DISTRIBUTED)
- Critical for Claude Code to discover skills
- Blocks both local and CI if budget exceeded

**Checks 11-16** (Plugin Standards):
- Via `validate-plugin-standards.sh`
- Critical for plugin installation/runtime
- Must pass in CI before merge allowed

### Local-Only Checks (Contextual)

**Git State** (via `validate-release-readiness.sh`):
- Working tree clean, branch check, remotes up-to-date
- Contextual to developer's local environment
- Not applicable in CI (CI has fresh clone)

**Documentation Sync**:
- Checks if docs need updates
- Local-only because skill auto-fixes docs in Phase 2

**Version Detection**:
- Suggests next version based on commits
- Local-only (version is determined before PR)

---

## Script Architecture

### Path Calculation

All LOCAL scripts use this pattern:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
```

**Why `../..`?**
- Script location: `.claude/scripts/validate-*.sh`
- Plugin root: `../../` from script
- Allows scripts to reference: `$PLUGIN_ROOT/scripts/`, `$PLUGIN_ROOT/skills/`, etc.

### Cross-Script References

LOCAL scripts reference DISTRIBUTED scripts:

```bash
# validate-compliance.sh invokes distributed validate-skills.sh
bash "$PLUGIN_ROOT/scripts/validate-skills.sh"

# validate-plugin-standards.sh invokes distributed validate-outputs.sh
bash "$PLUGIN_ROOT/scripts/validate-outputs.sh" "$PLUGIN_ROOT/jaan-to/outputs"

# validate-release-readiness.sh invokes distributed docs-sync-check.sh
bash "$PLUGIN_ROOT/scripts/docs-sync-check.sh"
```

**Why this pattern?**
- LOCAL scripts orchestrate/aggregate checks
- DISTRIBUTED scripts do the actual validation
- Users can run distributed scripts independently
- Same validation logic for user-created skills/outputs

### Error Reporting

Scripts use GitHub Actions-compatible format:

```bash
# Errors (blocking)
echo "::error::Description of error"
echo "  Fix: Specific fix command"

# Warnings (non-blocking)
echo "::warning::Description of warning"
echo "  Impact: What this affects"

# Info
echo "ℹ Informational message"
```

**Benefits:**
- CI automatically highlights errors/warnings
- Clear in terminal output too
- Provides actionable fix commands

---

## Adding New Validation Checks

### Step 1: Decide Check Type

**Advisory (warnings OK)?**
- Add to `validate-compliance.sh`
- Provides guidance, doesn't block
- Example: "Skill missing examples section"

**Critical (must pass)?**
- Add to `validate-plugin-standards.sh`
- Blocks release if fails
- Example: "Plugin manifest invalid JSON"

**Contextual (local environment)?**
- Add to `validate-release-readiness.sh`
- Depends on git state, local files
- Example: "Working tree has uncommitted changes"

### Step 2: Write Check Logic

```bash
echo "Check N: Description"
echo "────────────────────────────────────────────────────────"

# Perform validation
RESULT=$(validation command here)

if [ validation passes ]; then
  echo "  ✓ Check passed"
else
  echo "  ::error::Check failed: specific reason"
  echo "  Fix: command to fix the issue"
  ((ERRORS++))
fi

echo ""
```

**Guidelines:**
- Use descriptive check names
- Provide specific error messages
- Always include fix commands
- Use `::error::` for blockers, `::warning::` for advisory

### Step 3: Update Documentation

Add check to this file under "Check Distribution" section:

```markdown
**Check N**: Description
- Via `validate-*.sh`
- Purpose and rationale
- When it runs (local/CI/both)
```

### Step 4: Test Locally

```bash
# Test the specific script
bash .claude/scripts/validate-compliance.sh

# Test via skill
/jaan-release --dry-run

# Verify error formatting
# (should show ::error:: in output)
```

### Step 5: Test in CI

If check should run in CI:
1. Update `.github/workflows/release-check.yml`
2. Push to branch
3. Verify workflow runs check
4. Verify errors block merge

---

## Maintenance

### Updating Existing Checks

1. **Locate the script** containing the check
2. **Edit the check logic** (within the script)
3. **Test locally** with various failure scenarios
4. **Update this doc** if check behavior changes
5. **Test in CI** if check runs in CI

**No need to update:**
- `/jaan-release` skill (orchestrates, doesn't duplicate)
- CI workflows (invoke scripts, don't contain logic)

### Performance Optimization

Scripts are optimized for speed:
- Run expensive checks last (fail fast on cheap checks)
- Use `grep -q` for boolean checks (don't print matches)
- Avoid redundant filesystem traversals
- Cache results when checking multiple files

**Current performance:**
- `validate-compliance.sh`: ~8 seconds (scans skills/)
- `validate-plugin-standards.sh`: ~5 seconds (JSON validation + file checks)
- `validate-release-readiness.sh`: ~3 seconds (git operations)
- `update-website.sh`: ~2 seconds (sed + file detection)

**Total: ~18 seconds** (plus ~12 seconds for skill invocations in Phase 1)

---

## Benefits of This Architecture

### Single Source of Truth
- ✅ Validation logic in one place (`.claude/scripts/`)
- ✅ LOCAL skill and CI invoke same scripts
- ✅ Update once, applies everywhere
- ✅ No bash code duplication

### Maintainability
- ✅ Easy to add new checks (edit script, done)
- ✅ Easy to update checks (change one place)
- ✅ Easy to test (run script directly)
- ✅ Clear separation: advisory vs. critical vs. contextual

### Consistency
- ✅ Same validation locally and in CI
- ✅ Same error messages everywhere
- ✅ Same fix commands everywhere

### User Empowerment
- ✅ DISTRIBUTED scripts (validate-skills.sh, validate-outputs.sh) help users validate their own work
- ✅ Users can run these scripts independently
- ✅ Same standards for plugin and user-created content

---

## Anti-Patterns (What NOT to Do)

### ❌ Don't Duplicate Validation Logic

**BAD:**
```yaml
# .github/workflows/release-check.yml
- name: Check version
  run: |
    V1=$(jq -r '.version' plugin.json)
    V2=$(jq -r '.version' marketplace.json)
    # ... 50 lines of bash ...
```

**GOOD:**
```yaml
# .github/workflows/release-check.yml
- name: Check version
  run: bash .claude/scripts/validate-plugin-standards.sh
```

### ❌ Don't Put Validation in Skill

**BAD:**
```markdown
# /jaan-release SKILL.md

## Step 1.1: Validate Plugin Manifests

\```bash
jq empty .claude-plugin/plugin.json || exit 1
V1=$(jq -r '.version' .claude-plugin/plugin.json)
# ... inline validation logic ...
\```
```

**GOOD:**
```markdown
# /jaan-release SKILL.md

## Step 1.1: Run Validation Scripts

\```bash
bash .claude/scripts/validate-plugin-standards.sh
\```
```

### ❌ Don't Skip Error Messages

**BAD:**
```bash
if [ $ERRORS -gt 0 ]; then
  echo "Validation failed"
  exit 1
fi
```

**GOOD:**
```bash
if [ $ERRORS -gt 0 ]; then
  echo "::error::Validation failed: $ERRORS errors found"
  echo "  Fix: Address errors above and re-run"
  echo "  Help: See docs/development/validation-architecture.md"
  exit 1
fi
```

---

## See Also

- [CI Workflows](ci-workflows.md) - How CI uses these scripts
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Release process for maintainers
- [validation scripts](./../.claude/scripts/) - Source code

---

Last updated: 2026-02-15
