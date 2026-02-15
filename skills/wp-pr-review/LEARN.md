# Lessons: wp-pr-review

> Last updated: 2026-02-15

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to:wp-pr-review.learn.md`

Seeded from research: `$JAAN_OUTPUTS_DIR/research/67-wp-pr-review.md`

---

## Better Questions

Questions to ask during information gathering:

- Ask about the plugin's add-on ecosystem before reviewing hook changes — breaking changes to filter/action signatures affect third-party code
- Ask whether the plugin targets WordPress VIP hosting — VIP standards are stricter (no posts_per_page => -1, no file_get_contents for URLs, no front-end DB writes)
- Ask about the minimum supported PHP version — PHP 8.2 dynamic property deprecation and null parameter strictness are the most common compatibility breaks
- Ask if there are custom PHPCS rules beyond standard WordPress — some teams suppress specific sniffs intentionally

## Edge Cases

Special cases to check and handle:

- `is_admin()` used as authorization check instead of `current_user_can()` — `is_admin()` only checks request context, not user role
- `sanitize_text_field()` used for HTML attribute context — need `esc_attr()` at output point, sanitization does not equal escaping
- `wp_unslash()` missing before sanitization on superglobals — WordPress adds magic quotes, must unslash first
- REST routes registered without `permission_callback` — triggers `_doing_it_wrong` since WP 5.5, security vulnerability
- `add_option()` vs `update_option()` autoload behavior — `add_option` defaults autoload to 'yes', large data must use 'no'
- Named arguments used on WordPress core functions — WP explicitly does not support named params, param names may change
- `gh pr diff` returns HTTP 406 for PRs with 300+ changed files — fall back to `gh api repos/{owner}/{repo}/pulls/{number}/files --paginate` to get file list, then fetch patches individually
- ECONNRESET during large PR analysis — caused by network intermediaries dropping long-lived connections. Mitigate by batching file processing (30 files per batch) to reduce per-call context size

## Workflow

Process improvements:

- Run deterministic grep FIRST (Step 3) before LLM analysis — catches dangerous patterns with near-zero false negatives
- Focus review ONLY on changed files in the PR diff — never flag legacy code outside the diff
- Read `phpcs.xml.dist` early — it reveals the project's text domain and prefix, avoiding false positives on naming
- Check for `vendor/` and `node_modules/` in changed files — skip these entirely
- For PRs with 50+ PHP files, process in batches of 30 — prevents ECONNRESET from network intermediaries and keeps grep output manageable
- Fetch `gh pr view` metadata BEFORE `gh pr diff` — knowing file count early allows proactive batching instead of reactive fallback

## Common Mistakes

Things to avoid:

- Flagging formatting issues already caught by PHPCS (indentation, spacing, brace style) — these create noise
- Reporting issues in vendored or third-party code — only review project-owned files
- Using generic security advice instead of WordPress-specific functions (`htmlspecialchars` vs `esc_html`, PDO vs `$wpdb->prepare`)
- Confusing sanitization and escaping — sanitize on INPUT, escape on OUTPUT, they serve different purposes
- Flagging `array()` vs `[]` syntax without checking project's `phpcs.xml.dist` — some projects suppress this rule intentionally
- Missing the `wp_unslash()` requirement before sanitizing `$_POST`/`$_GET` — unique to WordPress due to magic quotes
