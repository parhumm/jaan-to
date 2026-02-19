---
title: "PM Jira Export Skill"
sidebar_position: 16
---

# PM Jira Export Skill

> Phase 6 | Status: pending

## Problem

jaan.to generates markdown outputs (PRDs, stories, test cases) that teams need to copy into Jira. Jira uses its own wiki markup/ADF format — direct markdown paste loses formatting, tables break, and code blocks mangle. This manual reformatting step creates friction in the PM workflow.

## Solution

Create `/pm-jira-export` with two operating modes:

1. **Copy-paste mode** (baseline, no MCP) — Convert markdown to Jira wiki markup, output as ready-to-paste text
2. **MCP mode** (optional) — Use Jira MCP to create/update issues directly

### Conversion Rules

| Markdown | Jira Wiki Markup |
|----------|-----------------|
| `# Heading` | `h1. Heading` |
| `**bold**` | `*bold*` |
| `- list item` | `* list item` |
| `1. ordered` | `# ordered` |
| `` `code` `` | `{{code}}` |
| ```` ```block``` ```` | `{code}...{code}` |
| `[text](url)` | `[text\|url]` |
| `\| table \|` | `\|\| header \|\|` / `\| cell \|` |

## Scope

**In-scope:**
- Markdown → Jira wiki markup conversion
- Field mapping (summary, description, acceptance criteria, labels)
- Batch export (multiple stories from one PRD)
- Handles `/pm-story-write`, `/pm-prd-write`, `/qa-test-cases` outputs

**Out-of-scope:**
- Jira project/board configuration
- Sprint management
- Jira webhook integration
- Confluence export (separate future skill)

## Implementation Steps

1. Create skill via `/jaan-to:skill-create pm-jira-export`
2. Implement markdown-to-Jira converter:
   - Parse markdown AST (headings, tables, lists, code blocks)
   - Map to Jira wiki markup equivalents
   - Handle nested lists and complex tables
3. Implement field extractor for PM outputs:
   - From `pm-story-write`: title → summary, story statement → description, ACs → acceptance criteria field
   - From `pm-prd-write`: title → epic summary, user stories → linked stories
   - From `qa-test-cases`: scenario name → test summary, steps → description
4. Add batch mode: scan `$JAAN_OUTPUTS_DIR/pm/stories/{id}-*/` for all story files
5. Add optional Jira MCP integration:
   - Check if Jira MCP is available
   - If yes, offer direct issue creation via MCP
   - If no, output copy-paste text
6. Output at `$JAAN_OUTPUTS_DIR/pm/jira-export/{NEXT_ID}-{slug}/`

## Skills Affected

- `/pm-story-write` — primary input source (already has Jira CSV Export section)
- `/pm-prd-write` — secondary input source
- `/qa-test-cases` — secondary input source

## Acceptance Criteria

- [ ] Converts markdown tables, code blocks, headings, lists to Jira format
- [ ] Works without Jira MCP (copy-paste mode as baseline)
- [ ] Optional Jira MCP integration for direct issue creation
- [ ] Handles `/pm-story-write`, `/pm-prd-write`, `/qa-test-cases` outputs
- [ ] Batch export mode for multiple outputs
- [ ] Follows v3.0.0 skill patterns (`$JAAN_*` environment variables)
- [ ] Output at `$JAAN_OUTPUTS_DIR/pm/jira-export/{id}-{slug}/`

## Dependencies

- None for copy-paste mode
- Jira MCP for direct integration mode (Phase 7)

## References

- [#127](https://github.com/parhumm/jaan-to/issues/127)
- Input skill: `skills/pm-story-write/SKILL.md` (has Jira CSV Export section)
- Input skill: `skills/pm-prd-write/SKILL.md`
- Jira wiki markup: [Atlassian text formatting notation](https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=texteffects)
