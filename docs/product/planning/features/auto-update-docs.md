# Auto-Update Docs Skill

**Status:** Complete
**Created:** 2026-01-11
**Issue:** #1
**Branch:** feature/auto-update-docs
**Milestone:** None

## Context

**Type:** New Feature
**Complexity:** Moderate
**Target:** Repo-Level

## Problem

When new commands, skills, scripts, or directories are added to the plugin, documentation quickly becomes stale. Currently, developers must manually remember to update CLAUDE.md, README.md, install.sh, and docs/architecture.md. This leads to:

- Undocumented commands that users don't know exist
- Stale structure trees that mislead developers
- Version mismatches between plugin.json and README
- PRs merged with incomplete documentation updates

The gap was identified when the `wdi` CLI was added - no skill existed to prompt documentation updates, so CLAUDE.md had to be manually updated after the fact.

## Done When

- [x] Skill triggers on "update the docs", "sync documentation", "update CLAUDE.md"
- [x] Detects undocumented commands in commands/*.md
- [x] Detects undocumented skills in skills/*/SKILL.md
- [ ] Detects directory structure changes vs CLAUDE.md tree (deferred - manual for now)
- [x] Updates CLAUDE.md commands/skills tables
- [x] Updates README.md commands/skills tables
- [ ] Updates install.sh --show-commands output (deferred - requires heredoc editing)
- [x] Supports --check flag
- [x] Supports --all flag
- [x] Idempotent - running twice produces same result

## Implementation (Completed)

1. Created `scripts/check-docs-drift.sh` - drift detection script
   - Compares commands/*.md against CLAUDE.md and README.md
   - Compares skills/*/SKILL.md against CLAUDE.md and README.md
   - Checks version sync between plugin.json and CLAUDE.md
   - Outputs machine-readable DRIFT lines for skill to parse
   - Supports `--verbose` for detailed output

2. Created `skills/workflow-auto-docs/SKILL.md`
   - Triggers on "update the docs", "sync documentation", etc.
   - Supports `--check` (dry run) and `--all` (no prompts) flags
   - Step-by-step workflow for detecting and fixing drift
   - Uses Edit tool to update documentation tables

3. Updated CLAUDE.md and README.md with new skill

## Files Changed

| File | Change |
|------|--------|
| `skills/workflow-auto-docs/SKILL.md` | Created - skill definition with workflow |
| `scripts/check-docs-drift.sh` | Created - drift detection helper script |
| `CLAUDE.md` | Added skill to Skills table and directory tree |
| `README.md` | Added skill to Skills table |

## Dependencies

**Blocked by:**
- None

**Blocks:**
- Future automation of documentation workflows

## Notes

**What's included:**
- Command drift detection (commands/*.md vs CLAUDE.md/README.md tables)
- Skill drift detection (skills/*/SKILL.md vs CLAUDE.md/README.md tables)
- Version sync detection (plugin.json vs CLAUDE.md)

**What's deferred:**
- Directory tree drift detection (complex parsing, manual updates work fine)
- install.sh updates (heredoc editing is fragile, manual is safer)
- PreToolUse warning hook (not needed - skill is easy to invoke)

**Design decisions:**
- Skill (auto-invoked) preferred over command (explicit) because doc updates should be frictionless
- Detection script separate from SKILL.md for reusability and testability
- Simple grep-based detection rather than complex parsing

---

*Created by `/wdi:feature`*
