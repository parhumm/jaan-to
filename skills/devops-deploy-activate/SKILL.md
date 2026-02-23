---
name: devops-deploy-activate
description: Activate deployment pipeline with secrets, platform provisioning, and supply chain hardening. Use when deploying to production.
allowed-tools: Read, Glob, Grep, Bash(gh secret:*), Bash(gh variable:*), Bash(gh workflow:*), Bash(gh api:*), Bash(gh run:*), Bash(gh auth:*), Bash(railway init:*), Bash(railway link:*), Bash(railway status:*), Bash(railway variables:*), Bash(vercel deploy:*), Bash(vercel env:*), Bash(vercel link:*), Bash(vercel inspect:*), Bash(fly launch:*), Bash(fly deploy:*), Bash(fly secrets:*), Bash(fly status:*), Bash(turbo run:*), Write(.github/**), Write($JAAN_OUTPUTS_DIR/devops/deploy-activate/**), Task, WebSearch, AskUserQuestion, Edit(.github/**)
argument-hint: [infra-scaffold-output] or (interactive)
license: MIT
compatibility: Designed for Claude Code with jaan-to plugin. Requires jaan-init setup.
---

# devops-deploy-activate

> Activate deployment pipeline — secrets, platforms, supply chain hardening, verification.

## Context Files

- `$JAAN_CONTEXT_DIR/tech.md` — Tech stack (determines deployment targets, package manager)
  - Uses sections: `#current-stack`, `#frameworks`, `#constraints`
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration
- `$JAAN_TEMPLATES_DIR/jaan-to-devops-deploy-activate.template.md` — Activation report template
- `$JAAN_LEARN_DIR/jaan-to-devops-deploy-activate.learn.md` — Past lessons (loaded in Pre-Execution)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` — Language resolution protocol

## Input

**Upstream Artifacts**: $ARGUMENTS

- **infra-scaffold** — Path to infra-scaffold output (from `/jaan-to:devops-infra-scaffold`)
- **Empty** — Interactive: search `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/` for latest output

---

## Pre-Execution Protocol
**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `devops-deploy-activate`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Know the tech stack for platform-specific activation
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration

### Language Settings
Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_devops-deploy-activate`

> **Language exception**: Generated code output (YAML workflows, shell commands, deployment configs) is NOT affected by this setting and remains in English/code.

---

# PHASE 1: Analysis (Read-Only)

## Thinking Mode

ultrathink

Use extended reasoning for:
- Analyzing infra-scaffold output to determine required secrets and platforms
- Cross-referencing .env files with CI/CD workflow secret references
- Planning activation order (secrets before platform provisioning)
- Identifying supply chain hardening opportunities in GitHub Actions

## Step 1: Parse Infra-Scaffold Output

Read infra-scaffold README and CI/CD workflow files:
1. Extract secret names referenced in workflows (`${{ secrets.* }}`)
1b. Extract variable names referenced in workflows (`${{ vars.* }}`)
2. Identify deployment platform targets (Vercel, Railway, Fly.io)
3. Detect Docker registry configuration
4. List GitHub Actions used (for SHA pinning)

If no infra-scaffold found:
- Search `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/` for latest output
- If still none: ask user for manual input via AskUserQuestion

Present parsed summary:
```
INFRA-SCAFFOLD ANALYSIS
=======================
Secrets Referenced:    {list with which workflow uses each}
Deployment Platforms:  {list}
Docker Registry:       {registry or "none"}
GitHub Actions Used:   {list with current versions}
```

## Step 2: Check CLI Tool Availability

Verify required tools are available:
- `gh auth status` (required — GitHub CLI)
- `railway version` (if Railway detected)
- `vercel --version` (if Vercel detected)
- `fly version` (if Fly.io detected)

Present status:
```
CLI TOOL STATUS
===============
gh:       ✓ Authenticated as {user} / ✗ Not found
railway:  ✓ v{version} / ✗ Not found / ⊘ Not needed
vercel:   ✓ v{version} / ✗ Not found / ⊘ Not needed
fly:      ✓ v{version} / ✗ Not found / ⊘ Not needed
```

If `gh` is missing or not authenticated: stop and ask user to install/authenticate.

## Step 3: Detect Current State

Check what is already configured:
1. `gh secret list` — which secrets already exist
2. `gh variable list` — which repository variables already exist
3. Check for existing platform project links (`.vercel/`, `fly.toml`, `railway.toml`)
4. Check `.github/workflows/` for existing CI/CD workflows

Present state:
```
CURRENT STATE
=============
Secrets Configured:    {count}/{total} ({list})
Secrets Missing:       {list}
Variables Configured:  {count}/{total} ({list})
Variables Missing:     {list}
Platform Links:        {found / none}
Existing Workflows:    {list or "none"}
```

## Step 4: Build Activation Checklist

Create ordered activation plan:

```
ACTIVATION CHECKLIST
====================
                                          Status
1. GitHub Secrets                         {needed / configured / partial}
2. GitHub Repository Variables            {needed / configured / partial}
3. GitHub Actions SHA Pinning             {needed / done}
4. Backend Platform ({platform})          {needed / linked}
5. Frontend Platform ({platform})         {needed / linked}
6. Repository Variables (post-provision)  {needed / configured}
7. Remote Cache (Turborepo)               {needed / n/a}
8. Verification Pipeline                  {needed}

Items to activate: {count}
Already configured: {count}
```

Mark items as: **needed** / **already configured** / **optional** / **n/a**

---

# HARD STOP — Review Activation Plan

Use AskUserQuestion:
- Question: "Proceed with activating {n} deployment components?"
- Header: "Activate"
- Options:
  - "Yes" — Proceed with activation
  - "No" — Cancel
  - "Edit" — Let me revise which components to activate

**Do NOT proceed to Phase 2 without explicit approval.**

---

# PHASE 2: Execution

## Step 5: Configure GitHub Secrets

For each required secret:
1. Show: name, description, which workflow uses it
2. Use AskUserQuestion to collect the value
3. Run `gh secret set {NAME}` with the provided value
4. **Never log or display secret values after entry**

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-deploy-activate-reference.md` section "Secret Management Patterns" for per-platform secret requirements and naming conventions.

Confirm after each:
> Secret `{NAME}` configured for repository.

## Step 6: Harden GitHub Actions

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-deploy-activate-reference.md` section "GitHub Actions SHA Pinning" for the resolution process using `gh api`.

For each GitHub Action reference in workflow files:
1. Parse action reference (e.g., `actions/checkout@v4`)
2. Resolve to full SHA digest via `gh api repos/{owner}/{repo}/git/ref/tags/{tag}`
3. Show proposed change: `actions/checkout@v4` → `actions/checkout@{sha} # v4`
4. Apply via Edit(.github/**)

Present pinning summary:
```
SHA PINNING RESULTS
===================
Pinned:    {count} actions
Skipped:   {count} (already pinned)
Failed:    {count} (show reasons)
```

## Step 7: Provision Backend Platform

Based on detected deployment target:

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-deploy-activate-reference.md` section "Platform CLI Provisioning" for Railway, Fly.io, and other platform setup commands.

**Railway:**
1. `railway init` — Create project
2. `railway link` — Link to repository
3. Configure environment variables via `railway variables set`
4. Verify: `railway status`

**Fly.io:**
1. `fly launch` — Create app (interactive)
2. `fly secrets set` — Configure secrets
3. Verify: `fly status`

Capture service URL from platform CLI output for repository variables (Step 8b).

Confirm:
> Backend platform ({platform}) provisioned and linked.

## Step 8: Connect Frontend Platform

Based on detected deployment target:

**Vercel:**
1. `vercel link` — Link to repository
2. Configure environment variables via Vercel dashboard or CLI
3. Set up preview deployments for PRs
4. Verify: `vercel inspect`

Capture production URL from platform CLI output for repository variables (Step 8b).

Confirm:
> Frontend platform ({platform}) connected with preview deployments.

## Step 8b: Configure Repository Variables

Set non-sensitive configuration values as GitHub repository variables:

1. `gh variable list` — show currently configured variables
2. For each required variable (from Step 1b `${{ vars.* }}` extraction):
   - Detect value from platform provisioning output if possible (service URLs)
   - Confirm value via AskUserQuestion before setting
   - Run `gh variable set {NAME} --body "{value}"`
   - For environment-scoped: `gh variable set {NAME} --env production --body "{value}"`
3. Present configured variables:

```
REPOSITORY VARIABLES
====================
{NAME}:           {value}
{NAME}:           {value}
Environment-scoped: {list}
```

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-deploy-activate-reference.md` section "Repository Variable Patterns" for common variables, URL capture commands, and secrets-vs-variables guidance.

## Step 9: Configure Remote Cache (if monorepo)

Only if `turbo.json` exists in the project:
1. Guide user to create Turborepo remote cache token
2. Set `TURBO_TOKEN` and `TURBO_TEAM` as GitHub secrets
3. Verify with `turbo run build --dry`

> **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/devops-deploy-activate-reference.md` section "Caching Hierarchy" for the full caching strategy (pnpm store → Next.js → Docker → Turborepo).

If `turbo.json` not found: skip with note.

## Step 10: Trigger Verification Pipeline

1. Suggest: push a test commit or use `gh workflow run ci.yml`
2. Monitor pipeline status via `gh run list --limit 1`
3. Wait for completion and report results

```
PIPELINE VERIFICATION
=====================
Workflow:   {workflow_name}
Run ID:     {run_id}
Status:     ✓ Pass / ✗ Failed at stage {stage}
Duration:   {time}
URL:        {run_url}
```

If failed: show failure details and suggest fixes.

## Step 11: Quality Check

**Secrets:**
- [ ] All required secrets configured in GitHub
- [ ] No secrets logged or displayed in output
- [ ] Secrets match workflow references

**Supply Chain:**
- [ ] All GitHub Actions pinned to SHA digests
- [ ] No mutable tags (`v4`, `latest`) remaining in workflows

**Platforms:**
- [ ] Backend platform connected and responding
- [ ] Frontend platform connected with preview deployments
- [ ] Remote cache configured (if applicable)

**Repository Variables:**
- [ ] All required `${{ vars.* }}` references have corresponding variables set
- [ ] Non-sensitive values used as variables (not secrets)
- [ ] Environment-scoped variables set where needed

**Pipeline:**
- [ ] CI pipeline triggered and completed
- [ ] All workflow stages passed

If any check fails, fix before proceeding.

## Step 12: Generate ID and Folder Structure

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/id-generator.sh"
SUBDOMAIN_DIR="$JAAN_OUTPUTS_DIR/devops/deploy-activate"
mkdir -p "$SUBDOMAIN_DIR"
NEXT_ID=$(generate_next_id "$SUBDOMAIN_DIR")
slug="{activation-slug}"
OUTPUT_FOLDER="${SUBDOMAIN_DIR}/${NEXT_ID}-${slug}"
```

Preview:
> **Output Configuration**
> - ID: {NEXT_ID}
> - Folder: `$JAAN_OUTPUTS_DIR/devops/deploy-activate/{NEXT_ID}-{slug}/`
> - Main file: `{NEXT_ID}-{slug}.md`

## Step 13: Write Activation Report

Use template from: `$JAAN_TEMPLATES_DIR/jaan-to-devops-deploy-activate.template.md`

Write `{NEXT_ID}-{slug}.md` with:
- Executive Summary
- Secrets configured (names only, never values)
- Actions hardened (SHA pinning results)
- Platforms provisioned (with connection status)
- Repository variables configured (names and values — non-secret)
- Pipeline verification results
- Remote cache status
- Next steps for ongoing maintenance

Update index:
```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/index-updater.sh"
add_to_index \
  "$SUBDOMAIN_DIR/README.md" \
  "$NEXT_ID" \
  "${NEXT_ID}-${slug}" \
  "{Activation Title}" \
  "{Executive summary — 1-2 sentences}"
```

Confirm:
> Activation report written to: `$JAAN_OUTPUTS_DIR/devops/deploy-activate/{NEXT_ID}-{slug}/{NEXT_ID}-{slug}.md`
> Index updated: `$JAAN_OUTPUTS_DIR/devops/deploy-activate/README.md`

## Step 14: Suggest Next Actions

> **Deployment pipeline activated!**
>
> **Immediate Steps:**
> - Monitor the first real deployment
> - Verify preview deployments work on PR creation
> - Check secret rotation schedule
>
> **Recommended Follow-ups:**
> - Set up monitoring and alerting for deployed services
> - Configure branch protection rules (`gh api repos/{owner}/{repo}/branches/{branch}/protection`)
> - Run `/jaan-to:release-iterate-changelog` for your first release
> - Schedule secret rotation (recommended: 90 days)

## Step 15: Capture Feedback

Use AskUserQuestion:
- Question: "How did the deployment activation turn out?"
- Header: "Feedback"
- Options:
  - "Perfect!" — Done
  - "Needs fixes" — What should I improve?
  - "Learn from this" — Capture a lesson for future runs

If "Learn from this": Run `/jaan-to:learn-add devops-deploy-activate "{feedback}"`

---

## Scope Boundaries

- Does NOT generate infrastructure files (that's `/jaan-to:devops-infra-scaffold`)
- Does NOT copy files into the project (that's `/jaan-to:dev-output-integrate`)
- Requires user to have CLI tools installed and authenticated
- Secrets are set by the USER through guided prompts (skill never handles secret values directly)

---

## DAG Position

```
devops-infra-scaffold + dev-output-integrate
  |
  v
devops-deploy-activate
```

---

## Skill Alignment

- Two-phase workflow with HARD STOP for human approval
- Multi-platform support (GitHub Actions, GitLab CI, etc.)
- Template-driven output structure
- Output to standardized `$JAAN_OUTPUTS_DIR` path

## Definition of Done

- [ ] All required GitHub secrets configured
- [ ] All required GitHub repository variables configured
- [ ] GitHub Actions pinned to SHA digests
- [ ] Backend platform provisioned and connected
- [ ] Frontend platform connected with preview deployments
- [ ] Remote cache configured (if monorepo)
- [ ] CI pipeline triggered and passed
- [ ] Activation report written to output directory
- [ ] Index updated with executive summary
- [ ] User approved final result
