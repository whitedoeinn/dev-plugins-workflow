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

Every issue should have exactly one type label:

| Label | Color | Description |
|-------|-------|-------------|
| `bug` | `#d73a4a` (red) | Something isn't working correctly |
| `feature` | `#0075ca` (blue) | New functionality |
| `enhancement` | `#a2eeef` (cyan) | Improvement to existing functionality |
| `documentation` | `#0075ca` (blue) | Documentation only |
| `question` | `#d876e3` (purple) | Needs discussion or clarification |
| `experiment` | `#fbca04` (yellow) | Exploratory work, spike, POC |

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
