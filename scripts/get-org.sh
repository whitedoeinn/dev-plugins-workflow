#!/usr/bin/env bash
# get-org.sh - Detect GitHub organization/user for WDI plugin
#
# Priority:
#   1. .wdi.json config file (explicit override)
#   2. Git remote URL (auto-detect from origin)
#   3. WDI_ORG environment variable
#   4. Empty string (caller handles - typically prompts user)
#
# Usage:
#   ORG=$(./scripts/get-org.sh)
#   ORG=$(./scripts/get-org.sh --require)     # Exits 1 if not found
#   ORGS=$(./scripts/get-org.sh --list)       # List user's orgs + personal namespace
#   USER=$(./scripts/get-org.sh --user)       # Get authenticated username only
#
# Exit codes:
#   0 = Success
#   1 = No org found (with --require flag)

set -euo pipefail

# Parse git remote URL for org/user
parse_git_remote() {
  local remote_url
  remote_url=$(git config --get remote.origin.url 2>/dev/null || echo "")

  if [[ -z "$remote_url" ]]; then
    return 1
  fi

  # Handle various URL formats:
  # git@github.com:org/repo.git
  # https://github.com/org/repo.git
  # https://github.com/org/repo
  # ssh://git@github.com/org/repo.git

  local org=""

  if [[ "$remote_url" =~ git@github\.com:([^/]+)/ ]]; then
    org="${BASH_REMATCH[1]}"
  elif [[ "$remote_url" =~ github\.com/([^/]+)/ ]]; then
    org="${BASH_REMATCH[1]}"
  elif [[ "$remote_url" =~ git@([^:]+):([^/]+)/ ]]; then
    # Generic Git SSH: git@host:org/repo
    org="${BASH_REMATCH[2]}"
  fi

  # Remove .git suffix if present in org (shouldn't happen but be safe)
  org="${org%.git}"

  echo "$org"
}

# Get authenticated GitHub username
get_github_user() {
  if ! command -v gh &>/dev/null; then
    return 1
  fi

  gh api user --jq '.login' 2>/dev/null || return 1
}

# List user's organizations
list_user_orgs() {
  if ! command -v gh &>/dev/null; then
    return 1
  fi

  gh api user/orgs --jq '.[].login' 2>/dev/null || return 1
}

# List all available namespaces (personal + orgs)
list_namespaces() {
  local username
  username=$(get_github_user) || return 1

  # Output personal namespace first (marked with *)
  echo "${username} (personal)"

  # Output orgs
  local orgs
  orgs=$(list_user_orgs 2>/dev/null || echo "")

  if [[ -n "$orgs" ]]; then
    echo "$orgs"
  fi
}

# Main detection logic
detect_org() {
  local org=""

  # 1. Check .wdi.json config file (project root first, then home)
  if [[ -f ".wdi.json" ]] && command -v jq &>/dev/null; then
    org=$(jq -r '.org // empty' .wdi.json 2>/dev/null || echo "")
  fi

  if [[ -z "$org" ]] && [[ -f "$HOME/.wdi.json" ]] && command -v jq &>/dev/null; then
    org=$(jq -r '.org // empty' "$HOME/.wdi.json" 2>/dev/null || echo "")
  fi

  # 2. Parse git remote
  if [[ -z "$org" ]]; then
    org=$(parse_git_remote 2>/dev/null || echo "")
  fi

  # 3. Check environment variable
  if [[ -z "$org" ]]; then
    org="${WDI_ORG:-}"
  fi

  echo "$org"
}

# Main
main() {
  local require=false
  local list=false
  local user_only=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --require)
        require=true
        shift
        ;;
      --list)
        list=true
        shift
        ;;
      --user)
        user_only=true
        shift
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  done

  # Handle --user flag
  if [[ "$user_only" == true ]]; then
    get_github_user
    exit $?
  fi

  # Handle --list flag
  if [[ "$list" == true ]]; then
    list_namespaces
    exit $?
  fi

  # Default: detect org
  local org
  org=$(detect_org)

  if [[ -z "$org" ]] && [[ "$require" == true ]]; then
    echo "Error: Could not detect organization" >&2
    echo "Set WDI_ORG environment variable or create .wdi.json with {\"org\": \"your-org\"}" >&2
    exit 1
  fi

  echo "$org"
}

main "$@"
