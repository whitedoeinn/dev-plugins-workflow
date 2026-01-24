---
title: Plugin source repo doesn't need wdi-local installation
date: 2026-01-21
category: developer-experience
component: plugin-loader
severity: low
problem_type: confusion
symptoms:
  - Uncertainty about whether dev-plugins-workflows needs wdi-local
  - Questions about plugin loading in source repo vs consuming projects
  - Confusion about marketplace installations vs directory auto-loading
tags:
  - plugin-installation
  - auto-discovery
  - wdi-local
  - claude-code
  - plugin-development
root_cause: Undocumented Claude Code auto-discovery behavior for plugin source directories
solution_approach: Document that Claude Code auto-loads plugins from directories containing .claude-plugin/plugin.json
learnings:
  - Claude Code auto-loads plugins from directories with .claude-plugin/plugin.json
  - Plugin source repos don't need marketplace installation
  - wdi-local was a workaround from before auto-discovery worked reliably
  - User-scoped marketplace installation provides commands to other projects
related_issues:
  - "#43"
  - "#52"
---

# Plugin Source Repo Doesn't Need wdi-local Installation

## Problem

Confusion about whether the dev-plugins-workflows repository needs `wdi-local` marketplace installation to function during development.

## Investigation

Checked the current plugin state:

```bash
# Global settings show wdi@wdi-marketplace enabled at user scope
cat ~/.claude/settings.json | jq '.enabledPlugins'
# Output: { "wdi@wdi-marketplace": true, "compound-engineering@every-marketplace": true }

# installed_plugins.json shows no wdi-local references
cat ~/.claude/plugins/installed_plugins.json | jq '.plugins | keys'
# Output: ["compound-engineering@every-marketplace", "wdi@wdi-marketplace"]
```

The repo has:
- `.claude-plugin/plugin.json` - Plugin metadata (version 0.3.25)
- `.claude-plugin/marketplace.json` - Marketplace config (name: wdi-marketplace)
- Session startup hook ran successfully without wdi-local

## Root Cause

**Claude Code auto-loads plugins from any directory containing `.claude-plugin/plugin.json`.**

This repo IS the plugin source, so Claude Code detects and loads it directly. No marketplace installation needed.

The `wdi-local` concept was a workaround from before:
1. Global scope installation (`--scope user`) worked reliably
2. Marketplace naming collision fix (#43) cleaned up local/remote conflicts
3. Claude Code's auto-detection of plugin directories became reliable

## Solution

**No action needed.** The current setup is correct:

| Context | How wdi loads |
|---------|---------------|
| **This repo** (dev-plugins-workflows) | Auto-loaded from `.claude-plugin/plugin.json` |
| **Other projects** | Via `wdi@wdi-marketplace` (user or project scope) |

### Why This Repo Is Unique

- Other projects need `wdi@wdi-marketplace` installed
- This repo IS the plugin source, so Claude Code loads it directly
- No marketplace reference needed in source repo

### Plugin Loading Precedence

Claude Code loads plugins in this order:
1. **Local directory** - `.claude-plugin/plugin.json` in current dir (auto-detected)
2. **Project scope** - Installed for specific project
3. **User scope** - Installed globally (`--scope user`)

## Verification

To confirm the plugin is loading correctly in this repo:

```bash
# SessionStart hook should show validation success
# (visible at session start)

# Commands should be available
# Try: /wdi:workflow-setup
```

## Prevention

Added this documentation to clarify:
- Plugin source repos auto-load via `.claude-plugin/plugin.json`
- `wdi-local` is obsolete - no longer needed anywhere
- User-scoped `wdi@wdi-marketplace` serves all other projects

## Related Documentation

- [Marketplace Naming Conflict](./marketplace-naming-conflict.md) - Why marketplace names matter
- [Installer Auto-Detection](./installer-auto-detection.md) - How install.sh detects maintainer mode
- [Plugin Architecture](../../standards/PLUGIN-ARCHITECTURE.md) - One-plugin policy
