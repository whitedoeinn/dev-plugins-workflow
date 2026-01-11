# Project Structure Standards

**Organization:** whitedoeinn
**Last Updated:** 2026-01-11

---

## Mono-repo Structure

Mono-repos cluster related packages. Use this structure:

```
{repo}/
├── README.md                   # Repo overview, package list
├── packages/                   # Individual packages
│   ├── {package-a}/
│   │   ├── README.md           # Package docs
│   │   ├── src/                # Source code
│   │   ├── tests/              # Package tests
│   │   └── pyproject.toml      # Or package.json
│   └── {package-b}/
├── shared/                     # Cross-package utilities
│   └── utils/
├── docs/                       # Repo-level documentation
│   ├── architecture.md         # System design
│   ├── changelog.md            # Change history
│   └── standards/              # Standards docs (if applicable)
└── scripts/                    # Build, deploy, dev tooling
    ├── build.sh
    └── dev.sh
```

### Required Files (Mono-repo)

| File | Purpose |
|------|---------|
| `README.md` | Overview, quick start, package list |
| `docs/architecture.md` | How packages relate, system design |
| `docs/changelog.md` | Version history |
| `packages/{name}/README.md` | Per-package documentation |

---

## Standalone Repo Structure

Standalone repos contain a single focused project. Use this structure:

```
{repo}/
├── README.md                   # Project overview
├── src/                        # Source code
│   └── {module}/
├── tests/                      # Test suite
├── docs/                       # Documentation
│   ├── architecture.md         # If complex enough
│   └── changelog.md            # Version history
├── scripts/                    # Tooling
└── pyproject.toml              # Or package.json
```

### Required Files (Standalone)

| File | Purpose |
|------|---------|
| `README.md` | Overview, installation, usage |
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
│   └── settings.json           # Local settings
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
| Internal utilities | Mono-repo package |
| Experimental/spike | Mono-repo package with `experiment-` prefix |

See [REPO-STANDARDS.md](REPO-STANDARDS.md) for repository naming decisions.
