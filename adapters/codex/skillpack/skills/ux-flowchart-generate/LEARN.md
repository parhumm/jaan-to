# Lessons: ux-flowchart-generate

> Last updated: 2026-02-09
>
> Plugin-side seed lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:ux-flowchart-generate.learn.md`

Accumulated lessons from flowchart generation executions, seeded from comprehensive Mermaid + UX flowchart research (40+ sources).

---

## Better Questions

### Phase 1: Analysis

**Source Availability**:
- "Which source type best describes your input?" — Determines extraction strategy and confidence expectations
- "Are there test files covering this flow?" — Enables High confidence scoring
- "Is this a new diagram or an update to an existing one?" — Triggers diff check (Phase 0)

**Diagram Goal**:
- "What's the primary goal: user flow, system flow, architecture overview, or state diagram?" — Determines diagram type and label language
- "Should I include all error paths and edge cases, or focus on the happy path?" — Scope narrowing prevents spaghetti diagrams

**Audience**:
- "Who will read this diagram: developers, designers, product managers, or mixed?" — Determines jargon level in node labels
- "Will this be embedded in a PR, a Confluence page, or a standalone document?" — Affects detail level

**Scope**:
- "Can you narrow the scope? (e.g., 'checkout only', 'auth module')" — Large scopes produce >25 node diagrams that need splitting

### Phase 2: Generation

**Update Mode**:
- "The existing diagram has manual annotations. Should I preserve them?" — Prevents destroying hand-added notes
- "Should changes be highlighted (green=added, yellow=modified)?" — Useful for PR reviews

---

## Edge Cases

### Monorepo Structures
- Multiple services may contribute to a single user flow
- Use subgraphs per service when `architecture` goal is selected
- For `mixed` mode in monorepos, specify which service directories to analyze

### >25 Node Diagrams (Auto-Split)
- Triggered when node count, edge count, cyclomatic complexity, parallel branches, or char count exceed thresholds
- Overview diagram uses `[[See: detail-{name}.md]]` subprocess nodes
- Each detail diagram is a separate file in the same output folder
- Evidence map covers ALL diagrams (single file with "Diagram" column)

### Mixed-Mode PRD-Code Mismatches
- PRD specifies feature but code doesn't implement it → `MISMATCH (PRD-only)` status
- Code implements something not in PRD → `MISMATCH (code-only)` status
- Both cases get dotted edges with `:::mismatch` styling and `⚠️` labels
- Mismatches table in evidence map documents discrepancies with severity

### Manual Annotation Preservation
- Content between `%% ===== MANUAL (DO NOT AUTO-EDIT) =====` markers is preserved across regenerations
- If markers are malformed, abort and warn user
- Incremental updates (<30% node changes) always preserve manual sections

### stateDiagram-v2 Selection
- Only selected when goal is `stateflow` AND >4 distinct states with non-trivial transitions
- All other goal types default to `flowchart` diagram type
- State diagrams have different node/edge conventions than flowcharts

### GitHub Rendering Limits
- GitHub runs Mermaid v11.4.1 with strict security
- 50K char hard limit; skill targets <40K
- 500 edge hard limit; skill targets ≤50
- No click events, tooltips, JavaScript, or FontAwesome
- Dagre-only layout (ELK unavailable)

---

## Common Mistakes

### Analysis Phase

❌ **Hallucinating nodes without evidence** — AI systems consistently fabricate components when generating from source code
✅ Every node requires an evidence map entry. Nodes without source traces get 🔴 Low confidence and are flagged

❌ **Missing error paths** — Forgetting error/fallback edges from decision nodes
✅ Quality gate DECISION_COMPLETE requires ≥2 outgoing edges per diamond; ERROR_PATHS requires ≥1 error edge

❌ **Using `end` as a node ID** — Mermaid reserved word that breaks rendering
✅ Use semantic IDs like `success_done` or `success_complete`

❌ **Sequential node IDs** (`n1`, `n2`, `n3`) instead of semantic names
✅ Use `{prefix}_{descriptive_name}` pattern: `entry_login`, `dec_email_valid`, `err_timeout`

❌ **Unlabeled edges** — Makes diagram ambiguous
✅ All edges MUST have labels, even simple ones like `|next|` or `|success|`

❌ **Mixing abstraction levels** — "Click button" alongside "Execute SQL query"
✅ One diagram = one abstraction level. Use `userflow` goal for user-facing, `systemflow` for technical

❌ **Using HTML in labels** — Stripped by DOMPurify on GitHub
✅ Use Markdown strings for formatting if needed

❌ **Emoji overuse in node labels** — May break GitHub rendering
✅ Use emoji sparingly; prefer classDef styling for visual differentiation

### Generation Phase

❌ **Overriding confidence scores manually** — Inflates trustworthiness
✅ Confidence is derived from evidence completeness automatically. Never override to higher than evidence supports

❌ **Skipping quality gates** — Produces invalid or unrenderable diagrams
✅ All 17 machine-checkable gates must pass before output. Fix issues, don't skip

❌ **Not splitting large diagrams** — Results in unreadable spaghetti
✅ Auto-split at >25 nodes, >50 edges, >15 cyclomatic, >8 parallel branches, >20K chars

❌ **Forgetting manual section markers** — Manual edits lost on regeneration
✅ Always include `%% ===== MANUAL (DO NOT AUTO-EDIT) =====` markers, even if empty

---

## Workflow

### Best Practices

**Source Parsing (Step 2)**:
- For `repo` mode, read `$JAAN_CONTEXT_DIR/tech.md` first to know which glob/grep patterns to use
- For `mixed` mode, parse PRD first, then code — cross-reference to detect mismatches
- Flag gaps immediately; don't wait for evidence map

**Mermaid Generation (Step 7)**:
- Declare all nodes first, then all edges, one per line — cleaner diffs
- Use `%%` comment headers to separate sections
- Use `classDef` instead of inline styles
- Keep IDs stable across regenerations for incremental updates

**Evidence Map (Step 8)**:
- Build evidence map in parallel with Mermaid generation, not after
- For `repo` mode, use Grep to find test files covering each code symbol
- Confidence derivation is automated — run the formula, don't estimate

**Quality Gates (Step 10)**:
- Run gates BEFORE preview to catch issues early
- If NODE_CAP or EDGE_CAP fails, split the diagram rather than removing nodes
- If DECISION_COMPLETE fails, add missing error paths

**Update Mode (Phase 0)**:
- Always check for existing diagram before generating
- Preserve manual sections between markers
- Use classDef `added`, `modified` to highlight changes
- Include Changelog section showing what changed

### Time Savers

- For small PRDs (<50 lines): Skip scope clarification, analyze entire document
- For large codebases: Narrow scope first — "auth module" not entire repo
- For `mixed` mode: Start with PRD structure, overlay code evidence
- Reuse node IDs from previous diagrams when updating

## Research Methodology References

This skill implements best practices from:

- **30 heuristics** across UX standards, Mermaid constraints, evidence mapping, quality gates, and updating/diffing
- **NASA's 4-level Credibility Assessment Scale** — Adapted for confidence scoring
- **ISO/IEC/IEEE 29148:2018** — Bidirectional traceability standard
- **Mermaid-Sonar** — Research-backed complexity thresholds
- **GitLab Mermaid linter** — Production-proven syntax validation pattern

For complete research foundation: `$JAAN_OUTPUTS_DIR/research/64-ux-flowchart-generate.md` and `$JAAN_OUTPUTS_DIR/research/65-ux-flowchart-generate-skill.md`
