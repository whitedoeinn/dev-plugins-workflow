# Circular Feature C

**Status:** Planning
**Created:** 2026-01-12

## Overview

Test feature that creates a circular dependency with circular-a.

## Done When

- [ ] Implement circular logic (test: never completes)

## Dependencies

**Blocked by:**
- [circular-a](./circular-a.md)

**Blocks:**
- [circular-a](./circular-a.md)

## Notes

This is a test fixture for circular dependency detection.
circular-c depends on circular-a, and circular-a depends on circular-c.
This should trigger: "Circular dependency detected: circular-a → circular-c → circular-a"
