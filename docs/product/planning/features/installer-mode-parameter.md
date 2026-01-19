# Feature: Installer Auto-Detection for Maintainer Mode

**Type:** Enhancement
**Status:** Complete
**Issue:** #43
**Appetite:** Small batch

## Problem

Setting up the wdi plugin for local development/maintenance is a manual, multi-step process requiring direct edits to multiple config files. This friction discourages dogfooding and makes onboarding new maintainers difficult.

## Solution

Auto-detect when running from a plugin source directory and automatically use local marketplace mode.

### Behavior

```
Detect plugin source?
  ├── Yes → Maintainer mode (automatic)
  └── No  → User mode (current behavior)
```

No flags. No prompts. No choices. Context determines behavior.

### Detection Logic

If `.claude-plugin/plugin.json` exists in current directory:
- Extract plugin name from JSON
- Add current directory as local marketplace
- Install plugin from local marketplace (live edits)
- Disable any remote version to avoid conflicts

Otherwise:
- Current behavior (install from GitHub)

### Generic Implementation

Works for ANY plugin, not just wdi. Reads plugin name from `plugin.json` instead of hardcoding.

## Implementation

### Changes to install.sh

```bash
# At top of script, after color definitions:
if [[ -f ".claude-plugin/plugin.json" ]]; then
  PLUGIN_NAME=$(jq -r '.name' .claude-plugin/plugin.json)
  MARKETPLACE_NAME="${PLUGIN_NAME}-local"
  IS_MAINTAINER=true
  echo -e "${YELLOW}Detected plugin source: $PLUGIN_NAME${NC}"
  echo "Installing in maintainer mode (live edits enabled)"
  echo ""
fi

# In main logic:
if [[ "$IS_MAINTAINER" == true ]]; then
  # Add local marketplace
  claude plugin marketplace add "$(pwd)" 2>/dev/null || true

  # Disable remote version if exists
  claude plugin disable "${PLUGIN_NAME}@${PLUGIN_NAME}-marketplace" 2>/dev/null || true

  # Install from local
  claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" --scope "$SCOPE"
else
  # Current remote behavior (unchanged)
  ...
fi
```

## Done When

- [x] Detects `.claude-plugin/plugin.json` in cwd
- [x] Extracts plugin name generically (works for any plugin)
- [x] Installs from local marketplace when in plugin source
- [x] Disables remote version to avoid conflicts
- [x] Falls back to current behavior when not in plugin source
- [x] compound-engineering installed regardless of mode
