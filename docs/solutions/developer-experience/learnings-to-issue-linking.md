---
title: Auto-Post Learnings to GitHub Issue
date: 2026-01-18
category: developer-experience
tags:
  - compound
  - github
  - documentation
  - workflow
component: workflows-feature.md
severity: low
problem_type: developer-experience
symptoms:
  - Learnings documented but not linked to issues
  - Issue closed with minimal context
  - Future searchers can't find learnings from issues
root_cause: No bidirectional linking between solution docs and GitHub issues
solution_approach: Add Step 1.5 to post learnings comment after compound completes
files_modified:
  - commands/workflows-feature.md
related_issues:
  - "#49"
learnings:
  - Bidirectional links compound discoverability
  - Small workflow additions can significantly improve knowledge retrieval
  - YAML frontmatter learnings array enables structured extraction
---

# Auto-Post Learnings to GitHub Issue

## Problem

After `/workflows:compound` generates a solution doc in `docs/solutions/`, the learnings are:
- Documented in markdown but not linked to the GitHub issue
- Issue gets closed with just a commit SHA
- Future searchers on GitHub can't find the associated learnings

## Solution

Add Step 1.5 to Phase 6 of `/wdi:workflows-feature` that:
1. Reads the generated solution doc
2. Extracts learnings from YAML frontmatter
3. Posts a structured comment to the feature issue

This creates bidirectional linking:
- **Issue → Doc**: Comment includes link to solution doc
- **Doc → Issue**: YAML frontmatter includes `related_issues`

## Implementation

Added to `commands/workflows-feature.md` after Step 1 (compound) and before Step 2 (commit):

```markdown
### Step 1.5: Add Learnings to Issue

1. Read the generated solution doc
2. Extract learnings from YAML frontmatter
3. Post comment to feature issue with:
   - Link to solution doc
   - Bulleted learnings
   - Prevention section (if any)
```

## Learnings

1. **Bidirectional links compound discoverability.** Someone searching GitHub issues finds the learnings. Someone reading docs finds the issue context.

2. **Small workflow additions can significantly improve knowledge retrieval.** This is ~30 lines of documentation but fundamentally changes how knowledge is accessed.

3. **YAML frontmatter enables structured extraction.** The `learnings` array in frontmatter can be programmatically extracted and formatted.

## Prevention

When adding new documentation workflows:
- Always consider bidirectional linking
- Use structured formats (YAML frontmatter) for machine-readable extraction
- Link to the originating issue/PR for context
