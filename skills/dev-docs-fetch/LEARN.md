# Lessons: dev-docs-fetch

> Last updated: 2026-02-22

---

## Better Questions
- Ask which specific topics within a library the user needs (e.g., "middleware" not all of FastAPI)
- Ask if user needs code examples (mode: code) or architecture concepts (mode: info)

## Edge Cases
- Library name may differ from Context7 ID (e.g., "postgres" vs "/postgres/postgres")
- Some libraries have multiple Context7 entries — resolve-library-id may return unexpected match
- Stale cache may be better than no cache when API is down

## Workflow
- Always check cache freshness with Bash before MCP calls to save tokens
- Prefer fetching with specific topic parameter to get more relevant docs
- Re-fetch only stale/missing — never re-fetch fresh cache

## Common Mistakes
- Fetching too many libraries at once (token budget: max 3-5 per run)
- Not preserving the `created` date when re-fetching (should only update `updated`)
- Using hardcoded library names instead of reading tech.md for auto-detection
