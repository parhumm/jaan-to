# Performance Checklist — WordPress Plugin PR Review

> Reference file for wp-pr-review skill. Loaded on demand during Step 4.

---

## N+1 Query Problem

The most common performance killer. Queries inside loops multiply database calls.

```php
// BAD — separate query per post
$posts = get_posts( array( 'numberposts' => 50 ) );
foreach ( $posts as $post ) {
    $meta = get_post_meta( $post->ID, 'custom_field', true ); // Query each iteration
}

// GOOD — WP_Query with meta cache priming
$query = new WP_Query( array(
    'posts_per_page'         => 50,
    'update_post_meta_cache' => true,
    'update_post_term_cache' => true,
) );
```

**Detection**: Look for `get_post_meta()`, `get_user_meta()`, `get_term_meta()`, `$wpdb->get_*()` calls inside `foreach`, `while`, or `for` loops.

---

## Unbounded Queries

Never use `posts_per_page => -1` or `nopaging => true`. Always set explicit limits.

```php
// BAD
$all = get_posts( array( 'posts_per_page' => -1 ) );

// GOOD
$batch = get_posts( array( 'posts_per_page' => 100 ) );
```

Also flag `$wpdb->get_results()` without `LIMIT` clause in the SQL.

---

## Autoloaded Options Bloat

The `autoload` column in `wp_options` determines what loads into memory on EVERY page request. Total autoloaded data should stay under 800KB-1MB.

```php
// BAD — large data autoloaded (autoload defaults to 'yes')
update_option( 'myplugin_large_cache', $huge_array );

// GOOD — explicitly disable autoload for non-critical/large data
update_option( 'myplugin_large_cache', $huge_array, false );
```

**When to autoload**: Small config arrays, feature flags, settings the plugin checks on every request.
**When NOT to autoload**: Cached data, logs, large serialized arrays, data only used in admin.

---

## Assets Loaded Globally

Scripts and styles enqueued on every page instead of conditionally.

```php
// BAD — loads on every admin page
add_action( 'admin_enqueue_scripts', function() {
    wp_enqueue_style( 'myplugin-admin', plugins_url( 'css/admin.css', __FILE__ ) );
} );

// GOOD — load only on the plugin's admin page
add_action( 'admin_enqueue_scripts', function( $hook ) {
    if ( 'toplevel_page_myplugin' !== $hook ) {
        return;
    }
    wp_enqueue_style( 'myplugin-admin', plugins_url( 'css/admin.css', __FILE__ ) );
} );
```

**Frontend assets**: Use `wp_enqueue_scripts` with conditional checks (is shortcode present? is specific page?).

---

## Cron Anti-Patterns

### Duplicate scheduling
```php
// BAD — registers duplicate event on every page load
wp_schedule_event( time(), 'daily', 'myplugin_cron' );

// GOOD — check first
if ( ! wp_next_scheduled( 'myplugin_cron' ) ) {
    wp_schedule_event( time(), 'daily', 'myplugin_cron' );
}
```

### Missing cleanup on deactivation
```php
// REQUIRED
register_activation_hook( __FILE__, function() {
    if ( ! wp_next_scheduled( 'myplugin_cron' ) ) {
        wp_schedule_event( time(), 'daily', 'myplugin_cron' );
    }
} );
register_deactivation_hook( __FILE__, function() {
    wp_clear_scheduled_hook( 'myplugin_cron' );
} );
```

---

## WP_Query Optimization Flags

| Flag | Purpose | When to Use |
|------|---------|-------------|
| `'no_found_rows' => true` | Skip `SQL_CALC_FOUND_ROWS` (pagination count) | When you don't need total count |
| `'update_post_meta_cache' => false` | Skip meta cache priming | When you don't need post meta |
| `'update_post_term_cache' => false` | Skip term cache priming | When you don't need terms |
| `'fields' => 'ids'` | Return only IDs, not full objects | When you only need post IDs |

---

## WordPress VIP Restrictions

Stricter performance rules for VIP-hosted sites:

- `posts_per_page => -1` is **prohibited**
- `post__not_in` triggers a **warning** — poor performance at scale
- `file_get_contents()` for remote URLs is **banned** — use `vip_safe_wp_remote_get()`
- Front-end database writes are **prohibited** — bypassed by page cache
- Individual cache objects must stay **under 1 MB**
- `switch_to_blog()` is **restricted** — performance implications on multisite

---

## Transient Usage

Use transients to cache expensive operations:

```php
// GOOD — cache expensive query
$data = get_transient( 'myplugin_expensive_data' );
if ( false === $data ) {
    $data = expensive_computation();
    set_transient( 'myplugin_expensive_data', $data, HOUR_IN_SECONDS );
}
```

**Flag**: Expensive operations (API calls, complex queries) without any caching mechanism.
