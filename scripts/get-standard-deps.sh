#!/bin/bash
# Returns dependencies for a given standard in structured format
# Used by /wdi-workflows:update-standard command
#
# Usage: ./scripts/get-standard-deps.sh <STANDARD-NAME>
#        ./scripts/get-standard-deps.sh --list
#
# Output: JSON-like structured data for reliable parsing

set -e

MAP_FILE="knowledge/standards-dependency-map.md"
STANDARDS_DIR="docs/standards"

if [ ! -f "$MAP_FILE" ]; then
  echo "ERROR: Map file not found: $MAP_FILE" >&2
  exit 1
fi

# List mode
if [ "$1" = "--list" ]; then
  echo "STANDARDS:"
  ls -1 "$STANDARDS_DIR"/*.md 2>/dev/null \
    | xargs -I{} basename {} .md \
    | grep -v "STANDARDS-UPDATE-PROTOCOL" \
    | while read -r std; do
      # Get impact score from map
      SCORE=$(grep -A 30 "## $std.md" "$MAP_FILE" 2>/dev/null \
        | grep "Impact score" \
        | head -1 \
        | sed 's/.*\*\* //' \
        | sed 's/ .*//' || echo "?")
      echo "  $std: $SCORE files"
    done
  exit 0
fi

# Check standard name provided
if [ -z "$1" ]; then
  echo "Usage: $0 <STANDARD-NAME> | --list" >&2
  exit 1
fi

STANDARD="$1"
STANDARD_FILE="$STANDARDS_DIR/$STANDARD.md"

# Check standard exists
if [ ! -f "$STANDARD_FILE" ]; then
  echo "ERROR: Standard not found: $STANDARD_FILE" >&2
  echo "Available standards:" >&2
  ls -1 "$STANDARDS_DIR"/*.md | xargs -I{} basename {} .md | grep -v "STANDARDS-UPDATE-PROTOCOL" >&2
  exit 1
fi

# Extract section for this standard from map
SECTION=$(awk "/^## $STANDARD.md/,/^---/" "$MAP_FILE" | sed '$d')

if [ -z "$SECTION" ]; then
  echo "ERROR: Standard not found in dependency map: $STANDARD" >&2
  exit 1
fi

# Parse enforced by
echo "STANDARD: $STANDARD"
echo ""
echo "ENFORCED_BY:"
echo "$SECTION" | sed -n '/\*\*Enforced by:\*\*/,/^\*\*/p' | grep "^- " | sed 's/^- /  /'

echo ""
echo "REFERENCED_BY:"
echo "$SECTION" | sed -n '/\*\*Referenced by:\*\*/,/^\*\*/p' | grep "^- " | sed 's/^- /  /'

echo ""
SCORE=$(echo "$SECTION" | grep "Impact score" | sed 's/.*\*\* //' | sed 's/ .*//')
echo "IMPACT_SCORE: $SCORE"

# Determine complexity
if [ "$SCORE" -ge 6 ] 2>/dev/null; then
  echo "COMPLEXITY: High"
elif [ "$SCORE" -ge 4 ] 2>/dev/null; then
  echo "COMPLEXITY: Moderate"
else
  echo "COMPLEXITY: Simple"
fi
