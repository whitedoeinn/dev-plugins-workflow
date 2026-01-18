# Auto-Docs: Automatic Documentation Sync

This plugin includes automatic documentation drift detection and repair. When you add or modify commands and skills, documentation in CLAUDE.md and README.md can become stale. The auto-docs capability fixes this.

## How It Works

```
Source Files                    Documentation
─────────────────              ─────────────────
commands/*.md        ──────►   CLAUDE.md tables
skills/*/SKILL.md    ──────►   README.md tables
plugin.json version  ──────►   CLAUDE.md version
```

The system detects when documentation is missing entries or has version mismatches.

## Two Ways to Trigger

### 1. Automatic (via commit skill)

When you stage changes to `commands/` or `skills/` directories, the commit skill automatically runs drift detection:

```bash
git add commands/my-new-command.md
# Say "commit these changes"
# → Commit skill detects staged command files
# → Runs drift detection
# → Auto-updates CLAUDE.md and README.md
# → Stages the documentation changes
# → Includes them in the commit
```

You don't need to think about it—documentation stays in sync automatically.

### 2. Manual (via skill trigger)

Say "update the docs" to run drift detection manually:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔧 workflow-auto-docs activated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Documentation Drift Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commands:
  • /wdi:my-new-command - missing from README.md

(a)pply all fixes, (r)eview each, (c)heck only:
```

Other trigger phrases: "sync documentation", "update CLAUDE.md", "docs are out of date"

## What Gets Synced

| Source | Target | Detection |
|--------|--------|-----------|
| `commands/*.md` | CLAUDE.md commands table | Looks for `/wdi:{name}` |
| `commands/*.md` | README.md commands table | Looks for `/wdi:{name}` |
| `skills/*/SKILL.md` | CLAUDE.md skills table | Looks for `` `{name}` `` |
| `skills/*/SKILL.md` | README.md skills table | Looks for `` `{name}` `` |
| `.claude-plugin/plugin.json` version | CLAUDE.md version line | Compares version strings |

## What Doesn't Get Synced

Some documentation requires manual updates:

| File | Why Manual |
|------|------------|
| `install.sh` | Heredoc strings are fragile to edit programmatically |
| `docs/architecture.md` | Diagrams require human judgment |
| Directory tree in CLAUDE.md | Complex parsing, rare changes |

## Flags

| Flag | Usage | Effect |
|------|-------|--------|
| `--check` | "update the docs --check" | Dry run—show drift without fixing |
| `--all` | "update the docs --all" | Fix all drift without prompting |

## Adding a New Doc to the Dependency Graph

The drift detection script (`scripts/check-docs-drift.sh`) currently tracks CLAUDE.md and README.md. To add another file:

### 1. Edit the detection script

```bash
# In scripts/check-docs-drift.sh, add a new check block:

# Check if in YOUR-DOC.md
if ! grep -q "/wdi:$cmd_name" YOUR-DOC.md 2>/dev/null; then
  echo "DRIFT:command:$cmd_name:missing_yourdoc"
  log "  ${RED}MISSING${NC}: /wdi:$cmd_name not in YOUR-DOC.md"
  DRIFT_FOUND=1
fi
```

### 2. Update the skill workflow

In `skills/workflow-auto-docs/SKILL.md`, add handling for the new drift type:

```markdown
### Adding a Command to YOUR-DOC.md

Find the appropriate table and add a row following the existing pattern.
```

### 3. Update skill notes

Add your file to the notes section so developers know it's tracked.

## Troubleshooting

### "Documentation is up to date" but I added a new command

Check that your command file:
- Is in the `commands/` directory (not a subdirectory)
- Has a `.md` extension
- Follows naming convention: `{name}.md` (becomes `/wdi:{name}`)

### Drift detected but not fixed

The skill uses the Edit tool to update files. If the table format in CLAUDE.md or README.md has drifted from the expected pattern, the edit may fail. Check that:
- Tables use standard markdown format
- Command/skill entries follow the existing pattern

### Version mismatch not detected

The script looks for the pattern `Current version: X.Y.Z` in CLAUDE.md. Verify:
- The pattern exists in CLAUDE.md
- Uses semantic versioning (X.Y.Z format)

## Under the Hood

The drift detection script (`scripts/check-docs-drift.sh`) outputs machine-readable lines:

```
DRIFT:<type>:<name>:<issue>[:<detail>]
```

Types:
- `command` - Command file drift
- `skill` - Skill file drift
- `version` - Version mismatch
- `stale_ref` - Reference to non-existent file

The skill parses these lines and uses the Edit tool to fix each issue.

Run the script directly to debug:

```bash
./scripts/check-docs-drift.sh --verbose
```

---

*See also: [SKILL.md](../skills/workflow-auto-docs/SKILL.md) for the full skill implementation*
