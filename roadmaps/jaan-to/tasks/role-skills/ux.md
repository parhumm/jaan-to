# UX Skills (20)

> Part of [Role Skills Catalog](../role-skills.md) | Phase 4 + Phase 6

**Chains**: Research → Synthesize → Persona | Journey → Edge Cases → Flow | IA: Sitemap → Taxonomy | Wireframe → Review → UI → Handoff | Copy → Errors | A11y → ARIA | Onboarding → Tooltips

## Userflow Schema

```mermaid
flowchart TD
    jaan-to-ux-research-plan["ux-research-plan<br>Research Plan<br>Questions + method + participants"] --> ux-research-synthesize["ux-research-synthesize<br>Research Synthesize<br>Themes + recommendations"]
    ux-research-synthesize["ux-research-synthesize<br>Research Synthesize<br>Themes + recommendations"] --> jaan-to-ux-persona-create["ux-persona-create<br>Persona Create<br>Goals + pains + JTBD"]
    jaan-to-ux-persona-create["ux-persona-create<br>Persona Create<br>Goals + pains + JTBD"] -.-> jaan-to-pm-jtbd-map["pm-jtbd-map<br>PM: jtbd-map"]
    jaan-to-ux-persona-create["ux-persona-create<br>Persona Create<br>Goals + pains + JTBD"] -.-> jaan-to-pm-persona-card["pm-persona-card<br>PM: persona-card"]
    jaan-to-ux-competitive-review["ux-competitive-review<br>Competitive Review<br>Flows + patterns + opportunities"] -.-> jaan-to-pm-positioning-brief["pm-positioning-brief<br>PM: positioning-brief"]
    jaan-to-ux-journey-map["ux-journey-map<br>Journey Map<br>Steps + pain points + metrics"] --> jaan-to-ux-journey-edge-cases["ux-journey-edge-cases<br>Journey Edge Cases<br>Edge cases + recovery paths"]
    jaan-to-ux-journey-edge-cases["ux-journey-edge-cases<br>Journey Edge Cases<br>Edge cases + recovery paths"] --> jaan-to-ux-flow-spec["ux-flow-spec<br>Flow Spec<br>Happy path + all states"]
    jaan-to-ux-flow-spec["ux-flow-spec<br>Flow Spec<br>Happy path + all states"] --> ux-microcopy-write["ux-microcopy-write<br>Microcopy Write<br>Labels + errors + toasts + tone"]
    jaan-to-ux-flow-spec["ux-flow-spec<br>Flow Spec<br>Happy path + all states"] -.-> jaan-to-dev-fe-state-machine["dev-fe-state-machine<br>DEV: fe-state-machine"]
    jaan-to-ux-heuristic-review["ux-heuristic-review<br>Heuristic Review<br>Issues + severity + quick wins"] --> jaan-to-ux-flow-spec["ux-flow-spec<br>Flow Spec<br>Happy path + all states"]
    jaan-to-ux-sitemap["ux-sitemap<br>Sitemap<br>Pages + entry points + IA risks"] --> jaan-to-ux-taxonomy["ux-taxonomy<br>Taxonomy<br>Naming rules + attributes"]
    jaan-to-ux-taxonomy["ux-taxonomy<br>Taxonomy<br>Naming rules + attributes"] --> jaan-to-ux-wireframe-screens["ux-wireframe-screens<br>Wireframe Screens<br>Screen list + states + interactions"]
    jaan-to-ux-wireframe-screens["ux-wireframe-screens<br>Wireframe Screens<br>Screen list + states + interactions"] --> jaan-to-ux-wireframe-review["ux-wireframe-review<br>Wireframe Review<br>Usability checklist + issues"]
    jaan-to-ux-wireframe-review["ux-wireframe-review<br>Wireframe Review<br>Usability checklist + issues"] --> jaan-to-ux-ui-spec-states["ux-ui-spec-states<br>UI Spec States<br>State list + triggers + copy"]
    jaan-to-ux-ui-spec-states["ux-ui-spec-states<br>UI Spec States<br>State list + triggers + copy"] --> jaan-to-ux-ui-handoff-notes["ux-ui-handoff-notes<br>UI Handoff Notes<br>Components + tokens + animation"]
    jaan-to-ux-ui-handoff-notes["ux-ui-handoff-notes<br>UI Handoff Notes<br>Components + tokens + animation"] -.-> dev-fe-task-breakdown["dev-fe-task-breakdown<br>DEV: fe-task-breakdown"]
    ux-microcopy-write["ux-microcopy-write<br>Microcopy Write<br>Labels + errors + toasts + tone"] --> jaan-to-ux-error-messages["ux-error-messages<br>Error Messages<br>User-friendly errors + recovery"]
    jaan-to-ux-a11y-audit["ux-a11y-audit<br>A11y Audit<br>Issues + fix checklist"] --> jaan-to-ux-a11y-aria-notes["ux-a11y-aria-notes<br>A11y ARIA Notes<br>Roles/labels + focus management"]
    jaan-to-ux-a11y-aria-notes["ux-a11y-aria-notes<br>A11y ARIA Notes<br>Roles/labels + focus management"] -.-> dev-fe-task-breakdown["dev-fe-task-breakdown<br>DEV: fe-task-breakdown"]
    jaan-to-ux-onboarding-steps["ux-onboarding-steps<br>Onboarding Steps<br>Steps + activation + drop-offs"] --> jaan-to-ux-onboarding-tooltips["ux-onboarding-tooltips<br>Onboarding Tooltips<br>Tooltip copy + skip/done patterns"]
    jaan-to-ux-onboarding-tooltips["ux-onboarding-tooltips<br>Onboarding Tooltips<br>Tooltip copy + skip/done patterns"] -.-> jaan-to-data-event-spec["data-event-spec<br>DATA: event-spec"]

    style jaan-to-pm-jtbd-map fill:#f0f0f0,stroke:#999
    style jaan-to-pm-persona-card fill:#f0f0f0,stroke:#999
    style jaan-to-pm-positioning-brief fill:#f0f0f0,stroke:#999
    style jaan-to-dev-fe-state-machine fill:#f0f0f0,stroke:#999
    style dev-fe-task-breakdown fill:#f0f0f0,stroke:#999
    style jaan-to-data-event-spec fill:#f0f0f0,stroke:#999
```

**Legend**: Solid = internal | Dashed = cross-role exit | Gray nodes = other roles

### /jaan-to-ux-research-plan

- **Logical**: `ux:research-plan`
- **Description**: Research plan: questions, method, participants, script outline, timeline, deliverables
- **Quick Win**: No - planning artifact
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-research-synthesize`
- **MCP Required**: Clarity (pain signals), Figma (flow context)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/research/{slug}/research-plan.md`

### ✅ /ux-research-synthesize

- **Logical**: `ux:research-synthesize`
- **Description**: Synthesize research findings into themes, executive summary, and recommendations
- **Reference**: [Building a Production-Ready UX Research Synthesis Skill: Comprehensive Research Foundation/jaan-to/outputs/research/47-ux-research-synthesize.md)
- **Quick Win**: Yes - pattern recognition, summarization
- **AI Score**: 5 | **Rank**: #8
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-persona-create`
- **MCP Required**: None (raw data input)
- **Input**: [study_name] [data_sources]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/research/{slug}/synthesis.md`
- **Failure Modes**: Too long reports; no actionable recommendations
- **Quality Gates**: Stakeholder feedback positive; action items tracked

### /jaan-to-ux-persona-create

- **Logical**: `ux:persona-create`
- **Description**: User personas with goals, pain points, behaviors, and Jobs-to-be-Done
- **Quick Win**: Yes - synthesize data, identify patterns
- **AI Score**: 5 | **Rank**: #16
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `pm-jtbd-map`, `pm-persona-card`
- **MCP Required**: None (research data input), Clarity (optional)
- **Input**: [research_data] [segment]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/personas/{slug}/persona.md`
- **Failure Modes**: Based on assumptions; not validated; too many personas
- **Quality Gates**: Validation interviews; periodic reviews; design decisions reference personas

### /jaan-to-ux-competitive-review

- **Logical**: `ux:competitive-review`
- **Description**: Competitive teardown: step-by-step flows, patterns, strengths/weaknesses, opportunities
- **Quick Win**: No - needs Figma MCP
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `pm-positioning-brief`
- **MCP Required**: Figma (optional), GA4/Clarity (validate assumptions)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/benchmark/{slug}/competitive-review.md`

### /jaan-to-ux-journey-map

- **Logical**: `ux:journey-map`
- **Description**: Step-by-step journey map, pain points + opportunities, metrics to watch per step
- **Quick Win**: Yes
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-journey-edge-cases`
- **MCP Required**: None
- **Input**: [persona] [task]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/journey/{slug}/journey-map.md`

### /jaan-to-ux-journey-edge-cases

- **Logical**: `ux:journey-edge-cases`
- **Description**: Edge-case list, recovery paths + UI requirements, "must not happen" failures
- **Quick Win**: Yes
- **Key Points**:
  - Include entry points and handoffs (email/push/search/support)
  - Identify moments of doubt and decision points
  - Capture emotions + frictions
- **→ Next**: `ux-flow-spec`
- **MCP Required**: None
- **Input**: [flow]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/journey/{slug}/edge-cases.md`

### /jaan-to-ux-sitemap

- **Logical**: `ux:sitemap`
- **Description**: Sitemap + page responsibilities, entry points + cross-links, IA risks (deep nesting, duplicates)
- **Quick Win**: Yes
- **Key Points**:
  - Group by user intent, not internal org
  - Define page responsibilities
  - Create naming rules to avoid drift
- **→ Next**: `ux-taxonomy`
- **MCP Required**: None
- **Input**: [feature]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/ia/{slug}/sitemap.md`

### /jaan-to-ux-taxonomy

- **Logical**: `ux:taxonomy`
- **Description**: Naming + grouping rules, attribute set (what metadata matters), examples + anti-examples
- **Quick Win**: Yes
- **Key Points**:
  - Group by user intent, not internal org
  - Define page responsibilities
  - Create naming rules to avoid drift
- **→ Next**: `ux-wireframe-screens`
- **MCP Required**: None
- **Input**: [content-types]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/ia/{slug}/taxonomy.md`

### /jaan-to-ux-wireframe-screens

- **Logical**: `ux:wireframe-screens`
- **Description**: Screen list by step, required states per screen, interaction notes
- **Quick Win**: Yes
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-wireframe-review`
- **MCP Required**: None
- **Input**: [journey]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/wireframe/{slug}/screens.md`

### /jaan-to-ux-wireframe-review

- **Logical**: `ux:wireframe-review`
- **Description**: Usability checklist, heuristic issues to look for, missing-state detector
- **Quick Win**: Yes
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-ui-spec-states`
- **MCP Required**: None
- **Input**: [wireframes]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/wireframe/{slug}/review-checklist.md`

### /jaan-to-ux-flow-spec

- **Logical**: `ux:flow-spec`
- **Description**: Flow spec: happy path + empty/loading/error states + edge cases + implementation notes
- **Quick Win**: Yes - flow documentation
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-microcopy-write`, `dev-fe-state-machine`
- **MCP Required**: Figma (flow/state extraction)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/flows/{slug}/flow-spec.md`

### /jaan-to-ux-heuristic-review

- **Logical**: `ux:heuristic-review`
- **Description**: Heuristic review: issues, severity, recommended fixes, quick wins, usability principles
- **Quick Win**: No - structured review
- **Key Points**:
  - Specify key states early (empty/error/loading)
  - Validate primary task completion
  - Include content hierarchy (what matters first)
- **→ Next**: `ux-flow-spec`
- **MCP Required**: Clarity (behavior evidence), Figma (screens)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/review/{slug}/heuristic-review.md`

### /jaan-to-ux-ui-spec-states

- **Logical**: `ux:ui-spec-states`
- **Description**: State list + triggers, copy requirements per state, visual priority guidance
- **Quick Win**: No - needs Figma
- **Key Points**:
  - Ensure state coverage: success/error/empty/loading
  - Document component usage to reduce custom builds
  - Align spacing/typography with system tokens
- **→ Next**: `ux-ui-handoff-notes`
- **MCP Required**: Figma (screens/states)
- **Input**: [screen]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/ui/{slug}/spec-states.md`

### /jaan-to-ux-ui-handoff-notes

- **Logical**: `ux:ui-handoff-notes`
- **Description**: Dev handoff notes, components + tokens used, interaction + animation guidance
- **Quick Win**: No - needs Figma
- **Key Points**:
  - Ensure state coverage: success/error/empty/loading
  - Document component usage to reduce custom builds
  - Align spacing/typography with system tokens
- **→ Next**: `dev-fe-task-breakdown`
- **MCP Required**: Figma (design specs)
- **Input**: [design]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/ui/{slug}/handoff-notes.md`

### ✅ /ux-microcopy-write

- **Logical**: `ux:microcopy-write`
- **Description**: Microcopy pack: labels, helper text, errors, toasts, confirmations, empty states, tone rules
- **Reference**: [UX Microcopy Writing Skill: Comprehensive Research Document](../../../../jaan-to/outputs/research/56-ux-microcopy-write.md)
- **Quick Win**: Yes - simple content
- **Key Points**:
  - Use verbs, be specific, avoid blame
  - Error messages: what happened + what to do next
  - Maintain tone rules and consistency
- **→ Next**: `ux-error-messages`
- **MCP Required**: Figma (components + strings)
- **Input**: [initiative]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/content/{slug}/microcopy.md`

### /jaan-to-ux-error-messages

- **Logical**: `ux:error-messages`
- **Description**: User-friendly errors, next steps + recovery actions, logging hints (error codes mapping)
- **Quick Win**: Yes
- **Key Points**:
  - Use verbs, be specific, avoid blame
  - Error messages: what happened + what to do next
  - Maintain tone rules and consistency
- **→ Next**: —
- **MCP Required**: None
- **Input**: [errors]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/content/{slug}/error-messages.md`

### /jaan-to-ux-a11y-audit

- **Logical**: `ux:a11y-audit`
- **Description**: Issues + severity, fix checklist, quick wins vs structural changes
- **Quick Win**: Yes
- **Key Points**:
  - Contrast, focus order, keyboard operability
  - Labels for inputs, meaningful headings
  - Don't rely on color alone
- **→ Next**: `ux-a11y-aria-notes`
- **MCP Required**: None
- **Input**: [screens]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/a11y/{slug}/audit.md`

### /jaan-to-ux-a11y-aria-notes

- **Logical**: `ux:a11y-aria-notes`
- **Description**: ARIA roles/labels guidance, focus management notes, accessible patterns reminders
- **Quick Win**: Yes
- **Key Points**:
  - Contrast, focus order, keyboard operability
  - Labels for inputs, meaningful headings
  - Don't rely on color alone
- **→ Next**: `dev-fe-task-breakdown`
- **MCP Required**: None
- **Input**: [components]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/a11y/{slug}/aria-notes.md`

### /jaan-to-ux-onboarding-steps

- **Logical**: `ux:onboarding-steps`
- **Description**: Onboarding steps + activation event, drop-off risks, measurement plan pointers
- **Quick Win**: Yes
- **Key Points**:
  - Define activation event clearly
  - Use progressive disclosure (don't teach everything)
  - Tooltips must be contextual and skippable
- **→ Next**: `ux-onboarding-tooltips`
- **MCP Required**: None
- **Input**: [product]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/onboarding/{slug}/steps.md`

### /jaan-to-ux-onboarding-tooltips

- **Logical**: `ux:onboarding-tooltips`
- **Description**: Tooltip copy set, tone rules + character limits, "skip/done" patterns
- **Quick Win**: Yes
- **Key Points**:
  - Define activation event clearly
  - Use progressive disclosure (don't teach everything)
  - Tooltips must be contextual and skippable
- **→ Next**: `data-event-spec`
- **MCP Required**: None
- **Input**: [steps]
- **Output**: `$JAAN_OUTPUTS_DIR/ux/onboarding/{slug}/tooltips.md`
