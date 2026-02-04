---
description: Feature workflow - from idea to shipped, with the journey documented
---

# /wdi:workflow-feature

> **⚠️ DEPRECATED:** Use `/wdi:workflow` instead.
> - For exploration (default): `/wdi:workflow`
> - For direct implementation: `/wdi:workflow --skip-explore`
> This command redirects to `/wdi:workflow --skip-explore`.

---

One command for the entire feature lifecycle. Captures ideas, plans work, builds features, and documents the journey.

## Usage

```bash
/wdi:workflow-feature              # Start something new (interactive)
/wdi:workflow-feature #45          # Continue existing issue #45
/wdi:workflow-feature --yes        # Auto-continue through phases
/wdi:workflow-feature --plan       # Stop after planning
/wdi:workflow-feature --idea "text"  # Quick capture an idea

# Headless/Agent mode
/wdi:workflow-feature #45 --headless                     # Run to completion, no prompts
/wdi:workflow-feature #45 --headless --stop-after=plan   # Stop after planning phase
/wdi:workflow-feature #45 --resume-from=review           # Jump to review phase
/wdi:workflow-feature #45 --retry                        # Re-run current phase
/wdi:workflow-feature #45 --status                       # Read-only status check
```

## Flags Reference

| Flag | Purpose |
|------|---------|
| `--yes` | Auto-continue through phases (still may prompt on errors) |
| `--plan` | Stop after planning phase |
| `--idea "text"` | Quick idea capture (creates issue immediately) |
| `--headless` | Agent mode: no prompts, bail on ambiguity |
| `--stop-after=PHASE` | Stop after completing PHASE |
| `--resume-from=PHASE` | Start from PHASE (skip earlier phases) |
| `--retry` | Re-run the current phase |
| `--status` | Read-only inspection, no changes |

**Phase names:** `learnings`, `plan`, `work`, `review`, `compound`

## How It Works

**The GitHub issue IS the document.** One issue per feature. Comments are the timeline. Labels show the state. The close comment captures the outcome.

```
Quick Idea:     Sentence → Issue → Done (30 seconds)
Build Feature:  Learnings → Plan → Work → Review → Compound → Done
Continue:       Pick up any issue from where it left off
```

---

## Headless Mode (`--headless`)

For agent execution or experienced users who want no prompts.

### Behavior

- **No prompts:** All decisions made automatically or from issue context
- **Bail on ambiguity:** If state unclear, ERROR instead of asking
- **All params required:** Missing context = error, not prompt
- **Structured output:** Comments posted in machine-readable format

### Bail Conditions (Error and Stop)

In headless mode, ERROR immediately if:

1. **Can't determine phase:** Labels missing or conflicting
2. **Invalid issue structure:** Not created via workflow (missing expected sections)
3. **Missing prerequisites:** Required context for phase not present
4. **Illogical flags:** `--stop-after=X` where X already passed, etc.
5. **External failures:** gh CLI errors, test failures (depending on phase)

### Error Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ERROR: Cannot continue in headless mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reason: [specific reason]
Issue:  #{number} - {title}
State:  [detected state or "unknown"]
Phase:  [current phase or "indeterminate"]

Suggestion: [actionable fix]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Status Mode (`--status`)

Read-only inspection of issue state. No changes made.

### Output

```
Issue Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issue:  #{number} - {title}
State:  {open/closed}
Phase:  {current phase label}

Progress:
  ✓ Learnings search: {found N learnings / no prior art}
  ✓ Plan: {created YYYY-MM-DD}
  → Work: {in progress / not started}
  ○ Review: {not started}
  ○ Compound: {not started}

Context Available:
  - Research findings: {yes/no}
  - Plan document: {yes/no}
  - Work summary: {yes/no}
  - Review findings: {yes/no}

Next: {description of next action}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Entry Point

### Flag Processing (First)

Parse flags before anything else:

```bash
HEADLESS=false
STOP_AFTER=""
RESUME_FROM=""
RETRY=false
STATUS=false
ISSUE_NUM=""
IDEA_TEXT=""

for arg in "$@"; do
  case "$arg" in
    --headless) HEADLESS=true ;;
    --stop-after=*) STOP_AFTER="${arg#*=}" ;;
    --resume-from=*) RESUME_FROM="${arg#*=}" ;;
    --retry) RETRY=true ;;
    --status) STATUS=true ;;
    --yes) AUTO_YES=true ;;
    --plan) STOP_AFTER="plan" ;;
    --idea) IDEA_MODE=true ;;
    \#*) ISSUE_NUM="${arg#\#}" ;;
    *) 
      if [ "$IDEA_MODE" = true ]; then
        IDEA_TEXT="$arg"
      fi
      ;;
  esac
done
```

### Validate Flag Combinations

```bash
# --headless requires issue number (can't create interactively)
if [ "$HEADLESS" = true ] && [ -z "$ISSUE_NUM" ]; then
  ERROR "Headless mode requires issue number"
fi

# --retry requires issue number
if [ "$RETRY" = true ] && [ -z "$ISSUE_NUM" ]; then
  ERROR "Retry requires issue number"
fi

# --resume-from requires issue number
if [ -n "$RESUME_FROM" ] && [ -z "$ISSUE_NUM" ]; then
  ERROR "Resume-from requires issue number"
fi

# Can't combine --retry with --resume-from
if [ "$RETRY" = true ] && [ -n "$RESUME_FROM" ]; then
  ERROR "Cannot combine --retry with --resume-from"
fi
```

### Route to Mode

```
If --status        → Status Mode (read-only)
If --idea "text"   → Quick Idea Mode
If ISSUE_NUM       → Continue Mode
Else               → Interactive Entry (ask what to do)
```

---

## Quick Idea Mode

Minimal friction. Capture the thought before it escapes.

### Via `--idea` flag

```bash
/wdi:workflow-feature --idea "Add guest allergy tracking"
```

Creates issue immediately without prompts.

### Interactive (no issue number, user selects "Quick idea")

```
What's the idea? (one sentence)
```

### Create Issue

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

### Output

```
Idea Captured
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Issue #{number}: {idea-sentence}

Later:
• Add context as comments on the issue
• Continue with: /wdi:workflow-feature #{number}
```

---

## Continue Mode

When invoked with an issue number: `/wdi:workflow-feature #45`

### Step 1: Fetch Issue State

```bash
ISSUE_DATA=$(gh issue view {issue-number} --json number,title,body,labels,state,comments)

# Extract fields
TITLE=$(echo "$ISSUE_DATA" | jq -r '.title')
STATE=$(echo "$ISSUE_DATA" | jq -r '.state')
LABELS=$(echo "$ISSUE_DATA" | jq -r '.labels[].name' | tr '\n' ',')
```

### Step 2: Validate Issue Exists

If the `gh issue view` command fails:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ERROR: Issue Not Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issue #{number} does not exist in this repository.

Suggestion:
  - List ideas: gh issue list --label idea
  - Create new: /wdi:workflow-feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Exit.**

### Step 3: Determine Current Phase

```bash
detect_phase() {
  case "$LABELS" in
    *phase:compounding*) echo "compound" ;;
    *phase:reviewing*)   echo "review" ;;
    *phase:working*)     echo "work" ;;
    *phase:planned*)     echo "plan-complete" ;;
    *phase:planning*)    echo "plan" ;;
    *phase:researched*)  echo "learnings-complete" ;;
    *idea*)              echo "idea" ;;
    *)                   echo "unknown" ;;
  esac
}

CURRENT_PHASE=$(detect_phase)
```

### Step 4: Validate Phase (Headless Mode)

In headless mode, bail if phase is unclear:

```bash
if [ "$HEADLESS" = true ] && [ "$CURRENT_PHASE" = "unknown" ]; then
  ERROR "Cannot determine phase" \
    "Issue labels don't indicate workflow state" \
    "Add appropriate phase label or run interactively"
fi
```

### Step 5: Validate `--stop-after` Flag

```bash
PHASE_ORDER=("learnings" "plan" "work" "review" "compound")

phase_index() {
  local phase=$1
  for i in "${!PHASE_ORDER[@]}"; do
    if [[ "${PHASE_ORDER[$i]}" == "$phase" ]]; then
      echo $i
      return
    fi
  done
  echo -1
}

if [ -n "$STOP_AFTER" ]; then
  STOP_IDX=$(phase_index "$STOP_AFTER")
  CURRENT_IDX=$(phase_index "$CURRENT_PHASE")
  
  if [ "$STOP_IDX" -lt "$CURRENT_IDX" ]; then
    ERROR "Invalid --stop-after" \
      "Issue is at '$CURRENT_PHASE' but --stop-after='$STOP_AFTER'" \
      "Cannot go backward. Use --resume-from to restart from a phase."
  fi
fi
```

### Step 6: Validate `--resume-from` Flag

```bash
if [ -n "$RESUME_FROM" ]; then
  RESUME_IDX=$(phase_index "$RESUME_FROM")
  CURRENT_IDX=$(phase_index "$CURRENT_PHASE")
  
  # Validate phase name
  if [ "$RESUME_IDX" -eq -1 ]; then
    ERROR "Invalid phase name" \
      "'$RESUME_FROM' is not a valid phase" \
      "Valid phases: learnings, plan, work, review, compound"
  fi
  
  # Warn if skipping phases (interactive only)
  if [ "$RESUME_IDX" -gt "$CURRENT_IDX" ] && [ "$HEADLESS" != true ]; then
    echo "Warning: Skipping from '$CURRENT_PHASE' to '$RESUME_FROM'"
    echo "Some context may be missing."
    read -p "Continue? (y/n): " CONFIRM
    [ "$CONFIRM" != "y" ] && exit 0
  fi
  
  # In headless mode, just validate prerequisites exist
  if [ "$HEADLESS" = true ] && [ "$RESUME_IDX" -gt "$CURRENT_IDX" ]; then
    validate_prerequisites "$RESUME_FROM"
  fi
  
  # Override current phase
  CURRENT_PHASE="$RESUME_FROM-start"
fi
```

### Step 7: Handle `--retry` Flag

```bash
if [ "$RETRY" = true ]; then
  # Keep current phase, mark as retry
  RETRY_MODE=true
  
  # Post retry notice
  gh issue comment {issue-number} --body "$(cat <<'EOF'
## Retry Attempt

Retrying phase: **{CURRENT_PHASE}**
Previous attempt preserved above for reference.

---
*Retry via `/wdi:workflow-feature --retry`*
EOF
)"
fi
```

### Step 8: Route to Phase

```bash
case "$CURRENT_PHASE" in
  idea)               start_from_learnings ;;
  learnings-start)    run_learnings_phase ;;
  learnings-complete) 
    if should_continue "plan"; then start_plan_phase; fi ;;
  plan|plan-start)    run_plan_phase ;;
  plan-complete)      
    if should_continue "work"; then start_work_phase; fi ;;
  work|work-start)    run_work_phase ;;
  work-complete)      
    if should_continue "review"; then start_review_phase; fi ;;
  review|review-start) run_review_phase ;;
  review-complete)    
    if should_continue "compound"; then start_compound_phase; fi ;;
  compound)           run_compound_phase ;;
  *)
    if [ "$HEADLESS" = true ]; then
      ERROR "Unknown phase state"
    else
      echo "Issue is in an unknown state. What would you like to do?"
      # Interactive recovery...
    fi
    ;;
esac

# Helper: Check if we should continue to next phase
should_continue() {
  local next_phase=$1
  
  # Check --stop-after
  if [ -n "$STOP_AFTER" ]; then
    NEXT_IDX=$(phase_index "$next_phase")
    STOP_IDX=$(phase_index "$STOP_AFTER")
    if [ "$NEXT_IDX" -gt "$STOP_IDX" ]; then
      echo "Stopped after $STOP_AFTER phase as requested."
      return 1
    fi
  fi
  
  # In headless mode, always continue
  if [ "$HEADLESS" = true ]; then
    return 0
  fi
  
  # In --yes mode, always continue
  if [ "$AUTO_YES" = true ]; then
    return 0
  fi
  
  # Otherwise prompt
  read -p "Continue to $next_phase? (y/n): " CONFIRM
  [ "$CONFIRM" = "y" ]
}
```

---

## Build Mode (Full Workflow)

When starting fresh on an idea issue or new feature.

### Overview

```
Learnings Search → Plan → Work → Review → Compound
```

Each phase:
1. Updates the issue with progress
2. Posts structured comment for context preservation
3. Pauses for approval (unless `--headless` or `--yes`)
4. Can be resumed if interrupted

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

### Output (Interactive)

```
Pre-flight
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Repository: {type}
✓ Branch: {branch}
{✓ or ⚠} Uncommitted: {count} files
✓ README exists

Continue? (y)es, (a)bort:
```

### Headless Behavior

Skip confirmation, just validate. If critical issues, bail:

```bash
if [ "$HEADLESS" = true ] && [ "$UNCOMMITTED" -gt 10 ]; then
  ERROR "Too many uncommitted files" \
    "$UNCOMMITTED uncommitted files detected" \
    "Commit or stash changes before running headless"
fi
```

---

## Phase 2: Learnings Search

Surface relevant prior work before planning.

### Step 1: Check Sources

```bash
LOCAL=""
CENTRAL=""
[ -d "docs/solutions" ] && LOCAL="docs/solutions"

# Detect org for learnings path (falls back to whitedoeinn if not detected)
ORG="${WDI_ORG:-whitedoeinn}"
[ -d "$HOME/github/${ORG}/learnings/curated" ] && CENTRAL="$HOME/github/${ORG}/learnings/curated"
```

### Step 2: Search

Extract keywords from issue title/body, search for matches:

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

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Learnings Search

{Found N related learnings / No prior art found}

{List of learnings with brief summaries}

---
*Phase: Learnings Search*
EOF
)"

# Update label
gh issue edit {issue-number} --add-label "phase:researched" 2>/dev/null || true
```

### Step 5: Check Stop Condition

```bash
if [ "$STOP_AFTER" = "learnings" ]; then
  echo "✓ Learnings search complete. Stopped as requested."
  exit 0
fi
```

---

## Phase 3: Plan

Research, design, and document what we're building.

### Step 1: Update Labels

```bash
gh label create "phase:planning" --color "1D76DB" --description "In planning" 2>/dev/null || true
gh issue edit {issue-number} --remove-label "idea" --remove-label "phase:researched" --add-label "phase:planning"
```

### Step 2: Gather Context

If minimal context (from Quick Idea), and NOT headless:

```
What problem does this solve?
```

```
What's the rough approach?
```

In headless mode, extract from issue body or bail:

```bash
if [ "$HEADLESS" = true ]; then
  PROBLEM=$(extract_section "Problem" "$ISSUE_BODY")
  if [ -z "$PROBLEM" ]; then
    ERROR "Missing problem statement" \
      "Issue body doesn't contain a Problem section" \
      "Add problem statement to issue or run interactively"
  fi
fi
```

### Step 3: Invoke Planning

Delegate to compound-engineering:

```
/compound-engineering:workflows:plan
```

Pass: issue title, problem statement, any context from issue body/comments, learnings found.

### Step 4: Update Issue with Plan

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

# Update label
gh issue edit {issue-number} --remove-label "phase:planning" --add-label "phase:planned"
```

Post plan summary as comment:

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Plan Created

### Research Summary
{key findings}

### Key Design Decisions
| Decision | Rationale |
|----------|-----------|
{decisions table}

### Risks Identified
{identified risks, or "None identified"}

---
*Phase: Plan*
EOF
)"
```

### Step 5: Check Stop Condition

```bash
if [ "$STOP_AFTER" = "plan" ]; then
  echo "✓ Planning complete. Stopped as requested."
  exit 0
fi
```

### Pause (Interactive Only)

```
Plan Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issue #{number} updated with plan.

Continue to work? (y)es, (e)dit plan, (a)bort:
```

---

## Phase 4: Work

Build the thing.

### Step 1: Update Label

```bash
gh issue edit {issue-number} --remove-label "phase:planned" --add-label "phase:working"
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
if [ -f "./scripts/run-tests.sh" ]; then
  ./scripts/run-tests.sh
elif [ -f "package.json" ]; then
  npm test
elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
  pytest
fi
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

# Update label
gh issue edit {issue-number} --remove-label "phase:working" --add-label "phase:worked"
```

### Step 5: Check Stop Condition

```bash
if [ "$STOP_AFTER" = "work" ]; then
  echo "✓ Work complete. Stopped as requested."
  exit 0
fi
```

### Pause (Interactive Only)

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
gh issue edit {issue-number} --remove-label "phase:worked" --add-label "phase:reviewing"
```

### Step 2: Invoke Review

Delegate to compound-engineering:

```
/compound-engineering:workflows:review
```

Runs 12+ review agents in parallel.

### Step 3: Handle Findings

**P1 (Blocking):** Must fix before continuing.

```bash
# In headless mode, bail on P1s
if [ "$HEADLESS" = true ] && [ "$P1_COUNT" -gt 0 ]; then
  ERROR "P1 findings block completion" \
    "$P1_COUNT blocking issues found" \
    "Fix P1s and run: /wdi:workflow-feature #{number} --headless"
fi
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

# Update label (only if no P1s)
if [ "$P1_COUNT" -eq 0 ]; then
  gh issue edit {issue-number} --remove-label "phase:reviewing" --add-label "phase:reviewed"
fi
```

### Step 5: Check Stop Condition

```bash
if [ "$STOP_AFTER" = "review" ]; then
  echo "✓ Review complete. Stopped as requested."
  exit 0
fi
```

### Gate on P1

If P1 issues exist, **stop**. Fix them first, then resume.

---

## Phase 6: Compound and Complete

Capture learnings, commit, close.

### Step 1: Update Label

```bash
gh issue edit {issue-number} --remove-label "phase:reviewed" --add-label "phase:compounding"
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

- All heavy lifting delegates to compound-engineering
- Phase labels enable at-a-glance status and filtering
- Resume any issue from where it left off
- Use `--headless` for agent execution
- Use `--stop-after=PHASE` for partial runs
- Learnings are captured in `docs/solutions/` for future reference
- In headless mode, all errors are explicit with suggestions
