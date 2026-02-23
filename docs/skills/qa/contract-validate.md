---
title: "qa-contract-validate"
sidebar_position: 7
doc_type: skill
created_date: 2026-02-23
updated_date: 2026-02-23
tags: [qa, api, contract, spectral, oasdiff, prism, schemathesis, openapi]
related: [backend-api-contract, dev-verify, devops-infra-scaffold]
---

# /jaan-to:qa-contract-validate

> Validate API contracts through a multi-tool pipeline -- lint, diff, mock, and fuzz.

---

## Overview

Runs a 4-stage validation pipeline against OpenAPI/Swagger specs: Spectral for linting, oasdiff for breaking change detection, Prism for conformance checking, and Schemathesis for fuzz testing. Each tool runs independently based on availability and provided inputs. Gracefully degrades when tools are missing -- reports INCONCLUSIVE rather than false PASS.

---

## Usage

```
/jaan-to:qa-contract-validate api/openapi.yaml
/jaan-to:qa-contract-validate api/openapi.yaml --baseline api/openapi-v1.yaml
/jaan-to:qa-contract-validate api/openapi.yaml --url http://localhost:3000
```

| Argument | Required | Description |
|----------|----------|-------------|
| spec path | Yes | Path to OpenAPI/Swagger YAML or JSON file |
| `--baseline` | No | Baseline spec for breaking change detection (oasdiff) |
| `--url` | No | Running API URL for conformance and fuzz testing |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/qa/contract-validate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Validation report with per-tool results and aggregate status |
| `spectral-results.json` | Raw Spectral lint output (if ran) |
| `oasdiff-results.json` | Raw oasdiff output (if ran) |
| `schemathesis-results.json` | Raw Schemathesis output (if ran) |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Spec path | No input provided | Need OpenAPI spec to validate |
| Baseline spec | Not provided via `--baseline` | Optional, enables breaking change detection |
| API URL | Not provided via `--url` | Optional, enables live conformance and fuzz testing |

---

## Validation Pipeline

| Stage | Tool | Type | Condition |
|-------|------|------|-----------|
| 1. Lint | Spectral | npm | Always (if installed) |
| 2. Breaking Changes | oasdiff | Go binary | Baseline provided + installed |
| 3. Conformance | Prism | npm | API URL provided + installed |
| 4. Fuzz Testing | Schemathesis | Python pip | API URL provided + installed |

**Aggregate status**: PASS (all ran, no errors), WARN (warnings only), FAIL (errors/breaking/defects), INCONCLUSIVE (0 tools ran).

---

## Tool Installation

| Tool | Install Command |
|------|----------------|
| Spectral | `npm install -g @stoplight/spectral-cli` |
| oasdiff | `go install github.com/tufin/oasdiff@latest` or `brew install oasdiff` |
| Prism | `npm install -g @stoplight/prism-cli` |
| Schemathesis | `pip install schemathesis` |

The skill checks availability with `npx --no-install` (npm tools) or version commands. It never auto-installs tools.

---

## Example

**Input:**
```
/jaan-to:qa-contract-validate api/openapi.yaml --baseline api/openapi-v1.yaml --url http://localhost:3000
```

**Output:**
```
jaan-to/outputs/qa/contract-validate/01-user-api/
├── 01-user-api.md                (validation report)
├── spectral-results.json
├── oasdiff-results.json
└── schemathesis-results.json
```

**Report summary:**
```
Pipeline: 4/4 tools executed
Aggregate: WARN
  Spectral:     WARN (2 warnings, 0 errors)
  oasdiff:      PASS (0 breaking changes)
  Prism:        PASS (0 conformance violations)
  Schemathesis: PASS (0 defects in 150 requests)
```

---

## Tips

- Run `/jaan-to:backend-api-contract` first to generate the OpenAPI spec
- Provide `--baseline` to catch breaking changes between versions
- Start your API locally and use `--url` for live conformance and fuzz testing
- Add contract validation CI stages via `/jaan-to:devops-infra-scaffold`

---

## Related Skills

- [/jaan-to:backend-api-contract](../backend/api-contract.md) - Generate OpenAPI specs
- [/jaan-to:dev-verify](../dev/verify.md) - Verify build pipeline and services
- [/jaan-to:devops-infra-scaffold](../devops/infra-scaffold.md) - Add contract validation CI stages

---

## Technical Details

- **Logical Name**: qa-contract-validate
- **Command**: `/jaan-to:qa-contract-validate`
- **Role**: qa
- **Scope**: OpenAPI/Swagger only (v1). GraphQL and gRPC out of scope.
- **Output**: `$JAAN_OUTPUTS_DIR/qa/contract-validate/{id}-{slug}/`
- **Reference**: `docs/extending/qa-contract-validate-reference.md`
