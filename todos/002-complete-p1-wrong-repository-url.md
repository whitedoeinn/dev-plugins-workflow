---
status: pending
priority: p1
issue_id: "002"
tags: [code-review, bug, frontend-setup]
dependencies: []
---

# Wrong Repository URL (Singular vs Plural)

## Problem Statement

The GitHub raw URLs in the command reference `dev-plugins-workflow` (singular) but the actual repository name is `dev-plugins-workflows` (plural). This will cause all downloads to fail with 404 errors.

**Why it matters:** The command will be completely non-functional in production. Users will see "Cannot reach GitHub" errors when the actual problem is a typo.

## Findings

**Location:** `commands/frontend-setup.md`, Lines 96, 141-143

**Current (Wrong):**
```bash
CSS_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.css"
JSON_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.json"
VERSION_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/.claude-plugin/plugin.json"
```

**Evidence:** Working directory path shows plural form:
```
/Users/davidroberts/github/whitedoeinn/dev-plugins-workflows
```

## Proposed Solutions

### Option A: Fix the URLs (Recommended)

**Pros:** Direct fix, immediate resolution
**Cons:** None
**Effort:** Minimal
**Risk:** None

Change all occurrences of `dev-plugins-workflow` to `dev-plugins-workflows`:
```bash
CSS_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflows/main/assets/tokens/tokens.css"
JSON_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflows/main/assets/tokens/tokens.json"
VERSION_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflows/main/.claude-plugin/plugin.json"
```

## Recommended Action

<!-- Fill in during triage -->

## Technical Details

**Affected files:**
- `commands/frontend-setup.md` (Lines 96, 141-143)

**Components affected:**
- Phase 3: Check for Existing Installation (version URL)
- Phase 4: Download Tokens (CSS and JSON URLs)

## Acceptance Criteria

- [ ] All GitHub URLs use correct repository name `dev-plugins-workflows`
- [ ] Test download of tokens.css from corrected URL succeeds
- [ ] Test download of tokens.json from corrected URL succeeds
- [ ] Test download of plugin.json (for version) from corrected URL succeeds

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Identified via code-simplicity-reviewer | Always verify URLs against actual repository names |

## Resources

- Actual repo: https://github.com/whitedoeinn/dev-plugins-workflows
