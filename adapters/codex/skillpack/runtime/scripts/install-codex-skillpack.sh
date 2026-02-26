#!/bin/bash
# install-codex-skillpack.sh — Install jaan.to Codex skillpack via Codex Skill Installer.
# Usage: bash scripts/install-codex-skillpack.sh [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
INSTALLER_SCRIPT="$CODEX_HOME_DIR/skills/.system/skill-installer/scripts/install-skill-from-github.py"
DEST_ROOT="$HOME/.agents/skills"
SKILLPACK_NAME="jaan-to-codex-pack"
SKILLPACK_PATH="adapters/codex/skillpack"
METHOD="auto"
FORCE=0
UPDATE_AGENTS=1
UPDATE_MCP=1
MCP_CONFIG_UPDATED=0
BLOCK_START="# >>> JAAN-TO CODEX RUNTIME >>>"
BLOCK_END="# <<< JAAN-TO CODEX RUNTIME <<<"
MCP_BLOCK_START="# >>> JAAN-TO MCP SERVERS >>>"
MCP_BLOCK_END="# <<< JAAN-TO MCP SERVERS <<<"

usage() {
  cat <<'EOF'
Usage: bash scripts/install-codex-skillpack.sh [options]

Options:
  --repo owner/repo       GitHub repo (default: inferred from origin or parhumm/jaan-to)
  --ref <ref>             Git ref/branch (default: current branch or main)
  --path <repo-path>      Skillpack path in repo (default: adapters/codex/skillpack)
  --dest <dir>            Destination skills root (default: ~/.agents/skills)
  --name <skill-name>     Installed skill directory name (default: jaan-to-codex-pack)
  --method <m>            Installer method: auto|download|git (default: auto)
  --force                 Replace existing installation directory
  --no-agents             Do not update ~/.codex/AGENTS.md managed block
  --no-mcp                Do not update ~/.codex/config.toml MCP servers
  -h, --help              Show this help
EOF
}

expand_home_path() {
  local path="$1"
  case "$path" in
    "~")
      echo "$HOME"
      ;;
    "~/"*)
      echo "$HOME/${path#~/}"
      ;;
    *)
      echo "$path"
      ;;
  esac
}

detect_repo_slug() {
  local remote_url
  remote_url="$(git -C "$PLUGIN_ROOT" remote get-url origin 2>/dev/null || true)"
  if [ -z "$remote_url" ]; then
    echo "parhumm/jaan-to"
    return 0
  fi

  local parsed=""
  parsed="$(echo "$remote_url" | sed -E 's#^https://github.com/([^/]+/[^/.]+)(\.git)?$#\1#')"
  if [ "$parsed" = "$remote_url" ]; then
    parsed="$(echo "$remote_url" | sed -E 's#^git@github.com:([^/]+/[^/.]+)(\.git)?$#\1#')"
  fi
  if [ -z "$parsed" ] || [ "$parsed" = "$remote_url" ]; then
    echo "parhumm/jaan-to"
    return 0
  fi
  echo "$parsed"
}

detect_ref() {
  local branch
  branch="$(git -C "$PLUGIN_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    echo "main"
    return 0
  fi
  echo "$branch"
}

strip_managed_block() {
  local file="$1"
  local tmp="$2"

  if [ ! -f "$file" ]; then
    : > "$tmp"
    return 0
  fi

  awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$file" > "$tmp"
}

update_codex_agents() {
  local runtime_root="$1"
  local agents_file="$CODEX_HOME_DIR/AGENTS.md"
  local stripped_file
  stripped_file="$(mktemp)"
  strip_managed_block "$agents_file" "$stripped_file"

  local block_file
  block_file="$(mktemp)"
  cat > "$block_file" <<EOF
$BLOCK_START
This machine uses the global jaan.to Codex skill pack.

## Alias Contract

- If user writes \`/jaan-to:{skill}\`, treat it as alias \`\$<skill>\`.
- If user writes \`/jaan-init\`, treat it as alias \`\$jaan-init\`.

## Runtime Defaults

- \`CLAUDE_PLUGIN_ROOT=$runtime_root\`
- \`CLAUDE_PROJECT_DIR=<current workspace root>\`
- \`JAAN_CONTEXT_DIR=jaan-to/context\`
- \`JAAN_TEMPLATES_DIR=jaan-to/templates\`
- \`JAAN_LEARN_DIR=jaan-to/learn\`
- \`JAAN_OUTPUTS_DIR=jaan-to/outputs\`
- \`JAAN_DOCS_DIR=jaan-to/docs\`

## Collision Guard

- Avoid installing duplicate jaan.to skills under project \`.agents/skills\`.
- If local-only development is required, run \`./jaan-to setup --mode local\` intentionally.
$BLOCK_END
EOF

  mkdir -p "$(dirname "$agents_file")"
  if [ -s "$stripped_file" ]; then
    cat "$stripped_file" > "$agents_file"
    printf '\n\n' >> "$agents_file"
    cat "$block_file" >> "$agents_file"
  else
    cat "$block_file" > "$agents_file"
  fi

  rm -f "$stripped_file" "$block_file"
}

strip_mcp_block() {
  local file="$1"
  local tmp="$2"

  if [ ! -f "$file" ]; then
    : > "$tmp"
    return 0
  fi

  awk -v start="$MCP_BLOCK_START" -v end="$MCP_BLOCK_END" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$file" > "$tmp"
}

update_codex_mcp_config() {
  local config_file="$CODEX_HOME_DIR/config.toml"
  local stripped_file
  stripped_file="$(mktemp)"
  strip_mcp_block "$config_file" "$stripped_file"

  # Per-server merge: check each managed server individually.
  # Servers already in user config (outside managed block) are preserved;
  # only missing servers are added to the managed block.
  local servers_to_add=()
  local servers_user_managed=()
  local managed_servers=("context7" "playwright" "storybook-mcp" "shadcn")

  for server in "${managed_servers[@]}"; do
    if grep -qE "^\[mcp_servers\.${server}\]" "$stripped_file" 2>/dev/null; then
      servers_user_managed+=("$server")
    else
      servers_to_add+=("$server")
    fi
  done

  # If ALL managed servers are already user-configured, skip entirely
  if [ "${#servers_to_add[@]}" -eq 0 ]; then
    mkdir -p "$(dirname "$config_file")"
    cat "$stripped_file" > "$config_file"
    echo "All MCP servers user-managed in $config_file. Removed stale managed block."
    MCP_CONFIG_UPDATED=0
    rm -f "$stripped_file"
    return 0
  fi

  # Build managed block with only the servers that need to be added
  local block_file
  block_file="$(mktemp)"
  {
    echo "$MCP_BLOCK_START"
    for server in "${servers_to_add[@]}"; do
      case "$server" in
        context7)
          cat <<'TOML'
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@latest"]
TOML
          ;;
        playwright)
          cat <<'TOML'
[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@latest"]
TOML
          ;;
        storybook-mcp)
          cat <<'TOML'
[mcp_servers.storybook-mcp]
type = "url"
url = "http://localhost:6006/mcp"
TOML
          ;;
        shadcn)
          cat <<'TOML'
[mcp_servers.shadcn]
command = "npx"
args = ["shadcn@latest", "mcp"]
TOML
          ;;
      esac
      echo ""
    done
    echo "$MCP_BLOCK_END"
  } > "$block_file"

  mkdir -p "$(dirname "$config_file")"
  if [ -s "$stripped_file" ]; then
    cat "$stripped_file" > "$config_file"
    printf '\n' >> "$config_file"
    cat "$block_file" >> "$config_file"
  else
    cat "$block_file" > "$config_file"
  fi

  MCP_CONFIG_UPDATED=1
  echo "MCP servers configured:"
  [ "${#servers_to_add[@]}" -gt 0 ] && echo "  Added (managed): ${servers_to_add[*]}"
  [ "${#servers_user_managed[@]}" -gt 0 ] && echo "  Preserved (user-managed): ${servers_user_managed[*]}"
  rm -f "$stripped_file" "$block_file"
}

REPO_SLUG="$(detect_repo_slug)"
REF_NAME="$(detect_ref)"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --repo requires owner/repo" >&2
        exit 1
      fi
      REPO_SLUG="$2"
      shift 2
      ;;
    --ref)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --ref requires a value" >&2
        exit 1
      fi
      REF_NAME="$2"
      shift 2
      ;;
    --path)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --path requires a value" >&2
        exit 1
      fi
      SKILLPACK_PATH="$2"
      shift 2
      ;;
    --dest)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --dest requires a path" >&2
        exit 1
      fi
      DEST_ROOT="$2"
      shift 2
      ;;
    --name)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --name requires a value" >&2
        exit 1
      fi
      SKILLPACK_NAME="$2"
      shift 2
      ;;
    --method)
      if [ -z "${2:-}" ]; then
        echo "ERROR: --method requires auto|download|git" >&2
        exit 1
      fi
      METHOD="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --no-agents)
      UPDATE_AGENTS=0
      shift
      ;;
    --no-mcp)
      UPDATE_MCP=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$METHOD" in
  auto|download|git)
    ;;
  *)
    echo "ERROR: Invalid --method value: $METHOD" >&2
    exit 1
    ;;
esac

if [ ! -f "$INSTALLER_SCRIPT" ]; then
  echo "ERROR: Codex Skill Installer script not found:" >&2
  echo "  $INSTALLER_SCRIPT" >&2
  echo "Make sure Codex is installed and system skills are initialized." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to run Codex Skill Installer." >&2
  exit 1
fi

DEST_ROOT="$(expand_home_path "$DEST_ROOT")"
INSTALL_DIR="$DEST_ROOT/$SKILLPACK_NAME"

if [ "$FORCE" -eq 1 ] && [ -e "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
fi

mkdir -p "$DEST_ROOT"

if [ -e "$INSTALL_DIR" ]; then
  echo "Skill pack already installed: $INSTALL_DIR"
  echo "Use --force to reinstall."
else
  INSTALL_CMD=(
    python3 "$INSTALLER_SCRIPT"
    --repo "$REPO_SLUG"
    --path "$SKILLPACK_PATH"
    --ref "$REF_NAME"
    --dest "$DEST_ROOT"
    --name "$SKILLPACK_NAME"
    --method "$METHOD"
  )

  if "${INSTALL_CMD[@]}"; then
    :
  elif [ "$METHOD" = "auto" ]; then
    echo "Auto install failed. Retrying with --method git..."
    python3 "$INSTALLER_SCRIPT" \
      --repo "$REPO_SLUG" \
      --path "$SKILLPACK_PATH" \
      --ref "$REF_NAME" \
      --dest "$DEST_ROOT" \
      --name "$SKILLPACK_NAME" \
      --method git
  else
    echo "ERROR: Skill install failed." >&2
    exit 1
  fi
fi

RUNTIME_ROOT="$INSTALL_DIR/runtime"
if [ ! -d "$RUNTIME_ROOT" ]; then
  echo "ERROR: Installed skill pack is missing runtime directory: $RUNTIME_ROOT" >&2
  exit 1
fi

if [ "$UPDATE_AGENTS" -eq 1 ]; then
  update_codex_agents "$RUNTIME_ROOT"
  echo "Updated managed jaan.to runtime block in $CODEX_HOME_DIR/AGENTS.md"
fi

if [ "$UPDATE_MCP" -eq 1 ]; then
  update_codex_mcp_config
  if [ "$MCP_CONFIG_UPDATED" -eq 1 ]; then
    echo "Updated managed Context7 MCP config in $CODEX_HOME_DIR/config.toml"
  else
    echo "Skipped managed Context7 MCP config update in $CODEX_HOME_DIR/config.toml"
  fi
fi

echo ""
echo "=== jaan.to Codex Skillpack Install ==="
echo "Repo: $REPO_SLUG"
echo "Ref: $REF_NAME"
echo "Path: $SKILLPACK_PATH"
echo "Destination: $INSTALL_DIR"
echo "Runtime root: $RUNTIME_ROOT"
echo "Restart Codex to pick up new skills."
