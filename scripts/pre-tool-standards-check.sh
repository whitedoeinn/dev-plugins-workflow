#!/bin/bash
# PreToolUse hook for standards file change detection
# Part of the Standards Update Protocol
#
# This hook intercepts Bash commands and checks for git commits
# when standard files are staged. It warns but doesn't block.

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Extract the command being run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only process git commit commands
if [[ ! "$COMMAND" =~ ^git[[:space:]]+commit ]] && [[ ! "$COMMAND" =~ \&\&[[:space:]]*git[[:space:]]+commit ]]; then
  exit 0
fi

# Check for staged standard files
STAGED_STANDARDS=$(git diff --cached --name-only 2>/dev/null | grep "^docs/standards/.*\.md$" || true)

if [ -n "$STAGED_STANDARDS" ]; then
  # Output warning to stderr (shown to user)
  {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Standards file change detected in commit"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Changed standards:"
    echo "$STAGED_STANDARDS" | while read -r file; do
      basename "$file" | sed 's/.md$//'
    done
    echo ""
    echo "Ensure you've updated all dependent files."
    echo "See: knowledge/standards-dependency-map.md"
    echo ""
    echo "To check impact: /wdi-workflows:update-standard --analyze"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  } >&2
fi

# Exit 0 to allow the commit (advisory only, not blocking)
exit 0
