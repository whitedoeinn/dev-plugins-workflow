# Standards Update Protocol

A systematic process for ensuring all affected areas are updated when any project standard changes.

---

## Why This Protocol Exists

Standards are referenced across multiple files:
- Commands that enforce the standards
- Documentation that explains them
- Templates that follow them
- Quick references that summarize them

When a standard changes, all these files must stay in sync. This protocol ensures nothing is missed.

---

## Workflow Options

### 1. On-Demand Impact Analysis

Before making any change, see what will be affected:

```
/wdi:update-standard --analyze BRANCH-NAMING
```

This shows:
- Files that enforce the standard (code changes needed)
- Files that reference the standard (text changes needed)
- Impact score and complexity assessment

**Use this to decide if the change is worth the effort.**

### 2. Guided Update Workflow

After deciding to proceed:

```
/wdi:update-standard BRANCH-NAMING
```

This walks you through:
- Each dependent file
- What section needs updating
- Staging changes for commit
- Verification checklist

### 3. Automatic Detection (PreCommit Hook)

When you stage a standard file for commit, the PreCommit hook triggers:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Standards file change detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changed standards:
  BRANCH-NAMING

Run impact analysis:
  /wdi:update-standard --analyze
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

This reminds you to update all dependents before committing.

---

## Step-by-Step Process

### Step 1: Assess Impact

```bash
# See what will be affected
/wdi:update-standard --analyze <STANDARD-NAME>
```

Consider:
- How many files are affected?
- Are the changes simple (text) or complex (logic)?
- Is this the right time for this change?

### Step 2: Decide to Proceed

**If impact is acceptable:**
- Continue to Step 3

**If impact is too high:**
- Consider smaller, incremental changes
- Defer to a dedicated refactoring session
- Document the desired change for later

### Step 3: Make the Standard Change

Edit the standard file in `docs/standards/`:

```bash
# Edit the standard
edit docs/standards/BRANCH-NAMING.md
```

### Step 4: Update Dependents

Run the guided update:

```bash
/wdi:update-standard BRANCH-NAMING
```

For each dependent file:
1. Review what the file does with this standard
2. Apply the necessary changes
3. Stage the updated file

### Step 5: Verify Changes

```bash
# Review all staged changes
git diff --cached

# Test affected commands if applicable
# Use commit skill with --skip-tests flag
```

### Step 6: Update Changelog

Add an entry to `docs/changelog.md`:

```markdown
## YYYY-MM-DD

### Changed
- **BRANCH-NAMING.md**: Added 'docs/' as valid branch type prefix
  - Updated commit.md, check-standards.md, standards-summary.md
```

### Step 7: Commit

```bash
git commit -m "docs: Update BRANCH-NAMING standard

Added 'docs/' as valid branch type prefix.
Updated all dependent files.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Impact Assessment Guide

### Simple Changes (Impact Score 3 or less)

- Text-only updates
- No logic changes in commands
- Can be done quickly

**Example:** Fixing a typo in COMMIT-STANDARDS.md

### Moderate Changes (Impact Score 4-5)

- Some command logic may change
- Multiple documentation files
- Test after updating

**Example:** Adding a new branch type to BRANCH-NAMING.md

### High-Impact Changes (Impact Score 6+)

- Significant command logic changes
- Template format changes
- Consider breaking into phases

**Example:** Restructuring PROJECT-STRUCTURE.md

---

## Dependency Map

The source of truth for what depends on what:

```
knowledge/standards-dependency-map.md
```

This file shows:
- Which files enforce each standard
- Which files reference each standard
- Impact score for each standard

Keep this map updated when:
- Adding a new standard
- Adding a new command that enforces a standard
- Adding documentation that references a standard

---

## Standards Inventory

| Standard | Description | Impact |
|----------|-------------|--------|
| REPO-STANDARDS.md | Repository naming conventions | 5 |
| BRANCH-NAMING.md | Git branch naming patterns | 3 |
| COMMIT-STANDARDS.md | Commit message format | 3 |
| PROJECT-STRUCTURE.md | Directory layout standards | 6 |
| FILE-NAMING.md | File and directory naming | 3 |
| CLAUDE-CODE-STANDARDS.md | Plugin/command naming | 5 |
| ISSUE-STANDARDS.md | GitHub issue conventions | 5 |
| DEPENDENCY-STANDARDS.md | Dependency tracking | 3 |

---

## Examples

### Example 1: Adding a Branch Type

**Change:** Add `docs/` as a valid branch prefix

**Steps:**
1. `--analyze BRANCH-NAMING` shows 3 files
2. Edit BRANCH-NAMING.md to add `docs/`
3. Run update workflow
4. Update commit.md branch validation
5. Update check-standards.md validation
6. Update standards-summary.md quick reference
7. Commit with all files

### Example 2: Changing Issue Labels

**Change:** Rename `bug` label to `defect`

**Steps:**
1. `--analyze ISSUE-STANDARDS` shows 5 files
2. Edit ISSUE-STANDARDS.md
3. Run update workflow
4. Update feature.md issue creation
5. Update all issue templates
6. Update standards-summary.md
7. Commit with all files

### Example 3: Restructuring Project Layout

**Change:** Move `knowledge/` under `docs/`

**Steps:**
1. `--analyze PROJECT-STRUCTURE` shows 6 files - High impact
2. Consider: Is this necessary now?
3. If yes, plan for dedicated session
4. Update standard first
5. Actually move the files
6. Update all references
7. Test thoroughly
8. Commit in logical chunks

---

## Quick Reference

```bash
# List all standards with impact
/wdi:update-standard --list

# Analyze before changing
/wdi:update-standard --analyze <STANDARD>

# Guided update after changing
/wdi:update-standard <STANDARD>

# Quick update (no prompts)
/wdi:update-standard --yes <STANDARD>
```

---

## Related

- `knowledge/standards-dependency-map.md` - Dependency reference
- `knowledge/standards-summary.md` - Quick reference for all standards
- `commands/standards-update.md` - Command documentation
