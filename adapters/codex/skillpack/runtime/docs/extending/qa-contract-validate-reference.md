# qa-contract-validate Reference

> Extracted reference material for the `qa-contract-validate` skill. Contains tool configs, CI patterns, and installation guides.

---

## Tool Installation Guide

### Spectral (npm)

```bash
# Project-local (recommended)
npm install -D @stoplight/spectral-cli

# Verify
npx --no-install @stoplight/spectral-cli --version
```

### oasdiff (Go binary -- NOT npm)

```bash
# Homebrew
brew install oasdiff

# Go install
go install github.com/tufin/oasdiff@latest

# Verify
oasdiff --version

# CI (GitHub Actions): pin to immutable commit SHA
# oasdiff/oasdiff-action@{sha} -- NEVER use @latest
```

### Prism (npm)

```bash
# Project-local
npm install -D @stoplight/prism-cli

# Verify
npx --no-install @stoplight/prism-cli --version
```

### Schemathesis (Python pip)

```bash
# pip install
pip install schemathesis

# Verify
schemathesis --version
```

---

## Spectral Ruleset Configuration

### Basic `.spectral.yaml`

```yaml
extends:
  - "spectral:oas"
rules:
  operation-operationId: error
  operation-description: warn
  oas3-api-servers: error
  no-$ref-siblings: error
  info-contact: warn
  info-description: warn
```

### With OWASP Rules

```yaml
extends:
  - "spectral:oas"
  - "@stoplight/spectral-owasp-ruleset"
rules:
  owasp:api1:2019-no-numeric-ids: warn
  owasp:api2:2019-no-http-basic: error
  owasp:api3:2019-define-error-responses-401: error
  owasp:api3:2019-define-error-responses-500: error
  owasp:api4:2019-rate-limit: warn
```

---

## CI Integration Patterns

### GitHub Actions -- Spectral

```yaml
- name: Lint OpenAPI Spec
  run: npx --no-install @stoplight/spectral-cli lint api.yaml --format junit --output spectral-results.xml
```

### GitHub Actions -- oasdiff

```yaml
- name: Check Breaking Changes
  uses: oasdiff/oasdiff-action@{pinned-sha}
  with:
    base: 'main:api.yaml'
    revision: api.yaml
    fail-on: ERR
```

### GitHub Actions -- Schemathesis

```yaml
- name: API Fuzz Testing
  run: |
    pip install schemathesis
    schemathesis run --url ${{ vars.API_URL }} api.yaml --stateful=links
```

---

## Aggregate Status Logic

| Spectral | oasdiff | Prism | Schemathesis | Aggregate |
|----------|---------|-------|-------------|-----------|
| PASS | PASS | PASS | PASS | **PASS** |
| WARN | * | * | * | **WARN** |
| FAIL | * | * | * | **FAIL** |
| * | FAIL | * | * | **FAIL** |
| * | * | FAIL | * | **FAIL** |
| * | * | * | FAIL | **FAIL** |
| SKIP | SKIP | SKIP | SKIP | **INCONCLUSIVE** |

Rules:
- Any FAIL in any tool = aggregate FAIL
- All tools skipped = INCONCLUSIVE (never PASS)
- Only warnings, no errors = WARN
- All tools pass = PASS
