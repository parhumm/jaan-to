#!/bin/bash
# jaan.to PreToolUse Security Gate
# Validates Bash commands before execution (defense-in-depth)
# Exit codes: 0 = allow (default), non-zero = deny
# Stdout cap: ≤1,200 chars (~300 tokens)

set -euo pipefail

INPUT=$(cat)

# Extract command from hook input
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

# Guard: Must have a command
if [ -z "$COMMAND" ]; then
  exit 0
fi

# ── Dangerous command patterns (blocklist — defense-in-depth) ──

# Block sudo anywhere in the command
if echo "$COMMAND" | grep -qE '(^|[;&|])\s*sudo\s'; then
  echo "BLOCKED: sudo commands are not allowed in plugin context."
  exit 2
fi

# Block --dangerously-skip-permissions (Nx-style attack vector)
if echo "$COMMAND" | grep -qF -- '--dangerously-skip-permissions'; then
  echo "BLOCKED: --dangerously-skip-permissions flag is not allowed."
  exit 2
fi

# Block rm -rf / or rm -rf ~
if echo "$COMMAND" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f\s+/'; then
  echo "BLOCKED: Recursive force delete of root is not allowed."
  exit 2
fi

# Block curl/wget piped to shell (remote code execution)
if echo "$COMMAND" | grep -qE '(curl|wget)\s.*\|\s*(bash|sh|zsh|dash)'; then
  echo "BLOCKED: Piping remote content to shell is not allowed."
  exit 2
fi

# Block eval anywhere in the command
if echo "$COMMAND" | grep -qE '(^|[;&|])\s*eval\s'; then
  echo "BLOCKED: eval is not allowed in plugin context."
  exit 2
fi

# Block $IFS manipulation (CVE-2025-66032 bypass technique)
if echo "$COMMAND" | grep -qE '\$IFS|\$\{IFS\}'; then
  echo "BLOCKED: \$IFS manipulation detected — potential injection."
  exit 2
fi

# Block source/dot of user-controlled paths (only allow plugin scripts)
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-}"
if echo "$COMMAND" | grep -qE '(^|[;&|])\s*(source|\.)\s'; then
  if [ -n "$PLUGIN_DIR" ] && ! echo "$COMMAND" | grep -qF "$PLUGIN_DIR"; then
    echo "BLOCKED: source/dot commands may only load plugin scripts."
    exit 2
  fi
fi

# Block chmod 777 (overly permissive)
if echo "$COMMAND" | grep -qE 'chmod\s.*777'; then
  echo "BLOCKED: chmod 777 is not allowed — use specific permissions."
  exit 2
fi

# All checks passed — allow
exit 0
