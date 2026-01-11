---
description: Full feature workflow with research, planning, implementation, and review (project)
---

# /wdi-workflows:feature - Compound Engineering Feature Workflow

Full feature development workflow using an interview-driven approach to tailor research, planning, and review phases.

## Flags

| Flag | Description |
|------|-------------|
| `--yes` | Auto-continue through phases (no pauses) |
| `--plan-only` | Stop after planning phase |

---

## Workflow Overview

```
Interview → Pre-flight → Research → Plan → Work → Review → Compound
```

Each phase pauses for approval unless `--yes` is passed.

---

## Phase 1: Interview

Use `AskUserQuestion` to gather context. Answers determine which agents to run and how deep to plan.

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

#### Question 2: Complexity Assessment

```
How complex is this work?
```

| Option | Description |
|--------|-------------|
| **Simple** | 1-2 files, straightforward implementation |
| **Moderate** | Multiple files, some design decisions needed |
| **Complex** | Architectural changes, extensive testing required |
| **Unknown** | Need research to determine scope |

#### Question 3: Target Location (Mono-repos Only)

If repository has `packages/` directory:

```
Where does this work belong?
```

| Option | Description |
|--------|-------------|
| **{package-1}** | Existing package (dynamically listed) |
| **{package-2}** | Existing package (dynamically listed) |
| **New Package** | Create new package first (triggers /new-package) |
| **Repo-Level** | Shared code, scripts, or root-level changes |

#### Question 4: Research Preference

```
How much research should we do?
```

| Option | Description |
|--------|-------------|
| **Full Research** | Run all relevant agents (recommended for complex/unknown) |
| **Light Research** | Quick codebase scan only |
| **Skip Research** | Go straight to planning (you know the codebase well) |

#### Question 5: Feature Description

```
Briefly describe the feature or work:
```
(Free text - used for research queries and issue creation)

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

### Check 4: New Package (If Selected)

If user selected "New Package" in Question 3:

```
You selected "New Package". Let's create it first.
```

Invoke `/wdi-workflows:new-package` workflow, then continue.

---

## Phase 3: Research (Adaptive)

Research depth and agents determined by interview answers.

### Agent Selection Matrix

| Feature Type | Complexity | Agents |
|--------------|------------|--------|
| New Feature | Complex/Unknown | repo-analyst, framework-docs, best-practices, git-history |
| New Feature | Moderate | repo-analyst, framework-docs |
| New Feature | Simple | repo-analyst |
| Enhancement | Any | repo-analyst, git-history |
| Bug Fix | Any | repo-analyst, git-history |
| Refactor | Complex | repo-analyst, git-history, best-practices |
| Refactor | Simple/Moderate | repo-analyst |
| Experiment | Any | repo-analyst, best-practices |

### Research Preference Override

| Preference | Effect |
|------------|--------|
| Full Research | Use all agents from matrix above |
| Light Research | repo-analyst only |
| Skip Research | Skip to Phase 4 |

### Run Research Agents

Run selected agents in parallel using Task tool:

```
subagent_type='compound-engineering:research:repo-research-analyst'
subagent_type='compound-engineering:research:git-history-analyzer'
subagent_type='compound-engineering:research:framework-docs-researcher'
subagent_type='compound-engineering:research:best-practices-researcher'
```

Prompt each agent with:
- Feature description from interview
- Feature type context
- Target package (if applicable)

Ask for:
- Relevant existing patterns
- Files that will need modification
- Constraints or considerations
- Recommended approaches

### Synthesize Research

Combine agent outputs into a research summary:
- Key findings
- Existing patterns to follow
- Files to modify
- Constraints identified

### Pause (unless --yes)

```
Research Phase Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature Type: {type}
Complexity: {complexity}
Target: {package or "repo-level"}

Agents run: [list agents]

Key findings:
• [finding 1]
• [finding 2]

Continue to planning? (y)es, (a)bort:
```

---

## Phase 4: Plan

### Planning Depth by Complexity

| Complexity | Planning Approach |
|------------|-------------------|
| Simple | Quick bullet-point plan, minimal overhead |
| Moderate | Structured plan with acceptance criteria |
| Complex | Detailed plan with architecture diagrams, risk assessment |
| Unknown | Start with exploration tasks, then refine |

### Invoke Planning Workflow

Use Skill tool:

```
/compound-engineering:workflows:plan
```

Pass research context and interview answers.

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
Generated by /wdi-workflows:feature
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

If `--plan-only`, stop here.

---

## Phase 5: Work

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

Pass the implementation plan from Phase 4.

### Execute Implementation

For each implementation step:
1. Add to TodoWrite as `in_progress`
2. Implement the step
3. Mark as `completed`
4. Move to next step

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

## Phase 6: Review (Adaptive)

Review agents selected based on feature type and complexity.

### Agent Selection Matrix

| Feature Type | Complexity | Review Agents |
|--------------|------------|---------------|
| New Feature | Complex | simplicity, architecture, security, performance |
| New Feature | Moderate | simplicity, architecture |
| New Feature | Simple | simplicity |
| Enhancement | Any | simplicity, architecture |
| Bug Fix | Any | simplicity, security |
| Refactor | Any | simplicity, architecture, performance |
| Experiment | Any | simplicity only (light review) |

### Run Review Agents

| Agent | Focus |
|-------|-------|
| `code-simplicity-reviewer` | YAGNI, over-engineering, unnecessary abstraction |
| `architecture-strategist` | Design patterns, consistency with codebase |
| `security-sentinel` | Security vulnerabilities, input validation |
| `performance-oracle` | Performance issues, inefficient patterns |

### Present Findings

For each finding:
```
[Agent]: {issue description}

File: {file}:{line}
Severity: {low|medium|high}

(f)ix, (a)cknowledge, (s)kip:
```

- **fix**: Apply suggested fix
- **acknowledge**: Note the issue but continue
- **skip**: Ignore this finding

### Pause (unless --yes)

```
Review Phase Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Findings: {count} total
  ✓ Fixed: {fixed}
  ○ Acknowledged: {acknowledged}
  - Skipped: {skipped}

Merge and compound? (y)es, (r)eview again, (a)bort:
```

---

## Phase 7: Compound

### Merge Strategy by Complexity

| Complexity | Strategy |
|------------|----------|
| Simple | Direct merge to main |
| Moderate | Direct merge with detailed message |
| Complex | Create PR for record-keeping |

**Direct merge:**
```bash
git checkout main
git pull
git merge --no-ff {branch} -m "Merge {branch}"
```

**Create PR:**
```bash
gh pr create --title "{type}: {feature-name}" --body "{plan-summary}"
```

### Update Changelog

Invoke `/wdi-workflows:commit` workflow:

```
/wdi-workflows:commit --yes
```

Updates `docs/changelog.md` with the feature entry.

### Invoke Compound Workflow

Use Skill tool:

```
/compound-engineering:workflows:compound
```

### Document Learnings

Capture what was learned:
- Patterns that worked well
- Things to do differently
- New conventions to adopt

**For Complex features:** Update `CLAUDE.md` with new patterns if significant.

### Cleanup

```bash
git branch -d {branch}
git push origin --delete {branch}  # if pushed
```

### Close Issue

```bash
gh issue close {issue-number} --comment "Completed in {commit-sha}"
```

### Final Output

```
Feature Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature Type: {type}
Complexity: {complexity}
Target: {package}

✓ Issue #{issue-number} closed
✓ Merged to main
✓ Changelog updated
✓ Learnings documented

Research agents used: {list}
Review agents used: {list}

Learnings:
• {learning 1}
• {learning 2}
```

---

## Examples

### New complex feature (full workflow)

```
/wdi-workflows:feature

? What type of work is this?
  → New Feature

? How complex is this work?
  → Complex

? Where does this work belong?
  → packages/dashboard

? How much research should we do?
  → Full Research

? Briefly describe the feature:
  → "Add real-time analytics dashboard with live updating charts"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-flight: ✓ All checks passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Research Phase
  Running: repo-analyst, framework-docs, best-practices, git-history

  Key findings:
  • Existing Chart.js integration in packages/dashboard
  • WebSocket support available via existing lib-ws
  • Similar pattern in guest-portal for live updates

  Continue to planning? [y]

→ Plan Phase
  Created: Issue #23 "New Feature: Real-time analytics dashboard"
  Plan: docs/product/planning/features/realtime-analytics.md

  Continue to work? [y]

→ Work Phase
  Branch: feature/realtime-analytics
  ✓ Created WebSocket connection hook
  ✓ Built LiveChart component
  ✓ Integrated with existing dashboard
  Tests: ✓ passing

  Ready for review? [y]

→ Review Phase
  simplicity-reviewer: ✓ Clean
  architecture-strategist: ✓ Follows existing patterns
  security-sentinel: ✓ WebSocket auth validated
  performance-oracle: 1 suggestion (debounce updates)

  (f)ix performance suggestion? [y]

  Merge and compound? [y]

→ Compound Phase
  ✓ Merged to main
  ✓ Issue #23 closed
  ✓ Changelog updated

  Learnings:
  • lib-ws handles reconnection automatically
  • Chart.js streaming plugin simplifies live updates

✓ Feature complete
```

### Quick bug fix

```
/wdi-workflows:feature

? What type of work is this?
  → Bug Fix

? How complex is this work?
  → Simple

? How much research should we do?
  → Light Research

? Briefly describe the feature:
  → "Fix navigation links not highlighting on mobile"

→ Research Phase
  Running: repo-analyst only
  Found: Navigation in src/components/Nav.tsx

→ Plan Phase
  Created: Issue #24 "Bug Fix: Mobile nav highlighting"

→ Work Phase
  Branch: fix/24-mobile-nav
  ✓ Fixed CSS media query
  Tests: ✓ passing

→ Review Phase
  simplicity-reviewer: ✓ Clean
  security-sentinel: ✓ No issues

→ Compound Phase
  ✓ Merged, closed, documented

✓ Bug fix complete
```

### Plan only (for discussion)

```
/wdi-workflows:feature --plan-only

? What type of work is this?
  → Enhancement

? How complex is this work?
  → Unknown

? How much research should we do?
  → Full Research

? Briefly describe the feature:
  → "Add dark mode support across all pages"

→ Research Phase
  Running: repo-analyst, framework-docs, best-practices, git-history

  Key findings:
  • DaisyUI supports data-theme attribute
  • 15 pages need theme-aware styling
  • LocalStorage can persist preference

→ Plan Phase
  Created: Issue #25 "Enhancement: Dark mode support"
  Plan: docs/product/planning/features/dark-mode.md

  Complexity revised: Moderate (15 files, pattern exists)

✓ Planning complete. Run /wdi-workflows:feature to continue.
```

### Experiment with minimal overhead

```
/wdi-workflows:feature --yes

? What type of work is this?
  → Experiment

? How complex is this work?
  → Simple

? How much research should we do?
  → Skip Research

? Briefly describe the feature:
  → "Test GraphQL subscriptions for live data"

→ Skipping research (user preference)
→ Light planning (experiment)
→ Branch: experiment/graphql-subscriptions
→ Light review (simplicity only)
→ Merged to main

✓ Experiment complete

Note: Experiment branches can be deleted after 90 days
if not promoted to permanent feature.
```

---

## Notes

- Interview answers determine agent selection and planning depth
- Complex work gets more research and review agents
- Simple work uses minimal overhead
- Experiments get light treatment (exploratory by nature)
- Use `--yes` for experienced users who know the codebase
- All phases can be aborted without side effects (except created branches/issues)
- Requires compound-engineering plugin for research and review agents
- Requires `gh` CLI authenticated for issue creation
- Feature specs use template from `docs/templates/feature.md`
- Feature specs saved to `docs/product/planning/features/`
- See PROJECT-STRUCTURE.md for full product documentation layout
