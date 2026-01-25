# Welcome, Future Collaborator

By the end of this guide (about 30 minutes), you'll have:

- A working WDI development environment
- Understanding of how wdi, compound-engineering, and learnings work together
- Your first contribution shipped (or at least captured as an idea)

Let's go.

---

## The 10-Minute Hello World

Get something working before diving into concepts.

### Step 1: Clone the Repo

```bash
git clone https://github.com/whitedoeinn/dev-plugins-workflow
cd dev-plugins-workflow
```

### Step 2: Run the Installer

```bash
./install.sh
```

This installs two plugins:
- `compound-engineering` - The engine (research agents, review agents, workflow primitives)
- `wdi` - The orchestrator (our conventions, GitHub integration, standards)

**Expected output:**
```
Installing wdi plugin...
  ✓ compound-engineering marketplace added
  ✓ compound-engineering installed
  ✓ wdi marketplace added
  ✓ wdi installed
Done! Start Claude Code to use the plugins.
```

### Step 3: Start Claude Code

```bash
claude
```

On first launch, you'll see environment validation:

```
Environment validated
  Plugins: 2 checked
  Tools: 2 checked
```

### Step 4: Validate Your Setup

Type this to Claude:

```
check my config
```

**Expected output:**
```
Environment Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ compound-engineering: installed
✓ gh CLI: authenticated
✓ wdi plugin: v0.4.x

All checks passed.
```

If something fails, follow the remediation steps shown. Common fixes:
- `gh auth login` for GitHub authentication
- Restart Claude Code if plugins aren't detected

### Step 5: Create Your First Issue

```
/wdi:workflow-feature
```

When prompted, choose **"Quick idea"** and enter:

```
Test my setup - Hello World contribution
```

**Expected output:**
```
Idea Captured
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Issue #XX: Test my setup - Hello World contribution

Later:
• Add context as comments on the issue
• Continue with: /wdi:workflow-feature #XX
```

You did it. You have a working environment and created your first GitHub issue.

---

## The Ecosystem: A Story

Now that you're set up, let's understand what you're working with.

### The Philosophy: Compound Engineering

Every problem you solve should make the next problem easier.

When you fix a bug, document what you learned. When you build a feature, capture the patterns you discovered. Over time, this knowledge accumulates and compounds - making the whole team faster.

This isn't about bureaucracy. It's about not solving the same problem twice.

### The Cast of Characters

| Component | Role | What It Does |
|-----------|------|--------------|
| **wdi** | The orchestrator | Knows our conventions. Gathers context, creates issues, tracks progress. |
| **compound-engineering** | The engine | Does the heavy lifting. Research agents, review agents, planning tools. |
| **learnings repo** | The memory | Central place where learnings from all projects accumulate. |

### How They Work Together

```
You → /wdi:workflow-feature → (wdi gathers context)
                                    ↓
                            compound-engineering
                              research agents
                              review agents
                              workflow tools
                                    ↓
                            docs/solutions/
                              (learning captured)
                                    ↓
                            whitedoeinn/learnings
                              (knowledge compounds across projects)
```

**wdi delegates to compound-engineering for all heavy lifting.** wdi encodes our specific decisions:

- GitHub issue format
- Phase labels (`phase:planning`, `phase:working`, etc.)
- The feature workflow stages
- Our commit conventions

Without wdi, you'd have powerful tools but no conventions. With wdi, you get opinionated workflows that match how we work.

### The Learnings Flow

When you complete a feature, the workflow captures what you learned:

1. **Local capture** - Learning saved in `docs/solutions/` in your project
2. **Central sync** - Periodically synced to `whitedoeinn/learnings`
3. **Future discovery** - Next time someone works on something similar, the Learnings Search phase surfaces your insight

This is how knowledge compounds. Your solution today helps someone (maybe future-you) avoid the same struggle later.

---

## Your First Real Contribution

Ready to contribute something meaningful? Here's the full cycle.

### Step 1: Find Something to Improve

Browse the repo. Read the code. Something will catch your eye:
- A confusing error message
- Missing documentation
- A feature that could be cleaner
- Something that tripped you up during setup

### Step 2: Capture It

```
/wdi:workflow-feature
```

Choose **"Quick idea"** and describe what you noticed in one sentence:

```
The troubleshooting doc doesn't cover XYZ error
```

You now have an issue. It costs nothing to capture thoughts this way.

### Step 3: Shape It (Optional)

If you want to add context before building:

1. Go to the issue on GitHub
2. Add comments with your thoughts, research, or questions
3. When you're ready to build, continue

### Step 4: Build It

```
/wdi:workflow-feature #XX
```

(Replace `#XX` with your issue number)

Choose **"Start building"** and the workflow takes over:

| Phase | What Happens |
|-------|--------------|
| **Pre-flight** | Validates your environment is ready |
| **Learnings Search** | Checks if we've solved similar problems before |
| **Plan** | Research agents analyze, then create a plan |
| **Work** | Implementation with test running |
| **Review** | Review agents check for issues |
| **Compound** | Captures what you learned |

Each phase updates the GitHub issue with progress. If you get interrupted, resume with `/wdi:workflow-feature #XX` - it picks up where you left off.

### Step 5: Ship It

When the workflow completes, it uses the commit skill to:
- Run tests
- Update the changelog
- Bump the version
- Create the commit
- Push to GitHub

**Use the commit skill, not raw git.** Say "commit these changes" and let it handle the conventions.

### Step 6: Celebrate

Your contribution is merged. The learning is documented. You've made the system a little better.

---

## Common Gotchas

Things that trip people up, with quick fixes.

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Command not found" | Plugin not loaded | Restart Claude Code |
| Changes don't propagate | Forgot version bump | Use commit skill (it bumps for you) |
| Hooks don't fire | Testing without --plugin-dir | Run `claude --plugin-dir .` |
| "Permission denied" | Script not executable | `chmod +x scripts/*.sh` |
| Stuck mid-workflow | Issue in weird state | Resume with `/wdi:workflow-feature #XX` |
| "gh not authenticated" | GitHub CLI needs login | Run `gh auth login` |
| Tests fail on commit | Code has issues | Fix the tests first, then commit |

### The Two-Restart Issue

When the plugin updates, you need to restart Claude Code twice:
1. First restart downloads the new plugin files
2. Second restart loads the new version

This is a Claude Code limitation, not a bug in wdi. If you pushed changes and they're not showing up, try restarting again.

### Testing Hooks Locally

If you're modifying `hooks/hooks.json`, you need the `--plugin-dir` flag:

```bash
claude --plugin-dir .
```

Commands and skills work immediately. Hooks need the flag.

---

## What's Next?

### Immediate

- [ ] Close your "Hello World" test issue (it was for validation)
- [ ] Pick a real issue from [good first issues](https://github.com/whitedoeinn/dev-plugins-workflow/labels/good%20first%20issue)
- [ ] Try the full `/wdi:workflow-feature` build flow on something small

### When You're Ready for More

| Topic | Resource |
|-------|----------|
| System design | [docs/architecture.md](architecture.md) |
| Development standards | [docs/standards/](standards/) |
| How learnings work | [docs/solutions/](solutions/) |
| Troubleshooting | [docs/troubleshooting.md](troubleshooting.md) |
| Adding commands | [CONTRIBUTING.md](../CONTRIBUTING.md) |

### Having Trouble?

- Check [troubleshooting.md](troubleshooting.md) first
- Open an issue - we want to help and your confusion often reveals documentation gaps

---

## Quick Reference

### Key Commands

| Command | When to Use |
|---------|-------------|
| `/wdi:workflow-feature` | Start or continue any feature work |
| `/wdi:workflow-feature #N` | Resume a specific issue |
| `/wdi:standards-check` | Validate repo against standards |

### Key Skills (Auto-Invoked)

| Say This | What Happens |
|----------|--------------|
| "commit these changes" | Smart commit with tests, docs, changelog |
| "check my config" | Environment validation |
| "update the docs" | Sync documentation with code changes |

### Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Everything about this project for Claude |
| `commands/*.md` | Command definitions (markdown IS implementation) |
| `skills/*/SKILL.md` | Skill definitions |
| `docs/solutions/` | Captured learnings |
| `.claude-plugin/plugin.json` | Plugin metadata and version |

---

*Guide last updated: January 2026*
