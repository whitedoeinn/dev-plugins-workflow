#!/bin/bash
# Pre-commit hook for standards file change detection
# Part of the Standards Update Protocol
#
# This hook triggers when any file in docs/standards/*.md is staged.
# It shows an impact analysis and suggests running the update-standard command.

set -e

# Check for staged standard files
STAGED_STANDARDS=$(git diff --cached --name-only 2>/dev/null | grep "^docs/standards/.*\.md$" || true)

if [ -n "$STAGED_STANDARDS" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Standards file change detected"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Changed standards:"
  echo "$STAGED_STANDARDS" | while read -r file; do
    basename "$file" | sed 's/.md$//'
  done
  echo ""
  echo "Before committing, ensure you've updated all dependent files."
  echo ""
  echo "Run impact analysis:"
  echo "  /wdi-workflows:update-standard --analyze"
  echo ""
  echo "Or use the full update workflow:"
  echo "  /wdi-workflows:update-standard <STANDARD-NAME>"
  echo ""
  echo "See: knowledge/standards-dependency-map.md for dependencies"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
