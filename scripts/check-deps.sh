#!/usr/bin/env bash

# Dependency checker for claude-workflows plugin
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
  echo "Missing required plugins: ${MISSING[*]}"
  echo "Run: ./install.sh (from claude-workflows directory)"
  echo "Or:  curl -sSL https://raw.githubusercontent.com/whitedoeinn/claude-workflows/main/install.sh | bash"
  echo ""
fi
