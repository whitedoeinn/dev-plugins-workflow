# Plugin Architecture Standard

**Status:** Draft
**Created:** 2026-01-13
**Applies to:** All WDI internal plugins

---

## Overview

This standard defines the architecture for WDI's Claude Code plugin ecosystem. It addresses namespace management, external dependencies, and organizational patterns.

## Core Principles

### 1. One Internal Plugin Policy

All WDI internal tooling lives in **one plugin** named `wdi`.

**Rationale:**
- Claude Code supports only one `.claude-plugin/` per project
- Multiple internal plugins would cause namespace collisions
- Simplifies versioning, installation, and maintenance
- Technical constraint becomes simplifying design decision

**What this means:**
- No separate `wdi-frontend`, `wdi-marketingops` plugins
- New capabilities are added TO the `wdi` plugin
- Single namespace: `/wdi:*`

### 2. External Dependencies Stay Global

Third-party plugins (e.g., `compound-engineering`) are installed globally via marketplace, not vendored.

**Rationale:**
- Third-party plugins have their own namespace (`/compound-engineering:*`)
- No collision risk with internal commands
- Maintained by external teams (stability)
- Treated like system dependencies (npm, homebrew)

**Installation pattern:**
```bash
# External dependency (global)
claude plugin install compound-engineering --scope project

# Internal plugin (via marketplace)
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/install.sh | bash
```

### 3. Domain-Prefixed Naming

All commands, skills, and hooks use domain prefixes for organization.

**Pattern:** `{domain}-{name}`

**Rationale:**
- Commands must be flat (subdirectories don't auto-discover)
- Prefixes provide logical grouping
- Alphabetical sorting groups by domain
- Clear ownership and discoverability

---

## Directory Structure

### Plugin Repository (dev-plugins)

```
dev-plugins/
├── .claude-plugin/
│   ├── plugin.json           # name: "wdi"
│   └── marketplace.json
├── commands/                  # Flat, domain-prefixed
│   ├── workflows-feature.md
│   ├── workflows-milestone.md
│   ├── workflows-enhanced-ralph.md
│   ├── standards-new-repo.md
│   ├── standards-check.md
│   ├── standards-update.md
│   ├── standards-new-command.md
│   └── standards-new-subproject.md
├── skills/                    # Domain-prefixed directories
│   ├── workflow-commit/
│   │   └── SKILL.md
│   ├── workflow-auto-docs/
│   │   └── SKILL.md
│   └── workflow-config-sync/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── scripts/
│   └── ...
├── env-baseline.json
└── CLAUDE.md
```

---

## Naming Conventions

### Commands

| Domain | Pattern | Example | Invocation |
|--------|---------|---------|------------|
| Workflows | `workflows-{name}.md` | `workflows-feature.md` | `/wdi:workflows-feature` |
| Standards | `standards-{name}.md` | `standards-new-repo.md` | `/wdi:standards-new-repo` |
| Frontend | `frontend-{name}.md` | `frontend-component.md` | `/wdi:frontend-component` |
| Marketing | `mktops-{name}.md` | `mktops-campaign.md` | `/wdi:mktops-campaign` |

### Skills

| Domain | Pattern | Example |
|--------|---------|---------|
| Workflows | `workflow-{name}/` | `workflow-commit/` |
| Workflows | `workflow-{name}/` | `workflow-config-sync/` |
| Frontend | `frontend-{name}/` | `frontend-lint/` |

### Hooks

Hooks are defined in a single `hooks.json` file. Use comments to organize by domain:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "..." }]
      }
    ]
  }
}
```

---

## External Dependencies

### Declaration

External dependencies are declared in `env-baseline.json`:

```json
{
  "required_plugins": [
    {
      "name": "compound-engineering",
      "source": "every-marketplace",
      "min_version": "2.0.0",
      "description": "Research and review agents"
    }
  ]
}
```

### Validation

The SessionStart hook validates external dependencies:
1. Checks if plugin is installed
2. Warns if missing with installation instructions

### Invocation

Always use fully-qualified names when calling external plugins:

```markdown
<!-- Commands -->
/compound-engineering:workflows:plan

<!-- Agents (via Task tool) -->
subagent_type='compound-engineering:research:repo-research-analyst'
```

---

## Versioning

### Internal Plugin (wdi)

- Uses semantic versioning: `MAJOR.MINOR.PATCH`
- Single version for entire plugin
- Breaking changes bump MAJOR version
- New features bump MINOR version
- Bug fixes bump PATCH version

### External Dependencies

- Specify minimum version in `env-baseline.json`
- Use `>=X.Y.Z` format
- Document compatibility in CLAUDE.md

---

## Scaling Guidelines

### Command Limits

| Scale | Status | Action |
|-------|--------|--------|
| 1-25 commands | Comfortable | Continue |
| 25-50 commands | Good | Ensure naming discipline |
| 50-75 commands | Manageable | Excellent documentation required |
| 75-100 commands | Caution | Consider if all commands are necessary |
| 100+ commands | Reconsider | May need architectural review |

### When to Add vs. Split

**Add to wdi plugin when:**
- Capability is used by WDI projects
- Fits within existing domain structure
- No namespace collision with existing commands

**Consider separate plugin when:**
- Capability is for external/public use
- Completely independent domain
- Would benefit from independent versioning

---

## Migration

### From wdi-workflows to wdi

1. **Rename commands:**
   - `feature.md` → `workflows-feature.md`
   - `setup.md` → `workflows-setup.md`
   - etc. for all commands

2. **Rename skills:**
   - `commit/` → `workflow-commit/`
   - `auto-update-docs/` → `workflow-auto-docs/`

3. **Update plugin.json:**
   ```json
   { "name": "wdi", "version": "0.2.0" }
   ```

4. **Update all documentation** referencing old command names

5. **Communicate breaking change** with migration guide

---

## Anti-Patterns

### Don't: Create Multiple Internal Plugins

```
✗ wdi-workflows/    → namespace collision risk
✗ wdi-frontend/     → can't use both in one project
✗ wdi-marketingops/ → versioning complexity
```

### Don't: Use Subdirectories for Commands

```
✗ commands/workflows/feature.md  → won't be discovered
✓ commands/workflows-feature.md  → works correctly
```

### Don't: Use Ambiguous Names

```
✗ setup.md       → which domain?
✓ workflows-setup.md  → clear ownership
```

---

## Checklist for New Commands/Skills

- [ ] Uses correct domain prefix
- [ ] No collision with existing names
- [ ] Added to CLAUDE.md documentation
- [ ] Tested locally before commit
- [ ] Version bumped appropriately

---

## References

- [Claude Code Plugin Documentation](https://docs.anthropic.com/claude-code/plugins)
- [Compound Engineering Plugin](https://github.com/EveryInc/compound-engineering-plugin)
- [WDI Plugin Repository](https://github.com/whitedoeinn/dev-plugins-workflow)

---

*This standard was derived from technical constraints in Claude Code's plugin system and represents a deliberate simplifying design decision.*
