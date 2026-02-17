---
title: "Security Output Proxy (Gitsubmodule)"
sidebar_position: 12
---

# Security Output Proxy

> Phase 6 | Status: pending

## Problem

Security and vulnerability findings are currently mixed into `jaan-to/outputs/` alongside all other development artifacts. Every team member with repo access can see security reports, threat models, and vulnerability details — information that should be restricted to tech leads and security-aware roles only.

## Solution

Separate all security-related outputs into a dedicated **gitsubmodule** (`jaan-to-sec-output/`) that mirrors the main output structure but lives in a separate repository with restricted access.

## Architecture

```
project-root/
├── jaan-to/
│   ├── outputs/          # Regular outputs (all team)
│   │   ├── detect/       # detect-dev, detect-design, etc. (NO security)
│   │   ├── pm/
│   │   ├── frontend/
│   │   └── ...
│   └── docs/             # Regular docs (all team)
│
├── jaan-to-sec-output/   # ← gitsubmodule (tech-lead only)
│   ├── outputs/
│   │   ├── detect/
│   │   │   └── security/ # detect-security outputs
│   │   └── sec/          # sec-audit-remediate, threat models, etc.
│   └── docs/
│       └── security/     # Security documentation
```

## Access Model

| Role | `jaan-to/` | `jaan-to-sec-output/` |
|------|-----------|----------------------|
| All developers | Read/Write | No access |
| Tech lead | Read/Write | Read/Write |
| Security team | Read | Read/Write |

## Implementation Steps

1. Create `jaan-to-sec-output` repository template
2. Update `jaan-init` to optionally initialize security submodule
3. Route `detect-security` and `sec-*` skill outputs to submodule path
4. Add `.gitmodules` configuration
5. Update `detect-pack` to reference security findings by link (not inline)
6. Document setup in `docs/guides/security-output-proxy.md`

## Skills Affected

- `detect-security` (new) — primary output target
- `sec-audit-remediate` — redirect outputs
- `detect-dev` — remove security findings (delegate to `detect-security`)
- `detect-pack` — reference security summary, don't inline details
- `jaan-init` — add submodule setup option

## Dependencies

- `detect-security` skill must exist first
- Git submodule support in user's environment
