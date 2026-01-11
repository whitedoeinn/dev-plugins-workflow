#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCOPE="${1:-project}"

# Handle update flag
if [ "$1" = "update" ]; then
  echo -e "${YELLOW}Updating plugins...${NC}"
  claude plugin update compound-engineering --scope project
  claude plugin update wdi-workflows --scope project
  echo -e "${GREEN}Update complete!${NC}"
  exit 0
fi

# Handle show-commands flag
if [ "$1" = "--show-commands" ]; then
  cat << 'EOF'
## Available Commands

### Workflow Commands
- `/wdi-workflows:feature` - Full feature workflow (research → plan → work → review → compound)
- `/wdi-workflows:commit` - Smart commit with tests, simplicity review, and changelog
- `/wdi-workflows:setup` - Set up and verify plugin dependencies

### Standards Commands
- `/wdi-workflows:new-repo` - Create a new repository following naming and structure standards
- `/wdi-workflows:new-package` - Add a new package to a mono-repo following standards
- `/wdi-workflows:check-standards` - Validate current repository against development standards
- `/wdi-workflows:update-standard` - Impact analysis and guided updates when changing standards
- `/wdi-workflows:new-command` - Create a new command and update all dependent files

Copy the above to your CLAUDE.md file to update the available commands section.
EOF
  exit 0
fi

echo -e "${YELLOW}Setting up wdi-workflows and dependencies...${NC}"
echo ""

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM="macOS"
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
  PLATFORM="WSL ($WSL_DISTRO_NAME)"
else
  PLATFORM="Linux"
fi
echo "Platform: $PLATFORM"
echo ""

# Verify Claude Code is installed
if ! command -v claude >/dev/null 2>&1; then
  echo -e "${RED}Error: Claude Code CLI not found${NC}"
  echo "Visit: https://code.claude.com to install"
  exit 1
fi

echo "Claude Code found"
echo ""

# Step 1: Add compound-engineering marketplace
echo -e "${YELLOW}Step 1: Adding compound-engineering marketplace...${NC}"
if claude plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin 2>/dev/null; then
  echo -e "${GREEN}Marketplace added${NC}"
else
  echo -e "${YELLOW}Marketplace already exists (continuing)${NC}"
fi
echo ""

# Step 2: Install compound-engineering
echo -e "${YELLOW}Step 2: Installing compound-engineering...${NC}"
if claude plugin install compound-engineering --scope "$SCOPE"; then
  echo -e "${GREEN}compound-engineering installed${NC}"
else
  echo -e "${YELLOW}compound-engineering may already be installed${NC}"
fi
echo ""

# Step 3: Add wdi-workflows marketplace
echo -e "${YELLOW}Step 3: Adding wdi-workflows marketplace...${NC}"
if claude plugin marketplace add https://github.com/whitedoeinn/wdi-workflows 2>/dev/null; then
  echo -e "${GREEN}Marketplace added${NC}"
else
  echo -e "${YELLOW}Marketplace already exists (continuing)${NC}"
fi
echo ""

# Step 4: Install wdi-workflows
echo -e "${YELLOW}Step 4: Installing wdi-workflows...${NC}"
if claude plugin install wdi-workflows --scope "$SCOPE"; then
  echo -e "${GREEN}wdi-workflows installed${NC}"
else
  echo -e "${YELLOW}wdi-workflows may already be installed${NC}"
fi
echo ""

# Step 5: Create CLAUDE.md if missing
echo -e "${YELLOW}Step 5: Checking for CLAUDE.md...${NC}"
if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/CLAUDE.md" ]; then
  cat > CLAUDE.md << 'EOF'
# Project

## Available Commands

### Workflow Commands
- `/wdi-workflows:feature` - Full feature workflow (research → plan → work → review → compound)
- `/wdi-workflows:commit` - Smart commit with tests, simplicity review, and changelog
- `/wdi-workflows:setup` - Set up and verify plugin dependencies

### Standards Commands
- `/wdi-workflows:new-repo` - Create a new repository following naming and structure standards
- `/wdi-workflows:new-package` - Add a new package to a mono-repo following standards
- `/wdi-workflows:check-standards` - Validate current repository against development standards
- `/wdi-workflows:update-standard` - Impact analysis and guided updates when changing standards
- `/wdi-workflows:new-command` - Create a new command and update all dependent files

## Setup

These commands require the `wdi-workflows` and `compound-engineering` plugins.
To reinstall or update, run: `./install.sh` or `./install.sh update`
EOF
  echo -e "${GREEN}Created CLAUDE.md${NC}"
else
  echo -e "${GREEN}CLAUDE.md already exists${NC}"
  echo -e "${YELLOW}Note: New commands may have been added. Run with --show-commands to see latest.${NC}"
fi
echo ""

# Done
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Available commands:"
echo "  Workflow:"
echo "    /wdi-workflows:feature         - Full feature workflow"
echo "    /wdi-workflows:commit          - Smart commit with review"
echo "  Standards:"
echo "    /wdi-workflows:new-repo        - Create new repository"
echo "    /wdi-workflows:new-package     - Add package to mono-repo"
echo "    /wdi-workflows:check-standards - Validate against standards"
echo "    /wdi-workflows:update-standard - Update standard dependencies"
echo "    /wdi-workflows:new-command     - Create new command"
echo ""
echo "To update plugins later: ./install.sh update"
