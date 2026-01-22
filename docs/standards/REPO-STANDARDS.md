# Repository Naming Standards

**Organization:** whitedoeinn
**Last Updated:** 2026-01-22

---

## Core Principles

1. **Cluster by function, not by project** — Related tools live together in mono-repos; standalone repos are the exception.

2. **No redundant prefixes** — The org name `whitedoeinn` already provides context. Don't prefix repos with `wdi-`.

3. **Lowercase with hyphens** — Always `marketing-ops`, never `Marketing_Ops` or `marketingOps`.

4. **Scope is implicit** — All repos in this org are private and internal to White Doe Inn. No need for `internal-` prefixes.

5. **Plugins are standalone** — Any project that gets installed into other projects (Claude Code plugins) lives in its own repo.

6. **URL stability** — Renaming repositories breaks downstream links, bookmarks, and CI integrations. Choose names that can remain stable for years. Treat repo names as permanent once created.

---

## Taxonomy

These terms have specific meanings in this organization. Use them consistently.

| Term | Definition | Example |
|------|------------|---------|
| **Repository** | Git repo, outermost container | `business-ops` |
| **Subproject** | Top-level unit in a mono-repo, organized by functional type | `tools/task-manager/` |
| **Module** | Logical grouping within a subproject by feature or concern | `src/tasks/`, `src/export/` |
| **Component** | Smallest reusable unit of code | `TaskList.js`, `task-lib.js` |

**Why these terms:**
- **Repository** is universal and clear
- **Subproject** emphasizes these are meaningful, self-contained pieces (avoids npm/cargo connotations of "package")
- **Module** follows common programming conventions
- **Component** is widely understood

---

## Functional Types

Every subproject has a **functional type** that determines its directory location and characteristics.

| Type | Definition | Directory | Standalone Repo? |
|------|------------|-----------|------------------|
| **Application** | User-facing software with UI | `apps/` | Sometimes |
| **Service** | Backend process, typically an API | `services/` | Sometimes |
| **Library** | Shared code imported by others | `libs/` | Rarely (Git-based install) |
| **Tool** | CLI or automation script | `tools/` | Sometimes |
| **Plugin** | Extends another system (Claude Code) | `plugins/` or standalone | Always standalone |

### Type Characteristics

| Type | Has UI? | Long-running? | Consumed by? |
|------|---------|---------------|--------------|
| Application | Yes | Yes | End users |
| Service | No | Yes | Other code via API |
| Library | No | No | Imported into other code |
| Tool | CLI/minimal | No | Run on-demand by users |
| Plugin | Sometimes | No | Host system (Claude Code) |

### Choosing Between Types

- **Tool vs Application**: Tools are CLI-first and run-to-completion. Applications have persistent UI and run continuously.
- **Tool vs Library**: Tools are invoked directly. Libraries are imported by other code.
- **Service vs Library**: Services run independently and communicate via network. Libraries are linked into other processes.

---

## Internal-Only Model

All libraries and shared code in this organization are **internal-only**.

### Key Characteristics

- **No public registry publishing** — We don't publish to npm, PyPI, RubyGems, etc.
- **Git-based installation** — Consuming projects install via Git URLs
- **Internal consumers only** — All code is private to White Doe Inn
- **Simpler versioning** — Can use branches/tags instead of semver for internal libs

### Installation Patterns

```bash
# npm - install from mono-repo subdirectory
npm install git+ssh://git@github.com/whitedoeinn/business-ops.git#tools/task-manager

# Python - install from Git
pip install git+ssh://git@github.com/whitedoeinn/business-ops.git#subdirectory=libs/shared-utils

# Direct script sourcing
source <(curl -sSL https://raw.githubusercontent.com/whitedoeinn/business-ops/main/scripts/shared.sh)
```

### Exceptions (Standalone Repos)

These warrant their own repos despite internal-only model:

| Type | Why Standalone |
|------|----------------|
| **Plugins** | External install pattern (`curl \| bash`), independent versioning |
| **Large applications** | Own CI/CD pipeline, team ownership |

---

## Repository Structure

### Clusters (Mono-repos)

| Repo | Purpose | Contains |
|------|---------|----------|
| `marketing-ops` | Marketing intelligence and automation | Dashboard, APIs (GA4, Google Ads, Mailchimp, SEO tools), CLIs |
| `business-ops` | Business operations automation | Task management tools, events, bookkeeping, future guest tools |
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

## Word Choice and Abbreviations

Use full words when possible to maximize clarity and searchability.

### Acceptable Abbreviations

Only abbreviate universally understood terms:

| Abbreviation | Full Word | OK to Use |
|--------------|-----------|-----------|
| `api` | Application Programming Interface | Always |
| `cli` | Command Line Interface | Always |
| `db` | Database | Always |
| `ui` | User Interface | Always |
| `auth` | Authentication | Context-dependent |
| `config` | Configuration | Context-dependent |
| `docs` | Documentation | Always |
| `ops` | Operations | Always |
| `libs` | Libraries | Always |
| `apps` | Applications | Always |

### Avoid These Abbreviations

| Avoid | Use Instead | Why |
|-------|-------------|-----|
| `mgmt` | `management` | Not universally recognized |
| `util` | `utilities` | Vague |
| `misc` | (be specific) | Meaningless |
| `tmp` | `temporary` | Unclear lifespan |
| `svc` | `service` | Saves only 4 characters |
| `pkg` | `packages` | Ambiguous across ecosystems |

### Length Guidelines

- **Repo names:** 3-5 words, max 30 characters
- **Subproject names:** 1-3 words, max 20 characters
- **Prefer clarity over brevity** — `guest-reservation-api` beats `gra`

---

## Mono-repo Internal Structure

```
{repo}/
├── README.md
├── CLAUDE.md               # Claude instructions for this repo
│
├── apps/                   # User-facing applications
│   └── {app-name}/
│
├── services/               # Backend APIs
│   └── {service-name}/
│
├── libs/                   # Shared libraries (internal only)
│   └── {lib-name}/
│
├── tools/                  # CLIs and automation scripts
│   └── {tool-name}/
│
├── shared/                 # Repo-internal utilities (not cross-repo)
│   └── {util-name}/
│
├── docs/
│   ├── architecture.md
│   ├── changelog.md
│   └── project-status.md
│
└── scripts/                # Build, deploy, dev tooling
```

### Subproject Structure

Each subproject follows a consistent internal structure:

```
{type}/{subproject-name}/
├── README.md               # Subproject docs
├── CLAUDE.md               # Claude instructions (if needed)
├── src/                    # Source code
│   └── {module}/           # Feature/concern groupings
├── tests/                  # Tests
├── package.json            # Or pyproject.toml, Cargo.toml, etc.
└── ...
```

### Subproject Naming

Inside mono-repos, subprojects are named by what they do:

```
marketing-ops/
├── apps/
│   └── dashboard/          # Marketing dashboard UI
├── services/
│   ├── api-google-ads/     # Google Ads API integration
│   ├── api-ga4/            # GA4 API integration
│   └── api-mailchimp/      # Mailchimp API integration
├── tools/
│   └── cli/                # Marketing CLI tool
└── libs/
    └── analytics-core/     # Shared analytics utilities

business-ops/
├── tools/
│   └── task-manager/       # Task management CLI
├── projects/               # Business project data (not code)
│   ├── kitchen-remodel/
│   └── inn-maintenance/
└── libs/
    └── shared-utils/       # Common utilities
```

### The `shared/` vs `libs/` Distinction

| Directory | Scope | Example |
|-----------|-------|---------|
| `shared/` | Repo-internal only | Build scripts, test helpers |
| `libs/` | Cross-repo consumption | Utilities installed via Git URL |

---

## Migration History

| From | To | Status |
|------|-----|--------|
| `wdi-content` | `marketing-ops` | Pending - Rename, restructure as mono-repo |
| `wdi-workflows` plugin | `wdi` plugin | Complete - Renamed in v1.0.0 |
| `wdi-workflows` repo | `dev-plugins-workflow` | Complete |
| Marketing Dashboard (local) | `marketing-ops/apps/dashboard` | Pending - Move into mono-repo |

---

## Decision Record

### Why mono-repos for clusters?

- Atomic changes across related subprojects
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

### Why type-based directories instead of flat `packages/`?

- Communicates intent at a glance (`tools/task-manager` vs `packages/task-manager`)
- Enables type-specific tooling and CI rules
- Matches how we think about the code
- Scales better as repos grow

### Why "subproject" instead of "package"?

- "Package" implies npm/PyPI/cargo publishing, which we don't do
- "Subproject" emphasizes self-contained, meaningful units
- Avoids ecosystem-specific connotations
- More intuitive for non-developers

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

### Good Subproject Names

```
tools/task-manager          # CLI tool for task management
apps/dashboard              # Marketing dashboard application
services/api-ga4            # GA4 API integration service
libs/analytics-core         # Shared analytics library
```

### Bad Subproject Names

```
packages/task-manager       # Wrong directory (should be tools/)
lib/utils                   # Too generic
tools/task-manager-v2       # Version in name
```

---

## Future Repos

When creating a new repo, ask:

1. **Does it belong in an existing cluster?** → Add as a subproject to the mono-repo
2. **Is it installed into other projects?** → Standalone repo (plugins)
3. **Is it a new business domain?** → Consider a new cluster mono-repo
4. **Is it experimental?** → Prefix with `experiment-`, delete or promote within 90 days

---

## Guest-Facing Projects (Future)

When guest-facing applications are developed (guidebook, surveys, portal), they will live in `business-ops/apps/guest-*` unless scale warrants a separate `guest-ops` cluster.

Criteria for splitting into `guest-ops`:
- 3+ guest-facing applications
- Different deployment pipeline than internal tools
- Different team/contractor ownership

---

## Deprecation and Archival

When retiring a repository, follow this process to minimize disruption.

### Deprecation Process

1. **Announce deprecation** — Update README with deprecation notice and timeline
2. **Add `archived-` prefix** — Rename repo to `archived-{original-name}`
3. **Add redirect notice** — README should point to replacement (if any)
4. **Archive in GitHub** — Use GitHub's archive feature to make read-only
5. **Retain for reference** — Don't delete; archived repos serve as documentation

### README Deprecation Template

```markdown
# ARCHIVED

This repository was archived on YYYY-MM-DD.

**Replacement:** [new-repo-name](link) (if applicable)
**Reason:** Brief explanation

---

# Original README content below...
```

### Naming During Deprecation

| Stage | Name | Status |
|-------|------|--------|
| Active | `marketing-dashboard` | Normal use |
| Deprecated | `marketing-dashboard` | README notice, still functional |
| Archived | `archived-marketing-dashboard` | Read-only, GitHub archived |

### When to Archive vs Delete

| Action | When |
|--------|------|
| **Archive** | Default. Preserves history and links for reference |
| **Delete** | Only for experiments that produced nothing useful, or security incidents |

**Note:** Archived repos still count toward GitHub limits but don't clutter active repo lists.
