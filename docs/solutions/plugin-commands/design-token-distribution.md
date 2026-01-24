---
title: Design Token Distribution via CLI Command
category: plugin-commands
problem_type: architecture
component: frontend-setup
date: 2026-01-23
tags: [design-tokens, shadcn-pattern, asset-distribution, frontend]
related_issues: [77]
---

# Design Token Distribution via CLI Command

## Problem

Design tokens existed in `assets/tokens/` but had no distribution mechanism. The plugin cache path is fragile (version-dependent like `~/.claude/plugins/cache/wdi-marketplace/wdi/0.3.36/`), meaning:
- Path changes on every plugin update
- Cache can be cleared unexpectedly
- Projects can't reliably reference tokens from cache

**Research question:** How should Claude Code plugins distribute assets (CSS, JSON) to consuming projects?

## Investigation

### What Doesn't Work

1. **Plugin cache references** - Path includes version number, breaks on update
2. **Symlinks to cache** - Same problem, breaks when cache clears
3. **npm package** - Overkill for CSS/JSON, requires npm publish infrastructure

### Research: How Others Solve This

**shadcn/ui approach:**
- Downloads components from GitHub raw URLs
- Copies files to project (user owns them)
- Version metadata in file headers
- Updates are opt-in via CLI

**compound-engineering plugin:**
- Only distributes markdown templates, not CSS/assets
- No precedent in Claude Code ecosystem for CSS distribution

## Solution

Implemented `/wdi:frontend-setup` command following shadcn pattern:

### 1. GitHub Raw URLs as Source

```bash
CSS_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.css"
JSON_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.json"
```

**Why GitHub raw URLs?**
- Stable (don't change with plugin version)
- Version-agnostic (always main branch)
- No CDN setup required
- HTTPS by default

### 2. Version Metadata in Files

**CSS header:**
```css
/**
 * WDI Design Tokens v0.3.37
 * Downloaded: 2026-01-23
 * Source: https://github.com/whitedoeinn/dev-plugins-workflows
 *
 * To update: run /wdi:frontend-setup
 */
```

**JSON metadata:**
```json
{
  "_wdiMeta": {
    "version": "0.3.37",
    "downloadedAt": "2026-01-23T21:14:00-0500",
    "source": "https://github.com/whitedoeinn/dev-plugins-workflows"
  }
}
```

### 3. Update Flow with Diff

```bash
# Extract local version
LOCAL_VERSION=$(head -10 "$TARGET_DIR/tokens.css" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')

# Fetch remote version
REMOTE_VERSION=$(curl -fsSL "$VERSION_URL" | jq -r '.version')

# Show diff if different
if [[ "$LOCAL_VERSION" != "v$REMOTE_VERSION" ]]; then
  diff -u "$TARGET_DIR/tokens.css" "$TEMP_DIR/tokens-new.css"
  # Prompt user before updating
fi
```

## Key Security Fixes Applied

During review, identified and fixed:

### 1. Secure Temp File Handling

**Before (vulnerable):**
```bash
curl -fsSL -o /tmp/wdi-tokens.css "$CSS_URL"
```

**After (secure):**
```bash
TEMP_DIR=$(mktemp -d) || exit 1
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM
curl -fsSL -o "$TEMP_DIR/tokens.css" "$CSS_URL"
```

### 2. Portable Date Format

**Before (GNU-only):**
```bash
date -Iseconds  # Fails on macOS
```

**After (portable):**
```bash
date +%Y-%m-%dT%H:%M:%S%z  # Works on both
```

## Prevention

1. **Always use `mktemp`** for temporary files in CLI commands
2. **Verify repository URLs** before shipping (singular vs plural caught in review)
3. **Test date commands** on both macOS and Linux
4. **Add pre-flight checks** for required tools (jq, curl) before first use

## Cross-References

- Plan: `plans/feat-frontend-setup-command.md`
- Command: `commands/frontend-setup.md`
- Standards: `docs/standards/FRONTEND-STANDARDS.md`
- Tokens: `assets/tokens/tokens.css`, `assets/tokens/tokens.json`
- Issue: #77

## Pattern for Future Asset Distribution

When distributing non-code assets from Claude Code plugins:

1. **Use GitHub raw URLs** - stable, version-agnostic
2. **Embed version metadata** - enables update detection
3. **Follow shadcn pattern** - copy to project, user owns code
4. **Show diff before updates** - respect user modifications
5. **Use secure temp files** - mktemp + trap for cleanup
6. **Test portability** - macOS vs Linux differences (especially date)
