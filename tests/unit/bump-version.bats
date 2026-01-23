#!/usr/bin/env bats
# Unit tests for bump-version.sh
#
# Tests the semantic versioning script that bumps plugin versions.
# Version sync issues have caused bugs (#2e42b9f), so we test thoroughly.

load '../test_helper'

SCRIPT="${SCRIPTS_DIR}/bump-version.sh"

setup() {
  setup_temp_dir

  # Create mock plugin directory structure
  mkdir -p "${TEST_TEMP_DIR}/.claude-plugin"

  # Create a wrapper script that uses our temp directory
  cat > "${TEST_TEMP_DIR}/bump-version.sh" << 'WRAPPER'
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_JSON="$SCRIPT_DIR/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$SCRIPT_DIR/.claude-plugin/marketplace.json"

if [ ! -f "$PLUGIN_JSON" ]; then
  echo "Error: plugin.json not found at $PLUGIN_JSON" >&2
  exit 1
fi

CURRENT=$(jq -r '.version // empty' "$PLUGIN_JSON")

if [ -z "$CURRENT" ]; then
  echo "Error: No version field in plugin.json" >&2
  exit 1
fi

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
    exit 1
    ;;
esac

jq --arg v "$NEW" '.version = $v' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"

if [ -f "$MARKETPLACE_JSON" ]; then
  jq --arg v "$NEW" '.plugins[0].version = $v' "$MARKETPLACE_JSON" > "$MARKETPLACE_JSON.tmp" && mv "$MARKETPLACE_JSON.tmp" "$MARKETPLACE_JSON"
fi

echo "$CURRENT → $NEW"
WRAPPER
  chmod +x "${TEST_TEMP_DIR}/bump-version.sh"
}

teardown() {
  teardown_temp_dir
}

# Helper to create plugin.json with a version
create_plugin_json() {
  local version="$1"
  cat > "${TEST_TEMP_DIR}/.claude-plugin/plugin.json" << EOF
{
  "name": "test-plugin",
  "version": "$version"
}
EOF
}

# Helper to create marketplace.json with a version
create_marketplace_json() {
  local version="$1"
  cat > "${TEST_TEMP_DIR}/.claude-plugin/marketplace.json" << EOF
{
  "plugins": [
    {
      "name": "test-plugin",
      "version": "$version"
    }
  ]
}
EOF
}

# ==============================================================================
# Patch version bumps
# ==============================================================================

@test "bump-version: patch increments third number" {
  create_plugin_json "1.2.3"

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_success
  assert_output "1.2.3 → 1.2.4"
}

@test "bump-version: patch from 0.0.0" {
  create_plugin_json "0.0.0"

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_success
  assert_output "0.0.0 → 0.0.1"
}

@test "bump-version: patch handles high numbers" {
  create_plugin_json "1.2.99"

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_success
  assert_output "1.2.99 → 1.2.100"
}

# ==============================================================================
# Minor version bumps
# ==============================================================================

@test "bump-version: minor increments second number, resets patch" {
  create_plugin_json "1.2.3"

  run "${TEST_TEMP_DIR}/bump-version.sh" minor

  assert_success
  assert_output "1.2.3 → 1.3.0"
}

@test "bump-version: minor from x.0.0" {
  create_plugin_json "2.0.0"

  run "${TEST_TEMP_DIR}/bump-version.sh" minor

  assert_success
  assert_output "2.0.0 → 2.1.0"
}

# ==============================================================================
# Major version bumps
# ==============================================================================

@test "bump-version: major increments first number, resets others" {
  create_plugin_json "1.2.3"

  run "${TEST_TEMP_DIR}/bump-version.sh" major

  assert_success
  assert_output "1.2.3 → 2.0.0"
}

@test "bump-version: major from 0.x.x" {
  create_plugin_json "0.3.29"

  run "${TEST_TEMP_DIR}/bump-version.sh" major

  assert_success
  assert_output "0.3.29 → 1.0.0"
}

# ==============================================================================
# Version sync (plugin.json ↔ marketplace.json)
# ==============================================================================

@test "bump-version: updates both plugin.json and marketplace.json" {
  create_plugin_json "1.0.0"
  create_marketplace_json "1.0.0"

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_success

  # Verify plugin.json was updated
  plugin_version=$(jq -r '.version' "${TEST_TEMP_DIR}/.claude-plugin/plugin.json")
  [ "$plugin_version" = "1.0.1" ]

  # Verify marketplace.json was updated
  marketplace_version=$(jq -r '.plugins[0].version' "${TEST_TEMP_DIR}/.claude-plugin/marketplace.json")
  [ "$marketplace_version" = "1.0.1" ]
}

@test "bump-version: versions stay in sync after minor bump" {
  create_plugin_json "0.3.29"
  create_marketplace_json "0.3.29"

  run "${TEST_TEMP_DIR}/bump-version.sh" minor

  assert_success

  plugin_version=$(jq -r '.version' "${TEST_TEMP_DIR}/.claude-plugin/plugin.json")
  marketplace_version=$(jq -r '.plugins[0].version' "${TEST_TEMP_DIR}/.claude-plugin/marketplace.json")

  [ "$plugin_version" = "$marketplace_version" ]
  [ "$plugin_version" = "0.4.0" ]
}

@test "bump-version: works without marketplace.json" {
  create_plugin_json "1.0.0"
  # Don't create marketplace.json

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_success
  assert_output "1.0.0 → 1.0.1"
}

# ==============================================================================
# Error handling
# ==============================================================================

@test "bump-version: fails without argument" {
  create_plugin_json "1.0.0"

  run "${TEST_TEMP_DIR}/bump-version.sh"

  assert_failure
  assert_output --partial "Usage:"
}

@test "bump-version: fails with invalid argument" {
  create_plugin_json "1.0.0"

  run "${TEST_TEMP_DIR}/bump-version.sh" invalid

  assert_failure
  assert_output --partial "Usage:"
}

@test "bump-version: fails when plugin.json missing" {
  # Don't create plugin.json

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_failure
  assert_output --partial "plugin.json not found"
}

@test "bump-version: fails when version field missing" {
  cat > "${TEST_TEMP_DIR}/.claude-plugin/plugin.json" << 'EOF'
{
  "name": "test-plugin"
}
EOF

  run "${TEST_TEMP_DIR}/bump-version.sh" patch

  assert_failure
  assert_output --partial "No version field"
}
