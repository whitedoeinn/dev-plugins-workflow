# Commit Message Standards

**Organization:** whitedoeinn
**Last Updated:** 2026-01-11

---

## Format

```
{type}: {Short description}

{Optional body explaining why, not what}

{Optional footer with references}
```

---

## Commit Types

| Type | Use for | Example |
|------|---------|---------|
| `feat` | New feature | `feat: Add campaign filter dropdown` |
| `fix` | Bug fix | `fix: Prevent duplicate form submissions` |
| `docs` | Documentation | `docs: Update API reference` |
| `refactor` | Code restructure | `refactor: Extract auth into service` |
| `test` | Test changes | `test: Add unit tests for UserService` |
| `chore` | Maintenance | `chore: Update dependencies` |
| `style` | Formatting | `style: Fix indentation in config` |
| `perf` | Performance | `perf: Cache API responses` |

---

## Subject Line Rules

1. **50 characters or less** (hard limit: 72)
2. **Capitalize first word** after type
3. **No period at end**
4. **Imperative mood**: "Add feature" not "Added feature"
5. **Present tense**: "Fix bug" not "Fixed bug"

### Good Subjects

```
feat: Add user authentication flow
fix: Handle null response from API
docs: Update installation instructions
refactor: Extract database connection logic
```

### Bad Subjects

```
feat: added new feature.           # Past tense, period, vague
Fix bug                            # No type prefix
feat: This commit adds a new feature that allows users to...  # Too long
```

---

## Body (Optional)

When a commit needs explanation, add a body:

```
feat: Add campaign budget alerts

Users requested notifications when campaigns approach budget limits.
This adds email alerts at 80% and 100% thresholds.

Closes #123
```

### When to Include Body

- Breaking changes
- Non-obvious "why"
- Reference to decisions or discussions
- Complex refactoring rationale

---

## Footer (Optional)

### Issue References

```
Closes #123
Fixes #456
Refs #789
```

### Breaking Changes

```
BREAKING CHANGE: Remove deprecated API endpoints

The following endpoints have been removed:
- GET /api/v1/users (use /api/v2/users)
- POST /api/v1/login (use /api/v2/auth)
```

### Co-authors

```
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

---

## Claude Code Commits

When using Claude Code, commits automatically include:

```
🤖 Generated with Claude Code

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

The `/wdi-workflows:commit` command handles this automatically.

---

## Examples

### Simple Feature

```
feat: Add export button to reports
```

### Bug Fix with Reference

```
fix: Prevent race condition in payment processing

The async payment handler was not awaiting the lock properly,
causing duplicate charges in high-traffic scenarios.

Fixes #234
```

### Breaking Change

```
refactor: Rename config keys to snake_case

BREAKING CHANGE: All config keys now use snake_case

Before: apiEndpoint, maxRetries
After: api_endpoint, max_retries

Update your .env files accordingly.
```

### Documentation Update

```
docs: Add troubleshooting section to README
```

### Multi-file Refactor

```
refactor: Extract authentication into dedicated service

Move auth logic from UserController to AuthService:
- Token generation
- Session management
- Password validation

This prepares for OAuth integration in FEAT-456.
```

---

## What NOT to Commit

- Sensitive data (API keys, passwords, tokens)
- Large binary files (use Git LFS or external storage)
- Auto-generated files (add to .gitignore)
- Editor/IDE configuration (add to .gitignore)
- macOS .DS_Store files (add to .gitignore)
