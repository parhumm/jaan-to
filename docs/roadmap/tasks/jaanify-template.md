---
title: "Jaanify Starter Template"
sidebar_position: 24
---

# Jaanify Starter Template

> Phase 6 | Status: pending

## Problem

New users must manually configure jaan.to, understand the skill chain, and figure out the optimal workflow order. The `parhumm/jaanify` repo demonstrates a real project built with jaan.to, but it is a showcase — not a reusable template. There is no one-command way to bootstrap a new project with jaan.to pre-configured for shipping an idea.

## Solution

Convert `parhumm/jaanify` from a showcase project into a **smart starter template** that bootstraps a new project with jaan.to pre-configured. The template includes guided pipeline documentation showing which skills to run and in what order.

### Template Structure

```
my-project/
├── jaan-to/
│   ├── config/
│   │   └── settings.yaml       # Pre-configured with sensible defaults
│   ├── context/
│   │   ├── tech.md             # Placeholder — fill with your stack
│   │   ├── team.md             # Placeholder — fill with your team
│   │   ├── brand.md            # Placeholder — fill with your brand
│   │   └── boundaries.md       # Default safety rules
│   ├── templates/              # Pre-seeded output templates
│   ├── outputs/                # Empty, ready for skill outputs
│   └── learn/                  # Empty, ready for learning files
├── PIPELINE.md                 # Guided skill execution order
└── .claude/
    └── settings.json           # jaan-to plugin pre-installed
```

### Guided Pipeline (PIPELINE.md)

```
Step 1: Research    → /pm-research-about [your idea]
Step 2: PRD         → /pm-prd-write [initiative]
Step 3: Stories     → /pm-story-write [from PRD]
Step 4: Design      → /frontend-design [from PRD]
Step 5: Breakdown   → /frontend-task-breakdown [from design]
Step 6: Scaffold    → /backend-scaffold + /frontend-scaffold
Step 7: Implement   → /backend-service-implement [from scaffold]
Step 8: Test        → /qa-test-cases → /qa-test-generate → /qa-test-run
Step 9: Deploy      → /devops-infra-scaffold → /devops-deploy-activate
```

## Scope

**In-scope:**
- Starter template repo (fork/convert from jaanify)
- One-command project bootstrap
- Pre-configured `jaan-to/config/settings.yaml`
- Example context templates with placeholder content
- Guided pipeline documentation
- Tech stack auto-detection (React, Next.js, Laravel, etc.)

**Out-of-scope:**
- CLI installer (`jaan-to-cli`) — that's Phase 10 distribution
- Automated pipeline execution — that's batch skills (#135)
- Template marketplace or registry
- CI/CD pre-configuration (that's per-project)

## Implementation Steps

1. Fork `parhumm/jaanify` as template base
2. Strip project-specific content:
   - Remove jaanify-specific outputs
   - Replace context files with placeholders
   - Reset learning files
   - Clear output directory
3. Add template scaffolding:
   - Pre-configured `settings.yaml` with sensible defaults
   - Context templates with `{PLACEHOLDER}` markers
   - `.claude/settings.json` with jaan-to plugin reference
4. Create `PIPELINE.md`:
   - Step-by-step skill execution guide
   - Prerequisites per step
   - Expected outputs per step
   - Decision points (where to make choices)
5. Add tech stack detection:
   - Check `package.json` → Node.js/React/Next.js
   - Check `composer.json` → PHP/Laravel
   - Check `go.mod` → Go
   - Auto-configure `tech.md` context based on detection
6. Add GitHub template repository features:
   - Mark as template repo
   - Add `Use this template` button
7. Test: create new project from template, run first 3 skills

## Skills Affected

- No existing skills modified
- Template references all shipped skills in `PIPELINE.md`
- `/jaan-init` — template may partially overlap; document relationship

## Acceptance Criteria

- [ ] Starter template repo created (fork/convert from jaanify)
- [ ] One-command project bootstrap (GitHub template or `npx`)
- [ ] Guided workflow documentation (`PIPELINE.md`)
- [ ] Pre-configured `jaan-to/config/settings.yaml`
- [ ] Example context templates with placeholders
- [ ] Tech stack auto-detection
- [ ] No project-specific references leak into template

## Dependencies

- Batch skills (#135) — enables automated pipeline (optional enhancement)
- All 43 shipped skills (template references them in pipeline)
- `/jaan-init` — existing init skill; template is complementary

## References

- [#136](https://github.com/parhumm/jaan-to/issues/136)
- Source project: `parhumm/jaanify`
- Init skill: `skills/jaan-init/SKILL.md`
- Batch skills: `docs/roadmap/tasks/batch-skills.md`
