# Semantic Versioning for Plugin

**Status:** Complete
**Created:** 2026-01-12
**Issue:** #3
**Branch:** feature/semver-versioning
**Milestone:** None

## Context

**Type:** New Feature
**Complexity:** Moderate
**Target:** Repo-Level

## Problem

The plugin currently uses a content hash as its version (e.g., `5dabfc30e25e`) as a temporary workaround for dogfooding. This was implemented because:

1. `claude plugin update` only syncs when the version changes
2. For local development, we need changes to sync without manual uninstall/reinstall cycles
3. The hash changes automatically when any command, skill, or hook file changes

However, this approach has limitations:

- **Invalid semver** - Claude Code requires valid MAJOR.MINOR.PATCH format if version is provided
- No semantic meaning (can't tell if changes are breaking, features, or fixes)
- Version inconsistency across files (plugin.json has hash, marketplace.json has 1.0.0, CLAUDE.md claims 1.1.0)
- No changelog integration tied to version bumps

## Research Findings

**Claude Code Requirements:**
- Version field is optional, but if provided must be valid semver
- Pre-release suffixes supported (`0.1.0-beta.1`)
- Official Anthropic plugins omit version entirely

**Historical Context:**
- Plugin previously used proper semver: `1.0.0` → `1.1.0` → `2.0.0`
- Hash was added as "temporary workaround" for dogfooding

**Best Practices for CD:**
- Use Conventional Commits (`feat:`, `fix:`, `docs:`)
- Auto-bump based on commit type
- Git tag on each release

## Decision: Start at `0.1.0`

Per semver spec, `0.x.x` is for initial development where breaking changes are expected. This allows:
- Breaking changes to bump minor (0.1.0 → 0.2.0) without inflating version
- `1.0.0` to be a deliberate declaration of production-readiness
- Heavy development without ending up at `26.19.4` before first real release

## Done When

- [x] Version follows semver format starting at `0.1.0`
- [x] Version bump script exists (`./scripts/bump-version.sh patch|minor|major`)
- [x] Sync script removed (commit skill handles versioning)
- [x] All version references synced (plugin.json, marketplace.json, CLAUDE.md)
- [x] Git tags created on version bumps (via commit skill Step 10.5)
- [x] Versioning policy documented (CLAUDE.md)

## Implementation (Completed)

1. Created `scripts/bump-version.sh` with major/minor/patch options
2. Deleted `scripts/sync-plugin.sh` (replaced by commit skill)
3. Set initial version to `0.1.0` in plugin.json
4. Synced marketplace.json and CLAUDE.md versions
5. Added Step 6.5 (version bump) and Step 10.5 (git tag) to commit skill
6. Documented versioning policy in CLAUDE.md
7. Updated CONTRIBUTING.md with new workflow

## Files Changed

| File | Change |
|------|--------|
| `.claude-plugin/plugin.json` | Version `0.1.0` (source of truth) |
| `.claude-plugin/marketplace.json` | Synced version |
| `scripts/bump-version.sh` | Created - version bump script |
| `scripts/sync-plugin.sh` | Deleted - replaced by commit skill |
| `skills/workflow-commit/SKILL.md` | Added version bump and git tag steps |
| `CLAUDE.md` | Updated version, documented policy |
| `CONTRIBUTING.md` | Updated push workflow |

## Dependencies

**Blocked by:**
- None

**Blocks:**
- Proper release process
- Consumer upgrade guidance

## Notes

**Versioning policy for 0.x.x:**
- `0.x.0` (minor) - New features OR breaking changes
- `0.x.y` (patch) - Bug fixes, documentation, internal changes
- `1.0.0` - First production-ready release for use in other projects

---

*Created by `/wdi:feature`*
