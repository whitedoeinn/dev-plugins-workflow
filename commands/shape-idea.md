---
description: Iterative shaping session for an idea (produces committed plan file)
---

# /wdi:shape-idea - Iterative Idea Shaping

Shape an idea through focused exploration from a specific perspective. Each session produces a committed plan file that persists across sessions.

## Usage

```
/wdi:shape-idea #123 [--perspective business|technical|ux]
```

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--perspective` | `-p` | Shaping perspective: `business`, `technical`, or `ux` (default: `technical`) |

## How It Works

1. **Fetch** the idea issue from GitHub
2. **Read** any existing shaping plan files for this idea
3. **Enter plan mode** to explore, ask questions, and think through the idea
4. **Produce** a plan file at `.claude/plans/idea-{number}-{perspective}-{date}.md`
5. **Add comment** to the GitHub issue linking to the plan file

Multiple shaping sessions accumulate as separate files, building a rich context for eventual promotion.

---

## Step 1: Parse Arguments

Extract issue number and perspective from the command arguments.

```
Pattern: #(\d+)
Pattern: --perspective (business|technical|ux)
Pattern: -p (business|technical|ux)
```

Default perspective is `technical` if not specified.

---

## Step 2: Fetch Issue

```bash
gh issue view {issue-number} --json number,title,body,labels,comments,url
```

### Validation

1. **Check issue exists** - Error if not found
2. **Check for `idea` label** - If missing, warn:

```
Warning: Issue #{number} does not have the 'idea' label.

This command is designed for shaping ideas captured via `/wdi:feature --idea`.
Regular issues may not have the expected structure.

(c)ontinue anyway, (a)bort:
```

---

## Step 3: Read Existing Shaping Files

Check for existing plan files for this idea:

```bash
ls .claude/plans/idea-{number}-*.md 2>/dev/null || echo "No existing shaping files"
```

If files exist, read them to understand prior shaping context:
- What perspectives have been explored?
- What decisions have been made?
- What open questions remain?

Display summary:

```
Existing Shaping Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• idea-{n}-business-2024-01-15.md (business perspective)
• idea-{n}-technical-2024-01-16.md (technical perspective)

Building on prior exploration. Open questions from previous sessions
will be considered.
```

---

## Step 4: Enter Plan Mode

Use `EnterPlanMode` to begin exploration.

### Exploration Prompts by Perspective

#### Business Perspective

Focus on:
- **Value proposition:** What problem does this solve? Who benefits?
- **Appetite:** Is the rough time estimate reasonable? What's the minimum viable scope?
- **ROI:** What's the expected return? How will we measure success?
- **Risks:** Business risks, opportunity costs, market timing
- **Dependencies:** Does this block or enable other work?
- **Cross-cutting implications:** What does this require from technical/UX?

#### Technical Perspective

Focus on:
- **Feasibility:** Can we build this? What are the technical constraints?
- **Architecture:** How does this fit into existing systems?
- **Complexity:** What's genuinely hard? What seems hard but isn't?
- **Dependencies:** External services, libraries, APIs needed
- **Risks:** Technical risks, scaling concerns, security implications
- **Cross-cutting implications:** What does this require from business/UX?

#### UX Perspective

Focus on:
- **User needs:** Who uses this? What's their mental model?
- **Workflow:** How does this fit into existing user journeys?
- **Accessibility:** Can all users access this functionality?
- **Edge cases:** What happens in error states, empty states, loading?
- **Risks:** Usability risks, learning curve, potential confusion
- **Cross-cutting implications:** What does this require from business/technical?

### Interactive Exploration

During plan mode:
- Ask clarifying questions using `AskUserQuestion`
- Research related code using `Grep`, `Glob`, `Read`
- Explore documentation and prior art
- Think through implications and trade-offs

---

## Step 5: Generate Plan File

After exploration, create the shaping plan file.

### File Path

```
.claude/plans/idea-{number}-{perspective}-{YYYY-MM-DD}.md
```

Example: `.claude/plans/idea-45-business-2024-01-15.md`

### File Structure

```markdown
# Shaping: {idea title}

**Issue:** #{number}
**Perspective:** {business|technical|ux}
**Date:** {YYYY-MM-DD}

## Original Idea

{issue body}

## Exploration

{Your thinking, questions explored, research done}

## Key Questions Answered

- **Q:** {question}
  **A:** {answer/decision}

## Cross-Cutting Implications

{How this perspective affects other areas}

- **→ UX:** {e.g., "Requires new API endpoint for..."}
- **→ Tech:** {e.g., "Need to consider rate limiting..."}
- **→ Business:** {e.g., "Implies pricing tier changes..."}

## Open Questions (for next session)

- {remaining unknowns}

## Decisions Made

- {decision with rationale}

## Risks Identified

- **Risk:** {description}
  **Mitigation:** {approach}

## Rough Scope

**In scope:**
- {what's included}

**Out of scope:**
- {what's deferred or excluded}
```

### Create Directory and File

```bash
mkdir -p .claude/plans
```

Write the plan file using the Write tool.

---

## Step 6: Add Issue Comment

Post a summary comment to the GitHub issue:

```bash
gh issue comment {issue-number} --body "$(cat <<'EOF'
## Shaping: {perspective} perspective

**Plan file:** `.claude/plans/idea-{number}-{perspective}-{date}.md`

### Summary

{2-3 sentence summary of exploration}

### Key Decisions

{bulleted list of decisions made}

### Cross-Cutting Implications

{key dependencies on other perspectives}

### Open Questions

{remaining unknowns, if any}

---
*Shaping session via `/wdi:shape-idea`*
EOF
)"
```

---

## Step 7: Output Summary

```
Shaping Session Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Idea: {title}
Perspective: {perspective}

✓ Plan file: .claude/plans/idea-{number}-{perspective}-{date}.md
✓ Issue comment added

Total shaping files for this idea: {count}
  • business: {yes/no}
  • technical: {yes/no}
  • ux: {yes/no}

Next steps:
• Shape from another perspective: /wdi:shape-idea #{number} --perspective {other}
• Promote when ready: /wdi:feature --promote #{number}
```

---

## Examples

### First shaping session (business)

```
/wdi:shape-idea #45 --perspective business

Fetching issue #45...

Idea: "Add usage metrics export"

No existing shaping files for this idea.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Entering plan mode for business perspective exploration...

[Claude explores value proposition, asks about target users,
researches competitor approaches, considers pricing implications]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Shaping Session Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Idea: Add usage metrics export
Perspective: business

✓ Plan file: .claude/plans/idea-45-business-2024-01-15.md
✓ Issue comment added

Total shaping files for this idea: 1
  • business: yes
  • technical: no
  • ux: no

Next steps:
• Shape from another perspective: /wdi:shape-idea #45 --perspective technical
• Promote when ready: /wdi:feature --promote #45
```

### Follow-up session (technical)

```
/wdi:shape-idea #45 --perspective technical

Fetching issue #45...

Idea: "Add usage metrics export"

Existing Shaping Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• idea-45-business-2024-01-15.md (business perspective)

Building on prior exploration. Key context from business:
  • Premium tier feature (drives upgrade)
  • CSV and JSON formats required
  • Must handle large datasets (100k+ rows)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Entering plan mode for technical perspective exploration...

[Claude explores API design, database queries, pagination,
background job processing for large exports]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Shaping Session Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Idea: Add usage metrics export
Perspective: technical

✓ Plan file: .claude/plans/idea-45-technical-2024-01-15.md
✓ Issue comment added

Total shaping files for this idea: 2
  • business: yes
  • technical: yes
  • ux: no

Next steps:
• Shape from another perspective: /wdi:shape-idea #45 --perspective ux
• Promote when ready: /wdi:feature --promote #45
```

---

## Notes

- Plan files are committed to git (tracked via `.gitignore` exception)
- Each perspective session creates a new file (doesn't overwrite)
- Multiple sessions from the same perspective append date to filename
- The `--promote` workflow reads all shaping files when promoting an idea
- Use this for ideas that need exploration before implementation
- Simple ideas can skip shaping and promote directly
