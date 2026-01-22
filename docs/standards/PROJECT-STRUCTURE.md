# Project Structure Standards

**Organization:** whitedoeinn
**Last Updated:** 2026-01-22

---

## Mono-repo Structure

Mono-repos cluster related subprojects by functional type. Use this structure:

```
{repo}/
├── README.md                   # Repo overview, subproject list
├── CLAUDE.md                   # Claude instructions for repo
│
├── apps/                       # User-facing applications
│   └── {app-name}/
│       ├── README.md           # Subproject docs
│       ├── src/                # Source code
│       ├── tests/              # Tests
│       └── package.json        # Or pyproject.toml
│
├── services/                   # Backend APIs
│   └── {service-name}/
│
├── libs/                       # Shared libraries (internal, Git-based install)
│   └── {lib-name}/
│
├── tools/                      # CLIs and automation scripts
│   └── {tool-name}/
│
├── shared/                     # Repo-internal utilities (not cross-repo)
│   └── utils/
│
├── docs/                       # Repo-level documentation
│   ├── architecture.md         # System design
│   ├── changelog.md            # Change history
│   ├── templates/              # Document templates
│   ├── standards/              # Standards docs (if applicable)
│   └── product/                # Product documentation
│       ├── design/             # PRDs and design docs
│       └── planning/           # Features, milestones, status
│           ├── features/       # Individual feature specs
│           ├── milestones/     # Milestone definitions
│           └── status.md       # Current progress overview
│
└── scripts/                    # Build, deploy, dev tooling
    ├── build.sh
    └── dev.sh
```

### Required Files (Mono-repo)

| File | Purpose |
|------|---------|
| `README.md` | Overview, quick start, subproject list |
| `CLAUDE.md` | Claude instructions for working in this repo |
| `docs/architecture.md` | How subprojects relate, system design |
| `docs/changelog.md` | Version history |
| `{type}/{name}/README.md` | Per-subproject documentation |

### Functional Type Directories

| Directory | Contents | Cross-repo? |
|-----------|----------|-------------|
| `apps/` | User-facing applications with UI | No |
| `services/` | Backend APIs, long-running processes | No |
| `libs/` | Shared libraries | Yes (Git-based install) |
| `tools/` | CLIs, automation scripts | Sometimes |
| `shared/` | Repo-internal utilities | Never |

See [REPO-STANDARDS.md](REPO-STANDARDS.md) for detailed functional type definitions.

---

## Standalone Repo Structure

Standalone repos contain a single focused project. Use this structure:

```
{repo}/
├── README.md                   # Project overview
├── CLAUDE.md                   # Claude instructions
├── src/                        # Source code
│   └── {module}/
├── tests/                      # Test suite
├── docs/                       # Documentation
│   ├── architecture.md         # If complex enough
│   ├── changelog.md            # Version history
│   ├── templates/              # Document templates (optional)
│   └── product/                # Product docs (optional)
│       ├── design/             # PRDs
│       └── planning/           # Features, milestones
├── scripts/                    # Tooling
└── pyproject.toml              # Or package.json
```

### Required Files (Standalone)

| File | Purpose |
|------|---------|
| `README.md` | Overview, installation, usage |
| `CLAUDE.md` | Claude instructions |
| `docs/changelog.md` | Version history |

---

## Claude Code Plugin Structure

Plugins follow a specific pattern for Claude Code integration:

```
{plugin-repo}/
├── .claude-plugin/
│   ├── plugin.json             # Plugin metadata
│   └── marketplace.json        # Marketplace config
├── .claude/
│   ├── settings.json           # Local settings (gitignored)
│   └── plans/                  # Plan files (selectively tracked)
│       └── idea-*.md           # Shaping plan files (committed)
├── commands/                   # Markdown command definitions
│   ├── {command-a}.md
│   └── {command-b}.md
├── hooks/
│   └── hooks.json              # Claude Code hooks
├── scripts/                    # Helper scripts
├── knowledge/                  # Reference documents (optional)
├── docs/
│   ├── architecture.md
│   ├── changelog.md
│   ├── troubleshooting.md
│   └── standards/              # If this is a standards repo
├── install.sh                  # Bootstrap script
├── README.md
├── CLAUDE.md                   # Claude-facing docs
└── CONTRIBUTING.md             # Contribution guide
```

**Note:** `.claude/` is generally gitignored (machine-specific settings), but `.claude/plans/idea-*.md` files are tracked via gitignore exception. These are shaping artifacts from `/wdi:shape-idea` sessions that should persist across collaborators.

---

## Directory Naming

- **Lowercase with hyphens**: `api-google-ads`, `guest-tools`
- **No underscores**: Use `package-name` not `package_name`
- **No camelCase**: Use `my-package` not `myPackage`
- **Descriptive**: `dashboard`, `cli`, `api-{service}`

---

## When to Use Which Structure

| Scenario | Structure |
|----------|-----------|
| Related tools in same domain | Mono-repo |
| Plugin installed via URL | Standalone |
| External consumers | Standalone |
| Internal utilities | Mono-repo subproject |
| Experimental/spike | Mono-repo subproject with `experiment-` prefix |

See [REPO-STANDARDS.md](REPO-STANDARDS.md) for repository naming decisions.

---

## Subproject Internal Structure

Each subproject within a mono-repo follows this pattern:

```
{type}/{subproject-name}/
├── README.md                   # Subproject overview
├── CLAUDE.md                   # Claude instructions (if needed)
├── src/                        # Source code
│   ├── {module}/               # Feature/concern groupings
│   └── index.js                # Entry point
├── tests/                      # Tests
│   ├── unit/
│   └── integration/
├── bin/                        # CLI entry points (for tools)
│   └── {tool-name}
├── package.json                # Or pyproject.toml, Cargo.toml
└── ...
```

### Type-Specific Variations

**Tools** (CLIs):
```
tools/{tool-name}/
├── bin/                        # CLI binary/entry point
├── commands/                   # Command templates (if bundled)
├── templates/                  # Config templates
└── src/
    ├── cli.js                  # CLI entry
    └── {module}/               # Feature modules
```

**Applications**:
```
apps/{app-name}/
├── src/
│   ├── components/             # UI components
│   ├── pages/                  # Routes/pages
│   └── services/               # Business logic
├── public/                     # Static assets
└── ...
```

**Services** (APIs):
```
services/{service-name}/
├── src/
│   ├── routes/                 # API endpoints
│   ├── models/                 # Data models
│   └── services/               # Business logic
└── ...
```

---

## Product Documentation Structure

For projects with formal product planning, use this structure:

```
docs/product/
├── design/                     # Design documents
│   ├── prd-{name}.md           # Product Requirements Documents
│   └── {design-doc}.md         # Other design docs
└── planning/                   # Planning artifacts
    ├── features/               # Feature specifications
    │   ├── {feature-slug}.md   # Individual feature files
    │   └── ...
    ├── milestones/             # Milestone definitions
    │   ├── MILE-001-{name}.md  # Milestone files
    │   └── ...
    └── status.md               # Current project status
```

### When to Use

| Document | When |
|----------|------|
| PRD | New product, major feature, needs stakeholder alignment |
| Feature | Any tracked work (created by `/wdi:feature`) |
| Milestone | Grouping features for a release or phase |
| Status | Ongoing project tracking |

### Templates

Templates for these documents are in `docs/templates/`:

| Template | Purpose |
|----------|---------|
| `feature.md` | Feature specification template |
| `prd.md` | Product Requirements Document template |
| `milestone.md` | Milestone with dependencies template |

---

## Template Directory

Store reusable document templates in `docs/templates/`:

```
docs/templates/
├── feature.md                  # Feature spec template
├── prd.md                      # PRD template
└── milestone.md                # Milestone template
```

These templates are used by workflows and can be copied manually for new documents.
