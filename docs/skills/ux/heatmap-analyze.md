# /jaan-to-ux-heatmap-analyze

> Analyze heatmap CSV exports and screenshots to generate prioritized UX research reports.

---

## What It Does

Analyzes heatmap data by combining:
- **CSV data**: Element click/tap rankings from analytics tool exports
- **Screenshots**: Heatmap images for visual pattern analysis (Claude Vision)
- **HTML** (optional): Page source for resolving CSS selectors to human-readable element names

Produces a prioritized research report with cross-validated findings, confidence scores, and ICE-scored recommendations.

---

## Usage

**With file paths:**
```
/jaan-to-ux-heatmap-analyze path/to/clicks.csv path/to/heatmap.png path/to/page.html "Why are users bouncing?"
```

**With CSV + screenshot only:**
```
/jaan-to-ux-heatmap-analyze data/clicks.csv data/heatmap.png
```

**Interactive wizard:**
```
/jaan-to-ux-heatmap-analyze
```

---

## Supported Data Formats

### Format A: Aggregated Element Data

Ranked element exports from analytics tools. CSV has a metadata section followed by a data table:

```
Metadata:
  Project name, Date range, URL, Page views, Total clicks, Metric type, Behavior segment

Data:
  Rank | Button (CSS Selector) | Clicks | % of clicks
  1    | nav > button.next     | 1,444  | 9.73%
  2    | nav > button.prev     | 1,290  | 8.69%
  ...
```

### Format B: Raw Coordinate Data

Event-level exports with individual click coordinates:

```
timestamp | session_id | x_coordinate | y_coordinate | viewport_width | device_type
2026-01-27T14:23:45Z | sess_abc | 425 | 687 | 1920 | desktop
```

The skill auto-detects which format your CSV uses.

---

## What It Asks

| Question | When |
|----------|------|
| CSV format? | Only if auto-detection fails |
| Analysis goal? | Always (friction, CTA, comparison, other) |
| Multi-file mode? | When multiple CSVs provided |
| Proceed with report? | Before generation (HARD STOP) |
| Write to file? | Before writing output |
| Feedback? | After writing |

---

## Analysis Capabilities

### With Aggregated Data (Format A)

| Analysis | Available |
|----------|-----------|
| Element click distribution (Pareto) | Yes |
| CTA effectiveness | Yes |
| Navigation pattern analysis | Yes |
| Desktop vs mobile comparison | Yes |
| Behavior segment comparison | Yes |
| CSS-to-HTML element mapping | Yes (with HTML) |
| Dead element detection | Yes (with HTML) |
| Rage click detection | No (needs timestamps) |
| Scroll depth analysis | No (needs scroll data) |
| Hesitation zone detection | No (needs timing) |

### With Raw Data (Format B)

All of the above, plus rage click detection, scroll analysis, hesitation zones, and session flow reconstruction.

---

## Output

**Path**: `jaan-to/outputs/ux/heatmap/{slug}/report.md`

**Example**: `jaan-to/outputs/ux/heatmap/checkout-page/report.md`

**Contains**:
- Executive summary with top 3-5 findings
- Detailed findings organized by severity (Critical → Low)
- Evidence from each data source (CSV, Vision, HTML)
- Confidence scores with validation status
- ICE-scored recommendations
- Element mapping table (CSS selector → human-readable name)
- Device/segment comparison (if applicable)
- Limitations and methodology

---

## Tips

- Provide HTML alongside CSV for much richer analysis — CSS selectors alone are often unreadable
- Include multiple CSVs (desktop + mobile) for comparison insights
- State your research question for focused analysis instead of generic exploration
- Screenshots with very tall dimensions (>5000px) may reduce vision accuracy for lower sections
- Normalize by page views when comparing files with different traffic volumes

---

## Learning

This skill reads from:
```
jaan-to/learn/jaan-to-ux-heatmap-analyze.learn.md
```

Add feedback:
```
/to-jaan-learn-add jaan-to-ux-heatmap-analyze "Always check for thumb-zone bias in mobile data"
```

---

[Back to UX Skills](README.md)
