#!/bin/bash
# Sync website/index.html with current plugin state
# Updates: version badge, skill counts, skills catalog
# Usage: ./scripts/sync-marketing-site.sh [--dry-run]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEX="$PLUGIN_ROOT/website/index.html"
DRY_RUN="${1:-}"

# --- 1. Extract latest version from CHANGELOG.md ---
VERSION=$(grep -m1 '^\#\# \[' "$PLUGIN_ROOT/CHANGELOG.md" | sed 's/.*\[\(.*\)\].*/\1/')
if [[ -z "$VERSION" ]]; then
  echo "ERROR: Could not extract version from CHANGELOG.md" >&2
  exit 1
fi

# --- 2. Count skills ---
TOTAL=0
declare -A ROLE_COUNT
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  name=$(basename "$skill_dir")
  [[ ! -f "$skill_dir/SKILL.md" ]] && continue
  TOTAL=$((TOTAL + 1))
  case "$name" in
    pm-*)   ROLE_COUNT[pm]=$(( ${ROLE_COUNT[pm]:-0} + 1 )) ;;
    data-*) ROLE_COUNT[data]=$(( ${ROLE_COUNT[data]:-0} + 1 )) ;;
    dev-*)  ROLE_COUNT[dev]=$(( ${ROLE_COUNT[dev]:-0} + 1 )) ;;
    ux-*)   ROLE_COUNT[ux]=$(( ${ROLE_COUNT[ux]:-0} + 1 )) ;;
    qa-*)   ROLE_COUNT[qa]=$(( ${ROLE_COUNT[qa]:-0} + 1 )) ;;
    *)      ROLE_COUNT[core]=$(( ${ROLE_COUNT[core]:-0} + 1 )) ;;
  esac
done

ACTIVE_ROLES=$(echo "${!ROLE_COUNT[@]}" | tr ' ' '\n' | wc -l | tr -d ' ')

# --- 3. Apply updates via Python ---
export PLUGIN_ROOT VERSION TOTAL ACTIVE_ROLES DRY_RUN

python3 << 'PYEOF'
import re, sys, os, glob

plugin_root = os.environ.get("PLUGIN_ROOT", ".")
index_path = os.path.join(plugin_root, "website", "index.html")
version = os.environ.get("VERSION", "")
total = os.environ.get("TOTAL", "0")
active_roles = os.environ.get("ACTIVE_ROLES", "0")
dry_run = os.environ.get("DRY_RUN", "") == "--dry-run"

with open(index_path, 'r') as f:
    html = f.read()

# 3a. Update version badge text and title
html = re.sub(
    r'title="Version [^"]*">\s*v[\d.]+',
    f'title="Version {version} - View changelog">v{version}',
    html
)

# 3b. Update all skill count numbers
html = re.sub(r'\d+ structured commands across \d+ roles',
              f'{total} structured commands across {active_roles} roles', html)
html = re.sub(r'\d+ skills available now\. \d+ active roles\.',
              f'{total} skills available now. {active_roles} active roles.', html)
html = re.sub(r'\d+ production skills\.',
              f'{total} production skills.', html)

# 3c. Rebuild skills catalog per role
skills_by_role = {}
for skill_dir in sorted(glob.glob(os.path.join(plugin_root, "skills", "*", "SKILL.md"))):
    name = os.path.basename(os.path.dirname(skill_dir))
    desc = ""
    in_frontmatter = False
    with open(skill_dir) as f:
        for line in f:
            if line.strip() == "---":
                if in_frontmatter:
                    break
                in_frontmatter = True
                continue
            if in_frontmatter and line.startswith("description:"):
                desc = line.split(":", 1)[1].strip().strip("'\"")
                break
    if not desc:
        desc = "(no description)"
    if name.startswith("pm-"): role = "pm"
    elif name.startswith("data-"): role = "data"
    elif name.startswith("dev-"): role = "dev"
    elif name.startswith("ux-"): role = "ux"
    elif name.startswith("qa-"): role = "qa"
    else: role = "core"
    skills_by_role.setdefault(role, []).append((name, desc))

role_display = {"pm": "PM", "data": "Data", "dev": "Dev",
                "ux": "UX", "core": "Core", "qa": "QA"}

for role, skills in skills_by_role.items():
    display = role_display.get(role, role.title())
    items = ""
    for cmd, desc in sorted(skills):
        items += f'''                        <li class="catalog-skill">
                            <span class="catalog-skill-dot"></span>
                            <code class="catalog-skill-command">/jaan-to:{cmd}</code>
                            <span class="catalog-skill-sep">&mdash;</span>
                            <span class="catalog-skill-desc">{desc}</span>
                        </li>\n'''

    pattern = (
        rf'(<span class="catalog-role-name">{display}</span>.*?'
        r'<ul class="catalog-skills">)\s*'
        r'(.*?)'
        r'(</ul>)'
    )
    replacement = r'\1\n' + items + r'                    \3'
    html = re.sub(pattern, replacement, html, flags=re.DOTALL)

if dry_run:
    print(f"[DRY RUN] Would update index.html:")
    print(f"  Version: {version}")
    print(f"  Total skills: {total}")
    print(f"  Active roles: {active_roles}")
    for role, skills in sorted(skills_by_role.items()):
        print(f"  {role_display.get(role, role)}: {len(skills)} skills")
        for cmd, _ in skills:
            print(f"    - /jaan-to:{cmd}")
else:
    with open(index_path, 'w') as f:
        f.write(html)
    print(f"Updated index.html: v{version}, {total} skills, {active_roles} roles")

PYEOF
