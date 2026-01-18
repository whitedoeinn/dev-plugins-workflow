# Getting Started with WDI Workflows

This guide gets you productive in 15 minutes. It explains what commands to use, when, and why we built things this way.

**Required for all whitedoeinn projects.** This plugin standardizes how we build features, manage issues, and maintain code quality.

## Prerequisites

- Claude Code CLI installed (`claude --version`)
- `gh` CLI authenticated (`gh auth login`)

## Installation

Run in your project directory:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

This installs both `wdi` and `compound-engineering` plugins.

### Verify Installation

```
/wdi:workflows-setup
```

This checks that all dependencies are configured correctly.

### Update to Latest Version

Re-run the install script:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

Run this periodically to get new features and fixes.

---

## How the Plugins Work Together

**Two plugins power this workflow:**

| Plugin | Role | What It Provides |
|--------|------|------------------|
| **compound-engineering** | The engine | Research agents, review agents, workflow primitives |
| **wdi** | The driver | Orchestrates compound-engineering for our conventions |

You interact with wdi commands. They call compound-engineering under the hood.

---

## The Full Feature Workflow

`/wdi:workflows-feature` runs these phases:

```
Interview → Pre-flight → Plan → Work → Review → Compound
    wdi         wdi       c-e    c-e     c-e       c-e
```

*c-e = compound-engineering (delegated)*

### Phase Breakdown

| Phase | What Happens | Powered By |
|-------|--------------|------------|
| **Interview** | Gathers feature type, description | wdi |
| **Pre-flight** | Validates repo status, detects mono-repo structure | wdi |
| **Plan** | Runs research agents, creates GitHub issue + feature spec | compound-engineering |
| **Work** | Implements changes with todo tracking | compound-engineering |
| **Review** | Runs 12+ review agents in parallel | compound-engineering |
| **Compound** | Captures learnings, updates changelog | compound-engineering |

Each phase pauses for your approval (unless you pass `--yes`).

### Research Agents

The Plan phase automatically runs research agents before creating the plan. These agents provide deep context that improves planning quality.

| Agent | What It Does | Why It Matters |
|-------|--------------|----------------|
| **Repo Research Analyst** | Analyzes repository structure, documentation patterns, existing conventions | Ensures plan follows existing patterns |
| **Git History Analyzer** | Traces code evolution, identifies key contributors, finds patterns in past changes | Understands *why* code exists, not just *what* |
| **Framework Docs Researcher** | Fetches current documentation for frameworks/libraries in your project | Avoids deprecated patterns, uses correct APIs |
| **Best Practices Researcher** | Gathers external standards, community patterns, well-regarded examples | Aligns with industry standards |

**How it works:** `/workflows:plan` (compound-engineering) automatically selects and runs relevant research agents based on your feature description. No manual configuration needed.

### Review Agents

The Review phase runs 12+ specialized agents in parallel. This catches issues that single-pass reviews miss.

| Agent | Focus Area | What It Catches |
|-------|------------|-----------------|
| **Code Simplicity Reviewer** | YAGNI, minimalism | Over-engineering, unnecessary abstractions |
| **Architecture Strategist** | Design patterns, boundaries | Architectural violations, misplaced code |
| **Security Sentinel** | OWASP, auth, secrets | Vulnerabilities, exposed credentials |
| **Performance Oracle** | Algorithms, queries | N+1 queries, inefficient patterns |
| **Data Integrity Guardian** | Migrations, transactions | Unsafe migrations, missing constraints |
| **Pattern Recognition Specialist** | Consistency, anti-patterns | Naming drift, code duplication |

Additional language-specific reviewers run based on file types changed (Rails, Python, TypeScript, etc.).

**How it works:** `/workflows:review` (compound-engineering) automatically runs all relevant agents in parallel. Findings are prioritized (P1/P2/P3) and converted to GitHub issues. No manual agent selection needed.

**Why this matters:** A single reviewer can't hold all these perspectives. Parallel agents catch more issues with no additional time cost.

---

## Which Command Do I Use?

| Situation | Command | Prerequisite | What Runs |
|-----------|---------|--------------|-----------|
| Vague idea, not ready to build | `--idea` | None | Creates issue only, no implementation |
| Clear idea, ready to implement | (default) | None | Full workflow: all 6 phases |
| Existing idea issue to promote | `--promote #123` | Issue with [shaped comments](../CLAUDE.md#shaping-comment-prefixes) | Full workflow with pre-filled context |
| Just need the plan, not implementation | `--plan` | None | Pre-flight → Research → Plan, then stops |
| Tiny fix, no tracking needed | Just ask Claude | None | No workflow—direct changes |
| Research only, no implementation | Just ask Claude | None | No workflow—conversation only |

### Command Examples

```bash
# Capture an idea quickly
/wdi:workflows-feature --idea

# Full workflow (most common)
/wdi:workflows-feature

# Promote a shaped idea to implementation
/wdi:workflows-feature --promote #123

# Get a plan but don't implement yet
/wdi:workflows-feature --plan

# Auto-continue without pauses (experienced users)
/wdi:workflows-feature --yes
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
