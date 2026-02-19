# qa-test-generate — Reference Material

> Extracted reference tables, code templates, and patterns for the `qa-test-generate` skill.
> This file is loaded by `qa-test-generate` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## Config Generation Specifications

### 5.1 Vitest Workspace Configuration (Research Section 4)

Generate `vitest.config.ts` with workspace separation:
- **unit** workspace: `src/**/*.{test,spec}.ts`, node environment, MSW setup
- **integration** workspace: `src/**/*.integration.test.ts`, node environment, DB + MSW setup, fork pool
- **bdd-unit** workspace: BDD step files tagged @unit, jsdom environment
- **bdd-integration** workspace: BDD step files tagged @integration, node environment, global DB setup

Include coverage configuration:
- Provider: v8
- Reporters: text, json-summary, lcov, html
- Thresholds: lines 80, branches 70, functions 75, statements 80

### 5.2 Playwright Configuration (Research Section 5)

Generate `playwright.config.ts` with playwright-bdd integration:
- `defineBddConfig` pointing to feature files and step definitions
- Projects: chromium, firefox, webkit (filtered by @e2e), mobile-chrome (@mobile), api (@api)
- CI-friendly settings: retries, workers, reporters (html + json + github)
- Web server configuration for local dev
- Sharding support for CI

### 5.3 Test Setup Files

Generate setup files:
- `test/setup/unit.ts` -- MSW server lifecycle (beforeAll/afterEach/afterAll)
- `test/setup/integration.ts` -- DB connection + MSW + transaction isolation
- `test/setup/bdd-unit.ts` -- Inherits unit setup + BDD timeout config
- `test/mocks/server.ts` -- MSW setupServer instance
- `test/mocks/handlers.ts` -- Auto-generated MSW handlers (from API contract if available, otherwise from scaffold routes)

---

## Test Data Layer Patterns

### 6.1 Test Data Factories (Research Section 2)

For each entity extracted from scaffold schemas:
- Generate `test/factories/{entity}.factory.ts` using Fishery pattern
- If Zod schemas exist in scaffold, combine with @anatine/zod-mock for defaults
- Include traits for common variants (e.g., `adminFactory`, `inactiveUserFactory`)
- Include sequences for unique IDs and emails
- Include associations for related entities

### 6.2 MSW Handlers (Research Section 3)

If backend-api-contract provided:
- Parse OpenAPI spec to generate typed MSW handlers
- One handler per endpoint (GET, POST, PUT, DELETE)
- Default responses use factory-generated data
- Error handlers for common failure modes (400, 401, 403, 404, 500)

If no API contract:
- Generate handlers from scaffold route definitions
- Use scaffold schema types for response shapes

### 6.3 Database Seed File

Generate `test/fixtures/db-seed.ts`:
- Named seed scenarios mapping to BDD Background steps
- Truncation helper for test isolation
- Transaction-based isolation pattern

### 6.4 Test Utilities

Generate `test/utils/test-utils.ts`:
- Custom Vitest matchers (e.g., `toMatchApiContract` for schema validation)
- Shared setup helpers
- BDD step helper functions

---

## BDD Binding Code Templates

Using jest-cucumber binding pattern adapted for Vitest (Research Pattern B):

```typescript
// Pattern: Feature-scoped step definitions
import { describe, it, expect, beforeEach } from 'vitest';

describe('Feature: {Feature Name}', () => {
  // Background -> beforeEach
  beforeEach(async () => {
    // Given steps from Background
  });

  // Each Scenario -> it() block
  it('Scenario: {Scenario Name}', async () => {
    // Given -> Arrange (factory setup, mock configuration)
    // When -> Act (function call, service invocation)
    // Then -> Assert (expect statements)
  });
});
```

---

## Integration Test Patterns

### 8.1 API Integration Tests

Using Vitest with MSW for HTTP-layer testing:
- Import route handler
- Configure MSW for downstream dependencies
- Map BDD Given steps to DB seed + MSW handler setup
- Map BDD When steps to HTTP request execution (supertest or direct handler invocation)
- Map BDD Then steps to response assertions (status code, body shape, headers)
- Validate response against API contract schema if available

### 8.2 Service Integration Tests

For cross-service operations:
- Set up transaction isolation
- Map BDD scenarios to multi-service test flows
- Assert database state changes
- Test error propagation across service boundaries

---

## Playwright BDD Step Templates

Using playwright-bdd pattern:

```typescript
// steps/{feature}.steps.ts
import { createBdd } from 'playwright-bdd';
import { test } from './fixtures';

const { Given, When, Then } = createBdd(test);

Given('{string} is on the {string} page', async ({ page }, user, pageName) => {
  await page.goto(`/${pageName}`);
});

When('they click the {string} button', async ({ page }, buttonLabel) => {
  await page.getByRole('button', { name: buttonLabel }).click();
});

Then('they should see {string}', async ({ page }, text) => {
  await expect(page.getByText(text)).toBeVisible();
});
```

---

## E2E Page Object Patterns

### 9.2 Page Object Generation

For each page/screen referenced in E2E scenarios:
- Generate page object class with locators
- Map BDD Given steps to navigation + state setup
- Map BDD When steps to page interactions
- Map BDD Then steps to visual/content assertions

### 9.3 Fixture Composition

Generate `steps/fixtures.ts`:
- Page object fixtures for each page
- API client fixture for seed operations
- Authentication fixture for logged-in scenarios
- Database seeder fixture (if needed for E2E)

---

## Key Generation Rules

### BDD-to-Assertion Mapping (Research Section 1)

| Gherkin Keyword | Test Phase | Vitest Pattern | Playwright Pattern |
|----------------|------------|----------------|-------------------|
| `Given` | Arrange/Setup | Factory build, vi.mock setup, MSW handler | Page navigation, API seed, fixture setup |
| `When` | Act/Trigger | Function call, service invocation | Page interaction (click, fill, submit) |
| `Then` | Assert/Verify | expect() value check | expect(locator) visibility/content check |
| `And/But` | Extends previous | Same as parent context | Same as parent context |
| `Background` | beforeEach | beforeEach() block | playwright-bdd Background |
| `Scenario Outline` | Parameterized | describe.each / it.each | playwright-bdd Examples table |

### Tag-to-Tier Routing (Research Section 6)

```
@unit          -> Vitest bdd-unit workspace
@smoke         -> Vitest fast subset + Playwright critical path
@e2e           -> Playwright full browser tests
@mobile        -> Playwright mobile projects only
@api           -> Vitest API integration tests
@integration   -> Vitest bdd-integration workspace
@boundary      -> Vitest unit workspace
@edge-case     -> Vitest unit + Playwright E2E
@negative      -> Vitest unit + integration
@positive      -> Split across tiers based on co-occurring tags
```

### Test Data Factory Pattern (Research Section 2)

- Use Fishery for class-based factories with traits, sequences, associations
- Use @anatine/zod-mock for schema-derived defaults (if Zod schemas in scaffold)
- Combine: Fishery provides structure, zod-mock provides realistic defaults
- Never use hardcoded fixture files when factories can generate dynamic data

### MSW Handler Pattern (Research Section 3)

- Generate from OpenAPI contract when available
- Default responses use factory-generated data
- Override per-scenario with `server.use()` in BDD steps
- Error handlers for 400, 401, 403, 404, 422, 500

### Anti-Patterns to NEVER Generate

- Empty test bodies (`it('should work', () => {})`)
- Placeholder assertions (`expect(true).toBe(true)`)
- Generic test data when BDD specifies concrete values
- Missing Given setup (tests that assume state without establishing it)
- Coupled tests (tests that depend on execution order)
- Direct DB access in E2E tests (use API or fixtures)
- Hardcoded wait times in Playwright (use `waitFor`, `toBeVisible`, etc.)
- Screenshot-only assertions without semantic checks

---

## Detailed Tag Routing Map

Route BDD scenarios to test tiers based on tag taxonomy with target descriptions:

```
TAG ROUTING MAP
-------------------------------------------------------------
@unit          -> Vitest (unit workspace)
                  Target: service functions, utility functions, hooks
@smoke         -> Vitest (fast subset) + Playwright (critical path)
                  Target: core happy path validation
@integration   -> Vitest (integration workspace, with MSW)
                  Target: API route handlers, service + DB interactions
@e2e           -> Playwright (full browser tests)
                  Target: complete user journeys
@mobile        -> Playwright (mobile projects only)
                  Target: responsive/mobile-specific flows
@api           -> Vitest (API integration) or Playwright API testing
                  Target: HTTP endpoint contract validation
@boundary      -> Vitest (unit workspace)
                  Target: min/max value validation
@edge-case     -> Vitest (unit) + Playwright (E2E for UI edge cases)
                  Target: empty states, concurrent ops, error conditions
@negative      -> Vitest (unit + integration)
                  Target: error handling, validation failures
@positive      -> Split across all tiers based on co-occurring tags
```

---

## Quality Check Checklist

Before preview, validate generated tests against all of the following:

**Completeness:**
- [ ] Every BDD scenario has a corresponding test file
- [ ] Every @unit scenario maps to a Vitest test
- [ ] Every @e2e scenario maps to a Playwright spec
- [ ] Every @integration scenario maps to an integration test
- [ ] All Given steps have setup code (no empty stubs)
- [ ] All When steps have action code (no TODOs)
- [ ] All Then steps have assertion code (no `expect(true).toBe(true)`)

**Test Data:**
- [ ] Factories exist for all entities referenced in BDD scenarios
- [ ] MSW handlers cover all API endpoints referenced in tests
- [ ] Concrete test data values match BDD scenario data (not generic placeholders)
- [ ] DB seed scenarios match BDD Background steps

**Configuration:**
- [ ] Vitest config has correct workspace separation
- [ ] Playwright config has correct project/tag filtering
- [ ] Setup files wire MSW server correctly
- [ ] Coverage thresholds configured

**Code Quality:**
- [ ] No placeholder comments ("TODO: implement", "FIXME")
- [ ] Import paths are correct relative to output structure
- [ ] TypeScript types are properly referenced
- [ ] Test names match BDD scenario names for traceability
- [ ] @tags from BDD preserved as test.describe or grep annotations

---

## Definition of Done Checklist

- [ ] All BDD scenarios parsed and routed to correct test tier
- [ ] Vitest workspace config generated with unit + integration separation
- [ ] Playwright config generated with playwright-bdd + project filtering
- [ ] MSW handlers generated (from API contract or scaffold routes)
- [ ] Test data factories generated for all entities
- [ ] Unit tests generated for all @unit/@smoke/@boundary scenarios
- [ ] Integration tests generated for all @integration/@api scenarios
- [ ] E2E Playwright specs generated for all @e2e/@mobile scenarios
- [ ] All Given/When/Then steps have concrete implementation (no stubs)
- [ ] Concrete test data values from BDD preserved in generated tests
- [ ] Quality check passed (completeness, data, config, code quality)
- [ ] Sequential ID generated
- [ ] Folder created: `{id}-{slug}/`
- [ ] Main document written with test strategy and coverage map
- [ ] Index updated
- [ ] User approved final result
