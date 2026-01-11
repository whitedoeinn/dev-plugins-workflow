---
description: Create a new package within a mono-repo following standards
---

# /wdi-workflows:new-package - Create Package

Add a new package to an existing mono-repo following WDI structure standards.

## Flags

| Flag | Description |
|------|-------------|
| `--yes` | Skip confirmations |
| `--type [python\|node\|content]` | Package type (auto-detected if not specified) |

---

## Workflow

### Step 1: Verify Context

Check we're in a mono-repo:

```bash
ls packages/ 2>/dev/null
```

**If not in a mono-repo:**

```
⚠️  Not in a mono-repo (no packages/ directory found).

Options:
1. Navigate to mono-repo root and retry
2. Create a mono-repo: /wdi-workflows:new-repo --type mono
3. If this should be standalone, use regular project setup

(a)bort:
```

### Step 2: Gather Information

```
Package name: _______
Description: _______
```

### Step 3: Validate Name

Read `knowledge/decision-trees/package-location.md` for naming rules.

**Validation checks:**
- Lowercase with hyphens only
- No generic names (`utils`, `common`, `shared`)
- Descriptive of function

**Common patterns:**
- `api-{service}` for API wrappers
- `{function}` for tools (dashboard, cli, reports)
- `guest-{function}` for guest-facing

**If validation fails:**

```
⚠️  Package name "{name}" may not follow conventions.

Suggested patterns:
  - api-{service} (e.g., api-ga4, api-mailchimp)
  - {function} (e.g., dashboard, cli, reports)
  - guest-{function} (e.g., guest-surveys, guest-portal)

(c)ontinue anyway, (e)dit name, (a)bort:
```

### Step 4: Detect Package Type

If `--type` not specified, detect from existing packages or repo:

```bash
# Check for Python indicators
ls packages/*/pyproject.toml 2>/dev/null && echo "python"

# Check for Node indicators
ls packages/*/package.json 2>/dev/null && echo "node"

# Check repo root
ls pyproject.toml package.json 2>/dev/null
```

If mixed or unclear, prompt:

```
Package type:
(p)ython - pyproject.toml, src/, tests/
(n)ode - package.json, src/, __tests__/
(c)ontent - README.md only (docs, research)
```

### Step 5: Confirm

```
Creating package: packages/{name}/

Type: {type}
Description: {description}

Structure:
├── README.md
├── src/
├── tests/
└── {pyproject.toml|package.json}

Proceed? (y)es, (e)dit, (a)bort:
```

### Step 6: Create Package

**For Python packages:**

```bash
mkdir -p packages/{name}/src packages/{name}/tests
touch packages/{name}/README.md
touch packages/{name}/pyproject.toml
touch packages/{name}/src/__init__.py
touch packages/{name}/tests/__init__.py
touch packages/{name}/tests/test_{name}.py
```

Create `pyproject.toml`:
```toml
[project]
name = "{name}"
version = "0.1.0"
description = "{description}"
requires-python = ">=3.11"

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"
```

**For Node packages:**

```bash
mkdir -p packages/{name}/src packages/{name}/__tests__
touch packages/{name}/README.md
touch packages/{name}/package.json
touch packages/{name}/src/index.ts
touch packages/{name}/__tests__/{name}.test.ts
```

Create `package.json`:
```json
{
  "name": "@wdi/{name}",
  "version": "0.1.0",
  "description": "{description}",
  "main": "src/index.ts",
  "scripts": {
    "test": "jest",
    "build": "tsc"
  }
}
```

**For Content packages:**

```bash
mkdir -p packages/{name}
touch packages/{name}/README.md
```

### Step 7: Create README

```markdown
# {name}

{description}

## Overview

(Add package overview here)

## Usage

```python
# or JavaScript, depending on type
from {name} import ...
```

## Development

### Setup

```bash
cd packages/{name}
# Python: pip install -e .
# Node: npm install
```

### Testing

```bash
# Python: pytest
# Node: npm test
```

## API Reference

(Document public API here)
```

### Step 8: Update Root README

Add package to the root README.md packages table:

```markdown
| {name} | {description} |
```

### Step 9: Update Changelog

Add entry to `docs/changelog.md`:

```markdown
## {date}

### Added
- New package: `{name}` - {description}
```

### Step 10: Output

```
✓ Package created: packages/{name}/

Structure:
packages/{name}/
├── README.md
├── src/
│   └── __init__.py
├── tests/
│   └── test_{name}.py
└── pyproject.toml

Next steps:
1. cd packages/{name}
2. Implement your package in src/
3. Add tests in tests/
4. Update README with usage examples

Commit when ready:
git add packages/{name} README.md docs/changelog.md
git commit -m "feat: Add {name} package"
```

---

## Examples

### Create Python API wrapper

```
/wdi-workflows:new-package

> Package name: api-ga4
> Description: Google Analytics 4 API wrapper

✓ Created: packages/api-ga4/
```

### Create Node package

```
/wdi-workflows:new-package --type node

> Package name: dashboard
> Description: Marketing dashboard frontend

✓ Created: packages/dashboard/
```

### Quick creation

```
/wdi-workflows:new-package --yes --type python

> Package name: reports
> Description: Report generation utilities

✓ Created: packages/reports/
```

---

## Notes

- Must be run from mono-repo root
- Auto-detects package type from existing packages
- Updates root README and changelog automatically
- See `knowledge/decision-trees/package-location.md` for naming guidance
