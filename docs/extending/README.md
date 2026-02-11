---
title: "Extending jaan.to"
sidebar_position: 1
---

# Extending jaan.to

> Add new skills and hooks.

---

## What Can You Extend?

| Extension | Difficulty | Reference |
|-----------|------------|-----------|
| [New Skill](create-skill.md) | Medium | Complete specification for skill creation |
| [New Hook](create-hook.md) | Easy | Add automation trigger |

---

## Extension Principles

1. **Follow patterns** - Match existing naming and structure
2. **Start minimal** - Add complexity only when needed
3. **Test first** - Verify behavior before committing
4. **Document** - Add docs alongside implementation

---

## Quick Reference

**Skill location**: `skills/{name}/`

**Hook location**: `scripts/{hook-name}.sh`

**Register hook**: `hooks/hooks.json` (plugin-level) or SKILL.md frontmatter (skill-scoped)

---

## Standards & Protocols

| Document | Purpose |
|----------|---------|
| [language-protocol.md](language-protocol.md) | Language/i18n protocol |
| [naming-conventions.md](naming-conventions.md) | Naming standards |
| [output-structure.md](output-structure.md) | Output directory structure |
| [pre-execution-protocol.md](pre-execution-protocol.md) | Skill pre-execution steps |
| [dev-workflow.md](dev-workflow.md) | Development workflow |
| [git-pr-workflow.md](git-pr-workflow.md) | Git/PR workflow |

---

## Skill Reference Files

Extracted reference material loaded on demand by skills (see [Token Strategy](../token-strategy.md)):

| File | Skill |
|------|-------|
| [dev-project-assemble-reference.md](dev-project-assemble-reference.md) | dev-project-assemble |
| [backend-service-implement-reference.md](backend-service-implement-reference.md) | backend-service-implement |
| [qa-test-generate-reference.md](qa-test-generate-reference.md) | qa-test-generate |
| [sec-audit-remediate-reference.md](sec-audit-remediate-reference.md) | sec-audit-remediate |
| [devops-infra-scaffold-reference.md](devops-infra-scaffold-reference.md) | devops-infra-scaffold |
| [detect-dev-reference.md](detect-dev-reference.md) | detect-dev |
| [detect-pack-reference.md](detect-pack-reference.md) | detect-pack |
| [backend-export-formats.md](backend-export-formats.md) | backend-task-breakdown |
| [microcopy-reference.md](microcopy-reference.md) | ux-microcopy-write |
| [ux-research-templates.md](ux-research-templates.md) | ux-research-synthesize |
| [research-methodology.md](research-methodology.md) | pm-research-about |
| [v3-compliance-reference.md](v3-compliance-reference.md) | skill-create |

---

## Next Steps

- [Create a Skill](create-skill.md) - Complete specification (schemas, examples, validation)
- [Create a Hook](create-hook.md) - Full walkthrough
