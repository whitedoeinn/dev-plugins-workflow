#!/bin/bash
# Bump plugin version (semver)
# Usage: bump-version.sh [major|minor|patch]
#
# Examples:
#   ./scripts/bump-version.sh patch  # 0.1.0 → 0.1.1
#   ./scripts/bump-version.sh minor  # 0.1.1 → 0.2.0
#   ./scripts/bump-version.sh major  # 0.2.0 → 1.0.0

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_JSON="$SCRIPT_DIR/../.claude-plugin/plugin.json"

if [ ! -f "$PLUGIN_JSON" ]; then
  echo "Error: plugin.json not found at $PLUGIN_JSON" >&2
  exit 1
fi

CURRENT=$(jq -r '.version // empty' "$PLUGIN_JSON")

if [ -z "$CURRENT" ]; then
  echo "Error: No version field in plugin.json" >&2
  exit 1
fi

# Parse current version (handle pre-release suffix if present)
BASE_VERSION=$(echo "$CURRENT" | cut -d'-' -f1)
IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

case "$1" in
  major)
    NEW="$((MAJOR+1)).0.0"
    ;;
  minor)
    NEW="$MAJOR.$((MINOR+1)).0"
    ;;
  patch)
    NEW="$MAJOR.$MINOR.$((PATCH+1))"
    ;;
  *)
    echo "Usage: bump-version.sh [major|minor|patch]" >&2
    echo "" >&2
    echo "Versioning policy (0.x.x development):" >&2
    echo "  patch - Bug fixes, small enhancements" >&2
    echo "  minor - New features, breaking changes (in 0.x)" >&2
    echo "  major - Reserved for 1.0.0 release" >&2
    exit 1
    ;;
esac

# Update plugin.json
jq --arg v "$NEW" '.version = $v' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"

echo "$CURRENT → $NEW"
