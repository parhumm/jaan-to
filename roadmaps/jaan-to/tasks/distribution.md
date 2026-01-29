# Distribution

> Phase 8 | Status: in-progress

## Description

Package jaan.to for public distribution, including multi-agent support, CLI installer, and public documentation. Reference: spec-kit's distribution approach with `uv tool install` and agent-specific context files.

### Already Done (Phase 2.5)

- [x] Plugin packaging structure (`.claude-plugin/plugin.json`)
- [x] Marketplace metadata (`marketplace.json`)
- [x] Plugin README.md with installation instructions
- [x] CHANGELOG.md for version tracking
- [x] LICENSE.md (MIT)

---

## Sub-Tasks

### 5.1 Multi-Agent Compatibility Research

**Goal:** Test jaan.to with other coding agents, document what works

- [ ] Test with Cursor (VS Code fork)
- [ ] Test with GitHub Copilot
- [ ] Test with Windsurf
- [ ] Test with Gemini Code Assist
- [ ] Test with Qwen Coder
- [ ] Document compatibility matrix
- [ ] Identify required adaptations per agent
- [ ] Create agent-specific context files (like spec-kit's AGENTS.md)

**Compatibility Matrix Template:**

| Agent | Skills Work | Hooks Work | MCP Work | Notes |
|-------|-------------|------------|----------|-------|
| Claude Code | ✅ | ✅ | ✅ | Primary target |
| Cursor | ? | ? | ? | Test needed |
| Copilot | ? | ? | ? | Test needed |
| Windsurf | ? | ? | ? | Test needed |
| Gemini | ? | ? | ? | Test needed |

### 5.2 CLI Installer (jaan-to-cli)

**Goal:** One-command setup like spec-kit's `uv tool install specify-cli`

```bash
# Installation
claude plugin install jaan-to

# Or manual setup:
git clone https://github.com/parhumm/jaan-to-claude-code
# Creates:
# .claude-plugin/
# ├── plugin.json
# skills/
# ├── pm-prd-write/
# ├── docs-create/
# └── ... (10 skills)
# context/
# ├── config.md
# ├── tech.md
# └── ...
# hooks/
# └── hooks.json
# scripts/
# ├── bootstrap.sh
# └── ...
```

- [ ] Create Python package structure (`src/jaan_to_cli/`)
- [ ] Implement `jaan-to init` command
- [ ] Implement `jaan-to add-skill <name>` command
- [ ] Implement `jaan-to doctor` (check configuration)
- [ ] Create pyproject.toml for uv packaging
- [ ] Test installation via `uv tool install`
- [ ] Document installation in README

### 5.3 Public Documentation Site

**Goal:** Hosted documentation for public users

- [ ] Choose hosting platform (GitHub Pages, Vercel, etc.)
- [ ] Migrate docs/ to public site format
- [ ] Create landing page with value proposition
- [ ] Create getting started tutorial
- [ ] Create video walkthrough (optional)
- [ ] Setup custom domain (docs.jaan.to or similar)

### 5.4 Branding Guidelines

**Goal:** Consistent visual identity

- [ ] Logo design (small and large variants)
- [ ] Color palette definition
- [ ] Typography guidelines
- [ ] Voice and tone guidelines
- [ ] Create media/ folder with assets
- [ ] Document in docs/branding.md

---

## Acceptance Criteria

- [ ] Multi-agent compatibility report created
- [ ] CLI installer functional (`uv tool install jaan-to-cli`)
- [ ] `jaan-to init` creates valid project structure
- [ ] Public docs site deployed and accessible
- [ ] Branding guidelines documented with assets

---

## Definition of Done

### Functional
- [ ] `jaan-to init` creates working jaan.to setup
- [ ] At least 3 agents tested for compatibility
- [ ] Documentation site live and indexed

### Quality
- [ ] CLI has helpful error messages
- [ ] Documentation is beginner-friendly
- [ ] Branding is consistent across materials

### Distribution
- [ ] Package published to PyPI (or similar)
- [ ] Installation instructions in README
- [ ] GitHub releases with changelog

---

## Dependencies

- Phase 7 complete (Testing + Polish)
- E2E tests passing
- All Phase 3/3.5 skills functional

## References

- [spec-kit](https://github.com/github/spec-kit) - Distribution reference
- [spec-kit AGENTS.md](https://github.com/github/spec-kit/blob/main/AGENTS.md) - Multi-agent example
