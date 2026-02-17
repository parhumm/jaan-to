---
title: "UX Flowchart PNG Conversion"
sidebar_position: 14
---

# UX Flowchart PNG Conversion

> Phase 6 | Status: pending

## Problem

`/ux-flowchart-generate` produces Mermaid flowcharts in markdown format. These render in GitHub but not in exported documents, PDFs, or offline environments. Users need PNG versions for embedding in PRDs, presentations, and design handoffs — currently requiring manual screenshots.

## Solution

Create a new `/ux-flowchart-png` skill that reads `/ux-flowchart-generate` outputs, extracts all Mermaid code blocks, converts them to PNG using a Python-based renderer, and updates markdown references to include PNG embeds alongside the Mermaid source.

### Approach: Mermaid CLI (`mmdc`)

The official Mermaid CLI (`@mermaid-js/mermaid-cli`) is the most reliable conversion tool. It uses Puppeteer internally for accurate rendering. Alternative: `mermaid-py` (lighter, pip-installable) as fallback for environments without Node.js.

## Scope

**In-scope:**
- Read `$JAAN_OUTPUTS_DIR/ux/diagrams/{id}-{slug}/` for Mermaid blocks
- Convert each Mermaid diagram to PNG
- Save PNGs alongside source markdown
- Update markdown references with `![flowchart](path-to-png)` embeds
- Graceful error when renderer not installed

**Out-of-scope:**
- SVG conversion (future enhancement)
- Interactive diagram rendering
- Non-Mermaid diagram formats (PlantUML, D2)

## Implementation Steps

1. Create skill via `/jaan-to:skill-create ux-flowchart-png`
2. Define SKILL.md with two-phase workflow:
   - Phase 1: Scan target directory for Mermaid blocks, list found diagrams
   - HARD STOP: User confirms which diagrams to convert
   - Phase 2: Run conversion, write PNGs, update markdown
3. Implement Mermaid extraction logic (parse ` ```mermaid ` blocks from markdown)
4. Support conversion backends:
   - Primary: `mmdc` (Mermaid CLI via npx)
   - Fallback: `mermaid-py` (Python pip package)
5. Use asset-handler pattern from `${CLAUDE_PLUGIN_ROOT}/scripts/lib/asset-handler.sh`
6. Output PNGs at `$JAAN_OUTPUTS_DIR/ux/diagrams/{id}-{slug}/{id}-flowchart-{slug}.png`
7. Update source markdown to include `![{diagram-name}]({png-path})` below each Mermaid block

## Skills Affected

- `/ux-flowchart-generate` — upstream input; no changes needed
- `/docs-create` — downstream consumer; will auto-embed PNGs when present
- `/pm-prd-write` — can reference PNG flowcharts in PRD outputs

## Acceptance Criteria

- [ ] Skill reads `/ux-flowchart-generate` outputs and finds all Mermaid code blocks
- [ ] Converts each Mermaid diagram to PNG
- [ ] Saves PNGs alongside source markdown in output directory
- [ ] Updates markdown references to include PNG embeds
- [ ] Follows v3.0.0 skill patterns (`$JAAN_*` environment variables)
- [ ] Graceful error when Python/Node dependencies not installed
- [ ] Two-phase workflow with HARD STOP gate

## Dependencies

- `/ux-flowchart-generate` must exist (already shipped)
- `mmdc` or `mermaid-py` installed on user's system

## References

- [#124](https://github.com/parhumm/jaan-to/issues/124)
- Existing skill: `skills/ux-flowchart-generate/SKILL.md`
- Asset handler: `scripts/lib/asset-handler.sh`
