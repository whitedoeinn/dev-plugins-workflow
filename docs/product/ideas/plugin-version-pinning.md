# Idea: Plugin: Version pinning for consuming projects

**Status:** Idea
**Created:** 2026-01-17
**Issue:** #19
**Appetite:** Unknown (blocked on external dependency)

## Problem

Projects always get the latest plugin version on `claude plugin update`. There's no way to opt for stability over freshness. This is blocked until Claude Code adds native version pinning support.

## Rough Solution

**Workarounds available now:**
- Use Git tags - projects can track `#v1.0.0` instead of latest
- Maintain a `stable` branch updated only for vetted releases

**Real solution:** Wait for Claude Code to add native plugin version pinning (tracking: anthropics/claude-code#9444)

## Open Questions

- When will Claude Code add plugin version pinning support?
- Should we implement branch-based channels (main vs stable) as interim solution?

## Originating Context

> While implementing the "Plugin Team Setup" plan (Phase 1 complete), we discussed day-2 change management for how plugin updates propagate to consuming projects. Researched Claude Code plugin capabilities and discovered version pinning isn't natively supported - only Git refs work, not semver ranges or named channels (STABLE, LATEST). Decision: accept latest-from-main for MVP, track this idea for future.

---

*Captured via `/wdi:feature --idea`*
