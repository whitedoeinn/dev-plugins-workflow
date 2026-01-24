# Feature Development Workflow

## The Compounding Loop (Implemented)

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
│              │  LEARNINGS SEARCH      │◄─── Phase 2.5 in workflow               │
│              │  (searches both)       │     Surfaces prior solutions            │
│              └───────────┬────────────┘                                          │
│                          │                                                       │
└──────────────────────────┼───────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              WORKFLOW PHASES                                     │
│                                                                                  │
│  ┌─────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐   ┌────────┐   ┌──────┐│
│  │INTERVIEW│──▶│PRE-FLIGHT│──▶│LEARNINGS │──▶│  PLAN  │──▶│  WORK  │──▶│REVIEW││
│  └─────────┘   └──────────┘   │  SEARCH  │   └────────┘   └────────┘   └──┬───┘│
│                               └──────────┘                                 │    │
│                                    ▲                                       │    │
│                                    │                                       ▼    │
│                          "Found 2 related                        ┌─────────────┐│
│                           learnings..."                          │Creates P1/P2││
│                                                                  │   Issues    ││
│                                                                  └──────┬──────┘│
│                                                                         │       │
│                                                                         ▼       │
│                                                                  ┌─────────────┐│
│                                                                  │  COMPOUND   ││
│                                                                  │ (learnings) ││
│                                                                  └──────┬──────┘│
└─────────────────────────────────────────────────────────────────────────┼───────┘
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

## Implementation Status

### Implemented ✅

| Feature | Status | Details |
|---------|--------|---------|
| **Learnings Search Phase** | ✅ #79 | Searches before Plan phase |
| **Local search** | ✅ | Queries `docs/solutions/` in current repo |
| **Central search** | ✅ #80 | Queries `learnings/curated/` cross-project |
| **Keyword search** | ✅ | Matches tags, symptom, title in frontmatter |
| **Issue-based search** | ✅ | Finds learnings via `related_issues` field |
| **Central repo** | ✅ | `whitedoeinn/learnings` with sync + triage |
| **Taxonomy** | ✅ | universal / frontend / backend / lob |

### The Compounding Feedback Loop (Now Working!)

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

## Search Flow Detail

```
Feature Description: "Add edit form for vendors with pre-population"
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │     EXTRACT SEARCH TERMS      │
                    │                               │
                    │  Keywords: form, edit, react  │
                    │  Issues: #45, #79 (if refs)   │
                    └───────────────┬───────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
        ┌───────────────────┐           ┌───────────────────┐
        │   LOCAL SEARCH    │           │  CENTRAL SEARCH   │
        │  docs/solutions/  │           │ learnings/curated/│
        │                   │           │                   │
        │ grep tags/symptom │           │ grep tags/symptom │
        │ grep related_issues│          │ grep related_issues│
        └─────────┬─────────┘           └─────────┬─────────┘
                  │                               │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────────┐
                    │       COMBINE & PRESENT       │
                    │                               │
                    │ Priority:                     │
                    │  1. Local issue-based         │
                    │  2. Central issue-based       │
                    │  3. Local keyword             │
                    │  4. Central keyword           │
                    │                               │
                    │ Deduplicate by filename       │
                    └───────────────────────────────┘
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

## Metrics

| Metric | How to Measure | Target |
|--------|----------------|--------|
| Learnings surfaced | "Found N related" in plan output | >50% of sessions |
| Cross-project discovery | Central matches found | Growing over time |
| Time to resolution | Compare similar issues | Decreasing trend |
| Repeat issues | Same symptom reappearing | Zero repeats |

## Related

- [whitedoeinn/learnings](https://github.com/whitedoeinn/learnings) - Central repo
- #79 - Learnings Search implementation
- #80 - Central learnings repo
- `docs/standards/LEARNINGS-ARCHITECTURE.md` - Detailed architecture
