---
title: "devops-deploy-activate"
sidebar_position: 3
doc_type: skill
created_date: 2026-02-12
updated_date: 2026-02-12
tags: [devops, deploy, activate, secrets, github-actions, supply-chain, platform]
related: [devops-infra-scaffold, dev-output-integrate, sec-audit-remediate]
---

# /jaan-to:devops-deploy-activate

> Activate deployment pipeline — secrets, platforms, supply chain hardening, verification.

---

## Overview

Takes infra-scaffold output and activates the deployment pipeline: configures GitHub secrets, pins GitHub Actions to SHA digests for supply chain security, provisions backend and frontend platforms (Railway, Vercel, Fly.io), sets up remote cache for monorepos, and triggers a verification pipeline run.

---

## Usage

```
/jaan-to:devops-deploy-activate
/jaan-to:devops-deploy-activate [infra-scaffold-output]
```

| Argument | Required | Description |
|----------|----------|-------------|
| infra-scaffold-output | No | Path to infra-scaffold output folder |

When run without arguments, searches for the latest infra-scaffold output.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/devops/deploy-activate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Activation report with secrets, platforms, and pipeline results |

Also modifies `.github/workflows/` files (SHA pinning).

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Activation scope | Always | Which components to activate |
| Secret values | Per secret | User provides values securely |
| Platform setup | Per platform | Confirm provisioning steps |
| Cache token | Monorepo detected | Turborepo remote cache setup |

---

## Prerequisites

| Tool | Required | Check Command |
|------|----------|---------------|
| GitHub CLI (`gh`) | Yes | `gh auth status` |
| Railway CLI | If Railway target | `railway version` |
| Vercel CLI | If Vercel target | `vercel --version` |
| Fly CLI | If Fly.io target | `fly version` |

---

## Workflow Chain

```
/jaan-to:devops-infra-scaffold + /jaan-to:dev-output-integrate --> /jaan-to:devops-deploy-activate
```

---

## Example

**Input:**
```
/jaan-to:devops-deploy-activate jaan-to/outputs/devops/infra-scaffold/01-my-app-infra/
```

**Output:**
```
Secrets configured:  5/5
Actions pinned:      8 actions → SHA digests
Backend:             Railway project linked
Frontend:            Vercel connected with preview deployments
Pipeline:            CI passed (2m 34s)

Activation report: jaan-to/outputs/devops/deploy-activate/01-my-app-activation/01-my-app-activation.md
```

---

## Tips

- Run `/jaan-to:devops-infra-scaffold` first to generate the infrastructure files
- Run `/jaan-to:dev-output-integrate` to copy CI/CD files into `.github/workflows/` before activating
- Ensure CLI tools are installed and authenticated before starting
- Secret values are entered interactively and never logged or stored in reports

---

## Related Skills

- [/jaan-to:devops-infra-scaffold](infra-scaffold.md) - Generate CI/CD and deployment configs
- [/jaan-to:dev-output-integrate](../dev/output-integrate.md) - Copy outputs into project
- [/jaan-to:sec-audit-remediate](../sec/audit-remediate.md) - Security fixes and hardening
- [/jaan-to:release-iterate-changelog](../release/iterate-changelog.md) - Generate changelog for releases

---

## Technical Details

- **Logical Name**: devops-deploy-activate
- **Command**: `/jaan-to:devops-deploy-activate`
- **Role**: devops
- **Output**: `$JAAN_OUTPUTS_DIR/devops/deploy-activate/{id}-{slug}/`
