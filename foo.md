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
