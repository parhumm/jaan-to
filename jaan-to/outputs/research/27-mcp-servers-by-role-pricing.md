# MCP Servers for Product Operations Roles: Complete Guide with Pricing

> MCP server recommendations by role with pricing, capabilities, and implementation priorities.
> Source: Local file (mcp_servers_by_role_report.md)
> Added: 2026-01-27

---

## Executive Summary

This report maps the most useful Model Context Protocol (MCP) servers to each of the six key product operations roles, aligned with the 60 highest-leverage tasks identified in the previous research. MCP servers enable AI assistants to securely connect to external tools, databases, and services through a standardized protocol—essentially acting as "USB-C for AI."

**Key Finding:** Most high-value MCP servers fall into three categories:
1. **Official/Vendor MCP servers** (free with product subscription)
2. **Open-source community servers** (free, self-hosted)
3. **Enterprise gateway services** (paid, managed hosting)

---

## Table of Contents
1. [PM / Product Owner MCP Servers](#1-pm--product-owner-mcp-servers)
2. [Software Engineer MCP Servers](#2-software-engineer-mcp-servers)
3. [UX / Product Design MCP Servers](#3-ux--product-design-mcp-servers)
4. [QA / Test Engineer MCP Servers](#4-qa--test-engineer-mcp-servers)
5. [SEO / Content Strategist MCP Servers](#5-seo--content-strategist-mcp-servers)
6. [Data / Analytics MCP Servers](#6-data--analytics-mcp-servers)
7. [Cross-Role MCP Servers](#7-cross-role-mcp-servers)
8. [Pricing Summary Matrix](#8-pricing-summary-matrix)

---

## 1. PM / Product Owner MCP Servers

### Primary Tasks Supported:
- Write PRDs and user stories
- Refine product backlog
- Synthesize customer feedback
- Prioritize features
- Analyze product metrics
- Track OKRs
- Write release notes
- Competitive analysis

| MCP Server | Provider | Pricing | Key Capabilities | Best For Tasks |
|------------|----------|---------|------------------|----------------|
| **Jira MCP** (Official) | Atlassian | **Free** with Jira subscription | Create/update issues, JQL search, sprint management, workflow transitions | Backlog refinement, story writing, release planning |
| **Linear MCP** (Official) | Linear | **Free** with Linear subscription | Issue CRUD, project management, cycle tracking, comments | Backlog refinement, story writing |
| **Notion MCP** (Official) | Notion | **Free** with Notion subscription | Create pages, search workspace, manage databases, unified search | PRD writing, documentation, OKR tracking |
| **Confluence MCP** | Atlassian | **Free** with Confluence subscription | Page creation, search, documentation management | PRD storage, release notes, competitive docs |
| **Slack MCP** (Official) | Slack | **Free** with Slack subscription | Search messages, post updates, channel management | Feedback synthesis, stakeholder comms |
| **mcp-atlassian** | Community (sooperset) | **Free** (open-source) | Combined Jira + Confluence access, Cloud + Server support | Full Atlassian workflow |
| **Productboard MCP** | Community | **Free** (open-source) | Feature prioritization, feedback collection | Prioritization, roadmap |
| **Intercom MCP** | Community | **Free** (open-source) | Customer conversation access, feedback extraction | Customer feedback synthesis |

### Recommended Stack for PMs:
```
Primary: Linear MCP (or Jira MCP) + Notion MCP + Slack MCP
Backup: mcp-atlassian for Jira/Confluence combo
```

### Setup Complexity:
- **Official servers (Linear, Notion, Slack)**: ⭐ Easy - OAuth one-click setup
- **Atlassian (Jira/Confluence)**: ⭐⭐ Medium - API token required
- **Community servers**: ⭐⭐⭐ Medium-Hard - Self-hosted, CLI config

---

## 2. Software Engineer MCP Servers

### Primary Tasks Supported:
- Write/implement code
- Review code / approve PRs
- Write unit/integration tests
- Create/update PR descriptions
- Write technical documentation
- Debug/fix bugs
- Write technical specifications
- Create ADRs

| MCP Server | Provider | Pricing | Key Capabilities | Best For Tasks |
|------------|----------|---------|------------------|----------------|
| **GitHub MCP** (Official) | GitHub | **Free** with GitHub account | Repo management, PR operations, issue tracking, code search, file operations | Code review, PR descriptions, issue management |
| **GitLab MCP** (Official) | GitLab | **Free** with GitLab (18.3+) | MR management, code review, CI/CD, project admin | Code review, merge requests |
| **Sentry MCP** (Official) | Sentry | **Free** tier available; Paid starts ~$26/mo | Error analysis, issue tracking, Seer AI integration, root cause analysis | Debugging, error monitoring |
| **Context7** | Upstash | **Free** | Up-to-date documentation for libraries | Technical documentation, coding |
| **Filesystem MCP** | Anthropic (Reference) | **Free** (open-source) | File read/write, directory operations | Local code operations |
| **Git MCP** | Anthropic (Reference) | **Free** (open-source) | Git operations, branch management | Version control |
| **gitlab-mcp-code-review** | Community | **Free** (open-source) | MR analysis, diff comparison, review comments | Code review workflows |
| **SonarCloud MCP** | Community | **Free** (open-source) | Code quality issues, PR analysis | Code quality checks |
| **Semgrep MCP** | Semgrep | **Free** for public repos; Pro from $40/dev/mo | Security scanning, custom rules | Security code review |

### Recommended Stack for Engineers:
```
Primary: GitHub MCP (or GitLab MCP) + Sentry MCP + Context7
Testing: Add Playwright MCP for automation
Security: Add Semgrep MCP for scanning
```

### Setup Complexity:
- **GitHub MCP**: ⭐ Easy - OAuth or PAT
- **GitLab MCP**: ⭐⭐ Medium - OAuth setup in 18.3+
- **Sentry MCP**: ⭐ Easy - Remote hosted with OAuth
- **Community servers**: ⭐⭐⭐ Medium-Hard - Self-hosted

---

## 3. UX / Product Design MCP Servers

### Primary Tasks Supported:
- Synthesize research findings
- Create user personas
- Write usability testing scripts
- Map customer journeys
- Maintain design system docs
- Create design specifications
- Prepare design handoff
- Competitive UX analysis

| MCP Server | Provider | Pricing | Key Capabilities | Best For Tasks |
|------------|----------|---------|------------------|----------------|
| **Figma MCP** (Official) | Figma | **Free** with Dev Mode (paid Figma plan required ~$15/seat/mo) | Design-to-code translation, component access, variables, Code Connect | Design handoff, design specs |
| **Framelink MCP for Figma** | Community (GLips) | **Free** (open-source) | Figma API access without Dev Mode, layout/styling extraction | Design handoff (free alternative) |
| **Notion MCP** | Notion | **Free** with subscription | Research documentation, persona storage, journey maps | Research synthesis, documentation |
| **Dovetail MCP** | Community | **Free** (open-source) | Research repository access, insight tagging | Research synthesis |
| **Miro MCP** | Community | **Free** (open-source) | Whiteboard access, journey mapping | Journey mapping, workshops |
| **Google Drive MCP** | Community | **Free** (open-source) | Access research files, recordings, docs | Research file access |

### Recommended Stack for UX Designers:
```
Primary: Figma MCP + Notion MCP
Research: Add Dovetail MCP if available
Alternative: Framelink MCP (free) instead of official Figma MCP
```

### Key Notes on Figma MCP:
- **Official Figma MCP** requires Dev Mode (Professional plan or higher)
- Provides structured data: component hierarchy, variables, design tokens, Code Connect mappings
- **Framelink MCP** (community) works without Dev Mode but with some limitations
- Both support Cursor, VS Code, Claude Code, Windsurf

### Setup Complexity:
- **Figma MCP (Official)**: ⭐⭐ Medium - Requires Dev Mode, local or remote server
- **Framelink MCP**: ⭐⭐ Medium - API key required
- **Notion MCP**: ⭐ Easy - OAuth

---

## 4. QA / Test Engineer MCP Servers

### Primary Tasks Supported:
- Write test cases
- Write bug reports
- Write automation scripts
- Conduct API testing
- Create test plans
- Perform regression testing
- Generate test coverage reports
- Set up test data

| MCP Server | Provider | Pricing | Key Capabilities | Best For Tasks |
|------------|----------|---------|------------------|----------------|
| **Playwright MCP** (Official) | Microsoft | **Free** (open-source) | Browser automation, accessibility tree access, test generation, screenshot capture | Test automation, E2E testing |
| **Selenium MCP** | Community | **Free** (open-source) | WebDriver automation, Chrome/Firefox support | Legacy automation |
| **Sentry MCP** | Sentry | **Free** tier; Paid from ~$26/mo | Error tracking, issue retrieval, root cause analysis | Bug investigation |
| **LambdaTest MCP** | LambdaTest | Freemium (limited); Paid from $15/mo | Cross-browser testing, SmartUI, accessibility testing | Cross-browser testing |
| **Postman MCP** | Community | **Free** (open-source) | API collection execution, environment management | API testing |
| **TestRail MCP** | Community | **Free** (open-source) | Test case management, execution tracking | Test management |
| **Cypress MCP** | Community (StudentOfJS) | **Free** (open-source) | Frontend testing, Jest integration | Frontend testing |
| **Accessibility Scanner MCP** | Community | **Free** (open-source) | Axe-core integration, WCAG compliance | Accessibility testing |

### Recommended Stack for QA:
```
Primary: Playwright MCP + Sentry MCP
API Testing: Postman MCP
Management: TestRail MCP (if using TestRail)
Cross-browser: LambdaTest MCP (paid for scale)
```

### Playwright MCP Capabilities:
- **Snapshot Mode**: Real-time accessibility tree snapshots (roles, labels, states)
- **Vision Mode**: Screenshot-based automation (when needed)
- Test generation from natural language
- Supports Chromium, Firefox, WebKit
- CI/CD integration ready

### Setup Complexity:
- **Playwright MCP**: ⭐⭐ Medium - npm install, config file
- **Selenium MCP**: ⭐⭐ Medium - WebDriver setup
- **LambdaTest MCP**: ⭐⭐ Medium - API key, cloud connection

---

## 5. SEO / Content Strategist MCP Servers

### Primary Tasks Supported:
- Create SEO content briefs
- Conduct keyword research
- Write meta titles/descriptions
- Optimize existing content
- Conduct content gap analysis
- Monitor SEO performance
- Perform technical SEO audits
- Build internal linking structure

| MCP Server | Provider | Pricing | Key Capabilities | Best For Tasks |
|------------|----------|---------|------------------|----------------|
| **Google Search Console MCP** | Community (AminForou) | **Free** (open-source) | Search analytics, URL inspection, sitemap management | Performance monitoring, technical SEO |
| **Ahrefs MCP** | Community | **Free** server; **Ahrefs API from $99/mo** | Backlink analysis, keyword research, traffic analysis | Keyword research, backlink analysis |
| **Semrush MCP** | Semrush | **Free** server; **Semrush API varies by plan ($139-$499/mo)** | Domain analytics, keyword metrics, competitor research | Competitive analysis, keyword research |
| **DataForSEO MCP** | DataForSEO | **Pay-as-you-go** (~$0.0006/SERP query) | SERP data, backlinks, on-page analysis | Scalable SEO data |
| **Schema.org Validator MCP** | Community | **Free** (open-source) | JSON-LD validation, structured data checks | Technical SEO |
| **Lighthouse MCP** | Community | **Free** (open-source) | Core Web Vitals, performance audits | Technical SEO audits |
| **ContentKing MCP** | ContentKing | **$39-$139/mo** (ContentKing subscription) | Real-time content monitoring, change alerts | Content monitoring |
| **Coupler.io MCP** | Coupler.io | Freemium; Pro from $49/mo | GSC + GA4 integration, unified data flows | Reporting, data integration |

### Recommended Stack for SEO:
```
Primary: Google Search Console MCP + Ahrefs MCP (or Semrush MCP)
Technical: Lighthouse MCP + Schema Validator MCP
Budget option: DataForSEO MCP (pay-per-use)
```

### Pricing Comparison for SEO Tools:
| Tool | MCP Server Cost | API/Platform Cost | Best For |
|------|-----------------|-------------------|----------|
| GSC | Free | Free | First-party data |
| Ahrefs | Free | $99-$999/mo | Backlinks, keywords |
| Semrush | Free | $139-$499/mo | All-in-one SEO |
| DataForSEO | Free | Pay-per-use | Scale/budget |

### Setup Complexity:
- **GSC MCP**: ⭐⭐⭐ Medium-Hard - OAuth + service account setup
- **Ahrefs/Semrush MCP**: ⭐⭐ Medium - API key required
- **DataForSEO MCP**: ⭐⭐ Medium - API credentials

---

## 6. Data / Analytics MCP Servers

### Primary Tasks Supported:
- Write ad-hoc SQL queries
- Build tracking plans
- Conduct funnel/cohort analysis
- Build dbt data models
- Create/maintain data dictionary
- Create analysis reports
- Create/update dashboards
- Analyze A/B tests

| MCP Server | Provider | Pricing | Key Capabilities | Best For Tasks |
|------------|----------|---------|------------------|----------------|
| **Snowflake MCP** (Official) | Snowflake Labs | **Free** with Snowflake account | Cortex AI, SQL execution, semantic views, object management | SQL queries, data warehouse |
| **BigQuery MCP** (Google Toolbox) | Google | **Free** with GCP account | SQL queries, table metadata, forecasting, catalog search | SQL queries, GCP analytics |
| **PostgreSQL MCP** | Anthropic (Reference) | **Free** (open-source) | SQL queries, schema exploration | Direct database queries |
| **Mixpanel MCP** (Official) | Mixpanel | **Free** with Mixpanel account | Segmentation, funnels, retention, event discovery | Product analytics |
| **Amplitude MCP** | Community (moonbird) | **Free** (open-source) | Event tracking, pageviews, revenue | Product analytics |
| **Google Analytics 4 MCP** | Community (Gomarble) | **Free** (open-source) | GA4 metrics, dimensions, reports | Web analytics |
| **Metabase MCP** | Community | **Free** (open-source) | Dashboard access, query execution | BI dashboards |
| **Looker MCP** | Community | **Free** (open-source) | Look access, explore queries | BI dashboards |
| **dbt MCP** | Community | **Free** (open-source) | Model documentation, lineage | Data modeling |
| **MySQL/MariaDB MCP** | Community | **Free** (open-source) | SQL queries, schema access | Database queries |

### Recommended Stack for Data/Analytics:
```
Data Warehouse: Snowflake MCP (or BigQuery MCP)
Product Analytics: Mixpanel MCP (official, best supported)
Web Analytics: GA4 MCP
BI: Metabase MCP or Looker MCP
```

### Snowflake MCP Capabilities (Official):
- **Cortex Search**: RAG applications, unstructured data
- **Cortex Analyst**: Structured data via semantic modeling
- **Cortex Agent**: Multi-source orchestration
- **SQL Execution**: With permission controls
- **Object Management**: Create/update Snowflake objects

### Mixpanel MCP (Official) Capabilities:
- Segmentation queries (event counts, unique users)
- Funnel analysis (conversion rates)
- Retention analysis (user engagement)
- Event/property discovery
- Data anomaly detection
- Session replay access

### Setup Complexity:
- **Snowflake MCP**: ⭐⭐⭐ Medium-Hard - Auth config, role setup
- **BigQuery MCP**: ⭐⭐ Medium - GCP credentials, IAM
- **Mixpanel MCP**: ⭐ Easy - OAuth remote connection
- **PostgreSQL MCP**: ⭐⭐ Medium - Connection string

---

## 7. Cross-Role MCP Servers

These MCP servers are valuable across multiple roles:

| MCP Server | Provider | Pricing | Roles Benefiting | Key Use Cases |
|------------|----------|---------|------------------|---------------|
| **Notion MCP** | Notion | **Free** with subscription | PM, UX, All | Documentation, knowledge base |
| **Slack MCP** | Slack | **Free** with subscription | All | Communication, feedback |
| **Google Drive MCP** | Community | **Free** | All | File access, collaboration |
| **Perplexity MCP** | Perplexity | **Free** tier; Pro $20/mo | All | Web research |
| **Brave Search MCP** | Brave | **Free** | All | Web search |
| **Memory MCP** | Anthropic | **Free** (reference) | All | Persistent context |
| **Zapier MCP** | Zapier | Freemium; Paid from $19.99/mo | PM, Data | Workflow automation |

---

## 8. Pricing Summary Matrix

### Free MCP Servers (No Cost)

| Category | MCP Server | Notes |
|----------|-----------|-------|
| **Project Management** | Linear MCP, Jira MCP (community) | Requires tool subscription |
| **Documentation** | Notion MCP, Confluence MCP | Requires tool subscription |
| **Code/Engineering** | GitHub MCP, GitLab MCP, Git MCP | Free with account |
| **Testing** | Playwright MCP, Selenium MCP | Fully open-source |
| **Analytics** | Mixpanel MCP, GA4 MCP | Requires tool subscription |
| **Database** | PostgreSQL MCP, MySQL MCP | Open-source |
| **SEO** | GSC MCP, Lighthouse MCP | Free tools |

### Freemium MCP Servers (Free Tier + Paid Options)

| MCP Server | Free Tier | Paid Tier | Notes |
|------------|-----------|-----------|-------|
| **Sentry MCP** | 5K errors/mo | From $26/mo | Full debugging |
| **LambdaTest MCP** | Limited | From $15/mo | Cross-browser |
| **Snowflake MCP** | $400 credits | Usage-based | Enterprise data |
| **BigQuery MCP** | 10GB/mo | Usage-based | GCP pricing |
| **Ahrefs MCP** | Free server | API from $99/mo | Ahrefs data |
| **Semrush MCP** | Free server | Plan from $139/mo | Semrush data |

### Paid MCP Servers / Dependencies

| MCP Server | Minimum Cost | What You Get |
|------------|--------------|--------------|
| **Figma MCP** (Official) | ~$15/seat/mo (Dev Mode) | Full design-to-code |
| **ContentKing MCP** | $39/mo | Real-time monitoring |
| **DataForSEO MCP** | Pay-per-use (~$0.0006/query) | Scalable SEO data |
| **Enterprise Gateways** (MintMCP, etc.) | Varies | Managed hosting, compliance |

---

## Quick Reference: MCP Servers by Task Category

### Documentation & Knowledge
- Notion MCP (Free) ⭐ Best choice
- Confluence MCP (Free)
- Google Drive MCP (Free)

### Project Management
- Linear MCP (Free) ⭐ Modern teams
- Jira MCP (Free) ⭐ Enterprise
- Asana MCP (Community)

### Code & Development
- GitHub MCP (Free) ⭐ Best choice
- GitLab MCP (Free)
- Sentry MCP (Freemium)

### Design
- Figma MCP (~$15/mo) ⭐ Official
- Framelink MCP (Free) - Alternative

### Testing & QA
- Playwright MCP (Free) ⭐ Best choice
- Selenium MCP (Free)
- LambdaTest MCP (Freemium)

### Analytics & Data
- Snowflake MCP (Freemium) ⭐ Enterprise
- BigQuery MCP (Freemium)
- Mixpanel MCP (Free) ⭐ Product analytics
- PostgreSQL MCP (Free)

### SEO & Content
- GSC MCP (Free) ⭐ Essential
- Ahrefs MCP (Free server, paid API)
- DataForSEO MCP (Pay-per-use)

### Communication
- Slack MCP (Free) ⭐ Best choice
- Discord MCP (Community)

---

## Implementation Priority Recommendations

### For a 10-50 Person Team (Budget-Conscious):
1. **Week 1**: GitHub MCP + Linear MCP + Notion MCP (all free)
2. **Week 2**: Playwright MCP + Sentry MCP free tier
3. **Week 3**: GSC MCP + Mixpanel MCP
4. **Week 4**: Framelink MCP (free Figma alternative)

### For a 50-200 Person Team (Enterprise):
1. **Week 1**: GitHub MCP + Jira/Confluence MCP + Slack MCP
2. **Week 2**: Sentry MCP paid + Snowflake MCP
3. **Week 3**: Figma MCP (official) + Mixpanel MCP
4. **Week 4**: Ahrefs/Semrush MCP + LambdaTest MCP

---

## Sources & References

1. Model Context Protocol Official: https://modelcontextprotocol.io/
2. Awesome MCP Servers: https://github.com/punkpeye/awesome-mcp-servers
3. MCP Registry: https://mcpservers.org/
4. PulseMCP Directory: https://www.pulsemcp.com/
5. Figma MCP Documentation: https://help.figma.com/hc/en-us/articles/32132100833559
6. Notion MCP Documentation: https://developers.notion.com/docs/mcp
7. Snowflake MCP: https://github.com/Snowflake-Labs/mcp
8. Mixpanel MCP: https://docs.mixpanel.com/docs/features/mcp
9. Sentry MCP: https://docs.sentry.io/product/sentry-mcp/
10. GitLab MCP: https://docs.gitlab.com/user/gitlab_duo/model_context_protocol/mcp_server/
11. Playwright MCP: https://executeautomation.github.io/mcp-playwright/docs/intro
12. Atlassian Remote MCP: https://www.atlassian.com/platform/remote-mcp-server

---

*Report generated: January 2026*
*Note: Pricing and features are subject to change. Always verify current pricing on vendor websites.*
