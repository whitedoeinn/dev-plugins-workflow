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
  claude plugin update compound-engineering@every-marketplace --scope project
  claude plugin update wdi@wdi-marketplace --scope project
  echo -e "${GREEN}Update complete!${NC}"
  exit 0
fi

# Handle show-commands flag
if [ "$1" = "--show-commands" ]; then
  cat << 'EOF'
## Available Commands

### Workflow Commands
- `/wdi:workflows-feature` - Full feature workflow (research → plan → work → review → compound)
- `/wdi:workflows-feature --idea` - Quick idea capture (creates idea file + draft issue)
- `/wdi:workflows-enhanced-ralph` - Quality-gated feature execution with research agents and type-specific reviews
- `/wdi:workflows-milestone` - Create and execute milestone-based feature groupings
- `/wdi:workflows-setup` - Set up and verify plugin dependencies

### Skills (Auto-Invoked)
- `workflow-commit` - Smart commit with tests, simplicity review, and changelog (say "commit these changes")
- `workflow-auto-docs` - Detect and fix documentation drift (say "update the docs")
- `config-sync` - Validate environment (say "check my config")

### Standards Commands
- `/wdi:standards-new-repo` - Create a new repository following naming and structure standards
- `/wdi:standards-new-subproject` - Add a new subproject to a mono-repo following standards
- `/wdi:standards-check` - Validate current repository against development standards
- `/wdi:standards-update` - Impact analysis and guided updates when changing standards
- `/wdi:standards-new-command` - Create a new command and update all dependent files

Copy the above to your CLAUDE.md file to update the available commands section.
EOF
  exit 0
fi

# Handle show-dev-workflow flag
if [ "$1" = "--show-dev-workflow" ]; then
  cat << 'EOF'
## Development Workflow

When developing this plugin:

### Commands and Skills
Changes to `commands/*.md` and `skills/*/SKILL.md` take effect immediately.
No restart required.

### Testing Hooks
Hooks require special handling:

1. Start Claude Code with plugin loaded from source:
   ```bash
   claude --plugin-dir .
   ```

2. Restart Claude Code after modifying hooks/hooks.json

### CI Validation
GitHub Actions validates on every PR:
- JSON syntax
- File existence
- Script permissions
- Hook script unit tests

Hook changes trigger a reminder to test in a live Claude session.
EOF
  exit 0
fi

echo -e "${YELLOW}Setting up wdi and dependencies...${NC}"
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

# Step 3: Add wdi marketplace
echo -e "${YELLOW}Step 3: Adding wdi marketplace...${NC}"
if claude plugin marketplace add https://github.com/whitedoeinn/dev-plugins-workflow 2>/dev/null; then
  echo -e "${GREEN}Marketplace added${NC}"
else
  echo -e "${YELLOW}Marketplace already exists (continuing)${NC}"
fi
echo ""

# Step 4: Install wdi
echo -e "${YELLOW}Step 4: Installing wdi...${NC}"
if claude plugin install wdi@wdi-marketplace --scope "$SCOPE"; then
  echo -e "${GREEN}wdi installed${NC}"
else
  echo -e "${YELLOW}wdi may already be installed${NC}"
fi
echo ""

# Step 5: Create CLAUDE.md if missing
echo -e "${YELLOW}Step 5: Checking for CLAUDE.md...${NC}"
if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/CLAUDE.md" ]; then
  cat > CLAUDE.md << 'EOF'
# Project

## Available Commands

### Workflow Commands
- `/wdi:workflows-feature` - Full feature workflow (research → plan → work → review → compound)
- `/wdi:workflows-feature --idea` - Quick idea capture (creates idea file + draft issue)
- `/wdi:workflows-enhanced-ralph` - Quality-gated feature execution with research agents and type-specific reviews
- `/wdi:workflows-milestone` - Create and execute milestone-based feature groupings
- `/wdi:workflows-setup` - Set up and verify plugin dependencies

### Skills (Auto-Invoked)
- `workflow-commit` - Smart commit with tests, simplicity review, and changelog (say "commit these changes")
- `workflow-auto-docs` - Detect and fix documentation drift (say "update the docs")
- `config-sync` - Validate environment (say "check my config")

### Standards Commands
- `/wdi:standards-new-repo` - Create a new repository following naming and structure standards
- `/wdi:standards-new-subproject` - Add a new subproject to a mono-repo following standards
- `/wdi:standards-check` - Validate current repository against development standards
- `/wdi:standards-update` - Impact analysis and guided updates when changing standards
- `/wdi:standards-new-command` - Create a new command and update all dependent files

## Setup

These commands require the `wdi` and `compound-engineering` plugins.
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
echo "    /wdi:workflows-feature         - Full feature workflow"
echo "    /wdi:workflows-feature --idea  - Quick idea capture"
echo "    /wdi:workflows-enhanced-ralph  - Quality-gated feature execution"
echo "    /wdi:workflows-milestone       - Create/execute milestone groupings"
echo "  Skills (auto-invoked):"
echo "    workflow-commit                - Say 'commit these changes' to trigger"
echo "    workflow-auto-docs             - Say 'update the docs' to trigger"
echo "    config-sync                    - Say 'check my config' to trigger"
echo "  Standards:"
echo "    /wdi:standards-new-repo        - Create new repository"
echo "    /wdi:standards-new-subproject  - Add subproject to mono-repo"
echo "    /wdi:standards-check           - Validate against standards"
echo "    /wdi:standards-update          - Update standard dependencies"
echo "    /wdi:standards-new-command     - Create new command"
echo ""
echo "To update plugins later: ./install.sh update"
