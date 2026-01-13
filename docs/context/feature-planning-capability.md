# Feature Planning Capability - Current State

Context document describing how feature planning works in wdi-workflows. Use this as input for designing a more comprehensive roadmap planning feature.

---

## Overview

The current system is optimized for **single-feature execution**, not portfolio or roadmap planning. It handles the lifecycle of one feature from ideation to completion, but lacks tooling for:

- Multi-feature prioritization
- Milestone planning and sequencing
- Dependency visualization across features
- Roadmap management

---

## Components

### 1. Feature Workflow Command

**File:** `commands/feature.md`
**Invocation:** `/wdi-workflows:feature`

An interview-driven workflow with 7 phases:

```
Interview → Pre-flight → Research → Plan → Work → Review → Compound
```

**Interview captures:**
- Feature type: New Feature | Enhancement | Bug Fix | Refactor | Experiment
- Complexity: Simple | Moderate | Complex | Unknown
- Target location (mono-repos): Which package
- Research preference: Full | Light | Skip
- Feature description (free text)

**Key outputs:**
- GitHub Issue with requirements and acceptance criteria
- Feature spec file at `docs/product/planning/features/{slug}.md`
- Implementation on feature branch
- Changelog entry on completion

**Flags:**
- `--yes` / `-y` - Auto-continue through phases
- `--plan` - Stop after planning (for discussion before committing)
- `--idea` - Quick idea capture mode

### 2. Feature Template

**File:** `docs/templates/feature.md`

Structured template capturing:

| Section | Purpose |
|---------|---------|
| Status | Planning → In Progress → Review → Complete |
| Context | Type, complexity, target package |
| Problem | Why this feature is needed |
| Done When | Acceptance criteria as checkboxes |
| Implementation Plan | Ordered list of steps |
| Files | Table of files to modify/create |
| Dependencies | Blocked by / Blocks relationships |
| Research Summary | Key findings from research phase |
| Notes | Decisions, alternatives considered |

**Dependency fields:**
```markdown
## Dependencies

**Blocked by:**
- {Feature or milestone this depends on}

**Blocks:**
- {Features that depend on this}
```

### 3. Milestone Template

**File:** `docs/templates/milestone.md`

Comprehensive template for grouping features:

| Section | Purpose |
|---------|---------|
| Value Delivered | What users get when complete |
| Scope | What's included / NOT included |
| Features | Table with priority and status |
| Technical Dependencies | External, Internal, Package, Infrastructure, Data |
| Non-Technical Dependencies | Maintenance, Personnel, Approval, Vendor, Event, Resource |
| Blocked By / Blocks | Blocking relationships |
| PRD Coverage | Which requirements this addresses |
| Risks | Likelihood, impact, mitigation |
| Done When | Milestone-level acceptance criteria |

**No command creates milestones** - template exists but is manually used.

### 4. Issue Standards

**File:** `docs/standards/ISSUE-STANDARDS.md`

Defines GitHub Issue conventions:
- Title format (sentence case, brief)
- Required labels (type): bug, feature, enhancement, documentation, question, experiment
- Optional labels: priority, status, area
- Issue templates for bug reports, feature requests, enhancements
- Issue lifecycle: Open → In Progress → Review → Closed

**Integration:** `/wdi-workflows:feature` creates issues automatically using these standards.

### 5. Dependency Standards

**File:** `docs/standards/DEPENDENCY-STANDARDS.md`

Comprehensive dependency tracking framework:

**Technical Types:**
| Type | Description |
|------|-------------|
| External | Third-party API/service |
| Internal | Another feature/milestone |
| Package | Library dependency |
| Infrastructure | Environment/platform |
| Data | Migration/data availability |

**Non-Technical Types:**
| Type | Description |
|------|-------------|
| Maintenance | Scheduled downtime |
| Personnel | Team availability |
| Approval | Sign-off required |
| Vendor | External company |
| Event | Deadline/demo |
| Resource | Hardware/budget |

**Status Values:** Available, Pending, In Progress, Blocked, At Risk, N/A

**Relationships:** Blocked by, Blocks, Depends on, Related to

### 6. Quick Reference

**File:** `knowledge/standards-summary.md`

Condensed reference for all standards including:
- Repository naming patterns
- Command naming conventions
- Branch and commit formats
- Issue and dependency quick reference

---

## Current Workflow Capabilities

### What Works Well

1. **Single-feature lifecycle** - Complete flow from idea to merged code
2. **Adaptive research** - Agent selection based on complexity
3. **Adaptive review** - Review depth based on feature type
4. **GitHub integration** - Issues created and closed automatically
5. **Documentation generation** - Feature specs and changelog entries
6. **Dependency capture** - Templates have fields for blocked by/blocks

### What's Missing

| Gap | Description |
|-----|-------------|
| **Roadmap file** | No `docs/roadmap.md` or equivalent |
| **Roadmap command** | No `/wdi-workflows:roadmap` or `/wdi-workflows:plan-milestone` |
| **Milestone automation** | Template exists but no command uses it |
| **Dependency visualization** | No way to see dependency graph across features |
| **Prioritization framework** | No guidance on sequencing work |
| **Portfolio view** | No aggregated view of all planned features |
| **GitHub Milestones** | No integration with GitHub's milestone feature |
| **Progress tracking** | No rollup of feature status to milestone level |

---

## File System Layout

Current product planning structure:

```
docs/
├── product/
│   └── planning/
│       └── features/           # Feature specs (created by /feature)
│           └── {slug}.md
├── templates/
│   ├── feature.md              # Feature template
│   └── milestone.md            # Milestone template (unused by commands)
├── standards/
│   ├── ISSUE-STANDARDS.md      # Issue format
│   └── DEPENDENCY-STANDARDS.md # Dependency tracking
└── changelog.md                # Updated by commit skill
```

**Missing:**
```
docs/
├── product/
│   └── planning/
│       ├── roadmap.md          # Does not exist
│       └── milestones/         # Does not exist
│           └── MILE-XXX.md
```

---

## Agent Integration

### Research Agents (used during /feature)

| Agent | Purpose |
|-------|---------|
| `repo-research-analyst` | Analyze repository structure and patterns |
| `git-history-analyzer` | Trace code evolution and contributors |
| `framework-docs-researcher` | Fetch library documentation |
| `best-practices-researcher` | Research external best practices |

### Review Agents (used during /feature)

| Agent | Purpose |
|-------|---------|
| `code-simplicity-reviewer` | Catch over-engineering |
| `architecture-strategist` | Design pattern compliance |
| `security-sentinel` | Security vulnerabilities |
| `performance-oracle` | Performance issues |

### Planning Agents (not yet integrated)

No agents currently assist with:
- Prioritization decisions
- Dependency analysis across features
- Milestone scoping
- Roadmap sequencing

---

## Integration Points

### Compound Engineering Plugin

The feature workflow leverages compound-engineering skills:

| Skill | Used In |
|-------|---------|
| `/compound-engineering:workflows:plan` | Phase 4: Plan |
| `/compound-engineering:workflows:work` | Phase 5: Work |
| `/compound-engineering:workflows:compound` | Phase 7: Compound |

### GitHub CLI

| Command | Used For |
|---------|----------|
| `gh issue create` | Create feature issue |
| `gh issue close` | Close issue on completion |
| `gh pr create` | Create PR for complex features |

**Not used:**
- `gh milestone create`
- `gh milestone list`
- `gh project` (GitHub Projects)

---

## Summary

**Current state:** Strong single-feature execution with templates and standards for dependency tracking, but no automation for portfolio-level planning.

**Key gaps for roadmap planning:**

1. No roadmap file or command
2. Milestone template exists but isn't wired to any workflow
3. No dependency visualization across features
4. No prioritization framework or sequencing logic
5. No GitHub Milestones integration
6. No aggregated progress tracking

**Foundation available:**
- Dependency standards already define types, status, relationships
- Milestone template is comprehensive
- Feature workflow could be extended to link to milestones
- GitHub CLI supports milestone operations

---

*This document describes the current state as of the commit that added it. Update when significant changes are made to planning capabilities.*
