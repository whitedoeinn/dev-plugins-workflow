# MILE-TEST-003: Circular Milestone

**Status:** Not Started
**Created:** 2026-01-12
**Target:** 2026-02-01
**Completed:**
**Owner:** Test

---

## Value Delivered

This milestone should FAIL due to circular dependencies.

## Scope

### What's Included

Two features with circular dependencies - impossible to execute.

### What's NOT Included

N/A

---

## Features

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | [circular-a](../features/circular-a.md) | High | Planning |
| 2 | [circular-c](../features/circular-c.md) | High | Planning |

### Feature Summary

**Critical (must ship):**
- circular-a - Depends on circular-c
- circular-c - Depends on circular-a

**WARNING:** These features have circular dependencies and cannot be executed.

---

## Dependencies

### Technical Dependencies

None.

### Milestone Dependencies

None.

---

## Done When

This milestone should never complete - it exists to test circular dependency detection.

---

## Notes

Test fixture for Scenario 4: Circular Dependency Detection.
Should error with: "Circular dependency detected: circular-a → circular-c → circular-a"
Execution should be blocked (non-zero exit).

---

*Template: docs/templates/milestone.md*
