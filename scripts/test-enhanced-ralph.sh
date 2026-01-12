#!/bin/bash
# Test scenarios for enhanced-ralph command
# Run: ./scripts/test-enhanced-ralph.sh
#
# Note: This script documents test scenarios for manual verification.
# Enhanced-ralph is a Claude Code command, so tests require interactive execution.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIXTURES_DIR="$PROJECT_DIR/test/fixtures"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${CYAN}Enhanced-Ralph Test Scenarios${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify fixtures exist
echo -e "${YELLOW}Verifying test fixtures...${NC}"
echo ""

FEATURES_OK=0
MILESTONES_OK=0

# Check feature fixtures
FEATURE_FILES=(
  "simple-feature.md"
  "ui-feature.md"
  "database-feature.md"
  "feature-a.md"
  "feature-b.md"
  "feature-c.md"
  "circular-a.md"
  "circular-c.md"
)

for file in "${FEATURE_FILES[@]}"; do
  if [ -f "$FIXTURES_DIR/features/$file" ]; then
    echo -e "  ${GREEN}✓${NC} features/$file"
    ((FEATURES_OK++))
  else
    echo -e "  ${RED}✗${NC} features/$file (MISSING)"
  fi
done

echo ""

# Check milestone fixtures
MILESTONE_FILES=(
  "simple-milestone.md"
  "ordered-milestone.md"
  "circular-milestone.md"
  "milestone-1.md"
  "milestone-2.md"
)

for file in "${MILESTONE_FILES[@]}"; do
  if [ -f "$FIXTURES_DIR/milestones/$file" ]; then
    echo -e "  ${GREEN}✓${NC} milestones/$file"
    ((MILESTONES_OK++))
  else
    echo -e "  ${RED}✗${NC} milestones/$file (MISSING)"
  fi
done

echo ""
echo -e "Fixtures: ${GREEN}$FEATURES_OK${NC}/8 features, ${GREEN}$MILESTONES_OK${NC}/5 milestones"
echo ""

if [ $FEATURES_OK -ne 8 ] || [ $MILESTONES_OK -ne 5 ]; then
  echo -e "${RED}Error: Missing test fixtures. Cannot proceed.${NC}"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${CYAN}Test Scenarios (Manual Verification Required)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat << 'EOF'
SCENARIO 1: Single Feature Execution
─────────────────────────────────────
Command: /wdi-workflows:enhanced-ralph simple-feature

Verify:
  [ ] Task type detection identifies ui, api, database types
  [ ] UI tasks invoke frontend-design (NOT design-principles)
  [ ] Research agents invoke when needed
  [ ] Quality gates invoke per task type
  [ ] Final output suggests commit skill ("commit these changes")

SCENARIO 2: Multiple Features in Milestone
──────────────────────────────────────────
Command: /wdi-workflows:enhanced-ralph --milestone simple-milestone

Verify:
  [ ] Both features executed sequentially
  [ ] Each feature status updated to "Complete" after success
  [ ] Milestone status updated to "In Progress" at start
  [ ] Milestone status updated to "Complete" at end
  [ ] Progress reported: "Feature 1/2: ..."

SCENARIO 3: Features with Dependencies
──────────────────────────────────────
Command: /wdi-workflows:enhanced-ralph --milestone ordered-milestone

Verify:
  [ ] Dependency graph built correctly
  [ ] Features listed as C, A, B in milestone
  [ ] Topological sort reorders to: A → B → C
  [ ] Execution follows correct order despite file order

SCENARIO 4: Circular Dependency Detection
─────────────────────────────────────────
Command: /wdi-workflows:enhanced-ralph --milestone circular-milestone

Verify:
  [ ] Cycle detected before execution starts
  [ ] Error message: "Circular dependency detected: circular-a → circular-c → circular-a"
  [ ] Execution blocked (does not proceed)

SCENARIO 5: Milestone Dependencies
──────────────────────────────────
Command: /wdi-workflows:enhanced-ralph --milestone milestone-2

Verify:
  [ ] Warning: "Milestone depends on incomplete MILE-TEST-004"
  [ ] Execution blocked without --force
  [ ] Execution proceeds with --force flag

SCENARIO 6: Implicit Cross-Milestone Dependencies
─────────────────────────────────────────────────
Command: /wdi-workflows:enhanced-ralph --milestone milestone-2

Verify:
  [ ] Cross-milestone dependency detected
  [ ] Warning: "feature-b depends on feature-a from MILE-TEST-004"
  [ ] Suggests completing milestone-1 first or using --force

SCENARIO 7: Resume from Failure
───────────────────────────────
Setup: Execute milestone, manually fail on feature 2
Command: /wdi-workflows:enhanced-ralph --milestone ordered-milestone --continue

Verify:
  [ ] Skips already-completed features
  [ ] Resumes from last incomplete feature
  [ ] Completes remaining features

SCENARIO 8: Missing Feature Files
─────────────────────────────────
Setup: Create milestone referencing non-existent feature
Command: /wdi-workflows:enhanced-ralph --milestone broken-milestone

Verify:
  [ ] Error on missing feature file
  [ ] Lists which features are missing
  [ ] Execution blocked

SCENARIO 9: Quality Gate Failure in Strict Mode
───────────────────────────────────────────────
Command: /wdi-workflows:enhanced-ralph --milestone simple-milestone --strict

Verify:
  [ ] Execution stops on quality gate failure
  [ ] Error clearly indicates which gate failed
  [ ] Milestone status remains "In Progress"

SCENARIO 10: All Flags Work with Milestones
───────────────────────────────────────────
Commands:
  /wdi-workflows:enhanced-ralph --milestone simple-milestone --strict
  /wdi-workflows:enhanced-ralph --milestone simple-milestone --fast
  /wdi-workflows:enhanced-ralph --milestone simple-milestone --skip-gates
  /wdi-workflows:enhanced-ralph --milestone simple-milestone --verbose
  /wdi-workflows:enhanced-ralph --milestone simple-milestone --continue
  /wdi-workflows:enhanced-ralph --milestone simple-milestone --force

Verify:
  [ ] --strict - fails on any quality issue
  [ ] --fast - skips optional reviews
  [ ] --skip-gates - skips all gates
  [ ] --verbose - shows detailed output
  [ ] --continue - resumes from failure
  [ ] --force - ignores milestone dependencies

EDGE CASES
──────────
  [ ] E1: Empty milestone (0 features) - graceful handling
  [ ] E2: Self-dependency (feature blocks itself) - detected as cycle
  [ ] E3: Duplicate features in milestone - detected and warned
  [ ] E4: Invalid feature link format - clear error message
  [ ] E5: Mixed status features - only executes non-complete

EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${CYAN}How to Run Tests${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat << 'EOF'
These tests require interactive Claude Code execution.

1. Start Claude Code in this project:
   claude

2. Copy test fixtures to docs/product/planning/:
   mkdir -p docs/product/planning/features docs/product/planning/milestones
   cp test/fixtures/features/*.md docs/product/planning/features/
   cp test/fixtures/milestones/*.md docs/product/planning/milestones/

3. Run each scenario command and verify the checkboxes above.

4. Clean up after testing:
   rm -rf docs/product/planning/features/*.md
   rm -rf docs/product/planning/milestones/*.md

EOF
echo ""
echo -e "${GREEN}Test fixtures verified. Ready for manual testing.${NC}"
echo ""
