#!/usr/bin/env bash
set -euo pipefail
# Probes many OPTIONAL external stores (Claude/Codex/Cursor) whose presence,
# permissions, and formats vary per machine. Keep nounset + pipefail for
# correctness, but disable exit-on-error: a missing dir or non-zero `find` must
# NEVER abort a read — every sub-reader is wrapped by sr_json_or and always
# emits valid JSON or a safe fallback.
set +e

# session-reader.sh — Shared, OS-aware, format-detecting reader for AI-tool
# session / plan / memory stores (Claude Code, Codex, Cursor).
#
# Emits METADATA ONLY as a single JSON object on stdout: presence, formats,
# counts, hashed identifiers, timestamps, and tool-name frequencies. It NEVER
# emits raw prompts, code, file paths, or tool-output content — all paths and
# ids are SHA-256 hashed, and SQLite stores are opened READ-ONLY by construction
# (immutable URI, no dot-commands, fixed schema-only queries).
#
# Used by: skills/pm-workflow-audit (discovery), skills/pm-skill-discover (retrofit).
#
# Usage:
#   bash session-reader.sh discover [--days=N] [--tools=claude,codex,cursor]
#                                   [--project=DIR] [--max=N]
#
# Safety: this script is deliberately read-only. It runs no network/exec, opens
# SQLite with mode=ro&immutable=1, and issues only sqlite_master / COUNT queries.
# See docs/security-strategy.md (Untrusted Input Processing) and
# docs/extending/threat-scan-reference.md.

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
SR_SUBCOMMAND="${1:-discover}"
[ "$#" -gt 0 ] && shift || true

SR_DAYS=14
SR_TOOLS="claude,codex,cursor"
SR_PROJECT="$PWD"
SR_MAX=8

for _arg in "$@"; do
  case "$_arg" in
    --days=*)    SR_DAYS="${_arg#*=}" ;;
    --tools=*)   SR_TOOLS="${_arg#*=}" ;;
    --project=*) SR_PROJECT="${_arg#*=}" ;;
    --max=*)     SR_MAX="${_arg#*=}" ;;
    *) echo "session-reader: unknown arg: $_arg" >&2 ;;
  esac
done

# Numeric guards (reject non-integers rather than trust untrusted-adjacent input)
case "$SR_DAYS" in ''|*[!0-9]*) SR_DAYS=14 ;; esac
case "$SR_MAX"  in ''|*[!0-9]*) SR_MAX=8 ;; esac

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
sr_have() { command -v "$1" >/dev/null 2>&1; }

if ! sr_have jq; then
  echo '{"error":"jq_not_available","hint":"install jq to run session-reader"}'
  exit 0
fi

# Short, stable, non-reversible hash of a string (privacy: never emit raw paths/ids)
sr_hash() {
  local s="$1"
  if sr_have shasum; then
    printf '%s' "$s" | shasum -a 256 2>/dev/null | cut -c1-12
  elif sr_have sha256sum; then
    printf '%s' "$s" | sha256sum 2>/dev/null | cut -c1-12
  else
    printf '%s' "$s" | cksum 2>/dev/null | cut -d' ' -f1
  fi
}

sr_detect_os() {
  case "$(uname -s 2>/dev/null)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then echo "wsl"; else echo "linux"; fi ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

sr_tool_enabled() { case ",$SR_TOOLS," in *",$1,"*) return 0 ;; *) return 1 ;; esac; }

# Echo $1 if it is valid JSON, else echo the fallback $2 (defensive: a
# misbehaving sub-reader degrades to a safe object, never crashes discover).
sr_json_or() {
  if printf '%s' "$1" | jq -e . >/dev/null 2>&1; then printf '%s' "$1"; else printf '%s' "$2"; fi
}

# Base dirs, honoring documented override env vars.
sr_claude_base() { echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"; }
sr_codex_base()  { echo "${CODEX_HOME:-$HOME/.codex}"; }
sr_cursor_base() {
  case "$(sr_detect_os)" in
    macos) echo "$HOME/Library/Application Support/Cursor" ;;
    linux|wsl) echo "$HOME/.config/Cursor" ;;
    windows) echo "${APPDATA:-$HOME/AppData/Roaming}/Cursor" ;;
    *) echo "$HOME/.config/Cursor" ;;
  esac
}

# Count files matching a glob modified within SR_DAYS. Args: dir, name-pattern
sr_count_recent() {
  local dir="$1" pat="$2"
  [ -d "$dir" ] || { echo 0; return; }
  find "$dir" -type f -name "$pat" -mtime "-${SR_DAYS}" 2>/dev/null | wc -l | tr -d ' '
}

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
sr_claude_json() {
  local base; base="$(sr_claude_base)"
  local projects_dir="$base/projects"
  local plans_dir="$base/plans"

  if [ ! -d "$base" ]; then
    echo '{"present":false}'; return
  fi

  # Sessions are FLAT: projects/<slug>/<session-id>.jsonl (NOT projects/*/sessions/).
  local sess_count=0 proj_count=0
  if [ -d "$projects_dir" ]; then
    proj_count=$(find "$projects_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    # Session transcripts sit at depth 2 (projects/<slug>/<id>.jsonl); nested
    # subagents/ live deeper — exclude them from the session count.
    sess_count=$(find "$projects_dir" -mindepth 2 -maxdepth 2 -type f -name '*.jsonl' -mtime "-${SR_DAYS}" 2>/dev/null | wc -l | tr -d ' ')
  fi

  # Tool-name frequency across recent sessions (metadata only; tool NAMES, no content).
  local tool_freq='{}'
  if [ -d "$projects_dir" ] && [ "$sess_count" -gt 0 ]; then
    tool_freq=$(find "$projects_dir" -type f -name '*.jsonl' -mtime "-${SR_DAYS}" 2>/dev/null \
      | head -n 200 \
      | while IFS= read -r f; do jq -rc 'try (.message.content[]?|select(.type=="tool_use").name) // empty' "$f" 2>/dev/null; done \
      | sort | uniq -c | sort -rn | head -n 25 \
      | awk '{c=$1; $1=""; sub(/^ +/,""); if (length($0)>0) printf "%s\t%s\n", $0, c}' \
      | jq -R -s 'split("\n")|map(select(length>0)|split("\t")|{(.[0]):(.[1]|tonumber)})|add // {}' 2>/dev/null)
    tool_freq="$(sr_json_or "$tool_freq" '{}')"
  fi

  # Plans (global, flat) + memory for THIS project (keyed by git repo root when available).
  local plan_count; plan_count=$(sr_count_recent "$plans_dir" '*.md')
  local repo_root; repo_root="$(cd "$SR_PROJECT" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo "$SR_PROJECT")"
  local mem_present=false mem_slug=""
  if [ -d "$projects_dir" ]; then
    # Best-effort slug match: separators -> '-', leading '-'.
    mem_slug="$(printf '%s' "$repo_root" | sed 's#[^A-Za-z0-9]#-#g')"
    if [ -f "$projects_dir/$mem_slug/memory/MEMORY.md" ]; then mem_present=true; fi
  fi

  jq -n \
    --arg base_h "$(sr_hash "$base")" \
    --argjson projects "$proj_count" \
    --argjson sessions "$sess_count" \
    --argjson plans "$plan_count" \
    --argjson tool_freq "$tool_freq" \
    --argjson mem_present "$mem_present" \
    '{present:true, layout:"flat", base_hash:$base_h,
      projects:$projects, recent_sessions:$sessions, recent_plans:$plans,
      tool_frequency:$tool_freq, project_memory_present:$mem_present}'
}

# ---------------------------------------------------------------------------
# Codex — detect documented JSONL layout vs SQLite variant vs absent
# ---------------------------------------------------------------------------
sr_codex_json() {
  local base; base="$(sr_codex_base)"
  if [ ! -d "$base" ]; then echo '{"present":false}'; return; fi

  local format="unknown"
  local sess_count=0 sqlite_tables='[]'
  if [ -d "$base/sessions" ]; then
    format="jsonl"
    sess_count=$(find "$base/sessions" -type f -name 'rollout-*.jsonl' -mtime "-${SR_DAYS}" 2>/dev/null | wc -l | tr -d ' ')
  elif ls "$base"/*.sqlite >/dev/null 2>&1; then
    format="sqlite"
    if sr_have sqlite3; then
      # READ-ONLY, schema-only: table names per DB (no content rows).
      sqlite_tables=$(for db in "$base"/*.sqlite; do
          [ -f "$db" ] || continue
          local t
          t=$(sqlite3 -readonly -batch -noheader "file:${db}?mode=ro&immutable=1" \
                "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;" 2>/dev/null | tr '\n' ',' )
          jq -n --arg db "$(sr_hash "$db")" --arg tables "${t%,}" '{db_hash:$db, tables:($tables|split(",")|map(select(length>0)))}'
        done | jq -s '.' 2>/dev/null || echo '[]')
    fi
  fi

  local agents_md=false skills_present=false
  [ -f "$base/AGENTS.md" ] && agents_md=true
  [ -d "$base/skills" ] && skills_present=true

  jq -n \
    --arg base_h "$(sr_hash "$base")" \
    --arg format "$format" \
    --argjson sessions "$sess_count" \
    --argjson sqlite_tables "$sqlite_tables" \
    --argjson agents_md "$agents_md" \
    --argjson skills "$skills_present" \
    '{present:true, format:$format, base_hash:$base_h, recent_sessions:$sessions,
      sqlite_tables:$sqlite_tables, agents_md:$agents_md, skills_dir:$skills,
      note:"Codex storage is version-dependent; content extraction intentionally not performed (metadata only)."}'
}

# ---------------------------------------------------------------------------
# Cursor — best-effort presence only (chat is reverse-engineered SQLite)
# ---------------------------------------------------------------------------
sr_cursor_json() {
  local base; base="$(sr_cursor_base)"
  local global_db="$base/User/globalStorage/state.vscdb"
  local present=false
  [ -f "$global_db" ] && present=true
  local rules_present=false
  { [ -d "$SR_PROJECT/.cursor/rules" ] || [ -f "$SR_PROJECT/.cursorrules" ]; } && rules_present=true

  jq -n \
    --argjson present "$present" \
    --arg base_h "$(sr_hash "$base")" \
    --argjson rules "$rules_present" \
    '{present:$present, base_hash:$base_h, project_rules_present:$rules,
      note:"Cursor chat lives in state.vscdb (reverse-engineered, undocumented); no dedicated plans/memory artifact — best-effort only."}'
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
case "$SR_SUBCOMMAND" in
  discover)
    claude_json='{"present":false,"skipped":true}'
    codex_json='{"present":false,"skipped":true}'
    cursor_json='{"present":false,"skipped":true}'
    sr_tool_enabled claude && claude_json="$(sr_json_or "$(sr_claude_json)" '{"present":false,"error":"read_failed"}')"
    sr_tool_enabled codex  && codex_json="$(sr_json_or "$(sr_codex_json)" '{"present":false,"error":"read_failed"}')"
    sr_tool_enabled cursor && cursor_json="$(sr_json_or "$(sr_cursor_json)" '{"present":false,"error":"read_failed"}')"

    jq -n \
      --arg os "$(sr_detect_os)" \
      --argjson days "$SR_DAYS" \
      --arg project_hash "$(sr_hash "$SR_PROJECT")" \
      --argjson claude "$claude_json" \
      --argjson codex "$codex_json" \
      --argjson cursor "$cursor_json" \
      '{schema:"jaan-session-reader/v1", os:$os, window_days:$days,
        project_hash:$project_hash,
        tools:{claude:$claude, codex:$codex, cursor:$cursor}}'
    ;;
  *)
    echo "session-reader: unknown subcommand: $SR_SUBCOMMAND (use: discover)" >&2
    exit 2
    ;;
esac
