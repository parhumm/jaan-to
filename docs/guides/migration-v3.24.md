---
title: "Migration Guide: v3.23 to v3.24"
sidebar_position: 3
---

# Migration Guide: v3.23 → v3.24

## What's New

v3.24 adds **multi-platform support** to all detect skills, enabling analysis of monorepos with multiple platforms (web, backend, mobile, TV apps, etc.). This release also renames `pack-detect` → `detect-pack` for naming consistency.

## Breaking Changes

### Command Rename
- **OLD**: `/jaan-to:pack-detect`
- **NEW**: `/jaan-to:detect-pack`

**Action**: Update any scripts, docs, or workflows that reference `/jaan-to:pack-detect`.

### Output Path Changes (Backward Compatible)

#### Single-Platform Projects (No Changes)
```
$JAAN_OUTPUTS_DIR/detect/dev/stack.md              # Unchanged
$JAAN_OUTPUTS_DIR/detect/design/brand.md           # Unchanged
```

#### Multi-Platform Monorepos (New Format)
```
$JAAN_OUTPUTS_DIR/detect/dev/stack-web.md          # Platform suffix added
$JAAN_OUTPUTS_DIR/detect/dev/stack-backend.md
$JAAN_OUTPUTS_DIR/detect/dev/stack-mobile.md
$JAAN_OUTPUTS_DIR/detect/pack/README-web.md        # Per-platform packs
$JAAN_OUTPUTS_DIR/detect/pack/README-backend.md
$JAAN_OUTPUTS_DIR/detect/pack/README.md            # Merged pack (all platforms)
```

**Action**: No migration needed! Old single-platform outputs continue to work. New platform-scoped outputs only appear for multi-platform monorepos.

### Evidence ID Format (Backward Compatible)

#### Single-Platform (Unchanged)
```yaml
evidence:
  id: E-DEV-001    # No platform prefix
```

#### Multi-Platform (New Format)
```yaml
evidence:
  id: E-DEV-WEB-001        # Platform prefix inserted
  id: E-DSN-BACKEND-023
  id: E-UX-MOBILE-042
```

**Action**: No migration needed! Both formats are supported. detect-pack automatically parses both single and multi-platform evidence IDs.

---

## Migration Steps

### For Existing Single-Platform Projects

**No action required.** Your existing outputs continue to work unchanged.

1. **Update plugin**:
   ```bash
   /plugin update jaan-to
   ```

2. **Test detect skills** (optional):
   ```bash
   /jaan-to:detect-dev
   /jaan-to:detect-pack  # New command name
   ```

   Expected: Same output paths and evidence IDs as before.

### For Multi-Platform Monorepos

1. **Update plugin**:
   ```bash
   /plugin update jaan-to
   ```

2. **Run detect skills** (auto-detects platforms):
   ```bash
   /jaan-to:detect-dev
   ```

   The skill will:
   - Auto-detect platforms from folder structure (web/, backend/, mobile/)
   - Prompt: "Detected platforms: web, backend, mobile. Analyze all or select?"
   - Create platform-scoped outputs: `stack-web.md`, `stack-backend.md`, etc.

3. **Run remaining detect skills** for each platform:
   ```bash
   /jaan-to:detect-design    # Skips backend/CLI (no UI)
   /jaan-to:detect-writing
   /jaan-to:detect-product
   /jaan-to:detect-ux        # Skips backend/CLI (no UI)
   ```

4. **Consolidate with detect-pack**:
   ```bash
   /jaan-to:detect-pack
   ```

   Creates:
   - Per-platform packs: `README-web.md`, `README-backend.md`, `README-mobile.md`
   - Merged pack: `README.md` with cross-platform risk heatmap

### For Teams Using CI/CD

Update any scripts that reference the old command:

```bash
# OLD
claude-code /jaan-to:pack-detect

# NEW
claude-code /jaan-to:detect-pack
```

---

## New Features

### Multi-Platform Auto-Detection

All detect skills now auto-detect platform structure:

**Platform Patterns**:
| Platform | Folder Patterns |
|----------|----------------|
| web | `web/`, `webapp/`, `frontend/`, `client/` |
| mobile | `mobile/`, `app/` |
| backend | `backend/`, `server/`, `api/`, `services/` |
| androidtv | `androidtv/`, `tv/`, `android-tv/` |
| ios | `ios/`, `iOS/` |
| android | `android/`, `Android/` |
| desktop | `desktop/`, `electron/` |
| cli | `cli/`, `cmd/` |

**Disambiguation Rules**:
- Exact folder match takes priority
- Pattern match fallback (e.g., `*frontend*` → web)
- User confirmation prompt after auto-detection

### Cross-Platform Evidence Linking

Link findings across platforms using `related_evidence` field:

```yaml
# In detect/dev/standards-web.md:
evidence:
  id: E-DEV-WEB-042
  related_evidence: [E-DEV-BACKEND-038]
  description: "TypeScript not detected - same issue in backend"

# In detect/dev/standards-backend.md:
evidence:
  id: E-DEV-BACKEND-038
  related_evidence: [E-DEV-WEB-042]
  description: "TypeScript not detected - same issue in web"
```

detect-pack automatically deduplicates cross-platform findings in the merged pack.

### Merged Pack with Cross-Platform Risk Heatmap

For multi-platform projects, detect-pack creates a merged pack at `detect/pack/README.md`:

**Cross-Platform Risk Heatmap**:
| Platform | Dev | Design | Writing | Product | UX | Score |
|----------|-----|--------|---------|---------|-----|-------|
| web      | C:2 H:5 M:8 | C:0 H:2 M:4 | C:0 H:1 M:3 | C:0 H:2 M:5 | C:1 H:3 M:6 | 7.2 |
| backend  | C:1 H:3 M:6 | - | C:0 H:0 M:2 | C:0 H:1 M:4 | - | 8.1 |
| mobile   | C:0 H:4 M:7 | C:0 H:3 M:5 | C:0 H:2 M:4 | C:0 H:2 M:6 | C:0 H:2 M:5 | 7.8 |
| **Total**| **3 12 21** | **5 9** | **3 7** | **4 15** | **1 5 11** | **7.7** |

### "Detect and Report N/A" Pattern

Domains that don't apply to a platform (e.g., Design for backend) now produce minimal output files with informational findings:

```yaml
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 1
overall_score: 10.0  # Perfect score (nothing to assess)
```

This ensures detect-pack always has complete coverage.

### Flat File Architecture (Formalized Exception)

Detect outputs use flat files with platform-scoped filenames instead of nested folders:

**Rationale**: Detect skills produce system state snapshots (overwritten each run), not versioned reports (archived).

**Pattern**:
```
detect/{domain}/{aspect}-{platform}.md  # Multi-platform
detect/{domain}/{aspect}.md             # Single-platform
```

This pattern is now documented in CLAUDE.md as an official exception to the ID-based folder structure.

---

## Rollback

If you encounter issues:

1. **Revert to v3.23**:
   ```bash
   /plugin install jaan-to@3.23.1
   ```

2. **Old outputs remain unchanged** - no data loss

3. **Report issue**: https://github.com/parhumm/jaan-to-claude-code/issues

---

## FAQ

### Do I need to re-run detect skills on existing projects?
No. Existing single-platform outputs continue to work without changes.

### What if my monorepo doesn't match standard patterns?
The skill will prompt you to manually select platforms after auto-detection fails. You can also use custom folder patterns in `jaan-to/config/settings.yaml` (coming in v3.25).

### Can I mix single-platform and multi-platform outputs?
Yes! Single-platform projects use the old format (no suffix). Multi-platform projects use the new format (with suffix). Both coexist in the same `detect/` directory.

### What happens to pack-detect skill files?
The skill directory was renamed from `skills/pack-detect/` to `skills/detect-pack/`. All references have been updated across the codebase.

### Do evidence IDs ever collide between platforms?
No. Multi-platform evidence IDs include platform prefixes (`E-DEV-WEB-001` vs `E-DEV-BACKEND-001`), preventing collisions even if sequence numbers overlap.

---

## Need Help?

- **Documentation**: [docs/skills/detect/](../skills/detect/README.md)
- **Examples**: See multi-platform analysis workflow in action
- **Issues**: https://github.com/parhumm/jaan-to-claude-code/issues
- **Slack**: #jaan-to-plugin
