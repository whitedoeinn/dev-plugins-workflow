# Claude Workflows Plugin

## Project Overview

This is the source repository for the `claude-workflows` Claude Code plugin. It provides compound-engineering workflows for feature development and smart commits.

## Structure

```
claude-workflows/
├── commands/           # Markdown-based command definitions
│   ├── commit.md       # /claude-workflows:commit workflow
│   ├── feature.md      # /claude-workflows:feature workflow
│   └── setup.md        # /claude-workflows:setup verification
├── .claude-plugin/     # Plugin configuration
│   ├── plugin.json     # Plugin metadata
│   └── marketplace.json # Local marketplace config
├── hooks/              # Claude Code hooks
│   └── hooks.json      # SessionStart hook config
├── scripts/            # Helper scripts
│   └── check-deps.sh   # Dependency checker
├── docs/               # Documentation
│   └── changelog.md    # Project changelog
└── install.sh          # Bootstrap installation script
```

## Commands

| Command | Description |
|---------|-------------|
| `/claude-workflows:commit` | Smart commit with tests, simplicity review, and changelog |
| `/claude-workflows:feature` | Full feature workflow (research → plan → work → review → compound) |
| `/claude-workflows:setup` | Verify dependencies and installation status |

## Dependencies

This plugin requires the `compound-engineering` plugin for:
- Research agents (repo-research-analyst, git-history-analyzer, etc.)
- Review agents (code-simplicity-reviewer, security-sentinel, etc.)
- Workflow skills (plan, work, review, compound)

## How It Works

Claude Code plugins use markdown files as command definitions. When you run `/claude-workflows:commit`, Claude Code:
1. Finds `commands/commit.md` via `plugin.json` → `"commands": "./commands/"`
2. Loads the markdown as instructions
3. Executes the workflow steps described in the markdown

The markdown files contain both documentation AND executable instructions for Claude.

## Development Workflow

1. **Edit command files** in `/commands/*.md`
2. **Test locally** - Changes take effect immediately in this project
3. **Push to GitHub** - Other projects can then update via `./install.sh update`

## Key Files

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin metadata, version, command registration |
| `install.sh` | Bootstrap script for installing in other projects |
| `commands/*.md` | Command definitions (these ARE the implementation) |
| `hooks/hooks.json` | SessionStart hook to check dependencies |
| `scripts/check-deps.sh` | Verifies compound-engineering is installed |

## Testing Changes

After editing a command:
1. Run the command in this repo to verify it works
2. Check that the markdown is valid and instructions are clear
3. Push to GitHub when ready for distribution

## Version

Current version: 1.0.0 (see `.claude-plugin/plugin.json`)
