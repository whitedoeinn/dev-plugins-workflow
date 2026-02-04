# Pattern Detection Interface Spec

**Status:** Draft  
**Purpose:** Define how `/wdi:workflow` detects and applies patterns to features

---

## Core Concept

Patterns are **reusable workflow extensions** that inject phase-specific behavior based on what you're building.

```
Feature Request → Pattern Detection → Pattern Phases Injected → Workflow Runs
```

Not hardcoded `if (specDriven)`. Pluggable. Extensible.

---

## Two Orthogonal Dimensions

### 1. App Patterns (structural)
- **Auto-detectable** from repo structure
- Examples: `spec-driven`, `plugin`, `library`, `monorepo`, `infra`
- Affects: validation, testing, packaging, deployment

### 2. UX Patterns (aesthetic)  
- **Requires human input** (can't be inferred)
- Examples: `clawd-neon`, `warm-craft`, `brutalist-minimal`
- Affects: component styling, design tokens, visual language
- Selected via: explicit flag, fuzzy keywords, or interview

**These compose independently.** A spec-driven app can use any UX pattern.

---

## Pattern Interface

```typescript
interface Pattern {
  id: string;                    // e.g., "spec-driven"
  name: string;                  // e.g., "Spec-Driven Application"
  dimension: "app" | "ux";
  version: string;

  // ─────────────────────────────────────────────
  // DETECTION (how is this pattern selected?)
  // ─────────────────────────────────────────────
  
  detect?: PatternDetector;      // Auto-detection function
  keywords?: string[];           // Fuzzy match triggers
  explicit?: boolean;            // Only via --pattern flag
  
  // ─────────────────────────────────────────────
  // INJECTION (what does this pattern add?)
  // ─────────────────────────────────────────────
  
  phases?: {
    // Inject before/after standard phases
    beforeExplore?: PhaseInjection;
    afterExplore?: PhaseInjection;
    beforeWork?: PhaseInjection;
    afterWork?: PhaseInjection;
    beforeReview?: PhaseInjection;
    afterReview?: PhaseInjection;
  };
  
  reviewCriteria?: string[];     // Additional review agent prompts
  artifacts?: PatternArtifact[]; // Files to generate/validate
  validators?: PatternValidator[]; // Custom validation steps
  
  // ─────────────────────────────────────────────
  // COMPOSABILITY
  // ─────────────────────────────────────────────
  
  composable?: boolean;          // Can stack with others (default: true)
  requires?: string[];           // Must have these patterns too
  conflicts?: string[];          // Cannot combine with these
}
```

---

## Detection Methods

### 1. Auto-Detection (App Patterns)

```typescript
interface PatternDetector {
  // Returns confidence 0-1, or null if doesn't apply
  (context: DetectionContext): number | null;
}

interface DetectionContext {
  repoRoot: string;
  files: string[];              // List of files in repo
  packageJson?: object;         // If exists
  configFiles: string[];        // Found config files
  issueContext?: string;        // Issue title + body
}
```

**Example: spec-driven detector**
```typescript
const specDrivenDetector: PatternDetector = (ctx) => {
  if (ctx.files.includes("specs/flows.json")) return 0.95;
  if (ctx.files.includes("specs/sdd.json")) return 0.90;
  if (ctx.files.some(f => f.startsWith("specs/"))) return 0.70;
  return null;
};
```

### 2. Fuzzy Matching (UX Patterns)

User says: "make it feel warm and approachable"

```typescript
// Pattern definition
{
  id: "warm-craft",
  keywords: ["warm", "cozy", "approachable", "friendly", "artisan", "handmade"]
}

// Matching logic
function fuzzyMatch(input: string, patterns: Pattern[]): Pattern[] {
  const words = input.toLowerCase().split(/\s+/);
  return patterns
    .map(p => ({
      pattern: p,
      score: p.keywords?.filter(k => words.includes(k)).length || 0
    }))
    .filter(m => m.score > 0)
    .sort((a, b) => b.score - a.score)
    .map(m => m.pattern);
}
```

### 3. Explicit Flag

```bash
/wdi:workflow #45 --pattern spec-driven
/wdi:workflow #45 --pattern spec-driven,warm-craft
```

### 4. Interview (when ambiguous)

```
Detected: This looks like a frontend feature.

What vibe are you going for?
  1. Clean & minimal (brutalist-minimal)
  2. Warm & approachable (warm-craft)  
  3. Bold & technical (clawd-neon)
  4. Skip UX pattern
```

---

## Phase Injection

Patterns inject behavior at specific points:

```typescript
interface PhaseInjection {
  name: string;                  // e.g., "Spec Validation"
  description: string;
  
  // What to do
  action: "validate" | "generate" | "prompt" | "custom";
  
  // For validate/generate
  script?: string;               // npm script or command
  artifacts?: string[];          // Files to check/create
  
  // For prompt
  prompt?: string;               // Additional context for AI
  
  // For custom
  handler?: string;              // Path to handler script
  
  // Control flow
  blocking?: boolean;            // Stop workflow if fails (default: true)
  optional?: boolean;            // Can be skipped
}
```

**Example: spec-driven phases**

```typescript
{
  id: "spec-driven",
  phases: {
    beforeWork: {
      name: "Validate Specs",
      action: "validate",
      script: "npm run validate:specs && npm run validate:routes",
      blocking: true
    },
    afterWork: {
      name: "Check Spec Coverage",
      action: "validate", 
      script: "npm run coverage:stories",
      blocking: false  // Warning only
    }
  },
  reviewCriteria: [
    "Do all new routes have corresponding flow specs?",
    "Are user stories testable as written?",
    "Does implementation match spec intent?"
  ]
}
```

---

## Pattern Resolution Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Pattern Resolution                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Explicit patterns from --pattern flag?                  │
│     YES → Use those, skip detection                         │
│     NO  → Continue                                          │
│                                                              │
│  2. Run all app pattern detectors                           │
│     → Collect patterns with confidence > 0.5                │
│     → Auto-select highest confidence per dimension          │
│                                                              │
│  3. UX pattern needed? (frontend work detected)             │
│     YES → Check for keywords in issue/prompt                │
│           Found → Suggest match                              │
│           None  → Interview (unless --headless)             │
│     NO  → Skip UX patterns                                  │
│                                                              │
│  4. Check composability                                      │
│     → Validate no conflicts                                 │
│     → Add required dependencies                             │
│                                                              │
│  5. Return PatternSet                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Pattern Registry

Patterns live in the plugin as markdown + frontmatter:

```
dev-plugins-workflow/
├── patterns/
│   ├── app/
│   │   ├── spec-driven.md
│   │   ├── plugin.md
│   │   ├── library.md
│   │   └── monorepo.md
│   └── ux/
│       ├── clawd-neon.md
│       ├── warm-craft.md
│       └── brutalist-minimal.md
```

**Pattern file format:**

```markdown
---
id: spec-driven
name: Spec-Driven Application
dimension: app
version: 1.0.0

detect:
  files:
    - specs/flows.json      # confidence: 0.95
    - specs/sdd.json        # confidence: 0.90
    - specs/**              # confidence: 0.70

phases:
  beforeWork:
    name: Validate Specs
    script: npm run validate:specs && npm run validate:routes
    blocking: true

reviewCriteria:
  - Do all new routes have corresponding flow specs?
  - Are user stories testable as written?
---

# Spec-Driven Application Pattern

## When This Applies

Your app has a `specs/` folder with:
- `flows.json` — route-to-flow mapping
- `sdd.json` — full spec document
- User stories driving development

## What This Pattern Adds

### Before Work Phase
Validates that specs are internally consistent...

### Review Criteria
Reviewers will specifically check...
```

---

## Integration with Workflow

**In `/wdi:workflow`:**

```
Phase 1: Pre-flight
Phase 2: Learnings Search
Phase 2.5: Pattern Detection    ← NEW
Phase 3: Explore (3 lenses)
Phase 4: Curate
Phase 5: Work
  └─ [pattern.beforeWork injections]
  └─ actual work
  └─ [pattern.afterWork injections]
Phase 6: Review
  └─ standard review
  └─ [pattern.reviewCriteria added]
Phase 7: Compound
```

**Issue comment format:**

```markdown
## Patterns Detected

| Pattern | Dimension | Confidence | Source |
|---------|-----------|------------|--------|
| spec-driven | app | 95% | auto (specs/flows.json) |
| warm-craft | ux | — | explicit (--pattern) |

### Injected Phases
- **Before Work:** Validate Specs (blocking)
- **After Work:** Check Spec Coverage (warning)

### Additional Review Criteria
- Do all new routes have corresponding flow specs?
- Are user stories testable as written?
```

---

## First Patterns to Build

### App Patterns (auto-detect)

| ID | Detects On | Injects |
|----|------------|---------|
| `spec-driven` | `specs/flows.json` | Spec validation, story coverage |
| `plugin` | `.claude-plugin/` or `openclaw.plugin.json` | Plugin packaging, manifest validation |
| `library` | No `src/app`, has `src/index.ts` | API docs generation, export validation |

### UX Patterns (keywords/explicit)

| ID | Keywords | Provides |
|----|----------|----------|
| `clawd-neon` | bold, technical, cyber, neon | Dark theme, accent colors, monospace |
| `warm-craft` | warm, cozy, friendly, artisan | Earth tones, rounded corners, serif accents |

---

## Open Questions

1. **Pattern versioning** — How do we handle pattern updates mid-feature?
2. **Pattern overrides** — Can a repo override a global pattern definition?
3. **Pattern composition limits** — Max patterns? Priority when conflicts?
4. **Headless UX patterns** — Skip or error when UX pattern needed but can't interview?

---

## Next Steps

1. [ ] Finalize this spec (review with Dave)
2. [ ] Create `patterns/` folder structure
3. [ ] Implement `spec-driven` as first pattern
4. [ ] Add pattern detection to workflow command
5. [ ] Defer UX patterns to follow-up
