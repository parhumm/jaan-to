> Reference: [54-roles-wp-details.md](../../jaan-to/outputs/research/54-roles-wp-details.md) — WordPress Plugin Development: Complete Role-Based Skills Guide

    /jaan-to-wp-pm-problem-brief
	•	Logical: wp-pm:problem-brief
	•	Description: WP-specific problem statement + target user + scope boundaries (admin/front/editor, multisite, roles) + measurable outcomes
	•	Quick Win: Yes
	•	Key Points:
	•	Define the “WP surface” (wp-admin vs frontend vs block editor) and where value is delivered
	•	Identify collision/interop risks early (names, hooks, assets, settings)
	•	Capture constraints that affect feasibility (capabilities, network mode, uninstall expectations)
	•	→ Next: wp-org-guideline-scan
	•	MCP Required: None
	•	Input: [audience] [pain] [surface]
	•	Output: jaan-to/outputs/wp/pm/{slug}/problem-brief.md

⸻

/jaan-to-wp-org-guideline-scan
	•	Logical: wp-org:guideline-scan
	•	Description: WordPress.org directory compliance scan + risk notes + “must change” checklist
	•	Quick Win: Yes
	•	Key Points:
	•	Validate directory-fit and disclosure requirements before building distribution assumptions
	•	Flag common rejection triggers and required policy items
	•	Produce a remediation checklist mapped to guidelines
	•	→ Next: wp-pm-slug-textdomain
	•	MCP Required: None
	•	Input: [plugin-idea] [distribution-model]
	•	Output: jaan-to/outputs/wp/org/{slug}/guideline-scan.md
	•	Reference: Detailed Plugin Guidelines (WordPress.org)  ￼

⸻

/jaan-to-wp-pm-slug-textdomain
	•	Logical: wp-pm:slug-textdomain
	•	Description: Naming, slug, prefix + text-domain plan (translation-ready + directory compatibility)
	•	Quick Win: Yes
	•	Key Points:
	•	Ensure slug/text-domain alignment for portability and WordPress.org expectations
	•	Define a consistent prefix strategy to avoid naming collisions
	•	Document stable identifiers (option keys, hook prefixes, asset handles)
	•	→ Next: wp-dev-architecture-map
	•	MCP Required: None
	•	Input: [plugin-name]
	•	Output: jaan-to/outputs/wp/pm/{slug}/naming-and-textdomain.md
	•	Reference: Internationalization: text domains must match slug  ￼

⸻

/jaan-to-wp-dev-architecture-map
	•	Logical: wp-dev:architecture-map
	•	Description: Plugin structure plan (modules, responsibilities, boundaries) + interop conventions
	•	Quick Win: Yes
	•	Key Points:
	•	Design around WordPress APIs and extension points (actions/filters)
	•	Prevent collisions (prefixing, avoiding globals, safe handles)
	•	Keep admin/front/integrations separated to reduce regressions
	•	→ Next: wp-hooks-feature-hook-map
	•	MCP Required: None
	•	Input: [plugin-type] [features]
	•	Output: jaan-to/outputs/wp/dev/{slug}/architecture-map.md
	•	Reference: Plugin best practices (interop + naming collisions)  ￼

⸻

/jaan-to-wp-hooks-feature-hook-map
	•	Logical: wp-hooks:feature-hook-map
	•	Description: Hook map per feature (core hooks, execution timing, arguments, side effects) + compatibility notes
	•	Quick Win: Yes
	•	Key Points:
	•	Use actions/filters as primary integration mechanism (WP way)
	•	Document hook timing + risks (performance, recursion, priority conflicts)
	•	Define where you expose your own extension hooks (public API)
	•	→ Next: wp-data-storage-decision
	•	MCP Required: None
	•	Input: [feature]
	•	Output: jaan-to/outputs/wp/dev/{slug}/hooks/{feature}/hook-map.md
	•	Reference: REST routes/args validation pattern is analogous for “explicit contracts” mindset  ￼

⸻

/jaan-to-wp-data-storage-decision
	•	Logical: wp-data:storage-decision
	•	Description: Storage strategy per entity (options vs meta vs custom tables) + multisite scope + retention policy
	•	Quick Win: Yes
	•	Key Points:
	•	Pick the smallest viable persistence layer (avoid tables unless justified)
	•	Define network-wide vs per-site behavior up front
	•	Include migration triggers and “uninstall cleanup” stance
	•	→ Next: wp-settings-settings-api-plan
	•	MCP Required: None
	•	Input: [entities] [multisite-mode]
	•	Output: jaan-to/outputs/wp/dev/{slug}/data/storage-decision.md
	•	Reference: Plugin uninstall expectations (cleanup belongs in uninstall, not deactivation)  ￼

⸻

/jaan-to-wp-settings-settings-api-plan
	•	Logical: wp-settings:settings-api-plan
	•	Description: Settings design (sections/fields, defaults) + validation/sanitization responsibilities + admin UX notes
	•	Quick Win: Yes
	•	Key Points:
	•	Validate early; sanitize consistently; reject invalid states
	•	Define defaults and “safe” initial configuration (reduces support load)
	•	Document capability gating for settings screens
	•	→ Next: wp-admin-menu-ia
	•	MCP Required: None
	•	Input: [settings]
	•	Output: jaan-to/outputs/wp/dev/{slug}/settings/settings-api-plan.md
	•	Reference: Data validation principles  ￼

⸻

/jaan-to-wp-dev-uninstall-policy
	•	Logical: wp-dev:uninstall-policy
	•	Description: Uninstall behavior specification (what is removed, what is retained, user choice) + safety checklist
	•	Quick Win: Yes
	•	Key Points:
	•	Separate deactivate vs uninstall responsibilities
	•	Require explicit policy for deleting user data
	•	Include safeguards against direct access
	•	→ Next: wp-sec-nonce-plan
	•	MCP Required: None
	•	Input: [data-types] [retain-or-remove]
	•	Output: jaan-to/outputs/wp/dev/{slug}/lifecycle/uninstall-policy.md
	•	Reference: Uninstall methods guidance  ￼

⸻

/jaan-to-wp-admin-menu-ia
	•	Logical: wp-admin:menu-ia
	•	Description: Admin information architecture (menus/pages) + capability model + navigation clarity
	•	Quick Win: Yes
	•	Key Points:
	•	Minimize admin clutter; place items where users expect
	•	Define capability requirements per page/action
	•	Plan notices (errors/warnings/success) as part of UX
	•	→ Next: wp-assets-enqueue-plan
	•	MCP Required: None
	•	Input: [pages] [capability]
	•	Output: jaan-to/outputs/wp/admin/{slug}/menu-ia.md

⸻

/jaan-to-wp-assets-enqueue-plan
	•	Logical: wp-assets:enqueue-plan
	•	Description: Asset loading map (admin vs frontend vs editor) + dependencies + conditional loading + versioning rules
	•	Quick Win: Yes
	•	Key Points:
	•	Conditional loading prevents global slowdowns
	•	Dependencies and load strategy should be explicit (avoid conflicts)
	•	Separate editor assets from frontend assets
	•	→ Next: wp-rest-endpoint-spec
	•	MCP Required: None
	•	Input: [scripts] [styles] [surfaces]
	•	Output: jaan-to/outputs/wp/dev/{slug}/assets/enqueue-plan.md
	•	Reference: wp_enqueue_script() behavior and loading strategy  ￼

⸻

/jaan-to-wp-block-block-json-spec
	•	Logical: wp-block:block-json-spec
	•	Description: Block definition spec (metadata, attributes, render strategy, surfaces) using block.json conventions
	•	Quick Win: No
	•	Key Points:
	•	Treat block.json as the single source of truth for block registration metadata
	•	Define attributes schema + defaults to avoid editor/front mismatch
	•	Decide dynamic vs static rendering approach as an explicit contract
	•	→ Next: wp-assets-enqueue-plan
	•	MCP Required: None
	•	Input: [block]
	•	Output: jaan-to/outputs/wp/blocks/{slug}/{block}/block-spec.md
	•	Reference: Block Editor block.json fundamentals  ￼

⸻

/jaan-to-wp-rest-endpoint-spec
	•	Logical: wp-rest:endpoint-spec
	•	Description: REST routes spec (namespace, methods, args schema, validation/sanitization, permission model) + error contract
	•	Quick Win: Yes
	•	Key Points:
	•	Every endpoint must define a permission strategy (public vs authenticated)
	•	Args should include validation + sanitization callbacks for predictable behavior
	•	Document responses and errors as a stable contract for consumers
	•	→ Next: wp-sec-capability-map
	•	MCP Required: None
	•	Input: [routes]
	•	Output: jaan-to/outputs/wp/dev/{slug}/rest/endpoints.md
	•	Reference: Adding custom REST endpoints (permissions + args schema)  ￼

⸻

/jaan-to-wp-sec-capability-map
	•	Logical: wp-sec:capability-map
	•	Description: Authorization matrix (who can do what) across admin actions, AJAX, REST, and destructive operations
	•	Quick Win: Yes
	•	Key Points:
	•	Prefer capability checks over role checks
	•	Use meta-capabilities where object context matters
	•	Align capability requirements with admin UX (hide vs disable vs error)
	•	→ Next: wp-sec-nonce-plan
	•	MCP Required: None
	•	Input: [features]
	•	Output: jaan-to/outputs/wp/security/{slug}/capability-map.md
	•	Reference: current_user_can() capability checks  ￼

⸻

/jaan-to-wp-sec-nonce-plan
	•	Logical: wp-sec:nonce-plan
	•	Description: Nonce strategy for forms/links/AJAX + lifecycle notes + guest considerations
	•	Quick Win: Yes
	•	Key Points:
	•	Use nonces for state-changing actions (CSRF protection)
	•	Document where nonces live (hidden fields, localized data, URLs)
	•	Note session sensitivity and validity caveats
	•	→ Next: wp-sec-escaping-checklist
	•	MCP Required: None
	•	Input: [surfaces]
	•	Output: jaan-to/outputs/wp/security/{slug}/nonce-plan.md
	•	Reference: Nonces guidance  ￼

⸻

/jaan-to-wp-sec-escaping-checklist
	•	Logical: wp-sec:escaping-checklist
	•	Description: Output-escaping checklist by UI context (HTML/attr/URL) + safe rendering rules
	•	Quick Win: Yes
	•	Key Points:
	•	Escape on output (late), validate/sanitize on input (early)
	•	Use context-appropriate escaping rules per surface
	•	Document any “trusted output” exceptions explicitly
	•	→ Next: wp-sec-db-safety-plan
	•	MCP Required: None
	•	Input: [screens]
	•	Output: jaan-to/outputs/wp/security/{slug}/escaping-checklist.md
	•	Reference: Escaping data guidance  ￼

⸻

/jaan-to-wp-sec-db-safety-plan
	•	Logical: wp-sec:db-safety-plan
	•	Description: Database safety plan (core APIs first, prepared queries when needed) + query risk review checklist
	•	Quick Win: Yes
	•	Key Points:
	•	Prefer WordPress APIs; use prepared queries for custom SQL
	•	Enforce placeholder discipline for safe SQL
	•	Include performance notes (indexes, query frequency, caching opportunities)
	•	→ Next: wp-perf-transients-cache-plan
	•	MCP Required: None
	•	Input: [queries]
	•	Output: jaan-to/outputs/wp/security/{slug}/db-safety-plan.md
	•	Reference: wpdb::prepare() safe query preparation rules  ￼

⸻

/jaan-to-wp-perf-transients-cache-plan
	•	Logical: wp-perf:cache-plan
	•	Description: Caching plan using Transients (what to cache, TTLs, invalidation triggers, fallbacks)
	•	Quick Win: Yes
	•	Key Points:
	•	Cache expensive computations and external calls with explicit invalidation
	•	Document TTL rationale and “stale acceptable?” decisions
	•	Ensure cache keys follow namespace strategy to prevent collisions
	•	→ Next: wp-cron-job-plan
	•	MCP Required: None
	•	Input: [features]
	•	Output: jaan-to/outputs/wp/perf/{slug}/transients-cache-plan.md
	•	Reference: Transients API overview  ￼

⸻

/jaan-to-wp-cron-job-plan
	•	Logical: wp-cron:job-plan
	•	Description: WP-Cron job spec (schedule, duplication guards, triggers, operational caveats)
	•	Quick Win: No
	•	Key Points:
	•	Avoid scheduling duplicates; define idempotency expectations
	•	Document operational caveats (WP-Cron runs on visits; reliability assumptions)
	•	Define retry/failure behavior and observability signals
	•	→ Next: wp-qa-compat-matrix
	•	MCP Required: None
	•	Input: [job] [recurrence]
	•	Output: jaan-to/outputs/wp/dev/{slug}/cron/{job}/cron-plan.md
	•	Reference: Scheduling WP-Cron events + duplication guard guidance  ￼

⸻

/jaan-to-wp-privacy-eraser-exporter-plan
	•	Logical: wp-privacy:eraser-exporter-plan
	•	Description: Personal data handling plan (inventory, export/erase integration, retention stance) for GDPR-style workflows
	•	Quick Win: No
	•	Key Points:
	•	Inventory personal data (where stored, why, retention, third-parties)
	•	Add erase/export support when plugin stores personal data
	•	Document what cannot be erased automatically (third-party systems) and user messaging
	•	→ Next: wp-org-readme-draft
	•	MCP Required: None
	•	Input: [data-stores]
	•	Output: jaan-to/outputs/wp/privacy/{slug}/personal-data-tools-plan.md
	•	Reference: Adding the Personal Data Eraser to your plugin  ￼

⸻

/jaan-to-wp-qa-compat-matrix
	•	Logical: wp-qa:compat-matrix
	•	Description: Compatibility & test target matrix (WP/PHP versions, multisite mode, key themes/plugins) + smoke test checklist
	•	Quick Win: Yes
	•	Key Points:
	•	Define minimum supported WP/PHP and justify based on hosting reality
	•	Identify “must test” integrations (cache plugins, security plugins, block themes if relevant)
	•	Include install/activate/settings/uninstall smoke flows
	•	→ Next: wp-release-coding-standards
	•	MCP Required: None
	•	Input: [wp] [php] [targets]
	•	Output: jaan-to/outputs/wp/qa/{slug}/compat-matrix.md

⸻

/jaan-to-wp-release-coding-standards
	•	Logical: wp-release:coding-standards
	•	Description: Coding standards checklist + review readiness notes (consistency, maintainability expectations)
	•	Quick Win: Yes
	•	Key Points:
	•	Adopt WordPress Coding Standards as a baseline for reviews
	•	Define formatting/documentation expectations to reduce future maintenance cost
	•	Capture “no-go” anti-patterns that frequently cause issues
	•	→ Next: wp-org-readme-draft
	•	MCP Required: None
	•	Input: [repo]
	•	Output: jaan-to/outputs/wp/release/{slug}/coding-standards.md
	•	Reference: WordPress Coding Standards handbook  ￼

⸻

/jaan-to-wp-org-readme-draft
	•	Logical: wp-org:readme-draft
	•	Description: WordPress.org readme.txt content plan (sections, FAQs, screenshots mapping, changelog discipline)
	•	Quick Win: Yes
	•	Key Points:
	•	Follow the directory readme standard so listing renders correctly
	•	Use clear upgrade notes and changelog entries to reduce support burden
	•	Map screenshots to features users actually need to understand
	•	→ Next: wp-org-assets-plan
	•	MCP Required: None
	•	Input: [slug]
	•	Output: jaan-to/outputs/wp/org/{slug}/readme-draft.md
	•	Reference: How readme.txt works in the plugin directory  ￼

⸻

/jaan-to-wp-org-assets-plan
	•	Logical: wp-org:assets-plan
	•	Description: WordPress.org assets checklist (icons, banners, screenshots) + naming + placement rules
	•	Quick Win: Yes
	•	Key Points:
	•	Use the top-level /assets directory in SVN (not inside trunk/tags)
	•	Define which screens to capture for screenshots (aligned with UX and features)
	•	Keep assets consistent with branding and avoid outdated UI
	•	→ Next: wp-org-svn-release-plan
	•	MCP Required: None
	•	Input: [slug]
	•	Output: jaan-to/outputs/wp/org/{slug}/assets-plan.md
	•	Reference: How plugin assets work in WordPress.org SVN  ￼

⸻

/jaan-to-wp-org-svn-release-plan
	•	Logical: wp-org:svn-release-plan
	•	Description: Release flow for WordPress.org SVN (trunk/tags discipline, packaging expectations, version alignment)
	•	Quick Win: No
	•	Key Points:
	•	Keep main plugin file in trunk root to avoid download issues
	•	Tag releases consistently; align stable tag expectations with release notes
	•	Document the repeatable release checklist (preflight → tag → verify listing)
	•	→ Next: wp-support-triage-rules
	•	MCP Required: None
	•	Input: [version]
	•	Output: jaan-to/outputs/wp/org/{slug}/svn-release-plan.md
	•	Reference: Using Subversion for WordPress.org plugins  ￼

⸻

/jaan-to-wp-support-triage-rules
	•	Logical: wp-support:triage-rules
	•	Description: Support triage rubric (severity, reproduction requirements, conflict isolation, hotfix policy)
	•	Quick Win: Yes
	•	Key Points:
	•	Require repro steps + environment info (WP/PHP + active plugins/theme)
	•	Separate “bug” vs “conflict” vs “feature request” with clear routing
	•	Define hotfix triggers and communication expectations (changelog + notices)
	•	→ Next: wp-pm-problem-brief
	•	MCP Required: None
	•	Input: [reports]
	•	Output: jaan-to/outputs/wp/support/{slug}/triage-rules.md
	•	Reference: Plugin Handbook (general best practices + interoperability mindset)  ￼