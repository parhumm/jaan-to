#!/bin/bash
# validate-mcp-servers.sh — Validate MCP server configuration for dual-runtime parity.
# Usage: bash scripts/validate-mcp-servers.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MCP_JSON="$PLUGIN_ROOT/.mcp.json"
INSTALLER="$PLUGIN_ROOT/scripts/install-codex-skillpack.sh"
SKILLS_DIR="$PLUGIN_ROOT/skills"

ERRORS=0
WARNINGS=0

echo "═══════════════════════════════════════"
echo "  MCP Server Validation"
echo "═══════════════════════════════════════"
echo ""

# --- Check 1: .mcp.json exists and is valid JSON ---
echo "Section A: Claude Code MCP Configuration"
echo "────────────────────────────────────────────────────"

if [ ! -f "$MCP_JSON" ]; then
  echo "  ::error::A1 .mcp.json not found at $MCP_JSON"
  ERRORS=$((ERRORS + 1))
else
  if ! jq empty "$MCP_JSON" 2>/dev/null; then
    echo "  ::error::A1 .mcp.json is not valid JSON"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✓ .mcp.json exists and is valid JSON"
  fi
fi

# --- Check 2: Extract server names from .mcp.json ---
SERVERS=()
if [ -f "$MCP_JSON" ] && jq empty "$MCP_JSON" 2>/dev/null; then
  while IFS= read -r server; do
    SERVERS+=("$server")
  done < <(jq -r '.mcpServers | keys[]' "$MCP_JSON" 2>/dev/null)
  echo "  ✓ MCP servers found: ${SERVERS[*]:-none}"
fi

echo ""

# --- Check 3: Codex installer parity ---
echo "Section B: Codex MCP Parity"
echo "────────────────────────────────────────────────────"

if [ ! -f "$INSTALLER" ]; then
  echo "  ::error::B1 Codex installer not found at $INSTALLER"
  ERRORS=$((ERRORS + 1))
else
  for server in "${SERVERS[@]}"; do
    if grep -q "\\[mcp_servers\\.$server\\]" "$INSTALLER" 2>/dev/null; then
      echo "  ✓ Server '$server' configured in Codex installer"
    else
      echo "  ::error::B2 Server '$server' in .mcp.json but missing from Codex installer"
      echo "    Add [mcp_servers.$server] block to update_codex_mcp_config() in install-codex-skillpack.sh"
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

echo ""

# --- Check 4: Skills declaring mcp__ tools have matching server ---
echo "Section C: Skill-to-Server Mapping"
echo "────────────────────────────────────────────────────"

for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$(dirname "$skill_file")")"

  # Extract mcp__ tool references from allowed-tools frontmatter
  mcp_tools="$(awk '/^---$/{n++; next} n==1 && /^allowed-tools:/{sub(/^allowed-tools: */, ""); print; exit}' "$skill_file" | grep -oE 'mcp__[a-zA-Z0-9_]+__[a-zA-Z0-9_-]+' || true)"

  [ -z "$mcp_tools" ] && continue

  # Extract unique server names from mcp__<server>__<tool> patterns
  mcp_servers="$(
    echo "$mcp_tools" | while IFS= read -r tool; do
      [ -n "$tool" ] || continue
      tool="${tool#mcp__}"
      echo "${tool%%__*}"
    done | sort -u
  )"

  for srv in $mcp_servers; do
    found=0
    for configured in "${SERVERS[@]}"; do
      if [ "$srv" = "$configured" ]; then
        found=1
        break
      fi
    done
    if [ "$found" -eq 1 ]; then
      echo "  ✓ [$skill_name] uses mcp__${srv}__ → server '$srv' configured"
    else
      echo "  ::error::C1 [$skill_name] uses mcp__${srv}__ but server '$srv' not in .mcp.json"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

echo ""

# --- Check 5: Unused servers (advisory) ---
echo "Section D: Server Utilization"
echo "────────────────────────────────────────────────────"

for server in "${SERVERS[@]}"; do
  used=0
  for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
    [ -f "$skill_file" ] || continue
    if grep -q "mcp__${server}__" "$skill_file" 2>/dev/null; then
      used=1
      break
    fi
  done
  if [ "$used" -eq 1 ]; then
    echo "  ✓ Server '$server' used by at least one skill"
  else
    echo "  ::warning::D1 Server '$server' configured but no skill references mcp__${server}__"
    WARNINGS=$((WARNINGS + 1))
  fi
done

echo ""

# --- Summary ---
echo "═══════════════════════════════════════"
echo "  MCP Validation Summary"
echo "═══════════════════════════════════════"
echo ""
echo "  Blocking errors:     $ERRORS"
echo "  Advisory warnings:   $WARNINGS"
echo ""

if [ "$ERRORS" -gt 0 ]; then
  echo "✗ FAIL: $ERRORS blocking error(s) found"
  exit 1
fi

echo "✓ PASS: All MCP validation checks passed"
if [ "$WARNINGS" -gt 0 ]; then
  echo "  ($WARNINGS advisory warning(s) — review recommended)"
fi
