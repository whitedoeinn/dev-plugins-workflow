---
status: pending
priority: p3
issue_id: "006"
tags: [code-review, consistency, frontend-setup]
dependencies: []
---

# Phase Heading Level Inconsistency

## Problem Statement

The command uses `### Phase N:` (H3 with "Phase") but other commands in the plugin use either `## Phase N:` (H2) or `### Step N:` (H3 with "Step").

**Why it matters:** Minor inconsistency in documentation structure. Doesn't affect functionality but reduces pattern predictability.

## Findings

**Location:** `commands/frontend-setup.md`, Lines 20, 31, 62, 86, 135, 169, 209

**Current pattern:**
```markdown
### Phase 1: Detect Project Type
### Phase 2: Resolve Target Directory
...
```

**Other commands:**
- `workflow-feature.md`: `## Phase N:` (H2 with Phase)
- `standards-check.md`: `### Step N:` (H3 with Step)
- `workflow-enhanced-ralph.md`: `## Step N:` (H2 with Step)

## Proposed Solutions

### Option A: Change to `### Step N:` (Recommended)

**Pros:** Matches `standards-check.md` which is a similar utility command
**Cons:** Requires updating all phase headings
**Effort:** Minimal
**Risk:** None

### Option B: Change to `## Phase N:`

**Pros:** Matches `workflow-feature.md`
**Cons:** May affect document hierarchy
**Effort:** Minimal
**Risk:** None

### Option C: Leave as-is

**Pros:** No changes needed
**Cons:** Inconsistency remains
**Effort:** None
**Risk:** None

## Recommended Action

<!-- Fill in during triage -->

## Technical Details

**Affected files:**
- `commands/frontend-setup.md` (Lines 20, 31, 62, 86, 135, 169, 209)

## Acceptance Criteria

- [ ] Heading pattern is consistent with similar commands
- [ ] Document hierarchy is preserved
- [ ] Table of contents (if generated) renders correctly

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Identified via pattern-recognition-specialist | Document consistency aids navigation |

## Resources

- Reference: `commands/standards-check.md` for Step pattern
- Reference: `commands/workflow-feature.md` for Phase pattern
