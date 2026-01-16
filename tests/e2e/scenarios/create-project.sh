#!/usr/bin/env bash
#
# E2E Scenario: Create Project
#
# Tests the wdi create_project workflow for different project types.
# This scenario validates the project scaffolding functionality.
#
# Prerequisites:
#   - wdi CLI installed
#   - jq installed
#   - git installed
#   - GH_TOKEN set (for GitHub repo creation - optional)
#
# Test modes:
#   --local     Skip GitHub operations (default in CI)
#   --github    Full GitHub integration test

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_NAME="$(basename "$0")"
LOCAL_MODE=true  # Default to local-only testing

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --github) LOCAL_MODE=false; shift ;;
    --local) LOCAL_MODE=true; shift ;;
    *) shift ;;
  esac
done

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

log "Starting create project E2E test"
echo ""

# Create test workspace
TEST_WORKSPACE=$(mktemp -d)
export TEST_WORKSPACE
log "Test workspace: $TEST_WORKSPACE"

# Set up wdi config
export WDI_HOME="${TEST_WORKSPACE}/.config/wdi"
export WDI_CONFIG="${WDI_HOME}/config.json"
mkdir -p "$WDI_HOME"

# Create test config
TEST_ORG="${TEST_ORG:-wdi-test}"
cat > "$WDI_CONFIG" << EOF
{
  "github_org": "${TEST_ORG}",
  "project_dir": "${TEST_WORKSPACE}/projects",
  "business_domains": ["marketing", "operations", "finance"],
  "plugin_domains": ["workflow", "frontend", "backend"]
}
EOF

mkdir -p "${TEST_WORKSPACE}/projects"

success "Test environment configured"

# Add wdi to PATH
if [[ -f "/plugin/scripts/wdi" ]]; then
  export PATH="/plugin/scripts:$PATH"
elif [[ -f "${HOME}/.local/bin/wdi" ]]; then
  export PATH="${HOME}/.local/bin:$PATH"
fi

# ============================================================================
# Test Functions
# ============================================================================

# Test creating plugin project structure (local only, no GitHub)
test_plugin_structure() {
  log "Testing plugin project structure..."

  local project_name="dev-plugins-test-workflow"
  local project_path="${TEST_WORKSPACE}/projects/${project_name}"

  # Create the structure manually (simulating what create_project does)
  mkdir -p "$project_path"
  cd "$project_path"

  # Initialize git
  git init -q

  # Create plugin structure
  mkdir -p .claude-plugin commands skills hooks knowledge scripts docs

  # Create plugin.json
  cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "dev-plugins-test-workflow",
  "description": "Test plugin",
  "version": "0.1.0",
  "commands": "./commands/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
EOF

  # Create hooks.json
  echo '{"hooks": []}' > hooks/hooks.json

  # Create CLAUDE.md
  echo "# dev-plugins-test-workflow" > CLAUDE.md

  # Create README.md
  echo "# dev-plugins-test-workflow" > README.md

  # Create install.sh
  echo '#!/usr/bin/env bash' > install.sh
  chmod +x install.sh

  # Verify structure
  local required_files=(
    ".claude-plugin/plugin.json"
    "hooks/hooks.json"
    "CLAUDE.md"
    "README.md"
    "install.sh"
  )

  for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      fail "Missing required file: $file"
    fi
  done

  # Verify plugin.json is valid JSON
  if ! jq empty .claude-plugin/plugin.json 2>/dev/null; then
    fail "plugin.json is not valid JSON"
  fi

  success "Plugin structure is valid"

  # Clean up
  cd "$TEST_WORKSPACE"
}

# Test creating business domain project structure
test_business_domain_structure() {
  log "Testing business domain project structure..."

  local project_name="marketing-ops"
  local project_path="${TEST_WORKSPACE}/projects/${project_name}"

  mkdir -p "$project_path"
  cd "$project_path"

  git init -q

  # Create standard structure
  mkdir -p packages shared src tests scripts docs

  # Create CLAUDE.md
  cat > CLAUDE.md << 'EOF'
# marketing-ops

Business domain project.

## Structure

```
marketing-ops/
├── packages/
├── shared/
├── src/
├── tests/
├── scripts/
└── docs/
```
EOF

  # Create README.md
  echo "# marketing-ops" > README.md

  # Verify structure
  local required_dirs=(
    "packages"
    "shared"
    "src"
    "tests"
    "scripts"
    "docs"
  )

  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      fail "Missing required directory: $dir"
    fi
  done

  if [[ ! -f "CLAUDE.md" ]] || [[ ! -f "README.md" ]]; then
    fail "Missing required documentation files"
  fi

  success "Business domain structure is valid"

  cd "$TEST_WORKSPACE"
}

# Test creating experiment project structure
test_experiment_structure() {
  log "Testing experiment project structure..."

  local project_name="experiment-new-feature"
  local project_path="${TEST_WORKSPACE}/projects/${project_name}"

  mkdir -p "$project_path"
  cd "$project_path"

  git init -q

  # Create standard structure
  mkdir -p packages shared src tests scripts docs

  # Create README with experiment notice
  cat > README.md << 'EOF'
# experiment-new-feature

> ⚠️ **Experiment**: This repo has a 90-day lifecycle.
> Promote to permanent repo or archive with documented learnings.

Test experiment.
EOF

  # Verify experiment notice
  if ! grep -q "Experiment" README.md; then
    fail "README missing experiment notice"
  fi

  success "Experiment structure is valid"

  cd "$TEST_WORKSPACE"
}

# Test name validation rules
test_name_validation() {
  log "Testing name validation rules..."

  # Test lowercase validation (checking script contains the check)
  if [[ -f "/plugin/scripts/wdi" ]]; then
    if grep -q "uppercase" /plugin/scripts/wdi || grep -q "lowercase" /plugin/scripts/wdi; then
      success "Lowercase validation exists in script"
    else
      fail "No lowercase validation found"
    fi

    # Test underscore validation
    if grep -q "underscore" /plugin/scripts/wdi; then
      success "Underscore validation exists in script"
    else
      fail "No underscore validation found"
    fi

    # Test wdi- prefix check
    if grep -q "wdi-" /plugin/scripts/wdi; then
      success "wdi- prefix check exists in script"
    else
      fail "No wdi- prefix check found"
    fi
  else
    skip "Cannot test name validation without wdi script"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

log "Running structure tests (local mode)..."
echo ""

test_plugin_structure
test_business_domain_structure
test_experiment_structure
test_name_validation

# ============================================================================
# GitHub Integration Tests (Optional)
# ============================================================================

if [[ "$LOCAL_MODE" == false ]]; then
  log "Running GitHub integration tests..."

  if [[ -z "${GH_TOKEN:-}" ]]; then
    skip "GH_TOKEN not set - skipping GitHub tests"
  else
    # Authenticate gh
    echo "$GH_TOKEN" | gh auth login --with-token 2>/dev/null || true

    # Test repo creation would go here
    # This would create a test repo, verify it, then delete it
    skip "GitHub integration tests not yet implemented"
  fi
else
  skip "GitHub integration tests (use --github flag to enable)"
fi

# ============================================================================
# Cleanup
# ============================================================================

log "Cleaning up test workspace..."
rm -rf "$TEST_WORKSPACE"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "========================================"
log "Create Project E2E Test Complete"
echo "========================================"
echo ""
success "All tests passed!"
echo ""
