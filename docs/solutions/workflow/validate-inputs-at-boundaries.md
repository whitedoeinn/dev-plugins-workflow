---
title: Validate Inputs at Workflow Boundaries
category: workflow
tags:
  - validation
  - error-handling
  - user-experience
component: wdi-plugin
date_resolved: 2026-01-24
related_issues:
  - "#85"
learnings:
  - Always validate external inputs (issue numbers, file paths) before proceeding
  - Helpful error messages should suggest next actions, not just state the problem
  - Small, focused changes are easier to review and ship
---

# Validate Inputs at Workflow Boundaries

## Problem

When `/wdi:workflow-feature #9999` was run with a non-existent issue number, the workflow failed with a cryptic `gh` CLI error. Users got no guidance on what went wrong or what to do next.

## Solution

Added validation step after fetching issue state. If the issue doesn't exist, show a helpful error with suggestions:

```
Issue Not Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issue #9999 does not exist in this repository.

To see your ideas: gh issue list --label idea
To create new: /wdi:workflow-feature
```

## What We Learned

### 1. Validate at Boundaries

Workflows that accept external input (issue numbers, file paths, user input) should validate early and fail fast with helpful messages. Don't let cryptic tool errors reach the user.

### 2. Error Messages Should Suggest Actions

"Issue not found" is unhelpful. "Issue not found. Try X or Y" gives users a path forward.

### 3. Small Changes Ship Faster

This was a 16-line addition. Small, focused changes are:
- Easier to review (no P1/P2/P3 findings)
- Lower risk
- Faster to compound and ship

## Prevention

When adding workflow steps that depend on external resources:
1. Check if the resource exists before using it
2. Provide helpful error messages with next actions
3. Exit gracefully rather than letting downstream failures cascade
