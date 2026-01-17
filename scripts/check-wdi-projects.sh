#!/usr/bin/env bash
# Check wdi plugin status across all projects

GITHUB_DIR="${1:-/Users/davidroberts/github}"

echo "Scanning projects in ${GITHUB_DIR}"
echo ""
printf "%-35s %-15s %-15s %-10s\n" "PROJECT" "COMPOUND-ENG" "WDI" "CLAUDE.MD"
printf "%-35s %-15s %-15s %-10s\n" "-----------------------------------" "---------------" "---------------" "----------"

for dir in "$GITHUB_DIR"/*/; do
  [[ -d "$dir" ]] || continue
  
  name=$(basename "$dir")
  settings="$dir/.claude/settings.json"
  
  # Check compound-engineering
  if [[ -f "$settings" ]] && grep -q "compound-engineering" "$settings" 2>/dev/null; then
    ce="✓"
  else
    ce="✗"
  fi
  
  # Check wdi
  if [[ -f "$settings" ]] && grep -q "wdi@" "$settings" 2>/dev/null; then
    wdi="✓"
  else
    wdi="✗"
  fi
  
  # Check CLAUDE.md
  if [[ -f "$dir/CLAUDE.md" ]] || [[ -f "$dir/.claude/CLAUDE.md" ]]; then
    claude_md="✓"
  else
    claude_md="-"
  fi
  
  printf "%-35s %-15s %-15s %-10s\n" "$name" "$ce" "$wdi" "$claude_md"
done

echo ""
echo "Legend: ✓ = installed  ✗ = missing  - = optional (no CLAUDE.md)"
echo ""
echo "Projects needing wdi:"
for dir in "$GITHUB_DIR"/*/; do
  [[ -d "$dir" ]] || continue
  name=$(basename "$dir")
  settings="$dir/.claude/settings.json"
  
  # Only list if has compound-engineering but not wdi (active Claude projects)
  if [[ -f "$settings" ]] && grep -q "compound-engineering" "$settings" 2>/dev/null; then
    if ! grep -q "wdi@" "$settings" 2>/dev/null; then
      echo "  - $name"
    fi
  fi
done
