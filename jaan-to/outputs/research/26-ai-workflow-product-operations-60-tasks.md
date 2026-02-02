# AI-Assisted Product Operations: The 60 Highest-Leverage Tasks Across SaaS Teams

> 60 AI-ready tasks across 6 roles with inputs, outputs, metrics, AI suitability scores, and skill commands.
> Source: Local file (ai-assisted-product-operations-The-60-highest-leverage-tasks-across-SaaS-teams.md)
> Added: 2026-01-27

---

Modern SaaS product teams spend **40-60% of their time on repetitive, documentable tasks** that produce standardized outputs—making them ideal candidates for AI assistance. This research identifies the top 10 tasks across six core roles (PM/PO, Engineering, UX Design, QA, SEO/Content, Data/Analytics) that deliver maximum leverage when augmented by AI, along with end-to-end workflows that chain multiple roles together.

The highest-value AI opportunities cluster around **document generation** (PRDs, test cases, briefs), **data synthesis** (feedback analysis, research summaries), and **code/query generation** (SQL, automation scripts, schemas). Tasks requiring human judgment for strategic decisions or relationship-building remain lower priority for full automation but benefit significantly from AI-generated first drafts.

---

## Product Manager / Product Owner Tasks

| # | Task Name | When It Happens | Inputs Needed | AI-Generated Outputs | Measurable Outcomes | AI Suitability (1-5) | Dependencies/Handoffs | Common Failure Modes | Quality Gates | Example AI Skill Command |
|---|-----------|-----------------|---------------|---------------------|---------------------|---------------------|----------------------|---------------------|---------------|-------------------------|
| 1 | Write PRD | Per feature/epic (1-4 per sprint) | User research, customer feedback, business objectives, competitive analysis | PRD with problem statement, success metrics, user stories, acceptance criteria, scope | Time to first draft reduced 60-80%; fewer clarification questions from engineering | **5** - Highly structured, template-based | Engineering, Design, QA, Stakeholders | Too much/little detail; missing success metrics; no stakeholder alignment | Engineering can estimate without questions; clear AC; stakeholder sign-off | `/PM-PRD:GENERATE [feature_name] [user_problem] [target_persona]` |
| 2 | Refine product backlog | Weekly (1-2 hours) | Existing backlog, feedback, sprint retro findings, bug reports | Split stories, prioritized items with estimates, missing AC suggestions | Backlog grooming time reduced 40%; fewer "not ready" stories in sprint | **5** - Pattern recognition, gap identification | Engineering, Scrum Master, Design | Stories too large; missing AC; scope creep; redundant items | Items meet Definition of Ready; top items detailed for 2 sprints | `/PM-BACKLOG:REFINE [sprint_goal] [capacity]` |
| 3 | Write user stories with AC | Daily (4-10 per sprint) | User research, personas, requirements, UX designs | User stories in standard format; Given/When/Then acceptance criteria | Story clarity score improved; QA can write tests from AC directly | **5** - Format conversion, edge case generation | Engineering, QA, Design | Too technical; missing "so that"; AC not testable | INVEST criteria met; QA confirms testability | `/PM-STORY:CREATE [feature] [persona] [goal]` |
| 4 | Synthesize customer feedback | Ongoing + weekly synthesis | Support tickets, NPS, interviews, sales notes, feature requests | Categorized feedback report, prioritized pain points, theme clusters | 80% reduction in feedback processing time; themes quantified | **5** - Scale categorization, sentiment analysis | Customer Success, Support, Sales, UX | Feedback silos; recency bias; loud customers over-represented | Multiple sources triangulated; connected to segments | `/PM-FEEDBACK:SYNTHESIZE [date_range] [segment]` |
| 5 | Prioritize features | Weekly + quarterly roadmap | Feature requests, business objectives, effort estimates, competitive intel | RICE scores, prioritized list with rationale, dependency map | Consistent framework application; reduced stakeholder conflicts | **4** - Calculate scores, normalize estimates | Engineering, Sales, Executives | Gut-feeling decisions; inconsistent scoring; pet projects | Transparent scoring documented; stakeholder alignment | `/PM-PRIORITIZE:SCORE [features_list] [framework]` |
| 6 | Update product roadmap | Weekly (30 min) + monthly major | Strategy/OKRs, prioritized backlog, capacity, market changes | Visual roadmap (Now/Next/Later), stakeholder presentations, status summaries | Roadmap update time reduced 50%; consistent stakeholder views | **4** - Format data, generate views | Executives, Sales, Marketing, Engineering | Too detailed timelines; output vs. outcome focus | Aligns with OKRs; engineering validated capacity | `/PM-ROADMAP:UPDATE [quarter] [theme]` |
| 7 | Analyze product metrics | Daily review + weekly deep-dive | Analytics data (usage, retention, churn), revenue metrics, NPS | Dashboards, insight narratives, anomaly alerts, hypothesis suggestions | Faster anomaly detection; actionable insights per report increased | **5** - Trend detection, narrative generation | Data/Analytics, Engineering, Executives | Vanity metrics focus; data without insights | Metrics tied to outcomes; hypotheses validated | `/PM-METRICS:ANALYZE [metric_category] [period]` |
| 8 | Define/track OKRs | Quarterly setting + weekly tracking | Company strategy, product vision, historical performance | OKR documents, progress summaries, initiative recommendations | 70% target achievement rate; OKRs connected to daily work | **4** - Suggest KRs, flag poorly-formed OKRs | Executives, Engineering, Product team | Too many objectives; vanity KRs; unattainable goals | SMART criteria for KRs; team understands connection | `/PM-OKR:DEFINE [objective] [period]` |
| 9 | Write release notes | Per release (weekly-monthly) | Shipped features, bug fixes, user-facing changes | Customer-facing release notes, changelog, support docs | Release note publishing time reduced 70%; consistent tone | **5** - Technical-to-user language conversion | Marketing, Support, Engineering | Too technical; missing context; delayed publication | Customer-understandable; complete coverage | `/PM-RELEASE:NOTES [version] [audience]` |
| 10 | Create competitive analysis | Quarterly + ongoing monitoring | Competitor docs, pricing, reviews, analyst reports | Competitive matrix, feature comparison, battlecards | Sales win rate improvement; informed roadmap decisions | **5** - Monitor changes, generate comparisons | Sales, Marketing, Executives | Outdated info; feature parity obsession | Sales finds battlecards useful; updated regularly | `/PM-COMPETITIVE:ANALYZE [competitor_list]` |

---

## Software Engineer Tasks

| # | Task Name | When It Happens | Inputs Needed | AI-Generated Outputs | Measurable Outcomes | AI Suitability (1-5) | Dependencies/Handoffs | Common Failure Modes | Quality Gates | Example AI Skill Command |
|---|-----------|-----------------|---------------|---------------------|---------------------|---------------------|----------------------|---------------------|---------------|-------------------------|
| 1 | Write/implement code | Daily (4-6 hours) | Technical specs, user stories, AC, design mockups | Source code, unit tests, refactoring suggestions | Lines of code per hour increased; code quality scores improved | **5** - Code generation, autocompletion | PM (requirements), QA (testability), Design | Scope creep; technical debt; insufficient test coverage | Code compiles; tests pass; meets AC; code review approval | `/ENG-CODE:IMPLEMENT [ticket_id] [language]` |
| 2 | Review code / approve PRs | Daily (1-2 hours) | Pull request, diff, linked tickets, description | Review comments, security scan results, style checks, improvement suggestions | Review time reduced 40%; defect escape rate decreased | **5** - Automated linting, security scanning | Other engineers, DevOps | Rubber-stamping; bikeshedding; delayed reviews | Checklist completion; response time <24hrs | `/ENG-PR:REVIEW [pr_url]` |
| 3 | Write unit/integration tests | Daily (with every feature) | Requirements, AC, code under test | Test files, edge case coverage, mock generation | Test coverage >80%; test reliability >95% | **5** - Test generation, edge case identification | QA, DevOps (CI pipelines) | Insufficient coverage; flaky tests; testing implementation not behavior | Coverage metrics; test reliability rate | `/ENG-TEST:GENERATE [file_path] [coverage_target]` |
| 4 | Create/update PR description | Daily (multiple per day) | Completed code changes, linked issues, PR template | PR description, change summary, screenshots, test evidence | PR acceptance rate improved; fewer reviewer questions | **5** - Auto-summarize changes, populate templates | Other engineers (reviewers), PM, QA | PRs too large; missing context; unclear descriptions | Template completeness; PR size <400 LOC; CI passes | `/ENG-PR:DESCRIBE [branch_name]` |
| 5 | Write technical documentation | Weekly/per feature | Code changes, technical decisions, architecture | README files, API docs, runbooks, inline comments | Documentation freshness score; onboarding time reduced | **5** - Draft generation, format standardization | Other engineers, PM, Support | Documentation stale; inconsistent formatting | Up-to-date with code; follows style guide | `/ENG-DOCS:GENERATE [component] [doc_type]` |
| 6 | Debug/fix bugs | Daily (up to 75% of time) | Bug reports, error logs, stack traces | Root cause analysis, code fixes, regression tests | Mean time to resolution reduced; fewer bug recurrences | **4** - Log analysis, fix suggestions | QA (verification), Support, DevOps | Fixing symptoms not root cause; introducing new bugs | Bug cannot be reproduced; regression tests added | `/ENG-DEBUG:ANALYZE [error_log] [context]` |
| 7 | Write technical specification | Per feature/project (weekly) | Product requirements, constraints, existing architecture | Tech spec with architecture, data models, API contracts, diagrams | Spec review cycles reduced; implementation alignment improved | **5** - Draft generation, diagram creation | PM, Architects, Other engineers | Skipping design phase; over-engineering | Architecture review approval; addresses all requirements | `/ENG-SPEC:DRAFT [prd_link] [system_context]` |
| 8 | Create ADRs | Per significant decision (monthly) | Technical context, problem statement, alternatives | ADR document (context, decision, consequences) | Decision documentation coverage 100%; reduced context loss | **5** - Draft from discussion, suggest alternatives | Tech leads, Architects, Future team | Not documenting decisions; too verbose; missing consequences | Follows MADR template; includes alternatives | `/ENG-ADR:CREATE [decision_title] [context]` |
| 9 | Write/triage bug reports | Daily (when issues found) | Issue observation, environment details, user reports | Bug ticket with steps to reproduce, severity, expected vs actual | Bug reproducibility rate >90%; developer resolution time reduced | **5** - Auto-capture details, suggest severity | QA, PM, Support | Missing reproduction steps; vague descriptions; duplicates | Reproducible by another engineer; complete fields | `/ENG-BUG:REPORT [observation] [environment]` |
| 10 | Refactor existing code | Weekly/opportunistic | Code smells, technical debt items, performance issues | Cleaner code, improved tests, documentation updates | Code quality metrics improved; performance gains | **5** - Identify opportunities, suggest improvements | Other engineers, Tech leads | "Big bang" refactors; breaking functionality | All existing tests pass; improved metrics | `/ENG-REFACTOR:SUGGEST [file_path] [goal]` |

---

## UX / Product Design Tasks

| # | Task Name | When It Happens | Inputs Needed | AI-Generated Outputs | Measurable Outcomes | AI Suitability (1-5) | Dependencies/Handoffs | Common Failure Modes | Quality Gates | Example AI Skill Command |
|---|-----------|-----------------|---------------|---------------------|---------------------|---------------------|----------------------|---------------------|---------------|-------------------------|
| 1 | Synthesize research findings | After each research phase | Raw data (interviews, tests, surveys), analysis framework | Research reports, executive summary, insight themes, recommendations | Research synthesis time reduced 60%; actionable recommendations per study | **5** - Pattern recognition, summarization | PM, Stakeholders, Engineering | Too long reports; no actionable recommendations | Stakeholder feedback; action items tracked | `/UX-RESEARCH:SYNTHESIZE [study_name] [data_sources]` |
| 2 | Conduct user interviews | Weekly (2-5 sessions during discovery) | Research plan, interview guide, participant list | Interview transcripts, theme extraction, affinity maps | Interview analysis time reduced 50%; themes identified across sessions | **5** - Transcription, theme identification | PM (research objectives), Engineering | Leading questions; bias in selection; insufficient probing | Peer review of guide; triangulation with other methods | `/UX-INTERVIEW:GUIDE [research_questions] [persona]` |
| 3 | Create user personas | Per major initiative (1-2 times) | User research, analytics, surveys, stakeholder input | Persona documents (goals, pain points, behaviors, JTBD) | Persona alignment score; design decisions reference personas | **5** - Synthesize data, identify patterns | PM, Marketing, Engineering | Based on assumptions; not validated; too many personas | Validation interviews; periodic reviews | `/UX-PERSONA:CREATE [research_data] [segment]` |
| 4 | Write usability testing scripts | Project-based (2-4 per quarter) | Test objectives, prototype, participant criteria | Test scripts (intro, tasks, probing questions), task flows | Script quality score; session efficiency improved | **5** - Generate templates, unbiased task phrasing | Research, PM, Engineering | Leading task descriptions; too many tasks; unrealistic scenarios | Pilot tests; peer review; time-box validation | `/UX-USABILITY:SCRIPT [prototype_link] [objectives]` |
| 5 | Map customer journeys | Per major initiative | Research insights, analytics, personas, touchpoints | Journey maps (phases, actions, emotions, pain points, opportunities) | Pain points identified; roadmap items prioritized | **5** - Synthesize into drafts, identify pain points | PM, Marketing, Support, Engineering | Based on assumptions; missing error paths; too complex | Validation against real data; stakeholder review | `/UX-JOURNEY:MAP [persona] [scenario]` |
| 6 | Maintain design system docs | Ongoing (weekly updates) | Component library, code library, usage guidelines | Component documentation, anatomy, variants, accessibility notes | Documentation coverage score; adoption metrics | **5** - Generate from components, identify gaps | Engineering, Other Designers, QA | Outdated; Figma-code inconsistency; unclear usage | Regular audits; user feedback | `/UX-DESIGNSYSTEM:DOCUMENT [component_name]` |
| 7 | Create design specifications | End of each design phase | Final designs, interaction requirements, accessibility | Design spec (spacing, colors, interaction behavior, responsive specs) | Developer questions reduced 60%; implementation accuracy | **5** - Auto-generate specs, identify missing states | Engineering, QA, PM | Incomplete edge cases; vague interactions | Developer Q&A sessions; implementation review | `/UX-SPEC:GENERATE [figma_frame_url]` |
| 8 | Prepare design handoff | End of design phase/sprint | Completed designs, component library, interaction specs | Annotated files, dev-ready assets, "Ready for Dev" labels | Handoff time reduced; developer satisfaction score | **4** - Auto-generate specs, detect inconsistencies | Engineering (primary), QA, PM | Missing states; unclear naming; outdated design vs code | Developer walkthrough; checklist completion | `/UX-HANDOFF:PREPARE [project_name]` |
| 9 | Run usability tests | Weekly during testing (2-5 per week) | Testing script, prototype, recording tools | Session summaries, usability metrics, findings report | Time-on-analysis reduced 50%; pattern identification improved | **4** - Auto-transcribe, identify patterns | Engineering, PM, Stakeholders | Testing wrong user type; observer bias; ignoring findings | Multiple observers; standardized metrics | `/UX-USABILITY:ANALYZE [session_recordings]` |
| 10 | Conduct competitive UX analysis | Quarterly or per initiative | Competitor list, evaluation criteria, product access | Competitive analysis report, UX pattern documentation | Differentiation opportunities identified; design informed by market | **4** - Gather info, identify patterns | PM, Marketing, Stakeholders | Surface-level analysis; copying without understanding why | Cross-functional review; periodic updates | `/UX-COMPETITIVE:ANALYZE [competitor_list] [criteria]` |

---

## QA / Test Engineer Tasks

| # | Task Name | When It Happens | Inputs Needed | AI-Generated Outputs | Measurable Outcomes | AI Suitability (1-5) | Dependencies/Handoffs | Common Failure Modes | Quality Gates | Example AI Skill Command |
|---|-----------|-----------------|---------------|---------------------|---------------------|---------------------|----------------------|---------------------|---------------|-------------------------|
| 1 | Write test cases | Daily/Sprint (5-20 per sprint) | User stories, AC, design specs, API docs | Test cases (ID, steps, preconditions, expected results, priority) | Test case creation time reduced 60%; edge case coverage improved | **5** - Generate from AC, suggest edge cases | PM (requirements), Engineering | Vague steps; missing edge cases; not traceable to requirements | Peer review; traceable to requirements; reusable | `/QA-TEST:CASES [user_story_id]` |
| 2 | Write bug reports | Daily (3-10+ per sprint) | Failed test case, screenshots, logs, environment | Bug ticket (severity, priority, steps to reproduce, expected vs actual) | Bug report quality score; developer resolution time reduced | **5** - Structure reports, detect duplicates | Engineering, PM, Support | Vague descriptions; missing repro steps; incorrect severity | Developer can reproduce in <5 min; linked to test case | `/QA-BUG:REPORT [observation] [test_case_id]` |
| 3 | Write automation scripts | Weekly/Sprint | Manual test cases, locators, framework (Cypress/Playwright) | Automation scripts, Page Object Models, test data files | Automation coverage increased; script reliability >95% | **5** - Generate code, suggest stable locators | Engineering, DevOps | Brittle locators; flaky tests; not integrated with CI/CD | 95%+ reliability; <5 min execution; CI integrated | `/QA-AUTOMATION:SCRIPT [test_case_id] [framework]` |
| 4 | Conduct API testing | Daily/Sprint | API docs (OpenAPI), endpoints, auth tokens | Postman collections, API test scripts, Newman reports | API test coverage 100%; schema validation passing | **5** - Generate from specs, validate schemas | Backend Engineering, DevOps | Incomplete schema validation; missing error responses | 100% endpoint coverage; validates all status codes | `/QA-API:TEST [openapi_spec_url]` |
| 5 | Create test plans | Per sprint/release | Sprint goals, backlog, risk assessment, resources | Test plan (objectives, scope, strategy, schedule, entry/exit criteria) | Test plan creation time reduced 50%; coverage aligned with sprint | **5** - Generate from backlog, suggest risks | PM, Engineering, Leadership | Plans outdated; unrealistic timelines; missing risks | Covers all stories; realistic allocation; stakeholder sign-off | `/QA-PLAN:CREATE [sprint_id] [scope]` |
| 6 | Perform regression testing | Every release (weekly) | Regression suite, build info, change log | Regression report, pass/fail summary, impacted test identification | Regression cycle time reduced; >90% baseline pass rate | **4** - Identify impacted tests, prioritize suite | Engineering, DevOps, PM | Suite bloated; tests not prioritized; flaky tests | >90% pass rate; <30 min smoke tests; prioritized by risk | `/QA-REGRESSION:RUN [build_version] [scope]` |
| 7 | Review acceptance criteria | Daily/Sprint planning | User stories, AC, Definition of Done | Refined AC, testability assessment, Given/When/Then format | AC clarity score; fewer ambiguous criteria | **4** - Identify vague criteria, suggest scenarios | PM, Engineering | Vague/untestable criteria; missing edge cases | Each criterion measurable and testable; G/W/T format | `/QA-AC:REVIEW [user_story_id]` |
| 8 | Generate test coverage reports | Weekly/End of sprint | Test execution data, requirements, defect data | Coverage reports, QA dashboards, metrics (defect density, DRE) | Stakeholder visibility improved; actionable insights | **4** - Auto-generate reports, identify trends | PM, Leadership, Engineering | Vanity metrics; outdated reports; no historical comparison | Actionable insights; aligned with business goals | `/QA-REPORT:COVERAGE [sprint_id]` |
| 9 | Set up test data | Sprint/as needed | Data requirements, schemas, anonymization rules | Test data sets, generation scripts, mock configurations | Test data availability 100%; no PII exposure | **4** - Generate realistic data, anonymize | Engineering, DevOps, Security | Stale data; PII exposure; insufficient variety | Covers all scenarios; properly anonymized; refreshable | `/QA-DATA:GENERATE [schema] [scenarios]` |
| 10 | Integrate tests with CI/CD | Sprint/as automation matures | Automation scripts, CI platform, environment configs | Pipeline configurations (YAML), test stage definitions | Test feedback loop <15 min; tests run on every PR | **4** - Generate pipeline configs, optimize | DevOps, Engineering, PM | Flaky tests block deployments; slow test stages | Tests run on every PR; clear pass/fail visibility | `/QA-CICD:CONFIGURE [pipeline_type]` |

---

## SEO / Content Strategist Tasks

| # | Task Name | When It Happens | Inputs Needed | AI-Generated Outputs | Measurable Outcomes | AI Suitability (1-5) | Dependencies/Handoffs | Common Failure Modes | Quality Gates | Example AI Skill Command |
|---|-----------|-----------------|---------------|---------------------|---------------------|---------------------|----------------------|---------------------|---------------|-------------------------|
| 1 | Create SEO content briefs | Weekly (2-5 per week) | Target keyword, SERP analysis, brand voice, persona | Content brief (keyword, outline, word count, competitor refs, CTAs) | Brief creation time reduced 70%; writer revision cycles reduced | **5** - Analyze SERP, generate outlines | Content Writers, SMEs, Editors | Too vague or prescriptive; missing search intent alignment | Brief answers "what makes this better than page 1" | `/SEO-BRIEF:CREATE [keyword] [content_type]` |
| 2 | Conduct keyword research | Weekly (ongoing refinement) | Seed keywords, competitor domains, personas | Keyword list with volume/difficulty/intent, topic clusters, KOB analysis | Keyword opportunities identified; content roadmap informed | **5** - Automate gathering, classify intent | Product Marketing, Content Writers | Targeting wrong intent; ignoring difficulty; missing long-tail | Keywords align with ICP; balanced intent distribution | `/SEO-KEYWORD:RESEARCH [seed_topic] [competitor_domains]` |
| 3 | Write meta titles/descriptions | Per content piece (ongoing) | Target keyword, page content, character limits | Meta title (<60 chars), meta description (<155 chars), A/B variations | CTR improvement; no truncation in SERPs | **5** - Generate variations, optimize length | Content Writers, SEO, Web Dev | Truncation; keyword stuffing; generic descriptions | Primary keyword included; compelling; proper length | `/SEO-META:WRITE [page_url] [target_keyword]` |
| 4 | Optimize existing content | Weekly (1-3 pieces) | Traffic decline reports, original content, updated research | Content optimization checklist, updated sections, internal links | Traffic recovery +20-50% within 90 days; ranking improvement | **5** - Identify declining content, suggest improvements | Content Writers, Product Marketing | Surface-level changes; breaking existing rankings | Matches current intent; competitive depth; tracked 30/60/90 days | `/SEO-CONTENT:OPTIMIZE [page_url]` |
| 5 | Conduct content gap analysis | Quarterly + monthly monitoring | Competitor domains, own rankings, buyer journey | Gap analysis spreadsheet, prioritized content roadmap | New content opportunities identified; quick wins prioritized | **5** - Process large datasets, identify patterns | Content Strategy, Product Marketing | Chasing irrelevant keywords; ignoring relevance | Gaps prioritized by traffic + business relevance | `/SEO-GAP:ANALYZE [competitor_list]` |
| 6 | Monitor SEO performance | Daily monitoring + weekly reporting | GSC, GA4, rank tracking, conversion data | SEO dashboard, performance reports, anomaly alerts | Faster anomaly detection; stakeholder-ready reports | **4** - Automate dashboards, generate narratives | Marketing Leadership, Sales | Vanity metrics; no context; missing attribution | KPIs tied to business goals; insights with data | `/SEO-REPORT:GENERATE [period] [audience]` |
| 7 | Conduct SERP analysis | Per content piece/keyword cluster | Target keywords, live SERP results | SERP analysis (content types, word counts, features, intent, questions) | Content format aligned with SERP; featured snippet opportunities | **4** - Automate scraping, pattern recognition | Content Strategists, Writers | Assuming intent without checking; missing SERP features | Format matches expectations; differentiation found | `/SEO-SERP:ANALYZE [keyword]` |
| 8 | Perform technical SEO audits | Monthly comprehensive + weekly monitoring | GSC, crawling tools, speed tools, site access | Audit report, prioritized issues, crawl errors, Core Web Vitals | Technical issues reduced; crawl efficiency improved | **4** - Detection automated, prioritize by impact | Engineering, DevOps, Web Dev | Not prioritizing by impact; missing JS rendering issues | Issues ranked by impact/effort; clear repro steps | `/SEO-AUDIT:TECHNICAL [domain]` |
| 9 | Build internal linking structure | Weekly ongoing + monthly audit | Content inventory, topic clusters, crawl data | Linking strategy, hub-spoke maps, orphan page list | Orphaned content reduced; topic clusters interconnected | **4** - Identify opportunities, detect orphans | Content Writers, Web Dev | Random linking; orphaned pages; over-optimized anchors | Important pages have adequate links; no orphans | `/SEO-LINKS:INTERNAL [topic_cluster]` |
| 10 | Create schema markup | Per page type + quarterly audit | Page content, schema.org docs, competitor analysis | JSON-LD schema code, implementation docs, validation report | Rich results generated; schema validation passing | **4** - Generate code, validate | Engineering, Web Dev | Invalid syntax; schema not matching content | Passes Rich Results Test; generates rich results | `/SEO-SCHEMA:GENERATE [page_url] [schema_type]` |

---

## Data / Analytics Tasks

| # | Task Name | When It Happens | Inputs Needed | AI-Generated Outputs | Measurable Outcomes | AI Suitability (1-5) | Dependencies/Handoffs | Common Failure Modes | Quality Gates | Example AI Skill Command |
|---|-----------|-----------------|---------------|---------------------|---------------------|---------------------|----------------------|---------------------|---------------|-------------------------|
| 1 | Write ad-hoc SQL queries | Daily (multiple times) | Stakeholder question, data warehouse access, schema knowledge | SQL query, results summary, data export | Query generation time reduced 70%; faster stakeholder response | **5** - Natural language to SQL | PM, Marketing, Sales, CS | Misunderstanding question; wrong joins; incorrect filters | Row count sanity checks; cross-reference dashboards | `/DATA-SQL:QUERY [question] [tables]` |
| 2 | Build tracking plans | Weekly + per new feature | Product requirements, business KPIs, event taxonomy | Tracking plan spreadsheet, event specs, implementation tickets | Event coverage complete; naming conventions consistent | **5** - Generate event names, suggest properties | PM, Engineering, Marketing | Inconsistent naming; missing properties; implementation differs | QA in staging; compare tracked vs spec; volume monitoring | `/DATA-TRACKING:PLAN [feature_name] [kpis]` |
| 3 | Conduct funnel analysis | Weekly monitoring + ad-hoc | Defined funnel steps, time window, segments | Funnel visualization, drop-off analysis, recommendations | Conversion bottlenecks identified; optimization hypotheses | **5** - Write funnel SQL, identify anomalies | PM, Growth, Engineering | Mixing cohorts; wrong conversion window; ignoring platform | Sum validation; compare with analytics tool | `/DATA-FUNNEL:ANALYZE [funnel_name] [segment]` |
| 4 | Conduct cohort/retention analysis | Weekly + monthly deep dives | Cohort definition, retention event, time periods | Cohort tables, retention curves, churn risk identification | Retention trends visible; LTV projections informed | **5** - Generate cohort SQL with window functions | Product, Marketing, Finance, CS | Incomplete data; timezone issues; not accounting for seasonality | Early cohorts stable; cross-reference with finance | `/DATA-COHORT:ANALYZE [cohort_type] [retention_event]` |
| 5 | Build dbt data models | Weekly iterations + daily testing | Raw sources, business logic, model architecture | Staging/mart models, tests, documentation (schema.yml) | Model coverage complete; data quality tests passing | **5** - Generate SQL, write tests, create docs | Data Engineering, BI, Business users | Circular dependencies; missing tests; poor documentation | dbt test passes; row counts match; code review | `/DATA-DBT:MODEL [source_table] [model_type]` |
| 6 | Create/maintain data dictionary | Weekly updates + monthly audits | Database schemas, business context, stakeholder input | Data dictionary, column descriptions, lineage documentation | Documentation coverage >90%; onboarding time reduced | **5** - Draft descriptions, infer relationships | All data consumers, Compliance, Engineering | Documentation stale; multiple definitions; no ownership | Automated sync; regular review; new hire can understand | `/DATA-DICTIONARY:DOCUMENT [table_name]` |
| 7 | Create analysis reports | Weekly regular + ad-hoc deep dives | Analysis findings, audience context | Written reports, slide decks, executive summaries | Stakeholder satisfaction; action items concrete | **5** - Draft summaries, structure narratives | Leadership, Cross-functional teams | Too much detail; no "so what"; burying the lead | Executive summary test; peer review; clear actions | `/DATA-REPORT:CREATE [analysis_topic] [audience]` |
| 8 | Create/update dashboards | Weekly updates + monthly new | KPIs, data sources, stakeholder requirements | Interactive dashboards, scheduled reports | Dashboard adoption; load time <3s; metrics aligned | **4** - Suggest chart types, write queries | Executives, Product, Marketing, CS | Information overload; slow performance; dashboard rot | Numbers match source; filters work; stakeholder feedback | `/DATA-DASHBOARD:BUILD [dashboard_type] [metrics]` |
| 9 | Analyze A/B tests | Weekly ongoing + results review | Experiment config, metrics, sample size requirements | Statistical significance, confidence intervals, recommendation | Experiment velocity increased; decision quality improved | **4** - Calculate statistics, generate reports | PM, Engineering, Leadership | Peeking; SRM; multiple comparisons; stopping too early | Check for SRM; pre-register hypotheses; A/A tests | `/DATA-ABTEST:ANALYZE [experiment_id]` |
| 10 | Validate event/data (QA) | Per release/feature launch | Tracking plan, test environment, expected data | QA test results, bug tickets, sign-off documentation | Event validation coverage 100%; fewer post-launch data issues | **4** - Generate test cases, create checklists | Engineering, Product, QA | Testing only happy path; not testing all platforms | Event volume matches expected; all properties populated | `/DATA-EVENTS:VALIDATE [tracking_plan] [environment]` |

---

## Cross-Role Synthesis: Top 20 AI-Ready Tasks Ranked by Impact

Ranking methodology combines **repetition frequency** (daily/weekly tasks weighted higher), **business impact** (revenue, velocity, quality metrics), and **AI suitability** (structured output, template-based, data processing).

| Rank | Task | Role | Repetition | Business Impact | AI Score | Combined Score |
|------|------|------|------------|-----------------|----------|----------------|
| 1 | Write test cases from AC | QA | Daily | Defect prevention, velocity | 5 | **98** |
| 2 | Write ad-hoc SQL queries | Data | Daily | Decision speed, self-service | 5 | **97** |
| 3 | Write/review code | Engineering | Daily | Core product velocity | 5 | **96** |
| 4 | Create SEO content briefs | SEO/Content | Weekly | Organic traffic, CAC reduction | 5 | **95** |
| 5 | Write PRDs | PM | Per feature | Alignment, reduced rework | 5 | **94** |
| 6 | Write user stories with AC | PM | Daily | Sprint readiness, clarity | 5 | **93** |
| 7 | Generate unit/integration tests | Engineering | Daily | Code quality, defect prevention | 5 | **92** |
| 8 | Synthesize research findings | UX | Per study | Product-market fit decisions | 5 | **91** |
| 9 | Build tracking plans | Data | Weekly | Measurement accuracy | 5 | **90** |
| 10 | Write bug reports | QA | Daily | Resolution speed | 5 | **89** |
| 11 | Conduct funnel/cohort analysis | Data | Weekly | Growth optimization | 5 | **88** |
| 12 | Write meta titles/descriptions | SEO | Per piece | CTR, organic traffic | 5 | **87** |
| 13 | Create automation scripts | QA | Weekly | Test efficiency, coverage | 5 | **86** |
| 14 | Write technical documentation | Engineering | Weekly | Onboarding, knowledge transfer | 5 | **85** |
| 15 | Synthesize customer feedback | PM | Weekly | Product direction accuracy | 5 | **84** |
| 16 | Create user personas | UX | Per initiative | Design alignment | 5 | **83** |
| 17 | Write usability test scripts | UX | Per project | Research quality | 5 | **82** |
| 18 | Optimize existing content | SEO | Weekly | Traffic recovery | 5 | **81** |
| 19 | Build dbt data models | Data | Weekly | Data quality, self-service | 5 | **80** |
| 20 | Create PR descriptions | Engineering | Daily | Review efficiency | 5 | **79** |

---

## Five End-to-End Workflows That Chain Multiple Roles

### Workflow 1: Feature Development (PRD → Ship)

| Step | Role | Task | Artifact | AI Skill Command |
|------|------|------|----------|------------------|
| 1 | PM | Define feature requirements | PRD with AC | `/PM-PRD:GENERATE` |
| 2 | UX | Create user journey and wireframes | Journey map, wireframes | `/UX-JOURNEY:MAP` |
| 3 | UX | Conduct usability testing | Test script, findings report | `/UX-USABILITY:SCRIPT` |
| 4 | Engineering | Write technical specification | Tech spec, ADR | `/ENG-SPEC:DRAFT` |
| 5 | QA | Create test plan and cases | Test plan, test cases | `/QA-PLAN:CREATE`, `/QA-TEST:CASES` |
| 6 | Data | Build tracking plan | Tracking spec | `/DATA-TRACKING:PLAN` |
| 7 | Engineering | Implement and test code | Code, unit tests, PR | `/ENG-CODE:IMPLEMENT` |
| 8 | QA | Execute tests and validate | Test results, bug reports | `/QA-AUTOMATION:SCRIPT` |
| 9 | PM | Write release notes | Release notes | `/PM-RELEASE:NOTES` |
| 10 | Data | Validate tracking and analyze | Event QA, adoption dashboard | `/DATA-EVENTS:VALIDATE` |

**Metrics to measure improvement:**
- Feature cycle time (idea → production)
- Defect escape rate to production
- Time spent in requirements clarification
- Feature adoption rate at 30/60/90 days

---

### Workflow 2: Content Launch (Keyword → Published → Optimized)

| Step | Role | Task | Artifact | AI Skill Command |
|------|------|------|----------|------------------|
| 1 | SEO | Conduct keyword research | Keyword list with intent | `/SEO-KEYWORD:RESEARCH` |
| 2 | SEO | Analyze SERP competition | SERP analysis report | `/SEO-SERP:ANALYZE` |
| 3 | SEO | Create content brief | Content brief | `/SEO-BRIEF:CREATE` |
| 4 | SEO | Write meta tags and schema | Meta tags, JSON-LD | `/SEO-META:WRITE`, `/SEO-SCHEMA:GENERATE` |
| 5 | Content | Draft and publish content | Published article | (Human writing) |
| 6 | Data | Set up content tracking | Tracking events | `/DATA-TRACKING:PLAN` |
| 7 | Data | Build content performance dashboard | Dashboard | `/DATA-DASHBOARD:BUILD` |
| 8 | SEO | Monitor and optimize (30/60/90 days) | Optimization checklist | `/SEO-CONTENT:OPTIMIZE` |

**Metrics to measure improvement:**
- Time from keyword to published content
- First-page ranking velocity (days to page 1)
- Organic traffic growth per content piece
- Conversion rate from organic content

---

### Workflow 3: User Research → Product Decision

| Step | Role | Task | Artifact | AI Skill Command |
|------|------|------|----------|------------------|
| 1 | PM | Define research objectives | Research brief | `/PM-PRD:GENERATE` (research section) |
| 2 | UX | Create interview guide | Interview script | `/UX-INTERVIEW:GUIDE` |
| 3 | UX | Conduct user interviews | Transcripts, notes | (Human interviews) |
| 4 | UX | Synthesize research findings | Research report, personas | `/UX-RESEARCH:SYNTHESIZE`, `/UX-PERSONA:CREATE` |
| 5 | PM | Synthesize customer feedback | Feedback themes | `/PM-FEEDBACK:SYNTHESIZE` |
| 6 | Data | Analyze usage data for validation | Cohort analysis, funnels | `/DATA-FUNNEL:ANALYZE`, `/DATA-COHORT:ANALYZE` |
| 7 | PM | Prioritize features based on research | Prioritized backlog | `/PM-PRIORITIZE:SCORE` |
| 8 | PM | Update roadmap | Updated roadmap | `/PM-ROADMAP:UPDATE` |

**Metrics to measure improvement:**
- Time from research initiation to decision
- Research utilization rate (% of decisions citing research)
- Feature success rate (features that hit success metrics)
- Stakeholder confidence score

---

### Workflow 4: Bug Discovery → Resolution → Verification

| Step | Role | Task | Artifact | AI Skill Command |
|------|------|------|----------|------------------|
| 1 | QA | Discover and report bug | Bug report | `/QA-BUG:REPORT` |
| 2 | PM | Prioritize bug in backlog | Prioritized bug | `/PM-BACKLOG:REFINE` |
| 3 | Engineering | Debug and identify root cause | Root cause analysis | `/ENG-DEBUG:ANALYZE` |
| 4 | Engineering | Implement fix with tests | Code fix, regression tests | `/ENG-CODE:IMPLEMENT`, `/ENG-TEST:GENERATE` |
| 5 | Engineering | Create PR with description | PR with summary | `/ENG-PR:DESCRIBE` |
| 6 | Engineering | Code review | Review comments | `/ENG-PR:REVIEW` |
| 7 | QA | Verify fix and regression | Verification results | `/QA-REGRESSION:RUN` |
| 8 | Data | Monitor fix in production | Anomaly dashboard | `/DATA-DASHBOARD:BUILD` |

**Metrics to measure improvement:**
- Mean time to resolution (MTTR)
- Bug reopen rate
- Regression introduction rate
- Customer-reported vs. internally-found ratio

---

### Workflow 5: Experiment Design → Analysis → Decision

| Step | Role | Task | Artifact | AI Skill Command |
|------|------|------|----------|------------------|
| 1 | PM | Define experiment hypothesis | Experiment brief | `/PM-PRD:GENERATE` (experiment section) |
| 2 | Data | Design experiment and metrics | Experiment design, power analysis | `/DATA-ABTEST:ANALYZE` (design mode) |
| 3 | Data | Build tracking for experiment | Tracking plan | `/DATA-TRACKING:PLAN` |
| 4 | Engineering | Implement experiment variants | Feature flags, code | `/ENG-CODE:IMPLEMENT` |
| 5 | QA | Validate experiment implementation | Validation results | `/DATA-EVENTS:VALIDATE` |
| 6 | Data | Monitor experiment progress | Experiment dashboard | `/DATA-DASHBOARD:BUILD` |
| 7 | Data | Analyze results at significance | Analysis report, recommendation | `/DATA-ABTEST:ANALYZE` |
| 8 | PM | Make go/no-go decision | Decision documentation | `/PM-PRD:GENERATE` (results section) |

**Metrics to measure improvement:**
- Experiment velocity (experiments per month)
- Time from hypothesis to decision
- Decision confidence (statistical power achieved)
- Win rate (% of experiments with positive results shipped)

---

## Source Bibliography

### Product Management
- ProductPlan - "A Day in the Life of a Product Manager" (productplan.com/learn/day-in-the-life-product-manager)
- Atlassian - "Backlog Refinement" (atlassian.com/agile/scrum/backlog-refinement)
- Aha! Roadmaps - "Product Manager Responsibilities" (aha.io/roadmapping/guide/product-management)
- Productboard - "What Does a PM Do All Day" (productboard.com/blog/what-pm-does-all-day)
- Mountain Goat Software - "Product Backlog Refinement" (mountaingoatsoftware.com/blog/product-backlog-refinement-grooming)

### Software Engineering
- GitLab Engineering Handbook (handbook.gitlab.com/handbook/engineering/workflow)
- Google Engineering Practices - Code Review (google.github.io/eng-practices/review/reviewer)
- Swarmia - "Complete Guide to Code Reviews" (swarmia.com/blog/a-complete-guide-to-code-reviews)
- ADR GitHub Organization (adr.github.io)
- GitHub Docs - PR Templates (docs.github.com)

### UX/Product Design
- Nielsen Norman Group - Design Critiques and Interview Guides (nngroup.com/articles)
- Maze - Usability Testing Scripts (maze.co/guides/usability-testing/script)
- Figma - Design Handoff Best Practices (figma.com/best-practices/guide-to-developer-handoff)
- UXPin - Design System Documentation Guide (uxpin.com/studio/blog/design-system-documentation-guide)
- Interaction Design Foundation - Design Critiques (interaction-design.org/literature/topics/design-critiques)

### QA/Testing
- TestRail - Effective Test Cases Templates (testrail.com/blog/effective-test-cases-templates)
- BrowserStack - How to Write Bug Reports (browserstack.com/guide/how-to-write-a-bug-report)
- Postman Learning Center - Test Scripts (learning.postman.com/docs/tests-and-scripts)
- Smartsheet - Agile Testing Templates (smartsheet.com/content/agile-testing-templates)
- Scrum.org - Definition of Done vs Acceptance Criteria (scrum.org/resources)

### SEO/Content
- Ahrefs - Keyword Research Guide (ahrefs.com/blog/keyword-research)
- Clearscope - SEO Content Brief Creation (clearscope.io/blog/how-to-create-seo-content-brief)
- Search Engine Journal - SEO Maintenance Checklist (searchenginejournal.com)
- Content Harmony - Content Brief Templates (contentharmony.com/blog/content-brief-template-examples)
- Backlinko - Content Gap Analysis (backlinko.com/hub/seo/content-gap)

### Data/Analytics
- Amplitude - Tracking Plan Guide (amplitude.com/blog/create-tracking-plan)
- Avo - Tracking Plan Templates (avo.app/blog/9-free-tracking-plan-templates)
- Segment - Data Tracking Plan Academy (segment.com/academy/collecting-data)
- dbt Labs - Data Modeling Best Practices (getdbt.com/blog/modular-data-modeling-techniques)
- CXL - A/B Testing Statistics (cxl.com/blog/ab-testing-statistics)

### Source Agreement Notes
Most sources converge on the importance of **standardized templates** and **clear acceptance criteria** as foundational to quality. Where sources differ: Some Agile practitioners (Mountain Goat) emphasize that backlog refinement should be timeboxed strictly at 10% of sprint capacity, while others (Atlassian) are more flexible. For A/B testing, frequentist (CXL) and Bayesian (various) approaches are both endorsed—practical recommendation is to use both as cross-checks. Test automation frameworks (Cypress vs. Playwright) have strong partisan camps, but BrowserStack research suggests choosing based on team familiarity rather than marginal technical differences.
