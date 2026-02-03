# jaan.to Configuration {#config}

> Auto-detected by `/jaan-to-dev-stack-detect` on 2026-02-03
> Status: **Seed template** - Default configuration

---

## Enabled Roles {#enabled-roles}

Based on detected tech stack, these skill roles are enabled:

- `pm` - Product Management (PRDs, stories, research)
- `dev` - Development (task breakdowns, stack detection)
- `ux` - User Experience (microcopy, heatmap analysis)
- `data` - Data & Analytics (GTM tracking)
- `qa` - Quality Assurance (testing, accessibility)

> **Note**: All roles enabled by default for empty projects. Refine based on actual usage.

---

## Output Settings {#output-settings}

### ID Generation
- **Format**: Sequential numeric (01, 02, 03...)
- **Scope**: Per subdomain (pm/prd, pm/stories, dev/backend, etc.)
- **Auto-increment**: Yes

### File Naming
- **Convention**: `{ID}-{slug}/{ID}-{type}-{slug}.md`
- **Example**: `01-user-auth/01-prd-user-auth.md`

### Index Updates
- **Auto-generate**: Yes
- **README per subdomain**: Yes
- **Sort order**: By ID (ascending)

---

## Language Preferences {#language-preferences}

### Microcopy Languages
Default set (7 languages):
- English (EN)
- Persian/Farsi (FA)
- Turkish (TR)
- German (DE)
- French (FR)
- Russian (RU)
- Tajik (TG)

### Tone Defaults
- **Product**: Friendly & Encouraging
- **Technical**: Clear & Concise
- **Transactional**: Professional & Reassuring

---

## Quality Gates {#quality-gates}

### Approval Checkpoints
- PRD generation: HARD STOP before generation
- Skill creation: Interactive wizard
- Context file updates: Show diffs for customized sections

### Learning System
- **Capture feedback**: Yes
- **Auto-categorize lessons**: Yes (Better Questions, Edge Cases, Workflow, Common Mistakes)
- **Apply lessons**: Yes (read LEARN.md files in Pre-Execution)

---

## Integration Settings {#integration-settings}

### Git Workflow
- **Auto-commit**: No (user confirms)
- **Branch naming**: `feature/{slug}`, `skill/{skill-name}`
- **Commit message format**: Conventional Commits

### Export Formats
- **Task breakdowns**: Jira CSV, Linear MD, JSON
- **Microcopy**: Markdown + JSON (i18n)
- **GTM tracking**: Markdown with code blocks

---

## Project Metadata {#metadata}

- **Project Type**: {To be determined}
- **Team Size**: {To be configured}
- **Stage**: {Development/Staging/Production}
- **Primary Domain**: {To be configured}
