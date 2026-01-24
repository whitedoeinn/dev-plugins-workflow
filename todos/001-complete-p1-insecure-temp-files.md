---
status: pending
priority: p1
issue_id: "001"
tags: [code-review, security, frontend-setup]
dependencies: []
---

# Insecure Temporary File Handling

## Problem Statement

The `/wdi:frontend-setup` command uses predictable paths in `/tmp/` for temporary files without creating unique filenames. This creates a security vulnerability where attackers can exploit symlink attacks or race conditions.

**Why it matters:** On multi-user systems, an attacker could pre-create `/tmp/wdi-tokens.css` as a symlink to a sensitive file (e.g., `~/.bashrc`), causing the curl download to overwrite the victim's file.

## Findings

**Location:** `commands/frontend-setup.md`, Lines 113-117, 146-148, 154-157, 203-205

**Vulnerable Pattern:**
```bash
curl -fsSL -o /tmp/wdi-tokens.css "$CSS_URL"
curl -fsSL -o /tmp/wdi-tokens.json "$JSON_URL"
# ... later ...
rm -f /tmp/wdi-tokens.css /tmp/wdi-tokens.json
```

**Issues:**
1. Predictable temp file paths allow symlink attacks
2. Cleanup only happens at end - if script fails, temp files persist
3. Race condition window between download and use

## Proposed Solutions

### Option A: Use mktemp with trap cleanup (Recommended)

**Pros:** Secure, portable, guaranteed cleanup
**Cons:** Slightly more complex
**Effort:** Small
**Risk:** Low

```bash
# Create unique temp directory at start
TEMP_DIR=$(mktemp -d) || { echo "ERROR: Cannot create temp directory"; exit 1; }
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

# Use temp directory for all downloads
curl -fsSL -o "$TEMP_DIR/tokens.css" "$CSS_URL"
curl -fsSL -o "$TEMP_DIR/tokens.json" "$JSON_URL"
```

### Option B: Use process ID in temp names

**Pros:** Simple change
**Cons:** Less secure than mktemp, no trap cleanup
**Effort:** Minimal
**Risk:** Medium

```bash
TEMP_PREFIX="/tmp/wdi-tokens-$$"
curl -fsSL -o "${TEMP_PREFIX}.css" "$CSS_URL"
```

## Recommended Action

<!-- Fill in during triage -->

## Technical Details

**Affected files:**
- `commands/frontend-setup.md` (Lines 113-117, 146-148, 154-157, 203-205)

**Components affected:**
- Phase 3: Check for Existing Installation
- Phase 4: Download Tokens
- Phase 5: Install Tokens (cleanup)

## Acceptance Criteria

- [ ] Temp files use unique, unpredictable paths
- [ ] Temp files are cleaned up even on script failure/interruption
- [ ] No symlink attack vulnerability exists
- [ ] Works on both macOS and Linux

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Identified via security-sentinel review | Predictable temp paths are a common security issue |

## Resources

- PR: N/A (pre-commit review)
- Related: shadcn CLI uses similar temp file patterns but with mktemp
