# exploration-reflection

**AI learns from exploration outcomes to improve future explorations**

## Purpose

After each unleashed workflow completes (human makes decision), reflect on:
- What approaches worked?
- What discoveries were valuable?
- What explorations were dead ends?
- What patterns are emerging?

## When To Reflect

Auto-invoke after:
1. Human makes final decision in curation
2. Code is merged/shipped
3. Issue is closed

## What To Capture

Store in `.claude/learnings/explorations.jsonl` (append-only):

```jsonl
{
  "timestamp": "2026-01-31T20:30:00Z",
  "problem": "search performance with 1000+ tasks",
  "threads": [
    {
      "id": "A",
      "approach": "index + cache",
      "outcome": "selected",
      "key_discovery": "10x improvement, not 2x",
      "why_successful": "simple, fast, no new dependencies"
    },
    {
      "id": "B", 
      "approach": "virtual scroll",
      "outcome": "rejected",
      "key_discovery": "breaks screen reader accessibility",
      "why_unsuccessful": "didn't test accessibility during exploration"
    },
    {
      "id": "C",
      "approach": "predictive search ML",
      "outcome": "partial - idea kept for later",
      "key_discovery": "users love it in demo",
      "why_deferred": "too complex for current need"
    }
  ],
  "decision_factors": ["simplicity", "performance", "accessibility"],
  "human_feedback": "A was perfect. C's UX ideas are great - let's revisit when we have more capacity",
  "lessons": [
    "Test accessibility during exploration, not after",
    "Demos can validate UX ideas even if implementation is complex",
    "10x improvements happen - don't assume linear gains"
  ]
}
```

## Pattern Recognition

After 5+ explorations, start noticing patterns:

**Good patterns to detect:**
- Human consistently values X over Y
- Discoveries about Z are often valuable
- Approach type A succeeds more than type B
- Certain tradeoffs are never acceptable

**Don't Over-Optimize:**
- Don't become predictable
- Don't stop exploring radical ideas
- Patterns inform, they don't constrain

## Learning From Rejections

**When all threads are rejected:**
- What was the actual problem vs. what was stated?
- What constraint was missed?
- What should have been explored instead?

Document this honestly. Rejection is valuable data.

## Future-Facing Insights

Note things like:
- "Thread C's approach would work better for [different problem]"
- "This discovery about X could apply to Y feature"  
- "Pattern Z keeps emerging - might be worth a standalone solution"

## Share Learnings

Periodically (after 10 explorations), generate summary:

```markdown
## Exploration Learnings Summary

**Successful patterns:**
1. [Pattern]: worked N times because [reason]
2. [Pattern]: worked M times because [reason]

**Common pitfalls:**
1. [Pitfall]: failed N times because [reason]

**Recurring discoveries:**
1. [Discovery type]: emerged M times, suggests [insight]

**Human preferences detected:**
1. Values [X] over [Y] (N cases)
2. Accepts [tradeoff A] but not [tradeoff B] (M cases)
```

Show this to human, ask: "Does this match your thinking? Anything I'm missing?"

## Privacy/Scope

Learnings are **per-project**. Don't cross-apply across different repos unless explicitly similar domains.

Each project has its own `.claude/learnings/explorations.jsonl`

## Integration

This is passive. AI invokes it after human makes decision. Human doesn't trigger it directly.

Think of it as the AI's "what did I learn today?" journal.

---

**Get smarter with every exploration.**
