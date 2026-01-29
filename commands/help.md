---
description: Quick reference for WDI workflow and AI cost management
---

# /wdi:help

Context-aware help for WDI development workflows.

## Usage

```
/wdi:help              — Show all topics
/wdi:help status       — Current session & cost info
/wdi:help cost         — Cost-aware AI usage
/wdi:help models       — Model selection guidance
/wdi:help workflow     — Feature workflow phases
/wdi:help commands     — All WDI commands
/wdi:help thinking     — Thinking/reasoning toggle
```

## Behavior

Based on the topic requested, provide the relevant help section below.

---

## Topic: status

### Current Session & Cost Info

When this topic is requested, gather live data and present it.

**Step 1: Detect Environment**

```bash
# Claude Code stats
STATS_FILE="$HOME/.claude/stats-cache.json"

# Clawdbot session data
CLAWDBOT_SESSIONS="$HOME/.clawdbot/agents/*/sessions/"
```

**Step 2: Display Session Status**

```
Session Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CURRENT SESSION
  ───────────────
  Environment:  Claude Code (Max plan — flat rate)
  Model:        {detect from conversation context}
  Thinking:     {on/off if detectable, otherwise "N/A"}

  RECENT ACTIVITY (from stats-cache.json)
  ───────────────────────────────────────
  Today:     {messages} messages, {sessions} sessions, {tool_calls} tool calls
  Yesterday: {messages} messages, {sessions} sessions, {tool_calls} tool calls
  This week: {messages} messages across {sessions} sessions

  COST CONTEXT
  ────────────
  Claude Code:  Flat $200/mo Max plan — no per-token cost
  Clawdbot:     Pay-per-token (check dashboard for usage)

  QUICK ACTIONS
  ─────────────
  /wdi:help cost      — Detailed cost optimization tips
  /wdi:help models    — Model selection guidance
  /wdi:help thinking  — Thinking toggle & cost impact
```

**Step 3: Read Stats Data**

Read `~/.claude/stats-cache.json` and extract:
- Today's entry from `dailyActivity` array (match by date)
- Yesterday's entry
- Sum of last 7 days for weekly totals

If the file doesn't exist or has no data for today, show "No data yet" for that row.

**Step 4: Clawdbot Cost Estimate (if available)**

If `~/.clawdbot/agents/` exists, check for session data:

```bash
# Find today's sessions
find ~/.clawdbot/agents/*/sessions/ -name "*.jsonl" -newer /tmp/today-marker 2>/dev/null
```

If Clawdbot session data is available, add a section:

```
  CLAWDBOT USAGE (estimated)
  ──────────────────────────
  Sessions today:  {count}
  See dashboard for exact costs: http://localhost:3000/usage
```

If not available, omit this section silently.

**Step 5: Cost Optimization Tips**

Always append:

```
  OPTIMIZATION TIPS
  ─────────────────
  • Heavy coding/building → Use Claude Code (flat rate)
  • Strategic planning    → Use Clawdbot with Opus (worth the cost)
  • Quick questions       → Use Clawdbot with Sonnet (default)
  • Bulk simple tasks     → Use Clawdbot with Haiku (cheapest)
  • Thinking tokens       → Keep OFF unless debugging complex issues
```

---

## Topic: cost

### Cost-Aware AI Usage

**Two Systems, Different Billing:**

| System | Billing | Best For |
|--------|---------|----------|
| **Clawdbot** (Reid/Wren) | API pay-per-token | Planning, coordination, async work |
| **Claude Code** | Max plan (flat $200/mo) | Building, coding, execution |

**The Golden Rule:**
> Plan in Clawdbot → Build in Claude Code

Claude Code is "free" (flat rate). Use it for heavy execution work.
Clawdbot costs per token. Use it for strategic thinking, coordination.

**Clawdbot Model Tiers:**

| Alias | Model | Cost | Use When |
|-------|-------|------|----------|
| `sonnet` | Claude Sonnet 4 | $ | Default — most work |
| `opus` | Claude Opus 4.5 | $$$$$ | Deep thinking, strategy |
| `haiku` | Claude Haiku 3.5 | ¢ | Simple tasks |
| `local` | Ollama llama3.1:8b | Free | Fallback, simple tasks |

**Switching Models (in Clawdbot):**
```
/model opus     — Switch to deep thinking
/model sonnet   — Back to default
/model local    — Use local GPU (free)
```

**Trigger Phrases (auto-detected):**
- "Let's think through this" → switches to Opus
- "Help me design..." → switches to Opus
- "Back to normal" → returns to Sonnet

---

## Topic: models

### Model Selection Guide

**In Clawdbot (Dashboard/Telegram):**

| Task Type | Recommended | Command |
|-----------|-------------|---------|
| Quick questions | Sonnet (default) | — |
| Strategy/planning | Opus | `/model opus` |
| Simple lookups | Haiku | `/model haiku` |
| Offline/free | Local | `/model local` |

**In Claude Code:**
- Model is determined by your Max plan
- Opus-tier quality included
- No need to manage — just use it

**When to Escalate to Opus:**
- Architecture decisions
- Multi-step strategic planning
- Novel problems with unclear solutions
- When you need pushback/devil's advocate
- Complex debugging (multiple rounds without resolution)

**When Sonnet is Fine:**
- Execution of defined tasks
- Code following established patterns
- Summarization, organization
- Most daily Q&A

---

## Topic: workflow

### Feature Workflow Phases

```
/wdi:workflow-feature
```

| Phase | Purpose | Model Suggestion |
|-------|---------|------------------|
| **Plan** | Define scope, approach | Opus (think hard) |
| **Work** | Implement the feature | Claude Code (free) |
| **Review** | Check quality, tests | Sonnet |
| **Compound** | Parallel review agents | Haiku (many calls) |

**Key Insight:**
Planning happens in Clawdbot (Reid), building happens in Claude Code.
This splits strategic thinking (pay-per-token, use Opus when needed) from execution (flat rate, unlimited).

**Handoff Pattern:**
1. Plan with Reid in Clawdbot → "Here's the approach..."
2. Switch to Claude Code → Execute the build
3. Return to Reid → "Done, pushed. Can you review?"

### Scoped Handoff Prompts (Critical!)

**Problem:** Open-ended workflow commands cause Claude Code to proceed through ALL phases without stopping at human decision gates.

**Solution:** Use **scoped prompts** with explicit boundaries:

```
FIRST: Make sure repo is current
- git pull
- git status (confirm clean)

THEN: Execute ONLY the [specific phase]
- [Task 1]
- [Task 2]

STOP BEFORE:
- Committing
- Pushing  
- Closing the issue

REPORT BACK:
- What was implemented
- Test results
- Any decisions made
- Ready for review
```

**Human Decision Gates:**
| Gate | When | Who Decides |
|------|------|-------------|
| Plan Review | After planning | Human approves scope |
| P1/P2/P3 Triage | After code review | Human prioritizes fixes |
| Commit | Before committing | Human approves changes |
| Deploy | Before deploying | Human approves release |

**Key Insight:** Clawdbot = state machine (controls flow). Claude Code = scoped executor (does exactly what's asked, stops, reports back).

---

## Topic: commands

### All WDI Commands

**Workflow:**
- `/wdi:workflow-feature` — Full feature lifecycle
- `/wdi:workflow-feature #N` — Continue existing issue
- `/wdi:workflow-enhanced-ralph` — Quality-gated with research agents
- `/wdi:workflow-milestone` — Group related features
- `/wdi:workflow-setup` — Verify plugin dependencies
- `/wdi:triage-ideas` — Review and prioritize backlog

**Standards:**
- `/wdi:standards-new-repo` — Create new repository
- `/wdi:standards-new-subproject` — Add subproject to mono-repo
- `/wdi:standards-check` — Validate against standards
- `/wdi:standards-update` — Update standards with impact analysis
- `/wdi:standards-new-command` — Create new plugin command

**Frontend:**
- `/wdi:frontend-setup` — Install WDI design tokens

**Help:**
- `/wdi:help` — This help system
- `/wdi:help <topic>` — Topic-specific help

---

## Topic: thinking

### Thinking / Reasoning Toggle

**What It Is:**
Extended thinking generates "reasoning tokens" — the model's internal thought process before answering.

**In Clawdbot Dashboard:**
- Pink brain icon (🧠) toggles thinking ON/OFF
- ON = shows reasoning, may improve complex answers, costs more
- OFF = standard responses, cheaper

**Command (TUI/Dashboard):**
```
/think off       — No thinking tokens
/think low       — Minimal thinking  
/think medium    — Moderate thinking
/think high      — Maximum thinking
```

**Recommendations:**

| Situation | Thinking Setting |
|-----------|------------------|
| Normal chat | OFF |
| Complex debugging | ON (medium/high) |
| Simple execution | OFF |
| Strategic planning | ON (with Opus) |

**Cost Impact:**
Thinking tokens are billed. High thinking on Opus = expensive.
Keep OFF by default, enable when you need to see/improve reasoning.

**Separate from Model Choice:**
- Sonnet + thinking OFF = cheap
- Sonnet + thinking ON = moderate  
- Opus + thinking OFF = expensive
- Opus + thinking ON = most expensive

---

## Topic: all (default)

### Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│              WDI AI QUICK REFERENCE                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  WHERE TO WORK                                      │
│  ──────────────                                     │
│  Planning/Strategy  → Clawdbot (Reid)              │
│  Building/Coding    → Claude Code (free via Max)   │
│                                                     │
│  CLAWDBOT MODELS                                    │
│  ────────────────                                   │
│  /model sonnet  → Default (good + cheap)           │
│  /model opus    → Deep thinking (expensive)        │
│  /model haiku   → Quick + cheap                    │
│  /model local   → Free (Ollama)                    │
│                                                     │
│  TRIGGER PHRASES (auto-escalate to Opus)           │
│  ───────────────────────────────────────           │
│  "Let's think through this"                        │
│  "Help me design..."                               │
│  "I need your best thinking"                       │
│                                                     │
│  THINKING TOGGLE (dashboard 🧠 icon)               │
│  ───────────────────────────────────               │
│  OFF = standard (cheaper)                          │
│  ON  = shows reasoning (costs more)                │
│                                                     │
│  HELP TOPICS                                        │
│  ────────────                                       │
│  /wdi:help status    — Session info & costs        │
│  /wdi:help cost      — Billing & cost tips         │
│  /wdi:help models    — When to use which model     │
│  /wdi:help workflow  — Feature workflow phases     │
│  /wdi:help thinking  — Reasoning toggle explained  │
│  /wdi:help commands  — All WDI commands            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Implementation Note

When the user runs `/wdi:help <topic>`, output ONLY the relevant topic section.
When they run `/wdi:help` with no topic, show the "all" quick reference card.
