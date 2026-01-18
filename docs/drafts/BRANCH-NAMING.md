# Branch Naming Standards

> **DRAFT:** This standard is not implemented. We currently work directly on main.
> See [#44](https://github.com/whitedoeinn/dev-plugins-workflow/issues/44) for the decision on whether to adopt branching.

**Organization:** whitedoeinn
**Last Updated:** 2026-01-11

---

## Branch Types

| Prefix | Use for | Example |
|--------|---------|---------|
| `feature/` | New functionality | `feature/FEAT-123-user-dashboard` |
| `fix/` | Bug fixes | `fix/456-login-redirect` |
| `hotfix/` | Urgent production fixes | `hotfix/critical-auth-bug` |
| `experiment/` | Spikes and experiments | `experiment/test-new-api` |
| `docs/` | Documentation only | `docs/update-readme` |
| `refactor/` | Code restructuring | `refactor/extract-auth-service` |
| `chore/` | Maintenance tasks | `chore/update-dependencies` |

---

## Branch Format

```
{type}/{identifier}-{short-description}
```

### With Issue/Ticket Reference

When there's a GitHub Issue or project ticket:

```
feature/FEAT-123-add-export-button
fix/789-null-pointer-exception
```

### Without Issue Reference

For quick changes without formal tracking:

```
docs/update-installation-guide
chore/upgrade-python-version
```

---

## Naming Rules

1. **Lowercase only**: `feature/add-login` not `Feature/Add-Login`
2. **Hyphens for spaces**: `user-dashboard` not `user_dashboard`
3. **Short but descriptive**: Aim for 3-5 words after prefix
4. **No special characters**: Only letters, numbers, hyphens, slashes
5. **Present tense verbs**: `add`, `fix`, `update` not `added`, `fixed`

---

## Examples

### Good Branch Names

```
feature/FEAT-42-campaign-filter-dropdown
fix/123-prevent-duplicate-submissions
hotfix/auth-token-expiry
docs/add-api-documentation
refactor/split-monolith-services
experiment/graphql-migration
chore/bump-node-version
```

### Bad Branch Names

```
feature/FEAT-42                    # Too vague
johns-changes                      # Personal name, no context
fix_the_bug                        # Underscores, vague
Feature/New-Feature                # Mixed case
feature/add-the-new-user-dashboard-component-with-charts  # Too long
```

---

## Protected Branches

| Branch | Purpose | Direct Push |
|--------|---------|-------------|
| `main` | Production code | No (PR required) |
| `develop` | Integration branch (if used) | No (PR required) |

---

## Branch Lifecycle

```
                    ┌──────────────┐
                    │  Create from │
                    │     main     │
                    └──────┬───────┘
                           │
                           ▼
┌────────────────────────────────────────────────────┐
│                  feature/FEAT-123-add-login        │
│                                                    │
│  1. Create branch: git checkout -b feature/...    │
│  2. Commit changes                                 │
│  3. Push: git push -u origin feature/...          │
│  4. Create PR                                      │
│  5. Review and merge                               │
│  6. Delete branch                                  │
└────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Merge to    │
                    │    main      │
                    └──────────────┘
```

---

## Experiment Branches

Experiment branches have special rules:

1. **Maximum 90 days**: Either promote to feature or delete
2. **No production deployment**: Experiments stay in development
3. **Clear naming**: `experiment/test-{hypothesis}`
4. **Document outcomes**: Before deleting, capture learnings
