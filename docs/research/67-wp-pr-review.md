# Building a Claude Code skill for WordPress plugin PR reviews

**WordPress plugins account for 96% of all WordPress vulnerabilities** — 7,966 new ones discovered in 2024 alone, a 34% increase year-over-year. A well-structured Claude Code PR review skill can catch the most dangerous patterns before they ship: missing escaping, broken access control, SQL injection, and the dozens of WordPress-specific anti-patterns that automated linters miss. This document provides the complete research foundation for building that skill, covering official standards, security patterns, performance anti-patterns, add-on ecosystem considerations (informed by wp-slimstat), tooling integration, and the Claude Code SKILL.md architecture itself.

The research spans 10 domains — from WordPress Coding Standards and OWASP mappings to real-world CVEs from 2024–2025, backward compatibility matrices, and the exact SKILL.md frontmatter format. Every section includes code examples showing both vulnerable and secure patterns, severity classifications, and direct references. The goal: a single SKILL.md-driven review workflow that any WordPress plugin team can adopt.

---

## 1. WordPress plugin development standards and official documentation

### Plugin header requirements and file structure

Every WordPress plugin begins with a header comment block in its main PHP file. The **only mandatory field is `Plugin Name`**, but a production plugin should declare all metadata:

```php
/*
 * Plugin Name:       My Plugin
 * Plugin URI:        https://example.com/plugins/my-plugin/
 * Description:       Short description (under 140 chars)
 * Version:           1.0.0
 * Requires at least: 5.6
 * Requires PHP:      7.4
 * Author:            Author Name
 * License:           GPL v2 or later
 * Text Domain:       my-plugin
 * Domain Path:       /languages
 * Requires Plugins:  woocommerce
 */
```

The `Requires at least`, `Requires PHP`, and `Tested up to` headers are critical for compatibility enforcement. WordPress prevents installation when minimum requirements aren't met, and plugins not tested against the latest 3 major releases receive a warning on wordpress.org.

The canonical file structure separates admin code from public code:

```
/plugin-name/
    plugin-name.php          # Main file with header
    uninstall.php            # Cleanup on deletion
    /includes/               # Shared classes
    /admin/                  # Admin-only code (css/, js/, images/)
    /public/                 # Frontend code (css/, js/, images/)
    /languages/              # Translation files
```

**Every PHP file must include the ABSPATH guard**: `if ( ! defined( 'ABSPATH' ) ) { exit; }` — this prevents direct file access and is a mandatory check during wordpress.org plugin review.

### WordPress PHP Coding Standards (WPCS)

The WPCS enforces rules that differ significantly from PSR standards. Key rules a reviewer must know:

- **Naming**: Functions and variables use `snake_case` (never camelCase). Classes use `Capitalized_Words_With_Underscores`. Constants are `ALL_UPPERCASE`. File names are lowercase with hyphens.
- **Indentation**: Real tabs, not spaces. Trailing commas after last array items.
- **Yoda conditions**: Constants/literals always on the LEFT of comparisons: `if ( true === $value )` — prevents accidental assignment.
- **Array syntax**: Long syntax required: `array( 1, 2, 3 )` — not `[ 1, 2, 3 ]`.
- **Braces**: Always required, even for single statements. Opening brace on same line as control structure.
- **Spacing**: Spaces inside parentheses of control structures: `foreach ( $foo as $bar )`.
- **No shorthand PHP tags**: Always `<?php`, never `<?` or `<?=`.
- **No `extract()`**: Explicitly prohibited. Never use on any data.
- **`elseif`** not `else if` (for colon syntax compatibility).

Four PHPCS rulesets are available: **WordPress** (complete superset), **WordPress-Core** (core coding standards), **WordPress-Extra** (extended best practices), and **WordPress-Docs** (inline documentation). The `WordPress` ruleset includes all sniffs from the other three.

### WordPress VIP coding standards (stricter subset)

WordPress VIP standards add performance and security rules beyond standard WPCS. Key restrictions:

- **`posts_per_page => -1` is prohibited** — unbounded queries are never acceptable
- **`post__not_in` triggers a warning** — poor performance at scale
- **`file_get_contents()` for remote URLs is banned** — use `vip_safe_wp_remote_get()`
- **`eval()`, `create_function()`, `ini_set()`, `error_reporting()`** — prohibited
- **`switch_to_blog()` is restricted** — performance implications on multisite
- **Front-end database writes are prohibited** — bypassed by page cache
- **Individual cache objects must stay under 1 MB**
- **Application containers are read-only** — file operations only in `/tmp/` and `wp-content/uploads/`

### What the Plugin Review Team checks

The wordpress.org Plugin Review Team's most common rejection reasons, in order of frequency:

1. **Missing or improper data sanitization/escaping** — the single most frequent issue. All `$_POST`, `$_GET`, `$_REQUEST`, `$_SERVER` data must be sanitized. All output must be escaped at the point of echo.
2. **Missing nonce verification** — every form and AJAX action must verify nonces.
3. **Missing capability checks** — `current_user_can()` required before privileged actions.
4. **Non-unique prefixing** — all public namespace items need a unique 4–5 character prefix.
5. **No direct file access guard** — `defined( 'ABSPATH' )` check required.
6. **GPL license violations** — all included code must be GPL-compatible.
7. **Obfuscated code** — human-readable source required; minified files must include originals.
8. **CDN usage for assets** — all non-service scripts/styles must be included locally.
9. **Improper enqueuing** — must use `wp_enqueue_script()` / `wp_enqueue_style()`.
10. **Calling home without disclosure** — no external requests without user knowledge.

### Complete security function reference

**Sanitization functions** strip or transform dangerous input:

| Function | Purpose |
|----------|---------|
| `sanitize_text_field()` | General text — strips tags, breaks, extra whitespace |
| `sanitize_textarea_field()` | Multi-line text — preserves newlines |
| `sanitize_email()` | Email addresses |
| `sanitize_file_name()` | File names — replaces whitespace, special chars |
| `sanitize_key()` | Lowercase alphanumeric + dashes + underscores |
| `sanitize_title()` | URL-safe slugs |
| `sanitize_hex_color()` | 3/6-digit hex color with `#` |
| `sanitize_url()` | URLs |
| `sanitize_sql_orderby()` | SQL ORDER BY clauses |
| `absint()` / `intval()` | Non-negative integer / integer cast |
| `wp_kses()` | Allow only specified HTML tags/attributes |
| `wp_kses_post()` | Allow post-appropriate HTML |

**Escaping functions** encode output for its context:

| Function | Context |
|----------|---------|
| `esc_html()` | Inside HTML elements |
| `esc_attr()` | Inside HTML attributes |
| `esc_url()` | In `href`, `src` URLs |
| `esc_js()` | Inline JavaScript strings |
| `esc_textarea()` | Inside `<textarea>` |
| `wp_kses()` / `wp_kses_post()` | Rich HTML output |
| `wp_json_encode()` | PHP→JS data transfer |

Combined translation+escaping: `esc_html__()`, `esc_html_e()`, `esc_attr__()`, `esc_attr_e()`.

**Critical rules**: Escape LATE (at point of output). Match escape function to context. Use `wp_unslash()` before sanitization on superglobals (WordPress adds magic quotes). Never use `sanitize_text_field()` for SQL protection — use `$wpdb->prepare()`.

### Nonce, capability, and REST API security

**Nonces verify intent, not identity**. Always pair with `current_user_can()`:

```php
// Form: create nonce
wp_nonce_field( 'my-action', '_my_nonce' );

// Handler: verify nonce + check capability
if ( ! wp_verify_nonce( sanitize_text_field( wp_unslash( $_POST['_my_nonce'] ) ), 'my-action' ) ) {
    wp_die( 'Security check failed' );
}
if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( 'Unauthorized' );
}
```

For AJAX: use `check_ajax_referer( 'my-action', 'security' )`. For REST API routes, **`permission_callback` is mandatory** since WP 5.5 — routes without it trigger `_doing_it_wrong`:

```php
register_rest_route( 'myplugin/v1', '/data', array(
    'methods'             => 'POST',
    'callback'            => 'handle_data',
    'permission_callback' => function() {
        return current_user_can( 'edit_posts' );
    },
    'args' => array(
        'email' => array(
            'sanitize_callback' => 'sanitize_email',
            'validate_callback' => 'is_email',
        ),
    ),
));
```

**Critical mistake**: `is_admin()` does NOT check if the user is an administrator — it only checks if the request is to an admin page. ALWAYS use `current_user_can()` for authorization.

For database queries, **always use `$wpdb->prepare()`** with `%s` (string), `%d` (integer), `%f` (float) placeholders. Prefer `$wpdb->insert()`, `$wpdb->update()`, `$wpdb->delete()` for CRUD. Never pass user input directly to `$wpdb->query()`.

---

## 2. Backward compatibility for WordPress 5.6+ and PHP 7.4+

### PHP version compatibility matrix

WordPress requires **PHP 7.4 minimum**. Each PHP version introduces syntax that causes parse errors on older versions — these cannot be caught at runtime:

**PHP 8.0** (breaks on 7.4): Named arguments, union types (`int|string`), match expressions, nullsafe operator (`$obj?->method()`), constructor promotion, `str_contains()`/`str_starts_with()`/`str_ends_with()` (WordPress polyfills these).

**PHP 8.1** (breaks on 8.0): Enums, fibers, readonly properties, intersection types (`Countable&Iterator`), `never` return type. Passing `null` to non-nullable internal function parameters deprecated.

**PHP 8.2** (breaks on 8.1): Readonly classes, `null`/`false`/`true` as standalone types. **Dynamic properties deprecated** — `$obj->undeclaredProperty = 'value'` triggers deprecation notice (fatal in PHP 9.0). Fix: use `#[\AllowDynamicProperties]` or declare all properties.

**Critical PHP 8.2 breaking change**: `strlen(null)`, `strpos(null, ...)`, `explode(',', null)` throw Fatal TypeError. WordPress plugins must cast: `strlen( (string) $value )`.

**WordPress does NOT support named parameters** — parameter names are subject to change across WordPress versions. Never use named arguments when calling WordPress functions.

### Feature detection patterns

```php
// Function-based detection (preferred)
if ( function_exists( 'wp_set_script_translations' ) ) { /* WP 5.0+ */ }
if ( function_exists( 'wp_interactivity_state' ) ) { /* WP 6.5+ */ }
if ( function_exists( 'register_block_type' ) ) { /* WP 5.0+ */ }

// Version-based detection
global $wp_version;
if ( version_compare( $wp_version, '6.5', '>=' ) ) { /* Interactivity API */ }

// PHP version (syntax differences require separate files)
if ( version_compare( PHP_VERSION, '8.0', '>=' ) ) {
    require_once __DIR__ . '/includes/php8-features.php';
}

// Bootstrap with minimum requirements
if ( version_compare( PHP_VERSION, '7.4', '<' ) ) {
    add_action( 'admin_notices', function() {
        echo '<div class="error"><p>' .
            esc_html__( 'Requires PHP 7.4+.', 'my-plugin' ) .
        '</p></div>';
    });
    return;
}
```

**PHPCompatibilityWP** is the recommended PHPCS standard for cross-version checking:

```bash
composer require --dev phpcompatibility/phpcompatibility-wp:"^3.0@dev"
vendor/bin/phpcs -p . --standard=PHPCompatibilityWP --runtime-set testVersion 7.4- --extensions=php
```

### WordPress Privacy Policy API (WP 4.9.6+)

Plugins collecting user data must implement three privacy hooks:

```php
// 1. Privacy policy content suggestion
add_action( 'admin_init', function() {
    if ( function_exists( 'wp_add_privacy_policy_content' ) ) {
        wp_add_privacy_policy_content( 'My Plugin', wp_kses_post( $content ) );
    }
});

// 2. Personal data exporter
add_filter( 'wp_privacy_personal_data_exporters', function( $exporters ) {
    $exporters['my-plugin'] = array(
        'exporter_friendly_name' => __( 'My Plugin Data', 'my-plugin' ),
        'callback'               => 'myplugin_data_exporter',
    );
    return $exporters;
});

// 3. Personal data eraser
add_filter( 'wp_privacy_personal_data_erasers', function( $erasers ) {
    $erasers['my-plugin'] = array(
        'eraser_friendly_name' => __( 'My Plugin Data', 'my-plugin' ),
        'callback'             => 'myplugin_data_eraser',
    );
    return $erasers;
});
```

---

## 3. Security vulnerabilities — OWASP mapping, patterns, and real-world CVEs

### OWASP Top 10 mapped to WordPress plugins

| OWASP Category | WordPress Manifestation |
|---|---|
| A01 Broken Access Control | Missing `current_user_can()` on AJAX/REST handlers; `is_admin()` used as auth |
| A02 Cryptographic Failures | Plaintext keys in `wp_options`; exposed `wp-config.php` |
| A03 Injection | `$wpdb->query()` without `prepare()`; OS command injection via `shell_exec()` |
| A04 Insecure Design | Type juggling with `==`; race conditions in file uploads |
| A05 Security Misconfiguration | `WP_DEBUG` true in production; exposed `phpinfo()` |
| A06 Vulnerable Components | 96% of 2024 vulns were in plugins; 33% unpatched at disclosure |
| A07 Auth Failures | Authentication bypass (Really Simple Security CVE-2024-10924) |
| A08 Data Integrity Failures | `unserialize()` on user data (GiveWP CVE-2024-5932) |
| A09 Logging Failures | No activity logging; no file integrity monitoring |
| A10 SSRF | `wp_remote_get($_GET['url'])` without validation |

### Vulnerability patterns with code examples

**XSS (most common — ~50% of all WP vulns)**:
```php
// VULNERABLE: Stored XSS
echo '<input value="' . get_option('my_setting') . '">';
// sanitize_text_field does NOT escape quotes — still vulnerable in attributes

// FIXED:
echo '<input value="' . esc_attr( get_option('my_setting') ) . '">';
```

**SQL Injection**:
```php
// VULNERABLE: Direct concatenation
$wpdb->get_var("SELECT * FROM wp_users WHERE id = " . $_REQUEST['id']);

// FIXED:
$wpdb->get_var($wpdb->prepare("SELECT * FROM {$wpdb->users} WHERE id = %d", absint($_REQUEST['id'])));
```

**Broken Access Control (AJAX)**:
```php
// VULNERABLE: No capability check, no nonce
add_action('wp_ajax_delete_item', function() {
    $wpdb->delete($wpdb->prefix . 'items', ['id' => $_POST['id']]);
});

// FIXED:
add_action('wp_ajax_delete_item', function() {
    check_ajax_referer('delete_item_nonce', 'security');
    if (!current_user_can('manage_options')) { wp_send_json_error('Unauthorized'); }
    $wpdb->delete($wpdb->prefix . 'items', ['id' => absint($_POST['id'])], ['%d']);
    wp_send_json_success();
});
```

**PHP Object Injection**:
```php
// VULNERABLE: unserialize on user data — allows POP chain RCE
$data = unserialize($_GET['myvalue']);

// FIXED: Use JSON
$data = json_decode(wp_unslash($_POST['data']), true);
```

**Dangerous patterns to always flag**: `eval()`, `assert()`, `preg_replace()` with `/e` modifier, `create_function()`, `extract()` on user input, `shell_exec()`/`exec()`/`system()` with user input, `include`/`require` with user-controlled paths, `$_FILES['type']` for validation (client-controlled).

### Real-world CVEs from 2024–2025

**CVE-2024-10924 — Really Simple Security (4M+ sites, CVSS 9.8)**: Authentication bypass. `check_login_and_get_user()` returned `WP_REST_Response` error on failure, but the calling function never checked the return type — proceeded to authenticate anyway. Unauthenticated attackers could log in as any user including admin when 2FA was enabled. **Code review catch**: All error returns from auth functions must halt execution flow.

**CVE-2024-5932 — GiveWP (100K+ installs, CVSS 10.0)**: PHP Object Injection to RCE. The `give_title` parameter was excluded from serialized field validation, stored as serialized data, then deserialized. A POP chain through Faker's `ValidGenerator` `__call()` magic method led to `call_user_func()` → `shell_exec()` for full remote code execution. **Code review catch**: Grep for `unserialize()`/`maybe_unserialize()` with user-controlled input.

**CVE-2024-27956 — WordPress Automatic Plugin (40K installs)**: Unauthenticated SQL injection via authentication bypass in CSV export. 6,500+ exploitation attempts blocked. **Code review catch**: Every database query path must use `$wpdb->prepare()`.

**CVE-2024-6386 — WPML (1M+ installs, CVSS 9.9)**: Server-Side Template Injection via missing input validation on a Twig render function, exploitable by Contributor+ users.

**CVE-2024-25600 — Bricks Builder (30K installs)**: Unauthenticated RCE via REST route with no capability check. Exploited within hours of disclosure. Generic WAFs failed to block it.

**Key statistics (Patchstack 2025 report)**: **43% of WordPress vulnerabilities are exploitable without authentication**. 33% remained unpatched at public disclosure. 1,018 vulnerabilities affected components with 100K+ installs. XSS was the most common type. Only 7 bugs affected WordPress core itself.

---

## 4. Performance anti-patterns and WordPress-specific code smells

### The most damaging performance mistakes

**N+1 query problem** — the most common performance killer:
```php
// BAD: Separate query per post
$posts = get_posts(['numberposts' => 50]);
foreach ($posts as $post) {
    $meta = get_post_meta($post->ID, 'custom_field', true); // Query each iteration
}

// GOOD: WP_Query with meta cache priming
$query = new WP_Query([
    'posts_per_page'         => 50,
    'update_post_meta_cache' => true,
    'update_post_term_cache' => true,
]);
```

**Autoloaded options bloat** — the `autoload` column in `wp_options` determines what loads into memory on every page request. Autoloaded data should stay **under 800KB–1MB**. Many plugins incorrectly set `autoload='yes'`:
```php
// BAD: Large data autoloaded
update_option('myplugin_large_cache', $huge_array); // autoload defaults to 'yes'

// GOOD: Explicitly disable autoload for non-critical data
update_option('myplugin_large_cache', $huge_array, false);
```

**Unbounded queries**: Never use `posts_per_page => -1` or `nopaging => true`. Always set explicit limits.

**Assets loaded everywhere**: Scripts and styles enqueued globally instead of conditionally:
```php
// BAD: Loads on every admin page
add_action('admin_enqueue_scripts', function() {
    wp_enqueue_style('myplugin-admin', plugins_url('css/admin.css', __FILE__));
});

// GOOD: Load only on the plugin's admin page
add_action('admin_enqueue_scripts', function($hook) {
    if ($hook !== 'toplevel_page_myplugin') return;
    wp_enqueue_style('myplugin-admin', plugins_url('css/admin.css', __FILE__));
});
```

**Cron anti-patterns**: Calling `wp_schedule_event()` on every page load creates duplicate events. Always check first, and always clear on deactivation:
```php
register_activation_hook(__FILE__, function() {
    if (!wp_next_scheduled('myplugin_cron')) {
        wp_schedule_event(time(), 'daily', 'myplugin_cron');
    }
});
register_deactivation_hook(__FILE__, function() {
    wp_clear_scheduled_hook('myplugin_cron');
});
```

### Twenty code patterns to flag in every PR review

Each pattern below includes the severity level a review skill should assign:

**Critical severity**:
- **Hardcoded `wp_` table prefix** instead of `$wpdb->prefix` — breaks on non-default prefix sites and multisite
- **Shortcodes that echo** instead of return — output appears at page top, breaking layout entirely
- **Direct `header()` calls** instead of `wp_safe_redirect()` + `exit` — open redirect vulnerability
- **Direct cURL** instead of WP HTTP API (`wp_remote_get()`) — bypasses transport layer, not hookable, may not work on all hosts
- **Direct filesystem access** instead of `WP_Filesystem` API — fails on hosts requiring FTP credentials
- **`file_get_contents()` for remote requests** — may be disabled, no error handling, bypasses SSL verification
- **Missing activation/deactivation/uninstall hooks** — orphaned data, broken cron jobs, database bloat

**Warning severity**:
- **Hardcoded paths** instead of `plugin_dir_path()`, `plugin_dir_url()`, `plugins_url()`
- **Missing text domain** or incorrect i18n — text domain must match plugin slug, must be string literal
- **Manual form handling** instead of WordPress Settings API — misses nonce/CSRF protection
- **Global variable pollution** — unprefixed functions, classes, constants cause collisions
- **Missing `uninstall.php`** — no cleanup when plugin deleted
- **Non-unique prefixes** — less than 4–5 character unique prefix on all public items
- **Using short PHP tags** — `<?` may be disabled; always use `<?php`
- **Wrong date/time functions** — `date()` uses server timezone; use `current_time()`, `wp_date()`
- **Improper hook priorities** — wrong hook for operations (redirect on `init` = headers sent)
- **No multisite compatibility** — activation only runs for current site

**Info severity**:
- **`json_encode()` instead of `wp_json_encode()`** — misses UTF-8 handling and error checking
- **Not using `wp_parse_args()`** for function arguments
- **Missing PHPDoc blocks** — required by WordPress Docs standards

---

## 5. Add-on and extension ecosystem patterns informed by wp-slimstat

### How wp-slimstat structures its add-on system

wp-slimstat uses the **base plugin + separate add-on plugins** pattern, the dominant architecture among major WordPress plugins (WooCommerce, EDD, GravityForms). Add-ons are standalone WordPress plugins that depend on and extend the core.

The canonical wp-slimstat add-on pattern:

```php
<?php
/*
Plugin Name: WP SlimStat - My Add-on
Description: Extends Slimstat Analytics
Version: 1.0
*/
class wp_slimstat_my_addon {
    public static function init() {
        if (!class_exists('wp_slimstat')) {
            return true; // Graceful degradation
        }
        add_filter('slimstat_filter_pageview_stat', array(__CLASS__, 'modify_pageview'));
    }

    public static function modify_pageview($_stat = array()) {
        // Extension logic here
        return $_stat;
    }
}

if (function_exists('add_action')) {
    add_action('plugins_loaded', array('wp_slimstat_my_addon', 'init'), 15);
}
```

Key architectural elements: **dependency check via `class_exists('wp_slimstat')`**, bootstrap via `plugins_loaded` at **priority 15** (after core loads at priority 10), static class methods with `__CLASS__` references, and filter hooks like `slimstat_filter_pageview_stat`.

wp-slimstat registers a dedicated **Add-ons submenu page** and includes it in the admin bar. Its custom update mechanism contacts `https://www.wp-slimstat.com/update-checker/` with the plugin slug and license key, then caches download links via transients for 48 hours.

### Custom update mechanisms

Two WordPress filter hooks enable self-hosted updates:

**`pre_set_site_transient_update_plugins`** injects update information:
```php
add_filter('pre_set_site_transient_update_plugins', function($transient) {
    if (empty($transient->checked)) return $transient;
    
    $remote = wp_remote_get('https://your-server.com/info.json', [
        'timeout' => 10, 'headers' => ['Accept' => 'application/json']
    ]);
    if (is_wp_error($remote) || 200 !== wp_remote_retrieve_response_code($remote)) {
        return $transient;
    }
    
    $remote = json_decode(wp_remote_retrieve_body($remote));
    if ($remote && version_compare($installed_version, $remote->version, '<')) {
        $res = new stdClass();
        $res->slug = $remote->slug;
        $res->plugin = plugin_basename(__FILE__);
        $res->new_version = $remote->version;
        $res->package = $remote->download_url;
        $transient->response[plugin_basename(__FILE__)] = $res;
    }
    return $transient;
});
```

**`plugins_api`** provides plugin information for the "View Details" modal.

**WordPress 6.5 introduced native `Requires Plugins` header** — `Requires Plugins: woocommerce` in plugin metadata prevents activation if dependencies aren't active. However, it does not support version constraints yet.

### Code review considerations for add-on ecosystems

When reviewing PRs that affect the add-on API, a reviewer must check:

- **Hook signature changes**: Adding optional parameters is safe; removing parameters or changing order is breaking
- **Filter return type changes**: Changing from array to object breaks all existing add-on callbacks
- **Removed or renamed hooks**: Must use `do_action_deprecated()` / `apply_filters_deprecated()` first
- **Public→protected/private visibility changes**: Fatal errors in add-ons calling the method
- **Database schema changes**: Column removals/renames break add-ons querying those columns
- **Constant or option name changes**: Add-ons checking `SLIMSTAT_ANALYTICS_VERSION` or reading `slimstat_options` will fail
- **Semantic versioning adherence**: Breaking changes require a major version bump

---

## 6. PR review best practices, checklists, and severity classification

### Review hierarchy adapted from Google and WP-CLI

Google's engineering practices framework, adapted for WordPress, prioritizes: **Design → Functionality → Complexity → Tests → Naming → Comments → Style → Documentation**. The WP-CLI handbook uses a Maslow-style hierarchy: **Correct → Secure → Readable → Elegant → Altruistic**.

Professional WordPress agencies like **10up** review every line of code including third-party plugins, enforce late escaping, run PHPCS with WordPress standards on all projects, and use automated CI via GitHub Actions. **Automattic (WordPress VIP)** applies the strictest coding standards in the ecosystem.

### Severity classification decision tree

```
Is it a security vulnerability?           → CRITICAL
Could it cause data loss?                 → CRITICAL
Does it cause PHP fatal errors?           → CRITICAL
Is it a broken access control issue?      → CRITICAL
Does it cause significant performance     → WARNING
  degradation (N+1, unbounded queries)?
Does it violate standards with            → WARNING
  functional impact?
Does it break backward compatibility?     → WARNING
Is it missing i18n for user strings?      → WARNING
Is it a style/formatting issue only?      → INFO
Is it a suggestion for improvement?       → INFO
```

### Comprehensive review checklist

**Security** (all CRITICAL if violated): All user input sanitized. All output escaped at point of echo. Nonces on all state-changing actions. `current_user_can()` before privileged operations. `$wpdb->prepare()` on all direct queries. `permission_callback` on all REST routes. No `eval()`, `extract()`, `unserialize()` on user data. ABSPATH guard on all files.

**Performance** (WARNING): No `posts_per_page => -1`. No queries in loops. Transients/cache for expensive operations. Assets conditional-loaded. Autoload set correctly. No blocking operations on `init`.

**Compatibility** (WARNING): PHP/WP minimum version declared and checked. Feature detection with `function_exists()`. No PHP 8+ syntax without guards. Multisite-aware activation. Proper lifecycle hooks.

**Standards** (INFO to WARNING): WPCS-compliant naming. WordPress APIs used instead of PHP equivalents. No deprecated functions. Proper PHPDoc. i18n on all user-facing strings with correct text domain.

---

## 7. Tooling ecosystem for automated WordPress plugin analysis

### PHPCS with WordPress standards

Installation and configuration:
```bash
composer require --dev wp-coding-standards/wpcs dealerdirect/phpcodesniffer-composer-installer
```

A custom ruleset (`phpcs.xml.dist`) configures project-specific rules:
```xml
<?xml version="1.0"?>
<ruleset name="My Plugin">
    <file>.</file>
    <exclude-pattern>/vendor/*</exclude-pattern>
    <exclude-pattern>/node_modules/*</exclude-pattern>
    
    <rule ref="WordPress-Extra"/>
    <rule ref="WordPress-Docs"/>
    
    <config name="minimum_wp_version" value="5.6"/>
    
    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
                <element value="my-plugin"/>
            </property>
        </properties>
    </rule>
    
    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" type="array">
                <element value="my_plugin"/>
            </property>
        </properties>
    </rule>
</ruleset>
```

Key sniffs: **WordPress.Security.EscapeOutput** (unescaped output), **WordPress.Security.NonceVerification** (missing nonces), **WordPress.Security.ValidatedSanitizedInput** (unsanitized input), **WordPress.DB.PreparedSQL** (SQL injection risks), **WordPress.WP.DeprecatedFunctions** (deprecated calls).

### PHPStan for WordPress

```bash
composer require --dev phpstan/phpstan szepeviktor/phpstan-wordpress phpstan/extension-installer
```

Configuration (`phpstan.neon`):
```yaml
includes:
    - vendor/szepeviktor/phpstan-wordpress/extension.neon
parameters:
    level: 5
    paths: [plugin.php, src/, includes/]
    excludePaths: [vendor/, node_modules/]
```

PHPStan catches undefined functions/methods/classes, type mismatches, dead code, missing return statements, and validates `apply_filters()`/`do_action()` docblocks. Start at **level 5** and increase gradually (levels 0–9).

### WordPress Plugin Check (PCP) — official tool

Since October 2024, the official **Plugin Check (PCP)** tool is used for automatic pre-submission checks on wordpress.org. Plugins with errors in the Plugin Repo category are blocked from submission. It performs both static checks (PHPCS sniffs, regex analysis) and runtime checks (actual plugin activation).

```bash
wp plugin install plugin-check --activate
wp plugin check my-plugin --categories=security,performance
```

GitHub Action integration:
```yaml
- uses: wordpress/plugin-check-action@v1
```

### GitHub Actions CI/CD matrix

A production WordPress plugin CI pipeline should test across PHP versions (7.4, 8.0, 8.1, 8.2, 8.3) and WordPress versions (latest minus 2, latest), running PHPCS, PHPStan, PHPUnit, Plugin Check, and ESLint in parallel jobs. The `shivammathur/setup-php@v2` action configures PHP versions, and `cs2pr` converts PHPCS output to GitHub annotations.

---

## 8. Claude Code SKILL.md architecture for PR review

### How skills are structured

A Claude Code skill consists of a directory containing a `SKILL.md` file with **YAML frontmatter** and **markdown instructions**:

```yaml
---
name: wp-plugin-pr-review
description: Review WordPress plugin pull requests for security vulnerabilities,
  performance issues, coding standards violations, and backward compatibility problems.
  Use when reviewing PRs, analyzing diffs, or auditing WordPress plugin code.
context: fork
allowed-tools: Read, Grep, Glob, Bash
---
```

The directory structure supports progressive disclosure:
```
wp-plugin-pr-review/
├── SKILL.md                          # Core instructions (<500 lines)
├── references/
│   ├── security-checklist.md         # Detailed security patterns
│   ├── performance-checklist.md      # Performance anti-patterns  
│   ├── standards-checklist.md        # WPCS rules reference
│   ├── addon-ecosystem.md            # Add-on compatibility checks
│   └── vulnerability-patterns.md     # Known CVE patterns
└── scripts/
    └── grep-patterns.sh             # Deterministic pattern detection
```

**Key architectural decisions**:
- **`context: fork`** runs the review as a subagent, isolating it from the main conversation
- **`allowed-tools: Read, Grep, Glob, Bash`** restricts to read-only operations appropriate for review
- **Progressive disclosure**: Metadata (~100 tokens) loads at startup; full instructions (<5K tokens) load when relevant; reference files load only as needed
- **SKILL.md should stay under 500 lines** — detailed checklists go in `references/`

### Anthropic's official code-review plugin pattern

Anthropic ships an official code-review plugin that launches **4 parallel review agents**, scores each finding for confidence, and **only outputs issues with confidence ≥80**. This is the baseline pattern to build on:

```
/code-review              # Outputs to terminal
/code-review --comment    # Posts as PR comment
```

### Recommended output format for findings

```markdown
## Code Review Summary
- **Files reviewed**: 12
- **Critical issues**: 1 | **Warnings**: 3 | **Info**: 2
- **Verdict**: CHANGES REQUESTED

### 🔴 CRITICAL: SQL injection in analytics query
- **File**: `includes/class-analytics.php` (Lines 142–148)
- **Category**: Security — WordPress.DB.PreparedSQL
- **Confidence**: 0.95

**Problem**: User input from `$_GET['filter']` passed directly to `$wpdb->query()`.

**Vulnerable code**:
```php
$results = $wpdb->get_results("SELECT * FROM {$table} WHERE status = '" . $_GET['filter'] . "'");
```

**Fix**:
```php
$results = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$table} WHERE status = %s",
    sanitize_text_field(wp_unslash($_GET['filter']))
));
```
```

### Recommended SKILL.md workflow structure

The skill should execute a **five-phase review workflow**:

1. **Context gathering**: Read `CLAUDE.md`, `composer.json`, `phpcs.xml.dist`, and the main plugin file header to understand the project's conventions, PHP/WP version requirements, and text domain.

2. **Diff analysis**: Run `git diff main...HEAD` to identify changed files and their purposes. Focus review only on changes introduced by the PR.

3. **Critical security scan**: Grep for dangerous patterns first — `$_GET`/`$_POST`/`$_REQUEST` without sanitization, `$wpdb->query()` without `prepare()`, `unserialize()`, `eval()`, `extract()`, missing `permission_callback`, missing nonce verification.

4. **Standards and compatibility review**: Check for WPCS violations, backward compatibility issues (PHP 8+ syntax without guards, deprecated function usage), performance anti-patterns (queries in loops, `posts_per_page => -1`, global asset loading), and add-on ecosystem impact (hook signature changes, visibility changes, removed extension points).

5. **Output formatting**: Group findings by severity (CRITICAL → WARNING → INFO), include file paths and line numbers, provide both the problem and the fix, filter by confidence threshold (≥80), and generate a verdict (APPROVE / REQUEST_CHANGES / COMMENT).

### Deterministic grep patterns for the skill's scripts

The skill should include a bash script that greps for high-signal patterns:

```bash
# Security patterns (CRITICAL)
grep -rn "\\$_GET\|\\$_POST\|\\$_REQUEST\|\\$_SERVER\|\\$_COOKIE" --include="*.php" .
grep -rn "\\$wpdb->query\|\\$wpdb->get_" --include="*.php" . | grep -v "prepare"
grep -rn "unserialize\|maybe_unserialize" --include="*.php" .
grep -rn "eval(\|assert(\|create_function\|extract(" --include="*.php" .
grep -rn "shell_exec\|exec(\|system(\|passthru\|popen" --include="*.php" .
grep -rn "permission_callback.*__return_true" --include="*.php" .

# Performance patterns (WARNING)
grep -rn "posts_per_page.*-1\|nopaging.*true" --include="*.php" .
grep -rn "query(\|get_results\|get_var\|get_row\|get_col" --include="*.php" . # Inside loops

# Standards patterns (WARNING/INFO)  
grep -rn "wp_redirect\b" --include="*.php" . | grep -v "wp_safe_redirect"
grep -rn "json_encode\b" --include="*.php" . | grep -v "wp_json_encode"
grep -rn "file_get_contents\|curl_init\|curl_exec" --include="*.php" .
grep -rn "header(" --include="*.php" . | grep -i "location"
```

The LLM then analyzes grep results contextually — determining whether a `$_POST` usage is actually sanitized nearby, whether a `$wpdb->get_results()` is inside a loop, and whether a `file_get_contents()` is for local files (acceptable) or remote URLs (not acceptable).

---

## 9. Putting it all together — from research to SKILL.md

### Key design decisions for the skill

**Scope management**: The skill must be generic for any WordPress plugin but include special awareness for add-on ecosystems. The `references/addon-ecosystem.md` file should contain wp-slimstat-informed patterns: dependency checking via `class_exists()`, custom update hook safety (`pre_set_site_transient_update_plugins`), license key handling, and hook contract preservation.

**False positive reduction**: The biggest risk in an AI code review skill is noise. The Anthropic code-review plugin's approach — **confidence scoring with an ≥80 threshold** — is essential. The skill should explicitly instruct: "Do NOT flag formatting issues handled by PHPCS. Do NOT flag patterns in vendor/ or node_modules/. Focus on issues introduced by the PR diff, not legacy code."

**Progressive depth**: Start with the deterministic grep scan (fast, high-signal), then escalate to contextual analysis (understanding whether flagged patterns are actually dangerous in context), then provide severity-classified output with fix suggestions.

**Integration with existing tooling**: The skill should check for and reference existing PHPCS/PHPStan configuration. If `phpcs.xml.dist` exists, note its configured text domain and prefix. If `phpstan.neon` exists, note its configured level. The review should complement — not duplicate — these automated tools.

### What makes WordPress plugin review uniquely challenging

WordPress's architecture creates review challenges absent from typical PHP projects. The global function namespace means every plugin function risks collision. The hook system means security bugs can appear anywhere in the call chain — a filter callback that modifies data without sanitizing it may be called from a context that trusts its output. WordPress's "magic quotes" wrapping of superglobals means `wp_unslash()` must be called before sanitization. The `is_admin()` function is one of the most dangerous misleading APIs in the ecosystem — it checks request context, not user role, yet developers constantly use it for authorization.

The add-on ecosystem adds another layer: changes to hook signatures, public method visibility, database schemas, or option key names can silently break third-party add-ons that the core plugin developer may not even know about. A good review skill must flag these as **WARNING: Potential add-on breaking change** whenever hooks, public APIs, or shared data structures are modified.

---

## Conclusion

This research reveals three critical insights for building the Claude Code PR review skill. First, **WordPress security review is fundamentally different from general PHP security review** — the platform's unique functions (`esc_html()` vs `htmlspecialchars()`, `$wpdb->prepare()` vs PDO, `wp_verify_nonce()` for CSRF), its misleading APIs (`is_admin()`), and its global namespace architecture create a distinct vulnerability surface that requires WordPress-specific knowledge encoded in the skill's reference files.

Second, the **highest-value review targets are the CRITICAL patterns**: missing `$wpdb->prepare()`, unescaped output, missing capability checks on AJAX/REST handlers, and `unserialize()` on user data. These four patterns account for the vast majority of real-world WordPress CVEs from 2024–2025. A skill that reliably catches only these four categories would prevent most critical vulnerabilities.

Third, **the skill architecture must balance LLM analysis with deterministic detection**. Grep-based pattern matching catches dangerous function calls with near-zero false negatives; the LLM's contextual understanding then filters false positives (is this `$_POST` access actually sanitized two lines above?) and provides actionable fix suggestions. This "10% LLM steering, 90% deterministic execution" approach, recommended by experienced Claude Code skill builders, produces the most reliable reviews.

The complete reference material — vulnerability patterns, WPCS rules, backward compatibility matrices, add-on ecosystem contracts, and severity classification trees — should live in the skill's `references/` directory for progressive loading, keeping the core SKILL.md under 500 lines and focused on the five-phase review workflow.