#!/bin/bash
# Detect documentation drift between source files and docs
# Output: DRIFT lines for skill to parse
# Exit code: 0 = no drift, 1 = drift found

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

DRIFT_FOUND=0

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse flags
VERBOSE=false
CHECK_ONLY=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v) VERBOSE=true; shift ;;
    --check) CHECK_ONLY=true; shift ;;
    *) shift ;;
  esac
done

log() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo -e "$1" >&2
  fi
}

# Check commands in commands/*.md against CLAUDE.md
log "${YELLOW}Checking commands...${NC}"
for cmd_file in commands/*.md; do
  [[ -f "$cmd_file" ]] || continue
  cmd_name=$(basename "$cmd_file" .md)

  # Check if in CLAUDE.md (look for the command in any format)
  if ! grep -q "/wdi-workflows:$cmd_name" CLAUDE.md 2>/dev/null; then
    echo "DRIFT:command:$cmd_name:missing_claude"
    log "  ${RED}MISSING${NC}: /wdi-workflows:$cmd_name not in CLAUDE.md"
    DRIFT_FOUND=1
  else
    log "  ${GREEN}OK${NC}: /wdi-workflows:$cmd_name"
  fi

  # Check if in README.md
  if ! grep -q "/wdi-workflows:$cmd_name" README.md 2>/dev/null; then
    echo "DRIFT:command:$cmd_name:missing_readme"
    log "  ${RED}MISSING${NC}: /wdi-workflows:$cmd_name not in README.md"
    DRIFT_FOUND=1
  fi
done

# Check skills in skills/*/SKILL.md against CLAUDE.md
log "${YELLOW}Checking skills...${NC}"
for skill_dir in skills/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  [[ -f "$skill_file" ]] || continue

  # Check if in CLAUDE.md skills table (look for skill name in backticks)
  if ! grep -q "| \`$skill_name\`" CLAUDE.md 2>/dev/null; then
    echo "DRIFT:skill:$skill_name:missing_claude"
    log "  ${RED}MISSING${NC}: skill '$skill_name' not in CLAUDE.md skills table"
    DRIFT_FOUND=1
  else
    log "  ${GREEN}OK${NC}: skill '$skill_name'"
  fi

  # Check if in README.md skills table
  if ! grep -q "| \`$skill_name\`" README.md 2>/dev/null; then
    echo "DRIFT:skill:$skill_name:missing_readme"
    log "  ${RED}MISSING${NC}: skill '$skill_name' not in README.md skills table"
    DRIFT_FOUND=1
  fi
done

# Check version sync between plugin.json and CLAUDE.md
log "${YELLOW}Checking version sync...${NC}"
if [[ -f .claude-plugin/plugin.json ]]; then
  plugin_version=$(jq -r '.version // empty' .claude-plugin/plugin.json)
  if [[ -n "$plugin_version" ]]; then
    # Look for "Current version: X.Y.Z" pattern in CLAUDE.md
    claude_version=$(grep -oE "Current version: [0-9]+\.[0-9]+\.[0-9]+" CLAUDE.md 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" || echo "")

    if [[ -n "$claude_version" && "$plugin_version" != "$claude_version" ]]; then
      echo "DRIFT:version:$plugin_version:claude_mismatch:$claude_version"
      log "  ${RED}MISMATCH${NC}: plugin.json=$plugin_version, CLAUDE.md=$claude_version"
      DRIFT_FOUND=1
    else
      log "  ${GREEN}OK${NC}: version $plugin_version"
    fi
  fi
fi

# Summary
if [[ "$DRIFT_FOUND" -eq 0 ]]; then
  log "${GREEN}No documentation drift detected.${NC}"
else
  log "${YELLOW}Documentation drift detected. Run auto-update-docs skill to fix.${NC}"
fi

exit $DRIFT_FOUND
