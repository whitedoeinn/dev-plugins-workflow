---
title: Phase Labels for Workflow Visibility
category: workflow
tags:
  - github-labels
  - workflow-tracking
  - visibility
  - orchestration
component: wdi-plugin
date_resolved: 2026-01-24
related_issues:
  - "#83"
learnings:
  - Labels must be created before use - add creation at ALL entry points
  - The thin orchestration pattern works well for cross-cutting concerns
  - Review phase catches architectural gaps (P1: missed code path)
---

# Phase Labels for Workflow Visibility

## Problem

During workflow execution, stakeholders (including future-self) couldn't tell at a glance what phase a feature was in. Had to read through issue comments to understand progress. Also couldn't filter/query issues by phase for analytics.

## Solution

Added phase labels (`phase:planning`, `phase:working`, `phase:reviewing`, `phase:compounding`) that are automatically applied and removed as the workflow progresses through phases.

### Implementation Pattern

1. **Label Creation** - Idempotent creation at workflow entry points:
   ```bash
   gh label create "phase:X" --color "..." 2>/dev/null || true
   ```

2. **Phase Transitions** - Atomic add/remove at phase boundaries:
   ```bash
   gh issue edit {n} --remove-label "phase:old" --add-label "phase:new"
   ```

3. **Cleanup on Close** - Remove final label when complete:
   ```bash
   gh issue edit {n} --remove-label "phase:compounding"
   ```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Single active label | Clearer than accumulating labels |
| `phase:` prefix | Enables filtering with `label:phase:*` |
| 4 main phases | Early phases (interview, pre-flight, learnings) are quick |
| Idempotent creation | Safe for re-runs, resumption |

## What We Learned

### 1. Multiple Entry Points Need Same Setup

The P1 review finding caught that label creation was only in `--idea` mode, not the full workflow path. Any setup code that's required for a feature to work must be present at ALL entry points.

**Pattern:** When adding cross-cutting infrastructure, grep for all places where the feature is first used and ensure setup happens there.

### 2. Thin Orchestration Works for Cross-Cutting Concerns

Phase labels touch every phase but don't require new systems or abstractions. Simple `gh` CLI calls inline with existing workflow steps. This validates the "thin orchestration layer" architecture from #40.

### 3. Review Phase Catches Architectural Gaps

The simplicity reviewer correctly identified the missing code path that would have caused runtime failures. Multi-agent review is valuable even for "small" features.

## Prevention

When adding workflow-wide features:
1. List ALL code paths that create/modify the artifact
2. Add setup code to each path (not just the first one found)
3. Make setup idempotent (safe to repeat)
4. Run review phase even for small changes
