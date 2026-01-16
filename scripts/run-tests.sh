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
#   e2e           Run E2E tests in containers
#   all           Run all tests
#   docker        Run all tests in Docker
#   clean         Clean up test artifacts
#   help          Show this help
#
# Options:
#   --verbose     Show detailed output
#   --filter      Filter tests by pattern
#   --local       Run tests locally (not in Docker)

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
LOCAL_MODE=false

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v) VERBOSE=true; shift ;;
    --filter) FILTER="$2"; shift 2 ;;
    --local) LOCAL_MODE=true; shift ;;
    *) break ;;
  esac
done

COMMAND="${1:-help}"
shift || true

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
    echo "  Or:     git clone https://github.com/bats-core/bats-core.git && cd bats-core && ./install.sh /usr/local"
    echo ""
    return 1
  fi
  return 0
}

# Check for BATS helper libraries
check_bats_libs() {
  local libs_path="${BATS_LIB_PATH:-/usr/local/lib}"
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
    echo "  git clone https://github.com/bats-core/bats-support.git ${libs_path}/bats-support"
    echo "  git clone https://github.com/bats-core/bats-assert.git ${libs_path}/bats-assert"
    echo "  git clone https://github.com/bats-core/bats-file.git ${libs_path}/bats-file"
    echo ""
    return 1
  fi
  return 0
}

# Run unit tests locally
run_unit_local() {
  log "Running unit tests locally..."

  if ! check_bats || ! check_bats_libs; then
    error "Prerequisites not met for local unit tests"
    return 1
  fi

  local bats_args=("--recursive")
  [[ "$VERBOSE" == true ]] && bats_args+=("--verbose-run")
  [[ -n "$FILTER" ]] && bats_args+=("--filter" "$FILTER")

  cd "$PROJECT_ROOT"

  if [[ -d "${TESTS_DIR}/unit" ]] && [[ -n "$(ls -A "${TESTS_DIR}/unit"/*.bats 2>/dev/null)" ]]; then
    bats "${bats_args[@]}" "${TESTS_DIR}/unit/"
  else
    warn "No unit tests found in ${TESTS_DIR}/unit/"
    return 0
  fi
}

# Run unit tests in Docker
run_unit_docker() {
  log "Running unit tests in Docker..."

  cd "$TESTS_DIR"
  docker compose -f docker-compose.test.yml build unit-tests
  docker compose -f docker-compose.test.yml run --rm unit-tests
}

# Run integration tests
run_integration() {
  log "Running integration tests..."

  local integration_script="${TESTS_DIR}/integration/run-integration.sh"

  if [[ -f "$integration_script" ]]; then
    chmod +x "$integration_script"
    "$integration_script"
  else
    warn "No integration tests found"
    return 0
  fi
}

# Run E2E tests in Docker
run_e2e() {
  log "Running E2E tests in Docker..."

  # Check for required environment variables
  if [[ -z "${GH_TOKEN:-}" ]]; then
    warn "GH_TOKEN not set - some E2E tests may be skipped"
  fi

  cd "$TESTS_DIR"
  docker compose -f docker-compose.test.yml --profile e2e build
  docker compose -f docker-compose.test.yml --profile e2e run --rm e2e-runner
}

# Run all tests in Docker
run_docker() {
  log "Running all tests in Docker..."

  cd "$TESTS_DIR"

  # Build images
  docker compose -f docker-compose.test.yml build

  # Run tests in order
  log "Running unit tests..."
  docker compose -f docker-compose.test.yml run --rm unit-tests && success "Unit tests passed" || { error "Unit tests failed"; return 1; }

  log "Running integration tests..."
  docker compose -f docker-compose.test.yml run --rm integration-tests && success "Integration tests passed" || { error "Integration tests failed"; return 1; }

  success "All tests passed!"
}

# Run all tests
run_all() {
  local failed=false

  log "Running all tests..."
  echo ""

  # Unit tests
  if [[ "$LOCAL_MODE" == true ]]; then
    run_unit_local || failed=true
  else
    run_unit_docker || failed=true
  fi

  # Integration tests
  run_integration || failed=true

  echo ""
  if [[ "$failed" == true ]]; then
    error "Some tests failed"
    return 1
  else
    success "All tests passed!"
  fi
}

# Clean up test artifacts
clean() {
  log "Cleaning up test artifacts..."

  cd "$TESTS_DIR"

  # Stop and remove containers
  docker compose -f docker-compose.test.yml down --volumes --remove-orphans 2>/dev/null || true

  # Remove test images
  docker images --filter "reference=*wdi-test*" -q | xargs -r docker rmi 2>/dev/null || true

  # Clean up local artifacts
  rm -rf "${PROJECT_ROOT}/.test-output" 2>/dev/null || true

  success "Cleanup complete"
}

# Show help
show_help() {
  cat << EOF

${CYAN}wdi Plugin Test Runner${NC}

Usage: ./scripts/run-tests.sh [command] [options]

${YELLOW}Commands:${NC}
  unit          Run unit tests (BATS)
  integration   Run integration tests
  e2e           Run E2E tests in containers
  all           Run all tests
  docker        Run all tests in Docker
  clean         Clean up test artifacts
  help          Show this help

${YELLOW}Options:${NC}
  --verbose     Show detailed output
  --filter      Filter tests by pattern
  --local       Run tests locally (requires BATS installed)

${YELLOW}Examples:${NC}
  ./scripts/run-tests.sh unit                    # Run unit tests in Docker
  ./scripts/run-tests.sh unit --local            # Run unit tests locally
  ./scripts/run-tests.sh unit --filter validate  # Filter tests by name
  ./scripts/run-tests.sh e2e                     # Run E2E tests (requires GH_TOKEN)
  ./scripts/run-tests.sh all                     # Run all tests
  ./scripts/run-tests.sh clean                   # Clean up Docker resources

${YELLOW}Environment Variables:${NC}
  GH_TOKEN            GitHub token for E2E tests
  ANTHROPIC_API_KEY   API key for Claude tests (optional)
  BATS_LIB_PATH       Path to BATS helper libraries (default: /usr/local/lib)

EOF
}

# Main
case "$COMMAND" in
  unit)
    if [[ "$LOCAL_MODE" == true ]]; then
      run_unit_local
    else
      run_unit_docker
    fi
    ;;
  integration)
    run_integration
    ;;
  e2e)
    run_e2e
    ;;
  all)
    run_all
    ;;
  docker)
    run_docker
    ;;
  clean)
    clean
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    error "Unknown command: $COMMAND"
    show_help
    exit 1
    ;;
esac
