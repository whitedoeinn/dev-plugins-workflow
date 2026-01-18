# Troubleshooting

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
claude plugin install compound-engineering --scope project
```

---

### Plugin installed but commands still don't work

**Cause:** The plugin may be installed globally but not for your project scope.

**Solution:** Check installation and reinstall for project:
```bash
# View current installations
cat ~/.claude/plugins/installed_plugins.json | grep -A5 "wdi"

# Reinstall for project scope
claude plugin install wdi --scope project
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
3. Reinstall:
   ```bash
   claude plugin install wdi --scope project
   ```
4. Restart Claude Code

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
