# Feature Development Workflow

## Two Entry Points

```
/wdi:workflow-feature
        │
        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                            WHAT DO YOU WANT TO DO?                             │
│                                                                                │
│   ┌─────────────────────┐              ┌─────────────────────────────────┐    │
│   │    QUICK IDEA       │              │       BUILD SOMETHING           │    │
│   │                     │              │                                 │    │
│   │  One sentence       │              │  Full workflow:                 │    │
│   │  → Issue created    │              │  Pre-flight → Learnings →      │    │
│   │  → Done (30 sec)    │              │  Plan → Work → Review →        │    │
│   │                     │              │  Compound                       │    │
│   └─────────┬───────────┘              └────────────────┬────────────────┘    │
│             │                                           │                      │
│             ▼                                           ▼                      │
│   ┌─────────────────────┐              ┌─────────────────────────────────┐    │
│   │  GitHub Issue #N    │              │       FULL WORKFLOW             │    │
│   │  label: idea        │              │       (see below)               │    │
│   └─────────────────────┘              └─────────────────────────────────┘    │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘

Continue later: /wdi:workflow-feature #N
```

## The Compounding Loop (Full Workflow)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           LEARNINGS ECOSYSTEM                                    │
│                                                                                  │
│   Local (per repo)              Central (cross-project)                         │
│   ┌─────────────────┐           ┌─────────────────────────────────┐             │
│   │ docs/solutions/ │──sync────▶│   whitedoeinn/learnings         │             │
│   │ (repo-specific) │           │   ├── curated/universal/        │             │
│   └────────┬────────┘           │   ├── curated/frontend/         │             │
│            │                    │   ├── curated/backend/          │             │
│            │                    │   └── curated/lob/{domain}/     │             │
│            │                    └─────────────────┬───────────────┘             │
│            │                                      │                              │
│            └──────────────┬───────────────────────┘                              │
│                           │                                                      │
│                           ▼                                                      │
│              ┌────────────────────────┐                                          │
│              │  LEARNINGS SEARCH      │◄─── Phase 2 in workflow                 │
│              │  (searches both)       │     Surfaces prior solutions            │
│              └───────────┬────────────┘                                          │
│                          │                                                       │
└──────────────────────────┼───────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              WORKFLOW PHASES                                     │
│                                                                                  │
│  GitHub Issue: Updated at each phase with milestone comments                    │
│  Phase Labels: Applied/removed for at-a-glance visibility                       │
│                                                                                  │
│  ┌──────────┐   ┌──────────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌──────┐ │
│  │PRE-FLIGHT│──▶│LEARNINGS │──▶│  PLAN  │──▶│  WORK  │──▶│ REVIEW │──▶│CLOSE │ │
│  └──────────┘   │  SEARCH  │   └───┬────┘   └───┬────┘   └───┬────┘   └──┬───┘ │
│                 └──────────┘       │            │            │           │      │
│                                    │            │            │           │      │
│                              phase:planning  phase:working  phase:reviewing     │
│                                    │            │            │           │      │
│                                    ▼            ▼            ▼           ▼      │
│                              ┌─────────────────────────────────────────────────┐│
│                              │           ISSUE COMMENTS                        ││
│                              │                                                 ││
│                              │ • Learnings Search: Prior art found            ││
│                              │ • Plan: Research summary, decisions, risks     ││
│                              │ • Work: What was built, deviations             ││
│                              │ • Review: P1/P2/P3 counts, blocking status     ││
│                              │ • Compound: Learnings documented               ││
│                              │ • Close: Outcome, commit, summary              ││
│                              └─────────────────────────────────────────────────┘│
│                                                                                  │
│                                                                   ┌─────────────┐│
│                                                                   │  COMPOUND   ││
│                                                                   │ (learnings) ││
│                                                                   └──────┬──────┘│
└──────────────────────────────────────────────────────────────────────────┼───────┘
                                                                           │
                                                                           ▼
                                                            ┌──────────────────────┐
                                                            │  OUTPUTS             │
                                                            │  • docs/solutions/   │──┐
                                                            │  • GitHub Issues     │  │
                                                            │  • Code patterns     │  │
                                                            └──────────────────────┘  │
                                                                         ▲          │
                                                                         └──────────┘
                                                                        Feeds back
```

## Phase Labels

Issues are labeled with their current workflow phase:

| Label | Color | When Applied |
|-------|-------|--------------|
| `phase:planning` | 🔵 Blue | Start of Plan phase |
| `phase:working` | 🟢 Green | Start of Work phase |
| `phase:reviewing` | 🟡 Yellow | Start of Review phase |
| `phase:compounding` | 🟣 Purple | Start of Compound phase |

Labels are automatically applied and removed as the workflow progresses.

Filter issues by phase: `label:phase:planning`, `label:phase:working`, etc.

## Issue Timeline

When complete, a GitHub issue tells the full story:

```
#85: Validate issue exists in continue mode
├── [Body] Problem, Solution, Plan
├── [Comment] Learnings Search - "No prior art found"
├── [Comment] Plan - Research: gh returns exit code 1...
├── [Comment] Work - Added Step 1.5, tests passing
├── [Comment] Review - 0 P1s, 0 P2s, 0 P3s
├── [Comment] Compound - Learnings documented
└── [Closed] ✓ Completed as planned, commit 8ce4fc7
```

See [Issue #85](https://github.com/whitedoeinn/dev-plugins-workflow/issues/85) for a real example.

## Implementation Status

### Implemented ✅

| Feature | Status | Details |
|---------|--------|---------|
| **Two Entry Points** | ✅ #81 | Quick idea OR Build something |
| **Phase Labels** | ✅ #83 | At-a-glance workflow visibility |
| **Milestone Comments** | ✅ #81 | Progress posted at each phase |
| **Input Validation** | ✅ #85 | Helpful error for non-existent issues |
| **Learnings Search** | ✅ #79 | Searches before Plan phase |
| **Local search** | ✅ | Queries `docs/solutions/` in current repo |
| **Central search** | ✅ #80 | Queries `learnings/curated/` cross-project |
| **Central repo** | ✅ | `whitedoeinn/learnings` with sync + triage |

### The Compounding Feedback Loop

```
Session 1: Solve "form not pre-populating"
    │
    ▼
/workflows:compound → docs/solutions/react-form-key-pattern.md
    │
    ▼
./scripts/sync-all.sh → learnings/curated/frontend/
    │
    ▼
Session 2: "Add edit form for vendors"
    │
    ▼
Learnings Search: "Found 2 related learnings..."     ◄── THIS NOW WORKS
    │
    ├── Local: docs/solutions/react-form-key-pattern.md
    └── Central: learnings/curated/frontend/react-form-key-pattern.md
    │
    ▼
Developer: "Use key={entity.id} - already documented!"
    │
    ▼
Time saved: 30 min research → 2 min lookup
```

## Taxonomy (Central Repo)

```
learnings/curated/
├── universal/          # Tech-agnostic patterns
│   └── prevention-strategies.md
├── frontend/           # React, CSS, UI
│   └── react-form-key-pattern.md
├── backend/            # Ruby, Rails, APIs
│   └── plugin-version-caching.md
└── lob/                # Line-of-business
    ├── events/
    └── lodging/
```

| Scope | When to Use | Example |
|-------|-------------|---------|
| `universal` | Any project, any stack | Git patterns, debugging |
| `frontend` | React, CSS, browser | Form state, component patterns |
| `backend` | Ruby, Rails, APIs, DB | Query optimization, caching |
| `lob/*` | Business domain specific | Event scheduling, reservations |

## Related

- [whitedoeinn/learnings](https://github.com/whitedoeinn/learnings) - Central learnings repo
- [Issue #85](https://github.com/whitedoeinn/dev-plugins-workflow/issues/85) - Real example of complete workflow
- #81 - Simplified workflow with milestone comments
- #83 - Phase labels implementation
- #79 - Learnings Search implementation
- #80 - Central learnings repo
