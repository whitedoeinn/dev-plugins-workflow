# Repository Naming Standards

**Organization:** whitedoeinn  
**Last Updated:** 2026-01-11

---

## Core Principles

1. **Cluster by function, not by project** — Related tools live together in mono-repos; standalone repos are the exception.

2. **No redundant prefixes** — The org name `whitedoeinn` already provides context. Don't prefix repos with `wdi-`.

3. **Lowercase with hyphens** — Always `marketing-ops`, never `Marketing_Ops` or `marketingOps`.

4. **Scope is implicit** — All repos in this org are private and internal to White Doe Inn. No need for `internal-` prefixes.

5. **Plugins are standalone** — Any project that gets installed into other projects (Claude Code plugins) lives in its own repo.

---

## Repository Structure

### Clusters (Mono-repos)

| Repo | Purpose | Contains |
|------|---------|----------|
| `marketing-ops` | Marketing intelligence and automation | Dashboard, APIs (GA4, Google Ads, Mailchimp, SEO tools), CLIs |
| `business-ops` | Business operations automation | Events, Bookkeeping/QBO, future guest tools |
| `knowledge-base` | Research and education | Research spikes, training materials, competitive analysis (content only) |

### Standalone Repos

| Repo | Purpose | Why standalone |
|------|---------|----------------|
| `dev-plugins-workflow` | Claude Code workflow plugin | Installed via `curl \| bash`, needs independent versioning |
| `dev-plugins-frontend` | Claude Code front-end plugin | Same |
| `dev-plugins-backend` | Claude Code back-end plugin | Same |
| `dev-plugins-analytics` | Claude Code analytics plugin | Same |

---

## Naming Format

```
{cluster}-{scope}       # Mono-repos: marketing-ops, business-ops
{type}-{domain}-{name}  # Standalone: dev-plugins-workflow
```

### Cluster Names

| Cluster | Use for |
|---------|---------|
| `marketing-*` | Marketing systems, analytics, content |
| `business-*` | Operations, finance, events, guest services |
| `dev-*` | Development tooling, plugins, automation |
| `knowledge-*` | Research, education, documentation |

### Type Names (for standalone repos)

| Type | Use for |
|------|---------|
| `plugins` | Claude Code plugins |
| `tools` | Standalone utilities |
| `docs` | Documentation-only repos |

---

## Mono-repo Internal Structure

```
{repo}/
├── README.md
├── packages/
│   ├── {package-a}/
│   ├── {package-b}/
│   └── {package-c}/
├── shared/              # Common utilities across packages
├── docs/
│   ├── architecture.md
│   ├── changelog.md
│   └── project-status.md
└── scripts/             # Build, deploy, dev tooling
```

### Package Naming

Inside mono-repos, packages are named by what they do:

```
marketing-ops/
├── packages/
│   ├── dashboard/
│   ├── api-google-ads/
│   ├── api-ga4/
│   ├── api-mailchimp/
│   └── cli/

business-ops/
├── packages/
│   ├── events/
│   ├── bookkeeping/
│   └── guest-tools/
```

---

## Migration History

| From | To | Status |
|------|-----|--------|
| `wdi-content` | `marketing-ops` | Pending - Rename, restructure as mono-repo |
| `wdi-workflows` plugin | `wdi` plugin | Complete - Renamed in v1.0.0 |
| `wdi-workflows` repo | `dev-plugins-workflow` | Complete |
| Marketing Dashboard (local) | `marketing-ops/packages/dashboard` | Pending - Move into mono-repo |

---

## Decision Record

### Why mono-repos for clusters?

- Atomic changes across related packages
- Simpler dependency management
- Easier refactoring
- Single CI/CD pipeline
- Can always split later if needed

### Why standalone repos for plugins?

- External consumers install via URL
- Need independent semantic versioning
- Clean `curl | bash` install pattern
- Stable URLs for documentation

### Why no `internal-` prefix?

- All repos in this org are private by default
- The prefix adds noise without information
- If something becomes public/productized, it moves to a different org

---

## Examples

### Good Names

```
marketing-ops           # Mono-repo for marketing cluster
business-ops            # Mono-repo for business cluster
dev-plugins-workflow    # Standalone Claude Code plugin
knowledge-base          # Research and education content
```

### Bad Names

```
wdi-marketing-dashboard     # Redundant prefix
internal-ops                # Vague, unnecessary scope prefix
dashboard                   # Too generic
marketing-dashboard-v2      # Version in name
dave-scripts                # Personal name
```

---

## Future Repos

When creating a new repo, ask:

1. **Does it belong in an existing cluster?** → Add as a package to the mono-repo
2. **Is it installed into other projects?** → Standalone repo
3. **Is it a new business domain?** → Consider a new cluster mono-repo
4. **Is it experimental?** → Prefix with `experiment-`, delete or promote within 90 days

---

## Guest-Facing Projects (Future)

When guest-facing applications are developed (guidebook, surveys, portal), they will live in `business-ops/packages/guest-*` unless scale warrants a separate `guest-ops` cluster.

Criteria for splitting into `guest-ops`:
- 3+ guest-facing packages
- Different deployment pipeline than internal tools
- Different team/contractor ownership
