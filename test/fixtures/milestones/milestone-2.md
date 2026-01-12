# MILE-TEST-005: Dependent Milestone

**Status:** Not Started
**Created:** 2026-01-12
**Target:** 2026-03-01
**Completed:**
**Owner:** Test

---

## Value Delivered

Extended features that build on the foundation milestone.

## Scope

### What's Included

Features that depend on milestone-1's completion.

### What's NOT Included

N/A

---

## Features

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | [feature-b](../features/feature-b.md) | High | Planning |
| 2 | [feature-c](../features/feature-c.md) | High | Planning |

### Feature Summary

**Critical (must ship):**
- feature-b - Middle layer (depends on feature-a from milestone-1)
- feature-c - Top layer (depends on feature-b)

---

## Dependencies

### Technical Dependencies

| Dependency | Type | Status | Blocking Features | Owner |
|------------|------|--------|-------------------|-------|
| feature-a | Internal | Pending | feature-b, feature-c | - |

### Milestone Dependencies

| Milestone | Reason | Status |
|-----------|--------|--------|
| MILE-TEST-004 | Foundation services needed | In Progress |

---

## Blocked By

| Blocker | Owner | Expected Resolution | Status |
|---------|-------|---------------------|--------|
| MILE-TEST-004 not complete | Test | TBD | Active |

---

## Done When

- [ ] milestone-1 complete
- [ ] feature-b complete
- [ ] feature-c complete
- [ ] Full stack operational

---

## Notes

Test fixture for Scenario 5: Milestone Dependencies.
This milestone depends on milestone-1 which is "In Progress" (not Complete).
Executing this should:
- WARN: "Milestone depends on incomplete MILE-TEST-004"
- Block execution without --force
- Proceed with --force flag

Also tests Scenario 6: Implicit Cross-Milestone Dependencies.
feature-b depends on feature-a which is in milestone-1.

---

*Template: docs/templates/milestone.md*
