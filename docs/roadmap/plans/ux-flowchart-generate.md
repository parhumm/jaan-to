# Plan: Create `ux-flowchart-generate` Skill

## Context

The `ux-flowchart-generate` skill generates GitHub-renderable Mermaid flowcharts from PRDs, docs, and codebases with evidence maps, confidence scoring, and unknowns lists. Two detailed research documents ([64-ux-flowchart-generate.md](64-ux-flowchart-generate.md) | [65-ux-flowchart-generate-skill.md](65-ux-flowchart-generate-skill.md)) provide the full specification. No MCP required — pure text-to-Mermaid generation.

**Duplicate check**: No existing skill matches. Closest UX skills (heatmap-analyze, research-synthesize, microcopy-write) have <30% overlap.

**LEARN.md lessons applied**: Use ID-based output structure with `id-generator.sh` and `index-updater.sh`.

---

## Files to Create

### 1. `skills/ux-flowchart-generate/SKILL.md`

**Frontmatter:**
```yaml
---
name: ux-flowchart-generate
description: Generate GitHub-renderable Mermaid flowcharts from PRD/docs/codebase with evidence maps and confidence scoring.
allowed-tools: Read, Glob, Grep, Write($JAAN_OUTPUTS_DIR/ux/**), Task, AskUserQuestion, Edit(jaan-to/config/settings.yaml)
argument-hint: [source_type] [paths...] [goal] [scope?]
---
```

**Structure** (mapping the 7-phase pipeline to standard 2-phase skill format):

- **Context Files**: LEARN.md, template.md, tech.md (tech-aware — reads codebase)
- **Input**: `$ARGUMENTS` parsed as `[source_type] [paths...] [goal] [scope?]`
  - `source_type`: `prd`, `doc`, `repo`, `mixed`
  - `goal`: `userflow`, `systemflow`, `architecture`, `stateflow` (default: `userflow`)
  - `scope`: optional free text to narrow focus
- **Pre-Execution**: Standard LEARN.md + Language Settings + tech.md read

**PHASE 1 (Analysis — maps to pipeline phases 0-2):**
- Step 1: Validate inputs & detect source type
- Step 2: Parse sources — extract entities, build intermediate graph model
- Step 3: Select diagram type (flowchart vs stateDiagram-v2 based on goal + sources)
- Step 4: Plan Mermaid structure — node inventory, edge plan, subgraph grouping, splitting decisions
- Step 5: Clarify with user (audience, update mode, scope, confidence threshold)

**HARD STOP**: Show planned diagram structure (node count, edge count, subgraph plan, estimated complexity, source coverage)

**PHASE 2 (Generation — maps to pipeline phases 3-6):**
- Step 6: Generate slug
- Step 6.5: Generate ID and folder structure (using `id-generator.sh`)
- Step 7: Generate Mermaid code (apply node shapes, edge conventions, style definitions, GitHub constraints)
- Step 8: Build evidence map (Node ID → PRD Ref → Code Path → Code Symbol → Test Path → Confidence → Status → Notes)
- Step 9: Identify unknowns & mismatches
- Step 10: Validate quality gates (17 machine-checkable + 5 human-review flags)
- Step 11: Preview & approval
- Step 12: Write output files (flowchart.md + evidence-map.md) + update index
- Step 13: Capture feedback

**Quality gates** (embedded in Step 10):

*Machine-checkable (hard fail):*
- SYNTAX_VALID, NODE_CAP (≤25), EDGE_CAP (≤50), TEXT_CAP (<40K chars)
- CYCLOMATIC (≤15), NO_ORPHANS, DECISION_COMPLETE, ENTRY_EXISTS, EXIT_EXISTS
- ERROR_PATHS (≥1 error edge), LABELS_PRESENT, SEMANTIC_IDS, NO_RESERVED
- DIRECTION_SET, STYLES_DEFINED, METADATA_PRESENT, EVIDENCE_COMPLETE

*Human-review flags:*
- AUDIENCE_FIT, ABSTRACTION_CONSISTENT, FLOW_DIRECTION, UI_STATES_COMPLETE, MISMATCH_FLAGGED

**Definition of Done**: Sources parsed, diagram generated, evidence map complete, quality gates pass, unknowns documented, output files written, index updated, user approved.

### 2. `skills/ux-flowchart-generate/LEARN.md`

Seed file with research-informed initial lessons:

- **Better Questions**: Source availability, diagram goal, scope narrowing, audience, update mode
- **Edge Cases**: Monorepo structures, >25 node diagrams (auto-split), mixed-mode PRD-code mismatches, manual annotation preservation
- **Workflow**: Always validate Mermaid syntax before preview, enforce semantic node IDs, auto-split at thresholds
- **Common Mistakes**: Hallucinated nodes without evidence, missing error paths, using `end` as node ID, sequential node IDs instead of semantic, unlabeled edges

### 3. `skills/ux-flowchart-generate/template.md`

Two output templates:

**Template A — flowchart.md:**
- Header metadata (skill, source, goal, generated date, confidence)
- Executive Summary (overview)
- Diagram (Mermaid code block with metadata comments, node sections, edge sections, style definitions)
- Unknowns & Gaps table
- Diagram Metrics table
- Validation results
- Next skills references
- Metadata table

**Template B — evidence-map.md:**
- Header (companion reference to flowchart.md)
- Confidence key
- Node evidence table (Node ID | Label | PRD Ref | Code Path | Code Symbol | Test Path | Confidence | Status | Notes)
- Mismatches section (mixed mode only)
- Source file index

## Files to Modify

### 4. `scripts/seeds/config.md`

Add row to Available Skills table:
```
| ux-flowchart-generate | `/ux-flowchart-generate` | Generate Mermaid flowcharts from PRD/docs/codebase with evidence maps |
```

## Output Structure

```
$JAAN_OUTPUTS_DIR/ux/diagrams/{id}-{slug}/
  ├── {id}-flowchart-{slug}.md       # Main diagram + unknowns + metrics
  └── {id}-evidence-map-{slug}.md    # Traceability table + mismatches
```

## Post-Creation Steps

1. Create git branch `skill/ux-flowchart-generate` from `dev`
2. Write all files
3. Validate v3.0.0 compliance (all `$JAAN_*` env vars, no hardcoded paths)
4. Validate against `docs/extending/create-skill.md` spec
5. Create docs via `/docs-create`
6. Commit and create PR to `dev`

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Subdomain | `ux/diagrams` | Matches research spec; distinct from `ux/heatmap`, `ux/research` |
| Report type | `flowchart` | Consistent with subdomain naming convention |
| Two output files | Yes | Separation of diagram from traceability data (per research) |
| Tech-aware | Yes | Reads codebase for `repo`/`mixed` source types |
| Mermaid version | v11.4.1 constraints | GitHub's confirmed version — strict security, Dagre-only |
| Auto-split | >25 nodes or >50 edges or >15 cyclomatic | Per research thresholds |
| Confidence scoring | Fully automated, not manually overridable | Prevents score inflation |

## Verification

1. Run `/skill-update ux-flowchart-generate` to validate v3.0.0 compliance
2. Test with example: `/ux-flowchart-generate prd path/to/prd.md userflow`
3. Verify output files created in correct structure
4. Verify Mermaid renders on GitHub
5. Verify evidence map has entries for all diagram nodes
