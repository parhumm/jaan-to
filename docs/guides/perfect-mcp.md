---
title: "Perfect MCP"
sidebar_position: 4
---

# The Perfect MCP — Best Practices, Anti-Patterns & Checklist

> A synthesized reference for configuring, securing, and operating MCP servers in a Claude Code workflow.
> Source: deep read of internal research summaries (27, 37, 78, 82) plus the `docs/mcp/` connector docs.

---

## The One Principle Everything Else Follows From

**Every MCP tool definition is loaded into context, and every tool output is spent from context — MCP is a token tax you pay before any work begins, and a trust boundary you cross on every call.**

Two hard truths flow from this:

1. **Token budget** — Each MCP tool definition consumes **200–850 tokens**, loaded upfront. Real measurements show 7 servers eating **67,300 tokens (34% of a 200K window)** before the first message; one developer hit **82,000 tokens** from tools alone, leaving ~12K for actual work. Past ~20–25K of tool definitions, Claude's reasoning quality measurably degrades.
2. **Trust budget** — MCP is an *untrustworthy protocol by design*: tool descriptions and tool *outputs* are interpreted as instructions by the model, the spec has **no tool-signing or immutability mechanism**, and **10+ CVEs** have hit MCP tooling since April 2025. Every server you add is code that can become malicious at any time — including after you approved it.

So the golden rule is: **Add the fewest servers that give Claude real context it would otherwise hallucinate — and treat every one as hostile.** Context quality and least privilege beat connector count.

For every server you're tempted to add, apply this filter:

> **"Does this give Claude live, authoritative data it would otherwise guess wrong — and is the value worth the permanent token + trust cost?"** If no → don't add it.

---

## What to Include vs. Exclude

| ✅ Add (real context Claude can't infer) | ❌ Skip (cost without payoff) |
|------------------------------------------|-------------------------------|
| Live API/registry schemas that stop hallucination (shadcn, OpenAPI) | "Nice to have" servers you won't call most sessions |
| Browser eyes for visual verification (Playwright) | Servers duplicating something a CLI/script already does |
| Authoritative docs lookup (Context7) | Broad servers exposing dozens of tools you use one of |
| Issue/monitoring data tied to a real skill (Jira, Sentry, GA4) | Anything writing/deleting without human-in-the-loop |
| Project-shared core set, checked into `.mcp.json` | Unaudited community servers (37% run with no auth) |
| Per-developer personal servers at **user** scope | Servers you can't pin/scope/sandbox |

**Skill ↔ MCP division of labor:** Skills encode *portable expertise* (how to build well); MCP provides *real-time project context* (actual component APIs, live URLs, current tokens). Keep skills generic; let MCP supply the living truth.

---

## Recommended Structure

Keep the **core server set small (aim for ≤ 4 in project scope)**. Configure shared servers in a project-scoped `.mcp.json` at the repo root; keep personal servers at user scope.

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    }
  }
}
```

**Transports** (pick the narrowest that works):

| Transport | Use for | Command |
|-----------|---------|---------|
| **stdio** | Local servers, full control | `claude mcp add --transport stdio --env KEY=val name -- npx -y pkg` |
| **HTTP** | Remote servers (recommended) | `claude mcp add --transport http name https://host/mcp --header "Authorization: Bearer …"` |
| **SSE** | Legacy remote (deprecated) | `claude mcp add --transport sse name https://host/sse` |

> All flags (`--transport`, `--env`, `--scope`, `--header`) come **before** the server name; `--` separates the name from the command.

**Scopes** (precedence: local > project > user):

| Scope | Storage | Who sees it | Use case |
|-------|---------|-------------|----------|
| **Local** (default) | `~/.claude.json` | You, this project | Personal/sensitive dev servers |
| **Project** | `.mcp.json` (committed) | All collaborators | Team-shared core set |
| **User** | `~/.claude.json` | You, all projects | Personal utilities everywhere |

**Secrets** use env-var expansion — never hardcode tokens: `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`.

---

## Best Practices

### Server selection & footprint
1. **Start minimal, add only what proves its worth.** Recommended sequence: CLAUDE.md + one schema server (immediate accuracy gain) → add a feedback-loop server → add a verification server → then skills/hooks. Resist configuring everything at once.
2. **Keep the count low.** Each server multiplies tool definitions. Prefer one server you call constantly over five you call occasionally. Prune servers you didn't use last week.
3. **Prefer "lite" / scoped server profiles** that expose only the toolsets you need, and toggle servers between sessions rather than running them all permanently.
4. **Write clear `serverInstructions`** in each config — they sharpen Tool Search discovery and reduce wasted calls.

### Token discipline (the always-loaded tax)
5. **Lean on MCP Tool Search.** It auto-activates when tool definitions exceed ~10% of context, builds a lightweight index, and fetches full schemas on demand — **~85% reduction** in tool overhead, and accuracy improved from 49%→74% on Opus 4. Tune with `ENABLE_TOOL_SEARCH=auto:5` (5% threshold) or disable with `ENABLE_TOOL_SEARCH=false`. Requires Sonnet 4+ / Opus 4+.
6. **Cap tool output.** Default max is 25K tokens (warning at 10K). Raise deliberately with `MAX_MCP_OUTPUT_TOKENS=50000`, never blindly — a chatty tool can blow the window in one call.
7. **Reference resources with `@` mentions** (`@github:issue://123`, `@postgres:schema://users`) so Claude pulls *specific* data instead of dumping whole datasets.
8. **Monitor with `/context`, compact at ~70%.** Target MCP tools **under 25K** of the 200K window (system prompt ~4K, system tools ~15K, autocompact+output ~45K, leaving **110K+** for real work).

### Security (treat the protocol as hostile)
9. **Pin and hash tool descriptions at approval time; block on any change.** This is the only defense against **rug-pull attacks** — a server that ships benign tools, gets approved, then silently swaps in malicious behavior. The spec offers no immutability; you must enforce it. (Cursor v1.3 added re-approval on config change for exactly this reason.)
10. **Run a scanner in proxy mode** (e.g. MCP-Scan) to detect tool poisoning, shadowing, and rug pulls at runtime by hashing descriptions.
11. **Sanitize tool descriptions *and* outputs** before they reach the model — strip `<IMPORTANT>`, `<system>`, injection markers, Unicode tag-block/zero-width characters, and HTML comments. **Tool *return data* has the highest attack-success rate** because models treat it as system-verified.
12. **Scope every server to least privilege** — minimum-privilege OAuth 2.1 + PKCE tokens with audience validation (RFC 8707). Never grant a server more than the one job it does.
13. **Require human-in-the-loop for all write/delete operations**, across every connector, no exceptions.
14. **Vet before adding.** A scan found **554 network-exposed MCP servers, 37% with no auth**. Pin package versions (`mcp-remote` shipped an RCE affecting 437K+ downloads). Audit community/doc-sourcing servers for external context-poisoning (e.g. Context7-style sources injecting insecure code patterns).

### Operations & portability
15. **Check `.mcp.json` into git** for the shared core; keep personal/credentialed servers at local or user scope.
16. **Document each connector** (purpose, tools enabled, which skills depend on it). Skills declare deps in frontmatter: `allowed-tools: mcp__<server>__<tool>`.
17. **Keep runtimes in parity.** If you support more than one agent runtime (e.g. Claude Code `.mcp.json` + Codex `config.toml`), add a CI check that both list the same servers.
18. **Govern at the org level** with managed config — `managed-mcp.json` for exclusive control, or `allowedMcpServers` / `deniedMcpServers` policy (by server name, command, or URL pattern). **Denylist always wins.**

---

## Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|--------------|--------------|-----|
| **Context bloat from too many servers** | 7 servers = 67K tokens (34%) before any work; reasoning degrades past ~20–25K | Keep the core set ≤ 4; enable Tool Search; prune unused servers |
| **Kitchen-sink connectors** | Broad servers register dozens of tools you use one of | Prefer scoped/"lite" profiles; add servers per real need |
| **Hardcoded secrets in `.mcp.json`** | Leaks credentials into git history | `${VAR}` / `${VAR:-default}` env-var expansion |
| **Trusting a server after approval** (no pinning) | Rug-pull: benign tools silently swapped for malicious ones | Hash descriptions at approval; block/re-approve on change |
| **Treating tool output as safe data** | Highest-success injection vector — models read it as verified | Sanitize outputs; strip injection markers + invisible Unicode |
| **Auto-approving writes/deletes** | One poisoned tool exfiltrates or destroys data | Mandatory human-in-the-loop for all mutations |
| **Over-broad OAuth scopes** | A compromised server inherits everything you granted | Least-privilege scoped tokens (OAuth 2.1 + PKCE, RFC 8707) |
| **Uncapped tool output** | A single chatty call blows the context window | Keep `MAX_MCP_OUTPUT_TOKENS` sane; use `@`-mention resources |
| **Unaudited community servers** | 37% of exposed servers have no auth; RCEs in popular packages | Vet + pin versions; scan; avoid unmaintained servers |

---

## The Checklist

**Footprint & selection**
- [ ] Core project-scoped set is **≤ ~4 servers**; each gives context Claude would otherwise hallucinate
- [ ] Every server passes the filter: *"live authoritative data worth the permanent token + trust cost?"*
- [ ] Personal/credentialed servers live at **local/user** scope, not in committed `.mcp.json`
- [ ] Servers prefer scoped/"lite" profiles over kitchen-sink tool sets
- [ ] Each server has clear `serverInstructions` for Tool Search

**Token discipline**
- [ ] MCP tool definitions stay **under ~25K** of the context window (`/context` checked)
- [ ] **Tool Search** enabled (or intentionally tuned) for large tool sets
- [ ] Tool output capped sensibly; `@`-mention resources used for targeted pulls
- [ ] Compaction happens proactively at ~70% usage

**Security (assume the protocol is hostile)**
- [ ] Tool descriptions **hashed/pinned at approval**; changes block or force re-approval
- [ ] A scanner runs in **proxy mode** (poisoning / shadowing / rug-pull detection)
- [ ] Tool **descriptions and outputs sanitized** (injection markers, tag-block/zero-width Unicode, HTML comments)
- [ ] Every server uses **least-privilege scoped OAuth** (2.1 + PKCE, audience-validated)
- [ ] **Human-in-the-loop** required for all write/delete operations
- [ ] Package versions **pinned**; community servers vetted; auth verified

**Operations & hygiene**
- [ ] Shared `.mcp.json` **checked into git**; secrets via env-var expansion only
- [ ] Each connector **documented** (purpose, tools, dependent skills)
- [ ] Skills reference MCP via `allowed-tools: mcp__<server>__<tool>`
- [ ] Multi-runtime configs kept **in parity** (CI-validated)
- [ ] Org policy via `managed-mcp.json` / `allowed`·`deniedMcpServers` where applicable

---

## Token Budget Reference (200K window)

| Component | Tokens | Note |
|-----------|--------|------|
| System prompt | ~4K | Fixed |
| System tools | ~15K | Fixed |
| **MCP tools (target)** | **< 25K** | Keep here; Tool Search cuts ~85% |
| MCP tools (7 servers, no Tool Search) | ~67K (34%) | Documented context collapse |
| MCP tools (worst case observed) | ~82K | Left only ~12K for work |
| Autocompact + output reserve | ~45K | — |
| **Left for conversation + code** | **110K+** | The goal |

**Rule of thumb:** every MCP tool definition costs 200–850 tokens *all session* and is a *trust boundary every call*. Keep the set small, let Tool Search lazy-load the rest, monitor with `/context`, and compact at 60–70%.

> **The horizon:** *code execution with MCP* — agents calling servers via code instead of direct tool calls — measured **150,000 → 2,000 tokens (98.7% savings)** in Anthropic's tests. Today's tool-definition model is transitional; design for small footprints now so you're ready for it.

---

## TL;DR

A perfect MCP setup is **small, scoped, pinned, and sanitized.** Add only the servers that hand Claude live truth it would otherwise hallucinate, keep their tool definitions under ~25K tokens, and lean on Tool Search to lazy-load the rest. Treat the protocol as hostile: hash descriptions at approval, sanitize every output, scope tokens to least privilege, and keep a human in the loop for anything that writes. Commit the shared core to git, document each connector, and remember — every server is a permanent token tax *and* a standing trust boundary, so every one has to earn its place.
