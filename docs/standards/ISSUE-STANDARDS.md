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

**Avoid:**
- `Bug` (too vague)
- `Fix The Thing That's Broken In The Dashboard When You Click` (too long)
- `[BUG] [URGENT] [P0] Fix login` (use labels, not title prefixes)

---

## Label Taxonomy

Labels use **prefixed groups** for consistent filtering across all WDI repos.

### `type:` — What kind of work? (mutually exclusive)

| Label | Color | Description |
|-------|-------|-------------|
| `type:bug` | `#d73a4a` (red) | Something broken, unexpected behavior |
| `type:feature` | `#0e8a16` (green) | New or improved capability |
| `type:chore` | `#6c757d` (gray) | Maintenance, refactoring, deps, tech debt |

Every issue should have exactly one `type:` label.

### `priority:` — How urgent? (mutually exclusive)

| Label | Color | Description |
|-------|-------|-------------|
| `priority:critical` | `#b60205` (dark red) | Drop everything — production down, security hole, data loss |
| `priority:high` | `#d93f0b` (orange) | This sprint — blocking release or significant user pain |
| `priority:medium` | `#fbca04` (yellow) | Soon — real issue but not blocking |
| *(no label)* | — | Backlog — we'll get to it eventually |

**Principle:** "Low priority is a joke — go label-less instead." If it's truly low priority, don't label it.

### `area:` — Where in the codebase? (stackable)

| Label | Color | Description |
|-------|-------|-------------|
| `area:frontend` | `#1d76db` (blue) | Web app, React components, stores, UI |
| `area:api` | `#5319e7` (purple) | Backend, routes, database, validation |
| `area:infra` | `#0e0e0e` (black) | Deployment, Docker, CI/CD, config |

Issues can have multiple area labels if they span layers.

### `concern:` — What aspect of quality? (stackable)

| Label | Color | Description |
|-------|-------|-------------|
| `concern:a11y` | `#0052cc` (blue) | Accessibility — WCAG, screen readers, contrast |
| `concern:security` | `#ee0701` (red) | Auth, permissions, vulnerabilities |
| `concern:mobile` | `#c2e0c6` (light green) | Responsive, touch, small screens |
| `concern:perf` | `#bfd4f2` (light blue) | Speed, bundle size, caching |
| `concern:ux` | `#d4c5f9` (lavender) | General UX polish, flows, clarity |
| `concern:docs` | `#fef2c0` (cream) | Documentation, READMEs, guides |
| `concern:testing` | `#f9d0c4` (peach) | Test coverage, flaky tests, harnesses |
| `concern:data` | `#c5def5` (light blue) | Data integrity, migrations, schema, validation |
| `concern:dx` | `#bfdadc` (teal) | Developer experience, tooling, standards, conventions |

Issues can have multiple concern labels.

### `state:` — Workflow status (mutually exclusive)

| Label | Color | Description |
|-------|-------|-------------|
| `state:needs-scoping` | `#e6e6e6` (gray) | Not yet planned — needs research/scoping |
| `state:ready` | `#0e8a16` (green) | Scoped, ready to build |
| `state:in-progress` | `#fbca04` (yellow) | Work underway |
| `state:needs-review` | `#1d76db` (blue) | Code done, needs review |
| `state:needs-compounding` | `#5319e7` (purple) | Reviewed, capture learnings |
| `state:blocked` | `#b60205` (red) | Can't proceed — waiting on dependency |

State labels enable workflow automation (see WDI plugin integration).

### `from:` — Issue origin (optional)

| Label | Color | Description |
|-------|-------|-------------|
| `from:uat` | `#c2b280` (tan) | Found during UAT testing |
| `from:user` | `#ff7619` (orange) | Reported by end user |
| `from:review` | `#ffefc6` (cream) | Found during code review |

Helps track where issues are discovered and prioritize accordingly.

---

## Quick Reference

```
type:     bug | feature | chore                          (pick one)
priority: critical | high | medium | (unlabeled=backlog)  (pick one)
area:     frontend | api | infra                          (stack if needed)
concern:  a11y | security | mobile | perf | ux | docs | testing | data | dx
state:    needs-scoping | ready | in-progress | needs-review | needs-compounding | blocked
from:     uat | user | review                             (optional)
```

---

## Filtering Examples

| Want to see | Filter |
|-------------|--------|
| All accessibility work | `label:concern:a11y` |
| High priority bugs | `label:type:bug label:priority:high` |
| Frontend a11y specifically | `label:area:frontend label:concern:a11y` |
| What's blocking release | `label:priority:critical,priority:high` |
| UAT findings to triage | `label:from:uat` |
| Security backlog | `label:concern:security -label:priority:critical -label:priority:high` |
| Ready to pick up | `label:state:ready` |

---

## Scope Taxonomy (Epics)

For larger efforts, use GitHub's **sub-issues** feature rather than scope labels:

1. Create parent issue (the "epic")
2. Add sub-issues via **Create sub-issue** in sidebar
3. Progress tracked automatically

**When to create an epic:**
- Work spans multiple PRs over days/weeks
- Multiple people might contribute
- Needs coordination across features

**Simple issues don't need epics.** Most bugs and small features are standalone.

---

## Issue Lifecycle

```
Created → state:needs-scoping → state:ready → state:in-progress → state:needs-review → Closed
```

### WDI Workflow Integration

The WDI plugin reads `state:` labels to determine where to start:

| State Label | Plugin Behavior |
|-------------|-----------------|
| `state:needs-scoping` | Start with planning phase |
| `state:ready` | Start with implementation |
| `state:in-progress` | Resume implementation |
| `state:needs-review` | Run review phase |
| `state:needs-compounding` | Run compounding phase |
| `state:blocked` | Skip, surface blocker |

The plugin updates state labels as work progresses.

### Closing Issues

Issues close when:
- **Completed** — PR merged with `Fixes #123`
- **Won't fix** — Declined with explanation in comment
- **Duplicate** — Link to original, close as not planned
- **Stale** — No longer relevant, explain why

---

## Writing Good Issues

### Do

- **Be specific** — Include exact error messages, URLs, steps
- **One issue per issue** — Don't bundle unrelated problems
- **Link related issues** — Use `Related to #123` or `Depends on #456`
- **Update as you learn** — Edit the issue with new information
- **Close with context** — Explain the resolution

### Don't

- **Assume context** — Others (or future you) won't remember
- **Write novels** — Keep it concise, use formatting
- **Leave stale issues** — Close or update outdated issues
- **Duplicate** — Search before creating

---

## Issue Templates

Use templates in `.github/ISSUE_TEMPLATE/` for consistency.

### Bug Report

```markdown
---
name: Bug Report
about: Report something that isn't working correctly
labels: type:bug
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
```

### Feature Request

```markdown
---
name: Feature Request
about: Suggest new functionality
labels: type:feature
---

## Problem
What problem does this solve?

## Proposed Solution
Describe the feature you'd like.

## Alternatives Considered
Other approaches you've thought about.
```

### Chore

```markdown
---
name: Chore
about: Maintenance, cleanup, dependencies, or configuration
labels: type:chore
---

## Task
What needs to be done?

## Reason
Why is this maintenance needed?

## Scope
What files/areas are affected?
```

---

## Syncing Labels Across Repos

Use `github-label-sync` or the provided script to sync labels:

```bash
# labels.json contains the canonical label definitions
gh label create "type:bug" --color "d73a4a" --description "Something broken"
# ... repeat for all labels
```

Labels should be consistent across all WDI repos.

---

## Notes

- Every issue needs a `type:` label
- Priority labels are optional — unlabeled = backlog
- Use `state:` labels for workflow automation
- Use `concern:` labels liberally — they help with filtering
- `from:` labels help track quality (catching issues in UAT vs prod)
