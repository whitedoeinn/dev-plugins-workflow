---
status: pending
priority: p2
issue_id: "005"
tags: [code-review, ux, frontend-setup]
dependencies: []
---

# jq Dependency Check Should Happen Earlier

## Problem Statement

The command requires `jq` but only mentions it in the error handling section. The actual first use of `jq` is in Phase 1 (project type detection), before any error handling can warn the user.

**Why it matters:** Users without jq installed will see confusing errors from the detection logic instead of a clear "jq is required" message.

## Findings

**Location:** `commands/frontend-setup.md`, Lines 36-42, 282

**First use of jq (Phase 1):**
```bash
if jq -e '.dependencies.next' package.json > /dev/null 2>&1; then
  PROJECT_TYPE="nextjs"
```

**Error handling mention (much later):**
```markdown
| No jq | jq not found | "jq is required. Run: brew install jq" |
```

## Proposed Solutions

### Option A: Add Phase 0 for pre-flight checks (Recommended)

**Pros:** Consistent with other complex commands (workflow-feature has Pre-flight Checks)
**Cons:** Adds a phase
**Effort:** Small
**Risk:** None

Add before Phase 1:
```markdown
### Phase 0: Pre-flight Checks

Verify required tools are available before starting.

**Check jq:**
```bash
if ! command -v jq &> /dev/null; then
  echo "ERROR: jq is required but not installed."
  echo "Install with: brew install jq"
  exit 1
fi
```

**Check curl:**
```bash
if ! command -v curl &> /dev/null; then
  echo "ERROR: curl is required but not installed."
  exit 1
fi
```
```

### Option B: Inline check at first use

**Pros:** Simpler, no new phase
**Cons:** Less consistent with other commands
**Effort:** Minimal
**Risk:** Low

## Recommended Action

<!-- Fill in during triage -->

## Technical Details

**Affected files:**
- `commands/frontend-setup.md` (add new Phase 0, renumber existing phases)

**Components affected:**
- All phases (renumbering)
- Phase 1 becomes Phase 2, etc.

## Acceptance Criteria

- [ ] Command checks for jq before any jq usage
- [ ] Clear error message with installation instructions
- [ ] Also check for curl availability
- [ ] Pre-flight check runs before any other operations

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Identified via pattern-recognition-specialist | Pre-flight checks are a pattern in complex commands |

## Resources

- Similar pattern: `commands/workflow-feature.md` Phase 2: Pre-flight Checks
