---
status: pending
priority: p2
issue_id: "004"
tags: [code-review, compatibility, frontend-setup]
dependencies: []
---

# `date -Iseconds` Not Portable on macOS

## Problem Statement

The command uses `date -Iseconds` for ISO 8601 formatting, but the `-I` flag is GNU-specific and not available on macOS's BSD date command.

**Why it matters:** The command will fail on macOS (the primary development platform for many users) when writing the JSON metadata.

## Findings

**Location:** `commands/frontend-setup.md`, Line 197

**Current (Not portable):**
```bash
jq --arg d "$(date -Iseconds)" \
  '. + {"_wdiMeta": {"version": $v, "downloadedAt": $d, ...}}'
```

**Behavior:**
- Linux (GNU date): Works, outputs `2026-01-23T21:14:00+00:00`
- macOS (BSD date): Error - `date: illegal option -- I`

## Proposed Solutions

### Option A: Use portable date format (Recommended)

**Pros:** Works on both GNU and BSD date
**Cons:** Slightly different format
**Effort:** Minimal
**Risk:** None

```bash
# Portable ISO 8601 format
jq --arg d "$(date +%Y-%m-%dT%H:%M:%S%z)" \
  '. + {"_wdiMeta": {"version": $v, "downloadedAt": $d, ...}}'
```

### Option B: Detect and use appropriate format

**Pros:** Produces identical output on both platforms
**Cons:** More complex
**Effort:** Small
**Risk:** Low

```bash
if date -Iseconds &>/dev/null; then
  DATE_ISO=$(date -Iseconds)
else
  DATE_ISO=$(date +%Y-%m-%dT%H:%M:%S%z)
fi
```

## Recommended Action

<!-- Fill in during triage -->

## Technical Details

**Affected files:**
- `commands/frontend-setup.md` (Line 197)

**Components affected:**
- Phase 5: Install Tokens (JSON metadata)

## Acceptance Criteria

- [ ] Command works on macOS without errors
- [ ] Command works on Linux without errors
- [ ] Downloaded timestamp is in ISO 8601 format
- [ ] Timestamp includes timezone information

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Identified via code-simplicity-reviewer | BSD vs GNU date differences are a common gotcha |

## Resources

- GNU vs BSD date: https://stackoverflow.com/questions/9804966
