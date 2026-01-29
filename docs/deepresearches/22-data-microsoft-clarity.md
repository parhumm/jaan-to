# Microsoft Clarity: API, MCP, and Claude Code Skill Integration

> Research conducted: 2026-01-27

## Executive Summary

- **Official MCP server exists** (`@microsoft/clarity-mcp-server`) with 3 tools: query-analytics-dashboard, list-session-recordings, query-documentation-resources—but provides only aggregated analytics, NOT raw session/heatmap data
- **Data Export API is heavily rate-limited**: 10 requests/project/day, last 1-3 days of data only, no raw session events or heatmap coordinates available via API
- **Cookie-based workaround enables session URL extraction**: Extract `_clck` (user ID) and `_clsk` (session ID) from cookies to build playback URLs, bypassing API rate limits entirely
- **JavaScript SDK is FREE and unlimited**: `identify()`, `set()`, `event()`, `consent()`, `upgrade()` functions require no separate API key and work across web + mobile platforms
- **Oct 2025 consent mandate** requires explicit consent signals for EEA/UK/Switzerland traffic—implement now or lose data

## Background & Context

Microsoft Clarity is a free behavioral analytics platform offering session recordings, heatmaps (click, scroll, movement, attention), and AI-powered insights via Copilot. It competes with Hotjar, FullStory, and LogRocket but differentiates through zero cost (100,000 sessions/day free), native AI integration, and built-in consent compliance.

For developers building Claude Code skills that analyze user behavior, Clarity presents a unique challenge: while the platform captures rich interaction data, programmatic access is severely limited. The official Data Export API restricts access to 10 requests per day with only aggregated dashboard metrics—no raw session events, heatmap coordinates, or individual recording data.

This research maps the complete Clarity API landscape, identifies viable workarounds for skill development, and provides implementation patterns for integrating Clarity data into Claude Code workflows via MCP servers and hybrid skill architectures.

## Key Findings

### 1. Official Microsoft Clarity MCP Server

Microsoft provides an official MCP server package: `@microsoft/clarity-mcp-server`

**Installation:**
```bash
npm install -g @microsoft/clarity-mcp-server
```

**Configuration (claude_desktop_config.json):**
```json
{
  "mcpServers": {
    "clarity": {
      "command": "npx",
      "args": ["@microsoft/clarity-mcp-server", "--clarity_api_token=YOUR_TOKEN"],
      "env": {
        "CLARITY_API_TOKEN": "${CLARITY_API_TOKEN}"
      }
    }
  }
}
```

**Available Tools:**

| Tool | Purpose | Rate Limit |
|------|---------|------------|
| `query-analytics-dashboard` | Natural language analytics queries | 10/day |
| `list-session-recordings` | Filter recordings by device, browser, OS, country | 10/day |
| `query-documentation-resources` | Access Clarity docs | Unlimited |

**Critical Limitation:** The MCP server queries the Data Export API, inheriting its 10 req/day limit. It provides aggregated metrics only—NOT individual session data, heatmap coordinates, or raw event streams.

### 2. Data Export REST API

**Endpoint:** `GET https://www.clarity.ms/export-data/api/v1/project-live-insights`

**Authentication:** Bearer token (generate via Settings → Data Export → Generate API token)

**Example Request:**
```bash
curl --location 'https://www.clarity.ms/export-data/api/v1/project-live-insights?numOfDays=1&dimension1=OS' \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer YOUR_TOKEN'
```

**Available Metrics:**
- Traffic, sessions, users
- Scroll depth, engagement time
- Dead clicks, rage clicks, excessive scrolling
- Script errors, quick backs

**Available Dimensions (max 3):**
- Browser, Device, Country, OS
- Source, Medium, Campaign, Channel, URL

**Rate Limits:**
- 10 requests per project per day
- Data range: Last 1-3 days only
- No historical data access

### 3. Cookie-Based Session URL Extraction (Workaround)

Since no API exists for individual session data, extract session IDs from browser cookies:

**Cookie Format:**
- `_clck`: `{USER_ID}|{additional_data}` (1-year persistence)
- `_clsk`: `{SESSION_ID}|{additional_data}` (1-day persistence)

**Extraction JavaScript:**
```javascript
// Extract IDs from cookies
var userID = document.cookie.split('_clck=')[1]?.split('|')[0];
var sessionID = document.cookie.split('_clsk=')[1]?.split('|')[0];
var projectID = 'your-project-id'; // from Clarity dashboard

// Construct playback URL
var playbackURL = `https://clarity.microsoft.com/player/${projectID}/${userID}/${sessionID}`;
```

**Advantages:**
- Bypasses 10 req/day API limit entirely
- Works for any session with recordings enabled
- Can integrate with GTM/dataLayer for automatic capture

**Limitations:**
- Client-side only (requires browser access)
- URLs expire after 30 days (13 months if manually favorited)
- Cookieless sessions capture single-page recordings only

### 4. JavaScript Client SDK (Free & Unlimited)

All client APIs are free with no rate limits:

| Function | Parameters | Use Case |
|----------|------------|----------|
| `clarity("consent", signal)` | "YES" or "NO" | GDPR/consent handling |
| `clarity("identify", customId, sessionId, pageId, friendlyName)` | Custom ID required | User tracking, omnichannel |
| `clarity("set", key, value)` | key: string, value: string/array | Custom tags/attributes |
| `clarity("event", name)` | Event name string | Custom event tracking |
| `clarity("upgrade", reason)` | Upgrade reason string | Session prioritization |

**GTM Integration Example:**
```javascript
// Sync dataLayer events to Clarity
window.dataLayer.push({
  'event': 'purchase',
  'value': 129.99
});

// Forward to Clarity
window.clarity("set", "last_purchase_value", "129.99");
window.clarity("event", "purchase");
```

### 5. Smart Events & Funnels (No-Code)

**9 Auto-Detected Smart Event Types:**
1. Purchase
2. Add to Cart
3. Begin Checkout
4. Contact Us
5. Submit Form
6. Request Quote
7. Sign Up
8. Login
9. Download

Smart Events apply retroactively to historical sessions—no code deployment required.

**Funnel Tracking:**
- Drag-and-drop funnel builder
- Calculates conversion rates, drop-off stages
- Links directly to heatmaps for UX analysis

### 6. Heatmap Data Access

**Available Export Formats:**
- CSV (metadata only, not coordinates)
- PNG (visual export)

**Data Architecture:**
- Clarity tracks interactions as DOM-element coordinates, not pure X/Y pixels
- Click data stored as: `{element_selector, x_offset_in_element, y_offset_in_element}`
- Makes heatmaps responsive to layout changes

**Critical Gap:** No programmatic access to raw heatmap coordinate data. The `clarity-decode` server-side implementation is proprietary.

### 7. Consent Management (Oct 2025 Deadline)

**Who's Affected:** Any traffic from EEA, UK, or Switzerland

**Two Consent Signals:**

| Signal | Effect When Granted | Effect When Denied |
|--------|--------------------|--------------------|
| `analytics_storage` | All Clarity features | Cookieless tracking only |
| `ad_storage` | Data shared with Microsoft Ads | No remarketing data |

**Implementation:**
```javascript
// Direct Clarity API
window.clarity("consent", userHasConsented ? "YES" : "NO");

// Or via Google Consent Mode V2 (auto-read by Clarity)
gtag.config({
  'analytics_storage': 'granted',
  'ad_storage': 'granted'
});
```

**Cookie Behavior:** When consent is denied, existing Clarity cookies are immediately deleted.

## Recent Developments (2024-2025)

- **Oct 2025 Consent Mandate:** EEA/UK/Switzerland traffic now requires explicit consent signals
- **Copilot in Clarity:** AI-powered session summaries and heatmap insights
- **Brand Agents:** Automated customer service agents integrated with Clarity recordings
- **Bot Activity Detection:** Built-in filtering for bot traffic
- **Data Export API Launch:** REST API for dashboard metrics (with 10/day limit)
- **Official MCP Server:** `@microsoft/clarity-mcp-server` released for Claude integration
- **Mobile SDKs:** React Native, Flutter, iOS, Android support with unified Identify API

## Best Practices & Recommendations

1. **Use DataLayer-First Architecture:** Define all tracking in `window.dataLayer`—both GA4 and Clarity consume from the same source, reducing duplicate instrumentation

2. **Implement Session URL Extraction:** Capture session IDs client-side for high-volume access; reserve 10 API calls/day for compliance audits or data dumps

3. **Enforce Consent Before Oct 2025:** Implement `window.clarity("consent", signal)` in your CMP; test with EEA traffic to verify enforcement

4. **Leverage Smart Events:** Start with auto-detected events (Purchase, Add to Cart); add custom events only if gaps remain

5. **Cache Aggressively for MCP:** Use 7-day TTL for rate-limited API data; implement file-based persistent cache in `.jaan-to/cache/analytics/`

## MCP Server Implementation Pattern

For building custom analytics MCP servers:

**Three-Tool Architecture:**
```typescript
// 1. Query tool (rate-limited)
server.registerTool("query_metrics", {
  description: "Query dashboard analytics",
  inputSchema: { metric: z.string(), startDate: z.string(), endDate: z.string() }
}, async (args) => {
  // Check cache first (7-day TTL for Clarity)
  const cached = checkCache(`clarity-${args.metric}-${args.startDate}`);
  if (cached) return cached;

  // Respect 10/day limit
  if (dailyRequestCount >= 10) {
    return { content: [{ type: "text", text: `Rate limit: 10/day. Using cached data.` }] };
  }

  // Fetch and cache
  const data = await clarityApi.getMetrics(args);
  saveCache(cacheKey, data, "7days");
  return { content: [{ type: "text", text: formatData(data) }] };
});

// 2. List tool (metadata)
server.registerTool("list_sessions", { ... });

// 3. Docs tool (reference)
server.registerTool("docs", { ... });
```

**Authentication Pattern:**
```json
{
  "env": {
    "CLARITY_API_TOKEN": "${CLARITY_API_TOKEN}",
    "CLARITY_PROJECT_ID": "${CLARITY_PROJECT_ID}"
  }
}
```

## Skill Architecture for Clarity Integration

**Recommended Hybrid Approach:**

```yaml
---
name: data-clarity-analyze
description: |
  Analyze Microsoft Clarity heatmap and session data for UX insights.
  Auto-triggers on: clarity analysis, heatmap review, session patterns
allowed-tools: Read, Glob, Grep, Write(.jaan-to/**), Bash(python:*)
argument-hint: [csv-path-or-session-url]
---
```

**Phase 1 (Analysis):**
1. Detect data source (MCP available? CSV export? Session URL?)
2. Ask clarifying questions (time period? segments? decision this informs?)
3. Plan analysis scope

**HARD STOP:** Confirm analysis plan with user

**Phase 2 (Generation):**
1. Process data (parse CSV, query MCP, analyze screenshots)
2. Generate insights with evidence
3. Write report to `.jaan-to/outputs/data/clarity/`

## Comparisons

| Aspect | Microsoft Clarity | Hotjar | FullStory |
|--------|------------------|--------|-----------|
| **Cost** | Free (100K sessions/day) | $39-169/mo | $500+/mo |
| **Session Recordings** | Yes | Yes | Yes |
| **Heatmaps** | Click, scroll, movement | Click, scroll | Click, scroll |
| **Data Export API** | 10/day (limited) | Unlimited (paid) | Unlimited (enterprise) |
| **Raw Coordinate Access** | No | CSV (Business+) | Full API |
| **AI/Copilot** | Yes | No | No |
| **Mobile SDKs** | RN, Flutter, iOS, Android | Browser only | Browser + iOS |
| **Consent Compliance** | Oct 2025 mandate | Yes | Yes |
| **MCP Server** | Official | Community | None |

## Open Questions

- **Enterprise Rate Limits:** No public documentation on higher limits for enterprise tier—requires direct sales contact
- **Session URL Stability:** Cookie-based extraction works but no official SLA on URL permanence
- **Smart Events Limit:** Maximum 20 custom Smart Events per project—unclear if enterprise increases this
- **Heatmap CSV Format:** Column names and coordinate formats not publicly documented

## Sources

### Primary (Official Microsoft)
1. [Microsoft Clarity Documentation Hub](https://learn.microsoft.com/en-us/clarity/) - Complete platform overview
2. [Clarity Client API Reference](https://learn.microsoft.com/en-us/clarity/clarity-api) - JavaScript SDK functions
3. [Data Export API](https://learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-data-export-api) - REST API specification
4. [Consent Management](https://learn.microsoft.com/en-us/clarity/setup-and-installation/consent-management) - Oct 2025 requirements
5. [Smart Events Framework](https://learn.microsoft.com/en-us/clarity/setup-and-installation/smart-events) - No-code event tracking
6. [Funnels & Conversion Tracking](https://learn.microsoft.com/en-us/clarity/setup-and-installation/funnels) - Funnel analytics

### Secondary (Implementation)
7. [Microsoft Clarity MCP Server](https://github.com/microsoft/clarity-mcp-server) - Official MCP implementation
8. [Clarity GitHub Repository](https://github.com/microsoft/clarity) - Open-source client SDK
9. [GTM Microsoft Clarity Utility](https://github.com/Jude-Nwachukwu/gtm-microsoft-clarity-utility) - Session URL extraction
10. [Session Playback URL Guide](https://dumbdata.co/post/how-to-get-the-microsoft-clarity-session-recording-playback-url-with-without-gtm/) - Cookie extraction method

### Tertiary (Patterns)
11. [Model Context Protocol Docs](https://modelcontextprotocol.io/) - MCP server implementation patterns
12. [Clarity Blog](https://clarity.microsoft.com/blog/) - Feature announcements and tutorials

## Research Metadata

- **Date Researched:** 2026-01-27
- **Category:** data (analytics, tracking, MCP integration)
- **Research Method:** Adaptive 5-wave approach (Scout → Gaps → Expand → Verify → Deep)
- **Sources Consulted:** ~65 unique sources across 5 waves
- **Search Queries Used:**
  - Microsoft Clarity API documentation endpoints
  - Clarity Data Export API rate limit official
  - Microsoft Clarity MCP server npm package
  - Clarity session recording playback URL format
  - Clarity JavaScript SDK identify set event functions
  - MCP server TypeScript implementation patterns
  - Claude Code skill architecture analytics integration
  - Microsoft Clarity Google Analytics 4 integration
  - Clarity consent management Oct 2025 deadline
  - Clarity heatmap CSV export data format
