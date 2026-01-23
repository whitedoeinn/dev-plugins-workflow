# Shaping: Add cross-platform Google Drive path detection utility

**Issue:** #64
**Perspective:** technical
**Date:** 2026-01-22

## Original Idea

Projects using Google Drive sync need cross-platform path detection:
- **Mac/Linux:** `~/Google Drive/`
- **WSL:** `/mnt/c/Users/<winuser>/Google Drive/`

Currently duplicated in multiple projects. Proposed solution: add `scripts/get-google-drive-path.sh` to the plugin.

## Exploration

### Current Implementations

Examined existing implementations:

1. **business-ops/tools/task-manager/src/lib/google-drive.js**
   - Node.js implementation
   - Detects WSL via `/proc/version` containing "microsoft"
   - Gets Windows username via `cmd.exe /c "echo %USERNAME%"`
   - Provides: `getGoogleDriveBase()`, `getWdiSharedDrive()`, `resolveGoogleDrivePath()`

2. **wdi-content/scripts/google-drive.js**
   - Same logic as above
   - Added project-specific helpers: `getKitchenRemodelFolder()`, `getKitchenRemodelSpreadsheet()`

### Technical Approach

Shell script is appropriate because:
- Zero dependencies (pure bash)
- Works from any context (CLI, scripts, hooks)
- Can be called from JavaScript via `execSync()`
- Plugin already distributes scripts (e.g., `scripts/wdi`)

## Key Questions Answered

- **Q:** How to detect WSL reliably?
  **A:** Check if `/proc/version` contains "microsoft" (case-insensitive)

- **Q:** How to get Windows username from WSL?
  **A:** `cmd.exe /c "echo %USERNAME%"` with carriage return stripping

- **Q:** Should the script handle relative paths?
  **A:** Yes, accept optional argument to append to base path

- **Q:** How will projects use this?
  **A:** Either call directly from bash, or from JS: `execSync('get-google-drive-path.sh').toString().trim()`

## Cross-Cutting Implications

- **→ Business:** None - purely technical utility
- **→ UX:** None - CLI utility

## Open Questions (for next session)

- None - straightforward implementation

## Decisions Made

1. **Shell script over Node module** - Plugin doesn't distribute npm packages, shell scripts work universally
2. **Optional relative path argument** - Allows `get-google-drive-path.sh "Shared drives/X"` pattern
3. **No caching** - Path detection is fast enough, caching adds complexity

## Risks Identified

- **Risk:** Script not in PATH when called from JavaScript
  **Mitigation:** Document that callers should use full path or ensure PATH includes plugin scripts

- **Risk:** `cmd.exe` not available in some WSL configurations
  **Mitigation:** Fall back to `$HOME/Google Drive` if cmd.exe fails

## Rough Scope

**In scope:**
- `scripts/get-google-drive-path.sh` - main utility
- Documentation in scripts/ or README
- Update consuming projects to use it (optional, separate PRs)

**Out of scope:**
- Node.js module distribution
- WDI-specific path helpers (callers compose their own paths)
- Automatic PATH setup (document manual setup if needed)

---

## Implementation Plan

### Step 1: Create the shell script

**File:** `scripts/get-google-drive-path.sh`

```bash
#!/bin/bash
# Cross-platform Google Drive path detection
# Usage: get-google-drive-path.sh [relative-path]

set -e

# Detect platform and get base path
if grep -qi microsoft /proc/version 2>/dev/null; then
  # WSL: Get Windows username and construct path
  WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n') || WIN_USER=""
  if [ -n "$WIN_USER" ]; then
    BASE="/mnt/c/Users/$WIN_USER/Google Drive"
  else
    # Fallback if cmd.exe fails
    BASE="$HOME/Google Drive"
  fi
else
  # Mac/Linux: Use home directory
  BASE="$HOME/Google Drive"
fi

# Output with optional relative path
if [ -n "$1" ]; then
  echo "$BASE/$1"
else
  echo "$BASE"
fi
```

### Step 2: Make executable and test

```bash
chmod +x scripts/get-google-drive-path.sh
./scripts/get-google-drive-path.sh
./scripts/get-google-drive-path.sh "Shared drives/White Doe Inn"
```

### Step 3: Document in README or create docs/utilities.md

Add usage examples and note about PATH.

---

## Verification

```bash
# On WSL
./scripts/get-google-drive-path.sh
# Expected: /mnt/c/Users/dgrst/Google Drive

# On Mac/Linux
./scripts/get-google-drive-path.sh
# Expected: /home/user/Google Drive (or /Users/user/Google Drive on Mac)

# With relative path
./scripts/get-google-drive-path.sh "Shared drives/White Doe Inn/Operations"
# Expected: Full path to that directory
```
