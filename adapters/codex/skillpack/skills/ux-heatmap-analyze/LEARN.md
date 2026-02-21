# Lessons: ux-heatmap-analyze

> Last updated: 2026-02-03

Accumulated lessons from deep research and past executions. Read this before analyzing heatmaps to apply learned improvements.

---

## Better Questions

Questions to ask during information gathering:

- What business decision will this analysis inform? (redesign, checkout optimization, navigation restructure)
- What user segment does this data represent? (new vs returning, paid vs organic, geography)
- When multiple CSVs are provided, which comparison matters most to the stakeholder?
- Have there been recent design changes that might explain unusual patterns?
- Are there known conversion metrics to correlate with heatmap findings?

## Edge Cases

Special cases to check and handle:

- Aggregated CSV exports have a metadata header section before the data table; skip non-data rows when parsing
- React/Next.js/Angular apps generate opaque CSS class names (css-*, sc-*, ng-*); selector resolution requires HTML context
- Very tall screenshots (>5000px) may lose detail in vision analysis; note reduced confidence for below-fold findings
- Mobile tap data includes thumb-zone bias; bottom 40% of screen naturally gets more taps
- Behavior segment files (quick backs, excessive scrolling) represent filtered subsets, not full traffic; always state segment scope
- When page views differ vastly between files (e.g., 7,195 vs 16), percentage comparisons are misleading; use absolute counts per 1,000 page views
- CSV element percentages may not sum to 100% due to overlapping elements or multi-click sessions

## Workflow

Process improvements learned from research and past runs:

- Always perform vision analysis BEFORE CSV analysis to avoid anchoring bias
- Place heatmap images before text in the analysis context for optimal Vision performance
- For aggregated data: Pareto analysis (top 20% elements getting 80% clicks) is the highest-value first analysis
- Cross-reference CSS selectors with HTML before presenting findings; stakeholders need human-readable element names, not selectors
- Always state data limitations upfront in the report; do not imply capabilities the data does not support
- When comparing device types, normalize by page views before comparing interaction counts
- Two-pass cross-reference validation reduces false positives by 40-60%; always apply when multiple data sources available

## Common Mistakes

Things to avoid based on research findings:

- Never claim rage click or hesitation detection from aggregated element-click data; these require raw timestamps and coordinates
- Never assume scroll depth from click heatmap screenshots; scroll and click are separate heatmap types
- Never compare absolute click counts between desktop and mobile without normalizing by page views
- Never present a finding without stating which data source (CSV, screenshot, HTML) supports it
- Never assign confidence above 0.80 to vision-only findings; image-only analysis maxes at 0.80
- Never hallucinate element functionality from CSS selectors alone; use HTML context or flag as "unresolved"
- Do not treat percentage-of-clicks as engagement rate; 5% of 50,000 clicks is very different from 5% of 99 clicks
- Do not use brand names, project names, or URLs from sample/test data in reports; generalize to page/feature descriptions
