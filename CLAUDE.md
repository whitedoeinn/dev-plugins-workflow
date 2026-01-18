# WDI Plugin

## Project Overview

This is the source repository for the `wdi` Claude Code plugin. It provides:
- Compound-engineering workflows for feature development
- Smart commit workflows with quality gates
- Development standards and project scaffolding
- Repository and subproject creation commands

**Architecture:** See `docs/standards/PLUGIN-ARCHITECTURE.md` for the one-plugin policy and naming conventions.

## Shell Functions

### `ip` - Improve Prompt

When the user's message starts with `ip ` followed by text, immediately run the `ip` shell function via Bash, passing the text exactly as provided (preserving any quotes):

```bash
ip "user's text here"
```

**Example:** If user says `ip "write a blog post about AI"`, run:
```bash
ip "write a blog post about AI"
```

The function pipes input through `fabric-ai --pattern improve_prompt`, streams output, and copies the result to clipboard.

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
│   ├── vendor-to-project.sh         # Vendor plugin to target project
│   ├── check-deps.sh                # Dependency and standards checker
│   ├── validate-env.sh              # Environment validation
│   ├── run-tests.sh                 # Run unit + integration tests
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
│   └── workflow-config-sync/        # Environment validation (say "check my config")
└── install.sh                       # Bootstrap installation script
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/wdi:workflows-feature` | Full feature workflow (interview → pre-flight → plan → work → review → compound) |
| `/wdi:workflows-feature --idea` | Quick idea capture (creates GitHub issue, no implementation) |
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
| `workflow-config-sync` | "check my config" | Validate environment and auto-remediate drift |

> **IMPORTANT:** Always use the commit skill instead of running `git commit` directly.
> The skill ensures changelog updates, runs tests, and performs simplicity review.

## Dependencies

This plugin requires the `compound-engineering` plugin (external dependency):
- `/workflows:plan` - Creates implementation plans (includes research agents)
- `/workflows:work` - Implements plans step-by-step with todo tracking
- `/workflows:review` - Runs 12+ review agents in parallel, creates prioritized todos
- `/workflows:compound` - Documents learnings in `docs/solutions/`

**Installation:** compound-engineering is installed globally via marketplace, not vendored.

**Note:** wdi delegates to compound-engineering for all heavy lifting. wdi provides context gathering (interview), validation (pre-flight), GitHub issue integration, and workflow orchestration.

## WDI CLI (Deprecated)

> **Note:** The wdi CLI is deprecated. Claude Code can create directories and projects directly - just describe what you want. The CLI remains available but is no longer actively maintained.

```bash
# Legacy install (deprecated)
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/wdi | bash -s install

# Commands (deprecated)
wdi create_project   # Use Claude directly instead
wdi doctor           # Check/install dependencies
wdi config           # Configure org, domains, project location
wdi update           # Update CLI to latest version
```

## Idea Capture Workflow

Use `--idea` mode to quickly capture ideas without implementing them:

```bash
/wdi:workflows-feature --idea
```

**Creates:** GitHub issue with `idea` label and `status:needs-shaping`

Ideas live entirely in GitHub Issues:
- **Capture:** Issue body contains problem, appetite, rough solution, open questions
- **Shape:** Add comments using prefixes (see below)
- **Promote:** When ready, run `/wdi:workflows-feature --promote #123`

### Shaping Comment Prefixes

Comments are only parsed during promotion if they start with a recognized prefix. Comments without prefixes are for human discussion and are ignored.

| Prefix | Maps to | Example |
|--------|---------|---------|
| `Decision:` | Research context | "Decision: Use YAML frontmatter" |
| `Test:` | Acceptance criteria | "Test: Verify API returns 200" |
| `Blocked:` | Dependencies | "Blocked: Waiting on #45" |

**Conflict detection:** If two `Decision:` comments contradict each other, promotion halts and requires human resolution.

### Promotion as Onramp

`--promote` is an **onramp** to the full workflow, not a bypass. The idea content pre-populates context, but all phases still run:

```
Promote → Interview (pre-filled) → Pre-flight → Plan → Work → Review → Compound
```

| Status | Location | Next Step |
|--------|----------|-----------|
| Idea | GitHub Issue | Shape via comments |
| Feature | Full workflow with pre-populated context | All phases run |
| Complete | Merged to main | - |

**Promote an idea to a feature:**
```bash
/wdi:workflows-feature --promote #123
```

> **Planned:** PR-based Review phase is being shaped in [#33](https://github.com/whitedoeinn/dev-plugins-workflow/issues/33). Currently all commits go directly to main with quality gates.

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

### Testing

Run tests before pushing:

```bash
./scripts/run-tests.sh
```

Tests include:
- **Unit tests** (BATS) - Test individual script functions
- **Integration tests** - Validate plugin structure and command parsing

CI runs these automatically on every push/PR. No Docker or E2E infrastructure needed - keep it simple.

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

Current version: 0.3.0 (see `.claude-plugin/plugin.json`)

Recent changes:
- **#40:** Aligned wdi workflow with compound-engineering (removed duplicate research, delegated to /workflows:plan, /workflows:work, /workflows:review, /workflows:compound)
- **#30:** Added idea promotion workflow with prescriptive comment prefixes and conflict detection

### Versioning Policy

This plugin uses [semantic versioning](https://semver.org/):

| Bump | When to use |
|------|-------------|
| `patch` | Bug fixes, small enhancements, documentation |
| `minor` | New features, new commands/skills |
| `major` | Breaking changes (command renames, removals) |

The commit skill automatically handles version bumps based on commit type.
