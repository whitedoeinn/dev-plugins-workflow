#!/usr/bin/env bash
#
# Integration Test Runner
#
# Tests that commands and skills load correctly.
# Validates that markdown files are properly formatted and parseable.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0

log() {
  echo -e "${CYAN}[Integration]${NC} $1"
}

success() {
  echo -e "${GREEN}[PASS]${NC} $1"
  ((PASSED++)) || true
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  ((FAILED++)) || true
}

# ============================================================================
# Test: Command files are valid markdown
# ============================================================================

test_command_files() {
  log "Testing command files..."

  local commands_dir="${PROJECT_ROOT}/commands"

  if [[ ! -d "$commands_dir" ]]; then
    fail "Commands directory not found"
    return
  fi

  for cmd_file in "$commands_dir"/*.md; do
    [[ -f "$cmd_file" ]] || continue

    local cmd_name
    cmd_name=$(basename "$cmd_file" .md)

    # Check file is not empty
    if [[ ! -s "$cmd_file" ]]; then
      fail "Command file is empty: $cmd_name"
      continue
    fi

    # Check file starts with a heading or YAML frontmatter
    local first_line
    first_line=$(head -1 "$cmd_file")
    if [[ "$first_line" != "---" ]] && ! echo "$first_line" | grep -q "^#"; then
      fail "Command file doesn't start with heading or frontmatter: $cmd_name"
      continue
    fi

    # Check for required sections (at minimum should have some content)
    if [[ $(wc -l < "$cmd_file") -lt 5 ]]; then
      fail "Command file too short: $cmd_name"
      continue
    fi

    success "Command file valid: $cmd_name"
  done
}

# ============================================================================
# Test: Skill files are valid
# ============================================================================

test_skill_files() {
  log "Testing skill files..."

  local skills_dir="${PROJECT_ROOT}/skills"

  if [[ ! -d "$skills_dir" ]]; then
    fail "Skills directory not found"
    return
  fi

  for skill_dir in "$skills_dir"/*/; do
    [[ -d "$skill_dir" ]] || continue

    local skill_name
    skill_name=$(basename "$skill_dir")

    local skill_file="${skill_dir}SKILL.md"

    # Check SKILL.md exists
    if [[ ! -f "$skill_file" ]]; then
      fail "Skill missing SKILL.md: $skill_name"
      continue
    fi

    # Check file is not empty
    if [[ ! -s "$skill_file" ]]; then
      fail "SKILL.md is empty: $skill_name"
      continue
    fi

    # Check file starts with a heading or YAML frontmatter
    local first_line
    first_line=$(head -1 "$skill_file")
    if [[ "$first_line" != "---" ]] && ! echo "$first_line" | grep -q "^#"; then
      fail "SKILL.md doesn't start with heading or frontmatter: $skill_name"
      continue
    fi

    success "Skill file valid: $skill_name"
  done
}

# ============================================================================
# Test: plugin.json is valid
# ============================================================================

test_plugin_json() {
  log "Testing plugin.json..."

  local plugin_json="${PROJECT_ROOT}/.claude-plugin/plugin.json"

  if [[ ! -f "$plugin_json" ]]; then
    fail "plugin.json not found"
    return
  fi

  # Check JSON is valid
  if ! jq empty "$plugin_json" 2>/dev/null; then
    fail "plugin.json is not valid JSON"
    return
  fi

  # Check required fields
  local required_fields=("name" "version")

  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$plugin_json" &>/dev/null; then
      fail "plugin.json missing required field: $field"
    else
      success "plugin.json has field: $field"
    fi
  done
}

# ============================================================================
# Test: hooks.json is valid
# ============================================================================

test_hooks_json() {
  log "Testing hooks.json..."

  local hooks_json="${PROJECT_ROOT}/hooks/hooks.json"

  if [[ ! -f "$hooks_json" ]]; then
    fail "hooks.json not found"
    return
  fi

  # Check JSON is valid
  if ! jq empty "$hooks_json" 2>/dev/null; then
    fail "hooks.json is not valid JSON"
    return
  fi

  # Check it has hooks object
  if ! jq -e '.hooks' "$hooks_json" &>/dev/null; then
    fail "hooks.json missing 'hooks' object"
    return
  fi

  success "hooks.json is valid"

  # List hook event types (SessionStart, etc.)
  local hook_events
  hook_events=$(jq -r '.hooks | keys[]' "$hooks_json" 2>/dev/null || echo "")

  for event in $hook_events; do
    success "Hook event defined: $event"
  done
}

# ============================================================================
# Test: env-baseline.json is valid
# ============================================================================

test_env_baseline() {
  log "Testing env-baseline.json..."

  local baseline="${PROJECT_ROOT}/env-baseline.json"

  if [[ ! -f "$baseline" ]]; then
    fail "env-baseline.json not found"
    return
  fi

  # Check JSON is valid
  if ! jq empty "$baseline" 2>/dev/null; then
    fail "env-baseline.json is not valid JSON"
    return
  fi

  # Check required fields
  local required_fields=("required_plugins" "required_cli_tools" "admin_contact")

  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$baseline" &>/dev/null; then
      fail "env-baseline.json missing: $field"
    else
      success "env-baseline.json has: $field"
    fi
  done
}

# ============================================================================
# Test: Scripts are executable
# ============================================================================

test_scripts_executable() {
  log "Testing script permissions..."

  local scripts=(
    "${PROJECT_ROOT}/install.sh"
    "${PROJECT_ROOT}/scripts/validate-env.sh"
    "${PROJECT_ROOT}/scripts/check-docs-drift.sh"
    "${PROJECT_ROOT}/scripts/wdi"
    "${PROJECT_ROOT}/scripts/run-tests.sh"
  )

  for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
      if [[ -x "$script" ]]; then
        success "Executable: $(basename "$script")"
      else
        fail "Not executable: $(basename "$script")"
      fi
    fi
  done
}

# ============================================================================
# Test: No syntax errors in shell scripts
# ============================================================================

test_shell_syntax() {
  log "Testing shell script syntax..."

  for script in "${PROJECT_ROOT}/scripts"/*.sh; do
    [[ -f "$script" ]] || continue

    local script_name
    script_name=$(basename "$script")

    if bash -n "$script" 2>/dev/null; then
      success "Syntax OK: $script_name"
    else
      fail "Syntax error: $script_name"
    fi
  done

  # Also check the wdi script
  if [[ -f "${PROJECT_ROOT}/scripts/wdi" ]]; then
    if bash -n "${PROJECT_ROOT}/scripts/wdi" 2>/dev/null; then
      success "Syntax OK: wdi"
    else
      fail "Syntax error: wdi"
    fi
  fi
}

# ============================================================================
# Run All Tests
# ============================================================================

log "Running integration tests..."
echo ""

test_plugin_json
test_hooks_json
test_env_baseline
test_command_files
test_skill_files
test_scripts_executable
test_shell_syntax

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "========================================"
log "Integration Test Summary"
echo "========================================"
echo ""

echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [[ $FAILED -gt 0 ]]; then
  fail "Some integration tests failed"
  exit 1
else
  success "All integration tests passed!"
  exit 0
fi
