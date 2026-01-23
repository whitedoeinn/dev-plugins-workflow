#!/usr/bin/env bats
# Unit tests for plugin deduplication logic in check-deps.sh and machine-setup.sh
#
# Tests the jq filters that clean up duplicate plugin entries in installed_plugins.json
# This logic has broken multiple times (#52), so we test it thoroughly.

load '../test_helper'

setup() {
  setup_temp_dir
  export INSTALLED_PLUGINS="${TEST_TEMP_DIR}/installed_plugins.json"
}

teardown() {
  teardown_temp_dir
}

# Helper to run the dedup jq filter (same as in machine-setup.sh)
run_dedup_filter() {
  jq '
    .plugins["wdi@wdi-marketplace"] = (
      [.plugins["wdi@wdi-marketplace"][]? | select(.scope == "user")]
      | sort_by(.installedAt) | if length > 0 then [last] else [] end
    )
  ' "$INSTALLED_PLUGINS"
}

# ==============================================================================
# Duplicate user-scope entries (the bug from #52)
# ==============================================================================

@test "dedup: multiple user-scope entries keeps most recent" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {
        "scope": "user",
        "version": "0.3.29",
        "installedAt": "2026-01-23T00:30:06.567Z"
      },
      {
        "scope": "user",
        "version": "0.3.29",
        "installedAt": "2026-01-22T18:44:24.611Z"
      }
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  # Should have exactly one entry
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 1 ]
  # Should keep the most recent (2026-01-23)
  kept_date=$(echo "$output" | jq -r '.plugins["wdi@wdi-marketplace"][0].installedAt')
  [ "$kept_date" = "2026-01-23T00:30:06.567Z" ]
}

@test "dedup: three user-scope entries keeps most recent" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {
        "scope": "user",
        "version": "0.3.27",
        "installedAt": "2026-01-20T10:00:00.000Z"
      },
      {
        "scope": "user",
        "version": "0.3.29",
        "installedAt": "2026-01-23T00:30:06.567Z"
      },
      {
        "scope": "user",
        "version": "0.3.28",
        "installedAt": "2026-01-21T12:00:00.000Z"
      }
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 1 ]
  kept_date=$(echo "$output" | jq -r '.plugins["wdi@wdi-marketplace"][0].installedAt')
  [ "$kept_date" = "2026-01-23T00:30:06.567Z" ]
}

# ==============================================================================
# Mixed scope entries
# ==============================================================================

@test "dedup: user + project scope keeps user scope" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {
        "scope": "user",
        "version": "0.3.29",
        "installedAt": "2026-01-22T18:44:24.611Z"
      },
      {
        "scope": "project",
        "version": "0.3.29",
        "installedAt": "2026-01-23T00:30:06.567Z"
      }
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 1 ]
  kept_scope=$(echo "$output" | jq -r '.plugins["wdi@wdi-marketplace"][0].scope')
  [ "$kept_scope" = "user" ]
}

@test "dedup: multiple user + project keeps most recent user" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {
        "scope": "user",
        "version": "0.3.28",
        "installedAt": "2026-01-21T00:00:00.000Z"
      },
      {
        "scope": "project",
        "version": "0.3.29",
        "installedAt": "2026-01-23T12:00:00.000Z"
      },
      {
        "scope": "user",
        "version": "0.3.29",
        "installedAt": "2026-01-22T00:00:00.000Z"
      }
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 1 ]
  kept_date=$(echo "$output" | jq -r '.plugins["wdi@wdi-marketplace"][0].installedAt')
  [ "$kept_date" = "2026-01-22T00:00:00.000Z" ]
}

# ==============================================================================
# Clean state (no duplicates)
# ==============================================================================

@test "dedup: single user-scope entry unchanged" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {
        "scope": "user",
        "version": "0.3.29",
        "installedAt": "2026-01-23T00:30:06.567Z"
      }
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 1 ]
}

# ==============================================================================
# Edge cases
# ==============================================================================

@test "dedup: empty plugin array returns empty array" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": []
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 0 ]
}

@test "dedup: missing plugin key returns empty array" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "other-plugin@marketplace": [
      {"scope": "user", "version": "1.0.0", "installedAt": "2026-01-01T00:00:00.000Z"}
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 0 ]
}

@test "dedup: only project-scope entries returns empty array" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {
        "scope": "project",
        "version": "0.3.29",
        "installedAt": "2026-01-23T00:30:06.567Z"
      }
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  result_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$result_count" -eq 0 ]
}

@test "dedup: preserves other plugins unchanged" {
  cat > "$INSTALLED_PLUGINS" << 'EOF'
{
  "version": 2,
  "plugins": {
    "wdi@wdi-marketplace": [
      {"scope": "user", "version": "0.3.29", "installedAt": "2026-01-23T00:00:00.000Z"},
      {"scope": "user", "version": "0.3.28", "installedAt": "2026-01-22T00:00:00.000Z"}
    ],
    "compound-engineering@every-marketplace": [
      {"scope": "user", "version": "2.28.0", "installedAt": "2026-01-23T00:00:00.000Z"}
    ]
  }
}
EOF

  run run_dedup_filter

  assert_success
  # wdi should be deduped
  wdi_count=$(echo "$output" | jq '.plugins["wdi@wdi-marketplace"] | length')
  [ "$wdi_count" -eq 1 ]
  # compound-engineering should be unchanged
  ce_count=$(echo "$output" | jq '.plugins["compound-engineering@every-marketplace"] | length')
  [ "$ce_count" -eq 1 ]
}
