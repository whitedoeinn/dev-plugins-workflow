#!/bin/bash
# Validates that the dependency map matches actual file references
# Part of the Standards Update Protocol
#
# Usage: ./scripts/validate-dependency-map.sh [--fix]
#
# Exit codes:
#   0 = Map is valid
#   1 = Map has issues (missing files or undocumented references)

set -e

FIX_MODE=false
if [ "$1" = "--fix" ]; then
  FIX_MODE=true
fi

STANDARDS_DIR="docs/standards"
MAP_FILE="knowledge/standards-dependency-map.md"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Validating Standards Dependency Map"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check map file exists
if [ ! -f "$MAP_FILE" ]; then
  echo -e "${RED}ERROR: Map file not found: $MAP_FILE${NC}"
  exit 1
fi

# Get list of standards
STANDARDS=$(ls -1 "$STANDARDS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | grep -v "STANDARDS-UPDATE-PROTOCOL")

echo "Standards found: $(echo "$STANDARDS" | wc -l | tr -d ' ')"
echo ""

# For each standard, find actual references
for STANDARD in $STANDARDS; do
  echo "Checking: $STANDARD.md"

  # Files that reference this standard (excluding meta files that reference ALL standards)
  ACTUAL_REFS=$(grep -rl "$STANDARD" --include="*.md" --include="*.sh" . 2>/dev/null \
    | grep -v "$STANDARDS_DIR/$STANDARD.md" \
    | grep -v "$MAP_FILE" \
    | grep -v ".git" \
    | grep -v "docs/changelog.md" \
    | grep -v "commands/update-standard.md" \
    | grep -v "docs/standards/STANDARDS-UPDATE-PROTOCOL.md" \
    | grep -v "^./README.md$" \
    | grep -v "^./CLAUDE.md$" \
    | sort -u || true)

  # Files listed in map for this standard
  MAP_REFS=$(grep -A 20 "## $STANDARD.md" "$MAP_FILE" 2>/dev/null \
    | grep -E "^- " \
    | sed 's/^- //' \
    | sed 's/ (.*//' \
    | grep -v "^$" || true)

  # Check for files in reality but not in map
  for FILE in $ACTUAL_REFS; do
    FILE_CLEAN=$(echo "$FILE" | sed 's|^\./||')
    if ! echo "$MAP_REFS" | grep -q "$FILE_CLEAN"; then
      echo -e "  ${YELLOW}UNDOCUMENTED: $FILE_CLEAN references $STANDARD but not in map${NC}"
      ((WARNINGS++)) || true
    fi
  done

  # Check for files in map but not in reality
  for FILE in $MAP_REFS; do
    if [ ! -f "$FILE" ]; then
      echo -e "  ${RED}MISSING: $FILE listed in map but doesn't exist${NC}"
      ((ERRORS++)) || true
    fi
  done

  # Count actual references for impact score
  ACTUAL_COUNT=$(echo "$ACTUAL_REFS" | grep -c "." || echo "0")
  echo "  Actual references: $ACTUAL_COUNT files"
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}ERRORS: $ERRORS (files in map don't exist)${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}WARNINGS: $WARNINGS (undocumented references)${NC}"
  echo ""
  echo "To add missing references to map, run:"
  echo "  /wdi-workflows:update-standard --analyze"
fi

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}Map is valid and complete${NC}"
  exit 0
fi

if [ $ERRORS -gt 0 ]; then
  exit 1
fi

exit 0
