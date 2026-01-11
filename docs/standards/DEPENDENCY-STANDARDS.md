# Dependency Standards

Standards for documenting and tracking dependencies in features, milestones, and projects.

---

## Dependency Types

### Technical Dependencies

Dependencies on systems, code, or technical resources.

| Type | Description | Examples |
|------|-------------|----------|
| `External` | Third-party API or service | Google Ads API, Stripe, AWS S3, Cloudflare |
| `Internal` | Another feature or milestone | MILE-001, auth-feature, packages/lib-auth |
| `Package` | Library or dependency | react@18, pydantic>=2.0, tailwindcss |
| `Infrastructure` | Environment or platform | Production database, CI/CD pipeline, staging server |
| `Data` | Data migration or availability | Historical data import, schema migration, seed data |

### Non-Technical Dependencies

Dependencies on people, processes, or external events.

| Type | Description | Examples |
|------|-------------|----------|
| `Maintenance` | Scheduled system downtime | Server maintenance window, database upgrade |
| `Personnel` | Team member availability | Vacation, medical leave, contractor end date |
| `Approval` | Sign-off or review required | Legal review, stakeholder approval, security audit |
| `Vendor` | External company dependency | Contract renewal, vendor API migration, support ticket |
| `Event` | External event or deadline | Conference demo, investor meeting, holiday freeze |
| `Resource` | Physical or financial resource | Hardware delivery, budget approval, license renewal |

---

## Dependency Status

| Status | Description |
|--------|-------------|
| `Available` | Dependency is ready, no blocking |
| `Pending` | Dependency expected but not yet available |
| `In Progress` | Dependency actively being worked on |
| `Blocked` | Dependency is stuck, needs intervention |
| `At Risk` | Dependency may not be available on time |
| `N/A` | Dependency no longer applies |

---

## Documenting Dependencies

### In Features

Use the Dependencies section in feature specs:

```markdown
## Dependencies

**Blocked by:**
- [MILE-001](../milestones/MILE-001-dashboard-mvp.md) - Need base dashboard first
- Google Ads API v15 - Requires new reporting endpoints

**Blocks:**
- [real-time-updates](./real-time-updates.md) - Needs this data layer
```

### In Milestones

Use structured tables for clarity:

**Technical Dependencies:**

```markdown
| Dependency | Type | Status | Blocking Features | Notes |
|------------|------|--------|-------------------|-------|
| Google Ads API v15 | External | Available | config-snapshots | Upgraded Jan 5 |
| pydantic>=2.0 | Package | Available | all | Already installed |
| MILE-001 | Internal | Complete | all | Base dashboard done |
| Production DB | Infrastructure | Pending | real-metrics | Provisioning in progress |
```

**Non-Technical Dependencies:**

```markdown
| Dependency | Type | Date/Window | Impact | Mitigation |
|------------|------|-------------|--------|------------|
| AWS maintenance | Maintenance | Jan 15-16 | Deploy blocked | Schedule around it |
| Jane vacation | Personnel | Jan 20-27 | Auth work paused | Defer to MILE-003 |
| Legal review | Approval | By Jan 30 | Can't launch | Started Jan 10 |
| Demo at conference | Event | Feb 1 | Hard deadline | Prioritize critical path |
```

---

## Dependency Tracking

### Blocking Relationships

Use consistent terminology:

| Term | Meaning |
|------|---------|
| **Blocked by** | This item cannot proceed until dependency is resolved |
| **Blocks** | Other items waiting on this item |
| **Depends on** | Softer dependency; can proceed but may need rework |
| **Related to** | Informational; no blocking relationship |

### Transitive Dependencies

When a milestone depends on another milestone, inherit feature dependencies:

```
MILE-002 depends on MILE-001
  └── MILE-001 contains feature-A
      └── feature-A depends on Google Ads API

Therefore: MILE-002 transitively depends on Google Ads API
```

Document transitive dependencies in the milestone's Technical Dependencies table.

### Circular Dependencies

Avoid circular dependencies. If detected:

1. Break into smaller features
2. Identify the minimal viable portion that can ship first
3. Document the intended resolution order

---

## Status Transitions

```
Available ←──────────────────────────────┐
    ↑                                    │
    │ resolved                           │ already available
    │                                    │
Pending ──────→ In Progress ──────→ Available
    │                │
    │ stuck          │ stuck
    ↓                ↓
At Risk ←───── Blocked
    │
    │ resolved or removed
    ↓
   N/A
```

---

## Best Practices

### Do

- **Document early** - Identify dependencies during planning, not when blocked
- **Include dates** - When is the dependency expected to resolve?
- **Name an owner** - Who is responsible for resolving or tracking?
- **Update status** - Keep dependency status current as things change
- **Link to sources** - Reference issues, docs, or external resources

### Don't

- **Assume availability** - Verify external dependencies before committing
- **Hide dependencies** - Undocumented dependencies cause surprises
- **Over-depend** - If everything blocks everything, nothing ships
- **Ignore non-technical** - Personnel and process dependencies are real

---

## Integration with Workflows

### /wdi-workflows:feature

When creating a feature, the workflow prompts for dependencies:
- Blocked by (other features, milestones, external)
- Blocks (what's waiting on this)

### /wdi-workflows:new-package

When creating a package, document package dependencies in pyproject.toml or package.json, but also note external service dependencies in the README.

### Milestone Planning

When creating milestones:
1. List all features in the milestone
2. Aggregate technical dependencies from features
3. Add milestone-level non-technical dependencies
4. Identify the critical path based on blocking relationships

---

## Examples

### Feature with Multiple Dependencies

```markdown
## Dependencies

**Blocked by:**
- [config-snapshots](./config-snapshots.md) - Need snapshot data structure (Internal)
- Google Ads API v15 - Requires campaign.bidding_strategy_system_status field (External)
- Production database provisioned - Need persistent storage (Infrastructure)

**Blocks:**
- [change-alerts](./change-alerts.md) - Needs diff capability from this feature
- MILE-003 - Attribution Clarity milestone waiting on this

**Depends on (soft):**
- json-diff-kit npm package - For visualization, can stub initially (Package)
```

### Milestone with Mixed Dependencies

```markdown
## Dependencies

### Technical Dependencies

| Dependency | Type | Status | Blocking Features | Owner |
|------------|------|--------|-------------------|-------|
| Google Ads API v15 | External | Available | config-snapshots | - |
| MILE-001 | Internal | Complete | all | - |
| Staging environment | Infrastructure | In Progress | smoke-tests | @devops |
| Historical data import | Data | Pending | real-metrics | @data-team |

### Non-Technical Dependencies

| Dependency | Type | Date/Window | Impact | Mitigation | Owner |
|------------|------|-------------|--------|------------|-------|
| AWS us-east-1 maintenance | Maintenance | Jan 15 02:00-06:00 | Deploy blocked | Deploy Jan 14 or Jan 16 | @devops |
| Sarah PTO | Personnel | Jan 18-22 | Frontend work paused | Front-load critical UI | @sarah |
| Security audit sign-off | Approval | By Jan 25 | Can't launch externally | Audit scheduled Jan 20 | @security |
| Investor demo | Event | Jan 30 | Hard deadline | This is the forcing function | @product |
```

---

## Quick Reference

**Technical Types:** External, Internal, Package, Infrastructure, Data

**Non-Technical Types:** Maintenance, Personnel, Approval, Vendor, Event, Resource

**Status Values:** Available, Pending, In Progress, Blocked, At Risk, N/A

**Relationships:** Blocked by, Blocks, Depends on, Related to
