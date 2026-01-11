---
description: Set up claude-workflows and its dependencies
---

# Setup Claude Workflows

This command helps set up the claude-workflows plugin and its dependencies.

## Steps

1. **Check Dependencies**
   - Verify `compound-engineering` plugin is installed
   - If missing, provide installation instructions

2. **Verify Installation**
   - Check that `/claude-workflows:feature` and `/claude-workflows:commit` commands are available
   - List available commands from this plugin

3. **Initialize Project**
   - Check for CLAUDE.md in the project
   - If missing, offer to create a starter template

## Installation Commands

If dependencies are missing, run:

```bash
# Add compound-engineering marketplace
/plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin

# Install compound-engineering
/plugin install compound-engineering

# Add claude-workflows marketplace
/plugin marketplace add https://github.com/whitedoeinn/claude-workflows

# Install claude-workflows
/plugin install claude-workflows
```

Or use the bootstrap script:

```bash
curl -sSL https://raw.githubusercontent.com/whitedoeinn/claude-workflows/main/install.sh | bash
```

## Updating Plugins

To update to the latest versions:

```bash
./install.sh update
```

Or manually:

```bash
claude plugin update compound-engineering --scope project
claude plugin update claude-workflows --scope project
```
