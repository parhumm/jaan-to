---
title: "ux-flowchart-generate"
sidebar_position: 4
---

# /jaan-to:ux-flowchart-generate

> Generate GitHub-renderable Mermaid flowcharts from PRDs, docs, codebases, or any combination — with evidence maps and confidence scoring.

---

## What It Does

Generates Mermaid flowcharts that render directly on GitHub, with:
- **Evidence maps** tracing every diagram node to its PRD section, code path, and test file
- **Confidence scoring** (automated, based on evidence completeness)
- **Unknowns lists** identifying gaps and mismatches between PRD and code
- **Quality gates** (17 machine-checkable + 5 human-review flags)

Supports four source types (`prd`, `doc`, `repo`, `mixed`) and four diagram goals (`userflow`, `systemflow`, `architecture`, `stateflow`).

---

## Usage

**PRD-only user flow:**
```
/jaan-to:ux-flowchart-generate prd docs/prd-auth.md userflow "password reset"
```

**Repo-only system flow:**
```
/jaan-to:ux-flowchart-generate repo src/middleware/ systemflow "auth"
```

**Mixed mode (PRD + code):**
```
/jaan-to:ux-flowchart-generate mixed docs/prd-checkout.md src/checkout/ userflow
```

**Interactive wizard:**
```
/jaan-to:ux-flowchart-generate
```

---

## Parameters

| Param | Required | Values | Default |
|---|---|---|---|
| `source_type` | Yes | `prd`, `doc`, `repo`, `mixed` | — |
| `paths` | Yes | Space-separated file/directory paths | — |
| `goal` | Yes | `userflow`, `systemflow`, `architecture`, `stateflow` | `userflow` |
| `scope` | No | Free text to narrow focus | Entire source |

---

## What It Asks

| Question | When |
|----------|------|
| Source type? | If not provided in arguments |
| File paths? | If not provided in arguments |
| Diagram goal? | If not provided in arguments |
| Audience? | Always (determines label language) |
| Update mode? | When existing diagram detected |
| Scope confirmation? | When scope provided |
| Proceed with generation? | Before generation (HARD STOP) |
| Write to file? | Before writing output |
| Feedback? | After writing |

---

## Output

**Path**: `jaan-to/outputs/ux/diagrams/{id}-{slug}/`

**Files produced**:

| File | Contents |
|------|----------|
| `{id}-flowchart-{slug}.md` | Mermaid diagram + unknowns table + metrics + validation results |
| `{id}-evidence-map-{slug}.md` | Node-by-node traceability table + mismatches + source file index |

**Example**: `jaan-to/outputs/ux/diagrams/01-password-reset/01-flowchart-password-reset.md`

---

## Diagram Conventions

### Node Shapes

| UX Concept | Shape | Syntax |
|---|---|---|
| Entry point | Stadium (pill) | `id([Label])` |
| User action | Rectangle | `id[Label]` |
| Decision | Diamond | `id{Label?}` |
| Success | Double circle | `id(((Label)))` |
| Error | Rectangle + red class | `id[Error: Label]:::error` |
| Loading | Rounded rectangle | `id(Label)` |
| External API | Subroutine | `id[[Label]]` |
| Data store | Cylinder | `id[(Label)]` |

### Edge Types

| Type | Syntax | Use |
|---|---|---|
| Happy path | `-->` | Primary flow |
| Error path | `-.->` | Fallback/error |
| Critical | `==>` | Emphasis (max 1-2) |
| Mismatch | `-.->` + `:::mismatch` | PRD-code discrepancy |

---

## Confidence Scoring

Evidence-based, automated (no manual override):

| Level | Symbol | Criteria |
|---|---|---|
| High | 🟢 | PRD + code + test all present |
| Medium | 🟡 | PRD or code (not both), or missing test |
| Low | 🔴 | Inferred only — no direct trace |
| Unknown | ⚫ | Not yet assessed |

---

## Quality Gates

17 machine-checkable gates that must pass before output:
- Syntax valid, node cap (≤25), edge cap (≤50), text cap (<40K chars)
- Cyclomatic complexity (≤15), no orphans, complete decisions
- Entry/exit nodes exist, error paths present, all edges labeled
- Semantic IDs, no reserved words, direction set, styles defined
- Metadata present, evidence complete

5 human-review flags reported but not blocking:
- Audience fit, abstraction consistency, flow direction, UI states, mismatches flagged

---

## Auto-Split

Large diagrams are automatically split when any threshold is exceeded:

| Metric | Threshold |
|---|---|
| Nodes | >25 |
| Edges | >50 |
| Cyclomatic | >15 |
| Parallel branches | >8 |
| Mermaid chars | >20,000 |

Split produces an overview diagram with subprocess nodes linking to detail diagrams in the same folder.

---

## Tips

- Use `mixed` mode for the richest output — it cross-references PRD against code and flags mismatches
- Narrow scope for large codebases (e.g., "auth module" not entire repo)
- Provide test file paths for higher confidence scores
- For `userflow` goal, labels use user-facing language; for `systemflow`, technical terms are fine
- GitHub renders Mermaid v11.4.1 — no click events, tooltips, or FontAwesome

---

## Learning

This skill reads from:
```
jaan-to/learn/jaan-to:ux-flowchart-generate.learn.md
```

Add feedback:
```
/jaan-to:learn-add ux-flowchart-generate "Always validate mermaid syntax before preview"
```

---

[Back to UX Skills](README.md)
