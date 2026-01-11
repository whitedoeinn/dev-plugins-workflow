# Troubleshooting

## Common Issues

### "Unknown skill: commit" or "Unknown skill: feature"

**Cause:** The plugin is not installed for your current project.

**Solution:**
```bash
cd your-project
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflows/main/install.sh | bash
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
cat ~/.claude/plugins/installed_plugins.json | grep -A5 "wdi-workflows"

# Reinstall for project scope
claude plugin install wdi-workflows --scope project
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

### commit skill fails at simplicity review

**Cause:** The `compound-engineering` plugin's review agent found issues.

**Solution:**
- Review the issues shown
- Fix them or use `--skip-review` flag when committing:
  ```
  commit these changes --skip-review
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

### /wdi-workflows:feature can't create GitHub Issue

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
   rm -rf ~/.claude/plugins/cache/wdi-workflows*
   ```
3. Reinstall:
   ```bash
   claude plugin install wdi-workflows --scope project
   ```
4. Restart Claude Code

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
cat ~/.claude/plugins/installed_plugins.json | jq '.plugins["wdi-workflows@wdi-workflows-local"]'
```

### View known marketplaces

```bash
cat ~/.claude/plugins/known_marketplaces.json
```

---

## Getting Help

If you're still having issues:
1. Check the [GitHub Issues](https://github.com/whitedoeinn/dev-plugins-workflows/issues)
2. Open a new issue with:
   - Your OS and Claude Code version
   - The exact error message
   - Steps to reproduce
