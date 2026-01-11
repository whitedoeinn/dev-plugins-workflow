# Changelog

All notable changes documented here.

---

## 2026-01-11

### Version 2.0.0
- Bumped to major version 2.0.0 to reflect breaking change

### Fixed
- Added missing `skills` entry to plugin.json to register skills directory

### Improved
- Changelog entries now emphasize impact over description - prevents generic "added X" entries

### Breaking Change - Commit Workflow Converted to Skill
- **REMOVED:** `/wdi-workflows:commit` command no longer exists
- **ADDED:** `commit` skill that auto-invokes when you say "commit these changes"
- The skill provides the same functionality (tests, simplicity review, changelog)
- Trigger phrases: "commit these changes", "commit this", "push this", "let's commit"
- New file: `skills/commit/SKILL.md`

### Added - Standards Update Protocol (v1.2.0)
- **Standards Update Protocol** for comprehensive updates when changing standards:
  - `/wdi-workflows:update-standard` - Impact analysis and guided update workflow
  - `--analyze` flag for read-only impact assessment before making changes
  - `--list` flag to show all standards with impact scores
  - PreCommit hook (`scripts/pre-commit-standards.sh`) for automatic detection
- **Standards Dependency Map** (`knowledge/standards-dependency-map.md`):
  - Machine-readable reference showing which files depend on each standard
  - Impact scores and complexity assessments
  - Used by command and hook for lookup
- **Protocol Documentation** (`docs/standards/STANDARDS-UPDATE-PROTOCOL.md`):
  - Step-by-step process for updating standards
  - Impact assessment guide
  - Examples for common scenarios

### Added - Standards Framework (v1.1.0)
- **Development Standards** in `docs/standards/`:
  - REPO-STANDARDS.md - Repository naming conventions
  - PROJECT-STRUCTURE.md - Directory layout standards
  - FILE-NAMING.md - File and directory naming
  - BRANCH-NAMING.md - Git branch conventions
  - COMMIT-STANDARDS.md - Commit message format
  - CLAUDE-CODE-STANDARDS.md - Plugin/command naming (`wdi-*` prefix)
  - ISSUE-STANDARDS.md - GitHub issue conventions, labels, templates
  - DEPENDENCY-STANDARDS.md - Dependency types, status values, tracking
- **GitHub Issue Templates** in `.github/ISSUE_TEMPLATE/`:
  - bug_report.md - Bug report template
  - feature_request.md - Feature request template
  - enhancement.md - Enhancement template
- **Document Templates** in `docs/templates/`:
  - feature.md - Feature specification template
  - prd.md - Product Requirements Document template
  - milestone.md - Milestone with dependencies template
- **PR Template** in `.github/PULL_REQUEST_TEMPLATE.md`
- **Product Documentation Structure** (`docs/product/`) for PRDs, features, milestones
- **New Commands**:
  - `/wdi-workflows:new-repo` - Create repository following standards
  - `/wdi-workflows:new-package` - Add package to mono-repo
  - `/wdi-workflows:check-standards` - Validate against standards
- **Knowledge Directory** with quick references:
  - standards-summary.md - One-page quick reference
  - decision-trees/repo-type.md - Mono vs standalone flowchart
  - decision-trees/package-location.md - Package placement guide

### Enhanced
- `/wdi-workflows:new-repo` now uses interview-driven workflow with `AskUserQuestion`
  - Adaptive questions based on repo type (plugin, mono-repo, standalone, experiment)
  - Proposes names following standards, allows modification with validation
  - Captures exception reasons for non-standard names
  - Auto-creates GitHub Issues for potential standard changes
- `/wdi-workflows:new-package` now uses interview-driven workflow with `AskUserQuestion`
  - Adaptive questions based on package type (API wrapper, tool, guest-facing, shared lib, content)
  - Proposes names following patterns (api-*, guest-*, lib-*)
  - Validates modifications, captures exceptions in `.github/package-naming-exceptions.md`
  - Auto-creates GitHub Issues for potential standard changes
- `/wdi-workflows:feature` now uses interview-driven workflow with `AskUserQuestion`
  - Gathers feature type (new, enhancement, bug fix, refactor, experiment)
  - Assesses complexity to determine agent selection and planning depth
  - Selects target package in mono-repos (or triggers new-package creation)
  - Offers research preference (full, light, skip)
  - Adapts research and review agents based on answers
  - Saves feature specs to `docs/product/planning/features/` using template

### Changed
- **Renamed plugin from `claude-workflows` to `wdi-workflows`**
- **Renamed repository from `wdi-workflows` to `dev-plugins-workflows`**
- All commands now use `/wdi-workflows:` prefix
- Updated all GitHub URLs to point to `whitedoeinn/dev-plugins-workflows`
- `/wdi-workflows:commit` now validates branch naming
- `/wdi-workflows:feature` now includes pre-flight repository context check
- SessionStart hook now warns about deprecated `wdi-` repo prefixes

### Added (Documentation)
- CLAUDE.md with project overview and development guide
- Architecture documentation (docs/architecture.md)
- Troubleshooting guide (docs/troubleshooting.md)
- Contributing guide (CONTRIBUTING.md)

### Updated
- README.md with standards section and new commands
- CLAUDE.md with updated structure and key standards

---

## 2026-01-10

### Added
- Install script (`install.sh`) for easy project bootstrap
- Local plugin development support via marketplace.json
- SessionStart hook for dependency checking

### Changed
- Updated Claude Code permissions to bypassPermissions

---

## 2026-01-09

### Added
- Initial `/wdi-workflows:feature` workflow with 5-phase compound engineering
- Initial `/wdi-workflows:commit` workflow with tests, review, and changelog
- `/wdi-workflows:setup` command for dependency verification
- Plugin structure with proper Claude Code plugin format
- Skills array in plugin.json for compound-engineering integration

### Infrastructure
- Converted project to proper Claude Code plugin structure
- Added plugin.json with metadata and command registration
