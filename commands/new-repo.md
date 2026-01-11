---
description: Create a new repository following organizational standards
---

# /wdi-workflows:new-repo - Create Repository

Create a new GitHub repository following WDI naming and structure standards.

## Flags

| Flag | Description |
|------|-------------|
| `--yes` | Skip confirmations, use defaults |
| `--clone` | Clone locally after creation |
| `--type [mono\|standalone]` | Repository type (prompts if not specified) |

---

## Workflow

### Step 1: Gather Information

Prompt for required information:

```
Repository name: _______
Description: _______
Type: (m)ono-repo, (s)tandalone, (p)lugin
```

If `--type` is provided, skip type prompt.

### Step 2: Validate Name

Read `knowledge/decision-trees/repo-type.md` for naming rules.

**Validation checks:**
- Lowercase with hyphens only
- No `wdi-` prefix (org provides context)
- Matches type pattern:
  - Mono-repo: `{cluster}-ops` (e.g., `marketing-ops`)
  - Plugin: `dev-plugins-{domain}` (e.g., `dev-plugins-analytics`)
  - Standalone: descriptive name

**If validation fails:**

```
⚠️  Name "{name}" doesn't match conventions.

Expected patterns:
  - Mono-repo: {cluster}-ops (marketing-ops, business-ops)
  - Plugin: dev-plugins-{domain}
  - Standalone: descriptive-name

(c)ontinue anyway, (e)dit name, (a)bort:
```

### Step 3: Confirm Type

Based on name, suggest appropriate type:

```
Repository: {name}
Type: {type}
Description: {description}

This will create:
  - Private repo in whitedoeinn org
  - Initial structure for {type}
  - README and standard files

Proceed? (y)es, (e)dit, (a)bort:
```

### Step 4: Create Repository

```bash
gh repo create whitedoeinn/{name} --private --description "{description}"
```

### Step 5: Initialize Structure

**For Mono-repos:**

```bash
# Clone the new repo
git clone git@github.com:whitedoeinn/{name}.git
cd {name}

# Create structure
mkdir -p packages shared docs scripts
touch README.md
touch docs/architecture.md
touch docs/changelog.md
touch .gitignore
```

Create `README.md`:
```markdown
# {name}

{description}

## Packages

| Package | Description |
|---------|-------------|
| (none yet) | Run `/wdi-workflows:new-package` to add |

## Development

### Prerequisites
- (list requirements)

### Setup
```bash
# Clone and setup
git clone git@github.com:whitedoeinn/{name}.git
cd {name}
```

## Documentation

- [Architecture](docs/architecture.md)
- [Changelog](docs/changelog.md)
```

**For Plugins:**

```bash
# Clone the new repo
git clone git@github.com:whitedoeinn/{name}.git
cd {name}

# Create plugin structure
mkdir -p .claude-plugin commands hooks scripts docs knowledge
touch README.md CLAUDE.md CONTRIBUTING.md
touch .claude-plugin/plugin.json
touch .claude-plugin/marketplace.json
touch hooks/hooks.json
touch docs/changelog.md
touch docs/troubleshooting.md
touch install.sh
chmod +x install.sh
touch .gitignore
```

Create `plugin.json`:
```json
{
  "name": "{name}",
  "description": "{description}",
  "version": "0.1.0",
  "author": {
    "name": "White Doe Inn",
    "url": "https://github.com/whitedoeinn"
  },
  "homepage": "https://github.com/whitedoeinn/{name}",
  "repository": "https://github.com/whitedoeinn/{name}",
  "license": "MIT",
  "commands": "./commands/",
  "hooks": "./hooks/hooks.json"
}
```

**For Standalone:**

```bash
# Clone the new repo
git clone git@github.com:whitedoeinn/{name}.git
cd {name}

# Create structure
mkdir -p src tests docs scripts
touch README.md CLAUDE.md
touch docs/changelog.md
touch .gitignore
```

### Step 6: Initial Commit

```bash
git add -A
git commit -m "$(cat <<'EOF'
chore: Initialize {type} repository

Set up standard directory structure and documentation.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
git push origin main
```

### Step 7: Output

```
✓ Repository created: https://github.com/whitedoeinn/{name}

Structure:
{tree output}

Next steps:
1. cd {name}
2. Start adding packages/code
3. Update README with specifics

For plugins: Run /wdi-workflows:setup to verify configuration
```

If `--clone` was passed, already in the directory.

---

## Examples

### Create mono-repo

```
/wdi-workflows:new-repo

> Repository name: business-ops
> Description: Business operations automation
> Type: mono

✓ Created: https://github.com/whitedoeinn/business-ops
```

### Create plugin

```
/wdi-workflows:new-repo --type standalone

> Repository name: dev-plugins-analytics
> Description: Claude Code analytics commands

✓ Created: https://github.com/whitedoeinn/dev-plugins-analytics
```

### Quick creation

```
/wdi-workflows:new-repo --yes --clone --type mono

> Repository name: guest-ops
> Description: Guest-facing applications

✓ Created and cloned to ./guest-ops
```

---

## Notes

- Requires `gh` CLI authenticated (`gh auth login`)
- All repos created as private by default
- Updates to standards should be reflected in new repos
- See `docs/standards/REPO-STANDARDS.md` for full naming conventions
