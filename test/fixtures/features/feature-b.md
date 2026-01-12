# Feature B - Middle Layer

**Status:** Planning
**Created:** 2026-01-12

## Overview

Middle layer feature that depends on Feature A and is needed by Feature C.

## Done When

- [ ] Extend base service with business logic (test: logic executes correctly)
- [ ] Add validation layer (test: invalid input rejected)

## Dependencies

**Blocked by:**
- [feature-a](./feature-a.md)

**Blocks:**
- [feature-c](./feature-c.md)

## Notes

This is a test fixture for dependency ordering tests.
Feature B depends on A, and Feature C depends on B.
Correct order: A → B → C
