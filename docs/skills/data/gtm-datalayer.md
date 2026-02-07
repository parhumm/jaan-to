# /jaan-to:data-gtm-datalayer

> Generate production-ready GTM tracking code with enforced naming conventions.

---

## What It Does

Generates Google Tag Manager tracking code for:
- **Click tracking** (HTML attributes or dataLayer.push)
- **Impression tracking** (dataLayer.push for visibility events)

Enforces lowercase-kebab-case naming and suggests improvements for clarity.

---

## Usage

**Interactive wizard:**
```
/jaan-to:data-gtm-datalayer
```

**With PRD:**
```
/jaan-to:data-gtm-datalayer jaan-to/outputs/pm/user-auth/prd.md
```

**With description:**
```
/jaan-to:data-gtm-datalayer "track subscription modal impressions and button clicks"
```

---

## Tracking Types

### 1. Click (HTML Attributes)

For simple click tracking without flows:

```html
<button data-al-feature="player" data-al-item="pause">Pause</button>
```

### 2. Click (dataLayer)

For flow-based click tracking:

```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "player",
    item: "play",
    action: "Click"
  },
  _clear: true
});
```

### 3. Impression

For visibility/exposure events:

```javascript
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "player",
    item: "modal-purchase"
  },
  _clear: true
});
```

---

## What It Asks

| Question | When |
|----------|------|
| Tracking type? | Always |
| Feature name? | Always |
| Item name? | Always |
| Action? | Click-dataLayer only |
| Additional params? | Optional |

---

## Naming Rules

The skill enforces consistent naming:

| Input | Converted |
|-------|-----------|
| "Play Button" | `play-button` |
| "modalPurchase" | `modal-purchase` |
| "NAV_BAR" | `nav-bar` |

Unclear names (like "btn1") prompt for clarification.

---

## Output

**Path**: `jaan-to/outputs/data/gtm/{slug}/tracking.md`

**Example**: `jaan-to/outputs/data/gtm/player-play/tracking.md`

**Contains**:
- Overview (feature, item, type)
- Tracking code (copy-paste ready)
- Example usage
- Implementation notes

---

## Example

**Input**:
```
/jaan-to:data-gtm-datalayer
```

**Questions**:
1. Type? → `click-datalayer`
2. Feature? → `subscription`
3. Item? → `upgrade-button`
4. Action? → `Click` (default)
5. Params? → `source=modal`, `count=3`, `premium=true`

**Output** (ES5 typed values):
```javascript
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "subscription",
    item: "upgrade-button",
    action: "Click",
    params: {
      source: "modal",
      count: 3,
      premium: true,
    }
  },
  _clear: true
});
```

Param types are auto-detected:
- `"modal"` → string (quotes)
- `3` → int (no quotes)
- `true` → bool (no quotes)

---

## Tips

- Use PRD input to generate all tracking for a feature at once
- Always include impression + click tracking for modals
- Don't forget non-happy paths (close, dismiss, cancel)
- Test with GTM Preview Mode before deploying

---

## Learning

This skill reads from:
```
jaan-to/learn/data-gtm-datalayer.learn.md
```

Add feedback:
```
/jaan-to:learn-add data-gtm-datalayer "Always ask about error states"
```

---

[Back to Data Skills](README.md)
