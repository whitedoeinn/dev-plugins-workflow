# Getting Started with WDI Workflows

This guide gets you productive in 15 minutes. It explains what commands to use, when, and why we built things this way.

**Required for all whitedoeinn projects.** This plugin standardizes how we build features, manage issues, and maintain code quality.

## Prerequisites

- Claude Code CLI installed (`claude --version`)
- `gh` CLI authenticated (`gh auth login`)
- `jq` installed (`brew install jq` on macOS, `apt install jq` on Linux)

## Installation

### New Machine Setup

For a fresh development machine, use the comprehensive setup script:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash -s -- --reset
```

This installs plugins at **user scope** (global), creates `~/.claude/CLAUDE.md` with environment standards, and verifies the installation.

### Existing Machine / Project Install

If you already have plugins installed and just need to add them to a project:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

This installs both `wdi` and `compound-engineering` plugins.

### Multi-Machine Sync

If you work across multiple machines, run the setup script on each:

```bash
# If you have the repo cloned
cd ~/github/whitedoeinn/dev-plugins-workflow
git pull
./install.sh --reset
```

The script ensures consistent configuration across all your development machines.

### Verify Installation

```
/wdi:workflow-setup
```

This checks that all dependencies are configured correctly.

### Automatic Updates

Plugin updates happen automatically when you start Claude Code:
1. **First restart** - SessionStart hook downloads new plugin files
2. **Second restart** - Claude loads the updated plugin

This two-restart requirement is a Claude Code limitation, not a wdi bug.

### Manual Update

Re-run the install script:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

### If Updates Aren't Working

Run the machine setup script to reset to a known good state:

```bash
./install.sh --reset
# Or: curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash -s -- --reset
```

This clears caches, removes stale entries, and reinstalls fresh. See [troubleshooting.md](troubleshooting.md) for more details.

---

## How the Plugins Work Together

**Two plugins power this workflow:**

| Plugin | Role | What It Provides |
|--------|------|------------------|
| **compound-engineering** | The engine | Research agents, review agents, workflow primitives, frontend-design |
| **wdi** | The driver | Orchestrates compound-engineering for our conventions, provides standards |

You interact with wdi commands. They call compound-engineering under the hood.

### compound-engineering Capabilities

Beyond the workflow primitives, compound-engineering provides specialized skills:

| Skill | When It's Used | What It Does |
|-------|----------------|--------------|
| **frontend-design** | UI implementation | Generates polished, production-grade UI with high design quality |
| **design-iterator** | Iterative refinement | Takes screenshots, analyzes, improves - repeats N times |
| **figma-design-sync** | Design matching | Compares implementation to Figma, fixes differences |

These are invoked automatically when relevant, or you can request them explicitly (e.g., "refine this with frontend-design").

---

## The Full Feature Workflow

`/wdi:workflow-feature` offers two entry points:

| Mode | What Happens |
|------|--------------|
| **Quick idea** | One sentence → Issue created → Done (30 seconds) |
| **Build something** | Full workflow: Pre-flight → Learnings Search → Plan → Work → Review → Compound |

```
Quick idea:     Sentence → Issue → Done
Build:          Pre-flight → Learnings → Plan → Work → Review → Compound
                    wdi         wdi        c-e    c-e     c-e       c-e
```

*c-e = compound-engineering (delegated)*

📊 **Visual diagram:** [docs/workflows/feature-workflow-diagram.md](workflows/feature-workflow-diagram.md) — shows the complete learnings ecosystem and compounding feedback loop.

### Phase Breakdown

| Phase | What Happens | Powered By |
|-------|--------------|------------|
| **Interview** | Gathers feature type, description | wdi |
| **Pre-flight** | Validates repo status, detects mono-repo structure | wdi |
| **Learnings Search** | Searches local + central learnings for prior solutions | wdi |
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

## Frontend Development

When building UI, two resources work together:

| Resource | What It Provides |
|----------|------------------|
| **wdi** | Design tokens (`/wdi:frontend-setup`), standards (`FRONTEND-STANDARDS.md`) |
| **compound-engineering** | `frontend-design` skill for implementation |

### Design Tokens

Install WDI design tokens to your project:

```
/wdi:frontend-setup
```

This copies `tokens.css` and `tokens.json` to your project (shadcn-style copy pattern). Tokens include:
- Color palette with semantic naming
- Typography scale
- Spacing scale
- 6 proven themes (default, forest, ocean, sunset, midnight, minimal)

See: [FRONTEND-STANDARDS.md](standards/FRONTEND-STANDARDS.md)

### frontend-design Skill

For UI implementation, compound-engineering's `frontend-design` skill generates polished, production-grade interfaces:

```
Create a dashboard with user stats and recent activity
```

Or explicitly request design refinement:

```
Refine this component with frontend-design
```

The skill avoids generic AI aesthetics and generates distinctive, professional UI.

### Iterative Design

For designs that need multiple passes:

```
Iterate on this hero section 5 times
```

This invokes `design-iterator` which takes screenshots, analyzes what's not working, improves, and repeats.

---

## Which Command Do I Use?

| Situation | Command | What Happens |
|-----------|---------|--------------|
| Quick thought to capture | `/wdi:workflow-feature` → "Quick idea" | One sentence → Issue → Done (30 seconds) |
| Ready to build something | `/wdi:workflow-feature` → "Build something" | Full workflow: all phases |
| Continue existing issue | `/wdi:workflow-feature #N` | Resumes from where it left off |
| Just need the plan | `/wdi:workflow-feature` → "Build" + `--plan` | Pre-flight → Learnings → Plan, then stops |
| Tiny fix, no tracking needed | Just ask Claude | No workflow—direct changes |

### Command Examples

```bash
# Start something new
/wdi:workflow-feature

# Continue existing issue
/wdi:workflow-feature #45

# Auto-continue without pauses (experienced users)
/wdi:workflow-feature --yes

# Stop after planning
/wdi:workflow-feature --plan
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

### Why quick idea vs build something?

Ideas range from "a sentence that will remind me" to "ready to implement now." The two entry points handle both:

1. **Quick idea** — Capture a thought in one sentence before it escapes (30 seconds)
2. **Build something** — Full workflow when you're ready to implement

**Shaping happens naturally:**
- Add comments to the issue over time
- When ready: `/wdi:workflow-feature #N` → "Start building"

No special syntax or prefixes. Just write what you're thinking.

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
/wdi:workflow-feature
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
| Start new (idea or build) | `/wdi:workflow-feature` |
| Continue issue | `/wdi:workflow-feature #N` |
| Plan only | `/wdi:workflow-feature --plan` |
| Commit changes | "commit these changes" |
| Check standards | `/wdi:standards-check` |
| New repo | `/wdi:standards-new-repo` |

---

## Going Deeper

| Topic | Document |
|-------|----------|
| System architecture | [docs/architecture.md](architecture.md) |
| Workflow diagram | [docs/workflows/feature-workflow-diagram.md](workflows/feature-workflow-diagram.md) |
| Learnings architecture | See CLAUDE.md "Learnings Architecture" section |
| Frontend standards | [docs/standards/FRONTEND-STANDARDS.md](standards/FRONTEND-STANDARDS.md) |
| Design tokens | [assets/tokens/](../assets/tokens/) |
| Auto-docs capability | [docs/auto-docs.md](auto-docs.md) |
| Branch naming | [docs/drafts/BRANCH-NAMING.md](drafts/BRANCH-NAMING.md) *(draft - see #44)* |
| Commit conventions | [docs/standards/COMMIT-STANDARDS.md](standards/COMMIT-STANDARDS.md) |
| All standards | [docs/standards/](standards/) |
| Troubleshooting | [docs/troubleshooting.md](troubleshooting.md) |
| Changelog | [docs/changelog.md](changelog.md) |

---

## What's Next?

1. **Try the walkthrough** above on a real (small) change
2. **Capture a quick idea** to see how fast idea capture works
3. **Read the architecture doc** when you want to understand the system
4. **Check issue #42** for capabilities we haven't adopted yet

---

*This guide covers wdi v0.4.8. For compound-engineering capabilities, see their documentation.*
