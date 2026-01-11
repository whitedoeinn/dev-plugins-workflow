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

See [DEPENDENCY-STANDARDS.md](../../standards/DEPENDENCY-STANDARDS.md) for type and status definitions.

### Technical Dependencies

Dependencies derived from feature requirements:

| Dependency | Type | Status | Blocking Features | Owner |
|------------|------|--------|-------------------|-------|
| {API/Service} | External | Available | {feature-1, feature-2} | - |
| {Library} | Package | Available | {feature-3} | - |
| {Feature from another milestone} | Internal | Pending | {feature-4} | @{owner} |
| {Database/Server} | Infrastructure | In Progress | {feature-5} | @{owner} |
| {Migration/Import} | Data | Pending | {feature-6} | @{owner} |

**Technical Types:** External, Internal, Package, Infrastructure, Data
**Status Values:** Available, Pending, In Progress, Blocked, At Risk, N/A

### Milestone Dependencies

Other milestones that must complete before this one:

| Milestone | Reason | Status |
|-----------|--------|--------|
| MILE-{XXX} | {Why it must complete first} | Complete |
| MILE-{XXX} | {Why it must complete first} | In Progress |

### Non-Technical Dependencies

External factors that affect this milestone:

| Dependency | Type | Date/Window | Impact | Mitigation | Owner |
|------------|------|-------------|--------|------------|-------|
| {Description} | Maintenance | {Date range} | {What's blocked} | {Workaround} | @{owner} |
| {Description} | Personnel | {Date range} | {What's affected} | {Coverage plan} | @{owner} |
| {Description} | Approval | {Deadline} | {What's waiting} | {Status} | @{owner} |
| {Description} | Vendor | {Date/Event} | {What's affected} | {Alternative} | @{owner} |
| {Description} | Event | {Date} | {Hard deadline} | {Priority adjustment} | @{owner} |
| {Description} | Resource | {Date needed} | {What's blocked} | {Procurement status} | @{owner} |

**Non-Technical Types:** Maintenance, Personnel, Approval, Vendor, Event, Resource

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
