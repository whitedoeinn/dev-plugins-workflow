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

### Parallel Exploration (Cost Optimized)

**Spawn 3 parallel subagents** — each runs on DeepSeek (cheap), not Opus:

```
sessions_spawn(task: "Explore Lens A (Conservative) for: [problem]. 
  Minimal changes to existing patterns. 
  Ask: What's the simplest thing that could work?
  Return: Approach, discoveries, tradeoffs, risks.
  NO implementation code — design only.",
  label: "lens-a")

sessions_spawn(task: "Explore Lens B (Balanced) for: [problem].
  Mix of new and existing approaches.
  Ask: What's best if not anchored to current patterns?
  Return: Approach, discoveries, tradeoffs, risks.
  NO implementation code — design only.",
  label: "lens-b")

sessions_spawn(task: "Explore Lens C (Radical) for: [problem].
  Fresh approach from first principles.
  Ask: If built from scratch, what would I do?
  Return: Approach, discoveries, tradeoffs, risks.
  NO implementation code — design only.",
  label: "lens-c")
```

Each subagent:
- Runs on `agents.defaults.subagents.model` (DeepSeek)
- Works in isolation
- Returns structured findings

### Collect and Present

Wait for all 3 subagents to complete. Synthesize their findings:

```markdown
## Lens A: [Name]
**Approach:** [Strategy]
**Discoveries:** [Unexpected findings]
**Tradeoffs:** [Costs/limitations]

## Lens B: [Name]
...

## Lens C: [Name]
...
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

### Do the Work (via Claude Code)

**Use Claude Code for implementation** — runs on Max subscription (flat rate), not API:

```bash
# Create tmux session in target repo
tmux new-session -d -s workflow-work -c /path/to/repo

# Launch Claude Code with the curated approach
tmux send-keys -t workflow-work "claude 'Implement [curated approach]. Context: [issue link, constraints, etc.]'" Enter

# Monitor progress
tmux capture-pane -p -t workflow-work -S -50

# Send Enter to continue when prompted
tmux send-keys -t workflow-work Enter
```

**Why Claude Code:**
- Flat-rate Max subscription vs per-token API
- Better at multi-file refactoring
- Has MCP plugins for visual feedback
- Cost: ~$0 vs $5-15 for heavy generation

**Fallback:** If Claude Code unavailable or task is trivial, implement directly.

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

## Phase 7: Review (Parallel Subagents)

**Spawn parallel review agents** — each runs on DeepSeek:

```
sessions_spawn(task: "Review for ARCHITECTURE: [diff/files].
  Check: separation of concerns, abstractions, patterns.
  Return: P1/P2/P3 findings with specific line references.",
  label: "review-arch")

sessions_spawn(task: "Review for PERFORMANCE: [diff/files].
  Check: O(n) vs O(1), memoization, unnecessary renders.
  Return: P1/P2/P3 findings with specific line references.",
  label: "review-perf")

sessions_spawn(task: "Review for ERROR HANDLING: [diff/files].
  Check: null safety, error boundaries, edge cases.
  Return: P1/P2/P3 findings with specific line references.",
  label: "review-errors")

sessions_spawn(task: "Review for TESTING: [diff/files].
  Check: test coverage, edge cases, assertions.
  Return: P1/P2/P3 findings with specific line references.",
  label: "review-testing")
```

### Pattern-Specific Review Criteria

If spec-driven, add additional reviewer:
```
sessions_spawn(task: "Review for SPEC ALIGNMENT: [diff/files].
  Check: Do new routes have flow specs? Stories testable? Implementation matches spec?
  Return: P1/P2/P3 findings.",
  label: "review-specs")
```

### Collect and Synthesize

Wait for all reviewers. Dedupe overlapping findings. Prioritize:

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

## Cost Optimization

This workflow is designed to minimize API costs by routing work appropriately:

| Phase | Model/Tool | Why |
|-------|------------|-----|
| Orchestration | Opus (main) | Needs intelligence for coordination |
| Explore (3 lenses) | Subagents → DeepSeek | Parallel, cheaper |
| Curate | Opus (main) | Human interaction |
| Work (coding) | Claude Code via tmux | Flat-rate Max subscription |
| Review | Subagents → DeepSeek | Parallel, cheaper |
| Compound | Opus (main) | Synthesis |

**Key principle:** Opus orchestrates, cheap models + Claude Code do the heavy lifting.

Use `--skip-explore` to skip exploration on trivial work.

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
