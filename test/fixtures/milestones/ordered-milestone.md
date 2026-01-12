# MILE-TEST-002: Ordered Milestone

**Status:** Not Started
**Created:** 2026-01-12
**Target:** 2026-02-01
**Completed:**
**Owner:** Test

---

## Value Delivered

A complete service stack with proper layering and dependencies.

## Scope

### What's Included

Three features that MUST be built in dependency order.

### What's NOT Included

N/A

---

## Features

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | [feature-c](../features/feature-c.md) | High | Planning |
| 2 | [feature-a](../features/feature-a.md) | High | Planning |
| 3 | [feature-b](../features/feature-b.md) | High | Planning |

### Feature Summary

**Critical (must ship):**
- feature-a - Foundation service (no deps)
- feature-b - Middle layer (depends on A)
- feature-c - Top layer API (depends on B)

**NOTE:** Features are intentionally listed in WRONG order (C, A, B).
Dependency resolution should reorder to: A → B → C

---

## Dependencies

### Technical Dependencies

None required.

### Milestone Dependencies

None.

---

## Done When

- [ ] All features complete in correct order
- [ ] Service stack works end-to-end

---

## Notes

Test fixture for Scenario 3: Features with Dependencies.
Features listed in wrong order: C, A, B
Topological sort should reorder to: A → B → C

---

*Template: docs/templates/milestone.md*
