# detect-dev Reference Material

> Extracted reference tables, format specifications, and scoring rubrics for the `detect-dev` skill.
> This file is loaded by `detect-dev` SKILL.md via inline pointers.

---

## Evidence Format (SARIF-compatible)

Every finding MUST include structured evidence blocks:

```yaml
evidence:
  id: E-DEV-001                # Single-platform format
  id: E-DEV-WEB-001            # Multi-platform format (platform prefix)
  type: code-location          # code-location | config-pattern | dependency | metric | absence
  confidence: 0.95             # 0.0-1.0
  location:
    uri: "src/auth/login.py"
    startLine: 42
    endLine: 58
    snippet: |
      query = "SELECT * FROM users WHERE id=" + user_id
  method: manifest-analysis    # manifest-analysis | static-analysis | manual-review | pattern-match | heuristic
```

**Evidence ID Format**:

```python
# Generation logic:
if current_platform == 'all' or current_platform is None:  # Single-platform
  evidence_id = f"E-DEV-{sequence:03d}"                     # E-DEV-001
else:  # Multi-platform
  platform_upper = current_platform.upper()
  evidence_id = f"E-DEV-{platform_upper}-{sequence:03d}"    # E-DEV-WEB-001, E-DEV-BACKEND-023
```

Evidence IDs use namespace `E-DEV-*` to prevent collisions in detect-pack aggregation. Platform prefix prevents ID collisions across platforms in multi-platform analysis.

---

## Frontmatter Schema (Universal)

Every output file MUST include this YAML frontmatter:

```yaml
---
title: "{document title}"
id: "{AUDIT-YYYY-NNN}"
version: "1.0.0"
status: draft
date: {YYYY-MM-DD}
target:
  name: "{repo-name}"
  platform: "{platform_name}"  # 'all' for single-platform, 'web'/'backend'/etc for multi-platform
  commit: "{git HEAD hash}"
  branch: "{current branch}"
tool:
  name: "detect-dev"
  version: "1.0.0"
  rules_version: "2024.1"
confidence_scheme: "four-level"
findings_summary:
  critical: 0
  high: 0
  medium: 0
  low: 0
  informational: 0
overall_score: 0.0             # 0-10, OpenSSF-style
lifecycle_phase: post-build    # CycloneDX vocabulary
---
```

---

## Document Structure (Diataxis)

Each output file follows:
1. **Executive Summary** - BLUF: what was found and why it matters
2. **Scope and Methodology** - What was analyzed, tools used, exclusions
3. **Findings** - Each as H3 with ID/severity/confidence/description/evidence/impact/remediation
4. **Recommendations** - Prioritized remediation roadmap
5. **Appendices** - Methodology details, confidence scale reference

---

## Prohibited Anti-patterns

- Never present speculation as evidence. Use hedging for confidence < Firm.
- Never omit confidence levels. Every finding MUST include confidence.
- Never inflate severity. Reserve Critical for verified, exploitable, high-impact.
- Never make scope-exceeding claims. Distinguish "findings" from "observations".

---

## Platform Disambiguation Rules

**Priority order** (highest to lowest):

1. **Explicit markers**: Check `package.json` `workspaces` field or `nx.json` app names
2. **Exact folder match**: `web/`, `backend/`, `mobile/` (case-insensitive exact match)
3. **Pattern match**: `*frontend*`, `*server*`, `*app*` in folder name
4. **File pattern fallback**: If folder contains `.jsx/.tsx` -> web, `Dockerfile` -> backend, `.kt/.swift` -> mobile

**Conflict resolution**:

- **Multiple patterns match** (e.g., `client-server/`): Prompt user to select or split
- **Subfolder structure** (e.g., `apps/web/`): Use subfolder name as platform, ignore parent
- **Shared code** (`packages/`, `libs/`): Analyze once without platform suffix (creates `stack.md` not `stack-shared.md`), then link findings via `related_evidence` in per-platform outputs

**Edge cases**:

- **Microservices** (`services/auth/`, `services/payment/`): All under single 'backend' platform (not separate platforms)
- **Mobile subfolders** (`app/ios/`, `app/android/`): Two platforms (ios, android), not one "app" platform
- **Monorepo without markers** (Bazel WORKSPACE, custom build system): Fall back to manual platform selection via interactive prompt
- **Turborepo/Nx patterns** (`apps/*/`, `packages/*/`): Use glob to list subdirectories, classify each independently

**Validation**:

After auto-detection, always show: "Detected platforms: {list}. Correct? [y/n/select]"
- If 'n' or 'select', prompt: "Enter platform names (comma-separated): "

---

## Language-Specific Scan Patterns (Step 2 Reference)

### Python
- Glob: `**/pyproject.toml`, `**/requirements.txt`, `**/Pipfile`, `**/setup.py`, `**/setup.cfg`
- Extract: dependencies, dev-dependencies
- Detect frameworks: fastapi, django, flask, starlette, litestar, tornado
- Detect ORM: sqlalchemy, django-orm, tortoise-orm, peewee
- Detect testing: pytest, unittest, nose2, tox
- Detect version from: `python_requires` or `[tool.poetry.dependencies].python`

### Go
- Glob: `**/go.mod`
- Extract: module name, go version, require statements
- Detect frameworks: gin, echo, fiber, chi, gorilla/mux

### Rust
- Glob: `**/Cargo.toml`
- Extract: package name, edition, dependencies
- Detect frameworks: actix-web, axum, rocket, warp, tokio

### Ruby
- Glob: `**/Gemfile`
- Extract: gems
- Detect frameworks: rails, sinatra, hanami

### Java / Kotlin
- Glob: `**/pom.xml`, `**/build.gradle`, `**/build.gradle.kts`
- Detect: spring-boot, quarkus, micronaut, ktor

### PHP
- Glob: `**/composer.json`
- Detect: laravel, symfony, slim

### C# / .NET
- Glob: `**/*.csproj`, `**/*.sln`
- Detect: aspnet, blazor, maui

### Dart / Flutter
- Glob: `**/pubspec.yaml`
- Detect: flutter

### Elixir
- Glob: `**/mix.exs`
- Detect: phoenix

### Swift
- Glob: `**/Package.swift`
- Detect: vapor, swiftui

---

## Confidence Scoring Examples (Step 8 Reference)

| Confidence | Source | Example |
|-----------|--------|---------|
| Confirmed (0.95-1.00) | Manifest file with explicit dependency | `"react": "^18.2.0"` in package.json |
| Firm (0.80-0.94) | Docker image with version tag | `postgres:15` in docker-compose |
| Firm (0.80-0.94) | CI workflow file | `.github/workflows/` exists |
| Tentative (0.50-0.79) | Directory structure inference | `k8s/` directory exists |
| Uncertain (0.20-0.49) | Grep mention in arbitrary files | "datadog" mentioned in a README |

**Only include detections with confidence >= Uncertain (0.20) in findings.**

Calculate overall_score (OpenSSF-style 0-10):
`overall_score = 10 - (critical * 2.0 + high * 1.0 + medium * 0.4 + low * 0.1) / max(total_findings, 1)`
Clamp result to 0-10 range.
