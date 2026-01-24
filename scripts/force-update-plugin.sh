#!/usr/bin/env bash
# force-update-plugin.sh - Bulletproof plugin update for all machines
#
# Use this script after breaking changes to force ALL machines to get the latest version.
# It clears caches, refreshes marketplace, and reinstalls the plugin.
#
# Usage:
#   ./scripts/force-update-plugin.sh
#   curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/force-update-plugin.sh | bash

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         WDI Plugin Force Update                               ║"
echo "║         Clearing caches and reinstalling fresh                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Detect installation scope
SCOPE="user"
if claude plugin list 2>/dev/null | grep -q "wdi@wdi-marketplace.*project"; then
  SCOPE="project"
fi
echo "Detected installation scope: $SCOPE"

# Step 1: Clear plugin cache
echo ""
echo "Step 1/5: Clearing plugin cache..."
if [ -d "$HOME/.claude/plugins/cache/wdi-marketplace" ]; then
  rm -rf "$HOME/.claude/plugins/cache/wdi-marketplace"
  echo "  ✓ Cleared ~/.claude/plugins/cache/wdi-marketplace/"
else
  echo "  - Cache already clear"
fi

# Step 2: Refresh marketplace
echo ""
echo "Step 2/5: Refreshing marketplace..."
claude plugin marketplace update wdi-marketplace 2>/dev/null || {
  echo "  - Marketplace not found, adding it first..."
  claude plugin marketplace add https://github.com/whitedoeinn/dev-plugins-workflow 2>/dev/null || true
}
echo "  ✓ Marketplace refreshed"

# Step 3: Uninstall existing plugin
echo ""
echo "Step 3/5: Removing existing plugin installation..."
claude plugin uninstall wdi@wdi-marketplace --scope "$SCOPE" 2>/dev/null || echo "  - No existing installation found"
echo "  ✓ Removed existing installation"

# Step 4: Fresh install
echo ""
echo "Step 4/5: Installing fresh from marketplace..."
claude plugin install wdi@wdi-marketplace --scope "$SCOPE"
echo "  ✓ Plugin installed"

# Step 5: Verify
echo ""
echo "Step 5/5: Verifying installation..."
INSTALLED_VERSION=$(claude plugin list 2>/dev/null | grep "wdi@wdi-marketplace" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
echo "  Installed version: $INSTALLED_VERSION"

# Show what commands should now be available
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Update Complete!                                             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "IMPORTANT: You must restart Claude Code TWICE for changes to take effect:"
echo ""
echo "  1. First restart  → Downloads new plugin version"
echo "  2. Second restart → Loads the new plugin into memory"
echo ""
echo "After restarting twice, these commands should work:"
echo "  /wdi:workflow-feature     (was: /wdi:workflows-feature)"
echo "  /wdi:workflow-setup       (was: /wdi:workflows-setup)"
echo "  /wdi:workflow-milestone   (was: /wdi:workflows-milestone)"
echo "  /wdi:workflow-enhanced-ralph (was: /wdi:workflows-enhanced-ralph)"
echo ""
echo "If commands still show old names after two restarts, run this script again."
