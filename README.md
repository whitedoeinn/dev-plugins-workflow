# Claude Workflows

Claude Code plugin providing compound-engineering workflows for feature development and smart commits.

## Commands

| Command | Description |
|---------|-------------|
| `/claude-workflows:feature` | Full feature workflow: research → plan → work → review → compound |
| `/claude-workflows:commit` | Smart commit with tests, simplicity review, and changelog |

## Requirements

- Claude Code CLI
- `compound-engineering` plugin enabled
- `gh` CLI authenticated (for GitHub Issue creation)

## Installation

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": [
    "https://raw.githubusercontent.com/whitedoeinn/claude-workflows/main/marketplace.json"
  ],
  "enabledPlugins": {
    "claude-workflows": true
  }
}
```

## Updating

The plugin pulls from the latest version on GitHub. To get updates, the plugin will automatically use the newest version.

## Workflow Details

### /claude-workflows:feature

Orchestrates the complete feature development cycle:

1. **Research** - Smart-selects research agents based on feature context
2. **Plan** - Creates GitHub Issue + local plan file with requirements
3. **Work** - Feature branch, implementation, tests
4. **Review** - Multi-agent code review (simplicity, architecture, security, performance)
5. **Compound** - Merge, changelog, document learnings

Flags:
- `--yes` - Auto-continue through phases
- `--plan-only` - Stop after planning
- `--skip-research` - Skip research agents

### /claude-workflows:commit

Smart commit with quality gates:

1. Stage changes (interactive or all)
2. Run tests (pytest, npm test based on file types)
3. Simplicity review (catches over-engineering)
4. Generate commit message
5. Update changelog (`docs/changelog.md`)
6. Push

Flags:
- `--yes` - Auto-accept defaults
- `--summary` - Generate fun changelog summary
- `--skip-review` - Skip simplicity review
- `--skip-tests` - Skip tests
