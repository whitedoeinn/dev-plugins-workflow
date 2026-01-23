#!/usr/bin/env bash
# Cross-platform Google Drive path detection
#
# Returns the platform-appropriate Google Drive base path.
# Detects WSL and constructs the correct Windows-mounted path.
#
# Usage:
#   ./get-google-drive-path.sh              # Returns base path
#   ./get-google-drive-path.sh "relative"   # Returns base path + relative
#   GDRIVE=$(./get-google-drive-path.sh)
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
