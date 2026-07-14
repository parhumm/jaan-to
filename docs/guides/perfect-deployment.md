---
title: "Perfect Deployment"
sidebar_position: 7
---

# The Perfect Deployment — CI/CD & Release Best Practices, Anti-Patterns & Checklist

> A synthesized reference for shipping software safely, repeatably, and fast.
> Source: deep read of internal research summaries (17, 68, 74).

---

## The One Principle Everything Else Follows From

**Separate build, release, and run into immutable stages — then decouple *deployment* from *release* so shipping code is boring and turning it on is reversible.**

Two ideas from fifteen years of cloud-native practice carry the whole guide:

1. **Build/Release/Run with immutable artifacts (12-Factor V).** Build once into a versioned, immutable image; inject config per environment; run that exact artifact everywhere. No rebuilds between staging and prod, no "fix it on the server." The same artifact that passed CI is the one that runs.
2. **Deployment ≠ release (progressive delivery).** Getting code onto production servers should be a non-event; *exposing* it to users is a separate, gradual, instantly-reversible decision via feature flags and canaries. This decoupling is what makes frequent shipping safe — AI-powered flag intelligence is measured cutting failure rates **68%** and MTTR **85%**.

Everything else — statelessness, config-in-env, dev/prod parity — exists to make those two things possible. **Statelessness (12-Factor VI) enables everything downstream:** horizontal scaling, zero-downtime deploys, instant rollback, disaster recovery.

For every deployment decision, apply this filter:

> **"If this release goes wrong at 2am, how fast and how safely can one person roll it back?"** If the answer isn't "seconds, automatically," fix the deployment design — not the release.

---

## What to Include vs. Exclude

| ✅ Do | ❌ Don't |
|------|---------|
| Build one immutable artifact, promote it across envs | Rebuild per environment ("works in staging") |
| Config via environment variables (12-Factor III) | Config/secrets baked into code or images |
| Stateless processes; state in backing services | In-process/session state that blocks scaling |
| Decouple deploy from release (flags, canary) | Big-bang deploys that *are* the release |
| Migrations as a separate pre-deploy CI job | Migrations run on app startup |
| OIDC / short-lived tokens for cloud auth | Long-lived cloud credentials stored in CI |
| Security scans as required, merge-blocking checks | Scans in a dashboard nobody opens |
| Fast startup + graceful shutdown (probes) | Slow boot, no health checks, abrupt kills |
| Logs to stdout as event streams | Apps writing/managing their own log files |

---

## Recommended Structure

A shift-left pipeline where quality, security, and observability move *earlier*, gated at each stage:

```text
 commit ─▶ PR ──────────────▶ main ─▶ build ─▶ release ─▶ deploy ─▶ release(on)
   │        │                  │       │         │          │          │
 lint     unit + SAST       E2E +    immutable  tag +     migrate    canary →
 +unit    +container scan   gates    image      changelog (separate  flags →
 (fast)   (block crit/high)         (build once) (SemVer/  job)       full rollout
                                                  CalVer)             + monitor DORA
```

**Drive infra from a declarative stack file**, then generate configs from it (keeps CI/Dockerfile/compose consistent):

```text
stack.yaml            # framework, databases, deploy target → generates configs
.github/workflows/    # thin orchestrators calling reusable workflows
  ci.yml              # lint → test → scan (reusable)
  deploy.yml          # build → migrate → deploy → verify
Dockerfile            # multi-stage: deps → build → (prune) → runtime (non-root)
docker-compose.yml    # local dev/prod parity, healthcheck-gated deps
.env.example          # documented config surface — never real secrets
```

**Multi-stage Dockerfile pattern** (religiously): `deps → build → (optional prune) → runtime`, always running as a **non-root user**, on a **distroless/Chainguard** base for the smallest attack surface. Use `output: 'standalone'` (Next.js) and `turbo prune --docker` (monorepos).

---

## Best Practices

### 12-Factor foundation
1. **Config in the environment, never in code** (III). Use a typed env-validation library (t3-env, envalid) that **fails at startup** on missing/invalid vars; keep `.env.example` as living documentation.
2. **Stateless, share-nothing processes** (VI); persist everything in backing services (DB, Redis) treated as swappable attached resources (IV).
3. **Dev/prod parity** (X) — same service types and versions everywhere. Dev Containers (`.devcontainer.json`) + Docker Compose close the time/personnel/tools gaps.
4. **Disposability** (IX) — fast startup, graceful shutdown via readiness/liveness probes + `preStop` hooks. **Logs to stdout** as event streams (XI); aggregate externally.

### Pipeline (shift-left, gated)
5. **Run tests earliest:** unit on every commit, integration on PR, E2E pre-deploy. Establish a **baseline test run before changes** to separate pre-existing failures from new regressions.
6. **Build-time quality gates** with measurable thresholds (latency, error rate, coverage) that *block* the build when exceeded.
7. **Cache broad→narrow** (package store → build output) with content-addressable keys (hash of lockfile + source); remote caching (Turborepo/Nx) for monorepos. Parallelize independent suites.
8. **Reusable workflows** for org standards (lint/test/scan) so each project's CI is a thin orchestrator. Pin actions by **SHA** (immutable actions / attestations).

### Build & containers
9. **Immutable, multi-stage images**, non-root runtime, distroless/Chainguard base. Build once; promote the same digest across environments.
10. **OIDC / keyless auth** for cloud + registries — short-lived tokens replace stored credentials, eliminating rotation burden and shrinking blast radius.

### Deployment strategies (decouple deploy from release)
11. **Pick the strategy by risk + state:**

    | Strategy | Risk | Rollback | Best for |
    |----------|------|----------|----------|
    | **Blue-Green** | Low | Instant (switch) | Stateless apps |
    | **Canary** | Low | Fast (route change) | User-facing services |
    | **Rolling** | Medium | Slow (gradual) | Stateful services |
    | **Feature Flags** | Very Low | Instant (toggle) | Any application |

12. **Progressive rollout:** internal/low-risk ring → 10–25% (watch business metrics) → full (watch stability); auto-expand only after gates hold for ~24h. Combine canary + flags for the strongest rollback control.
13. **Always have a documented rollback.** For app-only workflows: `git revert`, tag-based redeploy, or flag-disable (instant, no code change). **Clean up flags at 30+ days** to avoid debt.

### Migrations & data
14. **Migrations are a separate pre-deploy job**, never on app startup. Use **expand/contract** (add columns before removing, backfill out-of-band) for zero-downtime; database branching (Neon/PlanetScale) for preview envs; checksum validation against tampering.

### Security (DevSecOps)
15. **Scanning as required, merge-blocking checks**, results in developer-facing surfaces (PR comments, SARIF → GitHub Security tab), not separate dashboards: **SAST** (CodeQL) on push, **container scan** (Trivy) on every PR, **SCA** (Dependabot/Snyk) continuously, **IaC** scan for misconfig. Block on critical/high.
16. **Supply chain:** SBOMs (increasingly mandated — NIS2, CMMC), Sigstore signing, SLSA attestations. No hardcoded credentials; secret scanning on.

### Measure & learn
17. **Track DORA, drive them with delivery design, not pressure:** deployment frequency, lead time, change-failure rate, MTTR (elite = on-demand deploys, <1h lead time, <15% CFR, <1h MTTR). Elite performers are **2× more likely** to exceed org goals.
18. **Conventional commits → automated release:** `type(scope): subject` drives SemVer + changelog + publish (semantic-release). **Blameless postmortems** within 48h, action items with named owners + dates.
19. **Shift-left observability** built into the SDLC: RED (Rate/Errors/Duration) for services, USE (Utilization/Saturation/Errors) for resources; define **SLI → SLO → SLA**; dynamic-baseline alerting over static thresholds.

---

## Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|--------------|--------------|-----|
| **Rebuilding per environment** | Staging artifact ≠ prod artifact; "works in staging" | Build once, promote the same immutable digest |
| **Deploy = release (big bang)** | Full blast radius on every change | Decouple via flags/canary; gradual rollout |
| **Config/secrets in code or image** | Leaks, can't vary per env, rebuilds to change | Env vars + validation; OIDC for cloud auth |
| **Migrations on app startup** | Races, partial failures, hard rollback | Separate pre-deploy job; expand/contract |
| **Stateful processes** | Blocks horizontal scale + zero-downtime | Stateless; state in backing services |
| **`depends_on` without healthchecks** | Flaky env, race conditions | `condition: service_healthy` |
| **Long-lived cloud credentials in CI** | Rotation burden, large blast radius | OIDC / short-lived tokens |
| **Security scans that don't block** | Findings ignored; vulns ship | Required checks; SARIF; block crit/high |
| **No rollback plan** | Slow, manual recovery → high MTTR | Blue-green/flags; documented one-step revert |
| **Flags that never get cleaned up** | Accumulating config debt | Expiry reminders; cleanup at 30+ days |
| **Gaming vanity metrics** (LOC, commits) | Incentivizes bloat, not outcomes | Measure DORA + SPACE at team level |

---

## The Checklist

**12-Factor foundation**
- [ ] One immutable artifact built once, promoted across envs (build/release/run separated)
- [ ] Config + secrets via **env vars** with startup validation; `.env.example` maintained
- [ ] Processes **stateless**; state in backing services
- [ ] **Dev/prod parity** (Dev Containers + Compose); logs to **stdout**
- [ ] Fast startup + **graceful shutdown** (readiness/liveness probes)

**Pipeline & build**
- [ ] Shift-left tests (unit→integration→E2E) with **merge-blocking quality gates**
- [ ] Caching broad→narrow with content-addressable keys; parallelized suites
- [ ] **Multi-stage Dockerfile**, non-root runtime, distroless/Chainguard base
- [ ] Reusable workflows; actions pinned by **SHA**; **OIDC** for cloud/registry auth

**Release & data**
- [ ] **Deploy decoupled from release** (flags/canary); progressive rollout with metric gates
- [ ] **Documented one-step rollback**; flags cleaned up at 30+ days
- [ ] **Migrations as a separate pre-deploy job**, expand/contract, rollback documented

**Security & observability**
- [ ] SAST + container + SCA + IaC scans as **required checks** → SARIF, block crit/high
- [ ] Supply chain: SBOM, signing (Sigstore), no hardcoded secrets
- [ ] **DORA** tracked; conventional commits → automated SemVer + changelog
- [ ] SLI/SLO/SLA defined; RED/USE metrics; blameless postmortems within 48h

---

## Reference — Platforms, IaC & Scanners

**Deployment platforms**

| | Vercel | Railway | Fly.io | AWS ECS |
|---|--------|---------|--------|---------|
| Best for | Next.js/frontend | Full-stack apps | Global edge | Enterprise/control |
| Preview envs | Auto per PR | Auto per PR | Manual | Manual (IaC) |
| Scale to zero | Yes | Yes (sleep) | Yes (Machines) | No (min 1) |
| Complexity | Low | Low–Medium | Medium | High |

**IaC for TS teams:** Pulumi (TS-native, full-stack) · CDKTF (Terraform shops + TS) · SST (AWS app devs, framework-aware) · Terraform/HCL (multi-cloud enterprise).

**Security scanners:** Trivy (container + IaC, free) · Snyk (dependency mgmt) · CodeQL (SAST) · Dependabot (auto-fix PRs). All emit SARIF for the GitHub Security tab.

**DORA targets (elite):** deploy on-demand · lead time < 1h · change-failure < 15% · MTTR < 1h.

---

## TL;DR

A perfect deployment builds **one immutable artifact**, injects config from the **environment**, and runs that same artifact everywhere — so shipping is boring. It **decouples deployment from release**, exposing changes gradually through canaries and feature flags that roll back in seconds. Tests, security scans, and observability **shift left** into merge-blocking gates; migrations run as a **separate pre-deploy job**; cloud auth is **keyless (OIDC)**; and the whole system is measured by **DORA**, not vanity metrics. Make rollback instant and automatic, and frequent deploys stop being scary — they become the point.
