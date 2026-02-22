---
title: "CLI Transformation"
sidebar_position: 10
---

# CLI Transformation — Plugin to Standalone CLI

> Phase 9 | Status: Planned

## Description

Transform jaan.to from a Claude Code plugin into a standalone CLI app using the Claude Agent SDK (TypeScript). Dual distribution: plugin stays for Claude Code users, CLI reaches everyone via npm. Skills, templates, learning, and context files are shared between both runtimes.

### Strategic Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Distribution** | Dual (plugin + CLI) | Keep plugin for existing Claude Code users, CLI for new reach |
| **Language** | TypeScript | npm ecosystem, Claude Code is TS, best CLI tooling |
| **Goal** | Full independence | Product independence + multi-model + CI/CD automation |

---

## Why Transform

| As Plugin | As CLI |
|-----------|--------|
| Depends on Claude Code | Independent product |
| Only Claude Code users | Anyone with an API key |
| Plugin marketplace only | npm, pip, GitHub, brew |
| Can't run in CI/CD | First-class CI/CD support |
| Can't build a product on it | API/library for integrations |
| "A plugin for Claude Code" | "jaan.to — give soul to your workflow" |

### Market Gap

No CLI tool provides a structured, role-based workflow layer with learning. All compete on "give me a prompt, edit my code." None offer role-based skills, accumulated learning, two-phase workflow with human approval, template-driven output standardization, or spec-to-ship pipeline across roles. This is jaan.to's moat — independent of runtime.

---

## Architecture

### Portability Analysis

~90% of jaan.to's value is in portable markdown files. Claude Code-specific parts are thin wrappers.

| Component | Portable? |
|-----------|-----------|
| Skills (SKILL.md) | Yes — markdown, loadable by any agent |
| Agents (quality-reviewer.md, context-scout.md) | Yes — Agent SDK has identical subagent support |
| Config (defaults.yaml, settings.yaml) | Yes — generic YAML |
| Tools (Read, Write, Edit, Bash, Glob, Grep) | Yes — Agent SDK provides identical tools |
| Templates, Learning, Context files | Yes — filesystem markdown |
| MCP connections | Yes — Agent SDK has native MCP support |
| Hooks (hooks.json) | Partial — concept translates, format is Claude Code-specific |
| Bootstrap (bootstrap.sh) | Partial — needs new env var source |

### CLI Architecture

```
┌─────────────────────────────────────────────────┐
│                  jaan-to CLI                      │
│                                                   │
│  ┌─────────┐  ┌──────────┐  ┌────────────────┐  │
│  │ Command  │  │  Skill   │  │    Config      │  │
│  │ Parser   │  │  Loader  │  │    System      │  │
│  │ (args)   │  │ (SKILL.md│  │  (YAML merge)  │  │
│  └────┬─────┘  │  parse)  │  └───────┬────────┘  │
│       │        └────┬─────┘          │            │
│       ▼             ▼                ▼            │
│  ┌──────────────────────────────────────────┐    │
│  │           Skill Runtime                    │    │
│  │  - Parse SKILL.md frontmatter & body      │    │
│  │  - Resolve $JAAN_* env vars               │    │
│  │  - Load LEARN.md, templates, context      │    │
│  │  - Build system prompt from skill          │    │
│  │  - Configure allowed tools & permissions   │    │
│  │  - Register subagents                      │    │
│  └──────────────────┬───────────────────────┘    │
│                     ▼                             │
│  ┌──────────────────────────────────────────┐    │
│  │        Claude Agent SDK                    │    │
│  │  query(prompt, options) → stream           │    │
│  │  Built-in: Read, Write, Edit, Bash,       │    │
│  │           Glob, Grep, WebSearch, Task      │    │
│  │  + MCP servers                             │    │
│  │  + Hooks (programmatic)                    │    │
│  │  + Sessions                                │    │
│  └──────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

### CLI Commands

```bash
jaan-to init                                    # Initialize project
jaan-to run pm-prd-write "user auth feature"    # Run a skill
jaan-to run detect-dev --full                   # With flags
jaan-to run detect-dev --full --ci --output json # CI/CD mode
jaan-to skills                                  # List skills
jaan-to skills --role pm                        # Filter by role
jaan-to doctor                                  # Health check
jaan-to config set language en                  # Configure
```

---

## Sub-Tasks

### Phase A: MVP CLI

**Goal**: `jaan-to run pm-prd-write "feature X"` works

- [ ] Create `packages/cli/` with TypeScript project structure
- [ ] Install `@anthropic-ai/claude-agent-sdk` as core dependency
- [ ] Implement SKILL.md parser (YAML frontmatter + markdown body extraction)
- [ ] Implement config loader (merge `config/defaults.yaml` + project `settings.yaml`)
- [ ] Implement `$JAAN_*` env var resolver
- [ ] Implement skill runtime (build system prompt, configure Agent SDK query options)
- [ ] Implement `jaan-to init` command (port of bootstrap.sh)
- [ ] Implement `jaan-to run <skill-name> [args]` command
- [ ] Test with 3 representative skills: pm-prd-write, detect-dev, backend-scaffold

### Phase B: Feature Parity

**Goal**: Everything the plugin does, the CLI does

- [ ] Implement learning system (LEARN.md load + merge strategy)
- [ ] Implement template resolution with `{{variable}}` substitution
- [ ] Implement subagent registration (quality-reviewer, context-scout from agents/*.md)
- [ ] Implement hook system (pre/post tool use as programmatic Agent SDK hooks)
- [ ] Port shell script utilities to TypeScript (id-generator, index-updater, asset-handler)
- [ ] Port bootstrap validations (context file checks, detect suggestions)

### Phase C: CLI-Native Features

**Goal**: Things only a CLI can do

- [ ] CI/CD mode (`--ci` flag: non-interactive, auto-approve, JSON output)
- [ ] Batch mode (run multiple skills in sequence with shared context)
- [ ] Progress UI (terminal spinners, streaming output display)
- [ ] Session management (resume interrupted skill runs via Agent SDK sessions)
- [ ] Skill marketplace (`jaan-to install community/custom-skill`)

### Phase D: Multi-Model

**Goal**: Use any LLM, not just Claude

- [ ] Abstract the Agent SDK behind a provider interface
- [ ] Implement OpenAI provider (Codex / assistant APIs)
- [ ] Implement local model provider (Ollama)
- [ ] Skill compatibility matrix per model capability

---

## File Structure

### New Files (CLI Package)

```
packages/cli/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts              # CLI entry point
│   ├── commands/
│   │   ├── init.ts           # jaan-to init
│   │   ├── run.ts            # jaan-to run <skill>
│   │   ├── skills.ts         # jaan-to skills (list)
│   │   └── doctor.ts         # jaan-to doctor
│   ├── core/
│   │   ├── skill-loader.ts   # Parse SKILL.md → agent config
│   │   ├── config.ts         # YAML config merge system
│   │   ├── env.ts            # $JAAN_* env var resolution
│   │   ├── learning.ts       # LEARN.md merge/read
│   │   └── templates.ts      # Template variable substitution
│   ├── runtime/
│   │   ├── agent.ts          # Agent SDK wrapper
│   │   ├── hooks.ts          # Programmatic hooks
│   │   └── subagents.ts      # Register quality-reviewer, context-scout
│   └── utils/
│       ├── id-generator.ts   # Port of scripts/lib/id-generator.sh
│       ├── index-updater.ts  # Port of scripts/lib/index-updater.sh
│       └── asset-handler.ts  # Port of scripts/lib/asset-handler.sh
├── bin/
│   └── jaan-to.ts            # CLI binary entry
└── tests/
```

### Shared Files (Unchanged)

- `skills/*/SKILL.md` — all 45 skills
- `skills/*/template.md` — output templates
- `skills/*/LEARN.md` — seed lessons
- `agents/*.md` — subagent definitions
- `config/defaults.yaml` — plugin defaults
- `scripts/seeds/*.md` — context file seeds

---

## Acceptance Criteria

- [ ] `npm install -g jaan-to` installs CLI globally
- [ ] `jaan-to init` creates valid `jaan-to/` project structure
- [ ] `jaan-to run pm-prd-write "feature"` executes skill with interactive prompts
- [ ] `jaan-to run detect-dev --ci` runs in non-interactive mode
- [ ] Outputs appear in `jaan-to/outputs/` with correct structure
- [ ] Learning capture works (`jaan-to run learn-add`)
- [ ] Plugin continues working unchanged for Claude Code users

## Definition of Done

### Phase A (MVP)
- [ ] 3 skills run successfully via CLI
- [ ] `jaan-to init` creates valid project structure
- [ ] Config system loads and merges correctly

### Phase B (Parity)
- [ ] All 45 skills run via CLI
- [ ] Learning, templates, hooks all functional
- [ ] No regression in plugin behavior

### Phase C (CLI-Native)
- [ ] CI/CD mode tested in GitHub Actions pipeline
- [ ] Session resume works across interruptions

---

## Dependencies

- Claude Agent SDK (`@anthropic-ai/claude-agent-sdk`) — TypeScript package
- Phase 8 (Testing) helpful but not blocking — can test CLI independently
- No blocking dependency on Phase 6 (Role Skills) or Phase 7 (MCP)

## References

- [Claude Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Claude Agent SDK Quickstart](https://platform.claude.com/docs/en/agent-sdk/quickstart)
- [Agent SDK TypeScript](https://github.com/anthropics/claude-agent-sdk-typescript)
- [distribution.md](distribution.md) — Original distribution plan (CLI installer superseded by this doc)
