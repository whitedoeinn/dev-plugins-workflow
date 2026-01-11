# Claude Workflows

Claude Code plugin providing compound-engineering workflows for feature development and smart commits.

**Version:** 1.0.0 | **License:** MIT | [Architecture](docs/architecture.md) | [Troubleshooting](docs/troubleshooting.md) | [Contributing](CONTRIBUTING.md)

## Quick Start

Run in any project:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/claude-workflows/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/whitedoeinn/claude-workflows
cd claude-workflows
./install.sh
```

## Commands

| Command | Description |
|---------|-------------|
| `/claude-workflows:feature` | Full feature workflow: research → plan → work → review → compound |
| `/claude-workflows:commit` | Smart commit with tests, simplicity review, and changelog |
| `/claude-workflows:setup` | Set up and verify plugin dependencies |

## Requirements

- Claude Code CLI
- `compound-engineering` plugin (installed automatically by `install.sh`)
- `gh` CLI authenticated (for GitHub Issue creation)

## Installation

### Option 1: Bootstrap Script (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/claude-workflows/main/install.sh | bash
```

This installs both `compound-engineering` and `claude-workflows` plugins.

### Option 2: Manual Installation

```bash
# Add compound-engineering marketplace
/plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin

# Install compound-engineering
/plugin install compound-engineering

# Add claude-workflows marketplace
/plugin marketplace add https://github.com/whitedoeinn/claude-workflows

# Install claude-workflows
/plugin install claude-workflows
```

## Updating

To update plugins to the latest versions:

```bash
./install.sh update
```

Or manually:

```bash
claude plugin update compound-engineering --scope project
claude plugin update claude-workflows --scope project
```

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

## Cross-Platform Support

Works on macOS, Linux, and Windows (WSL). The install script automatically detects your platform.

## How It Works

This plugin uses Claude Code's markdown-based command system. Commands are defined as markdown files in `commands/` - the markdown IS the implementation. When you run `/claude-workflows:commit`, Claude Code reads `commands/commit.md` and follows the workflow steps.

The plugin builds on top of `compound-engineering` which provides:
- **Research agents** for codebase analysis
- **Review agents** for code quality checks
- **Workflow skills** for planning and documentation

See [docs/architecture.md](docs/architecture.md) for detailed diagrams.

## Troubleshooting

Common issues and solutions are documented in [docs/troubleshooting.md](docs/troubleshooting.md).

Quick fixes:
- **"Unknown skill: commit"** → Plugin not installed. Run `install.sh`
- **Commands not found** → Restart Claude Code after installation
- **Simplicity review fails** → Use `--skip-review` or fix the issues

## Team Onboarding

Add this to each project's README:

```markdown
## Claude Code Setup

This project uses custom Claude Code workflows. First-time setup:

\`\`\`bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/claude-workflows/main/install.sh | bash
\`\`\`

Available commands:
- `/claude-workflows:feature` - Full feature workflow
- `/claude-workflows:commit` - Smart commit with review

To update: `./install.sh update`
```
