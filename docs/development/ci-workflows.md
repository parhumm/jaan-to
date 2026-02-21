# CI Workflows

> GitHub Actions workflows for dual-runtime governance and release validation.

**Audience:** jaan-to contributors and maintainers

---

## Active Workflows

### `.github/workflows/_dual-runtime-gate.yml`

**Trigger:** `workflow_call` (reusable workflow)
**Purpose:** Single source of truth for runtime validation gates

**Checks executed:**
1. `bash .claude/scripts/validate-plugin-standards.sh`
2. `bash scripts/validate-skills.sh`
3. `bash scripts/validate-security.sh`
4. `bash scripts/validate-multi-runtime.sh`
5. `bash scripts/test/e2e-dual-runtime-smoke.sh` (blocking integrated E2E)
6. `bash scripts/validate-claude-compat.sh`
7. `bash scripts/validate-codex-runner.sh`

Use this workflow from other workflows instead of duplicating validation logic.

---

### `.github/workflows/dev-dist-build.yml`

**Trigger:** Pull requests to `dev` (`opened`, `synchronize`, `reopened`)
**Purpose:** Enforce dual-runtime gates and publish PR dist artifacts

**Flow:**
1. Call `_dual-runtime-gate.yml` (blocking)
2. Build dist targets (`bash scripts/build-all-targets.sh`)
3. Upload artifacts:
   - `jaan-to-claude-pr-<number>` from `dist/jaan-to-claude`
   - `jaan-to-codex-pr-<number>` from `dist/jaan-to-codex`
   - Retention: 7 days

**Artifact download flow:**
1. Open PR to `dev`
2. Wait for `Dev Dist Build` to pass
3. Open workflow run -> **Artifacts**
4. Download both runtime packages

---

### `.github/workflows/release-check.yml`

**Trigger:** Pull requests to `main`
**Purpose:** Keep release checks Claude-safe while enforcing dual-runtime parity

**Flow:**
1. Call `_dual-runtime-gate.yml` (blocking)
2. Run release-specific checks:
   - Version consistency
   - CHANGELOG entry
   - `plugin.json` component path contract
   - `CLAUDE.md` size cap
   - Hook stdout cap
   - Agent Skills metadata compliance
   - Docs site build

---

### `.github/workflows/dev-push-monitor.yml`

**Trigger:** Push to `dev`
**Purpose:** Non-blocking visibility for direct push parity regressions and deeper E2E drift

**Flow:**
1. Call `_dual-runtime-gate.yml` with `continue-on-error`
2. Run `bash scripts/test/e2e-dual-runtime-full.sh` with `continue-on-error`
3. Emit summary with success/warning status for both jobs

This preserves current direct-push policy while surfacing runtime regressions quickly.

---

### `.github/workflows/nightly-e2e.yml`

**Trigger:** Scheduled nightly run + `workflow_dispatch`
**Purpose:** Non-blocking full-suite E2E signal for regressions outside PR windows

**Flow:**
1. Run `bash scripts/test/e2e-dual-runtime-full.sh` with `continue-on-error`
2. Emit warning annotation if suite fails

Use this as an early warning monitor, not as a branch protection gate.

---

### `.github/workflows/deploy-docs.yml`

**Trigger:** Push to `main`
**Purpose:** Deploy docs and marketing site after merge

No release validation is duplicated here.

---

## Local Reproduction

Run the same checks locally before opening PRs:

```bash
bash .claude/scripts/validate-plugin-standards.sh
bash scripts/validate-skills.sh
bash scripts/validate-security.sh
bash scripts/test/e2e-dual-runtime-smoke.sh
bash scripts/validate-multi-runtime.sh
bash scripts/validate-claude-compat.sh
bash scripts/validate-codex-runner.sh
```

For deeper local coverage:

```bash
bash scripts/test/e2e-dual-runtime-full.sh
```

For release validation:

```bash
cd website/docs
npm ci
npm run build
cd ../..
```

---

## Contributor Guardrails

- PR template: `.github/pull_request_template.md`
- Required validation checklist includes all dual-runtime scripts.
- Shared-core rule remains mandatory: keep feature logic in shared paths, keep adapters thin.

---

## Design Principle

CI is script-first. Workflow YAML orchestrates scripts; script files own validation behavior.
This keeps local and CI behavior aligned and avoids duplicated logic.
