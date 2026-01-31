# /wdi:workflow-unleashed

**Autonomous exploration workflow - AI discovers solutions beyond human imagination**

## Philosophy

Traditional workflow: Human defines requirements → AI implements → Human verifies

**Unleashed workflow:** Human defines goals → AI explores solution space → AI discovers possibilities → Human curates discoveries

## How It Works

### 1. Intent Capture (Minimal)

Ask the human:
- **What problem** are you solving? (one sentence)
- **What constraints** matter? (technical, UX, business)
- **What's off-limits?** (things you definitely DON'T want)

That's it. No implementation details. No "how". Just "what" and "why not".

### 2. Parallel Exploration

Spawn **3 exploration threads** (metaphorically - Claude can't actually spawn, but simulate this):

**Thread A: Conservative**
- Minimal changes to existing patterns
- Highest compatibility
- Lowest risk

**Thread B: Balanced**
- Mix of new and existing
- Moderate innovation
- Balanced tradeoffs

**Thread C: Radical**
- Completely fresh approach
- Maximum innovation
- Higher risk, higher potential reward

### 3. Self-Discovery Process

For each thread, AI:

1. **Explores** - Try an approach
2. **Tests** - Run actual tests, check for breakage
3. **Discovers** - Find unexpected benefits or problems
4. **Pivots** - If approach hits dead end, try another angle
5. **Documents** - Capture what was learned

**No asking permission.** Just explore.

### 4. Quality Self-Review

Each thread reviews itself:
- Run all tests
- Check for code smells
- Identify technical debt
- Note integration concerns
- Flag potential issues

**Be honest.** Don't hide problems. Document them.

### 5. Present Discoveries

Show the human **all three approaches** with:

**For each solution:**
- What it does (outcomes, not implementation)
- What it discovered (unexpected benefits)
- What it costs (tradeoffs, issues)
- What it enables (future possibilities)

**Format:**

```
## Thread A: [Descriptive name]
**Approach:** [High-level strategy]
**Discoveries:** 
- [Unexpected benefit 1]
- [Unexpected benefit 2]
**Tradeoffs:**
- [Cost/limitation 1]
- [Cost/limitation 2]
**Quality:** [Test results, known issues]
**Future:** [What this enables]

[Show key code snippet or demo]
```

### 6. Human Curation

Human says:
- "Ship A" (take conservative path)
- "Ship B + C's idea about X" (combine approaches)
- "None of these, but C's discovery about Y is interesting - explore that"
- "A works but polish the API naming"

**The human curates, doesn't constrain.**

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

**AI:** [Starts parallel exploration]
- Thread A: Indexes + debouncing
- Thread B: Virtual scrolling + smart caching  
- Thread C: Predictive search with ML-lite

[15 minutes later]

**AI:** Here's what I discovered... [presents all 3]

## Integration with Existing Workflow

Can be used:
- **Standalone** - Pure exploration mode
- **Hybrid** - Use unleashed for planning, then use regular workflow for execution
- **Refinement** - Take an existing feature and "unleash" improvements

## Safety Rails

**What prevents chaos:**
1. Git branches - each thread works in isolation
2. Tests - must pass before presenting
3. Self-review - AI documents issues honestly
4. Human curation - final decision always human's

**What's removed:**
- Phase gates - no "planning must be approved before work"
- Prescriptive specs - no "must use this exact approach"
- Single solution - no "implement exactly this"

## When to Use This

**Good for:**
- "Make X better" (open-ended improvement)
- "We need Y but I don't know how" (exploration needed)
- "Current approach feels wrong" (seeking alternatives)
- "What could this enable?" (possibility space)

**Not good for:**
- "Change this CSS color to #FF0000" (trivial, no exploration needed)
- "Fix this specific bug" (defined problem, known solution space)
- "Implement this exact API spec" (no room for discovery)

## Cost Awareness

This uses more tokens than traditional workflow (3 threads * exploration).

**Estimate:** 3-5x token cost of regular workflow

**Worth it when:** The value of discovering better solutions > token cost

**Not worth it when:** Solution space is obvious/constrained

## Flags

- `--conservative-only` - Skip radical thread, only explore A+B
- `--radical-only` - Skip conservative, only explore B+C  
- `--yes` - Auto-accept first viable solution (defeats the purpose, but available)

## Output

Creates GitHub issue tagged `workflow:unleashed` with:
- Initial intent
- All exploration threads documented
- Final decision
- Merged code

---

**This is the experiment. Ship it and see what happens.**
