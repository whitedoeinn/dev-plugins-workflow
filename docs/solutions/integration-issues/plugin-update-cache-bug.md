---
title: Plugin updates not propagating - cache doesn't invalidate on version change
category: integration-issues
severity: critical
component: wdi plugin update mechanism (check-deps.sh, install.sh)
symptoms:
  - plugin update command reports success but files are stale
  - New commands don't appear after update despite version change
  - Version in `claude plugin list` shows new version but functionality is old
  - Multiple Claude Code restarts required with inconsistent behavior
  - Maintainer mode incorrectly triggered in consuming projects
tags:
  - plugin-update
  - version-propagation
  - marketplace
  - cache-invalidation
  - check-deps
  - install
  - maintainer-mode
related_issues:
  - "#52"
  - "#53"
  - "anthropics/claude-code#19197"
date_solved: 2026-01-19
---

# Plugin Update Cache Bug

## Problem

Claude Code plugin updates weren't propagating to consuming projects. Version numbers would update but new commands/files wouldn't appear, even after restarts.

## Symptoms

1. `claude plugin update wdi@wdi-marketplace` reports success
2. `claude plugin list` shows new version number
3. But new commands (e.g., `/wdi:hello`) don't exist
4. Old code still runs despite version bump

## Root Causes

### Bug 1: `plugin update` Doesn't Re-Download Files

Claude Code's `plugin update` command updates version metadata in `installed_plugins.json` but **does not re-download** plugin files from the cache at `~/.claude/plugins/cache/`. The cached files persist even when the version changes.

**Filed as:** [anthropics/claude-code#19197](https://github.com/anthropics/claude-code/issues/19197)

### Bug 2: Maintainer Mode False Positive

`install.sh` triggered maintainer mode whenever ANY `.claude-plugin/plugin.json` existed in the current directory - not just in the actual plugin source repo. This caused:
- Wrong marketplace source (local directory instead of GitHub)
- Updates to stop working

### Bug 3: Committed `.claude/` Settings

Projects had `.claude/settings.json` committed to git, causing:
- Duplicate plugin entries
- Stale plugin references
- Cross-machine conflicts

## What Didn't Work

| Attempt | Result | Why It Failed |
|---------|--------|---------------|
| `claude plugin marketplace update` | Reported success | Doesn't refresh plugin file cache |
| `claude plugin update` | "Already at latest" | Only checks version, doesn't re-download |
| Uninstall then install | Cache persisted | Uninstall doesn't clear file cache |
| marketplace update + plugin update | Still stale | Update command is fundamentally broken |

## Working Solution

### The Fix: Nuke Cache Before Install

**File:** `scripts/check-deps.sh`

```bash
# Auto-update wdi plugin (skip in maintainer mode)
if [[ ! -f "$PWD/.claude-plugin/plugin.json" ]] || \
   [[ "$(jq -r '.name' "$PWD/.claude-plugin/plugin.json" 2>/dev/null)" != "wdi" ]]; then
  # Delete stale cache and reinstall (workaround for plugin update bug)
  rm -rf ~/.claude/plugins/cache/wdi-marketplace/ 2>/dev/null || true
  claude plugin marketplace update wdi-marketplace 2>/dev/null || true
  claude plugin install wdi@wdi-marketplace --scope project 2>/dev/null || true
fi
```

### Key Changes

1. **Delete cache directory** before any update attempt
2. **Use `install` not `update`** - install works when cache is cleared
3. **Stricter maintainer detection** - requires full source structure:
   - `.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json`
   - `commands/` directory
   - `skills/` directory

4. **Add `.claude/` to .gitignore** in all repos

### Two Restarts Required

This is a Claude Code limitation, not a bug in wdi:

1. **First restart:** SessionStart hook runs → clears cache → downloads new files
2. **Second restart:** Claude loads the newly downloaded plugin

Plugins are loaded into memory before hooks run, so the first session still has old code.

## Manual Recovery

If automatic updates fail:

```bash
# Nuclear reset
rm -rf ~/.claude/plugins/cache/wdi-marketplace/
rm -rf ~/.claude/plugins/marketplaces/wdi-marketplace/
claude plugin marketplace remove wdi-marketplace
claude plugin marketplace add https://github.com/whitedoeinn/dev-plugins-workflow
claude plugin install wdi@wdi-marketplace --scope project
# Restart Claude twice
```

## Prevention Strategies

### 1. CI Enforcement

GitHub Action (`.github/workflows/version-bump-check.yml`) fails if plugin files change without version bump:

```bash
# To fix CI failure:
./scripts/bump-version.sh patch
git add .claude-plugin/
git commit -m "chore: Bump version"
git push
```

### 2. Commit Skill

Always use the commit skill ("commit these changes") instead of raw `git commit`. It auto-bumps versions.

### 3. Pre-commit Hook (Optional)

```bash
cp scripts/pre-commit-version-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Verification Checklist

```bash
# 1. Check cached version
ls ~/.claude/plugins/cache/wdi-marketplace/wdi/

# 2. Check marketplace metadata
jq '.plugins[0].version' ~/.claude/plugins/marketplaces/wdi-marketplace/.claude-plugin/marketplace.json

# 3. Check plugin list
claude plugin list --json | jq '.[] | select(.id | contains("wdi")) | {id, version}'

# 4. Verify commands exist
# Run /wdi:hello (or any command) in Claude
```

## Future: Remove Workaround

Tracked in [#53](https://github.com/whitedoeinn/dev-plugins-workflow/issues/53). When Anthropic fixes `plugin update`, simplify to:

```bash
claude plugin update wdi@wdi-marketplace --scope project 2>/dev/null || true
```

## Related Documentation

- [Plugin Version Propagation](../developer-experience/plugin-version-propagation.md)
- [Troubleshooting](../../troubleshooting.md#plugin-updates-not-propagating-to-other-projects)
- [CLAUDE.md - Versioning Policy](../../../CLAUDE.md#versioning-policy)

## Key Learnings

1. **Claude Code's plugin cache is buggy** - `plugin update` doesn't work reliably
2. **Cache clearing is the only reliable method** - delete before install
3. **Two restarts are unavoidable** - plugins load before hooks run
4. **Defense in depth works** - commit skill + CI + pre-commit hook catches issues at multiple points
5. **Version bumps are critical** - Claude caches by version, not content
