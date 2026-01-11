# Changelog

All notable changes documented here.

---

## 2026-01-11

### Changed
- **Renamed plugin from `claude-workflows` to `wdi-workflows`**
- All commands now use `/wdi-workflows:` prefix
- Updated all GitHub URLs and documentation

### Added
- CLAUDE.md with project overview and development guide
- Architecture documentation (docs/architecture.md)
- Troubleshooting guide (docs/troubleshooting.md)
- Contributing guide (CONTRIBUTING.md)

### Updated
- README.md with How It Works, Troubleshooting, and documentation links

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
