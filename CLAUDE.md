# WDI Workflows Plugin

## Project Overview

This is the source repository for the `wdi-workflows` Claude Code plugin. It provides:
- Compound-engineering workflows for feature development
- Smart commit workflows with quality gates
- Development standards and project scaffolding
- Repository and package creation commands

## Structure

```
dev-plugins-workflows/
├── commands/               # Markdown-based command definitions
│   ├── feature.md          # /wdi-workflows:feature workflow
│   ├── setup.md            # /wdi-workflows:setup verification
│   ├── new-repo.md         # /wdi-workflows:new-repo scaffolding
│   ├── new-package.md      # /wdi-workflows:new-package scaffolding
│   ├── check-standards.md  # /wdi-workflows:check-standards validation
│   ├── update-standard.md  # /wdi-workflows:update-standard impact analysis
│   └── new-command.md      # /wdi-workflows:new-command workflow
├── .claude-plugin/         # Plugin configuration
│   ├── plugin.json         # Plugin metadata
│   └── marketplace.json    # Local marketplace config
├── hooks/                  # Claude Code hooks
│   └── hooks.json          # SessionStart hook config
├── scripts/                # Helper scripts
│   ├── check-deps.sh       # Dependency and standards checker
│   ├── pre-tool-standards-check.sh  # PreToolUse hook for standards detection
│   ├── validate-dependency-map.sh   # Validates dependency map accuracy
│   └── get-standard-deps.sh         # Helper for parsing dependency map
├── docs/                   # Documentation
│   ├── standards/          # Development standards
│   │   ├── REPO-STANDARDS.md
│   │   ├── PROJECT-STRUCTURE.md
│   │   ├── FILE-NAMING.md
│   │   ├── BRANCH-NAMING.md
│   │   ├── COMMIT-STANDARDS.md
│   │   └── CLAUDE-CODE-STANDARDS.md
│   ├── architecture.md
│   ├── troubleshooting.md
│   └── changelog.md
├── knowledge/              # Reference docs for commands
│   ├── standards-summary.md
│   └── decision-trees/
│       ├── repo-type.md
│       └── package-location.md
├── skills/                 # Auto-invoked skills
│   └── commit/             # Smart commit skill (say "commit these changes")
│       └── SKILL.md
└── install.sh              # Bootstrap installation script
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/wdi-workflows:feature` | Full feature workflow (pre-flight → research → plan → work → review → compound) |
| `/wdi-workflows:setup` | Verify dependencies and installation status |

### Skills (Auto-Invoked)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `commit` | "commit these changes" | Smart commit with tests, simplicity review, and changelog |

### Standards Commands

| Command | Description |
|---------|-------------|
| `/wdi-workflows:new-repo` | Create repository following WDI naming standards |
| `/wdi-workflows:new-package` | Add package to mono-repo following standards |
| `/wdi-workflows:check-standards` | Validate current repo against standards |
| `/wdi-workflows:update-standard` | Impact analysis and guided updates for standard changes |
| `/wdi-workflows:new-command` | Create a new command and update all dependent files |

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

1. **Edit command files** in `/commands/*.md`
2. **Test locally** - Changes take effect immediately in this project
3. **Push to GitHub** - Other projects can then update via `./install.sh update`

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

Current version: 1.1.0 (see `.claude-plugin/plugin.json`)
