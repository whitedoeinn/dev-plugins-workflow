#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Auto-detect maintainer mode when running from plugin source
IS_MAINTAINER=false
PLUGIN_NAME=""
MARKETPLACE_NAME=""
REMOTE_MARKETPLACE_NAME=""

# Maintainer mode requires the FULL plugin source structure:
# - .claude-plugin/plugin.json (plugin config)
# - .claude-plugin/marketplace.json (local marketplace definition)
# - commands/ directory (command definitions)
# - skills/ directory (skill definitions)
# This prevents false positives on vendored projects or wrong directories.
if [[ -f ".claude-plugin/plugin.json" ]] && \
   [[ -f ".claude-plugin/marketplace.json" ]] && \
   [[ -d "commands" ]] && \
   [[ -d "skills" ]]; then
  if command -v jq >/dev/null 2>&1; then
    PLUGIN_NAME=$(jq -r '.name' .claude-plugin/plugin.json)
    MARKETPLACE_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
  else
    # Fallback: extract name without jq
    PLUGIN_NAME=$(grep -o '"name": *"[^"]*"' .claude-plugin/plugin.json | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
    MARKETPLACE_NAME=$(grep -o '"name": *"[^"]*"' .claude-plugin/marketplace.json | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
  fi

  # Validate extraction succeeded
  if [[ -n "$PLUGIN_NAME" && "$PLUGIN_NAME" != "null" ]]; then
    # Track remote marketplace name for conflict handling
    REMOTE_MARKETPLACE_NAME="${PLUGIN_NAME}-marketplace"
    IS_MAINTAINER=true
  fi
fi

SCOPE="${1:-project}"

# Handle update flag
if [ "$1" = "update" ]; then
  if [[ "$IS_MAINTAINER" == true ]]; then
    echo -e "${YELLOW}Maintainer mode: No update needed (using live edits)${NC}"
    echo "Just pull the latest changes with git:"
    echo "  git pull origin main"
    exit 0
  fi

  # Detect existing plugin scope (use wdi as reference)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -x "${SCRIPT_DIR}/scripts/get-plugin-scope.sh" ]]; then
    UPDATE_SCOPE=$("${SCRIPT_DIR}/scripts/get-plugin-scope.sh" wdi 2>/dev/null || echo "project")
  elif [[ -x "${SCRIPT_DIR}/get-plugin-scope.sh" ]]; then
    UPDATE_SCOPE=$("${SCRIPT_DIR}/get-plugin-scope.sh" wdi 2>/dev/null || echo "project")
  else
    UPDATE_SCOPE="project"
  fi

  echo -e "${YELLOW}Updating plugins (scope: $UPDATE_SCOPE)...${NC}"
  claude plugin update compound-engineering@every-marketplace --scope "$UPDATE_SCOPE"
  claude plugin update wdi@wdi-marketplace --scope "$UPDATE_SCOPE"
  echo -e "${GREEN}Update complete!${NC}"
  exit 0
fi

# Handle show-commands flag
if [ "$1" = "--show-commands" ]; then
  cat << 'EOF'
## Available Commands

### Workflow Commands
- `/wdi:workflow-feature` - Feature workflow (quick idea OR full build with Plan → Work → Review → Compound)
- `/wdi:workflow-feature #N` - Continue existing issue from where it left off
- `/wdi:workflow-enhanced-ralph` - Quality-gated feature execution with research agents and type-specific reviews
- `/wdi:workflow-milestone` - Create and execute milestone-based feature groupings
- `/wdi:workflow-setup` - Set up and verify plugin dependencies

### Skills (Auto-Invoked)
- `workflow-commit` - Smart commit with tests, auto-docs, and changelog (say "commit these changes")
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

if [[ "$IS_MAINTAINER" == true ]]; then
  echo -e "${YELLOW}Detected plugin source: $PLUGIN_NAME${NC}"
  echo "Installing in maintainer mode (live edits enabled)"
else
  echo -e "${YELLOW}Setting up wdi and dependencies...${NC}"
fi
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

# Step 3: Add plugin marketplace (local or remote)
if [[ "$IS_MAINTAINER" == true ]]; then
  echo -e "${YELLOW}Step 3: Adding local marketplace...${NC}"
  # Remove existing marketplace first if names conflict (local and remote use same name in marketplace.json)
  # This ensures local directory takes precedence over remote GitHub URL
  if ! claude plugin marketplace add "$(pwd)" 2>/dev/null; then
    echo -e "${YELLOW}Marketplace '$MARKETPLACE_NAME' exists, replacing with local...${NC}"
    claude plugin marketplace remove "$MARKETPLACE_NAME" 2>/dev/null || true
    if claude plugin marketplace add "$(pwd)" 2>/dev/null; then
      echo -e "${GREEN}Local marketplace added: $MARKETPLACE_NAME${NC}"
    else
      echo -e "${RED}Failed to add local marketplace${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}Local marketplace added: $MARKETPLACE_NAME${NC}"
  fi
else
  echo -e "${YELLOW}Step 3: Adding wdi marketplace...${NC}"
  if claude plugin marketplace add https://github.com/whitedoeinn/dev-plugins-workflow 2>/dev/null; then
    echo -e "${GREEN}Marketplace added${NC}"
  else
    echo -e "${YELLOW}Marketplace already exists (continuing)${NC}"
  fi
fi
echo ""

# Step 4: Install plugin
if [[ "$IS_MAINTAINER" == true ]]; then
  echo -e "${YELLOW}Step 4: Installing $PLUGIN_NAME from local...${NC}"
  # Disable any orphaned plugin entries from previous installations
  # This handles cases where marketplace was removed but plugin entry persists
  claude plugin disable "${PLUGIN_NAME}@${REMOTE_MARKETPLACE_NAME}" --scope "$SCOPE" 2>/dev/null || true
  claude plugin disable "${PLUGIN_NAME}@${PLUGIN_NAME}-local" --scope "$SCOPE" 2>/dev/null || true
  if claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" --scope "$SCOPE"; then
    echo -e "${GREEN}$PLUGIN_NAME installed from local (live edits enabled)${NC}"
  else
    echo -e "${YELLOW}$PLUGIN_NAME may already be installed${NC}"
  fi
else
  echo -e "${YELLOW}Step 4: Installing wdi...${NC}"
  if claude plugin install wdi@wdi-marketplace --scope "$SCOPE"; then
    echo -e "${GREEN}wdi installed${NC}"
  else
    echo -e "${YELLOW}wdi may already be installed${NC}"
  fi
fi
echo ""

# Step 5: Create CLAUDE.md if missing
echo -e "${YELLOW}Step 5: Checking for CLAUDE.md...${NC}"
if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/CLAUDE.md" ]; then
  cat > CLAUDE.md << 'EOF'
# Project

## Available Commands

### Workflow Commands
- `/wdi:workflow-feature` - Feature workflow (quick idea OR full build with Plan → Work → Review → Compound)
- `/wdi:workflow-feature #N` - Continue existing issue from where it left off
- `/wdi:workflow-enhanced-ralph` - Quality-gated feature execution with research agents and type-specific reviews
- `/wdi:workflow-milestone` - Create and execute milestone-based feature groupings
- `/wdi:workflow-setup` - Set up and verify plugin dependencies

### Skills (Auto-Invoked)
- `workflow-commit` - Smart commit with tests, auto-docs, and changelog (say "commit these changes")
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
if [[ "$IS_MAINTAINER" == true ]]; then
  echo -e "${GREEN}Maintainer setup complete!${NC}"
  echo ""
  echo "Mode: Maintainer (live edits enabled)"
  echo "  Changes to commands/*.md and skills/*/SKILL.md take effect immediately."
  echo "  Restart Claude Code after modifying hooks/hooks.json."
  echo ""
else
  echo -e "${GREEN}Setup complete!${NC}"
fi
echo ""
echo "Available commands:"
echo "  Workflow:"
echo "    /wdi:workflow-feature         - Quick idea OR full build workflow"
echo "    /wdi:workflow-feature #N      - Continue existing issue"
echo "    /wdi:workflow-enhanced-ralph  - Quality-gated feature execution"
echo "    /wdi:workflow-milestone       - Create/execute milestone groupings"
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
