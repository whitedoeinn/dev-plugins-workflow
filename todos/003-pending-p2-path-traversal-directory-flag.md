---
status: pending
priority: p2
issue_id: "003"
tags: [code-review, security, frontend-setup]
dependencies: []
---

# Path Traversal Vulnerability via --directory Flag

## Problem Statement

The `--directory <path>` flag accepts arbitrary user input that is passed directly to `mkdir -p` and file write operations without validation or sanitization.

**Why it matters:** A user (intentionally or through copy-paste errors) could write files to sensitive locations outside the project.

## Findings

**Location:** `commands/frontend-setup.md`, Lines 14-15, 174, 180

**Vulnerable Pattern:**
```bash
mkdir -p "$TARGET_DIR"
cat > "$TARGET_DIR/tokens.css" << EOF
```

**Exploitation Scenarios:**
```bash
/wdi:frontend-setup --directory /etc/cron.d
/wdi:frontend-setup --directory ../../../sensitive-location
/wdi:frontend-setup --directory /home/user/.ssh
```

## Proposed Solutions

### Option A: Validate path is within project root (Recommended)

**Pros:** Prevents accidental or malicious writes outside project
**Cons:** Restricts legitimate use cases (though rare)
**Effort:** Small
**Risk:** Low

```bash
# Validate target directory
TARGET_DIR=$(realpath -m "$TARGET_DIR" 2>/dev/null) || { echo "ERROR: Invalid path"; exit 1; }

# Ensure path is within current project
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [[ ! "$TARGET_DIR" =~ ^"$PROJECT_ROOT" ]]; then
  echo "ERROR: Target directory must be within the project root"
  echo "Specified: $TARGET_DIR"
  echo "Project root: $PROJECT_ROOT"
  exit 1
fi
```

### Option B: Warn but allow with confirmation

**Pros:** Flexible, preserves edge case uses
**Cons:** User could still proceed with dangerous path
**Effort:** Small
**Risk:** Medium

```bash
if [[ ! "$TARGET_DIR" =~ ^"$PROJECT_ROOT" ]]; then
  echo "WARNING: Target is outside project root"
  # Use AskUserQuestion to confirm
fi
```

## Recommended Action

<!-- Fill in during triage -->

## Technical Details

**Affected files:**
- `commands/frontend-setup.md` (Lines 14-15, 174, 180)

**Components affected:**
- Phase 2: Resolve Target Directory
- Phase 5: Install Tokens

## Acceptance Criteria

- [ ] Paths with `..` components are rejected or require confirmation
- [ ] Absolute paths outside project root are rejected or require confirmation
- [ ] Normal relative paths within project work without issues
- [ ] Error message clearly explains the restriction

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Identified via security-sentinel review | User-provided paths always need validation |

## Resources

- OWASP Path Traversal: https://owasp.org/www-community/attacks/Path_Traversal
