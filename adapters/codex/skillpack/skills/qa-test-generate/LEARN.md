# Lessons: qa-test-generate

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:qa-test-generate.learn.md`

## Better Questions

- Ask whether the project already has existing test infrastructure (vitest.config.ts, playwright.config.ts, MSW setup) before generating new config files -- avoid overwriting or conflicting with established patterns
- Ask about the team's preferred BDD binding approach: feature-scoped (jest-cucumber style) vs global step registry (Cucumber.js style) -- impacts reusability and maintenance burden
- Ask if the project uses Zod, Yup, or another validation library -- determines whether to use @anatine/zod-mock or plain Fishery for factory generation
- Ask about database setup for integration tests: does the team have a test DB instance, Docker Compose, or prefer in-memory? -- affects db-seed.ts generation
- Clarify whether @smoke tests should generate both Vitest AND Playwright versions, or only one tier

## Edge Cases

- BDD scenarios with Scenario Outline + Examples table need `describe.each` / `it.each` in Vitest and Examples-to-parameterized mapping in playwright-bdd
- Scenarios with Background section must be mapped to `beforeEach()` in Vitest and Background in playwright-bdd -- do not duplicate Background steps inside each test
- When BDD test data references dates like "today", "tomorrow", generate deterministic date helpers using `vi.useFakeTimers()` instead of `new Date()`
- Multiple @tags on a single scenario (e.g., `@smoke @e2e @mobile`) may cause it to appear in multiple test tiers -- deduplicate by primary tag priority: @e2e > @integration > @unit
- Empty/null state edge cases from BDD may need special MSW handlers returning empty arrays or 404 responses

## Workflow

- Parse ALL BDD scenarios first, build complete tag inventory, THEN plan test generation -- do not start generating tests until the full picture is clear
- Generate config files before test files -- tests depend on vitest.config.ts and setup files being correct
- Generate factories before tests -- unit and integration tests import from factories
- Generate MSW handlers before integration tests -- integration tests depend on MSW mock setup
- Generate page objects before E2E step definitions -- step definitions import page objects
- When both backend-scaffold and frontend-scaffold are provided, generate separate test suites for each and cross-reference shared factories

## Common Mistakes

- Do not generate `import { Given, When, Then } from 'cucumber'` for Vitest tests -- use jest-cucumber binding pattern or direct describe/it blocks
- Do not mix MSW v1 (`rest.get`) and v2 (`http.get`) syntax -- always use MSW v2 with `http` and `HttpResponse`
- Do not use `instanceof ZodError` for error type checking in test assertions -- use Zod's `.safeParse()` result or framework-specific error helpers
- Do not hardcode `localhost:3000` in Playwright config -- use `process.env.BASE_URL` with fallback
- Do not generate tests that import from absolute paths (`/src/...`) -- use relative paths from test file location or path aliases from tsconfig
- Do not forget to add `afterEach(() => server.resetHandlers())` in MSW setup -- without it, handler overrides leak between tests
- Do not use `page.waitForTimeout(1000)` in Playwright tests -- always use `expect(locator).toBeVisible()` or `page.waitForSelector()` instead
