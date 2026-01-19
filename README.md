# WDI Workflows

![Tests](https://github.com/whitedoeinn/dev-plugins-workflow/actions/workflows/test.yml/badge.svg)
![Plugin Validation](https://github.com/whitedoeinn/dev-plugins-workflow/actions/workflows/validate-plugin.yml/badge.svg)

Claude Code plugin providing compound-engineering workflows, development standards, and project scaffolding for White Doe Inn projects.

**Version:** 0.3.16 | **License:** MIT | [Architecture](docs/architecture.md) | [Troubleshooting](docs/troubleshooting.md) | [Contributing](CONTRIBUTING.md) | [Standards](docs/standards/)

## Quick Start

Run in any project:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/whitedoeinn/dev-plugins-workflow
cd dev-plugins-workflow
./install.sh
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/wdi:workflows-feature` | Full feature workflow: pre-flight → research → plan → work → review → compound |
| `/wdi:workflows-feature --idea` | Quick idea capture: creates idea file + draft issue, no implementation |
| `/wdi:workflows-feature --plan` | Stop after planning phase |
| `/wdi:workflows-enhanced-ralph` | Quality-gated feature execution with research agents and type-specific reviews |
| `/wdi:workflows-milestone` | Create and manage milestones that group related features for delivery |
| `/wdi:workflows-setup` | Set up and verify plugin dependencies |

### Skills (Auto-Invoked)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `workflow-commit` | "commit these changes" | Smart commit with tests, auto-docs, and changelog |
| `workflow-auto-docs` | "update the docs" | Detect and fix documentation drift when commands/skills change |
| `workflow-config-sync` | "check my config" | Validate environment against baseline, auto-remediate drift |

### Standards Commands

| Command | Description |
|---------|-------------|
| `/wdi:standards-new-repo` | Create a new repository following WDI naming and structure standards |
| `/wdi:standards-new-subproject` | Add a new subproject to a mono-repo following standards |
| `/wdi:standards-check` | Validate current repository against WDI development standards |
| `/wdi:standards-update` | Impact analysis and guided updates when changing development standards |
| `/wdi:standards-new-command` | Create a new command and update all dependent files |

## Requirements

- Claude Code CLI
- `compound-engineering` plugin (installed automatically by `install.sh`)
- `gh` CLI authenticated (for GitHub Issue creation)

## Installation

### Option 1: Bootstrap Script (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

This installs both `compound-engineering` and `wdi` plugins.

### Option 2: Manual Installation

```bash
# Add compound-engineering marketplace
/plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin

# Install compound-engineering
/plugin install compound-engineering

# Add wdi marketplace
/plugin marketplace add https://github.com/whitedoeinn/dev-plugins-workflow

# Install wdi
/plugin install wdi
```

## Updating

### Automatic Updates (Default)

Plugin updates happen automatically on session start:
1. **First restart** - SessionStart hook downloads new plugin files
2. **Second restart** - Claude loads the updated plugin

This two-restart requirement is a Claude Code limitation. The hook clears the plugin cache and reinstalls to work around a bug in `plugin update` that doesn't re-download changed files.

### Manual Update

Re-run the install script:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

### If Updates Aren't Working

Nuclear reset (clears all plugin state):

```bash
rm -rf ~/.claude/plugins/cache/wdi-marketplace/
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

See [troubleshooting.md](docs/troubleshooting.md) for more details.

## Workflow Details

### /wdi:workflows-feature

Orchestrates the complete feature development cycle:

1. **Research** - Smart-selects research agents based on feature context
2. **Plan** - Creates GitHub Issue + local plan file with requirements
3. **Work** - Implementation and tests (on main)
4. **Review** - Multi-agent code review (architecture, security, performance)
5. **Compound** - Changelog, document learnings

**Note:** The workflow commits directly to main with quality gates. Feature branches are not used by design ([#44](https://github.com/whitedoeinn/dev-plugins-workflow/issues/44)). Individuals may use feature branches manually for their own purposes.

Flags:
- `--yes` / `-y` - Auto-continue through phases
- `--plan` - Stop after planning
- `--idea` - Quick idea capture mode (minimal structure, no implementation)
- `--skip-research` - Skip research agents

### workflow-commit skill

Smart commit with quality gates. **Auto-invoked** when you say "commit these changes" or similar.

1. Stage changes (interactive or all)
2. Run tests (pytest, npm test based on file types)
3. Auto-update documentation (if commands/skills changed)
4. Generate commit message
5. Update changelog (`docs/changelog.md`)
6. Push

Flags (pass to Claude when requesting commit):
- `--yes` - Auto-accept defaults
- `--summary` - Generate fun changelog summary
- `--skip-tests` - Skip tests

## Cross-Platform Support

Works on macOS, Linux, and Windows (WSL). The install script automatically detects your platform.

## How It Works

This plugin uses Claude Code's markdown-based command system. Commands are defined as markdown files in `commands/` - the markdown IS the implementation. Skills in `skills/` auto-invoke based on context (e.g., say "commit these changes" to trigger the commit skill).

The plugin builds on top of `compound-engineering` which provides:
- **Research agents** for codebase analysis
- **Review agents** for code quality checks
- **Workflow skills** for planning and documentation

See [docs/architecture.md](docs/architecture.md) for detailed diagrams.

## Templates

### Daily Changelog Automation

GitHub Action templates for automatic daily commit summaries.

| Template | Cost | Best For |
|----------|------|----------|
| [daily-changelog.yml](docs/templates/workflows/daily-changelog.yml) | Free | Most projects |
| [daily-changelog-claude.yml](docs/templates/workflows/daily-changelog-claude.yml) | ~$0.01-0.05/run | Teams wanting AI-enhanced summaries |

**Quick Setup (Bash version):**
```bash
# Copy to your project
cp docs/templates/workflows/daily-changelog.yml .github/workflows/

# Enable workflow permissions in GitHub:
# Settings > Actions > General > Workflow permissions > Read and write
```

**Claude-Enhanced Setup:**
```bash
# Copy to your project
cp docs/templates/workflows/daily-changelog-claude.yml .github/workflows/daily-changelog.yml

# Add your API key as a repository secret:
# Settings > Secrets and variables > Actions > New repository secret
# Name: ANTHROPIC_API_KEY
# Value: (your key from console.anthropic.com)
```

Both run at midnight Eastern Time and can be triggered manually from the Actions tab.

## Troubleshooting

Common issues and solutions are documented in [docs/troubleshooting.md](docs/troubleshooting.md).

Quick fixes:
- **"Unknown skill: commit"** → Plugin not installed. Run `install.sh`
- **Commands not found** → Restart Claude Code after installation
- **"Environment cannot be auto-fixed"** → Follow the remediation steps shown, then say "check my config"
- **"gh not authenticated"** → Run `gh auth login` to authenticate GitHub CLI

## Development Standards

This plugin enforces WDI development standards. Key conventions:

| Standard | Document |
|----------|----------|
| Repository naming | [REPO-STANDARDS.md](docs/standards/REPO-STANDARDS.md) |
| Project structure | [PROJECT-STRUCTURE.md](docs/standards/PROJECT-STRUCTURE.md) |
| File naming | [FILE-NAMING.md](docs/standards/FILE-NAMING.md) |
| Branch naming | [BRANCH-NAMING.md](docs/drafts/BRANCH-NAMING.md) *(draft - not implemented)* |
| Commit messages | [COMMIT-STANDARDS.md](docs/standards/COMMIT-STANDARDS.md) |
| Claude Code plugins | [CLAUDE-CODE-STANDARDS.md](docs/standards/CLAUDE-CODE-STANDARDS.md) |

Quick reference: [knowledge/standards-summary.md](knowledge/standards-summary.md)

### Key Conventions

- **Repos:** No `wdi-` prefix (org name provides context)
- **Commands:** Use `/wdi:*` prefix with domain-prefixed names (e.g., `/wdi:workflows-feature`)
- **Mono-repos:** Cluster by domain (`marketing-ops`, `business-ops`)
- **Plugins:** Standalone repos (`dev-plugins-*`)
- **Branches:** Workflow uses main; if using branches manually: `feature/`, `fix/`, `hotfix/`, `docs/`, `experiment/`

## Team Onboarding

Add this to each project's README:

```markdown
## Claude Code Setup

This project uses custom Claude Code workflows. First-time setup:

\`\`\`bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
\`\`\`

Available commands:
- `/wdi:workflows-feature` - Full feature workflow
- `/wdi:standards-check` - Validate against WDI standards

Skills (auto-invoked):
- `workflow-commit` - Say "commit these changes" for smart commit with tests and changelog

To update: `./install.sh update`
```
