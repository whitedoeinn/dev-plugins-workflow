---
description: Feature workflow - from idea to shipped, with the journey documented
---

# /wdi:workflow-feature

One command for the entire feature lifecycle. Captures ideas, plans work, builds features, and documents the journey.

## Usage

```bash
/wdi:workflow-feature              # Start something new
/wdi:workflow-feature #45          # Continue existing issue #45
/wdi:workflow-feature --yes        # Auto-continue through phases
/wdi:workflow-feature --plan       # Stop after planning
```

## How It Works

**The GitHub issue IS the document.** One issue per feature. Comments are the timeline. Labels show the state. The close comment captures the outcome.

```
Quick Idea:     Sentence → Issue → Done (30 seconds)
Build Feature:  Plan → Work → Review → Compound → Done (full journey documented)
Continue:       Pick up any issue from where it left off
```

---

## Entry Point

### If Issue Number Provided (`#N`)

Continue working on existing issue. Jump to **Continue Mode**.

### If No Issue Number

Ask what the user wants to do:

```
What would you like to do?
```

| Option | Description |
|--------|-------------|
| **Quick idea** | Capture a thought in one sentence (done in 30 seconds) |
| **Build something** | Plan, build, review, and ship (full workflow) |

---

## Quick Idea Mode

Minimal friction. Capture the thought before it escapes.

### Step 1: Get the Idea

```
What's the idea? (one sentence)
```

Free text. Could be "phase labels on issues" or "that auth thing we discussed" or anything.

### Step 2: Create Issue

```bash
# Create labels if needed
gh label create "idea" --color "c5def5" --description "Captured idea" 2>/dev/null || true

# Create minimal issue
gh issue create \
  --title "{idea-sentence}" \
  --label "idea" \
  --body "$(cat <<'EOF'
Captured for later.

---
*Quick idea via `/wdi:workflow-feature`*
EOF
)"
```

### Step 3: Done

```
Idea Captured
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Issue #{number}: {idea-sentence}

Later:
• Add context as comments on the issue
• Continue with: /wdi:workflow-feature #{number}
```

**Exit. That's it.**

---

## Continue Mode

When invoked with an issue number: `/wdi:workflow-feature #45`

### Step 1: Fetch Issue State

```bash
gh issue view {issue-number} --json title,body,labels,state,comments
```

### Step 2: Determine Current Phase

Check labels to understand where we are:

| Label | State | Action |
|-------|-------|--------|
| `idea` (no phase label) | Not started | Ask: ready to plan, or add more context? |
| `phase:planning` | In planning | Resume Plan phase |
| `phase:working` | In work | Resume Work phase |
| `phase:reviewing` | In review | Resume Review phase |
| `phase:compounding` | Capturing learnings | Resume Compound phase |
| (closed) | Done | Inform user, offer to reopen |

### Step 3: Handle "idea" State (Not Started)

If issue has `idea` label but no `phase:` label:

```
Issue #{number}: {title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{Show issue body and any comments}

What would you like to do?
```

| Option | Description |
|--------|-------------|
| **Start building** | Begin Plan phase (full workflow) |
| **Add context** | Add more details to the issue, then decide |
| **Close it** | This idea isn't worth pursuing |

If **Start building**: Remove `idea` label, proceed to **Phase 1: Pre-flight**.

If **Add context**:
```
What context would you like to add?
```
Post as comment, then ask again.

If **Close it**:
```bash
gh issue close {issue-number} --comment "Decided not to pursue this idea."
```

### Step 4: Handle Active Phase

If issue has a `phase:` label, resume that phase. Read the last comment to understand progress, then continue from there.

---

## Build Mode (Full Workflow)

When user selects "Build something" from the entry point.

### Overview

```
Pre-flight → Learnings Search → Plan → Work → Review → Compound
```

Each phase:
1. Updates the issue with progress
2. Pauses for approval (unless `--yes`)
3. Can be resumed if interrupted

---

## Phase 1: Pre-flight

Quick validation before starting.

### Checks

```bash
# Repository type
if [ -d ".claude-plugin" ]; then
  TYPE="plugin"
elif [ -d "packages" ]; then
  TYPE="mono-repo"
else
  TYPE="standalone"
fi

# Branch status
BRANCH=$(git branch --show-current)
UNCOMMITTED=$(git status --porcelain | wc -l)

# Required files
[ -f "README.md" ] && README="✓" || README="✗"
```

### Output

```
Pre-flight
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Repository: {type}
✓ Branch: {branch}
{✓ or ⚠} Uncommitted: {count} files
✓ README exists

Continue? (y)es, (a)bort:
```

---

## Phase 2: Learnings Search

Surface relevant prior work before planning.

### Step 1: Check Sources

```bash
LOCAL=""
CENTRAL=""
[ -d "docs/solutions" ] && LOCAL="docs/solutions"
[ -d "$HOME/github/whitedoeinn/learnings/curated" ] && CENTRAL="$HOME/github/whitedoeinn/learnings/curated"
```

### Step 2: Search

Extract keywords from issue title/body, search for matches in:
- Local: `docs/solutions/`
- Central: `~/github/whitedoeinn/learnings/curated/`

```bash
grep -r -l -i "{keyword}" docs/solutions/ 2>/dev/null | head -5
grep -r -l -i "{keyword}" "$CENTRAL" 2>/dev/null | head -5
```

### Step 3: Present Findings

**If matches found:**

```
Learnings Search
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found {n} related learnings:
  • {filename} - {title from frontmatter}
  • {filename} - {title}

These will inform the plan.
```

**If no matches:**

```
No related learnings found. This is novel work.
```

### Step 4: Update Issue

Post learnings search results:

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Learnings Search

{Found N related learnings / No prior art found}

{List of learnings with brief summaries}

---
*Phase: Learnings Search*
EOF
)"
```

---

## Phase 3: Plan

Research, design, and document what we're building.

### Step 1: Create Phase Labels

```bash
gh label create "phase:planning" --color "1D76DB" --description "In planning" 2>/dev/null || true
gh label create "phase:working" --color "0E8A16" --description "In work" 2>/dev/null || true
gh label create "phase:reviewing" --color "FBCA04" --description "In review" 2>/dev/null || true
gh label create "phase:compounding" --color "6F42C1" --description "Capturing learnings" 2>/dev/null || true
```

### Step 2: Update Labels

```bash
gh issue edit {issue-number} --remove-label "idea" --add-label "phase:planning"
```

### Step 3: Gather Context

If coming from Quick Idea (minimal context), ask:

```
What problem does this solve?
```

```
What's the rough approach?
```

### Step 4: Invoke Planning

Delegate to compound-engineering:

```
/compound-engineering:workflows:plan
```

Pass: issue title, problem statement, any context from issue body/comments, learnings found.

### Step 5: Update Issue with Plan

Update the issue body with the plan:

```bash
gh issue edit {issue-number} --body "$(cat <<'EOF'
## Problem

{problem statement}

## Solution

{approach}

## Plan

{implementation steps from /workflows:plan}

## Files

{files to modify}

---
*Planned via `/wdi:workflow-feature`*
EOF
)"
```

Post plan summary as comment:

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Plan Created

### Research Summary
{key findings}

### Decisions
{key decisions and why}

### Risks
{identified risks, or "None identified"}

---
*Phase: Plan*
EOF
)"
```

### Pause (unless --yes)

```
Plan Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issue #{number} updated with plan.

Continue to work? (y)es, (e)dit plan, (a)bort:
```

If `--plan`, stop here. Note: Issue retains `phase:planning` label.

---

## Phase 4: Work

Build the thing.

### Step 1: Update Label

```bash
gh issue edit {issue-number} --remove-label "phase:planning" --add-label "phase:working"
```

### Step 2: Invoke Work

Delegate to compound-engineering:

```
/compound-engineering:workflows:work
```

Pass the plan from Phase 3.

### Step 3: Run Tests

```bash
# Detect and run appropriate tests
./scripts/run-tests.sh  # if exists
npm test                # if package.json
pytest                  # if Python
```

### Step 4: Update Issue

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Work Complete

### What Was Built
{summary of implementation}

### Tests
{passing/failing status}

### Deviations from Plan
{any changes from original plan, or "None - implemented as planned"}

---
*Phase: Work*
EOF
)"
```

### Pause (unless --yes)

```
Work Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests: ✓ passing

Continue to review? (y)es, (c)ontinue working, (a)bort:
```

---

## Phase 5: Review

Multi-agent review to catch issues before shipping.

### Step 1: Update Label

```bash
gh issue edit {issue-number} --remove-label "phase:working" --add-label "phase:reviewing"
```

### Step 2: Invoke Review

Delegate to compound-engineering:

```
/compound-engineering:workflows:review
```

Runs 12+ review agents in parallel.

### Step 3: Handle Findings

**P1 (Blocking):** Must fix before continuing. Create linked issues.

```bash
gh issue create \
  --title "BLOCKS #{issue-number}: {finding}" \
  --label "p1-critical" \
  --body "{details}

---
Blocks: #{issue-number}"
```

**P2/P3:** Create issues for later, don't block.

### Step 4: Update Issue

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Review Complete

**Findings:**
- 🔴 P1 (Blocking): {count} {links if any}
- 🟡 P2 (Important): {count}
- 🔵 P3 (Nice-to-have): {count}

{If P1s: "⚠️ Must resolve P1s before continuing."}
{If no P1s: "✓ No blocking issues."}

---
*Phase: Review*
EOF
)"
```

### Gate on P1

If P1 issues exist, **stop**. Fix them first, then resume with:

```
/wdi:workflow-feature #{issue-number}
```

### Pause (unless --yes)

```
Review Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Findings: 0 P1, 2 P2, 1 P3

Continue to compound? (y)es, (f)ix issues, (a)bort:
```

---

## Phase 6: Compound and Complete

Capture learnings, commit, close.

### Step 1: Update Label

```bash
gh issue edit {issue-number} --remove-label "phase:reviewing" --add-label "phase:compounding"
```

### Step 2: Invoke Compound

Delegate to compound-engineering:

```
/compound-engineering:workflows:compound
```

Creates learning doc in `docs/solutions/`.

### Step 3: Post Learnings to Issue

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Learnings Captured

Documented in `docs/solutions/{category}/{slug}.md`

### Key Learnings
{bullets from the learning doc}

### Prevention
{what to do differently next time, if applicable}

---
*Phase: Compound*
EOF
)"
```

### Step 4: Commit

Use the commit skill:

```
commit these changes
```

### Step 5: Close Issue

```bash
gh issue edit {issue-number} --remove-label "phase:compounding"
gh issue close {issue-number} --comment "$(cat <<'EOF'
## Complete

**Commit:** {sha}
**Learnings:** `docs/solutions/{category}/{slug}.md`

### Outcome
{One of:}
✓ Completed as planned
✓ Completed with modifications: {what changed}
⚠️ Partially completed: {what's left, link to follow-up issue}

### Summary
{One sentence describing what shipped}

---
*Closed via `/wdi:workflow-feature`*
EOF
)"
```

### Final Output

```
Feature Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Issue #{number} closed
✓ Learnings documented
✓ Committed to main

The journey is documented in the issue history.
```

---

## The Issue as Documentation

When you look back at any issue, you'll see:

```
#{number}: {title}
├── [Body] Problem, Solution, Plan
├── [Comment] Learnings Search - prior art found
├── [Comment] Plan - research summary, decisions
├── [Comment] Work - what was built, deviations
├── [Comment] Review - findings, what was fixed
├── [Comment] Learnings - what we learned
└── [Closed] Outcome + summary
```

The issue IS the documentation. No separate artifacts to maintain.

---

## Notes

- All heavy lifting delegates to compound-engineering (`/workflows:plan`, `/workflows:work`, `/workflows:review`, `/workflows:compound`)
- Phase labels enable at-a-glance status and filtering (`label:phase:working`)
- Resume any issue from where it left off with `/wdi:workflow-feature #N`
- Use `--yes` for auto-continue, `--plan` to stop after planning
- Learnings are captured in `docs/solutions/` for future reference
