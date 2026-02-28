# pm-research-about Reference

> Extracted reference material for the `pm-research-about` skill.
> Includes clarifying question templates, lookup tables, and format specifications.
> For methodology reference (scoring rubrics, agent capacity, wave templates), see `research-methodology.md`.

---

## Clarifying Questions Template

When the topic is unclear or broad, ask 3-5 of these questions. Each offers **3 options + 1 recommendation**:

> **Q1: What's your primary goal?**
> - [A] Learning fundamentals <- *Recommended for beginners*
> - [B] Implementation guide
> - [C] Comparison with alternatives
>
> **Q2: What depth level?**
> - [A] Overview (high-level concepts)
> - [B] Intermediate (patterns & practices) <- *Recommended*
> - [C] Advanced (internals & edge cases)
>
> **Q3: What's the context?**
> - [A] New project
> - [B] Existing codebase <- *Recommended if migration mentioned*
> - [C] General knowledge
>
> **Q4: Which aspect matters most?**
> - [A] Performance
> - [B] Developer experience <- *Recommended*
> - [C] Ecosystem & community
>
> **Q5: Include comparisons?**
> - [A] Yes, with {X} and {Y} <- *Recommended*
> - [B] Brief mentions only
> - [C] No comparisons needed

---

## Research Size Options

| Size | Sources | Agents | Best For |
|------|---------|--------|----------|
| [A] Quick (20) | ~20 sources | 3 agents | Quick overview <- *Recommended for simple topics* |
| [B] Standard (60) | ~60 sources | 7 agents | Solid research <- *Recommended* |
| [C] Deep (100) | ~100 sources | 10 agents | Comprehensive coverage |
| [D] Extensive (200) | ~200 sources | 14 agents | In-depth analysis |
| [E] Exhaustive (500) | ~500 sources | 29 agents | Maximum coverage |

**Default**: Standard (60) if user doesn't specify or just presses enter.

---

## Approval Mode Options

| Mode | Description |
|------|-------------|
| [A] Auto | Run all waves automatically, show final document only <- *Faster* |
| [B] Summary | Show brief progress after each wave, no approval needed |
| [C] Interactive | Ask for approval at each major step <- *Default* |

**Default**: Interactive (C) if user doesn't specify.

---

## README Index Update Format

When updating `$JAAN_OUTPUTS_DIR/research/README.md`:

1. **Add to Summary Index table:**
   Find the table under `## Summary Index` and add new row:
   ```markdown
   | [{NN}]({filename}) | {Title} | {Brief one-line description} |
   ```

2. **Add to Quick Topic Finder:**
   Find the most relevant section and add link:
   ```markdown
   - [{filename}]({filename})
   ```

---

## Git Commit Template (Research)

```bash
git add $JAAN_OUTPUTS_DIR/research/{filename} $JAAN_OUTPUTS_DIR/research/README.md
git commit -m "$(cat <<'EOF'
docs(research): Add {title}

Research on {topic} covering:
- {key point 1}
- {key point 2}
- {key point 3}

Sources: {N} sources consulted
Research method: Adaptive 5-wave approach

Generated with 💓 [Jaan.to](https://jaan.to)
EOF
)"
```

---

## Git Commit Template (Add to Index)

```bash
git add $JAAN_OUTPUTS_DIR/research/README.md $JAAN_OUTPUTS_DIR/research/{filename}
git commit -m "$(cat <<'COMMITMSG'
docs(research): Add {title} to index

{If URL: Fetched from: {URL}}
Category: {category}

Generated with 💓 [Jaan.to](https://jaan.to)
COMMITMSG
)"
```
