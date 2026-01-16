# Common test helper functions for BATS tests
#
# Load this file at the top of each test file:
#   load 'test_helper'

# Get the directory containing this helper
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TESTS_DIR/.." && pwd)"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

# Load BATS helper libraries
# Try multiple locations for flexibility
load_bats_libs() {
  local lib_paths=(
    "/usr/local/lib"
    "${HOME}/.local/lib"
    "${BATS_LIB_PATH:-}"
  )

  for path in "${lib_paths[@]}"; do
    if [[ -d "${path}/bats-support" ]]; then
      load "${path}/bats-support/load.bash"
      load "${path}/bats-assert/load.bash"
      load "${path}/bats-file/load.bash"
      return 0
    fi
  done

  # Fallback - define minimal assertions if libraries not found
  assert_success() { [ "$status" -eq 0 ]; }
  assert_failure() { [ "$status" -ne 0 ]; }
  assert_output() {
    if [[ "$1" == "--partial" ]]; then
      [[ "$output" == *"$2"* ]]
    else
      [ "$output" == "$1" ]
    fi
  }
  assert_line() {
    if [[ "$1" == "--partial" ]]; then
      echo "$output" | grep -q "$2"
    else
      echo "$output" | grep -qxF "$1"
    fi
  }
}

# Try to load libraries
load_bats_libs

# Create a temporary directory for tests
setup_temp_dir() {
  TEST_TEMP_DIR="$(mktemp -d)"
  export TEST_TEMP_DIR
}

# Clean up temporary directory
teardown_temp_dir() {
  if [[ -n "${TEST_TEMP_DIR:-}" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}

# Create a mock baseline file for testing
create_mock_baseline() {
  local baseline_file="${1:-$TEST_TEMP_DIR/env-baseline.json}"

  cat > "$baseline_file" << 'EOF'
{
  "version": "1.0",
  "required_plugins": [
    {
      "name": "test-plugin",
      "source": "test",
      "min_version": null
    }
  ],
  "required_cli_tools": [
    {
      "name": "test-tool",
      "check_command": "which test-tool",
      "install_hints": {
        "darwin": "echo 'install test-tool'",
        "linux": "echo 'install test-tool'",
        "manual": "manual install"
      },
      "can_auto_install": false,
      "requires_auth": false
    }
  ],
  "admin_contact": {
    "name": "Test Admin",
    "email": "test@example.com",
    "escalation_note": "Test note"
  }
}
EOF
}

# Create a minimal valid baseline for environment that should pass
create_passing_baseline() {
  local baseline_file="${1:-$TEST_TEMP_DIR/env-baseline.json}"

  cat > "$baseline_file" << 'EOF'
{
  "version": "1.0",
  "required_plugins": [],
  "required_cli_tools": [
    {
      "name": "git",
      "check_command": "git --version",
      "install_hints": {
        "darwin": "brew install git",
        "linux": "sudo apt install git",
        "manual": "https://git-scm.com"
      },
      "can_auto_install": false,
      "requires_auth": false
    }
  ],
  "admin_contact": {
    "name": "Test Admin",
    "email": "test@example.com"
  }
}
EOF
}

# Mock a command to simulate its presence/absence
mock_command() {
  local cmd="$1"
  local behavior="${2:-success}"

  local mock_dir="${TEST_TEMP_DIR}/bin"
  mkdir -p "$mock_dir"

  case "$behavior" in
    success)
      echo '#!/bin/bash
echo "mock '$cmd' success"
exit 0' > "${mock_dir}/${cmd}"
      ;;
    failure)
      echo '#!/bin/bash
echo "mock '$cmd' failure" >&2
exit 1' > "${mock_dir}/${cmd}"
      ;;
    version)
      echo '#!/bin/bash
echo "'$cmd' version 1.0.0"
exit 0' > "${mock_dir}/${cmd}"
      ;;
  esac

  chmod +x "${mock_dir}/${cmd}"
  export PATH="${mock_dir}:$PATH"
}

# Remove mock command
unmock_command() {
  local cmd="$1"
  rm -f "${TEST_TEMP_DIR}/bin/${cmd}"
}

# Create a mock project structure
create_mock_project() {
  local project_dir="${1:-$TEST_TEMP_DIR/project}"

  mkdir -p "${project_dir}/commands"
  mkdir -p "${project_dir}/skills/test-skill"
  mkdir -p "${project_dir}/.claude-plugin"

  # Create minimal files
  echo "# Test Command" > "${project_dir}/commands/test-command.md"
  echo "# Test Skill" > "${project_dir}/skills/test-skill/SKILL.md"
  echo '{"version": "1.0.0"}' > "${project_dir}/.claude-plugin/plugin.json"

  # Create CLAUDE.md with references
  cat > "${project_dir}/CLAUDE.md" << 'EOF'
# Test Project

## Commands
| Command | Description |
|---------|-------------|
| `/wdi:test-command` | Test command |

## Skills
| Skill | Trigger | Description |
|-------|---------|-------------|
| `test-skill` | "test" | Test skill |

Current version: 1.0.0
EOF

  # Create README.md
  cat > "${project_dir}/README.md" << 'EOF'
# Test Project

## Commands
| Command | Description |
|---------|-------------|
| `/wdi:test-command` | Test command |

## Skills
| Skill | Trigger | Description |
|-------|---------|-------------|
| `test-skill` | "test" | Test skill |
EOF

  echo "$project_dir"
}
