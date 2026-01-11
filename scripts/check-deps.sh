#!/usr/bin/env bash

# Dependency checker for wdi-workflows plugin
# Runs on SessionStart to verify required plugins are installed

# Required plugins (add more as needed)
REQUIRED=("compound-engineering")

MISSING=()

for plugin in "${REQUIRED[@]}"; do
  if ! claude plugin list 2>/dev/null | grep -q "$plugin"; then
    MISSING+=("$plugin")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  Missing required plugins: ${MISSING[*]}"
  echo "   Run: ./install.sh (from wdi-workflows directory)"
  echo "   Or:  curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflows/main/install.sh | bash"
  echo ""
fi

# Check for deprecated wdi- repo prefix (light warning)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
if [[ "$REPO_NAME" == wdi-* ]]; then
  echo "Note: Repo '$REPO_NAME' uses deprecated wdi- prefix. See docs/standards/REPO-STANDARDS.md"
fi
