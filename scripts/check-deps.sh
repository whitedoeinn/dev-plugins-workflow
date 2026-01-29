#!/usr/bin/env bash
# SessionStart hook: Auto-update wdi plugin
#
# Keeps consuming repos on the latest plugin version automatically.
# Skips update in maintainer mode (when running from plugin source).
#
# For environment issues or registry cleanup, run: ./install.sh --reset

# Skip in maintainer mode (running from plugin source)
if [[ -f "$PWD/.claude-plugin/plugin.json" ]]; then
  PLUGIN_NAME=$(jq -r '.name' "$PWD/.claude-plugin/plugin.json" 2>/dev/null || echo "")
  if [[ "$PLUGIN_NAME" == "wdi" ]]; then
    exit 0
  fi
fi

# Auto-update: refresh marketplace, then update plugin
# Runs silently - errors are not fatal (user can still work)
claude plugin marketplace update wdi-marketplace 2>/dev/null || true
claude plugin update wdi@wdi-marketplace 2>/dev/null || true
