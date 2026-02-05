# discovery-capture

**Behavior guide for documenting unexpected findings during exploration**

## When to Invoke

Use this when you (the AI) encounter something you didn't expect:
- Unexpected benefit or performance characteristic
- Unanticipated problem or blocker
- Novel approach that emerged during exploration
- Pattern that could generalize beyond current problem
- Tradeoff that wasn't obvious upfront

## What To Do

1. **Document the discovery immediately** — don't wait until the end

2. **Use this format in the thread documentation:**
   ```markdown
   ### 🔍 Discovery: [Short name]
   **Expected:** [What you thought would happen]
   **Actual:** [What actually happened]
   **Impact:** [Why this matters for the current problem]
   **Generalization:** [Could this apply elsewhere? If so, where?]
   ```

3. **Assess whether to pivot:**
   - Does this discovery suggest a better direction within the current lens?
   - Should you explore this finding further?
   - Does this invalidate your current approach?

4. **Flag for human attention:**
   - Mark discoveries with `🔍 DISCOVERY` in the thread
   - Highlight in final presentation
   - Explain significance concisely

## Examples

**Performance discovery:**
> **Expected:** Caching would speed up search by 2x
> **Actual:** Caching sped it up 10x AND reduced memory usage
> **Impact:** Could handle 10K tasks instead of 1K
> **Generalization:** This caching pattern could work for other list views

**Blocker discovery:**
> **Expected:** Virtual scrolling would improve performance
> **Actual:** Virtual scrolling breaks screen reader accessibility
> **Impact:** Can't ship without accessibility fix — potential blocker for this lens
> **Generalization:** Need accessibility testing early in exploration, not just at review

**Over-engineering discovery:**
> **Expected:** Building custom search index would be necessary
> **Actual:** Browser's built-in APIs are faster and handle i18n
> **Impact:** Entire approach was over-engineering the solution
> **Generalization:** Check platform capabilities before building custom solutions

## What's NOT a Discovery

Normal implementation details aren't discoveries. Expected behavior isn't a discovery.

**Discovery = something you didn't know before you tried it.**

If you knew it would work this way, document it normally. Don't dilute real discoveries with obvious observations.

## This Is a Behavior Guide

This skill tells you how to think during exploration. It's not executable code. It's your lab notebook discipline — capture findings while they're fresh, assess their impact, and flag what matters.

---

**Status:** Behavior guide for exploration workflow
