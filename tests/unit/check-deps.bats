#!/usr/bin/env bats
# Unit tests for check-deps.sh
#
# Tests the session-start dependency checker, including:
# - Plugin auto-update order (marketplace refresh before plugin update)
# - Maintainer mode detection (skips update in plugin source repo)

load '../test_helper'

# Path to the script under test
SCRIPT="${SCRIPTS_DIR}/check-deps.sh"

setup() {
  setup_temp_dir

  # Create mock plugin structure
  export MOCK_PLUGIN_ROOT="${TEST_TEMP_DIR}/plugin"
  mkdir -p "${MOCK_PLUGIN_ROOT}/scripts"

  # Copy scripts to mock location
  cp "$SCRIPT" "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"
  chmod +x "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  # Create a minimal validate-env.sh that always passes
  cat > "${MOCK_PLUGIN_ROOT}/scripts/validate-env.sh" << 'EOF'
#!/bin/bash
echo "Environment validated"
echo "  Plugins: 0 checked"
echo "  Tools: 0 checked"
exit 0
EOF
  chmod +x "${MOCK_PLUGIN_ROOT}/scripts/validate-env.sh"

  # Track claude command invocations
  export CLAUDE_INVOCATIONS="${TEST_TEMP_DIR}/claude_invocations.log"

  # Create mock claude command that logs invocations
  mkdir -p "${TEST_TEMP_DIR}/bin"
  cat > "${TEST_TEMP_DIR}/bin/claude" << 'EOF'
#!/bin/bash
echo "$*" >> "$CLAUDE_INVOCATIONS"
exit 0
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/claude"

  # Create mock jq that works for our tests
  cat > "${TEST_TEMP_DIR}/bin/jq" << 'EOF'
#!/bin/bash
# Simple jq mock that handles our specific use cases
if [[ "$*" == *".name"* ]]; then
  echo "not-wdi"
elif [[ "$*" == *"wdi@wdi-marketplace"* ]]; then
  echo "1"
else
  /usr/bin/jq "$@"
fi
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/jq"

  # Create mock git
  cat > "${TEST_TEMP_DIR}/bin/git" << 'EOF'
#!/bin/bash
if [[ "$1" == "rev-parse" ]]; then
  echo "/some/repo"
fi
exit 0
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/git"

  # Prepend mock bin to PATH
  export PATH="${TEST_TEMP_DIR}/bin:$PATH"

  # Create empty installed_plugins.json
  mkdir -p "${TEST_TEMP_DIR}/home/.claude/plugins"
  echo '{"plugins":{}}' > "${TEST_TEMP_DIR}/home/.claude/plugins/installed_plugins.json"
  export HOME="${TEST_TEMP_DIR}/home"
}

teardown() {
  teardown_temp_dir
}

# ==============================================================================
# Auto-update order tests
# ==============================================================================

@test "check-deps: calls marketplace update before plugin update" {
  # Run from a non-wdi directory (should trigger auto-update)
  cd "${TEST_TEMP_DIR}"

  run "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  assert_success

  # Verify invocation log exists
  [ -f "$CLAUDE_INVOCATIONS" ]

  # Get the order of calls
  FIRST_CALL=$(head -1 "$CLAUDE_INVOCATIONS")
  SECOND_CALL=$(tail -1 "$CLAUDE_INVOCATIONS")

  # First call should be marketplace update
  [[ "$FIRST_CALL" == *"plugin marketplace update wdi-marketplace"* ]]

  # Second call should be plugin update
  [[ "$SECOND_CALL" == *"plugin update wdi@wdi-marketplace"* ]]
}

@test "check-deps: skips auto-update in maintainer mode (wdi plugin directory)" {
  # Create a fake wdi plugin directory
  mkdir -p "${TEST_TEMP_DIR}/wdi-plugin/.claude-plugin"
  cat > "${TEST_TEMP_DIR}/wdi-plugin/.claude-plugin/plugin.json" << 'EOF'
{"name": "wdi", "version": "1.0.0"}
EOF

  # Override jq mock to return "wdi" for this test
  cat > "${TEST_TEMP_DIR}/bin/jq" << 'EOF'
#!/bin/bash
if [[ "$*" == *".name"* ]]; then
  echo "wdi"
else
  /usr/bin/jq "$@"
fi
EOF

  cd "${TEST_TEMP_DIR}/wdi-plugin"

  run "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  assert_success

  # Should NOT have any claude plugin invocations (maintainer mode skips update)
  if [ -f "$CLAUDE_INVOCATIONS" ]; then
    ! grep -q "plugin" "$CLAUDE_INVOCATIONS"
  fi
}

@test "check-deps: auto-update runs in non-plugin directories" {
  # Just a regular directory, not a plugin
  mkdir -p "${TEST_TEMP_DIR}/regular-project"
  cd "${TEST_TEMP_DIR}/regular-project"

  run "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  assert_success

  # Should have claude plugin invocations
  [ -f "$CLAUDE_INVOCATIONS" ]
  grep -q "plugin" "$CLAUDE_INVOCATIONS"
}

@test "check-deps: auto-update runs when plugin.json exists but is not wdi" {
  # Create a different plugin directory
  mkdir -p "${TEST_TEMP_DIR}/other-plugin/.claude-plugin"
  cat > "${TEST_TEMP_DIR}/other-plugin/.claude-plugin/plugin.json" << 'EOF'
{"name": "other-plugin", "version": "1.0.0"}
EOF

  cd "${TEST_TEMP_DIR}/other-plugin"

  run "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  assert_success

  # Should have claude plugin invocations (not in wdi maintainer mode)
  [ -f "$CLAUDE_INVOCATIONS" ]
  grep -q "plugin marketplace update" "$CLAUDE_INVOCATIONS"
  grep -q "plugin update" "$CLAUDE_INVOCATIONS"
}

# ==============================================================================
# Error handling tests
# ==============================================================================

@test "check-deps: continues if marketplace update fails" {
  # Make marketplace update fail
  cat > "${TEST_TEMP_DIR}/bin/claude" << 'EOF'
#!/bin/bash
echo "$*" >> "$CLAUDE_INVOCATIONS"
if [[ "$*" == *"marketplace update"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/claude"

  cd "${TEST_TEMP_DIR}"

  run "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  # Should still succeed (errors are suppressed with || true)
  assert_success

  # Should still attempt plugin update after marketplace update fails
  grep -q "plugin update" "$CLAUDE_INVOCATIONS"
}

@test "check-deps: continues if plugin update fails" {
  # Make plugin update fail
  cat > "${TEST_TEMP_DIR}/bin/claude" << 'EOF'
#!/bin/bash
echo "$*" >> "$CLAUDE_INVOCATIONS"
if [[ "$*" == *"plugin update wdi"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/claude"

  cd "${TEST_TEMP_DIR}"

  run "${MOCK_PLUGIN_ROOT}/scripts/check-deps.sh"

  # Should still succeed (errors are suppressed with || true)
  assert_success
}
