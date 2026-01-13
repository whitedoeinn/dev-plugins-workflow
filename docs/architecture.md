# Architecture

## Overview

Claude Workflows is a Claude Code plugin that orchestrates compound-engineering workflows. It builds on top of the `compound-engineering` plugin to provide high-level commands for feature development.

## Plugin System

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code CLI                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │  wdi   │───▶│   compound-engineering      │ │
│  │                     │    │                             │ │
│  │  :feature           │    │  Research Agents            │ │
│  │  :setup             │    │  Review Agents              │ │
│  │  commit (skill)     │    │  Workflow Skills            │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Commands vs Skills

| Type | Definition | Invocation | Example |
|------|------------|------------|---------|
| **Command** | Markdown file in `commands/` | `/wdi:feature` | User-facing workflows |
| **Skill** | SKILL.md in `skills/` | Auto-detected by context | `commit` (say "commit these changes") |

Commands are user-facing entry points invoked explicitly. Skills auto-invoke based on conversation context.

## Workflow: /wdi:feature

```
┌────────────────────────────┐
│ /wdi:feature  │
└─────────────┬──────────────┘
       │
       ▼
┌──────────────┐     ┌────────────────────────────────────┐
│   Research   │────▶│ compound-engineering research agents│
│   Phase      │     │ - repo-research-analyst            │
└──────┬───────┘     │ - git-history-analyzer             │
       │             │ - framework-docs-researcher        │
       ▼             │ - best-practices-researcher        │
┌──────────────┐     └────────────────────────────────────┘
│    Plan      │────▶ Creates GitHub Issue + local plan
│    Phase     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Work      │────▶ Feature branch + implementation
│    Phase     │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────────────────────────┐
│   Review     │────▶│ compound-engineering review agents │
│   Phase      │     │ - code-simplicity-reviewer         │
└──────┬───────┘     │ - architecture-strategist          │
       │             │ - security-sentinel                │
       ▼             │ - performance-oracle               │
┌──────────────┐     └────────────────────────────────────┘
│  Compound    │────▶ Merge + changelog + document learnings
│   Phase      │
└──────────────┘
```

## Skill: commit (auto-invoked)

```
┌────────────────────────────┐
│  commit skill              │
│  (say "commit these")      │
└─────────────┬──────────────┘
       │
       ▼
┌──────────────┐
│ Check Status │────▶ git status, stage files
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Run Tests   │────▶ pytest (*.py) or npm test (*.ts/*.js)
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌────────────────────────────────────┐
│  Simplicity  │────▶│ compound-engineering               │
│   Review     │     │ code-simplicity-reviewer           │
└──────┬───────┘     └────────────────────────────────────┘
       │
       ▼
┌──────────────┐
│   Generate   │────▶ AI-generated commit message
│   Message    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Update     │────▶ docs/changelog.md
│  Changelog   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Push      │────▶ git push
└──────────────┘
```

## File Structure

```
.claude-plugin/
├── plugin.json         # Plugin registration
│   ├── name            # Plugin identifier
│   ├── version         # Semantic version
│   ├── commands        # Points to ./commands/
│   └── hooks           # Points to ./hooks/hooks.json
└── marketplace.json    # Local marketplace config

commands/
├── feature.md          # /wdi:feature definition
└── setup.md            # /wdi:setup definition

skills/
└── commit/
    └── SKILL.md        # commit skill (auto-invoked)

hooks/
└── hooks.json          # SessionStart triggers check-deps.sh

scripts/
└── check-deps.sh       # Verifies compound-engineering installed
```

## Integration Points

| Integration | How |
|-------------|-----|
| compound-engineering agents | `Task` tool with `subagent_type='compound-engineering:...'` |
| GitHub | `gh` CLI for issue creation |
| Git | Direct `git` commands via Bash tool |
| Testing | `pytest` or `npm test` based on file types |

## Session Hooks

On session start (`hooks.json`):
1. `check-deps.sh` runs
2. Verifies `compound-engineering` plugin is available
3. Warns user if missing with installation instructions
