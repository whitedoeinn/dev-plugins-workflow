#!/usr/bin/env bash
# Sync local plugin changes to Claude Code cache
# Temporary workaround until proper semver is implemented

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_JSON="$PLUGIN_ROOT/.claude-plugin/plugin.json"

cd "$PLUGIN_ROOT"

# Compute hash of plugin content
HASH=$(find commands skills hooks -type f 2>/dev/null | sort | xargs cat 2>/dev/null | shasum -a 256 | cut -c1-12)

# Update plugin.json version
if command -v jq >/dev/null 2>&1; then
  jq --arg v "$HASH" '.version = $v' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"
else
  # Fallback without jq
  sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$HASH\"/" "$PLUGIN_JSON" && rm -f "$PLUGIN_JSON.bak"
fi

echo "Version set to: $HASH"

# Update plugin
claude plugin update wdi-workflows@wdi-workflows-local --scope project

echo ""
echo "Restart Claude Code to apply changes."
