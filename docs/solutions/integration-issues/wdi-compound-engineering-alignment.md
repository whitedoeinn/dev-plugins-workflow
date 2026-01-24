---
title: Align wdi workflow with compound-engineering
category: integration-issues
tags:
  - workflow-alignment
  - delegation
  - duplicate-removal
  - plugin-architecture
  - compound-engineering
component: wdi-plugin
severity: high
date_resolved: 2026-01-17
issue: "#40"
commit: 2fac8f2
---

# WDI and Compound-Engineering Alignment

## Problem

The wdi plugin was built by cherry-picking compound-engineering capabilities without understanding its prescriptive workflow. This created:

1. **Duplicate research execution** - wdi ran research agents in Phase 3, then `/workflows:plan` ran them again
2. **Promotion as bypass** - `--promote` created feature specs and jumped to Work phase, skipping planning
3. **Custom review dispatch** - wdi implemented its own 4-agent selection matrix instead of delegating to `/workflows:review` (which runs 12+ agents)
4. **Post-merge compounding** - Compound phase ran after merge, losing context for learnings capture
5. **Assessment fragmentation** - Complexity/subproject assessment ran independently instead of within planning

## Root Cause

Architectural misunderstanding about delegation boundaries. wdi was treating compound-engineering as a library of agents to cherry-pick, rather than a prescriptive workflow to delegate to.

**Anti-pattern:** Building a "parallel stack" instead of a "thin wrapper"

## Solution

Redesigned wdi as an orchestration layer that delegates heavy lifting to compound-engineering:

### 1. Redesigned --promote as Onramp

**Before:** Bypass that skipped phases (Interview → Create Spec → Jump to Work)
**After:** Onramp that pre-populates context and runs full workflow

```
--promote #123 now runs:
Interview (pre-filled) → Pre-flight → Plan → Work → Review → Compound
```

### 2. Removed Duplicate Research Phase

**Before:** Phase 3 (wdi runs agents) → Phase 4 Plan (compound-engineering runs agents again)
**After:** Single research execution within `/workflows:plan`

Removed ~165 lines of duplicate agent orchestration.

### 3. Delegated Review to /workflows:review

**Before:** Custom agent selection matrix (4 agents by complexity)
**After:** Delegation to `/workflows:review` (12+ agents) + GitHub issue creation

```markdown
Review findings converted to GitHub issues:
- P1 (Critical) → Blocking issue with `blocks:#N` label
- P2/P3 → Related issues
```

### 4. Reordered Compound Phase to Run FIRST

**Before:** Commit → Compound (work feels "done", context fading)
**After:** Compound → Commit (capture learnings while context is fresh)

## Architecture After Alignment

```
wdi (orchestration layer)
├── Interview (context gathering)
├── Pre-flight (validation)
└── Delegates to compound-engineering:
    ├── /workflows:plan (includes research agents)
    ├── /workflows:work (implementation with todos)
    ├── /workflows:review (12+ agents, creates todos)
    └── /workflows:compound (captures learnings)
└── Commit to main (AFTER learnings captured)
└── GitHub integration (issues, labels, cleanup)
```

**Note:** Feature branches deferred to #44. Currently all work happens on main with quality gates.

## Files Modified

| File | Changes |
|------|---------|
| `commands/workflow-feature.md` | Removed phases 3/3.5, rewrote phases 5/6, delegation notes |
| `CLAUDE.md` | Updated workflow docs, promotion as onramp |
| `.claude-plugin/plugin.json` | Version 0.3.0 → 0.3.1 |
| `docs/changelog.md` | Added alignment entry |

**Net change:** -437 lines, +173 lines (removed duplication)

## Prevention Strategies

### 1. Define Integration Boundary Upfront

Before building on a framework, document:
- What the framework provides (don't duplicate)
- What the wrapper adds (context, orchestration, integration)
- Explicit delegation points with fully-qualified names

### 2. Make Dependencies Explicit

Create architecture diagrams showing:
- Framework capabilities vs wrapper capabilities
- Flow of control and data
- "No duplication zones"

### 3. Implement Thin Wrappers

Rule of thumb: Wrapper should be <30% of total code. If more, you're duplicating the framework.

### 4. Validate via Static Analysis

```bash
# Check: No duplicate phase names without delegation
grep "Phase.*Research" commands/*.md | grep -v "/workflows:" → Should warn

# Check: All framework calls use fully-qualified names
grep -r "subagent_type=" commands/*.md → Should show compound-engineering:
```

## Decision Tree for Future Work

```
Can compound-engineering do this?
├─ YES → Delegate (use /compound-engineering:workflows:*)
│       └─ Need pre-processing? → Do locally, then delegate
├─ NO → Implement locally
│       └─ Should framework add it? → File issue
└─ UNKNOWN → Research framework docs first
```

## Related Issues

| Issue | Description |
|-------|-------------|
| #40 | Main alignment work (this solution) |
| #41 | Deferred: Complexity assessment (learn defaults first) |
| #33 | Idea: PR-based review phase (not yet implemented) |
| #31 | Ralph improvements (GitHub issue sync) |
| #44 | Branch strategy evaluation (deferred) |
| #30 | Idea promotion workflow (foundation for this work) |

## Key Lesson

**Each unit of engineering work should make subsequent units easier—not harder.**

When building on a framework:
1. Study the framework first (hours, not minutes)
2. Map what it provides vs what you add
3. Default to delegation; only override with documented justification
4. Make delegation explicit and visible

The wdi alignment reduced code by 264 lines while gaining capabilities (12+ review agents instead of 4, proper learnings capture). Delegation compounds knowledge; duplication compounds maintenance burden.

## Cross-References

- `docs/standards/PLUGIN-ARCHITECTURE.md` - One-plugin policy and external dependencies
- `docs/architecture.md` - System overview with delegation diagram
- `CLAUDE.md` - Workflow documentation and promotion as onramp

---

## Post-Implementation Correction

**Error discovered:** The original implementation included feature branch workflow (create branch, merge to main) despite our decision to defer feature branches.

**How it happened:**
1. The plan included feature branch language
2. Implementation followed the plan without cross-referencing prior decisions
3. Compound documented what was implemented (including the error)
4. Manual review of compound output caught the inconsistency

**What was fixed:**
- Removed "Create Feature Branch" section from Phase 4
- Removed merge commands from Phase 6
- Updated examples to remove branch references
- Added notes that branches are deferred (now tracked in #44)

**Meta-lesson:** When implementing a plan, cross-reference prior decisions (especially deferred work tracked in issues). The plan may contain assumptions that contradict earlier decisions.

**Why this wasn't caught earlier:**
- We implemented directly from a plan, not via `/wdi:workflow-feature`
- The Review phase (which runs 12+ agents) was skipped
- Only the commit skill ran, which has lighter review

**Process improvement:** For significant work, use the full feature workflow. The Review phase exists precisely to catch contradictions like this before merge.
