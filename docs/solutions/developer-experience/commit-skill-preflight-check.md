---
title: "Commit Skill Pre-Flight Branch Sync Check"
date: 2026-01-20
category: developer-experience
tags:
  - commit-skill
  - version-management
  - pre-flight-check
  - branch-sync
  - plugin-updates
component: skills/workflow-commit
severity: high
problem_type: quality-gate-failure
symptoms:
  - Version regression when local branch behind origin/main
  - Stale local repo allows dangerous commits
  - Plugin and marketplace versions become desynchronized
  - Nearly caused 0.3.19 to 0.3.2 version regression
root_cause: |
  Two interconnected issues:
  1. Missing Step 0 pre-flight check for branch synchronization
  2. Version bump staged only plugin.json, not marketplace.json
related_issues:
  - "#52"
  - "#53"
  - "#58"
learnings:
  - Pre-flight checks prevent cascading failures
  - Version management requires complete file staging
  - Branch synchronization must be a hard gate not a warning
  - Scripts that update multiple files need coordinated staging
---

## Problem

The commit skill in the wdi plugin lacked a pre-flight check to verify the local branch is in sync with origin/main. This allowed committing from a stale local repo, which nearly caused version regression from 0.3.19 → 0.3.2.

### How It Was Discovered

During a routine commit, the version bump showed `0.3.1 → 0.3.2`. The user noticed this was wrong - the remote was at v0.3.19. Investigation revealed:

1. Local repo was **37 commits behind** origin/main
2. The commit skill proceeded without any warning
3. `bump-version.sh` bumped the stale local version
4. If pushed, this would have regressed the plugin version catastrophically

### Secondary Bug

The commit skill only staged `plugin.json` after version bumps, but `bump-version.sh` also updates `marketplace.json`. This caused version desync between the two files.

## Root Cause

**Primary:** No validation that local branch was current before allowing commits. The commit skill assumed the local branch was always in sync with remote.

**Secondary:** Incomplete staging after version bump. The skill's Step 6 said:
```bash
git add .claude-plugin/plugin.json  # Missing marketplace.json!
```

## Solution

### 1. Added Step 0: Pre-Flight Branch Sync Check

Added to `skills/workflow-commit/SKILL.md` as the very first step:

```markdown
## Step 0: Pre-flight - Branch Sync Check

**CRITICAL:** Before any work, verify local branch is in sync with remote.

```bash
git fetch origin
BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
```

**If behind (BEHIND > 0):**
```
⚠️  Local branch is behind origin/main
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your local branch is {BEHIND} commits behind origin/main.
Committing now could cause version regression or overwrite remote changes.

Action required:
  git pull origin main

Then re-run the commit.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**ABORT** - Do not proceed. This is a hard gate, not a warning.
```

### 2. Fixed Version Bump Staging

Updated Step 6 to stage both version files:

```bash
# Before
git add .claude-plugin/plugin.json

# After
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

### 3. Updated CLAUDE.md Documentation

Added sync requirement notice:

```markdown
> **SYNC REQUIRED:** The commit skill requires your local branch to be in sync
> with origin/main. If behind, it will abort and ask you to `git pull` first.
> This prevents version regression and accidentally overwriting remote commits.
```

## Prevention: 3-Layer Defense

### Layer 1: Pre-Flight Check (Primary)
- Commit skill Step 0 checks branch sync before any operations
- Hard abort if behind - not a warning that can be dismissed

### Layer 2: Pre-Commit Hook (Safety Net)
- Script at `scripts/pre-commit-version-check.sh`
- Catches direct `git commit` usage that bypasses the skill
- Install: `cp scripts/pre-commit-version-check.sh .git/hooks/pre-commit`

### Layer 3: CI/CD Enforcement (Catch-All)
- GitHub Action `.github/workflows/version-bump-check.yml`
- Fails build if version wasn't bumped
- Catches everything, even `--no-verify` bypasses

## Key Learnings

| Learning | Application |
|----------|-------------|
| Pre-flight checks are essential for dangerous operations | Added Step 0 before ANY commit operations |
| Multi-file consistency requires coordinated staging | Both version files must stage together |
| Hard gates vs warnings matter | Branch sync is a hard abort, not recoverable |
| Single commits behind can cause disaster | 37 commits behind nearly caused major regression |

## Files Changed

| File | Change |
|------|--------|
| `skills/workflow-commit/SKILL.md` | Added Step 0, fixed Step 6 staging |
| `CLAUDE.md` | Added sync requirement documentation |
| `.claude-plugin/marketplace.json` | Fixed version desync |

## Related Documentation

- [Plugin Version Caching](../integration-issues/plugin-version-caching.md) - Why version bumps matter
- [Plugin Update Cache Bug](../integration-issues/plugin-update-cache-bug.md) - The Claude Code bug that compounds this
- [Plugin Version Propagation](./plugin-version-propagation.md) - Defense-in-depth strategy

## Commit Reference

- **Fix:** `a10cf2b` - feat: Add pre-flight branch sync check to commit skill (#58)
- **Issue:** #58 - Enhancement: Add pre-flight branch sync check to commit skill
