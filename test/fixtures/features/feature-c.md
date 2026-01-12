# Feature C - Top Layer

**Status:** Planning
**Created:** 2026-01-12

## Overview

Top layer feature that depends on Feature B (and transitively on A).

## Done When

- [ ] Create API endpoint using service (test: endpoint returns data)
- [ ] Add caching layer (test: second request is faster)

## Dependencies

**Blocked by:**
- [feature-b](./feature-b.md)

**Blocks:**
(none)

## Notes

This is a test fixture for dependency ordering tests.
Feature C depends on B (which depends on A).
Correct order: A → B → C
