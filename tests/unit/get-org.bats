#!/usr/bin/env bats
# Unit tests for get-org.sh
#
# Tests the org detection utility, including:
# - Git remote URL parsing (HTTPS and SSH formats)
# - .wdi.json config file override
# - WDI_ORG environment variable
# - Namespace listing (--list)
# - User detection (--user)

load '../test_helper'

# Path to the script under test
SCRIPT="${SCRIPTS_DIR}/get-org.sh"

setup() {
  setup_temp_dir

  # Create a mock git repo
  export MOCK_REPO="${TEST_TEMP_DIR}/repo"
  mkdir -p "$MOCK_REPO"
  cd "$MOCK_REPO"
  git init --quiet

  # Clear any existing env vars
  unset WDI_ORG

  # Mock gh command
  mkdir -p "${TEST_TEMP_DIR}/bin"
  export PATH="${TEST_TEMP_DIR}/bin:$PATH"
}

teardown() {
  teardown_temp_dir
}

# Helper to set git remote
set_git_remote() {
  local url="$1"
  git remote add origin "$url" 2>/dev/null || git remote set-url origin "$url"
}

# Helper to create mock gh command
create_mock_gh() {
  local username="${1:-testuser}"
  local orgs="${2:-}"

  cat > "${TEST_TEMP_DIR}/bin/gh" << EOF
#!/bin/bash
case "\$*" in
  "api user --jq .login")
    echo "$username"
    ;;
  "api user/orgs --jq .[].login")
    if [[ -n "$orgs" ]]; then
      echo "$orgs"
    fi
    ;;
  *)
    exit 1
    ;;
esac
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/gh"
}

# Helper to create mock jq command
create_mock_jq() {
  cat > "${TEST_TEMP_DIR}/bin/jq" << 'EOF'
#!/bin/bash
# Simple jq mock for .org extraction
# jq is called as: jq -r '.org // empty' .wdi.json
# We need to read the file and extract the org value

# Find the file argument (last argument that's a file)
FILE=""
for arg in "$@"; do
  if [[ -f "$arg" ]]; then
    FILE="$arg"
  fi
done

if [[ -n "$FILE" ]] && [[ "$*" == *".org"* ]]; then
  content=$(cat "$FILE")
  if [[ "$content" == *'"org"'* ]]; then
    echo "$content" | sed -n 's/.*"org"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
  fi
fi
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/jq"
}

# =============================================================================
# Git Remote URL Parsing Tests
# =============================================================================

@test "detects org from HTTPS git remote" {
  set_git_remote "https://github.com/testorg/testrepo.git"

  run "$SCRIPT"

  assert_success
  assert_output "testorg"
}

@test "detects org from HTTPS git remote without .git suffix" {
  set_git_remote "https://github.com/testorg/testrepo"

  run "$SCRIPT"

  assert_success
  assert_output "testorg"
}

@test "detects org from SSH git remote" {
  set_git_remote "git@github.com:testorg/testrepo.git"

  run "$SCRIPT"

  assert_success
  assert_output "testorg"
}

@test "detects user from personal repo SSH remote" {
  set_git_remote "git@github.com:joshbregman/my-project.git"

  run "$SCRIPT"

  assert_success
  assert_output "joshbregman"
}

@test "returns empty when no git remote" {
  # No remote set
  run "$SCRIPT"

  assert_success
  assert_output ""
}

# =============================================================================
# Config File Tests
# =============================================================================

@test "uses .wdi.json org over git remote" {
  set_git_remote "https://github.com/gitorg/repo.git"
  echo '{"org": "configorg"}' > .wdi.json
  create_mock_jq

  run "$SCRIPT"

  assert_success
  assert_output "configorg"
}

@test "falls back to git remote when .wdi.json has no org" {
  set_git_remote "https://github.com/gitorg/repo.git"
  echo '{"other": "value"}' > .wdi.json
  create_mock_jq

  run "$SCRIPT"

  assert_success
  assert_output "gitorg"
}

# =============================================================================
# Environment Variable Tests
# =============================================================================

@test "uses WDI_ORG environment variable as fallback" {
  # No git remote, no config
  export WDI_ORG=envorg

  run "$SCRIPT"

  assert_success
  assert_output "envorg"
}

@test "git remote takes precedence over WDI_ORG" {
  set_git_remote "https://github.com/gitorg/repo.git"
  export WDI_ORG=envorg

  run "$SCRIPT"

  assert_success
  assert_output "gitorg"
}

# =============================================================================
# --require Flag Tests
# =============================================================================

@test "--require exits 1 when no org found" {
  # No remote, no config, no env var
  run "$SCRIPT" --require

  assert_failure
}

@test "--require succeeds when org detected" {
  set_git_remote "https://github.com/testorg/repo.git"

  run "$SCRIPT" --require

  assert_success
  assert_output "testorg"
}

# =============================================================================
# --list Flag Tests
# =============================================================================

@test "--list shows personal namespace and orgs" {
  create_mock_gh "testuser" "org1
org2"

  run "$SCRIPT" --list

  assert_success
  assert_line "testuser (personal)"
  assert_line "org1"
  assert_line "org2"
}

@test "--list works with no orgs" {
  create_mock_gh "testuser" ""

  run "$SCRIPT" --list

  assert_success
  assert_output "testuser (personal)"
}

# =============================================================================
# --user Flag Tests
# =============================================================================

@test "--user returns authenticated username" {
  create_mock_gh "joshbregman"

  run "$SCRIPT" --user

  assert_success
  assert_output "joshbregman"
}

@test "--user fails when gh not authenticated" {
  # Create gh mock that fails
  cat > "${TEST_TEMP_DIR}/bin/gh" << 'EOF'
#!/bin/bash
exit 1
EOF
  chmod +x "${TEST_TEMP_DIR}/bin/gh"

  run "$SCRIPT" --user

  assert_failure
}
