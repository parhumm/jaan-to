# Add-on Ecosystem Checklist — WordPress Plugin PR Review

> Reference file for wp-pr-review skill. Loaded on demand during Step 4.
> Informed by wp-slimstat architecture and WordPress plugin ecosystem patterns.

---

## Hook Contract Preservation

WordPress plugins expose extensibility via `do_action()` and `apply_filters()`. Third-party add-ons depend on these hook signatures.

### Safe changes
- **Adding optional parameters** to existing hooks (backward compatible)
- **Adding new hooks** (no existing code depends on them)
- **Changing hook priority** within the same plugin's internal handlers

### Breaking changes (flag as WARNING)
- **Removing parameters** from hooks
- **Changing parameter order** in hooks
- **Changing parameter types** (array to object, string to int)
- **Renaming hooks** without deprecation notice
- **Removing hooks entirely** without deprecation notice

### Proper deprecation pattern
```php
// CORRECT — deprecate before removing
do_action_deprecated(
    'old_hook_name',
    array( $arg1, $arg2 ),
    '2.0.0',                    // Version deprecated
    'new_hook_name',             // Replacement
    'Old hook is deprecated.'    // Message
);

apply_filters_deprecated(
    'old_filter_name',
    array( $value, $context ),
    '2.0.0',
    'new_filter_name'
);
```

---

## Public API Stability

### Method visibility changes

| Change | Impact | Severity |
|--------|--------|----------|
| `public` to `protected` | Fatal error in add-ons calling the method | WARNING |
| `public` to `private` | Fatal error in add-ons calling the method | WARNING |
| `protected` to `private` | Fatal error in extending classes | WARNING |
| `private` to `public` | Safe (expands access) | INFO |
| `protected` to `public` | Safe (expands access) | INFO |

### Class structure changes

- **Removing a class** — Fatal error in `class_exists()` checks and `instanceof`
- **Renaming a class** — Same as removing without alias
- **Final-izing a class** — Breaks add-ons that extend it
- **Changing constructor signature** — Breaks `new ClassName()` calls in add-ons

### Method signature changes

- **Adding required parameters** — Fatal error in existing callers
- **Removing parameters** — May cause unexpected behavior
- **Changing return type** — Type errors in callers expecting previous type

---

## Database Schema Stability

### Changes that break add-ons
- **Column removals** — Add-ons querying removed columns get SQL errors
- **Column renames** — Same as removal for existing queries
- **Type changes** — May cause data truncation or type mismatch errors
- **Table renames** — All add-on queries against old table name fail

### Safe changes
- **Adding columns** (existing queries still work)
- **Adding indexes** (performance improvement, no breakage)
- **Adding tables** (no existing code references them)

### Migration pattern
```php
// Provide upgrade routine with version tracking
function myplugin_upgrade_db() {
    $current = get_option( 'myplugin_db_version', '1.0' );
    if ( version_compare( $current, '2.0', '<' ) ) {
        // Migration logic
        update_option( 'myplugin_db_version', '2.0' );
    }
}
add_action( 'plugins_loaded', 'myplugin_upgrade_db' );
```

---

## Option and Constant Stability

### Option key changes
Add-ons may directly read plugin options:
```php
// Add-on code (outside your control)
$settings = get_option( 'myplugin_options' );
$api_key = $settings['api_key'];
```

**Flag as WARNING**: Renaming option keys, changing option structure (flat to nested or vice versa), removing option keys without migration.

### Constant changes
Add-ons may check version constants:
```php
if ( defined( 'MYPLUGIN_VERSION' ) && version_compare( MYPLUGIN_VERSION, '2.0', '>=' ) ) {
    // Use new feature
}
```

**Flag as WARNING**: Removing or renaming constants that add-ons may reference.

---

## Semantic Versioning

WordPress plugins should follow semver for add-on ecosystem health:

| Version Bump | When |
|-------------|------|
| Major (2.0.0) | Breaking changes to hooks, public API, database schema |
| Minor (1.1.0) | New features, new hooks, backward-compatible changes |
| Patch (1.0.1) | Bug fixes, security patches |

**Flag as WARNING**: Breaking changes (hook removal, API changes, schema changes) without a major version bump.

---

## Dependency Declaration

WordPress 6.5 introduced the `Requires Plugins` header:

```php
/**
 * Requires Plugins: woocommerce
 */
```

This prevents activation if dependencies aren't active. However, it does not support version constraints yet.

### Add-on bootstrap pattern (wp-slimstat style)
```php
class My_Plugin_Addon {
    public static function init() {
        // Graceful degradation if core plugin not available
        if ( ! class_exists( 'Core_Plugin' ) ) {
            return true;
        }
        // Hook into core plugin's extension points
        add_filter( 'core_plugin_filter', array( __CLASS__, 'extend' ) );
    }
}

if ( function_exists( 'add_action' ) ) {
    add_action( 'plugins_loaded', array( 'My_Plugin_Addon', 'init' ), 15 );
}
```

**Key elements**:
- Dependency check via `class_exists()`
- Bootstrap on `plugins_loaded` at priority > 10 (after core loads)
- Graceful degradation (return, not die)

---

## Custom Update Mechanism Security

If the PR modifies update-related code, check:

- **HTTPS enforcement** on update check URLs
- **Response validation** — verify response code and JSON structure
- **Version comparison** before offering update
- **Package URL validation** — ensure download URL matches expected domain
- **Transient caching** — avoid excessive remote requests (48h cache typical)
- **License key handling** — keys should be sanitized and not logged

```php
// Pattern to validate
add_filter( 'pre_set_site_transient_update_plugins', function( $transient ) {
    $remote = wp_remote_get( 'https://your-server.com/info.json', array(
        'timeout' => 10,
        'headers' => array( 'Accept' => 'application/json' ),
    ) );
    if ( is_wp_error( $remote ) || 200 !== wp_remote_retrieve_response_code( $remote ) ) {
        return $transient;
    }
    // ... version comparison and update injection
} );
```
