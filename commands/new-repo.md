---
description: Create a WDI-standard repository with proper plugin structure
---

# /wdi:new-repo

Create a new GitHub repository with WDI standard structure.

## Usage

```
/wdi:new-repo <name> [--type TYPE] [--desc "description"] [--org ORG] [--public] [--clone]
```

## Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `name` | **required** | Repository name (lowercase, hyphens) |
| `--type` | `standalone` | `standalone`, `plugin`, `mono`, `knowledge`, `experiment` |
| `--desc` | auto | One-line description |
| `--org` | `whitedoeinn` | GitHub organization or username |
| `--public` | `false` | Make repository public (default: private) |
| `--clone` | `false` | Clone locally after creation |

## Examples

```
/wdi:new-repo foundation --type knowledge --desc "Human 3.0 methodology" --public --clone
/wdi:new-repo enterprise --type knowledge --desc "Corporate identity and governance" --public
/wdi:new-repo portfolio --type knowledge --desc "Software strategy and capabilities" --public
/wdi:new-repo dev-plugins-analytics --type plugin --clone
/wdi:new-repo marketing-ops --type mono
/wdi:new-repo experiment-graphql --type experiment
```

---

## Workflow

### Step 1: Parse Arguments

Extract from command:
- `NAME`: First positional argument (required)
- `TYPE`: From `--type` flag (default: `standalone`)
- `DESC`: From `--desc` flag (default: generate from name)
- `ORG`: From `--org` flag (default: `whitedoeinn`)
- `PUBLIC`: `--public` flag present (default: private)
- `CLONE`: `--clone` flag present (default: false)

**Validation:**
- Name must be lowercase with hyphens only
- Type must be one of: `standalone`, `plugin`, `mono`, `knowledge`, `experiment`

If validation fails:
```
❌ Invalid repository name: {name}
   Names must be lowercase with hyphens only (e.g., my-project)
```

### Step 2: Check if Repo Exists

```bash
gh repo view ${ORG}/${NAME} &>/dev/null && echo "exists" || echo "new"
```

If exists:
```
❌ Repository ${ORG}/${NAME} already exists.
   https://github.com/${ORG}/${NAME}
```
Stop execution.

### Step 3: Create Repository

```bash
VISIBILITY="--private"
if [ "$PUBLIC" = "true" ]; then
  VISIBILITY="--public"
fi

gh repo create ${ORG}/${NAME} ${VISIBILITY} --description "${DESC}"
```

### Step 4: Clone Repository

```bash
gh repo clone ${ORG}/${NAME}
cd ${NAME}
```

### Step 5: Create Structure

Based on TYPE, create directories and files:

#### Standalone Structure
```
{repo}/
├── src/
├── tests/
├── docs/
│   └── changelog.md
├── scripts/
├── README.md
├── CLAUDE.md
└── .gitignore
```

#### Plugin Structure
```
{repo}/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── commands/
├── hooks/
│   └── hooks.json
├── scripts/
├── docs/
│   ├── changelog.md
│   └── troubleshooting.md
├── knowledge/
├── install.sh
├── README.md
├── CLAUDE.md
├── CONTRIBUTING.md
└── .gitignore
```

#### Mono-repo Structure
```
{repo}/
├── packages/
├── shared/
├── docs/
│   ├── architecture.md
│   └── changelog.md
├── scripts/
├── README.md
├── CLAUDE.md
└── .gitignore
```

#### Knowledge Structure

For methodology, documentation, and knowledge repos (not code):

```
{repo}/
├── docs/
│   └── changelog.md
├── scripts/
├── README.md
├── CLAUDE.md
└── .gitignore
```

**Note:** Knowledge repos get minimal structure. Add domain-specific directories after creation (e.g., `telos/`, `decisions/`, `playbooks/`).

#### Experiment Structure
```
{repo}/
├── README.md
├── docs/
│   └── findings.md
└── .gitignore
```

### Step 6: Create Standard Files

#### .gitignore (all types)

```gitignore
# Dependencies
node_modules/
vendor/
venv/

# Build outputs
dist/
build/
*.egg-info/

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local

# Claude Code project-local settings
.claude/*

# Exception: Committed plan files for idea shaping
!.claude/plans/
.claude/plans/*
!.claude/plans/idea-*.md
```

#### CLAUDE.md (all types)

```markdown
# ${NAME}

${DESC}

## Structure

{Generate based on TYPE - show directory tree}

## Development

{Basic development instructions}

## Standards

This repository follows [WDI Repository Standards](https://github.com/whitedoeinn/dev-plugins-workflow/blob/main/docs/standards/REPO-STANDARDS.md).
```

#### README.md (all types)

```markdown
# ${NAME}

${DESC}

## Overview

{TODO: Add project overview}

## Getting Started

{TODO: Add setup instructions}

## Documentation

See [docs/](docs/) for detailed documentation.

## Standards

This repository follows [WDI Repository Standards](https://github.com/whitedoeinn/dev-plugins-workflow/blob/main/docs/standards/REPO-STANDARDS.md).
```

#### Experiment README Addition

For experiments, prepend to README:

```markdown
> ⚠️ **Experiment**: This repo has a 90-day lifecycle.
> Created: {date} | Expires: {date+90}
> Either promote to permanent repo or archive with documented learnings.
```

### Step 7: Initial Commit

```bash
git add -A
git commit -m "chore: initialize ${TYPE} repository

Set up standard directory structure and documentation.

Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin main
```

### Step 8: Output

```
✅ Repository created: https://github.com/${ORG}/${NAME}

Type: ${TYPE}
Visibility: ${PUBLIC ? "public" : "private"}

Structure:
$(tree -L 2)

Next steps:
1. cd ${NAME}
2. Update README.md with project specifics
3. Start building!
```

If `--clone` was NOT specified:
```
To clone locally:
  gh repo clone ${ORG}/${NAME}
```

---

## Notes

- All repos get CLAUDE.md for Claude Code context
- All repos follow WDI standards by default
- Use `--type knowledge` for documentation/methodology repos (no src/tests)
- Use `--type experiment` for spikes with 90-day lifecycle
- Private by default; use `--public` for open repos
