# Unleashed Mode - AI Exploration Workflow

**Ship date:** 2026-01-31  
**Status:** Experimental  
**Philosophy:** Eliminate human limiting beliefs from AI-assisted development

## The Problem

Traditional AI-assisted development:
1. Human imagines requirements
2. AI implements within those constraints  
3. Human reviews against original vision
4. Deviations = mistakes

**Limitation:** You can only get what you could imagine.

## The Solution

Unleashed workflow:
1. Human defines goals + constraints
2. AI explores solution space (multiple approaches)
3. AI discovers unexpected possibilities
4. Human curates discoveries (not requirements)
5. Refinement = polishing jewels, not fixing mistakes

**Advantage:** You get solutions that exceed your imagination.

## How It Works

### Command

```bash
/wdi:workflow-unleashed
```

### Process

1. **Minimal Intent Capture**
   - Problem (one sentence)
   - Constraints (what matters)
   - Off-limits (what NOT to do)

2. **Parallel Exploration** (3 threads)
   - Conservative (low risk, high compatibility)
   - Balanced (mix of new + existing)
   - Radical (maximum innovation)

3. **Self-Discovery**
   - AI tries approaches
   - Finds unexpected benefits/problems
   - Documents honestly
   - Pivots when needed

4. **Present All Options**
   - Show all 3 threads
   - Highlight discoveries
   - Explain tradeoffs
   - Recommend nothing (human curates)

5. **Human Curation**
   - Pick one
   - Combine approaches
   - Keep discoveries for later
   - Request refinements

### Example

**Traditional:**
```
Human: Add search bar to task list
       - Text input in header
       - Filter on title and description
       - Show count of results
       
AI: [implements exactly that]
```

**Unleashed:**
```
Human: Search is too slow with 1000+ tasks

AI: [explores 3 approaches]
    Thread A: Indexes + debouncing → 10x faster (unexpected!)
    Thread B: Virtual scroll → breaks accessibility (discovery)
    Thread C: Predictive search → users love demo (insight)
    
Human: Ship A. C's idea is great - save for later.
```

## Comparison: Constrained vs. Unleashed

| Aspect | Constrained (`/wdi:workflow-feature`) | Unleashed (`/wdi:workflow-unleashed`) |
|--------|--------------------------------------|--------------------------------------|
| **Input** | Detailed requirements | High-level goal + constraints |
| **Process** | Plan → Work → Review → Compound | Explore → Discover → Present → Curate |
| **Phases** | Explicit, gated | Fluid, self-organized |
| **Solutions** | One (as specified) | Multiple (discovered) |
| **Approval** | Each phase | Final outcome only |
| **Deviations** | Mistakes to fix | Discoveries to evaluate |
| **Output** | Meets spec | Exceeds imagination (hopefully) |
| **Cost** | Lower (1x tokens) | Higher (3-5x tokens) |
| **Best for** | Known solutions | Unknown possibilities |

## When To Use Each

### Use Constrained (/wdi:workflow-feature)

- Solution space is obvious
- Requirements are clear
- Low uncertainty
- Budget-constrained
- Quick iteration needed

**Example:** "Add dark mode toggle to settings page"

### Use Unleashed (/wdi:workflow-unleashed)

- Solution space unclear
- "Make it better" goal
- High uncertainty
- Discovery more valuable than speed
- Willing to invest in exploration

**Example:** "Onboarding feels clunky, not sure why"

## Principles

### 1. AI Self-Discovery

AI doesn't ask "should I try X?" - it tries X, documents what happened, presents findings.

**Traditional:**
```
AI: Should I use approach A or B?
Human: Try A
AI: [implements A]
```

**Unleashed:**
```
AI: [tries both A and B]
AI: Here's what I learned about A and B...
Human: [curates discoveries]
```

### 2. Honest Documentation

AI documents problems it finds, even in its own solutions.

**Don't hide issues.** Tradeoffs are information, not failures.

### 3. Human as Curator, Not Constraint

Human's job: recognize value, combine ideas, choose directions.

**Not:** "Did you do what I said?"  
**Instead:** "Which of these discoveries is most valuable?"

### 4. Dunning-Kruger Aware

Explicitly acknowledges: human requirements are limited by human knowledge.

The point is to discover what you don't know.

### 5. Refinement ≠ Failure

If AI ships Thread B then realizes Thread C had a better idea - refining to incorporate that isn't technical debt, it's **polishing the jewel**.

## Integration with Existing Workflows

Can be combined:

1. **Unleashed for planning** → Discover approaches → Curate → Execute with constrained workflow
2. **Constrained for feature** → Ship → Unleashed for enhancement → Discover improvements
3. **Hybrid:** Start unleashed, switch to constrained when direction clear

## Safety Rails

**What prevents chaos:**
- Git branches (isolation)
- Tests must pass
- Human makes final decision
- Self-review catches issues

**What's removed:**
- Phase-gate approvals
- Prescriptive specifications
- Single-solution constraint

## Cost Awareness

**Unleashed is more expensive** (3-5x tokens).

Worth it when:
- Discovery value > token cost
- Uncertainty is high
- Innovation needed

Not worth it when:
- Solution obvious
- Budget tight
- Speed critical

## Learning System

AI learns from each unleashed workflow:
- What discoveries were valuable
- What human preferences emerge
- What patterns succeed/fail

Stored in `.claude/learnings/explorations.jsonl`

After 10+ explorations, AI generates summary of learnings.

## Example Outcomes

**What unleashed might discover:**

- "Approach A is 10x faster than expected (not 2x)"
- "Users love predictive feature in demo (UX validation)"
- "This breaks accessibility (critical blocker)"
- "Simple approach enables future capability X"
- "Complex approach solves problem Y you didn't ask about"

**Human curates:**

- Keep A's speed
- Use C's UX insight
- Fix B's accessibility
- Defer Y for later

Result: Better than any single imagined solution.

## Meta-Learning

Over time, this workflow helps humans:
- Recognize when their constraints are too tight
- Trust AI exploration
- Value unexpected discoveries
- Think in terms of curation vs. specification

**The goal:** Make better things by getting out of your own way.

---

**Experiment status:** Active  
**Feedback:** Expected and welcomed  
**Philosophy:** Ship it and see what happens
