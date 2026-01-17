# Testing Guide

This document describes the testing infrastructure for the wdi plugin.

## Overview

| Layer | Framework | Purpose | When to Run |
|-------|-----------|---------|-------------|
| **Unit** | BATS | Test individual scripts in isolation | Every change |
| **Integration** | Shell scripts | Test plugin structure and file validation | Every PR |

## Quick Start

```bash
# Run all tests
./scripts/run-tests.sh

# Run unit tests only
./scripts/run-tests.sh unit

# Run integration tests only
./scripts/run-tests.sh integration
```

## Directory Structure

```
tests/
├── unit/                        # BATS unit tests
│   ├── validate-env.bats       # Tests for validate-env.sh
│   └── check-docs-drift.bats   # Tests for check-docs-drift.sh
├── integration/                 # Integration tests
│   └── run-integration.sh      # Plugin structure validation
├── fixtures/                   # Test data
└── test_helper.bash            # Common test utilities
```

## Running Tests

### Local Development

```bash
# Run all tests
./scripts/run-tests.sh

# Run specific unit test file
bats tests/unit/validate-env.bats

# Run with verbose output
./scripts/run-tests.sh --verbose unit

# Filter tests by name
./scripts/run-tests.sh --filter "baseline" unit
```

### CI Pipeline

Tests run automatically via GitHub Actions on every push and PR:

| Trigger | Tests Run |
|---------|-----------|
| Push to any branch | Unit + Integration |
| Pull Request | Unit + Integration |

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
| `BATS_LIB_PATH` | Location of BATS helper libraries (auto-detected on macOS) |

## Troubleshooting

### BATS not found

```bash
# macOS
brew install bats-core

# Ubuntu
sudo apt install bats
```

### BATS libraries not found

```bash
# macOS
brew tap bats-core/bats-core
brew install bats-support bats-assert bats-file

# Ubuntu/manual
sudo git clone https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support
sudo git clone https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert
sudo git clone https://github.com/bats-core/bats-file.git /usr/local/lib/bats-file
```

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
2. Add integration checks to `run-integration.sh` if needed
3. Update this document if the testing approach changes
