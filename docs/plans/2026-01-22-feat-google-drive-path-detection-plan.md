---
title: Add cross-platform Google Drive path detection utility
type: feat
date: 2026-01-22
issue: "#64"
---

# Add cross-platform Google Drive path detection utility

Add `scripts/get-google-drive-path.sh` - a shell utility that detects the platform (WSL vs Mac/Linux) and returns the correct Google Drive base path.

## Problem

Projects using Google Drive sync need cross-platform path detection:
- **Mac/Linux:** `$HOME/Google Drive/`
- **WSL:** `/mnt/c/Users/<winuser>/Google Drive/`

Currently duplicated in `business-ops` and `wdi-content` as Node.js modules. A shared shell script provides a single source of truth callable from any context.

## Acceptance Criteria

- [x] `scripts/get-google-drive-path.sh` returns correct path on WSL
- [x] `scripts/get-google-drive-path.sh` returns correct path on Mac/Linux
- [x] Optional relative path argument works: `get-google-drive-path.sh "Shared drives/X"`
- [x] Falls back to `$HOME/Google Drive` if WSL detection fails
- [x] Script is executable and follows existing script patterns

## Implementation

**File:** `scripts/get-google-drive-path.sh`

```bash
#!/usr/bin/env bash
# Cross-platform Google Drive path detection
#
# Usage:
#   ./get-google-drive-path.sh              # Returns base path
#   ./get-google-drive-path.sh "relative"   # Returns base path + relative
#
# Returns:
#   WSL: /mnt/c/Users/<winuser>/Google Drive[/relative]
#   Mac/Linux: $HOME/Google Drive[/relative]

set -e

# Detect WSL via /proc/version
if grep -qi microsoft /proc/version 2>/dev/null; then
  # WSL: Get Windows username
  WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n') || WIN_USER=""
  if [ -n "$WIN_USER" ]; then
    BASE="/mnt/c/Users/$WIN_USER/Google Drive"
  else
    # Fallback if cmd.exe fails
    BASE="$HOME/Google Drive"
  fi
else
  # Mac/Linux
  BASE="$HOME/Google Drive"
fi

# Output with optional relative path
if [ -n "$1" ]; then
  echo "$BASE/$1"
else
  echo "$BASE"
fi
```

## Verification

```bash
# Test on current platform
./scripts/get-google-drive-path.sh
# Expected (WSL): /mnt/c/Users/dgrst/Google Drive

./scripts/get-google-drive-path.sh "Shared drives/White Doe Inn"
# Expected: Full path to shared drive
```

## References

- Shaping: `.claude/plans/idea-64-technical-2026-01-22.md`
- Pattern: `scripts/get-plugin-scope.sh` (getter utility example)
- Related issue: #64
