# Changelog

All notable changes documented here.

---

## 2026-01-12

### Changed
- **Smarter feature workflow** - Claude now assesses complexity and suggests target subproject after research, reducing upfront questions from 5 to 3
- **Renamed `new-package` to `new-subproject`** - clearer terminology for mono-repo components

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
