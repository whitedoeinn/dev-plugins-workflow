# Architecture

## Overview

Claude Workflows is a Claude Code plugin that orchestrates compound-engineering workflows. It builds on top of the `compound-engineering` plugin to provide high-level commands for feature development.

## Plugin System

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code CLI                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │  wdi-workflows   │───▶│   compound-engineering      │ │
│  │                     │    │                             │ │
│  │  :commit            │    │  Research Agents            │ │
│  │  :feature           │    │  Review Agents              │ │
│  │  :setup             │    │  Workflow Skills            │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Commands vs Skills

| Type | Definition | Invocation | Example |
|------|------------|------------|---------|
| **Command** | Markdown file in `commands/` | `/wdi-workflows:commit` | User-facing workflows |
| **Skill** | Defined by plugins | `Task` tool with `subagent_type` | Internal building blocks |

Commands are user-facing entry points. Skills are internal capabilities that commands can invoke.

## Workflow: /wdi-workflows:feature

```
┌────────────────────────────┐
│ /wdi-workflows:feature  │
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

## Workflow: /wdi-workflows:commit

```
┌────────────────────────────┐
│  /wdi-workflows:commit  │
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
├── commit.md           # /wdi-workflows:commit definition
├── feature.md          # /wdi-workflows:feature definition
└── setup.md            # /wdi-workflows:setup definition

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
