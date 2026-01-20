#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up GitHub labels for issue management...${NC}"
echo ""

# Check gh auth
if ! gh auth status >/dev/null 2>&1; then
  echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
  echo "Run: gh auth login"
  exit 1
fi

# Type labels (required - one per issue)
echo "Creating type labels..."
gh label create "bug" --color "d73a4a" --description "Something isn't working correctly" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} bug" || echo "  - bug (exists)"
gh label create "feature" --color "0075ca" --description "New functionality" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} feature" || echo "  - feature (exists)"
gh label create "enhancement" --color "a2eeef" --description "Improvement to existing functionality" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} enhancement" || echo "  - enhancement (exists)"
gh label create "documentation" --color "0075ca" --description "Documentation only" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} documentation" || echo "  - documentation (exists)"
gh label create "question" --color "d876e3" --description "Needs discussion or clarification" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} question" || echo "  - question (exists)"
gh label create "experiment" --color "fbca04" --description "Exploratory work, spike, POC" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} experiment" || echo "  - experiment (exists)"
gh label create "idea" --color "c5def5" --description "Captured idea, not yet shaped" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} idea" || echo "  - idea (exists)"
gh label create "chore" --color "bfdadc" --description "Maintenance, cleanup, dependencies" --force 2>/dev/null && echo -e "  ${GREEN}✓${NC} chore" || echo "  - chore (exists)"

echo ""

# Status labels (lifecycle)
echo "Creating status labels..."
gh label create "status:needs-shaping" --color "FBCA04" --description "Raw idea, needs shaping" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:needs-shaping" || echo "  - status:needs-shaping (exists)"
gh label create "status:needs-design" --color "FBCA04" --description "Problem clear, solution unclear" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:needs-design" || echo "  - status:needs-design (exists)"
gh label create "status:needs-research" --color "FBCA04" --description "Needs technical investigation" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:needs-research" || echo "  - status:needs-research (exists)"
gh label create "status:ready" --color "0E8A16" --description "Ready for implementation" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:ready" || echo "  - status:ready (exists)"
gh label create "status:in-progress" --color "1D76DB" --description "Actively being worked" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:in-progress" || echo "  - status:in-progress (exists)"
gh label create "status:ready-to-promote" --color "0E8A16" --description "Triaged, ready for promotion" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:ready-to-promote" || echo "  - status:ready-to-promote (exists)"

echo ""

# Triage labels (from /wdi:triage-ideas)
echo "Creating triage labels..."
gh label create "triage:quick-decision" --color "1D76DB" --description "Needs brief investigation" 2>/dev/null && echo -e "  ${GREEN}✓${NC} triage:quick-decision" || echo "  - triage:quick-decision (exists)"
gh label create "blocked:research" --color "D93F0B" --description "Waiting on parent research" 2>/dev/null && echo -e "  ${GREEN}✓${NC} blocked:research" || echo "  - blocked:research (exists)"
gh label create "research" --color "5319E7" --description "Research initiative" 2>/dev/null && echo -e "  ${GREEN}✓${NC} research" || echo "  - research (exists)"

echo ""

# Needs labels (blockers)
echo "Creating needs labels..."
gh label create "needs:info" --color "D93F0B" --description "Awaiting more information" 2>/dev/null && echo -e "  ${GREEN}✓${NC} needs:info" || echo "  - needs:info (exists)"
gh label create "needs:decision" --color "D93F0B" --description "Blocked on decision" 2>/dev/null && echo -e "  ${GREEN}✓${NC} needs:decision" || echo "  - needs:decision (exists)"
gh label create "needs:discussion" --color "D93F0B" --description "Needs team discussion" 2>/dev/null && echo -e "  ${GREEN}✓${NC} needs:discussion" || echo "  - needs:discussion (exists)"

echo ""

# Appetite labels (sizing)
echo "Creating appetite labels..."
gh label create "appetite:small" --color "C5DEF5" --description "Hours to days" 2>/dev/null && echo -e "  ${GREEN}✓${NC} appetite:small" || echo "  - appetite:small (exists)"
gh label create "appetite:medium" --color "C5DEF5" --description "1-2 weeks" 2>/dev/null && echo -e "  ${GREEN}✓${NC} appetite:medium" || echo "  - appetite:medium (exists)"
gh label create "appetite:big" --color "C5DEF5" --description "3-6 weeks" 2>/dev/null && echo -e "  ${GREEN}✓${NC} appetite:big" || echo "  - appetite:big (exists)"

echo ""
echo -e "${GREEN}Labels setup complete!${NC}"
echo ""
echo "Label scheme:"
echo "  Type labels - What the issue IS (bug, feature, idea, chore, etc.)"
echo "  status:*    - Lifecycle state (needs-shaping → ready → in-progress)"
echo "  triage:*    - Triage actions (quick-decision)"
echo "  blocked:*   - Blockers (research)"
echo "  needs:*     - Blockers (info, decision, discussion)"
echo "  appetite:*  - Time budget (small, medium, big)"
