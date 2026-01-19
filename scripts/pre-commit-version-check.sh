#!/bin/bash
# Pre-commit hook: Ensure version bump for plugin repos
#
# This is a SAFETY NET - the primary workflow is the commit skill.
# This hook catches accidental direct `git commit` usage.
#
# Installation:
#   cp scripts/pre-commit-version-check.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Bypass (not recommended):
#   git commit --no-verify

set -e

PLUGIN_JSON=".claude-plugin/plugin.json"

# Skip if not a plugin repo
if [ ! -f "$PLUGIN_JSON" ]; then
  exit 0
fi

# Get staged files, excluding plugin.json itself
STAGED=$(git diff --cached --name-only | grep -v "^\.claude-plugin/plugin\.json$" || true)
PLUGIN_STAGED=$(git diff --cached --name-only | grep "^\.claude-plugin/plugin\.json$" || true)

# If there are staged changes but plugin.json isn't staged, warn
if [ -n "$STAGED" ] && [ -z "$PLUGIN_STAGED" ]; then
  echo ""
  echo "================================================================"
  echo "  ERROR: Committing without version bump!"
  echo "================================================================"
  echo ""
  echo "Claude Code caches plugins by version. Without a bump,"
  echo "your changes won't propagate to consuming projects."
  echo ""
  echo "Solutions:"
  echo ""
  echo "  1. USE COMMIT SKILL (recommended):"
  echo "     Say 'commit these changes' to Claude"
  echo ""
  echo "  2. BUMP MANUALLY:"
  echo "     ./scripts/bump-version.sh patch"
  echo "     git add .claude-plugin/plugin.json"
  echo "     git commit"
  echo ""
  echo "  3. BYPASS (not recommended):"
  echo "     git commit --no-verify"
  echo ""
  echo "================================================================"
  exit 1
fi

# If we get here, either:
# - plugin.json is being updated (version bump in progress)
# - no other files are staged (version-only commit)
exit 0
