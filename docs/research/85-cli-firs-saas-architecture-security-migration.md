# Converting jaan-to into a CLI-first SaaS: architecture, security, and migration

**jaan-to should adopt a pull-based agent architecture with OPA-style policy bundles, Sigstore-signed skill packages, and OS-level sandboxing to become a production-grade CLI-first SaaS.** This architecture—validated by analyzing eight control-plane/agent systems, ten package registries, and the security models of Claude Code, Codex CLI, and Cursor—provides the strongest combination of developer ergonomics, cross-tool compatibility (`jaan run <skill> --json`), and defense-in-depth security. The transition from file-based skills to a versioned registry with RBAC requires a four-phase migration spanning approximately 6–9 months, starting with the skill manifest specification and local runtime hardening before building the control plane.

This report synthesizes primary research across official documentation, security research papers, standards bodies (SLSA, OWASP, NIST), and established OSS projects to ground every recommendation in evidence. The analysis covers 13+ reference systems and produces concrete deliverables: a skill manifest schema, threat model, benchmarking scorecard, and phased migration plan.

---

## Comparative analysis reveals five dominant patterns

Analysis of GitHub Actions runners, Terraform Cloud agents, Dagger Engine, Buildkite agents, GitLab runners, Pulumi Deployments, HashiCorp Vault Agent, and OPA reveals convergent architectural patterns that jaan-to should adopt.

**Pull-based communication is universal.** Every production system uses agent-initiated HTTPS polling—GitHub Actions uses 50-second long polls, Terraform Cloud and Buildkite use standard HTTPS polling, Pulumi polls every 30 seconds, and OPA uses ETag-based bundle polling. This eliminates inbound firewall requirements and simplifies network security. Dagger is the exception: it runs a local BuildKit-based engine with a GraphQL API, which is the closest analog to jaan-to's local-first execution model.

**Token-based registration with OIDC migration is the trajectory.** All systems start with static token registration (GitHub's registration token → runner token, TFC's agent pool token, Buildkite's agent token) but are migrating toward OIDC federation. Pulumi ESC generates **short-lived OIDC credentials at evaluation time** that are never stored. GitHub Actions now supports OIDC for cloud provider authentication. jaan-to should launch with API key auth but design for OIDC from day one.

**Pool/group-based multi-tenancy with label routing governs job dispatch.** GitHub uses runner groups scoped to organizations and repositories. Terraform Cloud uses agent pools assigned to workspaces. Buildkite uses queues with tag matching. GitLab offers instance/group/project runner scoping with tag-based routing. This maps directly to jaan-to's org/project/RBAC model—agent pools per organization, label-based skill routing.

| Dimension | GitHub Actions | Terraform Cloud | Dagger | Buildkite | GitLab | Pulumi | Vault Agent | OPA |
|---|---|---|---|---|---|---|---|---|
| **Protocol** | HTTPS long poll | HTTPS poll | GraphQL/HTTP | HTTPS poll | HTTPS long poll | HTTPS poll (30s) | HTTPS + local proxy | REST + bundle poll |
| **Auth** | Reg token → runner token | Pool token | Session auto-managed | Agent token | Auth token + job token | Pool token / OIDC | Auto-auth (AppRole, K8s, AWS) | Bearer / client certs |
| **Dispatch** | Label+group match | First available in pool | Client-initiated DAG | Queue/tag match | Tag-based poll | Pool assignment | N/A (sidecar) | Query-response |
| **Isolation** | None (ephemeral recommended) | Temp dir per run | Container (BuildKit) | Setup-dependent | Executor-dependent | Container per run | Process-level | Process-level |
| **Caching** | GitHub-managed storage | None built-in | Content-addressed (local) | Artifact API | S3/GCS/Azure | Auto dependency cache | Token/lease cache | In-memory + ETag |
| **RBAC** | Runner groups → org/repo | Pools → workspace | N/A | Queues + hooks | Instance/Group/Project | Pool + ESC RBAC | Path-based ACL | Bundle roots |

**OPA's bundle distribution model is the best pattern for policy and skill distribution.** OPA periodically downloads gzipped tarballs from HTTP servers, uses ETag headers for efficient polling, supports multiple bundles with non-overlapping roots, and enforces policies in-memory with sub-millisecond latency. This maps perfectly to distributing skills as bundles—the CLI downloads skill bundles, caches them locally, and executes them without round-tripping to the control plane.

**Ephemeral execution and hook systems provide extensibility without coupling.** Buildkite's hook system (global → plugin → repository precedence, lifecycle hooks from `pre-checkout` through `post-command`) and TFC's pre-plan/pre-apply hooks demonstrate how to inject security policies, credential management, and custom behavior. jaan-to should implement `pre-run`, `post-run`, and `on-error` hooks in its skill execution lifecycle.

---

## The skill package specification should combine npm, OCI, and GitHub Actions patterns

Analysis of npm, PyPI, OCI artifacts, VS Code extensions, GitHub Actions marketplace, Bazel modules, pre-commit hooks, Homebrew, and Sigstore reveals clear best practices for a skill registry.

### Proposed skill.yaml manifest

```yaml
# skill.yaml — jaan-to Skill Manifest v1
schemaVersion: "1.0"

# Identity (npm-style scoping prevents name squatting)
name: "@org/skill-name"
version: "1.2.0"                       # Strict SemVer
description: "One-line description"
author:
  name: "Author Name"
  url: "https://github.com/author"
license: "MIT"
repository: "https://github.com/org/repo"
keywords: ["typescript", "react", "testing"]
categories: ["code-generation", "refactoring"]

# Compatibility gating (npm/VS Code pattern)
engines:
  cli: ">=2.0.0"
  runtime: ["node>=18", "python>=3.10"]
platforms: ["linux", "macos", "windows"]

# Entry points (multi-type skills)
entryPoints:
  seed: "./templates/"
  prompt: "./prompts/main.md"
  transform: "./transforms/index.js"
  hooks:
    preRun: "./hooks/validate.sh"
    postRun: "./hooks/format.sh"

# Explicit permissions (Android/Chrome-style capability model)
permissions:
  fileSystem:
    read: ["**/*.ts", "**/*.tsx"]
    write: ["src/**"]
    create: ["src/components/**"]
  network: false
  exec: ["npm", "npx", "prettier"]
  environment: ["NODE_ENV"]
  secrets: []

# Dependencies (both skill and tool dependencies)
dependencies:
  skills:
    "@org/base-config": "^1.0.0"
  tools:
    prettier: ">=3.0.0"

# Inputs/Outputs contract (GitHub Actions pattern)
inputs:
  componentName:
    type: "string"
    description: "Name of the component to generate"
    required: true
  withTests:
    type: "boolean"
    default: true
outputs:
  filesCreated:
    type: "string[]"

# Distribution
files: ["templates/", "prompts/", "transforms/", "hooks/"]
digest: "sha256:..."                    # Content-addressable (OCI pattern)

# Provenance (populated at publish, Sigstore/SLSA)
provenance:
  sourceCommit: "abc123..."
  buildWorkflow: ".github/workflows/publish.yml"
  transparency: "https://rekor.sigstore.dev/entry/..."
  slsaLevel: 3
```

**Key design decisions and their rationale:**

The **`@org/name` scoping** follows npm's model to prevent the name-squatting problems that plague PyPI's flat namespace and the typosquatting attacks that have led to thousands of malicious packages. The **explicit permissions block** addresses the most critical anti-pattern found across reference systems: VS Code extensions run with full host access (no sandbox), and GitHub Actions inherit full job permissions with no action-level isolation. Both have suffered real-world exploits. The **`digest` field** follows OCI's content-addressable model where SHA-256 digests provide immutable references, unlike GitHub Actions' mutable tags that enabled the tj-actions/changed-files supply chain attack in 2025. The **provenance section** implements SLSA Level 3 via Sigstore keyless signing, matching npm's `--provenance` attestation model.

**Versioning should enforce strict SemVer with content-addressable digests.** Tags/versions are human-readable references; digests are the immutable truth. The CLI should resolve `@org/skill@^1.0.0` to a specific digest and pin it in a lockfile (`jaan.lock`), following npm's `package-lock.json` pattern. Published versions must be immutable—yanking (hiding) replaces deletion, following PyPI's model after the left-pad incident demonstrated the danger of allowing version deletion.

**Distribution follows a registry + CDN model.** The control plane hosts the registry API (metadata, search, version resolution) while skill bundles (gzipped tarballs, like npm) are stored in object storage (S3/GCS) with CDN distribution. This separates the discovery layer from artifact storage, matching GitHub Actions Marketplace and Bazel Central Registry patterns. The CLI caches bundles locally using content-addressable storage, matching Dagger's BuildKit-based caching.

---

## Security threat model demands defense-in-depth across seven layers

The threat landscape for a local execution agent serving AI coding assistants is uniquely dangerous because it combines **prompt injection** (manipulating the AI model), **supply chain attacks** (malicious skills), and **local execution risks** (path traversal, command injection) into a single attack surface.

### Critical threats and mitigations

| Threat | Severity | Likelihood | Mitigations |
|---|---|---|---|
| Indirect prompt injection via repo content | Critical | High | Instruction hierarchy, output sanitization, sandboxing |
| MCP tool poisoning / tool hijacking | Critical | High | Tool signing, capability scoping, allowlists |
| Malicious skill in registry | Critical | Medium | Sigstore signing, SLSA provenance, automated scanning |
| Path traversal via symlinks | High | Medium | `openat2()` + `RESOLVE_NO_SYMLINKS`, Go `os.Root` |
| TOCTOU race conditions | High | Medium | File-descriptor-based APIs, atomic operations |
| Command injection via shell interpolation | Critical | High | Parameterized execution, allowlists (never denylists) |
| Secret exfiltration via telemetry | High | Medium | Allowlist-only upload schema, PII scrubbing pipeline |
| Container/sandbox escape | Critical | Low | MicroVMs for untrusted code, defense-in-depth layers |

### Prompt injection is the most novel and dangerous threat

Research from HiddenLayer demonstrated that Cursor's command denylist was bypassed via hidden instructions in a GitHub README—HTML comments invisible when rendered but processed by the LLM caused exfiltration of an OpenAI API key via curl, despite curl being explicitly blocked. The AIShellJack framework showed that attackers can instruct the agent to write malicious code to a file and execute it through a legitimate interpreter, completely bypassing command-level filtering. A meta-analysis of 78 studies found that **attack success rates against state-of-the-art defenses exceed 85%** when adaptive strategies are used.

jaan-to's mitigation strategy must assume prompt injection will succeed and contain the blast radius:

1. **Instruction hierarchy enforcement**: System prompts override user instructions override tool outputs. Microsoft's "Spotlighting" technique isolates untrusted inputs using special delimiters.
2. **Sandbox as the real security boundary**: Even if prompt injection causes the model to attempt malicious actions, OS-level sandboxing (Landlock, seccomp, Seatbelt) prevents actual harm. Anthropic's Claude Code sandbox reduced permission prompts by **84%** while maintaining security.
3. **Allowlist-only command execution**: Denylists are provably insufficient. Skills must declare permitted executables in their manifest (`permissions.exec`), and the runtime enforces this allowlist.

### Sandboxing should use OS primitives, not containers, for CLI performance

| Approach | Security | Overhead | Portability | Best for |
|---|---|---|---|---|
| Landlock + seccomp | Medium-High | **<50ms** | Linux 5.13+ | CLI tools (Codex CLI uses this) |
| macOS Seatbelt | Medium-High | Negligible | macOS only | CLI tools (Claude Code uses this) |
| Bubblewrap | Medium-High | Minimal | Linux | Claude Code on Linux |
| Docker containers | Medium | ~50ms startup | Cross-platform | Development isolation |
| gVisor | High | 10-30% I/O | Linux | Multi-tenant cloud |
| Firecracker microVM | Very High | ~125ms boot | Linux+KVM | Untrusted code execution |
| WASM/WASI | High | Microseconds | Cross-platform | Capability-scoped plugins |

**Recommendation**: jaan-to's local runtime should use **Landlock + seccomp on Linux** and **Seatbelt on macOS**, matching the approach validated by both Claude Code and Codex CLI. This provides strong filesystem and network isolation with **under 50ms overhead per command**. For the cloud/hosted execution tier (future), use Firecracker microVMs. The skill manifest's `permissions` block maps directly to sandbox policy: `permissions.fileSystem.write: ["src/**"]` becomes a Landlock rule restricting write access to the `src/` subtree.

### Path safety requires file-descriptor-based APIs

Path traversal and TOCTOU races are not theoretical—CVE-2019-5736 (runc container escape), the Python filelock vulnerability (GHSA-w853-jp5j-5j7f affecting PyTorch and Poetry), and Go's filepath.Walk susceptibility to symlink races all demonstrate real exploitation. The **gold standard** is `openat2()` with `RESOLVE_NO_SYMLINKS | RESOLVE_BENEATH` flags, as used by runc. Go 1.24's `os.Root` provides a traversal-resistant API built on this foundation. jaan-to must never use the check-then-open anti-pattern; all file operations should use file-descriptor-based resolution.

### Supply chain integrity requires Sigstore + SLSA Level 3

The npm chalk/debug compromise (2025), @solana/web3.js hijack (2024), and XZ Utils backdoor (CVE-2024-3094) all demonstrate that supply chain attacks are frequent, sophisticated, and high-impact. jaan-to's registry must implement:

- **Sigstore keyless signing**: Authors authenticate via OIDC (GitHub Actions, Google), Fulcio issues a short-lived certificate, the skill is signed, and the signature is recorded in Rekor's transparency log. No long-lived keys to manage.
- **SLSA Level 3 provenance**: Build isolation, signed attestations linking the artifact to source commit and build workflow, non-falsifiable metadata.
- **Install-time verification**: The CLI verifies signatures and provenance before executing any skill. Unsigned skills are rejected by default (configurable per-org policy).
- **Automated scanning**: GuardDog-style malware scanning, pattern detection for credential theft, exfiltration, and prompt injection payloads.

---

## Secrets management should follow Pulumi ESC's zero-trust model

Analysis of HashiCorp Vault Agent, Pulumi ESC, 1Password CLI, Doppler, Infisical, and GitHub Actions secrets reveals that the modern standard is **short-lived, dynamically generated credentials with no persistent storage**.

| System | Auth Model | Injection Method | Zero-Trust Features |
|---|---|---|---|
| Vault Agent | Auto-auth (AppRole, K8s, AWS) | Template rendering, env vars, sink | Dynamic secrets, short-lived leases, policy-scoped |
| Pulumi ESC | OIDC federation | `esc run` (env vars), SDKs | Credentials generated on-demand, never stored |
| 1Password CLI | Biometric, service accounts | `op run`, `op inject`, `op://` refs | Scoped service accounts, biometric MFA |
| Doppler | Browser OAuth, service tokens | `doppler run` (env vars) | Environment-scoped, versioned history |
| GitHub Actions | Auto-provisioned GITHUB_TOKEN | `${{ secrets.NAME }}` | OIDC for cloud providers, auto-masking |

**jaan-to's secrets architecture should implement:**

1. **Secret reference syntax** (`jaan://vault/key` or delegation to `op://`, `vault://`) so secrets never appear in config files—only references resolved at runtime.
2. **Process-scoped injection** via `jaan run <skill>`, which injects secrets as environment variables for the child process duration only, following `op run` / `doppler run` patterns.
3. **OS keychain storage** for CLI auth tokens (macOS Keychain, Linux Secret Service, Windows Credential Manager), never plaintext on disk.
4. **OIDC federation** with major clouds (AWS STS, Azure Managed Identity, GCP Workload Identity) for short-lived credentials.
5. **Provider abstraction** allowing users to plug in Vault, 1Password, Doppler, or AWS Secrets Manager as their secrets source.

---

## Telemetry privacy requires an allowlist-only upload schema

Run summary uploads must follow a strict data classification framework. The PII scrubbing pipeline executes entirely on the client before any data leaves the machine:

**Safe to upload**: CLI version, parameterized command name (not arguments), exit code, duration, step count, error category (enumerated, not raw message), OS/arch, feature flags used, SHA-256 hash of project identifier (salted).

**Must never leave the machine**: File paths (contain usernames), environment variable values, git remote URLs, command arguments, stack traces with variable values, HTTP request/response bodies, IP addresses, connection strings.

The scrubbing pipeline applies seven steps: extract allowlisted fields → parameterize commands → categorize errors to enum → hash identifiers → regex-scan for PII patterns → validate against schema → reject if unknown fields present. This follows Sentry's `send_default_pii=False` default and OpenTelemetry's redaction processor model.

User consent must be **opt-in by default** with `jaan telemetry status`, `jaan telemetry off`, `jaan telemetry show-last` (audit last upload), and respect for the `DO_NOT_TRACK=1` environment variable. For enterprise customers, implement regional data routing (US, EU minimum), Data Processing Agreements, and design for GDPR DSAR compliance from day one. Pursue SOC 2 Type II certification early—it is table stakes for enterprise sales.

---

## Reference architecture combines Dagger's local-first model with OPA's bundle distribution

The recommended architecture for jaan-to positions the CLI as a local runtime agent with a lightweight cloud control plane, drawing from Dagger's local execution model, OPA's bundle distribution, and GitHub Actions' runner group RBAC.

### Architecture overview

```
┌─────────────────────────────────────────────────────┐
│                  CONTROL PLANE (SaaS)                │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌───────┐ │
│  │ Registry │  │ IAM/RBAC │  │ Policy │  │ Telemetry│
│  │ Service  │  │ Service  │  │ Engine │  │ Service│ │
│  │          │  │          │  │ (OPA)  │  │        │ │
│  └────┬─────┘  └────┬─────┘  └───┬────┘  └───┬───┘ │
│       │              │            │            │     │
│  ┌────▼──────────────▼────────────▼────────────▼───┐ │
│  │              API Gateway (REST + gRPC)           │ │
│  └──────────────────────┬──────────────────────────┘ │
│                         │                            │
│  ┌──────────────────────▼──────────────────────────┐ │
│  │         Object Storage (S3/GCS) + CDN           │ │
│  │     (skill bundles, provenance attestations)     │ │
│  └─────────────────────────────────────────────────┘ │
└───────────────────────────┬─────────────────────────┘
                            │ HTTPS (pull-based)
                            │
┌───────────────────────────▼─────────────────────────┐
│               LOCAL RUNTIME (CLI Agent)              │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Bundle   │  │ Sandbox  │  │ Secrets  │          │
│  │ Cache    │  │ Runtime  │  │ Resolver │          │
│  │ (CAS)   │  │ (Landlock/│  │ (multi-  │          │
│  │         │  │ Seatbelt) │  │ backend) │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │              │             │                 │
│  ┌────▼──────────────▼─────────────▼───────────────┐ │
│  │          Execution Engine                        │ │
│  │   jaan run <skill> --json [--project X]          │ │
│  │   ┌─────────┐  ┌────────┐  ┌──────────────┐    │ │
│  │   │pre-run  │→ │execute │→ │post-run      │    │ │
│  │   │hooks    │  │(sandboxed)│ │hooks+summary │    │ │
│  │   └─────────┘  └────────┘  └──────────────┘    │ │
│  └─────────────────────────────────────────────────┘ │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Telemetry Pipeline (local scrub → upload)       │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### How the contract `jaan run <skill> --json` works across tools

The universal contract enables Claude Code, Codex CLI, and Cursor to invoke skills identically:

```bash
# CLI invocation (human or AI agent)
jaan run @org/react-component --json \
  --input componentName=Button \
  --input withTests=true

# Returns structured JSON on stdout
{
  "status": "success",
  "outputs": { "filesCreated": ["src/components/Button.tsx", "src/components/Button.test.tsx"] },
  "duration_ms": 1247,
  "skill": "@org/react-component@1.2.0",
  "digest": "sha256:abc123..."
}
```

The optional HTTP API mirrors the CLI contract for programmatic access:

```
POST /v1/skills/run
Authorization: Bearer <token>
Content-Type: application/json

{
  "skill": "@org/react-component",
  "version": "^1.0.0",
  "inputs": { "componentName": "Button", "withTests": true },
  "project": "my-app"
}
```

**Cross-tool compatibility** works because each AI coding assistant invokes `jaan run` as a shell command and parses the `--json` output. The skill doesn't know or care which tool invoked it. Claude Code's `CLAUDE.md` can reference `jaan run @org/deploy --json`; Cursor's `.cursorrules` can reference the same command; Codex CLI can invoke it in its sandbox. The contract is the shell + JSON boundary, not an SDK.

### Control plane responsibilities versus local runtime responsibilities

The control plane handles state that benefits from centralization: the skill registry (search, version resolution, download URLs), IAM/RBAC (org membership, project access, API keys, OIDC), policy engine (OPA-based org policies like "only allow signed skills" or "block network-accessing skills"), telemetry aggregation (anonymized run summaries, dashboards), and billing.

The local runtime handles everything execution-related: bundle caching (content-addressable storage keyed by digest), sandbox enforcement (Landlock/Seatbelt policies derived from skill manifest permissions), secrets resolution (provider abstraction layer), execution lifecycle (hooks, timeout, retries), and telemetry scrubbing (PII removal before upload).

This separation means the CLI works offline after initial skill download—matching Dagger's local-first philosophy. The control plane enhances but never gates local execution.

---

## Benchmarking scorecard provides quantified evaluation

The benchmarking framework spans six dimensions with weighted scoring. The complete scorecard template with targets:

**Performance (25% weight)**: Cold start <500ms, warm execution <200ms, agent bootstrap <5s, API latency p99 <500ms, bundle download p95 <3s, peak memory <256MB, cache hit rate >80%. Measure with hyperfine (CLI) and k6 (API).

**Reliability (20% weight)**: Agent availability 99.9%, job success rate 99.5%, control plane availability 99.95%, job start latency p95 <10s, retry rate <5%. Track via Prometheus + Grafana with error budget alerting.

**Safety and security (15% weight)**: Score against OWASP SAMM v2 across five business functions (Governance, Design, Implementation, Verification, Operations). Evaluate execution sandboxing, auth/authz, supply chain security, data protection, AI safety controls, and incident response readiness.

**Developer experience (20% weight)**: Time-to-first-value <5 minutes, install-to-hello-world ≤3 steps, error recovery rate >80%, tab completion 100%, NPS >40, DXI score >70/100. Follow CLI design guidelines from clig.dev and the SPACE framework.

**Adoption (10% weight)**: 30-day activation rate >25%, DAU/MAU ratio >15%, D30 retention >25%, D90 retention >15%. Use 30-60 day activation windows (developer tools have non-linear adoption curves where a developer may disappear for weeks then return).

**ROI (10% weight)**: Target >200% annual ROI. Formula: `(hours_saved_per_dev/week × 52 × dev_count × hourly_rate - tool_cost) / tool_cost`. DX research validates that each Developer Experience Index point improvement equals **13 minutes saved per developer per week**. AI coding tools show a validated average of **2.4 hours saved per developer per week**.

---

## Four-phase migration plan from files to SaaS

### Phase 1: Foundation (weeks 1–8)

Formalize the skill manifest specification (`skill.yaml` v1), implement the local execution engine with sandboxing (Landlock/Seatbelt), and establish the `jaan run <skill> --json` contract. Skills remain file-based but now require a manifest. Key deliverables:

- skill.yaml schema validator
- Local sandbox runtime (Rust binary, following Codex CLI's `codex-linux-sandbox` pattern)
- Hook system (pre-run, post-run, on-error)
- `jaan init`, `jaan validate`, `jaan run` CLI commands
- Content-addressable local cache for skill bundles
- Unit and integration test suite with hyperfine benchmarks

**Risk**: Sandbox portability across Linux/macOS/Windows. **Mitigation**: Linux (Landlock+seccomp) and macOS (Seatbelt) first; Windows via WSL2 initially.

### Phase 2: Registry and distribution (weeks 9–16)

Build the control plane registry service and migrate skills from files to database + object storage with versioning. Implement Sigstore signing. Key deliverables:

- Registry API (REST): publish, search, resolve, download
- PostgreSQL for metadata; S3/GCS for bundles
- `jaan publish`, `jaan search`, `jaan install` commands
- Sigstore integration for signing at publish time
- Provenance verification at install time
- `jaan.lock` lockfile for reproducible installations
- Org/scope management (`@org/skill-name`)

**Risk**: Bootstrapping a registry with no content. **Mitigation**: Auto-ingest existing jaan-to skills as the initial registry population; maintain backward compatibility with file-based skills during transition.

### Phase 3: Control plane and RBAC (weeks 17–24)

Build IAM, RBAC, policy engine, and telemetry services. Implement the HTTP API. Key deliverables:

- OAuth2/OIDC authentication flow for CLI
- Org/project/team RBAC with invitation system
- OPA-based policy engine (org-level policies: allowed skills, required signing, sandbox requirements)
- Telemetry pipeline: local scrubbing → upload → aggregation → dashboard
- HTTP API (`POST /v1/skills/run`) for programmatic access
- Secrets resolution layer with provider abstraction (env vars, Vault, 1Password, Doppler)
- API key management for CI/CD integration

**Risk**: Policy engine complexity. **Mitigation**: Ship with 5–10 built-in policies (require signing, block network skills, restrict executables), allow custom Rego policies as a power-user feature.

### Phase 4: Enterprise and scale (weeks 25–36)

Enterprise features, compliance, and ecosystem growth. Key deliverables:

- SSO/SAML integration
- SOC 2 Type II audit preparation
- Regional data routing (US, EU)
- Data Processing Agreement template
- Billing integration (usage-based: runs per month, seats)
- `jaan audit` command for security review of installed skills
- Cross-tool integration guides (Claude Code, Codex, Cursor)
- Community marketplace with quality tiers (verified publishers, audited skills)
- Advanced analytics dashboard (adoption metrics, ROI calculator)

**Risk**: Enterprise sales cycle vs. engineering investment. **Mitigation**: Design billing abstractions early but implement last; focus on PLG adoption first.

### Migration decision matrix

| Decision | Option A | Option B | Recommendation |
|---|---|---|---|
| Manifest format | JSON | YAML | **YAML** (human-editable, comments, established in DevOps) |
| Bundle format | Tarball (.tgz) | OCI artifact | **Tarball** initially (simpler), migrate to OCI for ecosystem compatibility |
| Registry backend | PostgreSQL + S3 | Dedicated package registry (Artifactory) | **PostgreSQL + S3** (full control, lower cost) |
| Auth | API keys only | OAuth2 + OIDC | **OAuth2 + OIDC** from Phase 3 (API keys for CI in Phase 2) |
| Sandbox runtime language | Node.js | Rust | **Rust** (performance, memory safety, follows Codex CLI precedent) |
| Policy engine | Custom | OPA/Rego | **OPA** (battle-tested, CNCF graduated, bundle model fits) |
| Signing | GPG | Sigstore | **Sigstore** (keyless, modern, adopted by npm/PyPI/OCI) |

---

## Defense-in-depth checklist for implementation

### Layer 1: Input trust boundaries
- Treat all repository content (README, rules files, comments) as untrusted
- Implement instruction hierarchy: system > user > tool output
- Validate and hash-pin rules files; reject modified rules without explicit approval
- Use delimiter techniques (Spotlighting) to separate trusted/untrusted model context

### Layer 2: Permission and approval model
- Default to least-privilege (read-only baseline for file system)
- Allowlist approach for commands (skill manifest `permissions.exec` is the allowlist)
- Human approval for any operation outside the declared permission boundary
- Enterprise-managed settings that cannot be overridden by user or agent

### Layer 3: OS-level sandboxing
- Landlock filesystem restrictions derived from `permissions.fileSystem` in manifest
- seccomp-BPF syscall filtering: block socket/connect/bind except AF_UNIX
- Seatbelt profiles on macOS with equivalent restrictions
- Process hardening: disable ptrace (`PR_SET_DUMPABLE=0`), zero core dumps, strip `LD_PRELOAD`
- Git credentials excluded from sandbox environment

### Layer 4: Path and file safety
- Use `openat2()` with `RESOLVE_NO_SYMLINKS | RESOLVE_BENEATH` for all file operations
- Go implementation should use `os.Root` (Go 1.24+)
- Kernel sysctl `fs.protected_symlinks=1`
- Atomic file operations: `rename()` for replacement, `mkstemp()` for temp files

### Layer 5: Supply chain integrity
- Sigstore keyless signing mandatory for published skills
- SLSA Level 3 provenance attestations linked to source commit
- Install-time verification: reject unsigned skills by default
- Automated scanning for malicious patterns (credential theft, exfiltration, prompt injection payloads)
- Pin dependencies by digest in `jaan.lock`

### Layer 6: Secrets protection
- Never write secrets to disk; OS keychain for CLI auth only
- Process-scoped injection via `jaan run` subprocess pattern
- Secret reference syntax for config files (resolve at runtime)
- Scan all output for secret patterns before model consumption or telemetry upload

### Layer 7: Monitoring and response
- Log all agent actions (tool, arguments, result, DENIED status)
- Allowlist-only telemetry upload with local PII scrubbing
- Alert on sandbox boundary violations
- `jaan audit` command for security review
- Kill switch: org admins can revoke skills instantly via control plane

---

## Conclusion: three insights that should guide implementation

**First, the sandbox is the real security boundary—not the AI model's alignment.** Research consistently shows that prompt injection defenses have >85% bypass rates under adaptive attacks. Every system that relies solely on model-level safety (denylists, instruction tuning) has been compromised. Both Anthropic (Claude Code) and OpenAI (Codex CLI) converged independently on OS-level sandboxing as the primary defense. jaan-to's skill manifest permissions should map directly to sandbox policies enforced at the kernel level, making the manifest not just documentation but the source of truth for runtime enforcement.

**Second, the "control plane + local agent" architecture is not a novel pattern—it's a solved problem.** Eight production systems have validated pull-based polling, token-based registration, pool/group RBAC, and ephemeral execution. The novel contribution jaan-to can make is combining this with OPA-style policy bundles and Sigstore-signed skill packages to create a developer tool that is simultaneously open (works across Claude Code/Codex/Cursor), secure (defense-in-depth from supply chain to execution), and fast (local-first with <50ms sandbox overhead). The `jaan run <skill> --json` contract is the right abstraction—it's tool-agnostic, composable, and scriptable.

**Third, start with the hardest problem: the skill manifest and local runtime.** The registry and control plane are well-understood infrastructure problems. The novel and risky work is defining a permission model that is expressive enough for real skills but restrictive enough for real security, and building a sandbox runtime that works across Linux and macOS with negligible overhead. Phase 1 should deliver a working local runtime with sandboxing and the manifest spec—everything else follows from getting this contract right.