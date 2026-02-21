# UX Flowchart: {{flow_name}}

> **Skill:** `/jaan-to:ux-flowchart-generate`
> **Source(s):** `{{source_type}}` — {{source_paths}}
> **Goal:** {{goal}}
> **Generated:** {{date}}
> **Confidence:** {{overall_confidence}} — {{confidence_rationale}}

## Executive Summary

{{overview}}

## Diagram

```mermaid
flowchart {{direction}}
    %% @generated-by: jaan-to:ux-flowchart-generate
    %% @sources: {{source_paths}}
    %% @generated: {{date}}
    %% @version: {{version}}

    %% === NODES ===
    {{nodes}}

    %% === EDGES: Happy Path ===
    {{happy_edges}}

    %% === EDGES: Error Paths ===
    {{error_edges}}

    %% === EDGES: Mismatch (PRD ↔ Code) ===
    {{mismatch_edges}}

    %% ===== MANUAL (DO NOT AUTO-EDIT) =====
    {{manual_section}}
    %% ===== END MANUAL =====

    %% === STYLES ===
    classDef error fill:#FEE2E2,stroke:#DC2626,color:#991B1B
    classDef success fill:#D1FAE5,stroke:#059669,color:#065F46
    classDef decision fill:#FEF3C7,stroke:#D97706,color:#92400E
    classDef entry fill:#DBEAFE,stroke:#2563EB,color:#1E40AF
    classDef mismatch fill:#FEF3C7,stroke:#DC2626,stroke-width:3px,stroke-dasharray:5 5
    {{class_assignments}}
```

## Unknowns & Gaps

| # | Unknown | Impact | Source Gap | Suggested Resolution |
|---|---|---|---|---|
{{#unknowns}}
| {{id}} | {{unknown}} | {{impact}} | {{source_gap}} | {{resolution}} |
{{/unknowns}}

## Diagram Metrics

| Metric | Value | Threshold |
|---|---|---|
| Nodes | {{node_count}} | ≤ 25 |
| Edges | {{edge_count}} | ≤ 50 |
| Cyclomatic complexity | {{cyclomatic}} | ≤ 15 |
| Subgraphs | {{subgraph_count}} | ≤ 5 |
| Mermaid chars | {{char_count}} | < 40,000 |
| Evidence coverage | {{high_confidence_pct}}% nodes at 🟢 | Target: ≥ 50% |

## Validation

{{#quality_gates}}
- {{status}} {{gate_name}} — {{description}}
{{/quality_gates}}

---

*→ Next skills: `ux:wireframe-notes`, `dev:fe-state-map`, `data:event-spec`*
*→ Evidence detail: see `evidence-map.md` in this directory*

---

## Metadata

| Field | Value |
|-------|-------|
| Flow Name | {{flow_name}} |
| Generated | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/ux/diagrams/{{id}}-{{slug}}/ |
| Skill | ux-flowchart-generate |
| Source Type | {{source_type}} |
| Goal | {{goal}} |
| Version | 3.0 |

---
---
---

# Evidence Map: {{flow_name}}

> Companion to `flowchart.md` — traces every diagram node to its source.
> **Generated:** {{date}}

## Confidence Key

| Level | Symbol | Criteria |
|---|---|---|
| High | 🟢 | PRD + code + test |
| Medium | 🟡 | PRD or code (not both), or missing test |
| Low | 🔴 | Inferred only — no direct trace |
| Unknown | ⚫ | Not yet assessed |

## Node Evidence

| Node ID | Label | PRD Ref | Code Path | Code Symbol | Test Path | Confidence | Status | Notes |
|---|---|---|---|---|---|---|---|---|
{{#evidence}}
| `{{node_id}}` | {{label}} | {{prd_ref}} | {{code_path}} | {{code_symbol}} | {{test_path}} | {{confidence}} | {{status}} | {{notes}} |
{{/evidence}}

## Mismatches

{{#has_mismatches}}
| # | Description | PRD Says | Code Does | Severity | Recommendation |
|---|---|---|---|---|---|
{{#mismatches}}
| {{id}} | {{description}} | {{prd_says}} | {{code_does}} | {{severity}} | {{recommendation}} |
{{/mismatches}}
{{/has_mismatches}}

## Source File Index

| File Path | Last Modified | Nodes Derived |
|---|---|---|
{{#source_files}}
| `{{path}}` | {{last_modified}} | {{nodes_derived}} |
{{/source_files}}

---

## Metadata

| Field | Value |
|-------|-------|
| Companion To | {{id}}-flowchart-{{slug}}.md |
| Generated | {{date}} |
| Output Path | {{env:JAAN_OUTPUTS_DIR}}/ux/diagrams/{{id}}-{{slug}}/ |
| Skill | ux-flowchart-generate |
| Version | 3.0 |
