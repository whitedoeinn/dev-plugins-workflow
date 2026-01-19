---
title: Plugin Version Propagation Prevention Strategies
date: 2026-01-19
category: developer-experience
tags:
  - version-bump
  - plugin-updates
  - pre-commit
  - commit-skill
  - prevention
component: skills/workflow-commit
severity: medium
problem_type: developer-experience
symptoms:
  - Plugin updates not reaching consuming projects
  - Changes deployed but not visible in other projects
  - Version number unchanged after commits
  - "I pushed changes but nothing happened"
root_cause: Commits made without version bump - Claude Code caches plugins by version
solution_approach: Multiple layers of defense with commit skill as primary, pre-commit hook as safety net
files_modified:
  - docs/solutions/developer-experience/plugin-version-propagation.md
  - scripts/pre-commit-version-check.sh
related_issues:
  - "#43"
learnings:
  - Defense in depth prevents human error
  - Commit skill is enforced by convention, not tooling
  - Pre-commit hooks catch bypass scenarios
---

# Plugin Version Propagation Prevention Strategies

## Problem Statement

**Symptom:** Plugin updates not propagating to consuming projects.

**Root Cause:** Claude Code caches plugins by version. Without a version bump, the auto-update mechanism (`claude plugin update`) sees no change and skips the update.

**Solution Implemented:** The commit skill now always bumps the version (Step 6). But what happens when developers bypass the skill?

---

## Defense Layers

### Layer 1: Commit Skill (Primary)

The `workflow-commit` skill (Step 6) handles version bumps automatically:

| Commit Type | Action |
|-------------|--------|
| `feat:` commits | Prompt for minor or patch |
| `BREAKING CHANGE:` | Prompt for major or minor |
| All other commits | Auto-bump patch |

**Key principle:** Every commit bumps the version. No exceptions.

**Why it works:**
- Integrated into natural workflow ("commit these changes")
- Auto-detects plugin repos via `.claude-plugin/plugin.json`
- Creates git tag automatically (Step 10)
- Updates changelog with version reference

### Layer 2: Pre-Commit Hook (Safety Net)

For when developers bypass the commit skill (direct `git commit`), add a pre-commit hook:

```bash
#!/bin/bash
# .git/hooks/pre-commit
# Ensures version is bumped for plugin repos

PLUGIN_JSON=".claude-plugin/plugin.json"

# Skip if not a plugin repo
[ ! -f "$PLUGIN_JSON" ] && exit 0

# Get staged files (excluding the plugin.json itself to avoid circular check)
STAGED=$(git diff --cached --name-only | grep -v "^.claude-plugin/plugin.json$")

# If there are staged changes but plugin.json isn't staged, warn
if [ -n "$STAGED" ] && ! git diff --cached --name-only | grep -q "^.claude-plugin/plugin.json$"; then
  echo ""
  echo "WARNING: Committing without version bump!"
  echo ""
  echo "Plugin updates won't propagate to consuming projects."
  echo ""
  echo "Options:"
  echo "  1. Use the commit skill: say 'commit these changes'"
  echo "  2. Bump manually: ./scripts/bump-version.sh patch"
  echo "  3. Bypass (not recommended): git commit --no-verify"
  echo ""
  exit 1
fi
```

**Installation:**
```bash
cp scripts/pre-commit-version-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Layer 3: Documentation Reminders

Add reminders in key locations:

**CLAUDE.md** (already present):
> **IMPORTANT:** Always use the commit skill instead of running `git commit` directly.

**CONTRIBUTING.md** (if exists):
> All commits to this plugin repository must use the commit skill to ensure version bumps.

**PR Template** (if using):
- [ ] Version bumped (auto if using commit skill)

---

## Troubleshooting Checklist

When plugin updates aren't propagating:

### 1. Verify Version Was Bumped

```bash
# Check if version changed in last commit
git show --name-only HEAD | grep "plugin.json"

# View version history
git log --oneline -10 -- .claude-plugin/plugin.json
```

### 2. Check Git Tag Exists

```bash
# List recent tags
git tag --sort=-creatordate | head -5

# Verify tag points to HEAD
git describe --tags --exact-match HEAD
```

### 3. Verify Tag Was Pushed

```bash
# Check if tag exists on remote
git ls-remote --tags origin | grep "$(jq -r '.version' .claude-plugin/plugin.json)"
```

### 4. Clear Consumer Cache

In the consuming project:
```bash
# Clear plugin cache
rm -rf ~/.claude/plugins/cache/wdi*

# Force reinstall
claude plugin install wdi@wdi-marketplace --scope project --force

# Restart Claude Code
```

### 5. Verify Marketplace Is Updated

```bash
# Check marketplace knows about new version
# (Implementation depends on marketplace setup)
```

---

## Best Practices for Plugin Development

### Do

1. **Always use the commit skill** - Say "commit these changes" instead of `git commit`
2. **Verify the tag after commit** - Check `git describe --tags` shows new version
3. **Test in consuming project** - After push, verify auto-update works
4. **Use semantic versioning** - patch for fixes, minor for features, major for breaking

### Don't

1. **Don't use `git commit` directly** - Bypasses version bump
2. **Don't use `--no-verify`** - Bypasses safety hooks
3. **Don't manually edit version** - Let the skill handle it for consistency
4. **Don't forget to push tags** - `git push origin v0.x.x` (skill does this automatically)

---

## Handling Bypass Scenarios

### Scenario: Developer Used `git commit` Directly

**Detection:** Version unchanged, no new tag.

**Recovery:**
```bash
# Bump version now
./scripts/bump-version.sh patch

# Amend the last commit
git add .claude-plugin/plugin.json
git commit --amend --no-edit

# Create and push tag
VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
git tag "v$VERSION"
git push --force  # Only if not pushed yet
git push origin "v$VERSION"
```

### Scenario: Tag Exists Locally But Not Pushed

**Detection:** `git tag` shows version, but `git ls-remote --tags` doesn't.

**Recovery:**
```bash
VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
git push origin "v$VERSION"
```

### Scenario: Marketplace Not Picking Up New Version

**Detection:** Version bumped and pushed, but consuming projects still get old version.

**Investigation:**
1. Verify tag is on remote
2. Check marketplace registry/cache refresh
3. Verify `install.sh` references correct source

---

## Pre-Commit Hook Installation

To install the pre-commit hook in this repository:

```bash
# From repository root
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook: Ensure version bump for plugin repos
# This is a safety net - prefer using the commit skill

PLUGIN_JSON=".claude-plugin/plugin.json"

# Skip if not a plugin repo
[ ! -f "$PLUGIN_JSON" ] && exit 0

# If there are staged changes but plugin.json isn't staged, warn
STAGED=$(git diff --cached --name-only | grep -v "^.claude-plugin/plugin.json$")
PLUGIN_STAGED=$(git diff --cached --name-only | grep "^.claude-plugin/plugin.json$")

if [ -n "$STAGED" ] && [ -z "$PLUGIN_STAGED" ]; then
  echo ""
  echo "ERROR: Committing without version bump!"
  echo ""
  echo "Claude Code caches plugins by version. Without a bump,"
  echo "your changes won't propagate to consuming projects."
  echo ""
  echo "Solutions:"
  echo "  1. Use commit skill: say 'commit these changes' to Claude"
  echo "  2. Bump manually: ./scripts/bump-version.sh patch && git add .claude-plugin/plugin.json"
  echo "  3. Bypass (not recommended): git commit --no-verify"
  echo ""
  exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

**Note:** Git hooks are not tracked in the repository. Each developer must install them locally, or use a tool like `husky` or `lefthook` to manage hooks.

---

## Automation Consideration: Husky/Lefthook

For team environments, consider using a hook manager that tracks hooks in the repo:

**Option 1: Husky (npm projects)**
```bash
npm install husky --save-dev
npx husky init
echo './scripts/pre-commit-version-check.sh' > .husky/pre-commit
```

**Option 2: Lefthook (any project)**
```yaml
# lefthook.yml
pre-commit:
  commands:
    version-check:
      run: ./scripts/pre-commit-version-check.sh
```

**Recommendation for wdi:** Given this is a single-developer workflow, a tracked script with manual installation instructions is sufficient. Add `husky`/`lefthook` if the team grows.

---

## Summary

| Layer | Purpose | Catches |
|-------|---------|---------|
| Commit skill | Primary workflow | 95% of commits |
| Pre-commit hook | Safety net | Direct `git commit` usage |
| Documentation | Awareness | New contributors |
| Troubleshooting guide | Recovery | When things go wrong |

The defense-in-depth approach ensures that version propagation failures are rare and recoverable.

---

## Related Documentation

- [Auto-Update on Session Start](./plugin-version-auto-update.md) - How consuming projects receive updates
- [Semantic Versioning Feature](../../product/planning/features/semver-versioning.md) - Version bump implementation details
- [Commit Skill](../../../skills/workflow-commit/SKILL.md) - Full workflow specification
