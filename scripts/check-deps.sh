#!/usr/bin/env bash
# Environment Checker for wdi plugin
# Runs on SessionStart to validate environment against baseline
#
# This script delegates to validate-env.sh for comprehensive validation
# with auto-remediation support.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATE_SCRIPT="${SCRIPT_DIR}/validate-env.sh"

# Run comprehensive environment validation
if [[ -x "$VALIDATE_SCRIPT" ]]; then
  "$VALIDATE_SCRIPT"
  EXIT_CODE=$?

  # Handle validation result
  case $EXIT_CODE in
    0)
      # Valid - nothing to report (output handled by validate-env.sh)
      ;;
    1)
      # Auto-fixed - output handled by validate-env.sh
      ;;
    2)
      # Blocked - output handled by validate-env.sh
      # For SessionStart hook, we show the message but don't block the shell
      # The user is informed and can choose to fix or continue at their own risk
      echo ""
      echo "WARNING: Your environment is out of sync. Workflows may not work correctly."
      echo ""
      ;;
  esac
else
  # Fallback: basic plugin check if validate-env.sh not available
  REQUIRED=("compound-engineering")
  MISSING=()

  for plugin in "${REQUIRED[@]}"; do
    if ! claude plugin list 2>/dev/null | grep -q "$plugin"; then
      MISSING+=("$plugin")
    fi
  done

  if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "Missing required plugins: ${MISSING[*]}"
    echo "   Run: ./install.sh (from wdi plugin directory)"
    echo "   Or:  curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash"
    echo ""
  fi
fi

# Check for deprecated wdi- repo prefix (light warning)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
if [[ "$REPO_NAME" == wdi-* ]]; then
  echo "Note: Repo '$REPO_NAME' uses deprecated wdi- prefix. See docs/standards/REPO-STANDARDS.md"
fi

# Clean up duplicate plugin entries in registry
# Source of truth is ~/.claude/plugins/installed_plugins.json
INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"

if [[ -f "$INSTALLED_PLUGINS" ]] && command -v jq &>/dev/null; then
  WDI_COUNT=$(jq -r '.plugins["wdi@wdi-marketplace"] | length' "$INSTALLED_PLUGINS" 2>/dev/null || echo "0")
  HAS_USER=$(jq -e '.plugins["wdi@wdi-marketplace"][] | select(.scope == "user")' "$INSTALLED_PLUGINS" &>/dev/null && echo "yes" || echo "no")
  HAS_PROJECT=$(jq -e '.plugins["wdi@wdi-marketplace"][] | select(.scope == "project")' "$INSTALLED_PLUGINS" &>/dev/null && echo "yes" || echo "no")

  NEEDS_CLEANUP="no"
  CLEANUP_REASON=""

  # Case 1: Both user and project scope (remove project scope)
  if [[ "$HAS_USER" == "yes" ]] && [[ "$HAS_PROJECT" == "yes" ]]; then
    NEEDS_CLEANUP="yes"
    CLEANUP_REASON="user + project scope"
  fi

  # Case 2: Multiple user-scope entries (keep most recent)
  if [[ "$WDI_COUNT" -gt 1 ]] && [[ "$HAS_PROJECT" != "yes" ]]; then
    NEEDS_CLEANUP="yes"
    CLEANUP_REASON="$WDI_COUNT duplicate user-scope entries"
  fi

  if [[ "$NEEDS_CLEANUP" == "yes" ]]; then
    echo "Cleaning wdi registry ($CLEANUP_REASON)..."
    # Keep only the most recent user-scope entry
    jq '
      .plugins["wdi@wdi-marketplace"] = [
        [.plugins["wdi@wdi-marketplace"][]? | select(.scope == "user")]
        | sort_by(.installedAt) | last // empty
      ] | map(select(. != null))
    ' "$INSTALLED_PLUGINS" > "${INSTALLED_PLUGINS}.tmp" && \
      mv "${INSTALLED_PLUGINS}.tmp" "$INSTALLED_PLUGINS"
    # Also remove any stale project settings.json
    rm -f "${PWD}/.claude/settings.json" 2>/dev/null || true
    echo "  Done. Restart Claude to load clean registry."
  fi
fi

# Auto-update wdi plugin (skip in maintainer mode)
if [[ ! -f "$PWD/.claude-plugin/plugin.json" ]] || \
   [[ "$(jq -r '.name' "$PWD/.claude-plugin/plugin.json" 2>/dev/null)" != "wdi" ]]; then
  # Update plugin to latest version
  claude plugin update wdi@wdi-marketplace 2>/dev/null || true
fi
