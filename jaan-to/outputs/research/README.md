# Deep Research Summaries

> Reference material from AI workflow research. These are condensed summaries, not user documentation.

This directory contains structured summaries of research on Claude Code best practices, AI workflows, and development patterns. Each summary extracts key points, critical insights, and quick reference tables.

## Summary Index

| # | Summary | Description |
|---|---------|-------------|
| [01](01-agent-best-practices.md) | Agent Best Practices | Comprehensive guide to Claude Code agent configuration including CLAUDE.md setup, headless mode for CI/CD, subagent delegation patterns, prompt caching for 90% cost reduction, and hook-based automation for seamless workflow integration. |
| [02](02-ai-dev-maintenance.md) | AI-Driven Development | Spec-driven development methodology where detailed specifications guide AI implementation, ensuring consistency and reducing ambiguity. Covers spec document structure, test-first approaches, version control for specs, and human-AI collaboration cycles. |
| [03](03-ai-workflow-layers.md) | AI Workflow Layers B-D | Progressive adoption framework spanning Layer B (individual productivity), Layer C (CI/CD automation), and Layer D (multi-system orchestration). Includes GitLab CI, Jira, GA4, and Telegram ChatOps integration patterns with implementation timelines. |
| [04](04-laravel-pr-agents.md) | Laravel PR Review Agents | Implementation guide for Claude-powered PR review in Laravel projects covering CLAUDE.md templates, diff-aware reviews, multi-perspective audits, structured JSON output, and security-focused checks for SQL injection, XSS, and mass assignment. |
| [05](05-ai-os-gap-analysis.md) | jaan.to Gap Analysis | Assessment of current Claude Code practices versus optimal usage, identifying gaps in configuration (CLAUDE.md), workflow (subagents), token efficiency (caching), documentation, integration (CI/CD), and security (permissions). |
| [06](06-claude-code-best-practices.md) | Claude Code Best Practices | Core configuration guide covering CLAUDE.md structure, custom commands with frontmatter, MCP server setup, tool restrictions, extended thinking keywords, hooks system, and session management strategies. |
| [07](07-documentation-practices.md) | Documentation Best Practices | Standards for AI-friendly documentation including README essentials, API documentation, code comment strategy (why not what), Architecture Decision Records, and inline documentation patterns. |
| [08](08-claude-optimization.md) | Claude Optimization | Token efficiency techniques covering MCP tool overhead (55K-134K tokens), subagent context isolation (37% reduction), model routing (3x savings), prompt caching (90% reduction), and extended thinking budget allocation. |
| [09](09-pr-review-practices.md) | PR Review Practices | Best practices for AI code review including diff-focused analysis, structured JSON output, severity levels, confidence thresholds (>=0.8), two-pass filtering architecture (40-60% false positive reduction), and rate limiting. |
| [10](10-quick-wins-roadmap.md) | Quick Wins Roadmap | Three-phase implementation timeline with role-specific quick wins for backend (test generation, rollout plans), frontend (component planning, a11y), and product (story refinement, analytics) teams. |
| [11](11-claude-workflow.md) | Claude Workflow | Operational workflow covering interactive vs headless modes, session management, task delegation patterns, tool selection hierarchy (specialized over bash), multi-file operations, and context hygiene practices. |
| [12](12-react-nx-monorepo.md) | React NX Monorepo 2025 | Modern React architecture comparing NX vs Turborepo (NX 7x faster), Vite vs Webpack (Vite 5-6x faster but MF immature), Module Federation 2.0, TanStack Query adoption, and React 19 migration considerations. |
| [13](13-pr-review-agent-base.md) | PR Review Agent Base | Foundation architecture for PR review agents covering GitHub Actions workflow, diff processing, prompt structure, output parsing, comment posting via GitHub Review API, confidence filtering, and error handling. |
| [14](14-laravel-pr-blueprint.md) | Laravel PR Blueprint | Complete 1-2 day implementation blueprint for Laravel 10 PR review including three architecture options (single-pass, multi-agent, two-pass), CLAUDE.md templates, security checks, GitHub Actions workflow, and cost estimation. |
| [15](15-quick-wins-adoption.md) | Quick Wins Adoption | Detailed quick win specifications by phase and role with triggers, inputs/outputs, implementation time, prerequisites, risks, and human-in-the-loop requirements for Layers B, C, and D. |
| [16](16-react-monorepo-2025.md) | React Monorepo 2025 | State-of-the-art React monorepo guidance covering tool selection (NX, Vite, Webpack), state management split (TanStack Query + Redux), React 19 timing (Q2-Q3 2026), TypeScript 5.8 benefits, and pnpm adoption. |
| [17](17-twelve-factor-app.md) | Twelve-Factor App | Cloud-native application principles from codebase management to admin processes, with modern implementations using containers, Kubernetes, and CI/CD. Includes beyond-twelve-factor extensions (API First, Telemetry, Auth). |
| [18](18-token-optimization.md) | Token Optimization | Cost optimization mastery covering MCP tool overhead (85% reduction via deferral), subagent isolation (37% savings), model routing (3x), prompt caching (90%), and typical reduction from $6/day to $2-3/day. |
| [19](19-ai-workflow-claude-code-hooks-best-practices.md) | Claude Code Hooks Best Practices | Comprehensive hooks guide covering 8 lifecycle events (PreToolUse, PostToolUse, etc.), JSON payload structures, exit codes, matchers, security best practices, real-world examples (auto-format, lint, git backup), and hooks vs MCP comparison. |
| [20](20-ux-heatmap-analysis.md) | Heatmap Analysis for Product & UX | Complete heatmap analysis guide covering all types (click, scroll, movement, attention), behavioral signals (rage clicks, dead clicks, thrashing), CRO integration, tool comparison (Hotjar, Clarity, FullStory), data formats, statistical testing, and AI/Vision automation for analysis. |
| [21](21-ai-workflow-claude-vision-csv-heatmap-analysis.md) | Claude Vision + CSV Heatmap Analysis | Multimodal heatmap analysis using Claude Vision with CSV data. Covers token calculation ((w×h)/750), 85-95% confidence with cross-reference, Batch API 50% savings, text linearization patterns, 4-stage preprocessing pipeline, tool export schemas, temporal analysis, skill architecture, and severity prioritization frameworks. |
| [22](22-data-microsoft-clarity.md) | Microsoft Clarity API & MCP Integration | Complete guide to Microsoft Clarity integration for Claude Code skills. Covers official MCP server (@microsoft/clarity-mcp-server), Data Export API (10 req/day limit), cookie-based session URL extraction workaround, JavaScript SDK (identify, set, event, consent), Smart Events, Oct 2025 consent mandate, and hybrid skill architecture patterns. |
| [23](23-ai-workflow-claude-code-plugin-standards.md) | Claude Code Plugin Best Practices & Standards | Quick-reference standards for configuration hierarchy, permission patterns, skill naming (`/ROLE-DOMAIN:ACTION`), hook exit codes, gate hierarchy, secrets protection, and MCP restrictions. |
| [24](24-ai-workflow-claude-code-planning-enterprise.md) | Claude Code Planning: Architecture & Enterprise Integration | Plan Mode architecture, 30-minute rule, enterprise configuration hierarchy, hooks system, human-in-the-loop gates, checkpoint/resume strategies, monorepo patterns, and anti-patterns. |
| [25](25-ai-workflow-enterprise-plugin-packs.md) | Building Enterprise-Grade Claude Code Plugin Packs | Plugin development guide covering structure, 3-layer configuration, command naming, safety boundaries, MCP integration (Jira, GitLab, Figma), PRD workflow, and distribution. |
| [26](26-ai-workflow-product-operations-60-tasks.md) | AI-Assisted Product Operations: 60 Highest-Leverage Tasks | 60 AI-ready tasks across 6 roles (PM, Engineering, UX, QA, SEO, Data) with inputs, outputs, metrics, AI suitability scores, skill commands, and 5 end-to-end workflows. |
| [27](27-mcp-servers-by-role-pricing.md) | MCP Servers by Role: Complete Guide with Pricing | MCP server recommendations for 6 product roles (PM, Engineering, UX, QA, SEO, Data) with pricing tiers (free/freemium/paid), setup complexity, recommended context, and implementation priorities for teams of different sizes. |
| [28](28-ai-workflow-claude-code-plugins-enterprise.md) | Claude Code Plugins Enterprise Best Practices | Comprehensive guide for large enterprise teams (200+ developers) on designing, distributing, and governing Claude Code plugins. Covers plugin architecture, modularization, installation scopes, internal marketplace distribution, versioning, advanced integrations (MCP, hooks, LSP, subagents), and organizational governance. |
| [29](29-ai-workflow-claude-code-create-plugins.md) | Create Plugins | Official guide for creating Claude Code plugins with skills, agents, hooks, and MCP servers. Covers standalone vs plugin configuration, quickstart, plugin structure (commands, agents, skills, hooks, MCP, LSP), migration from .claude/ directory, and sharing via marketplaces. |
| [30](30-ai-workflow-claude-code-plugins-reference.md) | Plugins Reference | Complete technical reference for the Claude Code plugin system. Covers component schemas (skills, agents, hooks, MCP, LSP), plugin manifest schema, installation scopes (user/project/local/managed), caching/file resolution, CLI commands, debugging tools, and semantic version management. |
| [31](31-ai-workflow-claude-code-discover-plugins.md) | Discover and Install Plugins | Guide for finding and installing Claude Code plugins from marketplaces. Covers official Anthropic marketplace, code intelligence (LSP) plugins for 11 languages, external integrations (GitHub, Jira, Figma, Slack, Sentry), marketplace management, auto-updates, and team configuration. |
| [32](32-ai-workflow-claude-code-common-workflows.md) | Common Workflows | Step-by-step guides for everyday Claude Code tasks: exploring codebases, fixing bugs, refactoring, writing tests, creating PRs, using subagents, Plan Mode, extended thinking, session management, git worktrees for parallel sessions, unix-style piping, and output format control. |
| [33](33-ai-workflow-claude-code-best-practices-official.md) | Best Practices for Claude Code | Official tips for environment configuration, effective communication, session management, automation and scaling, and avoiding common failure patterns. Covers CLAUDE.md best practices, subagent delegation, headless mode, and fan-out patterns. |
| [34](34-ai-workflow-claude-code-skills-official.md) | Extend Claude with Skills | Official guide for creating, managing, and sharing SKILL.md files with YAML frontmatter, supporting files, invocation control, subagent execution, dynamic context injection, and visual output generation. |
| [35](35-ai-workflow-claude-code-output-styles.md) | Output Styles | Official guide for adapting Claude Code beyond software engineering through system prompt modification. Built-in styles (Default, Explanatory, Learning) and custom style creation with frontmatter. |
| [36](36-ai-workflow-claude-code-hooks-guide-official.md) | Get Started with Hooks | Official quickstart for hooks: auto-formatting, logging, notifications, file protection. Step-by-step setup with PreToolUse, PostToolUse, and Notification examples. |
| [37](37-ai-workflow-claude-code-mcp-official.md) | Connect Claude Code to Tools via MCP | Official MCP guide: HTTP/SSE/stdio server installation, OAuth authentication, resources, Tool Search, plugin MCP servers, installation scopes, managed configuration, and Claude Code as MCP server. |
| [38](38-ai-workflow-claude-code-subagents-official.md) | Create Custom Subagents | Official guide for specialized AI subagents with custom prompts, tool restrictions, permission modes, hooks, skills preloading, foreground/background execution, and built-in agents (Explore, Plan, general-purpose). |
| [39](39-ai-workflow-claude-code-hooks-reference-official.md) | Hooks Reference | Official technical reference: all 12 lifecycle events, input/output JSON schemas, exit codes, PreToolUse/PermissionRequest/PostToolUse/Stop decision control, prompt-based hooks, plugin hooks, and security. |
| [40](40-ai-workflow-claude-code-settings-official.md) | Claude Code Settings | Official configuration reference: 4-tier scope hierarchy (Managed/User/Project/Local), permissions system, 70+ environment variables, sandbox config, attribution, plugin config, and Bash tool behavior. |
| [41](41-ai-workflow-claude-code-checkpointing.md) | Checkpointing | Official guide for automatic edit tracking and rewind system. Checkpoint creation, three restore options (conversation/code/both), limitations (bash/external changes not tracked), and version control complement. |
| [42](42-ai-workflow-claude-code-interactive-mode.md) | Interactive Mode | Official reference for keyboard shortcuts, input modes (multiline, vim, bash), 30+ built-in commands, background tasks, task list management, PR review status, and command history with reverse search. |
| [43](43-ai-workflow-claude-code-cli-reference.md) | CLI Reference | Official complete CLI reference: commands, 40+ flags, system prompt customization (replace/append), --agents JSON format, output formats (text/json/stream-json), and session management options. |
| [44](44-pm-role-details-research-pm-ux-engineering.md) | Product Role Details Research — PM, UX & Engineering Skills | Comprehensive research on product team role capabilities covering PM discovery/strategy/PRDs, UX journeys/IA/wireframes/accessibility, and Engineering architecture/APIs/CI-CD/observability. |
| [45](45-pm-user-research-synthesis-methods.md) | PM User Research Synthesis: Implementation Guide | Data organization, pain prioritization, and quote banking with practical templates. Covers nugget-based architecture, Frequency×Severity scoring, AI transcript tools, validation methods, and affinity mapping workshops. 60+ sources from 2025 research. |

## Quick Topic Finder

### Claude Code Setup & Configuration
- [01-agent-best-practices.md](01-agent-best-practices.md)
- [06-claude-code-best-practices.md](06-claude-code-best-practices.md)
- [11-claude-workflow.md](11-claude-workflow.md)
- [19-ai-workflow-claude-code-hooks-best-practices.md](19-ai-workflow-claude-code-hooks-best-practices.md)
- [23-ai-workflow-claude-code-plugin-standards.md](23-ai-workflow-claude-code-plugin-standards.md)
- [24-ai-workflow-claude-code-planning-enterprise.md](24-ai-workflow-claude-code-planning-enterprise.md)
- [25-ai-workflow-enterprise-plugin-packs.md](25-ai-workflow-enterprise-plugin-packs.md)
- [27-mcp-servers-by-role-pricing.md](27-mcp-servers-by-role-pricing.md)
- [28-ai-workflow-claude-code-plugins-enterprise.md](28-ai-workflow-claude-code-plugins-enterprise.md)
- [29-ai-workflow-claude-code-create-plugins.md](29-ai-workflow-claude-code-create-plugins.md)
- [30-ai-workflow-claude-code-plugins-reference.md](30-ai-workflow-claude-code-plugins-reference.md)
- [31-ai-workflow-claude-code-discover-plugins.md](31-ai-workflow-claude-code-discover-plugins.md)
- [33-ai-workflow-claude-code-best-practices-official.md](33-ai-workflow-claude-code-best-practices-official.md)
- [34-ai-workflow-claude-code-skills-official.md](34-ai-workflow-claude-code-skills-official.md)
- [35-ai-workflow-claude-code-output-styles.md](35-ai-workflow-claude-code-output-styles.md)
- [36-ai-workflow-claude-code-hooks-guide-official.md](36-ai-workflow-claude-code-hooks-guide-official.md)
- [37-ai-workflow-claude-code-mcp-official.md](37-ai-workflow-claude-code-mcp-official.md)
- [38-ai-workflow-claude-code-subagents-official.md](38-ai-workflow-claude-code-subagents-official.md)
- [39-ai-workflow-claude-code-hooks-reference-official.md](39-ai-workflow-claude-code-hooks-reference-official.md)
- [40-ai-workflow-claude-code-settings-official.md](40-ai-workflow-claude-code-settings-official.md)
- [41-ai-workflow-claude-code-checkpointing.md](41-ai-workflow-claude-code-checkpointing.md)
- [42-ai-workflow-claude-code-interactive-mode.md](42-ai-workflow-claude-code-interactive-mode.md)
- [43-ai-workflow-claude-code-cli-reference.md](43-ai-workflow-claude-code-cli-reference.md)

### AI-Powered Workflows
- [02-ai-dev-maintenance.md](02-ai-dev-maintenance.md)
- [03-ai-workflow-layers.md](03-ai-workflow-layers.md)
- [10-quick-wins-roadmap.md](10-quick-wins-roadmap.md)
- [15-quick-wins-adoption.md](15-quick-wins-adoption.md)
- [26-ai-workflow-product-operations-60-tasks.md](26-ai-workflow-product-operations-60-tasks.md)
- [32-ai-workflow-claude-code-common-workflows.md](32-ai-workflow-claude-code-common-workflows.md)
- [44-pm-role-details-research-pm-ux-engineering.md](44-pm-role-details-research-pm-ux-engineering.md)
- [45-pm-user-research-synthesis-methods.md](45-pm-user-research-synthesis-methods.md)

### PR Review Automation
- [04-laravel-pr-agents.md](04-laravel-pr-agents.md)
- [09-pr-review-practices.md](09-pr-review-practices.md)
- [13-pr-review-agent-base.md](13-pr-review-agent-base.md)
- [14-laravel-pr-blueprint.md](14-laravel-pr-blueprint.md)

### Token & Cost Optimization
- [08-claude-optimization.md](08-claude-optimization.md)
- [18-token-optimization.md](18-token-optimization.md)

### Tech Stack Best Practices
- [12-react-nx-monorepo.md](12-react-nx-monorepo.md)
- [16-react-monorepo-2025.md](16-react-monorepo-2025.md)

### Documentation & Architecture
- [05-ai-os-gap-analysis.md](05-ai-os-gap-analysis.md)
- [07-documentation-practices.md](07-documentation-practices.md)
- [17-twelve-factor-app.md](17-twelve-factor-app.md)

### UX & Product Analytics
- [20-ux-heatmap-analysis.md](20-ux-heatmap-analysis.md)
- [21-ai-workflow-claude-vision-csv-heatmap-analysis.md](21-ai-workflow-claude-vision-csv-heatmap-analysis.md)
- [22-data-microsoft-clarity.md](22-data-microsoft-clarity.md)

## Related Resources

- **Consolidated Document**: [CONSOLIDATED.md](CONSOLIDATED.md) - All key points merged without duplication
