# WDI Plugin

## Project Overview

This is the source repository for the `wdi` Claude Code plugin. It provides:
- Compound-engineering workflows for feature development
- Smart commit workflows with quality gates
- Development standards and project scaffolding
- Repository and subproject creation commands

**Architecture:** See `docs/standards/PLUGIN-ARCHITECTURE.md` for the one-plugin policy and naming conventions.

## Structure

```
dev-plugins/
├── commands/                        # Markdown-based command definitions
│   ├── workflows-feature.md         # /wdi:workflows-feature
│   ├── workflows-enhanced-ralph.md  # /wdi:workflows-enhanced-ralph
│   ├── workflows-milestone.md       # /wdi:workflows-milestone
│   ├── workflows-setup.md           # /wdi:workflows-setup
│   ├── standards-new-repo.md        # /wdi:standards-new-repo
│   ├── standards-new-subproject.md  # /wdi:standards-new-subproject
│   ├── standards-check.md           # /wdi:standards-check
│   ├── standards-update.md          # /wdi:standards-update
│   └── standards-new-command.md     # /wdi:standards-new-command
├── .claude-plugin/                  # Plugin configuration
│   ├── plugin.json                  # Plugin metadata (name: "wdi")
│   └── marketplace.json             # Local marketplace config
├── hooks/                           # Claude Code hooks
│   └── hooks.json                   # SessionStart hook config
├── scripts/                         # Helper scripts
│   ├── wdi                          # Global CLI for project bootstrapping
│   ├── vendor-to-project.sh         # Vendor plugin to target project
│   ├── check-deps.sh                # Dependency and standards checker
│   ├── validate-env.sh              # Environment validation
│   └── ...
├── env-baseline.json                # Environment baseline definition
├── docs/
│   ├── standards/                   # Development standards
│   │   ├── PLUGIN-ARCHITECTURE.md   # One-plugin policy
│   │   ├── REPO-STANDARDS.md
│   │   └── ...
│   ├── templates/
│   └── ...
├── skills/                          # Auto-invoked skills
│   ├── workflow-commit/             # Smart commit (say "commit these changes")
│   ├── workflow-auto-docs/          # Doc sync (say "update the docs")
│   └── config-sync/                 # Environment validation (say "check my config")
└── install.sh                       # Bootstrap installation script
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/wdi:workflows-feature` | Full feature workflow (pre-flight → research → plan → work → review → compound) |
| `/wdi:workflows-feature --idea` | Quick idea capture (creates idea file + draft issue, no implementation) |
| `/wdi:workflows-feature --plan` | Stop after planning phase |
| `/wdi:workflows-enhanced-ralph` | Quality-gated feature execution with research agents and type-specific reviews |
| `/wdi:workflows-milestone` | Create and execute milestone-based feature groupings |
| `/wdi:workflows-setup` | Verify dependencies and installation status |

### Standards Commands

| Command | Description |
|---------|-------------|
| `/wdi:standards-new-repo` | Create repository following WDI naming standards |
| `/wdi:standards-new-subproject` | Add subproject to mono-repo following standards |
| `/wdi:standards-check` | Validate current repo against standards |
| `/wdi:standards-update` | Impact analysis and guided updates for standard changes |
| `/wdi:standards-new-command` | Create a new command and update all dependent files |

### Skills (Auto-Invoked)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `workflow-commit` | "commit these changes" | Smart commit with tests, simplicity review, and changelog |
| `workflow-auto-docs` | "update the docs" | Detect and fix documentation drift when commands/skills change |
| `config-sync` | "check my config" | Validate environment and auto-remediate drift |

> **IMPORTANT:** Always use the commit skill instead of running `git commit` directly.
> The skill ensures changelog updates, runs tests, and performs simplicity review.
> A PreToolUse hook will warn if you try to run `git commit` directly.

## Dependencies

This plugin requires the `compound-engineering` plugin (external dependency):
- Research agents (repo-research-analyst, git-history-analyzer, etc.)
- Review agents (code-simplicity-reviewer, security-sentinel, etc.)
- Workflow skills (plan, work, review, compound)

**Installation:** compound-engineering is installed globally via marketplace, not vendored.

## WDI CLI (Pre-Claude-Code)

The `wdi` CLI runs **before** Claude Code starts, solving the problem of creating directories without knowing naming standards.

```bash
# Install globally
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins/main/scripts/wdi | bash -s install

# Commands
wdi create_project   # Interactive project creation with standards compliance
wdi doctor           # Check/install dependencies (git, gh, jq, claude)
wdi config           # Configure org, domains, project location
wdi update           # Update CLI to latest version
```

## Idea Capture Workflow

Use `--idea` mode to quickly capture ideas without implementing them:

```bash
/wdi:workflows-feature --idea
```

**Creates:**
- Idea file: `docs/product/ideas/{slug}.md`
- Draft issue: GitHub issue with `idea` type label and `status:needs-shaping`

**Lifecycle:**
```
Capture → Shape → Plan → Build
```

| Status | Location | Next Step |
|--------|----------|-----------|
| Idea | `docs/product/ideas/` | Shape when ready |
| Shaping | `docs/product/shaping/` | Research and design |
| Planning | `docs/product/planning/features/` | Ready to build |

**Promote an idea to a feature:**
```bash
/wdi:workflows-feature @docs/product/ideas/{slug}.md
```

## Environment Validation

On every session start, the plugin validates your environment against `env-baseline.json`:

1. **Required plugins** - Checks compound-engineering is installed
2. **Required CLI tools** - Checks for gh, jq, and auto-installs if possible
3. **Authentication** - Checks gh auth status

### Validation Outcomes

| State | What Happens |
|-------|--------------|
| Valid | Brief confirmation message |
| Auto-fixed | Shows what was fixed, then confirms valid |
| Blocked | Shows issues, remediation steps, and admin contact |

### Manual Re-validation

Say "check my config" to run validation manually (useful after fixing issues).

## Key Standards

When working in WDI projects, follow these conventions:

| Topic | Convention |
|-------|------------|
| Repo names | No `wdi-` prefix (org provides context) |
| Command prefix | `/wdi:` (single internal plugin) |
| Domain prefixes | `workflows-`, `standards-`, `frontend-`, etc. |
| Mono-repos | `{cluster}-ops` (marketing-ops, business-ops) |
| Branches | `feature/`, `fix/`, `hotfix/`, `docs/`, `experiment/` |
| Commits | `feat:`, `fix:`, `docs:`, `refactor:`, `chore:` |

Full details in `docs/standards/` and `docs/standards/PLUGIN-ARCHITECTURE.md`.

## How It Works

Claude Code plugins use markdown files as command definitions. When you run `/wdi:workflows-feature`:
1. Claude Code finds `commands/workflows-feature.md` via `plugin.json`
2. Loads the markdown as instructions
3. Executes the workflow steps described in the markdown

Skills work similarly but auto-invoke based on context. When you say "commit these changes", Claude loads `skills/workflow-commit/SKILL.md` and follows the workflow.

## Development Workflow

### Commands and Skills
1. **Edit command files** in `/commands/*.md` or skill files in `/skills/*/SKILL.md`
2. **Test locally** - Changes take effect immediately in this project
3. **Push to GitHub** - Other projects can then update via `./scripts/update-plugins.sh`

### Testing Hooks

Hooks require special handling because they only fire when the plugin is properly loaded:

```bash
# Start Claude Code with plugin loaded from current directory
claude --plugin-dir .
```

**Important:**
- Hooks need the `--plugin-dir` flag to activate
- Restart Claude Code after modifying `hooks/hooks.json` or hook scripts
- Commands and skills work immediately without restart

## Key Files

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin metadata, version, command registration |
| `scripts/vendor-to-project.sh` | Vendor plugin to target projects |
| `commands/*.md` | Command definitions (these ARE the implementation) |
| `docs/standards/*.md` | Development standards documents |
| `hooks/hooks.json` | SessionStart hook to check dependencies |

## Version

Current version: 1.0.0 (see `.claude-plugin/plugin.json`)

This is a major version representing the architecture change from `wdi-workflows` to `wdi`.

### Versioning Policy

This plugin uses [semantic versioning](https://semver.org/):

| Bump | When to use |
|------|-------------|
| `patch` | Bug fixes, small enhancements, documentation |
| `minor` | New features, new commands/skills |
| `major` | Breaking changes (command renames, removals) |

The commit skill automatically handles version bumps based on commit type.
