#!/bin/bash
#
# vendor-to-project.sh - Vendor wdi plugin into a project
#
# Usage: ./scripts/vendor-to-project.sh /path/to/target/project
#
# This script copies the wdi plugin files into the target project's .claude-plugin/
# directory. compound-engineering remains a global dependency (not vendored).
#
# Architecture: See docs/standards/PLUGIN-ARCHITECTURE.md
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WDI_ROOT="$(dirname "$SCRIPT_DIR")"

# Validate arguments
if [ -z "$1" ]; then
    echo -e "${RED}Error: Target project path required${NC}"
    echo "Usage: $0 /path/to/target/project"
    exit 1
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET${NC}"
    exit 1
fi

echo -e "${GREEN}Vendoring wdi plugin to: $TARGET${NC}"
echo ""

# Get wdi version
WDI_VERSION=$(jq -r '.version' "$WDI_ROOT/.claude-plugin/plugin.json")
echo "wdi version: $WDI_VERSION"

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$TARGET/.claude-plugin/commands"
mkdir -p "$TARGET/.claude-plugin/skills"
mkdir -p "$TARGET/.claude-plugin/hooks"
mkdir -p "$TARGET/.claude"
mkdir -p "$TARGET/scripts"

# Copy wdi commands
echo "Copying commands..."
cp "$WDI_ROOT/commands/"*.md "$TARGET/.claude-plugin/commands/"

# Copy wdi skills
echo "Copying skills..."
for skill_dir in "$WDI_ROOT/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$TARGET/.claude-plugin/skills/$skill_name"
    cp -R "$skill_dir"* "$TARGET/.claude-plugin/skills/$skill_name/"
    echo "  Copied skill: $skill_name"
done

# Copy hooks
echo "Copying hooks..."
cp "$WDI_ROOT/hooks/hooks.json" "$TARGET/.claude-plugin/hooks/"

# Update hook paths to be relative to new location
if command -v jq &> /dev/null; then
    # Hooks should reference scripts relative to plugin root
    # No path changes needed since we're copying the structure
    :
fi

# Copy supporting files
echo "Copying supporting files..."
cp -R "$WDI_ROOT/knowledge" "$TARGET/.claude-plugin/" 2>/dev/null || true
cp "$WDI_ROOT/env-baseline.json" "$TARGET/.claude-plugin/" 2>/dev/null || true

# Copy scripts needed by hooks
mkdir -p "$TARGET/.claude-plugin/scripts"
cp "$WDI_ROOT/scripts/check-deps.sh" "$TARGET/.claude-plugin/scripts/" 2>/dev/null || true
cp "$WDI_ROOT/scripts/validate-env.sh" "$TARGET/.claude-plugin/scripts/" 2>/dev/null || true
chmod +x "$TARGET/.claude-plugin/scripts/"*.sh 2>/dev/null || true

# Clear required_plugins from vendored env-baseline.json
# (compound-engineering is a global dependency, not vendored)
echo "Updating env-baseline.json..."
if [ -f "$TARGET/.claude-plugin/env-baseline.json" ]; then
    jq '.required_plugins = []' "$TARGET/.claude-plugin/env-baseline.json" \
        > "$TARGET/.claude-plugin/env-baseline.json.tmp" \
        && mv "$TARGET/.claude-plugin/env-baseline.json.tmp" \
              "$TARGET/.claude-plugin/env-baseline.json"
fi

# Update hooks to use correct paths
echo "Updating hook paths..."
if [ -f "$TARGET/.claude-plugin/hooks/hooks.json" ]; then
    # Update paths to reference scripts in the vendored location
    sed -i.bak 's|\${CLAUDE_PLUGIN_ROOT}/scripts/|\${CLAUDE_PLUGIN_ROOT}/scripts/|g' \
        "$TARGET/.claude-plugin/hooks/hooks.json"
    rm -f "$TARGET/.claude-plugin/hooks/hooks.json.bak"
fi

# Create plugin.json
echo "Creating plugin.json..."
cat > "$TARGET/.claude-plugin/plugin.json" << EOF
{
  "name": "wdi",
  "description": "WDI development toolkit - vendored from dev-plugins",
  "version": "$WDI_VERSION",
  "commands": "./commands/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
EOF

# Create plugin-manifest.json for tracking
echo "Creating plugin-manifest.json..."
cat > "$TARGET/.claude-plugin/plugin-manifest.json" << EOF
{
  "vendored_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$WDI_ROOT",
  "wdi_version": "$WDI_VERSION",
  "external_dependencies": {
    "compound-engineering": {
      "source": "every-marketplace",
      "note": "Install globally: claude plugin install compound-engineering --scope project"
    }
  }
}
EOF

# Create/update .claude/settings.json to require compound-engineering
echo "Configuring settings.json..."
if [ -f "$TARGET/.claude/settings.json" ]; then
    # Add compound-engineering to enabledPlugins if not present
    if command -v jq &> /dev/null; then
        # Check if enabledPlugins exists and add compound-engineering
        jq '. + {"enabledPlugins": (.enabledPlugins // {} | . + {"compound-engineering@every-marketplace": true})}' \
            "$TARGET/.claude/settings.json" > "$TARGET/.claude/settings.json.tmp" \
            && mv "$TARGET/.claude/settings.json.tmp" "$TARGET/.claude/settings.json"
    fi
else
    # Create new settings.json with compound-engineering enabled
    cat > "$TARGET/.claude/settings.json" << EOF
{
  "enabledPlugins": {
    "compound-engineering@every-marketplace": true
  }
}
EOF
fi

# Create update script in target project
echo "Creating update script..."
cat > "$TARGET/scripts/update-plugins.sh" << 'UPDATEEOF'
#!/bin/bash
#
# update-plugins.sh - Update vendored wdi plugin from source
#
# Usage: ./scripts/update-plugins.sh
#
# This script re-vendors the wdi plugin from its source location.
# Modify WDI_SOURCE if your dev-plugins repo is elsewhere.
#

set -e

# Configure source location (modify if needed)
WDI_SOURCE="${WDI_SOURCE:-$HOME/vscode-projects/dev-plugins-workflow}"

if [ ! -d "$WDI_SOURCE" ]; then
    echo "Error: wdi source not found at $WDI_SOURCE"
    echo "Set WDI_SOURCE environment variable to the correct path"
    exit 1
fi

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Updating wdi plugin from: $WDI_SOURCE"
echo "Target project: $PROJECT_ROOT"

# Run the vendor script from source
"$WDI_SOURCE/scripts/vendor-to-project.sh" "$PROJECT_ROOT"

echo ""
echo "Plugin updated successfully!"
echo ""
echo "Remember: compound-engineering is a global dependency."
echo "To update it: claude plugin update compound-engineering --scope project"
UPDATEEOF

chmod +x "$TARGET/scripts/update-plugins.sh"

# Summary
echo ""
echo -e "${GREEN}Done! Vendored wdi plugin to $TARGET${NC}"
echo ""
echo "Vendored:"
echo "  wdi: $WDI_VERSION"
echo ""
echo "External dependency (global, not vendored):"
echo "  compound-engineering (via every-marketplace)"
echo ""
echo "Next steps:"
echo "  1. Ensure compound-engineering is installed:"
echo "     claude plugin install compound-engineering --scope project"
echo "  2. Start Claude Code in the project directory"
echo "  3. Verify with: /wdi:workflows-setup"
echo ""
echo "To update wdi later:"
echo "  cd $TARGET && ./scripts/update-plugins.sh"
