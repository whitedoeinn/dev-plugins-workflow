# discovery-capture

**Auto-invoked when AI discovers something unexpected during unleashed workflow**

## Trigger Patterns

Invoke this skill when you (the AI) encounter:
- Unexpected benefit
- Unanticipated problem
- Novel approach that emerged
- Pattern that could generalize
- Tradeoff that wasn't obvious upfront

## What To Do

1. **Document the discovery immediately**
   - What you expected
   - What actually happened
   - Why it matters

2. **Add to thread documentation**
   ```markdown
   ### Discovery: [Short name]
   **Expected:** [What you thought would happen]
   **Actual:** [What actually happened]
   **Impact:** [Why this matters]
   **Generalization:** [Could this apply elsewhere?]
   ```

3. **Consider pivot**
   - Does this discovery suggest a better direction?
   - Should you explore this further?
   - Does this invalidate your current approach?

4. **Flag for human attention**
   - Mark discoveries as `🔍 DISCOVERY` in the thread
   - Highlight in final presentation
   - Explain why you think it's significant

## Examples of Discoveries

**Good discovery:**
> **Expected:** Caching would speed up search by 2x  
> **Actual:** Caching sped it up 10x AND reduced memory usage  
> **Impact:** We could handle 10K tasks instead of 1K  
> **Generalization:** This caching pattern could work for other list views

**Important discovery:**
> **Expected:** Virtual scrolling would improve performance  
> **Actual:** Virtual scrolling breaks screen reader accessibility  
> **Impact:** Can't ship this without accessibility fix  
> **Generalization:** Need accessibility testing in exploration phase

**Pivot-worthy discovery:**
> **Expected:** Building custom search index  
> **Actual:** Browser's built-in search APIs are faster and handle i18n  
> **Impact:** Entire approach was over-engineering  
> **Generalization:** Check browser APIs before building custom solutions

## Don't Over-Document

Not everything is a discovery. Normal implementation details aren't discoveries.

**Discovery = something you didn't know before you tried it**

If you knew it would work this way, it's not a discovery. Just document it normally.

## Integration

This skill is passive - you invoke it when YOU (the AI) realize you've discovered something. It's not triggered by user input.

Think of it as your internal "lab notebook" during exploration.

---

**Ship it and see what you discover.**
