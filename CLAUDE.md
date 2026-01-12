# WDI Workflows Plugin

## Project Overview

This is the source repository for the `wdi-workflows` Claude Code plugin. It provides:
- Compound-engineering workflows for feature development
- Smart commit workflows with quality gates
- Development standards and project scaffolding
- Repository and subproject creation commands

## Structure

```
dev-plugins-workflows/
├── commands/               # Markdown-based command definitions
│   ├── feature.md          # /wdi-workflows:feature workflow
│   ├── enhanced-ralph.md   # /wdi-workflows:enhanced-ralph quality-gated execution
│   ├── milestone.md        # /wdi-workflows:milestone grouping features
│   ├── setup.md            # /wdi-workflows:setup verification
│   ├── new-repo.md         # /wdi-workflows:new-repo scaffolding
│   ├── new-subproject.md   # /wdi-workflows:new-subproject scaffolding
│   ├── check-standards.md  # /wdi-workflows:check-standards validation
│   ├── update-standard.md  # /wdi-workflows:update-standard impact analysis
│   └── new-command.md      # /wdi-workflows:new-command workflow
├── .claude-plugin/         # Plugin configuration
│   ├── plugin.json         # Plugin metadata
│   └── marketplace.json    # Local marketplace config
├── hooks/                  # Claude Code hooks
│   └── hooks.json          # SessionStart hook config
├── scripts/                # Helper scripts
│   ├── wdi                 # Global CLI for project bootstrapping
│   ├── check-deps.sh       # Dependency and standards checker
│   ├── check-docs-drift.sh # Detects documentation drift
│   ├── pre-tool-standards-check.sh  # PreToolUse hook for commit skill + standards
│   ├── validate-dependency-map.sh   # Validates dependency map accuracy
│   ├── get-standard-deps.sh         # Helper for parsing dependency map
│   └── test-enhanced-ralph.sh       # Test scenarios for enhanced-ralph
├── docs/                   # Documentation
│   ├── standards/          # Development standards
│   │   ├── REPO-STANDARDS.md
│   │   ├── PROJECT-STRUCTURE.md
│   │   ├── FILE-NAMING.md
│   │   ├── BRANCH-NAMING.md
│   │   ├── COMMIT-STANDARDS.md
│   │   └── CLAUDE-CODE-STANDARDS.md
│   ├── templates/          # Reusable templates
│   │   ├── feature.md      # Feature spec template
│   │   ├── milestone.md    # Milestone template
│   │   └── workflows/      # GitHub Actions templates
│   │       ├── daily-changelog.yml        # Bash-based daily changelog
│   │       └── daily-changelog-claude.yml # Claude-enhanced version
│   ├── context/            # Session context files (for resuming work)
│   ├── showcase/           # Visual documentation and guides
│   ├── architecture.md
│   ├── troubleshooting.md
│   └── changelog.md
├── knowledge/              # Reference docs for commands
│   ├── standards-summary.md
│   └── decision-trees/
│       ├── repo-type.md
│       └── package-location.md
├── skills/                 # Auto-invoked skills
│   ├── commit/             # Smart commit skill (say "commit these changes")
│   │   └── SKILL.md
│   └── auto-update-docs/   # Doc sync skill (say "update the docs")
│       └── SKILL.md
├── test/                   # Test fixtures
│   └── fixtures/           # Test data for enhanced-ralph scenarios
│       ├── features/       # Test feature files
│       └── milestones/     # Test milestone files
└── install.sh              # Bootstrap installation script
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/wdi-workflows:feature` | Full feature workflow (pre-flight → research → plan → work → review → compound) |
| `/wdi-workflows:enhanced-ralph` | Quality-gated feature execution with research agents and type-specific reviews |
| `/wdi-workflows:milestone` | Create and execute milestone-based feature groupings |
| `/wdi-workflows:setup` | Verify dependencies and installation status |

### Skills (Auto-Invoked)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `commit` | "commit these changes" | Smart commit with tests, simplicity review, and changelog |
| `auto-update-docs` | "update the docs" | Detect and fix documentation drift when commands/skills change |

> **IMPORTANT:** Always use the commit skill instead of running `git commit` directly.
> The skill ensures changelog updates, runs tests, and performs simplicity review.
> A PreToolUse hook will warn if you try to run `git commit` directly.

### Standards Commands

| Command | Description |
|---------|-------------|
| `/wdi-workflows:new-repo` | Create repository following WDI naming standards |
| `/wdi-workflows:new-subproject` | Add subproject to mono-repo following standards |
| `/wdi-workflows:check-standards` | Validate current repo against standards |
| `/wdi-workflows:update-standard` | Impact analysis and guided updates for standard changes |
| `/wdi-workflows:new-command` | Create a new command and update all dependent files |

## WDI CLI (Pre-Claude-Code)

The `wdi` CLI runs **before** Claude Code starts, solving the problem of creating directories without knowing naming standards.

```bash
# Install globally
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflows/main/scripts/wdi | bash -s install

# Commands
wdi create_project   # Interactive project creation with standards compliance
wdi doctor           # Check/install dependencies (git, gh, jq, claude)
wdi config           # Configure org, domains, project location
wdi update           # Update CLI to latest version
```

## Session Context

Save work-in-progress context to `docs/context/` when pausing a task. Files here help resume work across sessions.

To resume: "Read docs/context/{filename}.md and continue"

## GitHub Actions Templates

Workflow templates for common CI/CD tasks. Copy to your project's `.github/workflows/`.

### Daily Changelog

Automatically generate daily summaries of commits.

| Template | Description |
|----------|-------------|
| `docs/templates/workflows/daily-changelog.yml` | Simple bash-based (free, reliable) |
| `docs/templates/workflows/daily-changelog-claude.yml` | Claude-enhanced (smarter summaries, requires API key) |

**Setup (Bash version):**
1. Copy `docs/templates/workflows/daily-changelog.yml` to `.github/workflows/`
2. Enable write permissions: Settings > Actions > General > Workflow permissions

**Setup (Claude-enhanced):**
1. Copy `docs/templates/workflows/daily-changelog-claude.yml` to `.github/workflows/`
2. Add `ANTHROPIC_API_KEY` secret (get one at console.anthropic.com)
3. Enable write permissions: Settings > Actions > General > Workflow permissions

## Dependencies

This plugin requires the `compound-engineering` plugin for:
- Research agents (repo-research-analyst, git-history-analyzer, etc.)
- Review agents (code-simplicity-reviewer, security-sentinel, etc.)
- Workflow skills (plan, work, review, compound)

## Key Standards

When working in WDI projects, follow these conventions:

| Topic | Convention |
|-------|------------|
| Repo names | No `wdi-` prefix (org provides context) |
| Command prefix | `/wdi-*` (prevents conflicts with 3rd-party) |
| Mono-repos | `{cluster}-ops` (marketing-ops, business-ops) |
| Plugins | `dev-plugins-{domain}` standalone repos |
| Branches | `feature/`, `fix/`, `hotfix/`, `docs/`, `experiment/` |
| Commits | `feat:`, `fix:`, `docs:`, `refactor:`, `chore:` |

Full details in `docs/standards/` and quick reference in `knowledge/standards-summary.md`.

## How It Works

Claude Code plugins use markdown files as command definitions. When you run `/wdi-workflows:feature`:
1. Claude Code finds `commands/feature.md` via `plugin.json`
2. Loads the markdown as instructions
3. Executes the workflow steps described in the markdown

Skills work similarly but auto-invoke based on context. When you say "commit these changes", Claude loads `skills/commit/SKILL.md` and follows the workflow.

The markdown files contain both documentation AND executable instructions for Claude.

## Development Workflow

### Commands and Skills
1. **Edit command files** in `/commands/*.md` or skill files in `/skills/*/SKILL.md`
2. **Test locally** - Changes take effect immediately in this project
3. **Push to GitHub** - Other projects can then update via `./install.sh update`

### Testing Hooks

Hooks require special handling because they only fire when the plugin is properly loaded:

```bash
# Start Claude Code with plugin loaded from current directory
claude --plugin-dir .
```

**Important:**
- Hooks (e.g., `pre-tool-standards-check.sh`) need the `--plugin-dir` flag to activate
- Restart Claude Code after modifying `hooks/hooks.json` or hook scripts
- Commands and skills work immediately without restart

### Unit Testing Hook Scripts

Run script tests before committing hook changes:

```bash
./scripts/test-hooks.sh
```

This validates hook behavior without needing a full Claude Code session.

## Key Files

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin metadata, version, command registration |
| `install.sh` | Bootstrap script for installing in other projects |
| `commands/*.md` | Command definitions (these ARE the implementation) |
| `docs/standards/*.md` | Development standards documents |
| `knowledge/*.md` | Quick reference for commands |
| `hooks/hooks.json` | SessionStart hook to check dependencies |

## Version

Current version: 0.1.3 (see `.claude-plugin/plugin.json`)

### Versioning Policy

This plugin uses [semantic versioning](https://semver.org/). During `0.x.x` development:

| Bump | When to use |
|------|-------------|
| `patch` | Bug fixes, small enhancements, documentation |
| `minor` | New features, breaking changes |
| `major` | Reserved for `1.0.0` (production-ready release) |

The commit skill automatically handles version bumps based on commit type:
- `fix:`, `perf:` → auto-bump patch
- `feat:`, `refactor:` → prompts for minor/patch/none
- `docs:`, `chore:`, `test:`, `style:` → no bump

Run manually: `./scripts/bump-version.sh [patch|minor|major]`
