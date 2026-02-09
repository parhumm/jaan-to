# Security Checklist — WordPress Plugin PR Review

> Reference file for wp-pr-review skill. Loaded on demand during Step 3-4.

---

## Sanitization Functions

Use on INPUT (before storing/processing data):

| Function | Use For | Example |
|----------|---------|---------|
| `sanitize_text_field()` | General text — strips tags, breaks, extra whitespace | `sanitize_text_field( wp_unslash( $_POST['name'] ) )` |
| `sanitize_textarea_field()` | Multi-line text — preserves newlines | Textareas, descriptions |
| `sanitize_email()` | Email addresses | `sanitize_email( $_POST['email'] )` |
| `sanitize_file_name()` | File names — replaces whitespace, special chars | Upload handlers |
| `sanitize_key()` | Lowercase alphanumeric + dashes + underscores | Option keys, slugs |
| `sanitize_title()` | URL-safe slugs | Custom post type slugs |
| `sanitize_hex_color()` | 3/6-digit hex color with `#` | Color picker values |
| `sanitize_url()` | URLs | `sanitize_url( $_POST['website'] )` |
| `sanitize_sql_orderby()` | SQL ORDER BY clauses | Dynamic sorting |
| `absint()` | Non-negative integer | IDs, counts |
| `intval()` | Integer cast | Numeric values |
| `wp_kses()` | Allow only specified HTML tags/attributes | Rich text with restrictions |
| `wp_kses_post()` | Allow post-appropriate HTML | WYSIWYG editor content |

**Critical rule**: Always call `wp_unslash()` BEFORE sanitization on superglobals (`$_POST`, `$_GET`, `$_REQUEST`). WordPress adds magic quotes to all superglobals.

```php
// CORRECT
$value = sanitize_text_field( wp_unslash( $_POST['field'] ) );

// WRONG — magic quotes not removed
$value = sanitize_text_field( $_POST['field'] );
```

---

## Escaping Functions

Use on OUTPUT (at point of echo):

| Function | Context | Example |
|----------|---------|---------|
| `esc_html()` | Inside HTML elements | `<p><?php echo esc_html( $text ); ?></p>` |
| `esc_attr()` | Inside HTML attributes | `<input value="<?php echo esc_attr( $val ); ?>">` |
| `esc_url()` | In `href`, `src` URLs | `<a href="<?php echo esc_url( $link ); ?>">` |
| `esc_js()` | Inline JavaScript strings | Inline `onclick` handlers |
| `esc_textarea()` | Inside `<textarea>` | `<textarea><?php echo esc_textarea( $content ); ?></textarea>` |
| `wp_kses()` / `wp_kses_post()` | Rich HTML output | When HTML must be preserved |
| `wp_json_encode()` | PHP to JS data transfer | `wp_localize_script()` data |

**Combined translation+escaping**: `esc_html__()`, `esc_html_e()`, `esc_attr__()`, `esc_attr_e()`.

**Critical rules**:
- Escape LATE — at the point of output, not earlier
- Match escape function to output context (HTML body vs attribute vs URL vs JS)
- `sanitize_text_field()` does NOT escape quotes — still vulnerable in attributes
- Never trust data from `get_option()`, `get_post_meta()`, or any stored value

---

## Nonce Verification

Nonces verify intent, NOT identity. Always pair with `current_user_can()`.

### Form nonces
```php
// CREATE (in form)
wp_nonce_field( 'my_action', '_my_nonce' );

// VERIFY (in handler)
if ( ! isset( $_POST['_my_nonce'] ) || ! wp_verify_nonce( sanitize_text_field( wp_unslash( $_POST['_my_nonce'] ) ), 'my_action' ) ) {
    wp_die( 'Security check failed' );
}
```

### AJAX nonces
```php
// CREATE
wp_create_nonce( 'my_ajax_action' );

// VERIFY
check_ajax_referer( 'my_ajax_action', 'security' );
```

### URL nonces
```php
// CREATE
$url = wp_nonce_url( $base_url, 'my_action' );

// VERIFY
if ( ! wp_verify_nonce( sanitize_text_field( wp_unslash( $_GET['_wpnonce'] ) ), 'my_action' ) ) {
    wp_die( 'Invalid nonce' );
}
```

---

## Capability Checks

**Always use `current_user_can()` before privileged operations.**

| Capability | Who Has It | Use For |
|-----------|-----------|---------|
| `manage_options` | Administrator | Plugin settings |
| `edit_posts` | Editor, Author, Contributor | Content operations |
| `publish_posts` | Editor, Author | Publishing |
| `delete_others_posts` | Editor, Administrator | Bulk operations |
| `upload_files` | Author+ | File uploads |
| `install_plugins` | Super Admin (multisite) | Plugin management |

**CRITICAL MISTAKE**: `is_admin()` does NOT check if the user is an administrator. It only checks if the request is to an admin page (`/wp-admin/`). ALWAYS use `current_user_can()` for authorization.

```php
// VULNERABLE
if ( is_admin() ) {
    // This runs for ANY logged-in user visiting wp-admin
    delete_important_data();
}

// CORRECT
if ( current_user_can( 'manage_options' ) ) {
    delete_important_data();
}
```

---

## Database Security

**Always use `$wpdb->prepare()` with typed placeholders:**

| Placeholder | Type |
|------------|------|
| `%s` | String |
| `%d` | Integer |
| `%f` | Float |

```php
// VULNERABLE
$wpdb->get_var( "SELECT * FROM {$wpdb->prefix}items WHERE id = " . $_GET['id'] );

// CORRECT
$wpdb->get_var( $wpdb->prepare(
    "SELECT * FROM {$wpdb->prefix}items WHERE id = %d",
    absint( $_GET['id'] )
) );
```

**Prefer CRUD helpers** — they handle escaping automatically:
- `$wpdb->insert( $table, $data, $format )`
- `$wpdb->update( $table, $data, $where, $format, $where_format )`
- `$wpdb->delete( $table, $where, $where_format )`

**Never**: Pass user input directly to `$wpdb->query()`. Use `$wpdb->prefix` not hardcoded `wp_`.

---

## REST API Security

`permission_callback` is **mandatory** since WP 5.5. Routes without it trigger `_doing_it_wrong`.

```php
// VULNERABLE — no permission check
register_rest_route( 'myplugin/v1', '/data', array(
    'methods'  => 'POST',
    'callback' => 'handle_data',
) );

// ALSO VULNERABLE — __return_true bypasses auth
register_rest_route( 'myplugin/v1', '/data', array(
    'methods'             => 'POST',
    'callback'            => 'handle_data',
    'permission_callback' => '__return_true',
) );

// CORRECT
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
) );
```

---

## ABSPATH Guard

Every PHP file must include:
```php
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}
```

This prevents direct file access and is mandatory for wordpress.org plugin review.

---

## Dangerous Functions Blacklist

Flag these as CRITICAL when used with user input:

| Function | Risk |
|----------|------|
| `eval()` | Arbitrary code execution |
| `assert()` | Code execution (with string arg) |
| `create_function()` | Deprecated, eval-based |
| `extract()` | Variable injection |
| `unserialize()` | PHP Object Injection / RCE |
| `maybe_unserialize()` | Same risk as unserialize on user data |
| `shell_exec()` / `exec()` / `system()` / `passthru()` / `popen()` | OS command injection |
| `preg_replace()` with `/e` | Code execution (deprecated in PHP 7) |
| `include` / `require` with user-controlled path | Local/Remote File Inclusion |
| `file_get_contents()` for remote URLs | SSRF, no error handling, may bypass SSL |
| `header('Location: ' . $user_input)` | Open redirect |
