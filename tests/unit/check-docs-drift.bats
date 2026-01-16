#!/usr/bin/env bats
# Unit tests for check-docs-drift.sh
#
# Tests the documentation drift detection script

load '../test_helper'

# Path to the script under test
SCRIPT="${SCRIPTS_DIR}/check-docs-drift.sh"

setup() {
  setup_temp_dir

  # Create mock project structure
  export MOCK_PROJECT="${TEST_TEMP_DIR}/project"
  mkdir -p "${MOCK_PROJECT}/commands"
  mkdir -p "${MOCK_PROJECT}/skills/test-skill"
  mkdir -p "${MOCK_PROJECT}/.claude-plugin"
  mkdir -p "${MOCK_PROJECT}/scripts"

  # Copy the actual script
  cp "$SCRIPT" "${MOCK_PROJECT}/scripts/check-docs-drift.sh"
  chmod +x "${MOCK_PROJECT}/scripts/check-docs-drift.sh"

  # Change to mock project for tests
  cd "$MOCK_PROJECT"
}

teardown() {
  teardown_temp_dir
}

# ==============================================================================
# No drift tests
# ==============================================================================

@test "check-docs-drift: passes when no commands or skills exist" {
  # Create minimal docs
  echo "# Project" > CLAUDE.md
  echo "# Project" > README.md

  run ./scripts/check-docs-drift.sh

  assert_success
}

@test "check-docs-drift: passes when commands are documented" {
  # Create a command
  echo "# Test Command" > commands/test-cmd.md

  # Create docs that reference it
  cat > CLAUDE.md << 'EOF'
# Test Project
## Commands
/wdi:test-cmd - Test command
EOF

  cat > README.md << 'EOF'
# Test Project
## Commands
/wdi:test-cmd - Test command
EOF

  run ./scripts/check-docs-drift.sh

  assert_success
}

@test "check-docs-drift: passes when skills are documented" {
  # Create a skill
  mkdir -p skills/my-skill
  echo "# My Skill" > skills/my-skill/SKILL.md

  # Create docs that reference it with correct table format
  cat > CLAUDE.md << 'EOF'
# Test Project
## Skills
| `my-skill` | trigger | description |
EOF

  cat > README.md << 'EOF'
# Test Project
## Skills
| `my-skill` | trigger | description |
EOF

  run ./scripts/check-docs-drift.sh

  assert_success
}

# ==============================================================================
# Drift detection tests
# ==============================================================================

@test "check-docs-drift: detects command missing from CLAUDE.md" {
  # Create a command
  echo "# New Command" > commands/new-cmd.md

  # CLAUDE.md doesn't reference it
  cat > CLAUDE.md << 'EOF'
# Test Project
No commands here
EOF

  cat > README.md << 'EOF'
# Test Project
/wdi:new-cmd is here
EOF

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:command:new-cmd:missing_claude"
}

@test "check-docs-drift: detects command missing from README.md" {
  # Create a command
  echo "# Another Command" > commands/another-cmd.md

  # CLAUDE.md references it
  cat > CLAUDE.md << 'EOF'
# Test Project
/wdi:another-cmd is documented
EOF

  # README.md doesn't
  cat > README.md << 'EOF'
# Test Project
No commands here
EOF

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:command:another-cmd:missing_readme"
}

@test "check-docs-drift: detects skill missing from CLAUDE.md" {
  # Create a skill
  mkdir -p skills/missing-skill
  echo "# Missing Skill" > skills/missing-skill/SKILL.md

  # CLAUDE.md doesn't have the table entry
  cat > CLAUDE.md << 'EOF'
# Test Project
No skills table
EOF

  cat > README.md << 'EOF'
# Test Project
| `missing-skill` | trigger | description |
EOF

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:skill:missing-skill:missing_claude"
}

@test "check-docs-drift: detects skill missing from README.md" {
  mkdir -p skills/orphan-skill
  echo "# Orphan Skill" > skills/orphan-skill/SKILL.md

  cat > CLAUDE.md << 'EOF'
# Test Project
| `orphan-skill` | trigger | description |
EOF

  cat > README.md << 'EOF'
# Test Project
No skills
EOF

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:skill:orphan-skill:missing_readme"
}

# ==============================================================================
# Version sync tests
# ==============================================================================

@test "check-docs-drift: detects version mismatch" {
  # Create plugin.json with version
  echo '{"version": "2.0.0"}' > .claude-plugin/plugin.json

  # CLAUDE.md has different version
  cat > CLAUDE.md << 'EOF'
# Test Project
Current version: 1.0.0
EOF

  echo "# Readme" > README.md

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:version:2.0.0:claude_mismatch:1.0.0"
}

@test "check-docs-drift: passes when versions match" {
  echo '{"version": "1.5.0"}' > .claude-plugin/plugin.json

  cat > CLAUDE.md << 'EOF'
# Test Project
Current version: 1.5.0
EOF

  echo "# Readme" > README.md

  run ./scripts/check-docs-drift.sh

  assert_success
}

# ==============================================================================
# Stale reference tests
# ==============================================================================

@test "check-docs-drift: detects stale command reference" {
  # CLAUDE.md references a command that doesn't exist
  cat > CLAUDE.md << 'EOF'
# Test Project
See commands/nonexistent-cmd.md for details
EOF

  echo "# Readme" > README.md

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:stale_ref:commands/nonexistent-cmd.md"
}

@test "check-docs-drift: detects stale skill reference" {
  cat > CLAUDE.md << 'EOF'
# Test Project
Check skills/ghost-skill/SKILL.md
EOF

  echo "# Readme" > README.md

  run ./scripts/check-docs-drift.sh

  assert_failure
  assert_output --partial "DRIFT:stale_ref:skills/ghost-skill/SKILL.md"
}

@test "check-docs-drift: excludes changelog from stale reference checks" {
  mkdir -p docs
  # Changelog can reference old/removed files
  cat > docs/changelog.md << 'EOF'
# Changelog
- Removed commands/old-command.md
EOF

  echo "# Project" > CLAUDE.md
  echo "# Project" > README.md

  run ./scripts/check-docs-drift.sh

  assert_success
}

# ==============================================================================
# Output format tests
# ==============================================================================

@test "check-docs-drift: outputs DRIFT: format for parsing" {
  echo "# Undocumented" > commands/undoc.md
  echo "# Project" > CLAUDE.md
  echo "# Project" > README.md

  run ./scripts/check-docs-drift.sh

  assert_failure
  # Check output starts with DRIFT:
  assert_output --partial "DRIFT:"
}

@test "check-docs-drift: --verbose shows colors and details" {
  echo "# Undocumented" > commands/undoc.md
  echo "# Project" > CLAUDE.md
  echo "# Project" > README.md

  run ./scripts/check-docs-drift.sh --verbose

  assert_failure
  # Verbose mode shows more details (checking for text, not colors in output)
  assert_output --partial "Checking"
}

@test "check-docs-drift: exit code 0 means no drift" {
  echo "# Project" > CLAUDE.md
  echo "# Project" > README.md

  run ./scripts/check-docs-drift.sh

  [ "$status" -eq 0 ]
}

@test "check-docs-drift: exit code 1 means drift found" {
  echo "# Missing" > commands/missing.md
  echo "# Project" > CLAUDE.md
  echo "# Project" > README.md

  run ./scripts/check-docs-drift.sh

  [ "$status" -eq 1 ]
}
