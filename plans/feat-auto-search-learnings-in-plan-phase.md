# feat: Auto-Search Learnings in Plan Phase

## Overview

**Type:** Enhancement
**Target:** `commands/workflow-feature.md`
**Complexity:** Small (hours to days)

Add automatic search of `docs/solutions/` for relevant learnings before the plan phase begins. This closes the compounding feedback loop by surfacing previously documented solutions when planning new work.

## Problem Statement

Currently, learnings documented via `/workflows:compound` are stored in `docs/solutions/` but are not automatically surfaced when planning new features. Developers must manually remember or search for relevant patterns, breaking the compounding feedback loop.

**The gap:**
```
Session 1: Solve "form not pre-populating" → Document in docs/solutions/
Session 2: Plan new edit form feature → No automatic lookup of related learnings
Result: Developer might re-solve already-documented problems
```

**Evidence:** In the GC Project Manager experiment (business-ops#3), we documented the `react-form-key-pattern` but the workflow didn't automatically surface it when planning related features.

## Proposed Solution

Add a "Learnings Search" step to `wdi:workflow-feature` that runs **before** invoking compound-engineering's `/workflows:plan`:

```
Interview → Pre-flight → **Learnings Search** → Plan → Work → Review → Compound
                              ↑ NEW
```

### Search Implementation

1. **Extract keywords** from the feature description (interview answer)
2. **Search `docs/solutions/`** for matching:
   - YAML frontmatter tags
   - `symptom` field
   - Title text
3. **Present findings** before proceeding to plan phase
4. **Include in plan context** so compound-engineering's research agents have this background

### Search Strategy

Use keyword-based grep on YAML frontmatter (deterministic, easy to debug):

```bash
# Search tags and symptoms in docs/solutions/
grep -r -l "tags:.*{keyword}" docs/solutions/ 2>/dev/null
grep -r -l "symptom:.*{keyword}" docs/solutions/ 2>/dev/null
```

Keywords extracted from feature description using simple heuristics:
- Technology names (react, rails, zustand, etc.)
- Pattern names (form, edit, crud, etc.)
- Problem indicators (stale, bug, error, etc.)

## Technical Approach

### Phase 1: Add Learnings Search Step

Modify `commands/workflow-feature.md` to add new step between Pre-flight and Plan:

```markdown
## Phase 2.5: Learnings Search (NEW)

Before invoking `/workflows:plan`, search for related learnings:

### Step 1: Extract Keywords

From the feature description, extract:
- Technology names mentioned
- Pattern/component types (form, modal, list, etc.)
- Problem indicators

### Step 2: Search docs/solutions/

```bash
# Check if docs/solutions/ exists
if [ -d "docs/solutions" ]; then
  # Search frontmatter for matching tags
  grep -r -l "tags:.*{keyword}" docs/solutions/ 2>/dev/null | head -5
  grep -r -l "symptom:.*{keyword}" docs/solutions/ 2>/dev/null | head -5
fi
```

### Step 3: Present Findings

If matches found:
```
Related Learnings Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 2 related learnings for "edit form":

• react-form-key-pattern.md
  Symptom: "form shows stale data"
  Tags: react, forms, state, edit

• spec-driven-testing-pattern.md
  Tags: testing, requirements

These will be included in the plan context.
```

If no matches:
```
No related learnings found in docs/solutions/
Proceeding to plan phase...
```

### Step 4: Include in Plan Context

Pass learnings to `/workflows:plan` as additional context so research agents can reference them.
```

### Phase 2: Update Plan Command Integration

The learnings should be passed to compound-engineering's `/workflows:plan` as pre-research context. This could be done via:

1. Prepending to feature description
2. Adding a new "prior art" section to the plan template
3. Including as agent context (if compound-engineering supports this)

## Acceptance Criteria

- [ ] `wdi:workflow-feature` searches `docs/solutions/` before plan phase
- [ ] Matching learnings are displayed to user
- [ ] Learnings context is passed to plan phase
- [ ] Works when `docs/solutions/` doesn't exist (graceful skip)
- [ ] Works with zero matches (clear message)

## Test Case: Verification in business-ops

After implementing, verify in business-ops repo:

1. Run `/wdi:workflow-feature`
2. Describe: "Add edit form for vendors with pre-population"
3. **Expected:** System should find and display `react-form-key-pattern.md`
4. Verify the learning appears in plan context

```bash
# In business-ops repo after updating plugin
claude plugin update wdi

# Run workflow and describe an edit form feature
/wdi:workflow-feature
# At interview: "Add edit form for vendors"

# Expected output should include:
# Related Learnings Found
# • react-form-key-pattern.md
#   Symptom: "form shows stale data"
```

## Success Metrics

| Metric | How to Measure | Target |
|--------|----------------|--------|
| Learnings surfaced | Count of "Found related:" in plan outputs | >50% of sessions where relevant docs exist |
| Time saved | Compare planning time with/without auto-search | Qualitative improvement |

## Dependencies

- `docs/solutions/` directory must exist with YAML frontmatter
- Learnings must have consistent frontmatter (tags, symptom fields)
- grep available in shell (standard)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Too many false positives | Start with exact keyword match; tune later |
| Slow search on large docs/ | Limit to first 5 matches |
| Frontmatter format varies | Document required fields in LEARNINGS-INDEX.yaml |

## Implementation Plan

1. **Edit `commands/workflow-feature.md`** - Add Phase 2.5 section
2. **Test locally** - Run workflow in business-ops
3. **Commit and push** - `feat: Add learnings search to plan phase`
4. **Verify in consumer** - `claude plugin update wdi` in business-ops
5. **Run test case** - Verify react-form-key-pattern is surfaced

## Future Enhancements

- Semantic search (beyond keyword matching)
- Learnings index file (`docs/solutions/LEARNINGS-INDEX.yaml`) for faster lookup
- Integration with compound-engineering's research agents (if they add support)

## References

- Workflow diagram: `docs/workflows/feature-workflow-diagram.md` (business-ops)
- Related learnings: `docs/solutions/developer-experience/` (business-ops)
- GC Project Manager experiment: business-ops#8
- PR with spec-driven testing: experiment-gc-project-manager#3
