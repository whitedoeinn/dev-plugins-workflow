---
# YAML frontmatter for machine-readable metadata
status: planning  # planning | in-progress | review | complete
type: feature     # feature | enhancement | bug-fix | refactor | experiment
complexity: moderate  # simple | moderate | complex
issue: null       # GitHub issue number
branch: null      # Git branch name
created: null     # YYYY-MM-DD
---

# {Feature Title}

## Problem

What problem does this solve? Include a specific scenario:

> When [persona] tries to [action], they [pain point] because [reason].

## Context

**Target:** {package or repo-level}
**Milestone:** {MILE-XXX} (optional)

## Research Requirements

What needs to be understood before implementation:

- [ ] {Research topic 1} [research: {agent-hint}]
- [ ] {Research topic 2}

## Done When

Tasks organized by phase. Each task includes:
- Verification criteria in `(test: ...)`
- Optional annotations: `[research: topic]`, `[review: type]`, `[skip-gates]`, `[strict]`

### Phase 1: Foundation
- [ ] {Task 1} (test: {verification}) [review: security]
- [ ] {Task 2} (test: {verification})

### Phase 2: Core Implementation
- [ ] {Task 3} (test: {verification})
- [ ] {Task 4} (test: {verification}) [research: external-api]

### Phase 3: Polish
- [ ] {Task 5} (test: {verification})

## Exit Criteria

Feature is complete when:
- [ ] All "Done When" tasks checked
- [ ] Tests pass (workflow detects and runs appropriate tests)
- [ ] Documentation updated
- [ ] PR merged or committed to main

## Files

| File | Change |
|------|--------|
| `{path/to/file}` | {description} |

## Dependencies

**Blocked by:**
- {Feature or issue this depends on}

**Blocks:**
- {Features that depend on this}

## Research Summary

Key findings (populated during/after research phase):

- {Finding 1}
- {Finding 2}

## Notes

Additional context, decisions made, alternatives considered.

---

*Created by `/wdi:feature`*
