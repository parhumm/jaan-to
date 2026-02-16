# Asset Embedding Reference

> Shared reference for skills that embed user-provided images in markdown output.

## Asset Resolution Protocol

For each user-provided image/folder path:

```
1. Check: is_jaan_path "$source"
   (Tests if path is inside $JAAN_OUTPUTS_DIR, $JAAN_TEMPLATES_DIR, $JAAN_CONTEXT_DIR, or $JAAN_LEARN_DIR)

   YES → Reference in-place. No copy.
         resolved_path=$(resolve_asset_path "$source" "$OUTPUT_FILE")
         Markdown: ![alt](resolved_path)

   NO  → Asset is external.
         Ask user: "Copy these external assets into output folder? [y/n]"
         If yes → copy_external_assets "$source" "$OUTPUT_FOLDER"
         resolved_path=$(resolve_asset_path "$source" "$OUTPUT_FILE")
         Markdown: ![alt](resolved_path)
```

## asset-handler.sh Usage

Source the utility in the Write Phase, after output folder creation:

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/asset-handler.sh"
```

**Functions:**

| Function | Args | Returns |
|----------|------|---------|
| `is_jaan_path "$path"` | Absolute path | Exit 0 if inside `$JAAN_*`, 1 if external |
| `resolve_asset_path "$source" "$output_file"` | Source path, output .md file | Relative path for markdown link |
| `copy_external_assets "$source" "$output_folder"` | Source path, output folder | Copies to `$OUTPUT_FOLDER/assets/` |
| `url_encode_path "$path"` | Path string | URL-encoded path (spaces → %20) |

## Markdown Embedding Syntax

Use standard markdown image syntax with URL-encoded paths:

```markdown
![Description of image](url_encode_path(resolved_path))
```

For paths with spaces or special characters, always URL-encode:
- Spaces → `%20`
- Parentheses → `%28` / `%29`

## Quality Check Items

When a skill accepts image input, add these to its quality check step:

- [ ] All image references use `![alt](path)` markdown syntax (not plain text file names)
- [ ] Paths are URL-encoded (no raw spaces or special characters)
- [ ] `$JAAN_*` assets reference existing location (no unnecessary copies)
- [ ] External assets copied to `$OUTPUT_FOLDER/assets/` only after user consent

## Write Phase Pattern

Insert asset resolution **after** output folder creation and **before** writing the main file:

1. For each user-provided image path, call `is_jaan_path`
2. Group results: `$JAAN_*` paths (reference in-place) vs external paths (need copy)
3. If external paths exist, ask user for copy consent
4. If approved, call `copy_external_assets` for each external path
5. Call `resolve_asset_path` for all paths to get markdown-relative references
6. Use resolved paths in `![alt](path)` when generating document content
