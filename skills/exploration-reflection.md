# exploration-reflection

**Behavior guide for learning from exploration outcomes**

## Purpose

After each unleashed exploration completes (human makes a curation decision), reflect on what happened:
- What approaches worked and why?
- What discoveries were valuable?
- What explorations were dead ends?
- What would you do differently?

## When to Reflect

After:
1. Human makes final curation decision
2. Chosen approach is implemented/shipped
3. Issue is closed

## What to Capture

If `.claude/learnings/explorations.jsonl` exists, append a reflection:

```jsonl
{
  "timestamp": "2026-01-31T20:30:00Z",
  "problem": "search performance with 1000+ tasks",
  "lenses": [
    {
      "id": "conservative",
      "approach": "index + cache",
      "outcome": "selected",
      "key_discovery": "10x improvement, not 2x",
      "why": "simple, fast, no new dependencies"
    },
    {
      "id": "balanced",
      "approach": "virtual scroll",
      "outcome": "rejected",
      "key_discovery": "breaks screen reader accessibility",
      "lesson": "test accessibility during exploration, not after"
    },
    {
      "id": "radical",
      "approach": "predictive search",
      "outcome": "deferred",
      "key_discovery": "users love it in demo",
      "lesson": "demos validate UX ideas even when implementation is complex"
    }
  ],
  "decision_factors": ["simplicity", "performance", "accessibility"],
  "lessons": [
    "Test accessibility during exploration, not after",
    "10x improvements happen — don't assume linear gains",
    "Demos can validate UX cheaply"
  ]
}
```

If the file doesn't exist yet, create it. This is a future enhancement — the learning system isn't automated, but manual reflection entries are still valuable.

## What to Reflect On

### After successful explorations:
- Why did the human choose this approach?
- What made the discoveries valuable?
- Were there signals early that this lens would win?

### After rejections:
- Was the actual problem different from what was stated?
- What constraint was missed in intent capture?
- What should have been explored differently?

### After all approaches fail:
- Were the constraints too tight?
- Was the problem framed wrong?
- What information was missing?

**Rejection and failure are valuable data.** Document them honestly.

## Pattern Recognition (Future Enhancement)

After 5+ explorations, patterns should emerge:
- Human consistently values X over Y
- Certain discoveries are reliably valuable
- Specific tradeoffs are never acceptable

**Caution:** Don't let pattern recognition narrow exploration. Patterns inform, they don't constrain. The point of unleashed is to keep discovering.

## Future-Facing Notes

Capture insights like:
- "Radical approach would work better for [different problem]"
- "This discovery about X could apply to Y"
- "Pattern Z keeps emerging — might deserve its own solution"

These notes are for future explorations, not current implementation.

## Scope

Learnings are per-project. Don't cross-apply across repos unless domains are explicitly similar.

## This Is a Behavior Guide

This isn't automated. It's a discipline — after each exploration, take a few minutes to capture what you learned. Future-you will thank present-you.

---

**Status:** Behavior guide for unleashed methodology  
**Note:** The automated learning system (pattern detection, summaries) is a future enhancement, not current functionality.
