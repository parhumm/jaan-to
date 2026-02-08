#!/bin/bash
# Prebuild script for Docusaurus
# Copies CHANGELOG.md and CONTRIBUTING.md with frontmatter injection
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$DOCS_ROOT/../.." && pwd)"

mkdir -p "$DOCS_ROOT/src/pages"

# Copy CHANGELOG with frontmatter
if [[ -f "$REPO_ROOT/CHANGELOG.md" ]]; then
  printf -- '---\ntitle: Changelog\n---\n\n' | cat - "$REPO_ROOT/CHANGELOG.md" > "$DOCS_ROOT/src/pages/changelog.md"
fi

# Copy CONTRIBUTING with frontmatter
if [[ -f "$REPO_ROOT/CONTRIBUTING.md" ]]; then
  printf -- '---\ntitle: Contributing\n---\n\n' | cat - "$REPO_ROOT/CONTRIBUTING.md" > "$DOCS_ROOT/src/pages/contributing.md"
fi
