#!/bin/bash
# Setup GitHub branch protection rules for jaan-to
# Usage: ./scripts/setup-branch-protection.sh
# Requires: gh CLI authenticated with repo admin access

set -euo pipefail

REPO="parhumm/jaan-to"

echo "Setting up branch protection for $REPO..."
echo ""

# Check gh CLI is authenticated
if ! gh auth status &>/dev/null; then
  echo "Error: gh CLI not authenticated. Run: gh auth login"
  exit 1
fi

# Configure main branch protection using raw JSON input
echo "Configuring main branch protection..."
gh api repos/$REPO/branches/main/protection \
  --method PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["validate"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF

echo "✓ main branch protected"
echo "  - Require PR with 1 approval"
echo "  - Require status check: validate (release-check.yml)"
echo "  - Dismiss stale reviews on new commits"
echo "  - No force pushes"

# dev branch: no protection (allow direct pushes)
# If protection exists, remove it
if gh api repos/$REPO/branches/dev/protection &>/dev/null 2>&1; then
  echo ""
  echo "Removing protection from dev branch..."
  gh api repos/$REPO/branches/dev/protection --method DELETE >/dev/null
fi

echo ""
echo "✓ dev branch: no protection (direct pushes allowed)"

echo ""
echo "════════════════════════════════════════"
echo "  Branch protection configured!"
echo "════════════════════════════════════════"
echo ""
echo "main: PRs required, 1 approval, CI must pass"
echo "dev:  Direct pushes allowed"
