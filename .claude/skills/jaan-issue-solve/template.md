# Comment Template

Use this template when generating comments for closed issues.

## GitHub Issue Comment

```
**Resolved in [{{version}}]({{release_url}})** (`{{commit_ref}}`)

{{resolution_details}}

{{closing_note}}

**Full changelog:** {{changelog_url}}
```

### Variable Guide

| Variable | Source | Example |
|----------|--------|---------|
| `{{version}}` | Target version tag | `v6.1.0` |
| `{{release_url}}` | `https://github.com/{owner}/{repo}/releases/tag/{version}` | |
| `{{commit_ref}}` | From changelog entry, if available | `eedcbab` |
| `{{resolution_details}}` | Match changelog entries to issue, explain specifically how the change addresses the reported problem | |
| `{{closing_note}}` | Warm closing — vary per comment, don't repeat the same phrase | |
| `{{changelog_url}}` | `https://github.com/{owner}/{repo}/blob/main/CHANGELOG.md` | |

### Tone Examples

**Good closing notes** (rotate, don't repeat):
- "Thank you for reporting this — it helped us improve the plugin."
- "We appreciate you raising this issue."
- "Thanks for the detailed report — it made the fix straightforward."
- "Happy to have this resolved. Let us know if you run into anything else."

**Good resolution detail style:**
- Start with what changed, then explain how it fixes the reported problem
- Reference specific mechanisms (e.g., "three-tier fallback", "lazy loading")
- Include commit refs inline when available
