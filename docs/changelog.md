# Changelog

All notable changes documented here.

---

## 2026-01-12

### Added
- **Enhanced-Ralph command (v0.1.2)** - Quality-gated feature execution with research agents and type-specific reviews. Detects 8 task types (ui, database, api, security, data, test, config, external), invokes appropriate research/review agents, and enforces quality gates per task. Supports `--strict`, `--fast`, `--skip-gates`, and `--continue` flags
- **Milestone command (v0.1.2)** - Create and manage milestones that group related features for delivery. Execute entire milestones with `--milestone` flag on enhanced-ralph
- **Milestone mode for enhanced-ralph** - Execute all features in a milestone sequentially with automatic dependency resolution via topological sort. Detects circular dependencies, cross-milestone dependencies, and supports `--force` to proceed despite incomplete prerequisites
- **Test fixtures** - 8 feature files and 5 milestone files for testing dependency resolution, circular detection, and cross-milestone scenarios
- **Test runner script** - `scripts/test-enhanced-ralph.sh` documents 10 test scenarios and 5 edge cases for manual verification
- **Showcase page** - Visual guide at `docs/showcase/enhanced-ralph-guide.html` explaining the workflow with Terminal Noir aesthetic
- **Enhanced Ralph logo illustration** - CSS-only Looney Toons-inspired hero image at `docs/showcase/enhanced-ralph-logo.html` featuring BoneMonkey riding Ralph as a rocket ship with animated flame and catchphrase
- **Enhanced Ralph marketing site** - Full marketing page at `docs/showcase/enhanced-ralph-marketing.html` with pipeline visualization, features grid, and "Sorry folks, I'm all outta bubble gum!" messaging
- **BoneMonkey infographic update** - Refreshed `docs/showcase/bonemonkey-infographic.html` with Enhanced Ralph branding and "Speed of Imagination" theme
- **Auto-update-docs skill (v0.1.1)** - Say "update the docs" to detect and fix documentation drift. Finds undocumented commands/skills and version mismatches, then updates CLAUDE.md and README.md tables automatically
- **Semantic versioning (v0.1.0)** - Plugin now uses proper semver starting at 0.1.0 for pre-production development. Version bumps are integrated into the commit skill with smart detection: fixes auto-bump patch, features prompt for minor/patch/none
- **CI validation on every PR** - GitHub Actions validates JSON syntax, plugin structure, script permissions, and runs hook unit tests
- **Hook script unit tests** - `./scripts/test-hooks.sh` validates hook behavior without needing a Claude Code session
- **Development workflow docs** - CLAUDE.md and troubleshooting.md now explain how to test hooks during plugin development

### Changed
- **Smarter feature workflow** - Claude now assesses complexity and suggests target subproject after research, reducing upfront questions from 5 to 3
- **Renamed `new-package` to `new-subproject`** - clearer terminology for mono-repo components
- **Commit skill now enforced** - Direct `git commit` blocked by PreToolUse hook; must use commit skill for changelog updates and quality gates

---

## 2026-01-11

### Breaking Change
- **Commit workflow is now a skill** - say "commit these changes" instead of running `/wdi-workflows:commit`. Same quality gates (tests, review, changelog) but smoother UX.

### Added - `wdi` CLI
- **Standards-aware project creation from terminal** - `wdi create_project` guides you through naming before Claude Code even starts, preventing misnamed directories
- **Environment doctor** - `wdi doctor` checks and installs dependencies (git, gh, jq, claude) using your package manager
- **Configurable domains** - `wdi config` lets you set business domains, plugin domains, GitHub org - values populate interview choices
- **Full interview flow** - same REPO-STANDARDS.md compliance as `/wdi-workflows:new-repo` but works pre-Claude-Code
- **Exception tracking** - non-standard names get documented with reasons, issues created for standard reviews

Install: `curl -sSL .../scripts/wdi | bash -s install`

### Fixed
- Skills now auto-invoke properly - directory wasn't registered in plugin.json
- Changelog entries now guide toward impact over description - prevents generic "added X" entries
- Missing plugin warnings now stand out - added emoji and indentation so they're not buried in output

### Standards Update Protocol
- **Safer standards changes** - `/wdi-workflows:update-standard` analyzes ripple effects before you modify a standard, preventing broken references across docs and commands
- **Dependency visibility** - map shows which files depend on each standard so you know what breaks

### Standards Framework
- **Consistent naming across repos** - standards for repos, branches, commits, files prevent bike-shedding and make navigation predictable
- **Faster issue creation** - templates pre-fill structure so you focus on content
- **Scaffolding commands** - `/wdi-workflows:new-repo` and `/wdi-workflows:new-subproject` apply standards automatically

### Enhanced Workflows
- **Interview-driven scaffolding** - `new-repo`, `new-subproject`, and `feature` commands ask adaptive questions instead of requiring you to remember flags
- **Exception tracking** - non-standard names get documented with reasons, creating a paper trail for future standard updates

### Changed
- **Plugin renamed** from `claude-workflows` to `wdi-workflows` - `wdi-` prefix prevents conflicts with third-party plugins
- **Repository renamed** from `wdi-workflows` to `dev-plugins-workflows` - follows `dev-plugins-*` pattern for Claude Code plugins
- **Branch validation on commit** - catches non-standard branch names before they pollute git history
- **Pre-flight checks on feature** - validates repo setup before starting work, preventing wasted effort

---

## 2026-01-10

### Added
- **One-command install** - `install.sh` bootstraps the plugin in any project
- **Live plugin development** - marketplace.json lets you test changes without reinstalling
- **Missing dependency warnings** - SessionStart hook alerts immediately if required plugins aren't installed

### Changed
- **Smoother workflows** - bypassPermissions removes confirmation prompts for trusted operations

---

## 2026-01-09

### Added
- **Feature workflow** - 5-phase compound engineering: pre-flight → research → plan → work → review
- **Commit workflow** - quality gates (tests, simplicity review) before every commit
- **Setup verification** - `/wdi-workflows:setup` confirms dependencies are installed
