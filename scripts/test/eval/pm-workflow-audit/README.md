# pm-workflow-audit — Eval Harness

> The "create evals" foundation for `pm-workflow-audit` (research 76, EVAL-01/02/05). Grades **outcomes/state, not the path** the skill took, and is designed to report **pass^k** (success on all k trials), not pass@k.

## Three tiers (research 62's testing strategy)

| Tier | What | Runnable in CI | File |
|------|------|----------------|------|
| 1 Structural | frontmatter, line caps, naming, registration | yes | `scripts/validate-skills.sh`, `skill-standard-compliance-e2e.sh` |
| 2 Deterministic | reader contract + plan-structure grading | yes | `session-reader.test.sh`, `grade-plan.sh` |
| 3 Semantic | run the skill on fixtures, judge plan quality | maintainer / opt-in | `run.sh --semantic` (see below) |

## Run

```bash
# Tier 2 (deterministic, fast, no model calls):
bash scripts/test/eval/pm-workflow-audit/run.sh

# Grade a real generated plan:
bash scripts/test/eval/pm-workflow-audit/grade-plan.sh jaan-to/outputs/pm/workflow-audit/01-*/01-*.md
```

## Tier 3 — semantic (headless runner)

Tier 3 exercises the whole skill against fixture projects and judges the plan. It needs live model execution, so it is **not** wired into CI; run it locally over ≥5 trials and compute pass^k:

```bash
# For each fixture, N trials, headless:
claude -p "/jaan-to:pm-workflow-audit --depth=quick" --permission-mode acceptEdits \
  > /tmp/plan-$i.md
bash grade-plan.sh /tmp/plan-$i.md        # deterministic structure gate
# then judge quality with an LLM-judge from a different family, calibrated
# against the golden-expectations.md rubric (EVAL-03/04). Read traces (EVAL-06).
```

Report **pass^k** = (# trials passing ALL gates) / N. See `golden-expectations.md` for fixtures and the rubric.

## Fixtures

The reader test builds synthetic Claude/Codex stores in a throwaway `$HOME` (see `session-reader.test.sh`). Semantic fixtures (three project archetypes — bare vibe repo, partial-jaan-to, mature) are described in `golden-expectations.md`; build them under a temp `$HOME` + temp project dir the same way, then point `--project` at them.

## Why this exists

Per the build-order philosophy (`docs/guides/perfect-ai-workflow.md`): the simplest agent ships first (Slice 1), then evals (this harness, Slice 2), then a reliability-improvement pass against the baseline (Slice 2.5) — **before** any specialized agent is promoted from inline to a fanned-out subagent (Slice 3, eval-gated).
