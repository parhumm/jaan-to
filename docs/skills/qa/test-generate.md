---
title: "qa-test-generate"
sidebar_position: 3
doc_type: skill
created_date: 2026-02-11
updated_date: 2026-02-23
tags: [qa, test, generate, vitest, playwright, bdd, gherkin, e2e, unit]
related: [qa-test-cases, backend-scaffold, frontend-scaffold, backend-service-implement]
---

# /qa-test-generate

> Produce runnable Vitest unit tests and Playwright E2E specs from BDD test cases and scaffold code.

---

## Overview

Transforms BDD/Gherkin test cases (from `/qa-test-cases`) into runnable test files using Vitest for unit/integration tests and Playwright for E2E tests. Generates test data factories, MSW mock handlers, page objects, and CI configuration. Uses tag-based routing to map scenarios to the correct test layer.

---

## Usage

```
/qa-test-generate
/qa-test-generate qa-test-cases backend-scaffold
```

| Argument | Required | Description |
|----------|----------|-------------|
| qa-test-cases | Yes | Path to BDD/Gherkin test cases output |
| backend-scaffold or frontend-scaffold | Yes | Path to scaffold output |
| backend-api-contract | No | OpenAPI YAML for MSW handler generation |
| backend-service-implement | No | Service files for deeper unit tests |
| `--from-mutants` | No | Path to survivors JSON from `/qa-test-mutate` |

When run without arguments, launches an interactive wizard.

---

## What It Produces

Files at `$JAAN_OUTPUTS_DIR/qa/test-generate/{id}-{slug}/`:

| File | Content |
|------|---------|
| `{id}-{slug}.md` | Test generation guide with coverage map |
| `*.unit.test.ts` | Vitest unit tests with jest-cucumber BDD binding |
| `*.integration.test.ts` | API/service integration tests |
| `*.e2e.spec.ts` | Playwright E2E tests with playwright-bdd |
| `*.factory.ts` | Test data factories (Fishery + zod-mock) |
| `*.handlers.ts` | MSW mock handlers from OpenAPI |
| `*.page.ts` | Page objects for Playwright |
| `vitest.config.ts` | Vitest workspace configuration |
| `playwright.config.ts` | Playwright BDD configuration |

---

## What It Asks

| Question | When | Why |
|----------|------|-----|
| Test layer scope | Always | Unit / integration / E2E / all |
| BDD binding style | Not detected | jest-cucumber / playwright-bdd |
| Mock strategy | API tests | MSW / manual mocks / both |
| CI runner | Not in tech.md | GitHub Actions / GitLab CI |

---

## Tag Routing

Maps Gherkin tags to test layers:

| Tag | Layer | Framework |
|-----|-------|-----------|
| `@unit` | Unit test | Vitest + jest-cucumber |
| `@integration` | Integration test | Vitest + supertest |
| `@e2e` | E2E test | Playwright + playwright-bdd |
| `@api` | API test | Vitest + MSW |

---

## Workflow Chain

```
/qa-test-cases + /backend-scaffold --> /qa-test-generate
```

---

## Example

**Input:**
```
/qa-test-generate path/to/test-cases path/to/backend-scaffold
```

**Output:**
```
jaan-to/outputs/qa/test-generate/01-user-auth/
├── 01-user-auth.md
├── user-auth.unit.test.ts
├── user-auth.integration.test.ts
├── user-auth.e2e.spec.ts
├── user-auth.factory.ts
├── user-auth.handlers.ts
├── user-auth.page.ts
├── vitest.config.ts
└── playwright.config.ts
```

---

## Mutation-Guided Mode

Generate targeted tests for surviving mutants identified by `/qa-test-mutate`:

```
/qa-test-generate --from-mutants path/to/survivors.json
```

The `--from-mutants` flag reads a survivors JSON file (schema v1.0) produced by `/qa-test-mutate`. For each surviving mutant, the skill generates a targeted test that specifically kills that mutant, improving overall mutation score without redundant test bloat.

---

## Pyramid Validation

Test generation includes **testing pyramid validation** to ensure the generated test distribution follows best practices:

- **More unit tests** than integration tests
- **More integration tests** than E2E tests

If the generated output violates pyramid proportions, the skill emits a warning and suggests rebalancing before finalizing.

---

## Tips

- Run `/qa-test-cases` first to generate BDD scenarios
- Provide OpenAPI contract for automatic MSW handler generation
- Use tag routing to control which test layers are generated
- Copy generated configs to your project and adjust paths

---

## Related Skills

- [/qa-test-cases](test-cases.md) - Generate BDD/Gherkin test cases
- [/qa-test-mutate](test-mutate.md) - Mutation testing to find surviving mutants (input for `--from-mutants` mode)
- [/backend-scaffold](../backend/scaffold.md) - Generate backend code stubs
- [/backend-service-implement](../backend/service-implement.md) - Generate service implementations

---

## Technical Details

- **Logical Name**: qa-test-generate
- **Command**: `/qa-test-generate`
- **Role**: qa
- **Output**: `$JAAN_OUTPUTS_DIR/qa/test-generate/{id}-{slug}/`
