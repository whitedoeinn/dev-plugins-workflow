# Semantic Versioning for Plugin

**Status:** Planning
**Created:** 2026-01-12
**Issue:** TBD
**Branch:** feature/semver-versioning
**Milestone:** None

## Context

**Type:** Enhancement
**Complexity:** Moderate
**Target:** Repo-Level

## Problem

The plugin currently uses a content hash as its version (e.g., `5dabfc30e25e`) as a temporary workaround for dogfooding. This was implemented because:

1. `claude plugin update` only syncs when the version changes
2. For local development, we need changes to sync without manual uninstall/reinstall cycles
3. The hash changes automatically when any command, skill, or hook file changes

However, this approach has limitations:

- No semantic meaning (can't tell if changes are breaking, features, or fixes)
- Breaks compatibility with tools expecting semver format
- No changelog integration tied to version bumps
- Confusing for consumers who expect version numbers
- Can't communicate stability or maturity

## Done When

- [ ] Version follows semver format (MAJOR.MINOR.PATCH) (test: `jq '.version' .claude-plugin/plugin.json` matches pattern)
- [ ] Version bump script/command exists (test: `./scripts/bump-version.sh patch` increments patch)
- [ ] Pre-release versions supported (e.g., `1.0.0-beta.1`) (test: script handles pre-release tags)
- [ ] Sync script uses semver, not hash (test: `sync-plugin.sh` bumps patch, not hash)
- [ ] Changelog entries tied to version (test: version appears in changelog.md)
- [ ] Git tags created on version bumps (test: `git tag` shows version tags)

## Implementation Plan

1. Research Claude Code plugin versioning requirements (any constraints?)
2. Create `scripts/bump-version.sh` with major/minor/patch/prerelease options
3. Update `scripts/sync-plugin.sh` to bump patch version instead of using hash
4. Add pre-commit hook or CI check for version consistency
5. Document versioning policy in CLAUDE.md or dedicated doc
6. Migrate from current hash version to `1.0.0` (or appropriate starting version)

## Files

| File | Change |
|------|--------|
| `.claude-plugin/plugin.json` | Version field (source of truth) |
| `scripts/bump-version.sh` | New script for version management |
| `scripts/sync-plugin.sh` | Change from hash to patch bump |
| `docs/changelog.md` | Version headers for releases |
| `CLAUDE.md` | Document versioning policy |

## Dependencies

**Blocked by:**
- None

**Blocks:**
- Proper release process
- Consumer upgrade guidance
- Changelog automation

## Research Summary

- Claude Code's `plugin update` command compares version strings to detect changes
- Directory-based marketplaces copy files to cache on install/update
- Current hash approach: `find commands skills hooks -type f | xargs cat | shasum | cut -c1-12`

## Notes

**Current workaround:** `scripts/sync-plugin.sh` computes a content hash and uses it as the version. This triggers updates but loses semantic meaning.

**Decision needed:** What version to start at when implementing semver? Options:
- `1.0.0` - Indicates production-ready
- `0.1.0` - Indicates pre-release/unstable
- Continue current major version (`2.x.x` based on original `2.0.0`)

**Alternative considered:** Keep hash but append to semver (e.g., `2.0.0-5dabfc30e25e`). Rejected because it still requires manual semver bumps for meaningful releases.

---

*Created manually to track dogfooding enhancement*
