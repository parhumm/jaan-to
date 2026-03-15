# WordPress Plugin Testing: Best Practices, Methods & Standards (2024–2026)

> A practitioner-level reference covering the full testing stack for WordPress plugins — from PHPUnit unit tests to Playwright E2E, CI/CD pipelines, coverage standards, performance testing, and analytics-specific gaps.

---

## Table of Contents

1. [PHP Unit Testing](#1-php-unit-testing)
2. [Integration Testing](#2-integration-testing)
3. [E2E Testing](#3-e2e-testing)
4. [JS / Frontend Testing](#4-js--frontend-testing)
5. [CI/CD for WordPress Plugins](#5-cicd-for-wordpress-plugins)
6. [Test Coverage Standards](#6-test-coverage-standards)
7. [Performance Testing](#7-performance-testing)
8. [Official WordPress Standards](#8-official-wordpress-standards)
9. [Real-World Plugin Examples](#9-real-world-plugin-examples)
10. [Gaps: Analytics & Tracking Plugins](#10-gaps-analyticsTracking-plugins)

---

## 1. PHP Unit Testing

### 1.1 PHPUnit Setup for WordPress Plugins

The current recommended PHPUnit version as of 2025 is **PHPUnit 10.x** for PHP 8.1+. For PHP 7.4–8.0 compatibility, PHPUnit 9.x remains the last supported series.

**composer.json (require-dev)**

```json
{
  "require-dev": {
    "phpunit/phpunit": "^10.5",
    "brain/monkey": "^2.6",
    "mockery/mockery": "^1.6",
    "10up/wp_mock": "^0.5"
  },
  "scripts": {
    "test": "phpunit",
    "test:coverage": "phpunit --coverage-html coverage/"
  }
}
```

**phpunit.xml.dist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit
  bootstrap="tests/bootstrap.php"
  colors="true"
  convertDeprecationsToExceptions="true"
  convertErrorsToExceptions="true"
  convertNoticesToExceptions="true"
  convertWarningsToExceptions="true"
>
  <testsuites>
    <testsuite name="unit">
      <directory>tests/unit</directory>
    </testsuite>
    <testsuite name="integration">
      <directory>tests/integration</directory>
    </testsuite>
  </testsuites>

  <coverage>
    <include>
      <directory suffix=".php">src/</directory>
    </include>
    <report>
      <html outputDirectory="coverage/html"/>
      <clover outputFile="coverage/clover.xml"/>
    </report>
  </coverage>

  <php>
    <env name="WP_TESTS_CONFIG_FILE_PATH" value="tests/wp-tests-config.php"/>
  </php>
</phpunit>
```

**Typical directory layout**

```
my-plugin/
├── src/
│   ├── Admin/
│   ├── REST/
│   └── Tracking/
├── tests/
│   ├── bootstrap.php          # unit bootstrap (no WP loaded)
│   ├── bootstrap-integration.php
│   ├── wp-tests-config.php
│   ├── unit/
│   │   ├── Admin/
│   │   └── Tracking/
│   └── integration/
│       └── REST/
├── composer.json
└── phpunit.xml.dist
```

---

### 1.2 Brain Monkey

[Brain Monkey](https://brain-monkey.readthedocs.io/) is a test utility for PHP that lets you mock and spy on WordPress (or any other) functions and methods **without bootstrapping WordPress**. It is built on top of Mockery.

**Unit bootstrap (no WordPress)**

```php
<?php
// tests/bootstrap.php
require_once dirname(__DIR__) . '/vendor/autoload.php';

// Nothing else — Brain Monkey provides all WP stubs at test time.
```

**Example test using Brain Monkey**

```php
<?php
use Brain\Monkey;
use Brain\Monkey\Functions;
use PHPUnit\Framework\TestCase;

class MyPluginTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Monkey\setUp();
    }

    protected function tearDown(): void
    {
        Monkey\tearDown();
        parent::tearDown();
    }

    public function test_get_option_is_called(): void
    {
        Functions\expect('get_option')
            ->once()
            ->with('my_plugin_settings')
            ->andReturn(['enabled' => true]);

        $settings = new \MyPlugin\Settings();
        $result = $settings->get();

        self::assertTrue($result['enabled']);
    }

    public function test_hook_is_registered(): void
    {
        Functions\expect('add_action')
            ->once()
            ->with('init', \Mockery::type('callable'));

        $plugin = new \MyPlugin\Plugin();
        $plugin->register_hooks();
    }
}
```

**Spying on filters**

```php
public function test_filter_modifies_output(): void
{
    Monkey\Filters\expectApplied('my_plugin_output')
        ->once()
        ->with('original')
        ->andReturn('modified');

    $renderer = new \MyPlugin\Renderer();
    $output = $renderer->render('original');

    self::assertSame('modified', $output);
}
```

---

### 1.3 WP_Mock vs Brain Monkey — Trade-offs

| Dimension | WP_Mock (10up) | Brain Monkey (Inpsyde) |
|---|---|---|
| **Maintainer** | 10up | Inpsyde / community |
| **API style** | WP_Mock::userFunction() | Mockery-based fluent API |
| **Hook assertions** | WP_Mock::expectActionAdded() | Monkey\Actions\expectAdded() |
| **Mockery dependency** | Optional (built-in stubs) | Required (core dependency) |
| **WordPress stubs** | Bundled partial stubs | php-stubs/wordpress-stubs (optional) |
| **PHPUnit 10 support** | ✅ (v0.5+) | ✅ (v2.6+) |
| **Learning curve** | Lower (WP-centric API) | Higher (Mockery fluency needed) |
| **Extensibility** | Limited | High (full Mockery power) |
| **Community adoption** | Medium | High in modern plugins |

**Recommendation (2025):** Brain Monkey is preferred for greenfield projects due to its composability with Mockery and richer spy/stub API. WP_Mock is a solid, lower-friction choice for teams already familiar with it or for plugins with many legacy tests.

---

### 1.4 Testing Hooks / Filters / Actions Without Bootstrapping WordPress

The key insight: **you are not testing WordPress — you are testing your own code's intent to register hooks and respond to them**.

**Pattern: Test registration, not execution**

```php
// Testing that your class registers the correct hooks
public function test_registers_save_post_action(): void
{
    Monkey\Actions\expectAdded('save_post')
        ->once()
        ->with(\Mockery::type('callable'), 10, 2);

    $handler = new \MyPlugin\PostSaveHandler();
    $handler->register();
}
```

**Pattern: Test filter callback logic in isolation**

```php
// Don't test apply_filters('the_content', ...) — test your callback directly
public function test_content_filter_appends_tracking_pixel(): void
{
    Functions\expect('is_singular')->andReturn(true);
    Functions\expect('get_the_ID')->andReturn(42);

    $filter = new \MyPlugin\ContentFilter();
    $result = $filter->append_pixel('<p>Hello</p>');

    self::assertStringContainsString('<img', $result);
    self::assertStringContainsString('post_id=42', $result);
}
```

**Pattern: Assert do_action was called with correct args**

```php
public function test_fires_custom_event_on_conversion(): void
{
    Functions\expect('do_action')
        ->once()
        ->with('my_plugin_conversion', \Mockery::type('int'), \Mockery::type('array'));

    $tracker = new \MyPlugin\ConversionTracker();
    $tracker->record(99, ['source' => 'email']);
}
```

---

## 2. Integration Testing

Integration tests load real WordPress and interact with a live (test) database. They are slower but catch issues unit tests cannot — DB queries, hook execution order, option persistence, taxonomy registration, etc.

### 2.1 wp-env — Official Docker Environment

[`@wordpress/env`](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) is the official zero-configuration Docker environment for WordPress development and testing.

**Install**

```bash
npm install --save-dev @wordpress/env
# or globally
npm install -g @wordpress/env
```

**Start / Stop**

```bash
npx wp-env start
npx wp-env stop
npx wp-env clean all   # wipe database
npx wp-env run tests-cli wp --info
```

**`.wp-env.json` configuration**

```json
{
  "core": "WordPress/WordPress#6.7",
  "phpVersion": "8.2",
  "plugins": ["."],
  "themes": [],
  "port": 8888,
  "testsPort": 8889,
  "env": {
    "tests": {
      "mappings": {
        "wp-content/uploads": "./tests/fixtures/uploads"
      }
    }
  }
}
```

**Running PHPUnit inside wp-env**

```bash
npx wp-env run tests-phpunit phpunit -c phpunit.xml.dist
# or with a script in package.json:
# "test:php:integration": "wp-env run tests-phpunit phpunit --testsuite integration"
```

---

### 2.2 Bootstrapping the WP Test Suite

**`wp-tests-config.php`**

```php
<?php
define( 'DB_NAME', getenv('WP_DB_NAME') ?: 'wordpress_test' );
define( 'DB_USER', getenv('WP_DB_USER') ?: 'root' );
define( 'DB_PASSWORD', getenv('WP_DB_PASSWORD') ?: 'password' );
define( 'DB_HOST', getenv('WP_DB_HOST') ?: 'localhost' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'WP_TESTS_DOMAIN', 'example.org' );
define( 'WP_TESTS_EMAIL', 'admin@example.org' );
define( 'WP_TESTS_TITLE', 'Test Blog' );
define( 'WP_PHP_BINARY', 'php' );
define( 'WPLANG', '' );
define( 'WP_DEBUG', true );
define( 'ABSPATH', getenv('WP_TESTS_ABSPATH') ?: '/tmp/wordpress/' );
```

**`tests/bootstrap-integration.php`**

```php
<?php
// Load Composer autoloader
require_once dirname(__DIR__) . '/vendor/autoload.php';

// Locate the WordPress test library
$_tests_dir = getenv('WP_TESTS_DIR') ?: '/tmp/wordpress-tests-lib';

if ( ! file_exists( $_tests_dir . '/includes/functions.php' ) ) {
    echo "Could not find WordPress test suite at {$_tests_dir}" . PHP_EOL;
    exit( 1 );
}

// Load the test functions (registers the 'tests_add_filter' helper)
require_once $_tests_dir . '/includes/functions.php';

// Manually load your plugin before WP loads
tests_add_filter( 'muplugins_loaded', function () {
    require dirname( __DIR__ ) . '/my-plugin.php';
} );

// Bootstrap WordPress
require $_tests_dir . '/includes/bootstrap.php';
```

---

### 2.3 Testing Against a Real Database

Integration test classes extend `WP_UnitTestCase` (from the WP test library):

```php
<?php
use WP_UnitTestCase;

class Test_Post_Repository extends WP_UnitTestCase
{
    private Post_Repository $repository;

    public function set_up(): void
    {
        parent::set_up();
        $this->repository = new Post_Repository();
    }

    public function test_saves_meta_value(): void
    {
        $post_id = $this->factory()->post->create([
            'post_title' => 'Test Post',
            'post_status' => 'publish',
        ]);

        $this->repository->set_tracking_id($post_id, 'abc-123');

        $stored = get_post_meta($post_id, '_tracking_id', true);
        self::assertSame('abc-123', $stored);
    }

    public function test_query_returns_only_published(): void
    {
        $this->factory()->post->create_many(3, ['post_status' => 'publish']);
        $this->factory()->post->create_many(2, ['post_status' => 'draft']);

        $results = $this->repository->get_published_posts();

        self::assertCount(3, $results);
    }
}
```

> **Important:** `WP_UnitTestCase` wraps each test in a DB transaction that is rolled back on `tear_down()`, so tests are isolated by default. Do **not** use `@runInSeparateProcess` unless absolutely necessary — it is very slow.

---

### 2.4 Factory Objects for Fixture Creation

The `WP_UnitTest_Factory` provides factories for all core WP objects:

```php
// Posts
$post_id   = $this->factory()->post->create(['post_type' => 'product']);
$post_ids  = $this->factory()->post->create_many(10);
$post_obj  = $this->factory()->post->create_and_get(['post_title' => 'Hello']);

// Users
$user_id   = $this->factory()->user->create(['role' => 'editor']);
$admin_id  = $this->factory()->user->create(['role' => 'administrator']);

// Terms
$term_id   = $this->factory()->term->create(['taxonomy' => 'category', 'name' => 'News']);

// Comments
$comment   = $this->factory()->comment->create(['comment_post_ID' => $post_id]);

// Attachments
$attachment = $this->factory()->attachment->create_upload_object(
    __DIR__ . '/fixtures/image.jpg',
    $post_id
);

// Custom post types (registered by your plugin)
$product = $this->factory()->post->create([
    'post_type'   => 'my_product',
    'post_status' => 'publish',
    'meta_input'  => ['_price' => 9.99],
]);
```

---

## 3. E2E Testing

### 3.1 Playwright vs Cypress for WordPress

| Dimension | Playwright | Cypress |
|---|---|---|
| **Official WP support** | ✅ `@wordpress/e2e-test-utils-playwright` | ⚠️ Community only (`@10up/cypress-wordpress`) |
| **Multi-browser** | Chromium, Firefox, WebKit | Chromium (Firefox beta) |
| **Parallel execution** | Native, per-worker | Requires Cypress Cloud (paid) |
| **Network interception** | route(), page.route() | cy.intercept() |
| **Trace / video** | Built-in trace viewer | Built-in video recording |
| **TypeScript** | First-class | First-class |
| **wp-env integration** | Official `wp-env` + Playwright | Manual setup |
| **Performance** | Faster (no iframe sandbox) | Slower for large suites |
| **Ecosystem** | Growing WP-specific utilities | Mature, large community |

**Recommendation (2025):** Playwright is the clear choice for new WordPress plugin E2E suites. Gutenberg Core and most Automattic products have migrated to it.

---

### 3.2 `@wordpress/e2e-test-utils-playwright`

**Install**

```bash
npm install --save-dev @wordpress/e2e-test-utils-playwright @playwright/test
npx playwright install chromium
```

**`playwright.config.ts`**

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [['html'], ['github']],
  use: {
    baseURL: 'http://localhost:8889',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'npx wp-env start',
    url: 'http://localhost:8889',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
```

**Example E2E test using wp-utils**

```typescript
import { test, expect } from '@wordpress/e2e-test-utils-playwright';

test.describe('Plugin Settings Page', () => {
  test.use({ storageState: 'playwright/.auth/admin.json' });

  test('admin can save API key', async ({ admin, page }) => {
    await admin.visitAdminPage('options-general.php', '?page=my-plugin-settings');

    await page.fill('#my-plugin-api-key', 'sk-test-1234567890');
    await page.click('[name="submit"]');

    await expect(page.locator('.updated')).toContainText('Settings saved');
  });
});
```

---

### 3.3 Testing wp-admin Flows

**Authentication setup (global setup file)**

```typescript
// tests/e2e/global-setup.ts
import { chromium, FullConfig } from '@playwright/test';

export default async function globalSetup(config: FullConfig) {
  const { baseURL } = config.projects[0].use;
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto(`${baseURL}/wp-login.php`);
  await page.fill('#user_login', 'admin');
  await page.fill('#user_pass', 'password');
  await page.click('#wp-submit');
  await page.waitForURL(`${baseURL}/wp-admin/`);

  await page.context().storageState({ path: 'playwright/.auth/admin.json' });

  await browser.close();
}
```

**Testing the block editor**

```typescript
import { test, expect } from '@wordpress/e2e-test-utils-playwright';

test('tracking block renders preview', async ({ editor, page }) => {
  await editor.openDocumentSettingsSidebar();
  await editor.insertBlock({ name: 'my-plugin/tracking-block' });

  const block = page.getByRole('document', { name: 'Block: Tracking Block' });
  await expect(block).toBeVisible();
  await expect(block.locator('.tracking-preview')).toContainText('Preview');
});
```

---

### 3.4 REST API Interactions

```typescript
test('REST endpoint returns correct data', async ({ request }) => {
  // Authenticated request
  const response = await request.get('/wp-json/my-plugin/v1/events', {
    headers: {
      Authorization: `Bearer ${process.env.WP_REST_TOKEN}`,
    },
  });

  expect(response.status()).toBe(200);
  const data = await response.json();
  expect(data).toMatchObject({
    events: expect.arrayContaining([
      expect.objectContaining({ type: 'pageview' }),
    ]),
  });
});

test('unauthenticated request is rejected', async ({ request }) => {
  const response = await request.post('/wp-json/my-plugin/v1/events', {
    data: { type: 'pageview' },
  });
  expect(response.status()).toBe(401);
});
```

---

### 3.5 Authenticated vs Unauthenticated Users

```typescript
// Define projects per role in playwright.config.ts
projects: [
  {
    name: 'admin',
    use: { storageState: 'playwright/.auth/admin.json' },
    testMatch: '**/admin/**/*.spec.ts',
  },
  {
    name: 'subscriber',
    use: { storageState: 'playwright/.auth/subscriber.json' },
    testMatch: '**/subscriber/**/*.spec.ts',
  },
  {
    name: 'unauthenticated',
    testMatch: '**/public/**/*.spec.ts',
  },
],
```

---

## 4. JS / Frontend Testing

### 4.1 Jest + `@wordpress/jest-preset-default`

**Install**

```bash
npm install --save-dev \
  jest \
  @wordpress/jest-preset-default \
  @testing-library/react \
  @testing-library/jest-dom \
  @testing-library/user-event
```

**`jest.config.js`**

```javascript
module.exports = {
  preset: '@wordpress/jest-preset-default',
  testEnvironment: 'jsdom',
  setupFilesAfterFramework: ['@testing-library/jest-dom'],
  testMatch: ['**/tests/js/**/*.test.[jt]s?(x)'],
  collectCoverageFrom: [
    'src/js/**/*.{js,jsx,ts,tsx}',
    '!src/js/**/*.d.ts',
  ],
  coverageThreshold: {
    global: { lines: 70, branches: 65, functions: 70, statements: 70 },
  },
};
```

The preset handles: Babel transform for modern JS, Gutenberg `@wordpress/*` module mocking, CSS/SCSS mocking, and `jest-circus` test runner.

---

### 4.2 Testing Gutenberg Blocks

```javascript
// src/js/blocks/tracking-block/edit.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Edit } from './edit';

// @wordpress/blocks, @wordpress/data etc. are auto-mocked by the preset

describe('TrackingBlock Edit', () => {
  const defaultAttributes = { eventName: '', enabled: true };

  it('renders the inspector controls', () => {
    render(<Edit attributes={defaultAttributes} setAttributes={jest.fn()} />);
    expect(screen.getByLabelText(/event name/i)).toBeInTheDocument();
  });

  it('calls setAttributes when event name changes', async () => {
    const setAttributes = jest.fn();
    render(<Edit attributes={defaultAttributes} setAttributes={setAttributes} />);

    const input = screen.getByLabelText(/event name/i);
    await userEvent.type(input, 'purchase');

    expect(setAttributes).toHaveBeenCalledWith(
      expect.objectContaining({ eventName: expect.stringContaining('p') })
    );
  });
});
```

**Testing `save()` output (static rendering)**

```javascript
import { serialize } from '@wordpress/blocks';
import { registerBlockType, unregisterBlockType } from '@wordpress/blocks';
import blockConfig from './block.json';
import { save } from './save';

beforeAll(() => registerBlockType('my-plugin/tracking-block', { ...blockConfig, save }));
afterAll(() => unregisterBlockType('my-plugin/tracking-block'));

it('produces valid block markup', () => {
  const block = createBlock('my-plugin/tracking-block', { eventName: 'view' });
  expect(serialize(block)).toMatchSnapshot();
});
```

---

### 4.3 Testing Vanilla JS Trackers / Analytics Scripts

For scripts that don't use a framework (standalone beacons, tag managers, trackers):

```javascript
// tests/js/tracker.test.js
import { Tracker } from '../../src/js/tracker';

// Mock browser APIs
global.navigator.sendBeacon = jest.fn(() => true);
global.fetch = jest.fn(() => Promise.resolve({ ok: true }));

// Mock document.cookie
Object.defineProperty(document, 'cookie', {
  writable: true,
  value: '',
});

describe('Tracker', () => {
  let tracker;

  beforeEach(() => {
    jest.clearAllMocks();
    tracker = new Tracker({ endpoint: '/wp-json/my-plugin/v1/collect' });
  });

  it('sends a beacon with correct payload', () => {
    tracker.track('pageview', { url: '/hello' });

    expect(navigator.sendBeacon).toHaveBeenCalledOnce();
    const [url, blob] = navigator.sendBeacon.mock.calls[0];
    const body = JSON.parse(blob.text ? blob.text() : blob);
    expect(url).toBe('/wp-json/my-plugin/v1/collect');
    expect(body).toMatchObject({ event: 'pageview', url: '/hello' });
  });

  it('falls back to fetch when sendBeacon returns false', async () => {
    navigator.sendBeacon.mockReturnValue(false);
    await tracker.track('pageview', { url: '/hello' });
    expect(global.fetch).toHaveBeenCalled();
  });

  it('does not track when consent is not given', () => {
    tracker = new Tracker({ endpoint: '...', requireConsent: true });
    tracker.track('pageview', {});
    expect(navigator.sendBeacon).not.toHaveBeenCalled();
  });
});
```

---

## 5. CI/CD for WordPress Plugins

### 5.1 Full GitHub Actions Workflow

```yaml
# .github/workflows/tests.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ── PHP Unit + Integration ────────────────────────────────────────────────
  phpunit:
    name: PHPUnit (PHP ${{ matrix.php }} / WP ${{ matrix.wordpress }})
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        php: ['7.4', '8.0', '8.1', '8.2', '8.3']
        wordpress: ['6.4', '6.5', '6.6', '6.7', 'latest', 'trunk']
        exclude:
          # WP trunk requires PHP 8.0+
          - php: '7.4'
            wordpress: 'trunk'

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: wordpress_test
          MYSQL_ROOT_PASSWORD: root
        ports: ['3306:3306']
        options: --health-cmd="mysqladmin ping" --health-retries=3

    steps:
      - uses: actions/checkout@v4

      - name: Set up PHP ${{ matrix.php }}
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          coverage: pcov
          extensions: mysqli, zip
          tools: composer:v2

      - name: Cache Composer dependencies
        uses: actions/cache@v4
        with:
          path: vendor
          key: composer-${{ matrix.php }}-${{ hashFiles('composer.lock') }}

      - name: Install Composer dependencies
        run: composer install --prefer-dist --no-interaction

      - name: Install WordPress test suite
        run: |
          bash bin/install-wp-tests.sh wordpress_test root root 127.0.0.1 ${{ matrix.wordpress }}
        env:
          WP_VERSION: ${{ matrix.wordpress }}

      - name: Run unit tests
        run: vendor/bin/phpunit --testsuite unit --no-coverage

      - name: Run integration tests with coverage
        run: vendor/bin/phpunit --testsuite integration --coverage-clover coverage/clover.xml
        env:
          WP_DB_HOST: 127.0.0.1
          WP_DB_NAME: wordpress_test
          WP_DB_USER: root
          WP_DB_PASSWORD: root

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        if: matrix.php == '8.2' && matrix.wordpress == 'latest'
        with:
          files: coverage/clover.xml
          token: ${{ secrets.CODECOV_TOKEN }}

  # ── JS / Jest ─────────────────────────────────────────────────────────────
  jest:
    name: Jest
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage --ci

  # ── E2E / Playwright ──────────────────────────────────────────────────────
  e2e:
    name: E2E (Playwright)
    runs-on: ubuntu-latest
    needs: [phpunit, jest]

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npx playwright install --with-deps chromium

      - name: Start wp-env
        run: npx wp-env start
        env:
          WP_ENV_TESTS_PORT: 8889

      - name: Run Playwright tests
        run: npx playwright test
        env:
          CI: true

      - name: Upload Playwright report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 14

  # ── Coding Standards ──────────────────────────────────────────────────────
  phpcs:
    name: PHP Coding Standards
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          tools: cs2pr
      - run: composer install --prefer-dist --no-interaction
      - run: vendor/bin/phpcs --report=checkstyle | cs2pr
```

---

### 5.2 `bin/install-wp-tests.sh`

This script (from the WordPress test scaffold) downloads and configures the WordPress test library:

```bash
#!/usr/bin/env bash
# Usage: bin/install-wp-tests.sh <db-name> <db-user> <db-pass> <db-host> <wp-version>

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
WP_VERSION=${5-latest}

WP_TESTS_DIR=${WP_TESTS_DIR-/tmp/wordpress-tests-lib}
WP_CORE_DIR=${WP_CORE_DIR-/tmp/wordpress}

download() {
    if [ $(which curl) ]; then curl -s "$1" > "$2";
    elif [ $(which wget) ]; then wget -nv -O "$2" "$1";
    fi
}

if [[ $WP_VERSION == 'trunk' ]]; then
    WP_TESTS_TAG="trunk"
elif [[ $WP_VERSION == 'latest' ]]; then
    local_version=$(download https://api.wordpress.org/core/version-check/1.7/ - | grep '"version"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
    WP_TESTS_TAG="tags/$local_version"
else
    WP_TESTS_TAG="tags/$WP_VERSION"
fi

mkdir -p "$WP_TESTS_DIR"
svn export --quiet --ignore-externals \
    "https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/includes/" \
    "$WP_TESTS_DIR/includes"
svn export --quiet --ignore-externals \
    "https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/data/" \
    "$WP_TESTS_DIR/data"

# Create wp-tests-config.php
cat > "$WP_TESTS_DIR/wp-tests-config.php" << EOF
<?php
define('DB_NAME', '$DB_NAME');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');
define('DB_HOST', '$DB_HOST');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
define('ABSPATH', '$WP_CORE_DIR/');
EOF
```

---

### 5.3 Secrets Management

```yaml
# Never hardcode credentials — always use GitHub Secrets
env:
  WP_DB_PASSWORD: ${{ secrets.WP_DB_PASSWORD }}
  CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
  WP_REST_TOKEN: ${{ secrets.WP_REST_TOKEN }}

# For wp.org free plugins — use WORDPRESS_ORG_PASSWORD for SVN deployment
- name: Deploy to WordPress.org
  uses: 10up/action-wordpress-plugin-deploy@v2
  env:
    SVN_PASSWORD: ${{ secrets.SVN_PASSWORD }}
    SVN_USERNAME: ${{ secrets.SVN_USERNAME }}
    SLUG: my-plugin-slug
```

---

## 6. Test Coverage Standards

### 6.1 Realistic Coverage Targets for WordPress Plugins

There is no universal mandate from the Plugin Review Team (they do not check coverage), but leading open-source plugins and agencies target the following:

| Plugin type | Recommended line coverage |
|---|---|
| Simple utility plugin (<2k LOC) | 60–70% |
| Mid-sized plugin (2k–10k LOC) | 70–80% |
| Large/complex plugin (WooCommerce scale) | 80–90% |
| Analytics/tracking plugin | 75–85% (critical paths: 90%+) |

**High-priority code paths (always aim for 90%+)**

- Hook registration and callback logic
- REST API controllers (`WP_REST_Controller` subclasses)
- Data mutation functions (DB writes, meta updates, option changes)
- Authentication/permission checks (`permission_callback`)
- Consent and privacy logic

**Lower-priority paths (50–70% acceptable)**

- Admin UI rendering (HTML output)
- Error message strings
- Deprecated shim functions
- Third-party API wrappers (mock at boundary)

---

### 6.2 Coverage Tooling

**pcov (recommended for CI — fastest)**

```bash
# Install pcov
pecl install pcov
# or via shivammathur/setup-php:
# coverage: pcov
```

pcov is 3–5× faster than Xdebug for coverage collection and is safe for CI.

**Xdebug (recommended for local debugging)**

```ini
; php.ini / conf.d/xdebug.ini
zend_extension=xdebug.so
xdebug.mode=coverage
xdebug.start_with_request=yes
```

**phpunit.xml.dist coverage report config**

```xml
<coverage>
  <include>
    <directory suffix=".php">src/</directory>
  </include>
  <exclude>
    <directory>src/Compat/</directory>
    <file>src/generated-schema.php</file>
  </exclude>
  <report>
    <html outputDirectory="coverage/html" lowUpperBound="60" highLowerBound="80"/>
    <clover outputFile="coverage/clover.xml"/>
    <text outputFile="php://stdout" showUncoveredFiles="false"/>
  </report>
</coverage>
```

**Enforcing thresholds in CI**

```xml
<!-- phpunit.xml.dist — fail build if coverage drops below threshold -->
<coverage>
  <report>
    <clover outputFile="coverage/clover.xml"/>
  </report>
</coverage>
```

```yaml
# In GitHub Actions, use a coverage gate action
- name: Check coverage threshold
  uses: johanvanhelden/gha-clover-test-coverage-check@v1
  with:
    percentage: '75'
    filename: coverage/clover.xml
```

---

## 7. Performance Testing

### 7.1 k6 — Load Testing REST Endpoints

[k6](https://k6.io/) is the leading open-source load testing tool. It is script-based (JavaScript) and integrates well with CI.

**Install**

```bash
brew install k6          # macOS
# or use the k6 Docker image in CI
```

**k6 script for a tracking endpoint**

```javascript
// tests/performance/collect-endpoint.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 50 },   // ramp up
    { duration: '2m',  target: 200 },  // sustained load
    { duration: '30s', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],   // <1% error rate
    errors: ['rate<0.05'],
  },
};

export default function () {
  const payload = JSON.stringify({
    event: 'pageview',
    url:   `https://example.com/page-${Math.floor(Math.random() * 1000)}`,
    uid:   `user-${__VU}`,
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  const res = http.post(
    'http://localhost:8888/wp-json/my-plugin/v1/collect',
    payload,
    params
  );

  const ok = check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'body is valid JSON': (r) => {
      try { JSON.parse(r.body); return true; } catch { return false; }
    },
  });

  errorRate.add(!ok);
  sleep(1);
}
```

**Run**

```bash
k6 run tests/performance/collect-endpoint.js
```

---

### 7.2 k6 for wp-admin

```javascript
// tests/performance/wp-admin-dashboard.js
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 20,
  duration: '1m',
  thresholds: {
    http_req_duration: ['p(95)<3000'],  // wp-admin can be slow
    http_req_failed: ['rate<0.02'],
  },
};

// Authenticate once per VU (simulates logged-in admin)
export function setup() {
  const loginRes = http.post('http://localhost:8888/wp-login.php', {
    log: 'admin',
    pwd: 'password',
    wp-submit: 'Log In',
    redirect_to: '/wp-admin/',
    testcookie: '1',
  }, { redirects: 5 });
  return { cookies: loginRes.cookies };
}

export default function (data) {
  const res = http.get('http://localhost:8888/wp-admin/', {
    cookies: data.cookies,
  });
  check(res, { 'wp-admin loaded': (r) => r.status === 200 });
}
```

---

### 7.3 Locust (Python alternative)

```python
# tests/performance/locustfile.py
from locust import HttpUser, task, between
import json, random

class TrackingUser(HttpUser):
    wait_time = between(0.5, 2)

    @task(3)
    def send_pageview(self):
        self.client.post(
            '/wp-json/my-plugin/v1/collect',
            json={
                'event': 'pageview',
                'url': f'https://example.com/page-{random.randint(1, 1000)}',
            },
            headers={'Content-Type': 'application/json'},
        )

    @task(1)
    def send_click(self):
        self.client.post(
            '/wp-json/my-plugin/v1/collect',
            json={'event': 'click', 'element': 'cta-button'},
        )
```

```bash
locust -f tests/performance/locustfile.py --host=http://localhost:8888 \
  --users 200 --spawn-rate 20 --run-time 2m --headless
```

---

### 7.4 Recommended Thresholds for Analytics Plugins

| Metric | Green | Yellow | Red |
|---|---|---|---|
| P95 response time (collect endpoint) | <200ms | 200–500ms | >500ms |
| P99 response time | <500ms | 500ms–1s | >1s |
| Error rate under 200 VU | <0.5% | 0.5–2% | >2% |
| DB write time (single row) | <20ms | 20–50ms | >50ms |
| Throughput (req/s) | >500 | 200–500 | <200 |

---

## 8. Official WordPress Standards

### 8.1 WordPress Core Testing Guidelines

- All patches to WordPress Core must include unit or integration tests.
- Tests live in `tests/phpunit/` in the `develop.svn.wordpress.org` repository.
- The Core team uses the `WP_UnitTestCase` base class exclusively.
- Core requires all tests to pass on **all supported PHP versions** (currently 7.4–8.3).
- Reference: https://make.wordpress.org/core/handbook/testing/

### 8.2 Plugin Review Team Requirements

The WordPress.org Plugin Review Team does **not mandate** automated tests as a submission requirement. However, they do require:

- No live API calls on activation (no calling external services without user consent).
- Data sanitized on input, escaped on output.
- Correct use of nonces and capability checks.

> **Implication:** Testing nonce verification, capability checks, and sanitization/escaping functions is the minimum recommended coverage for plugins targeting wp.org.

### 8.3 10up Engineering Standards

10up's public [Engineering Best Practices](https://10up.github.io/Engineering-Best-Practices/) specify:

- PHPUnit for unit and integration testing.
- WP_Mock (which 10up maintains) as the preferred WordPress function mocking library.
- Jest for JavaScript testing.
- Cypress for E2E (their guidance predates Playwright's dominance; newer projects now use Playwright).
- Tests required for: REST endpoints, custom DB queries, hook callbacks, and utility functions.
- Coding standard: WordPress Coding Standards (WPCS) enforced via PHPCS.

### 8.4 WordPress VIP Testing Requirements

[WordPress VIP](https://docs.wpvip.com/technical-references/testing/) has the most rigorous requirements in the ecosystem:

- **PHPUnit integration tests required** for code running on VIP infrastructure.
- All database queries must be covered.
- No direct `$wpdb->query()` calls without test coverage.
- VIP uses the [VIP Coding Standards](https://github.com/Automattic/VIP-Coding-Standards) PHPCS ruleset (extends WPCS with stricter rules).
- Performance-sensitive code (high-traffic hooks, cron jobs) requires load testing evidence.
- E2E tests required for any checkout or subscription flows.
- VIP recommends `wp-env` for local and CI environments.

### 8.5 Automattic Internal Standards

Based on public repositories and engineering blog posts:

- WooCommerce uses a combination of PHPUnit (integration), Jest (JS), and Playwright (E2E).
- Gutenberg exclusively uses Playwright for E2E as of 2024.
- Jetpack uses PHPUnit + Jest + Playwright with a complex monorepo CI setup.
- Internal code coverage gate: 80% for new features, waivable with justification.

---

## 9. Real-World Plugin Examples

### 9.1 WooCommerce

**Test suite structure:**

```
woocommerce/
├── plugins/woocommerce/
│   ├── tests/
│   │   ├── php/
│   │   │   ├── includes/        # unit tests mirroring src/
│   │   │   ├── api/             # REST API integration tests
│   │   │   ├── bootstrap.php
│   │   │   └── phpunit.xml
│   │   ├── e2e/                 # Playwright E2E
│   │   │   ├── tests/
│   │   │   │   ├── shopper/
│   │   │   │   ├── merchant/
│   │   │   │   └── api/
│   │   │   └── playwright.config.js
│   │   └── js/                  # Jest unit tests
```

**Key practices:**
- REST API controllers have 1:1 test files in `tests/php/api/`.
- WC uses `WC_Unit_Test_Case` (extends `WP_UnitTestCase`) with a custom factory (`WC_Helper_Product`, `WC_Helper_Order`).
- Playwright E2E tests cover complete purchase flows including Stripe payment mocking.
- GitHub Actions matrix: PHP 7.4–8.3 × WP 6.4–trunk.
- JS coverage threshold: 70% lines.

### 9.2 Yoast SEO

**Test suite structure:**

```
wordpress-seo/
├── tests/
│   ├── unit/                   # Brain Monkey (no WP bootstrap)
│   │   ├── src/
│   │   └── bootstrap.php
│   ├── integration/            # WP_UnitTestCase
│   │   └── bootstrap.php
│   └── js/                     # Jest
│       └── __tests__/
```

**Key practices:**
- Yoast uses **Brain Monkey** for all unit tests — one of the largest Brain Monkey codebases in the WP ecosystem.
- Strict separation: `tests/unit/` never loads WordPress; `tests/integration/` always does.
- Uses `yoast/wp-test-utils` (their own open-source helper library wrapping Brain Monkey + WP fixtures).
- REST endpoint tests use integration tests with factory-created posts.
- CI matrix: PHP 7.4–8.3, WP 6.3–trunk, tested on pull requests and nightly schedules.

### 9.3 WP Rocket

WP Rocket is commercial/closed-source, but based on public documentation and their engineering blog:

- PHPUnit for unit tests, wp-env for integration.
- Heavy emphasis on cache-busting test scenarios (file system mocking with `vfsStream`).
- Performance regression tests: they run k6 against a reference site and assert that TTFB does not regress.
- Their CI runs PHPCS + PHPUnit on every PR, E2E only on release branches.

### 9.4 ACF (Advanced Custom Fields)

- PHPUnit integration tests with custom field type factories.
- Tests `register_field_group()` and all field type `->update_value()` / `->get_value()` callbacks.
- Jest for the field builder UI.

---

## 10. Gaps: Analytics / Tracking Plugins

### 10.1 Testing `sendBeacon` / Beacon API

```javascript
// Reliable pattern for testing sendBeacon with JSDOM
describe('BeaconSender', () => {
  beforeEach(() => {
    // JSDOM doesn't implement sendBeacon — we must mock it
    Object.defineProperty(navigator, 'sendBeacon', {
      writable: true,
      value: jest.fn(() => true),
    });
  });

  it('uses sendBeacon for pageunload events', () => {
    const sender = new BeaconSender({ endpoint: '/collect' });
    sender.send({ event: 'pageunload' });
    expect(navigator.sendBeacon).toHaveBeenCalledWith(
      '/collect',
      expect.any(Blob)
    );
  });

  it('serialises payload as application/json blob', () => {
    const sender = new BeaconSender({ endpoint: '/collect' });
    sender.send({ event: 'click', target: '#cta' });

    const blob = navigator.sendBeacon.mock.calls[0][1];
    expect(blob.type).toBe('application/json');
  });
});
```

**PHP-side test for the receiving endpoint:**

```php
public function test_beacon_endpoint_accepts_json_body(): void
{
    $request = new WP_REST_Request('POST', '/my-plugin/v1/collect');
    $request->set_header('Content-Type', 'application/json');
    $request->set_body(json_encode(['event' => 'pageview', 'url' => '/hello']));

    $response = rest_do_request($request);

    self::assertSame(200, $response->get_status());
}
```

---

### 10.2 Consent Gate Logic

Consent logic is safety-critical — test every state transition:

```javascript
describe('ConsentManager', () => {
  const cookieName = 'my_plugin_consent';

  beforeEach(() => {
    document.cookie = `${cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
    localStorage.clear();
  });

  it.each([
    ['cookie absent', () => {}],
    ['cookie explicitly declined', () => { document.cookie = `${cookieName}=0`; }],
  ])('does not track when %s', (_, setup) => {
    setup();
    const manager = new ConsentManager();
    expect(manager.hasConsent()).toBe(false);
  });

  it('tracks after consent is granted', () => {
    const manager = new ConsentManager();
    manager.grant();
    expect(manager.hasConsent()).toBe(true);
    // Also verify the cookie was set
    expect(document.cookie).toContain(`${cookieName}=1`);
  });

  it('revokes consent and fires consent_revoked event', () => {
    const handler = jest.fn();
    window.addEventListener('my_plugin_consent_revoked', handler);

    const manager = new ConsentManager();
    manager.grant();
    manager.revoke();

    expect(manager.hasConsent()).toBe(false);
    expect(handler).toHaveBeenCalledOnce();
  });
});
```

---

### 10.3 Fingerprinting

Fingerprinting helpers must be tested against known inputs with deterministic outputs:

```javascript
describe('FingerprintBuilder', () => {
  it('produces a stable hash for identical inputs', () => {
    const input = { ua: 'Mozilla/5.0', lang: 'en-US', tz: 'Europe/London' };
    const fp = new FingerprintBuilder();

    const hash1 = fp.build(input);
    const hash2 = fp.build(input);

    expect(hash1).toBe(hash2);
    expect(hash1).toHaveLength(32); // MD5 hex
  });

  it('produces different hashes for different inputs', () => {
    const fp = new FingerprintBuilder();
    expect(fp.build({ lang: 'en-US' })).not.toBe(fp.build({ lang: 'fr-FR' }));
  });

  it('omits undefined properties from the hash', () => {
    const fp = new FingerprintBuilder();
    const withUndefined  = fp.build({ ua: 'Mozilla', plugins: undefined });
    const withoutPlugins = fp.build({ ua: 'Mozilla' });
    expect(withUndefined).toBe(withoutPlugins);
  });
});
```

---

### 10.4 Geolocation Providers

Mock the provider at the boundary — test the consumer logic, not the third-party API:

```php
<?php
// Interface your plugin should define
interface GeoProvider {
    public function get_country(string $ip): string;
}

// Test with a mock provider
class Test_Geo_Router extends WP_UnitTestCase
{
    public function test_eu_traffic_is_flagged(): void
    {
        $provider = $this->createMock(GeoProvider::class);
        $provider->method('get_country')->willReturn('DE');

        $router = new GeoRouter($provider);
        $result = $router->classify('203.0.113.1');

        self::assertTrue($result->is_eu());
        self::assertTrue($result->requires_gdpr_consent());
    }

    public function test_us_traffic_is_not_flagged_for_gdpr(): void
    {
        $provider = $this->createMock(GeoProvider::class);
        $provider->method('get_country')->willReturn('US');

        $router = new GeoRouter($provider);
        $result = $router->classify('8.8.8.8');

        self::assertFalse($result->requires_gdpr_consent());
    }
}
```

---

### 10.5 Database Write-Heavy Code

For analytics plugins writing high-volume event rows, test:

1. **Correctness** — the right data is written
2. **Batching** — batch inserts are used (not N+1 single inserts)
3. **Idempotency** — duplicate events don't create duplicate rows

```php
class Test_Event_Writer extends WP_UnitTestCase
{
    /** @var wpdb|\PHPUnit\Framework\MockObject\MockObject */
    private $wpdb_mock;

    public function set_up(): void
    {
        parent::set_up();
        // For high-write tests, mock wpdb to avoid hitting the actual DB
        $this->wpdb_mock = $this->createMock(\wpdb::class);
        $this->wpdb_mock->prefix = 'wp_';
    }

    public function test_bulk_insert_uses_single_query(): void
    {
        $this->wpdb_mock->expects($this->once()) // exactly ONE insert call
            ->method('query')
            ->with($this->stringContains('INSERT INTO'))
            ->willReturn(5);

        $writer = new EventWriter($this->wpdb_mock);
        $writer->bulk_insert([
            ['event' => 'pageview', 'url' => '/a'],
            ['event' => 'pageview', 'url' => '/b'],
            ['event' => 'click',    'url' => '/c'],
            ['event' => 'pageview', 'url' => '/d'],
            ['event' => 'scroll',   'url' => '/e'],
        ]);
    }

    public function test_integration_writes_correct_row(): void
    {
        // Use real DB for this one
        global $wpdb;
        $writer = new EventWriter($wpdb);

        $writer->insert(['event' => 'pageview', 'url' => '/hello', 'uid' => 'abc']);

        $row = $wpdb->get_row(
            "SELECT * FROM {$wpdb->prefix}my_events WHERE uid = 'abc'"
        );

        self::assertNotNull($row);
        self::assertSame('pageview', $row->event);
        self::assertSame('/hello',   $row->url);
    }
}
```

---

### 10.6 Summary — Analytics Plugin Testing Checklist

| Area | Unit | Integration | E2E | Perf |
|---|---|---|---|---|
| Beacon / sendBeacon | ✅ Jest mock | ✅ REST endpoint | ✅ Network intercept | — |
| Consent gate (JS) | ✅ Jest | — | ✅ Cookie/storage state | — |
| Consent gate (PHP) | ✅ PHPUnit | ✅ WP_UnitTestCase | — | — |
| Geolocation lookup | ✅ PHPUnit (mock provider) | ✅ (real provider, gated) | — | ✅ k6 |
| Fingerprinting | ✅ Jest (snapshot) | — | — | — |
| DB writes (events) | ✅ wpdb mock | ✅ real DB | — | ✅ k6 |
| REST collect endpoint | ✅ PHPUnit | ✅ integration | ✅ Playwright | ✅ k6 |
| WP-admin analytics UI | — | — | ✅ Playwright | ✅ k6 (light) |
| Cron aggregation jobs | ✅ PHPUnit | ✅ integration | — | — |

---

## Quick-Reference: Recommended Toolchain (2025)

| Layer | Tool | Notes |
|---|---|---|
| PHP unit tests | PHPUnit 10 + Brain Monkey | No WP bootstrap |
| PHP integration | PHPUnit 10 + WP_UnitTestCase | wp-env Docker |
| JS unit | Jest + @wordpress/jest-preset-default | |
| React/Blocks | Jest + @testing-library/react | |
| E2E | Playwright + @wordpress/e2e-test-utils-playwright | |
| CI environment | GitHub Actions + wp-env | |
| PHP linting | PHPCS + WPCS / VIP-Coding-Standards | |
| Coverage (CI) | pcov | Faster than Xdebug |
| Coverage (local) | Xdebug 3 | Debugging support |
| Coverage gate | Codecov or clover-check action | |
| Performance | k6 | REST + wp-admin |
| Reporting | Codecov, Playwright HTML, Jest --coverage | |

---

*Last updated: 2025 — based on WordPress 6.7, PHPUnit 10, Playwright 1.44, wp-env 10.x, Brain Monkey 2.6, WP_Mock 0.5.*
