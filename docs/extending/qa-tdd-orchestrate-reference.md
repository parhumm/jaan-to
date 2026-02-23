# qa-tdd-orchestrate Reference

> Extracted reference material for the `qa-tdd-orchestrate` skill. Contains agent prompt templates, phase gate logic, and handoff manifest schemas.

---

## Agent Prompt Templates

### RED Agent Prompt

```
You are a TEST WRITER in a TDD RED phase. Your ONLY job is to write a failing test.

CONTEXT:
- Feature requirement: {requirement_text}
- Test framework: {framework} (e.g., Vitest, Jest, pytest, PHPUnit, Go testing)
- Test file naming: {convention} (e.g., *.test.ts, *_test.go)
- Existing test patterns: {sample test file content if available}

RULES:
- Write ONE test that describes expected behavior for: {component_name}
- The test MUST fail when run (there is no implementation yet)
- Use concrete values, not placeholders
- Follow existing test patterns in the project
- DO NOT read or reference any implementation files (src/**, lib/**)
- DO NOT plan the implementation
- DO NOT write more than one test at a time

OUTPUT:
- Write the test file to: {test_file_path}
- Report the file path when done
```

**Exclusion list**: Implementation plans, existing source code (`src/**`, `lib/**`), scaffold output, any file not in test directories.

### GREEN Agent Prompt

```
You are an IMPLEMENTER in a TDD GREEN phase. Your ONLY job is to make the failing test pass.

CONTEXT:
- Failing test file: {test_file_path}
- Test file content: {content from handoff-red.json allowlist}
- Test runner output: {stdout/stderr from handoff-red.json}
- Test command: {test_command}

RULES:
- Write the MINIMAL code needed to make the test pass
- Do NOT over-engineer or add features beyond what the test requires
- Do NOT refactor or optimize
- Do NOT read the requirements or feature description
- Follow existing code patterns if visible from test imports

OUTPUT:
- Write implementation file(s)
- Report file path(s) when done
```

**Exclusion list**: RED agent's prompt/reasoning, requirements text, feature description, architecture plans.

### REFACTOR Agent Prompt

```
You are a REFACTORER in a TDD REFACTOR phase. Your job is to improve code quality.

CONTEXT:
- Implementation files: {file_paths from handoff-green.json}
- Test files: {test_file_paths}
- All tests currently PASS
- Test command: {test_command}

RULES:
- Improve code quality: extract patterns, apply DRY, improve naming
- Do NOT change behavior — all existing tests must still pass
- Do NOT add new features or tests
- Run all tests after refactoring to verify no regression
- If any test fails after refactoring, revert changes

OUTPUT:
- Modified file path(s) or "No refactoring needed"
- Confirm all tests still pass
```

**Exclusion list**: RED and GREEN agent prompts/reasoning, requirements interpretation.

---

## Phase Gate Verification

### RED -> GREEN Gate

1. Run test command: `{test_command} {test_file}`
2. Assert exit code != 0 (test FAILS)
3. Assert test output contains failure message (not a syntax error)
4. Write `handoff-red.json` manifest
5. Build GREEN prompt ONLY from manifest-listed artifacts

### GREEN -> REFACTOR Gate

1. Run test command: `{test_command} {test_file}`
2. Assert exit code == 0 (test PASSES)
3. Write `handoff-green.json` manifest
4. Build REFACTOR prompt from all code + test files

### REFACTOR -> Done Gate

1. Run ALL tests: `{test_command}`
2. Assert exit code == 0 (ALL tests PASS)
3. If any test fails: revert refactoring, keep GREEN state

---

## Handoff Manifest Schema

### handoff-red.json

```json
{
  "phase": "red",
  "timestamp": "ISO-8601",
  "component": "{component_name}",
  "cycle": 1,
  "test_file": "{relative/path/to/test.test.ts}",
  "runner_output": "{stdout/stderr truncated to 2000 chars}",
  "exit_code": 1,
  "allowlist": [
    "{relative/path/to/test.test.ts}"
  ]
}
```

### handoff-green.json

```json
{
  "phase": "green",
  "timestamp": "ISO-8601",
  "component": "{component_name}",
  "cycle": 1,
  "implementation_files": [
    "{relative/path/to/impl.ts}"
  ],
  "test_file": "{relative/path/to/test.test.ts}",
  "runner_output": "{stdout/stderr truncated to 2000 chars}",
  "exit_code": 0,
  "allowlist": [
    "{relative/path/to/test.test.ts}",
    "{relative/path/to/impl.ts}"
  ]
}
```

### Allowlist Verification Procedure

Before spawning the next phase agent:

1. Read the handoff manifest from previous phase
2. Extract `allowlist` array
3. Build the new agent's Task prompt using ONLY content from allowlisted file paths
4. Verify: scan the constructed prompt for any content not traceable to an allowlisted file
5. If non-manifest content found: ABORT cycle (isolation violation)

This is the sole gate — no "reasoning scan" needed. If it's not in the manifest, it doesn't enter the prompt.

---

## Double-Loop State Tracking

### Outer Loop State

```json
{
  "acceptance_criteria": [
    {
      "id": "AC-1",
      "text": "{criterion text}",
      "status": "passing|failing|pending",
      "inner_cycles_completed": 3
    }
  ],
  "current_ac_index": 0
}
```

### Inner Loop State

```json
{
  "component": "{component_name}",
  "ac_id": "AC-1",
  "cycles": [
    {
      "cycle": 1,
      "red": {"status": "pass", "test_file": "..."},
      "green": {"status": "pass", "impl_files": ["..."]},
      "refactor": {"status": "pass", "modified_files": ["..."]}
    }
  ],
  "same_test_failures": 0,
  "total_cycles": 1
}
```

### Escalation Rules

| Condition | Action |
|-----------|--------|
| Same test fails 3 times with same error | AskUserQuestion with error details |
| Total cycles exceed max (default 10) | AskUserQuestion: continue or stop? |
| Acceptance test still fails after all inner cycles | AskUserQuestion with diagnostic info |
| Isolation violation detected | Abort cycle, report violation |
