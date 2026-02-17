---
title: "Branding + Website"
sidebar_position: 20
---

# Branding + Website

> Phase 6 | Status: pending

## Problem

jaan.to has no public website, branding guidelines, or visual demos of skill outputs. Potential users cannot see what the plugin does without installing it and reading markdown files. This limits discoverability and adoption.

## Solution

Create branding guidelines and a public website with skill output demos and flow-of-use walkthroughs. Build on the existing Docusaurus documentation site (Phase 3).

### Deliverables

| Deliverable | Format | Priority |
|-------------|--------|----------|
| Logo (small + large) | SVG + PNG | High |
| Color palette | CSS custom properties | High |
| Typography guidelines | Document | Medium |
| Landing page | Web page | High |
| Skill output demos | Interactive/visual | High |
| Flow walkthroughs | Step-by-step guides | High |
| Getting started tutorial | Documentation | Medium |

## Scope

**In-scope:**
- Brand identity (logo, colors, typography, voice)
- Landing page with value proposition
- At least 5 skill output demos (visual examples)
- At least 3 flow-of-use walkthroughs (idea → research → PRD → code → deploy)
- Getting started tutorial
- Hosting on existing infrastructure (Docusaurus / GitHub Pages / Vercel)

**Out-of-scope:**
- Custom CMS or blog platform
- Paid advertising or marketing campaigns
- Video tutorials (future enhancement)
- Multi-language website (English first)

## Implementation Steps

1. **Branding:**
   - Design logo (wordmark + icon variants)
   - Define color palette (primary, secondary, accent, neutral)
   - Select typography (headings, body, code)
   - Document voice and tone guidelines
   - Create `docs/branding.md` with all guidelines
   - Export media assets to `assets/branding/`

2. **Website:**
   - Extend existing Docusaurus site with landing page
   - Create hero section with tagline and CTA
   - Build skill demo components (before/after showing input → output)
   - Create flow walkthrough pages:
     - Walkthrough 1: Idea → PRD → Stories (PM flow)
     - Walkthrough 2: Design → Scaffold → Deploy (Dev flow)
     - Walkthrough 3: Detect → Audit → Remediate (Security flow)
   - Add getting started tutorial (install → jaan-init → first skill)
   - Configure hosting and custom domain

3. **Skill Demos (minimum 5):**
   - `/pm-prd-write` — Show PRD output from initiative description
   - `/frontend-design` — Show component design with code
   - `/detect-dev` — Show engineering audit output
   - `/backend-scaffold` — Show generated backend code
   - `/qa-test-cases` — Show BDD test cases from acceptance criteria

## Skills Affected

- No existing skills modified
- Website content references all shipped skills

## Acceptance Criteria

- [ ] Branding guidelines documented in `docs/branding.md`
- [ ] Logo designed (SVG + PNG variants)
- [ ] Landing page deployed and accessible
- [ ] At least 5 skill output demos (visual examples)
- [ ] At least 3 flow-of-use walkthroughs
- [ ] Getting started tutorial
- [ ] Public URL accessible

## Dependencies

- Existing Docusaurus site (Phase 3 — done)
- Skill outputs for demos (43 skills shipped)

## References

- [#137](https://github.com/parhumm/jaan-to/issues/137)
- Existing distribution task: `docs/roadmap/tasks/distribution.md`
- Docusaurus config: `website/` directory
