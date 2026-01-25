# Developer Onboarding Documentation for WDI Ecosystem

**Issue:** #87
**Type:** Feature
**Status:** Planning

---

## Overview

Create engaging, exciting developer onboarding documentation that helps a potential collaborator go from "what is this?" to "I just shipped my first contribution" in a single, well-designed journey.

The documentation should embody the "compound engineering" philosophy - each collaborator who understands the system makes it easier for the next one.

---

## Problem Statement / Motivation

**The gap:** A buddy wants to collaborate but faces these barriers:

1. **Unclear entry point** - README is comprehensive but overwhelming; where do they start?
2. **Missing "Hello World"** - No quick win to validate setup and build confidence
3. **Ecosystem is fragmented** - wdi, compound-engineering, and learnings repo are explained separately, not as a cohesive system
4. **Contribution path is implicit** - CONTRIBUTING.md exists but doesn't guide a first-timer through the full journey

**Why this matters:** First impressions determine whether someone becomes an active contributor or bounces. The existing docs are reference-grade, not onboarding-grade.

---

## Proposed Solution

Create a new **Developer Onboarding Guide** (`docs/COLLABORATOR-GUIDE.md`) that:

1. **Leads with outcomes** - "You'll ship your first contribution in 30 minutes"
2. **Provides a Hello World** - Quick win in first 10 minutes that validates everything works
3. **Explains the ecosystem as a story** - Why compound engineering? How do the pieces fit?
4. **Guides the first contribution** - Step-by-step from idea to shipped code
5. **Uses progressive disclosure** - Quick start first, deep dives linked

### Document Structure

```
docs/COLLABORATOR-GUIDE.md
├── 1. What You'll Build Today (hook)
├── 2. The 10-Minute Hello World
├── 3. The Ecosystem: A Story
├── 4. Your First Real Contribution
├── 5. Common Gotchas
├── 6. What's Next?
└── Appendix: Quick Reference
```

---

## Technical Considerations

### Architecture impacts

- **No code changes** - This is pure documentation
- **File location** - `docs/COLLABORATOR-GUIDE.md` fits existing structure
- **Cross-references** - Will link to existing docs (CONTRIBUTING.md, architecture.md, troubleshooting.md) rather than duplicate

### Existing documentation strategy

The new guide fills a gap in the progressive disclosure hierarchy:

```
Level 0: README.md           → What is this? (30 seconds)
Level 1: COLLABORATOR-GUIDE  → Get productive (30 minutes) ← NEW
Level 2: CONTRIBUTING.md     → Add/modify commands (reference)
Level 3: docs/standards/*    → Deep specifications (as needed)
```

### Tone and style

Following best practices research:
- Second person, active voice ("You'll create...", "Run this command...")
- No "simply" or "just" (implies user is at fault if they struggle)
- Time estimates for each section
- Show "why" alongside "how"
- Conversational but not slangy

---

## Acceptance Criteria

- [x] New file: `docs/COLLABORATOR-GUIDE.md` created
- [x] Section 1: Hook that promises specific outcome with time estimate
- [x] Section 2: Hello World that works in <10 minutes and produces visible result
- [x] Section 3: Ecosystem explanation covering wdi + compound-engineering + learnings
- [x] Section 4: First contribution walkthrough using `/wdi:workflow-feature`
- [x] Section 5: Top 5 gotchas with solutions (actually 7 gotchas)
- [x] Section 6: Clear next steps with links
- [x] README.md updated to link to COLLABORATOR-GUIDE.md
- [x] CLAUDE.md updated to reference COLLABORATOR-GUIDE.md in structure
- [ ] Guide tested by actually following it from scratch

### Testing requirements

- [ ] Clone fresh repo, follow guide verbatim, verify all commands work
- [ ] Time the Hello World section - must be completable in <10 minutes
- [ ] Verify all cross-reference links resolve

---

## Success Metrics

1. **Time to first success**: A new collaborator can validate their setup in <10 minutes
2. **Clarity**: No questions about "what should I do next?" at any step
3. **Engagement**: The documentation feels exciting, not like a chore
4. **Completeness**: Covers the full journey from discovery to contribution

---

## Dependencies & Risks

### Dependencies

| Dependency | Status | Notes |
|------------|--------|-------|
| Existing docs structure | ✓ Ready | Linking to architecture.md, troubleshooting.md |
| install.sh | ✓ Ready | Hello World will use this |
| `/wdi:workflow-feature` | ✓ Ready | First contribution walkthrough uses this |

### Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Guide becomes stale | Medium | Add to commit skill's doc-sync check |
| Too long/overwhelming | Medium | Strict progressive disclosure; time estimates |
| Assumes too much Claude Code knowledge | Low | Explain plugin concepts inline |

---

## Implementation Plan

### Phase 1: Core Document (Primary Deliverable)

**Create `docs/COLLABORATOR-GUIDE.md` with these sections:**

#### Section 1: What You'll Build Today
```markdown
# Welcome, Future Collaborator

By the end of this guide (about 30 minutes), you'll have:
- ✓ A working WDI development environment
- ✓ Understanding of how wdi, compound-engineering, and learnings work together
- ✓ Your first contribution shipped (or at least captured as an idea)

Let's go.
```

#### Section 2: The 10-Minute Hello World

Step-by-step:
1. Clone the repo
2. Run `./install.sh` (handles everything)
3. Start Claude Code: `claude`
4. Say "check my config" (validates environment)
5. Run `/wdi:workflow-feature` → "Quick idea" → Enter "Test my setup"
6. See issue created - **Success!**

Include expected output at each step. Screenshot-style ASCII art where helpful.

#### Section 3: The Ecosystem - A Story

**The Philosophy (2 paragraphs max):**
- Compound engineering = each solved problem makes future problems easier
- Knowledge accumulates in `docs/solutions/` and syncs across projects

**The Cast of Characters:**

| Component | Role | Analogy |
|-----------|------|---------|
| **wdi** | The orchestrator | A tour guide who knows the local conventions |
| **compound-engineering** | The engine | A powerful toolkit the guide uses |
| **learnings repo** | The memory | Institutional knowledge that travels |

**How They Work Together (diagram):**
```
You → /wdi:workflow-feature → (wdi gathers context)
                                    ↓
                            compound-engineering
                                (does the work)
                                    ↓
                            docs/solutions/
                                (learning captured)
                                    ↓
                            learnings repo
                                (knowledge compounds)
```

#### Section 4: Your First Real Contribution

Walk through a complete cycle:
1. **Find something to improve** - "I noticed X could be better"
2. **Capture it**: `/wdi:workflow-feature` → Quick idea
3. **Shape it**: Add context as comments on the issue
4. **Build it**: `/wdi:workflow-feature #N` → Start building
5. **Ship it**: The workflow handles plan/work/review/compound
6. **Celebrate**: Your contribution is merged, learning documented

Emphasize: Use the commit skill, not raw git commit.

#### Section 5: Common Gotchas

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Command not found" | Plugin not loaded | Restart Claude Code |
| Changes don't propagate | Forgot version bump | Use commit skill (it bumps for you) |
| Hooks don't fire | Testing without --plugin-dir | Run `claude --plugin-dir .` |
| "Permission denied" | Script not executable | `chmod +x scripts/*.sh` |
| Stuck mid-workflow | Issue in weird state | Resume with `/wdi:workflow-feature #N` |

#### Section 6: What's Next?

**Immediate:**
- Pick a "good first issue" from the repo
- Try the full `/wdi:workflow-feature` build flow

**When Ready:**
- Read `docs/architecture.md` for system design
- Check `docs/standards/` for conventions
- Look at `docs/solutions/` to see how learnings are captured

**Having Trouble?**
- `docs/troubleshooting.md` for common issues
- Open an issue - we want to help!

### Phase 2: Integration

- [x] Update README.md Quick Links to include "New Contributor? Start here →"
- [x] Update CLAUDE.md structure section to include COLLABORATOR-GUIDE.md
- [ ] Add "For contributors" callout box in README after Quick Start (skipped - link in Quick Links is sufficient)

### Phase 3: Testing

- [ ] Fresh clone test: Follow guide from scratch on clean machine
- [ ] Time validation: Hello World completes in <10 minutes
- [ ] Link validation: All cross-references resolve
- [ ] Buddy review: Have your potential collaborator actually use it and give feedback

---

## Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `docs/COLLABORATOR-GUIDE.md` | Create | Main onboarding document |
| `README.md` | Modify | Add "New contributor" link in Quick Links |
| `CLAUDE.md` | Modify | Update Structure section to include new file |

---

## References & Research

### Internal References
- Existing onboarding attempt: `docs/GETTING-STARTED.md` (referenced but doesn't exist - confirms gap)
- Contribution guide: `CONTRIBUTING.md` (functional but not welcoming)
- Architecture docs: `docs/architecture.md` (good reference, not onboarding)
- Ecosystem explanation: `CLAUDE.md:L89-L95` (compound-engineering relationship)

### External References
- [Google Developer Documentation Style Guide](https://developers.google.com/style/tone) - Voice and tone
- [README-Driven Development](https://tom.preston-werner.com/2010/08/23/readme-driven-development) - Philosophy
- [GitHub Open Source Guides](https://opensource.guide/best-practices/) - Contributor experience
- [VS Code Extension Getting Started](https://code.visualstudio.com/api/get-started/your-first-extension) - Hello World pattern

### Research Agents Used
- `repo-research-analyst` - Existing doc patterns (agent ID: a0b2fe2)
- `best-practices-researcher` - Onboarding best practices (agent ID: a7fc774)
- `framework-docs-researcher` - Claude Code plugin docs (agent ID: a854ed0)
- `spec-flow-analyzer` - User flow analysis and gaps (agent ID: affaffc)

---

## Open Questions (Resolved)

| Question | Answer |
|----------|--------|
| Target audience? | Internal collaborators with basic Claude Code familiarity |
| Cover compound-engineering setup? | No - install.sh handles it; document as "comes with" |
| Success criteria? | First issue created via workflow in <30 minutes total |
| Document location? | `docs/COLLABORATOR-GUIDE.md` |
| Time investment? | 10 min Hello World, 30 min full guide |

---

*Plan created via `/wdi:workflow-feature` → `/workflows:plan`*
