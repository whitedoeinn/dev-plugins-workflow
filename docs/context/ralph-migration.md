# Enhanced-Ralph Migration Context

**Source Project:** `/Users/davidroberts/vscode-projects/google-ads`
**Target Project:** This plugin (dev-plugins-workflow)
**Created:** 2026-01-12

## Overview

Migrate the enhanced-ralph skill and milestone command from the google-ads project to this workflow plugin. Enhanced-ralph provides quality-gated feature execution with task-type detection, research phases, and agent-based reviews.

---

## Scope

**In Scope:**
- Enhanced-Ralph skill migration
- Milestone command migration
- Enhancement: `--milestone` flag to execute all features in a milestone
- Adoption of existing plugin capabilities (commit, review via compound-engineering)

**Out of Scope (see other context docs):**
- Design-principles skill → Eliminated (standardizing on frontend-design)
- Review Command → Eliminated (use compound-engineering:workflows:review)
- Sync Configuration System → See `sync-config-evaluation.md`
- Daily Changelog Action → See `daily-changelog-evaluation.md`
- Capability gaps → See `capability-gaps.md`

---

## Source Files

### Enhanced-Ralph SKILL
**Location:** `/Users/davidroberts/vscode-projects/google-ads/.claude/skills/enhanced-ralph/SKILL.md`

**What It Does:**
- Wraps ralph-loop:ralph-loop with quality gates
- 8 task type detection (ui, database, api, security, data, test, config, external)
- Research phase orchestration (invokes framework-docs-researcher, best-practices-researcher, etc.)
- Quality gate agents per task type (design-implementation-reviewer, data-integrity-guardian, security-sentinel)
- File-type reviews (kieran-typescript-reviewer, kieran-python-reviewer)
- Modes: `--strict`, `--fast`, `--skip-gates`, `--continue`, `--verbose`

### Milestone Command
**Location:** `/Users/davidroberts/vscode-projects/google-ads/.claude/commands/milestone.md`

**What It Does:**
- Creates milestone files grouping features
- Interview-driven creation (value, features, order)
- Tracks milestone status (Not Started, In Progress, Complete)
- Currently shows manual workflow for executing features

---

## Dependencies (All Already Available)

| Dependency | Source | Status |
|------------|--------|--------|
| `frontend-design` skill | claude-plugins-official | Available |
| `ralph-loop:ralph-loop` | ralph-loop plugin | Available |
| `compound-engineering` agents | compound-engineering plugin | Available |
| `playwright-test` | compound-engineering plugin | Available |
| `commit` skill | This plugin | Available (say "commit these changes") |

### Agents Used (from compound-engineering)
**Research:** framework-docs-researcher, best-practices-researcher, git-history-analyzer, repo-research-analyst

**Quality Gates:** design-implementation-reviewer, data-integrity-guardian, security-sentinel, pattern-recognition-specialist, kieran-typescript-reviewer, kieran-python-reviewer

---

## Required Modifications

### Remove from Enhanced-Ralph
1. **Line 110:** Remove `Apply design-principles skill for consistent styling`
2. **Lines 155-160:** Remove design-principles from UI workflow diagram
3. **Line 184:** Change `frontend-design + design-principles` to just `frontend-design`
4. **Line 256:** Change `Ready for: /commit` to `Ready to commit - say "commit these changes"` (DONE)

### Add to Enhanced-Ralph
New `--milestone` flag with this behavior:

```markdown
## Milestone Mode

When invoked with `--milestone`:

1. **Parse Milestone File**
   - Read `docs/product/planning/milestones/[milestone-name].md`
   - Extract features list in order

2. **Execute Features Sequentially**
   - For each feature in order:
     - Run enhanced-ralph on that feature
     - If feature completes, mark it done
     - If feature fails, stop and report

3. **Update Milestone Status**
   - Update milestone file status to "In Progress" at start
   - Update to "Complete" when all features done

4. **Summary**
   - Report progress: "Completed 3/5 features in MILE-002"
   - List remaining features if stopped early
```

### Update Milestone Command
- Update "Working Through a Milestone" section to reference enhanced-ralph:
  ```
  /enhanced-ralph --milestone MILE-002-config-context
  ```
  Instead of manual ralph-loop invocations

---

## Migration Tasks

### Phase 1: Prepare Enhanced-Ralph
- [ ] Copy source SKILL.md to this project
- [ ] Remove design-principles references (4 locations)
- [x] Update final step to use commit skill invocation pattern
- [ ] Add `--milestone` flag support with milestone execution logic
- [ ] Abstract project-specific task keywords if needed

### Phase 2: Migrate Milestone Command
- [ ] Copy milestone.md to this project
- [ ] Update "Working Through a Milestone" section
- [ ] Add milestone template to `/docs/templates/`

### Phase 3: Integration
- [ ] Update plugin.json to include new skill and command
- [ ] Update install.sh
- [ ] Update CLAUDE.md with new capabilities
- [ ] Update README.md

### Phase 4: Testing
- [ ] Test single feature execution
- [ ] Test milestone execution with `--milestone` flag
- [ ] Verify all compound-engineering agents invoke correctly
- [ ] Verify frontend-design invocation works
- [ ] Verify commit skill integration (say "commit these changes")

---

## Target Files to Create

| File | Action |
|------|--------|
| `skills/enhanced-ralph/SKILL.md` | Create from source + modifications |
| `commands/milestone.md` | Create from source + modifications |
| `docs/templates/milestone.md` | Create milestone file template |

---

## Verification Checklist

### Single Feature Test
- [ ] Task type detection works
- [ ] UI tasks invoke frontend-design (not design-principles)
- [ ] Research agents invoked appropriately
- [ ] Quality gate agents invoked per task type
- [ ] Final output suggests commit skill ("commit these changes")

### Milestone Test
- [ ] Milestone file parsed correctly
- [ ] Features executed in order
- [ ] Milestone status updated to "In Progress"
- [ ] Progress reported between features
- [ ] Milestone marked "Complete" when done

### Integration Test
- [ ] compound-engineering agents callable
- [ ] frontend-design skill callable
- [ ] ralph-loop:ralph-loop callable
- [ ] playwright-test callable
- [ ] Milestone file read/write works

---

## Usage After Migration

```bash
# Execute single feature with quality gates
/enhanced-ralph feature-name

# Execute all features in a milestone
/enhanced-ralph --milestone MILE-002-config-context

# Create a new milestone
/milestone my-milestone
```
