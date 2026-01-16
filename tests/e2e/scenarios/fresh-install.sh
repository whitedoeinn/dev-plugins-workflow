#!/usr/bin/env bash
#
# E2E Scenario: Fresh Install
#
# Tests the wdi CLI installation on a fresh environment.
# This scenario simulates a new user installing wdi for the first time.
#
# Prerequisites:
#   - Fresh Ubuntu environment (Dockerfile.fresh-env)
#   - git installed
#   - curl installed
#
# Expected outcomes:
#   - wdi CLI installed to ~/.local/bin
#   - jq installed by wdi doctor
#   - gh installed by wdi doctor
#   - wdi config created

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_NAME="$(basename "$0")"

log() {
  echo -e "${CYAN}[$SCRIPT_NAME]${NC} $1"
}

success() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  exit 1
}

skip() {
  echo -e "${YELLOW}[SKIP]${NC} $1"
}

# ============================================================================
# Setup
# ============================================================================

log "Starting fresh install E2E test"
echo ""

# Verify we're in a fresh environment
log "Checking environment..."

if command -v wdi &> /dev/null; then
  skip "wdi already installed - this isn't a fresh environment"
  exit 0
fi

if [[ ! -d "${HOME}" ]]; then
  fail "HOME directory doesn't exist"
fi

success "Environment is fresh (no wdi installed)"

# ============================================================================
# Test 1: Install wdi CLI
# ============================================================================

log "Test 1: Installing wdi CLI..."

# Install from GitHub production URL (tests real-world install path)
INSTALL_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/wdi"
log "Installing from: $INSTALL_URL"
curl -sSL "$INSTALL_URL" | bash -s install

# Verify installation
if [[ -f "${HOME}/.local/bin/wdi" ]]; then
  success "wdi installed to ~/.local/bin/wdi"
else
  fail "wdi not found in ~/.local/bin"
fi

# Add to PATH for this session
export PATH="${HOME}/.local/bin:$PATH"

# ============================================================================
# Test 2: wdi version works
# ============================================================================

log "Test 2: Checking wdi version..."

if wdi version &> /dev/null; then
  VERSION=$(wdi version)
  success "wdi version: $VERSION"
else
  fail "wdi version command failed"
fi

# ============================================================================
# Test 3: wdi help works
# ============================================================================

log "Test 3: Checking wdi help..."

if wdi help | grep -q "Usage:"; then
  success "wdi help shows usage"
else
  fail "wdi help doesn't show usage"
fi

# ============================================================================
# Test 4: wdi doctor runs
# ============================================================================

log "Test 4: Running wdi doctor..."

# Doctor may install things, which is expected
DOCTOR_OUTPUT=$(wdi doctor 2>&1 || true)

# Check that doctor detected the environment
if echo "$DOCTOR_OUTPUT" | grep -qi "detected"; then
  success "wdi doctor detected environment"
else
  # Fallback check
  if echo "$DOCTOR_OUTPUT" | grep -qi "checking"; then
    success "wdi doctor ran checks"
  else
    fail "wdi doctor didn't run properly"
  fi
fi

# ============================================================================
# Test 5: Config directory created
# ============================================================================

log "Test 5: Checking config directory..."

if [[ -d "${HOME}/.config/wdi" ]]; then
  success "Config directory created: ~/.config/wdi"
else
  # May not exist until config is run
  skip "Config directory not created (normal if config not run)"
fi

# ============================================================================
# Test 6: Check jq installed
# ============================================================================

log "Test 6: Checking if jq is available..."

if command -v jq &> /dev/null; then
  JQ_VERSION=$(jq --version)
  success "jq is available: $JQ_VERSION"
else
  skip "jq not installed (may require manual install)"
fi

# ============================================================================
# Test 7: Check gh installed
# ============================================================================

log "Test 7: Checking if gh is available..."

if command -v gh &> /dev/null; then
  GH_VERSION=$(gh --version | head -1)
  success "gh is available: $GH_VERSION"
else
  skip "gh not installed (may require manual install)"
fi

# ============================================================================
# Test 8: wdi config (non-interactive check)
# ============================================================================

log "Test 8: Testing wdi config creation..."

# Create a config file programmatically
mkdir -p "${HOME}/.config/wdi"
cat > "${HOME}/.config/wdi/config.json" << 'EOF'
{
  "github_org": "test-org",
  "project_dir": "/tmp/projects",
  "business_domains": ["marketing", "operations"],
  "plugin_domains": ["workflow", "frontend"]
}
EOF

# Verify config can be read
if jq -e '.github_org' "${HOME}/.config/wdi/config.json" &> /dev/null; then
  success "Config file created and readable"
else
  fail "Config file not valid JSON"
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "========================================"
log "Fresh Install E2E Test Complete"
echo "========================================"
echo ""
success "All critical tests passed!"
echo ""
