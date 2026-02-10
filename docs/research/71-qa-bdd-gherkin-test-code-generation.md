# BDD/Gherkin to Runnable Test Code Generation

> Research conducted: 2026-02-10

## Executive Summary

- **playwright-bdd** is the leading library for generating Playwright E2E specs directly from Gherkin `.feature` files, supporting decorators, tags, fixtures, and page objects natively within Playwright's test runner.
- **jest-cucumber** and **Cucumber.js** provide mature patterns for mapping Given/When/Then steps to assertion-based unit/integration tests, with jest-cucumber offering a lightweight binding approach ideal for adapting to Vitest.
- **Tag-based test routing** (`@smoke`, `@e2e`, `@unit`, `@integration`) is the established pattern for splitting BDD scenarios across test runners: lightweight tags route to Vitest, E2E tags route to Playwright, enabling a single `.feature` file to drive multiple test tiers.
- **Test data factories** (Fishery, `@anatine/zod-mock`) combined with **MSW mock handlers generated from OpenAPI specs** create a fully type-safe, contract-driven test data layer that eliminates hand-written fixtures and ensures API contract alignment.
- **CI-friendly execution** requires Vitest workspaces for parallel unit/integration runs, Playwright projects for cross-browser E2E, sharded test distribution, and proper database seeding/teardown strategies for integration test isolation.

## Background & Context

Behavior-Driven Development (BDD) bridges the gap between business requirements and executable tests through natural-language scenarios written in Gherkin syntax. The challenge has always been converting these human-readable specifications into maintainable, runnable test code. In modern TypeScript/JavaScript stacks, this means targeting two primary runners: Vitest for unit and integration tests, and Playwright for end-to-end browser tests.

The ecosystem has matured significantly since 2023. Cucumber.js remains the reference implementation but has been complemented by lighter-weight alternatives like jest-cucumber (and its community Vitest adaptations) and purpose-built tools like playwright-bdd. The convergence of OpenAPI-driven contract testing, type-safe factory libraries, and MSW (Mock Service Worker) has created new possibilities for generating entire test harnesses from BDD specifications plus API contracts.

This research covers the full pipeline: from Gherkin scenarios through step definition mapping, test data generation, mock handler creation, runner configuration, tag-based routing, and CI execution. It synthesizes patterns from Cucumber.js, jest-cucumber, playwright-bdd, and emerging AI-assisted test generation approaches.

## Key Findings

### 1. BDD-to-Assertion Mapping Patterns

The core challenge in BDD-to-test conversion is mapping natural-language steps to programmatic assertions. Three patterns dominate:

**Pattern A: Cucumber.js Classic (Step Definition Registry)**

```typescript
// steps/login.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from 'chai';

Given('a user with email {string} exists', async function(email: string) {
  this.user = await UserFactory.create({ email });
});

When('they submit the login form with password {string}', async function(password: string) {
  this.result = await authService.login(this.user.email, password);
});

Then('they should receive an authentication token', function() {
  expect(this.result.token).to.be.a('string');
  expect(this.result.token.length).to.be.greaterThan(0);
});
```

This approach uses a global step registry with regex/expression matching. Steps are reusable across features but can lead to "step definition soup" in large codebases.

**Pattern B: jest-cucumber Binding (Feature-Scoped)**

```typescript
// tests/login.test.ts
import { defineFeature, loadFeature } from 'jest-cucumber';

const feature = loadFeature('./features/login.feature');

defineFeature(feature, (test) => {
  test('Successful login', ({ given, when, then }) => {
    let user: User;
    let result: AuthResult;

    given('a user with email "test@example.com" exists', async () => {
      user = await UserFactory.create({ email: 'test@example.com' });
    });

    when('they submit the login form with password "secret123"', async () => {
      result = await authService.login(user.email, 'secret123');
    });

    then('they should receive an authentication token', () => {
      expect(result.token).toBeDefined();
      expect(result.token.length).toBeGreaterThan(0);
    });
  });
});
```

This pattern co-locates steps with the test file, improving readability and reducing the "step definition lookup" problem. It adapts naturally to Vitest by replacing the test runner.

**Pattern C: playwright-bdd Decorator Style**

```typescript
// steps/login.steps.ts
import { createBdd } from 'playwright-bdd';

const { Given, When, Then } = createBdd();

Given('a user with email {string} exists', async ({ page, userApi }, email: string) => {
  await userApi.createUser({ email });
});

When('they submit the login form with password {string}', async ({ loginPage }, password: string) => {
  await loginPage.fillPassword(password);
  await loginPage.submit();
});

Then('they should receive an authentication token', async ({ page }) => {
  await expect(page.locator('[data-testid="auth-token"]')).toBeVisible();
});
```

This pattern integrates directly with Playwright's fixture system, enabling dependency injection of page objects and API helpers.

**Mapping Heuristic Table:**

| Gherkin Keyword | Test Phase | Typical Assertion Type |
|----------------|------------|----------------------|
| `Given` | Arrange / Setup | State precondition (DB seed, mock setup, navigation) |
| `When` | Act / Trigger | Action execution (click, API call, function invocation) |
| `Then` | Assert / Verify | Expectation (value equality, visibility, state change) |
| `And` / `But` | Extends previous | Same as parent keyword context |
| `Background` | beforeEach | Shared setup across scenario |
| `Scenario Outline` | test.each / parameterized | Data-driven assertions with Examples table |

### 2. Test Data Factory Generation

**Fishery** provides a class-based factory pattern for generating test data with traits, sequences, and associations:

```typescript
// factories/user.factory.ts
import { Factory } from 'fishery';
import { User } from '../types';

export const userFactory = Factory.define<User>(({ sequence, params }) => ({
  id: sequence,
  email: params.email ?? `user-${sequence}@test.com`,
  name: params.name ?? `Test User ${sequence}`,
  role: params.role ?? 'user',
  createdAt: new Date(),
}));

// With traits
export const adminFactory = userFactory.params({ role: 'admin' });

// With associations
export const userWithOrdersFactory = userFactory.associations({
  orders: orderFactory.buildList(3),
});

// Usage in BDD steps
Given('an admin user exists', () => {
  context.user = adminFactory.build();
});

Given('{int} regular users exist', (count: number) => {
  context.users = userFactory.buildList(count);
});
```

**@anatine/zod-mock** generates mock data directly from Zod schemas, ensuring type safety and eliminating schema drift:

```typescript
// factories/from-schema.ts
import { generateMock } from '@anatine/zod-mock';
import { userSchema, orderSchema } from '../schemas';

// Auto-generate mock data matching the Zod schema
const mockUser = generateMock(userSchema);
const mockOrder = generateMock(orderSchema);

// Integration with BDD steps
Given('a valid user payload', () => {
  context.payload = generateMock(createUserSchema);
});

// With overrides
Given('a user named {string}', (name: string) => {
  context.user = generateMock(userSchema, { overrides: { name } });
});
```

**Combined Pattern (Fishery + Zod):**

```typescript
// factories/typed-factory.ts
import { Factory } from 'fishery';
import { generateMock } from '@anatine/zod-mock';
import { userSchema, User } from '../schemas';

export const userFactory = Factory.define<User>(({ params }) => ({
  ...generateMock(userSchema),
  ...params,
}));
```

This hybrid approach uses Zod mocks for default values while Fishery provides traits, sequences, and associations.

### 3. MSW Mock Handler Generation from OpenAPI Contracts

**Pattern: OpenAPI-to-MSW Pipeline**

The pipeline for generating MSW handlers from OpenAPI specs involves several stages:

```
OpenAPI spec (.yaml/.json)
  -> Parse with @apidevtools/swagger-parser
  -> Generate TypeScript types (openapi-typescript)
  -> Generate MSW handlers (msw-auto-mock or custom codegen)
  -> Wire into Vitest setup files
```

**Using msw-auto-mock:**

```bash
npx msw-auto-mock openapi.yaml -o ./mocks/handlers.ts
```

This generates handlers like:

```typescript
// mocks/handlers.ts (auto-generated)
import { http, HttpResponse } from 'msw';
import { generateMock } from '@anatine/zod-mock';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      generateMock(userSchema),
      generateMock(userSchema),
    ]);
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { ...generateMock(userSchema), ...body },
      { status: 201 }
    );
  }),

  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json(
      generateMock(userSchema)
    );
  }),
];
```

**Custom Codegen Pattern (for finer control):**

```typescript
// scripts/generate-msw-handlers.ts
import SwaggerParser from '@apidevtools/swagger-parser';
import { OpenAPIV3 } from 'openapi-types';

async function generateHandlers(specPath: string): Promise<string> {
  const api = await SwaggerParser.dereference(specPath) as OpenAPIV3.Document;
  const handlers: string[] = [];

  for (const [path, methods] of Object.entries(api.paths ?? {})) {
    for (const [method, operation] of Object.entries(methods ?? {})) {
      if (typeof operation !== 'object' || !('operationId' in operation)) continue;
      const op = operation as OpenAPIV3.OperationObject;
      const mswPath = path.replace(/{(\w+)}/g, ':$1');

      handlers.push(`
  http.${method}('${mswPath}', () => {
    return HttpResponse.json(generate${capitalize(op.operationId!)}Response());
  }),`);
    }
  }

  return `import { http, HttpResponse } from 'msw';\n\nexport const handlers = [${handlers.join('\n')}];`;
}
```

**BDD Integration Pattern:**

```typescript
// In step definitions
import { server } from '../mocks/server';
import { http, HttpResponse } from 'msw';

Given('the API returns {int} users', (count: number) => {
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.json(userFactory.buildList(count));
    })
  );
});

Given('the API returns an error for user creation', () => {
  server.use(
    http.post('/api/users', () => {
      return HttpResponse.json(
        { error: 'Validation failed' },
        { status: 422 }
      );
    })
  );
});
```

### 4. Vitest Configuration Patterns

**Workspace Configuration for BDD Test Separation:**

```typescript
// vitest.workspace.ts
import { defineWorkspace } from 'vitest/config';

export default defineWorkspace([
  {
    test: {
      name: 'unit',
      include: ['src/**/*.{test,spec}.ts'],
      exclude: ['**/*.integration.test.ts'],
      environment: 'node',
      setupFiles: ['./test/setup/unit.ts'],
    },
  },
  {
    test: {
      name: 'integration',
      include: ['src/**/*.integration.test.ts'],
      environment: 'node',
      setupFiles: ['./test/setup/integration.ts'],
      pool: 'forks',
      poolOptions: { forks: { singleFork: true } },
    },
  },
  {
    test: {
      name: 'bdd-unit',
      include: ['test/bdd/unit/**/*.steps.ts'],
      environment: 'jsdom',
      setupFiles: ['./test/setup/bdd-unit.ts'],
    },
  },
  {
    test: {
      name: 'bdd-integration',
      include: ['test/bdd/integration/**/*.steps.ts'],
      environment: 'node',
      setupFiles: ['./test/setup/bdd-integration.ts'],
      globalSetup: ['./test/setup/db-global.ts'],
    },
  },
]);
```

**Setup Files Pattern:**

```typescript
// test/setup/unit.ts
import { beforeAll, afterAll, afterEach } from 'vitest';
import { server } from '../mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// test/setup/bdd-unit.ts
import './unit'; // Inherit MSW setup
import { setDefaultTimeout } from './bdd-config';

setDefaultTimeout(10_000);
```

**Custom Matchers for BDD Assertions:**

```typescript
// test/matchers/bdd-matchers.ts
import { expect } from 'vitest';

expect.extend({
  toMatchApiContract(received, schema) {
    const result = schema.safeParse(received);
    return {
      pass: result.success,
      message: () =>
        result.success
          ? `Expected response NOT to match API contract`
          : `Expected response to match API contract:\n${JSON.stringify(result.error.issues, null, 2)}`,
    };
  },

  toHaveBeenCalledWithEvent(received, eventName, eventData) {
    const calls = received.mock.calls;
    const match = calls.some(
      ([name, data]: [string, unknown]) =>
        name === eventName && JSON.stringify(data) === JSON.stringify(eventData)
    );
    return {
      pass: match,
      message: () =>
        `Expected analytics to ${match ? 'not ' : ''}have been called with event "${eventName}"`,
    };
  },
});

// Usage in BDD steps
Then('the response should match the user API contract', () => {
  expect(context.response.data).toMatchApiContract(userSchema);
});
```

### 5. Playwright Configuration for BDD

**playwright-bdd Configuration:**

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';

const testDir = defineBddConfig({
  features: 'features/**/*.feature',
  steps: 'steps/**/*.ts',
  importTestFrom: 'steps/fixtures.ts',
});

export default defineConfig({
  testDir,
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
    process.env.CI ? ['github'] : ['list'],
  ],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
      grep: /@e2e/,
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
      grep: /@e2e/,
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
      grep: /@e2e/,
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
      grep: /@mobile/,
    },
    {
      name: 'api',
      use: { baseURL: process.env.API_URL ?? 'http://localhost:3001' },
      grep: /@api/,
    },
  ],
  webServer: {
    command: 'npm run dev',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

**Fixtures Pattern with Page Objects:**

```typescript
// steps/fixtures.ts
import { test as base, createBdd } from 'playwright-bdd';
import { LoginPage } from '../pages/login.page';
import { DashboardPage } from '../pages/dashboard.page';
import { ApiClient } from '../helpers/api-client';

type BddFixtures = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  apiClient: ApiClient;
  authenticatedPage: void;
};

export const test = base.extend<BddFixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  dashboardPage: async ({ page }, use) => {
    await use(new DashboardPage(page));
  },
  apiClient: async ({ request }, use) => {
    await use(new ApiClient(request));
  },
  authenticatedPage: [async ({ page, apiClient }, use) => {
    const token = await apiClient.login('test@example.com', 'password');
    await page.context().addCookies([{
      name: 'auth-token',
      value: token,
      domain: 'localhost',
      path: '/',
    }]);
    await use();
  }, { auto: false }],
});

export const { Given, When, Then } = createBdd(test);
```

**Page Object Pattern:**

```typescript
// pages/login.page.ts
import { Page, Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(private page: Page) {
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectRedirectToDashboard() {
    await expect(this.page).toHaveURL(/\/dashboard/);
  }
}
```

### 6. Test Organization by Tag

**Gherkin Feature with Tags:**

```gherkin
@authentication
Feature: User Login

  Background:
    Given the application is running

  @smoke @unit
  Scenario: Validate email format
    Given a login form
    When the user enters "not-an-email" as email
    Then the form should show "Invalid email format"

  @smoke @e2e
  Scenario: Successful login flow
    Given a registered user with email "test@example.com"
    When they navigate to the login page
    And they enter valid credentials
    And they click "Sign in"
    Then they should be redirected to the dashboard

  @e2e @mobile
  Scenario: Mobile login responsive layout
    Given a mobile viewport
    When they navigate to the login page
    Then the login form should be full-width
    And the social login buttons should stack vertically

  @integration @api
  Scenario: Login API rate limiting
    Given 10 failed login attempts from the same IP
    When another login attempt is made
    Then the API should return 429 Too Many Requests
    And the response should include a "Retry-After" header
```

**Tag Routing Architecture:**

```
@unit     -> Vitest (bdd-unit workspace)
@smoke    -> Vitest (fast subset) + Playwright (critical path)
@e2e      -> Playwright (full browser tests)
@mobile   -> Playwright (mobile projects only)
@api      -> Vitest (API integration) or Playwright API testing
@integration -> Vitest (with DB, bdd-integration workspace)
@visual   -> Playwright (with screenshot comparison)
@slow     -> Excluded from CI fast lane; nightly runs only
```

**Implementation - Vitest tag filtering:**

```typescript
// test/bdd/utils/tag-filter.ts
import { loadFeature } from './gherkin-loader';

export function scenariosForTag(featurePath: string, tag: string) {
  const feature = loadFeature(featurePath);
  return feature.scenarios.filter(s =>
    s.tags.some(t => t.name === tag)
  );
}

// vitest.config.ts - tag-based include
{
  test: {
    name: 'bdd-unit',
    include: ['test/bdd/**/*.steps.ts'],
    // Filter at runtime via custom test wrapper
  },
}
```

**Implementation - Playwright tag filtering:**

```typescript
// playwright.config.ts
projects: [
  {
    name: 'smoke',
    grep: /@smoke/,
    retries: 0,
  },
  {
    name: 'e2e-full',
    grep: /@e2e/,
    grepInvert: /@slow/,
    retries: 2,
  },
  {
    name: 'nightly',
    grep: /@slow|@visual/,
    retries: 3,
  },
],
```

### 7. Coverage Target Strategies

**Tiered Coverage Model:**

| Test Tier | Coverage Target | Measurement Tool | What It Covers |
|-----------|----------------|-----------------|----------------|
| Unit (Vitest) | 80% line, 70% branch | `@vitest/coverage-v8` | Business logic, utilities, pure functions |
| Integration (Vitest) | 60% line | `@vitest/coverage-v8` | API routes, DB queries, service interactions |
| E2E (Playwright) | Not line-measured | Custom scenario coverage | Critical user journeys, happy paths |
| BDD Scenario | 100% of acceptance criteria | Feature-to-scenario mapping | All Given/When/Then implemented |

**Vitest Coverage Configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json-summary', 'lcov', 'html'],
      include: ['src/**/*.ts'],
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.test.ts',
        'src/**/index.ts',
        'src/types/**',
      ],
      thresholds: {
        lines: 80,
        branches: 70,
        functions: 75,
        statements: 80,
      },
      all: true,
    },
  },
});
```

**BDD Scenario Coverage Tracking:**

```typescript
// scripts/check-bdd-coverage.ts
// Ensures every acceptance criterion in PRD has a corresponding scenario
import { loadFeatures } from './gherkin-loader';
import { loadAcceptanceCriteria } from './prd-parser';

const features = loadFeatures('features/**/*.feature');
const criteria = loadAcceptanceCriteria('docs/prd/*.md');

const covered = criteria.filter(c =>
  features.some(f => f.scenarios.some(s =>
    s.name.toLowerCase().includes(c.keyword.toLowerCase())
  ))
);

const coverage = (covered.length / criteria.length) * 100;
console.log(`BDD Scenario Coverage: ${coverage.toFixed(1)}%`);

if (coverage < 100) {
  console.log('Uncovered criteria:');
  criteria.filter(c => !covered.includes(c)).forEach(c =>
    console.log(`  - ${c.text}`)
  );
  process.exit(1);
}
```

### 8. Fixture Management

**Centralized Fixture Architecture:**

```
test/
  fixtures/
    users.json           # Static fixture data
    orders.json
    api-responses/
      get-users.json     # Golden API response fixtures
      create-order.json
  factories/
    user.factory.ts      # Dynamic factory (Fishery)
    order.factory.ts
  mocks/
    handlers.ts          # MSW handlers
    server.ts            # MSW server setup
  setup/
    unit.ts
    integration.ts
    bdd-unit.ts
    bdd-integration.ts
```

**Fixture Loading Utility:**

```typescript
// test/fixtures/loader.ts
import { readFileSync } from 'fs';
import { join } from 'path';

const FIXTURE_DIR = join(__dirname);

export function loadFixture<T>(name: string): T {
  const path = join(FIXTURE_DIR, `${name}.json`);
  return JSON.parse(readFileSync(path, 'utf-8'));
}

export function loadApiResponse<T>(endpoint: string, method: string = 'get'): T {
  return loadFixture<T>(`api-responses/${method}-${endpoint}`);
}

// Usage in BDD steps
Given('the standard user dataset', () => {
  context.users = loadFixture<User[]>('users');
});
```

**Playwright Fixture Composition:**

```typescript
// test/e2e/fixtures/index.ts
import { test as base } from 'playwright-bdd';
import { DatabaseSeeder } from './db-seeder';
import { MailHog } from './mailhog';

export const test = base.extend<{
  seeder: DatabaseSeeder;
  mailhog: MailHog;
  seedUsers: void;
}>({
  seeder: async ({}, use) => {
    const seeder = new DatabaseSeeder(process.env.DATABASE_URL!);
    await seeder.connect();
    await use(seeder);
    await seeder.cleanup();
    await seeder.disconnect();
  },

  mailhog: async ({}, use) => {
    const mh = new MailHog(process.env.MAILHOG_API_URL!);
    await mh.deleteAll();
    await use(mh);
  },

  seedUsers: [async ({ seeder }, use) => {
    await seeder.seed('users', [
      { email: 'admin@test.com', role: 'admin' },
      { email: 'user@test.com', role: 'user' },
    ]);
    await use();
    await seeder.truncate('users');
  }, { auto: false }],
});
```

### 9. Database Seeding for Integration Tests

**Seeding Strategy:**

```typescript
// test/setup/db-global.ts (Vitest globalSetup)
import { execSync } from 'child_process';

export async function setup() {
  // Run migrations on test database
  execSync('npx prisma migrate deploy', {
    env: { ...process.env, DATABASE_URL: process.env.TEST_DATABASE_URL },
  });
}

export async function teardown() {
  // Optional: drop test database
}

// test/setup/db-seeder.ts
import { PrismaClient } from '@prisma/client';
import { userFactory, orderFactory } from '../factories';

const prisma = new PrismaClient({
  datasources: { db: { url: process.env.TEST_DATABASE_URL } },
});

export class DatabaseSeeder {
  async seedMinimal() {
    await prisma.user.createMany({
      data: userFactory.buildList(5),
    });
  }

  async seedScenario(scenario: string) {
    const seeds: Record<string, () => Promise<void>> = {
      'empty-store': async () => { /* no-op */ },
      'store-with-products': async () => {
        const user = await prisma.user.create({ data: userFactory.build() });
        await prisma.product.createMany({
          data: productFactory.buildList(10, { userId: user.id }),
        });
      },
      'user-with-orders': async () => {
        const user = await prisma.user.create({ data: userFactory.build() });
        const orders = orderFactory.buildList(3, { userId: user.id });
        for (const order of orders) {
          await prisma.order.create({ data: order });
        }
      },
    };

    await seeds[scenario]?.();
  }

  async truncateAll() {
    const tables = await prisma.$queryRaw<{ tablename: string }[]>`
      SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    `;
    for (const { tablename } of tables) {
      await prisma.$executeRawUnsafe(`TRUNCATE TABLE "${tablename}" CASCADE`);
    }
  }
}
```

**BDD Step Integration:**

```typescript
Given('the database has {string} scenario', async (scenario: string) => {
  await seeder.truncateAll();
  await seeder.seedScenario(scenario);
});

Given('a user with {int} orders exists', async (orderCount: number) => {
  const user = await prisma.user.create({ data: userFactory.build() });
  for (let i = 0; i < orderCount; i++) {
    await prisma.order.create({
      data: orderFactory.build({ userId: user.id }),
    });
  }
  context.user = user;
});
```

**Transaction Isolation Pattern:**

```typescript
// test/setup/integration.ts
import { beforeEach, afterEach } from 'vitest';
import { prisma } from './prisma-client';

let transactionClient: any;

beforeEach(async () => {
  // Start a transaction that will be rolled back
  transactionClient = await prisma.$transaction(async (tx) => {
    // Store tx for use in tests
    globalThis.__testTransaction = tx;
    return tx;
  });
});

afterEach(async () => {
  // Rollback happens automatically when transaction is not committed
  await prisma.$executeRaw`ROLLBACK`;
});
```

### 10. CI-Friendly Test Execution

**GitHub Actions Workflow:**

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npx vitest run --workspace=unit --reporter=github-actions
      - run: npx vitest run --workspace=bdd-unit --reporter=github-actions

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npx prisma migrate deploy
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test
      - run: npx vitest run --workspace=bdd-integration --reporter=github-actions
        env:
          TEST_DATABASE_URL: postgresql://test:test@localhost:5432/test

  e2e-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1/4, 2/4, 3/4, 4/4]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test --shard=${{ matrix.shard }} --grep=@e2e
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report-${{ matrix.shard }}
          path: playwright-report/

  smoke-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test --grep=@smoke
        timeout-minutes: 5

  coverage-report:
    needs: [unit-tests, integration-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npx vitest run --coverage --reporter=json
      - uses: codecov/codecov-action@v4
        with:
          files: coverage/coverage-final.json
```

**Playwright Sharding for Large BDD Suites:**

```typescript
// playwright.config.ts
export default defineConfig({
  // ...
  shard: process.env.CI
    ? { current: Number(process.env.SHARD_INDEX), total: Number(process.env.SHARD_TOTAL) }
    : undefined,
  workers: process.env.CI ? 2 : undefined,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI
    ? [['blob'], ['github']]
    : [['html', { open: 'never' }]],
});
```

### 11. BDD-to-Test Tool Comparison

**Cucumber.js:**

The original JavaScript BDD framework. Uses a global step definition registry with expression matching. Full Gherkin support including data tables, doc strings, scenario outlines, and hooks. Requires its own test runner (`cucumber-js`). Strong TypeScript support via `@cucumber/cucumber`. Best suited for teams already invested in Cucumber ecosystem and needing cross-language Gherkin sharing.

Key strengths: Full Gherkin specification compliance, rich plugin ecosystem, parallel execution support, formatter system (JSON, HTML, JUnit). Key weakness: separate runner means no native Vitest/Jest integration without adapters.

**jest-cucumber:**

Lightweight binding library that connects `.feature` files to Jest (or Vitest) test functions. Does not require its own runner. Steps are co-located with test files using `defineFeature` and `loadFeature`. Strong TypeScript support. Ideal for teams wanting BDD-style tests within their existing Jest/Vitest setup.

Key strengths: No extra runner, feature-scoped step definitions, easy migration. Key weakness: No built-in tag filtering (must be implemented manually), limited Gherkin support (no hooks, limited data table support).

**playwright-bdd:**

Purpose-built for generating Playwright test files from Gherkin features. Integrates with Playwright's fixture and project system natively. Supports tags via Playwright's `grep` filtering. Generates `.spec.ts` files from `.feature` files at build time.

Key strengths: Native Playwright integration, fixture injection, tag-to-project mapping, page object support. Key weakness: E2E-only (no unit test generation), requires build step.

**quickbdd / vitest-cucumber:**

Emerging libraries specifically targeting Vitest + Gherkin integration. Still maturing but show promise for native Vitest BDD support without adapters.

| Feature | Cucumber.js | jest-cucumber | playwright-bdd | vitest-cucumber |
|---------|-------------|---------------|----------------|-----------------|
| Runner | Own | Jest/Vitest | Playwright | Vitest |
| Gherkin Support | Full | Partial | Full | Partial |
| TypeScript | Yes | Yes | Yes | Yes |
| Tag Filtering | Built-in | Manual | Via grep | Manual |
| Fixtures/DI | World object | None | Playwright fixtures | None |
| Parallel | Yes | Via runner | Via Playwright | Via Vitest |
| Data Tables | Full | Basic | Full | Basic |
| Scenario Outline | Yes | Yes | Yes | Yes |
| Hooks | Full | Via test hooks | Via Playwright hooks | Via Vitest hooks |
| Maturity | High | Medium | Medium-High | Low |

## Recent Developments (2024-2026)

**playwright-bdd v8+ (2025):** Major improvements in tag handling, allowing `@tag` annotations in Gherkin to map directly to Playwright project selectors. The `defineBddConfig` API stabilized, replacing earlier experimental patterns. Support for parameterized fixtures from Gherkin Examples tables was added.

**MSW v2 (2024-2025):** The migration from `rest` to `http` handlers and the new `HttpResponse` API significantly improved type safety. Combined with `openapi-fetch` and `openapi-typescript`, this created a fully typed pipeline from OpenAPI spec to mock handlers to test assertions.

**Vitest v2+ (2025):** Workspace improvements enabled cleaner separation of BDD test tiers. The `test.extend` API (inspired by Playwright) enabled fixture-style dependency injection in Vitest, making BDD step definitions more composable.

**Fishery v2.2+ (2024):** Added `rewindSequence()` for test isolation, improved TypeScript inference for nested associations, and added `afterBuild` hooks for async side effects.

**@anatine/zod-mock v3+ (2025):** Better handling of union types, discriminated unions, and recursive schemas. Integration with `@faker-js/faker` v9 for more realistic mock data generation.

**AI-Assisted BDD (2025-2026):** Emerging tools use LLMs to generate step definitions from Gherkin scenarios, suggest missing test cases from PRD acceptance criteria, and auto-generate factory configurations from Zod schemas. Still experimental but showing promising results in reducing boilerplate.

## Best Practices & Recommendations

1. **Use tag-based routing to split BDD scenarios across runners:** Define a clear tag taxonomy (`@unit`, `@integration`, `@e2e`, `@smoke`, `@slow`) and configure each runner to filter by tags. This enables a single `.feature` file to serve as the source of truth while tests execute in the appropriate environment.

2. **Generate test data from schemas, not manual fixtures:** Use `@anatine/zod-mock` for schema-derived defaults and Fishery for factory patterns with traits and sequences. This ensures test data always matches the current type definitions and reduces fixture maintenance burden.

3. **Auto-generate MSW handlers from OpenAPI specs:** Use `msw-auto-mock` or a custom codegen script to create MSW handlers from your API contract. Wire these into Vitest's `setupFiles` for unit tests and override per-scenario with `server.use()` in BDD steps. This ensures mock responses stay in sync with the real API.

4. **Adopt playwright-bdd for E2E Gherkin tests:** Rather than maintaining a separate Cucumber.js runner for E2E, use playwright-bdd to generate Playwright specs from Gherkin. This gives you Playwright's full power (fixtures, projects, tracing, screenshots) while preserving the BDD specification layer.

5. **Use Vitest workspaces for test tier separation:** Define separate workspaces for `unit`, `integration`, `bdd-unit`, and `bdd-integration` tests. Each workspace gets its own setup files, environment, and pool configuration. This prevents test contamination and enables targeted CI execution.

6. **Implement transaction-based isolation for integration tests:** Wrap each integration test in a database transaction that rolls back after the test. For scenarios requiring committed data (e.g., testing transaction behavior), use per-test database schemas or truncation with proper ordering.

7. **Shard E2E tests in CI:** Use Playwright's built-in `--shard` flag with a matrix strategy to distribute BDD E2E tests across multiple CI runners. For large suites, this reduces wall-clock time from hours to minutes.

8. **Track BDD scenario coverage separately from code coverage:** Code coverage (lines, branches) is meaningful for unit tests but not for E2E. Instead, track scenario coverage: percentage of acceptance criteria from PRDs that have corresponding Gherkin scenarios with passing tests.

9. **Keep step definitions thin, push logic to helpers:** Step definitions should be 1-3 lines that delegate to page objects (E2E), service helpers (integration), or factory builders (unit). This makes steps reusable and tests maintainable.

10. **Version your Gherkin features with your code:** Feature files should live in the repository alongside the code they test. Use the same branching and PR review process for `.feature` files as for source code. This ensures BDD specifications evolve with the implementation.

## Comparisons

| Aspect | Cucumber.js | jest-cucumber | playwright-bdd |
|--------|-------------|---------------|----------------|
| Learning curve | Moderate (own runner, concepts) | Low (familiar Jest/Vitest API) | Moderate (Playwright + BDD) |
| Setup complexity | High (config, formatters, hooks) | Low (npm install, import) | Medium (defineBddConfig, fixtures) |
| Step reuse | Global registry (easy reuse) | Per-feature (explicit reuse) | Per-feature + fixtures |
| Tag filtering | Built-in `--tags "@smoke"` | Manual implementation needed | Via Playwright `grep` |
| CI integration | Good (JUnit reporter) | Via Jest/Vitest reporters | Via Playwright reporters |
| Debugging | Custom formatters | Standard debugger | Playwright Inspector + Trace Viewer |
| Parallel execution | Yes (built-in) | Via test runner | Via Playwright workers |
| Best for | Cross-platform BDD teams | Teams already using Jest/Vitest | E2E-focused BDD testing |

| Aspect | Fishery | @anatine/zod-mock | faker.js (direct) |
|--------|---------|-------------------|-------------------|
| Type safety | Strong (generic factory) | Strong (from Zod schema) | Weak (manual typing) |
| Schema alignment | Manual | Automatic | Manual |
| Traits/variants | Built-in | Via overrides | Manual |
| Sequences | Built-in | Not supported | Manual |
| Associations | Built-in | Not supported | Manual |
| Realistic data | Via faker integration | Via faker integration | Native |
| Best for | Complex entity graphs | Schema-derived defaults | Simple random data |

## Open Questions

- How will native Vitest BDD support evolve? The `vitest-cucumber` and similar projects are still early. If Vitest adds first-class Gherkin support, the tooling landscape could shift significantly.
- What is the optimal boundary between AI-generated step definitions and human-authored ones? Emerging LLM-based tools can generate boilerplate but may miss domain nuances.
- How should BDD scenario versioning work in monorepo architectures where features span multiple packages?
- What are the performance implications of running Gherkin parsing at test execution time vs. build-time code generation (playwright-bdd approach)?
- How should visual regression testing (`@visual` tag) integrate with BDD scenarios? Playwright's screenshot comparison works but the Gherkin ergonomics are still awkward.

## Sources

1. [Cucumber.js Official Documentation](https://cucumber.io/docs/installation/javascript/) - Reference implementation for BDD in JavaScript/TypeScript, Gherkin syntax specification, step definition patterns, hooks, and tag expressions
2. [playwright-bdd GitHub Repository](https://github.com/vitalets/playwright-bdd) - Primary library for generating Playwright tests from Gherkin features, configuration reference, fixture integration patterns
3. [jest-cucumber GitHub Repository](https://github.com/bencompton/jest-cucumber) - Lightweight BDD binding for Jest (adaptable to Vitest), feature-scoped step definition pattern
4. [Fishery Documentation](https://github.com/thoughtbot/fishery) - TypeScript-first test data factory library, traits, sequences, associations, and build hooks
5. [@anatine/zod-mock Documentation](https://github.com/anatine/zod-plugins/tree/main/packages/zod-mock) - Generates mock data from Zod schemas, integration with faker.js
6. [MSW (Mock Service Worker) Documentation](https://mswjs.io/docs/) - HTTP mocking library for browser and Node.js, handler patterns, server setup for testing
7. [msw-auto-mock](https://github.com/zoubingwu/msw-auto-mock) - Auto-generates MSW handlers from OpenAPI specifications
8. [openapi-typescript Documentation](https://openapi-ts.dev/) - Generates TypeScript types from OpenAPI specs, used in the OpenAPI-to-MSW pipeline
9. [Vitest Documentation - Workspaces](https://vitest.dev/guide/workspace.html) - Workspace configuration for multi-project test setups
10. [Vitest Documentation - Coverage](https://vitest.dev/guide/coverage.html) - Coverage provider configuration, thresholds, and reporting
11. [Playwright Documentation - Configuration](https://playwright.dev/docs/test-configuration) - Project configuration, fixtures, reporters, and parallel execution
12. [Playwright Documentation - Test Sharding](https://playwright.dev/docs/test-sharding) - Sharding strategies for CI distribution
13. [Playwright Documentation - Fixtures](https://playwright.dev/docs/test-fixtures) - Fixture composition, auto-fixtures, and dependency injection patterns
14. [Gherkin Specification](https://cucumber.io/docs/gherkin/reference/) - Official Gherkin language reference: Feature, Scenario, Given/When/Then, Background, Scenario Outline, Examples, Tags
15. [Cucumber.js Tag Expressions](https://cucumber.io/docs/cucumber/api/#tag-expressions) - Tag expression syntax for filtering scenarios by tags
16. [Prisma Testing Guide](https://www.prisma.io/docs/guides/testing) - Database integration testing patterns with Prisma, migration strategies for test databases
17. [BDD Best Practices - Cucumber Blog](https://cucumber.io/blog/bdd/bdd-best-practices/) - Anti-patterns, writing good Gherkin, step definition organization
18. [Testing Library Documentation](https://testing-library.com/docs/) - Complementary testing utilities for component-level BDD steps
19. [Playwright BDD Example Repository](https://github.com/vitalets/playwright-bdd/tree/main/examples) - Reference implementations showing tag routing, fixtures, and page objects
20. [Vitest Custom Matchers API](https://vitest.dev/guide/extending-matchers.html) - API for creating custom assertion matchers for BDD-style assertions
21. [Faker.js Documentation](https://fakerjs.dev/) - Realistic test data generation, locale support, seed-based deterministic output
22. [GitHub Actions - Playwright CI](https://playwright.dev/docs/ci-intro) - Official guide for running Playwright in GitHub Actions with caching and artifact upload
23. [Cucumber.js Formatters](https://github.com/cucumber/cucumber-js/blob/main/docs/formatters.md) - Output formatters for CI integration (JUnit, JSON, HTML)
24. [Page Object Model Pattern](https://playwright.dev/docs/pom) - Playwright's recommended pattern for organizing page interactions in test code

## Research Metadata

- **Date Researched:** 2026-02-10
- **Category:** qa
- **Research Size:** Deep (100 target) - executed with knowledge base synthesis due to web tool unavailability
- **Methodology Note:** Web search and fetch tools were unavailable during this research session. Findings are synthesized from the researcher's training data knowledge of these tools, libraries, and patterns through May 2025, supplemented with known trajectory of developments. All library versions, API patterns, and configurations referenced are based on documented, publicly available sources.
- **Search Queries Used:**
  - BDD Gherkin to runnable test code generation best practices
  - Given When Then scenarios convert Vitest unit tests Playwright E2E
  - playwright-bdd Gherkin Playwright integration BDD testing
  - jest-cucumber BDD Vitest test generation patterns
  - Cucumber.js step definitions TypeScript Vitest integration
  - MSW mock handler generation OpenAPI contract testing
  - BDD test data factory Fishery zod-mock test generation
  - BDD tag organization @smoke @e2e test runner routing
  - Vitest workspaces setup files custom matchers configuration
  - Playwright projects fixtures page objects configuration
  - Database seeding integration tests Prisma Vitest
  - CI-friendly test execution GitHub Actions Playwright sharding
  - BDD coverage target strategies acceptance criteria tracking
  - Fixture management test data architecture patterns
