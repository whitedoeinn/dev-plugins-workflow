---
status: complete
priority: p1
issue_id: "002"
tags: [code-review, bug, frontend-setup]
dependencies: []
---

# Wrong Repository URL - CORRECTED

## Problem Statement

The GitHub raw URLs in the command were incorrect. The initial review incorrectly identified the local directory name (`dev-plugins-workflows` plural) as the repo name, but the actual GitHub repo is `dev-plugins-workflow` (singular).

## What Happened

1. **Initial state**: URLs correctly used `dev-plugins-workflow` (singular)
2. **Review finding**: Incorrectly flagged as wrong based on local directory path
3. **Bad fix**: Changed to plural `dev-plugins-workflows`
4. **Result**: 404 errors when command ran
5. **Actual fix**: Reverted to singular `dev-plugins-workflow`

## Lesson Learned

**Never assume local directory names match GitHub repo names.** Always verify against the actual GitHub URL:
```bash
# Check actual repo name
curl -fsSL "https://api.github.com/orgs/whitedoeinn/repos" | jq -r '.[].name'
```

## Correct URLs

```bash
CSS_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.css"
JSON_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/assets/tokens/tokens.json"
VERSION_URL="https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/.claude-plugin/plugin.json"
```

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-23 | Incorrectly "fixed" to plural | Review agents can be wrong |
| 2026-01-23 | User discovered 404 in prod | Always test in real environment |
| 2026-01-23 | Reverted to correct singular | Local dir != GitHub repo name |
