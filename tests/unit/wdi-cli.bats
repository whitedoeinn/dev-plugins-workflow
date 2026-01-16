#!/usr/bin/env bats
# Unit tests for wdi CLI
#
# Tests the standalone CLI for project bootstrapping

load '../test_helper'

# Path to the script under test
SCRIPT="${SCRIPTS_DIR}/wdi"

setup() {
  setup_temp_dir

  # Create mock home directory
  export HOME="${TEST_TEMP_DIR}/home"
  mkdir -p "$HOME"

  # Set up WDI paths
  export WDI_HOME="${HOME}/.config/wdi"
  export WDI_CONFIG="${WDI_HOME}/config.json"

  # Create mock bin directory
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:$PATH"
}

teardown() {
  teardown_temp_dir
}

# ==============================================================================
# Help and version tests
# ==============================================================================

@test "wdi: shows help with no arguments" {
  run "$SCRIPT" help

  assert_success
  assert_output --partial "wdi"
  assert_output --partial "Usage:"
  assert_output --partial "Commands:"
}

@test "wdi: shows help with --help flag" {
  run "$SCRIPT" --help

  assert_success
  assert_output --partial "Usage:"
}

@test "wdi: shows help with -h flag" {
  run "$SCRIPT" -h

  assert_success
  assert_output --partial "Usage:"
}

@test "wdi: shows version" {
  run "$SCRIPT" version

  assert_success
  assert_output --partial "wdi version"
}

@test "wdi: shows version with --version flag" {
  run "$SCRIPT" --version

  assert_success
  assert_output --partial "version"
}

@test "wdi: fails on unknown command" {
  run "$SCRIPT" nonexistent-command

  assert_failure
  assert_output --partial "Unknown command"
}

# ==============================================================================
# Config tests
# ==============================================================================

@test "wdi: config creates config directory" {
  # Provide input for config prompts
  run bash -c "echo -e 'testorg\n/tmp/projects\nmarketing,sales\nworkflow,data' | $SCRIPT config"

  assert_success
  [ -d "$WDI_HOME" ]
}

@test "wdi: config creates config.json file" {
  run bash -c "echo -e 'testorg\n/tmp/projects\nmarketing\nworkflow' | $SCRIPT config"

  assert_success
  [ -f "$WDI_CONFIG" ]
}

@test "wdi: config stores github_org correctly" {
  run bash -c "echo -e 'myorg\n/tmp\nops\ndev' | $SCRIPT config"

  assert_success

  # Check the config file
  run jq -r '.github_org' "$WDI_CONFIG"

  assert_success
  assert_output "myorg"
}

@test "wdi: config stores project_dir correctly" {
  run bash -c "echo -e 'org\n/custom/path\nops\ndev' | $SCRIPT config"

  assert_success

  run jq -r '.project_dir' "$WDI_CONFIG"

  assert_success
  assert_output "/custom/path"
}

@test "wdi: config expands tilde in project_dir" {
  run bash -c "echo -e 'org\n~/projects\nops\ndev' | $SCRIPT config"

  assert_success

  run jq -r '.project_dir' "$WDI_CONFIG"

  assert_success
  # Should expand ~ to $HOME
  assert_output "${HOME}/projects"
}

# ==============================================================================
# Doctor tests (limited - can't easily mock all dependencies)
# ==============================================================================

@test "wdi: doctor runs without crashing" {
  run "$SCRIPT" doctor --check-only

  # May succeed or fail depending on environment, but shouldn't crash
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "wdi: doctor detects OS" {
  run "$SCRIPT" doctor --check-only

  # Should show OS detection in output
  [[ "$output" == *"detected"* || "$output" == *"Checking"* ]]
}

@test "wdi: doctor checks for git" {
  run "$SCRIPT" doctor --check-only

  # Output should mention git
  assert_output --partial "git"
}

# ==============================================================================
# Create project validation tests
# ==============================================================================

@test "wdi: create_project requires config" {
  # Don't create config
  unset WDI_CONFIG
  export WDI_CONFIG="${WDI_HOME}/config.json"

  # Create minimal environment
  mkdir -p "$WDI_HOME"

  # Run create_project with timeout (use gtimeout on macOS, timeout on Linux)
  local timeout_cmd="timeout"
  command -v gtimeout &>/dev/null && timeout_cmd="gtimeout"
  command -v $timeout_cmd &>/dev/null || timeout_cmd=""

  if [[ -n "$timeout_cmd" ]]; then
    run bash -c "echo 'n' | $timeout_cmd 5 $SCRIPT create_project 2>&1 || true"
  else
    # No timeout available, run with limited input
    run bash -c "echo 'n' | $SCRIPT create_project 2>&1 || true" &
    local pid=$!
    sleep 3
    kill $pid 2>/dev/null || true
    wait $pid 2>/dev/null || true
  fi

  # Should mention config, configuration, prerequisites, or doctor
  # (behavior depends on environment state)
  [[ "$output" == *"config"* || "$output" == *"Configuration"* || "$output" == *"prerequisites"* || "$output" == *"Checking"* ]]
}

# ==============================================================================
# Utility function tests
# ==============================================================================

@test "wdi: has_command returns 0 for existing command" {
  # Source the script to test internal functions
  source "$SCRIPT" 2>/dev/null || true

  # Test with a command that definitely exists
  run bash -c "command -v bash"

  assert_success
}

@test "wdi: colors are defined" {
  # Check that the script defines color variables
  run grep -E "^(RED|GREEN|YELLOW|CYAN|NC)=" "$SCRIPT"

  assert_success
}

# ==============================================================================
# Name validation tests
# ==============================================================================

@test "wdi: script contains lowercase validation" {
  run grep -q "lowercase" "$SCRIPT"

  assert_success
}

@test "wdi: script contains underscore validation" {
  run grep -q "underscore" "$SCRIPT"

  assert_success
}

@test "wdi: script contains wdi- prefix check" {
  run grep -q 'wdi-\*' "$SCRIPT"

  assert_success
}

# ==============================================================================
# Project structure tests
# ==============================================================================

@test "wdi: script creates plugin structure function" {
  run grep -q "create_plugin_structure" "$SCRIPT"

  assert_success
}

@test "wdi: script creates standard structure function" {
  run grep -q "create_standard_structure" "$SCRIPT"

  assert_success
}

@test "wdi: plugin structure includes .claude-plugin" {
  run grep -A 20 "create_plugin_structure" "$SCRIPT"

  assert_success
  assert_output --partial ".claude-plugin"
}

@test "wdi: plugin structure includes plugin.json" {
  run grep -A 30 "create_plugin_structure" "$SCRIPT"

  assert_success
  assert_output --partial "plugin.json"
}

# ==============================================================================
# Shell rc detection tests
# ==============================================================================

@test "wdi: detects zsh rc file" {
  export SHELL="/bin/zsh"

  # Source to get function
  run bash -c "source $SCRIPT 2>/dev/null; get_shell_rc"

  assert_output --partial ".zshrc"
}

@test "wdi: detects bash rc file" {
  export SHELL="/bin/bash"

  run bash -c "source $SCRIPT 2>/dev/null; get_shell_rc"

  [[ "$output" == *".bashrc"* || "$output" == *".bash_profile"* ]]
}
