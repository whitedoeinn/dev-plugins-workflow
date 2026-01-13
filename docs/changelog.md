# Changelog

All notable changes documented here.

---

## 2026-01-13

### Added
- **Idea capture mode (v0.1.7)** - New `--idea` flag for `/wdi-workflows:feature` enables quick idea capture without implementation. Creates minimal idea file in `docs/product/ideas/` and draft GitHub issue with `status:idea` label. Includes `setup-labels.sh` script to create lifecycle labels (`status:idea`, `status:ready`, `appetite:*`, `needs:*`). Promote ideas to features when ready via `@docs/product/ideas/{slug}.md`

### Changed
- **Cleaner CLI flags (v0.1.6)** - Renamed feature command flag `--plan-only` → `--plan` (simpler). Added `-y` short form for `--yes`. Old flag still works as alias for backwards compatibility

---

## 2026-01-12

### Changed
- **Cleaner CLI flags (v0.1.6)** - Renamed feature command flags based on CLI best practices research. `--capture` → `--idea` (matches lifecycle terminology), `--plan-only` → `--plan` (simpler). Added `-y` short form for `--yes`. Old flags still work as aliases for backwards compatibility

### Added
- **Auto-mark feature specs complete (v0.1.5)** - Feature workflow compound phase now automatically marks feature specification files as complete, updating status and checkboxes. No more manual cleanup after merging features
- **Environment consistency validation (v0.1.4)** - Automatic environment validation on every session start. Checks required plugins and CLI tools against `env-baseline.json`, auto-remediates fixable issues (missing plugins, jq), and blocks with clear guidance for unfixable issues (gh auth). Say "check my config" to manually re-validate. Foundation for future "safety scissor" mode for non-developer users
- **sync-config skill** - Auto-invokes on "check my config" to validate environment against baseline with detailed output
- **Component labels for GitHub issues** - `component:cli`, `component:hooks`, `component:commands`, `component:skills`, `component:standards`, `component:core` for filtering issues by area
- **Daily changelog GitHub Action templates** - Two workflow templates for automatic daily commit summaries. Bash version (free, reliable) and Claude-enhanced version (smarter AI summaries). Both run at midnight ET with manual trigger support. Located in `docs/templates/workflows/`
- **Enhanced-Ralph command (v0.1.2)** - Quality-gated feature execution with research agents and type-specific reviews. Detects 8 task types (ui, database, api, security, data, test, config, external), invokes appropriate research/review agents, and enforces quality gates per task. Supports `--strict`, `--fast`, `--skip-gates`, and `--continue` flags
- **Milestone command (v0.1.2)** - Create and manage milestones that group related features for delivery. Execute entire milestones with `--milestone` flag on enhanced-ralph
- **Milestone mode for enhanced-ralph** - Execute all features in a milestone sequentially with automatic dependency resolution via topological sort. Detects circular dependencies, cross-milestone dependencies, and supports `--force` to proceed despite incomplete prerequisites
- **Test fixtures** - 8 feature files and 5 milestone files for testing dependency resolution, circular detection, and cross-milestone scenarios
- **Test runner script** - `scripts/test-enhanced-ralph.sh` documents 10 test scenarios and 5 edge cases for manual verification
- **Showcase page** - Visual guide at `docs/showcase/enhanced-ralph-guide.html` explaining the workflow with Terminal Noir aesthetic
- **Auto-update-docs skill (v0.1.1)** - Say "update the docs" to detect and fix documentation drift. Finds undocumented commands/skills and version mismatches, then updates CLAUDE.md and README.md tables automatically
- **Semantic versioning (v0.1.0)** - Plugin now uses proper semver starting at 0.1.0 for pre-production development. Version bumps are integrated into the commit skill with smart detection: fixes auto-bump patch, features prompt for minor/patch/none
- **CI validation on every PR** - GitHub Actions validates JSON syntax, plugin structure, script permissions, and runs hook unit tests
- **Hook script unit tests** - `./scripts/test-hooks.sh` validates hook behavior without needing a Claude Code session
- **Development workflow docs** - CLAUDE.md and troubleshooting.md now explain how to test hooks during plugin development
- **Stale file reference validation (v0.1.3)** - `check-docs-drift.sh` now detects references to non-existent `commands/*.md` and `skills/*/SKILL.md` files, with smart exclusions for changelogs, examples, and context docs

### Fixed
- **Documentation drift** - Added enhanced-ralph and milestone commands to README, fixed version numbers in README and CLAUDE.md
- **Stale documentation references** - Updated `commands/commit.md` references to `skills/commit/SKILL.md` in standards-dependency-map and update-standard command after skill migration
- **Enhanced-ralph commit instructions** - Changed "Ready for: /wdi-workflows:commit" to skill invocation pattern ("commit these changes") in 6 places
- **Context docs commit references** - Updated migration notes and capability docs to use skill invocation pattern

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
