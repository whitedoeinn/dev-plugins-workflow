# Idea: Portfolio Changelog

**Status:** Idea
**Created:** 2026-01-17
**Appetite:** Unknown
**Issue:** #32

## Problem

No unified view of development activity across all whitedoeinn GitHub repos. Currently requires checking each repo individually to understand what's happening. Need a simple information radiator for tracking development progress across the portfolio.

## Rough Solution

Aggregate changelogs from all repos in the whitedoeinn org into a single portfolio-level view. Possible elements to track:

- Ideas created
- Features designed
- Features implemented
- Bugs squashed
- Application-level changes
- Possibly other categories TBD

Design considerations:
- Human consumption first (information radiator, not machine-readable)
- Could be a generated markdown file, a simple webpage, or both
- Needs to pull from GitHub API (commits, issues, PRs, releases)
- Should respect existing changelog formats in each repo

## Open Questions

- What's the right format/medium? (markdown, HTML, dashboard)
- How often should it update? (real-time, daily, on-demand)
- What categories matter most?
- Should it include all repos or just active ones?
- How to handle repos with different changelog conventions?
- Where does it live? (separate repo, docs site, wdi plugin)

## Notes

- Primary audience is humans (David, Tonia, possibly future team)
- Should be low-maintenance once set up
- Could integrate with existing /wdi:workflows-feature workflow to auto-update

---

*Captured via `/wdi:feature --idea`*
