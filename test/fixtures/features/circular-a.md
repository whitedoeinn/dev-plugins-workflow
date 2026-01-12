# Circular Feature A

**Status:** Planning
**Created:** 2026-01-12

## Overview

Test feature that creates a circular dependency with circular-c.

## Done When

- [ ] Implement circular logic (test: never completes)

## Dependencies

**Blocked by:**
- [circular-c](./circular-c.md)

**Blocks:**
- [circular-c](./circular-c.md)

## Notes

This is a test fixture for circular dependency detection.
circular-a depends on circular-c, and circular-c depends on circular-a.
This should trigger: "Circular dependency detected: circular-a → circular-c → circular-a"
