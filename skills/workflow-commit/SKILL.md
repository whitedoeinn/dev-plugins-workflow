---
name: workflow-commit
description: This skill should be used when committing code changes to git. It applies when the user asks to commit, push changes, save work, or mentions finishing work that needs to be committed. Triggers on phrases like "commit these changes", "commit this", "push this", "let's commit", "ready to commit", "save these changes", or any request involving git commit operations. Provides quality-gated commits with tests and automatic changelog updates.
---

<objective>
Smart commit workflow that enforces quality gates before every commit:
- Runs tests automatically
- Generates meaningful commit messages
- Updates changelog automatically

This ensures consistent code quality and documentation across all commits.

Note: Simplicity review runs during the workflow review phase, not at commit time.
We work directly on main (branching strategy is being evaluated in #44).
</objective>

<quick_start>
When invoked, output this banner first:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔧 workflow-commit activated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then:
1. Run `git status --short` to check for changes
2. If no changes: Tell user "Nothing to commit"
3. If changes exist: Proceed with the full workflow below

</quick_start>

<flags>
| Flag | Description |
|------|-------------|
| `--yes` | Skip prompts, auto-accept defaults. Aborts on test failures. |
| `--summary` | Generate fun changelog summary after commit |
| `--skip-tests` | Skip tests |
</flags>

<workflow>
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

**Why this matters:** Without this check, bumping a stale local version (e.g., 0.3.1 → 0.3.2 when remote is 0.3.19) would regress the plugin version and potentially overwrite commits.

## Step 1: Check Status

```bash
git status --short
```

- Clean tree: ABORT "Nothing to commit."
- Unstaged changes: Ask "(a)dd all, (s)elect files, (c)ontinue with staged, (q)uit"
- Optional: "Review diffs? [y/n]" → show file picker

## Step 2: Run Tests

Skip if --skip-tests. Detect and run:

| Staged Files    | Command                           |
|-----------------|-----------------------------------|
| *.py            | pytest (activate venv if present) |
| *.ts/*.tsx/*.js | npm test                          |

Fail = ABORT

## Step 3: Auto-Update Documentation

Check if commands or skills were modified:

```bash
git diff --cached --name-only | grep -E "^(commands/|skills/)" && DOCS_NEEDED=true
```

**If commands/skills staged:**

1. Run drift detection:
   ```bash
   ./scripts/check-docs-drift.sh
   ```

2. If drift found (exit code non-zero):
   ```
   Documentation drift detected - updating automatically...
   ```

3. Invoke workflow-auto-docs logic:
   - Parse drift output
   - Update CLAUDE.md and README.md tables
   - Stage the documentation changes:
     ```bash
     git add CLAUDE.md README.md
     ```

4. Show what was updated:
   ```
   Auto-updated documentation:
     • Added --promote flag to CLAUDE.md commands table
     • Updated version reference
   ```

**If no commands/skills changed:** Skip this step.

**With --yes:** Auto-apply all documentation fixes without prompting.

## Step 4: Generate Message

Analyze diff. Focus on "why" not "what". Keep concise.

## Step 5: Detect Context

Ask: (f)eature, (i)ssue fix, (h)otfix, (n)one — to determine commit prefix.

## Step 6: Version Bump (if plugin repo)

Skip this step if `.claude-plugin/plugin.json` doesn't exist or has no `version` field.

### Detect bump type from commit

**Every commit bumps the version.** Claude Code caches plugins by version, so without a bump, updates don't propagate to consuming projects.

| Signal | Action |
|--------|--------|
| Message starts with `feat:` | Prompt (minor or patch) |
| Message body contains `BREAKING CHANGE:` | Prompt (major or minor) |
| All other commits | Auto-bump patch |

### Auto-bump (no prompt)

For most commits, bump patch automatically:
```
Version: 0.1.0 → 0.1.1 (patch)
```

### Prompt when needed

For features:
```
Version bump for feature commit.
Current: 0.1.0

  [m] Minor (0.2.0) - New feature or capability
  [p] Patch (0.1.1) - Small enhancement

Choice [m/p]:
```

With `--yes`: Default to patch for features.

### Apply bump

```bash
NEW_VERSION=$(./scripts/bump-version.sh <type>)
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

**Important:** Stage both files. `bump-version.sh` updates both `plugin.json` and `marketplace.json` to keep versions in sync.

The version change is included in the same commit.

## Step 7: Confirm Message

```
Proposed commit message:
───────────────────────────────────────
feat: Add campaign filter dropdown

Implement status and budget filters.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
───────────────────────────────────────

(y)es, (e)dit, (a)bort:
```

## Step 8: Update Changelog

File: docs/changelog.md

Create if missing:
```markdown
# Changelog

All notable changes documented here.

---
```

Add entry under today's date:
```markdown
## YYYY-MM-DD

- **FEAT-XXX**: Description
- **Fix #NNN**: Description
- Hotfix: Description
- Description (no prefix)
```

Rules:
- If today's section exists, append to it
- If not, create new section at top
- Focus on impact/why, not just what changed
- Good: "Fixed skills not auto-invoking - directory wasn't registered"
- Bad: "Added skills entry to plugin.json"

## Step 9: Push

```bash
git add docs/changelog.md
git commit --amend --no-edit
git push
```

## Step 10: Git Tag (if version bumped)

If a version bump was applied in Step 6, create and push a git tag:

```bash
VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
git tag "v$VERSION"
git push origin "v$VERSION"
```

Output:
```
Tagged: v0.2.0
```

## Step 11: Summary (--summary flag only)

Invoke the changelog skill:

```
/compound-engineering:changelog
```

Generates a fun summary with emojis and shoutouts.
</workflow>

<success_criteria>
A successful commit workflow:
- Tests pass (or skipped with --skip-tests)
- Commit message is meaningful and approved
- Version bumped appropriately (if plugin repo)
- Changelog is updated with today's entry
- Changes are pushed to remote
- Git tag created (if version bumped)
</success_criteria>

<notes>
- Always adds `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` to commits
- Never force push
- Aborts on merge conflicts
- Creates docs/changelog.md if missing
- Auto-updates CLAUDE.md and README.md when commands/skills are modified (Step 3)
- **Requires:** compound-engineering plugin for --summary flag
</notes>
