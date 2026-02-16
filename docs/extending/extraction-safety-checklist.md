# Extraction Safety Checklist

> Determine whether content in a SKILL.md is safe to extract to a reference file.
> Used by skill authors during creation and maintenance.

---

## SAFE to Extract (lookup/template content)

- Code templates and boilerplate blocks (>20 lines)
- Lookup tables (CWE mappings, ISTQB mappings, label definitions)
- Scoring rubrics and grading matrices
- Pattern libraries and example catalogs
- i18n tables and microcopy dictionaries
- Long checklists (>10 items) that are post-execution validation
- Format specifications (SARIF templates, OpenAPI examples)
- Consolidation summary display templates
- Directory layout ASCII trees (>10 lines)
- Multi-stack pattern comparison tables

## NOT SAFE to Extract (procedural/decision content)

- Decision tables that feed directly into the next procedure step (e.g., tech stack detection in `backend-service-implement`, tag routing in `qa-test-generate`)
- Entity extraction algorithms where the table IS the algorithm (e.g., `backend-task-breakdown` entity extraction)
- Workflow state machines where steps reference each other inline
- Pre-execution protocol content (already in shared reference)
- Cross-skill contract formats that downstream skills depend on (e.g., detect-dev SARIF format used by `sec-audit-remediate`)
- Compact tech detection tables (<10 rows, needed for every invocation)

## Rule of Thumb

If removing the content would require the AI to make an extra tool call mid-procedure to look up a value it needs for the NEXT step, do **NOT** extract it.

---

## How to Extract

1. Create `docs/extending/{skill-name}-reference.md` with header:
   ```markdown
   # {Skill Name} Reference Material

   > Extracted reference tables and templates for the `{skill-name}` skill.
   > This file is loaded by `{skill-name}` SKILL.md via inline pointers.
   ```

2. Move safe content to the reference file under clear `##` section headings

3. Replace extracted content in SKILL.md with an inline pointer:
   ```markdown
   > **Reference**: See `${CLAUDE_PLUGIN_ROOT}/docs/extending/{skill-name}-reference.md`
   > section "{Section Name}" for {brief description}.
   ```

4. Verify SKILL.md is under 500 lines (target) / 600 lines (hard cap)

5. Run `scripts/validate-skills.sh` to confirm all gates pass

---

## Related

- [Token Strategy](../token-strategy.md) — Layer 2 (invocation-level) optimization
- [create-skill.md](create-skill.md) — Reference Extraction Pattern section
