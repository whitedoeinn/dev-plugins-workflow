# Testing Guide

This document describes the testing infrastructure for the wdi plugin.

## Overview

The testing infrastructure consists of three layers:

| Layer | Framework | Purpose | When to Run |
|-------|-----------|---------|-------------|
| **Unit** | BATS | Test individual scripts in isolation | Every change |
| **Integration** | Shell scripts | Test command/skill parsing and structure | Every PR |
| **E2E** | Docker containers | Test full workflows in realistic environments | Nightly / Manual |

## Quick Start

```bash
# Run all tests locally
./scripts/run-tests.sh all --local

# Run unit tests only
./scripts/run-tests.sh unit --local

# Run tests in Docker (recommended for consistency)
./scripts/run-tests.sh docker
```

## Directory Structure

```
tests/
├── unit/                        # BATS unit tests
│   ├── validate-env.bats       # Tests for validate-env.sh
│   ├── check-docs-drift.bats   # Tests for check-docs-drift.sh
│   └── wdi-cli.bats            # Tests for wdi CLI
├── integration/                 # Integration tests
│   └── run-integration.sh      # Command/skill parsing tests
├── e2e/                        # End-to-end tests
│   ├── run-e2e.sh              # E2E orchestrator
│   └── scenarios/              # Test scenarios
│       ├── fresh-install.sh    # New user installation
│       └── create-project.sh   # Project creation workflow
├── fixtures/                   # Test data (shared with test/fixtures)
├── test_helper.bash            # Common test utilities
├── Dockerfile.test             # Full test environment
├── Dockerfile.fresh-env        # Clean environment for E2E
└── docker-compose.test.yml     # Multi-container orchestration
```

## Running Tests

### Local Development

For quick iteration during development:

```bash
# Run specific unit test file
bats tests/unit/validate-env.bats

# Run with verbose output
bats --verbose-run tests/unit/

# Filter tests by name
./scripts/run-tests.sh unit --local --filter "baseline"
```

### Docker (Recommended)

For consistent, reproducible results:

```bash
# Build and run all tests
./scripts/run-tests.sh docker

# Run just unit tests in Docker
docker build -t wdi-test -f tests/Dockerfile.test .
docker run --rm wdi-test

# Run E2E tests
./scripts/run-tests.sh e2e
```

### CI Pipeline

Tests run automatically via GitHub Actions:

| Trigger | Tests Run |
|---------|-----------|
| Push to any branch | Unit + Integration |
| Pull Request | Unit + Integration + Matrix |
| Manual dispatch | Unit + Integration + E2E |
| Nightly (scheduled) | Full E2E suite |

## Writing Tests

### Unit Tests (BATS)

Create tests in `tests/unit/*.bats`:

```bash
#!/usr/bin/env bats

load '../test_helper'

setup() {
  setup_temp_dir
  # Test-specific setup
}

teardown() {
  teardown_temp_dir
}

@test "descriptive test name" {
  run some_command

  assert_success
  assert_output --partial "expected text"
}
```

**Available assertions** (from bats-assert):
- `assert_success` - Exit code 0
- `assert_failure` - Non-zero exit code
- `assert_output "exact"` - Exact output match
- `assert_output --partial "text"` - Partial output match
- `assert_line "line"` - Specific line in output

### Integration Tests

Add tests to `tests/integration/run-integration.sh`:

```bash
test_new_feature() {
  log "Testing new feature..."

  if some_check; then
    success "Feature works"
  else
    fail "Feature broken"
  fi
}

# Call at bottom of file
test_new_feature
```

### E2E Scenarios

Create new scenarios in `tests/e2e/scenarios/`:

```bash
#!/usr/bin/env bash
# E2E Scenario: Description

set -euo pipefail

# Colors and helpers
source /plugin/tests/e2e/helpers.sh 2>/dev/null || true

log() { echo -e "\033[0;36m[SCENARIO]\033[0m $1"; }
success() { echo -e "\033[0;32m[PASS]\033[0m $1"; }
fail() { echo -e "\033[0;31m[FAIL]\033[0m $1"; exit 1; }

# Test implementation
log "Running my scenario..."

# Verify outcomes
if [[ -f expected_file ]]; then
  success "File was created"
else
  fail "File was not created"
fi
```

## Test Helpers

The `tests/test_helper.bash` provides common utilities:

| Function | Description |
|----------|-------------|
| `setup_temp_dir` | Create temp directory, set `$TEST_TEMP_DIR` |
| `teardown_temp_dir` | Clean up temp directory |
| `create_mock_baseline` | Create test env-baseline.json |
| `create_passing_baseline` | Create baseline that passes validation |
| `mock_command cmd behavior` | Mock a command (success/failure/version) |
| `create_mock_project` | Create minimal project structure |

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `BATS_LIB_PATH` | Location of BATS helper libraries |
| `GH_TOKEN` | GitHub token for E2E tests |
| `TEST_ORG` | GitHub org for E2E tests (default: wdi-test) |
| `ANTHROPIC_API_KEY` | For Claude-based tests (optional) |

## Docker Images

### Dockerfile.test

Full test environment with all dependencies:
- Ubuntu 22.04
- git, jq, gh
- BATS + helper libraries
- Non-root test user

### Dockerfile.fresh-env

Minimal environment for fresh install testing:
- Ubuntu 22.04
- Only git and curl
- Simulates new user experience

## Troubleshooting

### BATS not found

```bash
# macOS
brew install bats-core

# Ubuntu
sudo apt install bats

# Manual
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local
```

### BATS libraries not found

```bash
# Install to /usr/local/lib
sudo git clone https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support
sudo git clone https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert
sudo git clone https://github.com/bats-core/bats-file.git /usr/local/lib/bats-file
```

### Docker tests failing

```bash
# Rebuild images
docker compose -f tests/docker-compose.test.yml build --no-cache

# Clean up
./scripts/run-tests.sh clean
```

### Tests pass locally but fail in CI

1. Check you're using the same versions of tools
2. Run in Docker locally: `./scripts/run-tests.sh docker`
3. Check for environment-specific assumptions

## Best Practices

1. **Keep tests fast** - Unit tests should complete in seconds
2. **Test one thing** - Each test should verify a single behavior
3. **Use descriptive names** - Test names should explain what's being tested
4. **Clean up** - Always clean up temp files in teardown
5. **Mock external services** - Don't depend on network in unit tests
6. **Assert outcomes, not implementation** - Test what happened, not how

## Adding New Scripts

When adding a new script to `scripts/`:

1. Create corresponding test file: `tests/unit/new-script.bats`
2. Add integration checks to `run-integration.sh`
3. Consider if E2E coverage is needed
4. Update this document if needed
