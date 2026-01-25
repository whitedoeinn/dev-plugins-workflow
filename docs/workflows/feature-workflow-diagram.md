# Feature Development Workflow

> **One command. Complete journey. Knowledge compounds.**

## The Big Picture

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0f172a', 'primaryTextColor': '#f8fafc', 'primaryBorderColor': '#334155', 'lineColor': '#475569', 'secondaryColor': '#f1f5f9', 'tertiaryColor': '#fef3c7', 'fontFamily': 'ui-monospace, monospace'}}}%%
flowchart TB
    subgraph entry [" "]
        cmd[["wdi:workflow-feature"]]
    end

    cmd --> choice{"Quick idea<br/>or build?"}

    choice -->|"idea"| quick["Capture in 30s"]
    choice -->|"build"| full["Start Journey"]

    quick --> issue["Issue #N created"]
    issue -.->|"#N"| continue["Continue anytime"]
    continue --> full

    subgraph workflow ["  THE JOURNEY  "]
        direction TB
        full --> preflight["Pre-flight"]
        preflight --> search["Learnings Search"]
        search --> plan["Plan"]
        plan --> work["Work"]
        work --> review["Review"]
        review --> compound["Compound"]
        compound --> done["Done"]
    end

    subgraph labels ["  PHASE LABELS  "]
        l1["planning"]
        l2["working"]
        l3["reviewing"]
        l4["compounding"]
    end

    plan -.-> l1
    work -.-> l2
    review -.-> l3
    compound -.-> l4

    done --> solutions[("Learnings")]
    solutions -->|"feeds next"| search

    style entry fill:none,stroke:none
    style cmd fill:#0f172a,stroke:#0f172a,color:#f8fafc
    style choice fill:#1e293b,stroke:#334155,color:#f8fafc
    style quick fill:#059669,stroke:#047857,color:#fff
    style issue fill:#f1f5f9,stroke:#cbd5e1,color:#1e293b
    style continue fill:#f1f5f9,stroke:#cbd5e1,color:#1e293b
    style full fill:#1e293b,stroke:#334155,color:#f8fafc
    style workflow fill:#f8fafc,stroke:#e2e8f0,color:#0f172a
    style preflight fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style search fill:#fef3c7,stroke:#fcd34d,color:#78350f
    style plan fill:#dbeafe,stroke:#3b82f6,color:#1e3a8a
    style work fill:#d1fae5,stroke:#10b981,color:#064e3b
    style review fill:#fce7f3,stroke:#ec4899,color:#831843
    style compound fill:#ede9fe,stroke:#8b5cf6,color:#4c1d95
    style done fill:#0f172a,stroke:#0f172a,color:#f8fafc
    style labels fill:#f8fafc,stroke:#e2e8f0
    style l1 fill:#3b82f6,stroke:#2563eb,color:#fff
    style l2 fill:#10b981,stroke:#059669,color:#fff
    style l3 fill:#f59e0b,stroke:#d97706,color:#fff
    style l4 fill:#8b5cf6,stroke:#7c3aed,color:#fff
    style solutions fill:#fef3c7,stroke:#f59e0b,color:#78350f
```

---

## The Compounding Flywheel

Every feature you ship makes the next one easier.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0f172a', 'fontFamily': 'ui-monospace, monospace'}}}%%
flowchart LR
    subgraph session1 ["  TODAY  "]
        direction TB
        p1["Problem: stale data"]
        s1["Solution: key=id"]
        d1["Document"]
    end

    subgraph central ["  HUB  "]
        direction TB
        sync["Sync"]
        repo["learnings/"]
        curated["Curated"]
    end

    subgraph session2 ["  TOMORROW  "]
        direction TB
        p2["Task: edit form"]
        search2["Search"]
        found["Found: 2m vs 30m"]
    end

    p1 --> s1 --> d1
    d1 -->|"compound"| sync
    sync --> repo --> curated
    curated -->|"auto"| search2
    p2 --> search2 --> found

    style session1 fill:#f8fafc,stroke:#e2e8f0
    style session2 fill:#f8fafc,stroke:#e2e8f0
    style central fill:#fef3c7,stroke:#f59e0b
    style p1 fill:#fecaca,stroke:#ef4444,color:#7f1d1d
    style s1 fill:#d1fae5,stroke:#10b981,color:#064e3b
    style d1 fill:#dbeafe,stroke:#3b82f6,color:#1e3a8a
    style sync fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style repo fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style curated fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style p2 fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style search2 fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style found fill:#d1fae5,stroke:#10b981,color:#064e3b
```

---

## What the Issue Looks Like

The GitHub issue becomes a living document of the journey.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'cScale0': '#dbeafe', 'cScale1': '#fef3c7', 'cScale2': '#d1fae5', 'cScale3': '#fce7f3', 'cScale4': '#ede9fe', 'cScale5': '#d1fae5', 'cScaleLabel0': '#1e3a8a', 'cScaleLabel1': '#78350f', 'cScaleLabel2': '#064e3b', 'cScaleLabel3': '#831843', 'cScaleLabel4': '#4c1d95', 'cScaleLabel5': '#064e3b'}}}%%
timeline
    title Issue #85 · Validate issue exists

    section Created
        Idea captured : 30 seconds

    section Search
        Local + central : No prior art
        : Novel work

    section Plan
        Research : gh exit code 1
        Decision : Inline validation

    section Work
        Built : Step 1.5 added
        Tests : Passing

    section Review
        Agents : 0 P1 · 0 P2 · 0 P3
        Status : Clear

    section Compound
        Documented : validate-inputs.md
        Insight : Suggest actions in errors

    section Done
        Outcome : Completed as planned
```

---

## The Review Swarm

12+ specialized agents catch what humans miss.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0f172a', 'fontFamily': 'ui-monospace, monospace'}}}%%
flowchart TB
    subgraph code [" "]
        changes["Your Changes"]
    end

    changes --> review[["workflows:review"]]

    subgraph agents ["  12+ AGENTS IN PARALLEL  "]
        direction LR
        a1["Architecture"]
        a2["Security"]
        a3["Performance"]
        a4["Simplicity"]
        a5["Data"]
        a6["Patterns"]
        a7["Rails"]
        a8["Python"]
        a9["TypeScript"]
        a10["Deploy"]
        a11["Agent"]
        a12["..."]
    end

    review --> agents

    agents --> findings["Prioritized Findings"]

    subgraph priority ["  TRIAGE  "]
        p1["P1 Blocking"]
        p2["P2 Important"]
        p3["P3 Consider"]
    end

    findings --> priority
    priority --> issues["Issues Created"]

    style code fill:none,stroke:none
    style changes fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style review fill:#0f172a,stroke:#0f172a,color:#f8fafc
    style agents fill:#fce7f3,stroke:#ec4899
    style a1 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a2 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a3 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a4 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a5 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a6 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a7 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a8 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a9 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a10 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a11 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style a12 fill:#fce7f3,stroke:#f9a8d4,color:#831843
    style findings fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style priority fill:#f8fafc,stroke:#e2e8f0
    style p1 fill:#fecaca,stroke:#ef4444,color:#7f1d1d
    style p2 fill:#fef3c7,stroke:#f59e0b,color:#78350f
    style p3 fill:#dbeafe,stroke:#3b82f6,color:#1e3a8a
    style issues fill:#d1fae5,stroke:#10b981,color:#064e3b
```

---

## Learnings Taxonomy

Knowledge organized for instant discovery.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0f172a', 'fontFamily': 'ui-monospace, monospace'}}}%%
flowchart TB
    subgraph repos ["  SOURCE REPOS  "]
        r1["business-ops/"]
        r2["dev-plugins/"]
        r3["marketing-ops/"]
    end

    repos -->|"sync"| central

    subgraph central ["  CENTRAL HUB  "]
        direction TB
        incoming["incoming/"]
        incoming -->|"triage"| curated

        subgraph curated ["  curated/  "]
            universal["universal/"]
            frontend["frontend/"]
            backend["backend/"]
            lob["lob/"]
        end
    end

    curated -->|"search"| sessions["Future Sessions"]

    style repos fill:#f8fafc,stroke:#e2e8f0
    style r1 fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style r2 fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style r3 fill:#f1f5f9,stroke:#cbd5e1,color:#334155
    style central fill:#fef3c7,stroke:#f59e0b
    style incoming fill:#fef3c7,stroke:#fcd34d,color:#78350f
    style curated fill:#fff7ed,stroke:#fdba74
    style universal fill:#dbeafe,stroke:#3b82f6,color:#1e3a8a
    style frontend fill:#fce7f3,stroke:#ec4899,color:#831843
    style backend fill:#ede9fe,stroke:#8b5cf6,color:#4c1d95
    style lob fill:#d1fae5,stroke:#10b981,color:#064e3b
    style sessions fill:#0f172a,stroke:#0f172a,color:#f8fafc
```

---

## State Machine

How issues flow through the system.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0f172a', 'primaryTextColor': '#f8fafc', 'primaryBorderColor': '#334155', 'lineColor': '#64748b', 'fontFamily': 'ui-monospace, monospace'}}}%%
stateDiagram-v2
    [*] --> Idea: quick idea
    [*] --> Planning: build

    Idea --> Planning: start
    Idea --> [*]: close

    Planning --> Working: approved
    Planning --> Planning: edit

    Working --> Reviewing: tests pass
    Working --> Working: continue

    Reviewing --> Compounding: no P1s
    Reviewing --> Working: fix P1s

    Compounding --> Closed: documented

    Closed --> [*]

    state Planning {
        [*] --> Research
        Research --> Design
        Design --> Decide
        Decide --> [*]
    }

    state Reviewing {
        [*] --> Swarm
        Swarm --> Triage
        Triage --> [*]
    }
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `wdi:workflow-feature` | Start new |
| `wdi:workflow-feature #45` | Continue issue |
| `wdi:workflow-feature --yes` | Auto-continue |
| `wdi:workflow-feature --plan` | Plan only |

---

## Real Example

[Issue #85](https://github.com/whitedoeinn/dev-plugins-workflow/issues/85) shows the complete journey.

```
#85: Validate issue exists
  Body      Problem, Solution, Plan
  Search    No prior art found
  Plan      gh returns exit code 1
  Work      Step 1.5 added, tests passing
  Review    0 P1, 0 P2, 0 P3
  Compound  Learnings documented
  Closed    Completed as planned
```

---

## Why This Matters

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'quadrant1Fill': '#d1fae5', 'quadrant2Fill': '#fef3c7', 'quadrant3Fill': '#fecaca', 'quadrant4Fill': '#fee2e2', 'quadrant1TextFill': '#064e3b', 'quadrant2TextFill': '#78350f', 'quadrant3TextFill': '#7f1d1d', 'quadrant4TextFill': '#7f1d1d', 'quadrantPointFill': '#0f172a', 'quadrantPointTextFill': '#0f172a', 'fontFamily': 'ui-monospace, monospace'}}}%%
quadrantChart
    title Developer Experience vs Knowledge Capture
    x-axis Low Friction --> High Friction
    y-axis Knowledge Lost --> Knowledge Compounds
    quadrant-1 "THE GOAL"
    quadrant-2 "Docs decay"
    quadrant-3 "Tribal knowledge"
    quadrant-4 "Process overhead"
    wdi: [0.2, 0.85]
    Confluence: [0.7, 0.5]
    Just code: [0.1, 0.15]
    Enterprise: [0.9, 0.6]
```

**The sweet spot:** Low friction, high knowledge retention.

---

## Get Started

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

Then run:
```
wdi:workflow-feature
```

---

<p align="center">
  <strong>One command. Complete journey. Knowledge compounds.</strong>
  <br><br>
  <a href="https://github.com/whitedoeinn/dev-plugins-workflow">GitHub</a> ·
  <a href="https://github.com/whitedoeinn/dev-plugins-workflow/issues/85">Example</a> ·
  <a href="https://github.com/whitedoeinn/learnings">Learnings</a>
</p>
