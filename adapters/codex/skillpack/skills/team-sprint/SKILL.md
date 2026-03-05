---
name: team-sprint
description: Run a full development sprint cycle from planning to PR. Use when advancing project with automated skill orchestration.
allowed-tools: >-
  Read, Glob, Grep,
  Write($JAAN_OUTPUTS_DIR/**),
  Bash(git checkout:*), Bash(git pull:*), Bash(git branch:*),
  Bash(git add:*), Bash(git commit:*), Bash(git push:*),
  Bash(git log:*), Bash(git diff:*),
  Bash(gh pr create:*), Bash(gh pr view:*),
  Bash(cp:*),
  Skill(pm-sprint-plan), Skill(team-ship),
  Skill(release-iterate-changelog),
  Edit(ROADMAP.md), Edit(jaan-to/config/settings.yaml)
argument-hint: "[cycle-number] [--focus spec|scaffold|code|test|audit] [--tasks 'task1,task2']"
disable-model-invocation: true
user-invocable: true
license: PROPRIETARY
---

# team-sprint

> Full development sprint cycle — plan, execute, verify, and ship via PR.

## Context Files

- `$JAAN_CONTEXT_DIR/config.md` - Project configuration
- `$JAAN_CONTEXT_DIR/boundaries.md` - Trust rules
- `$JAAN_TEMPLATES_DIR/jaan-to-team-sprint.template.md` - Cycle report template
- `$JAAN_LEARN_DIR/jaan-to-team-sprint.learn.md` - Past lessons (loaded in Pre-Execution)
- `$JAAN_CONTEXT_DIR/tech.md` - Tech context (if exists)
- `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md` - Language resolution protocol

## Input

**Arguments**: $ARGUMENTS

Parse from arguments:
1. **Cycle number** — positive integer (e.g., `5`). If omitted, auto-detect by counting `gap-reports/*-cycle/` directories + 1. If no gap-reports exist, default to `1`.
2. **--focus** — optional scope filter: `spec`, `scaffold`, `code`, `test`, `audit`. Passed through to pm-sprint-plan.
3. **--tasks** — optional comma-separated task keywords. Passed through to pm-sprint-plan.

---

## Pre-Execution Protocol

**MANDATORY** — Read and execute ALL steps in: `${CLAUDE_PLUGIN_ROOT}/docs/extending/pre-execution-protocol.md`
Skill name: `team-sprint`
Execute: Step 0 (Init Guard) → A (Load Lessons) → B (Resolve Template) → C (Offer Template Seeding)

Also read context files if available:
- `$JAAN_CONTEXT_DIR/tech.md` — Tech stack context
- `$JAAN_CONTEXT_DIR/config.md` — Project configuration

If the file does not exist, continue without it.

### Language Settings

Read and apply language protocol: `${CLAUDE_PLUGIN_ROOT}/docs/extending/language-protocol.md`
Override field for this skill: `language_team-sprint`

> **Language exception**: Git operations, skill names, YAML, and technical terms remain in English.

---

## Thinking Mode

ultrathink

Use extended reasoning for:
- Validating cycle number and branch strategy
- Orchestrating the planning → execution → verification pipeline
- Analyzing post-cycle results for gap reporting
- Evaluating ROADMAP completion accuracy

---

# PHASE 0: Pre-flight

## Step 0.1: Verify Environment

1. **Git status**: Check working tree is clean. If uncommitted changes exist, warn user and ask to proceed or stash.
2. **Current branch**: Must be on `dev` or a cycle branch. If not, ask user to switch.
3. **jaan-to plugin**: Check `${CLAUDE_PLUGIN_ROOT}` resolves and contains `skills/`. If not → "jaan-to plugin not found. Install or update the plugin."

## Step 0.2: Determine Cycle Number

If cycle number provided in arguments, use it.

If not:
```bash
# Count existing cycle gap reports
CYCLE_COUNT=$(ls -d gap-reports/*-cycle 2>/dev/null | wc -l | tr -d ' ')
CYCLE_NUMBER=$((CYCLE_COUNT + 1))
```

If no gap-reports directory exists, default to cycle 1.

## Step 0.3: Create Cycle Branch

```bash
CYCLE_BRANCH="cycle/$(printf '%02d' $CYCLE_NUMBER)"
git checkout dev
git pull origin dev
git checkout -b "$CYCLE_BRANCH"
```

Confirm: "Created branch `$CYCLE_BRANCH` from `dev`."

## Step 0.4: Security Baseline

Verify no secrets in tracked files before any commits:
```bash
git diff --name-only HEAD 2>/dev/null | xargs grep -liE '(sk-|ghp_|token=|password=|api_key=|secret=)' 2>/dev/null || true
```

If matches found → **STOP**: "Security risk detected. Remove secrets before proceeding."

---

# PHASE 1: Planning

## Step 1.1: Invoke Sprint Planning

Pass through user arguments to pm-sprint-plan:

```
/pm-sprint-plan {--focus_if_provided} {--tasks_if_provided}
```

This invokes the full pm-sprint-plan workflow:
1. Reads project state (ROADMAP, gap-reports, scorecards, tech.md)
2. Calculates progress matrix (if data available)
3. Classifies bottleneck
4. Builds execution queue
5. Presents sprint plan with HARD STOP for approval
6. Writes sprint plan artifact

**Wait for pm-sprint-plan to complete.** The approved sprint plan artifact will be at `$JAAN_OUTPUTS_DIR/pm/sprint-plan/`.

## Step 1.2: Verify Sprint Plan Artifact

After pm-sprint-plan completes, read the sprint plan artifact:
```bash
SPRINT_PLAN=$(ls -t $JAAN_OUTPUTS_DIR/pm/sprint-plan/*/\*.md 2>/dev/null | head -1)
```

Verify it contains:
- [ ] YAML frontmatter with `type: sprint-plan`
- [ ] `queue` array with at least 1 item
- [ ] `closing_skills` array

If verification fails → "Sprint plan artifact is invalid. Re-run `/pm-sprint-plan`."

---

# PHASE 2: Execution

## Step 2.1: Invoke Team Execution

Pass the sprint plan to team-ship:

```
/team-ship --track sprint
```

team-ship reads the sprint plan artifact and:
1. Parses execution queue and task groups
2. Spawns Agent Teams per role
3. Executes skills in dependency order
4. Runs verification gates between groups
5. Records checkpoint for resume

**Wait for team-ship to complete.** This is the autonomous execution phase.

## Step 2.2: Commit Execution Results

After team-ship completes, stage and commit:

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(cycle): complete cycle {CYCLE_NUMBER} execution

Sprint plan executed via team-sprint.
Skills completed: {completed_count}/{total_count}
EOF
)"
```

---

# PHASE 3: Post-Cycle

## Step 3.1: Mark ROADMAP Completion

For each successfully completed queue item:
1. Read the `roadmap_ref` from the sprint plan
2. Find the matching `- [ ]` line in ROADMAP.md
3. Replace with `- [x]` and append commit hash

```bash
# Example: mark item complete
# - [ ] Implement OAuth login → - [x] Implement OAuth login (abc1234)
```

Commit ROADMAP changes:
```bash
git add ROADMAP.md
git commit -m "docs(roadmap): mark cycle ${CYCLE_NUMBER} items complete"
```

## Step 3.2: Write Cycle Gap Report

Create gap report for this cycle at `gap-reports/${CYCLE_NUMBER}-cycle/gap-report.md`:

```markdown
# Cycle {CYCLE_NUMBER} Gap Report

## Summary
- Sprint focus: {focus}
- Queue items: {completed}/{total} completed
- Skills executed: {skill_list}

## Completed
{list of completed items with skill and output paths}

## Incomplete
{list of items that failed or were skipped, with reasons}

## New Gaps Discovered
{gaps found during execution that weren't in the original plan}

## Recommendations for Next Cycle
{suggested focus and priority items for cycle N+1}
```

Commit:
```bash
git add gap-reports/
git commit -m "docs(gaps): add cycle ${CYCLE_NUMBER} gap report"
```

## Step 3.3: Update Changelog

Invoke:
```
/release-iterate-changelog
```

Commit changelog updates separately.

## Step 3.4: Create PR to dev

```bash
git push -u origin "$CYCLE_BRANCH"

gh pr create \
  --base dev \
  --title "feat(cycle): cycle ${CYCLE_NUMBER} — {focus_summary}" \
  --body "$(cat <<'EOF'
## Cycle {CYCLE_NUMBER} Summary

### Sprint Focus
{focus_area} — {bottleneck_stage}

### Execution Queue
{completed_count}/{total_count} items completed

### Skills Used
{skill_list_with_status}

### Changes
{file_change_summary}

### Gap Report
See gap-reports/{CYCLE_NUMBER}-cycle/gap-report.md

---
Sprint plan: $JAAN_OUTPUTS_DIR/pm/sprint-plan/{id}/
Executed via: /team-sprint
EOF
)"
```

Present PR URL to user.

---

# PHASE 4: Review & Close

## Step 4.1: Present Cycle Summary

```
CYCLE {CYCLE_NUMBER} — COMPLETE
────────────────────────────────
Branch: {CYCLE_BRANCH}
PR: #{pr_number} ({pr_url})

EXECUTION RESULTS
─────────────────
Completed: {completed_count}/{total_count}
Skills: {skill_names}
Focus: {focus_area}

PROGRESS DELTA (if available)
─────────────────────────────
Specification: {before}% → {after}%
Scaffold:      {before}% → {after}%
Code:          {before}% → {after}%
Tests:         {before}% → {after}%
Infra:         {before}% → {after}%

NEXT STEPS
──────────
Bottleneck: {next_bottleneck}
Suggested: /team-sprint {CYCLE_NUMBER + 1} --focus {suggested_focus}
```

## Step 4.2: Capture Feedback

> "Any feedback on this sprint cycle? [y/n]"

**If yes:**
1. Capture feedback
2. `/jaan-to:learn-add team-sprint "{feedback}"`

**If no:** Cycle complete.

---

## Skill Alignment

- Full lifecycle orchestrator spanning multiple roles
- Composes pm-sprint-plan (planning) + team-ship (execution)
- Owns git lifecycle (branch creation, commits, PR)
- Two-phase with HARD STOP (inherited from pm-sprint-plan)
- Generic across tech stacks (reads tech.md)
- Follows pre-execution protocol (Steps 0→A→B→C)
- Follows team-{action} naming pattern (matches team-ship)

## Definition of Done

- [ ] Cycle branch created from dev
- [ ] Sprint plan generated and approved via pm-sprint-plan
- [ ] Execution completed via team-ship --track sprint
- [ ] ROADMAP items marked complete
- [ ] Gap report written
- [ ] CHANGELOG updated
- [ ] PR created to dev
- [ ] Cycle summary presented to user
- [ ] User feedback captured (if given)
