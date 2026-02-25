---
title: "LSP Support"
sidebar_position: 6
---

# LSP Support

> Bundle LSP server configs in plugin + make skills LSP-aware.

---

## Goal

Make jaan.to a code-intelligence-aware plugin by bundling LSP server configs and teaching skills to leverage diagnostics and code navigation. Users installing jaan.to get code intelligence out of the box, and skills become more powerful by using type-checked, navigation-aware workflows.

---

## Two Workstreams

### A: Bundle LSP Server Configs

Add LSP server definitions to the plugin so installing jaan.to auto-enables code intelligence.

| Priority | Language | Plugin ID | Binary Required |
|----------|----------|-----------|-----------------|
| 1 | TypeScript | `typescript-lsp` | `typescript-language-server` |
| 2 | Python | `pyright-lsp` | `pyright-langserver` |

**What this gives users:**
- Automatic diagnostics after every file edit (type errors, missing imports, syntax issues)
- Code navigation (jump to definition, find references, hover type info, list symbols)

**Implementation:**
- Add LSP server entries in plugin manifest or dedicated LSP config
- Reference: [plugins-reference#lsp-servers](https://code.claude.com/docs/en/plugins-reference#lsp-servers)
- Ensure graceful fallback when language server binary is not installed

### B: Make Skills LSP-Aware

Update skill workflows to leverage LSP capabilities when available.

**Capabilities skills can use:**
- `diagnostics` — get errors/warnings after generating or editing files
- `definition` — jump to definition of a symbol
- `references` — find all references to a symbol
- `hover` — get type information on a symbol
- `symbols` — list all symbols in a file or workspace
- `implementations` — find implementations of an interface/type
- `callHierarchy` — trace incoming/outgoing calls

---

## Examples: How LSP Makes Skills More Powerful

### `/dev-tech-plan`

**Without LSP:** Relies on grep-based search to understand code structure. May miss indirect dependencies or misread type relationships.

**With LSP:**
- **Jump-to-definition** to trace dependency chains before proposing architecture
- **Find-references** to assess blast radius of proposed changes
- **Call hierarchy** to map which services call what, informing decoupling decisions
- **Result:** Tech plans cite actual dependency graphs, not guesses

### `/qa-test-cases`

**Without LSP:** Generates test files that may have import errors or type mismatches. User has to fix manually.

**With LSP:**
- After generating test files, **diagnostics** report type errors instantly
- Skill **auto-fixes** missing imports and type mismatches before presenting output
- **Hover** on function signatures to generate accurate mock types
- **Result:** Test cases compile on first try

### `/backend-api-contract`

**Without LSP:** Reads route files with text search. May miss overloaded handlers or middleware.

**With LSP:**
- **Hover** for type info on existing endpoints to generate accurate OpenAPI specs
- **Find-implementations** to discover all handlers for a route (including middleware)
- **Symbols** to list all exported types for request/response schemas
- **Result:** OpenAPI contracts match actual code, not approximations

### `/pm-prd-write`

**Without LSP:** The context-scout agent uses file search to understand the codebase. Limited to filename/content matching.

**With LSP:**
- Context-scout agent uses **symbol search** to map codebase structure
- **Find-references** to quantify how widely a component is used (scope estimation)
- **Diagnostics** to surface existing tech debt relevant to the initiative
- **Result:** More accurate technical feasibility and effort sections in PRDs

### `/skill-create`

**Without LSP:** New skill scaffolding is template-based. No validation against actual plugin structure.

**With LSP:**
- **Diagnostics** validate generated YAML frontmatter and markdown structure
- **Symbols** to check for naming conflicts with existing skills
- **Result:** Fewer broken skills, faster iteration

---

## Dependencies

- Plugin manifest must support LSP server definitions (Phase 2.5 — done)
- Claude Code LSP tool enabled automatically when plugin installed with LSP config
- Language server binaries must be installed on user's system (document in README)

## Success Criteria

- [ ] At least 2 LSP server configs bundled (TypeScript + Python)
- [ ] At least 3 skills updated to leverage LSP diagnostics/navigation
- [ ] Documentation on how skill authors can use LSP in their skills
- [ ] Graceful degradation when LSP is unavailable (skills still work, just without LSP enhancements)
