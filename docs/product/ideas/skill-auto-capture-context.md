# Idea: Skill: Auto-capture originating context in idea workflow

**Status:** Idea
**Created:** 2026-01-17
**Issue:** #20
**Appetite:** Small

## Problem

Ideas captured mid-task lose the context of what triggered them. When reviewing ideas days or weeks later, it's hard to recall why the idea mattered or what you were doing when it occurred. This creates friction when triaging ideas because you have to reconstruct the context mentally.

## Rough Solution

The `--idea` workflow could automatically:
1. Summarize the recent conversation/task context before prompting for idea details
2. Include that summary in the idea file under an "Originating Context" section
3. Make the context editable so users can refine it

## Open Questions

- How much context is useful without being noisy?
- Should context capture be opt-out or opt-in?
- What's the right format - quote block, bullet points, narrative?

## Originating Context

> While running the idea workflow to capture a version pinning idea, David noted that his biggest productivity drain is keeping ideas straight. Ideas pop up constantly during work, and by the time you review them later, the original context is lost. He asked to capture context automatically going forward.

---

*Captured via `/wdi:feature --idea`*
