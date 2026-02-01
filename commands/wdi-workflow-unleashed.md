# /wdi:workflow-unleashed

**Exploration methodology — AI discovers approaches through deliberate perspective shifts**

## Philosophy

Traditional: Human defines requirements → AI implements → Human verifies

**Unleashed:** Human defines goals → AI explores through multiple lenses → AI presents discoveries → Human curates

## How It Works

### 1. Intent Capture (Minimal)

Ask the human:
- **What problem** are you solving? (one sentence)
- **What constraints** matter? (technical, UX, business)
- **What's off-limits?** (things you definitely DON'T want)

That's it. No implementation details. No "how". Just "what" and "why not".

### 2. Sequential Exploration with Perspective Shifts

Work through three deliberate lenses, one at a time. Commit fully to each before moving on.

**Lens A: Conservative**
- Minimal changes to existing patterns
- Highest compatibility, lowest risk
- Ask: "What's the simplest thing that could work?"

**Lens B: Balanced**
- Mix of new and existing approaches
- Moderate innovation, balanced tradeoffs
- Ask: "What's the best solution if I'm not anchored to current patterns?"

**Lens C: Radical**
- Fresh approach from first principles
- Maximum innovation, higher risk
- Ask: "If I built this from scratch with only the stated constraints, what would I do?"

**Guard against premature convergence.** If conservative works, still explore balanced and radical fully. The point is to discover alternatives, not confirm the obvious.

### 3. Self-Discovery Process

For each lens:

1. **Explore** — Try an approach
2. **Test** — Run actual tests, check for breakage
3. **Discover** — Find unexpected benefits or problems (invoke `discovery-capture` skill)
4. **Pivot** — If approach hits dead end, try another angle within the same lens
5. **Document** — Capture what was learned, including failures

**No asking permission.** Just explore.

### 4. Quality Self-Review

Each approach reviews itself:
- Run all tests
- Check for code smells
- Identify technical debt
- Note integration concerns
- Flag potential issues

**Be honest.** Don't hide problems. Document them.

### 5. Present Discoveries

Show the human **all three approaches** with:

```markdown
## Lens A: [Descriptive name]
**Approach:** [High-level strategy]
**Discoveries:**
- [Unexpected benefit 1]
- [Unexpected finding 2]
**Tradeoffs:**
- [Cost/limitation 1]
- [Cost/limitation 2]
**Quality:** [Test results, known issues]
**Future:** [What this enables or blocks]

[Show key code snippet or demo if applicable]
```

No recommendations. Present options. Let the human curate.

### 6. Human Curation

Human says:
- "Ship A" (take conservative path)
- "Ship B + C's idea about X" (combine approaches)
- "None of these, but C's discovery about Y is interesting — explore that"
- "A works but polish the API naming"

**The human curates, doesn't constrain.**

### 7. Failure Handling

**All approaches fail:**
Document what was tried, why each failed, what constraints might need loosening. Escalate to human.

**Human likes none:**
Ask which discoveries came closest. Iterate on that thread with refined constraints.

**Budget exhausted:**
Present partial results with clear gaps. "A is complete, B is 80% explored, C was abandoned at X."

**Premature convergence:**
If you notice all three lenses producing the same approach, stop and ask: "Am I actually exploring, or just confirming my first instinct?" Restart the lens that converged.

## Example Usage

```bash
/wdi:workflow-unleashed
```

**AI:** What problem are you solving?
**Human:** Search is too slow when we have 1000+ tasks

**AI:** What constraints matter?
**Human:** Must work on mobile, can't break existing saved searches

**AI:** What's off-limits?
**Human:** No external search services, no complete rewrite of task model

**AI:** [Explores three lenses sequentially]
- Lens A (Conservative): Indexes + debouncing
- Lens B (Balanced): Virtual scrolling + smart caching
- Lens C (Radical): Predictive search with lightweight ML

**AI:** Here's what I discovered across all three approaches...

**Human:** Ship A. Save C's predictive idea for later.

## Integration with Existing Workflow

- **Standalone** — Pure exploration mode
- **Exploration → Execution** — Use unleashed to find direction, then `/wdi:workflow-feature` for disciplined implementation
- **Enhancement** — Take an existing feature and explore improvements

## Safety Rails

**What prevents chaos:**
1. Git branches — each approach works in isolation
2. Tests — must pass before presenting
3. Self-review — AI documents issues honestly
4. Human curation — final decision always human's

**What's deliberately removed:**
- Phase gates during exploration
- Prescriptive specifications
- Single-solution constraint

## When to Use This

**Good for:**
- "Make X better" (open-ended improvement)
- "We need Y but I don't know how" (exploration needed)
- "Current approach feels wrong" (seeking alternatives)

**Not good for:**
- "Change this CSS color to #FF0000" (trivial)
- "Fix this specific bug" (defined problem)
- "Implement this exact API spec" (no room for discovery)

## Cost Awareness

Exploration costs more than implementation. Expect 3-10x token cost of a regular workflow depending on complexity and curation rounds.

**Worth it when:** Discovery value > token cost.
**Not worth it when:** Solution space is obvious.

---

**Status:** Experimental methodology  
**See also:** `docs/UNLEASHED.md` for full guide
