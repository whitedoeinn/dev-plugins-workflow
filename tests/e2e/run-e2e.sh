#!/usr/bin/env bash
#
# E2E Test Runner
#
# Runs all E2E test scenarios and reports results.
#
# Usage:
#   ./run-e2e.sh [--scenario <name>] [--github]
#
# Options:
#   --scenario <name>   Run only the specified scenario
#   --github            Enable GitHub integration tests (requires GH_TOKEN)
#   --verbose           Show detailed output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="${SCRIPT_DIR}/scenarios"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Options
SPECIFIC_SCENARIO=""
GITHUB_MODE=false
VERBOSE=false
SCENARIO_ARGS=()

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --scenario) SPECIFIC_SCENARIO="$2"; shift 2 ;;
    --github) GITHUB_MODE=true; SCENARIO_ARGS+=("--github"); shift ;;
    --verbose|-v) VERBOSE=true; shift ;;
    *) shift ;;
  esac
done

log() {
  echo -e "${CYAN}[E2E]${NC} $1"
}

success() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

log "E2E Test Runner"
echo ""

log "Pre-flight checks..."

# Check for required tools
for tool in bash git jq; do
  if ! command -v "$tool" &> /dev/null; then
    fail "Required tool not found: $tool"
    exit 1
  fi
done

success "All required tools available"

# Check GitHub integration requirements
if [[ "$GITHUB_MODE" == true ]]; then
  if [[ -z "${GH_TOKEN:-}" ]]; then
    fail "GitHub mode requires GH_TOKEN environment variable"
    exit 1
  fi
  success "GH_TOKEN is set"
fi

# ============================================================================
# Run Scenarios
# ============================================================================

PASSED=0
FAILED=0
SKIPPED=0
FAILED_SCENARIOS=()

run_scenario() {
  local scenario_script="$1"
  local scenario_name
  scenario_name=$(basename "$scenario_script" .sh)

  echo ""
  echo "========================================"
  log "Running scenario: $scenario_name"
  echo "========================================"
  echo ""

  if [[ ! -x "$scenario_script" ]]; then
    chmod +x "$scenario_script"
  fi

  local start_time end_time duration
  start_time=$(date +%s)

  if "$scenario_script" "${SCENARIO_ARGS[@]}" 2>&1; then
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    success "Scenario passed: $scenario_name (${duration}s)"
    ((PASSED++))
  else
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    fail "Scenario failed: $scenario_name (${duration}s)"
    ((FAILED++))
    FAILED_SCENARIOS+=("$scenario_name")
  fi
}

# Find and run scenarios
if [[ -n "$SPECIFIC_SCENARIO" ]]; then
  # Run specific scenario
  scenario_path="${SCENARIOS_DIR}/${SPECIFIC_SCENARIO}.sh"
  if [[ -f "$scenario_path" ]]; then
    run_scenario "$scenario_path"
  else
    fail "Scenario not found: $SPECIFIC_SCENARIO"
    exit 1
  fi
else
  # Run all scenarios
  log "Finding scenarios in: $SCENARIOS_DIR"

  if [[ ! -d "$SCENARIOS_DIR" ]]; then
    fail "Scenarios directory not found"
    exit 1
  fi

  scenario_files=("$SCENARIOS_DIR"/*.sh)

  if [[ ${#scenario_files[@]} -eq 0 || ! -f "${scenario_files[0]}" ]]; then
    log "No scenario files found"
    exit 0
  fi

  for scenario in "${scenario_files[@]}"; do
    if [[ -f "$scenario" ]]; then
      run_scenario "$scenario"
    fi
  done
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "========================================"
log "E2E Test Summary"
echo "========================================"
echo ""

echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

if [[ $FAILED -gt 0 ]]; then
  echo "Failed scenarios:"
  for scenario in "${FAILED_SCENARIOS[@]}"; do
    echo "  - $scenario"
  done
  echo ""
  exit 1
else
  success "All E2E tests passed!"
  exit 0
fi
