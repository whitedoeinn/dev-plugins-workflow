# Claude Code Standards

**Organization:** whitedoeinn
**Last Updated:** 2026-01-11

---

## Overview

All Claude Code customizations (plugins, commands, skills) use a consistent naming pattern to avoid conflicts with third-party plugins and maintain organizational identity.

---

## Naming Convention

### Command Prefix

All WDI commands use the `wdi-` prefix:

```
/wdi-{domain}:{command}
```

| Domain | Commands | Repo |
|--------|----------|------|
| `workflow` | `/wdi-workflow:commit`, `/wdi-workflow:feature` | `dev-plugins-workflow` |
| `frontend` | `/wdi-frontend:component`, `/wdi-frontend:page` | `dev-plugins-frontend` |
| `analytics` | `/wdi-analytics:report`, `/wdi-analytics:query` | `dev-plugins-analytics` |
| `backend` | `/wdi-backend:api`, `/wdi-backend:migration` | `dev-plugins-backend` |

### Repository Names

Plugin repos follow the standard naming (no `wdi-` prefix since they're in the whitedoeinn org):

```
dev-plugins-{domain}
```

### Plugin Names (in plugin.json)

Match the repo name:

```json
{
  "name": "dev-plugins-workflow",
  "commands": "./commands/"
}
```

---

## Why This Convention

1. **Namespace Protection**: `wdi-` prefix prevents conflicts with third-party plugins
2. **Clear Ownership**: Commands are immediately identifiable as WDI tools
3. **Consistent UX**: All internal commands follow the same pattern
4. **Discoverability**: Easy to list all WDI commands with `/wdi-*`

---

## Command Structure

Commands are defined as markdown files in `commands/`:

```
commands/
├── commit.md      # Becomes /wdi-workflow:commit
├── feature.md     # Becomes /wdi-workflow:feature
└── setup.md       # Becomes /wdi-workflow:setup
```

### Command File Format

```markdown
---
description: Short description for command listings
---

# /wdi-{domain}:{command} - Human Readable Title

## Flags

| Flag | Description |
|------|-------------|
| `--flag` | What it does |

## Workflow

### Step 1: First Step
...
```

---

## Plugin Dependencies

WDI plugins can depend on other plugins. Document dependencies in `plugin.json`:

```json
{
  "name": "dev-plugins-workflow",
  "dependencies": {
    "compound-engineering": ">=1.0.0"
  }
}
```

Check dependencies on SessionStart via hooks:

```json
{
  "SessionStart": ["scripts/check-deps.sh"]
}
```

---

## CLAUDE.md Requirements

Every project using Claude Code should have a `CLAUDE.md` file:

```markdown
# Project Name

## Overview
What this project does.

## Commands
Available Claude Code commands.

## Development
How to work on this project.

## Conventions
Project-specific patterns.
```

---

## Hooks

Claude Code supports these hook types:

| Hook | Trigger | Use for |
|------|---------|---------|
| `SessionStart` | New Claude Code session | Dependency checks, reminders |

Hooks are defined in `hooks/hooks.json`:

```json
{
  "SessionStart": ["scripts/check-deps.sh"]
}
```

---

## Plugin Installation

Plugins install via `install.sh` bootstrap script:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/{repo}/main/install.sh | bash
```

Or manually:

```bash
claude plugin marketplace add https://github.com/whitedoeinn/{repo}
claude plugin install {plugin-name} --scope project
```

---

## Future Plugins

When creating new Claude Code plugins, follow this checklist:

- [ ] Repo named `dev-plugins-{domain}`
- [ ] Commands prefixed `/wdi-{domain}:*`
- [ ] `plugin.json` with proper metadata
- [ ] `install.sh` for easy bootstrap
- [ ] `CLAUDE.md` for Claude context
- [ ] SessionStart hook for dependency check
- [ ] Documented in this standards file
