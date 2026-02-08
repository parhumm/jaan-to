---
title: "Migration Guide: v2.x to v3.0"
sidebar_position: 2
---

# Migration Guide: v2.x → v3.0

## Breaking Changes

### Path Customization
- Default paths unchanged: `jaan-to/templates`, `jaan-to/learn`, etc.
- **NEW**: Paths now customizable via `jaan-to/config/settings.yaml`
- Old hardcoded paths still work but deprecated

### Configuration File
- **NEW**: `jaan-to/config/settings.yaml` created on first run
- Auto-generated from plugin defaults
- Commit to repo for team sharing

### Environment Variables
- **NEW**: `JAAN_*` environment variables (e.g., `JAAN_OUTPUTS_DIR`)
- Set in `.claude/settings.json` → `env` key
- Override default paths per-project

## Migration Steps

### For Existing Projects

1. **Update plugin**:
   ```bash
   /plugin update jaan-to
   ```

2. **Re-run bootstrap** (automatic on next session):
   - Creates `jaan-to/config/settings.yaml`
   - Preserves existing templates, learn, context files
   - No data loss

3. **Review new config**:
   ```bash
   cat jaan-to/config/settings.yaml
   ```

4. **Customize paths** (optional):
   Edit `jaan-to/config/settings.yaml`:
   ```yaml
   paths_outputs: "artifacts/jaan-to"  # Custom output location
   paths_templates: "docs/templates"   # Custom templates
   ```

5. **Update permissions** (if paths customized):
   Edit `.claude/settings.json`:
   ```json
   {
     "permissions": {
       "allow": [
         "Read(artifacts/**)",
         "Write(artifacts/**)"
       ]
     }
   }
   ```

### For New Projects

No action needed. Bootstrap creates everything automatically.

## New Features

### Template Customization
```yaml
# jaan-to/config/settings.yaml
templates_jaan_to_pm_prd_write_path: "./custom-templates/enterprise-prd.md"
```

### Learning Merge
```yaml
learning_strategy: "merge"  # Combine plugin + project lessons
```

### Tech Stack Integration
Edit `jaan-to/context/tech.md` to customize:
- Languages & frameworks
- Technical constraints
- Architecture patterns

PRDs will automatically reference your stack.

## Rollback

If issues occur:
1. Pin to v2.2.0: `/plugin install jaan-to@2.2.0`
2. Delete `jaan-to/config/` directory
3. Restart session
