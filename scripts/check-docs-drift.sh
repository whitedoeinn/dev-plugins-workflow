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

# Check for stale file references in documentation
log "${YELLOW}Checking for stale file references...${NC}"

# Files/patterns to exclude from stale reference checks:
# - changelog.md: describes historical changes
# - CONTRIBUTING.md: contains examples
# - docs/context/: session context files may reference external projects
# - Example patterns like my-command.md, example-*.md
is_excluded_ref() {
  local source_file="$1"
  local ref_file="$2"

  # Exclude changelog (historical references)
  [[ "$source_file" == *"changelog.md" ]] && return 0

  # Exclude CONTRIBUTING (examples)
  [[ "$source_file" == *"CONTRIBUTING.md" ]] && return 0

  # Exclude context docs (may reference external projects)
  [[ "$source_file" == *"docs/context/"* ]] && return 0

  # Exclude obvious example patterns
  [[ "$ref_file" == *"my-command"* ]] && return 0
  [[ "$ref_file" == *"example-"* ]] && return 0

  return 1
}

# Find all references to commands/*.md files and verify they exist
while IFS= read -r line; do
  # Extract file path and source file
  ref_file=$(echo "$line" | grep -oE 'commands/[a-zA-Z0-9_-]+\.md' | head -1)
  source_file=$(echo "$line" | cut -d: -f1)

  # Skip if excluded
  is_excluded_ref "$source_file" "$ref_file" && continue

  if [[ -n "$ref_file" && ! -f "$ref_file" ]]; then
    echo "DRIFT:stale_ref:$ref_file:$source_file"
    log "  ${RED}STALE${NC}: $ref_file referenced in $source_file (file not found)"
    DRIFT_FOUND=1
  fi
done < <(grep -rn 'commands/[a-zA-Z0-9_-]*\.md' --include="*.md" --include="*.sh" 2>/dev/null | grep -v "^Binary" || true)

# Find all references to skills/*/SKILL.md files and verify they exist
while IFS= read -r line; do
  ref_file=$(echo "$line" | grep -oE 'skills/[a-zA-Z0-9_-]+/SKILL\.md' | head -1)
  source_file=$(echo "$line" | cut -d: -f1)

  # Skip if excluded
  is_excluded_ref "$source_file" "$ref_file" && continue

  if [[ -n "$ref_file" && ! -f "$ref_file" ]]; then
    echo "DRIFT:stale_ref:$ref_file:$source_file"
    log "  ${RED}STALE${NC}: $ref_file referenced in $source_file (file not found)"
    DRIFT_FOUND=1
  fi
done < <(grep -rn 'skills/[a-zA-Z0-9_-]*/SKILL\.md' --include="*.md" --include="*.sh" 2>/dev/null | grep -v "^Binary" || true)

# Summary
if [[ "$DRIFT_FOUND" -eq 0 ]]; then
  log "${GREEN}No documentation drift detected.${NC}"
else
  log "${YELLOW}Documentation drift detected. Run auto-update-docs skill to fix.${NC}"
fi

exit $DRIFT_FOUND
