# Frontend Standards

Organization-wide frontend development standards for WDI projects.

**Scope:** Next.js, React, Tailwind CSS, shadcn/ui, Radix primitives

**Related:**
- [compound-engineering frontend-design skill](https://github.com/compound-engineering/claude-code-plugins) - Use for implementation
- [REPO-STANDARDS.md](./REPO-STANDARDS.md) - General repository conventions
- [Issue #76](https://github.com/whitedoeinn/dev-plugins-workflow/issues/76) - Future theme explorations

---

## Table of Contents

1. [Core Principles](#core-principles)
2. [Tech Stack](#tech-stack)
3. [JSON Schema-First Development](#json-schema-first-development)
4. [Design Token System](#design-token-system)
5. [Typography](#typography)
6. [Spacing](#spacing)
7. [Color System](#color-system)
8. [Component Architecture](#component-architecture)
9. [Form Patterns](#form-patterns)
10. [Icon Standards](#icon-standards)
11. [Animation & Motion](#animation--motion)
12. [Accessibility](#accessibility)
13. [Responsive Design](#responsive-design)
14. [Theme System](#theme-system)
15. [Anti-Patterns](#anti-patterns)
16. [Workflow Integration](#workflow-integration)
17. [Stack-Specific Guidance](#stack-specific-guidance)
18. [Decision Record](#decision-record)

---

## Core Principles

1. **Schema-first**: Data schema is the source of truth. UI derives from it.
2. **Portable tokens**: Design decisions in CSS custom properties, not hardcoded values.
3. **Component composition**: Build complex UIs from simple, tested primitives.
4. **Accessibility by default**: WCAG 2.1 AA compliance is non-negotiable.
5. **Minimal over expressive**: Prefer proven patterns over stylistic experiments.

---

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Next.js | 14+ (App Router) |
| Runtime | React | 19+ |
| Styling | Tailwind CSS | v4 |
| Components | shadcn/ui | Latest |
| Primitives | Radix UI | Latest |
| Icons | Lucide React | Latest |
| Validation | Ajv | 8+ |
| Types | TypeScript | 5+ |

### Installation

```bash
# New project setup
npx create-next-app@latest my-app --typescript --tailwind --eslint --app

# Add shadcn/ui
npx shadcn-ui@latest init

# Add validation
npm install ajv json-schema-to-ts
```

---

## JSON Schema-First Development

**Core principle:** Data schema is the source of truth. UI derives from it.

### Workflow

```
JSON Schema → TypeScript Types → Components → Validation
     ↓              ↓               ↓            ↓
data.schema.json  json-schema-to-ts  Props match   Ajv runtime
                                     schema shape  validation
```

### Schema Location

```
src/
├── schemas/
│   ├── task.schema.json      # Task data structure
│   ├── user.schema.json      # User data structure
│   └── config.schema.json    # App configuration
├── types/
│   └── schema.ts             # Generated types (derived from schemas)
```

### TypeScript Types (Derived, Not Manual)

```typescript
// src/types/schema.ts
import { FromSchema } from 'json-schema-to-ts';
import taskSchema from '../schemas/task.schema.json';
import userSchema from '../schemas/user.schema.json';

export type Task = FromSchema<typeof taskSchema>;
export type User = FromSchema<typeof userSchema>;
```

### Schema Extensions for UI Metadata

Use `x-` prefixed custom properties for UI hints:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["pending", "in-progress", "completed"],
      "x-color": {
        "pending": "#f59e0b",
        "in-progress": "#3b82f6",
        "completed": "#22c55e"
      },
      "x-icon": {
        "pending": "clock",
        "in-progress": "loader",
        "completed": "check"
      }
    },
    "priority": {
      "type": "string",
      "enum": ["low", "medium", "high"],
      "x-label": {
        "low": "Low Priority",
        "medium": "Medium Priority",
        "high": "High Priority"
      }
    }
  }
}
```

### Component Props Match Schema

```typescript
import { Task } from '@/types/schema';

interface TaskCardProps {
  task: Task;  // Props derive from schema-generated type
  onUpdate?: (task: Task) => void;
}

export function TaskCard({ task, onUpdate }: TaskCardProps) {
  // Component implementation
}
```

### Runtime Validation with Ajv

```typescript
import Ajv from 'ajv';
import taskSchema from '@/schemas/task.schema.json';

const ajv = new Ajv({ allErrors: true });
const validateTask = ajv.compile(taskSchema);

export function validateTaskData(data: unknown): data is Task {
  const valid = validateTask(data);
  if (!valid) {
    console.error('Validation errors:', validateTask.errors);
  }
  return valid;
}

// Usage in form submission
function handleSubmit(formData: FormData) {
  const data = Object.fromEntries(formData);

  if (!validateTaskData(data)) {
    // Show validation errors from validateTask.errors
    return;
  }

  // Proceed with valid data
  saveTask(data);
}
```

### Benefits

- **Single source of truth** for data structure
- **Compile-time and runtime** type safety
- **UI automatically reflects** data changes
- **Validation rules defined once**, used everywhere
- **Schema extensions** keep UI metadata with data definition

---

## Design Token System

All design decisions use CSS custom properties. Import from `assets/tokens/tokens.css`.

### Token Categories

| Category | Prefix | Example |
|----------|--------|---------|
| Colors | `--color-*` | `--color-primary` |
| Spacing | `--space-*` | `--space-4` |
| Typography | `--text-*`, `--font-*` | `--text-base`, `--font-body` |
| Radius | `--radius-*` | `--radius-md` |
| Shadows | `--shadow-*` | `--shadow-md` |

### Using Tokens in Tailwind

Tokens are mapped to Tailwind via `@theme inline` in `globals.css`:

```css
@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  /* ... */
}
```

Use Tailwind classes that reference these tokens:

```tsx
// Good - uses token via Tailwind
<div className="bg-background text-foreground border-border">

// Bad - hardcoded values
<div style={{ background: '#ffffff', color: '#000000' }}>
```

---

## Typography

### Scale

Based on 4px grid with clear hierarchy:

| Token | Size | Rem | Use Case |
|-------|------|-----|----------|
| `--text-xs` | 12px | 0.75rem | Captions, labels, timestamps |
| `--text-sm` | 14px | 0.875rem | Secondary text, descriptions |
| `--text-base` | 16px | 1rem | Body text (default) |
| `--text-lg` | 18px | 1.125rem | Lead paragraphs |
| `--text-xl` | 20px | 1.25rem | H4, section headings |
| `--text-2xl` | 24px | 1.5rem | H3 |
| `--text-3xl` | 30px | 1.875rem | H2 |
| `--text-4xl` | 36px | 2.25rem | H1, page titles |
| `--text-5xl` | 48px | 3rem | Display, hero text |

### Line Heights

| Size | Line Height | Ratio |
|------|-------------|-------|
| xs-sm | 1.5 | Readable small text |
| base-lg | 1.6 | Optimal body text |
| xl-5xl | 1.2-1.3 | Tight headings |

### Font Stacks

```css
--font-display: var(--font-inter), system-ui, sans-serif;
--font-body: var(--font-inter), system-ui, sans-serif;
--font-mono: "SF Mono", "JetBrains Mono", monospace;
```

### Usage in Components

```tsx
// Headings use display font
<h1 className="text-4xl font-display font-bold">Page Title</h1>
<h2 className="text-3xl font-display font-semibold">Section</h2>

// Body uses body font (default)
<p className="text-base">Body text paragraph.</p>

// Code uses mono
<code className="font-mono text-sm">const x = 1;</code>
```

### Inter Font Guidance

Inter is the default for data-dense UIs (dashboards, admin panels). For marketing pages or brand-focused content, consider distinctive fonts per project requirements.

---

## Spacing

### Scale

Based on 4px unit:

| Token | Size | Pixels | Use Case |
|-------|------|--------|----------|
| `--space-0` | 0 | 0px | Reset |
| `--space-0.5` | 0.125rem | 2px | Hairline gaps |
| `--space-1` | 0.25rem | 4px | Tight inline spacing |
| `--space-2` | 0.5rem | 8px | Component padding (sm) |
| `--space-3` | 0.75rem | 12px | Component padding (md) |
| `--space-4` | 1rem | 16px | Component padding (lg), gaps |
| `--space-5` | 1.25rem | 20px | Section gaps |
| `--space-6` | 1.5rem | 24px | Card padding |
| `--space-8` | 2rem | 32px | Section spacing |
| `--space-10` | 2.5rem | 40px | Large gaps |
| `--space-12` | 3rem | 48px | Page sections |
| `--space-16` | 4rem | 64px | Major sections |
| `--space-20` | 5rem | 80px | Hero spacing |
| `--space-24` | 6rem | 96px | Max section gap |

### Spacing Patterns

```tsx
// Card padding
<div className="p-6">  {/* 24px all sides */}

// Button padding
<button className="px-4 py-2">  {/* 16px horizontal, 8px vertical */}

// Stack spacing
<div className="space-y-4">  {/* 16px between children */}

// Grid gap
<div className="grid gap-6">  {/* 24px grid gap */}

// Section margin
<section className="mt-12">  {/* 48px top margin */}
```

---

## Color System

### Semantic Colors

Each theme defines these semantic color tokens:

| Token | Purpose |
|-------|---------|
| `--background` | Page background |
| `--foreground` | Primary text |
| `--card` | Card/surface background |
| `--card-foreground` | Card text |
| `--primary` | Primary actions, links |
| `--primary-foreground` | Text on primary |
| `--secondary` | Secondary actions |
| `--secondary-foreground` | Text on secondary |
| `--muted` | Muted backgrounds |
| `--muted-foreground` | Secondary text |
| `--accent` | Accent highlights |
| `--accent-foreground` | Text on accent |
| `--border` | Borders |
| `--input` | Input borders |
| `--ring` | Focus rings |

### Status Colors

| Token | Purpose | WCAG Contrast |
|-------|---------|---------------|
| `--success` | Success states | 4.5:1 on background |
| `--warning` | Warning states | 4.5:1 on background |
| `--destructive` | Error/danger | 4.5:1 on background |

### Chart Colors

Sequential palette for data visualization:

| Token | Use |
|-------|-----|
| `--chart-1` | Primary series |
| `--chart-2` | Secondary series |
| `--chart-3` | Tertiary series |
| `--chart-4` | Quaternary series |
| `--chart-5` | Quinary series |

### Schema-Driven Colors

When colors are defined in JSON Schema extensions, read them programmatically:

```typescript
import taskSchema from '@/schemas/task.schema.json';

function getStatusColor(status: string): string {
  const colors = taskSchema.properties.status['x-color'] as Record<string, string>;
  return colors[status] ?? 'var(--muted)';
}

// Usage
<Badge style={{ backgroundColor: getStatusColor(task.status) }}>
  {task.status}
</Badge>
```

---

## Component Architecture

### Use shadcn/ui Components

Always prefer shadcn/ui components over custom implementations:

```tsx
// Good - use shadcn/ui
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";

// Bad - custom implementation when shadcn exists
function MyButton({ children }) { ... }
```

### Component File Structure

```
src/components/
├── ui/                    # shadcn/ui primitives (don't modify)
│   ├── button.tsx
│   ├── card.tsx
│   └── ...
├── features/              # Feature-specific components
│   ├── task-card.tsx
│   ├── user-avatar.tsx
│   └── ...
└── layouts/               # Layout components
    ├── sidebar.tsx
    ├── header.tsx
    └── ...
```

### Composition Patterns

**Card with Header and Actions:**

```tsx
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
    <CardDescription>Description</CardDescription>
  </CardHeader>
  <CardContent>
    {/* Content */}
  </CardContent>
  <CardFooter className="flex justify-end gap-2">
    <Button variant="outline">Cancel</Button>
    <Button>Save</Button>
  </CardFooter>
</Card>
```

**Form with Validation:**

```tsx
<form onSubmit={handleSubmit}>
  <div className="space-y-4">
    <div className="space-y-2">
      <Label htmlFor="email">Email</Label>
      <Input
        id="email"
        type="email"
        aria-describedby="email-error"
        aria-invalid={!!errors.email}
      />
      {errors.email && (
        <p id="email-error" className="text-sm text-destructive">
          {errors.email}
        </p>
      )}
    </div>
    <Button type="submit">Submit</Button>
  </div>
</form>
```

**Data Table Row:**

```tsx
<TableRow className="data-row">
  <TableCell>{item.name}</TableCell>
  <TableCell>
    <Badge variant={getStatusVariant(item.status)}>
      {item.status}
    </Badge>
  </TableCell>
  <TableCell className="text-right">
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon">
          <MoreHorizontal className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem>Edit</DropdownMenuItem>
        <DropdownMenuItem className="text-destructive">Delete</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  </TableCell>
</TableRow>
```

---

## Form Patterns

### Field States

| State | Visual Treatment |
|-------|-----------------|
| Default | `border-input` |
| Focus | `ring-2 ring-ring` |
| Error | `border-destructive` + error icon + message |
| Success | `border-success` + checkmark (optional) |
| Disabled | `opacity-50 cursor-not-allowed` |

### Error Display

```tsx
<div className="space-y-2">
  <Label htmlFor="email">
    Email <span className="text-destructive">*</span>
  </Label>
  <div className="relative">
    <Input
      id="email"
      className={cn(
        errors.email && "border-destructive pr-10"
      )}
      aria-describedby={errors.email ? "email-error" : "email-hint"}
      aria-invalid={!!errors.email}
    />
    {errors.email && (
      <AlertCircle className="absolute right-3 top-3 h-4 w-4 text-destructive" />
    )}
  </div>
  {errors.email ? (
    <p id="email-error" className="text-sm text-destructive flex items-center gap-1">
      <AlertCircle className="h-3 w-3" />
      {errors.email}
    </p>
  ) : (
    <p id="email-hint" className="text-sm text-muted-foreground">
      We'll never share your email.
    </p>
  )}
</div>
```

### Validation Timing

| Event | Action |
|-------|--------|
| Blur | Validate field (primary) |
| Change | Clear existing error if valid |
| Submit | Validate all fields |

**Do not** validate on every keystroke (annoying UX).

### Required Fields

Mark required fields with asterisk in label:

```tsx
<Label>
  Name <span className="text-destructive">*</span>
</Label>
```

### Form Layout

```tsx
// Single column (mobile-first)
<form className="space-y-4 max-w-md">

// Two column on desktop
<form className="space-y-4 max-w-2xl">
  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
    <Field />
    <Field />
  </div>
</form>
```

---

## Icon Standards

### Sizes

| Size | Pixels | Use Case |
|------|--------|----------|
| 12px | `h-3 w-3` | Inline with small text |
| 16px | `h-4 w-4` | Inline with body text, small buttons |
| 20px | `h-5 w-5` | Buttons, inputs |
| 24px | `h-6 w-6` | Standalone, navigation |
| 32px | `h-8 w-8` | Empty states, illustrations |
| 48px+ | `h-12 w-12` | Hero sections, major callouts |

### Icon Library

Use [Lucide React](https://lucide.dev/):

```tsx
import { Check, X, AlertCircle, Loader2 } from "lucide-react";

// Button with icon
<Button>
  <Check className="h-4 w-4 mr-2" />
  Save
</Button>

// Icon button
<Button variant="ghost" size="icon">
  <X className="h-4 w-4" />
  <span className="sr-only">Close</span>
</Button>

// Loading state
<Button disabled>
  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
  Saving...
</Button>
```

### Accessibility

Always provide accessible names for icon-only elements:

```tsx
// Good
<Button variant="ghost" size="icon" aria-label="Close dialog">
  <X className="h-4 w-4" />
</Button>

// Also good (sr-only text)
<Button variant="ghost" size="icon">
  <X className="h-4 w-4" />
  <span className="sr-only">Close dialog</span>
</Button>

// Bad - no accessible name
<Button variant="ghost" size="icon">
  <X className="h-4 w-4" />
</Button>
```

---

## Animation & Motion

### Principles

1. **Purpose**: Animation should guide attention, not decorate
2. **Duration**: 150-300ms for micro-interactions, 300-500ms for page transitions
3. **Easing**: Use `cubic-bezier(0.22, 1, 0.36, 1)` for natural movement

### Built-in Animations

From `globals.css`:

```tsx
// Fade in with upward movement
<div className="animate-fade-in-up">Content</div>

// Scale in (good for modals)
<div className="animate-scale-in">Modal content</div>

// Staggered children
<div className="animate-fade-in-up stagger-1">First</div>
<div className="animate-fade-in-up stagger-2">Second</div>
<div className="animate-fade-in-up stagger-3">Third</div>
```

### Hover Effects

```tsx
// Card lift on hover
<Card className="card-hover">
  {/* Lifts 4px on hover */}
</Card>

// Row highlight
<TableRow className="data-row">
  {/* Background changes on hover */}
</TableRow>
```

### Reduced Motion

Always respect user preferences:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Accessibility

### Target: WCAG 2.1 AA

| Criterion | Requirement |
|-----------|-------------|
| Color contrast (text) | 4.5:1 minimum |
| Color contrast (UI) | 3:1 minimum |
| Focus visible | 3px ring, visible on all backgrounds |
| Keyboard navigation | All interactive elements reachable |
| Screen readers | Proper ARIA labels and roles |

### Focus Styles

```css
/* Default focus style (from tokens) */
:focus-visible {
  outline: 2px solid var(--ring);
  outline-offset: 2px;
}
```

### Keyboard Navigation

Ensure all interactive elements are keyboard accessible:

```tsx
// Good - native button
<button onClick={handleClick}>Click me</button>

// Good - Radix handles keyboard
<Dialog.Trigger asChild>
  <Button>Open</Button>
</Dialog.Trigger>

// Bad - div as button without keyboard support
<div onClick={handleClick}>Click me</div>
```

### ARIA Patterns

```tsx
// Form field
<Label htmlFor="name">Name</Label>
<Input
  id="name"
  aria-describedby="name-hint name-error"
  aria-invalid={!!error}
/>
<p id="name-hint">Enter your full name</p>
<p id="name-error" role="alert">{error}</p>

// Loading state
<Button disabled aria-busy="true">
  <Loader2 className="animate-spin" aria-hidden="true" />
  Loading...
</Button>

// Icon button
<Button aria-label="Close" size="icon">
  <X aria-hidden="true" />
</Button>
```

### Testing

Use these tools:
- axe DevTools browser extension
- Lighthouse accessibility audit
- VoiceOver (macOS) / NVDA (Windows) manual testing

---

## Responsive Design

### Breakpoints

| Prefix | Min Width | Target |
|--------|-----------|--------|
| (none) | 0px | Mobile (default) |
| `sm:` | 640px | Large phones |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large screens |

### Mobile-First Approach

Always start with mobile styles, then add breakpoints:

```tsx
// Good - mobile first
<div className="p-4 md:p-6 lg:p-8">
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

// Bad - desktop first (requires overrides)
<div className="p-8 sm:p-4">
```

### Common Patterns

```tsx
// Stack to row
<div className="flex flex-col md:flex-row gap-4">

// Full width to constrained
<div className="w-full max-w-md mx-auto">

// Hide on mobile
<nav className="hidden md:flex">

// Show only on mobile
<Button className="md:hidden">Menu</Button>
```

---

## Theme System

### Available Themes

Six production-ready minimal themes:

| Theme | Inspiration | Best For |
|-------|-------------|----------|
| `precision` | Linear, Raycast | Dense data apps, power users |
| `warmth` | Notion, Coda | Content apps, documentation |
| `sophistication` | Stripe, Mercury | Financial apps, SaaS dashboards |
| `boldness` | Vercel | Developer tools, marketing |
| `utility` | GitHub | Development tools, utilities |
| `data` | BI/Analytics | Charts, dashboards, reporting |

### Theme Selection

Choose based on:
1. **Target users**: Power users → precision/data; General users → warmth/utility
2. **Content type**: Data-heavy → data; Content-focused → warmth
3. **Brand positioning**: Premium → sophistication; Bold → boldness

### Implementation

```tsx
// Theme provider wraps app
import { ThemeProvider } from "@/components/theme-provider";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}

// Use theme in components
import { useTheme } from "@/components/theme-provider";

function ThemeSwitcher() {
  const { theme, setTheme } = useTheme();
  return (
    <Select value={theme} onValueChange={setTheme}>
      {/* Theme options */}
    </Select>
  );
}
```

### Theme CSS Structure

Themes use `data-direction` attribute:

```css
[data-direction="precision"] {
  --background: #0a0a0a;
  --foreground: #fafafa;
  /* ... */
}
```

---

## Anti-Patterns

### Avoid These

| Anti-Pattern | Instead |
|--------------|---------|
| Hardcoded colors | Use CSS custom properties |
| Custom components when shadcn exists | Use shadcn/ui |
| Inline styles | Use Tailwind classes |
| px units for spacing | Use spacing tokens |
| Manual TypeScript types for data | Derive from JSON Schema |
| Validation logic in components | Use Ajv with schema |
| Animation without reduced-motion support | Always include prefers-reduced-motion |
| Icon buttons without labels | Always add aria-label |
| Form validation on change | Validate on blur |
| Desktop-first responsive | Mobile-first always |

### Code Examples

```tsx
// BAD
<div style={{ padding: '20px', backgroundColor: '#f5f5f5' }}>

// GOOD
<div className="p-5 bg-muted">
```

```tsx
// BAD - manual type
interface Task {
  id: string;
  status: 'pending' | 'done';
}

// GOOD - derived from schema
import { Task } from '@/types/schema';
```

```tsx
// BAD - validation in component
function validate(data) {
  if (!data.email.includes('@')) return 'Invalid email';
}

// GOOD - schema-based validation
import { validateTaskData } from '@/lib/validation';
if (!validateTaskData(data)) {
  // Use validateTask.errors
}
```

---

## Workflow Integration

### Enhanced Ralph Detection

When `/wdi:workflow-enhanced-ralph` detects UI tasks, it:

1. References `FRONTEND-STANDARDS.md` for conventions
2. Invokes `frontend-design` skill for implementation
3. Runs `design-implementation-reviewer` for verification

### Task Type Detection

Tasks are tagged `[ui]` when containing keywords:
- component, page, render, display, show
- chart, modal, form, button, input

### Quality Gates

UI tasks pass through:

1. **Implementation**: `frontend-design` skill
2. **Verification**: `playwright-test` for rendering
3. **Review**: `design-implementation-reviewer` for visual quality

See [workflow-enhanced-ralph.md](../../commands/workflow-enhanced-ralph.md) for full workflow.

---

## Stack-Specific Guidance

### When Using Next.js/React (WDI Default)

- Follow this document
- Use Tailwind + shadcn
- JSON Schema-first for data

### When Using Rails/Hotwire

- Refer to compound-engineering's `dhh-rails-style` skill
- Use vanilla CSS with OKLCH colors
- ViewComponents for component architecture
- Stimulus for interactivity

| Aspect | Next.js/React | Rails/Hotwire |
|--------|---------------|---------------|
| CSS | Tailwind | Vanilla + OKLCH |
| Components | shadcn/ui | ViewComponents |
| Interactivity | React hooks | Stimulus |
| Styling reference | This document | DHH Rails style |

---

## Decision Record

### Why These Standards?

**JSON Schema-first**: Prevents drift between backend data, frontend types, and validation rules. Single source of truth reduces bugs and maintenance.

**Tailwind over vanilla CSS**: Better developer experience for component-heavy React apps. Utility-first matches component model.

**shadcn/ui over custom components**: Production-tested, accessible, customizable. Don't reinvent wheels.

**6 minimal themes over 9 total**: Expressive themes (ledger, greenhouse, postcard) are experimental. Standards should only include proven patterns. Experiments live in project repos, not org-wide standards.

**Inter font as default**: Excellent for data-dense UIs, which is the primary WDI use case. Projects can override for brand pages.

**4px spacing unit**: Industry standard, aligns with Tailwind defaults, provides sufficient granularity without overwhelming choice.

**WCAG 2.1 AA target**: Legal baseline for accessibility in many jurisdictions. Higher target (AAA) deferred to project-specific requirements.

### Future Considerations

Tracked in [Issue #76](https://github.com/whitedoeinn/dev-plugins-workflow/issues/76):
- Dark mode toggle implementation
- Expressive theme promotion criteria
- i18n/RTL support patterns
- Additional component composition recipes
