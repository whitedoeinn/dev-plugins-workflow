# Troubleshooting

## New Machine Setup / Nuclear Reset

Use `install.sh --reset` to bootstrap a new development machine or reset a broken installation to a known good state.

```bash
# From the repo (if cloned)
cd ~/github/whitedoeinn/dev-plugins-workflow
git pull
./install.sh --reset

# Or via curl (new machines without the repo)
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash -s -- --reset
```

**What it does:**
1. Clears plugin caches (ensures fresh downloads)
2. Updates marketplaces (gets latest versions)
3. Removes ALL project-scope entries from `~/.claude/plugins/installed_plugins.json`
4. Deletes stale `.claude/settings.json` files from known project directories
5. Installs plugins at user scope (global)
6. Creates `~/.claude/CLAUDE.md` with environment standards
7. Verifies installation

**When to use:**
- Setting up a new development machine
- Plugin installations are in a broken/inconsistent state
- `claude plugin list` shows duplicate entries (same plugin at both scopes)
- Updates aren't propagating correctly
- You want to reset to a known good state

**Safe to re-run.** The script is idempotent.

---

## Installation Scopes

Plugins can be installed at two scopes:

| Scope | Flag | Settings Location | Use Case |
|-------|------|-------------------|----------|
| **User (global)** | `--scope user` | `~/.claude/settings.json` | Recommended for personal workstations |
| **Project** | `--scope project` | `.claude/settings.json` | Shared team projects |

**Recommendation:** For personal use, install globally (`--scope user`). This provides a single installation that works across all projects.

```bash
# Clean up duplicates and install globally
claude plugin uninstall wdi@wdi-marketplace --all
claude plugin uninstall compound-engineering@every-marketplace --all
claude plugin install compound-engineering@every-marketplace --scope user
claude plugin install wdi@wdi-marketplace --scope user
```

---

## Common Issues

### "Unknown skill: commit" or "Unknown skill: feature"

**Cause:** The plugin is not installed for your current project.

**Solution:**
```bash
cd your-project
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

Then start a new Claude Code session.

---

### Commands not found after installation

**Cause:** The Claude Code session was started before installation completed.

**Solution:** Exit and restart Claude Code:
```bash
exit  # or Ctrl+D
claude
```

---

### "Missing required plugins: compound-engineering"

**Cause:** The dependency plugin wasn't installed properly.

**Solution:**
```bash
claude plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin

# For global installation (recommended):
claude plugin install compound-engineering --scope user

# For project-only installation:
claude plugin install compound-engineering --scope project
```

---

### Plugin installed but commands still don't work

**Cause:** The plugin may be installed but disabled, or there may be duplicate installations at different scopes.

**Solution:** Check installation scope and status:
```bash
# Check user (global) settings
cat ~/.claude/settings.json | jq '.enabledPlugins | keys' 2>/dev/null

# Check project settings
cat .claude/settings.json | jq '.enabledPlugins | keys' 2>/dev/null

# For global installation (recommended - works across all projects):
claude plugin install wdi@wdi-marketplace --scope user

# For project-only installation:
claude plugin install wdi@wdi-marketplace --scope project
```

**Note:** If you have duplicate entries from both scopes, uninstall all and reinstall at one scope:
```bash
claude plugin uninstall wdi@wdi-marketplace --all
claude plugin install wdi@wdi-marketplace --scope user
```

---

### Permission errors running install.sh

**Cause:** Script doesn't have execute permission.

**Solution:**
```bash
chmod +x install.sh
./install.sh
```

Or run directly with bash:
```bash
bash install.sh
```

---

### commit skill fails at tests

**Cause:** Tests are failing in your project.

**Solution:**
- Fix the failing tests, or
- Use `--skip-tests` flag when committing:
  ```
  commit these changes --skip-tests
  ```

---

### /wdi:feature can't create GitHub Issue

**Cause:** The `gh` CLI is not authenticated.

**Solution:**
```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

---

### Changes to command files not taking effect

**Cause:** Claude Code caches plugin files.

**Solution:**
1. Exit Claude Code
2. Clear the plugin cache:
   ```bash
   rm -rf ~/.claude/plugins/cache/wdi*
   ```
3. Reinstall (use your existing scope):
   ```bash
   # Check which scope you're using:
   ./scripts/get-plugin-scope.sh wdi

   # Then reinstall with that scope:
   claude plugin install wdi@wdi-marketplace --scope user   # for global
   claude plugin install wdi@wdi-marketplace --scope project  # for project
   ```
4. Restart Claude Code

---

### Plugin updates not propagating to other projects

**Cause:** Version wasn't bumped when committing. Claude Code caches plugins by version, so without a version change, `claude plugin update` sees no difference.

**Symptoms:**
- You pushed changes to the plugin repo
- Other projects still have old behavior
- `git log` shows your commits, but consuming projects don't see them

**Quick Fix (if already committed):**
```bash
# Bump version now
./scripts/bump-version.sh patch
git add .claude-plugin/plugin.json
git commit --amend --no-edit

# Create and push tag
VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
git tag "v$VERSION"
git push --force-with-lease
git push origin "v$VERSION"
```

**Prevention:**
1. **Always use the commit skill** - Say "commit these changes" instead of `git commit`
2. **Install the pre-commit hook** (safety net):
   ```bash
   cp scripts/pre-commit-version-check.sh .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

**Verification checklist:**
```bash
# 1. Check version was bumped
git show --name-only HEAD | grep "plugin.json"

# 2. Check tag exists locally
git tag | grep "$(jq -r '.version' .claude-plugin/plugin.json)"

# 3. Check tag exists on remote
git ls-remote --tags origin | grep "$(jq -r '.version' .claude-plugin/plugin.json)"
```

See [Plugin Version Propagation](solutions/developer-experience/plugin-version-propagation.md) for full details.

---

### Hooks not firing during development

**Cause:** Hooks only work when the plugin is properly loaded via `--plugin-dir` or installation.

**Solution:**
```bash
# Start Claude Code with plugin loaded from source
claude --plugin-dir /path/to/dev-plugins-workflow
```

**Important notes:**
- You must restart Claude Code after modifying `hooks/hooks.json` or hook scripts
- Commands and skills work immediately without restart

---

## CI/CD Failures

### "Documentation drift detected" (validate-plugin.yml)

The workflow checks that:
- Every command in `commands/*.md` is listed in CLAUDE.md AND README.md
- Every skill in `skills/*/SKILL.md` is listed in CLAUDE.md AND README.md
- Version in `plugin.json` matches CLAUDE.md
- No docs reference commands/skills that were deleted

**To diagnose:**
```bash
./scripts/check-docs-drift.sh --verbose
```

**To fix:**
- Say "update the docs" to run `workflow-auto-docs` skill (auto-adds missing entries)
- Or manually add missing commands/skills to the tables in CLAUDE.md and README.md
- For version mismatch: update "Current version:" line in CLAUDE.md

---

### "Tests failed" (test.yml)

Runs BATS unit tests (`tests/unit/`) and integration tests (`tests/integration/`).

**To diagnose:**
```bash
./scripts/run-tests.sh
```

**To fix:** Read test output, fix the failing script, re-run locally before pushing.

---

### Adding a New Workflow

1. Create `.github/workflows/{name}.yml`
2. Add header comment explaining what it checks and when it runs
3. Add inline comments for non-obvious steps
4. Update this section if it has failure modes users should know about

---

## Debugging

### Check installed plugins

```bash
cat ~/.claude/plugins/installed_plugins.json | jq '.plugins | keys'
```

### Check plugin settings for a project

```bash
cat /path/to/project/.claude/settings.json
```

### View plugin installation paths

```bash
cat ~/.claude/plugins/installed_plugins.json | jq '.plugins["wdi@wdi-local"]'
```

### View known marketplaces

```bash
cat ~/.claude/plugins/known_marketplaces.json
```

---

## Getting Help

If you're still having issues:
1. Check the [GitHub Issues](https://github.com/whitedoeinn/dev-plugins-workflow/issues)
2. Open a new issue with:
   - Your OS and Claude Code version
   - The exact error message
   - Steps to reproduce
