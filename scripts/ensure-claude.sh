#!/usr/bin/env bash
set -e

# scripts/ensure-claude.sh
# Ensure the Claude Code CLI is installed. Exits 0 when available, non-zero otherwise.
# Usage:
#   bash scripts/ensure-claude.sh            # interactive by default
#   CLAUDE_AUTO_INSTALL=1 bash scripts/ensure-claude.sh  # try non-interactive installs
#   CLAUDE_ALLOW_REMOTE_INSTALL=1 bash scripts/ensure-claude.sh # allow piping remote installer

NON_INTERACTIVE=0
[[ "$CLAUDE_AUTO_INSTALL" == "1" ]] && NON_INTERACTIVE=1

# Quick success check
if command -v claude >/dev/null 2>&1; then
  # If 'claude' exists on PATH, ensure it's the CLI and not a GUI symlink (Homebrew cask)
  CLAUDE_PATH=$(command -v claude)
  # Try to get symlink target (portable)
  if [ -L "$CLAUDE_PATH" ]; then
    LINK_TARGET=$(readlink "$CLAUDE_PATH" 2>/dev/null || true)
  else
    LINK_TARGET=""
  fi

  if [[ -n "$LINK_TARGET" && ( "$LINK_TARGET" == *"/Applications/Claude.app"* || "$LINK_TARGET" == *"/Applications/Claude.app/Contents"* ) ]]; then
    echo "Found 'claude' at $CLAUDE_PATH pointing to the desktop app ($LINK_TARGET)."
    echo "This is the GUI bundle helper and not the CLI; attempting to use it will fail."
    if [[ $NON_INTERACTIVE -eq 1 ]]; then
      if [[ "$CLAUDE_FORCE_REPLACE" == "1" ]]; then
        echo "Removing GUI symlink $CLAUDE_PATH (CLAUDE_FORCE_REPLACE=1)."
        rm -f "$CLAUDE_PATH" 2>/dev/null || sudo rm -f "$CLAUDE_PATH" 2>/dev/null || true
      else
        echo "Non-interactive mode and CLAUDE_FORCE_REPLACE!=1 — refusing to remove GUI symlink." >&2
        exit 1
      fi
    else
      read -p "Remove the GUI symlink at $CLAUDE_PATH so the real CLI can be installed? [y/N] " resp || true
      case "$resp" in
        [yY]*) rm -f "$CLAUDE_PATH" 2>/dev/null || sudo rm -f "$CLAUDE_PATH" 2>/dev/null || true; echo "Removed $CLAUDE_PATH.";;
        *) echo "Leaving GUI symlink in place. Aborting."; exit 1;;
      esac
    fi
  fi

  echo "Claude Code found: $(claude --version 2>/dev/null || echo '(version unknown)')"
  exit 0
fi

echo "Claude Code CLI not found."

# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM=macOS
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
  PLATFORM="WSL ($WSL_DISTRO_NAME)"
else
  PLATFORM=Linux
fi

# Helper to check for success after an install attempt
_check_installed() {
  if command -v claude >/dev/null 2>&1; then
    echo "Claude Code is now installed: $(claude --version 2>/dev/null || echo '(version unknown)')"
    return 0
  fi
  return 1
}

# macOS: prefer Homebrew when available
if [[ "$PLATFORM" == "macOS" ]]; then
  if command -v brew >/dev/null 2>&1; then
    if [[ $NON_INTERACTIVE -eq 1 ]]; then
      echo "Attempting Homebrew install (non-interactive)..."
      if brew install claude || brew install --cask claude; then
        _check_installed && exit 0 || true
      else
        echo "Homebrew install failed or formula/cask not available."
      fi
    else
      read -p "Homebrew detected. Run 'brew install claude' now? [Y/n] " yn || true
      case "$yn" in
        [nN]*) echo "Skipping Homebrew install.";;
        *)
          echo "Running: brew install claude"
          if brew install claude; then
            _check_installed && exit 0 || true
          else
            echo "brew install claude failed; trying cask as fallback..."
            if brew install --cask claude; then
              _check_installed && exit 0 || true
            else
              echo "Both brew attempts failed."
            fi
          fi
        ;;
      esac
    fi
  else
    echo "Homebrew not found on this macOS system."
  fi

  # Offer official webpage and optional remote installer
  if [[ $NON_INTERACTIVE -eq 1 ]]; then
    echo "Non-interactive mode: will not open browser."
  else
    read -p "Open https://code.claude.com in your browser? [Y/n] " openyn || true
    case "$openyn" in
      [nN]*) echo "Skipping opening browser.";;
      *) open "https://code.claude.com" || true;;
    esac
  fi

  if [[ "$CLAUDE_ALLOW_REMOTE_INSTALL" == "1" ]]; then
    echo "Remote installer allowed by CLAUDE_ALLOW_REMOTE_INSTALL=1. Running official install script..."
    if curl -fsSL https://claude.ai/install.sh | bash; then
      _check_installed && exit 0 || true
    else
      echo "Remote installer failed." >&2
    fi
  else
    if [[ $NON_INTERACTIVE -eq 0 ]]; then
      echo "You can install via the official installer. Review before running:" 
      echo "  curl -sSL https://code.claude.com/install.sh | bash"
    else
      echo "To auto-run the remote installer set CLAUDE_ALLOW_REMOTE_INSTALL=1." 
    fi
  fi

  echo "If you installed claude just now, reload your shell (e.g. 'exec $SHELL') and re-run this script."
  _check_installed || exit 1
fi

# Non-macOS fallback: offer to open webpage or suggest installer
if [[ "$PLATFORM" != "macOS" ]]; then
  if [[ $NON_INTERACTIVE -eq 0 ]]; then
    read -p "Open https://code.claude.com in your browser? [Y/n] " openyn || true
    case "$openyn" in
      [nN]*) echo "Skipping opening browser.";;
      *)
        if command -v xdg-open >/dev/null 2>&1; then
          xdg-open "https://code.claude.com" || true
        else
          echo "Please open https://code.claude.com in your browser to install Claude Code CLI."
        fi
      ;;
    esac
  else
    echo "Non-interactive mode: please install Claude Code CLI from https://code.claude.com and set CLAUDE_AUTO_INSTALL=1 to attempt automated installs." 
  fi

  # Try remote installer only if explicitly allowed
  if [[ "$CLAUDE_ALLOW_REMOTE_INSTALL" == "1" ]]; then
    echo "Running remote installer (allowed by CLAUDE_ALLOW_REMOTE_INSTALL=1)..."
    if curl -fsSL https://claude.ai/install.sh | bash; then
      _check_installed && exit 0 || true
    else
      echo "Remote installer failed." >&2
    fi
  fi

  _check_installed || exit 1
fi
