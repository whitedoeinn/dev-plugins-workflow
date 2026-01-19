---
title: Plugin installer marketplace name mismatch causes orphaned plugin reference
date: 2026-01-18
category: developer-experience
component: plugin-installer
severity: high
problem_type: silent-failure
symptoms:
  - wdi plugin not visible after curl|bash installation
  - Plugin listed as "enabled" but marketplace doesn't exist
  - wdi@wdi-local enabled but wdi-local marketplace not found
  - Local plugin directory installation fails silently
  - Commands return "Unknown skill" error
tags:
  - plugin-installation
  - marketplace
  - claude-code
  - installer
  - silent-failure
  - naming-mismatch
  - orphaned-reference
root_cause: Installer assumed marketplace name pattern instead of reading from marketplace.json
solution_approach: Read actual marketplace name from marketplace.json and handle naming conflicts explicitly
files_modified:
  - install.sh
related_issues:
  - "#43"
learnings:
  - Never assume naming conventions - read actual configuration files
  - Handle collisions explicitly - don't rely on silent failure handling
  - Use explicit qualification - plugin@marketplace not just plugin
---

# Marketplace Naming Conflict Causes Orphaned Plugin Reference

## Problem

After implementing #43 (enabling marketplace plugin for installer mode testing), running the installer via `curl|bash` resulted in the wdi plugin not being visible at all. Commands returned "Unknown skill: wdi:" errors.

Investigation revealed:
- `wdi@wdi-local` was listed as "enabled" but no `wdi-local` marketplace existed
- The installer assumed marketplaces would be named `${PLUGIN_NAME}-local`
- Claude Code actually uses the `name` field from `marketplace.json`, which is `wdi-marketplace`
- When remote marketplace (also `wdi-marketplace`) was added first, adding local directory failed silently
- Result: Orphaned plugin reference pointing to non-existent marketplace

## Root Cause

Three interconnected problems in install.sh:

1. **Hardcoded marketplace name assumption**: Script assumed local marketplaces would use `-local` suffix (e.g., `wdi-local`), but `marketplace.json` defines the actual name as `wdi-marketplace`.

2. **Marketplace name collision**: Both remote (GitHub) and local (directory) installations use the same marketplace name from `marketplace.json`. When the script tried to add a local marketplace but remote already existed, the command failed silently.

3. **Orphaned plugin entries**: When a marketplace was removed, plugin entries referencing it persisted. These stale references caused installation failures.

## Solution

### Fix 1: Read Marketplace Name from marketplace.json

```bash
if [[ -f ".claude-plugin/marketplace.json" ]]; then
  MARKETPLACE_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
fi

# Fall back to plugin-name-local if marketplace.json doesn't exist
if [[ -z "$MARKETPLACE_NAME" || "$MARKETPLACE_NAME" == "null" ]]; then
  MARKETPLACE_NAME="${PLUGIN_NAME}-local"
fi
```

**Why**: Claude CLI identifies marketplaces by the `name` field in `marketplace.json`, not by any derived pattern.

### Fix 2: Handle Marketplace Name Conflicts

```bash
if ! claude plugin marketplace add "$(pwd)" 2>/dev/null; then
  echo "Marketplace '$MARKETPLACE_NAME' exists, replacing with local..."
  claude plugin marketplace remove "$MARKETPLACE_NAME" 2>/dev/null || true
  claude plugin marketplace add "$(pwd)"
fi
```

**Why**: When local and remote share the same name, explicitly remove the conflicting marketplace and retry. Local development takes precedence.

### Fix 3: Clean Up Orphaned Plugin Entries

```bash
# Disable any orphaned plugin entries from previous installations
claude plugin disable "${PLUGIN_NAME}@${REMOTE_MARKETPLACE_NAME}" --scope "$SCOPE" 2>/dev/null || true
claude plugin disable "${PLUGIN_NAME}@${PLUGIN_NAME}-local" --scope "$SCOPE" 2>/dev/null || true
```

**Why**: Plugin entries persist after marketplace removal. Proactively disable known orphaned entries before installation.

## Prevention Patterns

### For Future Plugin Installers

1. **Read actual configuration, never assume**
   ```bash
   # WRONG: Assume naming convention
   MARKETPLACE_NAME="${PLUGIN_NAME}-local"

   # RIGHT: Read actual marketplace name
   MARKETPLACE_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
   ```

2. **Handle name collisions explicitly** - Don't rely on silent failure handling

3. **Use explicit qualification** - Always `plugin@marketplace`, not just `plugin`

4. **Test collision scenarios** - Local/remote coexistence is a real use case

### Testing Checklist

- [ ] Fresh install on clean system
- [ ] Remote installed, then local: local takes precedence
- [ ] Local installed, then remote from different project: explicit qualification works
- [ ] jq not installed: fallback grep works
- [ ] marketplace.json missing: defaults correctly

## Diagnosis Commands

```bash
# Check marketplace configuration
claude plugin marketplace list

# Check plugin state
claude plugin list | grep wdi

# Verify marketplace source
# Should show: Source: Directory (/path/to/plugin) for local
# Should show: Source: Git (https://...) for remote
```

## Related Documentation

- [Installer Auto-Detection](./installer-auto-detection.md) - Initial #43 implementation
- [Plugin Architecture](../../standards/PLUGIN-ARCHITECTURE.md) - One-plugin policy
- [Troubleshooting](../../troubleshooting.md) - Common plugin issues
