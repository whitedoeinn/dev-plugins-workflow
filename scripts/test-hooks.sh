#!/bin/bash
# Unit tests for hook scripts
# Run: ./scripts/test-hooks.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/pre-tool-standards-check.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

# Test helper - runs hook and checks exit code
run_test() {
  local name="$1"
  local expected_exit="$2"
  local marker="$3"
  local input="$4"

  # Run the hook script with the given input
  if [ "$marker" = "1" ]; then
    echo "$input" | COMMIT_SKILL_ACTIVE=1 "$HOOK_SCRIPT" 2>/dev/null
  else
    echo "$input" | "$HOOK_SCRIPT" 2>/dev/null
  fi
  local actual_exit=$?

  if [ "$actual_exit" -eq "$expected_exit" ]; then
    echo -e "${GREEN}✓ PASS${NC}: $name"
    ((PASS++))
  else
    echo -e "${RED}✗ FAIL${NC}: $name (expected exit $expected_exit, got $actual_exit)"
    ((FAIL++))
  fi
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Hook Script Unit Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Direct commit without marker - should BLOCK
echo "Test 1: Direct git commit (no marker)"
run_test "Direct git commit blocks" 1 "0" '{"tool_input":{"command":"git commit -m \"test message\""}}'

# Test 2: Commit with marker - should ALLOW
echo ""
echo "Test 2: Commit with COMMIT_SKILL_ACTIVE=1"
run_test "Commit with marker allows" 0 "1" '{"tool_input":{"command":"git commit -m \"test message\""}}'

# Test 3: Non-commit command - should ALLOW (pass through)
echo ""
echo "Test 3: Non-commit commands"
run_test "git status passes through" 0 "0" '{"tool_input":{"command":"git status"}}'
run_test "git push passes through" 0 "0" '{"tool_input":{"command":"git push origin main"}}'
run_test "npm test passes through" 0 "0" '{"tool_input":{"command":"npm test"}}'

# Test 4: Chained commit command - should BLOCK
echo ""
echo "Test 4: Chained commands with git commit"
run_test "Chained git commit blocks" 1 "0" '{"tool_input":{"command":"git add . && git commit -m \"test\""}}'

# Test 5: Chained commit with marker - should ALLOW
echo ""
echo "Test 5: Chained commit with marker"
run_test "Chained commit with marker allows" 0 "1" '{"tool_input":{"command":"git add . && git commit -m \"test\""}}'

# Test 6: Empty/malformed input - should pass through
echo ""
echo "Test 6: Edge cases"
run_test "Empty JSON passes through" 0 "0" '{}'
run_test "Missing command passes through" 0 "0" '{"tool_input":{}}'

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Exit with failure if any tests failed
[ $FAIL -eq 0 ] || exit 1
