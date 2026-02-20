#!/usr/bin/env bash
# Validate all outputs follow the standard structure
#
# Usage: bash scripts/validate-outputs.sh [path-to-outputs-dir]
#
# Exit codes:
#   0 - All outputs valid
#   1 - Validation errors found

set -euo pipefail

# Determine outputs directory
OUTPUTS_DIR="${1:-jaan-to/outputs}"

# Counters
ERRORS=0
WARNINGS=0

echo "Validating outputs in: $OUTPUTS_DIR"
echo "=========================================="
echo ""

# Check if outputs directory exists
if [[ ! -d "$OUTPUTS_DIR" ]]; then
  echo "ERROR: Outputs directory not found: $OUTPUTS_DIR"
  exit 1
fi

# Check 1: Each subdomain has README.md
echo "Check 1: Subdomain indexes..."
SUBDOMAIN_COUNT=0
for subdomain in $(find "$OUTPUTS_DIR" -mindepth 2 -maxdepth 2 -type d 2>/dev/null); do
  SUBDOMAIN_COUNT=$((SUBDOMAIN_COUNT + 1))
  if [[ ! -f "$subdomain/README.md" ]]; then
    echo "  ✗ Missing index: $subdomain/README.md"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $SUBDOMAIN_COUNT -eq 0 ]]; then
  echo "  ⚠ No subdomains found (this is OK if no outputs generated yet)"
  WARNINGS=$((WARNINGS + 1))
else
  echo "  ✓ Checked $SUBDOMAIN_COUNT subdomains"
fi
echo ""

# Check 2: Folder naming pattern
echo "Check 2: Folder naming pattern..."
FOLDER_COUNT=0
for folder in $(find "$OUTPUTS_DIR" -mindepth 3 -maxdepth 3 -type d 2>/dev/null); do
  FOLDER_COUNT=$((FOLDER_COUNT + 1))
  folder_name=$(basename "$folder")

  # Check pattern: NN-slug (two digits, hyphen, lowercase alphanumeric with hyphens)
  if [[ ! "$folder_name" =~ ^[0-9]{2}-[a-z0-9-]+$ ]]; then
    echo "  ✗ Invalid folder name: $folder"
    echo "    Expected: NN-slug (e.g., 01-user-auth)"
    echo "    Found: $folder_name"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $FOLDER_COUNT -eq 0 ]]; then
  echo "  ⚠ No output folders found (this is OK if no outputs generated yet)"
  WARNINGS=$((WARNINGS + 1))
else
  echo "  ✓ Checked $FOLDER_COUNT output folders"
fi
echo ""

# Check 3: File naming inside folders
echo "Check 3: File naming consistency..."
FILE_COUNT=0
for file in $(find "$OUTPUTS_DIR" -mindepth 4 -maxdepth 4 -type f -name "*.md" 2>/dev/null); do
  FILE_COUNT=$((FILE_COUNT + 1))
  file_name=$(basename "$file")
  folder_name=$(basename $(dirname "$file"))

  # Extract IDs
  folder_id=$(echo "$folder_name" | cut -d'-' -f1)
  file_id=$(echo "$file_name" | cut -d'-' -f1)

  # Check ID consistency
  if [[ "$folder_id" != "$file_id" ]]; then
    echo "  ✗ ID mismatch in $file"
    echo "    Folder ID: $folder_id (from $folder_name)"
    echo "    File ID: $file_id (from $file_name)"
    ERRORS=$((ERRORS + 1))
  fi

  # Check file naming pattern: NN-type-slug.md
  if [[ ! "$file_name" =~ ^[0-9]{2}-[a-z0-9-]+\.md$ ]]; then
    echo "  ✗ Invalid file name: $file"
    echo "    Expected: NN-type-slug.md (e.g., 01-prd-user-auth.md)"
    echo "    Found: $file_name"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $FILE_COUNT -eq 0 ]]; then
  echo "  ⚠ No output files found (this is OK if no outputs generated yet)"
  WARNINGS=$((WARNINGS + 1))
else
  echo "  ✓ Checked $FILE_COUNT output files"
fi
echo ""

# Check 4: Research files (flat structure exception)
echo "Check 4: Research files (flat structure)..."
RESEARCH_DIR="$OUTPUTS_DIR/research"
RESEARCH_COUNT=0

if [[ -d "$RESEARCH_DIR" ]]; then
  for file in $(find "$RESEARCH_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | grep -v "README.md"); do
    RESEARCH_COUNT=$((RESEARCH_COUNT + 1))
    file_name=$(basename "$file")

    # Check pattern: NN-category-slug.md
    if [[ ! "$file_name" =~ ^[0-9]{2}-[a-z0-9-]+\.md$ ]]; then
      echo "  ✗ Invalid research file name: $file"
      echo "    Expected: NN-category-slug.md (e.g., 01-ai-workflow-research.md)"
      echo "    Found: $file_name"
      ERRORS=$((ERRORS + 1))
    fi
  done

  if [[ $RESEARCH_COUNT -gt 0 ]]; then
    echo "  ✓ Checked $RESEARCH_COUNT research files"
  else
    echo "  ⚠ No research files found"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  ⚠ Research directory not found: $RESEARCH_DIR"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Summary
echo "=========================================="
echo "VALIDATION SUMMARY"
echo "=========================================="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -eq 0 ]]; then
  echo "✓ All outputs are valid!"
  echo ""
  echo "Structure compliance:"
  echo "  - Subdomains: $SUBDOMAIN_COUNT"
  echo "  - Output folders: $FOLDER_COUNT"
  echo "  - Output files: $FILE_COUNT"
  echo "  - Research files: $RESEARCH_COUNT"
  exit 0
else
  echo "✗ Found $ERRORS validation error(s)"
  echo ""
  echo "Please fix the errors above and re-run validation."
  echo ""
  echo "Common fixes:"
  echo "  - Rename folders to NN-slug format (e.g., 01-user-auth)"
  echo "  - Rename files to NN-type-slug.md format (e.g., 01-prd-user-auth.md)"
  echo "  - Ensure folder ID matches file ID prefix"
  echo "  - Create missing subdomain README.md files"
  exit 1
fi
