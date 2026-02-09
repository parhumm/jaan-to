# Lessons: detect-pack

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before consolidating detect outputs to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions and patterns that improve consolidation quality:

- Ask "Were all detect skills run against the same commit?" when target.commit values differ across outputs
- Check if detect outputs are from the same session or accumulated over multiple runs
- Confirm with user whether partial runs should be labeled as such or re-run

## Edge Cases

Special cases to check and handle:

- **Partial runs**: When only 2-3 domains analyzed, clearly label overall score as "(partial)" and report coverage %. Don't extrapolate missing domain scores
- **Version mismatches**: Different detect skills may have been run with different rules_version values. Flag this in validation but don't refuse to consolidate
- **Stale outputs**: If target.commit doesn't match current HEAD, warn that outputs may be outdated. Still consolidate but add "(stale)" label
- **Evidence ID collisions**: If two skills accidentally produce the same E-ID (shouldn't happen with namespacing but check), flag as validation error and disambiguate
- **Empty domains**: A domain directory may exist but contain no findings (all informational). This is valid — include in heatmap with zeros

## Workflow

Process improvements learned from past runs:

- Validate frontmatter FIRST — catch stale/mismatched outputs before spending time aggregating
- Build the evidence index early — it reveals duplicate IDs and missing references
- Calculate domain scores independently before the overall score — per-domain is more actionable
- Sort unknowns backlog by confidence level (lowest first) then by severity (highest first)

## Common Mistakes

Things to avoid based on past feedback:

- Don't refuse to consolidate just because one domain is missing — partial analysis is valuable
- Don't recalculate individual domain scores — use the scores from the detect skill outputs
- Don't mix up "absence" evidence items with "missing evidence" — absence is intentional, missing is a validation error
- Don't present the overall score as a final quality judgment — it's a summary metric, not a grade
- Don't include detect skill internal metadata (tool versions, analysis timestamps) in the knowledge index — only include user-relevant information
