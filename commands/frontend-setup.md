---
description: Install WDI design tokens to project following shadcn copy pattern
---

# /wdi:frontend-setup - Install Design Tokens

Download and install WDI design tokens to your project. Tokens are copied locally (you own them), and updates are opt-in.

## Flags

| Flag | Description |
|------|-------------|
| `--force` | Skip confirmation, overwrite existing files |
| `--directory <path>` | Specify target directory manually |

---

## Workflow

### Phase 1: Detect Project Type

Check for `package.json` to determine project type and target directory.

```bash
# Check if package.json exists
if [[ ! -f "package.json" ]]; then
  # No package.json - prompt for directory
  PROMPT_DIR=true
fi
```

**Detection logic:**

```bash
# Parse package.json for framework
if jq -e '.dependencies.next' package.json > /dev/null 2>&1; then
  PROJECT_TYPE="nextjs"
elif jq -e '.devDependencies.vite' package.json > /dev/null 2>&1; then
  PROJECT_TYPE="vite"
else
  PROJECT_TYPE="unknown"
fi
```

**If no package.json or unknown type:**

Use `AskUserQuestion` to prompt:

```
Where should I install the design tokens?
```

| Option | Description |
|--------|-------------|
| `src/styles/` | Standard source directory (Recommended) |
| `styles/` | Root styles directory |
| `app/` | Next.js App Router directory |
| Other | Enter custom path |

---

### Phase 2: Resolve Target Directory

Based on project type, determine where to install tokens.

**Next.js:**
1. Check for `src/app/` directory → use `src/styles/`
2. Check for `app/` directory → use `styles/`
3. Check for `src/styles/` → use it
4. Fallback: prompt user

**Vite:**
1. Check for `src/styles/` → use it
2. Check for `src/` → create `src/styles/`
3. Fallback: prompt user

**Display chosen directory:**

```
Target directory: src/styles/
```

---

### Phase 3: Check for Existing Installation

If `tokens.css` already exists in target directory:

1. **Extract installed version** from header comment:
   ```bash
   LOCAL_VERSION=$(head -10 "$TARGET_DIR/tokens.css" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
   ```

2. **Fetch remote version** from GitHub:
   ```bash
   REMOTE_VERSION=$(curl -fsSL "https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/.claude-plugin/plugin.json" | jq -r '.version')
   ```

3. **Compare versions:**

   **If same version:**
   ```
   Design tokens already up to date (v0.3.36)
   ```
   Exit successfully.

   **If different version:**
   Show diff and prompt for confirmation (unless `--force`).

4. **Show diff preview:**
   ```bash
   # Create secure temp directory
   TEMP_DIR=$(mktemp -d) || { echo "ERROR: Cannot create temp directory"; exit 1; }
   trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

   # Download to temp for comparison
   curl -fsSL -o "$TEMP_DIR/tokens-new.css" "$CSS_URL"

   echo "Changes from v$LOCAL_VERSION to v$REMOTE_VERSION:"
   echo "────────────────────────────────────────────────"
   diff -u "$TARGET_DIR/tokens.css" "$TEMP_DIR/tokens-new.css" | head -30
   ```

5. **Prompt user** (skip if `--force`):

   Use `AskUserQuestion`:
   ```
   Update design tokens from v{LOCAL_VERSION} to v{REMOTE_VERSION}?
   ```

   | Option | Description |
   |--------|-------------|
   | Update | Overwrite with new version |
   | Skip | Keep current version |
   | View full diff | Show complete diff before deciding |

---

### Phase 4: Download Tokens

Download both token files from GitHub raw URLs:

```bash
# URLs (note: repository name is dev-plugins-workflows with 's')
CSS_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.css"
JSON_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.json"
VERSION_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/.claude-plugin/plugin.json"

# Create secure temp directory (if not already created in Phase 3)
if [[ -z "$TEMP_DIR" ]]; then
  TEMP_DIR=$(mktemp -d) || { echo "ERROR: Cannot create temp directory"; exit 1; }
  trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM
fi

# Download to secure temp directory
curl -fsSL -o "$TEMP_DIR/tokens.css" "$CSS_URL"
curl -fsSL -o "$TEMP_DIR/tokens.json" "$JSON_URL"
VERSION=$(curl -fsSL "$VERSION_URL" | jq -r '.version')
```

**Verify downloads:**
```bash
# Check files exist and have content
if [[ ! -s "$TEMP_DIR/tokens.css" ]] || [[ ! -s "$TEMP_DIR/tokens.json" ]]; then
  echo "ERROR: Failed to download tokens. Check your internet connection."
  exit 1
fi

# Check not HTML error page
if head -1 "$TEMP_DIR/tokens.css" | grep -q "<!DOCTYPE"; then
  echo "ERROR: Received error page instead of tokens. GitHub may be rate-limiting."
  exit 1
fi
```

---

### Phase 5: Install Tokens

Create target directory and install files with version metadata.

**Create directory:**
```bash
mkdir -p "$TARGET_DIR"
```

**Install tokens.css with version header:**

```bash
cat > "$TARGET_DIR/tokens.css" << EOF
/**
 * WDI Design Tokens v$VERSION
 * Downloaded: $(date +%Y-%m-%d)
 * Source: https://github.com/whitedoeinn/dev-plugins-workflow
 *
 * To update: run /wdi:frontend-setup
 * Documentation: docs/standards/FRONTEND-STANDARDS.md
 */

EOF
cat "$TEMP_DIR/tokens.css" >> "$TARGET_DIR/tokens.css"
```

**Install tokens.json with metadata:**

```bash
# Use portable date format (works on both GNU and BSD date)
jq --arg v "$VERSION" --arg d "$(date +%Y-%m-%dT%H:%M:%S%z)" \
  '. + {"_wdiMeta": {"version": $v, "downloadedAt": $d, "source": "https://github.com/whitedoeinn/dev-plugins-workflow"}}' \
  "$TEMP_DIR/tokens.json" > "$TARGET_DIR/tokens.json"
```

**Cleanup:**
```bash
# Temp directory is automatically cleaned up by trap on EXIT
# No manual cleanup needed
```

---

### Phase 6: Display Integration Guidance

Show next steps for integrating tokens with the project.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Design tokens installed to {TARGET_DIR}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files created:
  • {TARGET_DIR}/tokens.css  (CSS custom properties)
  • {TARGET_DIR}/tokens.json (machine-readable tokens)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Import tokens in your CSS entry point (e.g., globals.css):

   @import "tailwindcss";
   @import "./tokens.css";

2. Map tokens to Tailwind theme (Tailwind CSS v4):

   @theme inline {
     --color-background: var(--background);
     --color-foreground: var(--foreground);
     --color-primary: var(--primary);
     --color-primary-foreground: var(--primary-foreground);
     --color-secondary: var(--secondary);
     --color-secondary-foreground: var(--secondary-foreground);
     --color-muted: var(--muted);
     --color-muted-foreground: var(--muted-foreground);
     --color-accent: var(--accent);
     --color-accent-foreground: var(--accent-foreground);
     --color-destructive: var(--destructive);
     --color-border: var(--border);
     --color-input: var(--input);
     --color-ring: var(--ring);
     --radius-lg: var(--radius);
     --radius-md: calc(var(--radius) - 2px);
     --radius-sm: calc(var(--radius) - 4px);
   }

3. Set theme on your HTML element:

   <html data-direction="precision">

   Available themes:
   • precision   - Linear/Raycast (dark, dense, monochrome)
   • warmth      - Notion/Coda (light, friendly, soft shadows)
   • sophistication - Stripe/Mercury (cool, professional, layered)
   • boldness    - Vercel (high contrast, dramatic)
   • utility     - GitHub (functional, muted)
   • data        - Analytics (chart-optimized)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOCUMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Full standards: docs/standards/FRONTEND-STANDARDS.md
Token reference: assets/tokens/tokens.json
```

---

## Error Handling

| Error | Detection | Message |
|-------|-----------|---------|
| No network | curl fails | "Cannot reach GitHub. Check your internet connection." |
| Rate limited | HTML in response | "GitHub is rate-limiting. Try again in a few minutes." |
| Permission denied | mkdir/write fails | "Cannot write to {path}. Check directory permissions." |
| No jq | jq not found | "jq is required. Run: brew install jq" |

---

## Examples

### Fresh Installation

```
/wdi:frontend-setup

Detecting project type...
  Found: Next.js (App Router)
  Target: src/styles/

Downloading design tokens v0.3.36...
  ✓ tokens.css (500 lines, 6 themes)
  ✓ tokens.json (machine-readable)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Design tokens installed to src/styles/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Integration guidance displayed]
```

### Update Existing

```
/wdi:frontend-setup

Detecting project type...
  Found: Next.js (App Router)
  Target: src/styles/

Checking existing installation...
  Local version: v0.3.35
  Latest version: v0.3.36

Changes from v0.3.35 to v0.3.36:
────────────────────────────────
--- tokens.css (local)
+++ tokens.css (remote)
@@ -45,6 +45,8 @@
   --space-20: 5rem;
+  --space-24: 6rem;
+  --space-28: 7rem;

Update design tokens? [Update / Skip / View full diff]
> Update

Downloading design tokens v0.3.36...
  ✓ Updated tokens.css
  ✓ Updated tokens.json

Done! Tokens updated from v0.3.35 to v0.3.36.
```

### Force Update

```
/wdi:frontend-setup --force

Detecting project type...
  Found: Vite
  Target: src/styles/

Downloading design tokens v0.3.36...
  ✓ tokens.css (overwrote existing)
  ✓ tokens.json (overwrote existing)

Done!
```

### Custom Directory

```
/wdi:frontend-setup --directory ./theme

Creating directory: ./theme/

Downloading design tokens v0.3.36...
  ✓ tokens.css
  ✓ tokens.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Design tokens installed to ./theme/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Integration guidance displayed]
```

---

## Notes

- **You own the files**: Tokens are copied to your project, not linked. Modify as needed.
- **Updates are opt-in**: Run this command again to check for updates.
- **Follows shadcn pattern**: Copy to project, user owns code, explicit updates.
- **Requires jq**: Used for JSON manipulation. Install with `brew install jq`.
- **Works offline**: After first download, tokens are local. No network needed to use them.
