# File Naming Standards

**Organization:** whitedoeinn
**Last Updated:** 2026-01-11

---

## General Rules

1. **Lowercase with hyphens** for directories and multi-word files
2. **No spaces or underscores** in file names
3. **Descriptive names** over abbreviations
4. **Extension matches content** (.md for markdown, .py for Python, etc.)

---

## File Types

### Markdown Documentation

| Pattern | Example | Use for |
|---------|---------|---------|
| `UPPERCASE.md` | `README.md`, `CLAUDE.md` | Root-level standard files |
| `UPPERCASE-NAME.md` | `REPO-STANDARDS.md` | Standards documents |
| `lowercase.md` | `architecture.md`, `changelog.md` | General documentation |
| `lowercase-name.md` | `getting-started.md` | Multi-word docs |

### Code Files

| Language | Pattern | Example |
|----------|---------|---------|
| Python | `snake_case.py` | `api_client.py`, `test_utils.py` |
| JavaScript/TypeScript | `camelCase.js` | `apiClient.js`, `testUtils.js` |
| Ruby | `snake_case.rb` | `api_client.rb` |
| Shell | `kebab-case.sh` | `check-deps.sh`, `run-tests.sh` |

### Configuration Files

| Type | Name |
|------|------|
| Python project | `pyproject.toml` |
| Node project | `package.json` |
| Claude Code plugin | `plugin.json` |
| Environment | `.env`, `.env.example` |
| Git | `.gitignore`, `.gitattributes` |

---

## Special Files

### Required at Root

| File | Purpose |
|------|---------|
| `README.md` | Project overview and quick start |
| `.gitignore` | Git ignore patterns |

### Required for Claude Code Projects

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Claude Code context and instructions |

### Optional Standard Files

| File | Purpose |
|------|---------|
| `CONTRIBUTING.md` | Contribution guidelines |
| `LICENSE` | License file (no extension) |
| `CHANGELOG.md` | Root changelog (alt: `docs/changelog.md`) |

---

## Directory Names

| Pattern | Example | Use for |
|---------|---------|---------|
| `lowercase` | `src`, `tests`, `docs` | Standard directories |
| `lowercase-name` | `api-client`, `user-auth` | Multi-word directories |
| Never use | `ApiClient`, `api_client` | CamelCase or snake_case |

---

## Anti-patterns

| Don't | Do Instead |
|-------|------------|
| `My File.md` | `my-file.md` |
| `API_Client.py` | `api_client.py` |
| `testFile.js` | `test-file.js` or `testFile.js` (language convention) |
| `README.txt` | `README.md` |
| `script.sh.bak` | Delete or use git |
| `file (copy).md` | Descriptive name or delete |

---

## Version Numbers in Names

**Never** include versions in file names:

| Don't | Do Instead |
|-------|------------|
| `api-v2.py` | Use git branches/tags |
| `config-2024.json` | Use git history |
| `README-old.md` | Delete or archive properly |
