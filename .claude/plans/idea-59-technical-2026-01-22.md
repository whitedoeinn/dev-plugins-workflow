# Shaping: Use selective .gitignore patterns for .claude/ directory

**Issue:** #59
**Perspective:** technical
**Date:** 2026-01-22

## Original Idea

Currently the plugin source repo ignores the entire `.claude/` directory. The proposal is to change to selective ignoring based on Claude Code's official recommendations.

## Exploration

### Current State

The current `.gitignore` has:
```gitignore
.claude/

# Exception: Committed plan files for idea shaping
!.claude/plans/
!.claude/plans/idea-*.md
```

### BUG FOUND: Gitignore Exception Doesn't Work

**The negation patterns are not working.** When testing:
```bash
git add .claude/plans/idea-59-technical-2026-01-22.md
# Error: The following paths are ignored by one of your .gitignore files
```

**Root cause:** When you ignore a directory with trailing slash (`.claude/`), git ignores the entire directory and never evaluates negation patterns for contents.

**Fix:** Use `.claude/*` (ignore contents) instead of `.claude/` (ignore directory):

```gitignore
# Claude Code project-local settings (machine-specific)
.claude/*

# Exception: Committed plan files for idea shaping
!.claude/plans/
.claude/plans/*
!.claude/plans/idea-*.md
```

This pattern:
1. Ignores all contents of `.claude/` (but not the directory itself)
2. Un-ignores the `plans/` subdirectory
3. Ignores all contents of `plans/`
4. Un-ignores `idea-*.md` files specifically

### Claude Code Official Documentation

From [Claude Code settings docs](https://code.claude.com/docs/en/settings):

| File | Purpose | Git Status |
|------|---------|-----------|
| `.claude/settings.json` | Team-shared settings (permissions, hooks, MCP) | **Committed** |
| `.claude/settings.local.json` | Personal project-specific overrides | **Gitignored** |
| `.claude/agents/` | Custom subagents specific to the project | **Committed** |

## Cross-Cutting Implications

**→ UX:** Shape-idea workflow is currently broken; plan files cannot be committed
**→ Business:** No impact

## Decisions Made

1. **Fix the gitignore bug** - Current pattern silently fails; must be corrected
2. **Keep selective approach** - Only track `idea-*.md` for now (not settings.json or agents/)
3. **Use correct negation syntax** - `.claude/*` not `.claude/`

## Risks Identified

**Risk:** Commit `a37666e` introduced broken gitignore; all `idea-*.md` files since then are untracked
**Mitigation:** Fix gitignore, then commit existing plan files

## Scope

**In scope:**
- Fix `.gitignore` to use correct negation pattern
- Stage and commit any existing `idea-*.md` files

**Out of scope:**
- Committing `settings.json` or `agents/` (no current use case)

## Verification

After fix:
```bash
git add .claude/plans/idea-59-technical-2026-01-22.md
git status  # Should show file staged, not ignored
```
