# Plugin Updates Not Propagating Due to Version Caching

---
title: "Claude Code plugin updates not propagating to consuming projects"
category: integration-issues
tags:
  - claude-code
  - plugin-system
  - caching
  - version-management
  - deployment
severity: medium
symptoms:
  - Plugin changes pushed to GitHub not appearing in consuming projects
  - "already at latest version" message despite content changes
  - SessionStart hook cache clearing has no effect
  - Consuming projects stuck on old plugin behavior
component: plugin-update-mechanism
root_cause: "Claude Code plugin system caches by version number, not content hash"
solution: "Mandatory version bumping (at least patch) on every commit"
related_issues:
  - "#52"
  - "#43"
related_docs:
  - "docs/solutions/developer-experience/plugin-version-auto-update.md"
  - "docs/troubleshooting.md"
  - "docs/standards/PLUGIN-ARCHITECTURE.md"
---

## Problem

Plugin updates made in the source repository were not propagating to consuming projects. Even after pushing changes to GitHub, projects using the plugin would not see the new code.

### Symptoms

- Push changes to plugin repo → no effect in consuming projects
- `claude plugin update` reports "already at latest version"
- Restart Claude multiple times → still old behavior
- Cache clearing in hooks has no effect

## What We Tried (Failed Attempts)

### Attempt 1: Cache Clearing in SessionStart Hook

**Approach:** Clear the plugin cache directory before loading:
```bash
rm -rf ~/.claude/plugins/cache/wdi-marketplace/wdi/* 2>/dev/null || true
claude plugin install wdi@wdi-marketplace --scope project
```

**Why it failed:** Plugins are loaded **before** hooks run. By the time the SessionStart hook executes, the old plugin version is already loaded into memory. Clearing the cache only affects the *next* session.

### Attempt 2: Content-Based Caching (Remove Version Field)

**Hypothesis:** Documentation suggested version field is optional and caching is "content-based."

**Approach:** Remove the `version` field from `plugin.json`, hoping Claude Code would detect content changes.

**Test results:**
1. Removed version field, pushed changes
2. `claude plugin update` reported "already at latest version (0.2.1)"
3. Content changes were not detected

**Why it failed:** Claude Code uses the `version` field as the cache key. Without a version, it uses some fallback mechanism that doesn't check content hashes. There is no content-based cache invalidation.

## Root Cause

**Claude Code's plugin system caches by version number, not content hash.**

The plugin update mechanism:
1. Compares local cached version with remote version field
2. If versions match → "already at latest version"
3. Content changes are never checked

Without incrementing the version, Claude Code will never fetch updates regardless of what changed on GitHub.

## Solution: Mandatory Version Bumping

Every commit must bump the version. The commit skill now auto-bumps patch for all commits.

### Changes Made

#### 1. Restored Version Field in plugin.json

```json
{
  "name": "wdi",
  "version": "0.3.6",
  ...
}
```

#### 2. Updated Commit Skill to Always Bump

**File:** `skills/workflow-commit/SKILL.md`

| Signal | Action |
|--------|--------|
| Message starts with `feat:` | Prompt (minor or patch) |
| Message body contains `BREAKING CHANGE:` | Prompt (major or minor) |
| All other commits | Auto-bump patch |

Every single commit bumps at least patch version.

#### 3. Simplified Auto-Update Hook

**File:** `scripts/check-deps.sh`

```bash
# Auto-update wdi plugin (skip in maintainer mode)
if [[ ! -f "$PWD/.claude-plugin/plugin.json" ]] || \
   [[ "$(jq -r '.name' "$PWD/.claude-plugin/plugin.json" 2>/dev/null)" != "wdi" ]]; then
  claude plugin update wdi@wdi-marketplace --scope project 2>/dev/null || true
fi
```

No cache clearing needed - version bumps handle update detection.

## Update Flow (Consuming Projects)

```
┌─────────────────────────────────────────────────────────────────┐
│                    PLUGIN REPOSITORY                             │
├─────────────────────────────────────────────────────────────────┤
│  1. Make changes                                                │
│  2. Commit (skill auto-bumps version: 0.3.5 → 0.3.6)           │
│  3. Push to GitHub                                              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CONSUMING PROJECT                             │
├─────────────────────────────────────────────────────────────────┤
│  4. Restart Claude (Restart #1)                                 │
│     └─► SessionStart hook runs `claude plugin update`           │
│         └─► Downloads new version to cache                      │
│             (current session still has old version loaded)      │
│                                                                 │
│  5. Restart Claude (Restart #2)                                 │
│     └─► Loads newly cached version                              │
│     └─► New code is active!                                     │
└─────────────────────────────────────────────────────────────────┘
```

**Two restarts required because plugins load before hooks run.**

## Key Learnings

1. **Plugins load before hooks** - SessionStart hooks cannot update the currently-loaded plugin
2. **Version field is required** - Despite docs suggesting it's optional, Claude uses it for update detection
3. **Content hashing doesn't exist** - There's no content-based cache invalidation
4. **Two restarts required** - First downloads update, second loads it
5. **Always use commit skill** - It handles version bumping automatically

## Prevention

- **Always use the commit skill** for plugin changes
- The skill auto-bumps version on every commit
- Never bypass with raw `git commit` in plugin repos

## Troubleshooting Checklist

If updates aren't propagating:

1. Check version was bumped: `jq '.version' .claude-plugin/plugin.json`
2. Verify push succeeded: `git log origin/main -1`
3. In consuming project, run: `claude plugin update wdi@wdi-marketplace --scope project`
4. Check downloaded version: `ls ~/.claude/plugins/cache/wdi-marketplace/wdi/`
5. Restart Claude twice

## Related

- Issue #52: Documents this investigation
- Issue #43: Original auto-update implementation
- `docs/solutions/developer-experience/plugin-version-auto-update.md`: Auto-update design
- `docs/troubleshooting.md`: Cache clearing instructions
