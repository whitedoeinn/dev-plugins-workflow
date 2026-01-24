---
description: Full feature workflow with research, planning, implementation, and review (project)
---

# /wdi:feature - Compound Engineering Feature Workflow

Full feature development workflow using an interview-driven approach to tailor research, planning, and review phases.

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--yes` | `-y` | Auto-continue through phases (no pauses) |
| `--plan` | | Stop after planning phase |
| `--idea` | | Quick idea capture mode (minimal structure, no implementation) |
| `--promote` | | Promote an idea issue to a feature (e.g., `--promote #123`) |

### Aliases (backwards compatibility)

| Alias | Maps to |
|-------|---------|
| `--plan-only` | `--plan` |

---

## Workflow Overview

### Full Workflow (default)
```
Interview → Pre-flight → Learnings Search → Plan → Work → Review → Compound
```

**Note:** Research is now included within `/workflows:plan` (compound-engineering runs research agents automatically). The Learnings Search phase surfaces previously documented solutions from `docs/solutions/` before planning begins.

Each phase pauses for approval unless `--yes` is passed.

### Idea Mode (`--idea`)
```
Quick Interview → Create GitHub Issue → Done
```

Use idea mode when you have an idea but aren't ready to implement. Creates a GitHub issue for later shaping and triage.

---

## Idea Mode

When `--idea` flag is passed, run this simplified workflow instead of the full workflow.

### Step 1: Quick Interview

Use `AskUserQuestion` to gather minimal context.

#### Question 1: Idea Title

```
What's the idea? (short title)
```
(Free text - becomes the idea title and issue title)

#### Question 2: Problem Statement

```
What problem does this solve or what opportunity does it address?
```
(Free text - the "why" behind the idea)

#### Question 3: Appetite

```
How much time would this be worth?
```

| Option | Description |
|--------|-------------|
| **Small** | Hours to days - quick win |
| **Medium** | 1-2 weeks - meaningful feature |
| **Big** | 3-6 weeks - significant undertaking |
| **Unknown** | Need research to estimate |

#### Question 4: Rough Solution (Optional)

```
Any initial thoughts on approach? (leave blank if none)
```
(Free text - optional early thinking)

#### Question 5: Open Questions

```
What questions need answers before this can be built?
```
(Free text - captures unknowns)

### Step 2: Create GitHub Issue

```bash
gh issue create \
  --title "Idea: {title}" \
  --label "idea" \
  --label "status:needs-shaping" \
  --body "$(cat <<'EOF'
## Problem

{problem-statement}

## Appetite

{appetite}

## Rough Solution

{rough-solution or "TBD - needs shaping"}

## Open Questions

{open-questions}

---

**Status:** Idea - not ready for implementation

**Shaping:** Add comments to shape this idea. Use prefixes so they're captured when promoted:
- `Decision:` - Shaping decisions (e.g., "Decision: Use YAML frontmatter")
- `Test:` - Test requirements (e.g., "Test: Verify API returns 200")
- `Blocked:` - Dependencies (e.g., "Blocked: Waiting on #45")

Comments without prefixes are ignored (for human discussion only).

When ready, promote with `/wdi:feature --promote #{issue-number}`

*Captured by `/wdi:feature --idea`*
EOF
)"
```

If labels don't exist, create them:
```bash
gh label create "idea" --color "c5def5" --description "Captured idea, not yet shaped" 2>/dev/null || true
gh label create "status:needs-shaping" --color "FBCA04" --description "Raw idea, needs shaping" 2>/dev/null || true
```

### Step 3: Output

```
Idea Captured
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Title: {title}
Appetite: {appetite}

✓ Issue: #{issue-number} (idea, status:needs-shaping)

Next steps:
• Shape the idea: /wdi:shape-idea #{issue-number} --perspective business
• Or add comments to the issue with Decision:/Test:/Blocked: prefixes
• Promote to feature when ready: /wdi:feature --promote #{issue-number}
• Close the issue if the idea doesn't pan out
```

**Exit after idea mode - do not continue to full workflow.**

---

## Promotion Mode (`--promote #123`)

Promotion is an **onramp** to the standard workflow, not a shortcut around it. The idea content pre-populates workflow context, but all phases still run.

### Step 1: Fetch Issue Content

```bash
gh issue view {issue-number} --json title,body,labels,comments
```

Verify the issue has label `idea`. If not, warn and ask to confirm.

### Step 1.5: Read Shaping Plan Files

Check for shaping plan files from `/wdi:shape-idea` sessions:

```bash
ls .claude/plans/idea-{issue-number}-*.md 2>/dev/null
```

If shaping files exist, read and synthesize them:

#### Display Shaping Context

```
Shaping Context Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files:
  • idea-{n}-business-2024-01-15.md
  • idea-{n}-technical-2024-01-16.md

Perspectives covered: business, technical
```

#### Extract from Each File

For each shaping file, extract:
- **Decisions Made** - Pre-populate research context
- **Risks Identified** - Add to risk tracking
- **Open Questions** - Flag for interview clarification
- **Cross-Cutting Implications** - Identify dependencies between perspectives
- **Rough Scope** - Inform feature boundaries

#### Synthesize Multi-Perspective Context

When multiple perspectives exist, synthesize:

1. **Alignment check:** Do business and technical decisions align?
2. **Coverage gaps:** Which perspective is missing? (Warn if UX implications exist but no UX shaping)
3. **Cross-cutting needs:** Collect all `→ Tech`, `→ UX`, `→ Business` implications
4. **Consolidated decisions:** Merge decisions from all perspectives
5. **Aggregated risks:** Combine risks with perspective tags

```
Synthesized Shaping Context
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Decisions (3):
  [business] Premium tier feature
  [business] CSV and JSON export formats
  [technical] Use background jobs for large exports

Cross-Cutting Needs:
  → Tech: API rate limiting needed (from business)
  → UX: Progress indicator for long exports (from technical)

Risks (2):
  [technical] Large datasets may timeout
  [business] Competitor already has this feature

Open Questions:
  • What's the maximum export size? (from technical)

Missing perspective: ux
  Note: Technical shaping mentioned UX implications
```

#### If No Shaping Files

If no `.claude/plans/idea-{n}-*.md` files exist, continue with standard promotion (comments only).

### Step 2: Parse Actionable Comments

Comments are only processed if they start with a recognized prefix. Comments without prefixes are for humans and are ignored.

#### Recognized Prefixes

| Prefix | Maps to | Example |
|--------|---------|---------|
| `Decision:` | Research context | "Decision: Use YAML frontmatter for metadata" |
| `Test:` | Acceptance criteria | "Test: Verify /api/users returns 200" |
| `Blocked:` | Dependencies | "Blocked: Waiting on #45 to merge" |

#### Parsing Rules

1. Scan each comment for lines starting with a recognized prefix
2. Extract the content after the prefix
3. Ignore comments/lines without recognized prefixes (these are for humans)
4. A single comment may contain multiple prefixes (one per line)

#### Conflict Detection

Before proceeding, check for conflicts:

1. **Contradictory decisions** - Two `Decision:` items that contradict each other
2. **Circular blocks** - `Blocked:` references that create dependency loops

**If conflicts detected:**

```
⚠️  Conflict Detected - Cannot Proceed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The following comments appear to conflict:

Comment 1 ({date}): Decision: Use approach A
Comment 3 ({date}): Decision: Use approach B (contradicts A)

Resolution required:
• Edit or delete one of the conflicting comments
• Then re-run: /wdi:feature --promote #{issue-number}

Promotion halted.
```

**Exit without proceeding if conflicts exist.**

#### Present Parsed Items

If no conflicts, display what will be incorporated:

```
Parsed Shaping Comments
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Decisions (→ Research context):
  • Use YAML frontmatter for metadata

Tests (→ Acceptance criteria):
  • Verify /api/users returns 200

Blocked by:
  • Waiting on #45 to merge

Ignored (no prefix): 2 comments

Continue? (y)es, (a)bort:
```

### Step 3: Pre-populate Workflow Context

Create context that will pre-fill interview answers from three sources:

#### From Issue Content
- **Feature Type:** Infer from idea content (problem description, appetite)
- **Feature Description:** From Problem + Rough Solution sections

#### From Shaping Plan Files (Step 1.5)
- **Research context:** Consolidated decisions from all perspectives
- **Risks:** Aggregated risks with perspective tags
- **Scope:** In-scope/out-of-scope from shaping files
- **Cross-cutting needs:** Dependencies between business/technical/UX
- **Interview clarifications:** Open questions flagged for user input

#### From Issue Comments (Step 2)
- **Additional research context:** From `Decision:` comments (passed to `/workflows:plan`)
- **Acceptance criteria:** From `Test:` comments (added to Done When)
- **Dependencies:** From `Blocked:` comments

**Priority:** Shaping files take precedence over comments when both exist for the same decision.

### Step 4: Run Standard Workflow (Pre-populated)

Continue to **Phase 1: Interview** with pre-populated values. The user confirms or adjusts pre-filled answers.

The full workflow runs with no phases skipped:
- **Phase 1: Interview** - Pre-filled from idea, user confirms
- **Phase 2: Pre-flight** - Validates repository state
- **Phase 3: Plan** - `/workflows:plan` runs research and creates plan
- **Phase 4: Work** - `/workflows:work` implements the plan
- **Phase 5: Review** - `/workflows:review` runs all review agents
- **Phase 6: Compound** - `/workflows:compound` captures learnings, then merge

### Step 5: Update Original Issue (After Workflow Completes)

After Phase 6 completes, update the idea issue:

```bash
gh issue edit {issue-number} --body "$(cat <<'EOF'
## Summary

{brief description}

## Spec

**File:** `docs/product/planning/features/{slug}.md`

## Status

- **Promoted:** {date}
- **Completed:** {date}

---

*Promoted from idea and completed via `/wdi:feature --promote`*
EOF
)"
```

Update labels:
```bash
gh issue edit {issue-number} \
  --remove-label "idea" \
  --remove-label "status:needs-shaping" \
  --add-label "feature"
```

**Key change:** Nothing is skipped. The idea content is INPUT to the workflow, not a bypass.

---

## Phase 1: Interview

Use `AskUserQuestion` to gather context.

#### Question 1: Feature Type

```
What type of work is this?
```

| Option | Description |
|--------|-------------|
| **New Feature** | Adding new functionality that doesn't exist |
| **Enhancement** | Improving or extending existing functionality |
| **Bug Fix** | Fixing broken or incorrect behavior |
| **Refactor** | Restructuring code without changing behavior |
| **Experiment** | Exploratory work, spike, or proof of concept |

#### Question 2: Feature Description

```
Briefly describe the feature or work:
```
(Free text - used for research queries and issue creation. If a feature spec file was provided via `@file`, extract the description from it instead of asking.)

---

## Phase 2: Pre-flight Checks

Quick validation before starting work.

### Check 1: Repository Context

```bash
# Detect repository type
if [ -d "packages" ]; then
  TYPE="mono-repo"
elif [ -d ".claude-plugin" ]; then
  TYPE="plugin"
else
  TYPE="standalone"
fi
```

Confirm we're in the right repository for this work.

### Check 2: Branch Status

- Not on `main` with uncommitted changes
- Clean working tree (or offer to stash)

### Check 3: Required Files

Quick check that essential files exist:
- README.md
- docs/changelog.md (or will be created)

### Check 4: Mono-repo Detection

Detect if this is a mono-repo for later subproject targeting:

```bash
if [ -d "packages" ]; then
  IS_MONOREPO=true
  # List existing subprojects for later suggestion
  ls packages/
fi
```

---

## Phase 2.5: Learnings Search

Before invoking `/workflows:plan`, search for previously documented learnings that might be relevant to this feature. This closes the compounding feedback loop by surfacing solutions from past work.

### Step 1: Check for Learnings Sources

Check for both local and central learnings:

```bash
# Local learnings (repo-specific)
LOCAL_LEARNINGS=""
if [ -d "docs/solutions" ]; then
  LOCAL_LEARNINGS="docs/solutions"
fi

# Central learnings repo (cross-project)
CENTRAL_LEARNINGS=""
CENTRAL_PATH="$HOME/github/whitedoeinn/learnings/curated"
if [ -d "$CENTRAL_PATH" ]; then
  CENTRAL_LEARNINGS="$CENTRAL_PATH"
fi
```

**Behavior:**
- If neither exists, skip this phase silently
- If only local exists, search local only
- If only central exists, search central only
- If both exist, search both (local results shown first)

### Step 2: Extract Search Terms

#### 2a: Extract Keywords

From the feature description (interview answer), extract search keywords:
- Technology names (react, rails, zustand, stimulus, etc.)
- Pattern/component types (form, modal, list, edit, crud, etc.)
- Problem indicators (stale, bug, error, cache, state, etc.)

Use simple word extraction - no NLP required.

#### 2b: Extract Issue References

Parse the feature description and current issue body for issue references:
- `#123` - Same-repo issue reference
- `org/repo#123` - Cross-repo issue reference
- `related to #123`, `see #123`, `from #123` - Explicit relationships

```bash
# Extract issue references from description
echo "{feature-description}" | grep -oE '#[0-9]+' | sort -u
echo "{feature-description}" | grep -oE '[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+#[0-9]+' | sort -u
```

### Step 3: Search Learnings

Search both local (`docs/solutions/`) and central (`learnings/curated/`) sources.

#### 3a: Keyword Search (Local)

If local learnings exist, search YAML frontmatter:

```bash
# Search for matching tags
grep -r -l "tags:.*{keyword}" docs/solutions/ 2>/dev/null | head -5

# Search for matching symptoms
grep -r -l "symptom:.*{keyword}" docs/solutions/ 2>/dev/null | head -5

# Search titles
grep -r -l "^title:.*{keyword}" docs/solutions/ 2>/dev/null | head -5
```

#### 3b: Keyword Search (Central)

If central learnings exist, search the curated directory:

```bash
CENTRAL_PATH="$HOME/github/whitedoeinn/learnings/curated"

# Search for matching tags
grep -r -l "tags:.*{keyword}" "$CENTRAL_PATH" 2>/dev/null | head -5

# Search for matching symptoms
grep -r -l "symptom:.*{keyword}" "$CENTRAL_PATH" 2>/dev/null | head -5

# Search titles
grep -r -l "^title:.*{keyword}" "$CENTRAL_PATH" 2>/dev/null | head -5
```

#### 3c: Issue-Based Search

Search for learnings linked to referenced issues (both sources):

```bash
# Local
grep -r -l "related_issues:.*{issue-ref}" docs/solutions/ 2>/dev/null

# Central
grep -r -l "related_issues:.*{issue-ref}" "$CENTRAL_PATH" 2>/dev/null
```

This surfaces learnings from directly related prior work, not just keyword matches.

#### 3d: Combine Results

Combine results from both sources:
1. Local issue-based matches (highest priority - direct lineage)
2. Central issue-based matches
3. Local keyword matches
4. Central keyword matches (broadest - cross-project patterns)

Deduplicate by filename (same learning may exist in both places during sync).

### Step 4: Present Findings

**If matches found:**

```
Related Learnings Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found {n} related learnings:

From this repo (docs/solutions/):
  • local-pattern.md (linked to #45)
    Symptom: "specific issue"
    Tags: local, context

From central repo (learnings/curated/):
  • react-form-key-pattern.md [frontend]
    Symptom: "form shows stale data"
    Tags: react, forms, state

  • plugin-version-caching.md [backend]
    Tags: plugins, caching

These will be included in the plan context.
```

Read each matched file and extract:
- `title` from frontmatter
- `symptom` from frontmatter (if present)
- `tags` from frontmatter
- `related_issues` from frontmatter (to show lineage)
- First paragraph of solution section (brief summary)
- **Source:** local vs central (and scope for central: universal/frontend/backend/lob)

**Display priority:**
1. Local issue-based matches (most relevant - same repo lineage)
2. Central issue-based matches
3. Local keyword matches
4. Central keyword matches (broadest discovery)

**If no matches:**

```
No related learnings found
  Local: docs/solutions/ not found
  Central: ~/github/whitedoeinn/learnings/curated/ checked

Proceeding to plan phase...
```

### Step 5: Include in Plan Context

Pass the found learnings to `/workflows:plan` as additional context. Format as:

```
## Prior Art

The following previously documented solutions may be relevant:

### From This Repo

#### {learning-title-1}
**File:** `docs/solutions/{category}/{filename}.md`
**Symptom:** {symptom}
**Summary:** {first paragraph of solution}

### From Central Learnings Repo

#### {learning-title-2} [frontend]
**File:** `learnings/curated/frontend/{filename}.md`
**Symptom:** {symptom}
**Summary:** {first paragraph of solution}

#### {learning-title-3} [universal]
**File:** `learnings/curated/universal/{filename}.md`
**Summary:** {first paragraph of solution}
```

This context helps research agents avoid re-solving documented problems and build on existing patterns.

---

## Phase 3: Plan (Delegated)

**Note:** Research is handled by `/workflows:plan` - it automatically runs research agents (repo-research-analyst, best-practices-researcher, framework-docs-researcher) as part of planning.

### Invoke Planning Workflow

Use Skill tool:

```
/compound-engineering:workflows:plan
```

Pass interview answers (feature type, description).

### Generate Implementation Plan

The plan should include:
- **Requirements**: What the feature must do
- **Acceptance Criteria**: How to verify completion
- **Implementation Steps**: Ordered list of tasks
- **Files to Modify/Create**: Specific paths
- **Risks & Considerations**: What could go wrong (for complex work)

### Create GitHub Issue

```bash
gh issue create --title "{type}: {feature-name}" --body "$(cat <<'EOF'
## Overview

**Type:** {feature-type}
**Complexity:** {complexity}
**Target:** {package or repo-level}

## Requirements
{requirements}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}

## Implementation Plan
{steps}

## Files
- `{file1}` - {description}
- `{file2}` - {description}

## Research Summary
{key findings from research phase}

---
Generated by /wdi:feature
EOF
)"
```

### Save Feature Spec

Create feature specification using template:

1. Read template from `docs/templates/feature.md`
2. Fill in placeholders from interview and research
3. Save to `docs/product/planning/features/{feature-slug}.md`

Create directories if needed:
```bash
mkdir -p docs/product/planning/features
```

### Pause (unless --yes)

```
Plan Phase Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created: Issue #{issue-number}
Feature: docs/product/planning/features/{feature-slug}.md

Review the plan and continue to work? (y)es, (e)dit plan, (a)bort:
```

If `--plan`, stop here.

---

## Phase 4: Work (Delegated)

**Note:** Feature branches are deferred to #44. Currently work happens on main with quality gates.

### Invoke Work Workflow

Use Skill tool:

```
/compound-engineering:workflows:work
```

Pass the implementation plan from Phase 3.

### Execute Implementation

For each implementation step:
1. Add to TodoWrite as `in_progress`
2. **Before implementing:** Run conflict check (see below)
3. Implement the step
4. Mark as `completed`
5. Move to next step

### Implementation Conflict Detection

Before implementing each task that modifies files:

1. Check what files have already been modified:
   ```bash
   git diff --name-only
   ```

2. If the current task would change a file already modified:
   - Review the Research Summary decisions in the feature spec
   - Identify which decision drove the previous change
   - Verify the current task's changes don't contradict it

3. **If conflict detected:**
   ```
   ⚠️  Implementation Conflict Detected
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   File: config.yaml

   Previous change (Task 2): Set format to JSON
   Current task (Task 5): Set format to YAML

   These changes contradict each other.

   Resolution required:
   • Review the decisions in Research Summary
   • Determine which decision should take precedence
   • Update the feature spec if needed

   (r)esolve and continue, (a)bort:
   ```

4. **After completing each phase of tasks**, review all changes against all decisions:
   ```bash
   git diff HEAD~5..HEAD  # or appropriate range for this work
   ```
   Verify no contradictions exist before proceeding to next phase.

### Run Tests

```bash
# Detect and run appropriate tests
npm test      # if package.json exists
pytest        # if Python files changed
npm run build # if build script exists
```

If tests fail, fix issues before continuing.

### Pause (unless --yes)

```
Work Phase Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Branch: {branch}
Commits: {count}
Tests: ✓ passing

Ready for review? (y)es, (c)ontinue working, (a)bort:
```

---

## Phase 5: Review (Delegated)

Delegate to `/workflows:review` which runs 12+ agents in parallel, creates todos with priorities, and offers E2E testing.

### Step 1: Invoke Review Workflow

Use Skill tool:

```
/compound-engineering:workflows:review
```

The review workflow:
- Runs 12+ agents in parallel (architecture, security, performance, simplicity, data integrity, etc.)
- Creates todos in `todos/` directory with P1/P2/P3 priorities
- Offers E2E testing

### Step 2: Convert Findings to GitHub Issues

After review completes, convert todos to GitHub issues for tracking:

**P1 (Critical) → Blocking Issue:**
```bash
gh issue create \
  --title "BLOCKS #{feature-issue}: {finding-title}" \
  --label "p1-critical" \
  --body "$(cat <<'EOF'
{finding-content}

---
Blocks: #{feature-issue}
Created by: /wdi:feature review phase
EOF
)"
```

**P2/P3 → Related Issue:**
```bash
gh issue create \
  --title "Review: {finding-title}" \
  --label "p2-important" \
  --body "$(cat <<'EOF'
{finding-content}

---
Related to: #{feature-issue}
Created by: /wdi:feature review phase
EOF
)"
```

Add comment to feature issue listing created review issues.

### Step 3: Gate on P1

If any P1 issues created:
- **BLOCK** proceeding to Phase 6 (Compound)
- List P1 issues that must be resolved

### Pause (unless --yes)

```
Review Phase Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created issues from review findings:
  🔴 P1 (Blocking): #41, #42 - MUST resolve before merge
  🟡 P2 (Important): #43, #44
  🔵 P3 (Nice-to-have): #45

Continue to compound phase? (y)es, (f)ix P1s, (a)bort:
```

If P1 issues exist and user selects (y)es, warn again and require explicit confirmation.

---

## Phase 6: Compound and Complete

**Important:** Run compound FIRST to capture learnings while context is fresh, before the work feels "done."

### Step 1: Document Learnings (FIRST)

Invoke compound workflow before final commit:

Use Skill tool:

```
/compound-engineering:workflows:compound
```

This runs 6 parallel subagents to extract and document learnings in `docs/solutions/`.

### Step 1.5: Add Learnings to Issue

After compound completes, extract learnings from the generated solution doc and post to the feature issue:

1. Read the generated solution doc from `docs/solutions/{category}/{slug}.md`
2. Extract from YAML frontmatter:
   - `learnings` array
   - `related_issues` (should include current issue)
3. Extract from body:
   - Prevention/best practices section (if exists)
4. Post comment to feature issue:

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Compounding Learnings

Documented in `docs/solutions/{category}/{slug}.md`

### Key Learnings

{bulleted list from frontmatter learnings array}

### Prevention

{prevention section content, or omit if none}
EOF
)"
```

This creates bidirectional linking:
- Issue → Solution doc (via this comment)
- Solution doc → Issue (via `related_issues` in frontmatter)

### Step 2: Commit and Changelog

Say "commit these changes --skip-tests --yes":

The commit skill automatically updates `docs/changelog.md` with the feature entry.

### Step 3: Update Feature Spec

Mark the feature specification as complete:

1. Locate the feature spec file at `docs/product/planning/features/{feature-slug}.md`
2. Update status: `**Status:** In Progress` → `**Status:** Complete`
3. Mark all "Done When" checkboxes: `- [ ]` → `- [x]`

```markdown
# Before
**Status:** In Progress
- [ ] Criterion 1
- [ ] Criterion 2

# After
**Status:** Complete
- [x] Criterion 1
- [x] Criterion 2
```

### Step 4: Close Issue

```bash
gh issue close {issue-number} --comment "Completed in {commit-sha}"
```

### Final Output

```
Feature Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature Type: {type}

✓ Learnings documented (docs/solutions/)
✓ Committed to main
✓ Issue #{issue-number} closed
✓ Changelog updated
✓ Feature spec marked complete

Learnings captured:
• {learning 1}
• {learning 2}
```

---

## Examples

### New feature (full workflow)

```
/wdi:feature

? What type of work is this?
  → New Feature

? Briefly describe the feature:
  → "Add real-time analytics dashboard with live updating charts"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-flight: ✓ All checks passed
  Mono-repo detected: packages/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Learnings Search
  Found 2 related learnings for "real-time analytics dashboard":

  From central repo:
    • websocket-reconnection-pattern.md [frontend]
      Symptom: "WebSocket connection drops silently"
      Tags: websocket, realtime, state

    • react-form-key-pattern.md [frontend]
      Tags: react, state-management

  Included in plan context.

→ Plan Phase (delegated to /workflows:plan)
  Running research agents...
  • repo-research-analyst: Chart.js in packages/dashboard
  • best-practices-researcher: WebSocket patterns
  • framework-docs-researcher: Chart.js streaming plugin

  Created: Issue #23 "New Feature: Real-time analytics dashboard"
  Plan: docs/product/planning/features/realtime-analytics.md

  Continue to work? [y]

→ Work Phase (delegated to /workflows:work)
  ✓ Created WebSocket connection hook
  ✓ Built LiveChart component
  ✓ Integrated with existing dashboard
  Tests: ✓ passing

  Ready for review? [y]

→ Review Phase (delegated to /workflows:review)
  Running 12+ agents in parallel...

  Created issues from findings:
    🟡 P2: #45 - Consider debouncing updates

  Continue to compound? [y]

→ Compound Phase (delegated to /workflows:compound)
  ✓ Learnings documented (docs/solutions/realtime-analytics.md)
  ✓ Issue #23 closed
  ✓ Changelog updated

  Learnings captured:
  • lib-ws handles reconnection automatically
  • Chart.js streaming plugin simplifies live updates

✓ Feature complete
```

### Quick bug fix

```
/wdi:feature

? What type of work is this?
  → Bug Fix

? Briefly describe the feature:
  → "Fix navigation links not highlighting on mobile"

→ Pre-flight: ✓ All checks passed

→ Plan Phase
  Created: Issue #24 "Bug Fix: Mobile nav highlighting"

→ Work Phase
  ✓ Fixed CSS media query
  Tests: ✓ passing

→ Review Phase
  No P1/P2/P3 findings

→ Compound Phase
  ✓ Learnings documented
  ✓ Committed, closed, updated

✓ Bug fix complete
```

### Enhancement with feature spec provided

```
/wdi:feature @docs/product/planning/features/dark-mode.md

? What type of work is this?
  → Enhancement

  (Description extracted from spec: "Add dark mode support across all pages")

→ Plan Phase
  Running research agents...
  • DaisyUI supports data-theme attribute
  • 15 pages need theme-aware styling
  • LocalStorage can persist preference

  Updated: docs/product/planning/features/dark-mode.md
  Created: Issue #25 "Enhancement: Dark mode support"

  Continue to work? [y]

...
```

### Experiment with minimal overhead

```
/wdi:feature --yes

? What type of work is this?
  → Experiment

? Briefly describe the feature:
  → "Test GraphQL subscriptions for live data"

→ Plan Phase
→ Work Phase
  Branch: experiment/graphql-subscriptions
→ Review Phase
→ Compound Phase

✓ Experiment complete

Note: Experiment branches can be deleted after 90 days
if not promoted to permanent feature.
```

---

## Notes

- All phases delegate to compound-engineering workflows (`/workflows:plan`, `/workflows:work`, `/workflows:review`, `/workflows:compound`)
- **Learnings Search** runs before planning to surface previously documented solutions from `docs/solutions/`
- Research is included in `/workflows:plan` - no separate research phase
- Use `--yes` for experienced users who know the codebase
- All phases can be aborted without side effects (except created branches/issues)
- Requires compound-engineering plugin for planning, work, review, and compound workflows
- Requires `gh` CLI authenticated for issue creation
- Feature specs use template from `docs/templates/feature.md`
- Feature specs saved to `docs/product/planning/features/`
- Review findings are converted to GitHub issues (P1=blocking, P2/P3=related)
- Learnings are captured via `/workflows:compound` BEFORE merge
- See PROJECT-STRUCTURE.md for full product documentation layout
