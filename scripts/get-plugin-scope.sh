#!/usr/bin/env bash
# Plugin Scope Detection Utility
#
# Returns the scope at which a plugin is currently installed.
# Used by other scripts to ensure remediation uses the correct scope.
#
# Usage:
#   ./get-plugin-scope.sh <plugin-name>
#   SCOPE=$(./get-plugin-scope.sh wdi)
#
# Returns:
#   "user" if installed at user scope (global)
#   "project" if installed at project scope
#   "project" as fallback if not found (safer default)

set -euo pipefail

PLUGIN_NAME="${1:-}"

if [[ -z "$PLUGIN_NAME" ]]; then
  echo "project"
  exit 0
fi

# Check user settings first (global installation)
USER_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$USER_SETTINGS" ]]; then
  if command -v jq &>/dev/null; then
    if jq -e ".enabledPlugins | keys[] | select(startswith(\"$PLUGIN_NAME@\"))" "$USER_SETTINGS" &>/dev/null; then
      echo "user"
      exit 0
    fi
  else
    # Fallback without jq
    if grep -q "\"${PLUGIN_NAME}@" "$USER_SETTINGS" 2>/dev/null; then
      echo "user"
      exit 0
    fi
  fi
fi

# Check project settings
PROJECT_SETTINGS="${CLAUDE_PROJECT_DIR:-.}/.claude/settings.json"
if [[ -f "$PROJECT_SETTINGS" ]]; then
  if command -v jq &>/dev/null; then
    if jq -e ".enabledPlugins | keys[] | select(startswith(\"$PLUGIN_NAME@\"))" "$PROJECT_SETTINGS" &>/dev/null; then
      echo "project"
      exit 0
    fi
  else
    # Fallback without jq
    if grep -q "\"${PLUGIN_NAME}@" "$PROJECT_SETTINGS" 2>/dev/null; then
      echo "project"
      exit 0
    fi
  fi
fi

# Default to project scope (safer - won't affect global state)
echo "project"
