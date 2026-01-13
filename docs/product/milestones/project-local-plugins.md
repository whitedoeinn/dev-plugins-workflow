# MILE-001: Project-Local Plugin System

**Status:** Complete
**Created:** 2026-01-13
**Completed:** 2026-01-13
**Owner:** David Roberts

---

## Value Delivered

Projects become fully self-contained with zero global plugin state for internal tooling. External dependencies (compound-engineering) remain global via marketplace, which is appropriate since they're maintained by external teams. Internal plugin (wdi) is vendored for version control and isolation.

## Architecture Decision

**One Internal Plugin Policy:**
- All WDI internal tooling lives in ONE plugin named `wdi`
- External dependencies (compound-engineering) stay global via marketplace
- Domain-prefixed naming: `workflows-*`, `standards-*` for commands/skills
- This simplifies versioning, installation, and prevents namespace collisions

See `docs/standards/PLUGIN-ARCHITECTURE.md` for full details.

## Scope

### What's Included

- Plugin rename: `wdi-workflows` → `wdi` (v1.0.0)
- Domain-prefixed command naming (e.g., `/wdi:workflows-feature`)
- Domain-prefixed skill naming (e.g., `workflow-commit`)
- Vendor tooling (`scripts/vendor-to-project.sh`) for copying wdi into projects
- compound-engineering declared as external dependency (not vendored)

### What's NOT Included

- Version pinning with labels (STABLE, LATEST, HEAD) - future enhancement
- Automatic update notifications - future phase

---

## Features

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | One internal plugin architecture | Critical | Complete |
| 2 | Vendor wdi to projects | Critical | Complete |
| 3 | External dependency management | High | Complete |

### Feature Summary

**Complete:**
- Renamed plugin to `wdi` with domain-prefixed commands/skills
- Created vendor script that copies wdi into project's `.claude-plugin/`
- compound-engineering configured as external dependency via settings.json
- Created PLUGIN-ARCHITECTURE.md standard documenting the approach

---

## Dependencies

### Technical Dependencies

| Dependency | Type | Status | Notes |
|------------|------|--------|-------|
| compound-engineering | External | Available | Stays global via marketplace |
| Claude Code plugin loader | Package | Available | Single .claude-plugin/ per project |

---

## Done When

- [x] Milestone created
- [x] Architecture decision documented (PLUGIN-ARCHITECTURE.md)
- [x] Plugin renamed from `wdi-workflows` to `wdi`
- [x] Commands renamed with domain prefixes
- [x] Skills renamed with domain prefixes
- [x] All internal references updated
- [x] `scripts/vendor-to-project.sh` updated for new architecture
- [x] Documentation updated (README.md, CLAUDE.md, etc.)

---

## Notes

This milestone addressed the environmental drift problem discovered when wdi-content had cached v0.1.2 while the source was at v0.1.7. During implementation, a namespace collision problem was identified if we vendored multiple plugins.

The solution: ONE internal plugin policy. All WDI internal tooling lives in the `wdi` plugin. External dependencies (compound-engineering) stay global because:
1. They have their own namespace (`/compound-engineering:*`)
2. They're maintained by external teams
3. Treated like system dependencies (npm, homebrew)

Key technical constraint that drove this decision: Claude Code supports only ONE `.claude-plugin/` per project, and skills/commands with same name would collide silently.

---

## Revision History

| Date | Change |
|------|--------|
| 2026-01-13 | Created |
| 2026-01-13 | Updated with architecture decision (one internal plugin policy) |
| 2026-01-13 | Marked complete after rename implementation |

---

*Template: docs/templates/milestone.md*
