#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_usage() {
  cat << 'EOF'
Usage: ./install.sh [command] [options]

Commands:
  (none)          Install plugins (default)
  update          Update plugins to latest version
  --reset         Nuclear cleanup: clear caches, fix registry, reinstall fresh
  --show-commands Show available commands for CLAUDE.md
  --show-dev-workflow  Show development workflow info
  --help          Show this help

Options:
  user            Install at user scope (default, recommended)
  project         Install at project scope (not recommended)

Examples:
  ./install.sh              # Normal install at user scope
  ./install.sh --reset      # Fix broken state, reinstall fresh
  ./install.sh update       # Update to latest versions
EOF
}

# Parse flags
RESET_MODE=false
SCOPE="user"

for arg in "$@"; do
  case "$arg" in
    --reset)
      RESET_MODE=true
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    update|--show-commands|--show-dev-workflow)
      # Handled below
      ;;
    user|project)
      SCOPE="$arg"
      ;;
  esac
done

# Auto-detect maintainer mode when running from plugin source
IS_MAINTAINER=false
PLUGIN_NAME=""
MARKETPLACE_NAME=""
REMOTE_MARKETPLACE_NAME=""

if [[ -f ".claude-plugin/plugin.json" ]] && \
   [[ -f ".claude-plugin/marketplace.json" ]] && \
   [[ -d "commands" ]] && \
   [[ -d "skills" ]]; then
  if command -v jq >/dev/null 2>&1; then
    PLUGIN_NAME=$(jq -r '.name' .claude-plugin/plugin.json)
    MARKETPLACE_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
  else
    PLUGIN_NAME=$(grep -o '"name": *"[^"]*"' .claude-plugin/plugin.json | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
    MARKETPLACE_NAME=$(grep -o '"name": *"[^"]*"' .claude-plugin/marketplace.json | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
  fi

  if [[ -n "$PLUGIN_NAME" && "$PLUGIN_NAME" != "null" ]]; then
    REMOTE_MARKETPLACE_NAME="${PLUGIN_NAME}-marketplace"
    IS_MAINTAINER=true
  fi
fi

# Handle update flag
if [ "$1" = "update" ]; then
  if [[ "$IS_MAINTAINER" == true ]]; then
    echo -e "${YELLOW}Maintainer mode: No update needed (using live edits)${NC}"
    echo "Just pull the latest changes with git:"
    echo "  git pull origin main"
    exit 0
  fi

  echo -e "${YELLOW}Updating plugins...${NC}"
  claude plugin marketplace update wdi-marketplace 2>/dev/null || true
  claude plugin marketplace update every-marketplace 2>/dev/null || true
  claude plugin update compound-engineering@every-marketplace 2>/dev/null || true
  claude plugin update wdi@wdi-marketplace 2>/dev/null || true
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
- `/wdi:wdi-workflow-unleashed` - Exploration methodology: AI discovers approaches through perspective shifts
- `/wdi:wdi-workflow-curate` - Curate discoveries from unleashed exploration

### Skills (Auto-Invoked)
- `workflow-commit` - Smart commit with tests, auto-docs, and changelog (say "commit these changes")
- `workflow-auto-docs` - Detect and fix documentation drift (say "update the docs")
- `config-sync` - Validate environment (say "check my config")
- `discovery-capture` - Document unexpected findings during unleashed exploration
- `exploration-reflection` - Learn from exploration outcomes

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

# ============================================================================
# RESET MODE: Nuclear cleanup
# ============================================================================
if [[ "$RESET_MODE" == true ]]; then
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  Reset Mode: Clearing caches and fixing registry${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  # Check prerequisites
  if ! command -v claude &>/dev/null; then
    echo -e "${RED}ERROR: Claude Code CLI not found${NC}"
    exit 1
  fi

  if ! command -v jq &>/dev/null; then
    echo -e "${RED}ERROR: jq not found. Install it first:${NC}"
    echo "  brew install jq  # macOS"
    echo "  sudo apt install jq  # Ubuntu/Debian"
    exit 1
  fi

  # Ensure ~/.claude directory exists
  mkdir -p ~/.claude/plugins

  # Step 1: Clear plugin caches
  echo -e "${YELLOW}Step 1: Clearing plugin caches...${NC}"
  rm -rf ~/.claude/plugins/cache/wdi-marketplace/ 2>/dev/null || true
  rm -rf ~/.claude/plugins/cache/every-marketplace/ 2>/dev/null || true
  echo "  Done"

  # Step 2: Update marketplaces
  echo ""
  echo -e "${YELLOW}Step 2: Updating marketplaces...${NC}"
  claude plugin marketplace update wdi-marketplace 2>/dev/null || true
  claude plugin marketplace update every-marketplace 2>/dev/null || true
  echo "  Done"

  # Step 3: Clean installed_plugins.json
  echo ""
  echo -e "${YELLOW}Step 3: Cleaning plugin registry...${NC}"
  INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"

  if [[ -f "$INSTALLED_PLUGINS" ]]; then
    # Keep only the most recent user-scope entry for each plugin
    jq '
      .plugins["wdi@wdi-marketplace"] = (
        [.plugins["wdi@wdi-marketplace"][]? | select(.scope == "user")]
        | sort_by(.installedAt) | if length > 0 then [last] else [] end
      ) |
      .plugins["compound-engineering@every-marketplace"] = (
        [.plugins["compound-engineering@every-marketplace"][]? | select(.scope == "user")]
        | sort_by(.installedAt) | if length > 0 then [last] else [] end
      )
    ' "$INSTALLED_PLUGINS" > "${INSTALLED_PLUGINS}.tmp" && mv "${INSTALLED_PLUGINS}.tmp" "$INSTALLED_PLUGINS"
    echo "  Cleaned registry (kept most recent user-scope entry per plugin)"
  else
    echo "  No existing registry (fresh install)"
  fi

  # Step 4: Remove project-scope settings.json in current directory
  echo ""
  echo -e "${YELLOW}Step 4: Removing stale project settings...${NC}"
  if [[ -f ".claude/settings.json" ]]; then
    rm -f ".claude/settings.json"
    echo "  Removed: .claude/settings.json"
  else
    echo "  No stale settings found"
  fi

  # Step 5: Reinstall plugins at user scope
  echo ""
  echo -e "${YELLOW}Step 5: Reinstalling plugins at user scope...${NC}"

  # Uninstall first to ensure clean state
  claude plugin uninstall compound-engineering@every-marketplace --scope user 2>/dev/null || true
  claude plugin uninstall wdi@wdi-marketplace --scope user 2>/dev/null || true

  # Fresh install
  claude plugin install compound-engineering@every-marketplace --scope user
  claude plugin install wdi@wdi-marketplace --scope user
  echo "  Done"

  # Step 6: Verify
  echo ""
  echo -e "${YELLOW}Step 6: Verifying installation...${NC}"
  PLUGIN_JSON=$(claude plugin list --json 2>/dev/null || echo "[]")

  WDI_USER=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "wdi@wdi-marketplace" and .scope == "user")] | length')
  WDI_VERSION=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "wdi@wdi-marketplace" and .scope == "user")][0].version // "none"')
  CE_USER=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "compound-engineering@every-marketplace" and .scope == "user")] | length')
  CE_VERSION=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "compound-engineering@every-marketplace" and .scope == "user")][0].version // "none"')

  if [[ "$WDI_USER" == "1" ]]; then
    echo -e "  ${GREEN}✓${NC} wdi: v$WDI_VERSION (user scope)"
  else
    echo -e "  ${RED}✗${NC} wdi: installation problem"
  fi

  if [[ "$CE_USER" == "1" ]]; then
    echo -e "  ${GREEN}✓${NC} compound-engineering: v$CE_VERSION (user scope)"
  else
    echo -e "  ${RED}✗${NC} compound-engineering: installation problem"
  fi

  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}  Reset complete! Restart Claude Code to activate.${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
fi

# ============================================================================
# NORMAL INSTALL MODE
# ============================================================================

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
  echo "Install from: https://code.claude.com"
  exit 1
fi

# Check for GUI symlink conflict (Homebrew cask installs GUI, not CLI)
CLAUDE_PATH=$(command -v claude)
if [[ -L "$CLAUDE_PATH" ]]; then
  LINK_TARGET=$(readlink "$CLAUDE_PATH" 2>/dev/null || true)
  if [[ "$LINK_TARGET" == *"/Applications/Claude.app"* ]]; then
    echo -e "${RED}Error: Found Claude GUI app, not CLI${NC}"
    echo "The 'claude' command points to the desktop app, not the CLI."
    echo ""
    echo "To fix:"
    echo "  brew uninstall --cask claude"
    echo "  # Then install CLI from: https://code.claude.com"
    exit 1
  fi
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
- `/wdi:wdi-workflow-unleashed` - Exploration methodology: AI discovers approaches through perspective shifts
- `/wdi:wdi-workflow-curate` - Curate discoveries from unleashed exploration

### Skills (Auto-Invoked)
- `workflow-commit` - Smart commit with tests, auto-docs, and changelog (say "commit these changes")
- `workflow-auto-docs` - Detect and fix documentation drift (say "update the docs")
- `config-sync` - Validate environment (say "check my config")
- `discovery-capture` - Document unexpected findings during unleashed exploration
- `exploration-reflection` - Learn from exploration outcomes

### Standards Commands
- `/wdi:standards-new-repo` - Create a new repository following naming and structure standards
- `/wdi:standards-new-subproject` - Add a new subproject to a mono-repo following standards
- `/wdi:standards-check` - Validate current repository against development standards
- `/wdi:standards-update` - Impact analysis and guided updates when changing standards
- `/wdi:standards-new-command` - Create a new command and update all dependent files

## Setup

These commands require the `wdi` and `compound-engineering` plugins.
To reinstall or update, run: `./install.sh` or `./install.sh update`
For problems, run: `./install.sh --reset`
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
else
  echo -e "${GREEN}Setup complete!${NC}"
fi
echo ""
echo "Commands:"
echo "  /wdi:workflow-feature      - Quick idea OR full build workflow"
echo "  /wdi:workflow-commit       - Say 'commit these changes'"
echo "  /wdi:standards-new-repo    - Create new repository"
echo ""
echo "Troubleshooting:"
echo "  ./install.sh update        - Update to latest versions"
echo "  ./install.sh --reset       - Nuclear fix for broken state"
