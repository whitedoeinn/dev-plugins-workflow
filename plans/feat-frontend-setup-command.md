# Plan: /wdi:frontend-setup Command

## Overview

Create a `/wdi:frontend-setup` command that distributes WDI design tokens to consuming projects, following the shadcn "copy to project" pattern.

**Issue:** #77
**Priority:** P1
**Type:** Enhancement

## Problem Statement

Design tokens exist in `assets/tokens/` but have no distribution mechanism. The plugin cache path is fragile (version-dependent, clearable). Projects need a reliable way to get tokens that:
- Works offline after initial download
- Integrates with build tools (Tailwind, etc.)
- Gives users ownership of the files
- Makes updates explicit and opt-in

## Proposed Solution

A command that:
1. Downloads tokens from GitHub raw URL (stable source)
2. Detects project type to find the right destination
3. Copies files with version metadata
4. Shows Tailwind CSS 4 integration guidance
5. Handles updates gracefully with diff and confirmation

## Technical Approach

### GitHub Raw URLs

```
https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.css
https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.json
```

### Project Type Detection

From `package.json` dependencies:

| Check | Project Type | Target Directory |
|-------|--------------|------------------|
| `dependencies.next` exists | Next.js | `src/styles/` or `app/` |
| `devDependencies.vite` exists | Vite | `src/styles/` |
| Neither | Unknown | Prompt user |

### CSS File Location Detection

| Project Type | Primary | Fallbacks |
|--------------|---------|-----------|
| Next.js (App Router) | `src/app/globals.css` | `app/globals.css` |
| Next.js (Pages) | `src/styles/globals.css` | `styles/globals.css` |
| Vite | `src/index.css` | `src/styles/index.css` |
| Unknown | Prompt user | - |

### Version Metadata Format

**In tokens.css (header comment):**
```css
/**
 * WDI Design Tokens v0.3.36
 * Downloaded: 2026-01-23
 * Source: https://github.com/whitedoeinn/dev-plugins-workflow
 *
 * To update: run /wdi:frontend-setup
 * Do not edit below this line - your changes will be overwritten
 */
```

**In tokens.json (field):**
```json
{
  "_wdiMeta": {
    "version": "0.3.36",
    "downloadedAt": "2026-01-23T20:30:00Z",
    "source": "https://github.com/whitedoeinn/dev-plugins-workflow"
  },
  ...
}
```

### Update Detection

1. Check if `tokens.css` exists in target directory
2. If exists, read the version from header comment
3. Fetch current version from GitHub
4. Compare versions:
   - Same version → "Already up to date"
   - Different → Show diff, prompt for confirmation

### Diff Display

Use `diff -u` for unified diff format:
```
--- tokens.css (local v0.3.35)
+++ tokens.css (remote v0.3.36)
@@ -102,6 +102,10 @@
   --color-primary: #fafafa;
+  --color-primary-hover: #f0f0f0;
```

### Tailwind CSS 4 Integration Guidance

Display after successful install:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ Design tokens installed to src/styles/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:

1. Import tokens in your CSS entry point (e.g., globals.css):

   @import "tailwindcss";
   @import "./tokens.css";

2. Map tokens to Tailwind theme in globals.css:

   @theme inline {
     --color-background: var(--background);
     --color-foreground: var(--foreground);
     --color-primary: var(--primary);
     --color-primary-foreground: var(--primary-foreground);
     /* See FRONTEND-STANDARDS.md for complete mapping */
   }

3. Set theme on your HTML element:

   <html data-direction="precision">

   Available themes: precision, warmth, sophistication,
                     boldness, utility, data

📚 Full documentation: docs/standards/FRONTEND-STANDARDS.md
```

## Implementation Phases

### Phase 1: Project Detection

```markdown
## Step 1: Detect Project Type

1. Check for package.json in current directory
2. If not found: prompt user for target directory
3. Parse package.json:
   - Check dependencies for "next" → Next.js
   - Check devDependencies for "vite" → Vite
   - Neither → Unknown, prompt for directory
```

### Phase 2: Directory Resolution

```markdown
## Step 2: Resolve Target Directory

Based on project type:

**Next.js:**
1. Check for src/app/ → use src/styles/ (create if needed)
2. Check for app/ → use styles/ (create if needed)
3. Check for src/styles/ → use it
4. Fallback: prompt user

**Vite:**
1. Check for src/styles/ → use it
2. Check for src/ → create src/styles/
3. Fallback: prompt user

**Unknown:**
- Prompt: "Where should I install the design tokens?"
- Default suggestion: ./styles/
```

### Phase 3: Download Tokens

```markdown
## Step 3: Download Tokens from GitHub

1. Construct URLs:
   - CSS: https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.css
   - JSON: https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.json

2. Download with curl:
   ```bash
   curl -fsSL -o /tmp/wdi-tokens.css "$CSS_URL"
   curl -fsSL -o /tmp/wdi-tokens.json "$JSON_URL"
   ```

3. Verify downloads:
   - Check exit code
   - Verify file size > 0
   - Check not HTML (error page)

4. Get version from plugin.json:
   ```bash
   VERSION=$(curl -fsSL "https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/.claude-plugin/plugin.json" | jq -r '.version')
   ```
```

### Phase 4: Check for Existing Files

```markdown
## Step 4: Handle Existing Installation

1. Check if target/tokens.css exists:
   - No → proceed to Phase 5
   - Yes → check version

2. Extract local version from header comment:
   ```bash
   LOCAL_VERSION=$(head -5 target/tokens.css | grep -oP 'v\K[0-9.]+')
   ```

3. Compare versions:
   - Same → "Already up to date (v$VERSION)"
   - Different → show diff and prompt

4. If different, show diff:
   ```bash
   diff -u target/tokens.css /tmp/wdi-tokens.css | head -50
   ```

5. Prompt user:
   - [Update] - Overwrite with new version
   - [Skip] - Keep current version
   - [View full diff] - Show complete diff
```

### Phase 5: Install Tokens

```markdown
## Step 5: Copy Files with Version Metadata

1. Create target directory if needed:
   ```bash
   mkdir -p "$TARGET_DIR"
   ```

2. Prepend version header to CSS:
   ```bash
   cat > "$TARGET_DIR/tokens.css" << EOF
   /**
    * WDI Design Tokens v$VERSION
    * Downloaded: $(date +%Y-%m-%d)
    * Source: https://github.com/whitedoeinn/dev-plugins-workflow
    *
    * To update: run /wdi:frontend-setup
    */

   EOF
   cat /tmp/wdi-tokens.css >> "$TARGET_DIR/tokens.css"
   ```

3. Add meta field to JSON:
   ```bash
   jq --arg v "$VERSION" --arg d "$(date -Iseconds)" \
     '. + {"_wdiMeta": {"version": $v, "downloadedAt": $d}}' \
     /tmp/wdi-tokens.json > "$TARGET_DIR/tokens.json"
   ```
```

### Phase 6: Show Integration Guidance

```markdown
## Step 6: Display Next Steps

Show framework-specific integration guidance:

**Next.js / Vite with Tailwind:**
- How to import in globals.css
- @theme inline mapping example
- How to set data-direction attribute

**Reference:**
- Link to FRONTEND-STANDARDS.md
- List available themes
```

## Acceptance Criteria

- [x] `commands/frontend-setup.md` created
- [x] Downloads tokens.css and tokens.json from GitHub raw URL
- [x] Detects Next.js and Vite projects from package.json
- [x] Prompts for directory when project type unknown
- [x] Creates target directory if it doesn't exist
- [x] Adds version metadata to downloaded files
- [x] Shows diff and prompts before overwriting existing files
- [x] Displays Tailwind CSS 4 integration guidance
- [x] Documents command in CLAUDE.md

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `commands/frontend-setup.md` | Create | The command implementation |
| `CLAUDE.md` | Edit | Add to commands table |

## Flags

| Flag | Description |
|------|-------------|
| `--force` | Skip confirmation, overwrite existing files |
| `--directory <path>` | Specify target directory manually |

## Error Handling

| Error | Message | Recovery |
|-------|---------|----------|
| No network | "Cannot reach GitHub. Check your internet connection." | Retry or abort |
| No package.json | "No package.json found. Specify target directory with --directory" | Prompt for path |
| Permission denied | "Cannot write to {path}. Check permissions." | Suggest sudo or different path |
| Download failed | "Failed to download tokens. GitHub may be rate-limiting." | Retry after delay |

## Testing

1. **Fresh Next.js project** - Verify detection and installation
2. **Fresh Vite project** - Verify detection and installation
3. **Existing installation** - Verify diff and update flow
4. **No package.json** - Verify prompt for directory
5. **Network failure** - Verify error message

## Dependencies

- Requires `curl` (standard on macOS/Linux)
- Requires `jq` (installed by wdi via check-deps.sh)
- GitHub raw URL must be accessible

## References

### Internal
- `assets/tokens/tokens.css` - Source file (500 lines, 6 themes)
- `assets/tokens/tokens.json` - Source file (290 lines)
- `docs/standards/FRONTEND-STANDARDS.md` - Integration documentation
- `commands/standards-new-repo.md` - Pattern for interview-driven commands

### External
- [shadcn/ui CLI](https://ui.shadcn.com/docs/cli) - Copy pattern inspiration
- [Tailwind CSS 4 @theme](https://tailwindcss.com/docs/theme) - Integration target

## Decision Record

**Why download from GitHub instead of plugin cache?**
Plugin cache path includes version number (`~/.claude/plugins/cache/wdi-marketplace/wdi/0.3.36/`) which changes on every update. GitHub raw URL is stable.

**Why copy instead of symlink?**
Symlinks to plugin cache break when cache is cleared or plugin updates. Copy gives users ownership per shadcn pattern.

**Why version metadata in files?**
Enables detecting installed version for update flow. Without it, we can't know if user needs update.

**Why prompt for directory when unknown?**
Can't safely guess. Better to ask than install to wrong location.
