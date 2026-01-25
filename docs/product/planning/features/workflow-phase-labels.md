# Feature: Workflow Phase Labels

**Status:** Complete
**Type:** New Feature
**Issue:** #83
**Appetite:** Small (hours to days)

## Problem

- Can't see workflow state at a glance from issue list
- Context switching confusion when returning to work
- Stakeholder visibility requires reading all comments
- Can't query/filter issues by phase for analytics

## Solution

Add phase labels to GitHub issues that update automatically as the workflow progresses. Each phase transition adds the new phase label and removes the previous one.

## Research Summary

### GitHub CLI Capabilities
- `gh issue edit --add-label "name"` adds labels
- `gh issue edit --remove-label "name"` removes labels
- Labels can be added/removed atomically in same command
- Labels must exist before being applied (create on first use)

### Existing Pattern (from wdi-compound-engineering-alignment.md)
- wdi is a thin orchestration layer
- New features should integrate into `workflow-feature.md`
- Don't build parallel systems - extend existing phases

### Label Design Decision
- Prefix: `phase:` for easy filtering (`label:phase:*`)
- Values: `planning`, `working`, `reviewing`, `compounding`
- Single active phase label at any time (replace, don't accumulate)

## Acceptance Criteria

- [x] Phase labels created on first workflow run
- [x] Label added at start of each phase
- [x] Previous phase label removed at transition
- [x] Issue list shows current phase at a glance
- [x] Can filter issues by phase: `label:phase:planning`

## Implementation Plan

### Step 1: Create Labels (One-time Setup)
Add label creation to workflow-feature.md near existing label creation:

```bash
gh label create "phase:planning" --color "1D76DB" --description "In planning phase" 2>/dev/null || true
gh label create "phase:working" --color "0E8A16" --description "In work phase" 2>/dev/null || true
gh label create "phase:reviewing" --color "FBCA04" --description "In review phase" 2>/dev/null || true
gh label create "phase:compounding" --color "6F42C1" --description "Capturing learnings" 2>/dev/null || true
```

### Step 2: Add Phase Label Transitions
At each phase boundary in workflow-feature.md:

**Plan Phase Start (after issue creation):**
```bash
gh issue edit {issue-number} --add-label "phase:planning"
```

**Work Phase Start:**
```bash
gh issue edit {issue-number} --remove-label "phase:planning" --add-label "phase:working"
```

**Review Phase Start:**
```bash
gh issue edit {issue-number} --remove-label "phase:working" --add-label "phase:reviewing"
```

**Compound Phase Start:**
```bash
gh issue edit {issue-number} --remove-label "phase:reviewing" --add-label "phase:compounding"
```

**On Close:**
```bash
gh issue edit {issue-number} --remove-label "phase:compounding"
```

### Step 3: Handle Idempotency
- Labels are idempotent: adding existing label is no-op
- Removing non-existent label is no-op
- Safe for re-runs and resumed workflows

## Files to Modify

| File | Change |
|------|--------|
| `commands/workflow-feature.md` | Add label creation + phase transitions |
| `CLAUDE.md` | Document phase labels feature |
| `.claude-plugin/plugin.json` | Version bump |

## Risks

- **Low:** Label operations are atomic and idempotent
- **Low:** No new dependencies, uses existing `gh` CLI
