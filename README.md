# Claude Workflows

Shared Claude Code commands for compound-engineering workflows.

## Commands

| Command | Description |
|---------|-------------|
| `/feature` | Full feature workflow: research → plan → work → review → compound |
| `/commit` | Smart commit with tests, simplicity review, and changelog |

## Requirements

- Claude Code CLI
- `compound-engineering` plugin enabled
- `gh` CLI authenticated (for GitHub Issue creation)

## Installation

Run the install script with the path to your project:

```bash
./install.sh /path/to/your/project
```

Or manually create symlinks:

```bash
ln -sf /path/to/claude-workflows/commands/feature.md /path/to/project/.claude/commands/feature.md
ln -sf /path/to/claude-workflows/commands/commit.md /path/to/project/.claude/commands/commit.md
```

## Updating

Pull the latest changes and symlinks will automatically use the new versions:

```bash
cd /path/to/claude-workflows
git pull
```

## Workflow Details

### /feature

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

### /commit

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
