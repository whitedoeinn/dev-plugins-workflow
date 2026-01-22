#!/usr/bin/env bash
# Machine Setup for Claude Code
# Run this once on a new development machine to configure plugins and settings.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/machine-setup.sh | bash
#   # or
#   ./scripts/machine-setup.sh

set -euo pipefail

echo "Setting up Claude Code environment..."

# Ensure ~/.claude directory exists
mkdir -p ~/.claude

# Install plugins at user scope (global)
echo ""
echo "Installing plugins at user scope..."

if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code CLI not found. Install it first:"
  echo "  npm install -g @anthropic-ai/claude-code"
  exit 1
fi

claude plugin install compound-engineering@every-marketplace --scope user
claude plugin install wdi@wdi-marketplace --scope user

# Create global CLAUDE.md with environment standards
echo ""
echo "Creating global CLAUDE.md..."

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

# Verify installation
echo ""
echo "Verifying installation..."

INSTALLED=$(claude plugin list 2>/dev/null || echo "")

if echo "$INSTALLED" | grep -q "compound-engineering.*user"; then
  echo "  compound-engineering: OK (user scope)"
else
  echo "  compound-engineering: MISSING or wrong scope"
fi

if echo "$INSTALLED" | grep -q "wdi.*user"; then
  echo "  wdi: OK (user scope)"
else
  echo "  wdi: MISSING or wrong scope"
fi

# Check for duplicate scopes (should not exist on fresh install)
DUPLICATE_COUNT=$(echo "$INSTALLED" | grep -c "wdi@wdi-marketplace" || echo "0")
if [[ "$DUPLICATE_COUNT" -gt 1 ]]; then
  echo ""
  echo "WARNING: Duplicate wdi installations detected. Run in any project:"
  echo "  claude plugin uninstall wdi@wdi-marketplace --scope project"
fi

echo ""
echo "Setup complete! Restart Claude Code to activate plugins."
echo ""
echo "To verify, run: claude plugin list"
