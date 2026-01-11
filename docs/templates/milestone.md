# MILE-{XXX}: {Milestone Title}

**Status:** Planning | In Progress | Blocked | Complete
**Created:** {YYYY-MM-DD}
**Target:** {YYYY-MM-DD}
**Completed:** {YYYY-MM-DD or blank}
**Owner:** {Name}
**PRD:** {Link to PRD if applicable}

---

## Value Delivered

{1-2 sentences describing what users/stakeholders get when this milestone is complete.}

## Scope

### What's Included

{Brief description of what this milestone covers.}

### What's NOT Included

{Explicitly list what's deferred to future milestones.}

---

## Features

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | [{feature-name}](../features/{feature-file}.md) | Critical | Planning |
| 2 | [{feature-name}](../features/{feature-file}.md) | High | In Progress |
| 3 | [{feature-name}](../features/{feature-file}.md) | Medium | Complete |

### Feature Summary

**Critical (must ship):**
- {Feature 1} - {one-line description}
- {Feature 2} - {one-line description}

**High (should ship):**
- {Feature 3} - {one-line description}

**Medium (nice to have):**
- {Feature 4} - {one-line description}

---

## Dependencies

### Technical Dependencies

Dependencies derived from feature requirements:

| Dependency | Type | Status | Blocking Features |
|------------|------|--------|-------------------|
| {API/Service} | External | Available | {feature-1, feature-2} |
| {Library} | Package | Available | {feature-3} |
| {Feature from another milestone} | Internal | Pending | {feature-4} |

### Milestone Dependencies

Other milestones that must complete before this one:

| Milestone | Reason | Status |
|-----------|--------|--------|
| MILE-{XXX} | {Why it must complete first} | Complete |
| MILE-{XXX} | {Why it must complete first} | In Progress |

### Non-Technical Dependencies

External factors that affect this milestone:

| Dependency | Type | Date/Window | Impact | Mitigation |
|------------|------|-------------|--------|------------|
| {Description} | Maintenance | {Date range} | {What's blocked} | {Workaround} |
| {Description} | Personnel | {Date range} | {What's affected} | {Coverage plan} |
| {Description} | External | {Date/Event} | {What's waiting} | {Alternative} |

**Examples of non-technical dependencies:**
- System maintenance windows
- Team member vacation/unavailability
- Third-party API migrations
- Vendor contract renewals
- External approvals or reviews
- Seasonal business constraints
- Hardware/infrastructure provisioning

---

## Blocked By

{List anything currently blocking progress on this milestone.}

| Blocker | Owner | Expected Resolution | Status |
|---------|-------|---------------------|--------|
| {Blocker description} | {Who can unblock} | {Date} | Active |

---

## Blocks

{Other milestones or work waiting on this milestone.}

| Blocked Item | Type | Impact if Delayed |
|--------------|------|-------------------|
| MILE-{XXX} | Milestone | {Impact} |
| {Feature name} | Feature | {Impact} |

---

## PRD Coverage

{Which PRD requirements does this milestone address?}

| Requirement | Coverage | Notes |
|-------------|----------|-------|
| F1 ({name}) | Complete | {Notes} |
| F2 ({name}) | Partial | {What's covered, what's not} |
| F3 ({name}) | Not Started | Deferred to MILE-{XXX} |

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {Risk} | Low/Med/High | Low/Med/High | {Mitigation} |

---

## Done When

Acceptance criteria for the milestone:

- [ ] All critical features complete and tested
- [ ] {Specific criterion 1}
- [ ] {Specific criterion 2}
- [ ] Documentation updated
- [ ] Stakeholder sign-off

---

## Notes

{Decisions made, context, lessons learned, anything future-you needs to know.}

---

## Revision History

| Date | Change |
|------|--------|
| {Date} | Created |
| {Date} | {Change description} |

---

*Template: docs/templates/milestone.md*
