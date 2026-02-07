---
name: learn-report
description: Generate learning insights report from accumulated LEARN.md files
args:
  format:
    description: Output format (markdown or json)
    default: markdown
---

Generate a comprehensive learning insights report by analyzing all accumulated lessons in the project's learning directory.

**Instructions:**

1. Run the learning summary script:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/learning-summary.sh --format={{format}}
   ```

2. Display the complete output to the user

3. Provide a brief analysis of the results, highlighting:
   - Skills with the most accumulated learning
   - Coverage gaps (skills missing Common Mistakes or Edge Cases)
   - Overall learning health (total lessons, total files)

4. Suggest actionable next steps based on the gaps identified

**Expected Output:**
- If format=markdown: Formatted learning report with tables and recommendations
- If format=json: Structured JSON with lesson counts, mistakes, and edge cases

**Note:** This report scans all `.learn.md` files in the project's learning directory (default: `jaan-to/learn/`). If no files exist, the report will indicate learning system is not yet in use.
