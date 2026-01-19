---
title: Auto-Update wdi Plugin on Session Start
date: 2026-01-18
category: developer-experience
tags:
  - auto-update
  - session-start
  - maintainer-mode
  - plugin-management
component: scripts/check-deps.sh
severity: low
problem_type: developer-experience
symptoms:
  - Manual updates required
  - Version drift from latest plugin
  - Users running outdated versions unknowingly
root_cause: No automatic mechanism to keep installed plugin current
solution_approach: Inline auto-update in check-deps.sh SessionStart hook
files_modified:
  - scripts/check-deps.sh
  - CLAUDE.md
related_issues:
  - "#43"
learnings:
  - Question assumptions early (throttling not needed for single-dev workflow)
  - Inline over extract for single-use logic
  - Match existing patterns in the codebase
---

# Auto-Update wdi Plugin on Session Start

## Problem

Projects using the wdi plugin could drift from the latest version. Users would miss bug fixes, new features, and improvements because there was no automatic mechanism to keep the installed plugin current. Manual `./install.sh update` was required.

## Solution

Add 4 lines to `scripts/check-deps.sh` to auto-update the wdi plugin on every session start, except when in maintainer mode:

```bash
# Auto-update wdi plugin (skip in maintainer mode)
if [[ ! -f "$PWD/.claude-plugin/plugin.json" ]] || \
   [[ "$(jq -r '.name' "$PWD/.claude-plugin/plugin.json" 2>/dev/null)" != "wdi" ]]; then
  claude plugin update wdi@wdi-marketplace --scope project 2>/dev/null || true
fi
```

**Result:** Push plugin changes → restart session in any project → automatically get latest version.

## Key Decision: No Throttling

### Initial Assumption

Researched common throttling patterns:
- **Homebrew**: 24-hour interval (`HOMEBREW_AUTO_UPDATE_SECS`)
- **npm update-notifier**: Configurable intervals with timestamp file
- **GitHub CLI**: Daily check for extension updates

### User Insight

> "Why would we throttle it?"

For a single-developer active development workflow where you want immediate updates when restarting a session, throttling creates friction. If you push plugin changes and restart a session, you expect the new version.

### Final Decision

Run unconditionally on every session start. The `claude plugin update` command is:
- **Fast** when already current (sub-second)
- **Idempotent** (safe to run repeatedly)
- **Silent** on no-op (no output if nothing to update)

## Key Decision: Inline Over Extract

### Initial Implementation

Created a separate `scripts/check-update.sh` file with 27 lines:
- `is_maintainer_mode()` function
- `main()` function wrapper
- Proper bash structure with comments

### Simplicity Review Finding

A code-simplicity-reviewer flagged this as over-engineering:

> "The entire logic is ~5 lines of actual work. Creating a separate file adds: file existence check, executable check, subprocess overhead."

### Pattern Match

Examined how `install.sh` handles the same maintainer mode detection (lines 11-41): **inline, not in a separate file**.

### Final Decision

Inline the logic into `check-deps.sh`. Same functionality, 85% less code (4 lines vs 27 lines).

## Implementation Details

### Maintainer Mode Detection

The condition skips the update when:
1. A `.claude-plugin/plugin.json` file exists in the current directory, AND
2. The plugin name in that file is "wdi"

This prevents update loops when maintainers are working on the plugin source itself (where live edits should take precedence).

### Silent Failure

The `2>/dev/null || true` suffix ensures:
- No error output if update fails (network issues, etc.)
- The hook never blocks session start
- Graceful degradation when offline

### Explicit Qualification

Uses `wdi@wdi-marketplace` (not just `wdi`) to avoid ambiguity if multiple sources exist, matching the pattern in `install.sh`.

## Investigation Timeline

| Step | Action | Outcome |
|------|--------|---------|
| 1 | Research throttling patterns | Found Homebrew (24h) and npm approaches |
| 2 | Consider GitHub releases API | Possible but adds complexity for version checking |
| 3 | User questions throttling need | Realized single-dev workflow doesn't need it |
| 4 | Create separate check-update.sh | Working but 27 lines for 4 lines of work |
| 5 | Code-simplicity-reviewer flags it | Recommended inlining |
| 6 | Validate against #43 patterns | install.sh uses inline detection |
| 7 | Inline to 4 lines | Final solution, matches existing pattern |

## Prevention

For future auto-update implementations:

1. **Start without throttling** - Add complexity only when proven necessary
2. **Detect maintainer mode** - Prevent update loops in source directories
3. **Fail silently** - Never block user workflow for update failures
4. **Match existing patterns** - Reuse commands and approaches from install scripts
5. **Inline single-use logic** - Don't create files/functions for code called once

## Learnings

1. **Question assumptions early.** The "need" for throttling came from enterprise software patterns that don't apply to single-developer active development.

2. **Inline over extract for single-use logic.** The #43 pattern of reading `plugin.json` for context detection works best when kept close to its caller.

3. **Review agents catch what you miss.** Initial implementation "felt right" with separate concerns. The simplicity reviewer correctly identified it violated YAGNI.

4. **Consistent patterns within a codebase.** Looking at how `install.sh` solved the same problem (inline) guided the refactor.

## Related Documentation

- [Installer Auto-Detection](./installer-auto-detection.md) - Established the maintainer mode pattern
- [Marketplace Naming Conflict](./marketplace-naming-conflict.md) - Related installation edge case
