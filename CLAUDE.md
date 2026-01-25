# WDI Plugin

## Project Overview

This is the source repository for the `wdi` Claude Code plugin. It provides:
- Compound-engineering workflows for feature development
- Smart commit workflows with quality gates
- Development standards and project scaffolding
- Repository and subproject creation commands

**Architecture:** See `docs/standards/PLUGIN-ARCHITECTURE.md` for the one-plugin policy and naming conventions.

**Learnings:** Cross-project learnings are aggregated in [whitedoeinn/learnings](https://github.com/whitedoeinn/learnings). Learnings documented here via `/workflows:compound` are synced to the central repo for organization-wide discovery.

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
dev-plugins-workflow/
├── commands/                        # Markdown-based command definitions
│   ├── workflow-feature.md          # /wdi:workflow-feature
│   ├── workflow-enhanced-ralph.md   # /wdi:workflow-enhanced-ralph
│   ├── workflow-milestone.md        # /wdi:workflow-milestone
│   ├── workflow-setup.md            # /wdi:workflow-setup
│   ├── triage-ideas.md              # /wdi:triage-ideas
│   ├── standards-new-repo.md        # /wdi:standards-new-repo
│   ├── standards-new-subproject.md  # /wdi:standards-new-subproject
│   ├── standards-check.md           # /wdi:standards-check
│   ├── standards-update.md          # /wdi:standards-update
│   ├── standards-new-command.md     # /wdi:standards-new-command
│   └── frontend-setup.md            # /wdi:frontend-setup
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
├── assets/                          # Portable design assets
│   └── tokens/                      # Design tokens
│       ├── tokens.css               # CSS custom properties (import in projects)
│       └── tokens.json              # Machine-readable tokens
├── env-baseline.json                # Environment baseline definition
├── docs/
│   ├── COLLABORATOR-GUIDE.md        # New contributor onboarding (start here!)
│   ├── architecture.md              # System design diagrams
│   ├── troubleshooting.md           # Problem resolution
│   ├── standards/                   # Development standards
│   │   ├── PLUGIN-ARCHITECTURE.md   # One-plugin policy
│   │   ├── REPO-STANDARDS.md        # Repository conventions
│   │   ├── FRONTEND-STANDARDS.md    # UI/component standards
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
| `/wdi:workflow-feature` | Feature workflow - quick idea OR full build (Plan → Work → Review → Compound) |
| `/wdi:workflow-feature #N` | Continue existing issue from where it left off |
| `/wdi:workflow-enhanced-ralph` | Quality-gated feature execution with research agents and type-specific reviews |
| `/wdi:workflow-milestone` | Create and execute milestone-based feature groupings |
| `/wdi:workflow-setup` | Verify dependencies and installation status |
| `/wdi:triage-ideas` | Review idea backlog, identify clusters, prioritize |

### Standards Commands

| Command | Description |
|---------|-------------|
| `/wdi:standards-new-repo` | Create repository following WDI naming standards |
| `/wdi:standards-new-subproject` | Add subproject to mono-repo following standards |
| `/wdi:standards-check` | Validate current repo against standards |
| `/wdi:standards-update` | Impact analysis and guided updates for standard changes |
| `/wdi:standards-new-command` | Create a new command and update all dependent files |

### Frontend Commands

| Command | Description |
|---------|-------------|
| `/wdi:frontend-setup` | Install WDI design tokens to project (shadcn copy pattern) |

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

## Feature Workflow

One command for the entire feature lifecycle:

```bash
/wdi:workflow-feature              # Start something new
/wdi:workflow-feature #45          # Continue existing issue
```

### Two Entry Points

| Mode | Usage | What Happens |
|------|-------|--------------|
| **Quick idea** | "I have a thought" | One sentence → Issue created → Done (30 seconds) |
| **Build something** | "Let's do this" | Full workflow: Plan → Work → Review → Compound |

### The Issue IS the Document

No separate plan files or feature specs. The GitHub issue accumulates everything:

- **Body:** Updated with problem, solution, and plan
- **Comments:** Progress at each phase (learnings, plan, work, review, compound)
- **Labels:** Current phase (`phase:planning`, `phase:working`, etc.)
- **Close comment:** Final outcome and summary

### Continue From Where You Left Off

Resume any issue with `/wdi:workflow-feature #N`. The workflow reads the phase label and picks up where it stopped.

### Shaping Ideas

To add context to an idea before building:
1. Add comments to the issue (just regular comments)
2. When ready: `/wdi:workflow-feature #N` → "Start building"

No special prefixes or syntax. Just write what you're thinking.

## GitHub Issue Progress Sync

During `/wdi:workflow-feature`, the GitHub issue is updated at each significant milestone. This provides stakeholder visibility and creates an audit trail.

### Phase Labels

Issues are labeled with their current workflow phase for at-a-glance visibility:

| Label | Phase | Color |
|-------|-------|-------|
| `phase:planning` | Plan | Blue |
| `phase:working` | Work | Green |
| `phase:reviewing` | Review | Yellow |
| `phase:compounding` | Compound | Purple |

Labels are automatically added/removed as the workflow progresses. Filter issues by phase using `label:phase:planning`, etc.

### Milestone Updates

| Phase | Update Content |
|-------|----------------|
| **Learnings Search** | Related learnings found (or "novel work" if none) |
| **Plan** | Research summary, key decisions, risks, files to modify |
| **Work** | Implementation summary, test status, deviations from plan |
| **Review** | P1/P2/P3 counts with linked issues, blocking status |
| **Close** | Outcome (completed/modified/partial/abandoned), summary |

### Outcome Types

The close comment captures what actually happened:

| Outcome | When to Use |
|---------|-------------|
| ✓ **Completed as planned** | No P1s, no deviations |
| ✓ **Completed with modifications** | P1s resolved, or Work noted deviations |
| ⚠️ **Partially completed** | Some criteria unmet, follow-up issue created |
| ✗ **Abandoned** | Research/Review revealed "don't build this" |

### Example Issue Timeline

```
#123: Feature X
├── [Created] Plan phase
├── [Comment] Learnings Search - 2 related learnings
├── [Comment] Plan - research summary, 3 decisions
├── [Comment] Work - implemented, tests passing
├── [Comment] Review - 0 P1s, 2 P2s
├── [Comment] Compound - learnings documented
└── [Closed] Outcome: Completed as planned
```

## Learnings Architecture

Learnings documented via `/workflows:compound` flow through a two-tier system:

```
Source Repos                    Central Repo
─────────────                   ────────────
docs/solutions/  ──sync──►  whitedoeinn/learnings
                               ├── incoming/     (raw sync)
                               └── curated/      (triaged)
                                   ├── universal/
                                   ├── frontend/
                                   ├── backend/
                                   └── lob/{domain}/
```

**Sync:** Run `./scripts/sync-all.sh` in the learnings repo to pull from all configured source repos.

**Triage:** Move files from `incoming/` to appropriate `curated/` directory based on taxonomy.

**Search:** The Learnings Search phase queries both local `docs/solutions/` and central `learnings/curated/` before planning.

See [whitedoeinn/learnings](https://github.com/whitedoeinn/learnings) for full documentation.

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

### New Machine / Reset

For new machines or to reset a broken installation:

```bash
./scripts/machine-setup.sh
# Or: curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/machine-setup.sh | bash
```

This clears caches, removes stale project-scope entries, installs plugins at user scope, and creates `~/.claude/CLAUDE.md`. Safe to re-run.

## Key Standards

When working in WDI projects, follow these conventions:

| Topic | Convention |
|-------|------------|
| Repo names | No `wdi-` prefix (org provides context) |
| Command prefix | `/wdi:` (single internal plugin) |
| Domain prefixes | `workflow-`, `standards-`, `frontend-`, etc. |
| Mono-repos | `{cluster}-ops` (marketing-ops, business-ops) |
| Branches | `feature/`, `fix/`, `hotfix/`, `docs/`, `experiment/` |
| Commits | `feat:`, `fix:`, `docs:`, `refactor:`, `chore:` |
| Frontend | `docs/standards/FRONTEND-STANDARDS.md` |

**Standards Documents:**
- Repository: `docs/standards/REPO-STANDARDS.md`
- Issues (labels, sub-issues, living epics): `docs/standards/ISSUE-STANDARDS.md`
- Plugin architecture: `docs/standards/PLUGIN-ARCHITECTURE.md`
- Frontend (UI, components, tokens): `docs/standards/FRONTEND-STANDARDS.md`
- Design tokens: `assets/tokens/tokens.css`, `assets/tokens/tokens.json`

**Frontend Development:** When building UI components, reference `FRONTEND-STANDARDS.md` for:
- JSON Schema-first data patterns
- Design token usage
- Typography and spacing scales
- Component architecture (shadcn/ui)
- Accessibility requirements (WCAG 2.1 AA)
- Theme selection guidance

## How It Works

Claude Code plugins use markdown files as command definitions. When you run `/wdi:workflow-feature`:
1. Claude Code finds `commands/workflow-feature.md` via `plugin.json`
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

**Prerequisite:** BATS (Bash Automated Testing System) must be installed:
```bash
brew install bats-core  # macOS
```

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
- **Simplified workflow** - Removed --idea/--promote/shape-idea complexity. Now: quick idea OR build something, continue any issue with `#N`
- **#83:** Phase labels for at-a-glance visibility (`phase:planning/working/reviewing/compounding`)
- **#81:** Milestone comments at each phase for journey documentation
- **#40:** Delegated to compound-engineering (`/workflows:plan`, `/workflows:work`, `/workflows:review`, `/workflows:compound`)
