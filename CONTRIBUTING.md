# Contributing

## Adding a New Command

1. **Create the command file**

   Add a new markdown file in `commands/`:
   ```bash
   touch commands/my-command.md
   ```

2. **Add YAML frontmatter**

   Start with description metadata:
   ```markdown
   ---
   description: Short description of what the command does
   ---

   # /my-command - Command Title

   ## Workflow

   ### Step 1: First Step
   ...
   ```

3. **Write the workflow**

   Document each step Claude should follow. The markdown IS the implementation - Claude reads and executes these instructions.

4. **Test locally**

   Run your command in this repo:
   ```
   /my-command
   ```

5. **Push to GitHub**

   Other projects can then install/update to get your new command.

## Modifying Existing Commands

1. Edit the command file in `commands/`
2. Test the changes locally
3. Update `docs/changelog.md` with your changes
4. Push to GitHub

## Command File Structure

```markdown
---
description: One-line description for command listings
---

# /command-name - Human Readable Title

## Flags

| Flag | Description |
|------|-------------|
| `--flag` | What the flag does |

## Workflow

### Step 1: Step Name

Description of what to do.

```bash
# Example commands to run
git status
```

### Step 2: Next Step
...

## Examples

### Example: Basic Usage
\`\`\`
/command-name
\`\`\`

Expected output...

## Notes

- Important considerations
- Edge cases
```

## Testing Locally

Changes to command files take effect immediately in this repo. To test:

1. Make your edits to `commands/*.md`
2. Run the command: `/wdi:feature`, etc. (or say "commit these changes" for commits)
3. Verify the workflow works as expected

## Pushing Changes

Use the commit skill - it handles everything automatically:

```
Say: "commit these changes"
```

The commit skill will:
1. Run tests (if applicable)
2. Perform simplicity review (for large changes)
3. Bump version based on commit type (`feat:` → prompt, `fix:` → auto patch)
4. Update changelog
5. Create git tag
6. Push to remote

**Manual alternative** (not recommended):
```bash
./scripts/bump-version.sh patch  # or minor
# Edit docs/changelog.md
git add . && git commit -m "feat: Add new feature"
git push
```

4. **Other projects update**

   Users run:
   ```bash
   ./install.sh update
   ```

## Code Style

### Markdown Commands

- Use ATX-style headers (`#`, `##`, `###`)
- Keep step descriptions concise
- Include examples for complex workflows
- Document all flags in a table
- Add notes for edge cases and gotchas

### Bash Scripts

- Use `set -e` for error handling
- Add color output for user feedback
- Support both interactive and automated usage
- Handle cross-platform differences (macOS, Linux, WSL)

## Architecture

See [docs/architecture.md](docs/architecture.md) for how the plugin system works.

## Questions?

Open an issue on [GitHub](https://github.com/whitedoeinn/dev-plugins-workflow/issues).
