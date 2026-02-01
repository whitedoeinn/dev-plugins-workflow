# Unleashed Mode — AI Exploration Methodology

**Created:** 2026-01-31 (Sonnet 4.5)  
**Revised:** 2026-02-01 (Opus 4.5 review)  
**Status:** Experimental methodology

## The Problem

Traditional AI-assisted development:
1. Human imagines requirements
2. AI implements within those constraints
3. Human reviews against original vision
4. Deviations = mistakes

**Limitation:** You can only get what you could imagine. Requirements are bounded by what you already know.

## The Approach

Unleashed methodology:
1. Human defines goals + constraints + off-limits
2. AI explores solution space through multiple lenses
3. AI documents discoveries, tradeoffs, and failures honestly
4. Human curates discoveries
5. Refinement = polishing chosen approach, not fixing deviations

**Advantage:** You discover approaches you might not have considered. Unexpected tradeoffs surface before they become problems.

## How It Works

### 1. Minimal Intent Capture

Three questions:
- **What problem** are you solving? (one sentence)
- **What constraints** matter? (technical, UX, business)
- **What's off-limits?** (things you definitely DON'T want)

No implementation details. No "how." Just "what" and "why not."

### 2. Sequential Exploration with Perspective Shifts

Claude works sequentially, not in parallel. The "three threads" are three deliberate perspective shifts:

**Conservative lens:**
- Minimal changes to existing patterns
- Highest compatibility, lowest risk
- Question: "What's the simplest thing that could work?"

**Balanced lens:**
- Mix of new and existing approaches
- Moderate innovation, balanced tradeoffs
- Question: "What's the best solution if I'm not anchored to current patterns?"

**Radical lens:**
- Fresh approach from first principles
- Maximum innovation, higher risk
- Question: "If I were building this from scratch with no constraints except the stated ones, what would I do?"

### 3. Self-Discovery Process

For each lens:
1. **Explore** — Try an approach
2. **Test** — Run actual tests, check for breakage
3. **Discover** — Note unexpected benefits or problems
4. **Pivot** — If approach hits dead end, try another angle
5. **Document** — Capture what was learned, including failures

**No asking permission during exploration.** Document everything.

### 4. Quality Self-Review

Each approach reviews itself honestly:
- Run all tests
- Check for code smells and technical debt
- Identify integration concerns
- Flag potential issues

**Don't hide problems.** Tradeoffs are information, not failures.

### 5. Present Discoveries

Show all approaches with:

```markdown
## [Lens]: [Descriptive name]
**Approach:** [High-level strategy]
**Discoveries:**
- [Unexpected benefit or finding]
- [Another discovery]
**Tradeoffs:**
- [Cost or limitation]
- [Another tradeoff]
**Quality:** [Test results, known issues]
**Future:** [What this enables or blocks]
```

No recommendations. Present the options. Let the human curate.

### 6. Human Curation

The human says:
- "Ship the conservative approach"
- "Combine conservative's structure with radical's insight about X"
- "None of these work, but the balanced approach's discovery about Y is interesting — explore that"
- "Conservative works, but polish the API naming"

**The human curates, doesn't constrain.**

## Failure Modes

### All approaches hit dead ends
**Response:** Escalate to human. Document what was tried, why each failed, and what constraints might need loosening.

### Human dislikes all options
**Response:** Ask which discoveries were closest to useful. Iterate on that thread with refined constraints.

### Approaches conflict architecturally
**Response:** Document the incompatibilities explicitly. The human needs to choose a direction, not combine incompatible approaches.

### Token/time budget exhausted
**Response:** Present partial results with clear gaps. "Conservative is complete, balanced is 80% explored, radical was abandoned at X because Y."

### AI converges too early
**Response:** This is the most common failure. The AI finds something that works in the conservative lens and stops genuinely exploring alternatives. Guard against this by committing to each lens fully before moving on.

## Comparison: Constrained vs. Unleashed

| Aspect | Constrained | Unleashed |
|--------|------------|-----------|
| **Input** | Detailed requirements | Goal + constraints + off-limits |
| **Process** | Plan → Work → Review → Compound | Explore → Discover → Present → Curate |
| **Solutions** | One (as specified) | Multiple (discovered) |
| **Deviations** | Mistakes to fix | Discoveries to evaluate |
| **Cost** | 1x tokens | 3-10x tokens |
| **Best for** | Known solutions | Unknown possibilities |

## When To Use Each

### Use Constrained (`/wdi:workflow-feature`)
- Solution space is obvious
- Requirements are clear
- Budget-constrained
- Quick iteration needed
- Example: "Add dark mode toggle to settings page"

### Use Unleashed (`/wdi:workflow-unleashed`)
- Solution space unclear
- "Make it better" type goal
- Discovery more valuable than speed
- Willing to invest tokens in exploration
- Example: "Onboarding feels clunky, not sure why"

## Principles

### 1. Honest Documentation
Document problems, not just successes. Tradeoffs are information. Failures are data.

### 2. Human as Curator
Human's job: recognize value, combine ideas, choose directions.
Not: "Did you follow my spec?" Instead: "Which of these approaches is most valuable?"

### 3. Dunning-Kruger Awareness
Requirements are limited by knowledge. The point of exploration is to discover what you don't know yet.

### 4. Refinement ≠ Failure
Incorporating a discovery from one approach into another isn't rework. It's polishing the solution.

## Integration with Existing Workflows

1. **Unleashed → Constrained:** Explore approaches, curate, then execute chosen approach with full workflow discipline
2. **Constrained → Unleashed:** Ship MVP, then explore enhancements
3. **Hybrid:** Start unleashed, switch to constrained when direction is clear

## Cost Awareness

| Scenario | Multiplier | Notes |
|----------|-----------|-------|
| Clean run, human picks one | 3x | Best case |
| Exploration + iteration | 5x | Typical |
| Multiple curation rounds | 8-10x | Complex problems |

**Worth it when:** Uncertainty is high, discovery > speed, innovation needed.
**Not worth it when:** Solution obvious, budget tight, speed critical.

## Future Enhancements (Not Yet Implemented)

- **Learning system:** Track which discoveries were valuable across runs (`.claude/learnings/explorations.jsonl`)
- **Selective exploration:** `--conservative-only`, `--radical-only` flags
- **Auto-curation hints:** AI suggests which approach best fits human's historical preferences

These are ideas, not features. They'll be built when the methodology proves itself.

---

**Status:** Experimental methodology  
**Created:** Sonnet 4.5, 2026-01-31  
**Revised:** Opus 4.5, 2026-02-01
