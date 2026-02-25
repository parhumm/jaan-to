---
title: "Security Strategy"
sidebar_position: 99
---

# Security Strategy

> Internal security reference for jaan-to developers, skill creators, and contributors.

---

## Security Principles

These principles apply to all jaan-to development.

1. **Least Privilege**: Skills declare the minimum `allowed-tools` needed. No bare `Bash`, `Edit`, or `Write`.
2. **Allowlist Over Blocklist**: Specify what IS allowed, not what is forbidden. Blocklists are bypassable (CVE-2025-66032 proved this with 8+ shell parsing tricks).
3. **Canonical Path Validation**: Always use `realpath` before path operations. String-based prefix matching is insufficient (CVE-2025-54794).
4. **Defense in Depth**: Guardrails + permissions + hooks + skill-level restrictions. No single layer is relied upon alone.
5. **Human in the Loop**: HARD STOP before all writes. No autonomous destructive actions.

---

## Skill Security Checklist

Required for every new or modified skill:

- [ ] `allowed-tools` uses specific commands, not wildcards
  - `Bash(npm test:*)` not `Bash(npm:*)`
  - `Bash(gh secret set:*)` not `Bash(gh:*)`
- [ ] `Write()` scoped to `$JAAN_OUTPUTS_DIR/{role}/{domain}/**` or explicit project paths
- [ ] `Edit()` scoped to specific paths (never bare `Edit`)
- [ ] No `Bash(node:*)`, `Bash(npx:*)`, or `Bash(npm install:*)` without justification
- [ ] No `Read(.env*)` or `Read(**/secrets/*)`
- [ ] HARD STOP before any file write
- [ ] Privacy sanitization if skill sends data externally (GitHub, web)
- [ ] No hardcoded paths, credentials, or tokens

---

## Shell Script Security Standards

For all scripts in `scripts/`:

### Required Patterns

```bash
#!/bin/bash
set -euo pipefail    # Always. No exceptions.
```

- Parse JSON with `python3 json.load()` or `jq` — never `eval`
- Validate paths with `validate_path()` + `_canonical_path()` check against `$PROJECT_DIR`
- Use `mktemp` for temp files (never PID-based `$$`)
- Clean up temp files via `trap cleanup EXIT`
- Quote all shell variables: `"$VAR"` not `$VAR`
- Escape sed substitutions: `sed 's/[&/\]/\\&/g'`

### Forbidden Patterns

- `eval` — command injection risk
- `exec` — process replacement risk
- Backtick substitution — use `$()` instead
- `source` of user-controlled files — only source plugin scripts
- `curl | sh` — remote code execution
- `chmod 777` — overly permissive
- `$IFS` manipulation — injection vector (CVE-2025-66032)

---

## Hook Security Standards

For all hooks in `hooks/hooks.json`:

- Hook commands must be static paths (`${CLAUDE_PLUGIN_ROOT}/scripts/...`)
- Never pass user input directly into hook command strings
- PreToolUse hooks use allowlist-first approach
- PostToolUse hooks must be non-blocking (exit 0)
- JSON stdin must be parsed safely via `python3 json.load()` (never interpolated into commands)
- Debounce files use `$TMPDIR` or `mktemp`

---

## Template Security Standards

For `scripts/lib/template-processor.sh`:

| Directive | Security Rule |
|-----------|--------------|
| `{{env:VAR}}` | Only resolves allowlisted env vars (`HOME`, `USER`, `SHELL`, `LANG`, `TERM`, `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `PROJECT_DIR`, `PLUGIN_DIR`) |
| `{{import:path}}` | Validates path has no `..` or `/` prefix, then canonical check stays within project |
| `{{config:key}}` | Reads from validated config cache only |
| All substitutions | Values escaped for sed before replacement |

---

## Path Validation Pattern

All config-derived paths must use this validation chain:

```
get_config() → raw value
    ↓
validate_path() → reject ".." and absolute paths
    ↓
resolve_path() → expand $PLUGIN_ROOT, $PROJECT_DIR, ~
    ↓
_canonical_path() → realpath (or python3 fallback)
    ↓
prefix check → canonical must start with project_canonical
    ↓
use path
```

This is implemented in `get_validated_path()` in `scripts/lib/config-loader.sh`.

**macOS compatibility**: `realpath` may not be available on stock macOS. The `_canonical_path()` helper falls back to `python3 -c "import os; print(os.path.realpath(...))"`.

---

## CVE Lessons Learned

Past Claude Code CVEs and what they teach us:

| CVE | CVSS | Lesson | Our Mitigation |
|-----|------|--------|----------------|
| CVE-2025-54794 | 7.7 | Path validation must be canonical (`realpath`), not string prefix | `get_validated_path()` with `_canonical_path()` |
| CVE-2025-54795 | 8.7 | Command injection via quote escaping in echo | PreToolUse hook detects injection patterns |
| CVE-2025-66032 | — | Blocklists bypassable via `$IFS`, aliases, variable expansion | Allowlist-first in skill `allowed-tools` |

---

## Threat Model

| Threat | Attack Vector | Mitigation |
|--------|--------------|------------|
| Malicious `settings.yaml` | Path traversal in cloned repo | `validate_path()` + canonical check |
| Prompt injection via project files | Crafted markdown/code influences AI | Skills operate in scoped tool boundaries |
| Supply chain (hallucinated packages) | `npm install` of non-existent package | Narrow `Bash(npm:*)` to specific commands |
| Credential leakage via templates | `{{env:ANTHROPIC_API_KEY}}` | Env var allowlist, only safe vars |
| Credential leakage via issue reports | Paths, tokens in bug reports | Privacy sanitization (paths, credentials, connection strings) |
| Overprivileged skills | Broad tool access | Least-privilege `allowed-tools`, HARD STOP gates |
| Temp file symlink attacks | Predictable `/tmp/` filenames | `mktemp` with unpredictable names |
| Remote code execution | `curl | sh` in Bash commands | PreToolUse hook blocks piped execution |
| Prompt injection via web content | Crafted URLs/pages influence AI output | Threat scan + Safety Rules in skills processing WebFetch/WebSearch |
| Unicode hidden character attacks | Invisible chars encode instructions | Mandatory pre-processing strips hidden chars before analysis |
| ANSI-C / brace expansion bypass | Shell tricks assemble blocked commands | PreToolUse hook detects obfuscation patterns |

---

## Untrusted Input Processing Standard

Skills that process external or user-authored content must implement threat scanning. The shared reference at `docs/extending/threat-scan-reference.md` defines:

- **6 detection categories**: Prompt injection, embedded commands, credential probing, path traversal, hidden characters, obfuscation
- **3-tier verdict system**: SAFE (proceed) / SUSPICIOUS (warn + sanitize) / DANGEROUS (reject)
- **Mandatory pre-processing**: Strip Unicode hidden characters (Tag Block U+E0000-E007F, zero-width chars, RTL overrides), remove HTML comments, decode HTML entities
- **Untrusted Content Envelope**: Mental framing pattern to isolate untrusted input from system instructions

| Skill | Untrusted Source | Scan Location |
|-------|-----------------|---------------|
| `qa-issue-validate` | GitHub issue body | Step 2.5 |
| `qa-issue-report` | Collected environment data | Step 9.5 |
| `jaan-issue-report` | Collected issue details | Step 4.5 |
| `pm-roadmap-add` | User item description | Step 1.1 |
| `pm-roadmap-update` | Existing roadmap content | Step 1.1 |
| `pm-research-about` | WebFetch/WebSearch results | Safety Rules + Step 4 |
| `backend-pr-review` | PR diff content | Safety Instructions |
| `detect-*` | Repository content | Codebase Content Safety (shared/dev reference) |

Automated enforcement: `validate-security.sh` Section E checks that external-input skills reference the shared threat scan document.

---

## PreToolUse Security Gate

The `scripts/pre-tool-security-gate.sh` hook runs before every Bash command and blocks:

- `sudo` commands
- `--dangerously-skip-permissions` flag
- `rm -rf /` or `rm -rf ~`
- `curl`/`wget` piped to shell (`curl ... | bash`)
- `eval` statements
- `$IFS` manipulation
- `source`/`.` of non-plugin files
- `chmod 777`
- ANSI-C hex quoting (`$'\x73\x75\x64\x6f'` — assembles blocked commands at runtime)
- `base64 -d` piped to shell (hides payloads entirely)
- Brace expansion with dangerous commands (`{curl,http://evil}` — generates command+argument pairs)
- `sed` execute flag (`sed 's/.../e'` — weaponized sed)
- `sort --compress-program` (weaponized sort)

This is defense-in-depth — skill `allowed-tools` are the primary gate.

---

## Privacy Sanitization Patterns

Before any external data submission, sanitize:

### Paths
- `/Users/{name}/...` → `{USER_HOME}/...`
- Absolute project paths → relative paths

### Credentials
- `token=`, `key=`, `password=`, `secret=`, `Bearer `, `ghp_*`, `sk-*`, `api_key` → `[REDACTED]`

### Connection Strings
- `postgresql://`, `mysql://`, `mongodb://`, `redis://`, `amqp://` → `[DB_CONNECTION_REDACTED]`
- `jdbc:` prefixed URLs → `[DB_CONNECTION_REDACTED]`
- `://user:pass@` → `://[AUTH_REDACTED]@`

### Personal Info
- Email patterns, IP addresses, usernames in paths → generic placeholders

---

## Positive Security Posture

Things already done correctly (maintain these):

- No `eval`, `exec`, or backtick substitution anywhere in scripts
- No remote code download/execution (`curl | sh`)
- No hardcoded secrets or credentials
- Proper sed escaping (`s/[&/\]/\\&/g`) in template-processor.sh
- JSON parsing via Python `json.load()` — safe, no `eval`
- `set -euo pipefail` in all scripts (exception: `validate-compliance.sh` uses `set -u` due to `grep | wc` patterns requiring non-zero exits)
- Cleanup traps for temp files
- Human approval gates (HARD STOP) in all write-heavy skills
- Hook commands are static paths — no user input in command strings
- YAML parsing is line-by-line bash — no library deserialization risks

---

## Automated Enforcement

Security standards are automatically enforced at three levels:

| Enforcement Point | Script | Mode | Effect |
|-------------------|--------|------|--------|
| CI (PRs to main) | `scripts/validate-security.sh` | Normal (errors block) | PR cannot merge with blocking violations |
| `/jaan-release` | `scripts/validate-security.sh` | Normal (errors block) | Release blocked if security check fails |
| `/jaan-issue-review` | `scripts/validate-security.sh` | Normal (errors block) | PR verification includes security gate |

### Security Check Categories

| Section | What It Checks | Level |
|---------|---------------|-------|
| A: Skill Permissions | Bare Write/Bash/Edit, credential access, hardcoded secrets | BLOCKING (distributed), ADVISORY (local) |
| B: Shell Scripts | `set -euo pipefail`, eval, curl\|sh, chmod 777, $IFS | BLOCKING |
| C: Hook Safety | Static paths, no user input in commands | BLOCKING |
| D: Dangerous Patterns | `exec()`, `rm -rf /` in skill bodies | BLOCKING |

### Adding New Security Rules

1. Add the check to `scripts/validate-security.sh` under the appropriate section
2. Choose level: BLOCKING (must fix) or ADVISORY (review recommended)
3. Use `::error::` prefix for GitHub Actions annotations
4. Update the check count in this document
5. Run `bash scripts/validate-security.sh` to verify the new check works

---

## Related

- [Security (User Guide)](config/security.md) — End-user security documentation
- [Guardrails](config/guardrails.md) — Non-negotiable safety rules
- [Permissions](config/permissions.md) — Claude Code allow/deny configuration
