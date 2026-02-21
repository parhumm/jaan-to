# Lessons: detect-product

> Last updated: 2026-02-08

Accumulated lessons from past executions. Read this before detecting product reality to avoid past mistakes and apply learned improvements.

---

## Better Questions

Questions and patterns that improve detection quality:

- Ask "Is this a SaaS product, open-source tool, or internal app?" — the monetization model depends heavily on this
- Check if pricing pages exist in a separate marketing site (not in the main repo)
- Ask about feature flag usage when flags detected but no clear provider identified

## Edge Cases

Special cases to check and handle:

- **SaaS vs open-source distinction**: Open-source projects may have Stripe integration for sponsors/donations, not product monetization. Check context before classifying
- **Freemium without code gates**: Some freemium models enforce limits server-side only — the frontend repo may show no entitlement gates. Mark as Uncertain, not "no monetization"
- **Feature flag ambiguity**: Flags named `FF_NEW_DASHBOARD` might be gradual rollout (temporary) vs permanent entitlement gates. Check for tier/plan references nearby
- **Marketing site in same repo**: Pricing pages in `marketing/` or `landing/` directories are copy evidence but don't prove enforcement. Always require separate code path evidence
- **A/B testing vs feature gates**: Analytics event properties like `variant` or `experiment` indicate A/B tests, not permanent features. Don't count as "confirmed features"
- **Internal tools**: Admin panels and internal dashboards may not have monetization — this is normal, not a finding

## Workflow

Process improvements learned from past runs:

- Start with route scanning — it reveals the product surface area quickly
- Cross-reference pricing copy with entitlement gates — mismatches are high-value findings
- Scan analytics events early — they reveal what the team considers important enough to track
- Group features by domain/area before assessing — individual feature evidence is more meaningful in context

## Common Mistakes

Things to avoid based on past feedback:

- Don't assume "no Stripe" = "no monetization" — there are many payment providers and custom solutions
- Don't treat analytics SDK presence as proof of comprehensive tracking — check actual event coverage
- Don't flag absence of feature flags as a problem — many successful products don't use them
- Don't present inferred features with high confidence — if evidence is only heuristic, say so
- Don't list test/mock payment flows as real monetization evidence
