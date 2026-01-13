#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up GitHub labels for idea/feature workflow...${NC}"
echo ""

# Check gh auth
if ! gh auth status >/dev/null 2>&1; then
  echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
  echo "Run: gh auth login"
  exit 1
fi

# Status labels (lifecycle)
echo "Creating status labels..."
gh label create "status:idea" --color "FBCA04" --description "Raw idea, needs shaping" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:idea" || echo "  - status:idea (exists)"
gh label create "status:needs-design" --color "FBCA04" --description "Problem clear, solution unclear" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:needs-design" || echo "  - status:needs-design (exists)"
gh label create "status:needs-research" --color "FBCA04" --description "Needs technical investigation" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:needs-research" || echo "  - status:needs-research (exists)"
gh label create "status:ready" --color "0E8A16" --description "Ready for implementation" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:ready" || echo "  - status:ready (exists)"
gh label create "status:in-progress" --color "1D76DB" --description "Actively being worked" 2>/dev/null && echo -e "  ${GREEN}✓${NC} status:in-progress" || echo "  - status:in-progress (exists)"

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
echo "  status:*    - Lifecycle state (idea → ready → in-progress)"
echo "  needs:*     - Blockers (info, decision, discussion)"
echo "  appetite:*  - Time budget (small, medium, big)"
