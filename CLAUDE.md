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
│   ├── triage-ideas.md              # /wdi:triage-ideas
│   ├── shape-idea.md                # /wdi:shape-idea
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
│   ├── check-deps.sh                # Dependency checker + auto-update
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
| `/wdi:triage-ideas` | Review unshaped ideas, identify clusters, recommend shaping approach |
| `/wdi:shape-idea` | Iterative shaping session for an idea (produces committed plan file) |

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
| `workflow-commit` | "commit these changes" | Smart commit with tests, auto-docs, and changelog |
| `workflow-auto-docs` | "update the docs" | Detect and fix documentation drift when commands/skills change |
| `workflow-config-sync` | "check my config" | Validate environment and auto-remediate drift |

> **IMPORTANT:** Always use the commit skill instead of running `git commit` directly.
> The skill ensures tests pass, documentation stays in sync, and changelog is updated.

> **SYNC REQUIRED:** The commit skill requires your local branch to be in sync with origin/main.
> If behind, it will abort and ask you to `git pull` first. This prevents version regression
> and accidentally overwriting remote commits. See #58 for why this gate exists.

## Dependencies

This plugin requires the `compound-engineering` plugin (external dependency):
- `/workflows:plan` - Creates implementation plans (includes research agents)
- `/workflows:work` - Implements plans step-by-step with todo tracking
- `/workflows:review` - Runs 12+ review agents in parallel, creates prioritized todos
- `/workflows:compound` - Documents learnings in `docs/solutions/`

**Installation:** compound-engineering is installed globally via marketplace, not vendored.

**Note:** wdi delegates to compound-engineering for all heavy lifting. wdi provides context gathering (interview), validation (pre-flight), GitHub issue integration, and workflow orchestration.

### Installation Scope

Plugins can be installed at **user scope** (global) or **project scope** (local). For personal workstations, global installation is recommended:

```bash
# Global installation (recommended - works across all projects)
claude plugin install compound-engineering@every-marketplace --scope user
claude plugin install wdi@wdi-marketplace --scope user
```

Scripts like `check-deps.sh` and `validate-env.sh` automatically detect your installation scope and use it for updates and remediation. See [Troubleshooting: Installation Scopes](docs/troubleshooting.md#installation-scopes) for details.

> **DRIFT PREVENTION:** Never create `.claude/settings.json` files in project directories. If `claude plugin list` shows duplicate installations (same plugin at both user and project scope), the SessionStart hook will auto-remove the project-scope one. All plugins should be user-scope only.

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

Ideas flow through these stages:
- **Capture:** Issue body contains problem, appetite, rough solution, open questions
- **Shape:** Use `/wdi:shape-idea` for iterative exploration (or add comments with prefixes)
- **Triage:** Periodically run `/wdi:triage-ideas` to review unshaped ideas
- **Promote:** When ready, run `/wdi:workflows-feature --promote #123`

### Shaping with Plan Files (Recommended)

For ideas that need exploration before implementation, use iterative shaping sessions:

```bash
# Explore from business perspective
/wdi:shape-idea #45 --perspective business

# Later, explore from technical perspective
/wdi:shape-idea #45 --perspective technical

# Optionally, explore UX implications
/wdi:shape-idea #45 --perspective ux
```

**What happens:**
1. Claude enters plan mode to explore the idea from the chosen perspective
2. Produces a committed plan file: `.claude/plans/idea-{n}-{perspective}-{date}.md`
3. Adds a summary comment to the GitHub issue linking to the plan file

**Perspectives:**
| Perspective | Focus Areas |
|-------------|-------------|
| `business` | Value proposition, appetite, ROI, business risks |
| `technical` | Feasibility, architecture, complexity, technical risks |
| `ux` | User needs, workflows, accessibility, edge cases |

Each session produces a separate file, building rich context for promotion.

### Shaping Comment Prefixes (Lightweight)

For simple shaping, add comments directly to the issue with recognized prefixes:

| Prefix | Maps to | Example |
|--------|---------|---------|
| `Decision:` | Research context | "Decision: Use YAML frontmatter" |
| `Test:` | Acceptance criteria | "Test: Verify API returns 200" |
| `Blocked:` | Dependencies | "Blocked: Waiting on #45" |

Comments without prefixes are for human discussion and are ignored.

**Conflict detection:** If two `Decision:` comments contradict each other, promotion halts and requires human resolution.

### Promotion as Onramp

`--promote` is an **onramp** to the full workflow, not a bypass. The idea content pre-populates context, but all phases still run:

```
Promote → Interview (pre-filled) → Pre-flight → Plan → Work → Review → Compound
```

When promoting, the workflow reads context from:
1. **Issue body** - Original problem, appetite, rough solution
2. **Shaping plan files** - Decisions, risks, scope from `.claude/plans/idea-{n}-*.md`
3. **Issue comments** - `Decision:`, `Test:`, `Blocked:` prefixes

| Status | Location | Next Step |
|--------|----------|-----------|
| Idea | GitHub Issue | Shape with `/wdi:shape-idea` or comments |
| Feature | Full workflow with pre-populated context | All phases run |
| Complete | Merged to main | - |

**Promote an idea to a feature:**
```bash
/wdi:workflows-feature --promote #123
```

> **Planned:** PR-based Review phase is being shaped in [#33](https://github.com/whitedoeinn/dev-plugins-workflow/issues/33). Currently all commits go directly to main with quality gates.

## Environment Validation

On every session start, the plugin:

1. **Validates environment** against `env-baseline.json`:
   - Required plugins (compound-engineering)
   - Required CLI tools (gh, jq) with auto-install
   - Authentication (gh auth status)

2. **Auto-updates wdi plugin** from marketplace:
   - Runs `claude plugin update wdi@wdi-marketplace`
   - Skipped in maintainer mode (when working in this repo)
   - Ensures consuming projects always have latest version

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
3. **Push to GitHub** - Other projects auto-update on next session start

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
| `commands/*.md` | Command definitions (these ARE the implementation) |
| `docs/standards/*.md` | Development standards documents |
| `hooks/hooks.json` | SessionStart hook to check dependencies |

## Version

Current version: See `.claude-plugin/plugin.json`

### Versioning Policy

**Every commit bumps the version.** Claude Code caches plugins by version, so without a bump, updates don't propagate.

| Commit type | Version bump |
|-------------|--------------|
| `feat:` | Patch (or minor for significant features) |
| `fix:`, `perf:` | Patch |
| `docs:`, `chore:`, `refactor:`, `test:`, `style:` | Patch |

The commit skill automatically handles version bumps. Always use the commit skill for plugin changes.

### Pre-Commit Hook (Optional Safety Net)

Install the pre-commit hook to catch version bump issues locally:

```bash
cp scripts/pre-commit-version-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

This blocks commits that don't include a version bump, reminding you to use the commit skill.

### CI Enforcement (Required)

GitHub Actions enforces version bumps on every push to main. If you forget to bump:

1. CI fails with clear error message
2. Fix with:
   ```bash
   ./scripts/bump-version.sh patch
   git add .claude-plugin/
   git commit -m "chore: Bump version"
   git push
   ```

This catches issues even if the pre-commit hook isn't installed locally.

### How Updates Work

1. Commit using the commit skill (auto-bumps version, creates git tag)
2. Push to GitHub (skill pushes tag automatically)
3. Consuming projects: restart Claude → SessionStart hook runs `claude plugin update`
4. Restart Claude again to load the new version

### If Updates Aren't Propagating

See [Plugin Version Propagation Troubleshooting](docs/troubleshooting.md#plugin-updates-not-propagating-to-other-projects).

Recent changes:
- Added `/wdi:shape-idea` for iterative idea shaping with committed plan files
- Enhanced `--promote` to synthesize context from shaping plan files and issue comments
- **#40:** Aligned wdi workflow with compound-engineering (removed duplicate research, delegated to /workflows:plan, /workflows:work, /workflows:review, /workflows:compound)
- **#30:** Added idea promotion workflow with prescriptive comment prefixes and conflict detection
