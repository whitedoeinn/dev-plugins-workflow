---
title: Installer Auto-Detection for Maintainer Mode
date: 2025-01-18
category: plugin-development
tags: [install, auto-detect, maintainer-mode]
---

# Installer Auto-Detection for Maintainer Mode

## Problem

Setting up a Claude Code plugin for local development required manual edits to multiple config files. This friction discouraged dogfooding and made onboarding new maintainers difficult.

## Solution

Auto-detect when running install.sh from a plugin source directory and automatically configure local marketplace mode.

## Key Decision: No Flags, No Prompts

We initially planned to add `--mode=maintainer|user|dev` flags and prompts. Through iterative simplification, we realized:

1. **If you're in the plugin source, you want maintainer mode.** There's no scenario where someone running install.sh from the plugin source wants the remote version.

2. **If you're not in the plugin source, you want user mode.** The default behavior is correct.

3. **Context determines intent.** No need for flags or prompts when the context provides the answer.

Final implementation:
```
Detect plugin source?
  ├── Yes → Maintainer mode (automatic)
  └── No  → User mode (current behavior)
```

## Implementation Details

### Detection Logic

```bash
if [[ -f ".claude-plugin/plugin.json" ]]; then
  PLUGIN_NAME=$(jq -r '.name' .claude-plugin/plugin.json)
  if [[ -n "$PLUGIN_NAME" && "$PLUGIN_NAME" != "null" ]]; then
    MARKETPLACE_NAME="${PLUGIN_NAME}-local"
    IS_MAINTAINER=true
  fi
fi
```

Key points:
- Check for `.claude-plugin/plugin.json` (any plugin, not hardcoded)
- Use jq with grep fallback for extracting name
- Validate extraction succeeded before setting maintainer mode

### Maintainer Mode Behavior

1. Add current directory as local marketplace
2. Disable remote version to avoid conflicts
3. Install from local (live edits enabled)

### Update Command Handling

In maintainer mode, `./install.sh update` advises to use `git pull` instead since updates aren't relevant with live edits.

## Learnings

1. **Start with the simplest solution that could work.** We went through three iterations:
   - v1: `--mode=maintainer|user|dev` with branch support
   - v2: Auto-detect with confirmation prompt
   - v3: Pure auto-detect, no flags, no prompts

2. **Question every parameter.** Each flag/option is complexity debt. Ask "when would someone use this?" and if the answer is "rarely" or "never", cut it.

3. **Context over configuration.** The directory you're in tells us everything we need to know. No need to ask.

4. **Generic over specific.** Reading plugin name from `plugin.json` means this works for any plugin, not just wdi.
