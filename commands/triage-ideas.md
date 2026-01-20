---
description: Review unshaped ideas, identify clusters, recommend shaping approach
---

# /wdi:triage-ideas - Periodic Idea Triage

Review `status:needs-shaping` ideas, identify clusters, and recommend the right shaping approach for each.

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--plan` | | Analysis only, stop before execution |
| `--yes` | `-y` | Auto-accept recommendations |

---

## Phase 1: Fetch Ideas

Query GitHub for all unshaped ideas:

```bash
gh issue list \
  --label "status:needs-shaping" \
  --json number,title,body,labels,createdAt,comments \
  --limit 100
```

### Exit Early

If no issues found:

```
No Unshaped Ideas
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

No issues with status:needs-shaping label found.

To capture a new idea: /wdi:workflows-feature --idea
```

**Exit here if no ideas to triage.**

---

## Phase 2: Analyze and Cluster

### Extract Metadata

For each issue, extract:
- **Title**: From issue title (strip "Idea: " prefix if present)
- **Problem**: From `## Problem` section in body
- **Appetite**: From `## Appetite` section in body
- **Open Questions**: From `## Open Questions` section in body
- **Age**: Days since `createdAt`
- **Shaping Comments**: Count of comments with recognized prefixes (`Decision:`, `Test:`, `Blocked:`)

### Group by Similarity

Analyze issues for clustering:

1. **Semantic similarity** - Issues that solve related problems
2. **Shared dependencies** - Issues with overlapping `Blocked:` references
3. **Common domain** - Issues affecting the same area of the codebase

### Naming Clusters

Give each cluster a descriptive theme name:
- "Authentication improvements"
- "Performance optimization"
- "Documentation updates"
- "API enhancements"

### Allow Singletons

Not all ideas cluster. Standalone ideas form singleton clusters (cluster of 1).

### Display Analysis

```
Idea Triage Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found {count} unshaped ideas

Cluster 1: "Authentication improvements" (3 ideas)
  #12 Add OAuth support (45 days, 2 decisions)
  #18 SSO integration (30 days, 0 decisions)
  #22 Session timeout config (15 days, 1 decision)

Cluster 2: "Performance" (1 idea)
  #15 Cache API responses (60 days, 0 decisions)

Cluster 3: "Developer experience" (2 ideas)
  #20 Add --verbose flag (10 days, 1 decision)
  #21 Better error messages (10 days, 0 decisions)
```

---

## Phase 3: Characterize and Recommend

For each cluster, determine the appropriate action:

### Action Types

| Action | When to Use | Outcome |
|--------|-------------|---------|
| `quick-decision` | Open questions can be resolved in brief investigation | Tag for quick investigation |
| `individual-promote` | Ideas loosely related, each ready to be promoted independently | Mark ready-to-promote |
| `needs-research` | Genuinely uncertain, requires deeper investigation | Create parent research issue |

### Decision Criteria

**quick-decision:**
- Open questions are specific and answerable
- No significant unknowns about approach
- Single decision point needed
- Example: "Should we use library A or B?"

**individual-promote:**
- Ideas have enough shaping (decisions made)
- Clear enough to start implementation
- May be related but don't need coordination
- Example: Standalone bug fixes or small enhancements

**needs-research:**
- Multiple open questions with dependencies
- Approach fundamentally unclear
- Would benefit from structured research
- Example: "How should we architect real-time features?"

### Generate Recommendations

For each cluster, recommend one action:

```
Recommendations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cluster 1: "Authentication improvements" → needs-research
  Reason: Multiple interconnected unknowns about auth architecture
  Action: Create parent research issue, link #12, #18, #22

Cluster 2: "Performance" → quick-decision
  Reason: Single question: which caching strategy?
  Action: Tag #15 for brief investigation

Cluster 3: "Developer experience" → individual-promote
  Reason: Both ideas are well-shaped and independent
  Action: Mark #20, #21 ready-to-promote
```

---

## Phase 4: Review and Adjust

Present recommendations table to user.

### Review Interface

Use `AskUserQuestion` with options:

```
How do you want to proceed?
```

| Option | Description |
|--------|-------------|
| **Accept all** | Execute all recommendations as shown |
| **Review each** | Step through and confirm/adjust each cluster |
| **Edit clusters** | Merge or split clusters before proceeding |

### If "Review each" Selected

For each cluster, ask:

```
Cluster: "{cluster-name}" ({count} ideas)
Recommended: {action}
Reason: {reason}
```

| Option | Description |
|--------|-------------|
| **Accept** | Use recommended action |
| **quick-decision** | Change to quick-decision |
| **individual-promote** | Change to individual-promote |
| **needs-research** | Change to needs-research |
| **Skip** | Don't process this cluster |

### If "Edit clusters" Selected

Allow:
- **Merge**: Combine two clusters into one
- **Split**: Break a cluster into smaller groups
- **Move**: Move an issue between clusters

After editing, return to recommendation step.

### Stop for --plan

If `--plan` flag was passed:

```
Plan Complete (--plan mode)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{count} clusters identified with recommendations:

| Cluster | Action | Issues |
|---------|--------|--------|
| Auth improvements | needs-research | #12, #18, #22 |
| Performance | quick-decision | #15 |
| Developer experience | individual-promote | #20, #21 |

Run without --plan to execute these actions.
```

**Exit here if --plan flag was passed.**

---

## Phase 5: Execute Actions

### Ensure Labels Exist

Before executing, create any missing labels:

```bash
gh label create "status:ready-to-promote" --color "0E8A16" --description "Triaged, ready for promotion" 2>/dev/null || true
gh label create "triage:quick-decision" --color "1D76DB" --description "Needs brief investigation" 2>/dev/null || true
gh label create "blocked:research" --color "D93F0B" --description "Waiting on parent research" 2>/dev/null || true
gh label create "research" --color "5319E7" --description "Research initiative" 2>/dev/null || true
```

### Execute: quick-decision

For issues marked `quick-decision`:

1. Add label:
   ```bash
   gh issue edit {number} --add-label "triage:quick-decision"
   ```

2. Add comment listing open questions:
   ```bash
   gh issue comment {number} --body "$(cat <<'EOF'
   ## Quick Decision Needed

   This idea has been triaged and needs a brief investigation to resolve:

   ### Open Questions
   {open-questions-from-issue}

   ### Next Steps
   1. Investigate the questions above
   2. Add `Decision:` comment(s) with findings
   3. Remove `triage:quick-decision` label
   4. Either promote or close the issue

   *Tagged by `/wdi:triage-ideas`*
   EOF
   )"
   ```

### Execute: individual-promote

For issues marked `individual-promote`:

1. Update labels:
   ```bash
   gh issue edit {number} \
     --remove-label "status:needs-shaping" \
     --add-label "status:ready-to-promote"
   ```

2. Add comment with promotion command:
   ```bash
   gh issue comment {number} --body "$(cat <<'EOF'
   ## Ready to Promote

   This idea has been triaged and is ready for promotion to a feature.

   **Promote with:**
   ```
   /wdi:workflows-feature --promote #{number}
   ```

   *Tagged by `/wdi:triage-ideas`*
   EOF
   )"
   ```

### Execute: needs-research

For clusters marked `needs-research`:

1. Create parent research issue:
   ```bash
   gh issue create \
     --title "Research: {cluster-name}" \
     --label "research" \
     --label "status:needs-research" \
     --body "$(cat <<'EOF'
   ## Research Initiative: {cluster-name}

   This research initiative was created to investigate related ideas that share common unknowns.

   ## Related Ideas
   {for each issue in cluster:}
   - #{number}: {title}
   {end for}

   ## Open Questions (Aggregated)
   {combined open questions from all issues}

   ## Research Scope
   - Investigate common patterns and approaches
   - Make architectural decisions
   - Document findings for child issues

   ## Next Steps
   1. Use `/workflows:plan` to structure research
   2. Document decisions in comments (prefix with `Decision:`)
   3. Update child issues with findings
   4. Unblock children when ready

   ---
   *Created by `/wdi:triage-ideas`*
   EOF
   )"
   ```

2. Get the created issue number from output

3. Update child issues:
   ```bash
   gh issue edit {child-number} \
     --add-label "blocked:research"

   gh issue comment {child-number} --body "$(cat <<'EOF'
   ## Blocked on Research

   This idea is blocked pending research in #{parent-number}.

   Once the research issue is resolved, this idea can be promoted.

   *Tagged by `/wdi:triage-ideas`*
   EOF
   )"
   ```

4. Optionally offer to kick off research:
   ```
   Research issue #{parent-number} created.

   Start research now with /workflows:plan? (y)es, (l)ater:
   ```

   If yes, invoke:
   ```
   /compound-engineering:workflows:plan
   ```
   Pass the research issue content as context.

---

## Phase 6: Summary

### Generate Report

```
Triage Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Processed {total} ideas in {cluster-count} clusters

Actions Taken:
  quick-decision: {count} issues tagged
  individual-promote: {count} issues ready to promote
  needs-research: {count} research initiatives created

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Steps by Category:

🔍 Quick Decisions (investigate and resolve):
  #15 - Cache API responses
    → Answer: which caching strategy?

✅ Ready to Promote (run promotion command):
  #20 - /wdi:workflows-feature --promote #20
  #21 - /wdi:workflows-feature --promote #21

📚 Research Initiatives (structured investigation):
  #99 - Research: Authentication improvements
    → Blocks: #12, #18, #22
    → Run /workflows:plan to start
```

---

## Examples

### Basic triage

```
/wdi:triage-ideas

Idea Triage Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 5 unshaped ideas

Cluster 1: "Authentication" (2 ideas)
  #12 Add OAuth support (45 days, 2 decisions)
  #18 SSO integration (30 days, 0 decisions)

Cluster 2: "Performance" (1 idea)
  #15 Cache API responses (60 days, 0 decisions)

Cluster 3: "DX improvements" (2 ideas)
  #20 Add --verbose flag (10 days, 1 decision)
  #21 Better error messages (10 days, 0 decisions)

Recommendations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cluster 1: "Authentication" → needs-research
Cluster 2: "Performance" → quick-decision
Cluster 3: "DX improvements" → individual-promote

? How do you want to proceed?
  → Accept all

Executing...

Triage Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions Taken:
  quick-decision: 1 issue tagged
  individual-promote: 2 issues ready to promote
  needs-research: 1 research initiative created (#99)
```

### Plan mode (analysis only)

```
/wdi:triage-ideas --plan

Idea Triage Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 3 unshaped ideas
...

Plan Complete (--plan mode)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Cluster | Action | Issues |
|---------|--------|--------|
| Authentication | needs-research | #12, #18 |
| Performance | quick-decision | #15 |

Run without --plan to execute these actions.
```

### Auto-accept mode

```
/wdi:triage-ideas --yes

Idea Triage Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
...

Auto-accepting recommendations...

Triage Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
...
```

---

## Integration Points

### Input From
- `/wdi:workflows-feature --idea` - Creates ideas that get triaged here

### Output To
- `/wdi:workflows-feature --promote` - Promotes ready ideas to features
- `/compound-engineering:workflows:plan` - Kicks off research for research initiatives

---

## Notes

- Run periodically (weekly or bi-weekly) to keep ideas flowing
- Older ideas may indicate stale thinking - consider closing
- Clusters help identify related work for batching
- Research initiatives prevent scattered investigation
- `--plan` is useful for async review with stakeholders
