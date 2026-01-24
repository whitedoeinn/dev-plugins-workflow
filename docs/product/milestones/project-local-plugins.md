# MILE-001: Project-Local Plugin System

**Status:** Complete
**Created:** 2026-01-13
**Completed:** 2026-01-13
**Owner:** David Roberts

---

## Value Delivered

Projects become fully self-contained with zero global plugin state for internal tooling. External dependencies (compound-engineering) remain global via marketplace, which is appropriate since they're maintained by external teams. Internal plugin (wdi) is installed via marketplace with automatic updates on session start.

## Architecture Decision

**One Internal Plugin Policy:**
- All WDI internal tooling lives in ONE plugin named `wdi`
- External dependencies (compound-engineering) stay global via marketplace
- Domain-prefixed naming: `workflow-*`, `standards-*` for commands/skills
- This simplifies versioning, installation, and prevents namespace collisions

See `docs/standards/PLUGIN-ARCHITECTURE.md` for full details.

## Scope

### What's Included

- Plugin rename: `wdi-workflows` → `wdi` (v1.0.0)
- Domain-prefixed command naming (e.g., `/wdi:workflow-feature`)
- Domain-prefixed skill naming (e.g., `workflow-commit`)
- Marketplace-based installation via `install.sh`
- compound-engineering declared as external dependency (marketplace-based)

### What's NOT Included

- Version pinning with labels (STABLE, LATEST, HEAD) - future enhancement
- Automatic update notifications - future phase

---

## Features

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | One internal plugin architecture | Critical | Complete |
| 2 | Marketplace-based wdi installation | Critical | Complete |
| 3 | External dependency management | High | Complete |

### Feature Summary

**Complete:**
- Renamed plugin to `wdi` with domain-prefixed commands/skills
- Marketplace-based installation via `install.sh`
- compound-engineering configured as external dependency via marketplace
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
- [x] Marketplace-based installation via install.sh
- [x] Documentation updated (README.md, CLAUDE.md, etc.)

---

## Notes

This milestone addressed the environmental drift problem discovered when wdi-content had cached v0.1.2 while the source was at v0.1.7. During implementation, a namespace collision problem was identified if multiple plugins were installed locally.

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
