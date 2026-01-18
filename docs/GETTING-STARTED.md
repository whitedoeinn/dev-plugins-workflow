# Getting Started with WDI Workflows

This guide gets you productive in 15 minutes. It explains what commands to use, when, and why we built things this way.

**Required for all whitedoeinn projects.** This plugin standardizes how we build features, manage issues, and maintain code quality.

## Prerequisites

- Claude Code CLI installed (`claude --version`)
- `gh` CLI authenticated (`gh auth login`)

## Installation

Install via marketplace (run inside Claude Code):

```
/plugin marketplace add https://github.com/whitedoeinn/dev-plugins-workflow
/plugin install wdi
```

This also installs `compound-engineering` as a dependency.

### Verify Installation

```
/wdi:workflows-setup
```

This checks that all dependencies are configured correctly.

### Update to Latest Version

```
/plugin update wdi
```

Run this periodically to get new features and fixes.

---

## The 30-Second Mental Model

```
You have an idea
       ↓
Capture it → Shape it → Build it → Ship it
   --idea      issues     workflow    commit
```

**Two plugins work together:**
- **compound-engineering** — The engine (research agents, review agents, workflow primitives)
- **wdi** — The driver (orchestrates compound-engineering for our workflow)

You interact with wdi commands. They call compound-engineering under the hood.

---

## Which Command Do I Use?

```
What do you have right now?
│
├─► Vague idea, not ready to build
│   └─► /wdi:workflows-feature --idea
│
├─► Clear idea, ready to plan and build
│   └─► /wdi:workflows-feature
│
├─► Existing idea issue to promote
│   └─► /wdi:workflows-feature --promote #123
│
├─► Tiny fix, no tracking needed
│   └─► Just ask Claude, then "commit these changes"
│
└─► Exploration, no implementation
    └─► Just ask Claude questions
```

---

## Design Decisions: Why We Built It This Way

### Why wdi on top of compound-engineering?

**compound-engineering** is powerful but generic. It doesn't know:
- Our GitHub issue conventions
- Our feature spec format
- Our quality gates preferences
- When to use which agents

**wdi** encodes our decisions so you don't have to remember them.

### Why GitHub issues + feature specs (hybrid)?

| Approach | Tradeoff |
|----------|----------|
| GitHub issues only | Great for tracking, poor for structured specs |
| Markdown specs only | Great for structure, invisible to GitHub |
| **Hybrid** | Issues for tracking/visibility, specs for structure |

We use **issues for lifecycle** (status labels, comments, closing) and **specs for execution** (tasks, quality gates, context).

See: [#30](https://github.com/whitedoeinn/dev-plugins-workflow/issues/30), [#21](https://github.com/whitedoeinn/dev-plugins-workflow/issues/21)

### Why the idea → shape → promote flow?

Ideas captured in the moment are rarely implementation-ready. The flow:

1. **Capture** (`--idea`) — Get it out of your head before you forget
2. **Shape** (issue comments) — Refine over time, no pressure
3. **Promote** (`--promote #123`) — Convert to spec when ready

This separates "having ideas" from "building things."

See: [#30](https://github.com/whitedoeinn/dev-plugins-workflow/issues/30)

### Why work directly on main?

We currently commit directly to main with quality gates instead of using feature branches. This works because:
- Quality gates (tests, auto-docs, changelog) protect main
- Simpler workflow with less overhead
- Appropriate for current team scale

Branching is being evaluated in [#44](https://github.com/whitedoeinn/dev-plugins-workflow/issues/44).

### Why the commit skill instead of raw git?

The commit skill runs quality gates:
1. Tests (catches breaks before commit)
2. Auto-docs sync (keeps documentation current when commands/skills change)
3. Changelog update (keeps history current)

Raw `git commit` skips all of this.

### What is auto-docs?

This plugin automatically keeps documentation in sync with code. When you add or modify commands/skills, the commit skill detects this and updates CLAUDE.md and README.md tables automatically.

**Two ways it triggers:**
1. **Automatic** - Commit skill detects staged command/skill files and syncs docs
2. **Manual** - Say "update the docs" to run drift detection

For details on how it works and how to customize, see [docs/auto-docs.md](auto-docs.md).

---

## Your First Feature (Walkthrough)

Let's add a feature to this repo. Follow along:

### 1. Start the workflow

```
/wdi:workflows-feature
```

Claude will ask:
- **What type of work?** → Select "Enhancement"
- **How much research?** → Select "Light Research"
- **Describe it:** → "Add a troubleshooting entry for plugin not loading"

### 2. Watch the phases

| Phase | What Happens | Your Action |
|-------|--------------|-------------|
| Pre-flight | Checks repo status | Wait |
| Research | Scans codebase | Wait |
| Plan | Creates issue + spec | Review, approve |
| Work | Implements changes | Watch (or help) |
| Review | Runs quality gates | Fix or acknowledge |
| Compound | Merges, updates changelog | Confirm |

### 3. Each phase pauses for approval

You'll see prompts like:
```
Continue to work phase? (y)es, (e)dit plan, (a)bort:
```

Type `y` to continue, `e` to edit, `a` to stop.

### 4. End with commit

When work completes:
```
Ready to commit - say "commit these changes"
```

Type: `commit these changes`

The skill handles the rest.

---

## Common Gotchas

### "Command not found"

Restart Claude Code after plugin installation. Commands load on startup.

### "gh not authenticated"

Run `gh auth login` and follow prompts.

---

## Quick Reference

| Task | Command |
|------|---------|
| Capture idea | `/wdi:workflows-feature --idea` |
| Full workflow | `/wdi:workflows-feature` |
| Plan only | `/wdi:workflows-feature --plan` |
| Promote idea | `/wdi:workflows-feature --promote #123` |
| Commit changes | "commit these changes" |
| Check standards | `/wdi:standards-check` |
| New repo | `/wdi:standards-new-repo` |

---

## Going Deeper

| Topic | Document |
|-------|----------|
| System architecture | [docs/architecture.md](architecture.md) |
| Auto-docs capability | [docs/auto-docs.md](auto-docs.md) |
| Branch naming | [docs/drafts/BRANCH-NAMING.md](drafts/BRANCH-NAMING.md) *(draft - see #44)* |
| Commit conventions | [docs/standards/COMMIT-STANDARDS.md](standards/COMMIT-STANDARDS.md) |
| All standards | [docs/standards/](standards/) |
| Troubleshooting | [docs/troubleshooting.md](troubleshooting.md) |
| Changelog | [docs/changelog.md](changelog.md) |

---

## What's Next?

1. **Try the walkthrough** above on a real (small) change
2. **Capture an idea** with `--idea` to see the flow
3. **Read the architecture doc** when you want to understand the system
4. **Check issue #42** for capabilities we haven't adopted yet

---

*This guide covers wdi v0.3.1. For compound-engineering capabilities, see their documentation.*
