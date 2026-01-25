---
title: Progressive Disclosure Hierarchy for Developer Onboarding
date: 2026-01-25
category: developer-experience
tags:
  - onboarding
  - documentation
  - progressive-disclosure
  - hello-world
  - ecosystem-explanation
  - ux-writing
component: developer-onboarding
problem_type: contributor-friction
symptoms:
  - Comprehensive docs exist but contributors feel overwhelmed
  - No clear entry point for new contributors
  - Ecosystem relationships unclear despite being documented
  - High cognitive load before first contribution
root_cause: Flat information hierarchy treats all context as equally important; missing scaffolding for progressive complexity
solution_approach: Three-tier documentation pyramid with progressive disclosure; Hello World pattern for quick wins; ecosystem-as-story visualization
files_modified:
  - docs/COLLABORATOR-GUIDE.md
  - README.md
  - CLAUDE.md
related_issues:
  - "#87"
learnings:
  - Progressive disclosure hierarchy reduces cognitive load - README (30sec), COLLABORATOR-GUIDE (30min), standards (deep dives)
  - Hello World pattern (quick win before concepts) builds contributor confidence and creates momentum
  - Ecosystem-as-story approach with character tables makes abstract relationships concrete and memorable
---

# Progressive Disclosure Hierarchy for Developer Onboarding

## Problem Statement

The WDI plugin ecosystem had comprehensive documentation - README, CLAUDE.md, CONTRIBUTING.md, architecture.md, standards docs - but potential collaborators still struggled to get started. The docs answered every question but didn't guide newcomers through a learning journey.

**Symptoms:**
- "Where do I start?" despite having a README
- Contributors reading everything before attempting anything
- Ecosystem relationships (wdi, compound-engineering, learnings repo) unclear despite being documented
- Setup validation happening implicitly rather than explicitly

## Solution

Created `docs/COLLABORATOR-GUIDE.md` using three key patterns:

### 1. Progressive Disclosure Hierarchy

Structure documentation in tiers based on time commitment and depth:

```
Level 0: README.md           → What is this? (30 seconds)
Level 1: COLLABORATOR-GUIDE  → Get productive (30 minutes)
Level 2: CONTRIBUTING.md     → Technical reference (as needed)
Level 3: docs/standards/*    → Deep specifications (when required)
```

Each tier serves a different question:
- **README**: "Should I care about this?"
- **COLLABORATOR-GUIDE**: "How do I get started and contribute?"
- **CONTRIBUTING**: "How do I add/modify specific things?"
- **Standards**: "What are the exact rules for X?"

### 2. Hello World Pattern

Before explaining concepts, give contributors a quick win:

```markdown
## The 10-Minute Hello World

### Step 1: Clone the Repo
### Step 2: Run the Installer
### Step 3: Start Claude Code
### Step 4: Validate Your Setup (say "check my config")
### Step 5: Create Your First Issue (/wdi:workflow-feature → Quick idea)

You did it. You have a working environment.
```

**Why this works:**
- Validates setup before investing in concepts
- Creates momentum through visible success
- Reduces anxiety ("I can always get back to this working state")
- Provides concrete reference point for later explanations

### 3. Ecosystem-as-Story

Instead of listing components and their responsibilities, present them as characters in a narrative:

```markdown
### The Cast of Characters

| Component | Role | What It Does |
|-----------|------|--------------|
| **wdi** | The orchestrator | Knows our conventions. Gathers context, creates issues. |
| **compound-engineering** | The engine | Does the heavy lifting. Research agents, review agents. |
| **learnings repo** | The memory | Central place where learnings accumulate. |
```

Then show how they work together:

```
You → /wdi:workflow-feature → (wdi gathers context)
                                    ↓
                            compound-engineering
                              (does the work)
                                    ↓
                            docs/solutions/
                              (learning captured)
```

This approach makes abstract relationships concrete and memorable.

## Implementation

**Document structure:**
1. Hook with outcome promise ("30 minutes to productivity")
2. Hello World (10 minutes, explicit success markers)
3. Ecosystem story (cast of characters, flow diagram)
4. First real contribution walkthrough
5. Common gotchas table
6. What's next with tiered recommendations

**Integration:**
- README quick links bar: Added "New Contributor? Start Here"
- CLAUDE.md structure: Added COLLABORATOR-GUIDE.md to the file tree
- Cross-references: Links to architecture.md, troubleshooting.md, CONTRIBUTING.md for depth

## Prevention

When creating documentation for new systems:

1. **Start with the hierarchy** - Decide what goes in each tier before writing
2. **Design the Hello World first** - What's the quickest path to visible success?
3. **Draw the ecosystem diagram early** - Forces clarity on component relationships
4. **Test with a fresh perspective** - Have someone unfamiliar actually follow the guide

## Related

- `docs/solutions/developer-experience/installer-auto-detection.md` - Context-aware installation
- `docs/solutions/developer-experience/plugin-version-propagation.md` - How updates flow
- `docs/architecture.md` - System design reference
- `docs/troubleshooting.md` - Common issues and fixes
