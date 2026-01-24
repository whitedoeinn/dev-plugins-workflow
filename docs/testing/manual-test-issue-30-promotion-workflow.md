# Manual Testing: Issue #30 - Promotion Workflow

**Feature:** Idea capture and promotion workflow (hybrid model)
**Issue:** #30
**Date:** 2026-01-17

Use this checklist to manually verify the promotion workflow works as designed.

---

## Prerequisites

- [ ] `gh` CLI authenticated (`gh auth status`)
- [ ] Working in a repo with the wdi plugin loaded
- [ ] Clean git state (no uncommitted changes that would interfere)

---

## Test 1: Idea Creation (`--idea`)

**Goal:** Verify `--idea` creates a GitHub issue only (no file).

### Steps

1. Run `/wdi:workflow-feature --idea`
2. Answer the interview:
   - Title: "Test idea for manual verification"
   - Problem: "Testing that idea workflow creates issue only"
   - Appetite: Small
   - Rough Solution: "N/A - this is a test"
   - Open Questions: "Does it work?"

### Expected Results

- [ ] GitHub issue created with title "Idea: Test idea for manual verification"
- [ ] Issue has labels: `idea`, `status:needs-shaping`
- [ ] Issue body contains:
  - [ ] Problem section
  - [ ] Appetite section
  - [ ] Rough Solution section
  - [ ] Open Questions section
  - [ ] Shaping instructions with prefix documentation
- [ ] **NO file created** in `docs/product/ideas/`
- [ ] Output shows "Next steps" with `--promote #{issue-number}` syntax

### Cleanup

```bash
gh issue close {number} --comment "Manual test complete"
gh issue delete {number} --yes
```

---

## Test 2: Shaping with Prefixes

**Goal:** Verify prefixed comments are documented in issue body.

### Steps

1. Create a test idea (or use Test 1's issue before cleanup)
2. Add comments with various prefixes:

```bash
gh issue comment {number} --body "Decision: Use approach A for implementation"
gh issue comment {number} --body "Test: Verify the API returns 200 OK"
gh issue comment {number} --body "This is just discussion - no prefix"
gh issue comment {number} --body "Constraint: Must work without network access"
gh issue comment {number} --body "Doc: Update README with new usage"
gh issue comment {number} --body "Risk: May break existing integrations"
gh issue comment {number} --body "Blocked: Depends on issue #999"
```

### Expected Results

- [ ] All 7 comments added successfully
- [ ] Issue body shows prefix documentation for shapers to reference

---

## Test 3: Promotion (`--promote`)

**Goal:** Verify promotion parses prefixed comments correctly.

### Steps

1. Use the issue from Test 2 (with comments added)
2. Run `/wdi:workflow-feature --promote #{issue-number}`

### Expected Results

**Comment Parsing:**
- [ ] Shows "Parsed Shaping Comments" summary
- [ ] `Decision:` comment listed under "Decisions"
- [ ] `Test:` comment listed under "Tests"
- [ ] `Constraint:` comment listed under "Constraints"
- [ ] `Doc:` comment listed under "Docs"
- [ ] `Risk:` comment listed under "Risks"
- [ ] `Blocked:` comment listed under "Blocked by"
- [ ] Non-prefixed comment shown as "Ignored (no prefix)"
- [ ] "Conflicts: None detected" displayed

**Feature Interview:**
- [ ] Interview runs with pre-populated answers from idea
- [ ] Asks for research preference
- [ ] Asks for target (if mono-repo)

**Feature Spec Created:**
- [ ] File created at `docs/product/planning/features/{slug}.md`
- [ ] Has YAML frontmatter with: status, type, complexity, issue, branch, created
- [ ] Problem section populated from idea
- [ ] Research Summary includes Decision comments
- [ ] Done When includes Test comments
- [ ] Context includes Constraint comments
- [ ] Files table includes Doc comments
- [ ] Notes includes Risk comments
- [ ] Dependencies includes Blocked comments

**Issue Updated:**
- [ ] Issue body replaced with feature summary
- [ ] Shows link to spec file
- [ ] Shows promoted date, complexity, target
- [ ] Labels changed from `idea`, `status:needs-shaping` to `feature`, `status:ready`

### Cleanup

```bash
rm docs/product/planning/features/{slug}.md
gh issue close {number} --comment "Manual test complete"
gh issue delete {number} --yes
```

---

## Test 4: Conflict Detection

**Goal:** Verify conflicting decisions halt promotion.

### Steps

1. Create a new test idea issue
2. Add conflicting Decision comments:

```bash
gh issue comment {number} --body "Decision: Use JSON for all config files"
gh issue comment {number} --body "Decision: Use YAML for all config files"
```

3. Run `/wdi:workflow-feature --promote #{issue-number}`

### Expected Results

- [ ] Workflow detects conflict between JSON and YAML decisions
- [ ] Shows "Conflict Detected - Cannot Proceed" message
- [ ] Lists both conflicting comments
- [ ] Promotion halts (does not create feature spec)
- [ ] Instructs user to resolve conflict and re-run

### Cleanup

```bash
gh issue close {number} --comment "Conflict test complete"
gh issue delete {number} --yes
```

---

## Test 5: Auto-Documentation (Commit Skill)

**Goal:** Verify commit skill auto-updates documentation when commands/skills modified.

### Steps

1. Modify a command file (e.g., `commands/workflow-feature.md`)
2. Stage the changes
3. Run the commit skill ("commit these changes")

### Expected Results

- [ ] Step 4.5 detects command file was modified
- [ ] Runs `./scripts/check-docs-drift.sh`
- [ ] If drift found: auto-updates CLAUDE.md and README.md
- [ ] Stages documentation changes automatically
- [ ] Shows "Auto-updated documentation: ..." message

---

## Test 6: Implementation Conflict Detection (Phase 5)

**Goal:** Verify conflicts are detected during implementation.

### Steps

1. Create a feature with two tasks that would modify the same file differently
2. Implement Task 1 (modifies config.yaml to use JSON)
3. Start Task 2 (would modify config.yaml to use YAML)

### Expected Results

- [ ] Before implementing Task 2, conflict check runs
- [ ] Detects config.yaml was already modified
- [ ] Shows "Implementation Conflict Detected" message
- [ ] Presents resolution options (resolve and continue, abort)

---

## Test 7: Edge Cases

### 7a: Idea with no comments

1. Create idea, immediately promote (no shaping comments)
2. Expected: Promotion proceeds, shows "No actionable comments found"

### 7b: Comment with multiple prefixes

1. Add comment: "Decision: Use X\nTest: Verify X works"
2. Expected: Both Decision and Test extracted from same comment

### 7c: Prefix in middle of comment

1. Add comment: "I think Decision: Use X is best"
2. Expected: NOT parsed (prefix must be at start of line)

### 7d: Issue without `idea` label

1. Try to promote a non-idea issue
2. Expected: Warning shown, asks to confirm

---

## Test Summary

| Test | Description | Pass/Fail | Notes |
|------|-------------|-----------|-------|
| 1 | Idea creation (issue only) | | |
| 2 | Shaping with prefixes | | |
| 3 | Promotion workflow | | |
| 4 | Conflict detection | | |
| 5 | Documentation review | | |
| 6 | Documentation gate | | |
| 7a | No comments edge case | | |
| 7b | Multiple prefixes | | |
| 7c | Prefix mid-comment | | |
| 7d | Non-idea promotion | | |

---

## Bugs Found

| Bug | Description | Issue # |
|-----|-------------|---------|
| | | |

---

## Notes

- Testing performed by:
- Date:
- Plugin version:
