# Changelog

All notable changes documented here.

---

## 2026-01-25

### Added
- **Developer Onboarding Guide (#87)** - Created `docs/COLLABORATOR-GUIDE.md` for new contributors. Features progressive disclosure hierarchy (README → Guide → Standards), 10-minute Hello World for quick setup validation, ecosystem-as-story explanation of wdi/compound-engineering/learnings, first contribution walkthrough, and common gotchas table. Added prominent "New Contributor? Start Here" link in README
- **Progressive Disclosure Learning** - Documented onboarding patterns in `docs/solutions/developer-experience/progressive-disclosure-onboarding.md`
- **Sub-Issues & Living Epics (#65)** - Updated ISSUE-STANDARDS.md with GitHub's native sub-issues feature documentation and "living epics" pattern for ongoing work streams. Reopened Frontend Design Epic as a living epic

---

## 2026-01-24

### Breaking Changes
- **Simplified workflow-feature (#81, #83, #85)** - Complete rewrite of `/wdi:workflow-feature` with two entry points instead of flags:
  - **Quick idea**: One sentence → Issue → Done (30 seconds)
  - **Build something**: Full workflow with all phases
  - Continue any issue with `/wdi:workflow-feature #N`
  - Removed `--idea`, `--promote` flags
  - Deleted `/wdi:shape-idea` command
  - Added phase labels (`phase:planning/working/reviewing/compounding`) for at-a-glance visibility
  - Added milestone comments at each phase for journey documentation
  - Added input validation for non-existent issues

  **Migration:** The old flags no longer exist. Use the two entry points instead. To continue an idea, use `#N` syntax.

### Added
- **Learnings Search Phase (#79)** - New phase between Pre-flight and Plan that searches for relevant learnings before planning begins. Queries both local `docs/solutions/` and central `learnings/curated/` repo. Supports keyword search (tags, symptom, title) and issue-based search (related_issues field). Closes the compounding feedback loop by surfacing prior solutions automatically
- **Centralized Learnings Repository (#80)** - Created `whitedoeinn/learnings` to aggregate cross-project learnings. Features two-tier architecture (incoming/ → curated/), central pull sync script, comprehensive taxonomy (universal/frontend/backend/lob), and full documentation. Initial sync pulled 17 learnings from business-ops and dev-plugins-workflow
- **Learnings Architecture in CLAUDE.md** - Documented the sync/triage flow and linked to central learnings repo
- **Workflow Diagram** - Added `docs/workflows/feature-workflow-diagram.md` showing complete compounding feedback loop, learnings ecosystem, and implementation status. Linked from GETTING-STARTED.md and README.md

---

## 2026-01-23

### Breaking Changes
- **Command rename: `workflows-*` → `workflow-*` (v0.4.0)** - Renamed all workflow commands from plural to singular for consistency with skills and repository name:
  - `/wdi:workflows-feature` → `/wdi:workflow-feature`
  - `/wdi:workflows-setup` → `/wdi:workflow-setup`
  - `/wdi:workflows-milestone` → `/wdi:workflow-milestone`
  - `/wdi:workflows-enhanced-ralph` → `/wdi:workflow-enhanced-ralph`

  **Migration:** Run `./scripts/force-update-plugin.sh` to force-update, then restart Claude Code twice. See #78

### Added
- **`scripts/force-update-plugin.sh`** - Bulletproof migration script for breaking changes. Clears cache, refreshes marketplace, reinstalls plugin fresh. Use when automatic updates don't propagate

- **`/wdi:frontend-setup` command** - Install WDI design tokens to consuming projects following the shadcn copy pattern. Downloads from GitHub raw URLs (stable, version-agnostic), copies to project with version metadata, shows diff before updates. Includes security fixes: secure temp file handling with mktemp, portable date format. Addresses #77
- **Frontend Standards** - Comprehensive `docs/standards/FRONTEND-STANDARDS.md` documenting JSON Schema-first development, design tokens, typography/spacing scales, component architecture, form patterns, accessibility (WCAG 2.1 AA), and theme system. Addresses #65-#75
- **Design Tokens** - Portable `assets/tokens/tokens.css` and `tokens.json` with 6 minimal themes (precision, warmth, sophistication, boldness, utility, data). Extracted from google-ads, filtered to proven patterns only
- **`scripts/get-google-drive-path.sh`** - Cross-platform Google Drive path detection utility. Detects WSL vs Mac/Linux and returns the correct base path. Accepts optional relative path argument. Promoted from idea #64
- **Auto-fix `.gitignore` pattern in consuming projects** - `validate-env.sh` now detects and fixes broken `.claude/` patterns on session start, propagating the #59 fix to all wdi projects automatically
- **`check-deps.bats`** - Unit tests for auto-update order (marketplace refresh before plugin update), maintainer mode detection, and error handling

### Fixed
- **Plugin auto-update not propagating** - `claude plugin update` reads from a stale marketplace clone. Added `claude plugin marketplace update wdi-marketplace` before `plugin update` in `check-deps.sh` to git-pull the marketplace repo first, so the update command sees the latest version
- **Gitignore negation for `.claude/plans/`** - Pattern `.claude/` ignores the entire directory, so negation patterns like `!.claude/plans/idea-*.md` were never evaluated. Changed to `.claude/*` to allow selective tracking of shaping plan files. Unblocks `/wdi:shape-idea` workflow (#59)
- **Duplicate user-scope plugin entries** - The sledgehammer workaround (cache clear + install on every session) was creating duplicate user-scope entries. Now uses `plugin update` instead of `plugin install`, and properly deduplicates existing entries by keeping most recent
- **BATS library detection** - Test runner now finds BATS helper libraries in `/usr/lib/bats` (Ubuntu apt install location) in addition to `/usr/local/lib`

### Added
- **`plugin-dedup.bats`** - Unit tests for jq deduplication logic that cleans plugin registry (#52 kept breaking)
- **`bump-version.bats`** - Unit tests for version bump script, including sync verification between plugin.json and marketplace.json
- **Version sync integration test** - Catches plugin.json/marketplace.json version drift before commit

---

## 2026-01-22

### Documentation
- **`machine-setup.sh` documented everywhere** - Added references to troubleshooting.md (Nuclear Reset section), GETTING-STARTED.md (New Machine Setup, Multi-Machine Sync), and CLAUDE.md (New Machine / Reset subsection)

### Fixed
- **Duplicate plugin scope detection** - SessionStart hook now detects when wdi is installed at both user AND project scope and auto-removes the project-scope entry from `~/.claude/plugins/installed_plugins.json`. Previously only checked project settings files, missing the actual plugin registry
- **`machine-setup.sh` now comprehensive** - Script clears caches, updates marketplaces, removes ALL project-scope entries from registry, deletes stale project settings files, then installs fresh. Safe to re-run to reset to known good state

### Added
- **`scripts/machine-setup.sh`** - Bootstrap script for new development machines. Installs plugins at user scope, creates global `~/.claude/CLAUDE.md` with environment standards and drift detection rules. Run via curl or directly
- **Drift prevention docs** - Added DRIFT ALERT guidance to global and project CLAUDE.md files to catch settings that should never be modified (plugin scope, permission mode, status line)

---

## 2026-01-21

### Added
- **Solution doc: Plugin source auto-loading** - Documented why dev-plugins-workflows doesn't need wdi-local installation. Claude Code auto-loads plugins from directories with `.claude-plugin/plugin.json`, making the source repo self-sufficient
- **`/wdi:shape-idea` command** - Iterative shaping sessions for ideas captured via `--idea`. Explore ideas from business, technical, or UX perspectives. Each session produces a committed plan file at `.claude/plans/idea-{n}-{perspective}-{date}.md` and adds a summary comment to the GitHub issue. Multiple sessions accumulate as separate files, building rich context for promotion
- **Enhanced `--promote` workflow** - Now reads and synthesizes context from shaping plan files in addition to issue comments. Identifies cross-cutting needs between perspectives, detects coverage gaps, and pre-populates the interview with decisions, risks, and scope from shaping sessions
- **Gitignore exception for plan files** - `.claude/plans/idea-*.md` files are now tracked by git (exception to the `.claude/` ignore rule)

---

## 2026-01-20

### Added
- **`/wdi:triage-ideas` command** - Periodic review of unshaped ideas (`status:needs-shaping`). Clusters related ideas, recommends actions (quick-decision, individual-promote, needs-research), and automates GitHub issue updates. Supports `--plan` for analysis-only mode and `--yes` for auto-accept
- **Triage labels** - New GitHub labels for triage workflow: `status:ready-to-promote`, `triage:quick-decision`, `blocked:research`, `research`

---

## 2026-01-19

### Added
- **Issue scope taxonomy** - Defined hierarchy (initiative → epic → feature/bug/spike → task) in `docs/standards/ISSUE-STANDARDS.md`. Clarifies distinction between scope (size) and type (nature) labels. Created GitHub labels: initiative, epic, spike, task, chore
- **Commit skill pre-flight check (#58)** - Commit skill now verifies local branch is in sync with origin/main before proceeding. Prevents version regression from stale local state (the exact problem that caused the #52/#53 debugging nightmare)
- **Fixed marketplace.json staging** - Version bump now stages both `plugin.json` and `marketplace.json` to keep versions in sync
- **CI version bump enforcement** - New GitHub Action (`.github/workflows/version-bump-check.yml`) fails if plugin files change without a version bump. Catches forgotten bumps even without pre-commit hook installed

### Fixed
- **Plugin architecture overhaul (#52)** - Complete rewrite of plugin update mechanism to fix version propagation issues discovered during 10 days of testing
  - **Bug 1: Stale marketplace cache** - `check-deps.sh` now deletes marketplace cache before reinstall (workaround for `plugin update` not re-downloading files)
  - **Bug 2: Maintainer mode false positive** - `install.sh` now requires full source structure (marketplace.json + commands/ + skills/) to trigger maintainer mode
  - Removed vendor method entirely - marketplace-only installation path
  - Added `.claude/` to .gitignore (machine-specific settings shouldn't be committed)

### Changed
- **Two restarts required for updates** - First restart downloads new plugin files, second restart loads them. This is a Claude Code limitation, not a bug in wdi

### Removed
- **Vendor tooling** - Deleted `scripts/vendor-to-project.sh` and all vendor references from docs. Marketplace is the only supported installation method
- **hello.md test command** - Temporary test file used during update cycle verification

### Known Issues
- **Claude Code `plugin update` is broken** - Doesn't re-download files when version changes, only updates metadata. Workaround: delete cache before install. Tracking issue: #53
- **Claude Code `plugin list` display bug** - Plain text output shows duplicates for project-scoped plugins; `--json` output is correct

---

## 2026-01-18

### Added
- **Developer onboarding guide** - `docs/GETTING-STARTED.md` with mental model, command decision tree, design decisions, and walkthrough
- **Auto-docs documentation** - `docs/auto-docs.md` explaining capability, usage, and customization

### Changed
- **Workflow commits skip tests** - Workflows now use `--skip-tests` when committing since tests already ran during work phase. Reduces token waste when ralph is mass-producing features
- **Branch strategy deferred** - Moved BRANCH-NAMING.md to drafts/, work directly on main with quality gates (#44)
- **Enabled marketplace plugin for testing (#43)** - Re-enabled wdi@wdi-marketplace alongside wdi@wdi-local to test different installation contexts

### Fixed
- **Marketplace naming conflict (#43)** - Installer now reads actual marketplace name from marketplace.json instead of assuming `-local` suffix. Handles conflicts when local and remote use same name by replacing existing marketplace. Cleans up orphaned plugin entries from previous installations

### Removed
- **Redundant commit skill steps** - Removed simplicity review (runs in workflow) and branch validation (we use main). Commit skill now focused on tests, auto-docs, changelog

---

## 2026-01-17

### Changed
- **Aligned wdi with compound-engineering (#40)** - wdi now properly delegates to compound-engineering workflows. Removed duplicate research phase (now in /workflows:plan). Review phase delegates to /workflows:review and creates GitHub issues from findings (P1=blocking). Compound phase runs first to capture learnings before merge. --promote is now an onramp that runs full workflow with pre-populated context
- **Assessment phase deferred (#41)** - Complexity assessment captured as idea issue for future consideration after learning compound-engineering defaults

### Added
- **Idea promotion workflow (#30)** - Ideas now live entirely in GitHub Issues. `--idea` creates an issue with `idea` label, shaped via prefixed comments (Decision:, Test:, Blocked:), then `--promote #N` converts to feature spec with comment parsing and conflict detection
- **Two-layer conflict detection** - Semantic conflicts detected at promotion (contradicting Decision: comments halt promotion). Implementation conflicts detected during work phase (same file modified with different intent)
- **Auto-documentation in commit workflow** - Commit skill now auto-updates CLAUDE.md and README.md when commands or skills are modified (Step 4.5)
- **Manual testing document** - Comprehensive test checklist for promotion workflow at `docs/testing/manual-test-issue-30-promotion-workflow.md`
- **Idea captures** - Added plugin version pinning (#19) and auto-capture context (#20) ideas with originating context

### Changed
- **Feature template enhanced** - Added YAML frontmatter for machine-readable metadata (status, type, complexity, issue, branch, created). Organized tasks into phases. Prepares for Ralph improvements (#31)

### Removed
- **Legacy idea files** - Deleted `docs/templates/idea.md` and `docs/product/ideas/*.md`. Ideas now live in GitHub Issues only

### Changed
- **Commit skill type guidance** - Added "Choosing the Right Type" table clarifying fix vs chore. Moved `refactor:` from "Prompt" to "No bump" since it's internal restructuring

### Fixed
- **Feature branch references removed** - Alignment implementation incorrectly included feature branch workflow despite #31 deferring that decision. Caught during compound output review. Added Post-Implementation Correction to compound doc capturing the meta-lesson: cross-reference prior decisions when implementing plans
- **Repo name references** - Corrected two files still using plural `dev-plugins-workflows` after migration to singular `dev-plugins-workflow` in whitedoeinn org

### Removed
- **Stale docs/context/** - Deleted migration planning docs (ralph-migration.md, capability-gaps.md, feature-planning-capability.md) - work complete, remaining gaps tracked in #22

---

## 2026-01-16

### Added
- **Project scanner script** - `scripts/check-wdi-projects.sh` scans all projects in a directory and shows plugin installation status (compound-engineering, wdi, CLAUDE.md). Helps identify projects needing plugin updates

### Changed
- **Simplified testing infrastructure** - Removed Docker-based E2E testing in favor of local BATS tests. CI now runs in ~15 seconds instead of 10+ minutes with Docker. Removed ~1,500 lines of orchestration code
- **Marketplace naming clarified** - Renamed marketplace from `wdi-local` to `wdi-marketplace` for remote installs. Local development uses `wdi-local` pointing to source, team members use `wdi-marketplace` from GitHub

### Fixed
- **Explicit marketplace names in install.sh** - Now uses `wdi@wdi-marketplace` to avoid ambiguity when multiple marketplaces are configured

### Deprecated
- **wdi CLI** - The pre-Claude-Code CLI (`wdi create_project`, `wdi doctor`) is deprecated. Claude can create directories directly. Multiple CLI fixes were made today but the CLI itself is no longer recommended

---

## 2026-01-15

### Fixed
- **Stale file references (v0.2.1)** - Fixed all references to old command/skill paths leftover from v1.0.0 rename. Updated `commands/feature.md` → `commands/workflow-feature.md`, `skills/commit/` → `skills/workflow-commit/`, etc. across 10 files

### Added
- **CI drift detection** - GitHub Actions now validates documentation drift and dependency map on every push. Catches stale file references before merge

### Changed
- **Repository migrated to `whitedoeinn/dev-plugins-workflow`** - Moved from `wdi-dave-roberts/dev-plugins-workflows` (plural) to `whitedoeinn/dev-plugins-workflow` (singular) as the public repo. E2E tests now curl from GitHub production URL instead of using local volume mounts

---

## 2026-01-13

### Breaking Changes
- **Plugin renamed to `wdi` (v1.0.0)** - Major architecture change implementing the One Internal Plugin Policy. All WDI internal tooling now lives in a single plugin named `wdi` instead of `wdi-workflows`. Commands use domain-prefixed naming:
  - `/wdi-workflows:feature` → `/wdi:workflow-feature`
  - `/wdi-workflows:new-repo` → `/wdi:standards-new-repo`
  - Skills: `commit` → `workflow-commit`, `auto-update-docs` → `workflow-auto-docs`

  External dependencies (compound-engineering) remain global via marketplace. See `docs/standards/PLUGIN-ARCHITECTURE.md` for full rationale.

### Added
- **Plugin architecture standard** - New `docs/standards/PLUGIN-ARCHITECTURE.md` documents the one-plugin policy, domain-prefixed naming, and scaling guidelines
- **Project-local plugins milestone** - Tracks the architectural decision and implementation

### Changed
- **Idea capture mode (v0.1.7)** - New `--idea` flag for `/wdi:workflow-feature` enables quick idea capture without implementation. Creates minimal idea file in `docs/product/ideas/` and draft GitHub issue with `idea` type label and `status:needs-shaping`. Includes `setup-labels.sh` script to create type labels and lifecycle labels (`status:needs-shaping`, `status:ready`, `appetite:*`, `needs:*`). Promote ideas to features when ready via `@docs/product/ideas/{slug}.md`
- **Cleaner CLI flags (v0.1.6)** - Renamed feature command flag `--plan-only` → `--plan` (simpler). Added `-y` short form for `--yes`. Old flag still works as alias for backwards compatibility

---

## 2026-01-12

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
- **Enhanced-ralph commit instructions** - Changed "Ready for: /wdi:commit" to skill invocation pattern ("commit these changes") in 6 places
- **Context docs commit references** - Updated migration notes and capability docs to use skill invocation pattern

### Changed
- **Smarter feature workflow** - Claude now assesses complexity and suggests target subproject after research, reducing upfront questions from 5 to 3
- **Renamed `new-package` to `new-subproject`** - clearer terminology for mono-repo components
- **Commit skill now enforced** - Direct `git commit` blocked by PreToolUse hook; must use commit skill for changelog updates and quality gates

---

## 2026-01-11

### Breaking Change
- **Commit workflow is now a skill** - say "commit these changes" instead of running `/wdi:commit`. Same quality gates (tests, review, changelog) but smoother UX.

### Added - `wdi` CLI
- **Standards-aware project creation from terminal** - `wdi create_project` guides you through naming before Claude Code even starts, preventing misnamed directories
- **Environment doctor** - `wdi doctor` checks and installs dependencies (git, gh, jq, claude) using your package manager
- **Configurable domains** - `wdi config` lets you set business domains, plugin domains, GitHub org - values populate interview choices
- **Full interview flow** - same REPO-STANDARDS.md compliance as `/wdi:new-repo` but works pre-Claude-Code
- **Exception tracking** - non-standard names get documented with reasons, issues created for standard reviews

Install: `curl -sSL .../scripts/wdi | bash -s install`

### Fixed
- Skills now auto-invoke properly - directory wasn't registered in plugin.json
- Changelog entries now guide toward impact over description - prevents generic "added X" entries
- Missing plugin warnings now stand out - added emoji and indentation so they're not buried in output

### Standards Update Protocol
- **Safer standards changes** - `/wdi:update-standard` analyzes ripple effects before you modify a standard, preventing broken references across docs and commands
- **Dependency visibility** - map shows which files depend on each standard so you know what breaks

### Standards Framework
- **Consistent naming across repos** - standards for repos, branches, commits, files prevent bike-shedding and make navigation predictable
- **Faster issue creation** - templates pre-fill structure so you focus on content
- **Scaffolding commands** - `/wdi:new-repo` and `/wdi:new-subproject` apply standards automatically

### Enhanced Workflows
- **Interview-driven scaffolding** - `new-repo`, `new-subproject`, and `feature` commands ask adaptive questions instead of requiring you to remember flags
- **Exception tracking** - non-standard names get documented with reasons, creating a paper trail for future standard updates

### Changed
- **Plugin renamed** from `claude-workflows` to `wdi-workflows` - `wdi-` prefix prevents conflicts with third-party plugins
- **Repository renamed** from `wdi-workflows` to `dev-plugins-workflows` - follows `dev-plugins-*` pattern for Claude Code plugins *(Later migrated to singular `dev-plugins-workflow` in `whitedoeinn` org - see 2026-01-15)*
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
- **Setup verification** - `/wdi:setup` confirms dependencies are installed
