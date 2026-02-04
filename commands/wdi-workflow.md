# /wdi:workflow

**Unified feature workflow — exploration by default, patterns when detected**

## Usage

```bash
/wdi:workflow                     # Start new (interactive)
/wdi:workflow #45                 # Continue existing issue
/wdi:workflow --skip-explore      # Skip 3-lens exploration (trivial fixes)
/wdi:workflow --headless          # No prompts, agent mode
/wdi:workflow --stop-after=plan   # Stop after phase
/wdi:workflow --idea "text"       # Quick capture
```

## Philosophy

Traditional workflow was too rigid. Unleashed was too separate. This is both.

**Default:** 3-lens exploration (Conservative/Balanced/Radical) before building.  
**Escape hatch:** `--skip-explore` for trivial fixes where exploration is overkill.

## Phases

```
Learnings → [Pattern Detection] → Explore → Curate → Work → Review → Compound
                                     ↑
                              (skip with --skip-explore)
```

---

## Quick Reference

| Flag | Purpose |
|------|---------|
| `--skip-explore` | Direct to work (no 3-lens exploration) |
| `--headless` | No prompts, bail on ambiguity |
| `--stop-after=PHASE` | Stop after completing PHASE |
| `--resume-from=PHASE` | Start from PHASE |
| `--idea "text"` | Quick idea capture |
| `--yes` | Auto-continue through phases |
| `#N` | Continue issue N |

**Phase names:** `learnings`, `explore`, `curate`, `work`, `review`, `compound`

---

## Phase 1: Pre-flight

Quick validation.

```
Pre-flight
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Repository: {type}
✓ Branch: {branch}
✓ Uncommitted: {count} files
```

---

## Phase 2: Learnings Search

Surface relevant prior work before planning.

```bash
# Search local and central learnings
grep -r -l -i "{keywords}" docs/solutions/
grep -r -l -i "{keywords}" ~/github/whitedoeinn/learnings/curated/
```

Update issue with findings or "no prior art found."

---

## Phase 3: Pattern Detection

**Currently hardcoded. Will generalize when we have 3+ patterns.**

### Spec-Driven Detection

```bash
if [ -f "specs/flows.json" ] || [ -f "specs/sdd.json" ]; then
  PATTERN="spec-driven"
fi
```

**If spec-driven detected:**

```
Pattern Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ spec-driven (specs/flows.json found)

Injections:
  • Before Work: Validate specs (npm run validate:specs)
  • After Work: Check story coverage (npm run coverage:stories)
  • Review: Additional spec-alignment criteria
```

Post pattern detection to issue as comment.

---

## Phase 4: Explore (3 Lenses)

**Skip this phase with `--skip-explore`**

### Intent Capture

If not already in issue:
- What problem are you solving? (one sentence)
- What constraints matter?
- What's off-limits?

### Sequential Exploration

Work through three lenses, one at a time:

**Lens A: Conservative**
- Minimal changes to existing patterns
- Ask: "What's the simplest thing that could work?"

**Lens B: Balanced**
- Mix of new and existing approaches
- Ask: "What's the best solution if I'm not anchored to current patterns?"

**Lens C: Radical**
- Fresh approach from first principles
- Ask: "If I built this from scratch, what would I do?"

### Rules

- **No implementation code during exploration.** Design and analyze only.
- **Guard against premature convergence.** If A works, still explore B and C fully.
- **Test your thinking.** Run existing tests to check for breakage.

### Present Discoveries

Show all three approaches:

```markdown
## Lens A: [Name]
**Approach:** [Strategy]
**Discoveries:** [Unexpected findings]
**Tradeoffs:** [Costs/limitations]
**Quality:** [Test results, known issues]
```

**⚠️ HARD GATE: Stop here. Do not proceed until human curates.**

---

## Phase 5: Curate

Human selects:
- "Ship A"
- "Ship B + C's idea about X"
- "None of these, explore Y further"
- "A works but polish the naming"

In `--headless` mode: Error if multiple viable approaches. Agent can't curate.

---

## Phase 6: Work

### Pattern Injections (Before)

If spec-driven:
```bash
npm run validate:specs
npm run validate:routes
```
**Blocking.** Fix spec issues before proceeding.

### Do the Work

Implement the curated approach (or direct implementation if `--skip-explore`).

### Pattern Injections (After)

If spec-driven:
```bash
npm run coverage:stories
```
**Non-blocking.** Warning only.

### Run Tests

```bash
npm test  # or appropriate test command
```

---

## Phase 7: Review

Delegate to compound-engineering:

```
/compound-engineering:workflows:review
```

### Pattern-Specific Review Criteria

If spec-driven, add to review prompts:
- Do all new routes have corresponding flow specs?
- Are user stories testable as written?
- Does implementation match spec intent?

### Handle Findings

- **P1 (Blocking):** Fix before continuing. No exceptions.
- **P2/P3:** Create issues for later, don't block.

---

## Phase 8: Compound

Capture learnings from the entire cycle.

Delegate to compound-engineering:

```
/compound-engineering:workflows:compound
```

### Issue Close Comment

```markdown
## Complete

**Approach:** {Which lens, or "direct implementation"}
**Key discoveries:** {What we learned across exploration}
**Review findings:** {What was fixed}
**Learnings:** `docs/solutions/{category}/{slug}.md`
```

---

## Pattern: spec-driven

**Detected by:** `specs/flows.json` or `specs/sdd.json` exists

**Injects:**

| When | What | Blocking |
|------|------|----------|
| Before Work | `npm run validate:specs && npm run validate:routes` | Yes |
| After Work | `npm run coverage:stories` | No (warning) |
| Review | Additional spec-alignment criteria | — |

**Review criteria added:**
- Do all new routes have corresponding flow specs?
- Are user stories testable as written?
- Does implementation match spec intent?

---

## When to Use --skip-explore

**Use exploration (default) when:**
- "Make X better" (open-ended)
- "We need Y but not sure how"
- "Current approach feels wrong"
- Non-trivial features

**Skip exploration when:**
- "Fix this typo"
- "Change this color to #FF0000"  
- "Add this exact field to the form"
- Bug fixes with obvious solutions

---

## Headless Mode

For agent execution. No prompts, structured errors.

```bash
/wdi:workflow #45 --headless
/wdi:workflow #45 --headless --skip-explore
/wdi:workflow #45 --headless --stop-after=work
```

### Bail Conditions

In headless, ERROR and stop if:
- Can't determine phase from labels
- Multiple viable approaches after exploration (can't curate)
- Missing required context
- P1 review findings

### Error Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ERROR: [reason]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Issue:  #{number}
Phase:  {current}
Suggestion: [fix]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Issue Labels

| Label | Meaning |
|-------|---------|
| `idea` | Captured, not started |
| `phase:exploring` | In 3-lens exploration |
| `phase:curating` | Waiting for human selection |
| `phase:working` | Building |
| `phase:reviewing` | In review |
| `phase:compounding` | Capturing learnings |

---

## Migration

This replaces:
- `/wdi:workflow-feature` — use `/wdi:workflow --skip-explore` for equivalent
- `/wdi:workflow-unleashed` — this IS unleashed, as default

Old commands will warn and redirect.

---

## Cost Awareness

Exploration costs 3-10x more tokens than direct implementation.

**Worth it when:** Discovery value > token cost  
**Not worth it when:** Solution is obvious

Use `--skip-explore` to save tokens on trivial work.

---

## Future: More Patterns

When we have 3+ patterns, we'll generalize detection into a pluggable system.
For now, spec-driven is hardcoded. YAGNI.

Planned patterns:
- `plugin` — detects `.claude-plugin/` or `openclaw.plugin.json`
- `library` — detects package with no app, just exports
- UX patterns (warm-craft, clawd-neon) — requires human input

---

**See also:** 
- `docs/UNLEASHED.md` — full exploration methodology
- `docs/PATTERN-DETECTION-SPEC.md` — future pattern system spec
