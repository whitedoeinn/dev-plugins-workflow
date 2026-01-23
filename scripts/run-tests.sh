#!/usr/bin/env bash
#
# run-tests.sh - Test runner for wdi plugin
#
# Usage:
#   ./scripts/run-tests.sh [command] [options]
#
# Commands:
#   unit          Run unit tests (BATS)
#   integration   Run integration tests
#   all           Run all tests (default)
#   help          Show this help
#
# Options:
#   --verbose     Show detailed output
#   --filter      Filter tests by pattern

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="${PROJECT_ROOT}/tests"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Options
VERBOSE=false
FILTER=""

log() {
  echo -e "${CYAN}→${NC} $1"
}

success() {
  echo -e "${GREEN}✓${NC} $1"
}

error() {
  echo -e "${RED}✗${NC} $1"
}

warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Check if BATS is installed
check_bats() {
  if ! command -v bats &> /dev/null; then
    error "BATS not installed"
    echo ""
    echo "Install BATS:"
    echo "  macOS:  brew install bats-core"
    echo "  Ubuntu: sudo apt install bats"
    echo ""
    return 1
  fi
  return 0
}

# Check for BATS helper libraries
check_bats_libs() {
  local libs_path=""

  # Try multiple locations
  for try_path in "/usr/lib/bats" "/usr/local/lib" "${BATS_LIB_PATH:-}"; do
    if [[ -n "$try_path" ]] && [[ -d "${try_path}/bats-support" ]]; then
      libs_path="$try_path"
      export BATS_LIB_PATH="$libs_path"
      break
    fi
  done

  # On macOS with Homebrew, check the brew prefix
  if [[ -z "$libs_path" ]] && [[ "$(uname)" == "Darwin" ]] && command -v brew &> /dev/null; then
    libs_path="$(brew --prefix)/lib"
    export BATS_LIB_PATH="$libs_path"
  fi

  # Default fallback
  libs_path="${libs_path:-/usr/local/lib}"

  local missing=()

  for lib in bats-support bats-assert bats-file; do
    if [[ ! -d "${libs_path}/${lib}" ]]; then
      missing+=("$lib")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "Missing BATS libraries: ${missing[*]}"
    echo ""
    echo "Install missing libraries:"
    echo "  macOS:  brew tap bats-core/bats-core && brew install bats-support bats-assert bats-file"
    echo "  Ubuntu: git clone https://github.com/bats-core/bats-{support,assert,file}.git /usr/local/lib/"
    echo ""
    return 1
  fi
  return 0
}

# Run unit tests
run_unit() {
  log "Running unit tests..."

  if ! check_bats || ! check_bats_libs; then
    error "Prerequisites not met for unit tests"
    return 1
  fi

  local bats_args=("--recursive")
  [[ "$VERBOSE" == true ]] && bats_args+=("--verbose-run")
  [[ -n "$FILTER" ]] && bats_args+=("--filter" "$FILTER")

  cd "$PROJECT_ROOT"

  if [[ -d "${TESTS_DIR}/unit" ]] && [[ -n "$(ls -A "${TESTS_DIR}/unit"/*.bats 2>/dev/null)" ]]; then
    bats "${bats_args[@]}" "${TESTS_DIR}/unit/"
    success "Unit tests passed"
  else
    warn "No unit tests found in ${TESTS_DIR}/unit/"
    return 0
  fi
}

# Run integration tests
run_integration() {
  log "Running integration tests..."

  local integration_script="${TESTS_DIR}/integration/run-integration.sh"

  if [[ -f "$integration_script" ]]; then
    chmod +x "$integration_script"
    "$integration_script"
    success "Integration tests passed"
  else
    warn "No integration tests found"
    return 0
  fi
}

# Run all tests
run_all() {
  local failed=false

  log "Running all tests..."
  echo ""

  run_unit || failed=true
  echo ""
  run_integration || failed=true

  echo ""
  if [[ "$failed" == true ]]; then
    error "Some tests failed"
    return 1
  else
    success "All tests passed!"
  fi
}

# Show help
show_help() {
  cat << EOF

${CYAN}wdi Plugin Test Runner${NC}

Usage: ./scripts/run-tests.sh [command] [options]

${YELLOW}Commands:${NC}
  unit          Run unit tests (BATS)
  integration   Run integration tests
  all           Run all tests (default)
  help          Show this help

${YELLOW}Options:${NC}
  --verbose     Show detailed output
  --filter      Filter tests by pattern

${YELLOW}Examples:${NC}
  ./scripts/run-tests.sh                         # Run all tests
  ./scripts/run-tests.sh unit                    # Run unit tests only
  ./scripts/run-tests.sh integration             # Run integration tests only
  ./scripts/run-tests.sh --verbose unit          # Verbose unit tests
  ./scripts/run-tests.sh --filter validate unit  # Filter tests by name

${YELLOW}Environment Variables:${NC}
  BATS_LIB_PATH   Path to BATS helper libraries (auto-detected on macOS)

EOF
}

# Parse arguments
COMMAND="all"

while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v) VERBOSE=true; shift ;;
    --filter) FILTER="$2"; shift 2 ;;
    unit|integration|all|help|--help|-h)
      COMMAND="$1"
      shift
      ;;
    *)
      error "Unknown argument: $1"
      show_help
      exit 1
      ;;
  esac
done

# Main
case "$COMMAND" in
  unit)
    run_unit
    ;;
  integration)
    run_integration
    ;;
  all)
    run_all
    ;;
  help|--help|-h)
    show_help
    ;;
esac
