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
Interview → Pre-flight → Plan → Work → Review → Compound
```

**Note:** Research is now included within `/workflows:plan` (compound-engineering runs research agents automatically).

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
• Shape the idea by adding comments to the issue
• Promote to feature when ready: /wdi:feature --promote #{issue-number}
• Or close the issue if the idea doesn't pan out
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

Create context that will pre-fill interview answers:
- **Feature Type:** Infer from idea content (problem description, appetite)
- **Feature Description:** From Problem + Rough Solution sections
- **Research context:** From `Decision:` comments (passed to `/workflows:plan`)
- **Acceptance criteria:** From `Test:` comments (added to Done When)
- **Dependencies:** From `Blocked:` comments

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

### Create Feature Branch

Branch naming based on feature type:

| Type | Branch Pattern |
|------|----------------|
| New Feature | `feature/{slug}` |
| Enhancement | `feature/{slug}` |
| Bug Fix | `fix/{issue-number}-{slug}` |
| Refactor | `refactor/{slug}` |
| Experiment | `experiment/{slug}` |

```bash
git checkout -b {branch-pattern}
```

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
   git diff main...HEAD
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

**Important:** Run compound FIRST (while on feature branch) to capture learnings while context is fresh, then merge.

### Step 1: Document Learnings (FIRST)

While still on feature branch, invoke compound workflow:

Use Skill tool:

```
/compound-engineering:workflows:compound
```

This runs 6 parallel subagents to extract and document learnings in `docs/solutions/`.

### Step 2: Merge to Main

Direct merge (PR-based review tracked in Issue #33):

```bash
git checkout main
git pull
git merge --no-ff {branch} -m "Merge {branch}"
```

### Step 3: Commit and Changelog

Say "commit these changes --yes":

The commit skill automatically updates `docs/changelog.md` with the feature entry.

### Step 4: Update Feature Spec

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

### Step 5: Cleanup

```bash
git branch -d {branch}
git push origin --delete {branch}  # if pushed
```

### Step 6: Close Issue

```bash
gh issue close {issue-number} --comment "Completed in {commit-sha}"
```

### Final Output

```
Feature Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature Type: {type}

✓ Learnings documented (docs/solutions/)
✓ Merged to main
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

→ Plan Phase (delegated to /workflows:plan)
  Running research agents...
  • repo-research-analyst: Chart.js in packages/dashboard
  • best-practices-researcher: WebSocket patterns
  • framework-docs-researcher: Chart.js streaming plugin

  Created: Issue #23 "New Feature: Real-time analytics dashboard"
  Plan: docs/product/planning/features/realtime-analytics.md

  Continue to work? [y]

→ Work Phase (delegated to /workflows:work)
  Branch: feature/realtime-analytics
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
  ✓ Merged to main
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
  Branch: fix/24-mobile-nav
  ✓ Fixed CSS media query
  Tests: ✓ passing

→ Review Phase
  No P1/P2/P3 findings

→ Compound Phase
  ✓ Learnings documented
  ✓ Merged, closed, updated

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
