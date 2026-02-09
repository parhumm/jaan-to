# Standards Checklist — WordPress Plugin PR Review

> Reference file for wp-pr-review skill. Loaded on demand during Step 4.

---

## Naming Conventions (WPCS)

| Item | Convention | Example |
|------|-----------|---------|
| Functions | `snake_case` | `my_plugin_get_data()` |
| Variables | `snake_case` | `$user_name` |
| Classes | `Capitalized_Words_With_Underscores` | `My_Plugin_Admin` |
| Constants | `ALL_UPPERCASE` | `MY_PLUGIN_VERSION` |
| File names | `lowercase-hyphens` | `class-my-plugin-admin.php` |
| Hooks | `snake_case` with plugin prefix | `my_plugin_after_save` |
| Options | `snake_case` with plugin prefix | `my_plugin_settings` |

**Never use camelCase** for functions or variables in WordPress code.

---

## Yoda Conditions

Constants/literals always on the LEFT of comparisons. Prevents accidental assignment.

```php
// CORRECT (Yoda)
if ( true === $value ) { }
if ( 'active' === $status ) { }
if ( null === $result ) { }

// WRONG
if ( $value === true ) { }
if ( $status === 'active' ) { }
```

---

## Array Syntax

WPCS requires long array syntax:

```php
// CORRECT
$arr = array( 1, 2, 3 );

// WRONG (per WPCS)
$arr = [ 1, 2, 3 ];
```

**Note**: Some projects intentionally suppress this rule in `phpcs.xml.dist`. Check project config before flagging.

---

## Brace and Spacing Rules

- **Braces always required**, even for single statements
- Opening brace on **same line** as control structure
- **Spaces inside parentheses** of control structures

```php
// CORRECT
if ( $condition ) {
    do_something();
}

foreach ( $items as $item ) {
    process( $item );
}

// WRONG
if ($condition)
    do_something();
```

---

## PHP Tag Rules

- Always `<?php`, never `<?` or `<?=`
- Use `elseif` not `else if` (for colon syntax compatibility)
- No `extract()` — explicitly prohibited

---

## Internationalization (i18n)

### Requirements
- Text domain **must match plugin slug** (from Plugin Name header)
- Text domain **must be a string literal** (not a variable)
- All user-facing strings must use translation functions

### Functions
| Function | Returns/Echoes | Escaping |
|----------|---------------|----------|
| `__( 'text', 'domain' )` | Returns | None |
| `_e( 'text', 'domain' )` | Echoes | None |
| `esc_html__( 'text', 'domain' )` | Returns | HTML |
| `esc_html_e( 'text', 'domain' )` | Echoes | HTML |
| `esc_attr__( 'text', 'domain' )` | Returns | Attribute |
| `esc_attr_e( 'text', 'domain' )` | Echoes | Attribute |

```php
// CORRECT
echo esc_html__( 'Settings saved.', 'my-plugin' );

// WRONG — variable text domain
$domain = 'my-plugin';
echo __( 'Settings saved.', $domain );

// WRONG — missing text domain
echo __( 'Settings saved.' );
```

---

## Prefix Requirements

All public items need a unique 4-5 character prefix to avoid collisions:

- Functions: `myplugin_get_data()`
- Classes: `Myplugin_Admin`
- Constants: `MYPLUGIN_VERSION`
- Hooks: `myplugin_after_save`
- Option names: `myplugin_settings`
- Custom post types: `myplugin_event`
- Taxonomies: `myplugin_category`
- REST route namespaces: `myplugin/v1`
- Shortcodes: `[myplugin_form]`
- Widget IDs: `myplugin_recent`

---

## WordPress API Usage (Not PHP Equivalents)

| Instead of (PHP) | Use (WordPress) | Why |
|------------------|-----------------|-----|
| `json_encode()` | `wp_json_encode()` | UTF-8 handling, error checking |
| `header('Location: ...')` | `wp_safe_redirect()` + `exit` | Open redirect prevention |
| `file_get_contents($url)` | `wp_remote_get()` | Transport layer, SSL, timeouts |
| `curl_init()` | `wp_remote_get()` / `wp_remote_post()` | Hookable, transport-agnostic |
| `mail()` | `wp_mail()` | Filterable, SMTP-compatible |
| `date()` | `wp_date()` / `current_time()` | Timezone-aware |
| `htmlspecialchars()` | `esc_html()` | WordPress-specific encoding |
| `urlencode()` | `rawurlencode()` | RFC 3986 compliance |

---

## File Structure Requirements

1. **ABSPATH guard** on every PHP file:
   ```php
   if ( ! defined( 'ABSPATH' ) ) { exit; }
   ```

2. **Proper asset enqueuing** — `wp_enqueue_script()` / `wp_enqueue_style()`, never inline `<script>` or `<link>` tags

3. **No CDN for assets** — all non-service scripts/styles must be included locally

4. **No obfuscated code** — human-readable source required; minified files must include originals

---

## Deprecated Function Detection

Common deprecated functions to flag:

| Deprecated | Replacement | Since |
|-----------|-------------|-------|
| `get_bloginfo('url')` | `home_url()` | WP 3.0 |
| `get_bloginfo('wpurl')` | `site_url()` | WP 3.0 |
| `get_currentuserinfo()` | `wp_get_current_user()` | WP 4.5 |
| `create_function()` | Anonymous functions | PHP 7.2 |
| `each()` | `foreach` | PHP 7.2 |
| `mysql_*` functions | `$wpdb` methods | WP 3.9 |
| `screen_icon()` | Removed | WP 3.8 |
