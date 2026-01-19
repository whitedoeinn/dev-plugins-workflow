# Issue Standards

Standards for creating and managing GitHub Issues across WDI projects.

---

## Issue Titles

Keep titles brief and descriptive. Use sentence case.

**Format:** `Brief description of the issue`

**Good examples:**
- `Add dark mode toggle to settings`
- `Fix mobile navigation highlighting`
- `Campaign filter not saving selection`
- `Consider adding GraphQL support`

**Avoid:**
- `Bug` (too vague)
- `Fix The Thing That's Broken In The Dashboard When You Click` (too long)
- `[BUG] [URGENT] [P0] Fix login` (use labels, not title prefixes)

---

## Labels

Use labels instead of title prefixes for categorization.

### Required Labels (Type)

Every issue should have at least one type label describing the **nature** of the work:

| Label | Color | Description |
|-------|-------|-------------|
| `bug` | `#d73a4a` (red) | Defect or broken behavior |
| `feature` | `#006B75` (teal) | User-facing capability |
| `enhancement` | `#a2eeef` (cyan) | Improvement to existing functionality |
| `documentation` | `#0075ca` (blue) | Documentation changes only |
| `chore` | `#FEF2C0` (light yellow) | Maintenance, dependencies, CI, cleanup |
| `spike` | `#1E90FF` (blue) | Research or investigation |
| `idea` | `#0052CC` (blue) | Needs shaping before becoming a feature/epic |
| `question` | `#d876e3` (purple) | Needs discussion or clarification |

### Optional Labels (Scope)

Add a scope label to indicate position in the hierarchy (see [Scope Taxonomy](#scope-taxonomy) below):

| Label | Color | Description |
|-------|-------|-------------|
| `initiative` | `#5319E7` (dark purple) | Strategic goal spanning multiple epics |
| `epic` | `#7057ff` (purple) | Multi-phase work coordinating several features |
| `task` | `#C5DEF5` (light blue) | Single unit of work (child of feature) |

Note: `feature`, `bug`, and `spike` appear in both lists - they serve as both type and default scope.

### Optional Labels (Priority)

Add when priority matters:

| Label | Color | Description |
|-------|-------|-------------|
| `priority: high` | `#b60205` (dark red) | Needs attention soon |
| `priority: low` | `#c5def5` (light blue) | Nice to have, when time permits |

### Optional Labels (Status)

Add to communicate state:

| Label | Color | Description |
|-------|-------|-------------|
| `blocked` | `#000000` (black) | Waiting on external dependency |
| `needs-info` | `#fbca04` (yellow) | Requires more information |
| `wontfix` | `#ffffff` (white) | Declined, with explanation |
| `duplicate` | `#cfd3d7` (gray) | Duplicate of another issue |

### Optional Labels (Area)

For mono-repos or larger projects:

| Label | Color | Description |
|-------|-------|-------------|
| `area: dashboard` | `#5319e7` (purple) | Affects dashboard package |
| `area: api` | `#5319e7` (purple) | Affects API package |
| `area: docs` | `#5319e7` (purple) | Affects documentation |

---

## Scope Taxonomy

Issues are classified by **scope** to indicate their size and relationship to other work. This creates a hierarchy from strategic goals down to individual tasks.

### Scope Hierarchy

```
Initiative
    └── Epic
            └── Feature / Bug / Spike
                    └── Task
```

| Label | Color | Description | Example |
|-------|-------|-------------|---------|
| `initiative` | `#5319E7` (dark purple) | Strategic goal spanning multiple epics | "Improve developer experience" |
| `epic` | `#7057ff` (purple) | Multi-phase work coordinating several features | "Adopt branching & PR workflow" |
| `feature` | `#006B75` (teal) | User-facing capability | "Add PR creation step" |
| `bug` | `#d73a4a` (red) | Defect or broken behavior | "Plugin update not re-downloading" |
| `spike` | `#1E90FF` (blue) | Research or investigation | "Research Claude Code issues" |
| `task` | `#C5DEF5` (light blue) | Single unit of work | "Update CLAUDE.md" |

### Scope vs Type

- **Scope** describes the size/hierarchy (initiative → epic → feature → task)
- **Type** describes the nature of work (feature, bug, chore, docs, spike)

An issue can have both:
- `epic` + `chore` = An epic focused on maintenance work
- `feature` + `documentation` = A feature that's documentation-related
- `spike` is both a scope and type (research is inherently scoped)

### Using Scope Labels

1. **Initiatives** are rare - strategic goals that span months
2. **Epics** coordinate multiple features/bugs into a cohesive effort
3. **Features/Bugs/Spikes** are the typical working level
4. **Tasks** are optional - use for breaking down features if helpful

### Parent-Child Relationships

Use issue body to link scope relationships:

```markdown
## Parent
- #57 (Epic: Adopt Branching & PR Workflow)

## Children
- [ ] #58 - Update workflows-feature.md
- [ ] #59 - Update commit skill
```

Child issues should be assigned to the parent's **milestone** for tracking.

### Epics and Milestones

Every `epic` should have a corresponding **milestone**:
- Milestone groups all child issues
- Progress bar shows completion
- Epic issue is pinned for visibility

### When to Use What

| Situation | Scope Label |
|-----------|-------------|
| "We need to improve X across the board" | `initiative` |
| "This requires multiple coordinated changes" | `epic` |
| "Add this specific capability" | `feature` |
| "This is broken" | `bug` |
| "We need to research/investigate" | `spike` |
| "Do this one specific thing" | `task` |

---

## Issue Templates

Use templates in `.github/ISSUE_TEMPLATE/` for consistency.

### Bug Report Template

```markdown
---
name: Bug Report
about: Report something that isn't working correctly
title: ''
labels: bug
---

## Description

Brief description of the bug.

## Steps to Reproduce

1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior

What should happen.

## Actual Behavior

What actually happens.

## Environment

- Browser/OS:
- Version/Commit:

## Screenshots

If applicable, add screenshots.

## Additional Context

Any other relevant information.
```

### Feature Request Template

```markdown
---
name: Feature Request
about: Suggest new functionality
title: ''
labels: feature
---

## Problem

What problem does this solve? Why is it needed?

## Proposed Solution

Describe the feature you'd like.

## Alternatives Considered

Other approaches you've thought about.

## Additional Context

Mockups, examples, or references.
```

### Enhancement Template

```markdown
---
name: Enhancement
about: Suggest an improvement to existing functionality
title: ''
labels: enhancement
---

## Current Behavior

How does it work now?

## Proposed Improvement

What should change?

## Benefits

Why is this improvement valuable?

## Additional Context

Any other relevant information.
```

### Idea Template

```markdown
---
name: Idea
about: Capture a rough idea for later shaping
title: 'Idea: '
labels: idea
---

## Idea

What's the rough concept?

## Problem/Opportunity

What might this solve or enable?

## Initial Thoughts

Any early thinking on approach?
```

### Chore Template

```markdown
---
name: Chore
about: Maintenance, cleanup, dependencies, or configuration
title: ''
labels: chore
---

## Task

What needs to be done?

## Reason

Why is this maintenance needed?

## Scope

What files/areas are affected?
```

### Documentation Template

```markdown
---
name: Documentation
about: Documentation improvements or additions
title: ''
labels: documentation
---

## What needs documenting?

Describe what's missing or needs improvement.

## Location

Where should this documentation live?

## Audience

Who is this documentation for?
```

### Question Template

```markdown
---
name: Question
about: Ask a question that needs discussion
title: ''
labels: question
---

## Question

What do you need clarification on?

## Context

What led to this question?

## Options Considered

Any approaches you've thought about?
```

### Experiment Template

```markdown
---
name: Experiment
about: Exploratory work, spike, or proof of concept
title: 'Experiment: '
labels: experiment
---

## Hypothesis

What are you trying to learn or prove?

## Approach

How will you test this?

## Success Criteria

How will you know if the experiment succeeded?

## Time Box

Expected duration (max 90 days per standards).
```

---

## Writing Good Issues

### Do

- **Be specific** - Include exact error messages, URLs, steps
- **One issue per issue** - Don't bundle unrelated problems
- **Link related issues** - Use `Related to #123` or `Depends on #456`
- **Update as you learn** - Edit the issue with new information
- **Close with context** - When closing, explain the resolution

### Don't

- **Assume context** - Others (or future you) won't remember
- **Write novels** - Keep it concise, use formatting
- **Leave stale issues** - Close or update issues that are outdated
- **Duplicate** - Search before creating

---

## Issue Lifecycle

```
Open → In Progress → Review → Closed
```

### Linking to Branches/PRs

When starting work on an issue:
- Branch name includes issue number: `fix/123-mobile-nav`
- PR references issue: `Fixes #123` (auto-closes on merge)

### Closing Issues

Issues are closed when:
- **Completed** - Feature shipped, bug fixed
- **Won't fix** - Declined with explanation (add `wontfix` label)
- **Duplicate** - Link to original issue (add `duplicate` label)
- **Stale** - No longer relevant (explain why in comment)

---

## Issue-Driven Development

The `/wdi:feature` command creates issues automatically. This ensures:

1. Every feature has a tracking issue
2. Issues include requirements and acceptance criteria
3. Issues link to implementation branches
4. Issues close automatically when work merges

**Manual issue creation** is still useful for:
- Bug reports from users
- Feature ideas to discuss before committing
- Documentation improvements
- Questions that need async discussion

---

## Examples

### Good Bug Report

```
Title: Campaign filter not persisting after page refresh

Labels: bug, area: dashboard

## Description
The campaign status filter resets to "All" when refreshing the page.

## Steps to Reproduce
1. Go to /dashboard/campaigns
2. Select "Active" from the status filter
3. Refresh the page
4. Filter is back to "All"

## Expected Behavior
Filter selection should persist (localStorage or URL param).

## Environment
- Chrome 120, macOS
- Commit: abc123
```

### Good Feature Request

```
Title: Add export to CSV for campaign reports

Labels: feature, priority: high

## Problem
Users need to share campaign data with stakeholders who
don't have dashboard access.

## Proposed Solution
Add "Export CSV" button to campaign report page that
downloads current filtered view.

## Alternatives Considered
- PDF export (harder to work with in Excel)
- API endpoint (requires technical users)

## Additional Context
Requested by 3 users in last month.
```

---

## Notes

- Labels should be created consistently across all WDI repos
- Use GitHub's issue transfer feature to move misplaced issues
- Pin important issues (roadmap, contributing guide) to repo
- Use milestones for grouping issues by release or sprint
