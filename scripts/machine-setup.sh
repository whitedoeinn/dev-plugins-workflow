#!/usr/bin/env bash
# Machine Setup for Claude Code
# Run this once on a new development machine to configure plugins and settings.
# Also safe to re-run to clean up and reset to a known good state.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/machine-setup.sh | bash
#   # or
#   ./scripts/machine-setup.sh

set -euo pipefail

echo "Setting up Claude Code environment..."
echo ""

# Ensure ~/.claude directory exists
mkdir -p ~/.claude/plugins

if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code CLI not found. Install it first:"
  echo "  npm install -g @anthropic-ai/claude-code"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq not found. Install it first:"
  echo "  brew install jq  # macOS"
  echo "  sudo apt install jq  # Ubuntu/Debian"
  exit 1
fi

# Step 1: Clear plugin caches to ensure fresh downloads
echo "Step 1: Clearing plugin caches..."
rm -rf ~/.claude/plugins/cache/wdi-marketplace/ 2>/dev/null || true
rm -rf ~/.claude/plugins/cache/every-marketplace/ 2>/dev/null || true
echo "  Done"

# Step 2: Update marketplaces to get latest versions
echo ""
echo "Step 2: Updating marketplaces..."
claude plugin marketplace update wdi-marketplace 2>/dev/null || true
claude plugin marketplace update every-marketplace 2>/dev/null || true
echo "  Done"

# Step 3: Clean installed_plugins.json - remove project-scope and deduplicate
echo ""
echo "Step 3: Cleaning plugin registry..."
INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"

if [[ -f "$INSTALLED_PLUGINS" ]]; then
  # Keep only the most recent user-scope entry for each plugin (removes project-scope AND duplicates)
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

# Step 4: Remove any project-scope settings.json files in known project directories
echo ""
echo "Step 4: Removing stale project settings files..."
PROJECTS=(
  "$HOME/github/whitedoeinn/dev-plugins-workflow"
  "$HOME/github/whitedoeinn/events"
  "$HOME/github/whitedoeinn/google-ads"
  "$HOME/github/whitedoeinn/integration"
)

for project in "${PROJECTS[@]}"; do
  if [[ -f "$project/.claude/settings.json" ]]; then
    rm -f "$project/.claude/settings.json"
    echo "  Removed: $project/.claude/settings.json"
  fi
done
echo "  Done"

# Step 5: Ensure plugins are installed at user scope (install if missing, update if present)
echo ""
echo "Step 5: Ensuring plugins at user scope..."

# Check what's already installed
CE_INSTALLED=$(jq -r '.plugins["compound-engineering@every-marketplace"] | length' "$INSTALLED_PLUGINS" 2>/dev/null || echo "0")
WDI_INSTALLED=$(jq -r '.plugins["wdi@wdi-marketplace"] | length' "$INSTALLED_PLUGINS" 2>/dev/null || echo "0")

if [[ "$CE_INSTALLED" == "0" ]]; then
  echo "  Installing compound-engineering..."
  claude plugin install compound-engineering@every-marketplace --scope user
else
  echo "  Updating compound-engineering..."
  claude plugin update compound-engineering@every-marketplace 2>/dev/null || true
fi

if [[ "$WDI_INSTALLED" == "0" ]]; then
  echo "  Installing wdi..."
  claude plugin install wdi@wdi-marketplace --scope user
else
  echo "  Updating wdi..."
  claude plugin update wdi@wdi-marketplace 2>/dev/null || true
fi
echo "  Done"

# Step 6: Create global CLAUDE.md with environment standards
echo ""
echo "Step 6: Creating global CLAUDE.md..."

cat > ~/.claude/CLAUDE.md << 'EOF'
# Global Claude Code Settings

## Google Drive

Google Drive is synced locally at `~/Google Drive/`.

**Primary shared drive:**
- **White Doe Inn**: `~/Google Drive/Shared drives/White Doe Inn/`

When I mention "Google Drive" or files related to White Doe Inn business operations, look in the shared drive path above.

### Common locations:
- Kitchen Remodel: `~/Google Drive/Shared drives/White Doe Inn/Operations/Building and Maintenance /Kitchen Remodel/`
- Weathertek files: `~/Google Drive/Shared drives/White Doe Inn/Operations/Building and Maintenance /Kitchen Remodel/Weathertek Construction & Restoration/`

## Claude Code Environment Standards

### Plugin Installation Policy

**All plugins MUST be installed at user scope (global), NOT project scope.**

Expected configuration in `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "compound-engineering@every-marketplace": true,
    "wdi@wdi-marketplace": true
  }
}
```

**DRIFT ALERT:** If you see ANY of these conditions, stop and alert me:
- A `.claude/settings.json` file exists in ANY project directory
- `claude plugin list` shows the same plugin at both user AND project scope
- Any plugin installed at project scope (should always be user scope)

**Why this matters:** Project-scope installations create version conflicts and stale caches. User-scope ensures all projects use the same version and updates propagate correctly.

### Protected Settings

These settings should NEVER be modified without explicit user request:
- Plugin installation scope (must stay at user scope)
- Permission mode settings
- Status line configuration
- Hook configurations

If any workflow or script attempts to modify these settings, warn me before proceeding.
EOF

echo "  Done"

# Step 7: Verify installation
echo ""
echo "Step 7: Verifying installation..."
echo ""

# Get fresh plugin list
PLUGIN_JSON=$(claude plugin list --json 2>/dev/null || echo "[]")

# Check compound-engineering
CE_USER=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "compound-engineering@every-marketplace" and .scope == "user")] | length')
CE_PROJECT=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "compound-engineering@every-marketplace" and .scope == "project")] | length')
CE_VERSION=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "compound-engineering@every-marketplace" and .scope == "user")][0].version // "none"')

if [[ "$CE_USER" == "1" ]] && [[ "$CE_PROJECT" == "0" ]]; then
  echo "  ✓ compound-engineering: OK (user scope, v$CE_VERSION)"
else
  echo "  ✗ compound-engineering: PROBLEM (user=$CE_USER, project=$CE_PROJECT)"
fi

# Check wdi
WDI_USER=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "wdi@wdi-marketplace" and .scope == "user")] | length')
WDI_PROJECT=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "wdi@wdi-marketplace" and .scope == "project")] | length')
WDI_VERSION=$(echo "$PLUGIN_JSON" | jq -r '[.[] | select(.id == "wdi@wdi-marketplace" and .scope == "user")][0].version // "none"')

if [[ "$WDI_USER" == "1" ]] && [[ "$WDI_PROJECT" == "0" ]]; then
  echo "  ✓ wdi: OK (user scope, v$WDI_VERSION)"
else
  echo "  ✗ wdi: PROBLEM (user=$WDI_USER, project=$WDI_PROJECT)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup complete!"
echo ""
echo "  Restart Claude Code to activate plugins."
echo "  To verify: claude plugin list"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
