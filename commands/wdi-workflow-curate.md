# /wdi:workflow-curate

**Help human curate discoveries from unleashed exploration**

## Purpose

After AI has explored multiple solution threads, help the human:
- Understand what was discovered
- Compare approaches objectively
- Identify combinations/hybrids
- Make informed decisions

## Interactive Curation

When human runs this command (typically auto-invoked after unleashed workflow presents results):

### 1. Show Summary Matrix

```
Thread   | Approach        | Key Discovery          | Passes Tests | Complexity | Enables
---------|-----------------|------------------------|--------------|------------|--------
A        | Index + cache   | 10x faster, not 2x     | ✅           | Low        | Pagination
B        | Virtual scroll  | Breaks accessibility   | ⚠️           | Medium     | Infinite lists
C        | Predictive      | Users love it in demo  | ✅           | High       | Smart features
```

### 2. Ask Curation Questions

**Question 1:** "Which approach resonates with your intuition?"
- Not asking for decision yet
- Just feeling out initial reaction

**Question 2:** "Any discoveries surprise you?"
- Highlight unexpected findings
- Explain why they matter

**Question 3:** "Do you want to combine approaches?"
- Thread A's performance + Thread C's UX?
- Thread B's architecture + Thread A's simplicity?

**Question 4:** "What tradeoffs are you willing to accept?"
- Speed vs complexity?
- Innovation vs stability?
- Now vs later?

### 3. Offer Hybrid Paths

Based on answers, suggest combinations:

```
## Hybrid Option: A + C's predictive hint
- Use Thread A's caching for speed
- Add Thread C's predictive text hint (without full ML)
- Complexity: Low → Medium
- Benefits: Fast + smart, without heavy ML investment
```

### 4. Technical Deep-Dive (If Requested)

Human can ask:
- "Show me Thread B's implementation"
- "Why did C fail accessibility?"
- "What's the performance difference between A and C?"

Provide detailed technical answers, but don't lead with them. Lead with outcomes.

### 5. Decision Support

Help human choose by:
- Identifying clear winners (if they exist)
- Highlighting irreconcilable tradeoffs
- Suggesting phased approaches ("Ship A now, explore C later")
- Noting what's reversible vs. locked-in

### 6. Execution Path

Once decision made:
- Create clear implementation plan
- Merge/combine code as needed
- Run final test suite
- Document chosen approach + reasons
- Update issue with decision

## Example Flow

```
Human: /wdi:workflow-curate

AI: I explored 3 approaches to faster search...

[Shows matrix]

AI: Thread A discovered that caching gives 10x improvement, not 2x. 
    Thread C discovered users love predictive search in demo.
    Thread B has accessibility issues.

AI: Which approach resonates with you?